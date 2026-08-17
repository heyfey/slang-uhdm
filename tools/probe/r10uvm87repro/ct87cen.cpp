// r10uvm87 — MEASUREMENT-ONLY.  The § classTpGroupTsNameEverySite87 census.
//
// Walks EVERY object of ONE database exactly once (Serializer::AllObjects —
// uhdm-dump reprints an object at every reference, so a dump-line count is NOT
// an object count) and emits ONE ROW PER class_typespec, keyed by the fields
// `class_typespec::Compare` actually reads plus the two dump-axis fields this
// pass predicts as a free consequence:
//
//   NAME    vpiName                     (CMP-JUDGED — the head is here)
//   DEFN    vpiClassDefn's vpiFullName  (CMP-JUDGED)
//   INST    vpiInstance's vpiFullName   (CMP-JUDGED)
//   PARENT  vpiParent's UHDM kind name  (dump axis)
//   SPAN    line:col-endln:endcol       (dump axis)
//   OWNER   the nearest enclosing class_defn / package / module, by fullname
//
// Two modes:
//   --rows    every row, sorted, for a golden-vs-ours JOIN (the deficit census)
//   --group   only the rows whose OWNER is a class_defn AND whose vpiParent is
//             a class_defn or a type_parameter — the class-scope TYPE-PARAMETER
//             GROUP population, tallied per owner so the "ONE object per
//             distinct resolved type" claim is a COUNT, not a sentence.
//   --pred <name>  the MOVER PREDICTOR, run on PRISTINE databases only: every
//             class_typespec whose vpiName equals the resolved CLASS name while
//             some sibling in the same owner carries a typedef name.  See the
//             README: the honest predictor for this law is the ARM-derived site
//             list, and this switch only counts the population it can see from
//             the bytes.
//
// usage: ct87cen <db.uhdm> [--rows|--group|--pred]
// build: g++ -O2 -std=c++17 ct87cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct87cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "<null>";
  // every named container we care about derives from BaseClass with VpiFullName
  if (auto* i = any_cast<const instance*>(o)) return std::string(i->VpiFullName());
  if (auto* c = any_cast<const class_defn*>(o)) return std::string(c->VpiFullName());
  if (auto* t = any_cast<const task_func*>(o)) return std::string(t->VpiFullName());
  return kindName(o);
}
// The nearest enclosing NAMED container, walking vpiParent.
static std::string ownerOf(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 24 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
        t == uhdmfunction || t == uhdmtask)
      return kindName(p) + ":" + fullOf(p);
    p = p->VpiParent();
  }
  return "<unparented>";
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return std::string(b);
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct87cen <db.uhdm> [--rows|--group|--pred]\n"); return 2; }
  const char* mode = argc > 2 ? argv[2] : "--rows";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  // An UNPARENTED class_typespec cannot name its owner by walking vpiParent —
  // and our own head object is exactly that shape — so the owner is recovered
  // from the REFERENCE side: every ref_typespec whose Actual_typespec is this
  // object contributes its own owner.  Without this the census is BLIND to the
  // very population this pass moves, and a "no deficit" reading would be an
  // artifact of the instrument.
  std::map<const BaseClass*, std::string> refOwner;
  for (auto& p2 : all) {
    const BaseClass* o2 = p2.first;
    if (!o2 || o2->UhdmType() != uhdmref_typespec) continue;
    auto* rt2 = (const ref_typespec*)o2;
    const typespec* a2 = rt2->Actual_typespec();
    if (!a2 || a2->UhdmType() != uhdmclass_typespec) continue;
    if (refOwner.count(a2)) continue;
    refOwner[a2] = ownerOf(rt2);
  }
  long nCts = 0;
  std::vector<std::string> rows;
  // owner -> (defn target -> set of names) and owner -> count
  std::map<std::string, std::map<std::string, std::multiset<std::string>>> grp;
  for (auto& p : all) {
    const BaseClass* o = p.first;
    if (!o || o->UhdmType() != uhdmclass_typespec) continue;
    auto* ct = (const class_typespec*)o;
    nCts++;
    std::string name(ct->VpiName());
    std::string defn = ct->Class_defn() ? std::string(ct->Class_defn()->VpiFullName())
                                        : std::string("<none>");
    std::string inst = ct->Instance() ? std::string(ct->Instance()->VpiFullName())
                                      : std::string("<none>");
    std::string par = kindName(ct->VpiParent());
    std::string own = ownerOf(ct);
    if (own == "<unparented>") {
      auto r3 = refOwner.find((const BaseClass*)ct);
      if (r3 != refOwner.end()) own = r3->second + "|viaref";
    }
    char line[2048];
    snprintf(line, sizeof line, "NAME=%s|DEFN=%s|INST=%s|PARENT=%s|SPAN=%s|OWNER=%s",
             name.c_str(), defn.c_str(), inst.c_str(), par.c_str(),
             spanOf(ct).c_str(), own.c_str());
    rows.push_back(line);
    if (own.rfind("class_defn:", 0) == 0)
      grp[own][defn].insert(name);
  }
  if (!strcmp(mode, "--pred")) {
    // THE MOVER PREDICTOR — PRISTINE databases only.
    // Site A of § classTpTsResolvedNameEverySite87 renames exactly those
    // class_typespecs that are parented at a `type_parameter` and whose VpiName
    // is not a SPELLING of their own Class_defn (the simple name, or anything
    // ending in `::<simple name>`).  That is a test on the BYTES alone, so the
    // mover set can be listed BY NAME before a patched binary exists.
    long nTp = 0, nMove = 0;
    for (auto& p2 : all) {
      const BaseClass* o2 = p2.first;
      if (!o2 || o2->UhdmType() != uhdmclass_typespec) continue;
      auto* ct2 = (const class_typespec*)o2;
      const BaseClass* par2 = ct2->VpiParent();
      if (!par2 || par2->UhdmType() != uhdmtype_parameter) continue;
      nTp++;
      std::string nm(ct2->VpiName());
      std::string full = ct2->Class_defn() ? std::string(ct2->Class_defn()->VpiFullName()) : std::string();
      std::string simple = full;
      if (auto q = simple.rfind("::"); q != std::string::npos) simple = simple.substr(q + 2);
      bool ok = (!simple.empty()) &&
                (nm == simple ||
                 (nm.size() > simple.size() + 2 &&
                  nm.compare(nm.size() - simple.size() - 2, 2, "::") == 0 &&
                  nm.compare(nm.size() - simple.size(), simple.size(), simple) == 0));
      if (!ok) {
        nMove++;
        printf("PREDICT-A OWNER=%s TP=%s NAME=%s DEFN=%s\n", ownerOf(ct2).c_str(),
               std::string(((const type_parameter*)par2)->VpiFullName()).c_str(),
               nm.c_str(), full.c_str());
      }
    }
    fprintf(stderr, "type_parameter class_typespecs: %ld  PREDICT-A movers: %ld\n", nTp, nMove);
    return 0;
  }
  if (!strcmp(mode, "--rows")) {
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
  }
  else if (!strcmp(mode, "--group")) {
    for (auto& [own, byDefn] : grp)
      for (auto& [defn, names] : byDefn) {
        std::map<std::string, int> tally;
        for (auto& n : names) tally[n]++;
        std::string t;
        for (auto& [n, c] : tally) {
          char b[512]; snprintf(b, sizeof b, "{%s}x%d ", n.empty() ? "<empty>" : n.c_str(), c);
          t += b;
        }
        printf("GROUP OWNER=%s DEFN=%s OBJS=%zu NAMES=[ %s]\n",
               own.c_str(), defn.c_str(), names.size(), t.c_str());
      }
  }
  fprintf(stderr, "class_typespec objects: %ld  (db=%s)\n", nCts, argv[1]);
  return 0;
}
