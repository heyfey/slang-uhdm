// r10earl73 — RANGE-BOUND VALUE-ENCODING CENSUS (the instrument for R0, the
// head this pass leaves behind: a `constant <- operation <- range <-
// array_var`).  Direct .uhdm reader; NEVER uhdm-dump on Earlgrey.
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Every `range` the UhdmListener reaches is printed with the Compare-visible
// fields of both bound expressions, keyed on the VpiParent chain (kinds +
// names, NO span) so the multiset join separates DEF from ELAB by
// construction.
//
//   build: g++ -O2 -std=c++17 rngcen73.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o rngcen73
//   usage: rngcen73 <db.uhdm>
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
// The first constant reachable from a bound, with the positional route to it.
static void leg(const any* e, const std::string& path, int depth,
                std::string& out) {
  if (!e || depth > 8) return;
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    char b[400];
    snprintf(b, sizeof b, " %s{ct=%d sz=%d val=%s dec=%s}", path.c_str(),
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str());
    out += b;
    return;
  }
  if (e->UhdmType() == uhdmoperation) {
    auto* op = (const operation*)e;
    if (!op->Operands()) return;
    int i = 0;
    for (auto* o : *op->Operands())
      leg(o, path + "/op" + std::to_string(op->VpiOpType()) + "[" +
                   std::to_string(i++) + "]",
          depth + 1, out);
    return;
  }
  char b[200];
  snprintf(b, sizeof b, " %s{%s:%s}", path.c_str(),
           std::string(UhdmName(e->UhdmType())).c_str(), esc(e->VpiName()).c_str());
  out += b;
}
struct Cen : public UhdmListener {
  void enterRange(const range* const r) final {
    std::string p;
    leg(r->Left_expr(), "L", 0, p);
    leg(r->Right_expr(), "R", 0, p);
    printf("RG %s sz=%d%s\n", chainOf(r).c_str(), r->VpiSize(), p.c_str());
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: rngcen73 <db.uhdm>\n"); return 2; }
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
