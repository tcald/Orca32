//
//  ORIpeSlowControlDecoder.h
//  Orca
//
//  Created by Till Bergmann on 01/16/2009.
//  Copyright 2009 xxxx, University of xxxx. All rights reserved.
//-----------------------------------------------------------
//
//
//
//
//  TODO: Copyright etc. probably new since 2009? -tb-
//
//
//
//
//-------------------------------------------------------------




#import "ORIpeSlowControlDecoder.h"
#import "ORIpeSlowControlDefs.h"
#import "ORDataPacket.h"
#import "ORDataSet.h"

//parsing for decoders is in ORDataPacket -tb-


//DEBUGGING
#define    DebugMethCallsTB(x) x


#pragma mark •••Static Definitions




static NSString* kIpeAdeiObjectKey[32] = {
	//pre-make some keys for speed.
	@"IPE-ADEI  0", @"IPE-ADEI  1", @"IPE-ADEI  2", @"IPE-ADEI  3",
	@"IPE-ADEI  4", @"IPE-ADEI  5", @"IPE-ADEI  6", @"IPE-ADEI  7",
	@"IPE-ADEI  8", @"IPE-ADEI  9", @"IPE-ADEI 10", @"IPE-ADEI 11",
	@"IPE-ADEI 12", @"IPE-ADEI 13", @"IPE-ADEI 14", @"IPE-ADEI 15",
	@"IPE-ADEI 16", @"IPE-ADEI 17", @"IPE-ADEI 18", @"IPE-ADEI 19",
	@"IPE-ADEI 20", @"IPE-ADEI 21", @"IPE-ADEI 22", @"IPE-ADEI 23",
	@"IPE-ADEI 24", @"IPE-ADEI 25", @"IPE-ADEI 26", @"IPE-ADEI 27",
	@"IPE-ADEI 28", @"IPE-ADEI 29", @"IPE-ADEI 30", @"IPE-ADEI 31"
};



/** Base class for the ORIpeSlowControlModel decoders.
 */ //-tb-
@implementation ORIpeSlowControlDecoder

- (NSString*) getIpeSlowControlObjectKey:(unsigned short)aValue
{
	if(aValue<32) return kIpeAdeiObjectKey[aValue];
	else return [NSString stringWithFormat:@"IPE-ADEI %2d",aValue];		
	
}

//- (NSString*) getChannelKey:(unsigned short)aChan; //already defined in ORBaseDecoder -tb-

@end


/** Decoder for a ORIpeSlowControlModel channel data packet. 
 */ //-tb-
@implementation ORIpeSlowControlDecoderForChannelData   //TODO: work in progress ... -tb-

//-------------------------------------------------------------
/** Data format for ADEI channel data (first two words as cloase as possible at Orca standard):
  *
<pre>
xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
^^^^ ^^^^ ^^^^ ^^-----------------------data id
                 ^^ ^^^^ ^^^^ ^^^^ ^^^^-length in longs

xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
^^^^ ^^^--------------------------------spare
        ^ ^^^---------------------------adei object id
             ^ ^^^^---------------------spare
			        ^^^^ ^^^^ ----------channel
xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx dataRound
xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx dataDecimalPlaces
xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx timestampSec
xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx timestampSubSec
</pre>
    Orca identifies the type of binary data record by the header bytes.
    By this it finds this class (its selector is connected with its ID in
     - (NSDictionary*) dataRecordDescription
  */ //-tb- 2008-02-6
//-------------------------------------------------------------


- (unsigned long) decodeData:(void*)someData fromDataPacket:(ORDataPacket*)aDataPacket intoDataSet:(ORDataSet*)aDataSet
{
    DebugMethCallsTB(   NSLog(@"This is method: %@ of  %@. STILL UNDER DEVELOPMENT!\n",NSStringFromSelector(_cmd),  NSStringFromClass([self class]));  )


	ipeSlowControlChannelDataStruct* ePtr;

    unsigned long* ptr = (unsigned long*)someData;
	
	unsigned long length	= ExtractLength(*ptr);	 //get length from first word
	++ptr;										 
	
	//crate and channel from second word
	unsigned char adeiObj		= (*ptr>>21) & 0xf;
	//unsigned char card		= (*ptr>>16) & 0x1f;
	unsigned char chan		= (*ptr>>8) & 0xff;
	NSString* objectKey		= [self getIpeSlowControlObjectKey: adeiObj];
	//NSString* stationKey	= [self getStationKey: card];	
	NSString* channelKey	= [self getChannelKey: chan];	
	++ptr;	
	
	// Get the global data from the first event
    // ptr to event data
	ePtr = (ipeSlowControlChannelDataStruct*) ptr;			//recast to event structure

    //NSLog(@"Channel %08x - %8d %8d\n", ePtr->channelMap, ePtr->sec, ePtr->subSec);
    double  data = (double)(ePtr->dataRound) +  (0.000001) * ((double)ePtr->dataDecimalPlaces) ;
   NSLog(@"Receiving channel data for chan %d: (%d, %d, %f)\n",chan, ePtr->timestampSec, ePtr->timestampSubSec, data);

 
    #if 0
	[aDataSet histogram:ePtr->hitrate 
					  numBins:32768 
					  sender:self  
					  withKeys: @"IPE-ADEI",@"SensorHistogram",crateKey,stationKey,channelKey,nil];
    #endif

    #if 1
    // data formats are in ORDataSet.h/.m (histogram:,loadTimeSeries:,loadWaveform: etc) -tb- 2008-02-04
	[aDataSet loadTimeSeries: ePtr->dataRound
                      atTime: ePtr->timestampSec
					  sender:self  
					  withKeys: @"IPE-ADEI",@"SensorTimeSerie",objectKey,channelKey,nil];
    #endif

    return length; //must return number of longs processed.
}

- (NSString*) dataRecordDescription:(unsigned long*)ptr
{
    DebugMethCallsTB(   NSLog(@"This is method: %@ of  %@. STILL UNDER DEVELOPMENT!\n",NSStringFromSelector(_cmd),  NSStringFromClass([self class]));  )


    NSString* title= @"IPE ADEI SlowControlSensor Record\n\n";
	++ptr;		//skip the first word (dataID and length)
    
    NSString* objectKey = [NSString stringWithFormat:@"ADEI-ID    = %d\n",(*ptr>>21) & 0xf];
    //NSString* card  = [NSString stringWithFormat:@"Station    = %d\n",(*ptr>>16) & 0x1f];
    NSString* chan  = [NSString stringWithFormat:@"Channel    = %d\n",(*ptr>>8)  & 0xff];

	++ptr;		//point to event struct
	ipeSlowControlChannelDataStruct* ePtr = (ipeSlowControlChannelDataStruct*)ptr;			//recast to event structure
	
    double  data = (double)(ePtr->dataRound) +  (0.000001) * ((double)ePtr->dataDecimalPlaces) ;
	NSString* dataString    = [NSString stringWithFormat:@"Data     = %12.6f\n",data];

	NSCalendarDate* theDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:((NSTimeInterval)ePtr->timestampSec)-NSTimeIntervalSince1970];
    //NSTimeIntervalSince1970 is defined in NSDate.h (see NSDate, NSTimeInterval) - correction to unix time offset
	NSString* sampleDate     = [NSString stringWithFormat:@"Date       = %@\n", [theDate descriptionWithCalendarFormat:@"%m/%d/%y"]];
	NSString* sampleTime     = [NSString stringWithFormat:@"Time       = %@\n", [theDate descriptionWithCalendarFormat:@"%H:%M:%S"]];

	NSString* seconds		= [NSString stringWithFormat:@"Seconds    = %d\n", ePtr->timestampSec];
	NSString* subseconds		= [NSString stringWithFormat:@"SubSeconds = %d\n", ePtr->timestampSubSec];
		

    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",title,objectKey,chan,
	                    dataString,sampleDate,sampleTime,seconds,subseconds];               

}
@end


