// r11u111 -- which package object is which listing (measurement only).
// Prints, for AllPackages then TopPackages, each package's id and its
// vpiTypedef entries (kind, name, id, parent id, instance id), and each
// parameter's typespec actual id.  Ids are the ones uhdm-cmp prints.
// build: g++ -O2 -std=c++17 pkgids111.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pkgids111
#include <uhdm/uhdm.h>
#include <cstdio>
#include <string>
#include <filesystem>
using namespace UHDM;
static void pk(const char* lbl, const std::vector<package*>* v) {
  if (!v) return;
  for (auto* p : *v) {
    printf("%s package %s id:%u\n", lbl, std::string(p->VpiName()).c_str(), p->UhdmId());
    if (p->Typespecs())
      for (auto* t : *p->Typespecs())
        printf("   td %s(%s) id:%u parent:%u inst:%u\n", UhdmName(t->UhdmType()).data(),
               std::string(t->VpiName()).c_str(), t->UhdmId(),
               t->VpiParent() ? t->VpiParent()->UhdmId() : 0,
               t->Instance() ? t->Instance()->UhdmId() : 0);
    if (p->Parameters())
      for (auto* a : *p->Parameters()) {
        const typespec* ts = nullptr;
        if (a->UhdmType() == uhdmparameter && ((parameter*)a)->Typespec())
          ts = ((parameter*)a)->Typespec()->Actual_typespec();
        printf("   param %s id:%u ts:%s(%s) id:%u\n", std::string(a->VpiName()).c_str(), a->UhdmId(),
               ts ? UhdmName(ts->UhdmType()).data() : "-", ts ? std::string(ts->VpiName()).c_str() : "",
               ts ? ts->UhdmId() : 0);
      }
  }
}
int main(int argc, char** argv) {
  Serializer s;
  auto v = s.Restore(std::filesystem::path(argv[1]));
  for (auto* h : v) {
    design* d = UhdmDesignFromVpiHandle(h);
    pk("ALL", d->AllPackages());
    pk("TOP", d->TopPackages());
  }
}
