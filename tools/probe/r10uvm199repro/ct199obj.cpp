// r10uvm199 — WHOLE-DATABASE OBJECT-KIND COUNTER.  MEASUREMENT ONLY.
//
// The sorted-dump diff counts LINES, and one removed object prints several of
// them (its own header, plus a header line wherever it appears as somebody's
// `vpiParent`).  That makes a line count a bad attribution for a SUBTRACTIVE
// law.  This counts OBJECTS, by UHDM kind, over `Serializer::AllObjects` —
// so "what did this law destroy" is answered per kind, and each kind can be
// scored against GOLDEN's own count.
//
// build: g++ -O2 -std=c++17 ct199obj.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct199obj
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct199obj <db.uhdm> <tag>\n");
        return 2;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("OBJ-RESTORE_FAIL %s\n", argv[2]);
        return 3;
    }
    std::map<std::string, long> byKind;
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        ++n;
        ++byKind[std::string(UhdmName(o->UhdmType()))];
    }
    for (auto& [k, c] : byKind) printf("OBJ %s %s %ld\n", argv[2], k.c_str(), c);
    printf("OBJSUM %s total=%ld kinds=%zu\n", argv[2], n, byKind.size());
    return 0;
}
