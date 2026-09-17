// r11u63 A-PRIORI MOVER PREDICTOR — reads PRISTINE databases only, runs no
// binary and opens no source.  A hier_path that § connPathRootOwnTs63 can
// newly stamp is one that, in the PRISTINE database, has NO Typespec while its
// Root_value is an `expr` carrying a ref_typespec with an actual.  That is a
// SUPERSET: the law fires only on the ELABORATED PORT-CONNECTION walk, while
// this scan accepts a hier_path on any road, and the law never creates a
// Root_value the pristine binary did not already create (the binding condition
// is byte-identical).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    int hits = 0;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)obj;
        if (hp->Typespec()) continue;
        const any* rv = hp->Root_value();
        if (!rv) continue;
        auto* rx = any_cast<const expr*>(rv);
        if (!rx) continue;
        auto* rt = rx->Typespec();
        if (!rt || !rt->Actual_typespec()) continue;
        hits++;
        std::cout << "CAND " << (argc > 2 ? argv[2] : argv[1]) << " path="
                  << hp->VpiName() << " parent=" << UhdmName(hp->VpiParent() ? hp->VpiParent()->UhdmType() : uhdmconstant)
                  << " root=" << UhdmName(rv->UhdmType()) << ":" << rv->VpiName()
                  << " ts=" << UhdmName(rt->Actual_typespec()->UhdmType()) << ":"
                  << rt->Actual_typespec()->VpiName() << "\n";
    }
    std::cout << "HITS " << (argc > 2 ? argv[2] : argv[1]) << " " << hits << "\n";
    return 0;
}
