// r10v81 — WHOLE-DATABASE identity census, read straight from a .uhdm file.
// One line per visited object: PARENT-CHAIN (kinds+names, NO span) + depth +
// the object's own COMPARE-VISIBLE payload.  MEASUREMENT ONLY; the official
// uhdm-cmp remains the judge.  No span is carried anywhere (earl60's lesson).
//   build: g++ -O2 -std=c++17 vall81.cpp -I ~/.local/include -L ~/.local/lib64 \
//              -L ~/.local/lib -luhdm -lcapnp -lkj -o vall81
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string tsKind(const ref_typespec* rt) {
  if (!rt) return "-";
  const typespec* at = rt->Actual_typespec();
  if (!at) return "REF_NO_ACTUAL";
  return std::string(UhdmName(at->UhdmType()));
}
static std::string chainOf(const any* o, int& depth) {
  std::string r; depth = 0;
  const any* p = o->VpiParent();
  for (int i = 0; i < 60 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent(); depth++;
  }
  if (r.empty()) r = "-";
  return r;
}
struct Cen : public UhdmListener {
  void enterAny(const any* const o) final {
    if (!o) return;
    int d = 0;
    std::string ch = chainOf(o, d);
    char pay[1200];
    switch (o->UhdmType()) {
      case uhdmconstant: {
        auto* c = (const constant*)o;
        snprintf(pay, sizeof pay, "constant ct=%d sz=%d val=%s dec=%s ts=%s",
                 c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
                 esc(c->VpiDecompile()).c_str(), tsKind(c->Typespec()).c_str());
        break;
      }
      case uhdmref_obj: {
        auto* r = (const ref_obj*)o;
        const any* a = r->Actual_group();
        snprintf(pay, sizeof pay, "ref_obj nm=%s act=%s actnm=%s",
                 esc(r->VpiName()).c_str(),
                 a ? UhdmName(a->UhdmType()).data() : "-",
                 a ? esc(a->VpiName()).c_str() : "-");
        break;
      }
      case uhdmoperation:
        snprintf(pay, sizeof pay, "operation op=%d nm=%s",
                 ((const operation*)o)->VpiOpType(),
                 esc(o->VpiName()).c_str());
        break;
      default:
        snprintf(pay, sizeof pay, "%s nm=%s dn=%s",
                 UhdmName(o->UhdmType()).data(), esc(o->VpiName()).c_str(),
                 esc(o->VpiDefName()).c_str());
        break;
    }
    printf("OBJ d=%d %s || %s\n", d, ch.c_str(), pay);
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: vall81 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : r) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
