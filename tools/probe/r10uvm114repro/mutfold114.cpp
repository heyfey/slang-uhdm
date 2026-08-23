// r10uvm114 — MUTATION PROBE (measurement only): restore a database, fold the
// LEFT/RIGHT bound of every `range` whose bound is a vpiSubOp/vpiAddOp/vpiMultOp
// over two constants, under a typespec owner whose VpiName matches a filter,
// then save.  Used to test a candidate law against the OFFICIAL uhdm-cmp
// BEFORE writing emitter code.
//   usage: mutfold114 <in.uhdm> <out.uhdm> <name-substr|-> [ids...]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>
using namespace UHDM;

static long long cval(const constant* c, bool& ok) {
  std::string v(c->VpiValue());
  auto p = v.find(':');
  if (p == std::string::npos) { ok = false; return 0; }
  std::string d = v.substr(p + 1);
  try { return std::stoll(d); } catch (...) { ok = false; return 0; }
}
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: mutfold114 in out namefilter [ids...]\n"); return 2; }
  std::string filter(argv[3]);
  std::set<uint32_t> ids;
  for (int i = 4; i < argc; i++) ids.insert((uint32_t)atoi(argv[i]));
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  auto all = s.AllObjects();
  int folded = 0;
  for (auto& kv : all) {
    const BaseClass* o = kv.first;
    if (!o || o->UhdmType() != uhdmrange) continue;
    range* r = (range*)o;
    const any* ow = r->VpiParent();
    std::string on = ow ? std::string(ow->VpiName()) : std::string();
    if (filter != "-" && on.find(filter) == std::string::npos) continue;
    if (!ids.empty() && !ids.count((uint32_t)r->UhdmId())) continue;
    for (int side = 0; side < 2; side++) {
      expr* b = side ? r->Right_expr() : r->Left_expr();
      if (!b || b->UhdmType() != uhdmoperation) continue;
      operation* op = (operation*)b;
      int ot = op->VpiOpType();
      if (ot != vpiSubOp && ot != vpiAddOp && ot != vpiMultOp) continue;
      if (!op->Operands() || op->Operands()->size() != 2) continue;
      any* a0 = (*op->Operands())[0];
      any* a1 = (*op->Operands())[1];
      if (a0->UhdmType() != uhdmconstant || a1->UhdmType() != uhdmconstant) continue;
      bool ok = true;
      long long v0 = cval((constant*)a0, ok), v1 = cval((constant*)a1, ok);
      if (!ok) continue;
      long long v = (ot == vpiSubOp) ? v0 - v1 : (ot == vpiAddOp) ? v0 + v1 : v0 * v1;
      constant* c = s.MakeConstant();
      std::string d = std::to_string(v);
      c->VpiDecompile(d);
      c->VpiSize(64);
      bool isInt = (ot != vpiAddOp);
      c->VpiValue((isInt ? "INT:" : "UINT:") + d);
      c->VpiConstType(isInt ? vpiIntConst : vpiUIntConst);
      c->VpiParent(r);
      c->VpiFile(a0->VpiFile());
      c->VpiLineNo(a0->VpiLineNo());
      c->VpiColumnNo(a0->VpiColumnNo());
      c->VpiEndLineNo(a0->VpiEndLineNo());
      c->VpiEndColumnNo(a0->VpiEndColumnNo());
      if (side) r->Right_expr(c); else r->Left_expr(c);
      folded++;
    }
  }
  fprintf(stderr, "FOLDED %d\n", folded);
  s.Save(std::string(argv[2]));
  return 0;
}
