//--------------------------------------------------------
// ORCC4189Model
// Created by Mark  A. Howe on Fri Jul 22 2005
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

@class ORSerialPort;
@class ORTimeRate;

@interface ORCC4189Model : OrcaObject
{
    @private
        NSString*       portName;
        BOOL            portWasOpen;
        ORSerialPort*   serialPort;
        unsigned long	dataId;
		NSString*		lastRequest;
		NSMutableArray* cmdQueue;
		float		    current;
		unsigned long	timeMeasured;
		int				pollTime;
        NSMutableString*       buffer;
		BOOL			shipCurrent;
		ORTimeRate*		timeRate;
}

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;

- (void) registerNotificationObservers;
- (void) dataReceived:(NSNotification*)note;

#pragma mark ***Accessors
- (ORTimeRate*)timeRate;
- (BOOL) shipCurrent;
- (void) setShipCurrent:(BOOL)aFlag;
- (int) pollTime;
- (void) setPollTime:(int)aPollTime;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (NSString*) lastRequest;
- (void) setLastRequest:(NSString*)aRequest;
- (void) openPort:(BOOL)state;
- (float) current;
- (unsigned long) timeMeasured;
- (void) setCurrent:(float)aValue;

#pragma mark ***Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherCC4189;

- (void) shipCurrentValue;

#pragma mark ***Commands
- (void) addCmdToQueue:(NSString*)aCmd;
- (void) readCurrent;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

@end


extern NSString* ORCC4189ModelShipCurrentChanged;
extern NSString* ORCC4189ModelPollTimeChanged;
extern NSString* ORCC4189ModelSerialPortChanged;
extern NSString* ORCC4189Lock;
extern NSString* ORCC4189ModelPortNameChanged;
extern NSString* ORCC4189ModelPortStateChanged;
extern NSString* ORCC4189CurrentChanged;
