// r10v94 verifier census: every vpiCastOp operand[0] that is a ref_obj, keyed by
// the ref's VpiFullName + span, payload = the Actual_group's KIND, FULLNAME and
// SPAN.  The fullname of the ACTUAL is what exposes a cross-instance bind that a
// span-only payload would hide.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass* o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string kn(const BaseClass* o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>");
}
int main(int argc, char** argv) {
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::vector<std::string> out;
  for (auto& pr : s.AllObjects()) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)o;
    if (op->VpiOpType() != vpiCastOp) continue;
    auto* ops = op->Operands();
    if (!ops || ops->empty()) continue;
    const BaseClass* c = (*ops)[0];
    if (!c || c->UhdmType() != uhdmref_obj) continue;
    const ref_obj* r = (const ref_obj*)c;
    const BaseClass* a = r->Actual_group();
    std::string line = std::string(r->VpiFullName()) + "|" + sp(r) +
                       "|op@" + sp(op) + "  =>  " + kn(a);
    if (a) {
      std::string afn;
      if (const nets* n = any_cast<const nets*>(a)) afn = std::string(n->VpiFullName());
      else if (const variables* v = any_cast<const variables*>(a)) afn = std::string(v->VpiFullName());
      else if (const scope* sc = any_cast<const scope*>(a)) afn = std::string(sc->VpiFullName());
      else if (const parameter* pp = any_cast<const parameter*>(a)) afn = std::string(pp->VpiFullName());
      else if (const gen_var* gv = any_cast<const gen_var*>(a)) afn = std::string(gv->VpiFullName());
      else afn = std::string(a->VpiName());
      line += "|" + afn + "|" + sp(a);
    }
    out.push_back(line);
  }
  std::sort(out.begin(), out.end());
  for (auto& l : out) printf("%s\n", l.c_str());
  return 0;
}
