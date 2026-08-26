// r10earl99 -- MEASUREMENT ONLY.  THE LAW'S POPULATION, counted on a database
// BEFORE a line of the law was written.
//
// The shape: a `cont_assign` whose Rhs is an `operation` and whose CONDITIONAL
// CHAIN (vpiConditionOp, ops[1]/ops[2] only, nested arbitrarily deep --
// exactly the recursion of UHDM ExprEval::flattenPatternAssignments and
// Surelog CompileHelper::expandPatternAssignment) reaches an
// `operation(vpiAssignmentPatternOp)`.  For each such pattern it reports
//   * whether any DIRECT operand is a constant of VpiSize() == -1
//     (an unbased unsized literal that has not been re-typed), and
//   * the number of direct operands.
//
//   PAT <db> <home> <ca-line> <pat-span> ops=<n> unsized=<n>
//   SUM <db> pats=<n> unsized=<n>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static const char* g_db="?";
static int g_pats=0, g_uns=0; static int g_direct=0;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}

static void report(const operation* op, const std::string& own, uint32_t caln){
  int nops=0, nuns=0;
  if(op->Operands()) for(auto* o : *op->Operands()){
    nops++;
    if(o->UhdmType()==uhdmconstant && ((const constant*)o)->VpiSize()==-1) nuns++;
    if(o->UhdmType()==uhdmtagged_pattern){
      const any* p=((const tagged_pattern*)o)->Pattern();
      if(p && p->UhdmType()==uhdmconstant && ((const constant*)p)->VpiSize()==-1) nuns++;
    }
  }
  g_pats++; g_uns+=nuns;
  int mx=0; std::string szs;
  if(op->Operands()) for(auto* o : *op->Operands()){
    int z = 0; if(const expr* x=any_cast<const expr*>(o)) z=x->VpiSize();
    if(z>mx) mx=z; szs += (szs.empty()?"":",") + std::to_string(z);
  }
  printf("PAT %s %s %u %s ops=%d unsized=%d maxsz=%d szs=%s%s\n", g_db, own.c_str(), caln, sp(op).c_str(), nops, nuns, mx, szs.c_str(), g_direct?" DIRECT":" CHAIN");
}
static void chain(const any* e, const std::string& own, uint32_t caln, int d){
  if(!e || d>32 || e->UhdmType()!=uhdmoperation) return;
  auto* op=(const operation*)e;
  int t=op->VpiOpType();
  if(t==vpiConditionOp){
    if(op->Operands() && op->Operands()->size()>=3){
      chain(op->Operands()->at(1), own, caln, d+1);
      chain(op->Operands()->at(2), own, caln, d+1);
    }
    return;
  }
  if(t==vpiAssignmentPatternOp) report(op, own, caln);
}
static void do_ca(const VectorOfcont_assign* cas, const std::string& own){
  if(!cas) return;
  for(auto* ca : *cas){
    const any* r=ca->Rhs();
    if(!r || r->UhdmType()!=uhdmoperation) continue;
    int ot=((const operation*)r)->VpiOpType();
    if(ot==vpiAssignmentPatternOp){ g_direct=1; report((const operation*)r, own, ca->VpiLineNo()); g_direct=0; continue; }
    if(ot!=vpiConditionOp) continue;
    g_direct=0; chain(r, own, ca->VpiLineNo(), 0);
  }
}
static void do_scope(const scope* sc, const std::string& own);
static void do_inst(const instance* in){
  std::string own(in->VpiFullName());
  if(auto* m=any_cast<const module_inst*>(in)){
    do_ca(m->Cont_assigns(), own);
    if(m->Modules()) for(auto* c:*m->Modules()) do_inst(c);
    if(m->Interfaces()) for(auto* c:*m->Interfaces()) do_inst(c);
    if(m->Gen_scope_arrays()) for(auto* ga:*m->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto* g:*ga->Gen_scopes()) do_scope(g,own);
  } else if(auto* i=any_cast<const interface_inst*>(in)){
    do_ca(i->Cont_assigns(), own);
    if(i->Gen_scope_arrays()) for(auto* ga:*i->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto* g:*ga->Gen_scopes()) do_scope(g,own);
  }
}
static void do_scope(const scope* sc, const std::string& own){
  auto* g=any_cast<const gen_scope*>(sc); if(!g) return;
  std::string me=own+"."+std::string(g->VpiName());
  do_ca(g->Cont_assigns(), me);
  if(g->Modules()) for(auto* c:*g->Modules()) do_inst(c);
  if(g->Interfaces()) for(auto* c:*g->Interfaces()) do_inst(c);
  if(g->Gen_scope_arrays()) for(auto* ga:*g->Gen_scope_arrays()) if(ga->Gen_scopes()) for(auto* s:*ga->Gen_scopes()) do_scope(s,me);
}
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: pop99 <db.uhdm> [label]\n");return 2;}
  g_db = argc>2 ? argv[2] : argv[1];
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED %s\n",g_db);return 3;}
  for(vpiHandle h:r){
    const any*o=(const any*)((const uhdm_handle*)h)->object;
    auto*d=any_cast<const design*>(o); if(!d) continue;
    if(d->TopModules()) for(auto*m:*d->TopModules()) do_inst(m);
    if(d->AllModules()) for(auto*m:*d->AllModules()) do_inst(m);
  }
  printf("SUM %s pats=%d unsized=%d\n", g_db, g_pats, g_uns);
  return 0;
}
