//--------------------------------------------------------
// ORPacModel
// Created by Mark  A. Howe on Tue Jan 6, 2009
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
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
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

#import "ORPacModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORSerialPortList.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"

#pragma mark •••External Strings
NSString* ORPacModelRdacChannelChanged = @"ORPacModelRdacChannelChanged";
NSString* ORPacModelLcmEnabledChanged	= @"ORPacModelLcmEnabledChanged";
NSString* ORPacModelPreAmpChanged		= @"ORPacModelPreAmpChanged";
NSString* ORPacModelModuleChanged		= @"ORPacModelModuleChanged";
NSString* ORPacModelDacValueChanged		= @"ORPacModelDacValueChanged";
NSString* ORPacModelShipAdcsChanged		= @"ORPacModelShipAdcsChanged";
NSString* ORPacModelPollTimeChanged		= @"ORPacModelPollTimeChanged";
NSString* ORPacModelSerialPortChanged	= @"ORPacModelSerialPortChanged";
NSString* ORPacModelPortNameChanged		= @"ORPacModelPortNameChanged";
NSString* ORPacModelPortStateChanged	= @"ORPacModelPortStateChanged";
NSString* ORPacModelAdcChanged			= @"ORPacModelAdcChanged";
NSString* ORPacLock						= @"ORPacLock";

@interface ORPacModel (private)
- (void) runStarted:(NSNotification*)aNote;
- (void) runStopped:(NSNotification*)aNote;
- (void) timeout;
- (void) processOneCommandFromQueue;
@end

@implementation ORPacModel
- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[cmdQueue release];
	[lastRequest release];
    [portName release];
	[inComingData release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];

	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"Pac.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORPacController"];
}

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];

    [notifyCenter addObserver: self
                     selector: @selector(runStarted:)
                         name: ORRunStartedNotification
                       object: nil];
    
    [notifyCenter addObserver: self
                     selector: @selector(runStopped:)
                         name: ORRunStoppedNotification
                       object: nil];

}

- (void) shipAdcValues
{
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[18];
		data[0] = dataId | 18;
		data[1] = ([self uniqueIdNumber]&0xfff);
				
		int index = 2;
		int i;
		for(i=0;i<8;i++){
			data[index++] = adc[i];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
															object:[NSData dataWithBytes:&data length:sizeof(long)*18]];
	}
}


#pragma mark •••Accessors

- (int) rdacChannel
{
    return rdacChannel;
}

- (void) setRdacChannel:(int)aRdacChannel
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRdacChannel:rdacChannel];
    
    rdacChannel = aRdacChannel;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelRdacChannelChanged object:self];
}

- (BOOL) lcmEnabled
{
    return lcmEnabled;
}

- (void) setLcmEnabled:(BOOL)aLcmEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLcmEnabled:lcmEnabled];
    
    lcmEnabled = aLcmEnabled;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelLcmEnabledChanged object:self];
}

- (int) preAmp
{
    return preAmp;
}

- (void) setPreAmp:(int)aPreAmp
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPreAmp:preAmp];
    
    preAmp = aPreAmp;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPreAmpChanged object:self];
}

- (int) module
{
    return module;
}

- (void) setModule:(int)aModule
{
    [[[self undoManager] prepareWithInvocationTarget:self] setModule:module];
    
    module = aModule;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelModuleChanged object:self];
}

- (int) dacValue
{
    return dacValue;
}

- (void) setDacValue:(int)aDacValue
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDacValue:dacValue];
    
    dacValue = aDacValue;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelDacValueChanged object:self];
}

- (float) convertedAdc:(int)index
{
	if(index<0 && index>=8)return 0.0;
	else return 5.0 * adc[index]/65535.0;
}


- (unsigned short) adc:(int)index
{
	if(index>=0 && index<8)return adc[index];
	else return 0.0;
}

- (void) setAdc:(int)index value:(unsigned short)aValue;
{
	if(index>=0 && index<8){
		adc[index] = aValue;
		//get the time(UT!)
		time_t	theTime;
		time(&theTime);
		struct tm* theTimeGMTAsStruct = gmtime(&theTime);
		timeMeasured[index] = mktime(theTimeGMTAsStruct);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelAdcChanged 
															object:self 
														userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"Index"]];


	}
}

- (NSData*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSData*)aRequest
{
	[aRequest retain];
	[lastRequest release];
	lastRequest = aRequest;    
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                 }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
		[serialPort setSpeed:9600];
		[serialPort setParityNone];
		[serialPort setStopBits2:NO];
		[serialPort setDataBits:8];
        [serialPort open];
		[serialPort setDelegate:self];
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPortStateChanged object:self];
    
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setRdacChannel:	[decoder decodeIntForKey:@"ORPacModelRdacChannel"]];
	[self setLcmEnabled:	[decoder decodeBoolForKey:@"ORPacModelLcmEnabled"]];
	[self setPreAmp:		[decoder decodeIntForKey:@"ORPacModelPreAmp"]];
	[self setModule:		[decoder decodeIntForKey:@"ORPacModelModule"]];
	[self setDacValue:		[decoder decodeIntForKey:@"dacValue"]];
	[self setPortWasOpen:	[decoder decodeBoolForKey:	 @"portWasOpen"]];
    [self setPortName:		[decoder decodeObjectForKey: @"portName"]];
	[[self undoManager] enableUndoRegistration];
    [self registerNotificationObservers];

	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:rdacChannel		forKey:@"ORPacModelRdacChannel"];
    [encoder encodeBool:lcmEnabled		forKey:@"ORPacModelLcmEnabled"];
    [encoder encodeInt:preAmp			forKey:@"ORPacModelPreAmp"];
    [encoder encodeInt:module			forKey:@"ORPacModelModule"];
    [encoder encodeInt:dacValue			forKey: @"dacValue"];
    [encoder encodeBool:portWasOpen		forKey: @"portWasOpen"];
    [encoder encodeObject:portName		forKey: @"portName"];
}

#pragma mark ••• Commands
- (void) enqueLcmEnable
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacLcmEnaCmd;
		cmdData[1] = ([self lcmEnabled]?kPacLcmEnaSet:kPacLcmEnaClr);
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:cmdData length:2]];
				
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}
- (void) enqueModuleSelect
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacSelCmd; //module select
		cmdData[1] = (module << 3) | (preAmp & 0x7);
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:cmdData length:2]];
		
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (void) enqueReadADC:(int)aChannel
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacADCmd;		
		cmdData[1] = aChannel;
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:cmdData length:2]];
		
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (void) enqueWriteDac
{
    if([serialPort isOpen]){ 
		
		char cmdData[5];
		cmdData[0] = kPacRDacCmd;
		cmdData[1] = kPacRDacWriteOneRDac;
		cmdData[2] = module<<3 | preAmp;
		cmdData[3] = dacValue>>8;
		cmdData[4] = dacValue&0xff;
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:cmdData length:5]];
		
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (void) enqueReadDac
{
    if([serialPort isOpen]){ 

		char cmdData[3];
		cmdData[0] = kPacRDacCmd;
		cmdData[1] = kPacRDacReadOneRDac;
		cmdData[2] = module<<3 | preAmp;
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:cmdData length:3]];
		
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (void) enqueShipCmd
{
    if([serialPort isOpen]){ 
		
		char theCommand = kPacShipAdcs;
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:[NSData dataWithBytes:&theCommand length:1]];
		
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (void) selectModule
{
	[self enqueModuleSelect];
}

- (void) readAdcs
{
	[self enqueLcmEnable];
	[self enqueModuleSelect];
	int i;
	for(i=0;i<8;i++){
		[self enqueReadADC:i];
	}
	[self enqueShipCmd];
}

- (void) writeDac
{
	[self enqueWriteDac];
}

- (void) readDac
{
	[self enqueReadDac];
}

#pragma mark •••Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherPac
{
    [self setDataId:[anotherPac dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"PacModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORPacDecoderForAdc",				@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:8],        @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Adcs"];
    
    return dataDictionary;
}



- (void) dataReceived:(NSNotification*)note
{
	BOOL done = NO;
	if(!lastRequest)return;
	
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		if(!inComingData)inComingData = [[NSMutableData data] retain];
        [inComingData appendData:[[note userInfo] objectForKey:@"data"]];
		
		char* theCmd = (char*)[lastRequest bytes];
		switch (theCmd[0]){
			case kPacADCmd:
				if([inComingData length] == 3) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					short theChannel = theCmd[1] & 0x7;
					short msb		 = theData[0];
					short lsb		 = theData[1];
					if(theData[2] == kPacOkByte) [self setAdc:theChannel value: msb<<8 | lsb];
					else						 NSLogError(@"PAC",@"ADC !OK",nil);
					done = YES;
				}
			break;
				
			case kPacSelCmd:
				if([inComingData length] == 1) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					if(theData[0] != kPacOkByte)  NSLogError(@"PAC",@"Port D !OK",nil);
					done = YES;
				}
			break;
				
			case kPacRDacCmd:
				if(theCmd[1] == kPacRDacReadOneRDac){
					if([inComingData length] == 3) {
						unsigned char* theData	 = (unsigned char*)[inComingData bytes];
						short msb		 = theData[0];
						short lsb		 = theData[1];
						if(theData[2] == kPacOkByte) [self setDacValue: msb<<8 | lsb];
						else						 NSLogError(@"PAC",@"DAC !OK",nil);
						done = YES;
					}
				}
				else if(theCmd[1] == kPacRDacWriteOneRDac){
					if([inComingData length] == 1) {
						unsigned char* theData	 = (unsigned char*)[inComingData bytes];
						if(theData[0] != kPacOkByte) NSLogError(@"PAC",@"DAC !OK",nil);
					}
				}
			break;
				
			case kPacLcmEnaCmd:
				if([inComingData length] == 1) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					if(theData[0] != kPacOkByte)  NSLogError(@"PAC",@"LCM ENA !OK",nil);
					done = YES;
				}
			break;
		}
		
		if(done){
			[inComingData release];
			inComingData = nil;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
			[self setLastRequest:nil];			 //clear the last request
			[self processOneCommandFromQueue];	 //do the next command in the queue
		}
	}
}

- (unsigned long) timeMeasured:(int)index
{
	if(index<0)return 0;
	else if(index>=8)return 0;
	else return timeMeasured[index];
}

- (void)serialPortWriteProgress:(NSDictionary *)dataDictionary
{
}
@end

@implementation ORPacModel (private)

- (void) runStarted:(NSNotification*)aNote
{
}

- (void) runStopped:(NSNotification*)aNote
{
}

- (void) timeout
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	NSLogError(@"PAC",@"command timeout",nil);
	[self setLastRequest:nil];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSData* cmdData = [[[cmdQueue objectAtIndex:0] retain] autorelease];
	[cmdQueue removeObjectAtIndex:0];
	unsigned char* cmd = (unsigned char*)[cmdData bytes];
	if(cmd[0] == kPacShipAdcs){
		[self shipAdcValues];
	}
	else {
		[self setLastRequest:cmdData];
		[serialPort writeDataInBackground:cmdData];
		[self performSelector:@selector(timeout) withObject:nil afterDelay:3];
	}
}

@end