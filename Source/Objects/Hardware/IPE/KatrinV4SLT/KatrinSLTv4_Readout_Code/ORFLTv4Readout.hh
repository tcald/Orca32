#ifndef _ORFLTv4Readout_hh_
#define _ORFLTv4Readout_hh_
#include "ORVCard.hh"
#include <iostream>


/** For every card in the Orca configuration one instance of ORFLTv4Readout is constructed.
  *
  * Short firmware history (Firmware is CFPGA,FPGA8=X.X.X.X,X.X.X.X version):
  * - 2.1.2.0., 2.1.2.4: try to fix100 nsce shaping tome - firmware still buggy (reinvented k-offset bug)
  * - 2.1.2.0., 2.1.2.3: fixed HW histogram readout bug ('Monitor Spectrometer problem')
  * ...
  * - 2.1.1.4., 2.1.2.1: Filter redesign (timing problems), k-offset of energy fixed, FIFO redesign, 6+SUM channel veto
  * - 2.1.1.1., 2.1.1.1 and smaller: first version(s)
  *
  * NOTE: UPDATE 'kCodeVersion': After all major changes in HW_Readout.cc, FLTv4Readout.cc, FLTv4Readout.hh, SLTv4Readout.cc, SLTv4Readout.hh
  * 'kCodeVersion' in HW_Readout.cc should be increased!
  *
  *
  */ //-tb-
class ORFLTv4Readout : public ORVCard
{
  public:
    ORFLTv4Readout(SBC_card_info* ci) : ORVCard(ci) {} 
    virtual ~ORFLTv4Readout() {} 
    virtual bool Start();
    virtual bool Readout(SBC_LAM_Data*);
    virtual bool Stop();
	void ClearSumHistogramBuffer();

    /** Readout in energy mode with firmware 3.1  */
    bool ReadoutEnergyV31(SBC_LAM_Data*);
    
    /** Readout in trace mode with firmware 3.1  */
    bool ReadoutTraceV31(SBC_LAM_Data*);

    /** Readout in histogram mode with firmware 3.1  */
    bool ReadoutHistogramV31(SBC_LAM_Data*);

    /** Readout functions for older firmware versions */
    bool ReadoutLegacy(SBC_LAM_Data*);
    
    // Helper variables for histogram mode
    
    /** Get the number of total counts in a histogram */
    unsigned long long Counts(uint32_t *histogram);
    
    enum EORFLTv4Consts {
        kFifoEmpty          = 0x01,
        kNumChan            = 24,
        kNumFLTs            = 20,
		kMaxHistoLength     = 2048
    };
    bool firstTime;
    uint32_t pageAB;
    uint32_t oldPageAB;
	uint32_t sumHistogram[kNumChan][kMaxHistoLength];
	uint32_t recordingTimeSum[kNumChan];
    
    uint32_t histoBinWidth;
    uint32_t histoEnergyOffset;
    uint32_t histoClearByUser;
    uint32_t histoRefreshTime;
    uint32_t histoReadoutSec;
    
    uint32_t histoStorage[kNumChan][kMaxHistoLength];
    uint32_t histoCurrent[kMaxHistoLength];
    
    uint32_t runEndSec;
    
};

#endif /* _ORFLTv4Readout_hh_*/
