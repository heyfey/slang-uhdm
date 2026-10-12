// r11u300: per package listing (ALL/TOP), each subroutine's top-level return and assignment expression trees with UhdmIds, parents, spans, values and bindings (decode helper; reads only the databases it is given)
// print, per package listing (all/top), each subroutine's top-level return expression trees with ids and parents
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
using namespace UHDM;
static void ex(const any* e, int d) {
  if (!e) return;
  std::string ind(d * 2 + 4, ' ');
  std::cout << ind << UhdmName(e->UhdmType()) << "#" << e->UhdmId() << " '" << e->VpiName() << "' "
            << e->VpiLineNo() << ":" << e->VpiColumnNo() << "-" << e->VpiEndLineNo() << ":" << e->VpiEndColumnNo()
            << " par=" << (e->VpiParent() ? std::to_string(e->VpiParent()->UhdmId()) + UhdmName(e->VpiParent()->UhdmType()) : "-");
  if (e->UhdmType() == uhdmconstant) std::cout << " val=" << ((const constant*)e)->VpiValue();
  if (e->UhdmType() == uhdmref_obj) { auto a = ((const ref_obj*)e)->Actual_group(); std::cout << " act=" << (a ? std::to_string(a->UhdmId()) + UhdmName(a->UhdmType()) : "-"); }
  std::cout << "\n";
  if (d > 4) return;
  if (e->UhdmType() == uhdmoperation) { auto o = (const operation*)e; if (o->Operands()) for (auto x : *o->Operands()) ex(x, d + 1); }
  if (auto t = any_cast<const tf_call*>(e)) { if (t->Tf_call_args()) for (auto x : *t->Tf_call_args()) ex(x, d + 1); }
}
static void walkStmt(const any* s) {
  if (!s) return;
  if (s->UhdmType() == uhdmreturn_stmt) { std::cout << "    return#" << s->UhdmId() << "\n"; ex(((const return_stmt*)s)->VpiCondition(), 1); }
  else if (s->UhdmType() == uhdmassignment) { std::cout << "    assign#" << s->UhdmId() << "\n"; ex(((const assignment*)s)->Rhs(), 1); }
  else if (s->UhdmType() == uhdmbegin) { auto b = (const begin*)s; if (b->Stmts()) for (auto x : *b->Stmts()) walkStmt(x); }
  else if (s->UhdmType() == uhdmnamed_begin) { auto b = (const named_begin*)s; if (b->Stmts()) for (auto x : *b->Stmts()) walkStmt(x); }
}
static void walkPkgs(const VectorOfpackage* v, const char* tag) {
  if (!v) return;
  for (auto p : *v) { std::cout << tag << " package " << p->VpiName() << "#" << p->UhdmId() << "\n";
    if (p->Task_funcs()) for (auto tf : *p->Task_funcs()) { std::cout << "  tf " << tf->VpiName() << "#" << tf->UhdmId() << "\n"; walkStmt(tf->Stmt()); } }
}
int main(int argc, char** argv) {
  Serializer s; auto ds = s.Restore(std::string(argv[1]));
  for (auto h : ds) { auto d = (const design*)((const uhdm_handle*)h)->object; walkPkgs(d->AllPackages(), "ALL"); walkPkgs(d->TopPackages(), "TOP"); }
}
