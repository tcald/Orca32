//-------------------------------------------------------------------------
//  ORSIS3800Controller.h
//
//  Created by Mark A. Howe on Wednesday 9/30/08.
//  Copyright (c) 2008 CENPA. University of Washington. All rights reserved.
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

#pragma mark ***Imported Files
#import "ORSIS3800Controller.h"

@implementation ORSIS3800Controller

-(id)init
{
    self = [super initWithWindowNibName:@"SIS3800"];
    
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) awakeFromNib
{
	short i;
	for(i=0;i<8;i++){	
		[[countEnableMatrix0 cellAtRow:i column:0] setTag:i];
		[[countEnableMatrix1 cellAtRow:i column:0] setTag:i+8];
		[[countEnableMatrix2 cellAtRow:i column:0] setTag:i+16];
		[[countEnableMatrix3 cellAtRow:i column:0] setTag:i+24];
		[[countMatrix0 cellAtRow:i column:0] setTag:i];
		[[countMatrix1 cellAtRow:i column:0] setTag:i+8];
		[[countMatrix2 cellAtRow:i column:0] setTag:i+16];
		[[countMatrix3 cellAtRow:i column:0] setTag:i+24];
	}
	
	[super awakeFromNib];
}


#pragma mark •••Notifications
- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
	
    [notifyCenter addObserver : self
					 selector : @selector(slotChanged:)
						 name : ORVmeCardSlotChangedNotification
					   object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(baseAddressChanged:)
                         name : ORVmeIOCardBaseAddressChangedNotification
                       object : model];
    
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : ORSIS3800SettingsLock
                        object: nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(moduleIDChanged:)
                         name : ORSIS3800ModelIDChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(countEnableMaskChanged:)
                         name : ORSIS3800ModelCountEnableMaskChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(countersChanged:)
                         name : ORSIS3800CountersChanged
						object: model];	
	
    [notifyCenter addObserver : self
                     selector : @selector(lemoInModeChanged:)
                         name : ORSIS3800ModelLemoInModeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(enable25MHzPulsesChanged:)
                         name : ORSIS3800ModelEnable25MHzPulsesChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(enableInputTestModeChanged:)
                         name : ORSIS3800ModelEnableInputTestModeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(enableReferencePulserChanged:)
                         name : ORSIS3800ModelEnableReferencePulserChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(overFlowMaskChanged:)
                         name : ORSIS3800ModelOverFlowMaskChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORSIS3800PollTimeChanged
						object: model];	
    [notifyCenter addObserver : self
                     selector : @selector(clearOnRunStartChanged:)
                         name : ORSIS3800ModelClearOnRunStartChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(syncWithRunChanged:)
                         name : ORSIS3800ModelSyncWithRunChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(isCountingChanged:)
                         name : ORSIS3800ModelIsCountingChanged
						object: model];

}

- (void) updateWindow
{
    [super updateWindow];
    [self baseAddressChanged:nil];
    [self slotChanged:nil];
    [self settingsLockChanged:nil];
	[self moduleIDChanged:nil];
	[self countEnableMaskChanged:nil];
	[self countersChanged:nil];
	[self lemoInModeChanged:nil];
	[self enable25MHzPulsesChanged:nil];
	[self enableInputTestModeChanged:nil];
	[self enableReferencePulserChanged:nil];
	[self overFlowMaskChanged:nil];
	[self pollTimeChanged:nil];
	[self clearOnRunStartChanged:nil];
	[self syncWithRunChanged:nil];
	[self isCountingChanged:nil];
}

#pragma mark •••Interface Management

- (void) isCountingChanged:(NSNotification*)aNote
{
	[statusText setStringValue: [model isCounting]?@"Counting":@"NOT Counting"];
}

- (void) syncWithRunChanged:(NSNotification*)aNote
{
	[syncWithRunButton setIntValue: [model syncWithRun]];
}

- (void) clearOnRunStartChanged:(NSNotification*)aNote
{
	[clearOnRunStartButton setIntValue: [model clearOnRunStart]];
}

- (void) overFlowMaskChanged:(NSNotification*)aNote
{
	NSColor* red = [NSColor colorWithCalibratedRed:.8 green:0 blue:0 alpha:1];
	unsigned long aMask = [model overFlowMask];
	int i;
	for(i=0;i<8;i++){
		if(aMask & (0x00000001<<i))	[[countMatrix0 cellWithTag:i] setTextColor:red];
		else						[[countMatrix0 cellWithTag:i] setTextColor:[NSColor blackColor]];
		
		if(aMask & (0x00000100<<i))	[[countMatrix1 cellWithTag:i+8] setTextColor:red];
		else						[[countMatrix1 cellWithTag:i+8] setTextColor:[NSColor blackColor]];
		
		if(aMask & (0x00010000<<i))	[[countMatrix2 cellWithTag:i+16] setTextColor:red];
		else						[[countMatrix2 cellWithTag:i+16] setTextColor:[NSColor blackColor]];

		if(aMask & (0x01000000<<i))	[[countMatrix3 cellWithTag:i+24] setTextColor:red];
		else						[[countMatrix3 cellWithTag:i+24] setTextColor:[NSColor blackColor]];
	}
}

- (void) pollTimeChanged:(NSNotification*)aNote
{
	[pollTimePU selectItemAtIndex: [model pollTime]];
}

- (void) enableReferencePulserChanged:(NSNotification*)aNote
{
	[enableReferencePulserButton setIntValue: [model enableReferencePulser]];
}

- (void) enableInputTestModeChanged:(NSNotification*)aNote
{
	[enableInputTestModeButton setIntValue: [model enableInputTestMode]];
}

- (void) enable25MHzPulsesChanged:(NSNotification*)aNote
{
	[enable25MHzPulsesButton setIntValue: [model enable25MHzPulses]];
}

- (void) lemoInModeChanged:(NSNotification*)aNote
{
	[lemoInModePU selectItemAtIndex: [model lemoInMode]];
	
	int theMode = [model lemoInMode];
	NSString* s = @"";
	if(theMode == 0){
		s = [s stringByAppendingString:@"1->disable cnt all channels\n"];
		s = [s stringByAppendingString:@"2->clear all channels\n"];
		s = [s stringByAppendingString:@"5->ext clk shadow register\n"];
		s = [s stringByAppendingString:@"7->ext test pulse (<50MHz)\n"];
	}
	else if(theMode == 1){
		s = [s stringByAppendingString:@"1->disable cnt chan 1-16\n"];
		s = [s stringByAppendingString:@"2->clear cnt chan 1-16\n"];
		s = [s stringByAppendingString:@"3->disable cnt chan 17-32\n"];
		s = [s stringByAppendingString:@"4->clear cnt chan 17-32\n"];
		s = [s stringByAppendingString:@"5->ext clk shadow register\n"];
		s = [s stringByAppendingString:@"7->ext test pulse (<50MHz)\n"];
	}	
	else if(theMode == 2){
		s = [s stringByAppendingString:@"1->disable cnt chan 1-8\n"];
		s = [s stringByAppendingString:@"2->clear cnt chan 1-8\n"];
		s = [s stringByAppendingString:@"3->disable cnt chan 9-16\n"];
		s = [s stringByAppendingString:@"4->clear cnt chan 9-16\n"];
		s = [s stringByAppendingString:@"5->disable cnt chan 17-24\n"];
		s = [s stringByAppendingString:@"6->clear cnt chan 17-24\n"];
		s = [s stringByAppendingString:@"7->disable cnt chan 25-32\n"];
		s = [s stringByAppendingString:@"8->clear cnt chan 25-32\n"];
	}
	
	[lemoInText setStringValue:s];
}

- (void) moduleIDChanged:(NSNotification*)aNote
{
	unsigned short moduleID = [model moduleID];
	if(moduleID) [moduleIDField setStringValue:[NSString stringWithFormat:@"%x",moduleID]];
	else		 [moduleIDField setStringValue:@"---"];
}


- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORSIS3800SettingsLock to:secure];
    [settingLockButton setEnabled:secure];
}

- (void) settingsLockChanged:(NSNotification*)aNotification
{
    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORSIS3800SettingsLock];
    BOOL locked = [gSecurity isLocked:ORSIS3800SettingsLock];
    
    [settingLockButton		setState: locked];
    [addressText			setEnabled:!locked && !runInProgress];
    [initButton				setEnabled:!lockedOrRunningMaintenance];
	
    [pollTimePU				setEnabled:!lockedOrRunningMaintenance];
    [syncWithRunButton		setEnabled:!locked && !runInProgress];
    [clearOnRunStartButton	setEnabled:!locked && !runInProgress];
    [lemoInModePU			setEnabled:!lockedOrRunningMaintenance];
	[enableReferencePulserButton setEnabled:!locked && !runInProgress];
    [enableInputTestModeButton	 setEnabled:!locked && !runInProgress];
    [enable25MHzPulsesButton	 setEnabled:!locked && !runInProgress];
	
    [countEnableMatrix0	 setEnabled:!locked && !runInProgress];
    [countEnableMatrix1	 setEnabled:!locked && !runInProgress];
    [countEnableMatrix2	 setEnabled:!locked && !runInProgress];
    [countEnableMatrix3	 setEnabled:!locked && !runInProgress];
	
    [enableAllInGroupButton0	setEnabled:!locked && !runInProgress];
    [enableAllInGroupButton1	setEnabled:!locked && !runInProgress];
    [enableAllInGroupButton2	setEnabled:!locked && !runInProgress];
    [enableAllInGroupButton3	setEnabled:!locked && !runInProgress];
	
	[disableAllInGroupButton0	 setEnabled:!locked && !runInProgress];
    [disableAllInGroupButton1	 setEnabled:!locked && !runInProgress];
    [disableAllInGroupButton2	 setEnabled:!locked && !runInProgress];
    [disableAllInGroupButton3	 setEnabled:!locked && !runInProgress];
	
    [disableAllButton	 setEnabled:!locked && !runInProgress];
    [enableAllButton	 setEnabled:!locked && !runInProgress];
	
	[clearAllButton			setEnabled:!lockedOrRunningMaintenance];
	[startCountingButton	setEnabled:!lockedOrRunningMaintenance];
	[stopCountingButton		setEnabled:!lockedOrRunningMaintenance];
	[readAndClearButton		setEnabled:!lockedOrRunningMaintenance];
	[readNow				setEnabled:!lockedOrRunningMaintenance];
	[probeButton			setEnabled:!lockedOrRunningMaintenance];
	[clearOverFlowButton	setEnabled:!lockedOrRunningMaintenance];
}


- (void) setModel:(id)aModel
{
    [super setModel:aModel];
    [[self window] setTitle:[NSString stringWithFormat:@"SIS3800 Card (Slot %d)",[model slot]]];
}

- (void) slotChanged:(NSNotification*)aNotification
{
    [slotField setIntValue: [model slot]];
    [[self window] setTitle:[NSString stringWithFormat:@"SIS3800 Card (Slot %d)",[model slot]]];
}

- (void) baseAddressChanged:(NSNotification*)aNote
{
    [addressText setIntValue: [model baseAddress]];
}

- (void) countEnableMaskChanged:(NSNotification*)aNote
{
	short i;
	unsigned long theMask = [model countEnableMask];

	for(i=0;i<32;i++){
		BOOL bitSet = (theMask&(1L<<i))>0;
		if(i>=0 && i<8)			[[countEnableMatrix0 cellWithTag:i] setState:bitSet];
		else if(i>=8 && i<16)	[[countEnableMatrix1 cellWithTag:i] setState:bitSet];
		else if(i>=16 && i<24)	[[countEnableMatrix2 cellWithTag:i] setState:bitSet];
		else if(i>=24 && i<32)	[[countEnableMatrix3 cellWithTag:i] setState:bitSet];
	}	
}
- (void) countersChanged:(NSNotification*)aNote
{
	short i;	
	for(i=0;i<8;i++)	[[countMatrix0  cellWithTag:i] setDoubleValue:[model counts:i]];
	for(i=8;i<16;i++)	[[countMatrix1  cellWithTag:i] setDoubleValue:[model counts:i]];
	for(i=16;i<124;i++)	[[countMatrix2  cellWithTag:i] setDoubleValue:[model counts:i]];
	for(i=24;i<32;i++)	[[countMatrix3  cellWithTag:i] setDoubleValue:[model counts:i]];
}

#pragma mark •••Actions
- (void) syncWithRunAction:(id)sender
{
	[model setSyncWithRun:[sender intValue]];	
}

- (void) clearOnRunStartAction:(id)sender
{
	[model setClearOnRunStart:[sender intValue]];	
}

- (IBAction) enableReferencePulserAction:(id)sender
{
	[model setEnableReferencePulser:[sender intValue]];	
}

- (IBAction) enableInputTestModeAction:(id)sender
{
	[model setEnableInputTestMode:[sender intValue]];	
}

- (IBAction) enable25MHzPulsesAction:(id)sender
{
	[model setEnable25MHzPulses:[sender intValue]];	
}

- (IBAction) lemoInModeAction:(id)sender
{
	[model setLemoInMode:[sender indexOfSelectedItem]];	
}

- (IBAction) countEnableMask1Action:(id)sender
{
	[model setCountEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (IBAction) countEnableMask2Action:(id)sender
{
	NSLog(@"--- %d\n",[[sender selectedCell] tag]);
	[model setCountEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (IBAction) countEnableMask3Action:(id)sender
{
	[model setCountEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (IBAction) countEnableMask4Action:(id)sender
{
	[model setCountEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (IBAction) probeBoardAction:(id)sender;
{
	@try {
		[model readModuleID:YES];
	}
	@catch (NSException* localException) {
		NSLog(@"Probe of SIS 3300 board ID failed\n");
	}
}

- (IBAction) baseAddressAction:(id)sender
{
    if([sender intValue] != [model baseAddress]){
        [model setBaseAddress:[sender intValue]];
    }
}

- (IBAction) enableAll:(id)sender
{
	[model setCountEnableMask:0xFFFFFFFF];
}

- (IBAction) disableAll:(id)sender
{
	[model setCountEnableMask:0x00000000];
}

- (IBAction) enableAllInGroup:(id)sender
{
	unsigned long aMask = [model countEnableMask];
	switch ([sender tag]) {
		case 0: aMask |= 0x000000ff; break;
		case 1: aMask |= 0x0000ff00; break;
		case 2: aMask |= 0x00ff0000; break;
		case 3: aMask |= 0xff000000; break;
	}
	[model setCountEnableMask:aMask];
}

- (IBAction) disableAllInGroup:(id)sender
{
	unsigned long aMask = [model countEnableMask];
	switch ([sender tag]) {
		case 0: aMask &= ~0x000000ff; break;
		case 1: aMask &= ~0x0000ff00; break;
		case 2: aMask &= ~0x00ff0000; break;
		case 3: aMask &= ~0xff000000; break;
	}
	[model setCountEnableMask:aMask];
}

- (IBAction) settingLockAction:(id) sender
{
    [gSecurity tryToSetLock:ORSIS3800SettingsLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) initBoard:(id)sender
{
    @try {
        [self endEditing];
        [model initBoard];		//initialize and load hardward
        NSLog(@"Initialized SIS3800 (Slot %d <%p>)\n",[model slot],[model baseAddress]);
        
    }
	@catch(NSException* localException) {
        NSLog(@"Reset and Init of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Reset and Init", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) readNoClear:(id)sender
{
    @try {
		[model readCounts:NO];
    }
	@catch(NSException* localException) {
        NSLog(@"Read Scalers of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Read No Clear", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) readAndClear:(id)sender
{
    @try {
		[model readCounts:YES];
    }
	@catch(NSException* localException) {
        NSLog(@"Read Scalers of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Read And clear", @"OK", nil, nil,
                        localException);
    }
}
- (IBAction) clearAll:(id)sender;
{
    @try {
		[model clearAll];
    }
	@catch(NSException* localException) {
        NSLog(@"Clear Scalers of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Clear", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) clearAllOverFlowFlags:(id)sender;
{
    @try {
		int i;
		for(i=0;i<32;i++){
			[model clearOverFlowCounter:i];
		}
    }
	@catch(NSException* localException) {
        NSLog(@"Clear Overflow of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Clear Overflow", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) startAction:(id)sender
{
	@try {
		[model startCounting];
    }
	@catch(NSException* localException) {
        NSLog(@"Start Counting of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Start", @"OK", nil, nil,
                        localException);
    }
	
}

- (IBAction) stopAction:(id)sender
{
	@try {
		[model stopCounting];
    }
	@catch(NSException* localException) {
        NSLog(@"Stop Counting of SIS3800 FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed SIS3800 Stop", @"OK", nil, nil,
                        localException);
    }
	
}
- (IBAction) pollTimeAction:(id)sender
{
	[model setPollTime:[sender indexOfSelectedItem]];
}


@end
