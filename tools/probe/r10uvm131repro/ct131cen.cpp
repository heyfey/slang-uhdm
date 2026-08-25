// r10uvm131 — FORK CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge.
//
// One row per fork_stmt / named_fork the UhdmListener reaches:
//   KIND   = named_fork | fork_stmt
//   NAME   = VpiName ('-' when unnamed)
//   ENDLBL = VpiEndLabel ('-' when none)
//   JOIN   = VpiJoinType (0 join / 1 join_none / 2 join_any)
//   NSTMT  = Stmts() size            NVAR = Variables() size
//   SPAN   = line:col-endline:endcol
//   HOME   = the nearest named ancestor scope kind+name (class task / initial / …)
//   PATH   = the vpiParent callstack (kinds+names, NO ids, NO spans)
//
// The KEY used by score131.py is  KIND|NAME|ENDLBL|NSTMT|PATH  — id-free and
// span-free so golden and ours join; JOIN and SPAN are the SCORED columns.
//
//   build: g++ -O2 -std=c++17 ct131cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct131cen
//   usage: ct131cen <db.uhdm>
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
// parent chain, kinds+names only (no ids, no spans) so it joins across DBs
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
// nearest ancestor that is a task/function/process/module/class-ish scope
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

// DEDUPE by UhdmId: the same object is reached from several listing roots
// (ALLPKG/TOPPKG/ALLCLS/TOPMOD/ALLMOD).  A NODEDUP census manufactures
// AWAY-GOLDEN phantoms (RESUME.md §9), so each object prints ONCE, tagged
// with the FIRST listing root that reached it.
struct Cen : public UhdmListener {
  std::set<unsigned> seen;
  void row(const any* o, int join, std::string_view name,
           std::string_view endlbl, size_t nstmt, size_t nvar) {
    if (!seen.insert((unsigned)o->UhdmId()).second) return;
    printf("KIND=%s|NAME=%s|ENDLBL=%s|JOIN=%d|NSTMT=%zu|NVAR=%zu|SPAN=%s|SITE=%s|HOME=%s|PATH=%s\n",
           std::string(UhdmName(o->UhdmType())).c_str(), esc(name).c_str(),
           esc(endlbl).c_str(), join, nstmt, nvar, spanOf(o).c_str(), g_lst,
           homeOf(o).c_str(), chainOf(o).c_str());
  }
  void enterNamed_fork(const named_fork* o) override {
    row(o, o->VpiJoinType(), o->VpiName(), o->VpiEndLabel(),
        o->Stmts() ? o->Stmts()->size() : 0,
        o->Variables() ? o->Variables()->size() : 0);
  }
  void enterFork_stmt(const fork_stmt* o) override {
    row(o, o->VpiJoinType(), o->VpiName(), "-",
        o->Stmts() ? o->Stmts()->size() : 0,
        o->Variables() ? o->Variables()->size() : 0);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct131cen <db.uhdm>\n"); return 2; }
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
