// r10uvm145 — SUBROUTINE BODY / LOCAL-INITIALISER CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge; nothing here judges.
//
// The head this pass walks is a `begin`'s Stmts VECTOR SIZE MISMATCH, so the
// census must score (a) the COUNT of a body begin's top-level statements, (b)
// the statements themselves as a bag, and (c) every subroutine local with the
// facts that separate the two Surelog productions.
//
// Three row kinds, all deduped by UhdmId so a re-listed object is one row:
//
//  ROW=BODY  one per task_func
//    HSPAN   the subroutine's own span            <- THE KEY (both producers agree)
//    HNAME   VpiName                              (diagnostic)
//    HKIND   task / function
//    BKIND   UHDM kind of Stmt()  (begin / assignment / none / ...)
//    NSTMTS  #Stmts of the body when it IS a begin, else -1   <- THE HEAD'S FIELD
//    NVARS   #Variables on the task_func                      <- production signature
//    BVARS   #Variables on the body begin                     <- production signature
//
//  ROW=STMT  one per TOP-LEVEL statement of a body begin (and the bare body stmt)
//    HSPAN   the owning subroutine's span
//    SSPAN   the statement's own span             <- the rest of the key
//    SKIND   UHDM kind
//    SLHS    for an assignment, the Lhs's kind(name); else "-"
//    SLHSVAR 1 iff that Lhs IS a `variables` object.  THE HOIST DISCRIMINATOR,
//            and Surelog's own: `compileFunction`'s body loop keeps an
//            assignment as a DECLARATION exactly when
//            `any_cast<variables*>(stmt->Lhs())` (CompileStmt.cpp:2508).  An
//            ordinary body assignment's Lhs is a `ref_obj` / `hier_path` /
//            select.  Read INSTEAD of "the Lhs is in the Variables list",
//            which under-counts in the ELAB view where a cloned listing's
//            Variables vector holds different objects than its body does.
//
//  ROW=LOC   one per variable listed on a task_func or on its body begin
//    HSPAN   the owning subroutine's span
//    LNAME   VpiName                              <- the rest of the key
//    LKIND   UHDM kind
//    LAUTO   VpiAutomatic
//    LEXPR   1 iff the variable carries vpiExpr   <- question (1)
//    LOWN    func / begin / both                  <- THE PRODUCTION SIGNATURE
//    LHOIST  1 iff some top-level body statement is an assignment whose Lhs IS
//            this very variable object                       <- THE HOISTED INITIALISER
//    LSPAN   the variable's own span              (dump-only diagnostic)
//
// Compare-relevance: `begin::Compare` reads the Stmts VECTOR (size first —
// RESUME.md §9's vector SafeCompare overload), `scope::Compare` reads
// Variables, `assignment::Compare` reads VpiOpType/VpiBlocking/Lhs/Rhs,
// `variables::Compare` reads VpiName/VpiAutomatic/... — never a span.  SPANS
// APPEAR ONLY IN KEYS, never as scored columns.
//
//   build: g++ -O2 -std=c++17 ct145cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct145cen
//   usage: ct145cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
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
static std::string uhdmKind(const any* o) {
  return o ? std::string(UhdmName(o->UhdmType())) : std::string("none");
}
static std::string kindName(const any* o) {
  if (!o) return "-";
  std::string e(UhdmName(o->UhdmType()));
  std::string n(o->VpiName());
  if (!n.empty()) e += "(" + esc(n) + ")";
  return e;
}
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

static const char* g_lst = "-";

struct Cen : public UhdmListener {
  std::set<unsigned> seen;
  void enterAny(const any* o) override {
    const task_func* tf = any_cast<const task_func*>(o);
    if (!tf) return;
    if (!seen.insert((unsigned)tf->UhdmId()).second) return;
    const std::string hspan = spanOf(tf);
    const unsigned hid = (unsigned)tf->UhdmId();
    const std::string hscope = scopeOf(tf);
    const any* body = tf->Stmt();
    const begin* bg = any_cast<const begin*>(body);
    // The TOP-LEVEL statement list of the body: the begin's Stmts, or the
    // single bare body statement when the body is not a begin at all.
    std::vector<const any*> tops;
    if (bg) { if (bg->Stmts()) for (auto* st : *bg->Stmts()) tops.push_back(st); }
    else if (body) tops.push_back(body);
    // Which variable objects are the Lhs of a top-level assignment — the
    // HOISTED INITIALISER relation, read as OBJECT IDENTITY, not by name.
    std::set<unsigned> hoisted;
    for (const any* st : tops)
      if (const assignment* as = any_cast<const assignment*>(st))
        if (const any* l = as->Lhs())
          if (any_cast<const variables*>(l)) hoisted.insert((unsigned)l->UhdmId());
    printf("ROW=BODY|HID=%u|HSPAN=%s|HNAME=%s|HKIND=%s|BKIND=%s|BSPAN=%s|NSTMTS=%d"
           "|NVARS=%d|BVARS=%d|NTOPS=%d|HSCOPE=%s|SITE=%s\n",
           hid, hspan.c_str(), esc(tf->VpiName()).c_str(),
           uhdmKind(tf).c_str(), uhdmKind(body).c_str(),
           spanOf(body).c_str(),
           bg ? (bg->Stmts() ? (int)bg->Stmts()->size() : 0) : -1,
           tf->Variables() ? (int)tf->Variables()->size() : -1,
           (bg && bg->Variables()) ? (int)bg->Variables()->size() : -1,
           (int)tops.size(), hscope.c_str(), g_lst);
    for (const any* st : tops) {
      std::string lhs = "-";
      int lhsvar = 0;
      if (const assignment* as = any_cast<const assignment*>(st)) {
        lhs = kindName(as->Lhs());
        lhsvar = (as->Lhs() && any_cast<const variables*>(as->Lhs())) ? 1 : 0;
      }
      printf("ROW=STMT|HID=%u|HSPAN=%s|SSPAN=%s|SKIND=%s|SLHS=%s|SLHSVAR=%d"
             "|HSCOPE=%s|SITE=%s\n",
             hid, hspan.c_str(), spanOf(st).c_str(), uhdmKind(st).c_str(),
             lhs.c_str(), lhsvar, hscope.c_str(), g_lst);
    }
    // The local population: the union of the two listings, tagged by WHERE it
    // is listed (that tag IS the production signature).
    std::map<unsigned, std::pair<const variables*, int>> locs;  // 1=func 2=begin
    if (tf->Variables())
      for (auto* v : *tf->Variables()) locs[(unsigned)v->UhdmId()] = {v, 1};
    if (bg && bg->Variables())
      for (auto* v : *bg->Variables()) {
        auto it = locs.find((unsigned)v->UhdmId());
        if (it == locs.end()) locs[(unsigned)v->UhdmId()] = {v, 2};
        else it->second.second |= 2;
      }
    for (auto& kv : locs) {
      const variables* v = kv.second.first;
      const char* own = kv.second.second == 3 ? "both"
                      : kv.second.second == 2 ? "begin" : "func";
      printf("ROW=LOC|HID=%u|HSPAN=%s|LNAME=%s|LKIND=%s|LAUTO=%d|LEXPR=%d|LOWN=%s"
             "|LHOIST=%d|LSPAN=%s|LPAR=%s|HSCOPE=%s|SITE=%s\n",
             hid, hspan.c_str(), esc(v->VpiName()).c_str(), uhdmKind(v).c_str(),
             v->VpiAutomatic() ? 1 : 0, v->Expr() ? 1 : 0, own,
             hoisted.count((unsigned)v->UhdmId()) ? 1 : 0,
             spanOf(v).c_str(), kindName(v->VpiParent()).c_str(),
             hscope.c_str(), g_lst);
    }
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct145cen <db.uhdm>\n"); return 2; }
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
