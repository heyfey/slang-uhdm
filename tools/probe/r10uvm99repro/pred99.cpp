// r10uvm99 — MEASUREMENT ONLY.  The A-PRIORI MOVER PREDICTOR.
//
// Reads ONLY OUR PRISTINE databases — never golden, never the patched binary.
// § insideSetFirstRangeTruncates99 fires exactly when an `inside` set has at
// least one `[a:b]` member, and our PRISTINE emitter renders every such member
// as an `operation(vpiListOp)` operand of the `operation(vpiInsideOp)`.  So a
// database with no vpiInsideOp carrying a vpiListOp operand CANNOT move; one
// that has such an operand moves unless its first member's first bound is a
// non-primary (the unmodelled splice), which makes this a strict SUPERSET.
//
// Prints one line per database: PRED <n-inside-with-listop> <n-inside-total>
//
// build: g++ -O2 -std=c++17 pred99.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred99
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: pred99 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAILED\n"); return 3; }
  int hit = 0, tot = 0;
  for (auto& p : s.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o || o->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)o;
    if (op->VpiOpType() != vpiInsideOp) continue;
    ++tot;
    // A CASE-INSIDE item op is built by StmtEmit, not by this law's arm, and
    // wraps EVERY member (operand 0 included) in a vpiListOp; the expression
    // arm always puts the bare LHS at operand 0.  Predict only the latter.
    bool any = false;
    if (op->Operands() && !op->Operands()->empty()) {
      auto& ops = *op->Operands();
      bool firstIsList = ops[0] && ops[0]->UhdmType() == uhdmoperation &&
                         ((const operation*)ops[0])->VpiOpType() == vpiListOp;
      if (!firstIsList)
        for (size_t i = 1; i < ops.size(); ++i)
          if (ops[i] && ops[i]->UhdmType() == uhdmoperation &&
              ((const operation*)ops[i])->VpiOpType() == vpiListOp) { any = true; break; }
    }
    if (any) ++hit;
  }
  printf("PRED %d %d\n", hit, tot);
  return 0;
}
