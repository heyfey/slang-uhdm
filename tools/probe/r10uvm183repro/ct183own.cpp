// r10uvm183 — THE OWNER-FINDER + JUDGE DECODER for the MiniAmiq head
// (golden `unsupported_typespec(arg)` vs ours a resolved `string_typespec`).
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Both sides are present and of DIFFERENT KINDS, so the questions are the ones
// r10uvm170's `ct170own.cpp` asks (owner chains, the referrer index built from
// the committed `r10ladder1repro/ctfields.inc` field order, the `m_visited`
// ablation, `--maskall`, `--chain=N`) plus r10uvm181's STEP 2: every
// `foreach_stmt` of a named subroutine on BOTH sides with its iterated
// reference, that reference's typespec edge and every loop variable — which is
// what tells a formal's io_decl typespec apart from the foreach ARRAY
// REFERENCE that happens to share the same object.
//
// `--sharers` additionally prints every edge in each database that points at
// the head object, so a SHARED typespec (ours) is distinguished from a
// per-site mint (golden's).
//
// build: g++ -O2 -std=c++17 ct183own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct183own
// usage: ct183own <golden.uhdm> <ours.uhdm> [--refs] [--sharers] [--maskall]
//                 [--chain=N] [--foreach=<subroutine name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
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
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    // UhdmName() returns a string_view over UHDM's table and is NOT guaranteed
    // NUL-terminated — the explicit std::string is required (r10earl60).
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
static void chain(const char* tag, const BaseClass* o) {
    printf("  %s owner chain:\n", tag);
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 24;
         p = p->VpiParent(), ++g)
        printf("      < %s\n", ident(p).c_str());
    if (g == 0) printf("      < <no parent>\n");
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
// every object+field in `s` that points at `head`
static size_t referrers(const char* tag, Serializer& s, const BaseClass* head,
                        bool withChain) {
    printf("  %s referrers of %s:\n", tag, ident(head).c_str());
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        auto it = kFields.find(std::string(UhdmName(X->UhdmType())));
        if (it == kFields.end()) continue;
        for (const Field& f : it->second) {
            bool hit = false;
            size_t idx = 0;
            bool isvec = false;
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
            char w[32];
            snprintf(w, sizeof w, "vec[%zu]", idx);
            printf("      REF .%-20s %-9s %s\n", f.name, isvec ? w : "rel1",
                   ident(X).c_str());
            if (withChain) chain("        ", X);
        }
    }
    printf("      REFERRERS=%zu\n", n);
    return n;
}

static const BaseClass* enclosingTf(const BaseClass* o, const char* want) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
            const std::string n(p->VpiName());
            if (!want || n.find(want) != std::string::npos) return p;
            return nullptr;
        }
    return nullptr;
}
// the owning scope (package / class_defn / module) of an object, with its id,
// so the DEF and ELAB copies of the same source line can be told apart.
static std::string ownScope(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmpackage || t == uhdmclass_defn || t == uhdmmodule_inst ||
            t == uhdminterface_inst)
            return ident(p);
    }
    return "<no scope>";
}
static const ref_typespec* tsRefOf(const BaseClass* o) {
    if (!o) return nullptr;
    if (auto* v = any_cast<const variables*>(o)) return v->Typespec();
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Typespec();
    if (o->UhdmType() == uhdmio_decl) return ((const io_decl*)o)->Typespec();
    return nullptr;
}
static std::string tsEdge(const BaseClass* o) {
    const ref_typespec* rt = tsRefOf(o);
    if (!rt) return "TS=<null>";
    return "TS=" + ident(rt) + " -> " + ident(rt->Actual_typespec());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct183own <golden> <ours> [--refs] [--sharers] "
                "[--maskall] [--chain=N] [--foreach=<sub>]\n");
        return 2;
    }
    bool maskall = false, refs = false, sharers = false;
    const char* fnWant = nullptr;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--maskall")) maskall = true;
        if (!strcmp(argv[i], "--refs")) refs = true;
        if (!strcmp(argv[i], "--sharers")) sharers = true;
        if (!strncmp(argv[i], "--foreach=", 10)) fnWant = argv[i] + 10;
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
    if (HL) printf("golden head scope: %s\n", ownScope(HL).c_str());
    if (HR) printf("ours   head scope: %s\n", ownScope(HR).c_str());
    if (refs) {
        if (HL) referrers("GOLDEN", sg, HL, true);
        if (HR) referrers("OURS  ", so, HR, true);
    }
    if (sharers) {
        // How many edges point at each side?  Ours being SHARED with the
        // formal's io_decl is the whole point of this pass's decode.
        if (HL) referrers("GOLDEN-SHARERS", sg, HL, false);
        if (HR) referrers("OURS--SHARERS ", so, HR, false);
    }

    // ---- THE ABLATION -----------------------------------------------------
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
    // ---- THE CHAIN --------------------------------------------------------
    // (measurement only; masks cascade, so the list is a LOWER bound on what
    // is left — RESUME.md §9 "Ladder facts".)
    for (int i = 3; i < argc; i++) {
        if (strncmp(argv[i], "--chain=", 8)) continue;
        const int n = atoi(argv[i] + 8);
        std::vector<const BaseClass*> masked;
        for (int k = 0; k < n; ++k) {
            CompareContext fresh;
            for (auto* mm : masked) fresh.m_visited.insert(mm);
            int rr = dg->Compare(dou, &fresh);
            printf("CHAIN %2d r=%-6d LHS=%s\n            RHS=%s\n", k, rr,
                   ident(fresh.m_failedLhs).c_str(),
                   ident(fresh.m_failedRhs).c_str());
            if (!fresh.m_failedLhs) break;
            masked.push_back(fresh.m_failedLhs);
        }
        break;
    }
    if (maskall) {
        CompareContext c3;
        size_t nm = 0;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* o = (const BaseClass*)kv.first;
            if (o && o->UhdmType() == uhdmunsupported_typespec) {
                c3.m_visited.insert(o);
                ++nm;
            }
        }
        int r3 = dg->Compare(dou, &c3);
        printf("MASKALL (%zu golden unsupported_typespec masked):\n", nm);
        printf("  design::Compare r=%d\n", r3);
        printf("  NEXT LHS(golden) = %s\n", ident(c3.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c3.m_failedRhs).c_str());
    }

    // ---- STEP 2 — EVERY FOREACH IN A NAMED SUBROUTINE, BOTH SIDES ---------
    if (fnWant) {
        printf("FOREACH SITES IN SUBROUTINES MATCHING '%s' — golden then ours:\n",
               fnWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
                auto* fs = (const foreach_stmt*)o;
                if (!enclosingTf(o, fnWant)) continue;
                const BaseClass* tf = enclosingTf(o, nullptr);
                // The ITERATED REFERENCE is `foreach_stmt::Variable` (singular)
                // — Surelog writes it at CompileStmt.cpp:601 and we at the
                // `fs->Variable(rv)` line of StmtEmit's ForeachLoop arm.  The
                // inherited `Variables()` VECTOR is a different edge and is
                // empty here, which is why it must not be read instead.
                const BaseClass* arr = (const BaseClass*)fs->Variable();
                std::string lvs;
                if (auto* lv = fs->VpiLoopVars())
                    for (auto* v : *lv)
                        lvs += "\n           LOOPVAR " + ident(v) + " " + tsEdge(v);
                char b[3000];
                snprintf(b, sizeof b,
                         "    %5u:%-3u tf=%s\n           SCOPE %s\n           ARR "
                         "%s %s%s",
                         o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                         tf ? ident(tf).c_str() : "-", ownScope(o).c_str(),
                         ident(arr).c_str(), tsEdge(arr).c_str(), lvs.c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s2 : rows) printf("%s\n", s2.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
        // and the FORMALS of the same subroutines, so the io_decl typespec is
        // visible next to the foreach's array-reference typespec.
        printf("IO_DECLS OF THE SAME SUBROUTINES — golden then ours:\n");
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || o->UhdmType() != uhdmio_decl) continue;
                if (!enclosingTf(o, fnWant)) continue;
                char b[1600];
                snprintf(b, sizeof b, "    %s %s\n           SCOPE %s",
                         ident(o).c_str(), tsEdge(o).c_str(),
                         ownScope(o).c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s2 : rows) printf("%s\n", s2.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
    }
    return 0;
}
