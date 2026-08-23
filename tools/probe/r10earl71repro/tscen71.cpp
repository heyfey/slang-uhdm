// r10earl70 — LISTENER-DRIVEN whole-database expression census.  tscen65-69 walked
// hand-picked CONTAINERS (module_inst::Ports, Cont_assigns, gen_scope_arrays) and
// were BLIND to every copy reachable another way: earl70's head — the ELAB port
// High_conn part_select bound at flash_phy_rd.sv:143:22 — is LIVE in golden and in
// ours, and the container census did not print it in the testflags view at all.
// This version drives off UHDM's own UhdmListener, so every object the judge can
// reach is visited, and keys each cell on the PARENT CHAIN (kinds + names) instead
// of a hand-built owner string.
//
// r10earl67 — PARAMETER-READ CENSUS (extends r10earl66repro/tscen66.cpp)
// r10earl65 — TYPESPEC-PRESENCE CENSUS over expression constants, read straight
// from a .uhdm database (never uhdm-dump: Earlgrey's dump is >1 GB).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Extends r10earl64repro/excen64.cpp: same positional key (owner, site,
// positional route from the site root), same DEF/ELAB split, but the payload
// now carries what earl64's R0 head is about — the constant's TYPESPEC:
//
//   TS <sec> <owner> <site> <path> <kind> span=<f:l:c-l:c> ct= sz= val= dec= \
//      ts=<kindname|-> tsspan=<f:l:c-l:c> tsname=<n> tssgn=<0|1>
//
// Sites covered: cont_assign Lhs/Rhs, port High_conn, param_assign Rhs,
// (net|variable) declaration assignment expression, and range bounds of the
// instance's own typespecs are NOT walked (they are not where the head lives).
//
//   build: g++ -O2 -std=c++17 tscen65.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o tscen65
//   usage: [R66_INST=1] tscen65 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string OWN, INST;
static bool WITHINST = false;
static char SITE[256];

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string base(std::string_view f) {
  std::string s(f);
  size_t sl = s.find_last_of('/');
  if (sl != std::string::npos) s = s.substr(sl + 1);
  if (s.empty()) s = "-";
  return s;
}
static std::string span(const any* o) {
  char b[256];
  snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
           o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo());
  return b;
}
static void emit(const std::string& path, const any* e) {
  std::string kn = std::string(UhdmName(e->UhdmType()));
  char buf[1400];
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    std::string ts = "-", tsp = "-", tsn = "-";
    int tssgn = -1;
    if (auto* rt = c->Typespec()) {
      ts = "REF_NO_ACTUAL";
      if (auto* at = rt->Actual_typespec()) {
        ts = std::string(UhdmName(at->UhdmType()));
        tsp = span(at);
        tsn = esc(at->VpiName());
        if (at->UhdmType() == uhdmint_typespec)
          tssgn = ((const int_typespec*)at)->VpiSigned() ? 1 : 0;
        else if (at->UhdmType() == uhdminteger_typespec)
          tssgn = ((const integer_typespec*)at)->VpiSigned() ? 1 : 0;
      }
    }
    snprintf(buf, sizeof buf,
             "ct=%d sz=%d val=%s dec=%s ts=%s tsname=%s tssgn=%d tsspan=%s",
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str(), ts.c_str(),
             tsn.c_str(), tssgn, tsp.c_str());
  } else if (e->UhdmType() == uhdmref_obj) {
    auto* r = (const ref_obj*)e;
    std::string ak = "-", av = "-", ad = "-";
    int asz = -1, act = -1;
    if (const any* a = r->Actual_group()) {
      ak = std::string(UhdmName(a->UhdmType()));
      if (a->UhdmType() == uhdmenum_const) {
        auto* ec = (const enum_const*)a;
        av = esc(ec->VpiValue()); ad = esc(ec->VpiDecompile());
        asz = ec->VpiSize();
      } else if (auto* ex = any_cast<const expr*>(a)) {
        av = esc(ex->VpiValue()); ad = esc(ex->VpiDecompile()); asz = ex->VpiSize();
      }
      (void)act;
    }
    std::string afn = "-";
    if (const any* a = r->Actual_group()) {
      if (auto* a1 = any_cast<const parameter*>(a)) afn = esc(a1->VpiFullName());
      else if (auto* a2 = any_cast<const variables*>(a)) afn = esc(a2->VpiFullName());
      else if (auto* a3 = any_cast<const nets*>(a)) afn = esc(a3->VpiFullName());
      else if (auto* a4 = any_cast<const gen_var*>(a)) afn = esc(a4->VpiFullName());
      else if (auto* a5 = any_cast<const scope*>(a)) afn = esc(a5->VpiFullName());
    }
    snprintf(buf, sizeof buf,
             "name=%s actual=%s aval=%s adec=%s asz=%d afn=%s",
             esc(e->VpiName()).c_str(), ak.c_str(), av.c_str(), ad.c_str(), asz,
             afn.c_str());
  } else {
    snprintf(buf, sizeof buf, "name=%s", esc(e->VpiName()).c_str());
  }
  printf("TS %s %s %s %s span=%s %s\n", OWN.c_str(),
         SITE, path.c_str(), kn.c_str(), span(e).c_str(), buf);
}

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 32) return;
  switch (e->UhdmType()) {
    case uhdmconstant:
    case uhdmref_obj:
    case uhdmref_var:
      emit(path, e);
      return;
    case uhdmbit_select:
      emit(path, e);
      walk(((const bit_select*)e)->VpiIndex(), path + "/idx", depth + 1);
      return;
    case uhdmpart_select: {
      auto* p = (const part_select*)e;
      emit(path, e);
      walk(p->Left_range(), path + "/l", depth + 1);
      walk(p->Right_range(), path + "/r", depth + 1);
      return; }
    case uhdmindexed_part_select: {
      auto* p = (const indexed_part_select*)e;
      emit(path, e);
      walk(p->Base_expr(), path + "/b", depth + 1);
      walk(p->Width_expr(), path + "/w", depth + 1);
      return; }
    case uhdmvar_select: {
      auto* p = (const var_select*)e;
      emit(path, e);
      if (p->Exprs()) { int i = 0;
        for (auto* x : *p->Exprs()) walk(x, path + "/e[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      if (h->Path_elems()) { int i = 0;
        for (auto* p : *h->Path_elems()) walk(p, path + "/hp[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string me = path + "/op" + std::to_string(op->VpiOpType());
      if (op->Operands()) { int i = 0;
        for (auto* o : *op->Operands()) walk(o, me + "[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmtagged_pattern: {
      auto* tp = (const tagged_pattern*)e;
      std::string nm;
      if (auto* rt = tp->Typespec())
        if (auto* at = rt->Actual_typespec()) nm = std::string(at->VpiName());
      walk(tp->Pattern(), path + "/tp:" + nm, depth + 1);
      return; }
    case uhdmfunc_call: {
      auto* f = (const func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/arg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/sarg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    default: return;
  }
}


// ---------------------------------------------------------------------------
// The listener driver.  Key = <chain> <site> <path>; the chain is the VpiParent
// walk from the site up to the design, kinds and names only (no span), so the
// DEF listing (ref_module <- named_begin <- gen_for) and the ELABORATED tree
// (module_inst <- gen_scope <- gen_scope_array) separate by construction and a
// SECOND live copy under the same chain simply joins as a multiset duplicate.
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
struct Cen : public UhdmListener {
  void enterPort(const port* const p) final {
    if (!p->High_conn()) return;
    OWN = chainOf(p);
    snprintf(SITE, sizeof SITE, "HC_%s_L%u:%u", esc(p->VpiName()).c_str(),
             p->VpiLineNo(), p->VpiColumnNo());
    walk(p->High_conn(), "HC", 0);
  }
  void enterCont_assign(const cont_assign* const ca) final {
    OWN = chainOf(ca);
    snprintf(SITE, sizeof SITE, "CA_L%u:%u", ca->VpiLineNo(), ca->VpiColumnNo());
    walk(ca->Lhs(), "LHS", 0);
    walk(ca->Rhs(), "RHS", 0);
  }
  void enterParam_assign(const param_assign* const pa) final {
    OWN = chainOf(pa);
    std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : std::string("-");
    snprintf(SITE, sizeof SITE, "PA_%s", esc(nm).c_str());
    walk(pa->Rhs(), "PA", 0);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: tscen70 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
