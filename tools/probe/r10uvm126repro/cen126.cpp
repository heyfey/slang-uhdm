// r10uvm126 — UNPACKED-ARRAY ELEMENT-TYPESPEC census.  One CELL per variable /
// net / io_decl / typespec_member whose typespec is an array_typespec (or a
// packed_array_typespec), naming the ELEMENT typespec's KIND, NAME, SPAN,
// vpiSigned, vpiInstance and range count.
//
//     CELL \t SITE \t OWNER \t ARRAYTS \t ELEM
//
// SITE    = the owner's parent chain (kinds + names, NO ids, NO file)
// OWNER   = owner kind | owner name | owner span
// ARRAYTS = array-typespec kind | span | nranges | indexTs kind
// ELEM    = element typespec kind | name | span | signed | instance kind(name)
//           | nranges
//
// A second family of cells names every array_typespec that NO owner reaches
// (both producers leave some unparented):
//     ORPHANTS \t <arrayts kind|span|nranges> \t <elem ...>
//
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cen126 <db.uhdm> [owner-name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;

static std::string sp(const any* p) {
  if (!p) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)p->VpiLineNo(),
           (unsigned)p->VpiColumnNo(), (unsigned)p->VpiEndLineNo(),
           (unsigned)p->VpiEndColumnNo());
  return b;
}
static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  return e;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 10 && p; i++) {
    r = r.empty() ? node(p) : (node(p) + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static const typespec* actual(const ref_typespec* r) {
  return r ? r->Actual_typespec() : nullptr;
}
// The typespec a "thing that has one" carries.
static const typespec* tsOf(const any* a) {
  switch (a->UhdmType()) {
    case uhdmarray_var:   return actual(((const array_var*)a)->Typespec());
    case uhdmarray_net:   return actual(((const array_net*)a)->Typespec());
    case uhdmio_decl:     return actual(((const io_decl*)a)->Typespec());
    case uhdmtypespec_member:
      return actual(((const typespec_member*)a)->Typespec());
    case uhdmparameter:   return actual(((const parameter*)a)->Typespec());
    default: break;
  }
  if (const variables* v = any_cast<const variables*>(a))
    return actual(v->Typespec());
  if (const nets* n = any_cast<const nets*>(a)) return actual(n->Typespec());
  return nullptr;
}
static std::string elemStr(const typespec* e) {
  if (!e) return "<null>";
  std::string r(UhdmName(e->UhdmType()));
  r += "|" + std::string(e->VpiName());
  r += "|" + sp(e);
  int nr = 0;
  switch (e->UhdmType()) {
    case uhdmlogic_typespec:
      nr = ((const logic_typespec*)e)->Ranges()
               ? (int)((const logic_typespec*)e)->Ranges()->size() : 0; break;
    case uhdmbit_typespec:
      nr = ((const bit_typespec*)e)->Ranges()
               ? (int)((const bit_typespec*)e)->Ranges()->size() : 0; break;
    case uhdmint_typespec:
      nr = ((const int_typespec*)e)->Ranges()
               ? (int)((const int_typespec*)e)->Ranges()->size() : 0; break;
    default: break;
  }
  r += "|nr=" + std::to_string(nr);
  r += "|inst=" + (e->Instance()
                       ? std::string(UhdmName(e->Instance()->UhdmType())) + "(" +
                             std::string(e->Instance()->VpiName()) + ")"
                       : std::string("-"));
  return r;
}
// The element VARIABLE the array_var lists under vpiReg / vpiVariables.
static std::string regStr(const any* a) {
  if (a->UhdmType() != uhdmarray_var) return "-";
  auto* vs = ((const array_var*)a)->Variables();
  if (!vs || vs->empty()) return "-";
  std::string r;
  for (auto* v : *vs) {
    if (!r.empty()) r += ",";
    r += std::string(UhdmName(v->UhdmType()));
  }
  return r;
}
static std::string arrStr(const typespec* t, const typespec** elemOut) {
  std::string r(UhdmName(t->UhdmType()));
  r += "|" + sp(t);
  const typespec* e = nullptr;
  int nr = 0;
  std::string idx = "-";
  if (t->UhdmType() == uhdmarray_typespec) {
    auto* a = (const array_typespec*)t;
    e = actual(a->Elem_typespec());
    nr = a->Ranges() ? (int)a->Ranges()->size() : 0;
    if (auto* it = actual(a->Index_typespec()))
      idx = std::string(UhdmName(it->UhdmType()));
  } else if (t->UhdmType() == uhdmpacked_array_typespec) {
    auto* a = (const packed_array_typespec*)t;
    e = actual(a->Elem_typespec());
    nr = a->Ranges() ? (int)a->Ranges()->size() : 0;
  }
  r += "|nr=" + std::to_string(nr) + "|idx=" + idx;
  *elemOut = e;
  return r;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen126 <db> [substr]\n"); return 2; }
  std::string filt = (argc > 2) ? argv[2] : "";
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  std::set<const any*> reached;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    const typespec* t = tsOf(a);
    if (!t) continue;
    if (t->UhdmType() != uhdmarray_typespec &&
        t->UhdmType() != uhdmpacked_array_typespec) continue;
    if (!filt.empty() &&
        std::string(a->VpiName()).find(filt) == std::string::npos) continue;
    reached.insert(t);
    const typespec* e = nullptr;
    std::string at = arrStr(t, &e);
    printf("CELL\t%s\t%s|%s|%s\t%s\t%s\treg=%s\n", chainOf(a).c_str(),
           std::string(UhdmName(a->UhdmType())).c_str(),
           std::string(a->VpiName()).c_str(),
           sp(a).c_str(), at.c_str(), elemStr(e).c_str(), regStr(a).c_str());
  }
  if (!filt.empty()) return 0;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    if (a->UhdmType() != uhdmarray_typespec &&
        a->UhdmType() != uhdmpacked_array_typespec) continue;
    if (reached.count(a)) continue;
    const typespec* e = nullptr;
    std::string at = arrStr((const typespec*)a, &e);
    printf("ORPHANTS\t%s\t%s\t%s\n", chainOf(a).c_str(), at.c_str(),
           elemStr(e).c_str());
  }
  return 0;
}
