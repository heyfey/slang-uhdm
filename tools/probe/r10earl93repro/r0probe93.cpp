// r10earl93 — R0 DECODE PROBE (MEASUREMENT ONLY).  Print one instance's
// module-level relations on both sides so an `RHS: <null>` head can be
// attributed to an OWNER rather than to the pointee the head names.
// build: g++ -O2 -std=c++17 r0probe93.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o r0probe93
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
static std::string sp(const BaseClass* o){ if(!o) return "-"; char b[64]; snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo()); return b; }
static std::string kn(const BaseClass* o){ return o? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>"); }
int main(int argc,char**argv){
  if(argc<3){fprintf(stderr,"usage: r0probe93 <db.uhdm> <instFullName>\n");return 2;}
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::string want=argv[2];
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo||bo->UhdmType()!=uhdmmodule_inst) continue;
    const module_inst*mi=(const module_inst*)bo;
    if(std::string(mi->VpiFullName())!=want) continue;
    printf("INST %s def=%s span=%s\n",std::string(mi->VpiFullName()).c_str(),
           std::string(mi->VpiDefName()).c_str(),sp(mi).c_str());
    if(mi->Ports()) for(auto*p:*mi->Ports())
      printf("  PORT %-14s span=%-16s dir=%d HIGH=%-12s(%s) LOW=%-12s(%s)\n",
        std::string(p->VpiName()).c_str(),sp(p).c_str(),p->VpiDirection(),
        kn(p->High_conn()).c_str(),sp(p->High_conn()).c_str(),
        kn(p->Low_conn()).c_str(),sp(p->Low_conn()).c_str());
    if(mi->Nets()) for(auto*n:*mi->Nets())
      printf("  NET  %-14s span=%-16s kind=%s\n",std::string(n->VpiName()).c_str(),sp(n).c_str(),kn(n).c_str());
    if(mi->Cont_assigns()) for(auto*c:*mi->Cont_assigns())
      printf("  CA   span=%-16s LHS=%-12s(%s) RHS=%s(%s)\n",sp(c).c_str(),
        kn(c->Lhs()).c_str(),sp(c->Lhs()).c_str(),kn(c->Rhs()).c_str(),sp(c->Rhs()).c_str());
    if(mi->Variables()) for(auto*v:*mi->Variables())
      printf("  VAR  %-14s span=%-16s kind=%s\n",std::string(v->VpiName()).c_str(),sp(v).c_str(),kn(v).c_str());
    printf("  gen_scope_arrays=%zu\n", mi->Gen_scope_arrays()?mi->Gen_scope_arrays()->size():0);
  }
  return 0;
}
