//--------------------------------------------------------
// ORCaen1190Controller
// Created by Mark  A. Howe on Mon May 19 2008
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2008 CENPA, University of Washington. All rights reserved.
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
#import "ORCaenCardController.h"

@class ORValueBar;
@class ORValueBarGroup;

@interface ORCaen1190Controller : ORCaenCardController 
{
	IBOutlet NSMatrix*		channelLabelMatrix0;
	IBOutlet NSPopUpButton* deadTimePU;
	IBOutlet NSPopUpButton* leadingWidthResolutionPU;
	IBOutlet NSPopUpButton* leadingTimeResolutionPU;
	IBOutlet NSPopUpButton* leadingTrailingLSBPU;
	IBOutlet NSPopUpButton* edgeDetectionPU;
	IBOutlet NSButton*		enableTrigTimeSubCB;
	IBOutlet NSTextField*	rejectMarginTextField;
	IBOutlet NSTextField*	searchMarginTextField;
	IBOutlet NSTextField*	windowOffsetTextField;
	IBOutlet NSTextField*	windowWidthTextField;
	IBOutlet NSPopUpButton* acqModePU;
	IBOutlet NSTextField*	paramGroupField;
	IBOutlet NSMatrix*		enabledMatrix0;
	IBOutlet NSMatrix*		rateMatrix0;
	IBOutlet NSButton*		allButton0;
	IBOutlet NSButton*		noneButton0;
	IBOutlet ORValueBar*	valueBar0;
	IBOutlet ORValueBarGroup* valueBarGroup0;
 
	NSSize setupSize;
	NSSize ratesSize;
}

#pragma mark ***Initialization
- (id)		init;
 	
#pragma mark •••Notifications
- (void) registerNotificationObservers;
- (void) registerRates;
- (void) updateWindow;
- (void) setChannelLabels;

#pragma mark ***Interface Management
- (void) deadTimeChanged:(NSNotification*)aNote;
- (void) leadingWidthResolutionChanged:(NSNotification*)aNote;
- (void) leadingTimeResolutionChanged:(NSNotification*)aNote;
- (void) leadingTrailingLSBChanged:(NSNotification*)aNote;
- (void) edgeDetectionChanged:(NSNotification*)aNote;
- (void) enableTrigTimeSubChanged:(NSNotification*)aNote;
- (void) rejectMarginChanged:(NSNotification*)aNote;
- (void) searchMarginChanged:(NSNotification*)aNote;
- (void) windowOffsetChanged:(NSNotification*)aNote;
- (void) windowWidthChanged:(NSNotification*)aNote;
- (void) acqModeChanged:(NSNotification*)aNote;
- (void) paramGroupChanged:(NSNotification*)aNote;
- (void) updateWindow;
- (void) enabledMaskChanged:(NSNotification*)aNote;
- (void) tdcRateChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) deadTimeAction:(id)sender;
- (IBAction) leadingWidthResolutionAction:(id)sender;
- (IBAction) leadingTimeResolutionAction:(id)sender;
- (IBAction) leadingTrailingLSBAction:(id)sender;
- (IBAction) edgeDetectionAction:(id)sender;
- (IBAction) enableTrigTimeSubAction:(id)sender;
- (IBAction) rejectMarginAction:(id)sender;
- (IBAction) searchMarginAction:(id)sender;
- (IBAction) windowOffsetAction:(id)sender;
- (IBAction) windowWidthAction:(id)sender;
- (IBAction) acqModeAction:(id)sender;
- (IBAction) enabledMatrixAction:(id)sender;
- (IBAction) enabledAllAction:(id)sender;
- (IBAction) enabledNoneAction:(id)sender;
- (IBAction) incGroupAction:(id)sender;
- (IBAction) decGroupAction:(id)sender;
- (IBAction) loadDefaultsAction:(id)sender;

@end
