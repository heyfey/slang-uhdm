// r10det1repro/dtpop.cpp — THE POPULATION CENSUS, counted as OBJECTS.
//
// The campaign's own measurement law: an object is NOT a dump occurrence.
// `uhdm-dump | grep -c vpiTypedefAlias` counts PRINTS, and uhdm-dump re-prints
// back-references, so that number is inflated by an unknown factor (r10oth8 F3
// caught a 2.6x inflation of exactly this shape).  This probe restores the
// database and walks `Serializer::AllObjects()`, so every count below is a count
// of DISTINCT OBJECTS.
//
// Prints, for ONE database:
//     ALIAS   <n>   objects whose Typedef_alias() is non-null
//     CTS     <n>   class_typespec objects
//     TOTAL   <n>   all objects
//   and, with `--ids`, the ALLOBJ iteration order as
//     <idx> <id> <kind> <name> <file>:<line>:<col>
//   so the address-order iteration this emitter performs at 15 sites can be
//   compared between two runs WITHOUT any address entering the comparison.
//
//   usage: dtpop <db.uhdm> [--ids]
//
// GUARDS:
//   * a database that restores to NOTHING is `UNMEASURED: no objects`, exit 4 —
//     a zero count must never read as "the population is empty".
//   * Restore() is checked for an empty handle vector separately, because an
//     unreadable file otherwise reports 0 and exits 0.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <iostream>
#include <map>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: dtpop <db.uhdm> [--ids]\n";
        return 3;
    }
    bool ids = (argc > 2 && std::string(argv[2]) == "--ids");
    Serializer s;
    auto handles = s.Restore(std::string(argv[1]));
    if (handles.empty()) {
        std::cerr << "UNMEASURED: Restore returned no handles for " << argv[1]
                  << "\n";
        return 4;
    }
    auto all = s.AllObjects();
    if (all.empty()) {
        std::cerr << "UNMEASURED: no objects\n";
        return 4;
    }
    size_t alias = 0, cts = 0, total = 0, idx = 0;
    for (auto& kv : all) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        ++total;
        if (o->UhdmType() == uhdmclass_typespec) ++cts;
        if (const typespec* t = dynamic_cast<const typespec*>(o))
            if (t->Typedef_alias()) ++alias;
        if (ids)
            printf("%zu\t%u\t%s\t%s\t%s:%u:%u\n", idx++, kv.second,
                   UhdmName(o->UhdmType()).c_str(),
                   std::string(o->VpiName()).c_str(),
                   std::string(o->VpiFile()).c_str(), o->VpiLineNo(),
                   o->VpiColumnNo());
    }
    fprintf(stderr, "ALIAS\t%zu\nCTS\t%zu\nTOTAL\t%zu\n", alias, cts, total);
    return 0;
}
