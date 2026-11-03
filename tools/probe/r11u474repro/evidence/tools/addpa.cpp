// addpa <in> <out>: SIMULATION ONLY (the sister's ParamEmit face): in every interface_inst SFR_MASTER / SFR_MONITOR,
// the param_assign of ADDR_WIDTH / DATA_WIDTH takes golden's Rhs, a ref_obj SFR::sfr_<x>_width at the actual
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); int k=0;
 for(auto& kv: s.AllObjects()){ auto*o=(any*)kv.first; if(o->UhdmType()!=uhdminterface_inst) continue; auto*ii=(interface_inst*)o;
  std::string n(ii->VpiName()); int line= n=="SFR_MASTER"?56: n=="SFR_MONITOR"?65:0; if(!line||!ii->Param_assigns()) continue;
  for(auto*pa:*ii->Param_assigns()){ auto*l=pa->Lhs(); if(!l) continue; std::string ln(l->VpiName()); int dl= ln=="ADDR_WIDTH"?0: ln=="DATA_WIDTH"?1:-1; if(dl<0) continue;
   auto*r=s.MakeRef_obj(); r->VpiName(dl? "SFR::sfr_data_width":"SFR::sfr_addr_width"); r->VpiParent(pa); r->VpiLineNo(line+dl); r->VpiEndLineNo(line+dl); int c= line==56?30:31; r->VpiColumnNo(c); r->VpiEndColumnNo(c+5);
   r->VpiFile(ii->VpiFile()); r->VpiFullName(std::string(ii->VpiFullName())+"."+std::string(r->VpiName())); pa->Rhs(r); k++; }}
 std::cout<<"replaced "<<k<<"\n"; s.Save(std::filesystem::path(argv[2])); }
