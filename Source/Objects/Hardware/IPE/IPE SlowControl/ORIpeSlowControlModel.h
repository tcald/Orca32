//--------------------------------------------------------
// ORIpeSlowControlModel
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

#pragma mark ***Imported Files
#import "ORAdcProcessing.h"
#import "ORDataChainObject.h"

#pragma mark ***Forward Declarations
@class ORSensorItem;

/* Dodo-List:
 *
 * -could try using asynchronous download of csv files, see UsingNSURLConnection.html keyword: NSURLConnection (-tb-)
 *  (file://localhost/Developer/Documentation/DocSets/com.apple.ADC_Reference_Library.CoreReference.docset/Contents/Resources/Documents/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html#//apple_ref/doc/uid/20001836-BAJEAIEE)
 * Class: NSURLConnection
 */
/*********************************************************************-tb-
 * GLOBAL FUNCTIONS AND DEFINITIONS
 *********************************************************************/
 

/*********************************************************************-tb-
 * CLASSES
 *********************************************************************/

/** This class provides a list of items (or sensors or controls). These channels can be used in the Orca processing framework
  * as input channels. The channel values are read from the ADEI system (by sending http requests to the ADEI system).
  *
  * The channels are free configurable. They can be configured by requesting all available sensor descriptions from the ADEI system
  * and assigning one of these sensors to one of the channels. The available sensors are grouped in a tree structured
  * hierarchy and are displayed in a outline view. From there a sensor can easily be assigned to a channel (drag&drop).
  *
  * The slow control interface provides the ADEI web interface in a web view for monitoring a sensors values graphically.
  *
  * 2009-12: Now controls have been added. Controls are similar to Sensors with the extension that a setpoint can be sent to a control.
  *
  * <br>
  * Details: <br>
  *
  * The class holds a list of channel/sensor items (stored in #requestCache, #pollingLookUp and #channelLookup) and a tree (the ADEI hierarchy) of sensor items (starting at #itemTreeRoot).
  * For channels and sensors we use the same class structure ORSensorItem.
  * Sensors in the list may or may not have a sibling in the tree.
  * So we may or may not have the tree and independently of the tree are able to load the sensor values of
  * the sensors listed in the #requestCache. So the requestCache can be saved in the .Orca file and used without tree.
  * The tree in fact is only necessary for defining the sensors in the "channel map".
  *
  * <br>
  * Updates and additional notes 2011-12-14:<br>
  *
  * Below are examples of the internal data structures  #pollingLookUp, #channelLookup, #requestCache and #itemTreeRoot.
  *
  * #itemTreeRoot contains all information of the ADEI tree and is displayed in the ADEI tree outline view.
  *
  * #pollingLookUp (array) contains a list of all available channels in short form i.e. each item may be described by its URL and PATH.
  * Each list entry is a string and has the format 'URL/PATH'. This is called the #itemKey.
  * 
  * #channelLookup (dictionary) assigns the channel numbers to the item keys.
  *
  * #requestCache (dictionary) holds a entry for each defined channel - it uses the itemKey as key for the according entry.
  * Each toplevel object is again a dictionary which holds several standard keys like ChannelNumber, HiAlarm, LoAlarm, HiLimit, LoLimit.
  * Further it contains again a dictionary as object with key 'itemKey' (the key also could be any constant name e.g. 'itemInfo' to make
  * the access of its members easier) which holds further information, mainly the name, PATH, URL and for control items "Control = 1".
  
<pre>  
  
   Examples of the internal data structures (arrays, dictionarys):  pollingLookUp, channelLookup, requestCache, itemTreeRoot

112609 19:25:01 pollingLookUp:
 (
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/0/0",
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/2",
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/4",
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/6",
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/5",
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/3"
)
112609 19:25:01 channelLookup:
 {
    4 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/5";
    2 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/6";
    3 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/4";
    1 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/2";
    5 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/3";
    0 = "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/0/0";
}
112609 19:25:01 requestCache:
 {
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/0/0" =     {
        ChannelNumber = 0;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/0/0" =         {
            Date = "26-Nov-09 11:06:47.000000";
            Name = " item0 [Temperatures]";
            Path = "test_zeus/cfp_test/0/0";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            Value = " 10";
        };
    };
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/2" =     {
        ChannelNumber = 1;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/2" =         {
            Control = 1;
            Path = "test_zeus/cfp_test/3/2";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            "db_group" = 3;
            "db_name" = "cfp_test";
            "db_server" = "test_zeus";
            id = 2;
            name = "HV Setpoint";
            obtained = "1259259243.5455";
            timestamp = "1259259241.875";
            value = "8.5";
            verified = "1259259242.375";
            write = 1;
        };
    };
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/3" =     {
        ChannelNumber = 5;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/3" =         {
            Control = 1;
            Path = "test_zeus/cfp_test/3/3";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            "db_group" = 3;
            "db_name" = "cfp_test";
            "db_server" = "test_zeus";
            id = 3;
            name = Temp1;
            obtained = "1259234761.5002";
            timestamp = 1259234758;
            value = 123;
            verified = "1259234761.5";
            write = 1;
        };
    };
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/4" =     {
        ChannelNumber = 3;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/4" =         {
            Control = 1;
            Path = "test_zeus/cfp_test/3/4";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            "db_group" = 3;
            "db_name" = "cfp_test";
            "db_server" = "test_zeus";
            id = 4;
            name = Temp2;
            obtained = "1259234761.4031";
            timestamp = 1259234758;
            value = 4;
            verified = "1259234759.9844";
            write = 1;
        };
    };
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/5" =     {
        ChannelNumber = 4;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/5" =         {
            Control = 1;
            Path = "test_zeus/cfp_test/3/5";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            "db_group" = 3;
            "db_name" = "cfp_test";
            "db_server" = "test_zeus";
            id = 5;
            name = Temp3;
            obtained = "1259234761.5942";
            timestamp = 1259234758;
            value = 10;
            verified = "1259234761.5";
            write = 1;
        };
    };
    "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/6" =     {
        ChannelNumber = 2;
        HiAlarm = 100;
        HiLimit = 100;
        LoAlarm = 0;
        LoLimit = 0;
        "http://ipepdvadei.ka.fzk.de/test//test_zeus/cfp_test/3/6" =         {
            Control = 1;
            Path = "test_zeus/cfp_test/3/6";
            URL = "http://ipepdvadei.ka.fzk.de/test/";
            "db_group" = 3;
            "db_name" = "cfp_test";
            "db_server" = "test_zeus";
            id = 6;
            name = Press1;
            obtained = "1259234761.5694";
            timestamp = 1259234758;
            value = 10;
            verified = "1259234761.5";
            write = 1;
        };
    };
}



112609 19:25:01 itemTreeRoot:
 (
        {
        Children =         (
                        {
                Children =                 (
                                        {
                        Children =                         (
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/2/0";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item0;
                                read = 1;
                                value = 0;
                            },
                                                        {
...
...
...
                            },
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/2/5";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item5;
                                read = 1;
                                value = 5;
                            }
                        );
                        Name = 2;
                        Path = "test_zeus/cfp_test/2";
                        URL = "http://ipepdvadei.ka.fzk.de/test/";
                    },
                                        {
                        Children =                         (
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/4/0";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item0;
                                read = 1;
                                value = 0;
                                write = 1;
                            }
                        );
                        Name = 4;
                        Path = "test_zeus/cfp_test/4";
                        URL = "http://ipepdvadei.ka.fzk.de/test/";
                    },
...
...
...

                                        {
                        Children =                         (
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/6/0";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item0;
                                read = 1;
                                value = 0;
                            },
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/6/1";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item1;
                                read = 1;
                                value = 1;
                            },
...
...
...
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/6/5";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item5;
                                read = 1;
                                value = 5;
                            }
                        );
                        Name = 6;
                        Path = "test_zeus/cfp_test/6";
                        URL = "http://ipepdvadei.ka.fzk.de/test/";
                    },
                                        {
                        Children =                         (
                                                        {
                                Control = 1;
                                Path = "test_zeus/cfp_test/0/0";
                                URL = "http://ipepdvadei.ka.fzk.de/test/";
                                name = item0;
                                read = 1;
                                value = 0;
                            }
                        );
                        Name = 0;
                        Path = "test_zeus/cfp_test/0";
                        URL = "http://ipepdvadei.ka.fzk.de/test/";
                    }
                );
                Name = "cfp_test";
                Path = "test_zeus/cfp_test";
                URL = "http://ipepdvadei.ka.fzk.de/test/";
            }
        );
        Name = "test_zeus";
        Path = "test_zeus";
        URL = "http://ipepdvadei.ka.fzk.de/test/";
    }
)

</pre>  
  *
  *
  */
  
  
#define kResponseTimeHistogramSize 15000

@interface ORIpeSlowControlModel : OrcaObject <ORAdcProcessing>
{
    int				 channelDataId;
 	NSString*		 IPNumber;
	NSMutableArray*	 connectionHistory;
	unsigned 		 ipNumberIndex;	
    int				 pollTime;
	
	NSMutableArray* itemTreeRoot;
	NSString*		lastRequest;
    BOOL			viewItemName;
    int				itemType;
    double			setPoint;
    BOOL			fastGenSetup;
	BOOL			checkingForTimeouts;
	
	NSMutableDictionary* requestCache;	//items to poll. Also contains extra info for the processing system
                                        // These holds also the deleted item (for undo) and the items created by a Orca script -tb-
	NSMutableArray*		 pollingLookUp;	//a look up table for itemKey by index; 
                                        //this represents the contents of the list view (subset of requestCache) -tb-
	NSMutableDictionary* channelLookup; //a look up table for itemKey by channel
                                        //this represents the contents of the list view (subset of requestCache) -tb-
	
	NSMutableDictionary* pendingRequests;	//itemKeys in this are requests that have not come back
	long histogram[kResponseTimeHistogramSize];
    int timeOutCount;
    int totalRequestCount;
    BOOL shipRecords;
    BOOL showDebugOutput;
    NSMutableArray* setpointRequestsQueue;
    NSString* manualPath;
    int manualType;
}

#pragma mark ***Initialization
- (id)   init;
- (id)   initBasics;
- (void) dealloc;
- (void) setUpImage;
- (void) makeMainController;
- (void) clearHistory;

#pragma mark •••Data Records
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherCard;
- (int) channelDataId;
- (void) setChannelDataId:(int) aValue;

#pragma mark ***Accessors
- (int) manualType;
- (void) setManualType:(int)aManualType;
- (NSString*) manualPath;
- (void) setManualPath:(NSString*)aManualPath;
- (NSMutableArray*) setpointRequestsQueue;
- (void) setSetpointRequestsQueue:(NSMutableArray*)aSetpointRequestsQueue;
- (int) setpointRequestsQueueCount;
- (BOOL) showDebugOutput;
- (void) setShowDebugOutput:(BOOL)aShowDebugOutput;
- (BOOL) shipRecords;
- (void) setShipRecords:(BOOL)aShipRecords;
- (int) totalRequestCount;
- (void) setTotalRequestCount:(int)aTotalRequestCount;
- (int) timeOutCount;
- (void) setTimeOutCount:(int)aTimeOutCount;
- (BOOL) fastGenSetup;
- (void) setFastGenSetup:(BOOL)aFastGenSetup;
- (double) setPoint;
- (void) setSetPoint:(double)aSetPoint;
- (int) itemType;
- (void) setItemType:(int)aItemType;
- (BOOL) viewItemName;
- (void) setViewItemName:(BOOL)aViewItemName;
- (unsigned) connectionHistoryCount;
- (id) connectionHistoryItem:(unsigned)index;
- (NSString*) IPNumber;
- (void) setIPNumber:(NSString*)aIPNumber;
- (NSString*) ipNumberToURL;
- (NSArray*) itemTreeRoot;
- (int) pollTime;
- (void) setPollTime:(int)aPollTime;
- (NSString*) lastRequest;
- (void) setLastRequest:(NSString*)aString;
- (void) loadItemTree;
- (void) addItems:(NSArray*)aSensorPathArray;
- (NSString*) itemKey:aUrl:aPath;
- (void) removeSet:(NSIndexSet*)aSetToRemove;
- (unsigned) pendingRequestsCount;
- (id) pendingRequest:(id)aKey forIndex:(int)anIndex;

- (void)      dumpSensorlist;
- (void)      pollSlowControls;
- (NSString*) createWebRequestForItem:(int)aChannel;
- (NSString*) itemDetails:(int)index;

- (int)       createChannelWithUrl:(NSString*)aUrl path:(NSString*)aPath chan:(int)aChan controlType:(int)isControl;
- (void)      manuallyCreateChannel;


#pragma mark ***Polling Cache
- (unsigned)  pollingLookUpCount;
- (NSString*) requestCacheItemKey:(int)anIndex;
- (NSDictionary*) requestCacheItem:(int)anIndex;

- (NSMutableDictionary*) topLevelPollingDictionary:(id)anItemKey;
- (int)	 nextUnusedChannelNumber;
- (BOOL) itemExists:(int)anIndex;
- (BOOL) channelExists:(int)aChan;
- (BOOL) isControlItem:(int)anIndex;
- (BOOL) isControlItemWithItemKey:(NSString*)itemKey;
- (void) makeChannelLookup;
- (int) channelNumberForItemKey:(NSString*) anItemKey;  //works on requestCache
- (int) setChannelNumber:(int) aChan forItemKey:(NSString*) anItemKey ;//works on requestCache and channelLookup

#pragma mark •••Statistics
- (void) histogram:(int)milliSecs;
- (long) dataTimeHist:(int)index;

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

- (NSDictionary*) dataRecordDescription;
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary;

#pragma mark •••Adc or Bit Processing Protocol
- (void)processIsStarting;
- (void)processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (NSString*) processingTitle;
- (double) convertedValue:(int)channel;
- (double) maxValueForChan:(int)channel;
- (double) minValueForChan:(int)channel;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel;

#pragma mark •••Helpers
- (NSString*) identifier;
- (NSMutableDictionary*) makeTopLevelDictionary;

#pragma mark •••Main Scripting Methods
//Scripts really shouldn't call any other methods unless you -REALLY- know what you're doing!
- (int) createSensorWithUrl:(NSString*)aUrl path:(NSString*)aPath;
- (int) createControlWithUrl:(NSString*)aUrl path:(NSString*)aPath;
- (int) createSensorWithUrl:(NSString*)aUrl path:(NSString*)aPath chan:(int)aChan;
- (int) createControlWithUrl:(NSString*)aUrl path:(NSString*)aPath chan:(int)aChan;


- (int) findChanOfSensor:(NSString*)aUrl path:(NSString*)aPath;
- (int) findChanOfControl:(NSString*)aUrl path:(NSString*)aPath;

- (void) sendControlSetpointForChan:(int)aChan value:(double)aValue;
- (void) queueControlSetpointForChan:(int)aChan value:(double)aValue;
- (void) fillRequest:(NSDictionary*)unusedobj intoTree:(NSMutableDictionary*)requestTree accordingTo:(NSArray*)pathThroughTree level:(int)level;//don't call in scripts, helper for sendSetpointRequestQueue
- (void) traverseTree:(NSMutableDictionary*)theTree level:(int)level requestString:(NSMutableString*)aString requestStringList:(NSMutableArray*)requestStringList;//don't call in scripts, helper for sendSetpointRequestQueue

- (void) sendSetpointRequestQueue;
- (void) clearSetpointRequestQueue;


- (void) postRequestForChan:(int)aChan;
- (void) postControlSetpointForChan:(int)aChan value:(double)aValue;
- (BOOL) requestIsPendingForChan:(int)aChan;
- (double) valueForChan:(int)aChan;
- (double) valueForItemKey:(NSString*)itemKey;


//following methods are not recommended (use "...ForChan:" instead of "...aUrl path:..." functions) -tb-
- (int) findChanOfIndex:(int)anIndex;
- (void) postSensorRequest:(NSString*)aUrl path:(NSString*)aPath;
- (void) postControlRequest:(NSString*)aUrl path:(NSString*)aPath;
- (void) postControlSetpoint:(NSString*)aUrl path:(NSString*)aPath value:(double)aValue;
- (void) sendControlSetpoint:(NSString*)aUrl path:(NSString*)aPath value:(double)aValue;
- (void) sendRequestString:(NSString*)requestString;
- (BOOL) requestIsPending:(NSString*)aUrl path:(NSString*)aPath;
- (BOOL) requestIsPending:(NSString*)itemKey;
- (double) valueForUrl:(NSString*)aUrl path:(NSString*)aPath;

//dont use in scripts:
- (void) writeSetPoint:(int)anIndex value:(double)aValue;
- (void) queueControlSetpointForIndex:(int)anIndex value:(double)aValue;

@end

#pragma mark •••Notification Strings
extern NSString* ORIpeSlowControlModelManualTypeChanged;
extern NSString* ORIpeSlowControlModelManualPathChanged;
extern NSString* ORIpeSlowControlModelShowDebugOutputChanged;
extern NSString* ORIpeSlowControlModelShipRecordsChanged;
extern NSString* ORIpeSlowControlModelTotalRequestCountChanged;
extern NSString* ORIpeSlowControlModelTimeOutCountChanged;
extern NSString* ORIpeSlowControlModelFastGenSetupChanged;
extern NSString* ORIpeSlowControlModelSetPointChanged;
extern NSString* ORIpeSlowControlModelItemTypeChanged;
extern NSString* ORIpeSlowControlModelViewItemNameChanged;
extern NSString* ORIpeSlowControlLock;
extern NSString* ORIpeSlowControlItemListChanged;
extern NSString* ORIpeSlowControlPollTimeChanged;
extern NSString* ORIpeSlowControlLastRequestChanged;
extern NSString* SBC_LinkIPNumberChanged;
extern NSString* ORIpeSlowControlIPNumberChanged;
extern NSString* ORIpeSlowItemTreeChanged;
extern NSString* ORIpeSlowControlModelHistogramChanged;
extern NSString* ORIpeSlowControlPendingRequestsChanged;
extern NSString* ORIpeSlowControlSetpointRequestQueueChanged;

// this is for testing and debugging the  code -tb- 2008-12-08
//#define __ORCA_DEVELOPMENT__CONFIGURATION__
#ifdef __ORCA_DEVELOPMENT__CONFIGURATION__

#define USE_TILLS_DEBUG_MACRO //<--- to switch on/off debug output use/comment out this line -tb-
#ifdef USE_TILLS_DEBUG_MACRO
#define    DebugTB(x) x
#else
#define    DebugTB(x) 
#endif

#if 1
// if 1 all methods will print out a message -> for testing IB connections -tb-
#define    DebugMethCallsTB(x) x
#else
#define    DebugMethCallsTB(x) 
#endif

#else
#define    DebugTB(x) 
#define    DebugMethCallsTB(x) 
#endif

