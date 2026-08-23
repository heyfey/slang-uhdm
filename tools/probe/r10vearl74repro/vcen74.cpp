// r10vearl74 — VERIFIER range-bound census.  Adds TYPESPEC PRESENCE (and the
// actual typespec kind) to the judge-visible payload, and prints SPAN PRESENCE
// as a SEPARATE field so it can be scored on its own (golden's folded bound
// here is LOC-LESS).  Direct .uhdm reader; never uhdm-dump on Earlgrey.
// MEASUREMENT ONLY.  build:
//   g++ -O2 -std=c++17 vcen74.cpp -I ~/.local/include -L ~/.local/lib64 \
//       -L ~/.local/lib -luhdm -lcapnp -lkj -o vcen74
// usage: vcen74 <db.uhdm> [--span]
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static bool g_span = false;
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
static std::string tsOf(const expr* e) {
  auto* rt = e->Typespec();
  if (!rt) return "ts=0";
  auto* at = rt->Actual_typespec();
  if (!at) return "ts=r";
  return std::string("ts=") + std::string(UhdmName(at->UhdmType()));
}
static void leg(const any* e, const std::string& path, int depth,
                std::string& out) {
  if (!e || depth > 8) return;
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    char b[512];
    if (g_span)
      snprintf(b, sizeof b, " %s{loc=%d:%d:%d:%d f=%d}", path.c_str(),
               c->VpiLineNo(), c->VpiColumnNo(), c->VpiEndLineNo(),
               c->VpiEndColumnNo(), (int)!c->VpiFile().empty());
    else
      snprintf(b, sizeof b, " %s{ct=%d sz=%d val=%s dec=%s %s}", path.c_str(),
               c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str(), tsOf(c).c_str());
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
  char b[256];
  snprintf(b, sizeof b, " %s{%s:%s}", path.c_str(),
           std::string(UhdmName(e->UhdmType())).c_str(),
           esc(e->VpiName()).c_str());
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
  if (argc < 2) { fprintf(stderr, "usage: vcen74 <db.uhdm> [--span]\n"); return 2; }
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--span")) g_span = true;
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
