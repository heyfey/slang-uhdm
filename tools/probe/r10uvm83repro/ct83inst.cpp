// r10uvm83 — MEASUREMENT-ONLY.  The vpiInstance census.
// Tallies, over EVERY object of one database, the `Instance` (vpiInstance)
// single-relation edge that `variables::Compare`, `typespec::Compare`,
// `task_func::Compare` (and others) compare, keyed by
// (referrer kind -> target kind|target name).  `SafeCompare(lhs, nullptr)` sets
// ONLY m_failedLhs, so a golden `Instance` we leave NULL is a head whose RHS
// prints `<null>` and whose LHS is the TARGET — never the referrer.
//   usage: ct83inst <db.uhdm> [--per-kind] [--list <targetName>]
// build: g++ -O2 -std=c++17 ct83inst.cpp -I ~/.local/include \
//        -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83inst
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
int main(int argc,char** argv){
  bool perkind=false; const char* fld="Instance"; const char* dumpkind=nullptr;
  for(int i=2;i<argc;i++){ if(!strcmp(argv[i],"--per-kind")) perkind=true;
    else if(!strcmp(argv[i],"--field")&&i+1<argc) fld=argv[++i];
    else if(!strcmp(argv[i],"--dump")&&i+1<argc) dumpkind=argv[++i]; }
  Serializer s; s.Restore(std::string(argv[1]));
  auto all=s.AllObjects();
  std::map<std::string,size_t> tally; size_t objs=0, withfield=0, set=0, unset=0;
  for(auto& kv:all){
    const BaseClass* o=(const BaseClass*)kv.first; if(!o) continue; objs++;
    auto it=kFields.find(std::string(UhdmName(o->UhdmType()))); if(it==kFields.end()) continue;
    for(const Field& f:it->second){
      if(f.kind!=F_REL1||strcmp(f.name,fld)) continue;
      withfield++;
      const BaseClass* t=f.sel?std::get<0>(o->GetByVpiType(f.sel)):nullptr;
      std::string key;
      if(perkind) key=std::string(UhdmName(o->UhdmType()))+" -> ";
      key += t? (std::string(UhdmName(t->UhdmType()))+"|"+std::string(t->VpiName())+"#"+std::to_string(t->UhdmId())) : "<NULL>";
      tally[key]++;
      if(t) set++; else unset++;
      if(dumpkind&&!strcmp(dumpkind,std::string(UhdmName(o->UhdmType())).c_str())){
        const char* rr = !t? "NULL" : (t->UhdmType()==uhdmpackage ? (((const package*)t)->VpiTop()?"pkg:ELAB":"pkg:DEF") : std::string(UhdmName(t->UhdmType())).c_str());
        printf("DUMP\t%s\t%s\t%u:%u-%u:%u\t%s\n",std::string(UhdmName(o->UhdmType())).c_str(),
               std::string(o->VpiName()).c_str(),o->VpiLineNo(),(unsigned)o->VpiColumnNo(),
               o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo(),rr);
      }
    }
  }
  printf("OBJECTS %zu  with-%s-field %zu  SET %zu  NULL %zu\n",objs,fld,withfield,set,unset);
  for(auto& kv:tally) printf("TALLY\t%-60s %zu\n",kv.first.c_str(),kv.second);
  return 0;
}
