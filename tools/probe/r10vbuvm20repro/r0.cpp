// R0 decode check: the io_decl (severity) singular slot.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
using namespace UHDM;
static std::string kd(const any* t){return t?std::string(UhdmName(t->UhdmType())):"NULL";}
int main(int argc,char**argv){
  Serializer s; if(s.Restore(std::string(argv[1])).empty()){std::cout<<"RESTORE_FAIL\n";return 3;}
  long nro=0, hit=0;
  for(auto&kv:s.AllObjects()){
    const any*o=kv.first; if(!o||o->UhdmType()!=uhdmref_obj)continue; nro++;
    const ref_obj* r=(const ref_obj*)o;
    if(r->VpiLineNo()!=30001) continue;
    hit++;
    const any* ag=r->Actual_group();
    std::cout<<"REFOBJ name="<<r->VpiName()<<" full="<<r->VpiFullName()
             <<" @"<<r->VpiLineNo()<<":"<<r->VpiColumnNo()
             <<" parent="<<kd(r->VpiParent())
             <<" actual="<<kd(ag)<<"("<<(ag?std::string(ag->VpiName()):std::string("-"))<<")\n";
  }
  std::cout<<"TOTAL ref_obj="<<nro<<" at-line-30001="<<hit<<"\n";
  return 0;
}
