// r10uvm198 — THE OWNER-FINDER + JUDGE DECODER for the clone-body class-scope
// typedef LOCAL head: golden `unsupported_typespec(m_verbosity_setting)` vs our
// resolved `struct_typespec`.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The r10uvm170 form (both sides present, DIFFERENT KINDS, so no single field
// can be ablated), with one addition this pass needs: `--mint` prints, for the
// GOLDEN mint named by the head, every OTHER golden object of that kind+name
// and every referrer of each — i.e. whether the mint is SHARED or per
// declaration, which decides whether a law may mint one object per site.
//
//   (1) THE OWNER CHAIN of each side (`VpiParent` upward).  The head's own
//       vpiParent is NOT read by any generated Compare (RESUME §9) — it is
//       printed to NAME the construct, never to justify an edge.
//   (2) THE REFERRER INDEX — every object+FIELD in each database that POINTS
//       AT its side of the head (field table = the committed
//       `r10ladder1repro/ctfields.inc`, the official Compare field order).
//   (3) THE ABLATION — every generated `<kind>::Compare` opens with
//       `if (!context->m_visited.insert(this).second) return r;` keyed on the
//       LHS, so seeding the GOLDEN head into a fresh context's `m_visited`
//       makes its whole subtree return 0.  Re-run the OFFICIAL
//       `design::Compare` and print the NEXT head.  `--maskall` masks EVERY
//       golden `unsupported_typespec` at once (the whole placeholder family),
//       which says whether more of this family is behind the one head.
//   (4) `--pairs=<name>` — EVERY clone-body local on BOTH sides whose typespec
//       name is <name>: the object kind each side binds, its instance, and its
//       owning subroutine, so the population behind the head is counted, not
//       guessed.
//
// build: g++ -O2 -std=c++17 ct198own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct198own
// usage: ct198own <golden.uhdm> <ours.uhdm> [--refs] [--maskall] [--mint]
//                 [--pairs=<typespec name>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <cstdlib>
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
            t != uhdmnamed_begin)
            continue;
        r += " < ";
        r += std::string(UhdmName(t));
        r += ":";
        r += std::string(p->VpiName());
    }
    return r;
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
            printf("      REF .%-20s %-9s %s\n", f.name, isvec ? w : "rel1",
                   ident(X).c_str());
            chain("        ", X);
        }
    }
    if (print) printf("      REFERRERS=%zu\n", n);
    return n;
}
// the instance link a typespec carries (vpiInstance == 608 in the field table)
static const BaseClass* tsInstance(const BaseClass* o) {
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Instance"))
            return rel1(o, f);
    return nullptr;
}
// every object of this kind+name, with its referrer count and instance
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
// every ref_typespec whose Actual_typespec is named <nm>, with the variable /
// io_decl that owns it and the subroutine above that
static void pairs(const char* tag, Serializer& s, const char* nm) {
    printf("  %s BINDINGS to a typespec named '%s':\n", tag, nm);
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmref_typespec) continue;
        const BaseClass* a = nullptr;
        auto it = kFields.find("ref_typespec");
        if (it != kFields.end())
            for (const Field& f : it->second)
                if (f.kind == F_REL1 && !strcmp(f.name, "Actual_typespec"))
                    a = rel1(X, f);
        if (!a || a->VpiName() != std::string_view(nm)) continue;
        ++n;
        printf("      TS %-28s @%u:%u inst=%-34s owner=%s%s\n",
               std::string(UhdmName(a->UhdmType())).c_str(), a->VpiLineNo(),
               (unsigned)a->VpiColumnNo(), ident(tsInstance(a)).c_str(),
               ident(X->VpiParent()).c_str(), chainStr(X->VpiParent()).c_str());
    }
    printf("      BINDINGS=%zu\n", n);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct198own <golden> <ours> [--refs] [--maskall] [--mint]"
                " [--pairs=<name>]\n");
        return 2;
    }
    bool maskall = false, refs = false, mint = false;
    const char* pairName = nullptr;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--maskall")) maskall = true;
        if (!strcmp(argv[i], "--refs")) refs = true;
        if (!strcmp(argv[i], "--mint")) mint = true;
        if (!strncmp(argv[i], "--pairs=", 8)) pairName = argv[i] + 8;
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
    if (HL) printf("  golden head Instance = %s\n", ident(tsInstance(HL)).c_str());
    if (HR) printf("  ours   head Instance = %s\n", ident(tsInstance(HR)).c_str());
    if (refs) {
        if (HL) referrers("GOLDEN", sg, HL, true);
        if (HR) referrers("OURS  ", so, HR, true);
    }
    if (mint) {
        if (HL) mintCensus("GOLDEN", sg, HL);
        if (HR) mintCensus("OURS  ", so, HR);
    }
    if (pairName) {
        pairs("GOLDEN", sg, pairName);
        pairs("OURS  ", so, pairName);
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
