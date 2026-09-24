// r11u121 tsusers: every typespec object starting at <line.col> with the parents of the ref_typespecs that reference it
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
  std::map<const BaseClass*, std::string> users;
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
    auto rt = (const ref_typespec*)obj;
    if (!rt->Actual_typespec()) continue;
    const BaseClass* p = rt->VpiParent();
    users[rt->Actual_typespec()] += " " + (p ? std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")@" + std::to_string(p->VpiLineNo()) + "." + std::to_string(p->VpiColumnNo()) : std::string("-"));
  }
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj) continue;
    std::string k = std::to_string(obj->VpiLineNo()) + "." + std::to_string(obj->VpiColumnNo());
    if (k != at) continue;
    std::string n(UhdmName(obj->UhdmType()));
    if (n.find("typespec") == std::string::npos || n == "ref_typespec") continue;
    const BaseClass* p = obj->VpiParent();
    std::cout << "id" << id << " " << n << "(" << obj->VpiName() << ")@" << k << "-" << obj->VpiEndLineNo() << "." << obj->VpiEndColumnNo()
              << " parent=" << (p ? std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")" : "-") << " users:" << users[obj] << "\n";
  }
}
