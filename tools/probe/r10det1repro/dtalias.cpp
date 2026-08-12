// r10det1repro/dtalias.cpp — the ALIAS-CARRIER CENSUS BY SHAPE.
//
// The pass's convergence question is "are our 337 aliases the WRONG PICK out of
// golden's 1069, or a MISSING POPULATION?".  A single total cannot answer that;
// this counts carriers PER UHDM KIND, as OBJECTS (Serializer::AllObjects, not
// dump occurrences), so the two sides can be compared shape by shape.
//   usage: dtalias <db.uhdm>   -> "<kind>\t<carriers>\t<objects-of-that-kind>"
// GUARD: no objects is UNMEASURED, exit 4.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: dtalias <db.uhdm>\n"; return 3; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cerr << "UNMEASURED: no handles\n"; return 4; }
    auto all = s.AllObjects();
    if (all.empty()) { std::cerr << "UNMEASURED: no objects\n"; return 4; }
    std::map<std::string, std::pair<size_t, size_t>> byKind;
    for (auto& kv : all) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const typespec* t = dynamic_cast<const typespec*>(o);
        if (!t) continue;
        auto& e = byKind[std::string(UhdmName(o->UhdmType()))];
        ++e.second;
        if (t->Typedef_alias()) ++e.first;
    }
    for (auto& [k, e] : byKind)
        printf("%-28s %6zu %8zu\n", k.c_str(), e.first, e.second);
    return 0;
}
