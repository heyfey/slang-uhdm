// r10uvm211 — THE CLONE-BODY DECLARATION-CHAIN CENSUS, THROUGH THE ARRAY AND
// THE STRUCT MEMBER.  This file is r10uvm207repro/ct207cen.cpp UNCHANGED in
// behaviour (same walk, same producer-neutral keys, same payload, same
// --holders grouping); it is carried here so this pass's probe surface is
// self-contained, and because its `.elem.mem:<name>` chain path is EXACTLY the
// path this pass's head sits on:
//
//   DIFFER BY KIND x CHAIN x SHAPE, MiniAmiq/default at this pass's BASE:
//     bit_typespec chain=.elem.mem:addr    g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
//     bit_typespec chain=.elem.mem:byte_en g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
//     bit_typespec chain=.elem.mem:data    g=BARE/BARE/uvm_pkg o=BARE/QUAL/uvm_pkg  2
//   TOTAL agree=5743 differ=6 only-golden=1062 only-ours=472
//
// — six cells, two declarations (`uvm_reg_map::do_bus_read accesses@1993` and
// `do_bus_write accesses@1850`), three repairable members each, all in the
// ELABORATED clone listing.
//
// r10uvm207 — THE CLONE-BODY DECLARATION-CHAIN CENSUS, THROUGH THE **MEMBER**.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Direct descendant of r10uvm205's `ct205cen`, whose chain walk descends
// `array_typespec` / `packed_array_typespec` `Elem_typespec` and
// `Index_typespec` links only.  r10uvm205's R0 named the next SeqDriver head as
// "the CLASS MEMBER kind, a class typespec between the reference and the
// subroutine".  MEASURED (ct207own --chain=range --sub=m_set_mem_offset), the
// object between them is a **struct_typespec**, not a class typespec:
// `uvm_reg_map_addr_range` is a package-scope STRUCT typedef of uvm-1.2
// (`uvm_reg_map.svh:408-412`) and the head's link is its `typespec_member`
// `min`.  This census therefore adds TWO link kinds to the 205 walk:
//
//   .mem:<name>    struct_typespec  -> Members()[i]->Typespec()
//   .prop:<name>   class_typespec   -> Class_defn()->Variables()[i]->Typespec()
//                                     (only with --classprop; a class_defn is
//                                     one shared object reached from thousands
//                                     of declarations, so the cross product is
//                                     reported separately and never mixed into
//                                     the default census)
//
// Producer-neutral key, unchanged from 205 except for the richer chain:
//
//   <listing tag> <pkg> | <class> | <function> | d<block depth> | <role>
//     | <decl name>@<line>:<col> | <chain path>
//
// No id, no vpiFullName, no vector index, no span in the payload.
//
// PAYLOAD — the two names `typespec::Compare` reads first, plus the KIND and
// the vpiInstance package NAME (`typespec::Compare` walks Typedef_alias, then
// Instance):
//
//   <kind>[<VpiName> -> <Typedef_alias target VpiName>] inst=<package name>
//
// SHAPE columns: BARE (no `::`) / QUAL (has one) / NOALIAS.
//
// --holders  THE SHARING, BY WHOLE-DATABASE IDENTITY.  For every cell, the
//            HOLDER object the chain passed through last (the struct_typespec
//            or array_typespec that owns the ref) is grouped by identity and
//            the DECLARATIONS that reach it are listed.  A holder reached from
//            both a clone listing and a home listing CANNOT be re-pointed —
//            it must be SPLIT — and this is the column that decides which.
//
// build: g++ -O2 -std=c++17 ct211cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct211cen
// usage: ct211cen <golden.uhdm> <ours.uhdm> [--pkg=SUB] [--name=SUB]
//                 [--kinds] [--all] [--share] [--raw] [--arena] [--holders]
//                 [--classprop]
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
static const char* shapeOf(const std::string& n) {
    if (n.empty()) return "NONAME";
    return n.find("::") == std::string::npos ? "BARE" : "QUAL";
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
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}

struct Cell {
    std::string kind, ts, alias, inst, ainst, aliasKind, chain;
    const void* refId = nullptr;   // producer-private; NEVER keyed on, only
    const void* tsId = nullptr;    // used by --share to detect object sharing
    const void* holderId = nullptr;  // the struct/array typespec the ref hangs
                                     // off — --holders groups on it
    std::string holderKind, holderName;
};
static bool g_classprop = false;

// walk the typespec chain below a declaration, emitting one cell per
// scalar-typedef typespec reached.
static void walkChain(const ref_typespec* rt, const std::string& path,
                      int budget, const char* nameFilt,
                      const std::string& keyBase,
                      std::map<std::string, Cell>& out,
                      const std::string& chain = std::string(),
                      const typespec* holder = nullptr) {
    if (!rt || budget <= 0) return;
    char cb[64];
    snprintf(cb, sizeof cb, "%s>ref:%p", chain.c_str(), (const void*)rt);
    std::string ch(cb);
    const typespec* at = rt->Actual_typespec();
    if (!at) return;
    if (scalarTdKind(at->UhdmType())) {
        std::string nm(at->VpiName());
        if (nameFilt && nm.find(nameFilt) == std::string::npos) return;
        Cell c;
        c.kind = std::string(UhdmName(at->UhdmType()));
        c.ts = nm;
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        c.alias = tg ? std::string(tg->VpiName()) : std::string("-");
        const any* in = at->Instance();
        c.inst = in ? std::string(in->VpiName()) : std::string("-");
        const any* ain = tg ? tg->Instance() : nullptr;
        c.ainst = ain ? std::string(ain->VpiName()) : std::string("-");
        c.aliasKind = tg ? std::string(UhdmName(tg->UhdmType())) : std::string("-");
        c.refId = (const void*)rt;
        c.tsId = (const void*)at;
        c.holderId = (const void*)holder;
        c.holderKind = holder ? std::string(UhdmName(holder->UhdmType())) : "-";
        c.holderName = holder ? std::string(holder->VpiName()) : "-";
        snprintf(cb, sizeof cb, ">ts:%p", (const void*)at);
        c.chain = ch + cb;
        if (tg) {
            snprintf(cb, sizeof cb, ">al:%p>tgt:%p", (const void*)al,
                     (const void*)tg);
            c.chain += cb;
        }
        out.emplace(keyBase + " | " + (path.empty() ? "." : path), c);
        return;
    }
    if (at->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)at;
        snprintf(cb, sizeof cb, ">arr:%p", (const void*)at);
        walkChain(a->Elem_typespec(), path + ".elem", budget - 1, nameFilt,
                  keyBase, out, ch + cb, at);
        walkChain(a->Index_typespec(), path + ".index", budget - 1, nameFilt,
                  keyBase, out, ch + cb, at);
        return;
    }
    if (at->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)at;
        snprintf(cb, sizeof cb, ">parr:%p", (const void*)at);
        walkChain(a->Elem_typespec(), path + ".elem", budget - 1, nameFilt,
                  keyBase, out, ch + cb, at);
        return;
    }
    // THE 207 LINK: a STRUCT member.  `uvm_reg_map_addr_range` is a package
    // struct typedef and the corpus head is its `min` member, one link below a
    // clone body's local declaration.
    if (at->UhdmType() == uhdmstruct_typespec) {
        auto* st = (const struct_typespec*)at;
        snprintf(cb, sizeof cb, ">struct:%p", (const void*)at);
        std::string ch2 = ch + cb;
        if (auto* ms = st->Members())
            for (auto* m : *ms)
                walkChain(m->Typespec(),
                          path + ".mem:" + std::string(m->VpiName()),
                          budget - 1, nameFilt, keyBase, out, ch2, at);
        return;
    }
    // THE OTHER 207 LINK, opt-in only: a CLASS property.  A `class_defn` is one
    // shared object reached from every declaration of that class type, so this
    // is a cross product and is never mixed into the default census.
    if (g_classprop && at->UhdmType() == uhdmclass_typespec) {
        auto* ct = (const class_typespec*)at;
        const class_defn* cd = ct->Class_defn();
        if (!cd || !cd->Variables()) return;
        snprintf(cb, sizeof cb, ">class:%p", (const void*)at);
        std::string ch2 = ch + cb;
        for (auto* v : *cd->Variables())
            walkChain(v->Typespec(),
                      path + ".prop:" + std::string(v->VpiName()), budget - 1,
                      nameFilt, keyBase, out, ch2, at);
        return;
    }
}

static void collect(Serializer& S, const design* d, const char* pkgFilt,
                    const char* nameFilt, std::map<std::string, Cell>& out) {
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
        // a function's RETURN variable is the subroutine's own child and has
        // the subroutine's name; mark it so the § 16 return-variable exception
        // is a column of the census rather than a footnote.
        const char* r2 = role;
        if (sub->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)sub)->Return() == o)
            r2 = "ret";
        char e[512];
        snprintf(e, sizeof e, "%s | %s | %s | d%d | %s | %s@%u:%u",
                 tag.c_str(), nameOf(classOf(o)).c_str(), nameOf(sub).c_str(),
                 depth, r2, nameOf(o).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo());
        walkChain(rt, "", 8, nameFilt, std::string(e), out);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct205cen <golden> <ours> [--pkg=S] [--name=S] "
                "[--kinds] [--all] [--onlydiff]\n");
        return 2;
    }
    const char *pf = nullptr, *nf = nullptr;
    bool kinds = false, all = false, share = false, raw = false, arena = false,
         holders = false, decide = false;
    std::set<std::string> diffKeys;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--pkg=", 6)) pf = argv[i] + 6;
        else if (!strncmp(argv[i], "--name=", 7)) nf = argv[i] + 7;
        else if (!strcmp(argv[i], "--kinds")) kinds = true;
        else if (!strcmp(argv[i], "--all")) all = true;
        else if (!strcmp(argv[i], "--share")) share = true;
        else if (!strcmp(argv[i], "--raw")) raw = true;
        else if (!strcmp(argv[i], "--arena")) arena = true;
        else if (!strcmp(argv[i], "--holders")) holders = true;
        else if (!strcmp(argv[i], "--classprop")) g_classprop = true;
        else if (!strcmp(argv[i], "--decide")) decide = true;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    if (arena) {
        // THE ORDER-BLIND, ALIAS-VISIBLE WHOLE-ARENA MULTISET.  `uhdm-dump`
        // does not print `vpiTypedefAlias`, so the campaign's usual
        // sorted-dump attribution is BLIND to every law in this family: on arm
        // E it reads 0 content lines across a change uhdm-cmp scores from 112
        // lines to 1192.  This prints one line per `ref_typespec` in the arena
        // — the bound typespec's KIND, `VpiName`, its `Typedef_alias` target's
        // `VpiName` and its `Instance` name — with no id and no address, so
        // `sort | diff` between two databases of the SAME source names every
        // cell a re-point moved and nothing else.
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || o->UhdmType() != uhdmref_typespec) continue;
                auto* rt = (const ref_typespec*)o;
                const typespec* at = rt->Actual_typespec();
                if (!at) { printf("ARENA\t%s\t<null>\t-\t-\t-\n",
                                  side ? "OURS" : "GOLD"); continue; }
                const ref_typespec* al = at->Typedef_alias();
                const typespec* tg = al ? al->Actual_typespec() : nullptr;
                const any* in = at->Instance();
                printf("ARENA\t%s\t%s\t%s\t%s\t%s\n", side ? "OURS" : "GOLD",
                       UhdmName(at->UhdmType()).data(),
                       std::string(at->VpiName()).c_str(),
                       tg ? std::string(tg->VpiName()).c_str() : "-",
                       in ? std::string(in->VpiName()).c_str() : "-");
            }
        }
    }
    std::map<std::string, Cell> G, O;
    collect(sg, dg, pf, nf, G);
    collect(so, dou, pf, nf, O);
    if (raw) {
        // one line per cell per side, with the producer-private object
        // pointers exposed for OFF-LINE sharing analysis only.  Never a key.
        for (int side = 0; side < 2; ++side) {
            auto& M = side ? O : G;
            for (auto& [k, c] : M)
                printf("RAW\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%p\t%p\t%s\n",
                       side ? "OURS" : "GOLD", k.c_str(), c.kind.c_str(),
                       c.ts.c_str(), c.alias.c_str(), c.inst.c_str(),
                       c.ainst.c_str(), c.refId, c.tsId, c.chain.c_str());
        }
    }
    if (share) {
        // OBJECT SHARING between listings.  A `ref_typespec` (or the typespec
        // it binds) reached from BOTH a home-package listing and a clone
        // listing cannot be given two different names, so a law that bares the
        // clone's would move the home's too.  Producer-private pointers are
        // used HERE ONLY, never as a key.
        for (int side = 0; side < 2; ++side) {
            auto& M = side ? O : G;
            std::map<const void*, std::set<std::string>> byRef, byTs;
            for (auto& [k, c] : M) {
                std::string pk = k.substr(0, k.find(" | "));
                byRef[c.refId].insert(pk);
                byTs[c.tsId].insert(pk);
            }
            long shRef = 0, shTs = 0;
            for (auto& [i, s2] : byRef) if (s2.size() > 1) ++shRef;
            for (auto& [i, s2] : byTs) if (s2.size() > 1) ++shTs;
            printf("SHARE[%s] ref_typespecs reached from >1 listing: %ld / %zu ;"
                   " bound typespecs: %ld / %zu\n", side ? "OURS" : "GOLD",
                   shRef, byRef.size(), shTs, byTs.size());
            for (auto& [i, s2] : byTs) {
                if (s2.size() < 2) continue;
                std::string j;
                for (auto& x : s2) j += (j.empty() ? "" : " + ") + x;
                printf("  SHARED-TS %s\n", j.c_str());
            }
        }
    }
    if (holders) {
        // THE SHARING THAT DECIDES RE-POINT vs SPLIT.  Group every cell by the
        // identity of the HOLDER typespec its ref hangs off, and list the
        // declarations that reach it.  Producer-private addresses are used to
        // group WITHIN one database only; they are never printed and never a
        // key across databases.
        for (int side = 0; side < 2; ++side) {
            auto& M = side ? O : G;
            const char* tag = side ? "OURS" : "GOLD";
            std::map<const void*, std::set<std::string>> byHolder;
            std::map<const void*, std::string> face;
            for (auto& [k, c] : M) {
                if (!c.holderId) continue;
                byHolder[c.holderId].insert(k.substr(0, k.rfind(" | ")));
                face[c.holderId] = c.holderKind + " " + c.holderName;
            }
            long shared = 0;
            std::map<long, long> hist;
            for (auto& [h, u] : byHolder) {
                hist[(long)u.size()]++;
                if (u.size() > 1) ++shared;
            }
            printf("HOLDERS[%s] holder objects=%zu shared(>1 declaration)=%ld\n",
                   tag, byHolder.size(), shared);
            for (auto& [n, c] : hist)
                printf("HOLDERS[%s]   holders reached from %ld declaration(s): %ld\n",
                       tag, n, c);
            for (auto& [h, u] : byHolder) {
                if (u.size() < 2) continue;
                // the PACKAGE half of each declaration key decides whether a
                // holder is clone-only, home-only or MIXED.
                std::set<std::string> pkgs;
                for (auto& x : u) {
                    auto sp = x.find(' ');
                    auto bar = x.find(" | ");
                    if (sp != std::string::npos && bar != std::string::npos)
                        pkgs.insert(x.substr(sp + 1, bar - sp - 1));
                }
                std::string pj;
                for (auto& p : pkgs) pj += (pj.empty() ? "" : "+") + p;
                printf("HOLDERS[%s] %-40s n=%zu pkgs=%s\n", tag,
                       face[h].c_str(), u.size(), pj.c_str());
                for (auto& x : u)
                    printf("HOLDERS[%s]     %s\n", tag, x.c_str());
            }
        }
    }
    std::set<std::string> keys;
    for (auto& [k, v] : G) keys.insert(k);
    for (auto& [k, v] : O) keys.insert(k);
    size_t agree = 0, differ = 0, og = 0, oo = 0;
    std::map<std::string, long> shapeTab, kindTab;
    for (auto& k : keys) {
        auto gi = G.find(k), oi = O.find(k);
        if (gi == G.end()) {
            if (all) printf("ONLY-OURS   %s   ours=%s[%s -> %s] inst=%s\n",
                k.c_str(), oi->second.kind.c_str(), oi->second.ts.c_str(),
                oi->second.alias.c_str(), oi->second.inst.c_str());
            ++oo; continue;
        }
        if (oi == O.end()) {
            if (all) printf("ONLY-GOLDEN %s   gold=%s[%s -> %s] inst=%s\n",
                k.c_str(), gi->second.kind.c_str(), gi->second.ts.c_str(),
                gi->second.alias.c_str(), gi->second.inst.c_str());
            ++og; continue;
        }
        char sk[256];
        snprintf(sk, sizeof sk,
                 "%s chain=%s g=%s/%s/%s o=%s/%s/%s",
                 gi->second.kind.c_str(),
                 k.substr(k.rfind(" | ") + 3).c_str(),
                 shapeOf(gi->second.ts),
                 gi->second.alias == "-" ? "NOALIAS" : shapeOf(gi->second.alias),
                 gi->second.inst.c_str(), shapeOf(oi->second.ts),
                 oi->second.alias == "-" ? "NOALIAS" : shapeOf(oi->second.alias),
                 oi->second.inst.c_str());
        if (kinds) kindTab[sk]++;
        bool same = gi->second.ts == oi->second.ts &&
                    gi->second.alias == oi->second.alias &&
                    gi->second.kind == oi->second.kind;
        if (same) {
            ++agree;
            if (all) printf("AGREE       %s   %s[%s -> %s] inst g=%s o=%s\n",
                k.c_str(), gi->second.kind.c_str(), gi->second.ts.c_str(),
                gi->second.alias.c_str(), gi->second.inst.c_str(),
                oi->second.inst.c_str());
            continue;
        }
        ++differ;
        diffKeys.insert(k);
        printf("DIFFER      %s   gold=%s[%s -> %s]inst=%s  ours=%s[%s -> %s]inst=%s\n",
               k.c_str(), gi->second.kind.c_str(), gi->second.ts.c_str(),
               gi->second.alias.c_str(), gi->second.inst.c_str(),
               oi->second.kind.c_str(), oi->second.ts.c_str(),
               oi->second.alias.c_str(), oi->second.inst.c_str());
        shapeTab[sk]++;
    }
    if (decide) {
        // THE DECISION TABLE: for every DIFFERING cell, the HOLDER object in
        // OUR database that owns its ref, every declaration that reaches that
        // holder, and — for each of those declarations — whether its own cell
        // AGREES with golden today.  A holder with even one AGREEING reach is
        // one a re-point would move AWAY: it needs a SPLIT, not a re-point.
        std::map<const void*, std::set<std::string>> byHolder;  // holder->keys
        std::map<const void*, std::string> face;
        for (auto& [k, c] : O) {
            if (!c.holderId) continue;
            byHolder[c.holderId].insert(k);
            face[c.holderId] = c.holderKind + " " + c.holderName;
        }
        std::set<const void*> hot;
        for (auto& k : diffKeys) {
            auto oi = O.find(k);
            if (oi != O.end() && oi->second.holderId) hot.insert(oi->second.holderId);
        }
        long pure = 0, mixed = 0;
        for (auto* h : hot) {
            long nd = 0, na = 0, nog = 0;
            std::set<std::string> pkgs;
            for (auto& k : byHolder[h]) {
                auto sp = k.find(' ');
                auto bar = k.find(" | ");
                if (sp != std::string::npos && bar != std::string::npos)
                    pkgs.insert(k.substr(sp + 1, bar - sp - 1));
                if (diffKeys.count(k)) ++nd;
                else if (G.count(k)) ++na;
                else ++nog;
            }
            std::string pj;
            for (auto& p : pkgs) pj += (pj.empty() ? "" : "+") + p;
            const bool isMixed = (na > 0);
            if (isMixed) ++mixed; else ++pure;
            printf("DECIDE %-8s holder=%-42s cells: differ=%ld agree=%ld only-ours=%ld  pkgs=%s\n",
                   isMixed ? "MIXED" : "PURE", face[h].c_str(), nd, na, nog,
                   pj.c_str());
            for (auto& k : byHolder[h])
                printf("DECIDE     %-6s %s\n",
                       diffKeys.count(k) ? "DIFFER"
                                         : (G.count(k) ? "AGREE" : "ONLYOURS"),
                       k.c_str());
        }
        printf("DECIDE SUMMARY hot-holders=%zu PURE(all reaches differ)=%ld "
               "MIXED(some reach agrees)=%ld\n", hot.size(), pure, mixed);
    }
    if (kinds) {
        printf("\nALL CELLS BY KIND x CHAIN x SHAPE:\n");
        for (auto& [k, v] : kindTab) printf("  %-118s %6ld\n", k.c_str(), v);
    }
    printf("\nDIFFER BY KIND x CHAIN x SHAPE:\n");
    for (auto& [k, v] : shapeTab) printf("  %-118s %6ld\n", k.c_str(), v);
    printf("\nTOTAL agree=%zu differ=%zu only-golden=%zu only-ours=%zu\n",
           agree, differ, og, oo);
    return 0;
}
