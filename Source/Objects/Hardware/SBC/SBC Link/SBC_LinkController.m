//--------------------------------------------------------
// SBC_LinkController
// Created by Mark  A. Howe on Tue Feb 07 2006
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2006 CENPA, University of Washington. All rights reserved.
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

#import "SBC_LinkController.h"
#import "SBC_Link.h"
#import "SBC_Linking.h"
#import "ORCard.h"
#import "ORVmeAdapter.h"
#import "ORSBC_LAMModel.h"
#import "ORPlotter2D.h"
#import "ORPlotter1D.h"
#import "ORAxis.h"

@interface SBC_LinkController (private)
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
@end


@implementation SBC_LinkController

#pragma mark •••Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"SBC_Link"];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	[groupView setGroup:model];
		
    NSString* key = [NSString stringWithFormat: @"orca.%@%d.selectedtab",[model className],[model slot]];
    int index = [[NSUserDefaults standardUserDefaults] integerForKey: key];
    if((index<0) || (index>[tabView numberOfTabViewItems]))index = 0;
    [tabView selectTabViewItemAtIndex: index];
	
    [plotter setVectorMode:YES];
    [[plotter xScale] setRngLimitsLow:0 withHigh:300 withMinRng:300];
    [[plotter yScale] setRngLimitsLow:0 withHigh:100 withMinRng:10];
    [plotter setDrawWithGradient:YES];
    [plotter setBackgroundColor:[NSColor colorWithCalibratedRed:.9 green:1.0 blue:.9 alpha:1.0]];

	[[histogram xScale] setRngLimitsLow:0 withHigh:1000 withMinRng:300];
    [[histogram yScale] setRngLimitsLow:0 withHigh:5000 withMinRng:10];
    [histogram setDrawWithGradient:YES];
	
	[payloadSizeSlider setMinValue:0];
	[payloadSizeSlider setMaxValue:300];
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[model cpuName]];	
}

- (void) tabView:(NSTabView*)aTabView didSelectTabViewItem:(NSTabViewItem*)item
{
    NSString* key = [NSString stringWithFormat: @"orca.%@%d.selectedtab",[model className],[model slot]];
    int index = [tabView indexOfTabViewItem:item];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:key];
}

#pragma mark •••Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	[super registerNotificationObservers];
	
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
	
	[notifyCenter addObserver : self
					 selector : @selector(sbcLockChanged:)
						 name : ORRunStatusChangedNotification
					   object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : [model sbcLockName]
                        object: nil];
	
	   [notifyCenter addObserver : self
						selector : @selector(filePathChanged:)
							name : SBC_LinkPathChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(verboseChanged:)
							name : SBC_LinkVerboseChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(forceReloadChanged:)
							name : SBC_LinkForceReloadChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(startStatusChanged:)
							name : SBC_LinkReloadingChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(sbcLockChanged:)
							name : SBC_LinkReloadingChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(startStatusChanged:)
							name : SBC_LinkTryingToStartCrateChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(loadModeChanged:)
							name : SBC_LinkLoadModeChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(runInfoChanged:)
							name :  SBC_LinkRunInfoChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(byteRateChanged:)
							name :  SBC_LinkByteRateChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(runInfoChanged:)
							name :  SBC_LinkConnectionChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(ipNumberChanged:)
							name : SBC_LinkIPNumberChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(portNumberChanged:)
							name : SBC_LinkPortChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(userNameChanged:)
							name : SBC_LinkUserNameChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(passWordChanged:)
							name : SBC_LinkPassWordChanged
						  object : [model sbcLink]];
	   
	   
	   [notifyCenter addObserver : self
						selector : @selector(startStatusChanged:)
							name : SBC_LinkCrateStartStatusChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(startStatusChanged:)
							name : SBC_LinkConnectionChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(initAfterConnectChanged:)
							name : SBC_LinkInitAfterConnectChanged
						   object: [model sbcLink]];
	   
	   
	   [notifyCenter addObserver : self
						selector : @selector(sbcLockChanged:)
							name : [model sbcLockName]
						   object: nil];
							
	   [notifyCenter addObserver : self
						selector : @selector(addressChanged:)
							name : SBC_LinkWriteAddressChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(writeValueChanged:)
							name : SBC_LinkWriteValueChanged
						  object : [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(doRangeChanged:)
							name : SBC_LinkDoRangeChanged
						   object: [model sbcLink]];
	   
	   [notifyCenter addObserver : self
						selector : @selector(rangeChanged:)
							name : SBC_LinkRangeChanged
						   object: [model sbcLink]];
	   
    [notifyCenter addObserver : self
                     selector : @selector(readWriteTypeChanged:)
                         name : SBC_LinkRWTypeChanged
                       object : [model sbcLink]];

   [notifyCenter addObserver : self
                     selector : @selector(addressModifierChanged:)
                         name : SBC_LinkAddressModifierChanged
                       object : [model sbcLink]];

  [notifyCenter addObserver : self
                     selector : @selector(lamSlotChanged:)
                         name : ORSBC_LAMSlotChangedNotification
                       object : nil];

  [notifyCenter addObserver : self
                     selector : @selector(infoTypeChanged:)
                         name : SBC_LinkInfoTypeChanged
                       object : [model sbcLink]];

  [notifyCenter addObserver : self
                     selector : @selector(pingTaskChanged:)
                         name : ORSBC_LinkPingTask
                       object : [model sbcLink]];

  [notifyCenter addObserver : self
                     selector : @selector(cbTestChanged:)
                         name : ORSBC_LinkCBTest
                       object : [model sbcLink]];

  [notifyCenter addObserver : self
                     selector : @selector(numTestPointsChanged:)
                         name : ORSBC_LinkNumCBTextPointsChanged
                       object : [model sbcLink]];

  [notifyCenter addObserver : self
                     selector : @selector(payloadSizeChanged:)
                         name : ORSBC_LinkNumPayloadSizeChanged
                       object : [model sbcLink]];


}

- (void) updateWindow
{
	[super updateWindow];
    [self settingsLockChanged:nil];

	[self filePathChanged:nil];
	[self verboseChanged:nil];
	[self forceReloadChanged:nil];
    [self setToggleCrateButtonState];
	[self loadModeChanged:nil];

	[self byteRateChanged:nil];
	
	[self ipNumberChanged:nil];
	[self portNumberChanged:nil];
	[self userNameChanged:nil];
	[self passWordChanged:nil];
	[self initAfterConnectChanged:nil];

	[self writeValueChanged:nil];
	[self addressChanged:nil];
	[self doRangeChanged:nil];
	[self rangeChanged:nil];
    [self readWriteTypeChanged:nil];
    [self addressModifierChanged:nil];
    [self infoTypeChanged:nil];
    [self pingTaskChanged:nil];
    [self cbTestChanged:nil];
    [self numTestPointsChanged:nil];
    [self payloadSizeChanged:nil];
	
	[self lamSlotChanged:nil];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:[model sbcLockName] to:secure];
    [lockButton setEnabled:secure];
}

- (void) payloadSizeChanged:(NSNotification*)aNote
{
	[plotter setNeedsDisplay:YES];
	long size = [[model sbcLink] payloadSize]/1000;
	[payloadSizeSlider setIntValue:size];
	[payloadSizeField setIntValue:size];
	if(size<25)[payloadSizeField setTextColor:[NSColor colorWithCalibratedRed:.6 green:0 blue:0 alpha:1.0]];
	else [payloadSizeField setTextColor:[NSColor blackColor]];
	
}

- (void) numTestPointsChanged:(NSNotification*)aNote
{
	[numTestPointsField setIntValue:[[model sbcLink] numTestPoints]];
}

- (void) pingTaskChanged:(NSNotification*)aNote
{
	BOOL pingRunning = [[model sbcLink] pingTaskRunning];
	if(pingRunning)[pingTaskProgress startAnimation:self];
	else [pingTaskProgress stopAnimation:self];
	[pingButton setTitle:pingRunning?@"Stop":@"Send Ping"];
}

- (void) cbTestChanged:(NSNotification*)aNote
{
	BOOL isRunning = [[model sbcLink] cbTestRunning];
	if(isRunning){
		[cbTestProgress startAnimation:self];
		[cbTestProgress setDoubleValue:[[model sbcLink] cbTestProgress]];
	}
	else {
		[cbTestProgress stopAnimation:self];
		[cbTestProgress setDoubleValue:0];
	}
	[cbTestButton setTitle:isRunning?@"Stop":@"Test CB"];
	[plotter setNeedsDisplay:YES];
	[cbTestButton setNeedsDisplay:YES];
	[numRecordsField setIntValue:[[model sbcLink] totalRecordsChecked]];
	[numErrorsField setIntValue:[[model sbcLink] totalErrors]];
	[histogram setNeedsDisplay:YES];
}


- (void) lamSlotChanged:(NSNotification*)aNotification
{
	[groupView setNeedsDisplay:YES];
}

- (void) settingsLockChanged:(NSNotification*)aNotification
{
    BOOL locked = [gSecurity isLocked:[model sbcLockName]];   
    [lockButton setState: locked];
}

- (void) loadModeChanged:(NSNotification*)aNote
{
	[loadModeMatrix selectCellWithTag: [[model sbcLink] loadMode]];
	[setFilePathButton setEnabled:[[model sbcLink] loadMode]];
}

- (void) rangeChanged:(NSNotification*)aNote
{
	[rangeTextField setIntValue: [[model sbcLink] range]];
	[rangeStepper setIntValue:	 [[model sbcLink] range]];
}

- (void) doRangeChanged:(NSNotification*)aNote
{
	[doRangeButton setIntValue: [[model sbcLink] doRange]];
	[self startStatusChanged:nil];
}

- (void) readWriteTypeChanged:(NSNotification*)aNotification
{
	[self updateRadioCluster:readWriteTypeMatrix setting:[[model sbcLink] readWriteType]];
	
	switch([[model sbcLink] readWriteType]){
		case 0: default: [addressStepper setIncrement:1]; break;
		case 1: [addressStepper setIncrement:2]; break;
		case 2: [addressStepper setIncrement:4]; break;
	}
}

- (void) infoTypeChanged:(NSNotification*)aNotification
{
	[self updateRadioCluster:infoTypeMatrix setting:[[model sbcLink] infoType]];
	[self runInfoChanged:nil];

}

- (void) addressModifierChanged:(NSNotification*)aNotification
{
	[addressModifierPU selectItemWithTag:[[model sbcLink] addressModifier]];
}

- (void) startStatusChanged:(NSNotification*)aNote
{
	BOOL connected		 = [[model sbcLink] isConnected];
	NSString*  connectionState = [[model sbcLink] crateProcessState];
	
	[self setToggleCrateButtonState];
	[statusField setStringValue:connectionState];
	[connectionStatusField setStringValue:connected?@"Connected":@"Not Connected"];
	[status1Field setStringValue:connectionState];
	[connectionStatus1Field setStringValue:connected?@"Running":@"Not Running"];
	[connectButton setTitle:connected?@"Disconnect":@"Connect"];
	[connect1Button setTitle:connected?@"Disconnect":@"Connect"];
	
	BOOL functionsExist = 	[model showBasicOps] && connected;

	[addressModifierPU  setEnabled:functionsExist];
	[readWriteTypeMatrix  setEnabled:functionsExist];
	[doRangeButton setEnabled:functionsExist];
	[addressField setEnabled:functionsExist];
	[addressStepper setEnabled:functionsExist];
	[writeValueField setEnabled:functionsExist];
	[writeValueStepper setEnabled:functionsExist];
	[readButton setEnabled:functionsExist];
	[writeButton setEnabled:functionsExist];
    [rangeStepper setEnabled:functionsExist];
    [rangeTextField setEnabled:functionsExist && [[model sbcLink] doRange]];
    [resetCrateBusButton setEnabled:functionsExist];
    [cbTestButton setEnabled:connected];
	
	if(![model showBasicOps]) [functionAllowedField setStringValue:@"Low-Level Access NOT allowed with this SBC"];
	else [functionAllowedField setStringValue:@""];

}

- (void) sbcLockChanged:(NSNotification*)aNotification
{

    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL locked = [gSecurity isLocked:[model sbcLockName]];
	BOOL connected		 = [[model sbcLink] isConnected];
 
	[pingButton setEnabled:!locked && !runInProgress];
    [cbTestButton setEnabled:!locked && !runInProgress && connected];
	[payloadSizeSlider setEnabled:!locked && !runInProgress && connected];
    [ipNumberField setEnabled:!locked && !runInProgress];
    [portNumberField setEnabled:!locked && !runInProgress];
    [passWordField setEnabled:!locked && !runInProgress];
    [userNameField setEnabled:!locked && !runInProgress];
    [connectButton setEnabled:!locked && !runInProgress];
    [connect1Button setEnabled:!locked && !runInProgress];

	[self setToggleCrateButtonState];

}

- (void) setToggleCrateButtonState
{
    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL locked = [gSecurity isLocked:[model sbcLockName]];
	if([[model sbcLink] tryingToStartCrate] || runInProgress){
		[toggleCrateButton setTitle:@"---"];
		[toggleCrateButton setEnabled:NO];
	}
	else {
		if([[model sbcLink] isConnected]){
			[toggleCrateButton setTitle:@"Stop Crate"];
		}
		else {
			[toggleCrateButton setTitle:@"Start Crate"];
		}
		[toggleCrateButton setEnabled:!locked && !runInProgress];
	}
	
//	if([[model sbcLink] isConnected])	[connectButton setTitle:@"Disconnect"];
//	else					[connectButton setTitle:@"Connect"];
}


- (void) verboseChanged:(NSNotification*)aNote
{
	[verboseButton setState:[[model sbcLink] verbose]];
}

- (void) forceReloadChanged:(NSNotification*)aNote
{
	[forceReloadButton setState:[[model sbcLink] forceReload]];
}

- (void) filePathChanged:(NSNotification*)aNote
{
	[filePathField setStringValue:[[[model sbcLink] filePath] stringByAbbreviatingWithTildeInPath]];
}

- (void) byteRateChanged:(NSNotification*)aNote
{
	[byteRateSentField setFloatValue:[[model sbcLink] byteRateSent]/1000.];
	[byteRateReceivedField setFloatValue:[[model sbcLink] byteRateReceived]/1000.];
	[bytesSentRateBar setNeedsDisplay:YES];
}

- (void) runInfoChanged:(NSNotification*)aNote
{
	SBC_info_struct theRunInfo =  [[model sbcLink] runInfo];
	NSString* theRunInfoString = @"";
	int i,num;

	unsigned long aMinValue,aMaxValue,aWriteMark,aReadMark;
	[[model sbcLink] getQueMinValue:&aMinValue maxValue:&aMaxValue head:&aWriteMark tail:&aReadMark];
	switch([[model sbcLink] infoType]){
		case 0:
			theRunInfoString =                                 [NSString stringWithFormat: @"Connected     : %@\t\t# Records   : %d\n",[[model sbcLink] isConnected]?@"YES":@"NO ",theRunInfo.recordsTransfered];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"Config loaded : %@\t\tWrap Arounds: %d\n",(theRunInfo.statusBits & kSBC_ConfigLoadedMask) ? @"YES":@"NO ",theRunInfo.wrapArounds]];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"Running       : %@\t\tThrottle    : %d\n",(theRunInfo.statusBits & kSBC_RunningMask) ? @"YES":@"NO ",[[model sbcLink] throttle]]];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"Cycles * 10K  : %d\n",theRunInfo.readCycles/10000]];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"Lost Bytes    : %d\n",theRunInfo.lostByteCount]];

			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"CB Write Mark : %-9d   Bus Errors  : %d\n",aWriteMark,theRunInfo.busErrorCount]];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"CB Read Mark  : %-9d   Err Count   : %d\n",aReadMark,theRunInfo.msg_count]];
			theRunInfoString = [theRunInfoString stringByAppendingString:[NSString stringWithFormat: @"In Buffer Now : %-9d   Msg Count   : %d",theRunInfo.amountInBuffer,theRunInfo.msg_count]];
		break;

		case 1:
			num = MIN(kSBC_MaxErrorBufferSize,theRunInfo.err_count);
			if(num == 0) theRunInfoString =  @"No Errors";
			for(i=0;i<num;i++){
				theRunInfoString =  [theRunInfoString stringByAppendingFormat: @"[%2d] %s\n",i, theRunInfo.errorStrings[i]];
			}
		break;

		case 2:
			num = MIN(kSBC_MaxErrorBufferSize,theRunInfo.msg_count);
			if(num == 0) theRunInfoString =  @"No Messages";
			for(i=0;i<num;i++){
				theRunInfoString =  [theRunInfoString stringByAppendingFormat: @"[%2d] %s\n",i, theRunInfo.messageStrings[i]];
			}
		break;
	}
	float amountFilled;
	float totalAmount = (float)(aMaxValue-aMinValue);
	
	if(aReadMark==aWriteMark)		amountFilled = 0;
	else if(aReadMark<aWriteMark)	amountFilled = aWriteMark-aReadMark;
	else							amountFilled = totalAmount - (aReadMark-aWriteMark);
	
	
	[cbPercentField setFloatValue:totalAmount!=0?100.*amountFilled/totalAmount:0];
	[runInfoField setStringValue:theRunInfoString];
	[queView setNeedsDisplay:YES];
}

- (NSString*) literalToString:(int)aLiteral
{
	NSString* s = [NSString stringWithFormat:@"%c%c%c%c",(aLiteral>>24)&0xff,(aLiteral>>16)&0xff,(aLiteral>>8)&0xff,aLiteral&0xff];
	return s;
}

- (NSString*) errorString:(int)errNum
{
	switch (errNum) {
		case kSBC_ReadError:  return @"Rd Err";
		case kSBC_WriteError: return @"Wr Err";
		default:return [NSString stringWithFormat:@"Err %2d",errNum];
	}
}

- (void) getQueMinValue:(unsigned long*)aMinValue maxValue:(unsigned long*)aMaxValue head:(unsigned long*)aHeadValue tail:(unsigned long*)aTailValue
{
	[[model sbcLink]  getQueMinValue:aMinValue maxValue:aMaxValue head:aHeadValue tail:aTailValue];

}

- (void) initAfterConnectChanged:(NSNotification*)aNote
{
	[initAfterConnectButton setIntValue: [[model sbcLink] initAfterConnect]];
}

- (void) userNameChanged:(NSNotification*)aNote
{
	[userNameField setStringValue:[[model sbcLink] userName]];
}

- (void) passWordChanged:(NSNotification*)aNote
{
	[passWordField setStringValue:[[model sbcLink] passWord]];
}

- (void) ipNumberChanged:(NSNotification*)aNote
{
	[ipNumberField setStringValue:[[model sbcLink] IPNumber]];
}

- (void) portNumberChanged:(NSNotification*)aNote
{
	[portNumberField setIntValue:[[model sbcLink] portNumber]];
}

- (void) addressChanged:(NSNotification*)aNote
{
	[addressField setIntValue:[[model sbcLink] writeAddress]];
	[addressStepper setIntValue:[[model sbcLink] writeAddress]];
}

- (void) writeValueChanged:(NSNotification*)aNote
{
	[writeValueField setIntValue:[[model sbcLink] writeValue]];
	[writeValueStepper setIntValue:[[model sbcLink] writeValue]];
}

#pragma mark •••Actions
- (IBAction) lockAction:(id)sender
{
    [gSecurity tryToSetLock:[model sbcLockName] to:[sender intValue] forWindow:[self window]];
}

- (IBAction) filePathAction:(id)sender
{
	NSString* startPath = [[[model sbcLink] filePath] stringByDeletingLastPathComponent];
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setPrompt:@"Choose"];
	[openPanel beginSheetForDirectory:startPath?startPath:NSHomeDirectory()
                                 file:nil
                                types:nil
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:NULL];
}

- (void) loadModeAction:(id)sender
{
	[[model sbcLink] setLoadMode:[[sender selectedCell] tag]];	
}

- (IBAction) toggleCrateAction:(id)sender
{
	[[model sbcLink] toggleCrate];
}

- (IBAction) killCrateAction:(id)sender
{
	int choice = NSRunAlertPanelRelativeToWindow(@"This will KILL the crate process. There may be other ORCAs connected to the crate.",
												@"Is this really what you want?",
												@"Cancel",@"Yes, Kill Crate",nil,[self window]);
	if(choice == NSAlertAlternateReturn){		
		[[model sbcLink] killCrate];
	}

}

- (IBAction) verboseAction:(id)sender
{
	[[model sbcLink] setVerbose:[sender intValue]];
}

- (IBAction) forceReloadAction:(id)sender
{
	[[model sbcLink] setForceReload:[sender intValue]];
}

- (IBAction) initAfterConnectAction:(id)sender
{
	[[model sbcLink] setInitAfterConnect:[sender intValue]];	
}

- (IBAction) ipNumberAction:(id)sender
{
	[[model sbcLink] setIPNumber:[sender stringValue]];
}

- (IBAction) portNumberAction:(id)sender
{
	[[model sbcLink] setPortNumber:[sender intValue]];
}

- (IBAction) userNameAction:(id)sender
{
	[[model sbcLink] setUserName:[sender stringValue]];
}

- (IBAction) passWordAction:(id)sender
{
	[[model sbcLink] setPassWord:[sender stringValue]];
}

- (IBAction) connectionAction:(id)sender
{
	NS_DURING
		if([[model sbcLink] isConnected])[[model sbcLink] disconnect];
		else [[model sbcLink] connect];
	NS_HANDLER
		NSLog(@"%@\n",localException);
	NS_ENDHANDLER
}

-(IBAction) addressAction:(id)sender
{
	[[model sbcLink] setWriteAddress:[sender intValue]];
}

- (IBAction) writeValueAction:(id)sender
{
	[[model sbcLink] setWriteValue:[sender intValue]];
}

- (IBAction) writeAction:(id)sender
{
    unsigned short sdata;
    unsigned char  cdata;
	[self endEditing];
	long value = [[model sbcLink] writeValue];
	int address;
    NS_DURING
		if([model isKindOfClass:[ORVmeAdapter class]]){
			int 			startAddress 	= [[model sbcLink] writeAddress];
			int				endAddress		= [[model sbcLink] doRange]?startAddress + [[model sbcLink] range]*[addressStepper increment] : startAddress;
			unsigned short 	addressModifier = [[model sbcLink] addressModifier];
			unsigned short 	addressSpace	= 1;  //[[model sbcLink] rwIOSpaceValue];
			unsigned long  	ldata			= [[model sbcLink] writeValue];
			
			address = startAddress;
			if([[model sbcLink] doRange] && [[model sbcLink] range]==0){
				NSLog(@"Range == 0: nothing to do\n");
				return;
			}
			do {
				switch([[model sbcLink] readWriteType]){
					case 0: //byte
						cdata = (unsigned char)ldata;
						[[model sbcLink] writeByteBlock:&cdata
									atAddress:address
								   numToWrite:1
								   withAddMod:addressModifier
								usingAddSpace:addressSpace];
						ldata = cdata;
						break;
						
					case 1:	//short
						sdata = (unsigned short)ldata;
						[[model sbcLink] writeWordBlock:&sdata
									atAddress:address
								   numToWrite:1
								   withAddMod:addressModifier
								usingAddSpace:addressSpace];
						
						ldata = sdata;
						break;
						
					case 2: //long
						[[model sbcLink] writeLongBlock:&ldata
									atAddress:address
								   numToWrite:1
								   withAddMod:addressModifier
								usingAddSpace:addressSpace];
						
						break;
				}
				address+=[addressStepper increment];
				
			}while(address<endAddress);
			if([[model sbcLink] doRange]) NSLog(@"Vme Write Range @ (0x%08x-0x%08x 0x%x 0x%x): 0x%08x\n",startAddress,endAddress,addressModifier,addressSpace,ldata);
			else				NSLog(@"Vme Write @ (0x%08x 0x%x 0x%x): 0x%08x\n",startAddress,addressModifier,addressSpace,ldata);
			
		}
	else {
		address = [[model sbcLink] writeAddress];
		[[model sbcLink] writeLongBlock:&value
				atAddress:address
				numToRead:1];
	}
    NS_HANDLER
        NSRunAlertPanel([localException name], @"%@\nAddress: 0x%08X", @"OK", nil, nil,
                        localException,address);
    NS_ENDHANDLER
}

- (IBAction) readAction:(id)sender
{
    unsigned long ldata;
    unsigned short sdata;
    unsigned char  cdata;
	[self endEditing];
	unsigned long address;
	NS_DURING
		if([model isKindOfClass:[ORVmeAdapter class]]){
			unsigned long 	startAddress 	= [[model sbcLink] writeAddress];
			unsigned long	endAddress		= [[model sbcLink] doRange]?startAddress + [[model sbcLink] range]*[addressStepper increment] : startAddress;
			unsigned short 	addressModifier = [[model sbcLink] addressModifier];
			unsigned short 	addressSpace	= 1;  //[model rwIOSpaceValue];
			
			address = startAddress;
			if([[model sbcLink] doRange] && [[model sbcLink] range]==0){
				NSLog(@"Range == 0: nothing to do\n");
				return;
			}
			do {
				switch([[model sbcLink] readWriteType]){
					case 0: //byte
						[[model sbcLink] readByteBlock:&cdata
								   atAddress:address
								   numToRead:1
								  withAddMod:addressModifier
							   usingAddSpace:addressSpace];
						ldata = cdata;
					break;
						
					case 1: //short
						[[model sbcLink] readWordBlock:&sdata
								   atAddress:address
								   numToRead:1
								  withAddMod:addressModifier
							   usingAddSpace:addressSpace];
						
						ldata = sdata;
						
					break;
						
					case 2: //long
						[[model sbcLink] readLongBlock:&ldata
								   atAddress:address
								   numToRead:1
								  withAddMod:addressModifier
							   usingAddSpace:addressSpace];
						
					break;
				}
				NSLog(@"Vme Read @ (0x%08x 0x%x %d): 0x%08x\n",address,addressModifier,addressSpace,ldata);
				address+=[addressStepper increment];
			}while(address<endAddress);
		}
		else {
			long result;
			address = [[model sbcLink] writeAddress];
			[[model sbcLink] readLongBlock:&result
								 atAddress:address
								 numToRead:1];
			NSLog(@"%@ Address: 0x%08x = 0x%0x\n",[[model sbcLink] crateName],[[model sbcLink] writeAddress], result);
		}
    NS_HANDLER
        NSRunAlertPanel([localException name], @"%@\nAddress: 0x%08X", @"OK", nil, nil,
                        localException,address);
    NS_ENDHANDLER
}


- (IBAction) resetCrateBusAction:(id)sender
{
    BOOL crateBusButtonEnabled = [resetCrateBusButton isEnabled];
	[resetCrateBusButton setEnabled:NO];
    [model reset];
	[resetCrateBusButton setEnabled:crateBusButtonEnabled];
}

- (void) rangeTextFieldAction:(id)sender
{
	[[model sbcLink] setRange:[sender intValue]];	
}

- (void) doRangeAction:(id)sender
{
	[[model sbcLink] setDoRange:[sender intValue]];	
}

- (IBAction) readWriteTypeMatrixAction:(id)sender
{ 
    if ([[model sbcLink] readWriteType] != [sender selectedTag]){
        [[model sbcLink] setReadWriteType:[sender selectedTag]];
    }
}

- (IBAction) addressModifierPUAction:(id)sender
{
	[[model sbcLink] setAddressModifier:[[sender selectedItem] tag]];
}

- (IBAction) infoTypeAction:(id)sender
{
    if ([[model sbcLink] infoType] != [sender selectedTag]){
        [[model sbcLink] setInfoType:[sender selectedTag]];
    }
}

- (IBAction) ping:(id)sender
{
	NS_DURING
		[[model sbcLink] ping];
	NS_HANDLER
	NS_ENDHANDLER
}

- (IBAction) cbTest:(id)sender
{
	NS_DURING
		[self endEditing];
		[[model sbcLink] startCBTransferTest];
	NS_HANDLER
	NS_ENDHANDLER
}

- (IBAction) numTestPointsAction:(id)sender
{
	[[model sbcLink] setNumTestPoints:[sender intValue]];
}

- (IBAction) payloadSizeAction:(id)sender
{
	[[model sbcLink] setPayloadSize:[sender intValue]*1000];
}


- (unsigned long) plotter:(id)aPlotter numPointsInSet:(int)set
{
    return [[model sbcLink] cbTestCount];
}

- (BOOL) plotter:(id)aPlotter dataSet:(int)set index:(unsigned long)index x:(float*)xValue y:(float*)yValue
{
    if(index>100){
        *xValue = 0;
        *yValue = 0;
        return NO;
    }
    NSPoint track = [[model sbcLink] cbPoint:index];
    *xValue = track.x;
    *yValue = track.y;
    return YES;    
}

- (int) numberOfPointsInPlot:(id)aPlotter dataSet:(int)set
{
    return 1000;
}

- (float) plotter:(id) aPlotter dataSet:(int)set dataValue:(int) x
{
    return (float)[[model sbcLink] recordSizeHisto:x];
}

- (BOOL) plotter:(id)aPlotter dataSet:(int)set crossHairX:(float*)xValue crossHairY:(float*)yValue
{
    *xValue = [[model sbcLink] payloadSize]/1000.;
    *yValue = 0;
    return YES;
}

@end

@implementation SBC_LinkController (private)
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if(returnCode){
        NSString* path = [[[sheet filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath];
        [[model sbcLink] setFilePath:path];
    }
}
@end

@implementation OrcaObject (SBC_Link)
- (BOOL) showBasicOps
{
	return YES;
}
@end
