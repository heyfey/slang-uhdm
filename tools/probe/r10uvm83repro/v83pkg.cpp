// v83 VERIFIER — MEASUREMENT-ONLY, independent. Package + design vector sizes.
//   usage: v83pkg <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
template<class V> static const char* sz(V* v,char*b){ if(!v){return "NULL";} snprintf(b,32,"%zu",v->size()); return b;}
int main(int argc,char** argv){
  Serializer s; s.Restore(std::string(argv[1]));
  char b[32];
  for(auto& kv:s.AllObjects()){
    const BaseClass* o=(const BaseClass*)kv.first; if(!o) continue;
    if(o->UhdmType()==uhdmdesign){
      const design* d=(const design*)o;
      printf("DESIGN AllPackages=%s TopPackages=%s ", sz(d->AllPackages(),b), sz(d->TopPackages(),b));
      printf("Typespecs=%s ", sz(d->Typespecs(),b));
      printf("Parameters=%s ", sz(d->Parameters(),b));
      printf("Param_assigns=%s ", sz(d->Param_assigns(),b));
      printf("Task_funcs=%s ", sz(d->Task_funcs(),b));
      printf("Let_decls=%s\n", sz(d->Let_decls(),b));
    }
    if(o->UhdmType()==uhdmpackage){
      const package* p=(const package*)o;
      printf("PKG %-12s top=%d Variables=%s ",std::string(p->VpiName()).c_str(),(int)p->VpiTop(),sz(p->Variables(),b));
      printf("Parameters=%s ",sz(p->Parameters(),b));
      printf("Param_assigns=%s ",sz(p->Param_assigns(),b));
      printf("Typespecs=%s ",sz(p->Typespecs(),b));
      printf("Class_defns=%s ",sz(p->Class_defns(),b));
      printf("Task_funcs=%s ",sz(p->Task_funcs(),b));
      printf("Nets=%s Scopes=%s Instance_items=%s\n",sz(p->Nets(),b),sz(p->Scopes(),b),sz(p->Instance_items(),b));
    }
  }
  return 0;
}
