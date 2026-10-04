// r11u231: every task/function with its parent kind/name and its STORED full name (not the synthesised one).
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  s.Restore(std::string(argv[1]));
  for (auto& pr : s.AllObjects()) {
    auto* o = pr.first; if (!o) continue;
    if (o->UhdmType() != uhdmfunction && o->UhdmType() != uhdmtask) continue;
    auto* tf = (const task_func*)o;
    auto* p = o->VpiParent();
    printf("%s %s %u:%u par=%s:%s stored=[%s]\n", UhdmName(o->UhdmType()).data(), std::string(tf->VpiName()).c_str(),
           o->VpiLineNo(), o->VpiColumnNo(), p ? UhdmName(p->UhdmType()).data() : "-", p ? std::string(p->VpiName()).c_str() : "-",
           std::string(tf->VpiFullName()).c_str());
  }
}
