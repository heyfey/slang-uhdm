// r10uvm208 — THE OBJECT-SIDE ACCOUNTING INSTRUMENT.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// WHY IT EXISTS.  r10uvm205 recorded the instrument fact that `uhdm-dump` does
// NOT print `vpiTypedefAlias`, so the campaign's order-blind whole-dump
// attribution is BLIND to the alias re-points this family makes.  § 208 is the
// first law in the family that also MINTS OBJECTS — a fresh `array_typespec`
// and a fresh element `ref_typespec` per split clone declaration — and a minted
// object IS dump-visible.  So the pass has to account for BOTH halves, and this
// prints the half the census cannot see: the per-kind object population of a
// database.  Run it on the pristine and the patched database of the same row
// and diff: every kind whose count moved must be one the law mints.
//
// build: g++ -O2 -std=c++17 ct208obj.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct208obj
// usage: ct208obj <db.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct208obj <db.uhdm> <label>\n");
        return 2;
    }
    const char* label = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", label);
        return 3;
    }
    std::map<std::string, long> byKind;
    long total = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        byKind[std::string(UhdmName(o->UhdmType()))]++;
        ++total;
    }
    for (auto& [k, v] : byKind) printf("OBJ\t%s\t%s\t%ld\n", label, k.c_str(), v);
    printf("OBJTOTAL\t%s\t%ld\n", label, total);
    return 0;
}
