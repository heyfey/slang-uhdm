// r10earl93 — R0 DECODE PROBE 2 (MEASUREMENT ONLY): every ref_obj with a given
// VpiName, its span, its Actual_group kind and the instance it lives in.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::string want=argv[2];
  std::vector<std::string> rows;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo||bo->UhdmType()!=uhdmref_obj) continue;
    const ref_obj*ro=(const ref_obj*)bo;
    if(std::string(ro->VpiName())!=want) continue;
    std::string inst="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent())
      if(p->UhdmType()==uhdmmodule_inst){inst=std::string(((const module_inst*)p)->VpiFullName());break;}
    char b[2048];
    snprintf(b,sizeof b,"REF %-16s span=%-16s parent=%-14s(%s) ACTUAL=%-14s(%s) inst=%s fn=%s",
      want.c_str(),sp(bo).c_str(),kn(bo->VpiParent()).c_str(),sp(bo->VpiParent()).c_str(),
      kn(ro->Actual_group()).c_str(),sp(ro->Actual_group()).c_str(),inst.c_str(),
      std::string(ro->VpiFullName()).c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&l:rows) printf("%s\n",l.c_str());
  return 0;
}
