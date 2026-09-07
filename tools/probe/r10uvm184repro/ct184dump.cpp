// r10uvm184 — one object's every edge, by id.  MEASUREMENT ONLY.
// build: g++ -O2 -std=c++17 ct184dump.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184dump
// usage: ct184dump <db.uhdm> <id> [<id> ...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <string>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct184dump <db> <id>...\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    for (int a = 2; a < argc; ++a) {
        const uint32_t want = (uint32_t)atoi(argv[a]);
        const BaseClass* o = nullptr;
        for (auto& kv : s.AllObjects())
            if (kv.first && kv.first->UhdmId() == want) { o = kv.first; break; }
        printf("== id %u : %s\n", want, ident(o).c_str());
        if (!o) continue;
        printf("   parent %s\n", ident(o->VpiParent()).c_str());
        for (int t = 1; t <= 2100; ++t) {
            auto tup = o->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            if (!one && !vec) continue;
            if (vec) {
                printf("   [%4d] vector n=%zu\n", t, vec->size());
                for (size_t i = 0; i < vec->size(); ++i)
                    printf("           [%zu] %s\n", i, ident(vec->at(i)).c_str());
            } else {
                printf("   [%4d] %s\n", t, ident(one).c_str());
            }
        }
    }
    return 0;
}
