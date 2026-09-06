// r10earl110 -- the hier_path NAME census.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The head this pass owns is `hier_path::VpiName` -- the LAST field
// `hier_path::Compare` reads (Path_elems, then Root_value, then VpiName).
// So the census key must be everything the judge reads BEFORE the name, plus
// a position, and the VALUE must be the name itself:
//
//   key   = <span> | <ordered element KIND:NAME vector>
//   value = the hier_path's VpiName
//
// The span is in the key and NOT in the value because the judge never reads a
// span: it is here only to JOIN the two sides, exactly as r10uvm175's
// cells175.py keys on (line:col, path name).  Our hier_paths carry an EMPTY
// VpiFile (RESUME.md section 9), so the file is deliberately NOT in the key --
// the join is a MULTISET join and collisions are reported, never silently
// resolved by a last-writer dict.
//
// build:
//   g++ -O2 -std=c++17 cen110.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen110
// usage:
//   cen110 <db.uhdm>                 -- one TSV row per hier_path: key \t name
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: cen110 <db.uhdm> [tag]\n"); printf("CENRC 2\n"); return 2; }
    const char* tag = argc > 2 ? argv[2] : "";
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: load failed\n"); printf("CENRC 3\n"); return 3; }
    // Serializer::AllObjects() enumerates every object in the arena, so the
    // census is not limited to what a walk from the design root reaches --
    // and it is DEDUPED by object identity, never by slot (RESUME.md's
    // "slot-keyed censuses are BLIND below the slot").
    std::set<const hier_path*> seen;
    std::map<std::string, std::map<std::string, int>> rows;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)o;
        if (!seen.insert(hp).second) continue;
        char sp[64];
        snprintf(sp, sizeof sp, "%u:%u-%u:%u", hp->VpiLineNo(),
                 (unsigned)hp->VpiColumnNo(), hp->VpiEndLineNo(),
                 (unsigned)hp->VpiEndColumnNo());
        std::string key = sp;
        key += "|";
        if (hp->Path_elems())
            for (auto* e : *hp->Path_elems())
                key += kindOf(e) + ":" + std::string(e->VpiName()) + ",";
        rows[key][std::string(hp->VpiName())]++;
    }
    for (auto& kv : rows)
        for (auto& nv : kv.second)
            printf("%s%s%s\t%s\t%d\n", tag, *tag ? "|" : "", kv.first.c_str(),
                   nv.first.c_str(), nv.second);
    printf("CENRC 0\n");
    return 0;
}
