//--------------------------------------------------------
// ORPacController
// Created by Mark  A. Howe on Tue Jan 6, 2009
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
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files
@class ORPlotter1D;

@interface ORPacController : OrcaObjectController
{
	IBOutlet NSTabView*		tabView;
	IBOutlet NSTableView*	rdacTableView;
    IBOutlet NSTextField*   lockDocField;
	IBOutlet NSButton*		setAllRDacsButton;
	IBOutlet NSTextField*	rdacChannelTextField;
	IBOutlet NSTextField*	preAmpTextField;
	IBOutlet NSTextField*	moduleTextField;
	IBOutlet NSTextField*	dacValueField;
    IBOutlet NSButton*      lockButton;
    IBOutlet NSTextField*   portStateField;
    IBOutlet NSPopUpButton* portListPopup;
    IBOutlet NSButton*      openPortButton;
    IBOutlet NSButton*      readAdcsButton;
    IBOutlet NSButton*      writeLcmButton;
    IBOutlet NSMatrix*      adcMatrix;
    IBOutlet NSMatrix*      timeMatrix;
    IBOutlet NSButton*      writeDacButton;
    IBOutlet NSButton*      readDacButton;
    IBOutlet NSButton*      selectModuleButton;
    IBOutlet NSMatrix*      lcmEnabledMatrix;

    IBOutlet NSButton*      loadButton0;
    IBOutlet NSButton*      loadButton1;
    IBOutlet NSButton*      loadButton2;
    IBOutlet NSButton*      loadButton3;
    IBOutlet NSButton*      loadButtonAll;	

	IBOutlet NSPopUpButton* pollingButton;
	IBOutlet NSTextField*	logFileTextField;
	IBOutlet NSButton*		logToFileButton;
	
	IBOutlet ORPlotter1D*   plotter0;
	IBOutlet ORPlotter1D*   plotter1;
	
}

#pragma mark •••Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark •••Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark •••Interface Management
- (void) scaleAction:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNote;
- (void) pollingStateChanged:(NSNotification*)aNote;
- (void) rdacsChanged:(NSNotification*)aNote;
- (void) setAllRDacsChanged:(NSNotification*)aNote;
- (void) rdacChannelChanged:(NSNotification*)aNote;
- (void) lcmEnabledChanged:(NSNotification*)aNote;
- (void) preAmpChanged:(NSNotification*)aNote;
- (void) moduleChanged:(NSNotification*)aNote;
- (void) dacValueChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)aNote;
- (void) portNameChanged:(NSNotification*)aNote;
- (void) portStateChanged:(NSNotification*)aNote;
- (void) adcChanged:(NSNotification*)aNote;
- (void) logToFileChanged:(NSNotification*)aNote;
- (void) loadAdcTimeValuesForIndex:(int)index;
- (void) logFileChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) setAllRDacsAction:(id)sender;
- (IBAction) rdacChannelAction:(id)sender;
- (IBAction) writeLcmEnabledAction:(id)sender;
- (IBAction) preAmpAction:(id)sender;
- (IBAction) moduleAction:(id)sender;
- (IBAction) dacValueAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) portListAction:(id) sender;
- (IBAction) openPortAction:(id)sender;
- (IBAction) readAdcsAction:(id)sender;
- (IBAction) writeDacAction:(id)sender;
- (IBAction) readDacAction:(id)sender;
- (IBAction) lcmEnabledAction:(id)sender;
- (IBAction) selectModuleAction:(id)sender;
- (IBAction) loadRdcaAction:(id)sender;

- (IBAction) selectFileAction:(id)sender;
- (IBAction) setPollingAction:(id)sender;
- (IBAction) logToFileAction:(id)sender;

- (void) tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row;

@end


