// v146 VERIFIER census — IDENTITY-aware: for each ref_obj of a named set, print
// the ACTUAL's kind, name, value/decompile and its OWNER (parent kind+name).
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
static std::string val(const any* a) {
  if (!a) return "-";
  if (const expr* e = any_cast<const expr*>(a)) {
    std::string v(e->VpiValue()); std::string d(e->VpiDecompile());
    return v + "/" + d;
  }
  return "-";
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
  const design* d = (const design*)((const uhdm_handle*)h[0])->object;
  if (d->Parameters())
    for (auto* p : *d->Parameters())
      printf("LIST|%s|%s|imported=%s|%s\n", std::string(p->VpiName()).c_str(),
             std::string(UhdmName(p->UhdmType())).c_str(),
             p->UhdmType()==uhdmparameter?std::string(((const parameter*)p)->VpiImported()).c_str():"",
             val(p).c_str());
  if (d->Param_assigns())
    for (auto* pa : *d->Param_assigns())
      printf("LISTPA|%s|%s|%s\n", pa->Lhs()?std::string(pa->Lhs()->VpiName()).c_str():"<null>",
             pa->Rhs()?std::string(UhdmName(pa->Rhs()->UhdmType())).c_str():"<null>",
             val(pa->Rhs()).c_str());
  for (const auto& [obj, id] : s.AllObjects()) {
    if (!obj || obj->UhdmType() != uhdmref_obj) continue;
    const ref_obj* r = (const ref_obj*)obj;
    const any* act = r->Actual_group();
    std::string own = "-";
    if (act && act->VpiParent())
      own = std::string(UhdmName(act->VpiParent()->UhdmType())) + ":" +
            std::string(act->VpiParent()->VpiName());
    std::string chain; const BaseClass* p = obj->VpiParent();
    for (int g=0; p && g<8; g++, p=p->VpiParent()) { if(g) chain += ">"; chain += std::string(UhdmName(p->UhdmType())); if(p->UhdmType()==uhdmdesign) break; }
    printf("REF|%s|%u:%u|%s|%s|%s|%s|%s\n", std::string(obj->VpiName()).c_str(),
           obj->VpiLineNo(), (unsigned)obj->VpiColumnNo(),
           act?std::string(UhdmName(act->UhdmType())).c_str():"<null>",
           act?std::string(act->VpiName()).c_str():"-",
           val(act).c_str(), own.c_str(), chain.c_str());
  }
  return 0;
}
