// r10earl107 — MEASUREMENT ONLY.  Print every vpiAssignmentPatternOp /
// vpiConcatOp / vpiMultiAssignmentPatternOp operation in an arena together with
// its operands' compare-visible triple (VpiDecompile / VpiSize / VpiConstType)
// and the typespec it carries.  The official uhdm-cmp is the sole judge.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static std::string spanOf(const BaseClass* o) {
  if (!o) return "<null>";
  char b[128];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
           o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
  return b;
}
static std::string fileOf(const BaseClass* o) {
  if (!o) return "";
  std::string f(o->VpiFile());
  auto p = f.find_last_of('/');
  return p == std::string::npos ? f : f.substr(p + 1);
}
static const typespec* tsOf(const any* o) {
  if (const expr* e = any_cast<const expr*>(o))
    if (const ref_typespec* rt = e->Typespec()) return rt->Actual_typespec();
  return nullptr;
}
static void pr(const any* o, const char* tag, int idx) {
  if (!o) { printf("   %s[%d] <null>\n", tag, idx); return; }
  const typespec* t = tsOf(o);
  printf("   %s[%d] %s id:%u %s:%s", tag, idx,
         std::string(UhdmName(o->UhdmType())).c_str(), (unsigned)o->UhdmId(),
         fileOf(o).c_str(), spanOf(o).c_str());
  if (const constant* c = any_cast<const constant*>(o))
    printf("  dc='%s' size=%d val='%s' ct=%d", std::string(c->VpiDecompile()).c_str(),
           c->VpiSize(), std::string(c->VpiValue()).c_str(), c->VpiConstType());
  if (const operation* op = any_cast<const operation*>(o))
    printf("  op=%d nops=%zu", op->VpiOpType(),
           op->Operands() ? op->Operands()->size() : 0);
  if (const tagged_pattern* tp = any_cast<const tagged_pattern*>(o)) {
    const typespec* tt = nullptr;
    if (const ref_typespec* rt = tp->Typespec()) tt = rt->Actual_typespec();
    printf("  key='%s'(%s)", tt ? std::string(tt->VpiName()).c_str() : "?",
           tt ? std::string(UhdmName(tt->UhdmType())).c_str() : "?");
  }
  if (!o->VpiName().empty()) printf("  name='%s'", std::string(o->VpiName()).c_str());
  if (t) printf("  ts=%s'%s'", std::string(UhdmName(t->UhdmType())).c_str(),
                std::string(t->VpiName()).c_str());
  printf("\n");
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: dumpop107 <db> [filesubstr]\n"); return 2; }
  const char* filt = argc > 2 ? argv[2] : nullptr;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::vector<const BaseClass*> all;
  for (const auto& [o, id] : s.AllObjects()) if (o) all.push_back(o);
  std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
    return a->UhdmId() < b->UhdmId(); });
  for (const BaseClass* b : all) {
    const operation* op = any_cast<const operation*>((const any*)b);
    if (!op) continue;
    int ot = op->VpiOpType();
    if (ot != vpiAssignmentPatternOp && ot != vpiMultiAssignmentPatternOp) continue;
    if (filt && fileOf(op).find(filt) == std::string::npos) continue;
    const typespec* t = tsOf(op);
    printf("OP id:%u op=%d %s:%s ts=%s'%s' parent=%s %s\n", (unsigned)op->UhdmId(), ot,
           fileOf(op).c_str(), spanOf(op).c_str(),
           t ? std::string(UhdmName(t->UhdmType())).c_str() : "-",
           t ? std::string(t->VpiName()).c_str() : "",
           op->VpiParent() ? std::string(UhdmName(op->VpiParent()->UhdmType())).c_str() : "-",
           op->VpiParent() ? spanOf(op->VpiParent()).c_str() : "");
    if (op->Operands())
      for (size_t i = 0; i < op->Operands()->size(); i++) {
        const any* o = op->Operands()->at(i);
        pr(o, "opnd", (int)i);
        if (const tagged_pattern* tp = any_cast<const tagged_pattern*>(o)) pr(tp->Pattern(), "  patt", (int)i);
      }
  }
  return 0;
}
