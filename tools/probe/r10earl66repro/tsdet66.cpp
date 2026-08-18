// r10earl65 — TYPESPEC DETAIL probe: for every constant whose span matches
// <file-basename>:<line> (optionally :<col>), print the constant's compare-visible
// fields plus EVERYTHING the judge can read about its typespec (kind, VpiSigned,
// VpiName, ranges, Typedef_alias, span).  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 tsdet65.cpp -I ~/.local/include -L ~/.local/lib64 \
//              -L ~/.local/lib -luhdm -lcapnp -lkj -o tsdet65
//   usage: tsdet65 <db.uhdm> <file.sv> <line> [col]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstdlib>
#include <string>
using namespace UHDM;
static std::string base(std::string_view f) {
  std::string s(f);
  size_t sl = s.find_last_of('/');
  return sl == std::string::npos ? s : s.substr(sl + 1);
}
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: tsdet65 <db> <file.sv> <line> [col]\n"); return 2; }
  std::string wf = argv[2];
  uint32_t wl = (uint32_t)atoi(argv[3]);
  int32_t wc = argc > 4 ? atoi(argv[4]) : -1;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    const constant* c = any_cast<const constant*>(obj);
    if (!c) continue;
    if (base(c->VpiFile()) != wf || c->VpiLineNo() != wl) continue;
    if (wc >= 0 && (int32_t)c->VpiColumnNo() != wc) continue;
    printf("C id=%u %s:%u:%u-%u:%u ct=%d sz=%d val=%s dec=%s parent=%s",
           id, base(c->VpiFile()).c_str(), c->VpiLineNo(), c->VpiColumnNo(),
           c->VpiEndLineNo(), c->VpiEndColumnNo(), c->VpiConstType(), c->VpiSize(),
           std::string(c->VpiValue()).c_str(), std::string(c->VpiDecompile()).c_str(),
           c->VpiParent() ? std::string(UhdmName(c->VpiParent()->UhdmType())).c_str() : "-");
    const ref_typespec* rt = c->Typespec();
    if (!rt) { printf(" TS=NONE\n"); continue; }
    const typespec* a = rt->Actual_typespec();
    if (!a) { printf(" TS=REF_NO_ACTUAL rtname=%s\n", std::string(rt->VpiFullName()).c_str()); continue; }
    printf(" TS=%s tsid=%u name=%s span=%s:%u:%u-%u:%u",
           std::string(UhdmName(a->UhdmType())).c_str(), s.AllObjects().count(a) ? 0u : 0u,
           std::string(a->VpiName()).c_str(), base(a->VpiFile()).c_str(),
           a->VpiLineNo(), a->VpiColumnNo(), a->VpiEndLineNo(), a->VpiEndColumnNo());
    if (auto* it = any_cast<const int_typespec*>(a))
      printf(" signed=%d val=%s ranges=%d", it->VpiSigned() ? 1 : 0,
             std::string(it->VpiValue()).c_str(), it->Ranges() ? (int)it->Ranges()->size() : -1);
    if (auto* lt = any_cast<const logic_typespec*>(a))
      printf(" signed=%d ranges=%d", lt->VpiSigned() ? 1 : 0,
             lt->Ranges() ? (int)lt->Ranges()->size() : -1);
    printf(" alias=%s\n", a->Typedef_alias() ? "yes" : "no");
  }
  return 0;
}
