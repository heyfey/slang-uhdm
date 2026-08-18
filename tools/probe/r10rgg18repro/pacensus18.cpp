// r10rgg18/pacensus18.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every `param_assign` in a database, in
// BOTH views, with the Compare-VISIBLE payload of its Rhs (and of the Lhs
// parameter), because this pass's head is a param_assign Rhs CONSTANT whose
// `vpiDecompile` disagrees (`expr::Compare` reads VpiDecompile FIRST, then
// VpiSize, then Typespec; `constant::Compare` then reads VpiConstType —
// UHDM/build/generated/src/{expr,constant}.cpp).
//
// The key carries NO field that any generated Compare reads except the names:
// the span and the scope path are the cross-side OBJECT IDENTITY for the
// multiset join (the same use r10rgg14/16/17 made of them).
//
// Objects are enumerated by UhdmListener::listenDesign — the REACHABLE walk
// uhdm-dump makes.  Serializer::AllObjects() also returns the WEAKLY-REFERENCED
// TAIL, which the judge never compares and which manufactures phantom
// "ours-only" keys (RESUME §9); it is used here ONLY to COUNT that tail.
//
// TRAP (r10rgg11/12/13/15/16/17): Vpi*()/UhdmName() return string_views;
// handing one to printf("%s") writes raw bytes plus NULs and turns the census
// file BINARY, after which grep prints nothing.  Everything is materialised.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>

using namespace UHDM;

static std::string S(std::string_view v) { return std::string(v); }
static std::string kindOf(const any* o) {
  return o ? S(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string fullOf(const any* o) {
  if (!o) return "-";
  std::string f;
  if (auto* sc = any_cast<const scope*>(o)) f = S(sc->VpiFullName());
  else if (auto* ro = any_cast<const ref_obj*>(o)) f = S(ro->VpiFullName());
  else if (auto* nt = any_cast<const nets*>(o)) f = S(nt->VpiFullName());
  else if (auto* vr = any_cast<const variables*>(o)) f = S(vr->VpiFullName());
  else if (auto* ia = any_cast<const instance_array*>(o)) f = S(ia->VpiFullName());
  else if (auto* ga = any_cast<const gen_scope_array*>(o)) f = S(ga->VpiFullName());
  if (f.empty()) f = S(o->VpiName());
  if (f.empty()) f = kindOf(o);
  return f;
}
static std::string spanOf(const BaseClass* o) {
  if (!o) return "-";
  char b[96];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           (unsigned short)o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(),
           (unsigned short)o->VpiEndColumnNo());
  return b;
}
// The DECLARED TYPE, rendered from the typespec the object points at: kind,
// signedness where the kind carries it, and the declared width from the range.
static std::string tsOf(const ref_typespec* rt, int depth = 0);
static std::string tsBody(const typespec* t, int depth) {
  if (!t) return "<null>";
  if (depth > 4) return "...";
  std::string k = S(UhdmName(t->UhdmType()));
  if (k.rfind("uhdm", 0) == 0) k = k.substr(4);
  std::string r = k;
  const VectorOfrange* rg = nullptr;
  int sgn = -1;
  switch (t->UhdmType()) {
    case uhdmbit_typespec:
      rg = ((const bit_typespec*)t)->Ranges();
      sgn = ((const bit_typespec*)t)->VpiSigned() ? 1 : 0; break;
    case uhdmlogic_typespec:
      rg = ((const logic_typespec*)t)->Ranges(); break;
    case uhdmint_typespec: sgn = 1; break;
    case uhdminteger_typespec: sgn = 1; break;
    case uhdmbyte_typespec: sgn = 1; break;
    case uhdmshort_int_typespec: sgn = 1; break;
    case uhdmlong_int_typespec: sgn = 1; break;
    default: break;
  }
  if (sgn >= 0) r += sgn ? "/s" : "/u";
  if (rg && !rg->empty()) {
    r += "[";
    for (size_t i = 0; i < rg->size(); i++) {
      auto* one = rg->at(i);
      r += (i ? "," : "");
      auto lit = [&](const expr* e) -> std::string {
        if (!e) return "?";
        if (e->UhdmType() == uhdmconstant)
          return S(((const constant*)e)->VpiDecompile());
        return kindOf(e);
      };
      r += lit(one->Left_expr()) + ":" + lit(one->Right_expr());
    }
    r += "]";
  }
  return r;
}
static std::string tsOf(const ref_typespec* rt, int depth) {
  if (!rt) return "-";
  return tsBody(rt->Actual_typespec(), depth);
}
// The Compare-visible encoding of an arbitrary Rhs sub-expression.
static std::string enc(const any* e, int depth = 0) {
  if (!e) return "<null>";
  if (depth > 5) return "...";
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (const constant*)e;
      char b[1024];
      snprintf(b, sizeof b, "C{v=%s,sz=%d,ct=%d,dec=%s,ts=%s}",
               S(c->VpiValue()).c_str(), (int)c->VpiSize(),
               (int)c->VpiConstType(), S(c->VpiDecompile()).c_str(),
               tsOf(c->Typespec()).c_str());
      return b;
    }
    case uhdmref_obj: return "R{" + S(((const ref_obj*)e)->VpiName()) + "}";
    case uhdmoperation: {
      auto* o = (const operation*)e;
      std::string r = "O" + std::to_string(o->VpiOpType()) + "(";
      if (auto* ops = o->Operands())
        for (size_t i = 0; i < ops->size(); i++)
          r += (i ? "," : "") + enc(ops->at(i), depth + 1);
      return r + ")";
    }
    default:
      return kindOf(e) + "{" + S(e->VpiName()) + "}";
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pacensus18 <db.uhdm> [tag]\n"); return 2; }
  const char* tag = argc > 2 ? argv[2] : "";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  struct PaCollect final : public UhdmListener {
    std::vector<const param_assign*> pas;
    std::set<const void*> once;
    void enterParam_assign(const param_assign* const o) override {
      if (once.insert(o).second) pas.push_back(o);
    }
  } coll;
  size_t arenaPa = 0;
  for (auto& [obj, id] : s.AllObjects())
    if (obj && obj->UhdmType() == uhdmparam_assign) arenaPa++;
  for (auto h : restored)
    coll.listenDesign((design*)((uhdm_handle*)h)->object);
  std::vector<std::string> rows;
  for (auto* pa : coll.pas) {
    const BaseClass* root = pa;
    for (int g = 0; g < 128 && root->VpiParent(); g++) root = root->VpiParent();
    std::string scpath = "-";
    for (const BaseClass* a = pa->VpiParent(); a; a = a->VpiParent())
      if (auto* sc = any_cast<const scope*>(a)) {
        std::string f = S(sc->VpiFullName());
        if (!f.empty()) { scpath = f; break; }
      }
    const any* lhs = pa->Lhs();
    std::string lname = lhs ? S(lhs->VpiName()) : std::string("-");
    std::string lkind = kindOf(lhs);
    std::string lval = "-", lsz = "-", lsgn = "-", lts = "-";
    if (lhs && lhs->UhdmType() == uhdmparameter) {
      auto* p = (const parameter*)lhs;
      lval = S(p->VpiValue());
      lsz = std::to_string(p->VpiSize());
      lsgn = p->VpiSigned() ? "1" : "0";
      lts = tsOf(p->Typespec());
    }
    std::string key = std::string(tag) +
                      "\tROOT=" + fullOf(root) +
                      "\tSCOPE=" + scpath +
                      "\tNAME=" + lname +
                      "\tPAAT=" + spanOf(pa);
    const any* rhs = pa->Rhs();
    std::string pay = "LK=" + lkind + "\tLVAL=" + lval + "\tLSZ=" + lsz +
                      "\tLSGN=" + lsgn + "\tLTS=" + lts +
                      "\tRK=" + kindOf(rhs) +
                      "\tRAT=" + spanOf(rhs) +
                      "\tRHS=" + enc(rhs);
    rows.push_back(key + "\t||\t" + pay);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "param_assigns_reachable=%zu arena_param_assigns=%zu unreachable_tail=%zu\n",
          rows.size(), arenaPa,
          arenaPa > coll.pas.size() ? arenaPa - coll.pas.size() : 0);
  return 0;
}
