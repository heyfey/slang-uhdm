// r10vearl74 — CROSS-BOUNDARY PREDICTOR.  The shipped r10earl74 walks the
// bound's VpiParent chain outward WITHOUT limit; the verifier's fix stops the
// walk at the first `instance` (module_inst / interface_inst / program /
// package / udp_defn).  The two binaries can differ on a database ONLY where
// the unbounded walk's answer is found BEYOND that boundary, or differs from
// the bounded walk's answer.  Read from a PRISTINE database alone.
// MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 vcross74.cpp -I ~/.local/include -L ~/.local/lib64 \
//              -L ~/.local/lib -luhdm -lcapnp -lkj -o vcross74
//   usage: vcross74 <db.uhdm>   -> one CROSS line per divergent bound + TOTAL
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
    auto* le = r->Left_expr();
    if (!le || le->UhdmType() != uhdmconstant) return;
    if (((const constant*)le)->VpiValue() != "UINT:0") return;
    auto* re = r->Right_expr();
    if (!re || re->UhdmType() != uhdmoperation) return;
    auto* op = (const operation*)re;
    if (op->VpiOpType() != vpiSubOp || !op->Operands() ||
        op->Operands()->size() != 2) return;
    int bct; std::string btag, bdig;
    if (!decEnc((*op->Operands())[0], bct, btag, bdig)) return;
    // Walk outward twice: BOUNDED (stop after the first instance) and
    // UNBOUNDED.  Any bound whose two answers differ is a cell on which the
    // shipped patch and the fixed patch can disagree.
    std::string ansB = "-", ansU = "-", whoB = "-", whoU = "-";
    bool stopped = false;
    for (const any* up = r->VpiParent(); up; up = up->VpiParent()) {
      auto* sc = any_cast<const scope*>(up);
      if (sc && sc->Param_assigns())
        for (auto* pa : *sc->Param_assigns()) {
          if (!pa || !pa->Rhs()) continue;
          int pct; std::string ptag, pdig;
          if (!decEnc(pa->Rhs(), pct, ptag, pdig)) continue;
          if (pdig != bdig) continue;
          std::string a = ptag + "/" + std::to_string(pct);
          std::string w = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "-";
          if (!stopped && ansB == "-") { ansB = a; whoB = w; }
          if (ansU == "-") { ansU = a; whoU = w; }
          break;
        }
      if (any_cast<const instance*>(up)) stopped = true;
      if (ansU != "-") break;
    }
    if (ansB != ansU) {
      printf("CROSS %s bound=%s:%s(ct%d) bounded=%s(%s) unbounded=%s(%s)\n",
             chainOf(r).c_str(), btag.c_str(), bdig.c_str(), bct,
             ansB.c_str(), whoB.c_str(), ansU.c_str(), whoU.c_str());
      cand++;
    }
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: vcross74 <db.uhdm>\n"); return 2; }
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
