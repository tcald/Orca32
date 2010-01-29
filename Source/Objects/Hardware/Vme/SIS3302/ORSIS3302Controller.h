//-------------------------------------------------------------------------
//  ORSIS3302Controller.h
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

//-------------------------------------------------------------------------

#pragma mark ***Imported Files
#import "OrcaObjectController.h"
#import "ORSIS3302Model.h"
@class ORValueBar;
@class ORPlotter1D;

@interface ORSIS3302Controller : OrcaObjectController 
{
    IBOutlet NSTabView* 	tabView;
	IBOutlet   NSTextField* energyGateLengthField;
	IBOutlet NSPopUpButton* runModePU;
	IBOutlet NSTextField*	endAddressThresholdField;
	IBOutlet NSTextField*	energySampleStartIndex3Field;
	IBOutlet NSTextField*	energyTauFactorField;
	IBOutlet NSTextField*	energySampleStartIndex2Field;
	IBOutlet NSTextField*	energySampleStartIndex1Field;
	IBOutlet NSTextField*	energySampleLengthField;
	IBOutlet NSTextField*	energyGapTimeField;
	IBOutlet NSTextField*	energyPeakingTimeField;
	IBOutlet NSTextField*	triggerGateLengthField;
	IBOutlet NSTextField*	preTriggerDelayField;
	IBOutlet NSTextField*	sampleStartIndexField;
	IBOutlet NSTextField*	sampleLengthField;
	IBOutlet NSPopUpButton* lemoInModePU;
	IBOutlet NSTextField*	lemoInAssignmentsField;
	IBOutlet NSPopUpButton* lemoOutModePU;
	IBOutlet NSTextField*	lemoOutAssignmentsField;
	IBOutlet NSMatrix*		acqRegEnableMaskMatrix;
	
	//base address
    IBOutlet NSTextField*   slotField;
    IBOutlet NSTextField*   addressText;
	
	//CSR
	IBOutlet NSMatrix*		csrMatrix;
	

	IBOutlet NSButton*		writeThresholdButton;
	IBOutlet NSButton*		readThresholdButton;
	IBOutlet NSPopUpButton* clockSourcePU;

	IBOutlet NSMatrix*		enabledMatrix;
	IBOutlet NSMatrix*		gtMatrix;
	IBOutlet NSMatrix*		dacOffsetMatrix;
	IBOutlet NSMatrix*		thresholdMatrix;
	IBOutlet NSMatrix*		gateLengthMatrix;
	IBOutlet NSMatrix*		pulseLengthMatrix;
	IBOutlet NSMatrix*		sumGMatrix;
	IBOutlet NSMatrix*		peakingTimeMatrix;
	IBOutlet NSMatrix*		internalTriggerDelayMatrix;
    IBOutlet NSButton*      settingLockButton;
    IBOutlet NSButton*      initButton;
    IBOutlet NSButton*      statusButton;
	IBOutlet NSButton*		checkEventButton;
	
	IBOutlet NSPopUpButton*	triggerDecimationPU;
	IBOutlet NSPopUpButton*	energyDecimationPU;

    //rate page
    IBOutlet NSMatrix*      rateTextFields;
    IBOutlet NSStepper*     integrationStepper;
    IBOutlet NSTextField*   integrationText;
    IBOutlet NSTextField*   totalRateText;
    IBOutlet NSMatrix*      enabled2Matrix;

    IBOutlet ORValueBar*    rate0;
    IBOutlet ORValueBar*    totalRate;
    IBOutlet NSButton*      rateLogCB;
    IBOutlet NSButton*      totalRateLogCB;
    IBOutlet ORPlotter1D*   timeRatePlot;
    IBOutlet NSButton*      timeRateLogCB;
	
    NSView *blankView;
    NSSize settingSize;
    NSSize rateSize;
}

- (id)   init;
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark •••Interface Management
- (void) energyGateLengthChanged:(NSNotification*)aNote;
- (void) runModeChanged:(NSNotification*)aNote;
- (void) endAddressThresholdChanged:(NSNotification*)aNote;
- (void) energyTauFactorChanged:(NSNotification*)aNote;
- (void) energySampleStartIndex3Changed:(NSNotification*)aNote;
- (void) energySampleStartIndex2Changed:(NSNotification*)aNote;
- (void) energySampleStartIndex1Changed:(NSNotification*)aNote;
- (void) energySampleLengthChanged:(NSNotification*)aNote;
- (void) energyGapTimeChanged:(NSNotification*)aNote;
- (void) energyPeakingTimeChanged:(NSNotification*)aNote;
- (void) triggerGateLengthChanged:(NSNotification*)aNote;
- (void) preTriggerDelayChanged:(NSNotification*)aNote;
- (void) sampleStartIndexChanged:(NSNotification*)aNote;
- (void) sampleLengthChanged:(NSNotification*)aNote;
- (void) dacOffsetChanged:(NSNotification*)aNote;
- (void) lemoInModeChanged:(NSNotification*)aNote;
- (void) lemoOutModeChanged:(NSNotification*)aNote;
- (void) acqRegEnableMaskChanged:(NSNotification*)aNote;
- (void) csrChanged:(NSNotification*)aNote;

- (void) clockSourceChanged:(NSNotification*)aNote;
- (void) slotChanged:(NSNotification*)aNote;
- (void) baseAddressChanged:(NSNotification*)aNote;
- (void) settingsLockChanged:(NSNotification*)aNote;
- (void) registerRates;
- (void) rateGroupChanged:(NSNotification*)aNote;
- (void) waveFormRateChanged:(NSNotification*)aNote;
- (void) totalRateChanged:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) enabledChanged:(NSNotification*)aNote;
- (void) gtChanged:(NSNotification*)aNote;
- (void) thresholdChanged:(NSNotification*)aNote;
- (void) gateLengthChanged:(NSNotification*)aNote;
- (void) pulseLengthChanged:(NSNotification*)aNote;
- (void) sumGChanged:(NSNotification*)aNote;
- (void) peakingTimeChanged:(NSNotification*)aNote;
- (void) internalTriggerDelayChanged:(NSNotification*)aNote;
- (void) triggerDecimationChanged:(NSNotification*)aNote;
- (void) energyDecimationChanged:(NSNotification*)aNote;

- (void) scaleAction:(NSNotification*)aNote;
- (void) integrationChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) energyGateLengthAction:(id)sender;
- (IBAction) runModeAction:(id)sender;
- (IBAction) energySampleStartIndex3Action:(id)sender;
- (IBAction) energyTauFactorAction:(id)sender;
- (IBAction) energySampleStartIndex2Action:(id)sender;
- (IBAction) energySampleStartIndex1Action:(id)sender;
- (IBAction) energySampleLengthAction:(id)sender;
- (IBAction) energyGapTimeAction:(id)sender;
- (IBAction) energyPeakingTimeAction:(id)sender;
- (IBAction) triggerGateLengthAction:(id)sender;
- (IBAction) preTriggerDelayAction:(id)sender;
- (IBAction) sampleStartIndexAction:(id)sender;
- (IBAction) sampleLengthAction:(id)sender;
- (IBAction) dacOffsetAction:(id)sender;
- (IBAction) lemoInModeAction:(id)sender;
- (IBAction) lemoOutModeAction:(id)sender;
- (IBAction) acqRegEnableMaskAction:(id)sender;
- (IBAction) csrAction:(id)sender;

- (IBAction) clockSourceAction:(id)sender;
- (IBAction) baseAddressAction:(id)sender;
- (IBAction) settingLockAction:(id) sender;
- (IBAction) initBoard:(id)sender;
- (IBAction) integrationAction:(id)sender;
- (IBAction) probeBoardAction:(id)sender;
- (IBAction) triggerDecimationAction:(id)sender;
- (IBAction) energyDecimationAction:(id)sender;

- (IBAction) enabledAction:(id)sender;
- (IBAction) gtAction:(id)sender;
- (IBAction) thresholdAction:(id)sender;
- (IBAction) gateLengthAction:(id)sender;
- (IBAction) pulseLengthAction:(id)sender;
- (IBAction) sumGAction:(id)sender;
- (IBAction) peakingTimeAction:(id)sender;
- (IBAction) internalTriggerDelayAction:(id)sender;
- (IBAction) writeThresholdsAction:(id)sender;
- (IBAction) readThresholdsAction:(id)sender;
- (IBAction) checkEvent:(id)sender;
- (IBAction) report:(id)sender;
- (IBAction) forceTrigger:(id)sender;

#pragma mark •••Data Source
- (double)  getBarValue:(int)tag;
- (int)		numberOfPointsInPlot:(id)aPlotter dataSet:(int)set;
- (float)  	plotter:(id) aPlotter dataSet:(int)set dataValue:(int) x;
- (unsigned long)  	secondsPerUnit:(id) aPlotter;
- (int) 	numberOfDataSetsInPlot:(id)aPlotter;
- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
