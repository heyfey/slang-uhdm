// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
// Prints, for every package reachable from design::AllPackages / TopPackages,
// the state of EVERY vector field package::Compare walks, IN COMPARE ORDER
// (scope -> instance -> package), distinguishing NULL from EMPTY from a count.
// A `package|<rhs-null>|MISSING-OURS` head is exactly "golden non-empty, ours NULL"
// on one of these lines, so the two listings side by side name the field.
//
//   usage: ct83pkg <db.uhdm> [--list <VECNAME>] [--pkg <name>]
//
// build: g++ -O2 -std=c++17 ct83pkg.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83pkg
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string loc(const BaseClass* o){
  char b[256];
  snprintf(b,sizeof b,"%s:%u:%u-%u:%u",base(o->VpiFile()).c_str(),o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());
  return b;
}
template<typename T>
static void slot(const char* nm,const std::vector<T*>* v,const char* want,const char* pkg){
  if(!want) { printf("VEC %-24s %s\n", nm, v? ("n="+std::to_string(v->size())).c_str() : "NULL"); return; }
  if(strcmp(nm,want)) return;
  if(!v){ printf("LIST %s %s NULL\n",pkg,nm); return; }
  size_t i=0;
  for(auto* e:*v){
    const BaseClass* o=e;
    printf("E\t%zu\t%s\t%s\t%s\t#%u\n", i++, o?std::string(UhdmName(o->UhdmType())).c_str():"<null>",
           o?std::string(o->VpiName()).c_str():"-", o?loc(o).c_str():"-", o?o->UhdmId():0u);
  }
}
int main(int argc,char** argv){
  const char* want=nullptr; const char* onlypkg=nullptr;
  for(int i=2;i<argc;i++){
    if(!strcmp(argv[i],"--list")&&i+1<argc) want=argv[++i];
    else if(!strcmp(argv[i],"--pkg")&&i+1<argc) onlypkg=argv[++i];
  }
  Serializer s; auto restored=s.Restore(std::string(argv[1]));
  design* d=nullptr;
  for(auto h:restored){auto* o=(const BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) d=(design*)o;}
  if(!d){printf("NO_DESIGN\n");return 2;}
  struct Ent{const package* p;const char* via;};
  std::vector<Ent> pk;
  if(auto* v=d->AllPackages()) for(auto* p:*v) pk.push_back({p,"AllPackages"});
  if(auto* v=d->TopPackages()) for(auto* p:*v) pk.push_back({p,"TopPackages"});
  printf("DESIGN %s AllPackages=%zu TopPackages=%zu\n",std::string(d->VpiName()).c_str(),
         d->AllPackages()?d->AllPackages()->size():0, d->TopPackages()?d->TopPackages()->size():0);
  for(auto& e:pk){
    const package* p=e.p;
    std::string nm(p->VpiName());
    if(onlypkg && nm!=onlypkg) continue;
    if(!want) printf("== PKG %s via %s #%u @%s\n",nm.c_str(),e.via,p->UhdmId(),loc(p).c_str());
    else      printf("== PKG %s via %s #%u @%s  LIST=%s\n",nm.c_str(),e.via,p->UhdmId(),loc(p).c_str(),want);
    const char* w=want; const char* pn=nm.c_str();
    // scope::Compare order
    slot("Property_decls",p->Property_decls(),w,pn);
    slot("Sequence_decls",p->Sequence_decls(),w,pn);
    slot("Concurrent_assertions",p->Concurrent_assertions(),w,pn);
    slot("Named_events",p->Named_events(),w,pn);
    slot("Named_event_arrays",p->Named_event_arrays(),w,pn);
    slot("Variables",p->Variables(),w,pn);
    slot("Virtual_interface_vars",p->Virtual_interface_vars(),w,pn);
    slot("Logic_vars",p->Logic_vars(),w,pn);
    slot("Array_vars",p->Array_vars(),w,pn);
    slot("Array_var_mems",p->Array_var_mems(),w,pn);
    slot("Parameters",p->Parameters(),w,pn);
    slot("Param_assigns",p->Param_assigns(),w,pn);
    slot("Scopes",p->Scopes(),w,pn);
    slot("Typespecs",p->Typespecs(),w,pn);
    slot("Instance_items",p->Instance_items(),w,pn);
    slot("Let_decls",p->Let_decls(),w,pn);
    slot("Attributes",p->Attributes(),w,pn);
    // instance::Compare order
    slot("Programs",p->Programs(),w,pn);
    slot("Program_arrays",p->Program_arrays(),w,pn);
    slot("Class_defns",p->Class_defns(),w,pn);
    slot("Task_funcs",p->Task_funcs(),w,pn);
    slot("Nets",p->Nets(),w,pn);
    slot("Array_nets",p->Array_nets(),w,pn);
    slot("Spec_params",p->Spec_params(),w,pn);
    slot("Assertions",p->Assertions(),w,pn);
    if(!want){
      printf("SING %-24s %s\n","Module_inst",p->Module_inst()?"set":"NULL");
      printf("SING %-24s %s\n","Instance",p->Instance()?"set":"NULL");
      printf("SCA VpiName=%s VpiDefName=%s VpiTop=%d VpiUnit=%d VpiEndLabel=%s\n",
             std::string(p->VpiName()).c_str(),std::string(p->VpiDefName()).c_str(),
             (int)p->VpiTop(),(int)p->VpiUnit(),std::string(p->VpiEndLabel()).c_str());
    }
  }
  return 0;
}
