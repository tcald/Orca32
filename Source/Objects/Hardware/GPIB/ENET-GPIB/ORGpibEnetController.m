//--------------------------------------------------------------------------------
//  Class:		ORGpibEnetController.m
//  Author:		Jan M. Wouters
// 	History:	2003-02-15 (jmw) Original.
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
#import "ORGpibEnetController.h"
#import "ORGpibEnetModel.h"


@implementation ORGpibEnetController
#pragma mark •••Initialization
- (id) init
{
    self = [ super initWithWindowNibName: @"ORGpibSetup" ];
    return self;
}

- (void) awakeFromNib
{
    [ super awakeFromNib ];
    [ self populatePullDowns ];
    [ self setTestButtonsEnabled: false ];
    [ self changeIbstaStatus: 0 ];
    [ self changeStatusSummary: 0 error: 0 count: 0 ];
    [ self testLockChanged: nil ];
    [ self updateWindow ];
}

- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [ super registerNotificationObservers ];
 
    [ notifyCenter addObserver: self
	                  selector: @selector( testLockChanged: )
	                      name: ORRunStatusChangedNotification
	                    object: nil ];

    [ notifyCenter addObserver: self
	                  selector: @selector( testLockChanged: )
	                      name: ORGpibEnetTestLock
	                    object: nil ];
						
    [ notifyCenter addObserver: self
	                  selector: @selector( writeToMonitor: )
	                      name: ORGpibMonitorNotification
	                    object: nil ];

    [ notifyCenter addObserver: self
	                  selector: @selector( boardIndexChange: )
	                      name: ORGPIBBoardChangedNotification
	                    object: [ self model ]];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [gSecurity globalSecurityEnabled];
    [gSecurity setLock:ORGpibEnetTestLock to:secure];
    
    [testLockButton setEnabled:secure];
}


- (void) testLockChanged: (NSNotification*) aNotification
{
    BOOL locked		= [ gSecurity isLocked:ORGpibEnetTestLock ];
    BOOL runInProgress  = [ gOrcaGlobals runInProgress ];
    
    [ testLockButton setState: locked];
    
    [ connectButton setEnabled: !locked && !runInProgress ];
    [ mPrimaryAddress setEnabled: !locked && !runInProgress ];
    [ mSecondaryAddress setEnabled: !locked && !runInProgress ];
    [ mCommand setEnabled: !locked && !runInProgress];
    [ mQuery setEnabled: !locked && !runInProgress ];
    [ mWrite setEnabled: !locked && !runInProgress ];
    [ mRead setEnabled: !locked && !runInProgress ];
}

//--------------------------------------------------------------------------------
/*!\method  boardIndexChange
 * \brief	Update dialog to reflect a change in the board index
 * \param	aNotification			- The notification object.
 * \note	
 */
//--------------------------------------------------------------------------------
- (void) boardIndexChange: (NSNotification*) aNotification
{
	short index;
	index = [[ self model ] boardIndex ];
	[ mGpibBoard selectItemAtIndex: index ];
}

//--------------------------------------------------------------------------------
/*!\method  writeToMonitor
 * \brief	Write message to monitor text box.
 * \param	aNotification			- The notification object.
 * \note	
 */
//--------------------------------------------------------------------------------
- (void) writeToMonitor: (NSNotification*) aNotification
{
    unsigned long maxTextSize = 100000;
	NS_DURING
		NSString* command = [[ aNotification userInfo ] objectForKey: ORGpibMonitor ];
		[monitorView replaceCharactersInRange:NSMakeRange([[monitorView textStorage] length], 0) withString:command];
		if([[monitorView textStorage] length] > maxTextSize){
			[[monitorView textStorage] deleteCharactersInRange:NSMakeRange(0,maxTextSize/3)];
		}
		[monitorView scrollRangeToVisible: NSMakeRange([[monitorView textStorage] length], 0)];

	NS_HANDLER
	NS_ENDHANDLER

}


#pragma mark •••Actions - Setup
- (IBAction) testLockAction: (id) sender
{
    [ gSecurity tryToSetLock:ORGpibEnetTestLock to:[sender intValue ] forWindow: [ self window]];
}

- (IBAction) changeBoardIndexAction:(id) aSender
{
    [[ self undoManager ] setActionName:@"Select BoardIndex"];
    [[ self model ] setBoardIndex: [ mGpibBoard indexOfSelectedItem ]];
}

#pragma mark •••Actions - Test
- (IBAction) query: (id) aSender
{
    char	data[2048];
    long	returnLen;
    long	maxLength = sizeof( data ) - 1;
    
    NS_DURING
        returnLen =  [[ self model ] writeReadDevice:[ mPrimaryAddress indexOfSelectedItem ] 
                                             command:[ mCommand stringValue ]
                                                data:&data[0]
                                           maxLength:maxLength];
   
        if ( returnLen > 0 ){
            data[ returnLen ] = '\0';
            [ mResult insertText: [ NSString stringWithCString: data ] ];
        }
    NS_HANDLER
        NSLog(@"%@\n",[localException reason]);
        NSRunAlertPanel( [localException name ], 	// Name of panel
                        [localException reason ],	// Reason for error
                        @"OK",				// Okay button
                        nil,				// alternate button
                        nil );				// other button
    NS_ENDHANDLER
}


- (IBAction) read: (id) aSender
{
    char	data[ 2048 ];
    long	returnLen;
    
    NS_DURING
        returnLen = [[ self model ] readFromDevice: [ mPrimaryAddress indexOfSelectedItem ]
                                              data: &data[ 0 ]
                                         maxLength: sizeof( data ) - 1 ];
                                     
        if ( returnLen > 0 )
            [ mResult insertText: [ NSString stringWithCString: data ]];
            
    NS_HANDLER
        NSLog(@"%@\n",[localException reason]);
        NSRunAlertPanel( [ localException name ], 	// Name of panel
                         [ localException reason ],	// Reason for error
                        @"OK", 						// Okay button
                        nil, 						// alternate button
                        nil );						// other button
    NS_ENDHANDLER
}


- (IBAction) write: (id) aSender
{
    NS_DURING
        [[ self model ] writeToDevice: [ mPrimaryAddress indexOfSelectedItem ]
                              command: [ mCommand stringValue ]];
    
    NS_HANDLER
        NSLog(@"%@\n",[localException reason]);
        NSRunAlertPanel( [ localException name ], 	// Name of panel
                         [ localException reason ],	// Reason for error
                         @"OK",						// Okay button
                         nil, 						// alternate button
                         nil );						// other button
    NS_ENDHANDLER
}


- (IBAction) connect:(id) aSender
{
    short primaryAddress;
    
    NS_DURING
        primaryAddress = [mPrimaryAddress indexOfSelectedItem];
        if ( primaryAddress  > -1 && primaryAddress < kMaxGpibAddresses )
        {
            if ( [[self model] checkAddress:primaryAddress] )
                [[self model] deactivateAddress:primaryAddress];
            
            [[self model] setupDevice:primaryAddress secondaryAddress:
                                                [[mSecondaryAddress stringValue] intValue]];
            [mConfigured setStringValue:[NSString stringWithFormat:
                                                @"Configured:%d\n", primaryAddress]];
            [self setTestButtonsEnabled:true];
        }

    NS_HANDLER
        NSLog(@"%@\n",[localException reason]);
        NSRunAlertPanel( [localException name], 	// Name of panel
                        [localException reason],	// Reason for error
                        @"OK", 						// Okay button
                        nil, 						// alternate button
                        nil );						// other button
    NS_ENDHANDLER
    
    [self changeIbstaStatus:[[self model] ibsta]];
    [self changeStatusSummary:[[self model] ibsta] 
                         error:[[self model] iberr] 
                         count:[[self model] ibcntl]];

}


//--------------------------------------------------------------------------------
/*!
 * \method  changePrimaryAddress
 * \brief	Set the primary address for the GPIB device.
 * \note	
 */
//--------------------------------------------------------------------------------
- (IBAction) changePrimaryAddress: (id) aSender
{
// Make sure that value has changed.
    if ( [ aSender indexOfSelectedItem ] != mPrimaryAddressValue )
    {

// Get the users new selection
        mPrimaryAddressValue = [ aSender indexOfSelectedItem ];
//        [self updatePopUpButton:mPrimaryAddress setting:mPrimaryAddressValue];
        [ mPrimaryAddress selectItemAtIndex: mPrimaryAddressValue ];
        
        NSLog ( [ NSString stringWithFormat: @"New Address %d\n", mPrimaryAddressValue ] );
        
// Check if address is configured.
        if ( [[self model] checkAddress:mPrimaryAddressValue] )
        {
            NSLog ( @"Configured\n" );
            [ mConfigured setStringValue:[ NSString stringWithFormat:
                                                @"Configured:%d\n", mPrimaryAddressValue ]];
            [ self setTestButtonsEnabled: true ];
        }
        else
        {
            NSLog ( @"Not Configured\n" );
            [ mConfigured setStringValue: [ NSString stringWithFormat:
                                                @"Not configured:%d", mPrimaryAddressValue ]];
            [ self setTestButtonsEnabled: false ];
        }
    }
}

#pragma mark ***Actions - Monitor
//--------------------------------------------------------------------------------
/*!
 * \method  changeMonitorRead
 * \brief	Change the monitoring status.
 * \note	
 */
//--------------------------------------------------------------------------------
- (IBAction) changeMonitorRead: (id) aSender
{
    bool	tmpValue = false;
    if ( [ aSender state ] == 1 ) tmpValue = true;
	
	[[ self model ] setGPIBMonitorRead: tmpValue ];
}
//--------------------------------------------------------------------------------
/*!
 * \method  changeMonitorWrite
 * \brief	Change the monitoring status.
 * \note	
 */
//--------------------------------------------------------------------------------
- (IBAction) changeMonitorWrite: (id) aSender
{
    bool	tmpValue = false;
    if ( [ aSender state ] == 1 ) tmpValue = true;
	
	[[ self model ] setGPIBMonitorWrite: tmpValue ];
}



#pragma mark ***Support
- (void) changeIbstaStatus: (int) aStatus
{
    short 				i;
    static	short ibstaLoc[kNumIbstaBits] = { 15, 14, 13, 12, 11, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    NSTextFieldCell	*tmpObject;
    
//    printf( "ibsta %d\n", aStatus );
        
    for ( i = 0; i < kNumIbstaBits; i++ )
    {
        tmpObject = [mIbstaErrors cellAtRow:i column:0];
        
        if ( aStatus & ( 1 << ibstaLoc[i] ) )
            [tmpObject setTextColor:[NSColor blackColor]];

        else
            [tmpObject setTextColor:[NSColor grayColor]];
    }    
}

- (void) changeStatusSummary:(int) aStatus error:(int) anError count:(long) aCount
{
    [mibsta setStringValue:[NSString stringWithFormat:@"%#0x", aStatus]];
    [miberr setStringValue: [NSString stringWithFormat:@"%#0x", anError]];
    [mibcntl setStringValue:[NSString stringWithFormat:@"%d", aCount]];
}


- (void) updateWindow
{
    [super updateWindow];
	[ self boardIndexChange: nil ];
    [mSecondaryAddress setStringValue:[NSString stringWithFormat:@""]];
    [mCommand setStringValue:[NSString stringWithFormat:@""]];
}


//--------------------------------------------------------------------------------
/*!
 * \method  populatePullDowns
 * \brief	Populate the GPIB board pulldown and the primary address pulldown
 *			items.
 * \note	
 */
//--------------------------------------------------------------------------------
- (void) populatePullDowns
{
    short	i;
    
// Remove all items from popup menus
    [mGpibBoard removeAllItems];        
    [mPrimaryAddress removeAllItems];
    
// Repopulate GPIB Board address
    for ( i = 0; i < kNumBoards; i++ )
    {
        [mGpibBoard insertItemWithTitle:[[self model] boardNames:i] atIndex:i];
    }
    
// Repopulate Primary GPIB address
    for ( i = 0; i <  kMaxGpibAddresses; i++ ) {
        [mPrimaryAddress insertItemWithTitle:[NSString stringWithFormat:@"%d", i]
                                      atIndex:i];
    } 
    
    mPrimaryAddressValue = -1;
   [ self changePrimaryAddress:nil];
}

//--------------------------------------------------------------------------------
/*!
 * \method  setTestButtonEnableds
 * \brief	Enable or disable the test buttons.  Depends on success of eastablishing
 *			connection to ENET-GPIB device.
 * \note	
 */
//--------------------------------------------------------------------------------
- (void) setTestButtonsEnabled:(BOOL) aValue
{
    [mQuery setEnabled:aValue];
    [mWrite setEnabled:aValue];
    [mRead setEnabled:aValue];            
}    
@end
