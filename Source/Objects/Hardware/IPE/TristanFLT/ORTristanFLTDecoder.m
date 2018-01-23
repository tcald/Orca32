//
//  ORTristanFLTDecoder.m
//  Orca
//
//  Created by Mark Howe on 1/23/18.
//  Copyright 2018, University of North Carolina. All rights reserved.
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

#import "ORTristanFLTDecoder.h"
#import "ORTristanFLTModel.h"
#import "ORDataPacket.h"
#import "ORDataSet.h"

@implementation ORTristanFLTDecoderForTrace

//-------------------------------------------------------------
/** Data format for energy mode:
 xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
 ^^^^ ^^^^ ^^^^ ^^-----------------------data id
                  ^^ ^^^^ ^^^^ ^^^^ ^^^^-length in longs
 
 xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
 ^^^^ ^^^--------------------------------spare
		 ^ ^^^---------------------------crate
			  ^ ^^^^---------------------card
                     ^^^^ ^^^^-----------channel
                               ^^^^------gapLength
                                    ^^^^-shapingLength
 followed by n trace words to fill out the length
 */
//-------------------------------------------------------------
static NSString* kStationKey[32] = {
    //pre-make some keys for speed.
    @"Station  0", @"Station  1", @"Station  2", @"Station  3",
    @"Station  4", @"Station  5", @"Station  6", @"Station  7",
    @"Station  8", @"Station  9", @"Station 10", @"Station 11",
    @"Station 12", @"Station 13", @"Station 14", @"Station 15",
    @"Station 16", @"Station 17", @"Station 18", @"Station 19",
    @"Station 20", @"Station 21", @"Station 22", @"Station 23",
    @"Station 24", @"Station 25", @"Station 26", @"Station 27",
    @"Station 28", @"Station 29", @"Station 30", @"Station 31"
};


- (id) init
{
    self = [super init];
    getRatesFromDecodeStage = YES;
    return self;
}

- (void) dealloc
{
	[actualFlts release];
    [super dealloc];
}

- (NSString*) getStationKey:(unsigned short)aStation
{
    if(aStation<32) return kStationKey[aStation];
    else return [NSString stringWithFormat:@"Station %2d",aStation];
    
}

- (unsigned long) decodeData:(void*)someData fromDecoder:(ORDecoder*)aDecoder intoDataSet:(ORDataSet*)aDataSet;
{
    unsigned long* ptr = (unsigned long*)someData;
	unsigned long length	= ExtractLength(ptr[0]);								 
	unsigned char crate		= ShiftAndExtract(ptr[1],21,0x0f);
	unsigned char card		= ShiftAndExtract(ptr[1],16,0x1f);
	unsigned char chan		= ShiftAndExtract(ptr[1], 8,0xff);
	
	NSString* crateKey		= [self getCrateKey: crate];
	NSString* stationKey	= [self getStationKey: card];	
	//NSString* channelKey	= [self getChannelKey: chan];

    
    
	//get the actual object
	if(getRatesFromDecodeStage){
		NSString* fltKey          = [crateKey stringByAppendingString:stationKey];
		if(!actualFlts)actualFlts = [[NSMutableDictionary alloc] init];
		ORTristanFLTModel*   obj = [actualFlts objectForKey:fltKey];
		if(!obj){
			NSArray* listOfFlts = [[(ORAppDelegate*)[NSApp delegate] document] collectObjectsOfClass:NSClassFromString(@"ORTristanFLTModel")];
			for(ORTristanFLTModel* aFlt in listOfFlts){
				if(/*[aFlt crateNumber] == crate &&*/ [aFlt stationNumber] == card){
					[actualFlts setObject:aFlt forKey:fltKey];
					obj = aFlt;
					break;
				}
			}
		}
		if(getRatesFromDecodeStage)    getRatesFromDecodeStage     = [obj bumpRateFromDecodeStage:chan];
    }
	
    return length; //must return number of longs processed.
}

- (NSString*) dataRecordDescription:(unsigned long*)ptr
{
    NSString* title= @"TristanFLT Trace Record\n\n";
    NSString* crate = [NSString stringWithFormat:@"Crate      = %lu\n",ShiftAndExtract(ptr[1],21,0xf)];
    NSString* card  = [NSString stringWithFormat:@"Station    = %lu\n",ShiftAndExtract(ptr[1],16,0x1f)];
    NSString* chan  = [NSString stringWithFormat:@"Channel    = %lu\n",ShiftAndExtract(ptr[1],8,0xff)];
		
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",title,crate,card,chan];
    	
}

@end

