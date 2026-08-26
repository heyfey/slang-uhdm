// r10uvm151 — ARRAY-METHOD / BUILT-IN-METHOD CALL-SHAPE CENSUS.
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole acceptance judge;
// nothing here judges anything.  LHS is ALWAYS golden, RHS is ALWAYS ours.
//
// The head (uvm_component.svh:3436, `m_time_settings.sort() with (item.offset);`)
// is a whole-object TYPE flip: golden mints a bare `func_call` NAMED AFTER THE
// RECEIVER, we mint a `method_func_call` named after the METHOD with the
// receiver as `vpiPrefix`.  This census scores, for EVERY call object in a
// database, the fields `func_call::Compare` / `method_func_call::Compare`
// actually read — the UHDM KIND, VpiName, the PREFIX's name, the argument
// count, whether a `vpiWith` rides the call and whether a `vpiFunction`
// resolution rides it — plus the parent's kind, which is what separates a
// STATEMENT-position call from an expression-position one.
//
//  ROW=CALL (one per func_call / method_func_call / task_call reachable from
//            the design, deduped by UhdmId; the weaklyReferenced tail is
//            unreachable to the judge and never printed)
//    KIND    FC (func_call) / MFC (method_func_call) / TC (task_call) /
//            MTC (method_task_call) / HP (hier_path — the shape golden mints
//            for the same call in EXPRESSION position, printed so the flip is
//            a PAIRED cell and not a one-sided row)                  <- SCORED
//    NAME    VpiName                                                    <- SCORED
//    PFX     the Prefix ref's VpiName, or `-`                           <- SCORED
//    NARG    Tf_call_args size                                          <- SCORED
//    WITH    1 iff a vpiWith rides the call                             <- SCORED
//    FUNC    1 iff Function()/Task() is resolved                        <- SCORED
//    PK      the parent object's UHDM kind                              (key part)
//    ANCH    line:col the SHAPE ANCHORS ON — the PREFIX's start for a
//            prefixed method_func_call, the call's own start otherwise.
//            Golden's degenerate func_call starts exactly where our
//            method_func_call's prefix starts, so this is the ID-FREE join
//            key that pairs the two shapes across the flip.        <- KEY
//    SPAN    the call's own span                                   (diagnostic)
//    FILE    VpiFile of the call (or of its nearest located ancestor)<- KEY
//    ROOT    which design listing reached the object (diagnostic)
//
// THE weaklyReferenced TAIL IS NEVER COUNTED (RESUME.md §9: it is unreachable
// to the judge).  The sweep starts ONLY at the design's own listings, and any
// object whose parent chain does not terminate in one of them is dropped.
//
// SPANS APPEAR ONLY IN KEYS AND DIAGNOSTICS, never as scored columns
// (RESUME.md §9: no generated Compare reads VpiFile/line/col).
//
//   build: g++ -O2 -std=c++17 ct151cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct151cen
//   usage: ct151cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <ostream>
#include <streambuf>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <set>
#include <unordered_map>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' || c == '\t' || c == '\n') ? '_' : c;
  if (r.empty()) r = "-";
  return r;
}
static std::string kindName(const any* o) {
  if (!o) return "-";
  return std::string(UhdmName(o->UhdmType()));
}

static const char* g_root = "-";
// THE weaklyReferenced TAIL FILTER.  `uhdm-dump` lists, after the design, every
// serialized object the design does not reach; those objects are invisible to
// `uhdm-cmp` (RESUME.md §9) and a census that counts them manufactures
// phantom row-set deltas.  A UhdmListener started at a design listing can
// still walk INTO a stale clone (its `VpiParent` chain climbs out to a package
// object that is in nobody's `AllPackages`), so the filter is on the chain:
// an object counts only when the TOP of its own VpiParent chain is one of the
// objects the sweep actually started from.
static std::set<const any*> g_roots;
// THE TAIL SET, taken from UHDM's OWN visitor so it is EXACTLY the set
// `uhdm-dump` prints under `\_weaklyReferenced:` — the objects the design only
// SHALLOW-references (`UHDM/templates/vpi_visitor.cpp:543`), which `uhdm-cmp`
// never walks.  A `UhdmListener` sweep follows those back-reference edges and
// would otherwise count a stale clone's whole body as live cells.
static std::set<const any*> g_tail;
// MEMOISED, because the walk is O(depth) per object and a big design has a
// million objects at depth 100+: the answer is a property of the whole chain,
// so every ancestor visited on the way gets the same answer recorded.
static std::unordered_map<const any*, bool> g_reach;
static bool reachable(const any* o) {
  // MEMOISED, because the walk is O(depth) per object and a big design has a
  // million objects at depth 100+: the answer is a property of the whole chain,
  // so every ancestor visited on the way gets the same answer recorded.
  //
  // AND CYCLE-GUARDED.  A `VpiParent` chain in a Surelog database is not
  // guaranteed acyclic — AmiqEth's golden has one, and the plain
  // `while (p->VpiParent()) p = p->VpiParent();` walk this replaced spun on it
  // forever (the census sweep hung on that one database for over eight
  // minutes before this guard existed).  On a cycle the walk cannot reach a
  // design listing OR the tail set, so it answers the CONSERVATIVE way —
  // TRUE, count the object — which is the behaviour the census had before the
  // tail filter was added at all.
  std::vector<const any*> chain;
  std::set<const any*> onPath;
  const any* p = o;
  bool ans;
  for (;;) {
    auto it = g_reach.find(p);
    if (it != g_reach.end()) { ans = it->second; break; }
    if (g_tail.count(p)) { ans = false; break; }
    if (!onPath.insert(p).second) { ans = true; break; }   // cycle
    chain.push_back(p);
    if (!p->VpiParent()) { ans = g_roots.count(p) != 0; break; }
    p = p->VpiParent();
  }
  for (const any* q : chain) g_reach[q] = ans;
  return ans;
}

struct Cen : public UhdmListener {
  std::set<uint32_t> seen;
  void emit(const any* o, const char* kind, std::string_view name,
            const any* prefix, size_t narg, bool withp, bool funcp) {
    if (!reachable(o)) return;
    if (!seen.insert(o->UhdmId()).second) return;
    std::string pfx = "-";
    unsigned al = o->VpiLineNo(), ac = o->VpiColumnNo();
    if (prefix) {
      pfx = esc(((const expr*)prefix)->VpiName());
      if (prefix->VpiLineNo()) { al = prefix->VpiLineNo(); ac = prefix->VpiColumnNo(); }
    }
    // the FILE: the call's own, else the nearest ancestor that carries one
    std::string file(o->VpiFile());
    const any* p = o->VpiParent();
    std::set<const any*> fseen;
    while (file.empty() && p && fseen.insert(p).second) {
      file = std::string(p->VpiFile());
      p = p->VpiParent();
    }
    size_t sl = file.find_last_of('/');
    if (sl != std::string::npos) file = file.substr(sl + 1);
    printf("CALL KIND=%s NAME=%s PFX=%s NARG=%zu WITH=%d FUNC=%d PK=%s "
           "ANCH=%u:%u SPAN=%u:%u-%u:%u FILE=%s ROOT=%s\n",
           kind, esc(name).c_str(), pfx.c_str(), narg, withp ? 1 : 0,
           funcp ? 1 : 0, kindName(o->VpiParent()).c_str(), al, ac,
           o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo(), file.empty() ? "-" : file.c_str(), g_root);
  }
  void enterFunc_call(const func_call* const o) final {
    emit(o, "FC", o->VpiName(), nullptr,
         o->Tf_call_args() ? o->Tf_call_args()->size() : 0, false,
         o->Function() != nullptr);
  }
  void enterMethod_func_call(const method_func_call* const o) final {
    emit(o, "MFC", o->VpiName(), o->Prefix(),
         o->Tf_call_args() ? o->Tf_call_args()->size() : 0,
         o->With() != nullptr, o->Function() != nullptr);
  }
  void enterTask_call(const task_call* const o) final {
    emit(o, "TC", o->VpiName(), nullptr,
         o->Tf_call_args() ? o->Tf_call_args()->size() : 0, false,
         o->Task() != nullptr);
  }
  // A `hier_path` is the OTHER shape this population takes — it is what
  // golden mints for the same built-in call in EXPRESSION position, and what
  // it mints for a `this.`-rooted STATEMENT receiver.  Printing it here is what
  // makes the shape flip a PAIRED cell instead of a one-sided row.
  void enterHier_path(const hier_path* const o) final {
    emit(o, "HP", o->VpiName(), nullptr,
         o->Path_elems() ? o->Path_elems()->size() : 0, false, false);
  }
  void enterMethod_task_call(const method_task_call* const o) final {
    emit(o, "MTC", o->VpiName(), o->Prefix(),
         o->Tf_call_args() ? o->Tf_call_args()->size() : 0,
         o->With() != nullptr, o->Task() != nullptr);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct151cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  // CT151CEN_NOTAIL=1 SKIPS the tail pass.  UHDM's visitor FORMATS every line
  // even into a sink — on AmiqEth's 62 MB golden that alone runs for more than
  // eight minutes — so a whole-corpus scan runs with the pass OFF.  With it off
  // the census can only OVER-count (a stale clone's cells are counted as well
  // as the live ones), so a corpus scan that names a mover set with the pass
  // off has named it A FORTIORI.  The pass is ON by default and was ON for
  // every arm, boundary and mover measurement in this directory.
  if (getenv("CT151CEN_NOTAIL") == nullptr) {
    // run UHDM's own dump visitor into a sink to learn the tail set
    struct NullBuf : std::streambuf {
      int overflow(int c) override { return c; }
    } nb;
    std::ostream sink(&nb);
    VpiVisitor vis(sink);
    visit_designs(restored, &vis);
    g_tail = vis.getWeaklyReferenced();
  }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    Cen c;
    g_roots.clear();
    auto collect = [&](auto* vec) {
      if (!vec) return;
      for (auto* p : *vec) {
        const any* r = p;
        std::set<const any*> onPath;
        while (r->VpiParent() && onPath.insert(r).second) r = r->VpiParent();
        g_roots.insert(r);
      }
    };
    collect(d->AllPackages());
    collect(d->TopPackages());
    collect(d->AllClasses());
    collect(d->TopModules());
    collect(d->AllModules());
    collect(d->AllPrograms());
    collect(d->AllInterfaces());
    auto sweep = [&](const char* tag, auto* vec) {
      if (!vec) return;
      g_root = tag;
      for (auto* p : *vec) c.listenAny(p);
    };
    sweep("ALLPKG", d->AllPackages());
    sweep("TOPPKG", d->TopPackages());
    sweep("ALLCLS", d->AllClasses());
    sweep("TOPMOD", d->TopModules());
    sweep("ALLMOD", d->AllModules());
    sweep("ALLPRG", d->AllPrograms());
    sweep("ALLIFC", d->AllInterfaces());
  }
  return 0;
}
