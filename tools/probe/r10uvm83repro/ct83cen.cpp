// r10uvm83 — MEASUREMENT-ONLY.  THE JOINED vpiInstance CENSUS.
// Joins golden and ours object-by-object on a positional key
// (kind : VpiName : line:col-endline:endcol : two levels of parent kind+name —
// the FILE is deliberately NOT in the key, because our objects carry an empty
// VpiFile on most in-class declarations and a file-bearing key would join
// nothing), then classifies the `Instance` (vpiInstance) edge of every object
// that has one:
//    BOTH-NULL / BOTH-SET-SAME-ROLE / GOLDEN-SET-OURS-NULL /
//    GOLDEN-NULL-OURS-SET / ROLE-DIFFERS (def package vs elaborated package)
// AMBIGUOUS keys (more than one object per side) are counted and EXCLUDED from
// every verdict rather than joined arbitrarily.
//   usage: ct83cen <golden.uhdm> <ours.uhdm> [--list <CLASS>] [--kind <k>]
// build: g++ -O2 -std=c++17 ct83cen.cpp -I ~/.local/include -I ../r10ladder1repro \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>
using namespace UHDM;
enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string span(const BaseClass* o){char b[96];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),(unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());return b;}
static std::string ident(const BaseClass* o){
  if(!o) return "<null>";
  return std::string(UhdmName(o->UhdmType()))+"("+std::string(o->VpiName())+")#"+std::to_string(o->UhdmId())+"@"+base(o->VpiFile())+":"+span(o);
}
static std::string keyOf(const BaseClass* o){
  std::string s=std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+":"+span(o);
  const BaseClass* p=o->VpiParent();
  for(int i=0;i<2&&p;i++){ s+="<"+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName()); p=p->VpiParent(); }
  return s;
}
static std::string role(const BaseClass* t){
  if(!t) return "NULL";
  if(t->UhdmType()==uhdmpackage) return ((const package*)t)->VpiTop()? "pkg:ELAB":"pkg:DEF";
  if(t->UhdmType()==uhdmdesign) return "design";
  return std::string(UhdmName(t->UhdmType()));
}
static int instSel(){ // the vpi selector ctfields.inc uses for the Instance rel1
  for(auto& kv:kFields) for(auto& f:kv.second) if(f.kind==F_REL1&&!strcmp(f.name,"Instance")&&f.sel) return f.sel;
  return 0;
}
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83cen <golden> <ours> [--list CLASS] [--kind k]\n");return 2;}
  const char* list=nullptr; const char* onlykind=nullptr;
  for(int i=3;i<argc;i++){ if(!strcmp(argv[i],"--list")&&i+1<argc) list=argv[++i];
    else if(!strcmp(argv[i],"--kind")&&i+1<argc) onlykind=argv[++i]; }
  int SEL=instSel(); if(!SEL){printf("NO SELECTOR FOR Instance\n");return 3;}
  Serializer sg,so; sg.Restore(std::string(argv[1])); so.Restore(std::string(argv[2]));
  auto has=[&](const BaseClass* o){ auto it=kFields.find(std::string(UhdmName(o->UhdmType())));
    if(it==kFields.end()) return false;
    for(auto& f:it->second) if(f.kind==F_REL1&&!strcmp(f.name,"Instance")) return true; return false; };
  std::unordered_multimap<std::string,const BaseClass*> G,O;
  for(auto& kv:sg.AllObjects()){ auto* o=(const BaseClass*)kv.first; if(o&&has(o)) G.emplace(keyOf(o),o); }
  for(auto& kv:so.AllObjects()){ auto* o=(const BaseClass*)kv.first; if(o&&has(o)) O.emplace(keyOf(o),o); }
  printf("OBJECTS-WITH-Instance golden=%zu ours=%zu\n",G.size(),O.size());
  // ORDER-INDEPENDENT JOIN.  Objects with a NULL VpiParent (which is most
  // typespecs on our side AND on golden's) collapse to the same key in groups of
  // two or more — golden keeps a def-view and an elab-view copy of the same
  // typespec — so a 1:1 join would have to invent an order.  Instead the MULTISET
  // of Instance ROLES per key is compared: {NULL, pkg:DEF, pkg:ELAB, design, ...}.
  // Order never enters, and a key whose two multisets are equal cannot hide a
  // disagreement in this field.
  std::map<std::string,std::map<std::string,size_t>> gm,om;
  std::map<std::string,std::vector<const BaseClass*>> gobj,oobj;
  for(auto& kv:G){ gm[kv.first][role(std::get<0>(kv.second->GetByVpiType(SEL)))]++; gobj[kv.first].push_back(kv.second); }
  for(auto& kv:O){ om[kv.first][role(std::get<0>(kv.second->GetByVpiType(SEL)))]++; oobj[kv.first].push_back(kv.second); }
  size_t amb=0,nog=0,same=0,diff=0;
  std::map<std::string,size_t> shape;
  for(auto& kv:gm){
    auto it=om.find(kv.first);
    if(it==om.end()){ nog++; continue; }
    if(kv.second==it->second){ same++; continue; }
    diff++;
    std::string kind=gobj[kv.first][0]?std::string(UhdmName(gobj[kv.first][0]->UhdmType())):"?";
    std::string a,b;
    for(auto& r:kv.second) a+=r.first+"x"+std::to_string(r.second)+" ";
    for(auto& r:it->second) b+=r.first+"x"+std::to_string(r.second)+" ";
    shape[kind+"  G{"+a+"} O{"+b+"}"]++;
    if(list) printf("DIFFKEY\t%-58s G{%s} O{%s}\n",kv.first.c_str(),a.c_str(),b.c_str());
  }
  printf("KEYS golden=%zu ours=%zu  SAME-ROLE-MULTISET=%zu  DIFFERING=%zu  GOLDEN-ONLY-KEYS=%zu\n",
         gm.size(),om.size(),same,diff,nog);
  for(auto& kv:shape) printf("SHAPE\t%-90s %zu\n",kv.first.c_str(),kv.second);
  (void)amb; return 0;
}
#if 0
  printf("AMBIGUOUS-KEYS(excluded)=%zu  GOLDEN-ONLY-KEYS(no counterpart)=%zu\n",amb,nog);
  for(auto& kv:cls) printf("CLASS\t%-34s %zu\n",kv.first.c_str(),kv.second);
  for(auto& kv:missKind) printf("BYKIND\t%-50s %zu\n",kv.first.c_str(),kv.second);
  return 0;
}

#endif
