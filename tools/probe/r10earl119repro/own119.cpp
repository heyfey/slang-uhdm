// r10earl119 -- THE JUDGE, DECODED FIRST.  Owner-finder / FIELD BISECTOR for a
// VALUE head (both sides present, different KINDS), plus the SIBLING CENSUS of
// every gen-scope cast continuous assign in the two databases and a small
// MASK-AND-RERUN ladder around the OFFICIAL `design::Compare`.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9's head-decode discipline: read the owning kind's
// GENERATED Compare order BEFORE naming a field.  For this head the owner is a
// `cont_assign`, whose generated order
// (~/git-repos/UHDM/build/generated/src/cont_assign.cpp:99-127) is
//
//     VpiNetDeclAssign, VpiStrength0, VpiStrength1,
//     Delay, ==> Rhs <==, Lhs, Cont_assign_bits
//
// -- the Rhs is read BEFORE the Lhs, which is why an Rhs difference hides
// whatever the target reference is doing.  `constant::Compare`
// (constant.cpp:58-72) reads VpiConstType after `expr`'s own VpiDecompile /
// VpiSize / VpiValue, and NONE of the generated Compares reads VpiFile, line,
// column or VpiParent -- so this tool prints the location columns separately
// and never mixes them into the verdict.
//
// build:
//   g++ -O2 -std=c++17 own119.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own119
// usage:
//   own119 <golden.uhdm> <ours.uhdm> [rungs]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[320];
    std::string f(o->VpiFile());
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    snprintf(b, sizeof b, "%s %u:%u-%u:%u", f.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += " name='" + std::string(o->VpiName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
        s += " ts=" + kindOf(e->Typespec());
        if (auto* rt = e->Typespec())
            s += "->" + kindOf(rt->Actual_typespec());
    }
    if (auto* c = any_cast<const constant*>(o)) {
        s += " val='" + std::string(c->VpiValue()) + "'";
        s += " ctype=" + std::to_string(c->VpiConstType());
    }
    if (auto* r = any_cast<const ref_obj*>(o))
        s += " actual=" + kindOf(r->Actual_group());
    if (auto* op = any_cast<const operation*>(o)) {
        s += " optype=" + std::to_string(op->VpiOpType());
        if (op->Operands() && !op->Operands()->empty())
            s += " operand0=" + kindOf(op->Operands()->at(0));
    }
    s += "  @" + spanOf(o);
    return s;
}
static std::string fullOf(const BaseClass* o) {
    if (!o) return "<null>";
    if (auto* s = any_cast<const scope*>(o))
        if (!s->VpiFullName().empty()) return std::string(s->VpiFullName());
    std::string s;
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        std::string n(p->VpiName());
        if (n.empty()) continue;
        s = s.empty() ? n : n + "." + s;
    }
    return s;
}
static void chain(const char* tag, const BaseClass* o) {
    printf("   -- OWNER CHAIN (%s) --\n", tag);
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    for (int d = 0; d < 8 && p; d++) {
        printf("     %*s|vpiParent -> %s\n", d * 2, "", payload(p).c_str());
        p = p->VpiParent();
    }
}

// ------------------------------------------------------------------ siblings
// EVERY gen-scope continuous assign whose Rhs is a cast operation OR a folded
// constant, on BOTH sides, keyed by the cont_assign's span so the two lists
// can be read against each other.  This is the family the head belongs to.
struct Sib {
    std::string scope, lhs, rhs, loc;
    const cont_assign* ca = nullptr;
};

// COMPARE-VISIBLE payload only: no VpiFile, no line, no column, no
// VpiParent -- none of the generated `Compare`s read them (RESUME.md section
// 9), and OUR objects carry an EMPTY VpiFile, so putting a span in the sibling
// key would print every cell as a difference and hide the real ones.
static std::string visPayload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (auto* e = any_cast<const expr*>(o)) {
        s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
    }
    if (auto* c = any_cast<const constant*>(o)) {
        s += " val='" + std::string(c->VpiValue()) + "'";
        s += " ctype=" + std::to_string(c->VpiConstType());
    }
    if (auto* op = any_cast<const operation*>(o)) {
        s += " optype=" + std::to_string(op->VpiOpType());
        if (op->Operands() && !op->Operands()->empty())
            s += " operand0=" + visPayload(op->Operands()->at(0));
    }
    return s;
}
static std::map<std::string, Sib> sibs;
static std::set<const BaseClass*> seen;

static void collect(const BaseClass* s, const std::string& home, int gendepth);

static void collectGsa(VectorOfgen_scope_array* gsa, const std::string& home,
                       int gendepth) {
    if (!gsa) return;
    for (auto* a : *gsa)
        if (a && a->Gen_scopes())
            for (auto* g : *a->Gen_scopes()) collect(g, home, gendepth + 1);
}

static void collect(const BaseClass* s, const std::string& home, int gendepth) {
    if (!s || !seen.insert(s).second) return;
    VectorOfcont_assign* cas = nullptr;
    VectorOfgen_scope_array* gsas = nullptr;
    VectorOfmodule_inst* mods = nullptr;
    VectorOfinterface_inst* ifs = nullptr;
    std::string h = home;
    bool isGen = false;
    if (auto* m = any_cast<const module_inst*>(s)) {
        cas = m->Cont_assigns();
        gsas = m->Gen_scope_arrays();
        mods = m->Modules();
        ifs = m->Interfaces();
        h = std::string(m->VpiFullName());
    } else if (auto* g = any_cast<const gen_scope*>(s)) {
        cas = g->Cont_assigns();
        gsas = g->Gen_scope_arrays();
        mods = g->Modules();
        ifs = g->Interfaces();
        h = std::string(g->VpiFullName());
        isGen = true;
    } else if (auto* i = any_cast<const interface_inst*>(s)) {
        cas = i->Cont_assigns();
        gsas = i->Gen_scope_arrays();
        h = std::string(i->VpiFullName());
    } else {
        return;
    }
    if (isGen && cas)
        for (auto* c : *cas) {
            const any* r = c->Rhs();
            bool cast = false;
            if (auto* op = any_cast<const operation*>(r))
                cast = op->VpiOpType() == vpiCastOp;
            bool folded = r && r->UhdmType() == uhdmconstant;
            if (!cast && !folded) continue;
            char k[512];
            snprintf(k, sizeof k, "%s|%s|%u:%u", h.c_str(),
                     c->Lhs() ? std::string(c->Lhs()->VpiName()).c_str() : "-",
                     c->VpiLineNo(), (unsigned)c->VpiColumnNo());
            sibs[k] = Sib{h,
                          c->Lhs() ? std::string(c->Lhs()->VpiName())
                                   : std::string("-"),
                          visPayload(r), spanOf(c), c};
        }
    collectGsa(gsas, h, gendepth);
    if (mods)
        for (auto* m : *mods) collect(m, h, gendepth);
    if (ifs)
        for (auto* i : *ifs) collect(i, h, gendepth);
}

static std::map<std::string, Sib> sibsOf(const design* d) {
    sibs.clear();
    seen.clear();
    if (d->TopModules())
        for (auto* m : *d->TopModules()) collect(m, "", 0);
    return sibs;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own119 <golden> <ours> [rungs]\n");
        return 2;
    }
    int rungs = argc > 3 ? atoi(argv[3]) : 6;
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    // ---------------------------------------------------------------- head
    CompareContext ctx;
    int r = dg->Compare(dd, &ctx);
    const BaseClass* L = ctx.m_failedLhs;
    const BaseClass* R = ctx.m_failedRhs;
    printf("== design::Compare -> %d\n", r);
    printf("   HEAD LHS(golden) = %s\n", payload(L).c_str());
    printf("   HEAD RHS(ours)   = %s\n", payload(R).c_str());
    printf("        ours full  : %s\n", fullOf(R).c_str());
    printf("   BOTH SIDES PRESENT: %s  (a VALUE head, not a null one --\n"
           "   BaseClass.h's SINGULAR overload would have left one side unset)\n",
           (L && R) ? "yes" : "NO");
    chain("golden", L);
    chain("ours  ", R);

    // ------------------------------------------------------- the SIBLINGS
    auto gs = sibsOf(dg);
    auto os = sibsOf(dd);
    std::set<std::string> keys;
    for (auto& kv : gs) keys.insert(kv.first);
    for (auto& kv : os) keys.insert(kv.first);
    int same = 0, diff = 0, onlyg = 0, onlyo = 0;
    printf("== SIBLING CAST/FOLD CELLS in gen scopes (golden %zu, ours %zu)\n",
           gs.size(), os.size());
    for (const auto& k : keys) {
        auto ig = gs.find(k), io = os.find(k);
        if (ig == gs.end()) { onlyo++; continue; }
        if (io == os.end()) { onlyg++; continue; }
        if (ig->second.rhs == io->second.rhs) { same++; continue; }
        diff++;
        if (diff <= 40) {
            printf("   DIFF %s\n", k.c_str());
            printf("        golden %s\n", ig->second.rhs.c_str());
            printf("        ours   %s\n", io->second.rhs.c_str());
        }
    }
    printf("   SIBLINGS same=%d diff=%d only-golden=%d only-ours=%d\n", same,
           diff, onlyg, onlyo);

    // -------------------------------------------------- the FAILING FIELD
    // Re-run the owning cont_assign's generated Compare order, field by
    // field, each with a FRESH context, so the first failing field is
    // MEASURED and not inferred from the print.
    // GOLDEN'S FOLDED CONSTANT IS PARENTLESS (measured: Surelog's
    // `writeCont_assign` does a bare `assign->Rhs(rhstmp)` and never stamps a
    // parent, UhdmWriter.cpp:2159), so the golden owner cannot be reached by
    // walking up from the head -- it is found by SCOPE FULLNAME + SPAN below.
    const cont_assign* Ra =
        R ? any_cast<const cont_assign*>(R->VpiParent()) : nullptr;
    if (!Ra && R) Ra = any_cast<const cont_assign*>(R);
    // GOLDEN'S FOLDED CONSTANT IS PARENTLESS -- measured, and it is Surelog's
    // own doing: the bound-Lhs leg of `writeCont_assign` (UhdmWriter.cpp:2159)
    // does a bare `assign->Rhs(rhstmp)` and never stamps a parent.  So the
    // golden owner is found through the SIBLING MAP (scope fullname + Lhs name
    // + span), not by walking up from the head.
    const cont_assign* La = nullptr;
    if (Ra) {
        const BaseClass* sc = Ra->VpiParent();
        char k[512];
        snprintf(k, sizeof k, "%s|%s|%u:%u",
                 sc ? fullOf(sc).c_str() : "-",
                 Ra->Lhs() ? std::string(Ra->Lhs()->VpiName()).c_str() : "-",
                 Ra->VpiLineNo(), (unsigned)Ra->VpiColumnNo());
        auto it = gs.find(k);
        printf("== GOLDEN OWNER LOOKUP key='%s' -> %s\n", k,
               it == gs.end() ? "NOT FOUND" : "found");
        if (it != gs.end()) La = it->second.ca;
    }
    printf("== OWNER cont_assign  golden=%s  ours=%s\n",
           La ? spanOf(La).c_str() : "<none>",
           Ra ? spanOf(Ra).c_str() : "<none>");
    if (La && Ra) {
        printf("   -- cont_assign::Compare FIELD ORDER (fresh context each) --\n");
        {
            CompareContext c;
            int32_t rr = La->Rhs() && Ra->Rhs()
                             ? La->Rhs()->Compare(Ra->Rhs(), &c)
                             : (La->Rhs() == Ra->Rhs() ? 0 : 1);
            printf("      %-14s golden=%-12s ours=%-12s -> %d%s\n", "Rhs",
                   kindOf(La->Rhs()).c_str(), kindOf(Ra->Rhs()).c_str(), rr,
                   rr ? "   <== FAILS (compared BEFORE Lhs)" : "");
            printf("         golden Rhs: %s\n", payload(La->Rhs()).c_str());
            printf("         ours   Rhs: %s\n", payload(Ra->Rhs()).c_str());
        }
        {
            CompareContext c;
            int32_t rr = La->Lhs() && Ra->Lhs()
                             ? La->Lhs()->Compare(Ra->Lhs(), &c)
                             : (La->Lhs() == Ra->Lhs() ? 0 : 1);
            printf("      %-14s golden=%-12s ours=%-12s -> %d\n", "Lhs",
                   kindOf(La->Lhs()).c_str(), kindOf(Ra->Lhs()).c_str(), rr);
            printf("         golden Lhs: %s\n", payload(La->Lhs()).c_str());
            printf("         ours   Lhs: %s\n", payload(Ra->Lhs()).c_str());
            if (auto* lr = any_cast<const ref_obj*>(La->Lhs()))
                printf("         golden Lhs.Actual_group: %s\n",
                       payload(lr->Actual_group()).c_str());
            if (auto* rr2 = any_cast<const ref_obj*>(Ra->Lhs()))
                printf("         ours   Lhs.Actual_group: %s\n",
                       payload(rr2->Actual_group()).c_str());
        }
    }

    // ----------------------------------------------------------- the LADDER
    // MASK AND RERUN around the OFFICIAL Compare: seed the previous heads into
    // a fresh context's m_visited and re-run.  Counts are LOWER BOUNDS (masks
    // cascade -- RESUME.md section 9); this is a shape probe, never a judge.
    printf("== LADDER (mask-and-rerun, %d rungs max)\n", rungs);
    std::set<const BaseClass*> mask;
    for (int i = 0; i < rungs; i++) {
        CompareContext c;
        for (auto* m : mask) c.m_visited.insert(m);
        int rr = dg->Compare(dd, &c);
        if (rr == 0) {
            printf("   rung %d: EQUAL under the mask\n", i);
            break;
        }
        printf("   rung %d: LHS %s\n", i, payload(c.m_failedLhs).c_str());
        printf("           RHS %s\n", payload(c.m_failedRhs).c_str());
        if (!c.m_failedLhs && !c.m_failedRhs) break;
        if (c.m_failedLhs) mask.insert(c.m_failedLhs);
        if (c.m_failedRhs) mask.insert(c.m_failedRhs);
    }
    return 0;
}
