// chain2 <golden> <ours> [seeds]: failing pair; visited ref_typespecs whose actual is the failing object, with parent chains
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
using namespace UHDM;
static void ch(const BaseClass* o){ for(int d=0;o&&d<9;d++,o=o->VpiParent()) std::cout<<"    "<<UhdmName(o->UhdmType())<<" "<<o->VpiName()<<" L"<<o->VpiLineNo()<<":"<<o->VpiColumnNo()<<" id"<<o->UhdmId()<<"\n"; }
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  CompareContext c; int r=da->Compare(db,&c); if(!r){std::cout<<"EQUAL\n";return 0;}
  for(int side=0;side<2;side++){ const BaseClass* f= side?c.m_failedRhs:c.m_failedLhs; std::cout<<(side?"OURS\n":"GOLDEN\n"); ch(f);
    for(auto*o:c.m_visited){ if(o->UhdmType()==uhdmref_typespec && ((const ref_typespec*)o)->Actual_typespec()==f){ std::cout<<"  referrer:\n"; ch(o);} } }
}
