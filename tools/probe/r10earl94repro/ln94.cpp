// r10earl94 -- MEASUREMENT ONLY: every object at a given source LINE, with the
// fields the generated Compares read, its parent, and the enclosing instance.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  unsigned L=(unsigned)atoi(argv[2]);
  std::string instFilter = argc>3?argv[3]:"";
  std::vector<std::string> rows;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    if(bo->VpiLineNo()!=L) continue;
    std::string inst="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent())
      if(p->UhdmType()==uhdmmodule_inst){inst=std::string(((const module_inst*)p)->VpiFullName());break;}
    if(!instFilter.empty() && inst!=instFilter) continue;
    std::string extra;
    if(bo->UhdmType()==uhdmref_obj){const ref_obj*ro=(const ref_obj*)bo;
      extra="name="+std::string(ro->VpiName())+" ACT="+kn(ro->Actual_group())+"("+sp(ro->Actual_group())+")";}
    else if(bo->UhdmType()==uhdmconstant){const constant*c=(const constant*)bo;
      extra="val="+std::string(c->VpiValue())+" sz="+std::to_string(c->VpiSize())+" ct="+std::to_string(c->VpiConstType())+" dec="+std::string(c->VpiDecompile());}
    else if(bo->UhdmType()==uhdmoperation){const operation*o=(const operation*)bo;
      extra="optype="+std::to_string(o->VpiOpType())+" nops="+std::to_string(o->Operands()?o->Operands()->size():0);}
    else { const any*a=(const any*)bo; extra="name="+std::string(a->VpiName()); }
    char b[3072];
    snprintf(b,sizeof b,"%-22s span=%-18s parent=%-16s(%-18s) %s | n=%s",
      kn(bo).c_str(),sp(bo).c_str(),kn(bo->VpiParent()).c_str(),sp(bo->VpiParent()).c_str(),
      extra.c_str(), std::string(bo->VpiName()).c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&l:rows) printf("%s\n",l.c_str());
  return 0;
}
