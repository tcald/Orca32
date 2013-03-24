//
//  OREdelweissFLTModel.h
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
#import "ORIpeCard.h"
#import "ORIpeV4SLTModel.h"
#import "ORHWWizard.h"
#import "ORDataTaker.h"
#import "OREdelweissFLTDefs.h"
#import "ORAdcInfoProviding.h"


#pragma mark ‚Ä¢‚Ä¢‚Ä¢Forward Definitions
@class ORDataPacket;
@class ORTimeRate;
@class ORTestSuit;
@class ORCommandList;
@class ORRateGroup;

#define kNumEdelweissFLTTests 5
#define kEdelweissFLTBufferSizeLongs 1024
#define kEdelweissFLTBufferSizeShorts 1024/2

/** Access to the EDELWEISS first level trigger board of the IPE-DAQ V4 electronics.
 * The board contains 6 optical fiber inputs for bolometer ADC data and 
 * 6 optical fiber outputs for bolometer box commands. 
 * 
 * @section hwaccess Access to hardware  
 * ... uses the SBC Orca protocoll (software bus, using TCP/IP). 
 *
 * Every time a run is started the stored configuratiation is written to the
 * hardware before recording the data.
 *
 * The interface to the graphical configuration dialog is implemented in OREdelweissFLTController.
 *
 * The Flt will produce several types of data objects depending on the run mode:
 *   - events containing timestamp and energy
 *   - events with an additional adc data trace of ??? length (??? samples) //TODO:
 * 
 * @section readout Readout
 * UNDER CONSTRUCTION
 * .
 *
 */ 
@interface OREdelweissFLTModel : ORIpeCard <ORDataTaker,ORHWWizard,ORHWRamping,ORAdcInfoProviding>
{
    // Hardware configuration
    //int				fltRunMode;		replaced by flt ModeFlags -tb-
    NSMutableArray* thresholds;     //!< Array to keep the threshold of all 24 channel
    NSMutableArray* gains;			//!< Aarry to keep the gains
    unsigned long	dataId;         //!< Id used to identify energy data set (run mode)
	unsigned long	waveFormId;		//!< Id used to identify energy+trace data set (debug mode)
	unsigned long	hitRateId;
	unsigned long	histogramId;
	unsigned short	hitRateLength;		//!< Sampling time of the hitrate measurement (1..32 seconds)
	float			hitRate[kNumV4FLTChannels];	//!< Actual value of the trigger rate measurement
	BOOL			hitRateOverFlow[kNumV4FLTChannels];	//!< Overflow of hardware trigger rate register
	float			hitRateTotal;	//!< Sum trigger rate of all channels 
	
	BOOL			firstTime;		//!< Event loop: Flag to identify the first readout loop for initialization purpose
	
	ORTimeRate*		totalRate;
    int				analogOffset;
	unsigned long   statisticOffset; //!< Offset guess used with by the hardware statistical evaluation
	unsigned long   statisticN;		 //!< Number of samples used for statistical evaluation
	unsigned long   eventMask;		 //!<Bits set for last channels hit.
	
	//testing
	NSMutableArray* testStatusArray;
	NSMutableArray* testEnabledArray;
	BOOL testsRunning;
	ORTestSuit* testSuit;
	int savedMode;
	int savedLed;
	BOOL usingPBusSimulation;
    BOOL ledOff;
    unsigned long interruptMask;
	    
	// Register information (low level tab)
    unsigned short  selectedRegIndex;
    unsigned long   writeValue;
    unsigned long   selectedChannelValue;
    // fields for event readout
    int fifoBehaviour;
    unsigned long postTriggerTime;
    int gapLength;
    int filterLength;  //for ORKatrinV4FLTModel we use filterShapingLength from 2011-04/Orca:svnrev5050 on -tb- 
    BOOL storeDataInRam;
    BOOL runBoxCarFilter;
    BOOL readWaveforms;
    int runMode;        //!< This is the daqRunMode (not the fltRunMode on the hardware).
	                    //TODO: meaning runMode changed (compared to KATRIN); for EW we have several mode flags -tb-
    
	
	BOOL noiseFloorRunning;
	int noiseFloorState;
	long noiseFloorOffset;
    int targetRate;
	long noiseFloorLow[kNumV4FLTChannels];
	long noiseFloorHigh[kNumV4FLTChannels];
	long noiseFloorTestValue[kNumV4FLTChannels];
	BOOL oldEnabled[kNumV4FLTChannels];
	long oldThreshold[kNumV4FLTChannels];
	long newThreshold[kNumV4FLTChannels];
	
	unsigned long eventCount[kNumV4FLTChannels];
	
    //EDELWEISS vars
    int fltModeFlags; //TODO: unused, using "uint32_t controlRegister"
    //int tpix; //TODO: unused, using "uint32_t controlRegister"
    int fiberEnableMask;
    //int BBv1Mask;
    int selectFiberTrig;
	//uint64_t streamMask;
    uint64_t streamMask;
    uint64_t fiberDelays;
    int fastWrite;
    uint32_t statusRegister;
    int totalTriggerNRegister;
    uint32_t controlRegister;
    int repeatSWTriggerMode;
    int swTriggerIsRepeating;
    int32_t fiberOutMask;
    int fiberSelectForBBStatusBits;
    
    
    uint32_t statusBitsBB[kNumEWFLTFibers][kNumBBStatusBufferLength32];//default: [6][30]
    uint32_t oldStatusBitsBB[kNumEWFLTFibers][kNumBBStatusBufferLength32];//I store the old set of the status bits
    NSMutableData* statusBitsBBData;//used for  writing 'statusBitsBB' to file
    int relaisStatesBB; //remove it
    int fiberSelectForBBAccess;
    int useBroadcastIdforBBAccess;
    #if 0
    int idBBforBBAccess;
    int adcFreqkHzForBBAccess;  //remove it!!!
    int adcMultForBBAccess;    //remove it!!!
    int adcValueForBBAccess;   //remove it
    int adcRgForBBAccess;   //remove it
    int signa;//remove it
    int daca;//remove it
    int signb;//remove it
    int dacb;//remove it
    
    int adcRtForBBAccess;   //remove it
    int adcRt;  //remove it
    #endif
    unsigned int wCmdCode;
    unsigned int wCmdArg1;
    unsigned int wCmdArg2;
    int writeToBBMode;
}

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Initialization
- (id) init;
- (void) dealloc;
- (void) setUpImage;
- (void) makeMainController;
- (short) getNumberRegisters;

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Accessors
- (int) writeToBBMode;
- (void) setWriteToBBMode:(int)aWriteToBBMode;
- (unsigned int) wCmdArg2;
- (void) setWCmdArg2:(unsigned int)aWCmdArg2;
- (unsigned int) wCmdArg1;
- (void) setWCmdArg1:(unsigned int)aWCmdArg1;
- (unsigned int) wCmdCode;
- (void) setWCmdCode:(unsigned int)aWCmdCode;
- (NSMutableData*) statusBitsBBData;
- (void) setStatusBitsBBData:(NSMutableData*)aStatusBitsBBData;

- (int) dacbForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setDacbForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aDacb;
- (int) signbForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setSignbForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aSignb;
- (int) dacaForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setDacaForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aDaca;
- (int) signaForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setSignaForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aSigna;
- (int) adcRgForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setAdcRgForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aAdcRgForBBAccess;
- (void) writeAdcRgForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex;//HW access for Regul Parameter

- (int) adcRtForFiber:(int)aFiber;
- (void) setAdcRtForFiber:(int)aFiber to:(int)aAdcRt;
- (void) writeAdcRtForBBAccessForFiber:(int)aFiber;//HW access Rt
- (int) adcValueForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setAdcValueForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aAdcValueForBBAccess;
- (int) adcMultForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex; //TODO: change name to 'gains' (instead of Mult)
- (void) setAdcMultForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aAdcMultForBBAccess;
- (int) adcFreqkHzForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setAdcFreqkHzForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex to:(int)aAdcFreqkHzForBBAccess;
- (void) writeAdcFilterForBBAccessForFiber:(int)aFiber atIndex:(int)aIndex;//HW access for Freq+Gain (Mult)
- (int) useBroadcastIdforBBAccess;
- (void) setUseBroadcastIdforBBAccess:(int)aUseBroadcastIdforBBAccess;
- (int) idBBforBBAccessForFiber:(int)aFiber;
- (void) setIdBBforBBAccessForFiber:(int)aFiber to:(int)aIdBBforBBAccess;
- (int) fiberSelectForBBAccess;
- (void) setFiberSelectForBBAccess:(int)aFiberSelectForBBAccess;
- (int) relaisStatesBBForFiber:(int)aFiber;
- (void) setRelaisStatesBBForFiber:(int)aFiber to:(int)aRelaisStatesBB;

//BB status bit buffer
- (uint32_t) statusBB32forFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setStatusBB32forFiber:(int)aFiber atIndex:(int)aIndex to:(uint32_t)aValue;
- (uint16_t) statusBB16forFiber:(int)aFiber atIndex:(int)aIndex;
- (void) setStatusBB16forFiber:(int)aFiber atIndex:(int)aIndex to:(uint16_t)aValue;
- (uint16_t) statusBB16forFiber:(int)aFiber atOffset:(int) off index:(int)aIndex mask:(uint16_t) mask shift:(int) shift;
- (void) setStatusBB16forFiber:(int)aFiber atOffset:(int) off index:(int)aIndex mask:(uint16_t) mask shift:(int) shift to:(uint16_t)aValue;
- (void) dumpStatusBB16forFiber:(int)aFiber;

- (int) fiberSelectForBBStatusBits;//
- (void) setFiberSelectForBBStatusBits:(int)aFiberSelectForBBStatusBits;
- (uint32_t) fiberOutMask;
- (void) setFiberOutMask:(uint32_t)aFiberOutMask;
- (int) swTriggerIsRepeating;
- (void) setSwTriggerIsRepeating:(int)aSwTriggerIsRepeating;
- (int) repeatSWTriggerMode;
- (void) setRepeatSWTriggerMode:(int)aRepeatSWTriggerMode;
- (uint32_t) controlRegister;
- (void) setControlRegister:(uint32_t)aControlRegister;
- (int) statusLatency;
- (void) setStatusLatency:(int)aValue;
- (int) vetoFlag;
- (void) setVetoFlag:(int)aValue;
- (int) selectFiberTrig;
- (void) setSelectFiberTrig:(int)aSelectFiberTrig;
- (int) BBv1Mask;
- (BOOL) BBv1MaskForChan:(int)i;
- (void) setBBv1Mask:(int)aBBv1Mask;
- (int) fiberEnableMask;
- (int) fiberEnableMaskForChan:(int)i;
- (void) setFiberEnableMask:(int)aFiberEnableMask;
- (int) fltModeFlags;
- (void) setFltModeFlags:(int)aFltModeFlags;
- (int) tpix;
- (void) setTpix:(int)aTpix;


- (int) totalTriggerNRegister;
- (void) setTotalTriggerNRegister:(int)aTotalTriggerNRegister;
- (uint32_t) statusRegister;
- (void) setStatusRegister:(uint32_t)aStatusRegister;
- (int) fastWrite;
- (void) setFastWrite:(int)aFastWrite;
- (uint64_t) fiberDelays;
- (void) setFiberDelays:(uint64_t)aFiberDelays;
- (uint64_t) streamMask;
- (uint32_t) streamMask1;
- (uint32_t) streamMask2;
- (int) streamMaskForFiber:(int)aFiber chan:(int)aChan;
- (void) setStreamMask:(uint64_t)aStreamMask;
//- (void) setStreamMaskForFiber:(int)aFiber chan:(int)aChan;
- (int) targetRate;
- (void) setTargetRate:(int)aTargetRate;
- (int) runMode;
- (void) setRunMode:(int)aRunMode;
- (void) setToDefaults;
- (BOOL) storeDataInRam;
- (void) setStoreDataInRam:(BOOL)aStoreDataInRam;
- (int) filterLength;
- (void) setFilterLength:(int)aFilterLength;
- (int) gapLength;
- (void) setGapLength:(int)aGapLength;
- (unsigned long) postTriggerTime;
- (void) setPostTriggerTime:(unsigned long)aPostTriggerTime;
- (int) fifoBehaviour;
- (void) setFifoBehaviour:(int)aFifoBehaviour;
- (int) analogOffset;
- (void) setAnalogOffset:(int)aAnalogOffset;
- (BOOL) ledOff;
- (void) setLedOff:(BOOL)aledOff;
- (unsigned long) interruptMask;
- (void) setInterruptMask:(unsigned long)aInterruptMask;
- (unsigned short) hitRateLength;
- (void) setHitRateLength:(unsigned short)aHitRateLength;
- (BOOL) noiseFloorRunning;
- (int) noiseFloorOffset;
- (void) setNoiseFloorOffset:(int)aNoiseFloorOffset;
- (void) findNoiseFloors;
- (NSString*) noiseFloorStateString;


- (unsigned long) dataId;
- (void) setDataId: (unsigned long)aDataId;
- (unsigned long) waveFormId;
- (void) setWaveFormId: (unsigned long) aWaveFormId;
- (unsigned long) hitRateId;
- (void) setHitRateId: (unsigned long)aHitRateId;
- (unsigned long) histogramId;
- (void) setHistogramId: (unsigned long)aHistogramId;

- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherCard;

- (NSMutableArray*) gains;
- (NSMutableArray*) thresholds;
- (void) setGains:(NSMutableArray*)aGains;
- (void) setThresholds:(NSMutableArray*)aThresholds;

- (unsigned long)threshold:(unsigned short) aChan;
- (unsigned short)gain:(unsigned short) aChan;
- (BOOL) triggerEnabled:(unsigned short) aChan;
- (void) setThreshold:(unsigned short) aChan withValue:(unsigned long) aThreshold;
- (void) setGain:(unsigned short) aChan withValue:(unsigned short) aGain;
- (void) setTriggerEnabled:(unsigned short) aChan withValue:(BOOL) aState;

- (void) enableAllHitRates:(BOOL)aState;
- (void) enableAllTriggers:(BOOL)aState;
- (float) hitRate:(unsigned short)aChan;
- (float) rate:(int)aChan;

- (BOOL) hitRateOverFlow:(unsigned short)aChan;
- (float) hitRateTotal;

- (ORTimeRate*) totalRate;
- (void) setTotalRate:(ORTimeRate*)newTimeRate;

- (NSString*) getRegisterName: (short) anIndex;
- (unsigned long) getAddressOffset: (short) anIndex;
- (short) getAccessType: (short) anIndex;

- (unsigned short) selectedRegIndex;
- (void) setSelectedRegIndex:(unsigned short) anIndex;
- (unsigned long) writeValue;
- (void) setWriteValue:(unsigned long) aValue;
- (unsigned short) selectedChannelValue;
- (void) setSelectedChannelValue:(unsigned short) aValue;
- (int) restrictIntValue:(int)aValue min:(int)aMinValue max:(int)aMaxValue;
- (float) restrictFloatValue:(int)aValue min:(float)aMinValue max:(float)aMaxValue;


#pragma mark ‚Ä¢‚Ä¢‚Ä¢HW Access
//all can raise exceptions
- (unsigned long) regAddress:(int)aReg channel:(int)aChannel index:(int)index;
- (unsigned long) regAddress:(int)aReg channel:(int)aChannel;
- (unsigned long) regAddress:(int)aReg;
- (unsigned long) adcMemoryChannel:(int)aChannel page:(int)aPage;
- (unsigned long) readReg:(int)aReg;
- (unsigned long) readReg:(int)aReg channel:(int)aChannel;
- (unsigned long) readReg:(int)aReg channel:(int)aChannel  index:(int)aIndex;
- (void) writeReg:(int)aReg value:(unsigned long)aValue;
- (void) writeReg:(int)aReg channel:(int)aChannel value:(unsigned long)aValue;
- (void) readBlock:(int)aReg dataBuffer:(unsigned long*)aDataBuffer length:(unsigned long)length;

- (void) executeCommandList:(ORCommandList*)aList;
- (id) readRegCmd:(unsigned long) aRegister channel:(short) aChannel;
- (id) writeRegCmd:(unsigned long) aRegister channel:(short) aChannel value:(unsigned long)aValue;
- (id) readRegCmd:(unsigned long) aRegister;
- (id) writeRegCmd:(unsigned long) aRegister value:(unsigned long)aValue;

- (unsigned long) readVersion;

- (int32_t) readFiberOutMask;
- (void) writeFiberOutMask;

- (int)		readMode;

- (void) loadThresholdsAndGains;
- (void) initBoard;
- (void) writeInterruptMask;
- (void) readHitRates;
- (void) writeTestPattern:(unsigned long*)mask length:(int)len;
- (void) rewindTestPattern;
- (void) writeNextPattern:(unsigned long)aValue;
- (unsigned long) readStatus;
- (unsigned long) readControl;
- (unsigned long) readTotalTriggerNRegister;
- (void) writeControl;
- (void) writeStreamMask;
- (void) readStreamMask;
- (void) writeFiberDelays;
- (void) readFiberDelays;
- (void) writeCommandResync;
- (void) writeCommandTrigEvCounterReset;
- (void) writeCommandSoftwareTrigger;
- (void) readTriggerData;

- (void) sendWCommand;
- (void) sendWCommandIdBB:(int) idBB cmd:(int) cmd arg1:(int) arg1  arg2:(int) arg2;
- (void) readBBStatusForBBAccess;//BB access tab
- (void) readBBStatusBits;//low level tab
- (void) readAllBBStatusBits;

- (void) printStatusReg;
- (void) printVersions;
- (void) printValueTable;
- (void) printEventFIFOs;

/** Print result of hardware statistics for all channels */
- (void) printStatistics; // ak, 7.10.07
- (void) writeThreshold:(int)i value:(unsigned int)aValue;
- (unsigned int) readThreshold:(int)i;
- (void) writeTriggerControl;
- (BOOL) partOfEvent:(short)chan;
- (unsigned long) eventMask;
- (void) eventMask:(unsigned long)aMask;
- (NSString*) boardTypeName:(int)aType;
- (NSString*) fifoStatusString:(int)aType;

/** Enable the statistic evaluation of sum and sum square of the 
 * ADC signals in all channels.  */
- (void) enableStatistics; // ak, 7.10.07

/** Get statistics of a single channel */
- (void) getStatistics:(int)aChannel mean:(double *)aMean  var:(double *)aVar; // ak, 7.10.07

- (unsigned long) readMemoryChan:(int)chan page:(int)aPage;
- (void) readMemoryChan:(int)aChan page:(int)aPage pageBuffer:(unsigned short*)aPageBuffer;
- (void) clear:(int)aChan page:(int)aPage value:(unsigned short)aValue;

- (unsigned long) eventCount:(int)aChannel;
- (void)		  clearEventCounts;
- (BOOL) bumpRateFromDecodeStage:(short)channel;

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Archival
- (id) initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
- (NSDictionary*) dataRecordDescription;
- (void) appendEventDictionary:(NSMutableDictionary*)anEventDictionary topLevel:(NSMutableDictionary*)topLevel;
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary;

#pragma mark ‚Ä¢‚Ä¢‚Ä¢Data Taker
- (void) fireRepeatedSoftwareTriggerInRun;
- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) takeData:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;

#pragma mark ‚Ä¢‚Ä¢‚Ä¢HW Wizard
- (int) numberOfChannels;
- (NSArray*) wizardParameters;
- (NSArray*) wizardSelections;
- (NSNumber*) extractParam:(NSString*)param from:(NSDictionary*)fileHeader forChannel:(int)aChannel;



@end

@interface OREdelweissFLTModel (tests)
- (void) runTests;
- (BOOL) testsRunning;
- (void) setTestsRunning:(BOOL)aTestsRunning;
- (NSMutableArray*) testEnabledArray;
- (void) setTestEnabledArray:(NSMutableArray*)aTestsEnabled;
- (NSMutableArray*) testStatusArray;
- (void) setTestStatusArray:(NSMutableArray*)aTestStatus;
- (NSString*) testStatus:(int)index;
- (BOOL) testEnabled:(int)index;

- (void) ramTest;
- (void) modeTest;
- (void) thresholdGainTest;
- (void) speedTest;
- (void) eventTest;
- (int) compareData:(unsigned short*) data
			pattern:(unsigned short*) pattern
			  shift:(int) shift
				  n:(int) n;
@end

extern NSString* OREdelweissFLTModelWriteToBBModeChanged;
extern NSString* OREdelweissFLTModelWCmdArg2Changed;
extern NSString* OREdelweissFLTModelWCmdArg1Changed;
extern NSString* OREdelweissFLTModelWCmdCodeChanged;
extern NSString* OREdelweissFLTModelAdcRtChanged;
extern NSString* OREdelweissFLTModelDacbChanged;
extern NSString* OREdelweissFLTModelSignbChanged;
extern NSString* OREdelweissFLTModelDacaChanged;
extern NSString* OREdelweissFLTModelSignaChanged;
extern NSString* OREdelweissFLTModelStatusBitsBBDataChanged;
extern NSString* OREdelweissFLTModelAdcRtForBBAccessChanged;
extern NSString* OREdelweissFLTModelAdcRgForBBAccessChanged;
extern NSString* OREdelweissFLTModelAdcValueForBBAccessChanged;
extern NSString* OREdelweissFLTModelAdcMultForBBAccessChanged;
extern NSString* OREdelweissFLTModelAdcFreqkHzForBBAccessChanged;
extern NSString* OREdelweissFLTFiber;
extern NSString* OREdelweissFLTIndex;
extern NSString* OREdelweissFLTModelUseBroadcastIdforBBAccessChanged;
extern NSString* OREdelweissFLTModelIdBBforBBAccessChanged;
extern NSString* OREdelweissFLTModelFiberSelectForBBAccessChanged;
extern NSString* OREdelweissFLTModelRelaisStatesBBChanged;
extern NSString* OREdelweissFLTModelFiberSelectForBBStatusBitsChanged;
extern NSString* OREdelweissFLTModelFiberOutMaskChanged;
extern NSString* OREdelweissFLTModelTpixChanged;
extern NSString* OREdelweissFLTModelSwTriggerIsRepeatingChanged;
extern NSString* OREdelweissFLTModelRepeatSWTriggerModeChanged;
extern NSString* OREdelweissFLTModelControlRegisterChanged;
extern NSString* OREdelweissFLTModelTotalTriggerNRegisterChanged;
extern NSString* OREdelweissFLTModelStatusRegisterChanged;
extern NSString* OREdelweissFLTModelFastWriteChanged;
extern NSString* OREdelweissFLTModelFiberDelaysChanged;
extern NSString* OREdelweissFLTModelStreamMaskChanged;
extern NSString* OREdelweissFLTModelSelectFiberTrigChanged;
extern NSString* OREdelweissFLTModelBBv1MaskChanged;
extern NSString* OREdelweissFLTModelFiberEnableMaskChanged;
extern NSString* OREdelweissFLTModelFltModeFlagsChanged;
extern NSString* OREdelweissFLTModelTargetRateChanged;
extern NSString* OREdelweissFLTModelStoreDataInRamChanged;
extern NSString* OREdelweissFLTModelFilterLengthChanged;
extern NSString* OREdelweissFLTModelGapLengthChanged;
extern NSString* OREdelweissFLTModelPostTriggerTimeChanged;
extern NSString* OREdelweissFLTModelFifoBehaviourChanged;
extern NSString* OREdelweissFLTModelAnalogOffsetChanged;
extern NSString* OREdelweissFLTModelLedOffChanged;
extern NSString* OREdelweissFLTModelInterruptMaskChanged;
extern NSString* OREdelweissFLTModelTestsRunningChanged;
extern NSString* OREdelweissFLTModelTestEnabledArrayChanged;
extern NSString* OREdelweissFLTModelTestStatusArrayChanged;
extern NSString* OREdelweissFLTModelHitRateChanged;
extern NSString* OREdelweissFLTModelHitRateLengthChanged;
extern NSString* OREdelweissFLTModelGainChanged;
extern NSString* OREdelweissFLTModelThresholdChanged;
extern NSString* OREdelweissFLTChan;
extern NSString* OREdelweissFLTModelGainsChanged;
extern NSString* OREdelweissFLTModelThresholdsChanged;
extern NSString* OREdelweissFLTModelModeChanged;
extern NSString* OREdelweissFLTSettingsLock;
extern NSString* OREdelweissFLTModelEventMaskChanged;
extern NSString* OREdelweissFLTNoiseFloorChanged;
extern NSString* OREdelweissFLTNoiseFloorOffsetChanged;

extern NSString* ORIpeSLTModelName;

extern NSString* OREdelweissFLTSelectedRegIndexChanged;
extern NSString* OREdelweissFLTWriteValueChanged;
extern NSString* OREdelweissFLTSelectedChannelValueChanged;
