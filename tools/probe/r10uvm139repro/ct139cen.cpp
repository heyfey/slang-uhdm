// r10uvm139 — VARIABLE-LIFETIME CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge.
//
// One row per `variables` object the UhdmListener reaches, deduped by UhdmId
// (a NODEDUP census manufactures AWAY-GOLDEN phantoms — RESUME.md §9):
//
//   AUTO    = VpiAutomatic()            <- THE SCORED FIELD (variables::Compare
//                                          reads it: generated variables.cpp:256)
//   VKIND   = the object's UHDM kind    <- read by Compare (VpiType)
//   VNAME   = VpiName                   <- read by Compare
//   VTS     = its ref_typespec's Actual kind ('NOTS' no ref, 'NULLACT' empty)
//   VCONST  = VpiConstantVariable
//   VFULL   = VpiFullName               (dump-only — Compare never reads it)
//   VSPAN   = the object's own span     (dump-only)
//   OWNER   = the parent's kind(+name)
//   HOME    = nearest named ancestor scope
//   SCOPE   = the NAMED-scope parent chain (the census key's scope half)
//   PATH    = the vpiParent callstack (kinds+names, NO ids, NO spans)
//
// score139.py joins golden/pristine/patched as a MULTISET on the id-free key
//   SCOPE|VNAME  and scores AUTO|VKIND|VTS|VCONST|PATH|VFULL|VSPAN.
// The DEF/ELAB view is deliberately OUT of the key (the two producers label it
// differently) — a variable listed in both views is simply two bag entries.
//
//   build: g++ -O2 -std=c++17 ct139cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct139cen
//   usage: ct139cen <db.uhdm>
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
// The NAMED-SCOPE chain: the vpiParent walk keeping only the scopes that own a
// declaration (package / class / module / interface / program / subroutine),
// with their names and NO ids, NO spans, and NOT the `design` node (the two
// producers name it differently) and not the unnamed `begin`/`assignment`
// wrappers a re-parented initialised local hangs off.  This is the census KEY's
// scope half: it is identical on both sides for every cell either produces.
static std::string scopeOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram:
      case uhdminterface_inst: {
        std::string e(UhdmName(p->UhdmType()));
        e += "(" + esc(p->VpiName()) + ")";
        r = r.empty() ? e : (e + "/" + r);
        break;
      }
      default: break;
    }
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

static const char* g_lst = "-";

struct Cen : public UhdmListener {
  std::set<unsigned> seen;
  void enterAny(const any* o) override {
    const variables* v = any_cast<const variables*>(o);
    if (!v) return;
    if (!seen.insert((unsigned)v->UhdmId()).second) return;
    const typespec* ts =
        v->Typespec() ? v->Typespec()->Actual_typespec() : nullptr;
    std::string vts = ts ? std::string(UhdmName(ts->UhdmType()))
                         : (v->Typespec() ? "NULLACT" : "NOTS");
    const any* par = v->VpiParent();
    std::string owner = par ? std::string(UhdmName(par->UhdmType())) : "-";
    if (par && !par->VpiName().empty()) owner += "(" + esc(par->VpiName()) + ")";
    printf("AUTO=%d|VKIND=%s|VNAME=%s|VTS=%s|VCONST=%d|VFULL=%s|VSPAN=%s"
           "|OWNER=%s|SITE=%s|HOME=%s|SCOPE=%s|PATH=%s\n",
           v->VpiAutomatic() ? 1 : 0, std::string(UhdmName(v->UhdmType())).c_str(),
           esc(v->VpiName()).c_str(), vts.c_str(),
           v->VpiConstantVariable() ? 1 : 0, esc(v->VpiFullName()).c_str(),
           spanOf(v).c_str(), owner.c_str(), g_lst, homeOf(v).c_str(),
           scopeOf(v).c_str(), chainOf(v).c_str());
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct139cen <db.uhdm>\n"); return 2; }
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
    if (d->AllPrograms()) { g_lst = "ALLPRG"; for (auto* p : *d->AllPrograms()) c.listenAny(p); }
    if (d->AllInterfaces()){g_lst = "ALLIFC"; for (auto* p : *d->AllInterfaces()) c.listenAny(p); }
  }
  return 0;
}
