// r11u157 objtab: every hier_path of a database with its Path_elems in order:
//   P <id> <name> <file> <line:col:endline:endcol> <parent type>
//   E <id> <type> <name> <vpi fullname as the strict comparator reads it> <file> <span>
// (the element's vpi full name is vpi_get_str(vpiFullName): empty when it equals the name).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <map>
#include <vector>
static std::string base(std::string_view f) { std::string s(f); auto p = s.find_last_of('/'); return p == std::string::npos ? s : s.substr(p + 1); }
static std::string span(const UHDM::BaseClass* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + ":" + std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
int main(int argc, char** argv) {
  UHDM::Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  std::map<uint32_t, const UHDM::hier_path*> hp;
  for (auto& kv : s.AllObjects()) {
    const UHDM::BaseClass* o = (const UHDM::BaseClass*)kv.first;
    if (o->UhdmType() == UHDM::uhdmhier_path) hp[o->UhdmId()] = (const UHDM::hier_path*)o;
  }
  for (auto& [id, p] : hp) {
    std::cout << "P\t" << id << '\t' << p->VpiName() << '\t' << base(p->VpiFile()) << '\t' << span(p) << '\t'
              << (p->VpiParent() ? UHDM::UhdmName(p->VpiParent()->UhdmType()) : "-") << '\n';
    if (!p->Path_elems()) continue;
    for (auto* e : *p->Path_elems()) {
      vpiHandle eh = NewVpiHandle(e);
      const char* fn = vpi_get_str(vpiFullName, eh);
      std::cout << "E\t" << e->UhdmId() << '\t' << UHDM::UhdmName(e->UhdmType()) << '\t' << e->VpiName() << '\t' << (fn ? fn : "")
                << '\t' << base(e->VpiFile()) << '\t' << span(e) << '\t' << (e->VpiParent() == p ? "par=hp" : "par=other") << '\n';
      vpi_release_handle(eh);
    }
  }
}
