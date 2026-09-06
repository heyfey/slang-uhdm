// r10earl110 -- THE OWNER FINDER + FIELD BISECTOR for a hier_path head.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The brief handed this pass a "Path_elems SIZE mismatch" (buvm14's shape).
// This tool exists to CHECK that claim rather than carry it forward, exactly
// as r10buvm14 checked -- and refuted -- the framing IT was handed.
//
// It does three things:
//   (1) runs the OFFICIAL `design::Compare` (the same call uhdm-cmp makes) and
//       names the failed pair;
//   (2) when the pair is a hier_path pair, prints BOTH `Path_elems` lists IN
//       FULL with the COMPARE-VISIBLE payload of every element (kind, VpiName,
//       VpiDefName, and the per-kind fields the generated Compares read) --
//       never the span, never the fullname -- so "the size test fired" versus
//       "an element field fired" versus "a hier_path scalar fired" is READ,
//       not inferred;
//   (3) BISECTS the field by MASKING: it copies golden's `VpiName` onto our
//       head hier_path, re-runs a FRESH `design::Compare`, and prints the NEXT
//       head.  Repeating that walks the WHOLE reachable family and counts it.
//
// build:
//   g++ -O2 -std=c++17 own110.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own110
// usage:
//   own110 <golden.uhdm> <ours.uhdm> [maxIterations]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <string>
#include <variant>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[160];
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
// The COMPARE-VISIBLE payload only: BaseClass::Compare reads VpiType, VpiName
// and VpiDefName; expr adds VpiDecompile/VpiSize; constant adds VpiConstType;
// indexed_part_select adds VpiConstantSelect/VpiIndexedPartSelectType and its
// Base_expr/Width_expr; bit_select adds its VpiIndex.  NO span, NO fullname,
// NO parent -- no generated Compare reads any of those.
static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    s += " name='" + std::string(o->VpiName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += " dec='" + std::string(e->VpiDecompile()) + "'";
        if (e->VpiSize()) s += " size=" + std::to_string(e->VpiSize());
    }
    if (auto* c = any_cast<const constant*>(o))
        s += " ct=" + std::to_string(c->VpiConstType());
    if (auto* ips = any_cast<const indexed_part_select*>(o)) {
        s += " ipsType=" + std::to_string(ips->VpiIndexedPartSelectType());
        s += " constSel=" + std::to_string((int)ips->VpiConstantSelect());
        s += "\n         base: " + payload(ips->Base_expr());
        s += "\n         width: " + payload(ips->Width_expr());
    }
    if (auto* bs = any_cast<const bit_select*>(o))
        s += "\n         index: " + payload(bs->VpiIndex());
    if (auto* ps = any_cast<const part_select*>(o)) {
        s += "\n         left: " + payload(ps->Left_range());
        s += "\n         right: " + payload(ps->Right_range());
    }
    if (auto* r = any_cast<const ref_obj*>(o))
        s += " actual=" + kindOf(r->Actual_group()) +
             "('" + (r->Actual_group() ? std::string(r->Actual_group()->VpiName()) : "") + "')";
    return s;
}

static void dumpElems(const char* tag, const hier_path* hp) {
    if (!hp) { printf("  %s <null hier_path>\n", tag); return; }
    auto* pe = hp->Path_elems();
    printf("  %s hier_path VpiName='%s'  Path_elems=%zu  Root_value=%s  @%s\n",
           tag, std::string(hp->VpiName()).c_str(), pe ? pe->size() : 0,
           hp->Root_value() ? kindOf(hp->Root_value()).c_str() : "<null>",
           spanOf(hp).c_str());
    if (!pe) return;
    for (size_t i = 0; i < pe->size(); i++)
        printf("      [%zu] %s\n", i, payload(pe->at(i)).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: own110 <golden> <ours> [iters]\n"); return 2; }
    int maxIt = argc > 3 ? atoi(argv[3]) : 1;
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: load failed\n"); return 3; }
    if (hg.size() != ho.size()) { fprintf(stderr, "FATAL: design count %zu vs %zu\n", hg.size(), ho.size()); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    for (int it = 0; it < maxIt; it++) {
        CompareContext ctx;
        int r = dg->Compare(dd, &ctx);
        printf("== ITERATION %d : design::Compare -> %d\n", it, r);
        if (r == 0) { printf("   EQUAL -- no head.\n"); break; }
        const BaseClass* L = ctx.m_failedLhs;
        const BaseClass* R = ctx.m_failedRhs;
        printf("   HEAD LHS(golden) = %s id:%u  %s\n", kindOf(L).c_str(),
               L ? L->UhdmId() : 0, spanOf(L).c_str());
        printf("   HEAD RHS(ours)   = %s id:%u  %s\n", kindOf(R).c_str(),
               R ? R->UhdmId() : 0, spanOf(R).c_str());
        auto* hL = L ? any_cast<const hier_path*>(L) : nullptr;
        auto* hR = R ? any_cast<const hier_path*>(R) : nullptr;
        if (!hL || !hR) {
            printf("   NOT a hier_path pair -- the family is exhausted here.\n");
            if (L && R) { printf("   LHS payload: %s\n   RHS payload: %s\n",
                                 payload(L).c_str(), payload(R).c_str()); }
            break;
        }
        dumpElems("LHS(golden)", hL);
        dumpElems("RHS(ours)  ", hR);
        size_t nL = hL->Path_elems() ? hL->Path_elems()->size() : 0;
        size_t nR = hR->Path_elems() ? hR->Path_elems()->size() : 0;
        printf("   SIZE TEST: %zu vs %zu -> %s\n", nL, nR,
               nL == nR ? "EQUAL (the size arm did NOT fire)" : "MISMATCH (the size arm FIRED)");
        printf("   VPINAME  : golden='%s'\n              ours  ='%s'  -> %s\n",
               std::string(hL->VpiName()).c_str(), std::string(hR->VpiName()).c_str(),
               hL->VpiName() == hR->VpiName() ? "EQUAL" : "DIFFERS");
        if (hL->VpiName() == hR->VpiName()) {
            printf("   the VpiName is EQUAL -- the failure is NOT VpiName; stopping.\n");
            break;
        }
        // MASK: copy golden's name onto ours and re-run a FRESH Compare.
        ((hier_path*)hR)->VpiName(hL->VpiName());
        printf("   MASKED ours' VpiName := golden's; re-running.\n");
    }
    return 0;
}
