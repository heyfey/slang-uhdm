// (r11u293: copied from r11u291repro/drivers)
// (v11u293: copied from r11u293repro/drivers)
// (r11u291: copied from r11u289repro/drivers)
// r11u285 objinfo <db.uhdm> <regex>: every object the listener reaches (each once) whose type, name or stored full
// name matches <regex>: its UhdmId, type, name, stored VpiFullName, vpi_get_str(vpiFullName) and the parent chain
// (id:type:name). A decode aid only; it opens the one database it is given.
#include <uhdm/uhdm.h>
#include <uhdm/VpiListener.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <regex>
#include <set>
#include <cstdlib>
#include <vector>
using namespace UHDM;
struct L : VpiListener {
  std::regex re; std::set<const any*> seen;
  void enterAny(const any* o, vpiHandle h) override {
    if (!seen.insert(o).second) return;
    std::string t = UhdmName(o->UhdmType()), n(o->VpiName()), f; vpiHandle hh = h; (void)hh;
    if (auto* m = dynamic_cast<const ref_typespec*>(o)) f = m->VpiFullName(); else if (auto* v = dynamic_cast<const variables*>(o)) f = v->VpiFullName(); else if (auto* x = dynamic_cast<const typespec_member*>(o)) f = std::string(x->VpiName());
    if (!std::regex_search(t + " " + n + " " + f, re)) return;
    const char* c = vpi_get_str(vpiFullName, h);
    std::cout << "#" << o->UhdmId() << " " << t << " name=" << n << " full=" << f << " vpi=" << (c ? c : "")
              << " at " << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\n   parents:";
    for (const any* p = o->VpiParent(); p; p = p->VpiParent())
      std::cout << " #" << p->UhdmId() << ":" << UhdmName(p->UhdmType()) << ":" << p->VpiName();
    std::cout << "\n   path:";
    for (auto* a : callstack) std::cout << " #" << a->UhdmId() << ":" << UhdmName(a->UhdmType());
    std::cout << "\n";
  }
};
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  // fail closed on $FENCED (four names): a path naming a fenced test is refused before it is opened
  const char* fz = getenv("FENCED");
  if (!fz) { std::cerr << "objinfo: FENCED unset\n"; return 2; }
  std::vector<std::string> fn; { std::string w; for (const char* c = fz;; ++c) { if (!*c || *c == ' ') { if (!w.empty()) fn.push_back(w); w.clear(); if (!*c) break; } else w += *c; } }
  if (fn.size() != 4) { std::cerr << "objinfo: FENCED not 4 names\n"; return 2; }
  for (auto& f : fn) if (std::regex_search(std::string(argv[1]), std::regex("(^|[^A-Za-z0-9_])" + f + "([^A-Za-z0-9_]|$)"))) { std::cerr << "objinfo: fenced path refused\n"; return 2; }
  Serializer s; std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
  L l; l.re = std::regex(argv[2]);
  l.listenDesigns(designs);
  return 0;
}
