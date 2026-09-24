// r11u121 constid: every constant at <line.col>: id, size, value, parent kind and the parent's own parent kind
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  s.Restore(std::filesystem::path(argv[1]));
  std::string at = argv[2];
  std::map<const BaseClass*, std::string> rhsOf;
  for (auto& [obj, id] : s.AllObjects())
    if (obj && obj->UhdmType() == uhdmcont_assign) {
      auto ca = (const cont_assign*)obj;
      if (ca->Rhs()) rhsOf[ca->Rhs()] += " rhs-of-ca" + std::to_string(id) + "(par=" + (ca->VpiParent() ? std::string(UhdmName(ca->VpiParent()->UhdmType())) : "-") + ")";
    }
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj || obj->UhdmType() != uhdmconstant) continue;
    std::string k = std::to_string(obj->VpiLineNo()) + "." + std::to_string(obj->VpiColumnNo());
    if (k != at) continue;
    auto c = (const constant*)obj;
    const BaseClass* p = c->VpiParent();
    std::cout << "id" << id << " size=" << c->VpiSize() << " val=" << c->VpiValue() << " dec=" << c->VpiDecompile()
              << " parent=" << (p ? std::string(UhdmName(p->UhdmType())) : "-") << rhsOf[obj] << "\n";
  }
}
