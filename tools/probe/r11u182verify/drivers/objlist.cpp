// objlist.cpp <db.uhdm> <uhdm type name>: every serialized object of that kind (reachable or not), in serializer
// order, with its file basename, span, name, full name and its parent's kind/name (r11u182: the union-clone
// parent check behind the castUnionCloneFile171 dump-tail difference).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <filesystem>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; auto designs = s.Restore(std::string(argv[1]));
  std::string want = argv[2];
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (std::string(UhdmName(o->UhdmType())) != want) continue;
    const BaseClass* p = o->VpiParent();
    std::string f(o->VpiFile());
    std::cout << "id" << o->UhdmId() << " " << std::filesystem::path(f).filename().string() << " " << o->VpiLineNo() << ":" << o->VpiColumnNo()
              << "-" << o->VpiEndLineNo() << ":" << o->VpiEndColumnNo() << " name=" << o->VpiName()
              << " parent=" << (p ? std::string(UhdmName(p->UhdmType())) + "#" + std::to_string(p->UhdmId()) + ":" + std::string(p->VpiName()) : "-") << "\n";
  }
}
