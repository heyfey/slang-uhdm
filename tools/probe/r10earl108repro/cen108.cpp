// r10earl108 -- THE INSTANCE param_assign Rhs CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; nothing here judges anything.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// POPULATION.  Every `param_assign` in the arena, on either side, in either
// view.  Unlike r10earl107's census (which walked the OPERANDS of pattern
// operations) this one walks the CARRIER, because this pass's cell is one
// where golden holds an OPERATION and we hold a CONSTANT: an operand-keyed
// population cannot see a row that has no operands on our side at all.
//
// KEY   view | the Lhs parameter's vpiFullName | the param_assign's own span |
//       vpiOverriden.  The fullname already carries the full instance path, so
//       it names the cell across the two tools.  No FILE is in the key --
//       our constants carry an EMPTY VpiFile (RESUME.md section 9) and keying
//       on it splits every row into ONLY-GOLDEN + ONLY-OURS.
//
// PAYLOAD  the Rhs's COMPARE-VISIBLE shape and nothing else:
//       the Rhs object KIND (this is what `BaseClass::Compare` reads FIRST, and
//       it is where this pass's head fails), then for a constant its
//       VpiDecompile / VpiSize / VpiConstType / VpiValue, and for an operation
//       its VpiOpType, its operand COUNT and each operand's own triple, plus
//       the ACTUAL typespec kind + name behind its ref_typespec and that
//       ref_typespec's fullname (golden's is connection-scoped).  No location
//       is in the payload: no generated Compare reads one.
//
// FORMAL is a reported column (the Lhs parameter's own typespec kind), because
// Surelog's substitution matrix is keyed on exactly that
// (CompileHelper.cpp:5303 collapses only a `logic_typespec` formal), so the
// arms of that matrix must be scored separately.
//
// Duplicate (key,payload) pairs are DEDUPED per side before the join: both
// tools keep several arena copies of the same param_assign (a definition
// listing and an elaborated one), and a NODEDUP multiset join manufactures
// AWAY-GOLDEN phantoms out of the copy counts alone (RESUME.md section 9).
//
// build:
//   g++ -O2 -std=c++17 cen108.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen108
// usage:
//   cen108 <golden.uhdm> <ours.uhdm> <viewtag> [--raw]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <variant>
#include <vector>
using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
  if (!o) return "<null>";
  char b[128];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
           (unsigned)o->VpiEndColumnNo());
  return b;
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "";
  auto pv = o->GetVpiPropertyValue(vpiFullName);
  if (std::holds_alternative<const char*>(pv)) {
    const char* p = std::get<const char*>(pv);
    if (p && *p) return p;
  }
  return std::string(o->VpiName());
}
static const typespec* actualOf(const ref_typespec* rt) {
  return rt ? rt->Actual_typespec() : nullptr;
}
static std::string tsTag(const ref_typespec* rt) {
  const typespec* t = actualOf(rt);
  if (!t) return "<none>";
  std::string s(UhdmName(t->UhdmType()));
  std::string n = fullOf(t);
  if (!n.empty()) s += "(" + n + ")";
  return s;
}
// the compare-visible triple of one expression operand
static std::string leaf(const any* o) {
  if (!o) return "<null>";
  std::string s(UhdmName(o->UhdmType()));
  if (const constant* c = any_cast<const constant*>(o)) {
    char b[512];
    snprintf(b, sizeof b, "[dc=%s;sz=%d;ct=%d;v=%s]",
             std::string(c->VpiDecompile()).c_str(), c->VpiSize(),
             c->VpiConstType(), std::string(c->VpiValue()).c_str());
    s += b;
  } else if (const operation* op = any_cast<const operation*>(o)) {
    char b[64];
    snprintf(b, sizeof b, "[op=%d;n=%zu]", op->VpiOpType(),
             op->Operands() ? op->Operands()->size() : (size_t)0);
    s += b;
    if (op->Operands())
      for (auto* x : *op->Operands()) s += "," + leaf(x);
  } else if (const tagged_pattern* tp = any_cast<const tagged_pattern*>(o)) {
    s += "[" + tsTag(tp->Typespec()) + "]," + leaf(tp->Pattern());
  } else {
    std::string n = fullOf(o);
    if (!n.empty()) s += "(" + n + ")";
  }
  return s;
}
static std::string rhsShape(const param_assign* pa) {
  const any* r = pa->Rhs();
  if (!r) return "<no-rhs>";
  std::string s = leaf(r);
  if (const expr* e = any_cast<const expr*>(r)) {
    if (const ref_typespec* rt = e->Typespec()) {
      s += " ts=" + tsTag(rt);
      std::string fn = fullOf(rt);
      s += " tsfn=" + (fn.empty() ? std::string("<bare>") : fn);
    } else {
      s += " ts=<none>";
    }
  }
  return s;
}
static std::string formalOf(const param_assign* pa) {
  const any* l = pa->Lhs();
  if (!l) return "<no-lhs>";
  if (const parameter* p = any_cast<const parameter*>(l)) return tsTag(p->Typespec());
  return std::string(UhdmName(l->UhdmType()));
}

int main(int argc, char** argv) {
  if (argc < 4) {
    fprintf(stderr, "usage: cen108 <golden.uhdm> <ours.uhdm> <view> [--raw]\n");
    return 2;
  }
  bool raw = false;
  for (int i = 4; i < argc; i++)
    if (!strcmp(argv[i], "--raw")) raw = true;
  const char* view = argv[3];

  // side 0 = GOLDEN (LHS), side 1 = OURS (RHS)
  std::map<std::string, std::set<std::string>> rows[2];  // key -> payloads
  std::map<std::string, std::string> formal[2];
  for (int side = 0; side < 2; side++) {
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1 + side]));
    if (restored.empty()) {
      fprintf(stderr, "CENRC=3 empty restore %s\n", argv[1 + side]);
      return 3;
    }
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = kv.first;
      if (!o || o->UhdmType() != uhdmparam_assign) continue;
      const param_assign* pa = (const param_assign*)o;
      const any* l = pa->Lhs();
      std::string nm = l ? fullOf(l) : std::string("<no-lhs>");
      if (nm.empty()) continue;
      char key[2048];
      snprintf(key, sizeof key, "%s|%s|%s|ov=%d", view, nm.c_str(),
               spanOf(pa).c_str(), pa->VpiOverriden() ? 1 : 0);
      rows[side][key].insert(rhsShape(pa));
      formal[side][key] = formalOf(pa);
    }
  }

  std::set<std::string> keys;
  for (int side = 0; side < 2; side++)
    for (auto& kv : rows[side]) keys.insert(kv.first);

  size_t same = 0, diff = 0, onlyG = 0, onlyO = 0;
  for (auto& k : keys) {
    auto gi = rows[0].find(k), oi = rows[1].find(k);
    const char* verdict;
    if (gi == rows[0].end()) { verdict = "ONLY-OURS"; onlyO++; }
    else if (oi == rows[1].end()) { verdict = "ONLY-GOLDEN"; onlyG++; }
    else if (gi->second == oi->second) { verdict = "SAME"; same++; }
    else { verdict = "DIFF"; diff++; }
    if (!raw && !strcmp(verdict, "SAME")) continue;
    std::string f = gi != rows[0].end() ? formal[0][k] : formal[1][k];
    std::string gs, os;
    if (gi != rows[0].end()) for (auto& p : gi->second) gs += (gs.empty() ? "" : " ;; ") + p;
    if (oi != rows[1].end()) for (auto& p : oi->second) os += (os.empty() ? "" : " ;; ") + p;
    printf("%s\tFORMAL=%s\tKEY=%s\tG=%s\tO=%s\n", verdict, f.c_str(), k.c_str(),
           gs.c_str(), os.c_str());
  }
  printf("## view=%s SAME=%zu DIFF=%zu ONLY-GOLDEN=%zu ONLY-OURS=%zu TOTAL=%zu\n",
         view, same, diff, onlyG, onlyO, keys.size());
  return 0;
}
