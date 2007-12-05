//--------------------------------------------------------
// OReGunModel
// Created by Mark  A. Howe on Wed Nov 28, 2007
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

#import "OReGunModel.h"
#import "ORIP220Model.h"
#import "ORObjectProxy.h"

#pragma mark ***External Strings
NSString* OReGunModelOperationTypeChanged = @"OReGunModelOperationTypeChanged";
NSString* OReGunModelOverShootChanged = @"OReGunModelOverShootChanged";
NSString* OReGunModelDecayTimeChanged = @"OReGunModelDecayTimeChanged";
NSString* OReGunModelDecayRateChanged = @"OReGunModelDecayRateChanged";
NSString* OReGunModelExcursionChanged = @"OReGunModelExcursionChanged";
NSString* OReGunModelViewTypeChanged = @"OReGunModelViewTypeChanged";
NSString* OReGunModelVoltsPerMillimeterChanged = @"OReGunModelVoltsPerMillimeterChanged";
NSString* OReGunModelChanYChanged		= @"OReGunModelChanYChanged";
NSString* OReGunModelChanXChanged		= @"OReGunModelChanXChanged";
NSString* OReGunModelEndEditing			= @"OReGunModelEndEditing";
NSString* OReGunModelMovingChanged		= @"OReGunModelMovingChanged";
NSString* OReGunModelAbsMotionChanged	= @"OReGunModelAbsMotionChanged";
NSString* OReGunModelCmdPositionChanged	= @"OReGunModelCmdPositionChanged";
NSString* OReGunModelPositionChanged	= @"OReGunModelPositionChanged";
NSString* OReGunX220NameChanged			= @"OReGunX220NameChanged";
NSString* OReGunY220NameChanged			= @"OReGunY220NameChanged";
NSString* OReGunX220ObjectChanged		= @"OReGunX220ObjectChanged";
NSString* OReGunY220ObjectChanged		= @"OReGunY220ObjectChanged";

NSString* OReGunLock = @"OReGunLock";


@implementation OReGunModel
- (id) init
{
	self = [super init];
	x220Object = [[ORObjectProxy alloc] initWithProxyName:@"ORIP220Model" slotNotification:ORVmeCardSlotChangedNotification];
	y220Object = [[ORObjectProxy alloc] initWithProxyName:@"ORIP220Model" slotNotification:ORVmeCardSlotChangedNotification];
	return self;
}

- (void) dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[x220Object dealloc];
	[y220Object dealloc];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL) solitaryObject
{
    return YES;
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"eGun.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"OReGunController"];
}

- (ORObjectProxy*) x220Object
{
	return x220Object;
}

- (ORObjectProxy*) y220Object
{
	return y220Object;
}

#pragma mark ***Accessors

- (int) operationType
{
    return operationType;
}

- (void) setOperationType:(int)aOperationType
{
    [[[self undoManager] prepareWithInvocationTarget:self] setOperationType:operationType];
    
    operationType = aOperationType;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelOperationTypeChanged object:self];
}

- (float) overShoot
{
    return overShoot;
}

- (void) setOverShoot:(float)aOverShoot
{
    [[[self undoManager] prepareWithInvocationTarget:self] setOverShoot:overShoot];
    
    overShoot = aOverShoot;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelOverShootChanged object:self];
}

- (float) decayTime
{
    return decayTime;
}

- (void) setDecayTime:(float)aDecayTime
{
 	if(aDecayTime<=0.01)aDecayTime=0.01;
	else if(aDecayTime>1)aDecayTime = 1;
    [[[self undoManager] prepareWithInvocationTarget:self] setDecayTime:decayTime];
    
    decayTime = aDecayTime;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelDecayTimeChanged object:self];
}

- (float) decayRate
{
    return decayRate;
}

- (void) setDecayRate:(float)aDecayRate
{
 	if(aDecayRate<=1)aDecayRate=1;
	else if(aDecayRate>95)aDecayRate = 95;
   [[[self undoManager] prepareWithInvocationTarget:self] setDecayRate:decayRate];
    
    decayRate = aDecayRate;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelDecayRateChanged object:self];
}

- (float) excursion
{
    return excursion;
}

- (void) setExcursion:(float)aExcursion
{
	if(aExcursion<=1)aExcursion=1;
	else if(aExcursion>95)aExcursion = 95;
    [[[self undoManager] prepareWithInvocationTarget:self] setExcursion:excursion];
    
    excursion = aExcursion;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelExcursionChanged object:self];
}

- (int) viewType
{
    return viewType;
}

- (void) setViewType:(int)aViewType
{
    [[[self undoManager] prepareWithInvocationTarget:self] setViewType:viewType];
    
    viewType = aViewType;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelViewTypeChanged object:self];
}

- (float) voltsPerMillimeter
{
    return voltsPerMillimeter;
}

- (void) setVoltsPerMillimeter:(float)aVoltsPerMillimeter
{
	if(aVoltsPerMillimeter==0)aVoltsPerMillimeter = 0.075;
	else if(aVoltsPerMillimeter<.05)aVoltsPerMillimeter = 0.05;
	else if(aVoltsPerMillimeter>1.0)aVoltsPerMillimeter = 1.0;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setVoltsPerMillimeter:voltsPerMillimeter];
    
    voltsPerMillimeter = aVoltsPerMillimeter;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelVoltsPerMillimeterChanged object:self];
}

- (unsigned short) chanY
{
    return chanY;
}

- (void) setChanY:(unsigned short)aChanY
{
    [[[self undoManager] prepareWithInvocationTarget:self] setChanY:chanY];
	if(aChanY>15)aChanY=15;
    chanY = aChanY;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelChanYChanged object:self];
}

- (unsigned short) chanX
{
    return chanX;
}

- (void) setChanX:(unsigned short)aChanX
{
    [[[self undoManager] prepareWithInvocationTarget:self] setChanX:chanX];
    
	if(chanX>15)chanX=15;
    chanX = aChanX;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelChanXChanged object:self];
}

- (BOOL) moving
{
    return moving;
}

- (void) setMoving:(BOOL)aMoving
{
	NSLog(@"%d\n",aMoving);
    if(moving!=aMoving){
        moving = aMoving;
		if(!moving){
			NSLog(@"resetandNotify called\n");
			[self performSelector:@selector(resetTrackAndNotify) withObject:nil afterDelay:.3];
		}
        [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelMovingChanged object:self];
    }
}

- (unsigned)currentTrackIndex
{
    return currentTrackIndex;
}

- (unsigned)validTrackCount
{
    return validTrackCount;
}

- (NSPoint) track:(unsigned)i
{
    if(i<kNumTrackPoints)return track[i];
    else return NSZeroPoint;
}


- (BOOL) absMotion
{
    return absMotion;
}

- (void) setAbsMotion:(BOOL)aAbsMotion
{
    [[[self undoManager] prepareWithInvocationTarget:self] setAbsMotion:absMotion];
    
    absMotion = aAbsMotion;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelAbsMotionChanged object:self];
}

- (NSPoint) cmdPosition
{
    return cmdPosition;
}

- (void) setCmdPosition:(NSPoint)aCmdPosition
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCmdPosition:cmdPosition];
    
    cmdPosition = aCmdPosition;

    [[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelCmdPositionChanged object:self];
}


- (NSPoint) xyVoltage
{
	NSPoint xyVoltage;
	NS_DURING
		float x = 0;
		float y = 0;
		if([x220Object hwObject])x = [x220Object outputVoltage:chanX];
		if([y220Object hwObject])y = [y220Object outputVoltage:chanY];
		xyVoltage = NSMakePoint(x, y);
	NS_HANDLER
		xyVoltage = NSZeroPoint;
	NS_ENDHANDLER
    return xyVoltage;
}

- (void) updateTrack
{				
	track[currentTrackIndex] = [self xyVoltage];
	currentTrackIndex  = currentTrackIndex++;
	if(currentTrackIndex>=kNumTrackPoints)currentTrackIndex = 0;
	validTrackCount++;
	if(validTrackCount>kNumTrackPoints)validTrackCount= kNumTrackPoints;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelPositionChanged object:self];
}

#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setOperationType:[decoder decodeIntForKey:@"OReGunModelOperationType"]];
	[self setOverShoot:[decoder decodeFloatForKey:@"OReGunModelOverShoot"]];
	[self setDecayTime:[decoder decodeFloatForKey:@"OReGunModelDecayTime"]];
	[self setDecayRate:[decoder decodeFloatForKey:@"OReGunModelDecayRate"]];
	[self setExcursion:[decoder decodeFloatForKey:@"OReGunModelExcursion"]];
	[self setViewType:[decoder decodeIntForKey:@"OReGunModelViewType"]];
	[self setVoltsPerMillimeter:[decoder decodeFloatForKey:@"OReGunModelVoltsPerMillimeter"]];
	[self setChanY:[decoder decodeIntForKey:@"OReGunModelChanY"]];
	[self setChanX:[decoder decodeIntForKey:@"OReGunModelChanX"]];
	[self setAbsMotion:[decoder decodeBoolForKey:    @"OReGunModelAbsMotion"]];
	[self setCmdPosition:[decoder decodePointForKey: @"OReGunModelCmdPosition"]];
	x220Object = [[decoder decodeObjectForKey: @"x220Object"] retain];
	y220Object = [[decoder decodeObjectForKey: @"y220Object"] retain];
	[[self undoManager] enableUndoRegistration];

	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:operationType forKey:@"OReGunModelOperationType"];
    [encoder encodeFloat:overShoot forKey:@"OReGunModelOverShoot"];
    [encoder encodeFloat:decayTime forKey:@"OReGunModelDecayTime"];
    [encoder encodeFloat:decayRate forKey:@"OReGunModelDecayRate"];
    [encoder encodeFloat:excursion forKey:@"OReGunModelExcursion"];
    [encoder encodeInt:viewType forKey:@"OReGunModelViewType"];
    [encoder encodeFloat:voltsPerMillimeter forKey:@"OReGunModelVoltsPerMillimeter"];
    [encoder encodeInt:chanY forKey:@"OReGunModelChanY"];
    [encoder encodeInt:chanX forKey:@"OReGunModelChanX"];
    [encoder encodeObject:x220Object forKey:@"x220Object"];
    [encoder encodeObject:y220Object forKey:@"y220Object"];
	[encoder encodeBool:absMotion forKey:  @"OReGunModelAbsMotion"];
    [encoder encodePoint:cmdPosition forKey: @"OReGunModelCmdPosition"];
}

#pragma mark ***eGun Commands
- (void) getPosition
{
	NS_DURING
		[x220Object readBoard];
		if([x220Object hwObject] != [y220Object hwObject]){
			[y220Object readBoard];
		}
	NS_HANDLER
	NS_ENDHANDLER
	
}

- (void) stopMotion
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self setMoving:NO];
}

- (void) go
{
	[self resetTrack];
	if(absMotion) goalPosition = cmdPosition;
	else goalPosition = NSMakePoint([x220Object outputVoltage:chanX]+cmdPosition.x, [y220Object outputVoltage:chanY]+cmdPosition.x);
	[self moveToGoal];
}

- (void) moveToGoal
{
 	[self setMoving:YES];
	float delay; 
	if(operationType == 2){
		//overshoot
		float os = (1.0 * overShoot/100.);
		NSPoint currentPt	= NSMakePoint([x220Object outputVoltage:chanX],[y220Object outputVoltage:chanY]);
		NSPoint delta 		= NSMakePoint(goalPosition.x - currentPt.x,goalPosition.y - currentPt.y);
		NSPoint newPt		= NSMakePoint(goalPosition.x + delta.x*os,goalPosition.y + delta.y*os);
		[x220Object setOutputVoltage:chanX withValue:newPt.x];
		[y220Object setOutputVoltage:chanY withValue:newPt.y];
		delay = 1;
	}
	else {
		//wiggle
		[x220Object setOutputVoltage:chanX withValue:goalPosition.x];
		[y220Object setOutputVoltage:chanY withValue:goalPosition.y];
		delay = decayTime;
	}
	[self loadBoard];
	[self updateTrack];
	firstPoint = YES;
	
	if(operationType == 0)[self setMoving:NO];
	else [self performSelector:@selector(doMove) withObject:nil afterDelay:delay];
}

- (void) resetTrackAndNotify
{
	[self resetTrack];
	track[currentTrackIndex] = [self xyVoltage];
	currentTrackIndex  = currentTrackIndex++;
	validTrackCount++;
	[[NSNotificationCenter defaultCenter] postNotificationName:OReGunModelPositionChanged object:self];
}

- (void) resetTrack
{
    currentTrackIndex = 0;
    validTrackCount   = 0;
}

- (void) doMove
{
	//Note that all values are stored as raw values. Any conversion needed is done only for the display code.
	[[self undoManager] disableUndoRegistration];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if(operationType == 1){
		//wiggle
		if(firstPoint){
			NSPoint newPt		= NSMakePoint(goalPosition.x + [self excursion]*voltsPerMillimeter,goalPosition.y + [self excursion]*voltsPerMillimeter);
			[x220Object setOutputVoltage:chanX withValue:newPt.x];
			[y220Object setOutputVoltage:chanY withValue:newPt.y];
			firstPoint = NO;
			[self performSelector:@selector(doMove) withObject:nil afterDelay:[self decayTime]];
		}
		else {
			NSPoint currentPt	= NSMakePoint([x220Object outputVoltage:chanX],[y220Object outputVoltage:chanY]);
			NSPoint delta 		= NSMakePoint((goalPosition.x - currentPt.x)*[self decayRate]/100.,(goalPosition.y - currentPt.y)*[self decayRate]/100.);
			NSPoint newPt		= NSMakePoint(goalPosition.x + delta.x,goalPosition.y + delta.y);

			if(fabs(delta.x/voltsPerMillimeter) > .5){
				[x220Object setOutputVoltage:chanX withValue:newPt.x];
				[y220Object setOutputVoltage:chanY withValue:newPt.y];
				[self performSelector:@selector(doMove) withObject:nil afterDelay:[self decayTime]];
			}
			else {
				[x220Object setOutputVoltage:chanX withValue:goalPosition.x];
				[y220Object setOutputVoltage:chanY withValue:goalPosition.y];
				[self setMoving:NO];		
			}

		}
	}
	else {
		//overshoot
		[x220Object setOutputVoltage:chanX withValue:goalPosition.x];
		[y220Object setOutputVoltage:chanY withValue:goalPosition.y];
		[self setMoving:NO];		
	}
	
	[self updateTrack];
	[self loadBoard];
	
	[[self undoManager] enableUndoRegistration];
}

- (void) loadBoard
{
	NS_DURING
		[x220Object initBoard];
		if([x220Object hwObject] != [y220Object hwObject]){
			[y220Object initBoard];
		}
	NS_HANDLER
	NS_ENDHANDLER

}
@end
