// r10uvm208 — THE CLONE-BODY DECLARATION-CHAIN TYPESPEC-NAME CENSUS,
// PLUS THE OBJECT-IDENTITY (SHARING/ARITY) PROFILE the split-mint needs.
//
// This file is r10uvm205repro/ct205cen.cpp with ONE addition, `--prof`
// (§ IDENT below): for every declaration cell it reports HOW MANY DISTINCT
// DECLARATIONS reach each object on the chain — the declaration's own
// `ref_typespec`, the `array_typespec` it binds, the element `ref_typespec`
// and the element `typespec` — on BOTH sides.  GOLDEN'S ARITY IS THE SPEC:
// § 205 refused six clone `.elem` refs because our emitter hands ONE element
// ref to a clone declaration and to a home declaration, and a ref cannot carry
// two names.  Whether the repair is a re-point or a SPLIT-MINT is decided by
// what golden's own arity is on exactly those cells, which is what `--prof`
// reads.  Producer-private pointers are used ONLY to compute the counts and
// the co-owner sets; they are NEVER printed and NEVER keyed on.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY NOT r10uvm180's ct180cen / ct180ref.  `ct180cen` keys every io_decl and
// variable whose typespec IS a scalar-typedef kind; a declaration whose
// typespec is an ARRAY of one (`uvm_reg_addr_t addr[];`) fails that test at
// the first step and is invisible to it.  `ct180ref` walks refs top-down with
// `UhdmListener` and REFUSES any path through a `class_defn` or through
// another `typespec` — the same two steps § importCloneBareTdAlias16's own
// listener refuses — so a census built on it shares the law's blind spot.
// (It also cannot key the class world at all: the listener's `visited` set
// makes the callstack whichever path happened to reach the object first, and
// on SeqDriver that is a 90-step walk through 40 unrelated classes.)
//
// WHAT THIS COUNTS.  Every DECLARATION (io_decl, variable, function return
// variable) inside a package's subroutine bodies, at any block depth, in a
// class method or a free subroutine alike, and then the WHOLE TYPESPEC CHAIN
// below it — descending `array_typespec` / `packed_array_typespec`
// `Elem_typespec` and `Index_typespec` links — recording every scalar-typedef
// typespec the chain reaches.  Producer-neutral key:
//
//   <listing tag> <pkg> | <class> | <function> | d<block depth> | <role>
//     | <decl name>@<line>:<col> | <chain path>
//
// where <chain path> is the sequence of links walked from the declaration
// ("" for the declaration's own typespec, ".elem", ".elem.elem", ".index"…).
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
// build: g++ -O2 -std=c++17 ct208cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct208cen
// usage: ct208cen <golden.uhdm> <ours.uhdm> [--pkg=SUB] [--name=SUB]
//                 [--kinds] [--all] [--share] [--raw] [--arena] [--prof]
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
    // § IDENT — the four chain objects the split-mint has to reason about.
    // Producer-private; used ONLY to COUNT owners in --prof, never printed.
    const void* outerRefId = nullptr;  // the declaration's own ref_typespec
    const void* arrTsId = nullptr;     // the (packed_)array_typespec it binds
    const void* elemRefId = nullptr;   // the element ref_typespec (== refId
                                       // when the cell is at .elem)
};

// walk the typespec chain below a declaration, emitting one cell per
// scalar-typedef typespec reached.
static void walkChain(const ref_typespec* rt, const std::string& path,
                      int budget, const char* nameFilt,
                      const std::string& keyBase,
                      std::map<std::string, Cell>& out,
                      const std::string& chain = std::string(),
                      const void* outerRef = nullptr,
                      const void* arrTs = nullptr) {
    if (!rt || budget <= 0) return;
    if (!outerRef) outerRef = (const void*)rt;
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
        c.outerRefId = outerRef;
        c.arrTsId = arrTs;
        c.elemRefId = arrTs ? (const void*)rt : nullptr;
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
                  keyBase, out, ch + cb, outerRef, (const void*)at);
        walkChain(a->Index_typespec(), path + ".index", budget - 1, nameFilt,
                  keyBase, out, ch + cb, outerRef, (const void*)at);
        return;
    }
    if (at->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)at;
        snprintf(cb, sizeof cb, ">parr:%p", (const void*)at);
        walkChain(a->Elem_typespec(), path + ".elem", budget - 1, nameFilt,
                  keyBase, out, ch + cb, outerRef, (const void*)at);
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
    bool kinds = false, all = false, share = false, raw = false, arena = false;
    bool prof = false;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--pkg=", 6)) pf = argv[i] + 6;
        else if (!strncmp(argv[i], "--name=", 7)) nf = argv[i] + 7;
        else if (!strcmp(argv[i], "--kinds")) kinds = true;
        else if (!strcmp(argv[i], "--all")) all = true;
        else if (!strcmp(argv[i], "--share")) share = true;
        else if (!strcmp(argv[i], "--raw")) raw = true;
        else if (!strcmp(argv[i], "--arena")) arena = true;
        else if (!strcmp(argv[i], "--prof")) prof = true;
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
    if (prof) {
        // § IDENT — THE OBJECT-IDENTITY (ARITY / SHARING) PROFILE.
        //
        // For every cell, how many DISTINCT DECLARATIONS reach each of the four
        // chain objects.  A count of 1 everywhere is "one chain per
        // declaration" — golden's shape, if golden has it.  A count > 1 on the
        // element ref is the sharing § 205 refused: one ref, two owners, and a
        // ref cannot carry two names.  The `own=` column names the declaration
        // KEYS that share the object (producer-neutral text), so a shared cell
        // can be read off by name.  NO POINTER IS EVER PRINTED.
        for (int side = 0; side < 2; ++side) {
            auto& M = side ? O : G;
            const char* sn = side ? "OURS" : "GOLD";
            std::map<const void*, std::set<std::string>> ownOuter, ownArr,
                ownElemRef, ownElemTs;
            for (auto& [k, c] : M) {
                std::string decl = k.substr(0, k.rfind(" | "));
                if (c.outerRefId) ownOuter[c.outerRefId].insert(decl);
                if (c.arrTsId) ownArr[c.arrTsId].insert(decl);
                if (c.elemRefId) ownElemRef[c.elemRefId].insert(decl);
                if (c.arrTsId && c.tsId) ownElemTs[c.tsId].insert(decl);
            }
            long nCells = 0, shOuter = 0, shArr = 0, shElemRef = 0;
            for (auto& [k, c] : M) {
                if (!c.arrTsId) continue;         // .elem cells only
                ++nCells;
                size_t no = ownOuter.count(c.outerRefId)
                                ? ownOuter[c.outerRefId].size() : 0;
                size_t na = ownArr[c.arrTsId].size();
                size_t nr = ownElemRef[c.elemRefId].size();
                size_t nt = ownElemTs[c.tsId].size();
                if (no > 1) ++shOuter;
                if (na > 1) ++shArr;
                if (nr > 1) ++shElemRef;
                std::string co;
                if (nr > 1)
                    for (auto& x : ownElemRef[c.elemRefId])
                        co += (co.empty() ? "" : " ++ ") + x;
                printf("PROF\t%s\t%s\touter=%zu\tarr=%zu\telemref=%zu\t"
                       "elemts=%zu\t%s[%s -> %s]\town=%s\n",
                       sn, k.c_str(), no, na, nr, nt, c.kind.c_str(),
                       c.ts.c_str(), c.alias.c_str(), co.c_str());
            }
            printf("PROFSUM %s .elem-cells=%ld shared-outerref=%ld "
                   "shared-arrayts=%ld shared-elemref=%ld\n",
                   sn, nCells, shOuter, shArr, shElemRef);
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
        printf("DIFFER      %s   gold=%s[%s -> %s]inst=%s  ours=%s[%s -> %s]inst=%s\n",
               k.c_str(), gi->second.kind.c_str(), gi->second.ts.c_str(),
               gi->second.alias.c_str(), gi->second.inst.c_str(),
               oi->second.kind.c_str(), oi->second.ts.c_str(),
               oi->second.alias.c_str(), oi->second.inst.c_str());
        shapeTab[sk]++;
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
