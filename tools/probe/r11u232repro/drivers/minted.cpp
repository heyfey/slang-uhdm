// (r11u232) minted <db.uhdm>: variables parented at a ref_obj (drainFuncRet per-reference locals), by kind. Build as cc_objid.sh does.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::string(argv[1])); if (h.empty()) return 3;
  auto all = s.AllObjects();
  std::map<std::string,int> c; int n=0;
  for (auto& [o, id] : all) {
    n++;
    auto* p = o->VpiParent();
    std::string t = UhdmName(o->UhdmType());
    if (t.size() > 4 && t.substr(t.size()-4) == "_var" && p && p->UhdmType() == uhdmref_obj) c[t]++;
  }
  std::cout << "objects " << n << "\n"; int tot=0;
  for (auto& [k,v] : c) { std::cout << k << ' ' << v << '\n'; tot+=v; }
  std::cout << "variables parented at a ref_obj: " << tot << "\n";
}
