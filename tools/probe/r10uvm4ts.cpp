// r10uvm4ts: pointer + vpiInstance projection of every package's Typespecs,
// both views.  Answers "which object does each package list, and who owns it".
//   r10uvm4ts <file.uhdm> [pkgname]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::map<const void*, long> ids;
    auto id = [&](const void* p) {
        auto it = ids.find(p);
        if (it != ids.end()) return it->second;
        long n = (long)ids.size();
        ids[p] = n;
        return n;
    };
    // Stable ids: walk ALL then TOP in order.
    for (int top = 0; top < 2; top++) {
        auto* l = top ? d->TopPackages() : d->AllPackages();
        if (!l) continue;
        for (auto* p : *l) {
            if (argc > 2 && p->VpiName() != argv[2]) continue;
            std::cout << (top ? "TOP " : "ALL ") << p->VpiName() << ":\n";
            if (!p->Typespecs()) { std::cout << "  <null>\n"; continue; }
            for (auto* t : *p->Typespecs()) {
                auto* in = t->Instance();
                auto* pa = t->VpiParent();
                std::cout << "  #" << id((const void*)t) << " "
                          << UhdmName(t->UhdmType()) << " '" << t->VpiName()
                          << "' inst="
                          << (in ? std::string(UhdmName(in->UhdmType())) + "(" +
                                       std::string(in->VpiName()) + ")"
                                 : "<null>")
                          << " parent="
                          << (pa ? std::string(UhdmName(pa->UhdmType())) + "(" +
                                       std::string(pa->VpiName()) + ")"
                                 : "<null>")
                          << "\n";
            }
        }
    }
    return 0;
}
