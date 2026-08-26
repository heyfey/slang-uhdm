// r10earl100 -- MEASUREMENT ONLY.  THE LISTING CENSUS: for every scope that
// carries a Variables / Nets / Array_nets listing, one keyed line per signal
// naming WHICH LISTING it sits in and WHAT KIND it is -- exactly the two
// things `scope::Compare` (Variables, position 6) and `instance::Compare`
// (Nets, after Task_funcs) can see.  Plus one COUNT line per scope, because a
// vector SIZE MISMATCH is what the judge reports (BaseClass.h's vector
// SafeCompare sets BOTH owners and returns before any element is compared).
//
//   SIG <view>|<homekind>|<homefullname>|<signame>   <list>:<kind>
//   CNT <view>|<homekind>|<homefullname>            nV=<n> nN=<n> nA=<n>
//
// <view> is D for the definition listing (design::AllModules / AllPackages /
// AllInterfaces) and E for the elaborated tree (design::TopModules) -- the two
// producers name them identically, so the view must be in the key.
// NO SPAN and NO typespec in the key: this census scores LISTING MEMBERSHIP
// and OBJECT KIND, the fields this pass's law moves.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <set>
using namespace UHDM;
static char g_view = 'E';
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nm(const BaseClass*o){ if(!o) return "-"; auto v=((const any*)o)->VpiName(); return v.empty()?std::string("-"):std::string(v); }
static std::set<const any*> g_seen;

static void doScope(const any* sc){
  if(!g_seen.insert(sc).second) return;
  std::string fn;
  if(auto*s2=any_cast<const scope*>(sc)) fn=std::string(s2->VpiFullName());
  if(fn.empty()) fn=nm(sc);
  std::string home = std::string(1,g_view)+"|"+kn(sc)+"|"+fn;
  const VectorOfvariables* vars=nullptr; const VectorOfnet* nets=nullptr;
  const VectorOfarray_net* ans=nullptr;
  if(auto*m=any_cast<const instance*>(sc)){ vars=m->Variables(); nets=m->Nets(); ans=m->Array_nets(); }
  else if(auto*g=any_cast<const scope*>(sc)){ vars=g->Variables(); }
  if(auto*g=any_cast<const gen_scope*>(sc)){ nets=g->Nets(); ans=g->Array_nets(); }
  size_t nV=vars?vars->size():0, nN=nets?nets->size():0, nA=ans?ans->size():0;
  printf("CNT %s\tnV=%zu nN=%zu nA=%zu\n", home.c_str(), nV, nN, nA);
  if(vars) for(auto*v:*vars) printf("SIG %s|%s\tV:%s\n", home.c_str(), nm(v).c_str(), kn(v).c_str());
  if(nets) for(auto*n:*nets) printf("SIG %s|%s\tN:%s\n", home.c_str(), nm(n).c_str(), kn(n).c_str());
  if(ans)  for(auto*a:*ans)  printf("SIG %s|%s\tA:array_net\n", home.c_str(), nm(a).c_str());
}
static void walk(const any* o, int depth){
  if(!o||depth>80) return;
  UHDM_OBJECT_TYPE t=o->UhdmType();
  if(t==uhdmmodule_inst||t==uhdminterface_inst||t==uhdmgen_scope||t==uhdmprogram||t==uhdmpackage) doScope(o);
  if(auto*m=any_cast<const module_inst*>(o)){
    if(m->Modules()) for(auto*c:*m->Modules()) walk(c,depth+1);
    if(m->Gen_scope_arrays()) for(auto*ga:*m->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g:*ga->Gen_scopes()) walk(g,depth+1);
    if(m->Interfaces()) for(auto*c:*m->Interfaces()) walk(c,depth+1);
    if(m->Programs()) for(auto*c:*m->Programs()) walk(c,depth+1);
    return;
  }
  if(auto*g=any_cast<const gen_scope*>(o)){
    if(g->Modules()) for(auto*c:*g->Modules()) walk(c,depth+1);
    if(g->Gen_scope_arrays()) for(auto*ga:*g->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g2:*ga->Gen_scopes()) walk(g2,depth+1);
    return;
  }
  if(auto*i=any_cast<const interface_inst*>(o)){
    if(i->Gen_scope_arrays()) for(auto*ga:*i->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g:*ga->Gen_scopes()) walk(g,depth+1);
    return;
  }
}
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: ct100cen <db.uhdm>\n");return 2;}
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  for(vpiHandle h:r){
    const any* o=(const any*)((uhdm_handle*)h)->object;
    if(auto*d=any_cast<const design*>(o)){
      g_view='E'; if(d->TopModules()) for(auto*m:*d->TopModules()) walk(m,0);
      g_view='D';
      if(d->AllModules()) for(auto*m:*d->AllModules()) walk(m,0);
      if(d->AllPackages()) for(auto*m:*d->AllPackages()) walk(m,0);
      if(d->AllInterfaces()) for(auto*m:*d->AllInterfaces()) walk(m,0);
    }
  }
  return 0;
}
