// r10uvm127 — THE A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY.
//
// Reads a PRISTINE database ALONE (never golden, never the patched side) and
// names every cell § pkgRetOobClassAndImportCloneTs127 COULD touch:
//
//   * the argument is a ref_obj / constant / operation carrying NO
//     ref_typespec yet (the law only ADDS one);
//   * the call is a `func_call` with a BOUND `vpiFunction` (`ExprEval::evalFunc`
//     returns immediately when the callee is unresolved);
//   * the call is the DIRECT body-level `return` expression of its enclosing
//     subroutine: the parent chain is `function [ /begin ] /return_stmt
//     [ /operation ]` — every nested statement construct hardcodes Reduce::No;
//   * and the enclosing function is either
//       (a) parented by a `class_defn` whose own parent is a `package` AND
//           some package lists a task_func named `<class>::<method>` — the
//           OUT-OF-BODY class-method body half.  That listing entry is exactly
//           what an out-of-body definition produces (Surelog CompileStmt.cpp
//           :2338-2350 builds the `C::m` name at PACKAGE level), so an IN-BODY
//           method has none and is not named; or
//       (b) parented by a `package` while a function of the SAME VpiName is
//           listed in a DIFFERENTLY-NAMED package as well — the
//           WILDCARD-IMPORT-CLONE half.  Both sides of such a pair are named
//           (the key is the package NAME, so the two VIEWS of one package are
//           one entry); the predictor deliberately OVER-approximates — the home
//           package's own DEF listing and its already-stamped ELAB listing are
//           both named and neither moves, which is the fence doing its job.
//
//   build: g++ -O2 -std=c++17 pred127.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred127
//   usage: pred127 <db.uhdm>      (prints NOTHING when there is nothing to move)
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::map<std::string, std::set<std::string>> g_byName;  // tf name -> owning package NAMES
static std::set<const any*> g_seen;
static long g_cells = 0;

static bool directReturnBody(const func_call* c, const any*& fnOut) {
  const any* p = c->VpiParent();
  if (p && p->UhdmType() == uhdmoperation) p = p->VpiParent();
  if (!p || p->UhdmType() != uhdmreturn_stmt) return false;
  p = p->VpiParent();
  if (p && p->UhdmType() == uhdmbegin) p = p->VpiParent();
  if (!p || (p->UhdmType() != uhdmfunction && p->UhdmType() != uhdmtask))
    return false;
  fnOut = p;
  return true;
}

struct Pred : public UhdmListener {
  void enterFunc_call(const func_call* const c) final {
    if (!c->Function()) return;                 // unresolved callee: never stamped
    if (!g_seen.insert(c).second) return;
    const any* fn = nullptr;
    if (!directReturnBody(c, fn)) return;
    const any* own = fn->VpiParent();
    if (!own) return;
    bool halfA = false;
    if (own->UhdmType() == uhdmclass_defn && own->VpiParent() &&
        own->VpiParent()->UhdmType() == uhdmpackage)
      halfA = g_byName.count(std::string(own->VpiName()) +
                             "::" + std::string(fn->VpiName())) != 0;
    bool halfB = false;
    if (own->UhdmType() == uhdmpackage) {
      auto it = g_byName.find(std::string(fn->VpiName()));
      halfB = it != g_byName.end() && it->second.size() > 1;
    }
    if (!halfA && !halfB) return;
    if (!c->Tf_call_args()) return;
    for (auto* a : *c->Tf_call_args()) {
      auto k = a->UhdmType();
      if (k != uhdmref_obj && k != uhdmconstant && k != uhdmoperation) continue;
      if (auto* e = any_cast<const expr*>(a))
        if (e->Typespec()) continue;            // already stamped
      printf("CAND fn=%s call=%s owner=%s half=%s arg=%s@%u:%hu\n",
             std::string(fn->VpiName()).c_str(),
             std::string(c->VpiName()).c_str(),
             std::string(own->VpiName()).c_str(), halfA ? "A" : "B",
             std::string(a->VpiName()).c_str(), (unsigned)a->VpiLineNo(),
             a->VpiColumnNo());
      g_cells++;
    }
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred127 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    auto collect = [&](VectorOfpackage* v) {
      if (!v) return;
      for (auto* p : *v) {
        if (!p->Task_funcs()) continue;
        for (auto* tf : *p->Task_funcs())
          g_byName[std::string(tf->VpiName())].insert(std::string(p->VpiName()));
      }
    };
    collect(d->AllPackages());
    collect(d->TopPackages());
  }
  Pred pr;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) pr.listenDesign(d);
  }
  if (g_cells) printf("CELLS %ld\n", g_cells);
  return 0;
}
