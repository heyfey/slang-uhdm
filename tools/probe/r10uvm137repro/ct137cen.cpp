// r10uvm137 — FOREACH CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge.
//
// One row per foreach_stmt the UhdmListener reaches, deduped by UhdmId
// (a NODEDUP census manufactures AWAY-GOLDEN phantoms — RESUME.md §9):
//
//   VKIND   = Variable() UhdmName ('-' when the slot is empty)
//   VNAME   = Variable()->VpiName ('-' when empty)
//   VFULL   = Variable()->VpiFullName ('-' when empty)
//   VTS     = the Variable's ref_typespec Actual kind ('-' none, 'NOTS' no ref)
//   VTSNAME = that actual typespec's VpiName
//   VSPAN   = the Variable's own span
//   NLV     = VpiLoopVars() size
//   LVNAMES = the loop variables' names, comma joined (an operation prints '*')
//   LVKINDS = the loop variables' kinds, comma joined
//   LVTS    = the loop variables' actual-typespec kinds, comma joined
//   SPAN    = the foreach_stmt's own span
//   HOME    = nearest named ancestor scope
//   PATH    = the vpiParent callstack (kinds+names, NO ids, NO spans)
//
// score137.py joins golden/pristine/patched as a MULTISET on the id-free key
//   HOME|PATH|SPAN|NLV|LVNAMES
// and scores VKIND|VNAME|VFULL|VTS|VTSNAME|VSPAN|LVKINDS|LVTS.
//
//   build: g++ -O2 -std=c++17 ct137cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct137cen
//   usage: ct137cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += ((c == ' ' || c == '\t' || c == '|') ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  if (!o) return "-";
  char b[80];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
static std::string homeOf(const any* o) {
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdminitial: case uhdmalways: case uhdmfinal_stmt:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram: {
        std::string e(UhdmName(p->UhdmType()));
        if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
        return e;
      }
      default: break;
    }
    p = p->VpiParent();
  }
  return "-";
}
// the Actual_typespec behind an object that MAY carry a ref_typespec
static const typespec* actTs(const any* o) {
  if (!o) return nullptr;
  if (const variables* v = any_cast<const variables*>(o))
    return v->Typespec() ? v->Typespec()->Actual_typespec() : nullptr;
  if (const expr* e = any_cast<const expr*>(o))
    return e->Typespec() ? e->Typespec()->Actual_typespec() : nullptr;
  return nullptr;
}
static bool hasTsRef(const any* o) {
  if (!o) return false;
  if (const variables* v = any_cast<const variables*>(o)) return v->Typespec();
  if (const expr* e = any_cast<const expr*>(o)) return e->Typespec();
  return false;
}

static const char* g_lst = "-";

struct Cen : public UhdmListener {
  std::set<unsigned> seen;
  void enterForeach_stmt(const foreach_stmt* o) override {
    if (!seen.insert((unsigned)o->UhdmId()).second) return;
    const any* var = o->Variable();
    std::string vkind = var ? std::string(UhdmName(var->UhdmType())) : "-";
    std::string vname = var ? esc(var->VpiName()) : "-";
    std::string vfull = "-";
    if (const variables* vv = any_cast<const variables*>(var)) vfull = esc(vv->VpiFullName());
    else if (const hier_path* hp = any_cast<const hier_path*>(var)) vfull = esc(hp->VpiFullName());
    const typespec* ts = actTs(var);
    std::string vts = ts ? std::string(UhdmName(ts->UhdmType()))
                         : (var && hasTsRef(var) ? "NULLACT" : "NOTS");
    std::string vtsname = ts ? esc(ts->VpiName()) : "-";
    std::string lvn, lvk, lvt;
    size_t nlv = 0;
    if (o->VpiLoopVars()) {
      nlv = o->VpiLoopVars()->size();
      for (auto* lv : *o->VpiLoopVars()) {
        if (!lvn.empty()) { lvn += ","; lvk += ","; lvt += ","; }
        if (lv->UhdmType() == uhdmoperation) { lvn += "*"; }
        else lvn += esc(lv->VpiName());
        lvk += UhdmName(lv->UhdmType());
        const typespec* lt = actTs(lv);
        lvt += lt ? std::string(UhdmName(lt->UhdmType()))
                  : (hasTsRef(lv) ? "NULLACT" : "NOTS");
      }
    }
    if (lvn.empty()) { lvn = "-"; lvk = "-"; lvt = "-"; }
    printf("VKIND=%s|VNAME=%s|VFULL=%s|VTS=%s|VTSNAME=%s|VSPAN=%s|NLV=%zu"
           "|LVNAMES=%s|LVKINDS=%s|LVTS=%s|SPAN=%s|SITE=%s|HOME=%s|PATH=%s\n",
           vkind.c_str(), vname.c_str(), vfull.c_str(), vts.c_str(),
           vtsname.c_str(), spanOf(var).c_str(), nlv, lvn.c_str(), lvk.c_str(),
           lvt.c_str(), spanOf(o).c_str(), g_lst, homeOf(o).c_str(),
           chainOf(o).c_str());
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct137cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    Cen c;
    if (d->AllPackages()) { g_lst = "ALLPKG"; for (auto* p : *d->AllPackages()) c.listenAny(p); }
    if (d->TopPackages()) { g_lst = "TOPPKG"; for (auto* p : *d->TopPackages()) c.listenAny(p); }
    if (d->AllClasses())  { g_lst = "ALLCLS"; for (auto* p : *d->AllClasses())  c.listenAny(p); }
    if (d->TopModules())  { g_lst = "TOPMOD"; for (auto* p : *d->TopModules())  c.listenAny(p); }
    if (d->AllModules())  { g_lst = "ALLMOD"; for (auto* p : *d->AllModules())  c.listenAny(p); }
  }
  return 0;
}
