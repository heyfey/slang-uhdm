// vsd8 — ADVERSARIAL PROBE: element-variable SHARING census.
// For every class_defn-listing array_var and every package-listing array_var,
// print: owner, var name, array_var ptr, element var ptr, element ref_typespec
// ptr, element actual typespec ptr + kind/name + instance view.
// Purpose: (a) decide whether importCopyElem8's `ce==se` / `cts==sts` guards
// can ever fire; (b) decide whether the typespec nulled is SHARED with any
// other user (backfire), by counting how many owners name the same ts pointer.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static std::set<const BaseClass*> g_all, g_top;
static std::string view(const instance* i){ if(!i) return "<null>"; std::string nm(i->VpiName());
  if(g_top.count(i)) return "TOP:"+nm; if(g_all.count(i)) return "ALL:"+nm; return "OTHER:"+nm; }
static std::string span(const BaseClass* p){ return std::to_string(p->VpiLineNo())+":"+std::to_string(p->VpiColumnNo()); }
int main(int argc,char**argv){
  if(argc<2){std::cerr<<"usage: vsd8_elem <db> [name]\n";return 2;}
  std::string only = argc>2?argv[2]:"";
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  if(h.empty()){std::cerr<<"RESTORE FAILED\n";return 3;}
  auto* d=(design*)((uhdm_handle*)h[0])->object;
  if(auto*v=d->AllPackages()) for(auto*p:*v) g_all.insert(p);
  if(auto*v=d->TopPackages()) for(auto*p:*v) g_top.insert(p);
  std::map<const void*,int> tsUsers; std::map<const void*,int> evUsers;
  struct Row{std::string owner,var; const void*av;const void*ev;const void*rts;const void*ts;std::string tk,inst;};
  std::vector<Row> rows;
  auto doVar=[&](const std::string& owner, variables* v){
    if(!v||v->UhdmType()!=uhdmarray_var) return;
    if(!only.empty() && std::string(v->VpiName())!=only) return;
    auto* av=(array_var*)v; if(!av->Variables()) return;
    for(auto* ev:*av->Variables()){
      if(!ev) continue; evUsers[(const void*)ev]++;
      const void* rts=nullptr; const void* ts=nullptr; std::string tk="<null>",in="<null>";
      if(ev->Typespec()){ rts=(const void*)ev->Typespec();
        if(auto* t=ev->Typespec()->Actual_typespec()){ ts=(const void*)t; tsUsers[ts]++;
          tk=std::string(UhdmName(t->UhdmType()))+"("+std::string(t->VpiName())+")@"+span(t);
          in=view(t->Instance()); } }
      rows.push_back({owner,std::string(v->VpiName()),(const void*)av,(const void*)ev,rts,ts,tk,in});
    }
  };
  for(const auto&[obj,id]:s.AllObjects()){
    if(!obj) continue;
    if(obj->UhdmType()==uhdmclass_defn){ auto*cd=(class_defn*)obj; if(!cd->Variables()) continue;
      std::string cn(cd->VpiFullName().empty()?cd->VpiName():cd->VpiFullName());
      for(auto*v:*cd->Variables()) doVar("CLS "+cn+"@"+span(cd),v); }
    else if(obj->UhdmType()==uhdmpackage){ auto*p=(package*)obj; if(!p->Variables()) continue;
      for(auto*v:*p->Variables()) doVar("PKG "+view(p),v); }
  }
  size_t nsharedTs=0,nsharedEv=0;
  for(auto&r:rows){ int tu=r.ts?tsUsers[r.ts]:0; int eu=evUsers[r.ev];
    if(tu>1) nsharedTs++; if(eu>1) nsharedEv++;
    std::cout<<r.owner<<" :: "<<r.var<<"  av="<<r.av<<" ev="<<r.ev<<"(users="<<eu<<")"
             <<" rts="<<r.rts<<" ts="<<r.ts<<"(users="<<tu<<") "<<r.tk<<" inst="<<r.inst<<"\n"; }
  std::cout<<"[S] rows="<<rows.size()<<" rows_with_shared_ts="<<nsharedTs
           <<" rows_with_shared_elemvar="<<nsharedEv<<"\n";
  return rows.empty()?5:0;
}
