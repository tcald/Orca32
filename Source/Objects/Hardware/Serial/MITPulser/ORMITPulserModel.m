//--------------------------------------------------------
// ORMITPulserModel
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

#import "ORMITPulserModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"

#pragma mark ***External Strings
NSString* ORMITPulserModelFrequencyChanged	= @"ORMITPulserModelFrequencyChanged";
NSString* ORMITPulserModelDutyCycleChanged	= @"ORMITPulserModelDutyCycleChanged";
NSString* ORMITPulserModelVoltageChanged	= @"ORMITPulserModelVoltageChanged";
NSString* ORMITPulserModelClockSpeedChanged = @"ORMITPulserModelClockSpeedChanged";
NSString* ORMITPulserModelSerialPortChanged = @"ORMITPulserModelSerialPortChanged";
NSString* ORMITPulserModelPortNameChanged   = @"ORMITPulserModelPortNameChanged";
NSString* ORMITPulserModelPortStateChanged  = @"ORMITPulserModelPortStateChanged";
NSString* ORMITPulserLock = @"ORMITPulserLock";

@interface ORMITPulserModel (private)
- (void) sendCommand:(NSString*)aCommand;
@end

@implementation ORMITPulserModel

- (void) dealloc
{
    [portName release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];
	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"MITPulser"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORMITPulserController"];
}

- (NSString*) helpURL
{
	return @"RS232/MITPulser.html";
}

#pragma mark ***Accessors

- (int) frequency
{
    return frequency;
}

- (void) setFrequency:(int)aFrequency
{
    [[[self undoManager] prepareWithInvocationTarget:self] setFrequency:frequency];
    frequency = aFrequency;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelFrequencyChanged object:self];
}

- (int) dutyCycle
{
    return dutyCycle;
}

- (void) setDutyCycle:(int)aDutyCycle
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDutyCycle:dutyCycle];
    dutyCycle = aDutyCycle;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelDutyCycleChanged object:self];
}

- (int) voltage
{
    return voltage;
}

- (void) setVoltage:(int)aVoltage
{
    [[[self undoManager] prepareWithInvocationTarget:self] setVoltage:voltage];
    
    voltage = aVoltage;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelVoltageChanged object:self];
}

- (int) clockSpeed
{
    return clockSpeed;
}

- (void) setClockSpeed:(int)aClockSpeed
{
    [[[self undoManager] prepareWithInvocationTarget:self] setClockSpeed:clockSpeed];
    clockSpeed = aClockSpeed;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelClockSpeedChanged object:self];
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                 }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
		[serialPort setSpeed:9600];
		[serialPort setParityOdd];
		[serialPort setStopBits2:1];
		[serialPort setDataBits:7];
        [serialPort open];
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMITPulserModelPortStateChanged object:self];
    
}


#pragma mark *** Commands
- (void) loadHardware
{
	[self sendCommand: [self clockSpeedCommand]];
	[self sendCommand: [self voltageCommand]];
	[self sendCommand: [self dutyCycleCommand]];
	[self sendCommand: [self frequencyCommand]];
}

- (NSString*) clockSpeedCommand
{
	//the clock speed is stored as the index of the popup. convert to the proper command here
	switch(clockSpeed){
		case 0:  return @""; //clock speed command for index 0
		case 1:  return @""; //clock speed command for index 1
		case 2:  return @""; //clock speed command for index 2
		//case n:  return @""; //clock speed command for index n
		default: return nil;
	}
}

- (NSString*) voltageCommand
{
	return @""; //format your voltage command as an NSString here
}

- (NSString*) dutyCycleCommand
{
	return @""; //format your duty cycle command as an NSString here
}

- (NSString*) frequencyCommand
{
	return @""; //format your frequency command as an NSString here
}

#pragma mark ***Archival
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    
    [[self undoManager] disableUndoRegistration];
    [self setFrequency:	[decoder decodeIntForKey:@"frequency"]];
    [self setDutyCycle:	[decoder decodeIntForKey:@"dutyCycle"]];
    [self setVoltage:	[decoder decodeIntForKey:@"voltage"]];
    [self setClockSpeed:[decoder decodeIntForKey:@"clockSpeed"]];
    [[self undoManager] enableUndoRegistration];    
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:frequency	forKey:@"frequency"];
    [encoder encodeInt:dutyCycle	forKey:@"dutyCycle"];
    [encoder encodeInt:voltage		forKey:@"voltage"];
    [encoder encodeInt:clockSpeed	forKey:@"clockSpeed"];
}
@end

@implementation ORMITPulserModel (private)
- (void) sendCommand:(NSString*)aCommand
{
	if(aCommand == nil)return;
	
	int i;
	for(i=0;i<[aCommand length];i++){
		NSString* partToSend = [NSString stringWithFormat:@"%@\n",[aCommand substringWithRange:NSMakeRange(i,1)]]; 
		//Joe you may have to use @"%@\r" instead....what every your device needs
		[serialPort writeString:partToSend];
		usleep(1000); //sleep 1 mSec
	}
}
@end