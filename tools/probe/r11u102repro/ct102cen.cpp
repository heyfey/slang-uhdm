// r11u102 A-PRIORI CENSUS over PRISTINE databases.  MEASUREMENT ONLY; the
// official uhdm-cmp is the sole judge.  One row per candidate cell, each class
// a STRICT SUPERSET of the gate that lands:
//
//   B1  a net-decl-assign cont_assign whose Rhs is a func_call      (LAW B, user call)
//   B2  a net-decl-assign cont_assign whose Rhs is sys_func_call $clog2 (LAW B, $clog2)
//   B3  a PACKAGE param_assign whose Rhs is a func_call (DEF listing) (LAW B, the
//       package-parameter face — moves only where the parameter is READ)
//   A   a PACKAGE param_assign whose Rhs operation (DEF listing) has a
//       COMPARISON operation as a DIRECT operand of **, *, /, %, -, unary -
//       or +                                                        (LAW A)
//   C   a PACKAGE param_assign whose Rhs operation (DEF listing) reaches a
//       constant with an x/z digit THROUGH OPERATIONS                (LAW C, loose)
//   C2  the same through UNARY/BINARY operators only — never through a
//       concatenation, replication, pattern or CAST: the law's own walk
//       (an explicit cast is a Conversion the law never strips)     (LAW C)
//   NDA the net-decl-assign population itself (the control denominator)
//
// Build: g++ -O2 -std=c++17 ct102cen.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct102cen
// usage: ct102cen <db.uhdm> [label]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

static std::string loc(const BaseClass* o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), o->VpiColumnNo());
  return std::string(o->VpiFile()) + ":" + b;
}
static bool isCmp(int t) {
  return t == vpiLtOp || t == vpiLeOp || t == vpiGtOp || t == vpiGeOp ||
         t == vpiEqOp || t == vpiNeqOp;
}
static bool isMint(int t) {
  return t == vpiPowerOp || t == vpiMultOp || t == vpiDivOp || t == vpiModOp ||
         t == vpiSubOp || t == vpiMinusOp || t == vpiAddOp;
}
static bool hasXZ(const any* o, bool underOp, int d, bool strict = false) {
  if (!o || d > 16) return false;
  if (o->UhdmType() == uhdmconstant) {
    if (!underOp) return false;
    std::string v(((const constant*)o)->VpiValue());
    auto p = v.find(':');
    if (p == std::string::npos) return false;
    std::string pre = v.substr(0, p), dg = v.substr(p + 1);
    if (pre != "BIN" && pre != "HEX" && pre != "OCT") return false;
    return dg.find_first_of("xXzZ?") != std::string::npos;
  }
  if (o->UhdmType() == uhdmoperation) {
    auto* op = (const operation*)o;
    if (op->VpiOpType() == vpiConditionOp) return false;
    // C2 (strict): the law's own walk — unary/binary operators only, never
    // through a concatenation / replication / assignment pattern / cast.
    if (strict && (op->VpiOpType() == vpiConcatOp ||
                   op->VpiOpType() == vpiCastOp ||
                   op->VpiOpType() == vpiMultiConcatOp ||
                   op->VpiOpType() == vpiAssignmentPatternOp ||
                   op->VpiOpType() == vpiMultiAssignmentPatternOp))
      return false;
    if (op->Operands())
      for (auto* x : *op->Operands())
        if (hasXZ(x, true, d + 1, strict)) return true;
  }
  return false;
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  std::string lab = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { printf("NODB\t%s\n", lab.c_str()); return 0; }
  long nda = 0;
  for (auto& pr : s.AllObjects()) {
    const BaseClass* o = pr.first;
    if (!o) continue;
    if (o->UhdmType() == uhdmcont_assign) {
      auto* ca = (const cont_assign*)o;
      if (!ca->VpiNetDeclAssign()) continue;
      nda++;
      const any* rh = ca->Rhs();
      if (!rh) continue;
      if (rh->UhdmType() == uhdmfunc_call)
        printf("B1\t%s\t%s\t%s\n", lab.c_str(), std::string(((const func_call*)rh)->VpiName()).c_str(), loc(rh).c_str());
      else if (rh->UhdmType() == uhdmsys_func_call &&
               ((const sys_func_call*)rh)->VpiName() == "$clog2")
        printf("B2\t%s\t$clog2\t%s\n", lab.c_str(), loc(rh).c_str());
    } else if (o->UhdmType() == uhdmparam_assign) {
      auto* pa = (const param_assign*)o;
      const BaseClass* par = pa->VpiParent();
      if (!par || par->UhdmType() != uhdmpackage) continue;
      const any* rh = pa->Rhs();
      if (!rh) continue;
      std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "?";
      if (rh->UhdmType() == uhdmfunc_call)
        printf("B3\t%s\t%s\t%s\n", lab.c_str(), nm.c_str(), loc(rh).c_str());
      if (rh->UhdmType() == uhdmoperation) {
        auto* op = (const operation*)rh;
        if (isMint(op->VpiOpType()) && op->Operands())
          for (auto* x : *op->Operands())
            if (x->UhdmType() == uhdmoperation &&
                isCmp(((const operation*)x)->VpiOpType())) {
              printf("A\t%s\t%s\t%s\n", lab.c_str(), nm.c_str(), loc(rh).c_str());
              break;
            }
        if (hasXZ(rh, false, 0))
          printf("C\t%s\t%s\t%s\n", lab.c_str(), nm.c_str(), loc(rh).c_str());
        if (hasXZ(rh, false, 0, true))
          printf("C2\t%s\t%s\t%s\n", lab.c_str(), nm.c_str(), loc(rh).c_str());
      }
    }
  }
  printf("NDA\t%s\t%ld\n", lab.c_str(), nda);
  return 0;
}
