// r10earl101 -- MEASUREMENT ONLY.  THE REVERSE REFERENCE SCAN.
//
//   ref101 <db.uhdm> <name-substring>
//
// Pass A (arena): every typespec whose VpiName carries the substring = the
//   TARGET set; every ref_typespec whose Actual_typespec is a target, and every
//   typespec whose Typedef_alias resolves to one = the REFERENCE set.
// Pass B (UhdmListener, roots re-walked with `visited` cleared per root so the
//   DEF and the ELAB views both report): the FIELD PATH the walk took to each
//   target and to each reference -- never VpiParent, because the two producers
//   park these objects on different parents and no generated Compare reads
//   VpiParent (RESUME s9).
//
// Rows:
//   TS   id kind name span INST ALIAS refs alias_refs
//   TPATH  the path to the target object itself
//   RPATH  the path to a ref_typespec that names it as Actual_typespec
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;

static std::string kn(const BaseClass *o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nm(const BaseClass *o) {
  if (!o) return "-";
  std::string n(((const any *)o)->VpiName());
  return n.empty() ? std::string("~") : n;
}
static std::string sp(const BaseClass *o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string fl(const BaseClass *o) {
  if (!o) return "-";
  std::string f(o->VpiFile());
  size_t p = f.rfind('/');
  return p == std::string::npos ? f : f.substr(p + 1);
}
static std::string fn(const BaseClass *o) {
  if (!o) return "";
  const any *a = (const any *)o;
  if (const scope *x = any_cast<const scope *>(a)) return std::string(x->VpiFullName());
  if (const nets *x = any_cast<const nets *>(a)) return std::string(x->VpiFullName());
  if (const variables *x = any_cast<const variables *>(a)) return std::string(x->VpiFullName());
  if (const parameter *x = any_cast<const parameter *>(a)) return std::string(x->VpiFullName());
  if (const ref_obj *x = any_cast<const ref_obj *>(a)) return std::string(x->VpiFullName());
  return "";
}

struct Coll : public UhdmListener {
  std::set<const BaseClass *> targets, refs;
  std::map<const BaseClass *, std::set<std::string>> tpath, rpath;
  std::map<const BaseClass *, const BaseClass *> refOf;  // ref -> its target
  std::string root;

  std::string path() const {
    const any_stack_t &cs = getCallstack();
    std::string p = root;
    size_t n = cs.size();
    size_t start = (n > 10) ? n - 10 : 0;
    if (start) p += " >...";
    for (size_t i = start; i + 1 < n; ++i) {
      const BaseClass *f = cs[i];
      p += " > " + kn(f) + "[" + nm(f) + "]";
      std::string ff = fn(f);
      if (!ff.empty() && ff != nm(f)) p += "{" + ff + "}";
    }
    return p;
  }
  void noteT(const BaseClass *o) {
    if (targets.count(o) && tpath[o].size() < 24) tpath[o].insert(path());
  }
  void enterRef_typespec(const ref_typespec *const o) override {
    if (refs.count(o)) {
      const BaseClass *t = refOf[o];
      if (rpath[t].size() < 40) rpath[t].insert(path());
    }
  }
  void enterLogic_typespec(const logic_typespec *const o) override { noteT(o); }
  void enterBit_typespec(const bit_typespec *const o) override { noteT(o); }
  void enterInt_typespec(const int_typespec *const o) override { noteT(o); }
  void enterStruct_typespec(const struct_typespec *const o) override { noteT(o); }
  void enterEnum_typespec(const enum_typespec *const o) override { noteT(o); }
  void enterArray_typespec(const array_typespec *const o) override { noteT(o); }
  void enterPacked_array_typespec(const packed_array_typespec *const o) override { noteT(o); }
  void enterInteger_typespec(const integer_typespec *const o) override { noteT(o); }
};

int main(int argc, char **argv) {
  if (argc < 3) { fprintf(stderr, "usage: ref101 <db.uhdm> <name-substring>\n"); return 2; }
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::string pat = argv[2];

  Coll c;
  const design *dsn = nullptr;
  std::map<const BaseClass *, int> nrefs, nalias;
  for (auto &pr : s.AllObjects()) {
    const BaseClass *bo = pr.first;
    if (!bo) continue;
    if (bo->UhdmType() == uhdmdesign) dsn = (const design *)bo;
    if (const typespec *ts = any_cast<const typespec *>((const any *)bo))
      if (std::string(ts->VpiName()).find(pat) != std::string::npos) c.targets.insert(bo);
  }
  for (auto &pr : s.AllObjects()) {
    const BaseClass *bo = pr.first;
    if (!bo) continue;
    if (bo->UhdmType() == uhdmref_typespec) {
      const ref_typespec *rt = (const ref_typespec *)bo;
      if (rt->Actual_typespec()) {
        nrefs[rt->Actual_typespec()]++;
        if (c.targets.count(rt->Actual_typespec())) { c.refs.insert(bo); c.refOf[bo] = rt->Actual_typespec(); }
      }
    }
    if (const typespec *ts = any_cast<const typespec *>((const any *)bo))
      if (ts->Typedef_alias() && ts->Typedef_alias()->Actual_typespec())
        nalias[ts->Typedef_alias()->Actual_typespec()]++;
  }
  if (!dsn) { fprintf(stderr, "NO_DESIGN\n"); return 3; }

  auto go = [&](const char *tag, const std::string &nme, const any *o) {
    c.root = std::string(tag) + ":" + nme;
    c.getVisited().clear();
    c.listenAny(o);
  };
  if (dsn->AllPackages()) for (auto *p : *dsn->AllPackages()) go("PKG", std::string(p->VpiName()), p);
  if (dsn->AllModules()) for (auto *m : *dsn->AllModules()) go("D", std::string(m->VpiDefName()), m);
  if (dsn->AllInterfaces()) for (auto *m : *dsn->AllInterfaces()) go("I", std::string(m->VpiDefName()), m);
  if (dsn->AllClasses()) for (auto *m : *dsn->AllClasses()) go("C", std::string(m->VpiDefName()), m);
  if (dsn->TopModules()) for (auto *m : *dsn->TopModules()) go("E", std::string(m->VpiFullName()), m);

  std::vector<std::pair<uint32_t, const BaseClass *>> hits;
  for (auto *o : c.targets) hits.push_back({o->UhdmId(), o});
  std::sort(hits.begin(), hits.end());
  for (auto &h : hits) {
    const BaseClass *o = h.second;
    const typespec *ts = any_cast<const typespec *>((const any *)o);
    std::string al = "-";
    if (ts && ts->Typedef_alias()) {
      const ref_typespec *a = ts->Typedef_alias();
      al = kn(a->Actual_typespec()) + "(" + nm(a->Actual_typespec()) + " id" +
           std::to_string(a->Actual_typespec() ? a->Actual_typespec()->UhdmId() : 0) + ")";
    }
    std::string inst = (ts && ts->Instance()) ? kn(ts->Instance()) + "[" + nm(ts->Instance()) + "]" : std::string("-");
    printf("TS id=%-8u %-24s name=%-26s span=%-14s file=%-18s INST=%-24s ALIAS=%-46s refs=%d alias_refs=%d\n",
           o->UhdmId(), kn(o).c_str(), nm(o).c_str(), sp(o).c_str(), fl(o).c_str(),
           inst.c_str(), al.c_str(), nrefs[o], nalias[o]);
    for (auto &p : c.tpath[o]) printf("   TPATH id=%-8u %s\n", o->UhdmId(), p.c_str());
    for (auto &p : c.rpath[o]) printf("   RPATH id=%-8u %s\n", o->UhdmId(), p.c_str());
  }
  return 0;
}
