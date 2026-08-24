// r10earl80 — PARAM_ASSIGN VALUE-ENCODING CENSUS, read straight from a .uhdm
// database (never uhdm-dump: Earlgrey's dump is >1 GB and takes hours).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Every param_assign the UhdmListener reaches (so: exactly what the judge can
// reach) is printed as ONE line:
//
//   PA <chain> <name> <ovr> <lhs-ts> || <rhs-kind> ct= sz= val= dec= ts= tssgn=
//
// * <chain> is the VpiParent walk (kinds + names, NO span), so the DEF listing
//   and the ELABORATED body separate by construction and a second live copy
//   under the same chain joins as a multiset duplicate (RESUME §9: multiset
//   joins, never a last-writer dict).
// * <ovr> is param_assign::VpiOverriden.
// * <lhs-ts> is the Lhs parameter's own declaration typespec kind + signedness
//   + its declared size — the "declared type" axis of the census key.
// * The payload carries ONLY fields the generated Compare reads on a constant
//   (VpiType/VpiDecompile/VpiSize/Typespec/VpiConstType) plus VpiValue, which
//   the judge does NOT read but which must follow the const type.  NO span in
//   the payload (earl60/earl65 lesson: a span-carrying payload hides flips).
//
//   build: g++ -O2 -std=c++17 pacen80.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pacen80
//   usage: pacen80 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static void tsInfo(const ref_typespec* rt, std::string& kind, int& sgn,
                   int& sz) {
  kind = "-"; sgn = -1; sz = -1;
  if (!rt) return;
  kind = "REF_NO_ACTUAL";
  const typespec* at = rt->Actual_typespec();
  if (!at) return;
  kind = std::string(UhdmName(at->UhdmType()));
  switch (at->UhdmType()) {
    case uhdmint_typespec: sgn = ((const int_typespec*)at)->VpiSigned(); break;
    case uhdminteger_typespec: sgn = ((const integer_typespec*)at)->VpiSigned(); break;
    case uhdmbit_typespec: sgn = ((const bit_typespec*)at)->VpiSigned(); break;
    case uhdmlogic_typespec: sgn = ((const logic_typespec*)at)->VpiSigned(); break;
    default: break;
  }
  (void)sz;
}
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
  void enterParam_assign(const param_assign* const pa) final {
    const any* lhs = pa->Lhs();
    std::string nm = lhs ? esc(lhs->VpiName()) : std::string("-");
    std::string lk = "-"; int lsgn = -1, lsz = -1;
    if (lhs && lhs->UhdmType() == uhdmparameter) {
      auto* p = (const parameter*)lhs;
      tsInfo(p->Typespec(), lk, lsgn, lsz);
      lsz = p->VpiSize();
    }
    const any* rhs = pa->Rhs();
    std::string rk = rhs ? std::string(UhdmName(rhs->UhdmType())) : "-";
    char pay[900];
    if (rhs && rhs->UhdmType() == uhdmconstant) {
      auto* c = (const constant*)rhs;
      std::string tk; int tsgn, tsz;
      tsInfo(c->Typespec(), tk, tsgn, tsz);
      snprintf(pay, sizeof pay, "ct=%d sz=%d val=%s dec=%s ts=%s tssgn=%d",
               c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str(), tk.c_str(), tsgn);
    } else if (rhs && rhs->UhdmType() == uhdmoperation) {
      snprintf(pay, sizeof pay, "op=%d", ((const operation*)rhs)->VpiOpType());
    } else {
      snprintf(pay, sizeof pay, "-");
    }
    // SPAN PRESENCE is scored SEPARATELY (it is not a judge-read field, but
    // golden's constant on this head is LOC-LESS and a patch that starts
    // stamping a span there is a real change).  It is the LAST token so the
    // scorer can strip it from the judge payload.
    int sp = 0;
    if (rhs) sp = (rhs->VpiLineNo() != 0 || rhs->VpiColumnNo() != 0) ? 1 : 0;
    printf("PA %s %s ovr=%d lts=%s lsgn=%d lsz=%d || %s %s SPAN=%d\n",
           chainOf(pa).c_str(), nm.c_str(), pa->VpiOverriden() ? 1 : 0,
           lk.c_str(), lsgn, lsz, rk.c_str(), pay, sp);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pacen80 <db.uhdm>\n"); return 2; }
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
