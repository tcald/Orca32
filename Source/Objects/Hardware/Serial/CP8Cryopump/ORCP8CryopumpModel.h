//--------------------------------------------------------
// ORCP8CryopumpModel
// Created by Mark Howe Tuesday, March 20,2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012, University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files
#import "ORBitProcessing.h"
#import "ORSerialPortWithQueueModel.h"

@class ORTimeRate;

@interface ORCP8CryopumpModel : ORSerialPortWithQueueModel <ORBitProcessing>
{
    @private
        unsigned long		dataId;
	
		float				temperature;
		unsigned long		timeMeasured;
		int					pollTime;
        NSMutableString*    buffer;
		BOOL				shipTemperatures;
		ORTimeRate*			timeRates[2];
		int					dutyCycle;
		int					elapsedTime;
		int					failedRateRiseCycles;
		int					failedRepurgeCycles;
		float				firstStageTemp;
		int					firstStageControlTemp;
		int					firstStageControlMethod;
		int					lastRateOfRaise;
		NSString*			moduleVersion;
		int					powerFailureRecovery;
		int					powerFailureRecoveryStatus;
		int					pumpStatus;
		int					purgeStatus;
		int					regenerationCycles;
		int					regenerationError;
		char				regenerationSequence;
		int					regenerationStartDelay;
		int					regenerationStepTimer;
		int					regenerationTime;
		int					roughValveStatus;
		int					roughValveInterlock;
		float				secondStageTemp;
		int					status;
		int					thermocoupleStatus;
		float				thermocouplePressure;
		int					pumpRestartDelay;
		int					extendedPurgeTime;
		int					repurgeCycles;
		int					roughToPressure;
		int					rateOfRise;
		int					rateOfRiseCycles;
		int					restartTemperature;
		int					roughingInterlockStatus;
		int					pumpsPerCompressor;
		int					repurgeTime;
		BOOL				standbyMode;
		BOOL				roughingInterlock;
		int					secondStageTempControl;
        int                 cmdError;
        BOOL                wasPowerFailure;
        BOOL                delay;
		int					firstStageControlMethodRB;
		NSMutableDictionary* pumpOnConstraints;
		NSMutableDictionary* pumpOffConstraints;
		NSMutableDictionary* purgeOpenConstraints;
		NSMutableDictionary* roughingOpenConstraints;
        BOOL                constraintsDisabled;
}


#pragma mark •••Initialization
- (void) dealloc;
- (void) dataReceived:(NSNotification*)note;

#pragma mark •••Accessors
- (int)		firstStageControlMethodRB;
- (void)	setFirstStageControlMethodRB:(int)aFirstStageControlMethodRB;
- (NSString*) firstStageControlMethodString;
- (BOOL)    wasPowerFailure;
- (void)    setWasPowerFailure:(BOOL)aState;
- (int)     cmdError;
- (void)    incrementCmdError;
- (int)		secondStageTempControl;
- (void)	setSecondStageTempControl:(int)aSecondStageTempControl;
- (BOOL)	roughingInterlock;
- (void)	setRoughingInterlock:(BOOL)aRoughingInterlock;
- (BOOL)	standbyMode;
- (void)	setStandbyMode:(BOOL)aStandbyMode;
- (int)		repurgeTime;
- (void)	setRepurgeTime:(int)aRepurgeTime;
- (int)		pumpsPerCompressor;
- (void)	setPumpsPerCompressor:(int)aPumpsPerCompressor;
- (int)		pumpsPerCompressor;
- (void)	setPumpsPerCompressor:(int)aPumpsPerCompressor;
- (int)		roughingInterlockStatus;
- (void)	setRoughingInterlockStatus:(int)aRoughingInterlock;
- (int)		restartTemperature;
- (void)	setRestartTemperature:(int)aRestartTemperature;
- (int)		rateOfRiseCycles;
- (void)	setRateOfRiseCycles:(int)aRateOfRiseCycles;
- (int)		rateOfRise;
- (void)	setRateOfRise:(int)aRateOfRise;
- (int)		roughToPressure;
- (void)	setRoughToPressure:(int)aRoughToPressure;
- (int)		repurgeCycles;
- (void)	setRepurgeCycles:(int)aRepurgeCycles;
- (int)		extendedPurgeTime;
- (void)	setExtendedPurgeTime:(int)aExtendedPurgeTime;
- (int)		pumpRestartDelay;
- (void)	setPumpRestartDelay:(int)aPumpRestartDelay;
- (float)	thermocouplePressure;
- (void)	setThermocouplePressure:(float)aThermocouplePressure;
- (int)		thermocoupleStatus;
- (void)	setThermocoupleStatus:(int)aThermocoupleStatus;
- (int)		status;
- (void)	setStatus:(int)aStatus;
- (float)	secondStageTemp;
- (void)	setSecondStageTemp:(float)aSecondStageTemp;
- (int)		roughValveInterlock;
- (void)	setRoughValveInterlock:(int)aRoughValveInterlock;
- (int)		roughValveStatus;
- (void)	setRoughValveStatus:(int)aRoughValveStatus;
- (int)		regenerationTime;
- (void)	setRegenerationTime:(int)aRegenerationTime;
- (int)		regenerationStepTimer;
- (void)	setRegenerationStepTimer:(int)aRegenerationStepTimer;
- (int)		regenerationStartDelay;
- (void)	setRegenerationStartDelay:(int)aRegenerationStartDelay;
- (int)		regenerationSequence;
- (void)	setRegenerationSequence:(int)aRegenerationSequence;
- (int)		regenerationError;
- (void)	setRegenerationError:(int)aRegenerationError;
- (int)		regenerationCycles;
- (void)	setRegenerationCycles:(int)aRegenerationCycles;
- (int)		purgeStatus;
- (void)	setPurgeStatus:(int)aPurgeStatus;
- (int)		pumpStatus;
- (void)	setPumpStatus:(int)aPumpStatus;
- (int)		powerFailureRecoveryStatus;
- (void)	setPowerFailureRecoveryStatus:(int)aPowerFailureRecoveryStatus;
- (int)		powerFailureRecovery;
- (void)	setPowerFailureRecovery:(int)aPowerFailureRecovery;
- (NSString*) moduleVersion;
- (void)	setModuleVersion:(NSString*)aModuleVersion;
- (int)		lastRateOfRaise;
- (void)	setLastRateOfRaise:(int)aLastRateOfRaise;
- (int)		firstStageControlMethod;
- (void)	setFirstStageControlMethod:(int)aFirstStageControlMethod;
- (int)		firstStageControlTemp;
- (void)	setFirstStageControlTemp:(int)aFirstStageControlTemp;
- (float)	firstStageTemp;
- (void)	setFirstStageTemp:(float)aFirstStageTemp;
- (int)		failedRepurgeCycles;
- (void)	setFailedRepurgeCycles:(int)aFailedRepurgeCycles;
- (int)		failedRateRiseCycles;
- (void)	setFailedRateRiseCycles:(int)aFailedRateRiseCycles;
- (int)		elapsedTime;
- (void)	setElapsedTime:(int)aElapsedTime;
- (int)		dutyCycle;
- (void)	setDutyCycle:(int)aDutyCycle;
- (ORTimeRate*)timeRate:(int)index;
- (BOOL)	shipTemperatures;
- (void)	setShipTemperatures:(BOOL)aShipPressures;
- (int)		pollTime;
- (void)	setPollTime:(int)aPollTime;
- (float) temperature;
- (unsigned long) timeMeasured;
- (NSString*) auxStatusString:(int)aChannel;

#pragma mark •••Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherCP8Cryopump;
- (void) shipTemperatureValues;
- (void) addCmdToQueue:(NSString *)aCmd;
- (void) addCmdToQueue:(NSString*)aCmd waitForResponse:(BOOL)waitForResponse;

#pragma mark •••Commands
- (void) readTemperatures;
- (void) pollHardware;
- (void) initHardware;

#pragma mark •••Queries
- (void) readAllHardware;
- (void) readDutyCycle;
- (void) readElapsedTime;
- (void) readFailedRateRiseCycles;
- (void) readFailedPurgeCycles;
- (void) readFirstStageTemp;
- (void) readFirstStageControlTemp;
- (void) readLastRateOfRaise;
- (void) readModuleVersion;
- (void) readPowerFailureRecoveryStatus;
- (void) readPumpStatus;
- (void) readPurgeStatus;
- (void) readRegenerationCycles;
- (void) readRegenerationError;
- (void) readRegenerationSequence;
- (void) readRegenerationStartDelay;
- (void) readRegenerationStepTimer;
- (void) readRegenerationTime;
- (void) readRoughValveStatus;
- (void) readRoughValveInterlock;
- (void) readSecondStageTemp;
- (void) readSecondStageTempControl;
- (void) readStatus;
- (void) readThermocoupleStatus;
- (void) readThermocouplePressure;

#pragma mark •••HW Writes
- (void) writeFirstStageTempControl;
- (void) writePowerFailureRecoveryMode;
- (void) writeCryoPumpOn:(BOOL)aState;
- (void) writePurgeValveOpen:(BOOL)aState;
- (void) writeRoughValveOpen:(BOOL)aState;
- (void) writeThermocoupleOn:(BOOL)aState;
- (void) writeRegenerationCycleParameters;
- (void) writeRegenerationStartDelay:(int)aDelay;
- (void) writeRoughValveInterlockPermissionYes;
- (void) writeSecondStageControlTemp:(int)aTemp;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

#pragma mark •••Adc Processing Protocol
- (void) processIsStarting;
- (void) processIsStopping; 
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (void) setOutputBit:(int)channel value:(BOOL)value;
- (NSString*) processingTitle;

#pragma mark •••Constraints
- (void) addPumpOnConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removePumpOnConstraint:(NSString*)aName;
- (void) addPumpOffConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removePumpOffConstraint:(NSString*)aName;
- (void) addPurgeConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removePurgeConstraint:(NSString*)aName;
- (void) addRoughingConstraint:(NSString*)aName reason:(NSString*)aReason;
- (void) removeRoughingConstraint:(NSString*)aName;
- (NSDictionary*)pumpOnConstraints;
- (NSDictionary*)pumpOffConstraints;
- (NSDictionary*)purgeOpenConstraints;
- (NSDictionary*)roughingOpenConstraints;
- (void) disableConstraints;
- (void) enableConstraints;
- (BOOL) constraintsDisabled;

- (NSString*) pumpOnOffConstraintReport;
- (NSString*) purgeOpenConstraintReport;
- (NSString*) roughingOpenConstraintReport;

@end

@interface ORCP8CryopumpCmd : NSObject
{
	BOOL waitForResponse;
	NSString* cmd;
}

@property (nonatomic,assign) BOOL waitForResponse;
@property (nonatomic,copy) NSString* cmd;
@end

extern NSString* ORCP8CryopumpModelFirstStageControlMethodRBChanged;
extern NSString* ORCP8CryopumpModelSecondStageTempControlChanged;
extern NSString* ORCP8CryopumpModelRoughingInterlockChanged;
extern NSString* ORCP8CryopumpModelStandbyModeChanged;
extern NSString* ORCP8CryopumpModelRepurgeTimeChanged;
extern NSString* ORCP8CryopumpModelPumpsPerCompressorChanged;
extern NSString* ORCP8CryopumpModelRoughingInterlockStatusChanged;
extern NSString* ORCP8CryopumpModelRestartTemperatureChanged;
extern NSString* ORCP8CryopumpModelRateOfRiseCyclesChanged;
extern NSString* ORCP8CryopumpModelRateOfRiseChanged;
extern NSString* ORCP8CryopumpModelRoughToPressureChanged;
extern NSString* ORCP8CryopumpModelRepurgeCyclesChanged;
extern NSString* ORCP8CryopumpModelExtendedPurgeTimeChanged;
extern NSString* ORCP8CryopumpModelPumpRestartDelayChanged;
extern NSString* ORCP8CryopumpModelThermocouplePressureChanged;
extern NSString* ORCP8CryopumpModelThermocoupleStatusChanged;
extern NSString* ORCP8CryopumpModelStatusChanged;
extern NSString* ORCP8CryopumpModelSecondStageTempChanged;
extern NSString* ORCP8CryopumpModelRoughValveInterlockChanged;
extern NSString* ORCP8CryopumpModelRoughValveStatusChanged;
extern NSString* ORCP8CryopumpModelRegenerationTimeChanged;
extern NSString* ORCP8CryopumpModelRegenerationStepTimerChanged;
extern NSString* ORCP8CryopumpModelRegenerationStartDelayChanged;
extern NSString* ORCP8CryopumpModelRegenerationSequenceChanged;
extern NSString* ORCP8CryopumpModelRegenerationErrorChanged;
extern NSString* ORCP8CryopumpModelRegenerationCyclesChanged;
extern NSString* ORCP8CryopumpModelRegenerationChanged;
extern NSString* ORCP8CryopumpModelPurgeStatusChanged;
extern NSString* ORCP8CryopumpModelPumpStatusChanged;
extern NSString* ORCP8CryopumpModelPowerFailureRecoveryStatusChanged;
extern NSString* ORCP8CryopumpModelPowerFailureRecoveryChanged;
extern NSString* ORCP8CryopumpModelModuleVersionChanged;
extern NSString* ORCP8CryopumpModelLastRateOfRaiseChanged;
extern NSString* ORCP8CryopumpModelFirstStageControlMethodChanged;
extern NSString* ORCP8CryopumpModelFirstStageControlTempChanged;
extern NSString* ORCP8CryopumpModelFirstStageTempChanged;
extern NSString* ORCP8CryopumpModelFailedRepurgeCyclesChanged;
extern NSString* ORCP8CryopumpModelFailedRateRiseCyclesChanged;
extern NSString* ORCP8CryopumpModelElapsedTimeChanged;
extern NSString* ORCP8CryopumpModelDutyCycleChanged;
extern NSString* ORCP8CryopumpShipTemperaturesChanged;
extern NSString* ORCP8CryopumpPollTimeChanged;
extern NSString* ORCP8CryopumpLock;
extern NSString* ORCP8CryopumpModelCmdErrorChanged;
extern NSString* ORCP8CryopumpModelWasPowerFailireChanged;
extern NSString* ORCP8CryopumpModelConstraintsChanged;
extern NSString* ORCP8CryopumpConstraintsDisabledChanged;
