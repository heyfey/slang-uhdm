// r10uvm204 — THE OWNER-FINDER + JUDGE DECODER for the FOR-LOOP INITIALISATION
// declared variable head: golden lists
//   class_var(uvm_pkg::uvm_reg_field::do_predict::cb) parented at the loop's
//   `assignment`, bound to an UNNAMED class_typespec spanning the written type
// and we list <null>.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from r10uvm202repro/ct202own.cpp (owner chain / referrer index /
// mint census / ablation), with the modes THIS head needs:
//
//   --refs       every field of every object that POINTS AT the head, on both
//                sides — this is what decides WHICH container holds golden's
//                class_var and our null (the init `assignment`'s Lhs, a scope
//                `Variables` listing, or both).
//   --forinit    every `for_stmt` in the database with its init shape, field by
//                field: the number of init statements, and per init statement
//                the statement kind, the Lhs object kind + name, the Lhs
//                typespec kind + name + span, and whether that Lhs variable is
//                ALSO an element of some scope's `Variables` listing.
//   --fikeys     the same, reduced to a one-line-per-init CENSUS KEY suitable
//                for a golden-vs-ours join (`FI|<view>|<file>:<line>:<col>|<i>`
//                and a value carrying the shape).
//   --mint/--maskall/--pairs as in ct202own.
//
// build: g++ -O2 -std=c++17 ct204own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct204own
// usage: ct204own <golden.uhdm> <ours.uhdm> [--refs] [--mint] [--maskall]
//                 [--forinit] [--fikeys] [--pairs=<name>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// UhdmName() returns a string_view over UHDM's table and is NOT guaranteed
// NUL-terminated — the explicit std::string is required (r10earl60).
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string chainStr(const BaseClass* o) {
    std::string r;
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 24;
         p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask && t != uhdmbegin &&
            t != uhdmnamed_begin && t != uhdmfor_stmt && t != uhdmassignment)
            continue;
        r += " < ";
        r += std::string(UhdmName(t));
        r += "(";
        r += std::string(p->VpiName());
        r += ")";
    }
    return r;
}
static void chain(const char* tag, const BaseClass* o) {
    printf("  %s owner chain:%s\n", tag, chainStr(o).c_str());
}
static const BaseClass* rel1(const BaseClass* o, const Field& f) {
    if (!f.sel) return nullptr;
    return std::get<0>(o->GetByVpiType(f.sel));
}
static void relv(const BaseClass* o, const Field& f,
                 std::vector<const BaseClass*>& out) {
    if (!f.sel) return;
    if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
        for (auto* e : *v)
            if (e) out.push_back((const BaseClass*)e);
}
static size_t referrers(const char* tag, Serializer& s, const BaseClass* head,
                        bool print) {
    if (print) printf("  %s referrers of %s:\n", tag, ident(head).c_str());
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        auto it = kFields.find(std::string(UhdmName(X->UhdmType())));
        if (it == kFields.end()) continue;
        for (const Field& f : it->second) {
            bool hit = false, isvec = false;
            size_t idx = 0;
            if (f.kind == F_REL1) {
                if (rel1(X, f) == head) hit = true;
            } else if (f.kind == F_RELV) {
                std::vector<const BaseClass*> v;
                relv(X, f, v);
                for (size_t i = 0; i < v.size(); i++)
                    if (v[i] == head) { hit = true; isvec = true; idx = i; break; }
            }
            if (!hit) continue;
            ++n;
            if (!print) continue;
            char w[32];
            snprintf(w, sizeof w, "vec[%zu]", idx);
            printf("      REF .%-20s %-9s %s%s\n", f.name, isvec ? w : "rel1",
                   ident(X).c_str(), chainStr(X).c_str());
        }
    }
    if (print) printf("      REFERRERS=%zu\n", n);
    return n;
}
static const BaseClass* tsInstance(const BaseClass* o) {
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Instance"))
            return rel1(o, f);
    return nullptr;
}
static void mintCensus(const char* tag, Serializer& s, const BaseClass* like) {
    printf("  %s MINT CENSUS for %s named '%s':\n", tag,
           std::string(UhdmName(like->UhdmType())).c_str(),
           std::string(like->VpiName()).c_str());
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != like->UhdmType()) continue;
        if (X->VpiName() != like->VpiName()) continue;
        ++n;
        printf("      OBJ %s inst=%s refs=%zu%s\n", ident(X).c_str(),
               ident(tsInstance(X)).c_str(), referrers("", s, X, false),
               chainStr(X).c_str());
    }
    printf("      OBJECTS=%zu\n", n);
}

// ---------------------------------------------------------------- --forinit
// THE VIEW a for_stmt lives in: walk to the outermost ancestor.  A `module_inst`
// anywhere above means the ELABORATED view; a bare `package`/`class_defn` chain
// means the DEFINITION view.
static std::string viewOf(const BaseClass* o) {
    bool mod = false, pkg = false, cls = false;
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        switch (p->UhdmType()) {
            case uhdmmodule_inst: mod = true; break;
            case uhdmpackage: pkg = true; break;
            case uhdmclass_defn: cls = true; break;
            default: break;
        }
    }
    if (mod) return "elab";
    if (pkg) return "pkg";
    if (cls) return "cls";
    return "other";
}
// the nearest named enclosing scope, for the human-readable rows
static std::string scopeOf(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask || t == uhdmclass_defn ||
            t == uhdmpackage || t == uhdmmodule_inst) {
            std::string n(p->VpiName());
            return std::string(UhdmName(t)) + "(" + n + ")";
        }
    }
    return "-";
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[256];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
struct FIRow {
    std::string key;    // FI|<view>|<file>:<line>:<col>|<n>|<i>
    std::string val;    // the shape
    std::string human;
};
// every variable that is an element of SOME scope's Variables listing
static void collectListed(Serializer& s, std::set<const BaseClass*>& out) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        switch (X->UhdmType()) {
            case uhdmtask: vars = ((const task*)X)->Variables(); break;
            case uhdmfunction: vars = ((const function*)X)->Variables(); break;
            case uhdmbegin: vars = ((const begin*)X)->Variables(); break;
            case uhdmnamed_begin: vars = ((const named_begin*)X)->Variables(); break;
            case uhdmfork_stmt: vars = ((const fork_stmt*)X)->Variables(); break;
            case uhdmnamed_fork: vars = ((const named_fork*)X)->Variables(); break;
            case uhdmfor_stmt: vars = nullptr; break;
            case uhdmclass_defn: vars = ((const class_defn*)X)->Variables(); break;
            case uhdmpackage: vars = ((const package*)X)->Variables(); break;
            case uhdmmodule_inst: vars = ((const module_inst*)X)->Variables(); break;
            default: break;
        }
        if (!vars) continue;
        for (const variables* v : *vars)
            if (v) out.insert((const BaseClass*)v);
    }
}
static void forinit(const char* tag, Serializer& s, bool human,
                    std::vector<FIRow>& rows) {
    std::set<const BaseClass*> listed;
    collectListed(s, listed);
    std::map<std::string, size_t> tally;
    size_t nfor = 0, ninit = 0;
    std::vector<std::string> lines;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmfor_stmt) continue;
        const for_stmt* F = (const for_stmt*)X;
        ++nfor;
        const std::string vw = viewOf(X);
        const std::string loc = spanOf(X);
        std::vector<const any*> inits;
        if (const VectorOfany* iv = F->VpiForInitStmts())
            for (const any* a : *iv) inits.push_back(a);
        const any* single = F->VpiForInitStmt();
        const size_t n = inits.size() + (single ? 1 : 0);
        if (n == 0) {
            const std::string key = "FI|" + vw + "|" + loc + "|0|-";
            rows.push_back({key, "NOINIT", ""});
            tally["NOINIT"]++;
            continue;
        }
        std::vector<std::pair<std::string, const any*>> all;
        if (single) all.push_back({"SINGULAR", single});
        for (size_t i = 0; i < inits.size(); i++)
            all.push_back({"VEC" + std::to_string(i), inits[i]});
        for (size_t i = 0; i < all.size(); i++) {
            const any* st = all[i].second;
            ++ninit;
            std::string sk(UhdmName(st->UhdmType()));
            std::string lk = "-", ln = "-", tk = "-", tn = "-", tsp = "-";
            std::string inlist = "-";
            std::string rk = "-";
            if (st->UhdmType() == uhdmassignment) {
                const assignment* A = (const assignment*)st;
                if (const expr* L = A->Lhs()) {
                    lk = std::string(UhdmName(L->UhdmType()));
                    ln = std::string(L->VpiName());
                    const ref_typespec* rt = nullptr;
                    auto it = kFields.find(lk);
                    if (it != kFields.end())
                        for (const Field& f : it->second)
                            if (f.kind == F_REL1 && !strcmp(f.name, "Typespec"))
                                rt = (const ref_typespec*)rel1(L, f);
                    const typespec* a = rt ? rt->Actual_typespec() : nullptr;
                    if (a) {
                        tk = std::string(UhdmName(a->UhdmType()));
                        tn = std::string(a->VpiName());
                        if (tn.empty()) tn = "<unnamed>";
                        tsp = spanOf(a);
                    } else {
                        tk = rt ? "<rt-null-actual>" : "<no-ref_typespec>";
                    }
                    inlist = listed.count((const BaseClass*)L) ? "LISTED"
                                                               : "notlisted";
                } else {
                    lk = "<null-Lhs>";
                }
                if (const any* R = A->Rhs())
                    rk = std::string(UhdmName(R->UhdmType()));
                else
                    rk = "<null-Rhs>";
            }
            const std::string val = all[i].first + " " + sk + " lhs=" + lk +
                                    " ts=" + tk + " tsname=" + tn +
                                    " tsspan=" + tsp + " " + inlist +
                                    " rhs=" + rk;
            const std::string key = "FI|" + vw + "|" + loc + "|" +
                                    std::to_string(all.size()) + "|" +
                                    std::to_string(i);
            rows.push_back({key, val, ""});
            tally[std::string(sk) + " lhs=" + lk + " ts=" + tk + " " + inlist]++;
            if (human) {
                char b[1400];
                snprintf(b, sizeof b,
                         "    FOR %-5s %-40s scope=%-46s %-8s %-12s lhs=%-12s "
                         "name=%-20s ts=%-22s tsname=%-34s tsspan=%-28s %-10s rhs=%s",
                         vw.c_str(), loc.c_str(), scopeOf(X).c_str(),
                         all[i].first.c_str(), sk.c_str(), lk.c_str(),
                         ln.c_str(), tk.c_str(), tn.c_str(), tsp.c_str(),
                         inlist.c_str(), rk.c_str());
                lines.push_back(b);
            }
        }
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) printf("%s\n", l.c_str());
    for (auto& [k, c] : tally)
        printf("    %s SHAPE %-70s %zu\n", tag, k.c_str(), c);
    printf("    %s FOR_STMTS=%zu INIT_STMTS=%zu\n", tag, nfor, ninit);
}

// ------------------------------------------------------------------- --acg
// Every object carrying an `Actual_group` (ref_obj / ref_var / ...) whose
// VpiName is <nm>, on both sides, with the object it binds to.  A golden
// non-null against our null here is exactly the SINGULAR `SafeCompare`
// rhs==nullptr branch that prints `RHS: <null>` while naming the golden VALUE
// (RESUME.md §9; buvm13/15).
static const BaseClass* actualGroup(const BaseClass* o) {
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Actual_group"))
            return rel1(o, f);
    return nullptr;
}
static bool hasActualGroup(const BaseClass* o) {
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return false;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Actual_group")) return true;
    return false;
}
static void acg(const char* tag, Serializer& s, const char* nm) {
    printf("  %s Actual_group carriers named '%s':\n", tag, nm);
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || !hasActualGroup(X)) continue;
        if (std::string(X->VpiName()) != std::string(nm)) continue;
        const BaseClass* A = actualGroup(X);
        char b[1400];
        snprintf(b, sizeof b, "      ACG %-14s %-34s -> %-56s %s",
                 std::string(UhdmName(X->UhdmType())).c_str(),
                 spanOf(X).c_str(),
                 A ? ident(A).c_str() : "<null>", chainStr(X).c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("      CARRIERS=%zu\n", rows.size());
}

// every ref_typespec whose Actual_typespec is named <nm>
static void pairs(const char* tag, Serializer& s, const char* nm) {
    printf("  %s BINDINGS to a typespec named '%s':\n", tag, nm);
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmref_typespec) continue;
        const ref_typespec* rt = (const ref_typespec*)X;
        const typespec* a = rt->Actual_typespec();
        if (!a || a->VpiName() != std::string_view(nm)) continue;
        ++n;
        printf("      TS %-28s @%u:%u inst=%-30s owner=%s%s\n",
               std::string(UhdmName(a->UhdmType())).c_str(), a->VpiLineNo(),
               (unsigned)a->VpiColumnNo(), ident(tsInstance(a)).c_str(),
               ident(X->VpiParent()).c_str(), chainStr(X->VpiParent()).c_str());
    }
    printf("      BINDINGS=%zu\n", n);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct204own <golden> <ours> [--refs] [--mint] [--maskall]"
                " [--forinit] [--fikeys] [--pairs=<name>]\n");
        return 2;
    }
    bool maskall = false, refs = false, mint = false;
    bool fi = false, fikeys = false;
    const char* pairName = nullptr;
    const char* acgName = nullptr;
    bool twin = false;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--maskall")) maskall = true;
        if (!strcmp(argv[i], "--refs")) refs = true;
        if (!strcmp(argv[i], "--mint")) mint = true;
        if (!strcmp(argv[i], "--forinit")) fi = true;
        if (!strcmp(argv[i], "--fikeys")) fikeys = true;
        if (!strncmp(argv[i], "--pairs=", 8)) pairName = argv[i] + 8;
        if (!strncmp(argv[i], "--acg=", 6)) acgName = argv[i] + 6;
        if (!strcmp(argv[i], "--twin")) twin = true;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    if (HL) chain("golden", HL);
    if (HR) chain("ours  ", HR);
    if (refs) {
        if (HL) referrers("GOLDEN", sg, HL, true);
        if (HR) referrers("OURS  ", so, HR, true);
    }
    if (mint) {
        if (HL) mintCensus("GOLDEN", sg, HL);
        if (HR) mintCensus("OURS  ", so, HR);
    }
    if (fi || fikeys) {
        std::vector<FIRow> rg, ro;
        printf("GOLDEN for-init shapes\n");
        forinit("GOLDEN", sg, fi, rg);
        printf("OURS   for-init shapes\n");
        forinit("OURS  ", so, fi, ro);
        if (fikeys) {
            for (auto& x : rg) printf("GKEY %s\t%s\n", x.key.c_str(), x.val.c_str());
            for (auto& x : ro) printf("AKEY %s\t%s\n", x.key.c_str(), x.val.c_str());
        }
    }
    if (pairName) { pairs("GOLDEN", sg, pairName); pairs("OURS  ", so, pairName); }
    if (acgName) { acg("GOLDEN", sg, acgName); acg("OURS  ", so, acgName); }
    // --twin: OUR object at the golden head's own kind/name/line/column, and
    // ITS referrers — the direct answer to "does our counterpart exist, and is
    // it reached through the same fields".
    if (twin && HL) {
        printf("TWIN of %s in OURS:\n", ident(HL).c_str());
        size_t n = 0;
        for (auto& kv : so.AllObjects()) {
            const BaseClass* X = (const BaseClass*)kv.first;
            if (!X || X->UhdmType() != HL->UhdmType()) continue;
            if (X->VpiName() != HL->VpiName()) continue;
            if (X->VpiLineNo() != HL->VpiLineNo() ||
                X->VpiColumnNo() != HL->VpiColumnNo())
                continue;
            ++n;
            printf("  TWIN %s%s\n", ident(X).c_str(), chainStr(X).c_str());
            referrers("OURS  ", so, X, true);
        }
        printf("  TWINS=%zu\n", n);
    }
    if (HL) {
        CompareContext c2;
        c2.m_visited.insert(HL);
        int r2 = dg->Compare(dou, &c2);
        printf("ABLATION (mask the golden head only):\n");
        printf("  design::Compare r=%d\n", r2);
        printf("  NEXT LHS(golden) = %s\n", ident(c2.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c2.m_failedRhs).c_str());
        printf("  VERDICT: %s\n",
               (c2.m_failedLhs != HL || c2.m_failedRhs != HR)
                   ? "THE HEAD MOVED (this object was the whole head)"
                   : "REFUTED — the judge stopped on the same pair again");
    }
    if (maskall) {
        CompareContext c3;
        size_t nm = 0;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* o = (const BaseClass*)kv.first;
            if (o && o->UhdmType() == uhdmclass_var) {
                c3.m_visited.insert(o);
                ++nm;
            }
        }
        int r3 = dg->Compare(dou, &c3);
        printf("MASKALL (%zu golden class_var masked):\n", nm);
        printf("  design::Compare r=%d\n", r3);
        printf("  NEXT LHS(golden) = %s\n", ident(c3.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c3.m_failedRhs).c_str());
    }
    return 0;
}
