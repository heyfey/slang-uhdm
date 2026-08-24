// r10uvm123 — every vpiCastOp whose target typespec is a NAMED typespec
// instanced at a package: the site, the enclosing package object AND WHICH
// DESIGN LIST it belongs to (TopPackages = the ELABORATED view, AllPackages =
// the DEF view), and the target's judge-visible fields.
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cast123 <db.uhdm> [name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
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
  return std::string(UhdmName(e->UhdmType()));
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
// Object ids are NOT comparable across the two producers, so they are OFF by
// default (the census payload has to join golden against ours).  CAST123_IDS=1
// turns them on for head decoding.
static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  if (getenv("CAST123_IDS")) e += "#" + std::to_string((unsigned)p->UhdmId());
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  if (p->VpiLineNo())
    e += "@" + std::to_string((unsigned)p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo());
  return e;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cast123 <db> [substr]\n"); return 2; }
  std::string filt = (argc > 2) ? argv[2] : "";
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  std::set<const BaseClass*> topPkgs, allPkgs;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) topPkgs.insert(p);
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) allPkgs.insert(p);
  }
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmoperation) continue;
    auto* op = (const operation*)a;
    if (op->VpiOpType() != vpiCastOp) continue;
    const ref_typespec* rt = op->Typespec();
    const typespec* t = rt ? rt->Actual_typespec() : nullptr;
    if (!t || t->VpiName().empty()) continue;
    if (!filt.empty() &&
        std::string(t->VpiName()).find(filt) == std::string::npos) continue;
    // Which view does the cast site live in?
    const char* view = "OTHER";
    std::string owner = "-";
    for (const any* p = a->VpiParent(); p; p = p->VpiParent()) {
      if (p->UhdmType() == uhdmpackage) {
        owner = node(p);
        view = topPkgs.count(p) ? "TOPPKG" : (allPkgs.count(p) ? "ALLPKG" : "PKG?");
        break;
      }
      if (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdminterface_inst ||
          p->UhdmType() == uhdmprogram) { owner = node(p); view = "MODULE"; break; }
    }
    auto* rs = rangesOf(t);
    std::string L = "-", R = "-";
    if (rs && !rs->empty()) { L = shp((*rs)[0]->Left_expr()); R = shp((*rs)[0]->Right_expr()); }
    std::string al = "-";
    if (auto* ar = t->Typedef_alias())
      al = ar->Actual_typespec() ? std::string(ar->Actual_typespec()->VpiName())
                                 : std::string("<null>");
    printf("CAST %s op@%u:%u-%u:%u tgt=%s name=%s L=%s R=%s alias=%s inst=%s\n",
           view, (unsigned)a->VpiLineNo(), a->VpiColumnNo(),
           (unsigned)a->VpiEndLineNo(), a->VpiEndColumnNo(),
           std::string(UhdmName(t->UhdmType())).c_str(),
           std::string(t->VpiName()).c_str(), L.c_str(), R.c_str(), al.c_str(),
           t->Instance() ? node(t->Instance()).c_str() : "-");
  }
  return 0;
}
