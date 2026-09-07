// r10earl120 — SITE INSPECTOR: every typespec whose parent chain matches a
// substring, with its `Instance` edge spelled by ROLE and its chain printed.
//
// MEASUREMENT ONLY.  Used to read BOTH sides of one reference site once
// own120 has named it.
//
// build: g++ -O2 -std=c++17 site120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o site120
// usage: site120 <db.uhdm> <tag> <chain-substring> [--max=N] [--kind=K]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[512];
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), base(o->VpiFile()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string chainStr(const BaseClass* o, int n = 14) {
    std::string s;
    for (int i = 0; i < n && o; i++) { s += (i ? " < " : "") + ident(o); o = o->VpiParent(); }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 4) { fprintf(stderr, "usage: site120 <db> <tag> <chain-substr> [--max=N] [--kind=K]\n"); return 2; }
    const std::string tag(argv[2]), want(argv[3]);
    size_t maxn = 20;
    std::string kwant;
    for (int i = 4; i < argc; i++) {
        if (!strncmp(argv[i], "--max=", 6)) maxn = atoi(argv[i] + 6);
        if (!strncmp(argv[i], "--kind=", 7)) kwant = argv[i] + 7;
    }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    std::map<const BaseClass*, std::string> role;
    if (d->AllPackages())
        for (size_t i = 0; i < d->AllPackages()->size(); i++)
            role[d->AllPackages()->at(i)] += "All[" + std::to_string(i) + "]";
    if (d->TopPackages())
        for (size_t i = 0; i < d->TopPackages()->size(); i++)
            role[d->TopPackages()->at(i)] += "Top[" + std::to_string(i) + "]";

    size_t n = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        const typespec* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        if (!kwant.empty() && kindOf(obj) != kwant) continue;
        const std::string c = chainStr(obj);
        if (c.find(want) == std::string::npos) continue;
        const instance* in = t->Instance();
        std::string pay = in ? kindOf(in) + ":" + std::string(in->VpiName()) + " " +
                                   (role.count(in) ? role[in] : std::string("(unlisted)"))
                             : std::string("<null>");
        printf("%s  Instance=%-28s  %s\n", tag.c_str(), pay.c_str(), c.c_str());
        if (++n >= maxn) break;
    }
    printf("%s  matched=%zu\n", tag.c_str(), n);
    return 0;
}
