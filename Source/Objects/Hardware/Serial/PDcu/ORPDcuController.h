//--------------------------------------------------------
// ORPDcuController
// Created by Mark  A. Howe on Wed 4/15/2009
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2009 CENPA, University of Washington. All rights reserved.
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
//for the us of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

@class StopLightView;
@class ORPlotter1D;
@class ORSerialPortController;

@interface ORPDcuController : OrcaObjectController
{
	IBOutlet NSTextField*	motorPowerField;
	IBOutlet NSTextField*	tmpRotSetField;
	IBOutlet NSTextField*	stationPowerField;
	IBOutlet NSTextField*	pressureField;
	IBOutlet NSTextField*	motorCurrentField;
	IBOutlet NSTextField*	actualRotorSpeedField;
	IBOutlet NSTextField*	setRotorSpeedField;
	IBOutlet NSTextField*	turboAcceleratingField;
	IBOutlet NSTextField*	speedAttainedField;
	IBOutlet NSTextField*	turboPumpOverTempField;
	IBOutlet NSTextField*	driveUnitOverTempField;
	IBOutlet NSTextField*	oilDeficiencyField;
	IBOutlet NSTextField*	deviceAddressField;
    IBOutlet NSButton*		lockButton;
    IBOutlet NSButton*		stationOnButton;
    IBOutlet NSButton*		stationOffButton;
    IBOutlet NSButton*		updateButton;
    IBOutlet NSButton*		initButton;
    IBOutlet StopLightView* lightBoardView;
    IBOutlet ORPlotter1D*		plotter;
	IBOutlet NSPopUpButton*	pressureScalePU;
    IBOutlet NSPopUpButton* pollTimePopup;
    IBOutlet ORSerialPortController* serialPortController;
}

#pragma mark •••Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark •••Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;
- (void) updateButtons;

#pragma mark •••Interface Management
- (void) tmpRotSetChanged:(NSNotification*)aNote;
- (void) stationPowerChanged:(NSNotification*)aNote;
- (void) motorPowerChanged:(NSNotification*)aNote;
- (void) turboAcceleratingChanged:(NSNotification*)aNote;
- (void) speedAttainedChanged:(NSNotification*)aNote;
- (void) pressureChanged:(NSNotification*)aNote;
- (void) motorCurrentChanged:(NSNotification*)aNote;
- (void) motorCurrentChanged:(NSNotification*)aNote;
- (void) actualRotorSpeedChanged:(NSNotification*)aNote;
- (void) setRotorSpeedChanged:(NSNotification*)aNote;
- (void) pressureChanged:(NSNotification*)aNote;
- (void) turboAcceleratingChanged:(NSNotification*)aNote;
- (void) motorCurrentChanged:(NSNotification*)aNote;
- (void) actualRotorSpeedChanged:(NSNotification*)aNote;
- (void) setRotorSpeedChanged:(NSNotification*)aNote;
- (void) deviceAddressChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)aNote;
- (void) turboOverTempChanged:(NSNotification*)aNote;
- (void) unitOverTempChanged:(NSNotification*)aNote;
- (void) oilDeficiencyChanged:(NSNotification*)aNote;
- (void) updateStopLight;
- (void) pressureScaleChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) pollTimeChanged:(NSNotification*)aNote;
- (BOOL) portLocked;

#pragma mark •••Actions
- (IBAction) tmpRotSetAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) pressureScaleAction:(id)sender;
- (IBAction) turnOnAction:(id)sender;
- (IBAction) turnOffAction:(id)sender;
- (IBAction) deviceAddressAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) updateAllAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) initAction:(id)sender;

@end


