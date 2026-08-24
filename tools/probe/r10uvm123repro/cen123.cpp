// r10uvm123 — USE-SITE census of package-typedef typespecs.
// For every ref_typespec whose Actual_typespec is a NAMED vector/array typespec
// instanced at a package, print one CELL:
//     SITE \t REFFULL \t PAYLOAD
// SITE   = the ref_typespec's parent chain, kinds+names+spans, NO object ids
//          (ids are not comparable across the two producers).
// PAYLOAD= target kind | target VpiName | range0 Left shape | range0 Right shape
//          | alias target name (or '-') | instance name
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cen123 <db.uhdm> [name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string shp(const any* e) {
  if (!e) return "<null>";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    return "C{" + std::string(c->VpiValue()) + ",ct=" +
           std::to_string(c->VpiConstType()) + "}";
  }
  if (e->UhdmType() == uhdmoperation)
    return "OP" + std::to_string(((const operation*)e)->VpiOpType());
  if (e->UhdmType() == uhdmref_obj) return "REF(" + std::string(e->VpiName()) + ")";
  return std::string(UhdmName(e->UhdmType()));
}
static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  if (p->UhdmType() == uhdmoperation)
    e += "{op" + std::to_string(((const operation*)p)->VpiOpType()) + "}";
  if (p->VpiLineNo())
    e += "@" + std::to_string((unsigned)p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo());
  return e;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 14 && p; i++) {
    r = r.empty() ? node(p) : (node(p) + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static const VectorOfrange* rangesOf(const any* a) {
  switch (a->UhdmType()) {
    case uhdmbit_typespec: return ((const bit_typespec*)a)->Ranges();
    case uhdmlogic_typespec: return ((const logic_typespec*)a)->Ranges();
    case uhdmarray_typespec: return ((const array_typespec*)a)->Ranges();
    case uhdmpacked_array_typespec: return ((const packed_array_typespec*)a)->Ranges();
    case uhdmint_typespec: return ((const int_typespec*)a)->Ranges();
    default: return nullptr;
  }
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen123 <db> [substr]\n"); return 2; }
  std::string filt = (argc > 2) ? argv[2] : "";
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  auto all = s.AllObjects();
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_typespec) continue;
    auto* rt = (const ref_typespec*)a;
    const typespec* t = rt->Actual_typespec();
    if (!t) continue;
    auto* rs = rangesOf(t);
    if (!rs) continue;                       // vector/array typespecs only
    if (t->VpiName().empty()) continue;      // NAMED typedef objects only
    if (!filt.empty() &&
        std::string(t->VpiName()).find(filt) == std::string::npos) continue;
    if (!t->Instance() || t->Instance()->UhdmType() != uhdmpackage) continue;
    std::string L = "-", R = "-";
    if (!rs->empty()) { L = shp((*rs)[0]->Left_expr()); R = shp((*rs)[0]->Right_expr()); }
    std::string al = "-";
    if (auto* ar = t->Typedef_alias())
      al = ar->Actual_typespec() ? std::string(ar->Actual_typespec()->VpiName())
                                 : std::string("<null>");
    printf("CELL\t%s\t%s\t%s|%s|%s|%s|%s|%s|nr=%u\n", chainOf(rt).c_str(),
           std::string(rt->VpiFullName()).c_str(),
           std::string(UhdmName(t->UhdmType())).c_str(),
           std::string(t->VpiName()).c_str(), L.c_str(), R.c_str(), al.c_str(),
           std::string(t->Instance()->VpiName()).c_str(),
           (unsigned)(rs ? rs->size() : 0));
  }
  return 0;
}
