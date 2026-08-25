// r10uvm136 — CLASS-PROPERTY VARIABLE-KIND census.
//
// One CELL per variable listed in a class_defn's vpiVariables, plus the
// element variable of an array_var property.  It answers ONE question:
// which UHDM variables CLASS did each producer mint for the property, and
// what typespec did it bind?
//
//   CELL \t SITE \t IDX \t VAR \t TS \t TSFIELDS
//
// SITE  = the class chain (kinds + names; NO ids, NO file, NO span)
// IDX   = the property's index in the class's vpiVariables vector
// VAR   = kind|name|sgn=|auto=|vis=|rand=|nrange=
// TS    = actual typespec kind|name|nrange=|inst=
// TSFIELDS = for a struct/union typespec: the field-name list (order kept)
//
// The KEY for a golden-vs-ours join is SITE+VAR-name (never the span, never
// the file: RESUME §9 — our objects carry an empty VpiFile and spans are
// dump fidelity, not judge-visible).  Rows are emitted as a MULTISET.
//
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cen136 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  return e;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 12 && p; i++) {
    r = r.empty() ? node(p) : (node(p) + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static const typespec* actual(const ref_typespec* r) {
  return r ? r->Actual_typespec() : nullptr;
}
static int nRanges(const any* v) {
  if (!v) return -1;
  switch (v->UhdmType()) {
    case uhdmbit_var: { auto* r = ((const bit_var*)v)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmlogic_var: { auto* r = ((const logic_var*)v)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmarray_var: { auto* r = ((const array_var*)v)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmlogic_typespec: { auto* r = ((const logic_typespec*)v)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmbit_typespec: { auto* r = ((const bit_typespec*)v)->Ranges(); return r ? (int)r->size() : 0; }
    default: return -1;
  }
}
static std::string tsStr(const typespec* e) {
  if (!e) return "<null>";
  std::string r(UhdmName(e->UhdmType()));
  r += "|" + std::string(e->VpiName());
  r += "|nr=" + std::to_string(nRanges(e));
  r += "|inst=" + (e->Instance()
                       ? std::string(UhdmName(e->Instance()->UhdmType())) + "(" +
                             std::string(e->Instance()->VpiName()) + ")"
                       : std::string("-"));
  return r;
}
static std::string tsFields(const typespec* e) {
  if (!e) return "-";
  const VectorOftypespec_member* ms = nullptr;
  if (e->UhdmType() == uhdmstruct_typespec) ms = ((const struct_typespec*)e)->Members();
  else if (e->UhdmType() == uhdmunion_typespec) ms = ((const union_typespec*)e)->Members();
  else if (e->UhdmType() == uhdmenum_typespec) return "enum";
  if (!ms) return "-";
  std::string r;
  for (auto* m : *ms) { if (!r.empty()) r += ","; r += std::string(m->VpiName()); }
  return r.empty() ? "-" : r;
}
static std::string varStr(const variables* v) {
  if (!v) return "<null>";
  std::string r(UhdmName(v->UhdmType()));
  r += "|" + std::string(v->VpiName());
  r += std::string("|sgn=") + (v->VpiSigned() ? "1" : "0");
  r += std::string("|auto=") + (v->VpiAutomatic() ? "1" : "0");
  r += "|vis=" + std::to_string(v->VpiVisibility());
  r += "|rand=" + std::to_string(v->VpiRandType());
  r += "|nr=" + std::to_string(nRanges(v));
  return r;
}
static void emit(const char* tag, const any* owner, int idx, const variables* v) {
  const typespec* ts = actual(v->Typespec());
  printf("%s\t%s\t%d\t%s\t%s\t%s\n", tag, chainOf(v).c_str(), idx,
         varStr(v).c_str(), tsStr(ts).c_str(), tsFields(ts).c_str());
  (void)owner;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen136 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmclass_defn) continue;
    const class_defn* cd = (const class_defn*)a;
    auto* vs = cd->Variables();
    if (!vs) continue;
    int i = 0;
    for (auto* v : *vs) {
      emit("CELL", cd, i, v);
      if (v->UhdmType() == uhdmarray_var) {
        auto* evs = ((const array_var*)v)->Variables();
        if (evs) for (auto* ev : *evs) emit("ELEM", cd, i, ev);
      }
      i++;
    }
  }
  return 0;
}
