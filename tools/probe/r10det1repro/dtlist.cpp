// r10det1repro/dtlist.cpp — print the ORDER of the DESIGN-LEVEL vectors of a
// restored database, as source identities (kind/name/line:col) plus the
// serializer id.  The pad experiment (dtperturb.sh) found ONE object moving
// position inside a design-level list; a dump diff cannot say WHICH list, so
// this reads the list itself.
//   usage: dtlist <db.uhdm>
// GUARD: a database that restores to no design is UNMEASURED, exit 4 — never 0
// entries read as "the list is empty".
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <iostream>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: dtlist <db.uhdm>\n"; return 3; }
    Serializer s;
    auto handles = s.Restore(std::string(argv[1]));
    if (handles.empty()) { std::cerr << "UNMEASURED: no handles\n"; return 4; }
    const design* d = nullptr;
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) { d = (const design*)kv.first; break; }
    if (!d) { std::cerr << "UNMEASURED: no design\n"; return 4; }
    size_t i = 0;
    if (auto* v = d->Typespecs())
        for (auto* t : *v)
            printf("TYPESPECS\t%zu\t%s\t%s\t%u:%u\n", i++,
                   UhdmName(t->UhdmType()).data(), std::string(t->VpiName()).c_str(),
                   t->VpiLineNo(), t->VpiColumnNo());
    if (i == 0) { std::cerr << "UNMEASURED: design has no Typespecs\n"; return 4; }
    fprintf(stderr, "TYPESPECS n=%zu\n", i);
    return 0;
}
