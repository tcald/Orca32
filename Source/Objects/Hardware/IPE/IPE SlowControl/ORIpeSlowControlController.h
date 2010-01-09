//--------------------------------------------------------
// ORIpeSlowControlController
// Created by Mark  A. Howe on Mon Apr 11 2005
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
@class ORPlotter1D;
@class WebView;

#if defined(MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6 // 10.6-specific
@interface ORIpeSlowControlController : OrcaObjectController <NSComboBoxDataSource>
#else
@interface ORIpeSlowControlController : OrcaObjectController
#endif

{
	IBOutlet ORPlotter1D*		timingPlotter;   
	IBOutlet NSButton*			shipRecordsCB;
	IBOutlet NSTextField*		totalRequestCountField;
	IBOutlet NSTextField*		timeOutCountField;
	IBOutlet NSButton*			lockButton;   
	IBOutlet NSButton*			fastGenSetupButton;
	IBOutlet NSMatrix*			itemTypeMatrix;
	IBOutlet NSMatrix*			viewItemNameMatrix;
	IBOutlet ORTimedTextField*	lastRequestField;
    IBOutlet NSOutlineView*		itemTreeOutlineView;
    IBOutlet NSTextView*		treeDetailsView;
    IBOutlet NSTextView*		itemDetailsView;
    IBOutlet NSTableView*		itemTableView; 
    IBOutlet NSTableView*		pendingRequestsTable; 
	IBOutlet NSComboBox*		ipNumberComboBox;
	IBOutlet NSButton*			viewItemInWebButton;
	IBOutlet NSPopUpButton*		pollTimePopup;	
	IBOutlet NSTextField*		setPointField;
	IBOutlet NSButton*			setPointButton;
	IBOutlet id					editChannelNumberView;
	IBOutlet NSPopUpButton*		newChannelNumberPopup;	
    
	//Drawers
    IBOutlet NSDrawer*	treeDrawer;
    IBOutlet NSDrawer*	webDrawer;
    IBOutlet WebView*	webView;
	IBOutlet NSButton*  webViewButton;
	IBOutlet NSButton*  treeViewButton;
	
	//local caches
    NSMutableArray*     draggedNodes;
}

#pragma mark ***Initialization
- (id) init;

#pragma mark ***Interface Management
- (void) shipRecordsChanged:(NSNotification*)aNote;
- (void) totalRequestCountChanged:(NSNotification*)aNote;
- (void) timeOutCountChanged:(NSNotification*)aNote;
- (void) pendingRequestsChanged:(NSNotification*)aNote;
- (void) fastGenSetupChanged:(NSNotification*)aNote;
- (void) setPointChanged:(NSNotification*)aNote;
- (void) registerNotificationObservers;
- (void) itemTypeChanged:(NSNotification*)aNote;
- (void) updateWindow;
- (void) setWindowTitle;
- (void) lockChanged:(NSNotification*)aNote;
- (void) ipNumberChanged:(NSNotification*)aNote;
- (void) viewItemNameChanged:(NSNotification*)aNote;
- (void) treeChanged:(NSNotification*)aNote;
- (void) itemListChanged:(NSNotification*)aNote;
- (void) pollTimeChanged:(NSNotification*)aNote;
- (void) lastRequestChanged:(NSNotification*)aNote;
- (void) tableViewSelectionDidChange:(NSNotification *)aNote;
- (void) histoPlotChanged:(NSNotification*)aNote;

#pragma mark ***Actions
- (IBAction) shipRecordsAction:(id)sender;
- (IBAction) fastGenSetupAction:(id)sender;
- (IBAction) writeSetPointAction:(id) sender;
- (IBAction) setPointAction:(id) sender;
- (IBAction) itemTypeAction:(id)sender;
- (IBAction) viewItemNameAction:(id)sender;
- (IBAction) viewItemInWebAction:(id)sender;
- (IBAction) removeItemAction:(id)sender;
- (IBAction) delete:(id)sender;
- (IBAction) cut:(id)sender;
- (IBAction) ipNumberAction:(id)sender;
- (IBAction) lockAction:(id)sender;
- (IBAction) loadItemTree:(id)sender;
- (IBAction) dumpSensorAction:(id)sender;
- (IBAction) toggleTreeDrawer:(id)sender;
- (IBAction) toggleWebDrawer:(id)sender;
- (IBAction) pollNowAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) clearHistory:(id) sender;
- (IBAction) setPointAction:(id) sender;
//list view context menu
- (IBAction)adeiListContextMenuAction:(id)sender;
- (IBAction)adeiListContextMenuLoadValueAction:(id)sender;
- (IBAction)adeiListContextMenuRemoveAction:(id)sender;
- (IBAction)adeiListContextMenuDisplayWebViewAction:(id)sender;//web view
//associated
- (IBAction) editChannelNumberAction:(id)sender;
- (IBAction) cancelEditChannelNumberAction:(id)sender;
- (IBAction) newChannelNumberAction:(id)sender;


#pragma mark •••Data Source Methods (OutlineView)
- (int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item; 
- (id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item; 
- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

#pragma mark •••Data Source Methods (ComboBox)
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;

#pragma mark •••Data Source Methods (TableView)
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL) tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard;
- (void) dragDone;
@end

@interface ORIpeTableView : NSTableView
- (void) drawRow:(NSInteger)row clipRect:(NSRect)clipRect;
@end


