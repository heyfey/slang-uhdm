// r10uvm16a: census of typespec OBJECTS by name-substring.  Answers "is the
// bare-named typespec the SAME object as the qualified one, or a sibling?" —
// the question the pass-15 residue left open for the typedef NAMING half.
//   r10uvm16a <file.uhdm> <substr>
// Prints every typespec whose VpiName contains <substr>: id, kind, name,
// line:col, parent kind+name, and whether it appears in some package's
// Typespecs() vector.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string sub = argc > 2 ? argv[2] : "";

    // which typespecs are listed in some package/module Typespecs vector
    std::map<const BaseClass*, std::string> listed;
    auto scan = [&](const char* lbl, auto* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p->Typespecs()) continue;
            for (auto* t : *p->Typespecs())
                listed[t] += std::string(lbl) + ":" + std::string(p->VpiName()) + " ";
        }
    };
    scan("DEFPKG", d->AllPackages());
    scan("ELABPKG", d->TopPackages());
    scan("DEFMOD", d->AllModules());
    scan("ELABMOD", d->TopModules());

    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o) continue;
        auto* t = dynamic_cast<const typespec*>(o);
        if (!t) continue;
        std::string n(t->VpiName());
        if (!sub.empty() && n.find(sub) == std::string::npos) continue;
        const BaseClass* par = t->VpiParent();
        std::cout << "id=" << t->UhdmId() << " " << UhdmName(t->UhdmType())
                  << " '" << n << "' " << t->VpiLineNo() << ":"
                  << t->VpiColumnNo() << " parent="
                  << (par ? std::string(UhdmName(par->UhdmType())) + "'" +
                                std::string(par->VpiName()) + "'"
                          : "<null>")
                  << " inst="
                  << (t->Instance() ? std::string(t->Instance()->VpiName())
                                    : "<null>")
                  << " listed=[" << listed[o] << "]\n";
    }
    return 0;
}
