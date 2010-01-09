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
  * hierarchy and are displayed in a outline view. From there a sensor can easily be assigned to a channel.
  *
  * The slow control interface provides the ADEI web interface in a web view for monitoring a sensors values graphically.
  *
  * <br>
  * Details: <br>
  *
  * The class holds a list of channel/sensor items (stored in #sensorList) and a tree (the ADEI hierarchy) of sensor items (starting at #rootAdeiTree).
  * For channels and sensors we use the same class structure ORSensorItem.
  * Sensors in the list may or may not have a sibling in the tree.
  * So we may or may not have the tree and independently of the tree are able to load the sensor values of
  * the sensors listed in the #sensorList. So the sensorList can be saved in the .Orca file and used without tree.
  * The tree in fact is only necessary for defining the sensors in the "channel map".
  *
  *
  */
#define kResponseTimeHistogramSize 5000

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
	NSMutableArray*		 pollingLookUp;	//a look up table for itemKey by index
	NSMutableDictionary* channelLookup; //a look up table for itemKey by channel
	
	NSMutableDictionary* pendingRequests;	//itemKeys in this are requests that have not come back
	long histogram[kResponseTimeHistogramSize];
    int timeOutCount;
    int totalRequestCount;
    BOOL shipRecords;
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

- (void)          dumpSensorlist;
- (void)	      pollSlowControls;
- (NSString*)     createWebRequestForItem:(int)aChannel;
- (NSString*)	  itemDetails:(int)index;

#pragma mark ***Polling Cache
- (unsigned)  pollingLookUpCount;
- (NSString*) requestCacheItemKey:(int)anIndex;
- (NSDictionary*) requestCacheItem:(int)anIndex;

- (NSMutableDictionary*) topLevelPollingDictionary:(id)anItemKey;
- (int)	 nextUnusedChannelNumber;
- (BOOL) itemExists:(int)anIndex;
- (BOOL) isControlItem:(int)anIndex;
- (void) makeChannelLookup;

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
- (void) postSensorRequest:(NSString*)aUrl path:(NSString*)aPath;
- (void) postControlRequest:(NSString*)aUrl path:(NSString*)aPath;
- (void) postControlSetpoint:(NSString*)aUrl path:(NSString*)aPath value:(double)aValue;
- (BOOL) requestIsPending:(NSString*)aUrl path:(NSString*)aPath;
- (double) valueForUrl:(NSString*)aUrl path:(NSString*)aPath;


- (int) findChanOfSensor:(NSString*)aUrl path:(NSString*)aPath;
- (int) findChanOfControl:(NSString*)aUrl path:(NSString*)aPath;

- (void) postRequestForChan:(int)aChan;
- (void) postControlSetpointForChan:(int)aChan value:(double)aValue;
- (BOOL) requestIsPendingForChan:(int)aChan;
- (double) valueForChan:(int)aChan;


- (int) findChanOfIndex:(int)anIndex;
- (void) writeSetPoint:(int)anIndex value:(double)aValue;

@end

#pragma mark •••Notification Strings
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

