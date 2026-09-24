#include <uhdm/uhdm.h>
#include <iostream>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; if (s.Restore(std::string(argv[1])).empty()) return 2;
  for (auto& kv : s.AllObjects()) {
    const any* o = kv.first; if (o->UhdmType() != uhdmref_typespec) continue;
    auto rt = any_cast<const ref_typespec*>(o);
    std::cout << "ref_typespec#" << o->UhdmId() << " full='" << rt->VpiFullName() << "' chain:";
    for (const any* p = o->VpiParent(); p; p = p->VpiParent()) std::cout << " " << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")";
    std::cout << "\n";
  }
}
