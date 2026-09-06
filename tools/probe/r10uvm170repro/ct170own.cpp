// r10uvm170 — THE OWNER-FINDER + JUDGE DECODER for the
// `unsupported_typespec(uvm_severity)` vs `enum_typespec` head.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head here has BOTH sides present but they are DIFFERENT KINDS, so no
// single field can be ablated the way r10uvm168's const type was.  The three
// questions this tool answers instead:
//
//   (1) THE OWNER CHAIN of each side (`VpiParent` upward), so the head is
//       attributed to a named construct in a named scope.
//   (2) THE REFERRER INDEX — every object+FIELD in each database that POINTS AT
//       its side of the head (field table = the committed
//       `r10ladder1repro/ctfields.inc`, the official Compare field order).
//       For a typespec head the referrer is what actually decides the edge.
//   (3) THE ABLATION — every generated `<kind>::Compare` opens with
//       `if (!context->m_visited.insert(this).second) return r;` keyed on the
//       LHS, so seeding the GOLDEN head into a fresh context's `m_visited`
//       makes its whole subtree return 0.  Re-run the OFFICIAL
//       `design::Compare` and print the NEXT head.  That names the population
//       behind this one head without writing anything to either database.
//       `--maskall` masks EVERY golden unsupported_typespec whose kind
//       disagrees with our object, i.e. the whole family at once.
//
// build: g++ -O2 -std=c++17 ct170own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct170own
// usage: ct170own <golden.uhdm> <ours.uhdm> [--maskall] [--refs]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <string>
#include <unordered_map>
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
// every object+field in `all` that points at `head`
static void referrers(const char* tag, Serializer& s, const BaseClass* head) {
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
            chain("        ", X);
        }
    }
    printf("      REFERRERS=%zu\n", n);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct170own <golden> <ours> [--maskall] [--refs]\n"); return 2; }
    bool maskall = false, refs = false;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--maskall")) maskall = true;
        if (!strcmp(argv[i], "--refs")) refs = true;
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
        if (HL) referrers("GOLDEN", sg, HL);
        if (HR) referrers("OURS  ", so, HR);
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
    // ---- THE CHAIN: mask each head in turn and print the next ------------
    // (measurement only; masks cascade, so the list is a LOWER bound on what
    // is left — RESUME.md §9 "Ladder facts".)
    for (int i = 3; i < argc; i++) {
        if (strncmp(argv[i], "--chain=", 8)) continue;
        const int n = atoi(argv[i] + 8);
        CompareContext cc;
        for (int k = 0; k < n; ++k) {
            cc.m_failedLhs = cc.m_failedRhs = nullptr;
            CompareContext fresh;
            for (auto* v : {&cc}) (void)v;
            // a FRESH context each round, seeded with every head so far
            static std::vector<const BaseClass*> masked;
            if (k == 0) masked.clear();
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
        // mask EVERY golden unsupported_typespec — the family, at once
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
    return 0;
}
