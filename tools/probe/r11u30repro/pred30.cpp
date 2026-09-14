// r11u30 — MEASUREMENT ONLY.  The A-PRIORI MOVER PREDICTOR for
// § insideOpenRangeMemberIsOneListOp30.
//
// Reads ONLY OUR PRISTINE databases -- never golden, never the patched binary.
// The law fires exactly on an `inside` EXPRESSION whose written set has at
// least one `[a:b]` member.  Our PRISTINE emitter renders such a set by
// § insideSetFirstRangeTruncates99, i.e. it DROPS every member after the first
// bound -- so the pristine operation's own span still covers the whole written
// `x inside { ... }` while its LAST operand stops early.  The gap between the
// two is the dropped text, and it is visible without reading a single golden
// byte:
//
//   GAP = op(vpiInsideOp).VpiEndColumnNo - lastOperand.VpiEndColumnNo
//         (same VpiEndLineNo), i.e. the characters between the last emitted
//         operand and the closing `}`.
//
// A COMPLETE set ends `<last member>}` so GAP is 1 (or 2 with one space).  A
// truncated set leaves the rest of the list inside the gap.  A set whose end
// line differs from its last operand's (a multi-line set) is UNKNOWN and is
// predicted as a mover, which keeps the prediction a strict SUPERSET.
//
// A CASE-INSIDE item operation (StmtEmit) and a covergroup BINS operation put a
// vpiListOp at operand 0 and are built by neither this arm nor this law; they
// are skipped by that test, exactly as r10uvm99's pred99.cpp skipped them.
//
// Prints: PRED <n-movable-inside> <n-expression-inside> <n-inside-total>
//
// build: g++ -O2 -std=c++17 pred30.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred30
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: pred30 <db>\n"); return 2; }
  int gapMax = (argc > 2) ? atoi(argv[2]) : 2;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAILED\n"); return 3; }
  int hit = 0, nexpr = 0, tot = 0;
  for (auto& p : s.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o || o->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)o;
    if (op->VpiOpType() != vpiInsideOp) continue;
    ++tot;
    if (!op->Operands() || op->Operands()->empty()) continue;
    auto& ops = *op->Operands();
    if (ops[0] && ops[0]->UhdmType() == uhdmoperation &&
        ((const operation*)ops[0])->VpiOpType() == vpiListOp)
      continue;                      // case-inside / bins shape, not this arm
    ++nexpr;
    const any* last = ops.back();
    const UHDM::expr* le = any_cast<const UHDM::expr*>(last);
    if (!le) { ++hit; continue; }    // cannot read the span -> superset
    if (le->VpiEndLineNo() != op->VpiEndLineNo()) { ++hit; continue; }
    int gap = (int)op->VpiEndColumnNo() - (int)le->VpiEndColumnNo();
    if (gap > gapMax) ++hit;
  }
  printf("PRED %d %d %d\n", hit, nexpr, tot);
  return 0;
}
