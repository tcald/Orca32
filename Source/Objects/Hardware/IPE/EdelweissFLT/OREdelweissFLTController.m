//
//  OREdelweissFLTController.m
//  Orca
//
//  Created by Mark Howe on Wed Aug 24 2005.
//  Copyright (c) 2002 CENPA, University of Washington. All rights reserved.
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

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Imported Files
#import "OREdelweissFLTController.h"
#import "OREdelweissFLTModel.h"
#import "OREdelweissFLTDefs.h"
#import "SLTv4_HW_Definitions.h"
#import "ORFireWireInterface.h"
#import "ORTimeRate.h"
#import "ORPlotView.h"
#import "ORTimeLinePlot.h"
#import "ORValueBar.h"
#import "ORTimeAxis.h"
#import "ORValueBarGroupView.h"
#import "ORCompositePlotView.h"

@implementation OREdelweissFLTController

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Initialization
-(id)init
{
    self = [super initWithWindowNibName:@"EdelweissFLT"];
    
    return self;
}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Initialization
- (void) dealloc
{
	[rateFormatter release];
	[blankView release];
    [super dealloc];
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	
    settingSize			= NSMakeSize(670,790);
    triggerSize			= NSMakeSize(670,790);
    rateSize			= NSMakeSize(670,790);
    BBAccessSize		= NSMakeSize(670,790);
    testSize			= NSMakeSize(450,420);
    lowlevelSize		= NSMakeSize(450,420);
	
	rateFormatter = [[NSNumberFormatter alloc] init];
	[rateFormatter setFormat:@"##0.00"];
	[totalHitRateField setFormatter:rateFormatter];
	[rateTextFields setFormatter:rateFormatter];
    blankView = [[NSView alloc] init];
    
    NSString* key = [NSString stringWithFormat: @"orca.OREdelweissFLT%d.selectedtab",[model stationNumber]];
    int index = [[NSUserDefaults standardUserDefaults] integerForKey: key];
    if((index<0) || (index>[tabView numberOfTabViewItems]))index = 0;
    [tabView selectTabViewItemAtIndex: index];
	

	ORTimeLinePlot* aPlot = [[ORTimeLinePlot alloc] initWithTag:0 andDataSource:self];
	[timeRatePlot addPlot: aPlot];
	[(ORTimeAxis*)[timeRatePlot xAxis] setStartTime: [[NSDate date] timeIntervalSince1970]];
	[aPlot release];
	
	[self populatePullDown];
	[self updateWindow];
	
	[rate0 setNumber:18 height:10 spacing:6];
    
    //Trigger tab view
    [heatChannelsTextField setFrameCenterRotation:90.0];
    [ionChannelsTextField setFrameCenterRotation:90.0];
    [heatChannelsTextField2 setFrameCenterRotation:90.0];
    [ionChannelsTextField2 setFrameCenterRotation:90.0];

}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Accessors

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Notifications
- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    
    [super registerNotificationObservers];
    
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(settingsLockChanged:)
                         name : OREdelweissFLTSettingsLock
                        object: nil];
    
    [notifyCenter addObserver : self
					 selector : @selector(slotChanged:)
						 name : ORIpeCardSlotChangedNotification
					   object : model];
	
	
    [notifyCenter addObserver : self
                     selector : @selector(modeChanged:)
                         name : OREdelweissFLTModelModeChanged
                       object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(thresholdChanged:)
						 name : OREdelweissFLTModelThresholdChanged
					   object : model];
	
    #if 0
    [notifyCenter addObserver : self
					 selector : @selector(thresholdArrayChanged:)
						 name : OREdelweissFLTModelThresholdsChanged
					   object : model];
    #endif
	
    [notifyCenter addObserver : self
					 selector : @selector(gainChanged:)
						 name : OREdelweissFLTModelGainChanged
					   object : model];

	
    [notifyCenter addObserver : self
					 selector : @selector(gainArrayChanged:)
						 name : OREdelweissFLTModelGainsChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(hitRateLengthChanged:)
						 name : OREdelweissFLTModelHitRateLengthChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(hitRateChanged:)
						 name : OREdelweissFLTModelHitRateChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(hitRateEnabledMaskChanged:)
						 name : OREdelweissFLTModelHitRateEnabledMaskChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(totalRateChanged:)
						 name : ORRateAverageChangedNotification
					   object : [model totalRate]];
	
    [notifyCenter addObserver : self
                     selector : @selector(testEnabledArrayChanged:)
                         name : OREdelweissFLTModelTestEnabledArrayChanged
                       object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(testStatusArrayChanged:)
                         name : OREdelweissFLTModelTestStatusArrayChanged
                       object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(updateWindow)
                         name : OREdelweissFLTModelTestsRunningChanged
                       object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(interruptMaskChanged:)
                         name : OREdelweissFLTModelInterruptMaskChanged
						object: model];
	
    [notifyCenter addObserver : self
					 selector : @selector(selectedRegIndexChanged:)
						 name : OREdelweissFLTSelectedRegIndexChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(writeValueChanged:)
						 name : OREdelweissFLTWriteValueChanged
					   object : model];

    [notifyCenter addObserver : self
					 selector : @selector(selectedChannelValueChanged:)
						 name : OREdelweissFLTSelectedChannelValueChanged
					   object : model];

    [notifyCenter addObserver : self
                     selector : @selector(fifoBehaviourChanged:)
                         name : OREdelweissFLTModelFifoBehaviourChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(postTriggerTimeChanged:)
                         name : OREdelweissFLTModelPostTriggerTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(gapLengthChanged:)
                         name : OREdelweissFLTModelGapLengthChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(filterLengthChanged:)
                         name : OREdelweissFLTModelFilterLengthChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(storeDataInRamChanged:)
                         name : OREdelweissFLTModelStoreDataInRamChanged
						object: model];


    [notifyCenter addObserver : self
                     selector : @selector(noiseFloorChanged:)
                         name : OREdelweissFLTNoiseFloorChanged
                       object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(noiseFloorOffsetChanged:)
                         name : OREdelweissFLTNoiseFloorOffsetChanged
                       object : model];

    [notifyCenter addObserver : self
                     selector : @selector(targetRateChanged:)
                         name : OREdelweissFLTModelTargetRateChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fltModeFlagsChanged:)
                         name : OREdelweissFLTModelFltModeFlagsChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fiberEnableMaskChanged:)
                         name : OREdelweissFLTModelFiberEnableMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(BBv1MaskChanged:)
                         name : OREdelweissFLTModelBBv1MaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(selectFiberTrigChanged:)
                         name : OREdelweissFLTModelSelectFiberTrigChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(streamMaskChanged:)
                         name : OREdelweissFLTModelStreamMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fiberDelaysChanged:)
                         name : OREdelweissFLTModelFiberDelaysChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fastWriteChanged:)
                         name : OREdelweissFLTModelFastWriteChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(statusRegisterChanged:)
                         name : OREdelweissFLTModelStatusRegisterChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(totalTriggerNRegisterChanged:)
                         name : OREdelweissFLTModelTotalTriggerNRegisterChanged
						object: model];


    [notifyCenter addObserver : self
                     selector : @selector(controlRegisterChanged:)
                         name : OREdelweissFLTModelControlRegisterChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(repeatSWTriggerModeChanged:)
                         name : OREdelweissFLTModelRepeatSWTriggerModeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(swTriggerIsRepeatingChanged:)
                         name : OREdelweissFLTModelSwTriggerIsRepeatingChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(tpixChanged:)
                         name : OREdelweissFLTModelTpixChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fiberOutMaskChanged:)
                         name : OREdelweissFLTModelFiberOutMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fiberSelectForBBStatusBitsChanged:)
                         name : OREdelweissFLTModelFiberSelectForBBStatusBitsChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(relaisStatesBBChanged:)
                         name : OREdelweissFLTModelRelaisStatesBBChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fiberSelectForBBAccessChanged:)
                         name : OREdelweissFLTModelFiberSelectForBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(idBBforBBAccessChanged:)
                         name : OREdelweissFLTModelIdBBforBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(useBroadcastIdforBBAccessChanged:)
                         name : OREdelweissFLTModelUseBroadcastIdforBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(adcFreqkHzForBBAccessChanged:)
                         name : OREdelweissFLTModelAdcFreqkHzForBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(adcMultForBBAccessChanged:)
                         name : OREdelweissFLTModelAdcMultForBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(adcValueForBBAccessChanged:)
                         name : OREdelweissFLTModelAdcValueForBBAccessChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(polarDacChanged:)
                         name : OREdelweissFLTModelPolarDacChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triDacChanged:)
                         name : OREdelweissFLTModelTriDacChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rectDacChanged:)
                         name : OREdelweissFLTModelRectDacChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(adcRgForBBAccessChanged:)
                         name : OREdelweissFLTModelAdcRgForBBAccessChanged
						object: model];


    [notifyCenter addObserver : self
                     selector : @selector(statusBitsBBDataChanged:)
                         name : OREdelweissFLTModelStatusBitsBBDataChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(signaChanged:)
                         name : OREdelweissFLTModelSignaChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(dacaChanged:)
                         name : OREdelweissFLTModelDacaChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(signbChanged:)
                         name : OREdelweissFLTModelSignbChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(dacbChanged:)
                         name : OREdelweissFLTModelDacbChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(adcRtChanged:)
                         name : OREdelweissFLTModelAdcRtChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(D2Changed:)
                         name : OREdelweissFLTModelD2Changed
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(D3Changed:)
                         name : OREdelweissFLTModelD3Changed
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(wCmdCodeChanged:)
                         name : OREdelweissFLTModelWCmdCodeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(wCmdArg1Changed:)
                         name : OREdelweissFLTModelWCmdArg1Changed
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(wCmdArg2Changed:)
                         name : OREdelweissFLTModelWCmdArg2Changed
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(writeToBBModeChanged:)
                         name : OREdelweissFLTModelWriteToBBModeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(lowLevelRegInHexChanged:)
                         name : OREdelweissFLTModelLowLevelRegInHexChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionTriggerMaskChanged:)
                         name : OREdelweissFLTModelIonTriggerMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(heatTriggerMaskChanged:)
                         name : OREdelweissFLTModelHeatTriggerMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerParameterChanged:)
                         name : OREdelweissFLTModelTriggerParameterChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerEnabledChanged:)
                         name : OREdelweissFLTModelTriggerEnabledMaskChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionToHeatDelayChanged:)
                         name : OREdelweissFLTModelIonToHeatDelayChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(chargeBBFileChanged:)
                         name : OREdelweissFLTModelChargeBBFileChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(BB0x0ACmdMaskChanged:)
                         name : OREdelweissFLTModelBB0x0ACmdMaskChanged
						object: model];

}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Interface Management

- (void) BB0x0ACmdMaskChanged:(NSNotification*)aNote
{
	[BB0x0ACmdMaskTextField setIntValue: (int)[model BB0x0ACmdMask]];
   	int i;
	for(i=0;i<8;i++){
		[[BB0x0ACmdMaskMatrix cellWithTag:i] setIntValue: ([model BB0x0ACmdMask] & (0x1 <<i))];//cellWithTag:i is not defined for all i, but it works anyway
	}    
}

- (void) chargeBBFileChanged:(NSNotification*)aNote
{
	[chargeBBFileTextField setStringValue: [model chargeBBFile]];
}

- (void) ionToHeatDelayChanged:(NSNotification*)aNote
{
	[ionToHeatDelayTextField setIntValue: [model ionToHeatDelay]];
}

- (void) lowLevelRegInHexChanged:(NSNotification*)aNote
{
	//[lowLevelRegInHexPU setIntValue: [model lowLevelRegInHex]];
    [self endEditing];
	[lowLevelRegInHexPU selectItemAtIndex: [model lowLevelRegInHex]];
    if([model lowLevelRegInHex]){
        [regWriteValueTextField setFormatter: regWriteValueTextFieldFormatter];
    }else {
        [regWriteValueTextField setFormatter: nil];
    }

    [self writeValueChanged:nil];
}

- (void) writeToBBModeChanged:(NSNotification*)aNote
{
	[writeToBBModeCB setIntValue: [model writeToBBMode]];
    if([model writeToBBMode]){
        [writeToBBModeIndicator startAnimation:nil];
    }else{
        [writeToBBModeIndicator stopAnimation:nil];
    }
}

- (void) wCmdArg2Changed:(NSNotification*)aNote
{
	[wCmdArg2TextField setIntValue: [model wCmdArg2]];
}

- (void) wCmdArg1Changed:(NSNotification*)aNote
{
	[wCmdArg1TextField setIntValue: [model wCmdArg1]];
}

- (void) wCmdCodeChanged:(NSNotification*)aNote
{
	[wCmdCodeTextField setIntValue: [model wCmdCode]];
}

- (void) adcRtChanged:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
	[adcRtTextField setIntValue: [model adcRtForFiber:fiber]];
	[adcRtStepper setIntValue: [model adcRtForFiber:fiber]];
    //DEBUG 	    NSLog(@"%@::%@ fiber %i val %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiber,[model adcRtForFiber:fiber]);//TODO: DEBUG testing ...-tb-
}

- (void) D2Changed:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
	[D2TextField setIntValue: [model D2ForFiber:fiber]];
}

- (void) D3Changed:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
	[D3TextField setIntValue: [model D3ForFiber:fiber]];
}

- (void) statusBitsBBDataChanged:(NSNotification*)aNote
{

//TODO: call this after initFromCoder ...
	//[statusBitsBBArrayNo Outlet setObjectValue: [model statusBitsBBData]];
}




- (void) dacbChanged:(NSNotification*)aNote
{
	//[dacb<custom> setIntValue: [model dacb]];
    int fiber = [model fiberSelectForBBAccess];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[dacbMatrix cellWithTag:index] setIntValue: [model dacbForFiber: fiber atIndex:index]];
}

- (void) signbChanged:(NSNotification*)aNote
{
	//[signb<custom> setIntValue: [model signb]];
    int fiber = [model fiberSelectForBBAccess];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
    int sign = [model signbForFiber: fiber atIndex:index];
	[[signbMatrix cellWithTag:index] setIntValue: sign];
	[[signbMatrix cellWithTag:index] setTitle: (sign ? @"-":@"+")];
}

- (void) dacaChanged:(NSNotification*)aNote
{
	//[daca<custom> setIntValue: [model daca]];
    int fiber = [model fiberSelectForBBAccess];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[dacaMatrix cellWithTag:index] setIntValue: [model dacaForFiber: fiber atIndex:index]];
}

- (void) signaChanged:(NSNotification*)aNote
{
	//[signa<custom> setIntValue: [model signa]];
    int fiber = [model fiberSelectForBBAccess];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
    int sign = [model signaForFiber: fiber atIndex:index];
	[[signaMatrix cellWithTag:index] setIntValue: sign];
	[[signaMatrix cellWithTag:index] setTitle: (sign ? @"-":@"+")];
}

- (void) adcRgForBBAccessChanged:(NSNotification*)aNote
{
	//[adcRgForBBAccess<custom> setIntValue: [model adcRgForBBAccess]];
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[adcRgForBBAccessMatrix cellWithTag:index] setIntValue: [model adcRgForBBAccessForFiber: fiber atIndex:index]];
}

- (void) adcValueForBBAccessChanged:(NSNotification*)aNote
{
	//[adcValueForBBAccess<custom> setIntValue: [model adcValueForBBAccess]];
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[adcValueForBBAccessMatrix cellWithTag:index] setIntValue: [model adcValueForBBAccessForFiber: fiber atIndex:index]];
}

- (void) adcMultForBBAccessChanged:(NSNotification*)aNote
{
	//[adcMultForBBAccess<custom> setIntValue: [model adcMultForBBAccess]];
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[adcMultForBBAccessMatrix cellWithTag:index] setIntValue: [model adcMultForBBAccessForFiber: fiber atIndex:index]];
}






- (void) adcFreqkHzForBBAccessChanged:(NSNotification*)aNote
{
    int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
        //DEBUG OUTPUT: 	        
        NSLog(@"%@::%@: userInfo fiber %i index %i  \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiber, index);//TODO : DEBUG testing ...-tb-

    int selectedFiber = [model fiberSelectForBBAccess];
    if(fiber != selectedFiber){
        //is not visible
        //DEBUG OUTPUT: 	        
        NSLog(@"%@::%@: changed item is not visible \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
        return;
    }

	//[adcFreqkHzForBBAccess<custom> setIntValue: [model adcFreqkHzForBBAccess]];
	[[adcFreqkHzForBBAccessMatrix cellWithTag:index] setIntValue: [model adcFreqkHzForBBAccessForFiber: fiber atIndex:index]];
    
}


- (void) polarDacChanged:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[polarDacMatrix cellWithTag:index] setIntValue: [model polarDacForFiber: fiber atIndex:index]];
}

- (void) triDacChanged:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[triDacMatrix cellWithTag:index] setIntValue: [model triDacForFiber: fiber atIndex:index]];
}

- (void) rectDacChanged:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
      //not set ...int fiber = [[[aNote userInfo] objectForKey:OREdelweissFLTFiber] intValue];
    int index = [[[aNote userInfo] objectForKey:OREdelweissFLTIndex] intValue];
	[[rectDacMatrix cellWithTag:index] setIntValue: [model rectDacForFiber: fiber atIndex:index]];
}





- (void) useBroadcastIdforBBAccessChanged:(NSNotification*)aNote
{
	[useBroadcastIdforBBAccessCB setIntValue: [model useBroadcastIdforBBAccess]];
    if([model useBroadcastIdforBBAccess]){
    	[idBBforWCommandTextField setStringValue: @"0xFF"];
    	[idBBforAlimCommandTextField setStringValue: @"0xFF"];
    }else{
        int fiber = [model fiberSelectForBBAccess];
    	[idBBforWCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
    	[idBBforAlimCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
    }
}

- (void) idBBforBBAccessChanged:(NSNotification*)aNote
{
    int fiber = [model fiberSelectForBBAccess];
	[idBBforBBAccessTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
	//[idBBforWCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
	//[idBBforAlimCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
    if([model useBroadcastIdforBBAccess]){
    	[idBBforWCommandTextField setStringValue: @"0xFF"];
    	[idBBforAlimCommandTextField setStringValue: @"0xFF"];
    }else{
        int fiber = [model fiberSelectForBBAccess];
    	[idBBforWCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
    	[idBBforAlimCommandTextField setIntValue: [model idBBforBBAccessForFiber:fiber]];
    }
}


//this is the most important updater!
- (void) fiberSelectForBBAccessChanged:(NSNotification*)aNote
{
        //DEBUG OUTPUT: 	        
        NSLog(@"%@::%@: fiberSelectForBBAccess %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model fiberSelectForBBAccess]);//TODO : DEBUG testing ...-tb-
	//[fiberSelectForBBAccessPU setIntValue: [model fiberSelectForBBAccess]];
    int fiber = [model fiberSelectForBBAccess];
	[fiberSelectForBBAccessPU selectItemAtIndex: fiber];
    
    //update infos
    if([model BBv1MaskForChan:fiber])[fiberIsBBv1TextField setStringValue:@"Is BBv1: YES"];
    else [fiberIsBBv1TextField setStringValue:@"Is BBv1: NO"];
    
    //update everything from the BB status bit buffer!
    int index;
	[self relaisStatesBBChanged:nil];
	//[self adcFreqkHzForBBAccessChanged:nil];
    for(index=0;index<6;index++)
    	[[adcFreqkHzForBBAccessMatrix cellWithTag:index] setIntValue: [model adcFreqkHzForBBAccessForFiber: fiber atIndex:index]];
    
	//[self adcMultForBBAccessChanged:nil];
    for(index=0;index<6;index++)
    	[[adcMultForBBAccessMatrix cellWithTag:index] setIntValue: [model adcMultForBBAccessForFiber: fiber atIndex:index]];

	//[self adcValueForBBAccessChanged:nil];
    for(index=0;index<6;index++)
    	[[adcValueForBBAccessMatrix cellWithTag:index] setIntValue: [model adcValueForBBAccessForFiber: fiber atIndex:index]];
    
    for(index=0;index<12;index++)
    	[[polarDacMatrix cellWithTag:index] setIntValue: [model polarDacForFiber: fiber atIndex:index]];
    
    for(index=0;index<6;index++)
    	[[triDacMatrix cellWithTag:index] setIntValue: [model triDacForFiber: fiber atIndex:index]];
    
    for(index=0;index<6;index++)
    	[[rectDacMatrix cellWithTag:index] setIntValue: [model rectDacForFiber: fiber atIndex:index]];
    
	/*
    [self adcRgForBBAccessChanged:nil];
	[self signaChanged:nil];
	[self dacaChanged:nil];
	[self signbChanged:nil];
	[self dacbChanged:nil];
    */
    for(index=0;index<6;index++){
    	[[adcRgForBBAccessMatrix cellWithTag:index] setIntValue: [model adcRgForBBAccessForFiber: fiber atIndex:index]];
    	[[signaMatrix cellWithTag:index] setIntValue: [model signaForFiber: fiber atIndex:index]];
    	[[dacaMatrix cellWithTag:index] setIntValue: [model dacaForFiber: fiber atIndex:index]];
    	[[signbMatrix cellWithTag:index] setIntValue: [model signbForFiber: fiber atIndex:index]];
    	[[dacbMatrix cellWithTag:index] setIntValue: [model dacbForFiber: fiber atIndex:index]];
        int signa = [model signaForFiber: fiber atIndex:index];
	    [[signaMatrix cellWithTag:index] setTitle: (signa ? @"-":@"+")];
        int signb = [model signbForFiber: fiber atIndex:index];
	    [[signbMatrix cellWithTag:index] setTitle: (signb ? @"-":@"+")];
    }
        
        
        
	//[self adcRtForBBAccessChanged:nil];
    [self adcRtChanged:nil];
    [self D2Changed:nil];
    [self D3Changed:nil];
	[self idBBforBBAccessChanged:nil];

}

- (void) relaisStatesBBChanged:(NSNotification*)aNote
{
//	[relaisStatesBB<custom> setIntValue: [model relaisStatesBB]];
    int fiber = [model fiberSelectForBBAccess];
	int i;
    /* //obsolete 2013-08-08
    int32_t relaisStates = [model relaisStatesBBForFiber:fiber];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: UNDER CONSTRUCTION! fiberOutMask  %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiberOutMask);//TODO : DEBUG testing ...-tb-
	for(i=0;i<3;i++){
		[[relaisStatesBBMatrix cellWithTag:i] setIntValue: (relaisStates&(0x1<<i)) ];
	} 
    */   
    [refBBCheckBox setIntValue:[model refForBBAccessForFiber:fiber]];
    
    int32_t adcOnOfVal = [model adcOnOffForBBAccessForFiber:fiber];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: UNDER CONSTRUCTION! fiberOutMask  %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiberOutMask);//TODO : DEBUG testing ...-tb-
	for(i=0;i<[adcOnOffBBMatrix numberOfColumns];i++){
		[[adcOnOffBBMatrix cellAtRow:0 column:i] setIntValue: (adcOnOfVal&(0x1<<i)) ];
	} 
    
    [relais1PU selectItemAtIndex:[model relais1ForBBAccessForFiber:fiber]];
    [relais2PU selectItemAtIndex:[model relais2ForBBAccessForFiber:fiber]];

    int32_t mezVal = [model mezForBBAccessForFiber:fiber];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: UNDER CONSTRUCTION! fiberOutMask  %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiberOutMask);//TODO : DEBUG testing ...-tb-
	for(i=0;i<[mezOnOffBBMatrix numberOfColumns];i++){
		[[mezOnOffBBMatrix cellAtRow:0 column:i] setIntValue: (mezVal&(0x1<<i)) ];
	} 
}

- (void) fiberSelectForBBStatusBitsChanged:(NSNotification*)aNote
{
	[fiberSelectForBBStatusBitsPU selectItemAtIndex: [model fiberSelectForBBStatusBits]];
}

- (void) fiberOutMaskChanged:(NSNotification*)aNote
{
	//[fiberOutMask<custom> setIntValue: [model fiberOutMask]];
	int i;
    int32_t fiberOutMask = [model fiberOutMask];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: UNDER CONSTRUCTION! fiberOutMask  %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiberOutMask);//TODO : DEBUG testing ...-tb-
	for(i=0;i<6;i++){
		[[fiberOutMaskMatrix cellWithTag:i] setIntValue: (fiberOutMask&(0x1<<i)) ];
	}    
}

- (void) swTriggerIsRepeatingChanged:(NSNotification*)aNote
{
	if([model swTriggerIsRepeating]){
	    [swTriggerProgress  startAnimation:self ];
	}else{
	    [swTriggerProgress  stopAnimation:self ];
	}
}

- (void) repeatSWTriggerModeChanged:(NSNotification*)aNote
{
	[repeatSWTriggerModePU selectItemAtIndex: [model repeatSWTriggerMode]];
	//[repeatSWTriggerModeTextField setIntValue: [model repeatSWTriggerMode]];
}

- (void) controlRegisterChanged:(NSNotification*)aNote
{
	[controlRegisterTextField setIntValue: [model controlRegister]];
    [self fiberEnableMaskChanged:nil];
    [self selectFiberTrigChanged:nil];
    [self BBv1MaskChanged:nil];
    [self fltModeFlagsChanged:nil];
    [self tpixChanged:nil];

	//[selectFiberTrigPU selectItemAtIndex: [model selectFiberTrig]];
	[statusLatencyPU selectItemAtIndex: [model statusLatency]];
	[vetoFlagCB setIntValue: [model vetoFlag]];
}

- (void) totalTriggerNRegisterChanged:(NSNotification*)aNote
{
	[totalTriggerNRegisterTextField setIntValue: [model totalTriggerNRegister]];
}

- (void) statusRegisterChanged:(NSNotification*)aNote
{
	[statusRegisterTextField setIntValue: [model statusRegister]];
}

- (void) fastWriteChanged:(NSNotification*)aNote
{
	[fastWriteCB setIntValue: [model fastWrite]];
}

- (void) fiberDelaysChanged:(NSNotification*)aNote
{
    uint64_t val=[model fiberDelays];
    //DEBUG OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION! 0x%016llx \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model fiberDelays]);//TODO: DEBUG testing ...-tb-
	//[fiberDelaysTextField setIntValue: [model fiberDelays]];
	[fiberDelaysTextField setStringValue: [NSString stringWithFormat:@"0x%016qx",val]];

	uint64_t fibDelays;
	uint64_t fib;
	int clk12,clk120;

	for(fib=0;fib<6;fib++){
	    //NSLog(@"fib %i:",fib);
			fibDelays = ((val) >> (fib*8)) & 0xffff;
			clk120 = (fibDelays & 0xf0) >> 4;
			clk12  =  fibDelays & 0x0f;
		    [[fiberDelaysMatrix cellAtRow:0 column: fib] selectItemAtIndex: clk12 ];
		    [[fiberDelaysMatrix cellAtRow:1 column: fib] selectItemAtIndex: clk120];
	}

}

- (void) streamMaskChanged:(NSNotification*)aNote
{
	//[streamMaskTextField setIntValue: [model streamMask]];
	[streamMaskTextField setStringValue: [NSString stringWithFormat:@"0x%016qx",[model streamMask]]];
	//[streamMaskTextField setStringValue: [NSString stringWithFormat:@"0x1234000012340000"]];
//DEBUG OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION! 0x%016qx 0x%032qx 0x%016llx \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model streamMask],[model streamMask],[model streamMask]);//TODO: DEBUG testing ...-tb-

	//[model setStreamMask:[sender intValue]];	
	uint64_t chan, fib;
    //uint64_t val=[model streamMask];
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %llu:",fib];
	    for(chan=0;chan<6;chan++){
		    if([model streamMaskForFiber:fib chan:chan]) [[streamMaskMatrix cellAtRow:fib column: chan] setIntValue: 1];
			else  [[streamMaskMatrix cellAtRow:fib column: chan] setIntValue: 0];
			
			//debug s=[s stringByAppendingString: [NSString stringWithFormat: @"%u",[model streamMaskForFiber:fib chan:chan]]];
			#if 0
		    if([model streamMaskForFiber:fib chan:chan]){ 
			    //val |= ((0x1LL<<chan) << (fib*8));
				s=[s stringByAppendingString: @"1"];
			}else{
				s=[s stringByAppendingString: @"0"];
			}
			#endif
		}
		//debug NSLog(@"%@\n",s);
	}
	//debug NSLog(@"%016qx done.\n",val);
}


- (void) heatTriggerMaskChanged:(NSNotification*)aNote
{
	//[heatTriggerMaskTextField setIntValue: [model heatTriggerMask]];
	[heatTriggerMaskTextField setStringValue: [NSString stringWithFormat:@"0x%016qx",[model heatTriggerMask]]];
	//[streamMaskTextField setStringValue: [NSString stringWithFormat:@"0x1234000012340000"]];
//DEBUG OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION! 0x%016qx 0x%032qx 0x%016llx \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model streamMask],[model streamMask],[model streamMask]);//TODO: DEBUG testing ...-tb-

	uint64_t chan, fib;
    //uint64_t val=[model streamMask];
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %llu:",fib];
	    for(chan=0;chan<6;chan++){
		    if([model heatTriggerMaskForFiber:fib chan:chan]) [[heatTriggerMaskMatrix cellAtRow:fib column: chan] setIntValue: 1];
			else  [[heatTriggerMaskMatrix cellAtRow:fib column: chan] setIntValue: 0];
			
			//debug s=[s stringByAppendingString: [NSString stringWithFormat: @"%u",[model streamMaskForFiber:fib chan:chan]]];
			#if 0
		    if([model streamMaskForFiber:fib chan:chan]){ 
			    //val |= ((0x1LL<<chan) << (fib*8));
				s=[s stringByAppendingString: @"1"];
			}else{
				s=[s stringByAppendingString: @"0"];
			}
			#endif
		}
		//debug NSLog(@"%@\n",s);
	}
	//debug NSLog(@"%016qx done.\n",val);
    [self channelNameMatrixChanged:nil];
}

- (void) ionTriggerMaskChanged:(NSNotification*)aNote
{
	//[ionTriggerMaskTextField setIntValue: [model ionTriggerMask]];
	[ionTriggerMaskTextField setStringValue: [NSString stringWithFormat:@"0x%016qx",[model ionTriggerMask]]];
	uint64_t chan, fib;
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %llu:",fib];
	    for(chan=0;chan<6;chan++){
		    if([model ionTriggerMaskForFiber:fib chan:chan]) [[ionTriggerMaskMatrix cellAtRow:fib column: chan] setIntValue: 1];
			else  [[ionTriggerMaskMatrix cellAtRow:fib column: chan] setIntValue: 0];
		}
	}
    
    [self channelNameMatrixChanged:nil];
}

- (void) channelNameMatrixChanged:(NSNotification*)aNote
{
    //DEBUG: OUTPUT:      	
    NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-

    int fiber, chan, countHeat=0, countIon=0;
    for(fiber=0; fiber<kNumEWFLTFibers; fiber++){
        for(chan=0; chan<kNumEWFLTADCperFiber; chan++){
            //heat channels
            if([model heatTriggerMaskForFiber:fiber chan:chan] && countHeat<kNumEWFLTHeatChannels){
                [[channelNameMatrix cellAtRow:countHeat column:0] setStringValue:[NSString stringWithFormat:@"%i/%i",fiber+1,chan+1]];
                countHeat++;
            }
            //ion channels
            if([model ionTriggerMaskForFiber:fiber chan:chan] && countIon<kNumEWFLTIonChannels){
                [[channelNameMatrix cellAtRow:countIon+kNumEWFLTHeatChannels column:0] setStringValue:[NSString stringWithFormat:@"%i/%i",fiber+1,chan+1]];
                countIon++;
            }
        }
    }
    //clear unused text fields
    while(countHeat<kNumEWFLTHeatChannels){
        [[channelNameMatrix cellAtRow:countHeat column:0] setStringValue:@"-"];
        countHeat++;
    }
    while(countIon<kNumEWFLTIonChannels){
        [[channelNameMatrix cellAtRow:countIon+kNumEWFLTHeatChannels column:0] setStringValue:@"-"];
        countIon++;
    }
}


- (void) triggerParameterChanged:(NSNotification*)aNote
{
    //DEBUG: OUTPUT:      	NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
	//[selectFiberTrigPU setIntValue: [model selectFiberTrig]];
	
    //[selectFiberTrigPU selectItemAtIndex: [model selectFiberTrig]];
    
    //negPosPolarityMatrix
    int i;
    for(i=0;i<kNumEWFLTHeatIonChannels;i++){
        [[negPosPolarityMatrix cellAtRow:i column:0] setIntValue: [model negPolarity:i]];
        [[negPosPolarityMatrix cellAtRow:i column:1] setIntValue: [model posPolarity:i]];
    }    
    //gapMatrix
    for(i=0;i<kNumEWFLTHeatIonChannels;i++){
        [[gapMatrix cellAtRow:i column:0] selectItemAtIndex: [model gapLength:i]];
    }    
	//downSamplingMatrix
    for(i=0;i<kNumEWFLTHeatIonChannels;i++){
        [[downSamplingMatrix cellAtRow:i column:0] selectItemAtIndex: [model downSampling:i]];
    }    
	//shapingLengthMatrix
    for(i=0;i<kNumEWFLTHeatIonChannels;i++){
        [[shapingLengthMatrix cellAtRow:i column:0] setIntValue: [model shapingLength:i]];
    }    

}


- (void) selectFiberTrigChanged:(NSNotification*)aNote
{
    //DEBUG: OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION! [model selectFiberTrig] is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model selectFiberTrig]);//TODO : DEBUG testing ...-tb-
	//[selectFiberTrigPU setIntValue: [model selectFiberTrig]];
	[selectFiberTrigPU selectItemAtIndex: [model selectFiberTrig]];
}

- (void) BBv1MaskChanged:(NSNotification*)aNote
{
	//[BBv1MaskMatrix setIntValue: [model BBv1Mask]];
	int i;
	for(i=0;i<6;i++){
		[[BBv1MaskMatrix cellWithTag:i] setIntValue:[model BBv1MaskForChan:i]];
        //DEBUG OUTPUT: 	NSLog(@"%@::%@: UNDER CONSTRUCTION! [model BBv1MaskForChan:%i] %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),i,[model BBv1MaskForChan:i]);//TODO : DEBUG testing ...-tb-
	}    
    int fiber = [model fiberSelectForBBAccess];
    if([model BBv1MaskForChan:fiber])[fiberIsBBv1TextField setStringValue:@"Is BBv1: YES"];
    else [fiberIsBBv1TextField setStringValue:@"Is BBv1: NO"];

}

- (void) fiberEnableMaskChanged:(NSNotification*)aNote
{
	//[fiberEnableMask<custom> setIntValue: [model fiberEnableMask]];
	int i;
	for(i=0;i<6;i++){
		[[fiberEnableMaskMatrix cellAtRow:0 column:i] setIntValue: [model fiberEnableMaskForChan:i] ];
	}    
}

- (void) fltModeFlagsChanged:(NSNotification*)aNote
{
    int index=4;
	switch([model fltModeFlags]){
	    case 0x0: index=0; break;
	    case 0x1: index=1; break;
	    case 0x2: index=2; break;
	    case 0x3: index=3; break;
	    default: index=0; break;
	}
	[fltModeFlagsPU selectItemAtIndex: index];
	//[fltModeFlagsPU setIntValue: [model fltModeFlags]];
}

- (void) tpixChanged:(NSNotification*)aNote
{
	[tpixCB setIntValue: [model tpix]];
}


- (void) targetRateChanged:(NSNotification*)aNote
{
	[targetRateField setIntValue: [model targetRate]];
}


- (void) storeDataInRamChanged:(NSNotification*)aNote
{
	[storeDataInRamCB setIntValue: [model storeDataInRam]];
}

- (void) filterLengthChanged:(NSNotification*)aNote
{
	[filterLengthPU selectItemAtIndex:[model filterLength]-2];
}

- (void) gapLengthChanged:(NSNotification*)aNote
{
	[gapLengthPU selectItemAtIndex: [model gapLength]];
}

- (void) postTriggerTimeChanged:(NSNotification*)aNote
{
	[postTriggerTimeField setIntValue: [model postTriggerTime]];
}

- (void) fifoBehaviourChanged:(NSNotification*)aNote
{
	[fifoBehaviourMatrix selectCellWithTag: [model fifoBehaviour]];
}

- (void) interruptMaskChanged:(NSNotification*)aNote
{
	[interruptMaskField setIntValue: [model interruptMask]];
}

- (void) populatePullDown
{
    short	i;
	
	// Clear all the popup items.
    [registerPopUp removeAllItems];
    
	// Populate the register popup
    for (i = 0; i < [model getNumberRegisters]; i++) {
         //DEBUG NSLog(@"%@::%@: UNDER CONSTRUCTION! i  %i  name %@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),i,[model getRegisterName:i]);//TODO : DEBUG testing ...-tb-
        [registerPopUp insertItemWithTitle:[model getRegisterName:i] atIndex:i];
    } 
   
    
	// Clear all the popup items.
    [channelPopUp removeAllItems];
    
	// Populate the register popup
    for (i = 0; i < 24; i++) {
        [channelPopUp insertItemWithTitle: [NSString stringWithFormat: @"%i",i+1 ] atIndex:i];
        [[channelPopUp itemAtIndex:i] setTag: i];
    }
    [channelPopUp insertItemWithTitle: @"All" atIndex:i];
    [[channelPopUp itemAtIndex:i] setTag: 0x1f];// chan 31 = broadcast to all channels
}

- (void) updateWindow
{
    [super updateWindow];
    [self slotChanged:nil];
	[self modeChanged:nil];
	[self gainArrayChanged:nil];//TODO: obsolete -tb- 2013
	[self hitRateLengthChanged:nil];
	[self hitRateChanged:nil];
    [self updateTimePlot:nil];
    [self totalRateChanged:nil];
	[self scaleAction:nil];
    [self testEnabledArrayChanged:nil];
	[self testStatusArrayChanged:nil];
    [self miscAttributesChanged:nil];
	[self interruptMaskChanged:nil];
	[self selectedRegIndexChanged:nil];
	[self writeValueChanged:nil];
	[self selectedChannelValueChanged:nil];
	[self fifoBehaviourChanged:nil];
	[self postTriggerTimeChanged:nil];
    [self settingsLockChanged:nil];
	[self gapLengthChanged:nil];
	[self filterLengthChanged:nil];
	[self storeDataInRamChanged:nil];
	[self noiseFloorChanged:nil];
	[self noiseFloorOffsetChanged:nil];
	[self targetRateChanged:nil];
	[self fltModeFlagsChanged:nil];
	[self fiberEnableMaskChanged:nil];
	[self BBv1MaskChanged:nil];
	[self selectFiberTrigChanged:nil];
	[self streamMaskChanged:nil];
	[self fiberDelaysChanged:nil];
	[self fastWriteChanged:nil];
	[self statusRegisterChanged:nil];
	[self totalTriggerNRegisterChanged:nil];
	[self controlRegisterChanged:nil];
	[self repeatSWTriggerModeChanged:nil];
	[self swTriggerIsRepeatingChanged:nil];
	[self tpixChanged:nil];
	[self fiberOutMaskChanged:nil];
	[self fiberSelectForBBStatusBitsChanged:nil];
	[self useBroadcastIdforBBAccessChanged:nil];
	[self statusBitsBBDataChanged:nil];//?? still needed? -tb-
    
	[self fiberSelectForBBAccessChanged:nil];
      //<--- this calls the following commented methods
      /*
	[self idBBforBBAccessChanged:nil];
	[self relaisStatesBBChanged:nil];
	[self adcFreqkHzForBBAccessChanged:nil];
	[self adcMultForBBAccessChanged:nil];
	[self adcValueForBBAccessChanged:nil];
	[self adcRgForBBAccessChanged:nil];
	[self signaChanged:nil];
	[self dacaChanged:nil];
	[self signbChanged:nil];
	[self dacbChanged:nil];
      */
	//[self adcRtForBBAccessChanged:nil];
	[self adcRtChanged:nil];
	[self wCmdCodeChanged:nil];
	[self wCmdArg1Changed:nil];
	[self wCmdArg2Changed:nil];
	[self writeToBBModeChanged:nil];
    
    //trigger settings
	[self thresholdArrayChanged:nil];
	//[self thresholdChanged:nil];
	[self triggerEnabledChanged:nil];
	[self lowLevelRegInHexChanged:nil];
	[self ionTriggerMaskChanged:nil];
	[self heatTriggerMaskChanged:nil];
    //[self channelNameMatrixChanged:nil]; -> called by ionTriggerMaskChanged and heatTriggerMaskChanged
    [self hitRateEnabledMaskChanged:nil];
    [self triggerParameterChanged:nil];
	[self ionToHeatDelayChanged:nil];
	[self chargeBBFileChanged:nil];
	[self BB0x0ACmdMaskChanged:nil];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:OREdelweissFLTSettingsLock to:secure];
    [settingLockButton setEnabled:secure];	
}

- (void) settingsLockChanged:(NSNotification*)aNotification
{
	[self updateButtons];
}

- (void) updateButtons
{
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:OREdelweissFLTSettingsLock];
    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL locked = [gSecurity isLocked:OREdelweissFLTSettingsLock];
	BOOL testsAreRunning = [model testsRunning];
	BOOL testingOrRunning = testsAreRunning | runInProgress;
    
    [testEnabledMatrix setEnabled:!locked && !testingOrRunning];
    [settingLockButton setState: locked];
	[initBoardButton setEnabled:!lockedOrRunningMaintenance];
	[reportButton setEnabled:!lockedOrRunningMaintenance];
	[modeButton setEnabled:!lockedOrRunningMaintenance];
	[resetButton setEnabled:!lockedOrRunningMaintenance];
    [gainTextFields setEnabled:!lockedOrRunningMaintenance];
    [thresholdTextFields setEnabled:!lockedOrRunningMaintenance];
    [triggerEnabledCBs setEnabled:!lockedOrRunningMaintenance];
    [hitRateEnableMatrix setEnabled:!lockedOrRunningMaintenance];
	
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    //TODO: add new GUI elements -tb- 3013
    
    
	[versionButton setEnabled:!runInProgress];
	[testButton setEnabled:!runInProgress];
	[statusButton setEnabled:!runInProgress];
	
    [hitRateLengthPU setEnabled:!lockedOrRunningMaintenance];
    [hitRateAllButton setEnabled:!lockedOrRunningMaintenance];
    [hitRateNoneButton setEnabled:!lockedOrRunningMaintenance];
		
	if(testsAreRunning){
		[testButton setEnabled: YES];
		[testButton setTitle: @"Stop"];
	}
    else {
		[testButton setEnabled: !runInProgress];	
		[testButton setTitle: @"Test"];
	}
	

	[startNoiseFloorButton setEnabled: runInProgress || [model noiseFloorRunning]];
	
 	[self enableRegControls];
	
	//NSTabViewItem *tvi= [tabView tabViewItemAtIndex:4];
	//[tvi setEnabled:false];
	
}

- (void) enableRegControls
{
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:OREdelweissFLTSettingsLock];
	short index = [model selectedRegIndex];
	BOOL readAllowed = !lockedOrRunningMaintenance && ([model getAccessType:index] & kIpeRegReadable)>0;
	BOOL writeAllowed = !lockedOrRunningMaintenance && ([model getAccessType:index] & kIpeRegWriteable)>0;
	BOOL needsChannel = !lockedOrRunningMaintenance && ([model getAccessType:index] & kIpeRegNeedsChannel)>0;

	
	[regWriteButton setEnabled:writeAllowed];
	[regReadButton setEnabled:readAllowed];
	
	[regWriteValueStepper setEnabled:writeAllowed];
	[regWriteValueTextField setEnabled:writeAllowed];
    
    //TODO: extend the accesstype to "channel" and "block64" -tb-
    [channelPopUp setEnabled: needsChannel];
}

- (void) noiseFloorChanged:(NSNotification*)aNote
{
	if([model noiseFloorRunning]){
		[noiseFloorProgress startAnimation:self];
		[startNoiseFloorButton setTitle:@"Stop"];
	}
	else {
		[noiseFloorProgress stopAnimation:self];
		[startNoiseFloorButton setTitle:@"Start"];
	}
	[noiseFloorStateField setStringValue:[model noiseFloorStateString]];
	[noiseFloorStateField2 setStringValue:[model noiseFloorStateString]];
}

- (void) noiseFloorOffsetChanged:(NSNotification*)aNote
{
	[noiseFloorOffsetField setIntValue:[model noiseFloorOffset]];
}


- (void) testEnabledArrayChanged:(NSNotification*)aNotification
{
	int i;
	for(i=0;i<kNumEdelweissFLTTests;i++){
		[[testEnabledMatrix cellWithTag:i] setIntValue:[model testEnabled:i]];
	}    
}

- (void) testStatusArrayChanged:(NSNotification*)aNotification
{
	int i;
	for(i=0;i<kNumEdelweissFLTTests;i++){
		[[testStatusMatrix cellWithTag:i] setStringValue:[model testStatus:i]];
	}
}


- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [rate0 xAxis]){
		[model setMiscAttributes:[[rate0 xAxis]attributes] forKey:@"RateXAttributes"];
	};
	
	if(aNotification == nil || [aNotification object] == [totalRate xAxis]){
		[model setMiscAttributes:[[totalRate xAxis]attributes] forKey:@"TotalRateXAttributes"];
	};
	
	if(aNotification == nil || [aNotification object] == [timeRatePlot xAxis]){
		[model setMiscAttributes:[(ORAxis*)[timeRatePlot xAxis]attributes] forKey:@"TimeRateXAttributes"];
	};
	
	if(aNotification == nil || [aNotification object] == [timeRatePlot yAxis]){
		[model setMiscAttributes:[(ORAxis*)[timeRatePlot yAxis]attributes] forKey:@"TimeRateYAttributes"];
	};
	
}

- (void) miscAttributesChanged:(NSNotification*)aNote
{
	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"RateXAttributes"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"RateXAttributes"];
		if(attrib){
			[[rate0 xAxis] setAttributes:attrib];
			[rate0 setNeedsDisplay:YES];
			[[rate0 xAxis] setNeedsDisplay:YES];
			[rateLogCB setState:[[attrib objectForKey:ORAxisUseLog] boolValue]];
		}
	}
	if(aNote == nil || [key isEqualToString:@"TotalRateXAttributes"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"TotalRateXAttributes"];
		if(attrib){
			[[totalRate xAxis] setAttributes:attrib];
			[totalRate setNeedsDisplay:YES];
			[[totalRate xAxis] setNeedsDisplay:YES];
			[totalRateLogCB setState:[[attrib objectForKey:ORAxisUseLog] boolValue]];
		}
	}
	if(aNote == nil || [key isEqualToString:@"TimeRateXAttributes"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"TimeRateXAttributes"];
		if(attrib){
			[(ORAxis*)[timeRatePlot xAxis] setAttributes:attrib];
			[timeRatePlot setNeedsDisplay:YES];
			[[timeRatePlot xAxis] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"TimeRateYAttributes"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"TimeRateYAttributes"];
		if(attrib){
			[(ORAxis*)[timeRatePlot yAxis] setAttributes:attrib];
			[timeRatePlot setNeedsDisplay:YES];
			[[timeRatePlot yAxis] setNeedsDisplay:YES];
			[timeRateLogCB setState:[[attrib objectForKey:ORAxisUseLog] boolValue]];
		}
	}
}


- (void) updateTimePlot:(NSNotification*)aNote
{
	//if(!aNote || ([aNote object] == [[model adcRateGroup]timeRate])){
	//	[timeRatePlot setNeedsDisplay:YES];
	//}
}


- (void) gainChanged:(NSNotification*)aNotification
{
	int chan = [[[aNotification userInfo] objectForKey:OREdelweissFLTChan] intValue];
	[[gainTextFields cellWithTag:chan] setIntValue: [model gain:chan]];
}

- (void) triggerEnabledChanged:(NSNotification*)aNotification
{
	int i;
	for(i=0;i<kNumEWFLTHeatIonChannels;i++){
		[[triggerEnabledCBs cellWithTag:i] setState: [model triggerEnabled:i]];
	}
}


//TODO: unused - remove it -tb- 2013-06
- (void) triggersEnabledArrayChanged:(NSNotification*)aNotification
{
    //DEBUG 	
    NSLog(@"%@::%@  OBSOLETE (use triggerEnabledChanged)\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	short chan;
	for(chan=0;chan<kNumEWFLTHeatIonChannels;chan++){
		[[triggerEnabledCBs cellWithTag:chan] setIntValue: [model triggerEnabled:chan]];
		
	}
}



- (void) slotChanged:(NSNotification*)aNotification
{
    //DEBUG 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	// Set title of FLT configuration window 
	[[self window] setTitle:[NSString stringWithFormat:@"IPE-DAQ-V4 EDELWEISS FLT Card (Slot %d, FLT# %d)",[model slot]+1,[model stationNumber]]];
    [fltSlotNumTextField setStringValue: [NSString stringWithFormat:@"FLT# %d",[model stationNumber]]];
	//[fltSlotNumMatrix setSe];
    //[[fltSlotNumMatrix cellWithTag:[model stationNumber]] setIntValue:1];
	short chan;//'chan' is slot number -tb-
	for(chan=0;chan<kNumEWFLTs;chan++){
	    if(chan==[model stationNumber]-1)
	        [[fltSlotNumMatrix cellAtRow:0 column:chan] setState:1];
		else
            [[fltSlotNumMatrix cellAtRow:0 column:chan] setState:0];
	}
}

- (void) gainArrayChanged:(NSNotification*)aNotification
{
	short chan;
	for(chan=0;chan<kNumEWFLTHeatIonChannels;chan++){
		[[gainTextFields cellWithTag:chan] setIntValue: [model gain:chan]];
		
	}	
}


//call for change of single threshold
- (void) thresholdChanged:(NSNotification*)aNotification
{
	int chan = [[[aNotification userInfo] objectForKey:OREdelweissFLTChan] intValue];
	[[thresholdTextFields cellWithTag:chan] setIntValue: [(OREdelweissFLTModel*)model threshold:chan]];
}


//call for update of all thresholds
- (void) thresholdArrayChanged:(NSNotification*)aNotification
{
    //DEBUG 	    NSLog(@"%@::%@ is OBSOLETE!\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	short chan;
	for(chan=0;chan<kNumEWFLTHeatIonChannels;chan++){
		[[thresholdTextFields cellWithTag:chan] setIntValue: [(OREdelweissFLTModel*)model threshold:chan]];
	}
}


- (void) modeChanged:(NSNotification*)aNote
{
	[modeButton selectItemAtIndex:[model runMode]];
	[self updateButtons];
}

- (void) hitRateLengthChanged:(NSNotification*)aNote
{
	[hitRateLengthPU selectItemWithTag:[model hitRateLength]];
}

- (void) hitRateEnabledMaskChanged:(NSNotification*)aNote
{
//DEBUG OUTPUT: 	NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[hitRateLengthPU selectItemWithTag:[model hitRateLength]];
    //hitRateEnableMatrix
    int i;
    for(i=0;i<kNumEWFLTHeatIonChannels;i++){
        [[hitRateEnableMatrix cellAtRow:i column:0] setIntValue: [model hitRateEnabled:i]];
    }    
}

- (void) hitRateChanged:(NSNotification*)aNote
{
	int chan;
	for(chan=0;chan<kNumEWFLTHeatIonChannels;chan++){
		id theCell = [rateTextFields cellWithTag:chan];
		if([model hitRateOverFlow:chan]){
			[theCell setFormatter: nil];
			[theCell setTextColor:[NSColor redColor]];
			[theCell setObjectValue: @"OverFlow"];
		}
		else {
			[theCell setFormatter: rateFormatter];
			[theCell setTextColor:[NSColor blackColor]];
			[theCell setFloatValue: [model hitRate:chan]];
		}
	}
	[rate0 setNeedsDisplay:YES];
	[totalHitRateField setFloatValue:[model hitRateTotal]];
	[totalRate setNeedsDisplay:YES];
}

- (void) totalRateChanged:(NSNotification*)aNote
{
	if(aNote==nil || [aNote object] == [model totalRate]){
		[timeRatePlot setNeedsDisplay:YES];
	}
}

- (void) selectedRegIndexChanged:(NSNotification*) aNote
{
	//	NSLog(@"This is v4FLT selectedRegIndexChanged\n" );
    //[registerPopUp selectItemAtIndex: [model selectedRegIndex]];
	[self updatePopUpButton:registerPopUp	 setting:[model selectedRegIndex]];
	
	[self enableRegControls];
}

- (void) writeValueChanged:(NSNotification*) aNote
{
    //DEBUG    
    NSLog(@"%@::%@ lowLevelRegInHexPU intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[lowLevelRegInHexPU intValue]);//TODO: DEBUG testing ...-tb-
    [regWriteValueTextField setIntValue: [model writeValue]];
    [regWriteValueTextField setNeedsDisplay: YES];
}

- (void) selectedChannelValueChanged:(NSNotification*) aNote
{
    [channelPopUp selectItemWithTag: [model selectedChannelValue]];
	//[self updatePopUpButton:channelPopUp	 setting:[model selectedRegIndex]];
	
	[self enableRegControls];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[self window] setContentView:blankView];
    switch([tabView indexOfTabViewItem:tabViewItem]){
        case  0: [self resizeWindowToSize:settingSize];     break;
		case  1: [self resizeWindowToSize:triggerSize];	    break;
		case  2: [self resizeWindowToSize:rateSize];	    break;
		case  3: [self resizeWindowToSize:BBAccessSize];	break;
		case  4: [self resizeWindowToSize:testSize];        break;
		case  5: [self resizeWindowToSize:lowlevelSize];	break;
		default: [self resizeWindowToSize:testSize];	    break;
    }
    [[self window] setContentView:totalView];
	
    NSString* key = [NSString stringWithFormat: @"orca.OREdelweissFLT%d.selectedtab",[model stationNumber]];
    int index = [tabView indexOfTabViewItem:tabViewItem];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:key];
    
}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Actions
- (IBAction) sendBB0x0ABloqueAction:(id)sender
{
    [self endEditing];
	//debug     NSLog(@"Called %@::%@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG -tb-
    int fiber = [model fiberSelectForBBAccess];
    int idBB=[model idBBforBBAccessForFiber:fiber];
    if([model useBroadcastIdforBBAccess]) idBB=0xff;
    [model sendWCommandIdBB:idBB  cmd:0x0A arg1:0  arg2:0x00];
}

- (IBAction) sendBB0x0ADebloqueAction:(id)sender
{
    [self endEditing];
	//debug     NSLog(@"Called %@::%@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG -tb-
    int fiber = [model fiberSelectForBBAccess];
    int idBB=[model idBBforBBAccessForFiber:fiber];
    if([model useBroadcastIdforBBAccess]) idBB=0xff;
    [model sendWCommandIdBB:idBB  cmd:0x0A arg1:0  arg2:0x06];
}

- (IBAction) sendBB0x0ADemarrageAction:(id)sender
{
    [self endEditing];
	//debug     NSLog(@"Called %@::%@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG -tb-
    int fiber = [model fiberSelectForBBAccess];
    int idBB=[model idBBforBBAccessForFiber:fiber];
    if([model useBroadcastIdforBBAccess]) idBB=0xff;
    [model sendWCommandIdBB:idBB  cmd:0x0A arg1:0  arg2:0x07];
}

- (IBAction) sendBB0x0ACmdAction:(id)sender //send 0x0A Command
{
    [self endEditing];
	//debug     NSLog(@"Called %@::%@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG -tb-
    int fiber = [model fiberSelectForBBAccess];
    int idBB=[model idBBforBBAccessForFiber:fiber];
    if([model useBroadcastIdforBBAccess]) idBB=0xff;
    [model sendWCommandIdBB:idBB  cmd:0x0A arg1:0  arg2:[model BB0x0ACmdMask]];
}




- (void) BB0x0ACmdMaskTextFieldAction:(id)sender
{
	[model setBB0x0ACmdMask:[sender intValue]];	//BB0x0ACmdMaskTextField
}

- (IBAction) BB0x0ACmdMaskMatrixAction:(id)sender
{
	//debug 
    NSLog(@"Called %@::%@\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG -tb-
	int i,val=0;
	for(i=0;i<8;i++){
        //NSLog(@"Called %@::%@   cell with tag %i, id:%p intVal:%i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),i,[sender cellWithTag:i],[[sender cellWithTag:i] intValue]);//TODO: DEBUG -tb-
        ////cellWithTag:i is not defined for all i, but it works anyway: it returns 0 and [0 intValue] is 0, so nothing is set in this case -tb-
        if([[BB0x0ACmdMaskMatrix cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setBB0x0ACmdMask:val];
}

- (IBAction) chargeBBFileCommandSendButtonAction:(id)sender;
{
	[model chargeBBWithFile: [model chargeBBFile]];	
}

- (void) chargeBBFileTextFieldAction:(id)sender
{
	[model setChargeBBFile:[sender stringValue]];	
}

- (void) ionToHeatDelayTextFieldAction:(id)sender
{
	[model setIonToHeatDelay:[sender intValue]];	
}
- (void) lowLevelRegInHexPUAction:(id)sender /*lowLevelRegInHexPU*/
{
    //DEBUG    
    NSLog(@"%@::%@ lowLevelRegInHexPU intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[lowLevelRegInHexPU intValue]);//TODO: DEBUG testing ...-tb-
	//[model setLowLevelRegInHex:[sender intValue]];	
	[model setLowLevelRegInHex:[sender indexOfSelectedItem]];	
}

- (void) writeToBBModeCBAction:(id)sender
{
	[model setWriteToBBMode:[sender intValue]];	
}

- (void) wCmdArg2TextFieldAction:(id)sender
{
	[model setWCmdArg2:[sender intValue]];	
}

- (void) wCmdArg1TextFieldAction:(id)sender
{
	[model setWCmdArg1:[sender intValue]];	
}

- (void) wCmdCodeTextFieldAction:(id)sender
{
	[model setWCmdCode:[sender intValue]];	
}

- (IBAction) sendWCommandButtonAction:(id)sender
{
    //DEBUG    NSLog(@"%@::%@ intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-
    [self endEditing];
    [model sendWCommand];
}

- (void) adcRtTextFieldAction:(id)sender
{
    //DEBUG 	    NSLog(@"%@::%@ intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-

    int fiber = [model fiberSelectForBBAccess];
	[model setAdcRtForFiber:fiber to:[sender intValue]];	
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRtForBBAccessForFiber:fiber];
}

- (void) adcRtStepperAction:(id)sender
{
    //DEBUG    NSLog(@"%@::%@ intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-

    int fiber = [model fiberSelectForBBAccess];
	[model setAdcRtForFiber:fiber to:[sender intValue]];	
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRtForBBAccessForFiber:fiber];
}


- (void) D2TextFieldAction:(id)sender
{
    //DEBUG 	    NSLog(@"%@::%@ intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-
    int fiber = [model fiberSelectForBBAccess];
	[model setD2ForFiber:fiber to:[sender intValue]];	
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeD2ForBBAccessForFiber:fiber];
}

- (void) D3TextFieldAction:(id)sender
{
    //DEBUG 	    NSLog(@"%@::%@ intVal %i\n", NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-
    int fiber = [model fiberSelectForBBAccess];
	[model setD3ForFiber:fiber to:[sender intValue]];	
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeD3ForBBAccessForFiber:fiber];
}





- (IBAction) readBBStatusBBAccessButtonAction:(id)sender
{
        //DEBUG OUTPUT:         NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
        //[model readBBStatusBits];
	[self endEditing];
	@try {
        [model readBBStatusForBBAccess];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}





- (IBAction) dumpBBStatusBBAccessTextFieldAction:(id)sender
{
    [self endEditing];
    [model dumpStatusBB16forFiber: [model fiberSelectForBBAccess]];
}







- (void) dacbMatrixAction:(id)sender
{
	//[model setDacb:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setDacbForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRgForBBAccessForFiber:fiber atIndex:index];
}

- (void) signbMatrixAction:(id)sender
{
	//[model setSignb:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setSignbForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRgForBBAccessForFiber:fiber atIndex:index];
}

- (void) dacaMatrixAction:(id)sender
{
	//[model setDaca:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setDacaForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRgForBBAccessForFiber:fiber atIndex:index];
}

- (void) signaMatrixAction:(id)sender
{
	//[model setSigna:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setSignaForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRgForBBAccessForFiber:fiber atIndex:index];
}

- (void) adcRgForBBAccessMatrixAction:(id)sender
{
	//[model setAdcRgForBBAccess:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setAdcRgForBBAccessForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcRgForBBAccessForFiber:fiber atIndex:index];
}

- (void) adcValueForBBAccessMatrixAction:(id)sender
{
	//[model setAdcValueForBBAccess:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setAdcValueForBBAccessForFiber: fiber atIndex:index to:[sender intValue]];
    
    //if "Write Changes to BB" is selected ...
    //adc value is read only!
    //if([model writeToBBMode]) [model writeAdcValueForBBAccessForFiber:fiber atIndex:index];
}

- (void) adcMultForBBAccessMatrixAction:(id)sender  //gain  (gain+freq=filter)
{
	//[model setAdcMultForBBAccess:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setAdcMultForBBAccessForFiber: fiber atIndex:index to:[sender intValue]];

    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]){
    //DEBUG    
    NSLog(@"%@::%@ call writeAdcFilterForBBAccessForFiber: fiber %i index %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),fiber,index);//TODO: DEBUG testing ...-tb-
        [model writeAdcFilterForBBAccessForFiber:fiber atIndex:index];
    }
}





- (void) adcFreqkHzForBBAccessMatrixAction:(id)sender //freq (gain+freq=filter)
{

//	[model setAdcFreqkHzForBBAccess:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: tag %i,   intVal %i , fib %i, idx %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),
            //[[sender selectedCell] tag],[sender intValue],fiber,index);//TODO : DEBUG testing ...-tb-
	//if([sender intValue] != [model adcFreqkHzForBBAccessForFiber:fiber atIndex:index]){
		//[[self undoManager] setActionName: @"Set Threshold"];
		[model setAdcFreqkHzForBBAccessForFiber: fiber atIndex:[[sender selectedCell] tag] to:[sender intValue]];
	//}
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeAdcFilterForBBAccessForFiber:fiber atIndex:index];

}


- (void) polarDacMatrixAction:(id)sender
{

//	[model setAdcFreqkHzForBBAccess:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: tag %i,   intVal %i , fib %i, idx %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),
            //[[sender selectedCell] tag],[sender intValue],fiber,index);//TODO : DEBUG testing ...-tb-
	//if([sender intValue] != [model adcFreqkHzForBBAccessForFiber:fiber atIndex:index]){
		//[[self undoManager] setActionName: @"Set Threshold"];
		[model setPolarDacForFiber: fiber atIndex:[[sender selectedCell] tag] to:[sender intValue]];
	//}
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writePolarDacForFiber:fiber atIndex:index];

}

- (void) triDacMatrixAction:(id)sender
{
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setTriDacForFiber: fiber atIndex:[[sender selectedCell] tag] to:[sender intValue]];

    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeTriDacForFiber:fiber atIndex:index];
}

- (void) rectDacMatrixAction:(id)sender
{
    int fiber = [model fiberSelectForBBAccess];
    int index = [[sender selectedCell] tag];
    [model setRectDacForFiber: fiber atIndex:[[sender selectedCell] tag] to:[sender intValue]];

    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRectDacForFiber:fiber atIndex:index];
}





- (void) useBroadcastIdforBBAccessCBAction:(id)sender
{
	[model setUseBroadcastIdforBBAccess:[sender intValue]];	
}

- (void) idBBforBBAccessTextFieldAction:(id)sender
{

    //DEBUG 	
    NSLog(@"%@::%@ - sender intVal: %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender intValue]);//TODO: DEBUG testing ...-tb-
    int fiber = [model fiberSelectForBBAccess];
	[model setIdBBforBBAccessForFiber:fiber to:[sender intValue]];	
}

- (void) fiberSelectForBBAccessPUAction:(id)sender
{
    [self endEditing];
	//[model setFiberSelectForBBAccess:[sender intValue]];	
    //DEBUG 	
    NSLog(@"%@::%@ - selItemIndex: %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender indexOfSelectedItem]);//TODO: DEBUG testing ...-tb-
	[model setFiberSelectForBBAccess:[sender indexOfSelectedItem]];	
}

- (void) relaisStatesBBMatrixAction:(id)sender
{
//	[model setRelaisStatesBB:[sender intValue]];	
    int fiber = [model fiberSelectForBBAccess];
	int i, val=0;
	for(i=0;i<3;i++){
		if([[sender cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setRelaisStatesBBForFiber:fiber to:val];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}



- (IBAction) refBBCheckBoxAction:(id)sender
{
    int fiber = [model fiberSelectForBBAccess];
	int val=0;
	if([sender intValue]) val  =  0x1 ;
	[model setRefForBBAccessForFiber:fiber to:val];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}

- (IBAction) adcOnOffBBMatrixAction:(id)sender;
{
    int fiber = [model fiberSelectForBBAccess];
	int i, val=0;
	for(i=0;i<[adcOnOffBBMatrix numberOfColumns];i++){
		if([[sender cellAtRow:0 column:i] intValue]) val |= (0x1<<i);
	}
	[model setAdcOnOffForBBAccessForFiber:fiber to:val];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}

- (IBAction) relais1PUAction:(id)sender
{
    //DEBUG 	
    NSLog(@"%@::%@ - selItemIndex: %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender indexOfSelectedItem]);//TODO: DEBUG testing ...-tb-

    int fiber = [model fiberSelectForBBAccess];
	[model setRelais1ForBBAccessForFiber:fiber to:[sender indexOfSelectedItem]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}

- (IBAction) relais2PUAction:(id)sender
{
    //DEBUG 	
    NSLog(@"%@::%@ - selItemIndex: %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender indexOfSelectedItem]);//TODO: DEBUG testing ...-tb-

    int fiber = [model fiberSelectForBBAccess];
	[model setRelais2ForBBAccessForFiber:fiber to:[sender indexOfSelectedItem]];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}


- (IBAction) mezOnOffBBMatrixAction:(id)sender;
{
    int fiber = [model fiberSelectForBBAccess];
	int i, val=0;
	for(i=0;i<2;i++){
		if([[sender cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setMezForBBAccessForFiber:fiber to:val];
    
    //if "Write Changes to BB" is selected ...
    if([model writeToBBMode]) [model writeRelaisStatesForBBAccessForFiber:fiber];
}

- (void) fiberSelectForBBStatusBitsPUAction:(id)sender
{
	[model setFiberSelectForBBStatusBits:[fiberSelectForBBStatusBitsPU indexOfSelectedItem]];	
}


- (IBAction) readBBStatusBitsButtonAction:(id)sender
{
        //DEBUG OUTPUT:         NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
        //[model readBBStatusBits];
	[self endEditing];
	@try {
        [model readBBStatusBits];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readAllBBStatusBitsButtonAction:(id)sender
{
        //DEBUG OUTPUT:  
        NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
        [model readAllBBStatusBits];
}


- (void) fiberOutMaskMatrixAction:(id)sender
{
	//[model setFiberOutMask:[sender intValue]];	
	int i, val=0;
	for(i=0;i<6;i++){
		if([[sender cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setFiberOutMask:val];
    //NSLog(@"%@::%@: UNDER CONSTRUCTION! set 0x%x\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),val);//TODO : DEBUG testing ...-tb-
}


- (IBAction) readFiberOutMaskButtonAction:(id)sender
{
        //DEBUG OUTPUT:         NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
	[self endEditing];
	@try {
        [model readFiberOutMask];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) writeFiberOutMaskButtonAction:(id)sender
{
        //DEBUG OUTPUT: 	        NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
	[self endEditing];
	@try {
        [model writeFiberOutMask];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}


- (void) repeatSWTriggerModePUAction:(id)sender
{
	[model setRepeatSWTriggerMode:[repeatSWTriggerModePU indexOfSelectedItem]];	
}

- (void) repeatSWTriggerModeTextFieldAction:(id)sender
{
	[model setRepeatSWTriggerMode:[sender intValue]];	
}

- (void) controlRegisterTextFieldAction:(id)sender
{
	[model setControlRegister:[sender intValue]];	
}

- (IBAction) writeControlRegisterButtonAction:(id)sender
{
    //DEBUG
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-

	[self endEditing];
	@try {
    	[model writeControl];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readControlRegisterButtonAction:(id)sender
{
    //DEBUG
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-


	unsigned long controlReg = 0; //TODO: use try ... catch ... ? -tb-
	[self endEditing];
	@try {
	    controlReg = [model  readControl]; //TODO: use try ... catch ... ? -tb-
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
        return;
	}


	[model  setControlRegister: controlReg];

}


- (IBAction) statusLatencyPUAction:(id)sender
{
    //DEBUG
 	NSLog(@"%@::%@ [sender indexOfSelectedItem] %i\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender indexOfSelectedItem]);//TODO: DEBUG testing ...-tb-
	[model setStatusLatency:[sender indexOfSelectedItem]];	
}

- (IBAction) vetoFlagCBAction:(id)sender
{
    //DEBUG
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	[model setVetoFlag:[sender intValue]];	
}


- (void) totalTriggerNRegisterTextFieldAction:(id)sender
{
	[model setTotalTriggerNRegister:[sender intValue]];	
}

- (void) readStatusButtonAction:(id)sender
{
    //DEBUG
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-

	@try {
	    [model readStatus];	
	    [model readTotalTriggerNRegister];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (void) statusRegisterTextFieldAction:(id)sender
{
	[model setStatusRegister:[sender intValue]];	
}

- (void) fastWriteCBAction:(id)sender
{
	[model setFastWrite:[sender intValue]];	
}

- (void) writeFiberDelaysButtonAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
		
	[self endEditing];
	@try {
	    [model writeFiberDelays];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (void) readFiberDelaysButtonAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model readFiberDelays];	
    
	[self endEditing];
	@try {
	    [model readFiberDelays];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}

}

- (void) fiberDelaysTextFieldAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@: there is something wrong! Please contact a ORCA expert!\n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model setFiberDelays:[sender intValue]];	
}

- (IBAction) fiberDelaysMatrixAction:(id)sender
{
//DEBUG OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION!  \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model setStreamMask:[sender intValue]];	
	uint64_t fib;
    uint64_t val=0;
	int clk12,clk120;
	uint64_t fibDelays;
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %llu",fib];
		    clk12  = [[fiberDelaysMatrix cellAtRow:0 column: fib] indexOfSelectedItem];
		    clk120 = [[fiberDelaysMatrix cellAtRow:1 column: fib] indexOfSelectedItem];
			//debug s=[s stringByAppendingString: [NSString stringWithFormat:@"clk12 %i:",clk12]];
			//debug s=[s stringByAppendingString: [NSString stringWithFormat:@"clk120 %i:",clk120]];
			fibDelays = ((clk120 & 0xf) << 4)  |   (clk12 & 0xf);
			val |= ((fibDelays) << (fib*8));// see - (int) streamMaskForFiber:(int)aFiber chan:(int)aChan;
			//debug NSLog(@"%@\n",s);
	}
			//debug NSLog(@"%016qx done.\n",val);
	[model setFiberDelays:val];
}

- (IBAction) streamMaskEnableAllAction:(id)sender
{	[model setStreamMask:0x00003f3f3f3f3f3fLL];	 }

- (IBAction) streamMaskEnableNoneAction:(id)sender
{	[model setStreamMask:0x0];	 }


- (void) streamMaskTextFieldAction:(id)sender
{
	//[model setStreamMask:[sender intValue]];	
}

- (void) streamMaskMatrixAction:(id)sender
{
//DEBUG OUTPUT:  	NSLog(@"%@::%@: UNDER CONSTRUCTION!  \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model setStreamMask:[sender intValue]];	
	uint64_t chan, fib;
    uint64_t val=0;
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %lli:",fib];
	    for(chan=0;chan<6;chan++){
		    if([[streamMaskMatrix cellAtRow:fib column: chan] intValue]){ 
			    val |= ((0x1LL<<chan) << (fib*8));// see - (int) streamMaskForFiber:(int)aFiber chan:(int)aChan;
				//debug s=[s stringByAppendingString: @"1"];
			}else{
				//debug s=[s stringByAppendingString: @"0"];
			}
		}
		//debug NSLog(@"%@\n",s);
	}
	//debug NSLog(@"%016qx done.\n",val);
	[model setStreamMask:val];
}


- (IBAction) writeStreamMaskRegisterButtonAction:(id)sender
{
	//[model writeStreamMask];	
    
	[self endEditing];
	@try {
	    [model writeStreamMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readStreamMaskRegisterButtonAction:(id)sender
{
	//[model readStreamMask];	
    
	[self endEditing];
	@try {
	    [model readStreamMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}


- (IBAction) heatTriggerMaskEnableAllAction:(id)sender
{	[model setHeatTriggerMask:0x00003f3f3f3f3f3fLL];	 }

- (IBAction) heatTriggerMaskEnableNoneAction:(id)sender
{	[model setHeatTriggerMask:0x0];	 }


- (IBAction) heatTriggerMaskTextFieldAction:(id)sender
{
	//[model setHeatTriggerMask:[sender intValue]];	
}

- (IBAction) heatTriggerMaskMatrixAction:(id)sender
{
	//[model setHeatTriggerMask:[sender intValue]];	
	uint64_t chan, fib;
    uint64_t val=0;
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %lli:",fib];
	    for(chan=0;chan<6;chan++){
		    if([[heatTriggerMaskMatrix cellAtRow:fib column: chan] intValue]){ 
			    val |= ((0x1LL<<chan) << (fib*8));// see - (int) streamMaskForFiber:(int)aFiber chan:(int)aChan;
				//debug s=[s stringByAppendingString: @"1"];
			}else{
				//debug s=[s stringByAppendingString: @"0"];
			}
		}
		//debug NSLog(@"%@\n",s);
	}
	//debug NSLog(@"%016qx done.\n",val);
	[model setHeatTriggerMask:val];
}


- (IBAction) writeHeatTriggerMaskRegisterButtonAction:(id)sender
{
	[self endEditing];
	@try {
	    [model writeHeatTriggerMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readHeatTriggerMaskRegisterButtonAction:(id)sender
{
	[self endEditing];
	@try {
	    [model readHeatTriggerMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}



- (IBAction) ionTriggerMaskEnableAllAction:(id)sender;
{	[model setIonTriggerMask:0x00003f3f3f3f3f3fLL];	 }

- (IBAction) ionTriggerMaskEnableNoneAction:(id)sender;
{	[model setIonTriggerMask:0x0];	 }


- (void) ionTriggerMaskTextFieldAction:(id)sender
{
	//[model setIonTriggerMask:[sender intValue]];	
}

- (IBAction) ionTriggerMaskMatrixAction:(id)sender
{
	uint64_t chan, fib;
    uint64_t val=0;
	for(fib=0;fib<6;fib++){
		//debug NSString *s = [NSString stringWithFormat:@"fib %lli:",fib];
	    for(chan=0;chan<6;chan++){
		    if([[ionTriggerMaskMatrix cellAtRow:fib column: chan] intValue]){ 
			    val |= ((0x1LL<<chan) << (fib*8));// see - (int) streamMaskForFiber:(int)aFiber chan:(int)aChan;
				//debug s=[s stringByAppendingString: @"1"];
			}else{
				//debug s=[s stringByAppendingString: @"0"];
			}
		}
		//debug NSLog(@"%@\n",s);
	}
	//debug NSLog(@"%016qx done.\n",val);
	[model setIonTriggerMask:val];
}


- (IBAction) writeIonTriggerMaskRegisterButtonAction:(id)sender
{
	[self endEditing];
	@try {
	    [model writeIonTriggerMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readIonTriggerMaskRegisterButtonAction:(id)sender
{
	[self endEditing];
	@try {
	    [model readIonTriggerMask];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nAccess to FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readTriggerParametersButtonAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
    [model readTriggerParameters];
}

- (IBAction) writeTriggerParametersButtonAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
    [model writeTriggerParameters];
}

- (IBAction) dumpTriggerParametersButtonAction:(id)sender
{
//DEBUG OUTPUT: 	NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
    [model dumpTriggerParameters];
}


- (IBAction) readPostTriggerTimeAndIonToHeatDelayButtonAction:(id)sender{[model readPostTriggerTimeAndIonToHeatDelay];}
- (IBAction) writePostTriggerTimeAndIonToHeatDelayButtonAction:(id)sender{[model writePostTriggerTimeAndIonToHeatDelay];}



- (IBAction) triggerEnabledMatrixAction:(id)sender
{

//using triggerEnableAction!!!

//DEBUG OUTPUT:
 	NSLog(@"%@::%@: UNDER CONSTRUCTION!   \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
}

- (IBAction) negPosPolarityMatrixAction:(id)sender
{
    //negPosPolarityMatrix
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION! negPosPolarityMatrix: col is %i, row is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[negPosPolarityMatrix selectedColumn],[negPosPolarityMatrix selectedRow]);//TODO : DEBUG testing ...-tb-
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION! negPosPolarityMatrix: selectedCell %@ , state %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[negPosPolarityMatrix selectedCell],[[negPosPolarityMatrix selectedCell] intValue]);//TODO : DEBUG testing ...-tb-
    unsigned int col, row, state;
    col=[negPosPolarityMatrix selectedColumn];
    row=[negPosPolarityMatrix selectedRow];
    state = [[negPosPolarityMatrix selectedCell] intValue];
    if(row>=kNumEWFLTHeatIonChannels) return;
    if(col==0) [model setNegPolarity:row withValue:state];
    else       [model setPosPolarity:row withValue:state];
}

- (IBAction) gapMatrixAction:(id)sender
{
    //gapMatrix
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION! sender: %@, col is %i, row is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),sender,[sender selectedColumn],[sender selectedRow]);//TODO : DEBUG testing ...-tb-
    unsigned int col, row, state;
    col=[gapMatrix selectedColumn];
    row=[gapMatrix selectedRow];
    //state = [[gapMatrix selectedCell] intValue];
    state = [[gapMatrix selectedCell] indexOfSelectedItem];
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION!  selectedCell %@ , state %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[gapMatrix selectedCell],state);//TODO : DEBUG testing ...-tb-
    if(row>=kNumEWFLTHeatIonChannels) return;
    [model setGapLength:row withValue:state];
}

- (IBAction) downSamplingMatrixAction:(id)sender
{
    //downSamplingMatrix
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION!  col is %i, row is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[downSamplingMatrix selectedColumn],[downSamplingMatrix selectedRow]);//TODO : DEBUG testing ...-tb-
    unsigned int col, row, state;
    col=[downSamplingMatrix selectedColumn];
    row=[downSamplingMatrix selectedRow];
    //state = [[gapMatrix selectedCell] intValue];
    state = [[downSamplingMatrix selectedCell] indexOfSelectedItem];
    //DEBUG: OUTPUT:  	    NSLog(@"%@::%@: UNDER CONSTRUCTION!  selectedCell %@ , state %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender selectedCell],state);//TODO : DEBUG testing ...-tb-
    if(row>=kNumEWFLTHeatIonChannels) return;
    [model setDownSampling:row withValue:state];
}


- (IBAction) shapingLengthMatrixAction:(id)sender
{
    //downSamplingMatrix
    //DEBUG: OUTPUT:  	       NSLog(@"%@::%@: UNDER CONSTRUCTION!  col is %i, row is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[shapingLengthMatrix selectedColumn],[shapingLengthMatrix selectedRow]);//TODO : DEBUG testing ...-tb-
    unsigned int col, row, state;
    col=[shapingLengthMatrix selectedColumn];
    row=[shapingLengthMatrix selectedRow];
    //state = [[gapMatrix selectedCell] intValue];
    state = [[shapingLengthMatrix selectedCell] intValue];
    //DEBUG: OUTPUT:  	        NSLog(@"%@::%@: UNDER CONSTRUCTION!  selectedCell %@ , state %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender selectedCell],state);//TODO : DEBUG testing ...-tb-
    if(row>=kNumEWFLTHeatIonChannels) return;
    [model setShapingLength:row withValue:state];
}


- (void) selectFiberTrigPUAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@: UNDER CONSTRUCTION! %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender indexOfSelectedItem]);//TODO: DEBUG testing ...-tb-
	//[model setSelectFiberTrig:[sender intValue]];	
	[model setSelectFiberTrig:[sender indexOfSelectedItem]];	
}

- (void) BBv1MaskMatrixAction:(id)sender
{
	//[model setBBv1Mask:[sender intValue]];	
	int i, val=0;
	for(i=0;i<6;i++){
		if([[sender cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setBBv1Mask:val];
}

- (void) fiberEnableMaskMatrixAction:(id)sender
{
	//[model setFiberEnableMask:[sender intValue]];	
	int i, val=0;
	for(i=0;i<6;i++){
		if([[sender cellWithTag:i] intValue]) val |= (0x1<<i);
	}
	[model setFiberEnableMask:val];
}

- (void) fltModeFlagsPUAction:(id)sender
{
    int flags=4;
	switch([sender indexOfSelectedItem]){
	    case 0: flags=0x0; break;
	    case 1: flags=0x1; break;
	    case 2: flags=0x2; break;
	    case 3: flags=0x3; break;
	    default: flags=0; break;
	}
	//[model setFltModeFlags:[sender intValue]];	
	[model setFltModeFlags: flags];	
}

- (void) tpixCBAction:(id)sender
{
	//[model setTpix:[sender intValue]];	
	[model setTpix:[tpixCB intValue]];	
}





- (IBAction) writeCommandResyncAction:(id)sender
{
    //DEBUG OUTPUT:
 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model writeCommandResync];	
    
	@try {
	    [model writeCommandResync];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nWrite of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) writeCommandTrigEvCounterResetAction:(id)sender
{
    //DEBUG OUTPUT: 	NSLog(@"%@::%@ \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-
	//[model writeCommandTrigEvCounterReset];	
    
	@try {
	    [model writeCommandTrigEvCounterReset];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nWrite of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) writeSWTriggerAction:(id)sender
{
	@try {
	    [model writeCommandSoftwareTrigger];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nWrite of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readTriggerDataAction:(id)sender
{
//DEBUG OUTPUT:
 	NSLog(@"%@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-

	[self endEditing];
	@try {
	    [model readTriggerData];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception '%@'-'%@' in %@::%@ ; FLT (%d) \n",[localException name],[localException reason],NSStringFromClass([self class]),NSStringFromSelector(_cmd),[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nRead of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}



//TODO: 'old' KATRIN functions, remove it -tb-
- (void) targetRateAction:(id)sender
{
	[model setTargetRate:[sender intValue]];	
}

- (IBAction) openNoiseFloorPanel:(id)sender
{
	[self endEditing];
    [NSApp beginSheet:noiseFloorPanel modalForWindow:[self window]
		modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) closeNoiseFloorPanel:(id)sender
{
    [noiseFloorPanel orderOut:nil];
    [NSApp endSheet:noiseFloorPanel];
}

- (IBAction) findNoiseFloors:(id)sender
{
	[noiseFloorPanel endEditingFor:nil];		
    @try {
        NSLog(@"IPE V4 FLT (StationNumber %d) Finding Thresholds \n",[model stationNumber]);
		[model findNoiseFloors];
    }
	@catch(NSException* localException) {
        NSLog(@"Threshold Finder for IPE V4 FLT Board FAILED.\n");
        NSRunAlertPanel([localException name], @"%@\nFailed Threshold finder", @"OK", nil, nil,
                        localException);
    }
}
- (IBAction) noiseFloorOffsetAction:(id)sender
{
    if([sender intValue] != [model noiseFloorOffset]){
        [model setNoiseFloorOffset:[sender intValue]];
    }
}


- (IBAction) storeDataInRamAction:(id)sender
{
	[model setStoreDataInRam:[sender intValue]];	
}

- (IBAction) filterLengthAction:(id)sender
{
	[model setFilterLength:[sender indexOfSelectedItem]+2];	 //tranlate back to range of 2 to 8
}

- (IBAction) gapLengthAction:(id)sender
{
    //DEBUG: OUTPUT:  	
    NSLog(@"%@::%@: DEPRECATED \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO : DEBUG testing ...-tb-
	//[model setGapLength:[sender indexOfSelectedItem]];	
}



- (IBAction) postTriggerTimeAction:(id)sender
{
	@try {
		[model setPostTriggerTime:[sender intValue]];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT post trigger time\n");
		NSRunAlertPanel([localException name], @"%@\nSet post trigger time of FLT%d failed", @"OK", nil, nil,
						localException,[model stationNumber]);
	}
}

- (IBAction) fifoBehaviourAction:(id)sender
{
	@try {
		[model setFifoBehaviour:[[sender selectedCell]tag]];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception setting FLT behavior\n");
		NSRunAlertPanel([localException name], @"%@\nSetting Behaviour of FLT%d failed", @"OK", nil, nil,
						localException,[model stationNumber]);
	}
}

- (IBAction) analogOffsetAction:(id)sender
{
	@try {
		[model setAnalogOffset:[sender intValue]];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception setting FLT analog offset\n");
		NSRunAlertPanel([localException name], @"%@\nSet analog offset FLT%d failed", @"OK", nil, nil,
						localException,[model stationNumber]);
	}
}

- (IBAction) interruptMaskAction:(id)sender
{
	@try {
		[model setInterruptMask:[sender intValue]];	
	}
	@catch(NSException* localException) {
		NSLog(@"Exception setting FLT interrupt mask\n");
		NSRunAlertPanel([localException name], @"%@\nSet of interrupt mask of FLT%d failed", @"OK", nil, nil,
						localException,[model stationNumber]);
	}
}

- (IBAction) testEnabledAction:(id)sender
{
	NSMutableArray* anArray = [NSMutableArray array];
	int i;
	for(i=0;i<kNumEdelweissFLTTests;i++){
		if([[testEnabledMatrix cellWithTag:i] intValue])[anArray addObject:[NSNumber numberWithBool:YES]];
		else [anArray addObject:[NSNumber numberWithBool:NO]];
	}
	[model setTestEnabledArray:anArray];
}

- (IBAction) setDefaultsAction: (id) sender
{
	@try {
		[model setToDefaults];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception setting FLT default Values\n");
		NSRunAlertPanel([localException name], @"%@\nSet Defaults for FLT%d failed", @"OK", nil, nil,
						localException,[model stationNumber]);
	}
}

- (IBAction) readThresholdsGains:(id)sender
{



//TODO: readThresholdsGains    under construction -tb-
	@try {
		int i;
		NSFont* aFont = [NSFont userFixedPitchFontOfSize:10];
		NSLogFont(aFont,   @"FLT (station %d)\n",[model stationNumber]); // ak, 5.10.07
		NSLogFont(aFont,   @"chan | Gain | Threshold\n");
		NSLogFont(aFont,   @"-----------------------\n");
		for(i=0;i<kNumEWFLTHeatIonChannels;i++){
			//NSLogFont(aFont,@"%4d | %4d | %4d \n",i,[model readGain:i],[model readThreshold:i]);
			//NSLog(@"%d: %d\n",i,[model readGain:i]);
		}
		NSLogFont(aFont,   @"-----------------------\n");
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT gains and thresholds\n");
        NSRunAlertPanel([localException name], @"%@\nRead of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) writeThresholdsGains:(id)sender
{
	[self endEditing];
	@try {
		[model loadThresholdsAndGains];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception writing FLT gains and thresholds\n");
        NSRunAlertPanel([localException name], @"%@\nWrite of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) gainAction:(id)sender
{
	if([sender intValue] != [model gain:[[sender selectedCell] tag]]){
		[[self undoManager] setActionName: @"Set Gain"];
		[model setGain:[[sender selectedCell] tag] withValue:[sender intValue]];
	}
}

- (IBAction) thresholdAction:(id)sender
{
//	if([sender intValue] != [(OREdelweissFLTModel*)model threshold:[[sender selectedCell] tag]]){
//		[[self undoManager] setActionName: @"Set Threshold"];
//		[model setThreshold:[[sender selectedCell] tag] withValue:[sender intValue]];
//	}
    unsigned int col, row, state;
    col=[sender selectedColumn];
    row=[sender selectedRow];
    state = [[sender selectedCell] intValue];
    //DEBUG: OUTPUT:  
    	       NSLog(@"%@::%@: UNDER CONSTRUCTION!    selectedCell %@ , state %i ,col is %i, row is %i \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[sender selectedCell],state,col,row);//TODO : DEBUG testing ...-tb-
    if(row>=kNumEWFLTHeatIonChannels) return;
    [model setThreshold:row withValue:state];

}

- (IBAction) readThresholdsButtonAction:(id)sender{ [model readThresholds]; }
- (IBAction) writeThresholdsButtonAction:(id)sender{ [model writeThresholds]; }


- (IBAction) triggerEnableAction:(id)sender
{
	[[self undoManager] setActionName: @"Set TriggerEnabled"];
	[model setTriggerEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}


- (IBAction) reportButtonAction:(id)sender
{
	[self endEditing];
	@try {
		[model printVersions];
		[model printStatusReg];
		//[model printPixelRegs];
		[model printValueTable];
		//[model printStatistics];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT (%d) status\n",[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nRead of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) initBoardButtonAction:(id)sender
{
	[self endEditing];
	@try {
		[model initBoard];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception initBoard FLT (%d) status\n",[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nWrite of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) readAllButtonAction:(id)sender
{
	[self endEditing];
	@try {
		[model readAll];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception readAll FLT (%d) status\n",[model stationNumber]);
        NSRunAlertPanel([localException name], @"%@\nReading of FLT%d configuration failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) settingLockAction:(id) sender
{
    [gSecurity tryToSetLock:OREdelweissFLTSettingsLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) modeAction: (id) sender
{
	[model setRunMode:[modeButton indexOfSelectedItem]];
}

- (IBAction) versionAction: (id) sender
{
	@try {
		[model printVersions];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT HW Model Version\n");
        NSRunAlertPanel([localException name], @"%@\nRead of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) testAction: (id) sender
{
	NSLog(@"HW tests are currently not available!\n");//TODO: test mode does not exist any more ... -tb- 7/2010
	return;
	@try {
		[model runTests];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT HW Model Test\n");
        NSRunAlertPanel([localException name], @"%@\nFLT%d Access failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}


- (IBAction) resetAction: (id) sender
{
	@try {
		[model reset];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception during FLT reset\n");
        NSRunAlertPanel([localException name], @"%@\nFLT%d Access failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) hitRateEnableMatrixAction: (id) sender
{
	[model setHitRateEnabled:[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (IBAction) hitRateLengthAction: (id) sender
{
	if([sender indexOfSelectedItem] != [model hitRateLength]){
		[[self undoManager] setActionName: @"Set Hit Rate Length"]; 
		[model setHitRateLength:[[sender selectedItem] tag]];
	}
}

- (IBAction) hitRateAllAction: (id) sender
{
	[model enableAllHitRates:YES];
}

- (IBAction) hitRateNoneAction: (id) sender
{
	[model enableAllHitRates:NO];
}

- (IBAction) enableAllTriggersAction: (id) sender
{
	[model enableAllTriggers:YES];
}

- (IBAction) enableNoTriggersAction: (id) sender
{
	[model enableAllTriggers:NO];
}

- (IBAction) statusAction:(id)sender
{
	@try {
		[model printStatusReg];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception during FLT read status\n");
        NSRunAlertPanel([localException name], @"%@\nRead of FLT%d failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) selectRegisterAction:(id) aSender
{
    if ([aSender indexOfSelectedItem] != [model selectedRegIndex]){
	    [[model undoManager] setActionName:@"Select Register"]; // Set undo name
	    [model setSelectedRegIndex:[aSender indexOfSelectedItem]]; // set new value
    }
}

- (IBAction) selectChannelAction:(id) aSender
{
    if ([[aSender selectedItem] tag] != [model selectedChannelValue]){
	    [[model undoManager] setActionName:@"Select Channel Number"]; // Set undo name do it at model side -tb-
	    [model setSelectedChannelValue:[[aSender selectedItem] tag]]; // set new value
    }
}

- (IBAction) writeValueAction:(id) aSender
{
	[self endEditing];
	[model setWriteValue:[aSender intValue]]; // Set new value
    #if 0
    if ([aSender intValue] != [model writeValue]){
		[[model undoManager] setActionName:@"Set Write Value"]; // Set undo name.
		[model setWriteValue:[aSender intValue]]; // Set new value
    }
    #endif
}

- (IBAction) readRegAction: (id) sender
{
	int index = [model selectedRegIndex]; 
	@try {
		unsigned long value;
        if(([model getAccessType:index] & kIpeRegNeedsChannel)){
            int chan = [model selectedChannelValue];
		    value = [model readReg:index channel: chan ];
		    NSLog(@"FLTv4 reg: %@ for channel %i has value: 0x%x (%i)\n",[model getRegisterName:index], chan, value, value);
        }
		else {
		    value = [model readReg:index ];
		    NSLog(@"FLTv4 reg: %@ has value: 0x%x (%i)\n",[model getRegisterName:index],value, value);
        }
	}
	@catch(NSException* localException) {
		NSLog(@"Exception reading FLT reg: %@\n",[model getRegisterName:index]);
        NSRunAlertPanel([localException name], @"%@\nSLT%d Access failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) writeRegAction: (id) sender
{
	[self endEditing];
	int index = [registerPopUp indexOfSelectedItem];
	@try {
		unsigned long val = [model writeValue];
        if(([model getAccessType:index] & kIpeRegNeedsChannel)){
            int chan = [model selectedChannelValue];
     		[model writeReg:index  channel: chan value: val];//TODO: allow hex values, e.g. 0x23 -tb-
    		NSLog(@"wrote 0x%x (%i) to FLTv4 reg: %@ channel %i\n", val, val, [model getRegisterName:index], chan);
        }
		else{
    		[model writeReg:index value: val];//TODO: allow hex values, e.g. 0x23 -tb-
    		NSLog(@"wrote 0x%x (%i) to FLTv4 reg: %@ \n",val,val,[model getRegisterName:index]);
        }
	}
	@catch(NSException* localException) {
		NSLog(@"Exception writing FLTv4 reg: %@\n",[model getRegisterName:index]);
        NSRunAlertPanel([localException name], @"%@\nFLTv4%d Access failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}

- (IBAction) testButtonAction: (id) sender //temp routine to hook up to any on a temp basis
{
//DEBUG OUTPUT:
 	NSLog(@"WARNING: %@::%@: UNDER CONSTRUCTION! \n",NSStringFromClass([self class]),NSStringFromSelector(_cmd));//TODO: DEBUG testing ...-tb-

	@try {
		//[model testReadHisto];
	}
	@catch(NSException* localException) {
		NSLog(@"Exception running FLT test code\n");
        NSRunAlertPanel([localException name], @"%@\nFLT%d Access failed", @"OK", nil, nil,
                        localException,[model stationNumber]);
	}
}




//OrcaObjectController methods
- (IBAction) incDialog:(id)sender
{
    [self endEditing];
    [super incDialog:sender];
}

- (IBAction) decDialog:(id)sender
{
    [self endEditing];
    [super decDialog:sender];
}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Plot DataSource
- (int) numberPointsInPlot:(id)aPlotter
{
	return [[model  totalRate]count];
}

- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue
{
	int count = [[model totalRate]count];
	int index = count-i-1;
	*yValue =  [[model totalRate] valueAtIndex:index];
	*xValue =  [[model totalRate] timeSampledAtIndex:index];
}

@end



