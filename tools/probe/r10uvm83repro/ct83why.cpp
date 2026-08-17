// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
//
// *** THIS TOOL IS KEPT AS A RECORD OF A WRONG ANSWER.  READ THIS FIRST. ***
// It re-runs the failing object's fields from the CompareContext left at the END
// of the failing walk, and therefore reported SIX fields of the uvm_pkg pair as
// "FAILS" — because m_visited was already past every one of them, so the objects
// that had compared equal on the real walk were re-entered and re-judged out of
// order.  A per-field re-run WITHOUT a pre-field visited-snapshot answers a
// different question than the judge asks, and its output must not be read as a
// head.  `ct83head.cpp` (snapshot per field) and `ct83path.cpp` (snapshot per
// field AND per element, plus an official-head reproduction assertion at every
// step) are the corrected instruments; this one is preserved so the failure mode
// is documented rather than rediscovered.
// Answers "WHICH FIELD is the official head?" for a head whose m_failedLhs is a
// CONTAINER and whose m_failedRhs is <null>.
//
// Method (and the flaw): run the OFFICIAL design::Compare exactly as uhdm-cmp
// does, keep the SAME CompareContext, clear only the failed-pointers, then
// re-run the failing object's compared fields ONE AT A TIME in the generated
// order.  The reasoning WAS "the field that re-fails is the head's field,
// because every earlier field's objects are already in m_visited and compare
// equal instantly".  That reasoning is WRONG: the context kept here is the one
// from the END of the walk, not from the moment the failing object was entered,
// so an object the real walk had NOT yet reached is not in m_visited and
// re-fails here too.  Only the vector-SHAPE verdicts (size mismatch,
// rhs==nullptr) it prints are trustworthy — and on this head there were none,
// which is the one genuinely useful thing it established.
//
//   usage: ct83why <golden.uhdm> <ours.uhdm>
//
// build: g++ -O2 -std=c++17 ct83why.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83why
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

// LOCAL, VERBATIM re-implementation of UHDM::BaseClass::SafeCompare (BaseClass.h
// lines 187-225 of the installed header).  It is `protected` there, so it cannot
// be called from a probe; this copy has IDENTICAL semantics, including the
// "lhs non-empty AND rhs==nullptr sets ONLY m_failedLhs" branch that produces a
// `RHS: <null>` head on a CONTAINER.  MEASUREMENT-ONLY.
static int32_t mySafe(const BaseClass* lhs,const BaseClass* rhs,CompareContext* c){
  if(lhs&&rhs) return lhs->Compare(rhs,c);
  if(lhs&&!rhs){ c->m_failedLhs=lhs; return 1; }
  if(!lhs&&rhs){ c->m_failedRhs=rhs; return -1; }
  return 0;
}
template<typename T>
static int32_t mySafe(const BaseClass* lo,const std::vector<T*>* l,
                      const BaseClass* ro,const std::vector<T*>* r,CompareContext* c){
  if(l&&r){
    int32_t rr=0;
    if((rr=static_cast<int32_t>(l->size()-r->size()))!=0){ c->m_failedLhs=lo; c->m_failedRhs=ro; return 1; }
    for(size_t i=0,n=l->size();i<n;i++) if((rr=mySafe(l->at(i),r->at(i),c))!=0){
      printf("   ELEM[%zu] G=%s O=%s\n",i,ident(l->at(i)).c_str(),ident(r->at(i)).c_str());
      return rr; }
  } else if(l&&!l->empty()&&!r){ c->m_failedLhs=lo; return 1; }
  else if(!l&&r&&!r->empty()){ c->m_failedRhs=ro; return -1; }
  return 0;
}
static design* getdesign(Serializer& s,const char* p){
  auto restored=s.Restore(std::string(p));
  for(auto h:restored){auto* o=(BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) return (design*)o;}
  return nullptr;
}
#define VFIELD(NAME) do{ \
  auto* lv=L->NAME(); auto* rv=R->NAME(); \
  const char* nm=#NAME; \
  int32_t rr=mySafe(L,lv,R,rv,&ctx); \
  printf("FLD %-24s G=%-8s O=%-8s r=%d%s\n",nm, \
     lv?("n="+std::to_string(lv->size())).c_str():"NULL", \
     rv?("n="+std::to_string(rv->size())).c_str():"NULL", rr, rr?"   <== FAILS":""); \
  if(rr){ ctx.m_failedLhs=nullptr; ctx.m_failedRhs=nullptr; } \
}while(0)
#define SFIELD(NAME) do{ \
  auto* lv=L->NAME(); auto* rv=R->NAME(); \
  int32_t rr=mySafe(lv,rv,&ctx); \
  printf("SNG %-24s G=%-8s O=%-8s r=%d%s\n",#NAME,lv?"set":"NULL",rv?"set":"NULL",rr,rr?"   <== FAILS":""); \
  if(rr){ ctx.m_failedLhs=nullptr; ctx.m_failedRhs=nullptr; } \
}while(0)
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83why <golden> <ours>\n");return 2;}
  Serializer sg,so;
  design* dg=getdesign(sg,argv[1]); design* dr=getdesign(so,argv[2]);
  if(!dg||!dr){printf("NO_DESIGN\n");return 2;}
  CompareContext ctx;
  int32_t r=dg->Compare(dr,&ctx);
  printf("DESIGN-COMPARE r=%d visited=%zu\n",r,ctx.m_visited.size());
  printf("HEAD  LHS %s\n",ident(ctx.m_failedLhs).c_str());
  printf("HEAD  RHS %s\n",ident(ctx.m_failedRhs).c_str());
  if(r==0){printf("EQUAL\n");return 0;}
  const BaseClass* fl=ctx.m_failedLhs;
  if(!fl||fl->UhdmType()!=uhdmpackage){
    printf("HEAD IS NOT A PACKAGE — nothing more to say here\n"); return 0;
  }
  // find the RHS partner by position in the design vectors
  const package* L=(const package*)fl; const package* R=nullptr;
  const char* via="?";
  auto scan=[&](const std::vector<package*>* a,const std::vector<package*>* b,const char* nm){
    if(!a||!b) return; for(size_t i=0;i<a->size()&&i<b->size();i++) if(a->at(i)==L){R=b->at(i);via=nm;}
  };
  scan(dg->AllPackages(),dr->AllPackages(),"AllPackages");
  scan(dg->TopPackages(),dr->TopPackages(),"TopPackages");
  if(!R){printf("NO RHS PARTNER FOUND\n");return 0;}
  printf("PAIR via %s\n  G %s\n  O %s\n",via,ident(L).c_str(),ident(R).c_str());
  ctx.m_failedLhs=nullptr; ctx.m_failedRhs=nullptr;
  printf("-- scope::Compare order\n");
  printf("SCA VpiName G=%s O=%s r=%d\n",std::string(L->VpiName()).c_str(),std::string(R->VpiName()).c_str(),
         (int)std::string(L->VpiName()).compare(std::string(R->VpiName())));
  VFIELD(Property_decls); VFIELD(Sequence_decls); VFIELD(Concurrent_assertions);
  VFIELD(Named_events); VFIELD(Named_event_arrays); VFIELD(Variables);
  VFIELD(Virtual_interface_vars); VFIELD(Logic_vars); VFIELD(Array_vars);
  VFIELD(Array_var_mems); VFIELD(Parameters); VFIELD(Param_assigns);
  VFIELD(Scopes); VFIELD(Typespecs); VFIELD(Instance_items); VFIELD(Let_decls);
  VFIELD(Attributes);
  printf("-- instance::Compare order\n");
  printf("SCA VpiDefName G=%s O=%s\n",std::string(L->VpiDefName()).c_str(),std::string(R->VpiDefName()).c_str());
  VFIELD(Programs); VFIELD(Program_arrays); VFIELD(Class_defns); VFIELD(Task_funcs);
  VFIELD(Nets); VFIELD(Array_nets); VFIELD(Spec_params); VFIELD(Assertions);
  SFIELD(Module_inst); SFIELD(Instance);
  printf("-- package::Compare order\n");
  printf("SCA VpiType G=%d O=%d  VpiUnit G=%d O=%d  VpiEndLabel G=[%s] O=[%s]\n",
         L->VpiType(),R->VpiType(),(int)L->VpiUnit(),(int)R->VpiUnit(),
         std::string(L->VpiEndLabel()).c_str(),std::string(R->VpiEndLabel()).c_str());
  return 0;
}
