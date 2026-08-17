// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
//
// THE HEAD-FIELD LOCATOR.  uhdm-cmp prints only `m_failedLhs` / `m_failedRhs`,
// and when the head is a CONTAINER with `RHS: <null>` it does not say WHICH
// field of that container failed.  This tool replicates `design::Compare`'s own
// walk field by field and element by element with the SAME CompareContext the
// real run would have, SNAPSHOTS `m_visited` at the instant the failing child's
// Compare is entered, and then re-runs each of that child's compared fields from
// a FRESH context seeded with the snapshot.  The FIRST field that fails is the
// head's field, and the visited-snapshot is what makes that claim faithful:
// 209 of UHDM's 288 generated Compare bodies open with the
// `m_visited.insert(this)` short-circuit, so a re-run from a polluted OR from an
// empty visited set reports a DIFFERENT first failure than the real walk.
//
//   usage: ct83head <golden.uhdm> <ours.uhdm>
//
// build: g++ -O2 -std=c++17 ct83head.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83head
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string ident(const BaseClass* o){
  if(!o) return "<null>";
  char b[512];
  snprintf(b,sizeof b,"%s(%s)#%u@%s:%u:%u-%u:%u",std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(),o->UhdmId(),base(o->VpiFile()).c_str(),
           o->VpiLineNo(),(unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());
  return b;
}
// LOCAL, VERBATIM re-implementation of UHDM::BaseClass::SafeCompare
// (BaseClass.h lines 187-225 of the installed header); it is `protected` there.
static int32_t mySafe(const BaseClass* lhs,const BaseClass* rhs,CompareContext* c){
  if(lhs&&rhs) return lhs->Compare(rhs,c);
  if(lhs&&!rhs){ c->m_failedLhs=lhs; return 1; }
  if(!lhs&&rhs){ c->m_failedRhs=rhs; return -1; }
  return 0;
}
template<typename T>
static int32_t mySafeV(const BaseClass* lo,const std::vector<T*>* l,
                       const BaseClass* ro,const std::vector<T*>* r,CompareContext* c,
                       int* failIdx=nullptr){
  if(l&&r){
    int32_t rr=0;
    if((rr=static_cast<int32_t>(l->size()-r->size()))!=0){ c->m_failedLhs=lo; c->m_failedRhs=ro; if(failIdx)*failIdx=-2; return 1; }
    for(size_t i=0,n=l->size();i<n;i++) if((rr=mySafe(l->at(i),r->at(i),c))!=0){ if(failIdx)*failIdx=(int)i; return rr; }
  } else if(l&&!l->empty()&&!r){ c->m_failedLhs=lo; if(failIdx)*failIdx=-3; return 1; }
  else if(!l&&r&&!r->empty()){ c->m_failedRhs=ro; if(failIdx)*failIdx=-4; return -1; }
  return 0;
}
static design* getdesign(Serializer& s,const char* p){
  auto restored=s.Restore(std::string(p));
  for(auto h:restored){auto* o=(BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) return (design*)o;}
  return nullptr;
}
typedef std::vector<const any*> Snap;
static void snapshot(const CompareContext& c,Snap& s){ s.assign(c.m_visited.begin(),c.m_visited.end()); }
static void seed(CompareContext& c,const Snap& s){ for(auto* p:s) c.m_visited.insert(p); }

static Snap g_snap; static const package* g_L=nullptr; static const package* g_R=nullptr;
static const char* g_via="-"; static int g_idx=-1;

int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83head <golden> <ours>\n");return 2;}
  Serializer sg,so;
  design* dg=getdesign(sg,argv[1]); design* dr=getdesign(so,argv[2]);
  if(!dg||!dr){printf("NO_DESIGN\n");return 2;}
  // --- 1. the OFFICIAL head, exactly as uhdm-cmp computes it
  { CompareContext ctx; int32_t r=dg->Compare(dr,&ctx);
    printf("OFFICIAL  r=%d  visited=%zu\n",r,ctx.m_visited.size());
    printf("OFFICIAL  LHS %s\n",ident(ctx.m_failedLhs).c_str());
    printf("OFFICIAL  RHS %s\n",ident(ctx.m_failedRhs).c_str());
    if(r==0){printf("EQUAL\n");return 0;} }
  // --- 2. replicate design::Compare, snapshotting m_visited per package
  CompareContext ctx; ctx.m_visited.insert(dg);
  int fi=-1;
  if(mySafeV(dg,dg->Include_file_infos(),dr,dr->Include_file_infos(),&ctx,&fi)!=0){
    printf("DESIGN-FIELD Include_file_infos FAILS idx=%d\n",fi); }
  auto walk=[&](const std::vector<package*>* A,const std::vector<package*>* B,const char* nm)->bool{
    if(!A||!B){ printf("DESIGN-FIELD %s null-asym G=%p O=%p\n",nm,(void*)A,(void*)B); return false; }
    if(A->size()!=B->size()){ printf("DESIGN-FIELD %s SIZE G=%zu O=%zu\n",nm,A->size(),B->size()); return false; }
    for(size_t i=0;i<A->size();i++){
      Snap s; snapshot(ctx,s);
      int32_t r=mySafe(A->at(i),B->at(i),&ctx);
      printf("  %s[%zu] r=%d  G %s  O %s\n",nm,i,r,ident(A->at(i)).c_str(),ident(B->at(i)).c_str());
      if(r!=0){ g_snap=s; g_L=A->at(i); g_R=B->at(i); g_via=nm; g_idx=(int)i; return true; }
    }
    return false;
  };
  bool found = walk(dg->AllPackages(),dr->AllPackages(),"AllPackages");
  if(!found) found = walk(dg->TopPackages(),dr->TopPackages(),"TopPackages");
  if(!found){ printf("NO PACKAGE-LEVEL FAILURE — the head is past the package vectors\n"); return 0; }
  printf("FAILING PAIR via %s[%d]\n  G %s\n  O %s\n  snapshot(visited)=%zu\n",
         g_via,g_idx,ident(g_L).c_str(),ident(g_R).c_str(),g_snap.size());
  // --- 3. per-field re-run from the snapshot (+ the package itself, which
  //        package::Compare inserts before touching any field)
  const package* L=g_L; const package* R=g_R;
#define FLD(NAME) do{ \
    CompareContext c2; seed(c2,g_snap); c2.m_visited.insert(L); \
    auto* lv=L->NAME(); auto* rv=R->NAME(); int idx=-1; \
    int32_t rr=mySafeV(L,lv,R,rv,&c2,&idx); \
    printf("FLD %-24s G=%-8s O=%-8s r=%-4d %s", #NAME, \
       lv?("n="+std::to_string(lv->size())).c_str():"NULL", \
       rv?("n="+std::to_string(rv->size())).c_str():"NULL", rr, rr?"FAILS":"ok"); \
    if(rr){ const char* why = idx==-2?"VEC-SIZE":(idx==-3?"OURS-VEC-IS-NULL":(idx==-4?"GOLDEN-VEC-IS-NULL":"ELEMENT")); \
      printf("  why=%s idx=%d failedLhs=%s failedRhs=%s",why,idx, \
             ident(c2.m_failedLhs).c_str(),ident(c2.m_failedRhs).c_str()); \
      if(idx>=0) printf("\n      ELEM G %s\n      ELEM O %s",ident(lv->at(idx)).c_str(),ident(rv->at(idx)).c_str()); } \
    printf("\n"); \
  }while(0)
  printf("-- scope::Compare order\n");
  FLD(Property_decls); FLD(Sequence_decls); FLD(Concurrent_assertions);
  FLD(Named_events); FLD(Named_event_arrays); FLD(Variables);
  FLD(Virtual_interface_vars); FLD(Logic_vars); FLD(Array_vars);
  FLD(Array_var_mems); FLD(Parameters); FLD(Param_assigns);
  FLD(Scopes); FLD(Typespecs); FLD(Instance_items); FLD(Let_decls); FLD(Attributes);
  printf("-- instance::Compare order\n");
  FLD(Programs); FLD(Program_arrays); FLD(Class_defns); FLD(Task_funcs);
  FLD(Nets); FLD(Array_nets); FLD(Spec_params); FLD(Assertions);
  { CompareContext c2; seed(c2,g_snap); c2.m_visited.insert(L);
    int32_t rr=mySafe(L->Module_inst(),R->Module_inst(),&c2);
    printf("SNG %-24s G=%-8s O=%-8s r=%d\n","Module_inst",L->Module_inst()?"set":"NULL",R->Module_inst()?"set":"NULL",rr); }
  { CompareContext c2; seed(c2,g_snap); c2.m_visited.insert(L);
    int32_t rr=mySafe(L->Instance(),R->Instance(),&c2);
    printf("SNG %-24s G=%-8s O=%-8s r=%d\n","Instance",L->Instance()?"set":"NULL",R->Instance()?"set":"NULL",rr); }
  printf("-- package::Compare scalars: VpiType G=%d O=%d  VpiUnit G=%d O=%d  VpiEndLabel G=[%s] O=[%s]\n",
         L->VpiType(),R->VpiType(),(int)L->VpiUnit(),(int)R->VpiUnit(),
         std::string(L->VpiEndLabel()).c_str(),std::string(R->VpiEndLabel()).c_str());
  return 0;
}
