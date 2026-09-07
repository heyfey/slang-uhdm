// r10earl114 -- THE ARRAY_TYPESPEC POPULATION PROBE.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
//
// WHY IT EXISTS.  `kinds114` reported that the patched Earlgrey TESTFLAGS
// database holds 261 MORE `array_typespec` objects than the pristine one, while
// the DEFAULT database holds exactly as many as before -- and this law mints
// only `ref_typespec`, never a typespec.  An unexplained object-count change is
// exactly what a verifier convicts a pass on, so it is measured rather than
// argued: this tool prints, per `array_typespec`, its SPAN and its `Elem_typespec`
// edge plus how many `ref_typespec` objects point at it and what kinds own
// those, so the two databases' populations can be compared coordinate by
// coordinate.
//
// The expected shape, if the count change is REACHABILITY and not creation, is
// that every extra object shares a SPAN with one already present -- an arena
// copy that the pristine save had no reference to (r10earl112's R6 / r10earl113's
// R5 arena-count residue, which is 2x in testflags and 1x in default -- exactly
// the split that shows here).
//
// build:
//   g++ -O2 -std=c++17 ats114.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ats114
// usage:
//   ats114 <db.uhdm>          -- TSV: span \t name \t elem \t count \t refs \t owners
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}
static std::string base(std::string f) {
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    return f.empty() ? std::string("-") : f;
}
static std::string spanOf(const BaseClass* o) {
    char b[192];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(std::string(o->VpiFile())).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ats114 <db.uhdm>\n");
        printf("ATSRC 2\n");
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        printf("ATSRC 3\n");
        return 3;
    }
    // Every ref_typespec's target, so the referrer tally is exact.
    std::map<const typespec*, std::map<std::string, int>> refs;
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        if (o->UhdmType() != uhdmref_typespec) continue;
        auto* rt = (const ref_typespec*)o;
        if (auto* a = rt->Actual_typespec())
            refs[a][kindOf(rt->VpiParent())]++;
    }
    std::map<std::string, int> pop;
    std::map<std::string, std::map<std::string, int>> owners;
    seen.clear();
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        if (o->UhdmType() != uhdmarray_typespec) continue;
        auto* a = (const array_typespec*)o;
        std::string elem = "-";
        if (auto* er = a->Elem_typespec())
            elem = kindOf(er->Actual_typespec()) + "('" +
                   (er->Actual_typespec()
                        ? std::string(er->Actual_typespec()->VpiName())
                        : std::string()) + "')";
        std::string key = spanOf(a) + "\t'" + std::string(a->VpiName()) +
                          "'\t" + elem;
        pop[key]++;
        auto it = refs.find(a);
        if (it == refs.end())
            owners[key]["<unreferenced>"]++;
        else
            for (auto& kv : it->second) owners[key][kv.first] += kv.second;
    }
    for (auto& kv : pop) {
        std::string ow;
        for (auto& o : owners[kv.first])
            ow += (ow.empty() ? "" : ",") + o.first + "x" +
                  std::to_string(o.second);
        printf("%s\t%d\t%s\n", kv.first.c_str(), kv.second, ow.c_str());
    }
    printf("ATSRC 0\n");
    return 0;
}
