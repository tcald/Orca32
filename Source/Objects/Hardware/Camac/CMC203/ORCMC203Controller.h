//--------------------------------------------------------
// ORCMC203Controller
// Created by Mark  A. Howe on Tue Aug 02 2005
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
@class ORValueBar;
@class ORPlotter1D;

@interface ORCMC203Controller : OrcaObjectController
{
    IBOutlet NSButton*		loadButton;
    IBOutlet NSButton*		sampleButton;
	IBOutlet NSMatrix*		operationModeMatrix;
	IBOutlet NSTextField*	adcBitsTextField;
	IBOutlet NSPopUpButton* histogramModePU;
	IBOutlet NSPopUpButton* histogramMaxCountsPU;
	IBOutlet NSTextField*	wordSizeField;
	IBOutlet NSTextField*	histogramLengthTextField;
	IBOutlet NSTextField*	histogramStartTextField;
	IBOutlet NSButton*		initButton;
	IBOutlet NSTabView*		dataTabView;

	IBOutlet NSButton*		settingLockButton;

	//rates (fifo mode)
    IBOutlet NSStepper* 	integrationStepper;
    IBOutlet NSTextField* 	integrationText;
    IBOutlet NSTextField* 	totalRateText;
	
    IBOutlet ORValueBar*	totalRate;
    IBOutlet NSButton*		totalRateLogCB;
    IBOutlet ORPlotter1D*	timeRatePlot;
    IBOutlet NSButton*		timeRateLogCB;
	
	//histograms (histo mode)
    IBOutlet ORPlotter1D*	histoPlot;
}

#pragma mark ***Initialization

- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark •••Interface Management
- (void) operationModeChanged:(NSNotification*)aNote;
- (void) adcBitsChanged:(NSNotification*)aNote;
- (void) histogramModeChanged:(NSNotification*)aNote;
- (void) wordSizeChanged:(NSNotification*)aNote;
- (void) histogramLengthChanged:(NSNotification*)aNote;
- (void) histogramStartChanged:(NSNotification*)aNote;
- (void) settingsLockChanged:(NSNotification*)aNote;
- (void) slotChanged:(NSNotification*)aNote;
- (void) totalRateChanged:(NSNotification*)aNote;
- (void) integrationChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) updateHistoPlot:(NSNotification*)aNote;

#pragma mark ***Actions
- (IBAction) integrationAction:(id)sender;
- (IBAction) operationModeAction:(id)sender;
- (IBAction) sampleAction:(id)sender;
- (IBAction) adcBitsAction:(id)sender;
- (IBAction) histogramModeAction:(id)sender;
- (IBAction) wordSizeAction:(id)sender;
- (IBAction) histogramLengthTextFieldAction:(id)sender;
- (IBAction) histogramStartTextFieldAction:(id)sender;
- (IBAction) settingLockAction:(id) sender;
- (IBAction) initAction:(id)sender;
- (IBAction) loadFPGAAction:(id)sender;

@end

