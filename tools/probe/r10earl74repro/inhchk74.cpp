// r10earl74 — MOVER PREDICTOR, read from a PRISTINE database ALONE.
//
// § dimBoundInheritsParamEnc74 can only ever rewrite the (vpiConstType, value
// tag) of the FIRST operand of a size-form unpacked dimension bound, i.e. the
// `constant` inside `range(Left = UINT:0/64, Right = operation(vpiSubOp,
// [<constant>, INT:1/64]))`.  It rewrites it to the encoding of the
// `param_assign` of the parameter that sized the dimension, found by walking
// the bound's own VpiParent chain outward.
//
// A database can therefore move ONLY IF it already contains such a bound whose
// (ct, tag) differs from that of a `param_assign` Rhs constant, in an
// enclosing scope, carrying the SAME DECOMPILE DIGITS.  Matching on the digits
// instead of the (unrecorded) parameter name makes this a deliberate
// OVER-approximation: it flags every database that COULD move, never fewer.
//
// MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 inhchk74.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o inhchk74
//   usage: inhchk74 <db.uhdm>      prints one CAND line per candidate + a TOTAL
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static bool decEnc(const any* e, int& ct, std::string& tag, std::string& dig) {
  if (!e || e->UhdmType() != uhdmconstant) return false;
  auto* c = (const constant*)e;
  ct = c->VpiConstType();
  if (ct != vpiIntConst && ct != vpiUIntConst) return false;
  std::string v(c->VpiValue());
  auto p = v.find(':');
  if (p == std::string::npos) return false;
  tag = v.substr(0, p);
  dig = std::string(c->VpiDecompile());
  if (dig.empty()) dig = v.substr(p + 1);
  return true;
}
struct Chk : public UhdmListener {
  int cand = 0;
  void enterRange(const range* const r) final {
    // size form: Left is a bare UINT:0, Right is a vpiSubOp over [const, 1]
    auto* le = r->Left_expr();
    if (!le || le->UhdmType() != uhdmconstant) return;
    if (((const constant*)le)->VpiValue() != "UINT:0") return;
    auto* re = r->Right_expr();
    if (!re || re->UhdmType() != uhdmoperation) return;
    auto* op = (const operation*)re;
    if (op->VpiOpType() != vpiSubOp || !op->Operands() ||
        op->Operands()->size() != 2)
      return;
    int bct; std::string btag, bdig;
    if (!decEnc((*op->Operands())[0], bct, btag, bdig)) return;
    // walk outward for a param_assign Rhs with the same digits
    for (const any* up = r->VpiParent(); up; up = up->VpiParent()) {
      auto* sc = any_cast<const scope*>(up);
      if (!sc || !sc->Param_assigns()) continue;
      for (auto* pa : *sc->Param_assigns()) {
        if (!pa || !pa->Rhs()) continue;
        int pct; std::string ptag, pdig;
        if (!decEnc(pa->Rhs(), pct, ptag, pdig)) continue;
        if (pdig != bdig) continue;
        if (pct == bct && ptag == btag) continue;
        printf("CAND %s bound=%s:%s(ct%d) pa=%s:%s(ct%d) lhs=%s\n",
               chainOf(r).c_str(), btag.c_str(), bdig.c_str(), bct,
               ptag.c_str(), pdig.c_str(), pct,
               pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "-");
        cand++;
        return;
      }
    }
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: inhchk74 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Chk c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  printf("TOTAL %d\n", c.cand);
  return c.cand ? 1 : 0;
}
