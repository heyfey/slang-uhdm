// r10earl95 -- MEASUREMENT ONLY.  Derived from r10earl94repro/ln94.cpp: every
// object at a source LINE (or LINE RANGE "a-b"), with the fields the generated
// Compares read, its parent, and its HOME -- the enclosing gen-scope chain and
// module instance, which is what separates a DEF cell from an ELAB one and one
// generate DEPTH from another.
// r10earl95 -- MEASUREMENT ONLY: every object at a given source LINE, with the
// fields the generated Compares read, its parent, the enclosing gen scope and
// the enclosing instance.  Derived from r10earl94repro/ln94.cpp.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  unsigned L=(unsigned)atoi(argv[2]); unsigned L2=L; {const char*d=strchr(argv[2],(int)0x2d); if(d) L2=(unsigned)atoi(d+1);}
  std::string kindFilter = argc>3?argv[3]:"";
  std::vector<std::string> rows;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    if(bo->VpiLineNo()<L||bo->VpiLineNo()>L2) continue;
    if(!kindFilter.empty() && kn(bo)!=kindFilter) continue;
    // HOME = the nearest named enclosing scope chain (gen scopes + instance)
    std::string home="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent()){
      auto t=p->UhdmType();
      if(t==uhdmmodule_inst){home=std::string(((const module_inst*)p)->VpiFullName())+"|"+home;break;}
      if(t==uhdmgen_scope||t==uhdmgen_scope_array)
        home=std::string(((const any*)p)->VpiName())+"@"+sp(p)+"|"+home;
    }
    std::string extra;
    if(bo->UhdmType()==uhdmref_obj){const ref_obj*ro=(const ref_obj*)bo;
      extra="name="+std::string(ro->VpiName())+" ACT="+kn(ro->Actual_group())+"("+sp(ro->Actual_group())+")";}
    else if(bo->UhdmType()==uhdmconstant){const constant*c=(const constant*)bo;
      extra="val="+std::string(c->VpiValue())+" sz="+std::to_string(c->VpiSize())+" ct="+std::to_string(c->VpiConstType())+" dec="+std::string(c->VpiDecompile());}
    else if(bo->UhdmType()==uhdmoperation){const operation*o=(const operation*)bo;
      extra="optype="+std::to_string(o->VpiOpType())+" nops="+std::to_string(o->Operands()?o->Operands()->size():0);}
    else { const any*a=(const any*)bo; extra="name="+std::string(a->VpiName()); }
    char b[4096];
    snprintf(b,sizeof b,"%-20s span=%-16s par=%-14s(%-16s) %-60s HOME=%s",
      kn(bo).c_str(),sp(bo).c_str(),kn(bo->VpiParent()).c_str(),sp(bo->VpiParent()).c_str(),
      extra.c_str(), home.c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&l:rows) printf("%s\n",l.c_str());
  return 0;
}
