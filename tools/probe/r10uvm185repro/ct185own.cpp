// r10uvm185 — THE OWNER-FINDER + JUDGE DECODER for the BuildUVMPkg head
// (`enum_var` vs `class_var`, the RETURN variable of an `extern` class method).
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// It is r10uvm170's `ct170own.cpp` (owner chain + referrer index + ablation +
// chain) with the THREE additions this head's brief demands:
//
//   (A) THE FAILING EDGE, NAMED.  The head's two sides are children of a
//       `function`; this tool finds the OWNER PAIR by walking `VpiParent` on
//       both sides at once and then replays `task_func::Compare`'s OWN field
//       order over that pair, printing PASS/FAIL for every field, so the
//       failing edge is read off the judge rather than guessed.
//   (B) EVERY SIBLING EDGE ON THE SAME OWNER, both sides, in that same order —
//       which is what proves the edge is the ONLY thing wrong with the owner.
//   (C) THE NEXT TWO FIELDS in the judge's order after the failing one, with
//       their values on both sides, so the ladder past this head is known
//       BEFORE any code is written.
//
// The field order is transcribed from the generated
// `~/git-repos/UHDM/build/generated/src/{task_func,function,scope,...}.cpp`
// Compare bodies (base class first, then the derived fields, in the order the
// `if ((r = …))` lines appear) — it is not the ctfields.inc order, which is the
// LADDER's field table and includes fields no Compare reads.
//
// build: g++ -O2 -std=c++17 ct185own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct185own
// usage: ct185own <golden.uhdm> <ours.uhdm> [--refs] [--chain=N]
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

// ---------------------------------------------------------------------------
// (A)(B)(C): task_func / function Compare order, transcribed from the
// generated sources.  `scope`/`instance` bases contribute nothing for a
// class method beyond BaseClass's VpiType+VpiName+VpiDefName, which the tool
// prints as the first three rows.
struct CmpField {
    const char* name;
    int sel;      // vpi selector for a relation; 0 for a property row
    FKind kind;
};
// task_func::Compare then function::Compare, in source order.
static const CmpField kTaskFuncOrder[] = {
    {"VpiType", 0, F_TYPE},
    {"VpiName", 0, F_PROP},
    {"VpiDefName", 0, F_PROP},
    {"VpiMethod", vpiMethod, F_PROP},
    {"VpiAccessType", vpiAccessType, F_PROP},
    {"VpiVisibility", vpiVisibility, F_PROP},
    {"VpiVirtual", vpiVirtual, F_PROP},
    {"VpiAutomatic", vpiAutomatic, F_PROP},
    {"VpiDPIPure", vpiDPIPure, F_PROP},
    {"VpiDPIContext", vpiDPIContext, F_PROP},
    {"VpiDPICStr", vpiDPICStr, F_PROP},
    {"VpiDPICIdentifier", vpiDPICIdentifier, F_PROP},
    {"Left_range", vpiLeftRange, F_REL1},
    {"Right_range", vpiRightRange, F_REL1},
    {"Return", vpiReturn, F_REL1},
    {"Class_defn", vpiClassDefn, F_REL1},
    {"Io_decls", vpiIODecl, F_RELV},
    {"Stmt", vpiStmt, F_REL1},
    {"Instance", vpiInstance, F_REL1},
    {"VpiSigned", vpiSigned, F_PROP},
    {"VpiSize", vpiSize, F_PROP},
    {"VpiFuncType", vpiFuncType, F_PROP},
};

static std::string propStr(const BaseClass* o, const CmpField& f) {
    if (!o) return "<no-owner>";
    if (!strcmp(f.name, "VpiType"))
        return std::string(UhdmName(o->UhdmType()));
    if (!strcmp(f.name, "VpiName")) return std::string(o->VpiName());
    if (!strcmp(f.name, "VpiDefName")) return std::string(o->VpiDefName());
    auto v = o->GetVpiPropertyValue(f.sel);
    if (v.index() == 0) return "<unset>";
    char b[128];
    if (const int64_t* i = std::get_if<int64_t>(&v)) {
        snprintf(b, sizeof b, "%lld", (long long)*i);
        return b;
    }
    if (const char* const* s2 = std::get_if<const char*>(&v))
        return *s2 ? std::string(*s2) : std::string("<null>");
    return "<?>";
}

// Replay the owner's compared fields, both sides, marking the first failure and
// the next two rows after it.
static void fieldTable(const char* tag, const BaseClass* L, const BaseClass* R,
                       const CmpField* order, size_t n) {
    printf("  %s FIELD TABLE (judge order, %s vs %s):\n", tag, ident(L).c_str(),
           ident(R).c_str());
    int failAt = -1;
    for (size_t i = 0; i < n; i++) {
        const CmpField& f = order[i];
        std::string ls, rs;
        bool eq = true;
        if (f.kind == F_PROP || f.kind == F_TYPE) {
            ls = propStr(L, f);
            rs = propStr(R, f);
            eq = (ls == rs);
        } else if (f.kind == F_REL1) {
            const BaseClass* a = L ? std::get<0>(L->GetByVpiType(f.sel)) : nullptr;
            const BaseClass* b = R ? std::get<0>(R->GetByVpiType(f.sel)) : nullptr;
            ls = ident(a);
            rs = ident(b);
            if (!a && !b)
                eq = true;
            else if (!a || !b)
                eq = false;
            else {
                CompareContext cc;
                eq = (a->Compare(b, &cc) == 0);
            }
        } else {
            std::vector<const BaseClass*> va, vb;
            if (L) relv(L, {f.name, f.sel, f.kind}, va);
            if (R) relv(R, {f.name, f.sel, f.kind}, vb);
            char b1[64], b2[64];
            snprintf(b1, sizeof b1, "<%zu elems>", va.size());
            snprintf(b2, sizeof b2, "<%zu elems>", vb.size());
            ls = b1;
            rs = b2;
            eq = va.size() == vb.size();
            if (eq)
                for (size_t k = 0; k < va.size(); k++) {
                    CompareContext cc;
                    if (va[k]->Compare(vb[k], &cc) != 0) { eq = false; break; }
                }
        }
        const char* mark = eq ? "  ok  " : "**FAIL";
        if (!eq && failAt < 0) failAt = (int)i;
        const char* tail = "";
        if (failAt >= 0 && (int)i == failAt + 1) tail = "   <- NEXT FIELD 1";
        if (failAt >= 0 && (int)i == failAt + 2) tail = "   <- NEXT FIELD 2";
        printf("    %s %-20s L=%-46s R=%s%s\n", mark, f.name, ls.c_str(),
               rs.c_str(), tail);
    }
    if (failAt < 0) printf("    (no field of this owner disagrees)\n");
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct185own <golden> <ours> [--refs] [--chain=N]\n");
        return 2;
    }
    bool refs = false;
    for (int i = 3; i < argc; i++)
        if (!strcmp(argv[i], "--refs")) refs = true;

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

    // (A)+(B)+(C): the OWNER PAIR and its whole compared-field table.
    const BaseClass* OL = HL ? HL->VpiParent() : nullptr;
    const BaseClass* OR = HR ? HR->VpiParent() : nullptr;
    if (OL && OR && OL->UhdmType() == OR->UhdmType() &&
        (OL->UhdmType() == uhdmfunction || OL->UhdmType() == uhdmtask)) {
        fieldTable("OWNER", OL, OR, kTaskFuncOrder,
                   sizeof kTaskFuncOrder / sizeof kTaskFuncOrder[0]);
    } else {
        printf("  OWNER PAIR is not a task_func pair: L=%s R=%s\n",
               ident(OL).c_str(), ident(OR).c_str());
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
    // ---- THE CHAIN (measurement only; masks cascade, RESUME.md §9) --------
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
    return 0;
}
