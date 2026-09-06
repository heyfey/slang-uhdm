// r10earl107 -- THE ASSIGNMENT-PATTERN OPERAND CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; nothing here judges anything.
//
// POPULATION.  Every CONSTANT that is an operand (at any nesting depth) of a
// `vpiAssignmentPatternOp` / `vpiMultiAssignmentPatternOp` operation, on either
// side, in either view.
//
// KEY   view | CARRIER kind | carrier owner fullname | operand PATH (the index
//       chain from the outermost pattern op) | the operand's own file:span.
//       The span stays IN the key here -- unlike r10earl106's, this pass's
//       moving cell keeps its span on both sides (golden and ours both anchor
//       the member value at the written token), so the span DISCRIMINATES
//       instead of splitting.  The pattern OPERATION's own span is deliberately
//       NOT in the key: golden anchors a port high_conn pattern at the
//       PATTERN's span and we anchor it at the CONNECTION's, and that
//       difference is invisible to the judge (no generated Compare reads a
//       location).
//
// PAYLOAD  the constant's COMPARE-VISIBLE triple and nothing else --
//       VpiDecompile, VpiSize, VpiConstType, VpiValue.  `expr::Compare` reads
//       VpiDecompile FIRST, then VpiSize, then Typespec; `constant::Compare`
//       then reads VpiConstType.  No location is read anywhere.
//
// CARRIER  `port` (a high_conn -- THIS pass's site), `param_assign`,
//       `cont_assign`, `assignment`, `var`/`net` or `other`; printed so the
//       control columns can be scored separately from the moving one.
//
// Duplicate (key,payload) pairs are DEDUPED per side before the join: both
// tools keep several arena copies of the same pattern (flattened and not), and
// a NODEDUP multiset join manufactures AWAY-GOLDEN phantoms out of the copy
// counts alone (RESUME.md section 9).
//
// build:
//   g++ -O2 -std=c++17 cen107.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen107
// usage:
//   cen107 <golden.uhdm> <ours.uhdm> <viewtag>
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
  char b[128];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
           o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
  return b;
}
static std::string baseName(std::string_view f) {
  std::string s(f);
  auto p = s.find_last_of('/');
  return p == std::string::npos ? s : s.substr(p + 1);
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
// The carrier: the nearest ancestor that is not an operation / tagged_pattern.
static void carrierOf(const BaseClass* op, std::string& kind, std::string& owner) {
  const BaseClass* p = op->VpiParent();
  int d = 0;
  while (p && d < 16 &&
         (p->UhdmType() == uhdmoperation || p->UhdmType() == uhdmtagged_pattern)) {
    p = p->VpiParent();
    d++;
  }
  if (!p) { kind = "NONE"; owner = ""; return; }
  kind = UhdmName(p->UhdmType());
  owner = fullOf(p);
  if (owner.empty()) owner = spanOf(p);
  // A port's own fullname is often empty: qualify with the instance above it.
  const BaseClass* q = p->VpiParent();
  int e = 0;
  while (q && e < 6 && fullOf(q).empty()) { q = q->VpiParent(); e++; }
  if (q) owner = fullOf(q) + "/" + owner;
}
static std::string payloadOf(const constant* c) {
  char b[512];
  snprintf(b, sizeof b, "dc=<%s> sz=%d ct=%d val=<%s>",
           std::string(c->VpiDecompile()).c_str(), c->VpiSize(), c->VpiConstType(),
           std::string(c->VpiValue()).c_str());
  return b;
}
static void walkOperands(const operation* op, const std::string& pre,
                         const std::string& kind, const std::string& owner,
                         const char* view, std::set<std::string>& out) {
  if (!op->Operands()) return;
  for (size_t i = 0; i < op->Operands()->size(); i++) {
    const any* o = op->Operands()->at(i);
    if (!o) continue;
    std::string path = pre.empty() ? std::to_string(i) : pre + "." + std::to_string(i);
    const any* inner = o;
    if (const tagged_pattern* tp = any_cast<const tagged_pattern*>(o)) {
      const typespec* tt = nullptr;
      if (const ref_typespec* rt = tp->Typespec()) tt = rt->Actual_typespec();
      path += "{" + std::string(tt ? tt->VpiName() : "?") + "}";
      inner = tp->Pattern();
      if (!inner) continue;
    }
    if (const constant* c = any_cast<const constant*>(inner)) {
      out.insert(std::string(view) + " | " + kind + " | " + owner + " | " + path +
                 " | " + spanOf(inner) +
                 " || " + payloadOf(c));
    } else if (const operation* io = any_cast<const operation*>(inner)) {
      int ot = io->VpiOpType();
      if (ot == vpiAssignmentPatternOp || ot == vpiMultiAssignmentPatternOp ||
          ot == vpiConcatOp)
        walkOperands(io, path, kind, owner, view, out);
    }
  }
}
static void collect(const char* db, const char* view, std::set<std::string>& out,
                    bool& ok) {
  Serializer s;
  if (s.Restore(std::string(db)).empty()) { ok = false; return; }
  ok = true;
  for (const auto& [o, id] : s.AllObjects()) {
    if (!o) continue;
    const operation* op = any_cast<const operation*>((const any*)o);
    if (!op) continue;
    int ot = op->VpiOpType();
    if (ot != vpiAssignmentPatternOp && ot != vpiMultiAssignmentPatternOp) continue;
    // Only the OUTERMOST pattern op starts a walk (a nested one is reached
    // through its parent), so the path is stable on both sides.
    const BaseClass* p = op->VpiParent();
    if (p && (p->UhdmType() == uhdmoperation || p->UhdmType() == uhdmtagged_pattern))
      continue;
    std::string kind, owner;
    carrierOf(op, kind, owner);
    walkOperands(op, "", kind, owner, view, out);
  }
}
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: cen107 <golden> <ours> <viewtag> [--raw] [--tagblind]\n"); return 2; }
  bool raw = false, tagblind = false;
  for (int i = 4; i < argc; i++) {
    if (!strcmp(argv[i], "--raw")) raw = true;
    if (!strcmp(argv[i], "--tagblind")) tagblind = true;
  }
  std::set<std::string> G, O;
  bool og = false, oo = false;
  collect(argv[1], argv[3], G, og);
  collect(argv[2], argv[3], O, oo);
  if (!og || !oo) { printf("RESTORE_FAILED g=%d o=%d\n", (int)og, (int)oo); return 3; }
  // Split key || payload and join by key.
  // --tagblind drops the `{member}` tag the census puts in the path, so a cell
  // whose OPERAND-KIND still differs (golden a tagged_pattern, ours a bare
  // constant) is still JOINED and its compare-visible payload can be scored.
  // The tag axis is then reported separately, never silently merged.
  auto split = [&](const std::string& r, std::string& k, std::string& v) {
    auto p = r.find(" || ");
    k = r.substr(0, p);
    v = r.substr(p + 4);
    if (tagblind) {
      std::string o;
      int depth = 0;
      for (char c : k) {
        if (c == '{') depth++;
        else if (c == '}') depth--;
        else if (depth == 0) o += c;
      }
      k = o;
    }
  };
  std::map<std::string, std::set<std::string>> gm, om;
  std::string k, v;
  for (auto& r : G) { split(r, k, v); gm[k].insert(v); }
  for (auto& r : O) { split(r, k, v); om[k].insert(v); }
  if (raw) {
    for (auto& [key, vs] : gm) { std::string a; for (auto& x : vs) a += "{" + x + "}"; printf("G %s || %s\n", key.c_str(), a.c_str()); }
    for (auto& [key, vs] : om) { std::string a; for (auto& x : vs) a += "{" + x + "}"; printf("O %s || %s\n", key.c_str(), a.c_str()); }
    return 0;
  }
  for (auto& [key, gv] : gm) {
    auto it = om.find(key);
    if (it == om.end()) { printf("ONLY-G %s || %s\n", key.c_str(), (*gv.begin()).c_str()); continue; }
    if (gv == it->second) { printf("SAME   %s || %s\n", key.c_str(), (*gv.begin()).c_str()); continue; }
    std::string gs, os;
    for (auto& x : gv) gs += "{" + x + "}";
    for (auto& x : it->second) os += "{" + x + "}";
    printf("DIFF   %s || G%s | O%s\n", key.c_str(), gs.c_str(), os.c_str());
  }
  for (auto& [key, ov] : om)
    if (!gm.count(key)) printf("ONLY-O %s || %s\n", key.c_str(), (*ov.begin()).c_str());
  return 0;
}
