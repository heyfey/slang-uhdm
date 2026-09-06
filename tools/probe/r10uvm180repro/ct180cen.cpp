// r10uvm180 — THE CLONE-BODY TYPESPEC-NAME CENSUS.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHAT IT COUNTS.  Every DECLARATION inside a package's subroutine bodies —
// io_decls and variables at ANY block depth — whose typespec is one of the
// scalar-typedef kinds, on both sides, keyed by a producer-independent key:
//
//     <listing tag> | <function> | <declaration name>@<line>:<col> | <kind>
//
// and for each key the two names the judge actually reads: the typespec's own
// `VpiName` and its `Typedef_alias` target's `VpiName` (`typespec::Compare`
// reads VpiName, then Typedef_alias, then Instance).  Never an id, never a
// vpiFullName, never a vector index.
//
// The listing tag is the design-vector membership of the declaration's
// outermost package ancestor plus the package NAME (r10uvm178's key), so the
// two views of a package and a wildcard-import clone are distinct rows.
//
// OUTPUT (one row per key present on either side):
//     STATUS  key  golden="name -> alias" ours="name -> alias"
// with STATUS in AGREE / TOGOLD-CANDIDATE (differs) / ONLY-GOLDEN / ONLY-OURS.
// A second pass over two runs (pristine vs patched) is scored by score180.py.
//
// build: g++ -O2 -std=c++17 ct180cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct180cen
// usage: ct180cen <golden.uhdm> <ours.uhdm> [<name filter substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec:
        case uhdmbit_typespec:
        case uhdmint_typespec:
        case uhdminteger_typespec:
        case uhdmbyte_typespec:
        case uhdmshort_int_typespec:
        case uhdmlong_int_typespec:
            return true;
        default:
            return false;
    }
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
struct Listings {
    std::map<const BaseClass*, std::string> pkgTag;
    void build(const design* d) {
        if (auto* v = d->AllPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) ? "+" : "") +
                    ("ALL[" + std::to_string(i) + "]");
        if (auto* v = d->TopPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) &&
                             !pkgTag[(const BaseClass*)v->at(i)].empty()
                         ? "+"
                         : "") +
                    ("TOP[" + std::to_string(i) + "]");
    }
    std::string of(const BaseClass* o) const {
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = o; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) pkg = p;
        if (!pkg) return "<no-pkg>";
        auto it = pkgTag.find(pkg);
        std::string tag = it == pkgTag.end() ? "UNLISTED" : it->second;
        return tag + " " + std::string(pkg->VpiName());
    }
};

// innermost enclosing subroutine, plus the BLOCK DEPTH between it and the
// declaration (0 = the subroutine's own listing, >0 = a nested begin/end).
static const BaseClass* subrOf(const BaseClass* o, int& depth) {
    depth = 0;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)
            return p;
        if (p->UhdmType() == uhdmbegin || p->UhdmType() == uhdmnamed_begin ||
            p->UhdmType() == uhdmfork_stmt || p->UhdmType() == uhdmnamed_fork)
            ++depth;
    }
    return nullptr;
}
static const BaseClass* classOf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmclass_defn) return p;
    return nullptr;
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("<null>");
}

struct Cell {
    std::string ts;     // the typespec's own VpiName
    std::string alias;  // its Typedef_alias target's VpiName ("-" when none)
    std::string kind;
};

static void collect(Serializer& S, const design* d, const char* filt,
                    std::map<std::string, Cell>& out) {
    Listings L;
    L.build(d);
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        const char* role = nullptr;
        if (auto* v = any_cast<const variables*>(o)) {
            rt = v->Typespec();
            role = "var";
        } else if (auto* io = any_cast<const io_decl*>(o)) {
            rt = io->Typespec();
            role = "io";
        }
        if (!rt || !role) continue;
        const typespec* at = rt->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) continue;
        if (filt && std::string(at->VpiName()).find(filt) == std::string::npos)
            continue;
        int depth = 0;
        const BaseClass* sub = subrOf(o, depth);
        if (!sub) continue;
        const BaseClass* cd = classOf(o);
        char key[900];
        snprintf(key, sizeof key, "%-28s | %-10s | cls=%-26s | fn=%-34s | d%d | %s@%u:%u",
                 L.of(o).c_str(), role, cd ? nameOf(cd).c_str() : "-",
                 nameOf(sub).c_str(), depth, nameOf(o).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo());
        Cell c;
        c.kind = UhdmName(at->UhdmType());
        c.ts = std::string(at->VpiName());
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        c.alias = tg ? std::string(tg->VpiName()) : std::string("-");
        out.emplace(key, c);  // first writer wins; duplicate keys are reported
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct180cen <golden> <ours> [namefilter]\n");
        return 2;
    }
    const char* filt = argc > 3 ? argv[3] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    std::map<std::string, Cell> G, O;
    collect(sg, dg, filt, G);
    collect(so, dou, filt, O);
    std::set<std::string> keys;
    for (auto& [k, v] : G) keys.insert(k);
    for (auto& [k, v] : O) keys.insert(k);
    size_t agree = 0, differ = 0, og = 0, oo = 0;
    for (auto& k : keys) {
        auto gi = G.find(k), oi = O.find(k);
        if (gi == G.end()) {
            printf("ONLY-OURS      %s   ours=%s[%s -> %s]\n", k.c_str(),
                   oi->second.kind.c_str(), oi->second.ts.c_str(),
                   oi->second.alias.c_str());
            ++oo;
            continue;
        }
        if (oi == O.end()) {
            printf("ONLY-GOLDEN    %s   gold=%s[%s -> %s]\n", k.c_str(),
                   gi->second.kind.c_str(), gi->second.ts.c_str(),
                   gi->second.alias.c_str());
            ++og;
            continue;
        }
        bool same = gi->second.ts == oi->second.ts &&
                    gi->second.alias == oi->second.alias &&
                    gi->second.kind == oi->second.kind;
        if (same) { ++agree; printf("AGREE          %s   %s[%s -> %s]\n", k.c_str(),
                    gi->second.kind.c_str(), gi->second.ts.c_str(),
                    gi->second.alias.c_str()); }
        else {
            ++differ;
            printf("DIFFER         %s   gold=%s[%s -> %s]  ours=%s[%s -> %s]\n",
                   k.c_str(), gi->second.kind.c_str(), gi->second.ts.c_str(),
                   gi->second.alias.c_str(), oi->second.kind.c_str(),
                   oi->second.ts.c_str(), oi->second.alias.c_str());
        }
    }
    printf("CENSUS agree=%zu differ=%zu only-golden=%zu only-ours=%zu total=%zu\n",
           agree, differ, og, oo, keys.size());
    return 0;
}
