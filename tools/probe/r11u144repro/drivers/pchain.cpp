// pchain <db.uhdm> <type-substr> <line> [col] : print parent chain of every matching object
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_visitor.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
#include <cstdlib>
using namespace UHDM;
static std::string fn(const BaseClass* p){ vpiHandle h = NewVpiHandle(p); const char* c = vpi_get_str(vpiFullName, h); std::string r = c ? c : "(null)"; vpi_release_handle(h); return r; }
int main(int argc, char** argv) {
  if (argc < 4) { std::cerr << "usage\n"; return 2; }
  Serializer s; s.Restore(std::string(argv[1]));
  std::string ty = argv[2]; int line = std::stoi(argv[3]); int col = argc > 4 ? std::stoi(argv[4]) : -1;
  for (auto& [o, id] : s.AllObjects()) {
    const BaseClass* b = o;
    std::string tn = UhdmName(b->UhdmType());
    if (tn.find(ty) == std::string::npos) continue;
    const BaseClass* m = b;
    if (getenv("PARENT")) { m = b->VpiParent(); if (!m) continue; }
    if ((int)m->VpiLineNo() != line) continue;
    if (col >= 0 && (int)m->VpiColumnNo() != col) continue;
    std::cout << "== id " << b->UhdmId() << "\n";
    const BaseClass* p = b; int d = 0;
    while (p && d < 30) {
      std::cout << "  " << d << " " << UhdmName(p->UhdmType()) << " id=" << p->UhdmId() << " name='" << p->VpiName()
                << "' full='" << fn(p) << "' file=" << p->VpiFile() << " " << p->VpiLineNo() << ":" << p->VpiColumnNo()
                << "-" << p->VpiEndLineNo() << ":" << p->VpiEndColumnNo() << "\n";
      p = p->VpiParent(); d++;
    }
  }
}
