// r10uvm88 — MEASUREMENT-ONLY.  The `ref_obj -> Actual_group` census.
//
// Walks EVERY object of ONE database exactly once (Serializer::AllObjects;
// uhdm-dump reprints an object at every reference, so dump lines are NOT an
// object count) and emits ONE ROW PER ref_obj, keyed by the fields
// `ref_obj::Compare` actually reads (vpiName + Actual_group) plus the position
// that lets a golden row be joined to an ours row (file basename + span).
//
//   FILE:SPAN   basename(VpiFile):line:col-endln:endcol   (the JOIN key; dump
//               paths embed the workdir, so the basename is taken)
//   NAME        vpiName                         (CMP-JUDGED)
//   ACT         Actual_group's UHDM kind name   (CMP-JUDGED: null vs non-null
//               is exactly the head's shape)
//   ACTFULL     Actual_group's vpiFullName (fallback vpiName)
//   ACTOWN      the Actual's nearest enclosing named container, kind:fullname
//   ACTCONST    1 when the Actual is a `variables` with vpiConstantVariable
//   SITE        the ref_obj's nearest enclosing named container
//   SITEKIND    that container's UHDM kind
//   SITEINST    the enclosing task_func's vpiInstance (kind:fullname) — THE
//               DECODE AXIS: Surelog's `UhdmWriter::lateBinding` reaches a
//               package's `Variables()` only through `func->Instance()` when
//               that instance is a PACKAGE, so this column is the mechanism
//   SITECLS     1 when the enclosing task_func's owner chain reaches a
//               class_defn (i.e. the site is a CLASS METHOD)
//
// modes:
//   --rows      every ref_obj row (the join input)
//   --pkgvar    only the rows whose ACT is a variable owned by a PACKAGE
//   --pkgpop    the POPULATION scan: every ref_obj whose NAME matches a
//               package-scope variable name in this database, bound or not,
//               so a census cannot be blind to the rows where WE bind nothing
//   --pkgvars   list the package-scope variables themselves (name, const flag)
//
// usage: ct88cen <db.uhdm> [--rows|--pkgvar|--pkgpop|--pkgvars]
// build: g++ -O2 -std=c++17 ct88cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct88cen
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
static std::string base(std::string_view p) {
  size_t i = p.find_last_of('/');
  return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return std::string(b);
}
// vpiFullName through the public introspection, so this works for EVERY kind
// rather than only the handful with a C++ accessor.
static std::string fullOf(const BaseClass* o) {
  if (!o) return "<null>";
  vpiHandle h = NewVpiHandle(o);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : "";
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(o->VpiName());
  if (r.empty()) r = "<anon>";
  return r;
}
static const BaseClass* ownerObj(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 40 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
        t == uhdmfunction || t == uhdmtask || t == uhdmclass_typespec)
      return p;
    p = p->VpiParent();
  }
  return nullptr;
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = ownerObj(o);
  if (!p) return "<unparented>";
  return kindName(p) + ":" + fullOf(p);
}
// is `o` a variable whose DIRECT vpiParent is a package?
static bool pkgScopeVar(const BaseClass* o) {
  if (!o) return false;
  const any* a = (const any*)o;
  if (!any_cast<const variables*>(a)) return false;
  const BaseClass* p = o->VpiParent();
  return p && p->UhdmType() == uhdmpackage;
}
static int constFlag(const BaseClass* o) {
  if (!o) return -1;
  if (auto* v = any_cast<const variables*>((const any*)o))
    return v->VpiConstantVariable() ? 1 : 0;
  return -1;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct88cen <db.uhdm> [--rows|--pkgvar|--pkgpop|--pkgvars]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--rows";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  // every package-scope variable, by NAME (a name can repeat across packages)
  std::map<std::string, std::set<std::string>> pkgVarNames;  // name -> fullnames
  std::map<std::string, int> pkgVarConst;                    // fullname -> const
  for (auto& p : all) {
    const BaseClass* o = p.first;
    if (!pkgScopeVar(o)) continue;
    std::string n(o->VpiName());
    if (n.empty()) continue;
    pkgVarNames[n].insert(fullOf(o));
    pkgVarConst[fullOf(o)] = constFlag(o);
  }
  if (mode == "--pkgvars") {
    for (auto& kv : pkgVarNames)
      for (auto& f : kv.second)
        printf("PKGVAR\t%s\tCONST=%d\n", f.c_str(), pkgVarConst[f]);
    fprintf(stderr, "-- %zu package-scope variable names\n", pkgVarNames.size());
    return 0;
  }

  long nRef = 0, nBound = 0, nPkgVarBound = 0, nNamePop = 0;
  std::vector<std::string> rows;
  for (auto& p : all) {
    const BaseClass* o = p.first;
    if (!o || o->UhdmType() != uhdmref_obj) continue;
    auto* r = (const ref_obj*)o;
    nRef++;
    const BaseClass* act = (const BaseClass*)r->Actual_group();
    if (act) nBound++;
    std::string name(r->VpiName());
    bool namePop = pkgVarNames.count(name) != 0;
    if (namePop) nNamePop++;
    bool actPkgVar = pkgScopeVar(act);
    if (actPkgVar) nPkgVarBound++;
    if (mode == "--pkgvar" && !actPkgVar) continue;
    if (mode == "--pkgpop" && !(actPkgVar || namePop)) continue;
    const BaseClass* so = ownerObj(o);
    // the enclosing task_func and its vpiInstance
    const BaseClass* tf = o->VpiParent();
    for (int i = 0; i < 40 && tf; i++) {
      UHDM_OBJECT_TYPE t = tf->UhdmType();
      if (t == uhdmfunction || t == uhdmtask) break;
      if (t == uhdmpackage || t == uhdmmodule_inst || t == uhdmclass_defn) { tf = nullptr; break; }
      tf = tf->VpiParent();
    }
    std::string siteInst = "-";
    int siteCls = 0;
    if (tf) {
      auto* tfo = (const task_func*)tf;
      const instance* ti = tfo->Instance();
      siteInst = ti ? (kindName(ti) + ":" + fullOf(ti)) : "<null>";
      for (const BaseClass* q = tf->VpiParent(); q; q = q->VpiParent())
        if (q->UhdmType() == uhdmclass_defn) { siteCls = 1; break; }
    }
    char line[4096];
    snprintf(line, sizeof line,
             "%s|%s\tNAME=%s\tACT=%s\tACTFULL=%s\tACTOWN=%s\tACTCONST=%d\t"
             "SITEKIND=%s\tSITE=%s\tSITEINST=%s\tSITECLS=%d\tNAMEPOP=%d",
             base(o->VpiFile()).c_str(), spanOf(o).c_str(), name.c_str(),
             kindName(act).c_str(), act ? fullOf(act).c_str() : "-",
             act ? ownerStr(act).c_str() : "-", constFlag(act),
             so ? kindName(so).c_str() : "<none>", ownerStr(o).c_str(),
             siteInst.c_str(), siteCls, namePop ? 1 : 0);
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr,
          "-- ref_obj=%ld  bound=%ld  bound-to-pkg-scope-var=%ld  "
          "name-matches-a-pkg-var=%ld  rows=%zu\n",
          nRef, nBound, nPkgVarBound, nNamePop, rows.size());
  return 0;
}
