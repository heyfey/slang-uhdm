// r10uvm91 — MEASUREMENT-ONLY.  The class-scope TYPE-PARAMETER typespec group
// census, keyed by OBJECT IDENTITY so "golden shares ONE object" is a COUNT and
// not a sentence (r10uvm33's method note: prove a sharing law by identity, not
// by name).
//
// One row per (class_defn, SITE) where SITE is a type_parameter, the class
// vpiTypedef LISTING, a class property, a method io_decl / return / local.
// Each row prints the bound typespec's KIND, NAME, SPAN and a per-database
// OBJECT ORDINAL (o<N>) — two rows with the same o<N> are the SAME object.
//
// usage: ct91cen <db.uhdm> [--rows|--grp]
// build: g++ -O2 -std=c++17 ct91cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct91cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::map<const BaseClass*, int> g_ord;
static int ordOf(const BaseClass* o) {
  if (!o) return -1;
  auto it = g_ord.find(o);
  if (it != g_ord.end()) return it->second;
  int n = (int)g_ord.size() + 1;
  g_ord[o] = n;
  return n;
}
static std::string tsDesc(const typespec* t) {
  if (!t) return "<null>";
  char b[256];
  snprintf(b, sizeof b, "%-18s '%s' @%u:%u-%u:%u o%d",
           std::string(UHDM::UhdmName(t->UhdmType())).c_str(),
           std::string(t->VpiName()).c_str(), t->VpiLineNo(), t->VpiColumnNo(),
           t->VpiEndLineNo(), t->VpiEndColumnNo(), ordOf(t));
  return b;
}
static const typespec* actual(const ref_typespec* r) {
  return r ? r->Actual_typespec() : nullptr;
}
struct Row { std::string cls, site, ts; };
static std::vector<Row> rows;
static void add(const std::string& c, const std::string& s, const typespec* t) {
  rows.push_back({c, s, tsDesc(t)});
}

static void doClass(const class_defn* cd) {
  std::string cn(cd->VpiFullName());
  if (auto* ps = cd->Parameters())
    for (auto* p : *ps)
      if (p->UhdmType() == uhdmtype_parameter) {
        auto* tp = (const type_parameter*)p;
        add(cn, "TYPEPARAM " + std::string(tp->VpiName()), actual(tp->Typespec()));
      }
  if (auto* ts = cd->Typespecs())
    for (auto* t : *ts)
      add(cn, "LISTING", t);
  if (auto* vs = cd->Variables())
    for (auto* v : *vs)
      add(cn, "PROP " + std::string(v->VpiName()), actual(v->Typespec()));
  if (auto* ms = cd->Task_funcs())
    for (auto* m : *ms) {
      std::string mn(m->VpiName());
      if (auto* ios = m->Io_decls())
        for (auto* io : *ios)
          add(cn, "IO " + mn + "::" + std::string(io->VpiName()),
              actual(io->Typespec()));
      if (m->UhdmType() == uhdmfunction) {
        auto* f = (const function*)m;
        if (auto* rv = f->Return())
          add(cn, "RET " + mn, actual(rv->Typespec()));
      }
      if (auto* vs2 = m->Variables())
        for (auto* v : *vs2)
          add(cn, "LOCAL " + mn + "::" + std::string(v->VpiName()),
              actual(v->Typespec()));
      if (auto* sc = m->Stmt())
        if (sc->UhdmType() == uhdmbegin) {
          auto* bg = (const begin*)sc;
          if (auto* vs3 = bg->Variables())
            for (auto* v : *vs3)
              add(cn, "BLKLOCAL " + mn + "::" + std::string(v->VpiName()),
                  actual(v->Typespec()));
        }
    }
}

// --pred: the MOVER PREDICTOR, run on PRISTINE bytes only.  A class_defn is a
// SITE of § classTpTdGroupNonClsRootShared91 when its vpiTypedef LISTING holds a
// NAMED typespec of one of the law's SCALAR kinds and the class also has a
// type_parameter bound to a typespec of that SAME kind.  That is the shape the
// law rewrites, read entirely off the pristine database.
static bool scalarKind(UHDM_OBJECT_TYPE t) {
  return t == uhdmint_typespec || t == uhdminteger_typespec ||
         t == uhdmbit_typespec || t == uhdmlogic_typespec ||
         t == uhdmbyte_typespec || t == uhdmshort_int_typespec ||
         t == uhdmlong_int_typespec || t == uhdmreal_typespec ||
         t == uhdmstring_typespec || t == uhdmtime_typespec;
}
static void doPred(const class_defn* cd, std::vector<std::string>& hits) {
  std::set<UHDM_OBJECT_TYPE> tpKinds;
  if (auto* ps = cd->Parameters())
    for (auto* p : *ps)
      if (p->UhdmType() == uhdmtype_parameter)
        if (auto* a = actual(((const type_parameter*)p)->Typespec()))
          if (scalarKind(a->UhdmType())) tpKinds.insert(a->UhdmType());
  if (tpKinds.empty()) return;
  if (auto* ts = cd->Typespecs())
    for (auto* t : *ts)
      if (!t->VpiName().empty() && tpKinds.count(t->UhdmType())) {
        hits.push_back(std::string(cd->VpiFullName()) + " [" +
                       std::string(UHDM::UhdmName(t->UhdmType())) + " '" +
                       std::string(t->VpiName()) + "']");
        return;
      }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct91cen <db.uhdm> [--rows]\n"); return 2; }
  Serializer ser;
  std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }
  // Walk EVERY object once; uhdm-dump reprints, AllObjects does not.
  std::set<const class_defn*> seen;
  for (auto& p : ser.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o) continue;
    if (o->UhdmType() == uhdmclass_defn) seen.insert((const class_defn*)o);
  }
  std::vector<const class_defn*> cls(seen.begin(), seen.end());
  std::sort(cls.begin(), cls.end(), [](const class_defn* a, const class_defn* b) {
    return std::string(a->VpiFullName()) < std::string(b->VpiFullName());
  });
  if (argc > 2 && std::string(argv[2]) == "--pred") {
    std::vector<std::string> hits;
    for (auto* c : cls) doPred(c, hits);
    for (auto& h : hits) printf("SITE %s\n", h.c_str());
    printf("PRED %s sites=%zu\n", argv[1], hits.size());
    return 0;
  }
  for (auto* c : cls) doClass(c);
  std::stable_sort(rows.begin(), rows.end(), [](const Row& a, const Row& b) {
    if (a.cls != b.cls) return a.cls < b.cls;
    return a.site < b.site;
  });
  for (auto& r : rows) printf("%-46s | %-34s | %s\n", r.cls.c_str(), r.site.c_str(), r.ts.c_str());
  return 0;
}
