// r11u225: the per-package listings (typedef, task/func, class) of both package sections, in vector order, with ids.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
using namespace UHDM;
static void pk(const char* sec, const package* p) {
  printf("%s %s id=%u\n", sec, std::string(p->VpiName()).c_str(), p->UhdmId());
  if (p->Typespecs()) for (auto* t : *p->Typespecs()) printf("  typespec %u %d %s %u:%u par=%u inst=%u\n", t->UhdmId(), (int)t->UhdmType(), std::string(t->VpiName()).c_str(), t->VpiLineNo(), t->VpiColumnNo(), t->VpiParent()?t->VpiParent()->UhdmId():0, t->Instance()?t->Instance()->UhdmId():0);
  if (p->Task_funcs()) for (auto* t : *p->Task_funcs()) printf("  taskfunc %u %s %u:%u\n", t->UhdmId(), std::string(t->VpiName()).c_str(), t->VpiLineNo(), t->VpiColumnNo());
  if (p->Class_defns()) for (auto* t : *p->Class_defns()) printf("  class %u %s\n", t->UhdmId(), std::string(t->VpiName()).c_str());
}
int main(int argc, char** argv) {
  Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  for (auto* dh : designs) { const design* d = UhdmDesignFromVpiHandle(dh);
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) pk("all", p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) pk("top", p);
  }
}
