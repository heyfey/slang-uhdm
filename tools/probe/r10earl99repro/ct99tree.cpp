// r10earl99 -- MEASUREMENT ONLY.  Print the RHS TREE of every cont_assign of a
// named module instance (or every cont_assign at a given source line), read
// straight from a .uhdm (Earlgrey's uhdm-dump is gigabytes).
//   usage: ct99tree <db.uhdm> <substring-of-instance-fullname> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string tsof(const any*e){
  const expr*x=any_cast<const expr*>(e); if(!x) return "-";
  const ref_typespec*rt=x->Typespec(); if(!rt) return "-";
  const typespec*t=rt->Actual_typespec(); if(!t) return "ref<null>";
  return kn(t)+"("+std::string(t->VpiName())+")";
}
static void walk(const any*e,int d){
  if(!e){printf("%*s<null>\n",d*2,"");return;}
  for(int i=0;i<d;i++) printf("  ");
  printf("%s @%s", kn(e).c_str(), sp(e).c_str());
  if(!e->VpiName().empty()) printf(" name=%s", std::string(e->VpiName()).c_str());
  if(e->UhdmType()==uhdmoperation) printf(" op=%d", ((const operation*)e)->VpiOpType());
  if(const expr* xx=any_cast<const expr*>(e)) printf(" SZ=%d", xx->VpiSize());
  if(e->UhdmType()==uhdmconstant){auto*c=(const constant*)e;
    printf(" ct=%d sz=%d val=%s dec=%s", c->VpiConstType(), c->VpiSize(),
           std::string(c->VpiValue()).c_str(), std::string(c->VpiDecompile()).c_str());}
  printf(" ts=%s parent=%s@%s\n", tsof(e).c_str(), kn(e->VpiParent()).c_str(), sp(e->VpiParent()).c_str());
  switch(e->UhdmType()){
    case uhdmoperation:{auto*o=(const operation*)e; if(o->Operands()) for(auto*x:*o->Operands()) walk(x,d+1); break;}
    case uhdmtagged_pattern:{auto*t=(const tagged_pattern*)e;
      for(int i=0;i<d+1;i++) printf("  ");
      printf("[key ts=%s]\n", tsof(e).c_str());
      walk(t->Pattern(),d+1); break;}
    case uhdmpart_select: case uhdmindexed_part_select: case uhdmbit_select: break;
    default: break;
  }
}
static const char* g_pat=nullptr; static int g_line=0;
static void do_ca(const VectorOfcont_assign*cas,const std::string&own){
  if(!cas) return;
  for(auto*ca:*cas){
    if(g_line && (int)ca->VpiLineNo()!=g_line) continue;
    printf("=== CA %s line %u:%u-%u:%u\n", own.c_str(), ca->VpiLineNo(), ca->VpiColumnNo(), ca->VpiEndLineNo(), ca->VpiEndColumnNo());
    printf("  LHS: "); walk(ca->Lhs(),1);
    printf("  RHS:\n"); walk(ca->Rhs(),2);
  }
}
static void do_scope(const scope*sc,const std::string&own);
static void do_inst(const instance*in){
  std::string own(in->VpiFullName());
  bool hit = !g_pat || own.find(g_pat)!=std::string::npos;
  if(auto*m=any_cast<const module_inst*>(in)){
    if(hit) do_ca(m->Cont_assigns(),own);
    if(m->Modules()) for(auto*c:*m->Modules()) do_inst(c);
    if(m->Gen_scope_arrays()) for(auto*ga:*m->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g:*ga->Gen_scopes()) do_scope(g,own);
  } else if(auto*i=any_cast<const interface_inst*>(in)){
    if(hit) do_ca(i->Cont_assigns(),own);
    if(i->Gen_scope_arrays()) for(auto*ga:*i->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*g:*ga->Gen_scopes()) do_scope(g,own);
  }
}
static void do_scope(const scope*sc,const std::string&own){
  auto*g=any_cast<const gen_scope*>(sc); if(!g) return;
  std::string me=own+"."+std::string(g->VpiName());
  if(!g_pat||me.find(g_pat)!=std::string::npos) do_ca(g->Cont_assigns(),me);
  if(g->Modules()) for(auto*c:*g->Modules()) do_inst(c);
  if(g->Gen_scope_arrays()) for(auto*ga:*g->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto*s:*ga->Gen_scopes()) do_scope(s,me);
}
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: ct99tree <db.uhdm> [instsubstr] [line]\n");return 2;}
  g_pat = argc>2 ? argv[2] : nullptr;
  g_line = argc>3 ? atoi(argv[3]) : 0;
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  for(vpiHandle h:r){
    const any*o=(const any*)((const uhdm_handle*)h)->object;
    auto*d=any_cast<const design*>(o); if(!d) continue;
    if(d->TopModules()) for(auto*m:*d->TopModules()) do_inst(m);
  }
  return 0;
}
