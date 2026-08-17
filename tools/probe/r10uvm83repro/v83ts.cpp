// v83 VERIFIER instrument — MEASUREMENT-ONLY, INDEPENDENT of the pass's tools.
// For every unsupported_typespec in a database print:
//   name, span, and the vpiInstance ROLE (NULL / pkg:DEF / pkg:ELAB / <kind>).
// Also, for every ref_typespec whose Actual is an unsupported_typespec, the
// owning variable's fullname, so a cell can be read declaration by declaration.
//   usage: v83ts <db.uhdm> [--vars]
// build: g++ -O2 -std=c++17 v83ts.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o v83ts
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
using namespace UHDM;
static std::string role(const instance* t){
  if(!t) return "NULL";
  if(t->UhdmType()==uhdmpackage)
    return std::string(((const package*)t)->VpiTop()?"pkg:ELAB":"pkg:DEF")
           +"("+std::string(t->VpiName())+")";
  return std::string(UhdmName(t->UhdmType()))+"("+std::string(t->VpiName())+")";
}
int main(int argc,char** argv){
  bool vars=false;
  for(int i=2;i<argc;i++) if(!strcmp(argv[i],"--vars")) vars=true;
  Serializer s; s.Restore(std::string(argv[1]));
  auto all=s.AllObjects();
  std::map<std::string,int> tally;
  for(auto& kv:all){
    const BaseClass* o=(const BaseClass*)kv.first; if(!o) continue;
    if(o->UhdmType()!=uhdmunsupported_typespec) continue;
    const unsupported_typespec* u=(const unsupported_typespec*)o;
    char buf[512];
    snprintf(buf,sizeof buf,"TS\t%-34s %4u:%-3u-%4u:%-3u %s",
      std::string(u->VpiName()).c_str(),u->VpiLineNo(),(unsigned)u->VpiColumnNo(),
      u->VpiEndLineNo(),(unsigned)u->VpiEndColumnNo(),role(u->Instance()).c_str());
    tally[buf]++;
  }
  for(auto& kv:tally) printf("%s\tx%d\n",kv.first.c_str(),kv.second);
  if(vars){
    std::map<std::string,int> vt;
    for(auto& kv:all){
      const BaseClass* o=(const BaseClass*)kv.first; if(!o) continue;
      if(o->UhdmType()!=uhdmref_typespec) continue;
      const ref_typespec* r=(const ref_typespec*)o;
      const typespec* a=r->Actual_typespec();
      if(!a||a->UhdmType()!=uhdmunsupported_typespec) continue;
      const BaseClass* p=r->VpiParent();
      char buf[512];
      snprintf(buf,sizeof buf,"VAR\t%-46s %-16s -> %-26s %s",
        p?std::string(p->VpiName()).c_str():"<noparent>",
        p?std::string(UhdmName(p->UhdmType())).c_str():"-",
        std::string(a->VpiName()).c_str(),
        role(((const unsupported_typespec*)a)->Instance()).c_str());
      vt[buf]++;
    }
    for(auto& kv:vt) printf("%s\tx%d\n",kv.first.c_str(),kv.second);
  }
  return 0;
}
