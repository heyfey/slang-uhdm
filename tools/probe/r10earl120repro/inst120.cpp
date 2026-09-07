// r10earl120 — the OWNER-KIND census: every `typespec::Instance` edge in a
// database, keyed so the two producers can be joined.
//
// MEASUREMENT ONLY.  `uhdm-cmp` is the judge; nothing here scores acceptance.
//
// own120 named the owner kind: golden holds 174 `int_typespec::Instance ->
// package top_pkg` edges where we hold 24.  This tool prints every one of
// them with its parent chain (and, with --all, every typespec::Instance edge
// in the database keyed by home) so the two sides can be joined by NAME.
//
// KEY.  A typespec has no useful VpiName; our objects also carry an EMPTY
// VpiFile in places (RESUME.md section 9), so the key is
//     <typespec-kind> | <parent kind:name> | <grandparent kind:name> | line:col
// which is stable across the two producers.
//
// build: g++ -O2 -std=c++17 inst120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o inst120
// usage: inst120 <db.uhdm> <tag> [--pkg=NAME] [--all]
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
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("");
}
static std::string node(const BaseClass* o) {
    if (!o) return "<null>";
    return kindOf(o) + ":" + nm(o);
}
static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string key(const BaseClass* o) {
    char b[512];
    const BaseClass* p = o->VpiParent();
    const BaseClass* g = p ? p->VpiParent() : nullptr;
    snprintf(b, sizeof b, "%s|%s|%s|%s:%u:%u", kindOf(o).c_str(),
             node(p).c_str(), node(g).c_str(), base(o->VpiFile()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: inst120 <db.uhdm> <tag> [--pkg=NAME] [--all]\n");
        return 2;
    }
    std::string want;
    bool all = false;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--pkg=", 6)) want = argv[i] + 6;
        if (!strcmp(argv[i], "--all")) all = true;
    }
    const std::string tag(argv[2]);
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }

    std::map<std::string, size_t> byInstKind;   // owner-kind x instance-kind
    size_t tsTotal = 0, tsWithInst = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        const typespec* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        tsTotal++;
        const instance* i = t->Instance();
        if (i) tsWithInst++;
        if (!want.empty()) {
            if (!i || nm(i) != want) continue;
            printf("%s EDGE %s\n", tag.c_str(), key(obj).c_str());
            continue;
        }
        byInstKind[kindOf(obj) + " -> " + (i ? kindOf(i) + ":" + nm(i)
                                             : std::string("<null>"))]++;
        if (all && i)
            printf("%s ALL %s -> %s:%s\n", tag.c_str(), key(obj).c_str(),
                   kindOf(i).c_str(), nm(i).c_str());
    }
    if (want.empty()) {
        printf("%s TYPESPECS total=%zu withInstance=%zu\n", tag.c_str(), tsTotal, tsWithInst);
        for (const auto& [k, n] : byInstKind)
            printf("%s KIND %-56s %7zu\n", tag.c_str(), k.c_str(), n);
    }
    return 0;
}
