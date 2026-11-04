// objcensus <db>: one line per object of the design: kind, name, span and the kinds of its three
// parents (ids, files and full names left out).  Two databases' multisets are compared with
// msdist.py: an order- and identity-blind structural distance, used where the uhdm-dump line
// distance moves with the dump's first-visit expansion order.  Measurement only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int, char** argv) {
  Serializer s; s.Restore(std::filesystem::path(argv[1]));
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    std::cout << UhdmName(o->UhdmType()) << " " << o->VpiName() << " " << o->VpiLineNo() << ":" << o->VpiColumnNo()
              << "-" << o->VpiEndLineNo() << ":" << o->VpiEndColumnNo() << " |";
    const any* p = o->VpiParent();
    for (int i = 0; p && i < 3; ++i, p = p->VpiParent()) std::cout << " " << UhdmName(p->UhdmType());
    std::cout << "\n";
  }
}
