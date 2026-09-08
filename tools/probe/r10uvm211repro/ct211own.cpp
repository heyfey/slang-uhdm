// r10uvm211 — THE OWNER-FINDER AND THE ARITY PROFILE FOR THE
// ARRAY-OF-STRUCT HOLDER FACE.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE HEAD this pass re-measured on its own pristine build (MiniAmiq, BOTH
// modes, 112 cmp lines, ONE head each):
//
//   LHS bit_typespec (uvm_reg_addr_t)      inst uvm_pkg
//       |vpiParent ref_typespec
//       (svaunit_pkg::uvm_reg_map::do_bus_write::accesses::
//        uvm_pkg::uvm_reg_bus_op::addr::uvm_reg_addr_t)
//   RHS bit_typespec (uvm_pkg::uvm_reg_addr_t) inst svaunit_pkg
//
// i.e. the ALIAS TARGET of the `addr` member of `uvm_pkg::uvm_reg_bus_op`,
// reached from the wildcard-import clone body `svaunit_pkg`'s copy of
// `uvm_reg_map::do_bus_write` through its local `uvm_reg_bus_op accesses[$]`
// (uvm-1.2 `reg/uvm_reg_map.svh:1850`).  That is r10uvm207's own R1′ verbatim.
//
// THE QUESTION THIS TOOL ANSWERS, BEFORE ANY PLAN: § 207 re-points the ref
// that BINDS a repairable struct onto a clone copy, and REFUSED these two
// because the ARRAY that holds the struct is shared with a HOME declaration,
// so its `Elem_typespec` ref carries owner mask 3.  Whether the repair is a
// re-point or a SPLIT-MINT is decided by GOLDEN'S OWN ARITY on exactly those
// objects — how many DECLARATIONS reach each link of the chain, on each side.
//
//   --prof        for every link of every declaration chain: the object's
//                 kind/name and the NUMBER OF DECLARATIONS in the whole
//                 database that reach that exact object, on both sides.
//                 Producer-private addresses group objects WITHIN one
//                 database only; they are never printed and never keyed on.
//   --decl=SUB    restrict the printed chains to declarations whose key
//                 contains SUB (e.g. `--decl=accesses@1850`).
//   --face        the DECISION table: every declaration whose chain reaches a
//                 REPAIRABLE STRUCT (one carrying a member that still stands
//                 for a package scalar-typedef listing object) through an
//                 ARRAY link, with the arity of the array and of the struct,
//                 and whether that array is PURE (clone-only) or MIXED.
//   --who         for a --decl-named declaration, the LIST of declarations
//                 that reach each link of its chain, on both sides — the
//                 identity measurement the split/re-point decision rests on.
//
// build: g++ -O2 -std=c++17 ct211own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct211own
// usage: ct211own <golden.uhdm> <ours.uhdm> [--prof] [--face] [--decl=SUB]
//                 [--pkg=SUB]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
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
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}
// r10uvm207repro/ct207cen.cpp's listing tagger, verbatim: a package can be
// listed in AllPackages and in TopPackages, and the two listings are DIFFERENT
// objects with different chains, so the tag is part of every key.
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
static const BaseClass* subrOf(const BaseClass* o, int& depth) {
    depth = 0;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)
            return p;
        if (p->UhdmType() == uhdmbegin || p->UhdmType() == uhdmnamed_begin ||
            p->UhdmType() == uhdmfork_stmt || p->UhdmType() == uhdmnamed_fork ||
            p->UhdmType() == uhdmfor_stmt || p->UhdmType() == uhdmforeach_stmt)
            ++depth;
    }
    return nullptr;
}
static const BaseClass* classOf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmclass_defn) return p;
        if (p->UhdmType() == uhdmpackage) return nullptr;
    }
    return nullptr;
}

// one link of one declaration's chain
struct Link {
    std::string path;    // "", ".elem", ".elem.mem:addr", …
    std::string what;    // "ref" | kind name
    std::string name;    // VpiName of the object
    const void* id = nullptr;   // grouping ONLY, never printed
    std::string payload;        // for a scalar typedef: [name -> alias]
};

struct DB {
    std::map<std::string, std::vector<Link>> chains;  // decl key -> links
    std::map<const void*, std::set<std::string>> reach;  // object -> decls
};

static bool repairableStruct(const struct_typespec* st, int budget) {
    if (!st || budget <= 0 || !st->Members()) return false;
    for (auto* m : *st->Members()) {
        auto* mr = m->Typespec();
        auto* mt = mr ? mr->Actual_typespec() : nullptr;
        if (!mt) continue;
        if (scalarTdKind(mt->UhdmType())) {
            // "repairable" for THIS face means the member's typespec carries a
            // Typedef_alias whose TARGET name is QUALIFIED while the member's
            // own name is BARE — § 180's repair shape, which is what the judge
            // stops on.  A member with no alias, or an already-bare target, is
            // not part of this family.
            auto* al = mt->Typedef_alias();
            auto* tg = al ? al->Actual_typespec() : nullptr;
            if (tg && std::string(tg->VpiName()).find("::") != std::string::npos &&
                std::string(mt->VpiName()).find("::") == std::string::npos)
                return true;
        }
        if (mt->UhdmType() == uhdmstruct_typespec &&
            repairableStruct((const struct_typespec*)mt, budget - 1))
            return true;
    }
    return false;
}

static void walk(const ref_typespec* rt, const std::string& path, int budget,
                 const std::string& key, DB& db) {
    if (!rt || budget <= 0) return;
    Link lr;
    lr.path = path.empty() ? "." : path;
    lr.what = "ref_typespec";
    lr.name = nameOf(rt);
    lr.id = (const void*)rt;
    db.chains[key].push_back(lr);
    db.reach[(const void*)rt].insert(key);
    const typespec* at = rt->Actual_typespec();
    if (!at) return;
    Link lt;
    lt.path = path.empty() ? "." : path;
    lt.what = std::string(UhdmName(at->UhdmType()));
    lt.name = nameOf(at);
    lt.id = (const void*)at;
    if (scalarTdKind(at->UhdmType())) {
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        lt.payload = "[" + std::string(at->VpiName()) + " -> " +
                     (tg ? std::string(tg->VpiName()) : std::string("-")) + "]";
    }
    db.chains[key].push_back(lt);
    db.reach[(const void*)at].insert(key);
    if (at->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)at;
        walk(a->Elem_typespec(), path + ".elem", budget - 1, key, db);
        walk(a->Index_typespec(), path + ".index", budget - 1, key, db);
        return;
    }
    if (at->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)at;
        walk(a->Elem_typespec(), path + ".elem", budget - 1, key, db);
        return;
    }
    if (at->UhdmType() == uhdmstruct_typespec) {
        auto* st = (const struct_typespec*)at;
        if (auto* ms = st->Members())
            for (auto* m : *ms)
                walk(m->Typespec(), path + ".mem:" + std::string(m->VpiName()),
                     budget - 1, key, db);
        return;
    }
}

static void collect(Serializer& S, const design* d, const char* pkgFilt,
                    DB& db) {
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
        int depth = 0;
        const BaseClass* sub = subrOf(o, depth);
        if (!sub) continue;
        std::string tag = L.of(o);
        if (tag == "<no-pkg>") continue;
        if (pkgFilt && tag.find(pkgFilt) == std::string::npos) continue;
        const char* r2 = role;
        if (sub->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)sub)->Return() == o)
            r2 = "ret";
        char e[512];
        snprintf(e, sizeof e, "%s | %s | %s | d%d | %s | %s@%u:%u", tag.c_str(),
                 nameOf(classOf(o)).c_str(), nameOf(sub).c_str(), depth, r2,
                 nameOf(o).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo());
        walk(rt, "", 8, std::string(e), db);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct211own <golden> <ours> [--prof] [--face] [--who] "
                "[--decl=SUB] [--pkg=SUB]\n");
        return 2;
    }
    const char *declFilt = nullptr, *pkgFilt = nullptr;
    bool prof = false, face = false, who = false;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--decl=", 7)) declFilt = argv[i] + 7;
        else if (!strncmp(argv[i], "--pkg=", 6)) pkgFilt = argv[i] + 6;
        else if (!strcmp(argv[i], "--prof")) prof = true;
        else if (!strcmp(argv[i], "--face")) face = true;
        else if (!strcmp(argv[i], "--who")) who = true;
        else { fprintf(stderr, "unknown arg %s\n", argv[i]); return 2; }
    }
    Serializer sg, so;
    // uhdm-cmp EXITS 0 on a missing input; an instrument must not.
    for (int i = 1; i <= 2; i++) {
        FILE* f = fopen(argv[i], "rb");
        if (!f) { fprintf(stderr, "FATAL: cannot open %s\n", argv[i]); return 3; }
        fclose(f);
    }
    sg.Restore(std::string(argv[1]));
    so.Restore(std::string(argv[2]));
    const design* dg = topDesign(sg);
    const design* dobj = topDesign(so);
    if (!dg || !dobj) { fprintf(stderr, "FATAL: no design\n"); return 3; }
    DB G, O;
    collect(sg, dg, pkgFilt, G);
    collect(so, dobj, pkgFilt, O);

    if (prof) {
        for (int side = 0; side < 2; ++side) {
            DB& D = side ? O : G;
            const char* tag = side ? "OURS" : "GOLD";
            printf("PROF[%s] declarations=%zu objects=%zu\n", tag,
                   D.chains.size(), D.reach.size());
            for (auto& [k, links] : D.chains) {
                if (declFilt && k.find(declFilt) == std::string::npos) continue;
                printf("PROF[%s] %s\n", tag, k.c_str());
                for (auto& l : links)
                    printf("PROF[%s]     %-16s %-22s arity=%-3zu %s %s\n", tag,
                           l.path.c_str(), l.what.c_str(),
                           D.reach[l.id].size(), l.name.c_str(),
                           l.payload.c_str());
            }
        }
    }
    if (who) {
        // THE CO-OWNER LIST — the identity measurement the split/re-point
        // decision rests on: WHICH declarations reach each link of a named
        // declaration's chain.  A link co-owned by a HOME declaration cannot be
        // re-pointed at all; one co-owned only by CLONE declarations can.
        for (int side = 0; side < 2; ++side) {
            DB& D = side ? O : G;
            const char* tag = side ? "OURS" : "GOLD";
            for (auto& [k, links] : D.chains) {
                if (declFilt && k.find(declFilt) == std::string::npos) continue;
                printf("WHO[%s] %s\n", tag, k.c_str());
                for (auto& l : links) {
                    auto& u = D.reach[l.id];
                    printf("WHO[%s]   %-18s %-22s n=%zu %s\n", tag,
                           l.path.c_str(), l.what.c_str(), u.size(),
                           l.payload.c_str());
                    for (auto& x : u)
                        printf("WHO[%s]       <- %s\n", tag, x.c_str());
                }
            }
        }
    }
    if (face) {
        // Every declaration whose chain reaches a REPAIRABLE struct through an
        // ARRAY link: the decision table.  A PURE array can be re-pointed; a
        // MIXED one can only be SPLIT.
        for (int side = 0; side < 2; ++side) {
            DB& D = side ? O : G;
            const char* tag = side ? "OURS" : "GOLD";
            long pure = 0, mixed = 0;
            printf("FACE[%s] --------------------------------------------\n", tag);
            for (auto& [k, links] : D.chains) {
                if (declFilt && k.find(declFilt) == std::string::npos) continue;
                // find an ".elem" struct_typespec that is repairable
                for (size_t i = 0; i < links.size(); ++i) {
                    if (links[i].what != "struct_typespec") continue;
                    if (links[i].path.find(".elem") != 0) continue;
                    if (!repairableStruct(
                            (const struct_typespec*)links[i].id, 6))
                        continue;
                    // the array one link up is the declaration's own typespec
                    size_t arity_arr = 0, arity_elemref = 0;
                    for (auto& l : links)
                        if (l.path == "." && l.what == "array_typespec")
                            arity_arr = D.reach[l.id].size();
                    for (auto& l : links)
                        if (l.path == ".elem" && l.what == "ref_typespec")
                            arity_elemref = D.reach[l.id].size();
                    size_t arity_st = D.reach[links[i].id].size();
                    size_t arity_own = 0;
                    for (auto& l : links)
                        if (l.path == "." && l.what == "ref_typespec")
                            arity_own = D.reach[l.id].size();
                    bool isMixed = arity_arr > 1 || arity_elemref > 1;
                    if (isMixed) ++mixed; else ++pure;
                    printf("FACE[%s] %s\n", tag, k.c_str());
                    printf("FACE[%s]     ownref=%zu arr=%zu elemref=%zu "
                           "struct=%zu  %s  %s\n",
                           tag, arity_own, arity_arr, arity_elemref, arity_st,
                           isMixed ? "MIXED(split-only)" : "PURE(re-pointable)",
                           links[i].name.c_str());
                    break;
                }
            }
            printf("FACE[%s] SUMMARY pure=%ld mixed=%ld\n", tag, pure, mixed);
        }
    }
    return 0;
}
