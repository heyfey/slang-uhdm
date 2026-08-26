// r10earl100 -- MEASUREMENT ONLY.  Lists, for every module_inst (and every
// scope that carries Variables/Nets), the Variables / Nets / Array_nets /
// Ports listings by NAME + KIND + SPAN, straight out of a .uhdm database.
// The official uhdm-cmp stays the sole judge; this is a decode instrument.
//
//   MOD <fullname> <defname> <span>
//     V <i> <kind> <name> <span> ts=<kind>(<name>)
//     N <i> <kind> <name> <span> nettype=<n> ts=<kind>(<name>)
//     A <i> array_net <name> <span> elems=<kind>...
//     P <i> <dir> <name> <span> lowconn=<kind>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nm(const BaseClass*o){ if(!o) return "-"; auto v=((const any*)o)->VpiName(); return v.empty()?std::string("-"):std::string(v); }
static const char* g_filter = nullptr;

static std::string tsof(const any* o){
  const ref_typespec* rt = nullptr;
  if(auto*v=any_cast<const variables*>(o)) rt=v->Typespec();
  else if(auto*n=any_cast<const nets*>(o)) rt=n->Typespec();
  if(!rt) return "-";
  const typespec* a = rt->Actual_typespec();
  if(!a) return "ref(<null>)";
  return kn(a)+"("+nm(a)+")";
}

static void doScope(const any* sc){
  std::string fn; if(auto*sc2=any_cast<const scope*>(sc)) fn=std::string(sc2->VpiFullName()); else fn=std::string(nm(sc));
  if(g_filter && fn.find(g_filter)==std::string::npos) return;
  printf("MOD %s | %s | %s | %s\n", fn.c_str(), nm(sc).c_str(), kn(sc).c_str(), sp(sc).c_str());
  const VectorOfvariables* vars=nullptr; const VectorOfnet* nets=nullptr;
  const VectorOfarray_net* ans=nullptr; const VectorOfport* ports=nullptr;
  if(auto*m=any_cast<const instance*>(sc)){ vars=m->Variables(); nets=m->Nets(); ans=m->Array_nets(); }
  if(auto*mi=any_cast<const module_inst*>(sc)) ports=mi->Ports();
  else if(auto*g=any_cast<const scope*>(sc)){ vars=g->Variables(); }
  if(auto*g=any_cast<const gen_scope*>(sc)){ nets=g->Nets(); ans=g->Array_nets(); }
  if(vars){int i=0;for(auto*v:*vars){printf("  V %d %s %s %s ts=%s\n",i++,kn(v).c_str(),nm(v).c_str(),sp(v).c_str(),tsof(v).c_str());}}
  else printf("  V <null-vector>\n");
  if(nets){int i=0;for(auto*n:*nets){printf("  N %d %s %s %s nt=%d ts=%s\n",i++,kn(n).c_str(),nm(n).c_str(),sp(n).c_str(),(int)n->VpiNetType(),tsof(n).c_str());}}
  else printf("  N <null-vector>\n");
  if(ans){int i=0;for(auto*a:*ans){printf("  A %d array_net %s %s\n",i++,nm(a).c_str(),sp(a).c_str());}}
  if(ports){int i=0;for(auto*p:*ports){const any*lc=p->Low_conn();const any*hc=p->High_conn();
    printf("  P %d dir=%d %s %s low=%s(%s) high=%s(%s)\n",i++,(int)p->VpiDirection(),nm(p).c_str(),sp(p).c_str(),kn(lc).c_str(),nm(lc).c_str(),kn(hc).c_str(),nm(hc).c_str());}}
}

static void walk(const any* o, int depth){
  if(!o||depth>60) return;
  UHDM_OBJECT_TYPE t=o->UhdmType();
  if(t==uhdmmodule_inst||t==uhdminterface_inst||t==uhdmgen_scope||t==uhdmprogram||t==uhdmpackage) doScope(o);
  if(auto*d=any_cast<const design*>(o)){
    if(d->TopModules()) for(auto*m:*d->TopModules()) walk(m,depth+1);
    if(d->AllModules()) for(auto*m:*d->AllModules()) walk(m,depth+1);
    if(d->AllPackages()) for(auto*m:*d->AllPackages()) walk(m,depth+1);
    if(d->AllInterfaces()) for(auto*m:*d->AllInterfaces()) walk(m,depth+1);
    return;
  }
  if(auto*m=any_cast<const module_inst*>(o)){
    if(m->Modules()) for(auto*c:*m->Modules()) walk(c,depth+1);
    if(m->Gen_scope_arrays()) for(auto*ga:*m->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g:*ga->Gen_scopes()) walk(g,depth+1);
    if(m->Interfaces()) for(auto*c:*m->Interfaces()) walk(c,depth+1);
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
  if(argc<2){fprintf(stderr,"usage: ct100lst <db.uhdm> [fullname-substr]\n");return 2;}
  if(argc>2) g_filter=argv[2];
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  for(vpiHandle h:r){ walk((const any*)((uhdm_handle*)h)->object, 0); }
  return 0;
}
