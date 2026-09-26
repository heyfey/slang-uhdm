// objchain.cpp <db.uhdm> <uhdm type name> [substring of the full name]: every serialized object of that kind whose
// VpiFullName (ref_typespec / ref_obj) contains the substring, with its full name, span and its parent chain
// (kind:name@line:col) up to the design, sorted, so two databases can be compared object by object (r11u182).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string fn(const BaseClass* o) {
  if (o->UhdmType() == uhdmref_typespec) return std::string(((const ref_typespec*)o)->VpiFullName());
  if (o->UhdmType() == uhdmref_obj) return std::string(((const ref_obj*)o)->VpiFullName());
  return std::string(o->VpiName());
}
int main(int argc, char** argv) {
  Serializer s; auto designs = s.Restore(std::string(argv[1]));
  std::string want = argv[2], sub = argc > 3 ? argv[3] : "";
  std::vector<std::string> out;
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (std::string(UhdmName(o->UhdmType())) != want) continue;
    std::string f = fn(o);
    if (!sub.empty() && f.find(sub) == std::string::npos) continue;
    std::string ch;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
      if (p->UhdmType() == uhdmdesign) break;
      std::string nm(p->VpiName().empty() ? p->VpiDefName() : p->VpiName());
      ch += " < " + std::string(UhdmName(p->UhdmType())) + ":" + nm + "@" + std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo());
    }
    out.push_back(f + " | " + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + ch);
  }
  std::sort(out.begin(), out.end());
  for (auto& l : out) std::cout << l << "\n";
}
