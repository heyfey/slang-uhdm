// r10earl112 -- THE WHOLE-DATABASE KIND CENSUS.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
//
// A companion to `attrib112.sh` for databases whose `uhdm-dump` is too large to
// diff in reasonable time (Earlgrey/testflags dumps to ~360 MB / 4.7M lines).
// It walks `Serializer::AllObjects` -- EVERY object in the database, not only
// the ones reachable from the design tree -- and prints one line per UHDM kind
// with its count, plus a second table keyed by kind AND the object's own
// `VpiName`, so a change in WHICH names exist is visible and not only HOW MANY
// objects do.  Diffing two of these attributes a byte mover across the WHOLE
// database at once.
//
// build:
//   g++ -O2 -std=c++17 kinds112.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o kinds112
// usage:
//   kinds112 <db.uhdm> [--names]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: kinds112 <db.uhdm> [--names]\n");
        printf("KINDRC 2\n");
        return 2;
    }
    bool names = argc > 2 && std::strcmp(argv[2], "--names") == 0;
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        printf("KINDRC 3\n");
        return 3;
    }
    std::map<std::string, long> byKind;
    std::map<std::string, long> byKindName;
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        std::string k(UhdmName(o->UhdmType()));
        byKind[k]++;
        if (names) byKindName[k + "\t" + std::string(o->VpiName())]++;
    }
    for (auto& kv : byKind) printf("KIND\t%s\t%ld\n", kv.first.c_str(), kv.second);
    for (auto& kv : byKindName) printf("NAME\t%s\t%ld\n", kv.first.c_str(), kv.second);
    printf("KINDRC 0\n");
    return 0;
}
