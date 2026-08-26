// r10uvm159 — GENERIC OBJECT INSPECTOR.  MEASUREMENT ONLY (uhdm-cmp is the judge).
// Prints one object by UhdmId, or every object of a KIND, with:
//   span, VpiName/VpiDefName, VpiDecompile/VpiValue/VpiSize (when an expr),
//   its ref_typespec edge (name + ACTUAL kind/name/span/ID — the id is what
//   proves SHARING vs COPYING), its parent chain, and its holders.
//
// build: g++ -O2 -std=c++17 ct159obj.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct159obj
// usage: ct159obj <db.uhdm> [--id=N] [--kind=parameter] [--name=X] [--at=L:C]
//                 [--tsid=N]   (every object whose typespec ACTUAL has that id)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string nm(const BaseClass* o) {
    if (!o) return "-";
    std::string n(o->VpiName());
    return n.empty() ? std::string("-") : n;
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kindOf(o).c_str(), nm(o).c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
// Typespec edge, if the object has one (relation vpiTypespec == 5001-ish is
// kind-specific; GetByVpiType(vpiTypespec) is the closed dispatch).
static const ref_typespec* tsOf(const BaseClass* o) {
    auto [single, vt, vec] = o->GetByVpiType(vpiTypespec);
    if (single && single->UhdmType() == uhdmref_typespec) return (const ref_typespec*)single;
    return nullptr;
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct159obj <db.uhdm> [...]\n"); return 2; }
    unsigned wantId = 0, wantTsId = 0, atL = 0, atC = 0;
    std::string wantKind, wantName;
    for (int a = 2; a < argc; a++) {
        if (!strncmp(argv[a], "--id=", 5)) wantId = (unsigned)atoi(argv[a] + 5);
        else if (!strncmp(argv[a], "--tsid=", 7)) wantTsId = (unsigned)atoi(argv[a] + 7);
        else if (!strncmp(argv[a], "--kind=", 7)) wantKind = argv[a] + 7;
        else if (!strncmp(argv[a], "--name=", 7)) wantName = argv[a] + 7;
        else if (!strncmp(argv[a], "--at=", 5)) sscanf(argv[a] + 5, "%u:%u", &atL, &atC);
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    std::map<const BaseClass*, std::vector<std::pair<const BaseClass*, int>>> rev;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        for (int t = 1; t < 1100; ++t) {
            if (t == vpiParent) continue;
            auto [single, vt, vec] = obj->GetByVpiType(t);
            if (single) rev[single].push_back({obj, t});
            if (vec) for (auto* e : *vec) if (e) rev[e].push_back({obj, t});
        }
    }
    size_t n = 0;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        if (wantId && obj->UhdmId() != wantId) continue;
        if (!wantKind.empty() && kindOf(obj) != wantKind) continue;
        if (!wantName.empty() && std::string(obj->VpiName()) != wantName) continue;
        if (atL && (obj->VpiLineNo() != atL || (atC && obj->VpiColumnNo() != atC))) continue;
        const ref_typespec* rt = tsOf(obj);
        if (wantTsId) {
            if (!rt || !rt->Actual_typespec() || rt->Actual_typespec()->UhdmId() != wantTsId) continue;
        }
        n++;
        printf("OBJ %s defname=[%s]\n", ident(obj).c_str(), std::string(obj->VpiDefName()).c_str());
        if (const expr* e = any_cast<const expr*>(obj))
            printf("    expr dec=[%s] val=[%s] size=%d\n",
                   std::string(e->VpiDecompile()).c_str(),
                   std::string(e->VpiValue()).c_str(), e->VpiSize());
        if (rt)
            printf("    ts  ref=%s -> actual=%s\n", ident(rt).c_str(),
                   ident(rt->Actual_typespec()).c_str());
        else printf("    ts  <none>\n");
        printf("    par");
        int d = 0;
        for (const BaseClass* p = obj->VpiParent(); p && d < 8; p = p->VpiParent(), ++d)
            printf(" < %s", ident(p).c_str());
        printf("\n");
        auto it = rev.find(obj);
        if (it != rev.end())
            for (auto& [h, t] : it->second)
                printf("    held rel=%d by %s\n", t, ident(h).c_str());
    }
    printf("MATCHED %zu\n", n);
    return 0;
}
