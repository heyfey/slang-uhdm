// r10earl79 — SIZE-FORM UNPACKED DIMENSION scanner: every `range` whose owner
// is an `array_var`/`array_net` and whose Right_expr is the `[0 : E-1]`
// `vpiSubOp` shape, printed with the fold constant's judge-visible fields AND
// its FILE + SPAN (so a caller can read the WRITTEN FORM back out of the
// source and split "an expression" from "a bare name / a literal" — the exact
// line that separates § dimExprBoundFold79's population from
// § dimBoundInheritsParamEnc74's).
//
// MEASUREMENT ONLY.  Direct .uhdm reader; the official uhdm-cmp is the judge.
//
//   build: g++ -O2 -std=c++17 dimscan79.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o dimscan79
//   usage: dimscan79 <db.uhdm>
//   line:  DIM <ownerkind> <ownername> ct=<> sz=<> val=<> dec=<> @<file>:<span>
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
struct Scan : public UhdmListener {
  void enterRange(const range* const r) final {
    const any* p = r->VpiParent();
    if (!p) return;
    UHDM_OBJECT_TYPE pk = p->UhdmType();
    if (pk != uhdmarray_var && pk != uhdmarray_net) return;
    const any* re = r->Right_expr();
    if (!re || re->UhdmType() != uhdmoperation) return;
    auto* op = (const operation*)re;
    if (op->VpiOpType() != 11 || !op->Operands() || op->Operands()->size() != 2)
      return;
    const any* o0 = (*op->Operands())[0];
    if (!o0 || o0->UhdmType() != uhdmconstant) return;
    auto* c = (const constant*)o0;
    printf("DIM %s %s ct=%d sz=%d val=%s dec=%s @%s:%u:%u-%u:%u\n",
           std::string(UhdmName(pk)).c_str(), esc(p->VpiName()).c_str(),
           c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
           esc(c->VpiDecompile()).c_str(),
           esc(c->VpiFile().empty() ? p->VpiFile() : c->VpiFile()).c_str(),
           (unsigned)c->VpiLineNo(), (unsigned)c->VpiColumnNo(),
           (unsigned)c->VpiEndLineNo(), (unsigned)c->VpiEndColumnNo());
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: dimscan79 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Scan c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
