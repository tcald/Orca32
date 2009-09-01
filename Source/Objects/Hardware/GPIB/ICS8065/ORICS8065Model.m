//
//  ORICS8065Model.m
//  Orca
//
//  Created by Mark Howe on Friday, June 20, 2008.
//  Copyright (c) 2003 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this softwagre.
//-------------------------------------------------------------

#pragma mark ***Imported Files
#include <stdio.h>
#import "ORICS8065Model.h"

#pragma mark ***Defines
#define k8065CorePort 5555

NSString*   ORICS8065ModelCommandChanged		= @"ORICS8065ModelCommandChanged";
NSString*   ORICS8065PrimaryAddressChanged		= @"ORICS8065PrimaryAddressChanged";
NSString*	ORICS8065Connection					= @"ICS865OutputConnector";
NSString*	ORICS8065TestLock					= @"ORICS8065TestLock";
NSString*	ORGpib1MonitorNotification			= @"ORGpib1MonitorNotification";
NSString*	ORGpib1Monitor						= @"ORGpib1Monitor";
NSString*	ORGPIB1BoardChangedNotification		= @"ORGPIB1BoardChangedNotification";
NSString*	ORICS8065ModelIsConnectedChanged	= @"ORICS8065ModelIsConnectedChanged";
NSString*	ORICS8065ModelIpAddressChanged		= @"ORICS8065ModelIpAddressChanged";

@implementation ORICS8065Model
#pragma mark ***Initialization
- (void) commonInit
{
    short 	i;
    
	theHWLock = [[NSRecursiveLock alloc] init];    
    
    mErrorMsg = [[NSMutableString alloc] initWithFormat: @""];
    
    for ( i = 0; i < kMaxGpibAddresses; i++ ){
        memset(&mDeviceLink[i],0,sizeof(Create_LinkResp));
    } 
    
}

- (id) init
{
    self = [super init];
    
    [self commonInit];
    
    return self;   
}


- (void) dealloc
{
    [command release];
	int i;
    for ( i = 0; i < kMaxGpibAddresses; i++ ){
        if ( mDeviceLink[i].lid != 0 ){
			[self deactivateDevice:i];
		}
	} 
	
	if(rpcClient)clnt_destroy(rpcClient);
    [theHWLock release];
    [mErrorMsg release];
    [super dealloc];
}

- (void) awakeAfterDocumentLoaded
{
	@try {
		[self connect];
		[self connectionChanged];
	}
	@catch(NSException* localException) {
	}
}

- (void) setUpImage
{
    NSImage* aCachedImage = [NSImage imageNamed:@"ICS8065Box"];
    NSImage* i = [[NSImage alloc] initWithSize:[aCachedImage size]];
    [i lockFocus];
    [aCachedImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
    
    if(![self isEnabled]){
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path moveToPoint:NSZeroPoint];
        [path lineToPoint:NSMakePoint([self frame].size.width,[self frame].size.height)];
        [path moveToPoint:NSMakePoint([self frame].size.width,0)];
        [path lineToPoint:NSMakePoint(0,[self frame].size.height)];
        [path setLineWidth:2];
        [[NSColor redColor] set];
        [path stroke];
    }
    [i unlockFocus];
    
    [self setImage:i];
}

- (void) makeConnectors
{
	ORConnector* connectorObj = [[ORConnector alloc] initAt: NSMakePoint([self frame].size.width - kConnectorSize, 20 ) withGuardian: self];
	[connectorObj setConnectorType: 'GPI2'];
	[connectorObj addRestrictedConnectionType: 'GPI1']; //can only connect to gpib inputs
	[[self connectors] setObject: connectorObj forKey: ORICS8065Connection];
	[connectorObj release];
}

- (void) makeMainController
{
    [self linkToController: @"ORICS8065Controller"];
}

#pragma mark ***Accessors

- (NSString*) command
{
	if(!command)return @"";
    else return command;
}

- (void) setCommand:(NSString*)aCommand
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCommand:command];
    
    [command autorelease];
    command = [aCommand copy];    
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORICS8065ModelCommandChanged object:self];
}

- (int) primaryAddress
{
    return primaryAddress;
}

- (void) setPrimaryAddress:(int)aPrimaryAddress
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPrimaryAddress:primaryAddress];
    
    primaryAddress = aPrimaryAddress;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORICS8065PrimaryAddressChanged object:self];
}

- (BOOL) isEnabled
{
    return YES;
}

- (CLIENT*) rpcClient
{
	return rpcClient;
}

- (void) setRpcClient:(CLIENT*)anRpcClient
{
	if(rpcClient)clnt_destroy(rpcClient);
	
	rpcClient = anRpcClient;
}

- (void) setIsConnected:(BOOL)aFlag
{
    isConnected = aFlag;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORICS8065ModelIsConnectedChanged object:self];
}

- (NSString*) ipAddress
{
	if(!ipAddress)return @"";
    else return ipAddress;
}

- (void) setIpAddress:(NSString*)aIpAddress
{
	if(!aIpAddress)aIpAddress = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setIpAddress:ipAddress];
    
    [ipAddress autorelease];
    ipAddress = [aIpAddress copy];    
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORICS8065ModelIpAddressChanged object:self];
}


- (void) connect
{
	if(!isConnected){
		CLIENT* aClient = clnt_create((char*)[ipAddress cStringUsingEncoding:NSASCIIStringEncoding],DEVICE_CORE,DEVICE_CORE_VERSION, "TCP");
		[self setRpcClient:aClient];	
        [self setIsConnected: aClient!=nil];
		
	}
	else {
		[self setRpcClient:nil];	
        [self setIsConnected:rpcClient!=nil];
		int i;
		for( i=0; i<kMaxGpibAddresses; i++ ){
			if(mDeviceLink[i].lid != 0){
				[self deactivateDevice:i];
			}
		} 
	}
}

- (BOOL) isConnected
{
	return isConnected;
}


- (NSMutableString*) errorMsg
{
    return( mErrorMsg );
}

#pragma mark ***Basic commands
- (void) changeState: (short) aPrimaryAddress online: (BOOL) aState
{
}

- (BOOL) checkAddress: (short) aPrimaryAddress
{
    BOOL  bRetVal = false;
    if ( ! [self isEnabled]) return bRetVal;
    @try {
        [theHWLock lock];   //-----begin critical section
        // Check if device has been setup.
        if ( mDeviceLink[aPrimaryAddress].lid != 0 ){
            bRetVal = true;
        }
		
        [theHWLock unlock];   //-----end critical section
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
    
    return( bRetVal );    
}


- (void) enableEOT:(short)aPrimaryAddress state: (BOOL) state
{
	
}

- (void) resetDevice: (short) aPrimaryAddress
{
}

- (void) setGPIBMonitorRead: (bool) aMonitorRead
{
	mMonitorRead = aMonitorRead;
}

- (void) setGPIBMonitorWrite: (bool) aMonitorWrite
{
	mMonitorWrite = aMonitorWrite;
}

- (void) 	setupDevice: (short) aPrimaryAddress secondaryAddress: (short) aSecondaryAddress
{
	[self setupDevice:aPrimaryAddress];
}

- (void) setupDevice: (short) aPrimaryAddress
{  
    if(![self isEnabled])return;
	if(mDeviceLink[aPrimaryAddress].lid != 0) return; //already setup  
	
    @try {
        [theHWLock lock];   //-----begin critical section
		
		Create_LinkParms crlp;
		crlp.clientId = (long)rpcClient;
		crlp.lockDevice = 0;
		crlp.lock_timeout = 3000;
		char device[64];
		sprintf(device,"gpib0,%d",aPrimaryAddress);
		crlp.device = device;
		memcpy(&mDeviceLink[aPrimaryAddress], create_link_1(&crlp, rpcClient),sizeof(Create_LinkResp));
        [theHWLock unlock];   //-----end critical section
		
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
    
}

- (void) deactivateDevice: (short) aPrimaryAddress
{
    if( ![self isEnabled]) return;
    @try {
        [theHWLock lock];   //-----begin critical section
		
		if ( mDeviceLink[aPrimaryAddress].lid != 0 ){
			// Deactivate the device
			destroy_link_1(&mDeviceLink[aPrimaryAddress].lid,rpcClient);
			memset(&mDeviceLink[aPrimaryAddress],0,sizeof(Create_LinkResp));
		}
		
        [theHWLock unlock];   //-----end critical section
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
    
}

- (long) readFromDevice: (short) aPrimaryAddress data: (char*) aData maxLength: (long) aMaxLength
{
	
    if ( ! [self isEnabled]) return 0;
    long	nReadBytes = 0;
    
    @try {
        // Make sure that device is initialized.
        [theHWLock lock];   //-----begin critical section
		if ( mDeviceLink[aPrimaryAddress].lid == 0 ){
			[self setupDevice:aPrimaryAddress];
		}
        
	    //double t0 = [NSDate timeIntervalSinceReferenceDate];
	    //while([NSDate timeIntervalSinceReferenceDate]-t0 < .01);
        
        // Perform the read.				
		Device_ReadParms  dwrp; 
		Device_ReadResp*  dwrr; 
		dwrp.lid = mDeviceLink[aPrimaryAddress].lid; 
		dwrp.requestSize = aMaxLength;
		dwrp.io_timeout = 3000; 
		dwrp.lock_timeout = 3000;
		dwrp.flags = 0;
		dwrp.termChar = '\n';
		dwrr = device_read_1(&dwrp, rpcClient); 
		
		//To do: There has to be some serious error checking put in here, asap.....
		memcpy(aData,dwrr->data.data_val,dwrr->data.data_len);
        if (dwrr->error != 0) {
            [mErrorMsg setString:  @"***Error: read"];
            [self gpibError: mErrorMsg number:dwrr->error]; 
            [NSException raise: OExceptionGpibError format: @"%@",mErrorMsg];
        }
        
        // Successful read.
        else {
            nReadBytes = dwrr->data.data_len;
			aData[nReadBytes] = '\0';
			
            // Allow monitoring of commands.
            if ( mMonitorRead ) {
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];	
                NSString* dataStr = [[NSString alloc] initWithBytes: aData length: nReadBytes encoding: NSASCIIStringEncoding];
                [userInfo setObject: [NSString stringWithFormat: @"Read - Address: %d length: %d data: %@\n", 
									  aPrimaryAddress, nReadBytes, dataStr] 
							 forKey: ORGpib1Monitor]; 
                
                [[NSNotificationCenter defaultCenter]
				 postNotificationName: ORGpib1MonitorNotification
				 object: self
				 userInfo: userInfo];
                [dataStr release];
            }
            
        }
        [theHWLock unlock];   //-----end critical section
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
	
    return nReadBytes;
}



- (void) writeToDevice: (short) aPrimaryAddress command: (NSString*) aCommand
{
    if ( ! [self isEnabled]) return;
    @try {
        [theHWLock lock];   //-----begin critical section
		// Make sure that device is initialized.
		if ( mDeviceLink[aPrimaryAddress].lid == 0 ){
			[self setupDevice:aPrimaryAddress];
		}
        
        // Allow monitoring of commands.
        if ( mMonitorWrite ) {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject: [NSString stringWithFormat: @"Write - Address: %d Comm: %s\n", aPrimaryAddress, [aCommand cStringUsingEncoding:NSASCIIStringEncoding]] 
						 forKey: ORGpib1Monitor]; 
            
            [[NSNotificationCenter defaultCenter]
			 postNotificationName: ORGpib1MonitorNotification
			 object: self
			 userInfo: userInfo];
        }
        
        //	printf( "Command %s\n", [aCommand cString] );
        
        // Write to device.
		
		Device_WriteParms  dwrp; 
		Device_WriteResp*  dwrr; 
		dwrp.lid = mDeviceLink[aPrimaryAddress].lid; 
		dwrp.io_timeout = 3000; 
		dwrp.lock_timeout = 3000;
		dwrp.flags = 0;
		if(![aCommand hasSuffix:@"\n"])aCommand = [aCommand stringByAppendingString:@"\n"];
		dwrp.data.data_len = [aCommand length];
		dwrp.data.data_val = (char *)[aCommand cStringUsingEncoding:NSASCIIStringEncoding];
		dwrr = device_write_1(&dwrp, rpcClient); 
		
        if (dwrr &&  dwrr->error != 0 ) {
            [mErrorMsg setString:  @"***Error: write"];
            [self gpibError: mErrorMsg number: dwrr->error]; 
            [NSException raise: OExceptionGpibError format: @"%@",mErrorMsg];
        }  
        [theHWLock unlock];   //-----end critical section
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }  
	
}


- (long) writeReadDevice: (short) aPrimaryAddress command: (NSString*) aCommand data: (char*) aData
               maxLength: (long) aMaxLength
{
    long retVal = 0;
    if ( ! [self isEnabled]) return -1;
    @try {
        
        [theHWLock lock];   //-----begin critical section
        [self writeToDevice: aPrimaryAddress command: aCommand];
        retVal = [self readFromDevice: aPrimaryAddress data: aData maxLength: aMaxLength];
        
        [theHWLock unlock];   //-----end critical section
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
    
    return( retVal );
}

- (void) wait: (short) aPrimaryAddress mask: (short) aWaitMask
{
}

#pragma mark ***Support Methods
- (id) getGpibController
{
	return self;
}

- (void) gpibError: (NSMutableString*) aMsg number:(int)anErrorNum
{
    if ( ! [self isEnabled]) return;
    @try {
        // Handle the master error register and extract error.
        //[theHWLock unlock];   //-----end critical section
        [aMsg appendString: [NSString stringWithFormat:  @" e = %d < ", anErrorNum]];
        
        NSMutableString *errorType = [[NSMutableString alloc] initWithFormat: @""];
        
        if (anErrorNum == 4 )  [errorType appendString: @" invalid link identifier "];
        else if (anErrorNum == 11 )  [errorType appendString: @" device locked by another link "];
        else if (anErrorNum == 15 )  [errorType appendString: @" I/O timeout "];
        else if (anErrorNum == 17 )  [errorType appendString: @" I/O error "];
        else if (anErrorNum == 23 )  [errorType appendString: @" abort "];
        
        [aMsg appendString: errorType];
        [errorType release];
        
		
        //[theHWLock unlock];   //-----end critical section
		// Call ibonl to take the device and interface offline
		//    ibonl( Device, 0 );
		//    ibonl( BoardIndex, 0 );
    }
	@catch(NSException* localException) {
        [theHWLock unlock];   //-----end critical section
        [localException raise];
    }
    
}

#pragma mark •••Archival
- (id) initWithCoder: (NSCoder*) decoder
{
    self = [super initWithCoder: decoder];
    
    [[self undoManager] disableUndoRegistration];
    [self commonInit];
    [self setCommand:		[decoder decodeObjectForKey:@"command"]];
 	[self setIpAddress:		[decoder decodeObjectForKey:@"ipAddress"]];
	[self setPrimaryAddress:[decoder decodeIntForKey:   @"primaryAddress"]];
	
    [[self undoManager] enableUndoRegistration];
    
    return self;
}

- (void) encodeWithCoder: (NSCoder*) encoder
{
    [super encodeWithCoder: encoder];
	[encoder encodeObject:command		forKey: @"command"];
	[encoder encodeObject:ipAddress		forKey: @"ipAddress"];
	[encoder encodeInt:primaryAddress	forKey: @"primaryAddress"];
}

@end

