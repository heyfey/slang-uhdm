// r11u106 tw106 — the RANGE-BOUND walker.  Walks a UHDM database along the
// judge's containers (AllModules / TopModules recursively through gen scopes and
// sub-instances, AllPackages, AllInterfaces) and prints EVERY range bound
// reachable from a home's typespec, with the path that reaches it (no dedupe,
// cycle-guarded).  Measurement-only.
//   tw106 <db.uhdm>        one line per bound:  PATH \t L|R \t SUMMARY
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;
static std::set<const any*> onpath;
static std::string loc(const any* o) {
  if (!o->VpiLineNo()) return "@-";
  return "@" + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}
static std::string summ(const any* e) {
  if (!e) return "<null>";
  std::string s = UhdmName(e->UhdmType());
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    s += " " + std::string(c->VpiValue()) + " sz" + std::to_string(c->VpiSize()) +
         " ct" + std::to_string(c->VpiConstType()) + " dc=" + std::string(c->VpiDecompile());
  } else if (e->UhdmType() == uhdmoperation) {
    auto* o = (const operation*)e;
    s += " op" + std::to_string(o->VpiOpType()) + "(";
    if (o->Operands())
      for (auto* x : *o->Operands()) {
        s += UhdmName(x->UhdmType());
        if (!x->VpiName().empty()) s += ":" + std::string(x->VpiName());
        s += ",";
      }
    s += ")";
  } else if (!e->VpiName().empty()) s += ":" + std::string(e->VpiName());
  return s + " " + loc(e) + " #" + std::to_string(e->UhdmId());
}
static void ts(const std::string& p, const any* t);
static void ranges(const std::string& p, const VectorOfrange* rs) {
  if (!rs) return;
  int i = 0;
  for (auto* r : *rs) {
    std::string q = p + "/range" + std::to_string(i++) + loc(r);
    std::cout << q << "\tL\t" << summ(r->Left_expr()) << "\n";
    std::cout << q << "\tR\t" << summ(r->Right_expr()) << "\n";
  }
}
static void rts(const std::string& p, const ref_typespec* rt) {
  if (rt) ts(p, rt->Actual_typespec());
}
static void ts(const std::string& p0, const any* t) {
  if (!t || onpath.count(t)) return;
  onpath.insert(t);
  std::string p = p0 + "/" + UhdmName(t->UhdmType()) +
                  (t->VpiName().empty() ? "" : "(" + std::string(t->VpiName()) + ")") +
                  loc(t) + "#" + std::to_string(t->UhdmId());
  switch (t->UhdmType()) {
    case uhdmlogic_typespec: ranges(p, ((const logic_typespec*)t)->Ranges()); break;
    case uhdmbit_typespec: ranges(p, ((const bit_typespec*)t)->Ranges()); break;
    case uhdmarray_typespec:
      ranges(p, ((const array_typespec*)t)->Ranges());
      rts(p + "/elem", ((const array_typespec*)t)->Elem_typespec());
      break;
    case uhdmpacked_array_typespec:
      ranges(p, ((const packed_array_typespec*)t)->Ranges());
      rts(p + "/elem", ((const packed_array_typespec*)t)->Elem_typespec());
      break;
    case uhdmstruct_typespec:
      if (auto* m = ((const struct_typespec*)t)->Members())
        for (auto* x : *m) rts(p + "/m:" + std::string(x->VpiName()), x->Typespec());
      break;
    case uhdmunion_typespec:
      if (auto* m = ((const union_typespec*)t)->Members())
        for (auto* x : *m) rts(p + "/m:" + std::string(x->VpiName()), x->Typespec());
      break;
    default: break;
  }
  onpath.erase(t);
}
static void exprts(const std::string& p, const any* e, int d = 0) {
  if (!e || d > 12) return;
  std::string ek = UhdmName(e->UhdmType());
  if (e->UhdmType() == uhdmoperation) ek += std::to_string(((const operation*)e)->VpiOpType());
  if (auto* x = dynamic_cast<const expr*>(e)) rts(p + "/" + ek + loc(e) + ".ts", x->Typespec());
  if (e->UhdmType() == uhdmoperation) {
    auto* o = (const operation*)e;
    if (o->Operands()) {
      int i = 0;
      for (auto* x : *o->Operands()) exprts(p + "/op" + std::to_string(o->VpiOpType()) + "." + std::to_string(i++), x, d + 1);
    }
  } else if (e->UhdmType() == uhdmtagged_pattern) {
    exprts(p + "/tp", ((const tagged_pattern*)e)->Pattern(), d + 1);
  }
}
static void scope_(const std::string& p, const scope* s) {
  if (auto* v = s->Parameters())
    for (auto* x : *v) {
      std::string q = p + "/param(" + std::string(x->VpiName()) + ")";
      if (x->UhdmType() == uhdmparameter) rts(q, ((const parameter*)x)->Typespec());
      if (x->UhdmType() == uhdmtype_parameter) rts(q, ((const type_parameter*)x)->Typespec());
    }
  if (auto* v = s->Param_assigns())
    for (auto* x : *v) {
      std::string nm = x->Lhs() ? std::string(x->Lhs()->VpiName()) : "?";
      exprts(p + "/pa(" + nm + ").rhs", x->Rhs());
      if (auto* l = x->Lhs()) {
        if (l->UhdmType() == uhdmparameter) rts(p + "/pa(" + nm + ").lhs", ((const parameter*)l)->Typespec());
        if (l->UhdmType() == uhdmtype_parameter) rts(p + "/pa(" + nm + ").lhs", ((const type_parameter*)l)->Typespec());
      }
    }
  if (auto* v = s->Typespecs())
    for (auto* x : *v) ts(p + "/typedef", x);
  if (auto* v = s->Variables())
    for (auto* x : *v) rts(p + "/var(" + std::string(x->VpiName()) + ")", x->Typespec());
}
static void inst(const std::string& p0, const any* i) {
  if (!i) return;
  std::string p = p0 + "/" + UhdmName(i->UhdmType()) + "(" + std::string(i->VpiName()) + ")";
  scope_(p, (const scope*)i);
  auto nets = [&](const VectorOfnet* v) {
    if (v) for (auto* x : *v) rts(p + "/net(" + std::string(x->VpiName()) + ")", x->Typespec());
  };
  if (i->UhdmType() == uhdmmodule_inst) {
    auto* m = (const module_inst*)i;
    nets(m->Nets());
    if (m->Ports()) for (auto* x : *m->Ports()) rts(p + "/port(" + std::string(x->VpiName()) + ")", x->Typespec());
    if (m->Modules()) for (auto* x : *m->Modules()) inst(p, x);
    if (m->Interfaces()) for (auto* x : *m->Interfaces()) inst(p, x);
    if (m->Gen_scope_arrays()) for (auto* g : *m->Gen_scope_arrays())
      if (g->Gen_scopes()) for (auto* s : *g->Gen_scopes()) inst(p + "/gsa(" + std::string(g->VpiName()) + ")", s);
  } else if (i->UhdmType() == uhdminterface_inst) {
    auto* m = (const interface_inst*)i;
    nets(m->Nets());
    if (m->Ports()) for (auto* x : *m->Ports()) rts(p + "/port(" + std::string(x->VpiName()) + ")", x->Typespec());
    if (m->Gen_scope_arrays()) for (auto* g : *m->Gen_scope_arrays())
      if (g->Gen_scopes()) for (auto* s : *g->Gen_scopes()) inst(p + "/gsa(" + std::string(g->VpiName()) + ")", s);
  } else if (i->UhdmType() == uhdmgen_scope) {
    auto* m = (const gen_scope*)i;
    nets(m->Nets());
    if (m->Modules()) for (auto* x : *m->Modules()) inst(p, x);
    if (m->Interfaces()) for (auto* x : *m->Interfaces()) inst(p, x);
    if (m->Gen_scope_arrays()) for (auto* g : *m->Gen_scope_arrays())
      if (g->Gen_scopes()) for (auto* s : *g->Gen_scopes()) inst(p + "/gsa(" + std::string(g->VpiName()) + ")", s);
  }
}
int main(int argc, char** argv) {
  Serializer s;
  auto h = s.Restore(std::filesystem::path(argv[1]));
  auto* d = (design*)((uhdm_handle*)h[0])->object;
  if (d->AllPackages()) for (auto* x : *d->AllPackages()) scope_("AllPkg(" + std::string(x->VpiName()) + ")", x);
  if (d->AllModules()) for (auto* x : *d->AllModules()) inst("AllMod", x);
  if (d->AllInterfaces()) for (auto* x : *d->AllInterfaces()) inst("AllIf", x);
  if (d->TopModules()) for (auto* x : *d->TopModules()) inst("Top", x);
  return 0;
}
