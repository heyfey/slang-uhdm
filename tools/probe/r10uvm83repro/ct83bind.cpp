// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
//
// WHICH RHS OBJECT WAS GOLDEN'S `package uvm_pkg #1` COMPARED AGAINST?
// uhdm-cmp prints `m_failedLhs` and `m_failedRhs` only.  When the head is
// `LHS: package uvm_pkg / RHS: <null>` the *pairing* is invisible, and the
// pairing is the whole question: golden's ELAB package is reached from inside
// some reference, and if OUR reference lands on a DIFFERENT package object the
// two objects' vectors need not line up at all.
//
// Method: run the official design::Compare, snapshot m_visited AT THE FAILURE,
// then call `goldenHead->Compare(candidate)` for EVERY package in ours, from a
// context seeded with that snapshot MINUS the head itself (the head was entered
// by the real walk, so it must be removed or the guard returns 0 instantly).
// The candidate that reproduces (failedLhs=head, failedRhs=null) is the object
// the real walk paired the head with.
//
//   usage: ct83bind <golden.uhdm> <ours.uhdm>
// build: g++ -O2 -std=c++17 ct83bind.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83bind
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
  snprintf(b,sizeof b,"%s(%s)#%u@%s:%u:%u",std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(),o->UhdmId(),base(o->VpiFile()).c_str(),
           o->VpiLineNo(),(unsigned)o->VpiColumnNo());
  return b;
}
static design* getdesign(Serializer& s,const char* p){
  auto restored=s.Restore(std::string(p));
  for(auto h:restored){auto* o=(BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) return (design*)o;}
  return nullptr;
}
#define SHOW(NAME) printf("   %-22s G=%-8s O=%-8s\n",#NAME, \
   L->NAME()?("n="+std::to_string(L->NAME()->size())).c_str():"NULL", \
   R->NAME()?("n="+std::to_string(R->NAME()->size())).c_str():"NULL")
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83bind <golden> <ours>\n");return 2;}
  Serializer sg,so;
  design* dg=getdesign(sg,argv[1]); design* dr=getdesign(so,argv[2]);
  if(!dg||!dr){printf("NO_DESIGN\n");return 2;}
  std::vector<const any*> snap; const BaseClass* head=nullptr;
  { CompareContext ctx; int32_t r=dg->Compare(dr,&ctx);
    printf("OFFICIAL r=%d visited=%zu\n  LHS %s\n  RHS %s\n",r,ctx.m_visited.size(),
           ident(ctx.m_failedLhs).c_str(),ident(ctx.m_failedRhs).c_str());
    if(r==0){printf("EQUAL\n");return 0;}
    head=ctx.m_failedLhs;
    snap.assign(ctx.m_visited.begin(),ctx.m_visited.end()); }
  if(!head||head->UhdmType()!=uhdmpackage){printf("HEAD NOT A PACKAGE\n");return 0;}
  const package* L=(const package*)head;
  std::vector<const package*> cand;
  if(auto* v=dr->AllPackages()) for(auto* p:*v) cand.push_back(p);
  if(auto* v=dr->TopPackages()) for(auto* p:*v) cand.push_back(p);
  printf("HEAD (golden) %s\n",ident(L).c_str());
  for(auto* R:cand){
    CompareContext c; for(auto* p:snap) if(p!=(const any*)L) c.m_visited.insert(p);
    int32_t r=L->Compare(R,&c);
    bool match = (c.m_failedLhs==(const BaseClass*)L && c.m_failedRhs==nullptr && r!=0);
    printf("CAND %-40s r=%-4d failedLhs=%s failedRhs=%s %s\n",ident(R).c_str(),r,
           ident(c.m_failedLhs).c_str(),ident(c.m_failedRhs).c_str(),
           match?"  <== REPRODUCES THE OFFICIAL HEAD":"");
    if(match){
      printf("   -- the two objects' compared vectors, in compare order:\n");
      SHOW(Property_decls); SHOW(Sequence_decls); SHOW(Concurrent_assertions);
      SHOW(Named_events); SHOW(Named_event_arrays); SHOW(Variables);
      SHOW(Virtual_interface_vars); SHOW(Logic_vars); SHOW(Array_vars);
      SHOW(Array_var_mems); SHOW(Parameters); SHOW(Param_assigns);
      SHOW(Scopes); SHOW(Typespecs); SHOW(Instance_items); SHOW(Let_decls);
      SHOW(Attributes); SHOW(Programs); SHOW(Program_arrays); SHOW(Class_defns);
      SHOW(Task_funcs); SHOW(Nets); SHOW(Array_nets); SHOW(Spec_params); SHOW(Assertions);
      printf("   VpiTop G=%d O=%d  VpiName G=%s O=%s  VpiDefName G=%s O=%s\n",
             (int)L->VpiTop(),(int)R->VpiTop(),std::string(L->VpiName()).c_str(),
             std::string(R->VpiName()).c_str(),std::string(L->VpiDefName()).c_str(),
             std::string(R->VpiDefName()).c_str());
    }
  }
  return 0;
}
