// r10uvm129 — DECLARATOR-ARRAY ELEMENT-VARIABLE census.
//
// One CELL per array_var: the array_var itself, its array_typespec, its
// ELEMENT VARIABLE (class / VpiName / VpiSigned / VpiAutomatic) and the
// element typespec BOTH of them bind, with an explicit SHARED flag saying
// whether the element variable's ref_typespec actual IS the same OBJECT as the
// array_typespec's Elem_typespec actual.
//
//   CELL \t SITE \t ARRVAR \t ARRTS \t ELEMVAR \t ELEMTS \t shared=Y/N
//
// SITE     = the array_var's parent chain (kinds + names; NO ids, NO file)
// ARRVAR   = array_var | name | span | arrayType
// ARRTS    = array_typespec | span | nranges | index-typespec kind
// ELEMVAR  = kind | name | span | sgn= | auto= | arrmem=
// ELEMTS   = kind | name | span | sgn= | inst kind(name)
//
// A second family answers the OBJECT-IDENTITY question without ids: for every
// NAMED typespec object, how many ref_typespecs in the database point at it.
//
//   TSOBJ \t <kind>|<name> \t <span> \t nrefs=<N>
//
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cen129 <db.uhdm> [owner-name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
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
// VpiSigned wherever the typespec class carries one.
static std::string tsSgn(const typespec* e) {
  switch (e->UhdmType()) {
    case uhdmlogic_typespec: return ((const logic_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmbit_typespec: return ((const bit_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmint_typespec: return ((const int_typespec*)e)->VpiSigned()?"1":"0";
    case uhdminteger_typespec: return ((const integer_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmbyte_typespec: return ((const byte_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmshort_int_typespec: return ((const short_int_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmlong_int_typespec: return ((const long_int_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmtime_typespec: return ((const time_typespec*)e)->VpiSigned()?"1":"0";
    case uhdmenum_typespec: return "-";
    default: return "-";
  }
}
static std::string tsStr(const typespec* e) {
  if (!e) return "<null>";
  std::string r(UhdmName(e->UhdmType()));
  r += "|" + std::string(e->VpiName());
  r += "|" + sp(e);
  r += "|sgn=" + tsSgn(e);
  r += "|inst=" + (e->Instance()
                       ? std::string(UhdmName(e->Instance()->UhdmType())) + "(" +
                             std::string(e->Instance()->VpiName()) + ")"
                       : std::string("-"));
  return r;
}
static std::string varStr(const variables* v) {
  if (!v) return "<null>";
  std::string r(UhdmName(v->UhdmType()));
  r += "|" + std::string(v->VpiName());
  r += "|" + sp(v);
  r += std::string("|sgn=") + (v->VpiSigned() ? "1" : "0");
  r += std::string("|auto=") + (v->VpiAutomatic() ? "1" : "0");
  r += std::string("|arrmem=") + (v->VpiArrayMember() ? "1" : "0");
  return r;
}
static const char* atName(int t) {
  switch (t) {
    case vpiStaticArray: return "static";
    case vpiDynamicArray: return "dyn";
    case vpiAssocArray: return "assoc";
    case vpiQueueArray: return "queue";
    default: return "?";
  }
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen129 <db> [substr]\n"); return 2; }
  std::string filt = (argc > 2) ? argv[2] : "";
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  // How many ref_typespecs point at each typespec object?
  std::map<const typespec*, int> nrefs;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_typespec) continue;
    if (const typespec* t = ((const ref_typespec*)a)->Actual_typespec())
      nrefs[t]++;
  }
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmarray_var) continue;
    const array_var* av = (const array_var*)a;
    if (!filt.empty() &&
        std::string(av->VpiName()).find(filt) == std::string::npos) continue;
    const typespec* ats = actual(av->Typespec());
    std::string atsS = "<null>";
    const typespec* aElem = nullptr;
    if (ats) {
      atsS = std::string(UhdmName(ats->UhdmType())) + "|" + sp(ats);
      if (ats->UhdmType() == uhdmarray_typespec) {
        auto* at = (const array_typespec*)ats;
        aElem = actual(at->Elem_typespec());
        atsS += "|nr=" +
                std::to_string(at->Ranges() ? at->Ranges()->size() : 0);
        const typespec* it = actual(at->Index_typespec());
        atsS += std::string("|idx=") +
                (it ? std::string(UhdmName(it->UhdmType())) + "(" +
                          std::string(it->VpiName()) + ")"
                    : std::string("-"));
      } else {
        atsS += "|nr=?|idx=-";
      }
    }
    auto* vs = av->Variables();
    const variables* ev = (vs && !vs->empty()) ? (*vs)[0] : nullptr;
    const typespec* ets = ev ? actual(ev->Typespec()) : nullptr;
    printf("CELL\t%s\tarray_var|%s|%s|%s\t%s\t%s\t%s\tshared=%s\televts_nrefs=%d\n",
           chainOf(av).c_str(), std::string(av->VpiName()).c_str(),
           sp(av).c_str(), atName(av->VpiArrayType()), atsS.c_str(),
           varStr(ev).c_str(), tsStr(ets).c_str(),
           (ets && ets == aElem) ? "Y" : "N",
           ets ? nrefs[ets] : 0);
  }
  if (!filt.empty()) return 0;
  // Every NAMED typespec object and its referrer count — the id-free identity
  // measurement: two objects of the same kind+name are two ROWS.
  std::map<std::string, std::multiset<std::string>> byName;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    const typespec* t = any_cast<const typespec*>(a);
    if (!t || t->VpiName().empty()) continue;
    std::string key = std::string(UhdmName(t->UhdmType())) + "|" +
                      std::string(t->VpiName());
    byName[key].insert(sp(t) + "\tnrefs=" + std::to_string(nrefs[t]));
  }
  for (auto& kv : byName)
    for (auto& r : kv.second)
      printf("TSOBJ\t%s\t%s\n", kv.first.c_str(), r.c_str());
  return 0;
}
