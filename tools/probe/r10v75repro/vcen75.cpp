// r10v75 (VERIFIER) — INDEPENDENT whole-design constant census, keyed on the
// constant's own SPAN (line:col-endline:endcol; the FILE is dropped because our
// databases leave VpiFile EMPTY on a folded constant — RESUME §9) with a
// COMPARE-VISIBLE payload: the fields ANY generated Compare reads on a
// constant (VpiConstType / VpiSize / VpiValue / VpiDecompile) split from the
// ref_typespec edge (present? Actual_typespec kind / name / defname / signed /
// its own span).  A flat Serializer::AllObjects walk — deliberately NOT the
// listener route r10earl75repro/cscen75.cpp uses, so the two instruments are
// independent.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
//   build: g++ -O2 -std=c++17 vcen75.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vcen75
//   usage: vcen75 <db.uhdm> [--ts|--val]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
int main(int argc, char** argv) {
  bool wantTs = true, wantVal = true;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--ts")) wantVal = false;
    if (!strcmp(argv[i], "--val")) wantTs = false;
  }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    const constant* c = any_cast<const constant*>(obj);
    if (!c) continue;
    char key[128];
    snprintf(key, sizeof(key), "%u:%u-%u:%u", c->VpiLineNo(), c->VpiColumnNo(),
             c->VpiEndLineNo(), c->VpiEndColumnNo());
    std::string pay;
    if (wantVal) {
      char b[512];
      snprintf(b, sizeof(b), "ct=%d sz=%d v=%s d=%s", c->VpiConstType(),
               c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str());
      pay += b;
    }
    if (wantTs) {
      const ref_typespec* rt = c->Typespec();
      char b[768];
      if (!rt) snprintf(b, sizeof(b), " ts=NONE");
      else {
        const typespec* at = rt->Actual_typespec();
        if (!at) snprintf(b, sizeof(b), " ts=RT_NOACTUAL rtname=%s",
                          esc(rt->VpiName()).c_str());
        else {
          int sgn = -1;
          if (const int_typespec* it = any_cast<const int_typespec*>(at))
            sgn = it->VpiSigned() ? 1 : 0;
          snprintf(b, sizeof(b),
                   " ts=%d tsname=%s tsdef=%s tssgn=%d tsspan=%u:%u-%u:%u",
                   (int)at->UhdmType(), esc(at->VpiName()).c_str(),
                   esc(at->VpiDefName()).c_str(), sgn, at->VpiLineNo(),
                   at->VpiColumnNo(), at->VpiEndLineNo(), at->VpiEndColumnNo());
        }
      }
      pay += b;
    }
    printf("%s %s\n", key, pay.c_str());
  }
  return 0;
}
