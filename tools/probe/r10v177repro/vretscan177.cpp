// r10v177repro/vretscan177.cpp — the VERIFIER's minimal return-kind scanner.
// MEASUREMENT ONLY; the official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole judge.  LHS is ALWAYS golden.
//
// One line per `function` object in the database:
//     <return variable UhdmName>\t<function VpiFullName>\t<line:col>
// Objects are enumerated from `Serializer::AllObjects` and sorted, so the
// output is ORDER-BLIND: two databases whose object arenas are ordered
// differently produce identical text (RESUME §9's attribution rule).
//
// Deliberately tiny and independent of r10uvm177's `ct177cen` / `ct177pred`:
// it reads ONE field (the return variable's kind), which is the only field
// § ownNamedAliasRetIsRefVar177 can change.
//
// build: g++ -O2 -std=c++17 vretscan177.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vretscan177
// usage: vretscan177 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: vretscan177 <db.uhdm>\n");
        return 2;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL\n");
        return 3;
    }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmfunction)
            continue;
        const function* f = (const function*)o;
        const variables* r = f->Return();
        char buf[1024];
        snprintf(buf, sizeof(buf), "%s\t%s\t%d:%d",
                 r ? UhdmName(r->UhdmType()).c_str() : "<none>",
                 std::string(f->VpiFullName()).c_str(), (int)f->VpiLineNo(),
                 (int)f->VpiColumnNo());
        rows.push_back(buf);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows)
        printf("%s\n", r.c_str());
    return 0;
}
