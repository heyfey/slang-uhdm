// r10uvm207 — THE EDGE AND THE SHARING, for the CLASS-MEMBER window.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10uvm205's R0 named the next SeqDriver head: a `bit_typespec` reached from a
// WILDCARD-IMPORT CLONE body's local of CLASS type, through that class's MEMBER
// declaration — `adpcm_pkg::uvm_reg_map::m_set_mem_offset::range::
// uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t`.  A `class_typespec`
// stands between the reference and the subroutine, which is exactly the step
// § `cloneBodyBareTdAlias180`'s climb refuses.
//
// THIS TOOL ANSWERS TWO QUESTIONS BEFORE ANY PLAN:
//
//  --chain=<var>   THE EDGE.  Walk DOWN from a named declaration in a named
//                  subroutine: the declaration's `ref_typespec`, the typespec
//                  it binds, and — when that is a `class_typespec` — its
//                  `Class_defn`, that defn's own parent chain, and every
//                  member variable's typespec with its name / Typedef_alias
//                  target / vpiInstance.  Printed for BOTH databases so the
//                  pair the judge stops on is read, never guessed.
//
//  --share         THE SHARING, BY WHOLE-DATABASE IDENTITY.  For every
//                  `class_typespec` in the arena: which declarations bind it
//                  (by their innermost package + class + subroutine + name),
//                  and for every `class_defn`: which `class_typespec`s name it.
//                  A SHARED object re-pointed moves home cells too, so this
//                  count decides whether a law may re-point at all.
//
// No producer-private pointer is ever a KEY here; addresses are used only to
// group objects within ONE database and are never printed as a comparison.
//
// build: g++ -O2 -std=c++17 ct207own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct207own
// usage: ct207own <golden.uhdm> <ours.uhdm> [--chain=NAME] [--sub=NAME]
//                 [--share] [--tdname=NAME] [--members]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
// the innermost enclosing package / class / subroutine of an object, by a
// plain VpiParent climb (variables and io_decls ARE parented on both sides).
static std::string ownerPath(const BaseClass* o) {
    std::string pkg = "-", cls = "-", sub = "-";
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p; p = p->VpiParent()) {
        const auto k = p->UhdmType();
        if ((k == uhdmfunction || k == uhdmtask) && sub == "-") sub = nm(p);
        else if (k == uhdmclass_defn && cls == "-") cls = nm(p);
        else if (k == uhdmpackage && pkg == "-") pkg = nm(p);
    }
    return pkg + "|" + cls + "|" + sub;
}
static std::string parentChain(const BaseClass* o, int max = 10) {
    std::string s;
    int n = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && n < max;
         p = p->VpiParent(), ++n)
        s += " < " + kindOf(p) + ":" + nm(p);
    return s;
}
static std::string tsFace(const typespec* t) {
    if (!t) return "<null>";
    const ref_typespec* al = t->Typedef_alias();
    const typespec* tg = al ? al->Actual_typespec() : nullptr;
    const any* in = ((typespec*)t)->Instance();
    const any* ain = tg ? ((typespec*)tg)->Instance() : nullptr;
    char b[900];
    snprintf(b, sizeof b, "%s[%s -> %s] inst=%s alias-inst=%s",
             kindOf(t).c_str(), nm(t).c_str(),
             tg ? nm(tg).c_str() : "<noalias>", in ? nm(in).c_str() : "-",
             ain ? nm(ain).c_str() : "-");
    return b;
}

static void dumpTs(const char* tag, const ref_typespec* rt, int indent,
                   bool members, int budget);

static void dumpMembers(const char* tag, const class_defn* cd, int indent,
                        int budget) {
    if (!cd || budget <= 0) return;
    printf("%*s%s   class_defn %s   parents:%s\n", indent, "", tag,
           nm(cd).c_str(), parentChain(cd, 6).c_str());
    if (auto* vs = cd->Variables())
        for (auto* v : *vs) {
            printf("%*s%s     member var %s@%u:%u  ts=%s\n", indent, "", tag,
                   nm(v).c_str(), v->VpiLineNo(), (unsigned)v->VpiColumnNo(),
                   v->Typespec() ? tsFace(v->Typespec()->Actual_typespec()).c_str()
                                 : "<noref>");
        }
    if (auto* ex = cd->Extends()) {
        const ref_typespec* br = ex->Class_typespec();
        const typespec* bt = br ? br->Actual_typespec() : nullptr;
        if (bt && bt->UhdmType() == uhdmclass_typespec &&
            ((const class_typespec*)bt)->Class_defn())
            dumpMembers(tag, ((const class_typespec*)bt)->Class_defn(),
                        indent + 2, budget - 1);
    }
}

static void dumpTs(const char* tag, const ref_typespec* rt, int indent,
                   bool members, int budget) {
    if (!rt || budget <= 0) {
        printf("%*s%s   <no ref>\n", indent, "", tag);
        return;
    }
    const typespec* at = rt->Actual_typespec();
    printf("%*s%s   ref -> %s   ref-parents:%s\n", indent, "", tag,
           tsFace(at).c_str(), parentChain(rt, 6).c_str());
    if (!at) return;
    if (at->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)at;
        printf("%*s%s   .elem:\n", indent, "", tag);
        dumpTs(tag, a->Elem_typespec(), indent + 2, members, budget - 1);
    } else if (at->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)at;
        printf("%*s%s   .elem:\n", indent, "", tag);
        dumpTs(tag, a->Elem_typespec(), indent + 2, members, budget - 1);
    } else if (at->UhdmType() == uhdmstruct_typespec && members) {
        auto* st = (const struct_typespec*)at;
        printf("%*s%s   struct_typespec parents:%s\n", indent, "", tag,
               parentChain(st, 6).c_str());
        if (auto* ms = st->Members())
            for (auto* m : *ms)
                printf("%*s%s     member %s@%u:%u  ts=%s\n", indent, "", tag,
                       nm(m).c_str(), m->VpiLineNo(),
                       (unsigned)m->VpiColumnNo(),
                       m->Typespec()
                           ? tsFace(m->Typespec()->Actual_typespec()).c_str()
                           : "<noref>");
    } else if (at->UhdmType() == uhdmclass_typespec && members) {
        auto* ct = (const class_typespec*)at;
        printf("%*s%s   class_typespec parents:%s\n", indent, "", tag,
               parentChain(ct, 6).c_str());
        dumpMembers(tag, ct->Class_defn(), indent + 2, budget - 1);
    }
}

static void chainOf(Serializer& S, const char* tag, const char* var,
                    const char* sub, bool members) {
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
        else if (auto* io = any_cast<const io_decl*>(o)) rt = io->Typespec();
        else continue;
        if (var && nm(o) != var) continue;
        std::string op = ownerPath(o);
        if (sub && op.find(sub) == std::string::npos) continue;
        printf("%s DECL %s %s@%u:%u  owner=%s\n", tag, kindOf(o).c_str(),
               nm(o).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
               op.c_str());
        dumpTs(tag, rt, 2, members, 8);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct207own <golden> <ours> [--chain=NAME] [--sub=NAME] "
                "[--share] [--members] [--tdname=NAME]\n");
        return 2;
    }
    const char *chain = nullptr, *sub = nullptr, *tdname = nullptr;
    bool share = false, members = false;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--chain=", 8)) chain = argv[i] + 8;
        else if (!strncmp(argv[i], "--sub=", 6)) sub = argv[i] + 6;
        else if (!strncmp(argv[i], "--tdname=", 9)) tdname = argv[i] + 9;
        else if (!strcmp(argv[i], "--share")) share = true;
        else if (!strcmp(argv[i], "--members")) members = true;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    if (!topDesign(sg) || !topDesign(so)) { printf("NO_DESIGN\n"); return 3; }

    if (chain) {
        chainOf(sg, "GOLD", chain, sub, members);
        chainOf(so, "OURS", chain, sub, members);
    }
    if (share) {
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            // class_typespec -> the DECLARATIONS that bind it
            std::map<const BaseClass*, std::set<std::string>> ctsUsers;
            // class_defn -> the class_typespecs that name it
            std::map<const BaseClass*, long> defnRefs;
            long nCts = 0, nDefn = 0;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o) continue;
                if (o->UhdmType() == uhdmclass_typespec) {
                    ++nCts;
                    auto* ct = (const class_typespec*)o;
                    if (ct->Class_defn()) defnRefs[(const BaseClass*)ct->Class_defn()]++;
                    continue;
                }
                if (o->UhdmType() == uhdmstruct_typespec) { ++nCts; continue; }
                if (o->UhdmType() == uhdmclass_defn) { ++nDefn; continue; }
                const ref_typespec* rt = nullptr;
                if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
                else if (auto* io = any_cast<const io_decl*>(o)) rt = io->Typespec();
                if (!rt) continue;
                const typespec* at = rt->Actual_typespec();
                if (!at || (at->UhdmType() != uhdmclass_typespec &&
                            at->UhdmType() != uhdmstruct_typespec))
                    continue;
                char lb[700];
                snprintf(lb, sizeof lb, "%s@%u:%u [%s %s]", ownerPath(o).c_str(),
                         o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                         kindOf(at).c_str(), nm(at).c_str());
                ctsUsers[(const BaseClass*)at].insert(std::string(lb) + " " + nm(o));
            }
            long shared = 0, singles = 0;
            std::map<long, long> hist;
            for (auto& [c, u] : ctsUsers) {
                hist[(long)u.size()]++;
                if (u.size() > 1) ++shared; else ++singles;
            }
            printf("SHARE[%s] class_typespec objects=%ld class_defn objects=%ld "
                   "bound-by-decls=%zu shared(>1 decl)=%ld single=%ld\n",
                   tag, nCts, nDefn, ctsUsers.size(), shared, singles);
            for (auto& [n, c] : hist)
                printf("SHARE[%s]   class/struct_typespecs bound by %ld declaration(s): %ld\n",
                       tag, n, c);
            for (auto& [c, u] : ctsUsers) {
                if (u.size() < 2) continue;
                bool any = false;
                for (auto& x : u)
                    if (x.find("uvm_reg_map_addr_range") != std::string::npos)
                        any = true;
                if (!any) continue;
                printf("SHARE[%s] SHARED-STRUCT-TS bound by %zu declarations:\n",
                       tag, u.size());
                for (auto& x : u) printf("SHARE[%s]     %s\n", tag, x.c_str());
            }
            long dshared = 0;
            std::map<long, long> dh;
            for (auto& [d, n] : defnRefs) { dh[n]++; if (n > 1) ++dshared; }
            printf("SHARE[%s] class_defns named by >1 class_typespec: %ld / %zu\n",
                   tag, dshared, defnRefs.size());
            for (auto& [n, c] : dh)
                printf("SHARE[%s]   class_defns named by %ld class_typespec(s): %ld\n",
                       tag, n, c);
        }
    }
    if (tdname) {
        // every MEMBER declaration of every class_defn whose typespec chain
        // reaches a typespec with this name — with the class_defn's own
        // enclosing package, so "is the member's class itself imported" is a
        // COLUMN and not a guess.
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            std::map<std::string, long> tab;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || o->UhdmType() != uhdmclass_defn) continue;
                auto* cd = (const class_defn*)o;
                std::string pkg = "-";
                for (const BaseClass* p = cd->VpiParent(); p; p = p->VpiParent())
                    if (p->UhdmType() == uhdmpackage) { pkg = nm(p); break; }
                if (!cd->Variables()) continue;
                for (auto* v : *cd->Variables()) {
                    const ref_typespec* rt = v->Typespec();
                    const typespec* at = rt ? rt->Actual_typespec() : nullptr;
                    if (!at) continue;
                    if (nm(at).find(tdname) == std::string::npos) continue;
                    const ref_typespec* al = at->Typedef_alias();
                    const typespec* tg = al ? al->Actual_typespec() : nullptr;
                    char b[600];
                    snprintf(b, sizeof b, "defnpkg=%-14s class=%-30s ts=%-28s alias=%s",
                             pkg.c_str(), nm(cd).c_str(), nm(at).c_str(),
                             tg ? nm(tg).c_str() : "<noalias>");
                    tab[b]++;
                }
            }
            printf("\nMEMBERS OF EVERY class_defn WHOSE TYPE NAME MATCHES '%s' [%s]:\n",
                   tdname, tag);
            for (auto& [k, v] : tab) printf("  %-130s %6ld\n", k.c_str(), v);
        }
    }
    return 0;
}
