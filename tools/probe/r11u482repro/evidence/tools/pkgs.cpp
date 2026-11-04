// pkgs <db>: the design's allPackages and topPackages with ids and vpiTop.  Measurement only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int, char** argv) {
  Serializer s; auto ds = s.Restore(std::filesystem::path(argv[1]));
  for (auto h : ds) { auto* dd = (const any*)((uhdm_handle*)h)->object;
    auto* d = (design*)dd;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) std::cout << "all " << p->VpiName() << "#" << p->UhdmId() << " top=" << p->VpiTop() << "\n";
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) std::cout << "top " << p->VpiName() << "#" << p->UhdmId() << " top=" << p->VpiTop() << "\n";
  }
}
