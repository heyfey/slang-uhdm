// r10earl89 — DIMENSION-BOUND TYPESPEC census.  Direct .uhdm reader (never
// uhdm-dump on Earlgrey: earl61's rule).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One line per `range`, keyed on the OWNER CHAIN + the owner's declared kind +
// the range's ORDINAL among its owner's ranges (a two-dimension declaration
// owns two ranges with the same chain — earl79's rngcen79 keyed on the chain
// alone and would have merged them).  The payload carries ONLY fields a
// generated `Compare` reads (constant: VpiValue/VpiSize/VpiConstType/
// VpiDecompile/Typespec; the typespec's own kind + VpiSigned + whether it is
// LOCATED), and NO SPAN — earl60/earl69: a span-carrying payload hides a flip.
// The span tail after " || SPANS:" is reporting only and must not be scored.
//
//   build: g++ -O2 -std=c++17 dimts89.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o dimts89
//   usage: dimts89 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' || c == '|' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  char b[80];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(),
           (unsigned)o->VpiEndColumnNo());
  return b;
}
// The whole typespec answer for one constant, judge-visible only.
static std::string tsOf(const constant* c) {
  const ref_typespec* rt = c->Typespec();
  if (!rt) return "TS=none";
  const typespec* at = rt->Actual_typespec();
  if (!at) return "TS=ref/none";
  std::string r = "TS=";
  r += UhdmName(at->UhdmType());
  bool sgn = false;
  if (auto* it = any_cast<const int_typespec*>(at)) sgn = it->VpiSigned();
  else if (auto* lt = any_cast<const logic_typespec*>(at)) sgn = lt->VpiSigned();
  else if (auto* bt = any_cast<const bit_typespec*>(at)) sgn = bt->VpiSigned();
  r += sgn ? "/sgn" : "/uns";
  // LOCATED vs BARE: a package's own typespec keeps its declaration span, the
  // freshly-minted leaf typespec has none.  This is NOT the constant's span.
  r += at->VpiLineNo() ? "/loc" : "/bare";
  if (!at->VpiName().empty()) r += "/n:" + esc(at->VpiName());
  return r;
}
static void leg(const any* e, const std::string& path, int depth,
                std::string& out, std::string& spans) {
  if (!e || depth > 8) return;
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    char b[900];
    snprintf(b, sizeof b, " %s{ct=%d sz=%d val=%s dec=%s %s}", path.c_str(),
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str(), tsOf(c).c_str());
    out += b;
    spans += " " + path + "@" + spanOf(c);
    return;
  }
  if (e->UhdmType() == uhdmoperation) {
    auto* op = (const operation*)e;
    if (!op->Operands()) return;
    int i = 0;
    for (auto* o : *op->Operands())
      leg(o, path + "/op" + std::to_string(op->VpiOpType()) + "[" +
                   std::to_string(i++) + "]",
          depth + 1, out, spans);
    return;
  }
  char b[400];
  snprintf(b, sizeof b, " %s{%s:%s}", path.c_str(),
           std::string(UhdmName(e->UhdmType())).c_str(),
           esc(e->VpiName()).c_str());
  out += b;
}
struct Cen : public UhdmListener {
  std::map<std::string, int> ord;
  void enterRange(const range* const r) final {
    std::string p, sp;
    leg(r->Left_expr(), "L", 0, p, sp);
    leg(r->Right_expr(), "R", 0, p, sp);
    const any* par = r->VpiParent();
    std::string ok = par ? std::string(UhdmName(par->UhdmType())) : "-";
    std::string key = chainOf(r) + "|" + ok;
    int n = ord[key]++;
    printf("RG %s|#%d sz=%d%s || SPANS:%s\n", key.c_str(), n, r->VpiSize(),
           p.c_str(), sp.c_str());
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: dimts89 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
