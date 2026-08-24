// r10earl79 — RANGE-BOUND census with a COMPARE-VISIBLE payload and a
// SEPARATE span tail.  Direct .uhdm reader (never uhdm-dump on Earlgrey).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Line format:
//   RG <parent-chain, kinds+names, NO span> sz=<range VpiSize> <bound legs>
//      || SPANS: <span of every constant leg, in order>
// Everything BEFORE " || SPANS:" is judge-visible (constant::Compare reads
// VpiType/VpiName/VpiDefName, VpiDecompile, VpiSize, Typespec, VpiConstType);
// the tail is reporting only.  Scoring must use the judge half — earl78's
// rule, and earl60's lesson that a span-carrying payload hides a real flip.
//
//   build: g++ -O2 -std=c++17 rngcen79.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o rngcen79
//   usage: rngcen79 <db.uhdm>
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
static std::string spanOf(const any* o) {
  char b[80];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(),
           (unsigned)o->VpiEndColumnNo());
  return b;
}
static void leg(const any* e, const std::string& path, int depth,
                std::string& out, std::string& spans) {
  if (!e || depth > 8) return;
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    const char* ts = "-";
    if (c->Typespec()) ts = "ts";
    char b[500];
    snprintf(b, sizeof b, " %s{ct=%d sz=%d val=%s dec=%s %s}", path.c_str(),
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str(), ts);
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
  char b[300];
  snprintf(b, sizeof b, " %s{%s:%s}", path.c_str(),
           std::string(UhdmName(e->UhdmType())).c_str(),
           esc(e->VpiName()).c_str());
  out += b;
}
struct Cen : public UhdmListener {
  void enterRange(const range* const r) final {
    std::string p, sp;
    leg(r->Left_expr(), "L", 0, p, sp);
    leg(r->Right_expr(), "R", 0, p, sp);
    printf("RG %s sz=%d%s || SPANS:%s\n", chainOf(r).c_str(), r->VpiSize(),
           p.c_str(), sp.c_str());
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: rngcen79 <db.uhdm>\n"); return 2; }
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
