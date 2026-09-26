// pred176v: trigger of § tdKeyKeepsUnresolved176v over a PRISTINE database: an enum/struct/union
// typedef base name N typing io_decls in two different FILES, at least one of them in a PACKAGE
// subroutine (outside a class). Prints "TRIGGER <name> <files>" per hit, or nothing.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) { std::cout << "LOADFAIL\n"; return 2; }
  std::map<std::string, std::set<std::string>> filesAll, filesPkg;
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (!o || o->UhdmType() != uhdmio_decl) continue;
    auto* io = (const io_decl*)o;
    auto* rt = io->Typespec();
    if (!rt) continue;
    auto* ts = rt->Actual_typespec();
    if (!ts) continue;
    auto k = ts->UhdmType();
    if (k != uhdmenum_typespec && k != uhdmstruct_typespec && k != uhdmunion_typespec) continue;
    std::string n(ts->VpiName());
    auto p = n.rfind("::"); if (p != std::string::npos) n = n.substr(p + 2);
    if (n.empty()) continue;
    std::string file(io->VpiFile());
    bool inCls = false; std::string home = "?";
    for (const BaseClass* a = io->VpiParent(); a; a = a->VpiParent()) {
      auto t = a->UhdmType();
      if (t == uhdmclass_defn) inCls = true;
      if (t == uhdmpackage) { home = "pkg"; break; }
      if (t == uhdmmodule_inst || t == uhdminterface_inst || t == uhdmprogram) { home = "unit"; break; }
    }
    filesAll[n].insert(file);
    if (home == "pkg" && !inCls) filesPkg[n].insert(file);
  }
  for (auto& [n, fp] : filesPkg)
    if (filesAll[n].size() >= 2) {
      std::cout << "TRIGGER " << n;
      for (auto& f : filesAll[n]) std::cout << ' ' << f.substr(f.rfind('/') + 1);
      std::cout << '\n';
    }
  return 0;
}
