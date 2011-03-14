#ifndef _ORCAEN1724Readout_hh_
#define _ORCAEN1724Readout_hh_
#include "ORVVmeCard.hh"
#include <iostream>

class ORCAEN1724Readout : public ORVVmeCard
{
  public:
    ORCAEN1724Readout(SBC_card_info* ci) : ORVVmeCard(ci) {} 
    virtual ~ORCAEN1724Readout() {} 
    virtual bool Readout(SBC_LAM_Data*);
};

#endif /* _ORCAEN1724Readout_hh_*/
