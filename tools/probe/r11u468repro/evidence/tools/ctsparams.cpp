// ctsparams <db>...: law B predicate census on a database: class_typespec specialization pairs whose Lhs is the
// target class_defn's own formal while that class_defn's vpiParameter listing starts with imported entries.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static bool imported(const any* p, const class_defn* cd){
  if(p->VpiParent()!=cd) return true;
  if(p->UhdmType()==uhdmparameter) return !((parameter*)p)->VpiImported().empty();
  if(p->UhdmType()==uhdmtype_parameter) return !((type_parameter*)p)->VpiImported().empty();
  return false; }
int main(int argc,char**argv){
  for(int a=1;a<argc;a++){
    Serializer s; s.Restore(std::filesystem::path(argv[a])); int hits=0; std::string ex;
    for(auto& kv: s.AllObjects()){ auto*o=(BaseClass*)kv.first; if(o->UhdmType()!=uhdmclass_typespec) continue;
      auto*c=(class_typespec*)o; auto*cd=c->Class_defn(); if(!cd||!cd->Parameters()||!c->Param_assigns()) continue;
      auto& l=*cd->Parameters(); size_t n=0; while(n<l.size()&&l[n]&&imported(l[n],cd)) n++; if(n==0||n==l.size()) continue;
      for(auto*pa:*c->Param_assigns()){ if(!pa->Lhs()) continue; size_t pos=0; while(pos<l.size()&&l[pos]!=pa->Lhs()) pos++;
        if(pos<l.size()&&pos>=n&&l[pos-n]!=pa->Lhs()){ hits++; if(ex.empty()) ex=std::string(cd->VpiName())+"."+std::string(pa->Lhs()->VpiName())+"->"+std::string(l[pos-n]->VpiName()); } } }
    std::cout<<argv[a]<<" "<<hits<<" "<<ex<<"\n"; }
}
