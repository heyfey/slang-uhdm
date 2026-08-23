// r10earl72 — TYPESPEC DETAIL reader.  For every `constant` at a given
// line:col, print the FULL set of fields uhdm-cmp reads on its typespec chain:
//   ref_typespec (nothing but the actual is compared) -> actual typespec:
//   VpiName, Typedef_alias, Instance (typespec::Compare) and, for an
//   int_typespec, Cast_to_expr / VpiSigned / Ranges (int_typespec::Compare).
// Written because § caOpFoldTs's ELAB half mints a PER-REFERENCE clone and the
// clone's Instance() is a COMPARED field: a stamp that carries the wrong
// Instance would trade a `<null>` head for an Instance head.
// MEASUREMENT ONLY.  usage: tsdet72 <db.uhdm> <line> <col>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static uint32_t L, C;
static std::string chainOf(const any* o) {
  std::string r; const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
struct F : public UhdmListener {
  void enterConstant(const constant* const o) final {
    if (o->VpiLineNo() != L || o->VpiColumnNo() != C) return;
    std::string ts = "<null>", inst = "-", alias = "-", nm = "-", rng = "-",
                sgn = "-", cast = "-", tsl = "-";
    if (auto* rt = o->Typespec()) {
      ts = "REF_NO_ACTUAL";
      if (auto* at = rt->Actual_typespec()) {
        ts = std::string(UhdmName(at->UhdmType()));
        nm = at->VpiName().empty() ? "-" : std::string(at->VpiName());
        char b[128];
        snprintf(b, sizeof b, "%u:%u-%u:%u", at->VpiLineNo(), at->VpiColumnNo(),
                 at->VpiEndLineNo(), at->VpiEndColumnNo());
        tsl = b;
        alias = at->Typedef_alias() ? "SET" : "-";
        if (const any* in = at->Instance()) {
          inst = std::string(UhdmName(in->UhdmType()));
          if (!in->VpiName().empty()) inst += "(" + std::string(in->VpiName()) + ")";
        }
        if (at->UhdmType() == uhdmint_typespec) {
          auto* it = (const int_typespec*)at;
          sgn = it->VpiSigned() ? "1" : "0";
          cast = it->Cast_to_expr() ? "SET" : "-";
          rng = it->Ranges() ? std::to_string(it->Ranges()->size()) : "-";
        }
      }
    }
    printf("C %u:%u ts=%s@%s name=%s alias=%s inst=%s sgn=%s cast=%s rng=%s | %s\n",
           o->VpiLineNo(), o->VpiColumnNo(), ts.c_str(), tsl.c_str(), nm.c_str(),
           alias.c_str(), inst.c_str(), sgn.c_str(), cast.c_str(), rng.c_str(),
           chainOf(o).c_str());
  }
};
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: tsdet72 <db> <line> <col>\n"); return 2; }
  L = atoi(argv[2]); C = atoi(argv[3]);
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  F f;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) f.listenDesign(d);
  }
  return 0;
}
