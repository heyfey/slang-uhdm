// pkgsig_db <db.uhdm>: for every subroutine of every package in uhdmtopPackages and uhdmallPackages, each
// ref_obj inside its return / io_decl typespec ranges: the object its Actual names -- TOP (the uhdmtopPackages
// param_assign Rhs of that name), ALL (the uhdmallPackages one), or another kind.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <functional>
#include <string>
using namespace UHDM;
std::map<const any*, std::string> rhsOf;
static void walkRange(const std::string& where, const any* o) {
  if (!o) return;
  if (o->UhdmType() == uhdmref_obj) {
    const any* a = ((const ref_obj*)o)->Actual_group();
    std::string k = a ? UhdmName(a->UhdmType()) : "null";
    auto it = rhsOf.find(a);
    printf("%s\t%s\t-> %s %s\n", where.c_str(), std::string(o->VpiName()).c_str(), k.c_str(),
           it != rhsOf.end() ? it->second.c_str() : "(other)");
    return;
  }
  if (o->UhdmType() == uhdmoperation) {
    if (auto* ops = ((const operation*)o)->Operands()) for (auto* x : *ops) walkRange(where, x);
  }
}
static void walkTs(const std::string& where, const typespec* t) {
  if (!t) return;
  const VectorOfrange* rs = nullptr;
  if (t->UhdmType() == uhdmlogic_typespec) rs = ((const logic_typespec*)t)->Ranges();
  else if (t->UhdmType() == uhdmbit_typespec) rs = ((const bit_typespec*)t)->Ranges();
  if (rs) for (auto* r : *rs) { walkRange(where, r->Left_expr()); walkRange(where, r->Right_expr()); }
}
int main(int argc, char** argv) {
  Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  for (vpiHandle h : designs) {
    const design* d = (const design*)((const uhdm_handle*)h)->object;
    for (int top = 0; top < 2; ++top) {
      auto* v = top ? d->TopPackages() : d->AllPackages();
      if (!v) continue;
      for (auto* p : *v) if (p->Param_assigns()) for (auto* pa : *p->Param_assigns())
        rhsOf[pa->Rhs()] = std::string(top ? "TOP:" : "ALL:") + std::string(pa->Lhs()->VpiName()) +
                           (pa->Rhs() && pa->Rhs()->UhdmType() == uhdmconstant ? " size=" + std::to_string(((const constant*)pa->Rhs())->VpiSize()) : "");
    }
    for (int top = 0; top < 2; ++top) {
      auto* v = top ? d->TopPackages() : d->AllPackages();
      if (!v) continue;
      for (auto* p : *v) {
        if (!p->Task_funcs()) continue;
        for (auto* tf : *p->Task_funcs()) {
          std::string w = std::string(top ? "top " : "all ") + std::string(p->VpiName()) + "::" + std::string(tf->VpiName());
          if (tf->UhdmType() == uhdmfunction)
            if (auto* r = ((const function*)tf)->Return())
              if (auto* rt = r->Typespec()) walkTs(w + " return", rt->Actual_typespec());
          if (tf->Io_decls()) for (auto* io : *tf->Io_decls())
            if (auto* rt = io->Typespec()) walkTs(w + " io " + std::string(io->VpiName()), rt->Actual_typespec());
        }
      }
    }
  }
}
