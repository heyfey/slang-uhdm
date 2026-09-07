// r10earl112 -- THE JUDGE, DECODED FIRST.  Owner-finder + FIELD BISECTOR for a
// `hier_path` head whose two sides differ in more than one place.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9 head-decode discipline: read the generated Compare ORDER
// before naming a field.  For a `hier_path` that order is
//
//   hier_path::Compare
//     -> expr::Compare
//          -> BaseClass::Compare  (VpiType, VpiName, VpiDefName)
//          -> VpiDecompile        (string compare)
//          -> VpiSize             (int subtraction)
//          -> Typespec            (SafeCompare, singular)
//     -> Path_elems               (SafeCompare, vector)
//     -> Root_value               (SafeCompare, singular)
//     -> VpiName                  (string compare)
//
// BaseClass::Compare reads VpiName FIRST (uhdm's BaseClass.cpp), so on a
// hier_path pair whose VpiName differs the head is decided THERE and the later
// hier_path::VpiName line is never reached.  This tool prints each field's own
// comparison result so the claim "the failing field is X" is measured and not
// inherited from a previous pass's write-up.
//
// It also prints:
//   * the OWNER CHAIN above the head (parent, grandparent, ...) so the
//     rendering CONTEXT is read and not guessed;
//   * every Path_elems entry of both sides with the fields their Compares read;
//   * the SIBLINGS -- the other operands of the owning operation -- so the
//     "do the sibling paths agree?" question is answered by measurement.
//
// build:
//   g++ -O2 -std=c++17 own112.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own112
// usage:
//   own112 <golden.uhdm> <ours.uhdm> [maxIterations]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[256];
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

static std::string payloadShort(const BaseClass* o);

static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    s += " name='" + std::string(o->VpiName()) + "'";
    if (!o->VpiDefName().empty())
        s += " dn='" + std::string(o->VpiDefName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
        if (!e->VpiValue().empty())
            s += " value='" + std::string(e->VpiValue()) + "'";
        s += " ts=" + kindOf(e->Typespec());
        if (auto* rt = e->Typespec())
            s += "->" + kindOf(rt->Actual_typespec());
    }
    if (auto* c = any_cast<const constant*>(o))
        s += " ct=" + std::to_string(c->VpiConstType());
    if (auto* op = any_cast<const operation*>(o)) {
        s += " optype=" + std::to_string(op->VpiOpType());
        s += " ops=" +
             std::to_string(op->Operands() ? op->Operands()->size() : 0);
    }
    if (auto* bs = any_cast<const bit_select*>(o))
        s += " index=" + payloadShort(bs->VpiIndex());
    s += "  @" + spanOf(o);
    return s;
}

// the shorter, non-recursive form the bit_select row above uses
static std::string payloadShort(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += "('" + std::string(o->VpiName()) + "')";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += "[dec=" + std::string(e->VpiDecompile()) + "]";
        if (!e->VpiValue().empty())
            s += "[val=" + std::string(e->VpiValue()) + "]";
    }
    return s;
}

static void dumpElems(const char* tag, const hier_path* hp) {
    printf("   %s Path_elems (%zu):\n", tag,
           hp->Path_elems() ? hp->Path_elems()->size() : 0);
    if (!hp->Path_elems()) return;
    size_t i = 0;
    for (auto* e : *hp->Path_elems()) {
        printf("     [%zu] %s\n", i++, payload(e).c_str());
        if (auto* bs = any_cast<const bit_select*>(e))
            printf("          |vpiIndex -> %s\n",
                   payload(bs->VpiIndex()).c_str());
        if (auto* ro = any_cast<const ref_obj*>(e))
            printf("          |vpiActual -> %s\n",
                   payloadShort(ro->Actual_group()).c_str());
    }
}

// The field bisector, in the generated order, each result printed.
static void bisect(const hier_path* L, const hier_path* R) {
    printf("   -- FIELD BISECTION (generated Compare order) --\n");
    printf("      BaseClass VpiType   : %d vs %d -> %d\n", (int)L->VpiType(),
           (int)R->VpiType(), (int)L->VpiType() - (int)R->VpiType());
    int rn = std::string(L->VpiName()).compare(std::string(R->VpiName()));
    printf("      BaseClass VpiName   : '%s' vs '%s' -> %d\n",
           std::string(L->VpiName()).c_str(), std::string(R->VpiName()).c_str(),
           rn);
    printf("      BaseClass VpiDefName: '%s' vs '%s'\n",
           std::string(L->VpiDefName()).c_str(),
           std::string(R->VpiDefName()).c_str());
    printf("      expr VpiDecompile   : '%s' vs '%s' -> %d\n",
           std::string(L->VpiDecompile()).c_str(),
           std::string(R->VpiDecompile()).c_str(),
           std::string(L->VpiDecompile()).compare(
               std::string(R->VpiDecompile())));
    printf("      expr VpiSize        : %d vs %d -> %d\n", L->VpiSize(),
           R->VpiSize(), L->VpiSize() - R->VpiSize());
    printf("      expr Typespec       : %s vs %s\n",
           kindOf(L->Typespec()).c_str(), kindOf(R->Typespec()).c_str());
    printf("      hier_path Path_elems: %zu vs %zu\n",
           L->Path_elems() ? L->Path_elems()->size() : 0,
           R->Path_elems() ? R->Path_elems()->size() : 0);
    printf("      hier_path Root_value: %s vs %s\n",
           kindOf(L->Root_value()).c_str(), kindOf(R->Root_value()).c_str());
    printf("      NOTE: BaseClass::Compare reads VpiName BEFORE any expr field,\n"
           "            so a differing VpiName decides the head first.\n");
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own112 <golden> <ours> [iters]\n");
        return 2;
    }
    int maxIt = argc > 3 ? atoi(argv[3]) : 1;
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    for (int it = 0; it < maxIt; it++) {
        CompareContext ctx;
        int r = dg->Compare(dd, &ctx);
        printf("== ITERATION %d : design::Compare -> %d\n", it, r);
        if (r == 0) {
            printf("   EQUAL -- no head.\n");
            break;
        }
        const BaseClass* L = ctx.m_failedLhs;
        const BaseClass* R = ctx.m_failedRhs;
        printf("   HEAD LHS(golden) = %s id:%u  %s\n", kindOf(L).c_str(),
               L ? L->UhdmId() : 0, spanOf(L).c_str());
        printf("        payload: %s\n", payload(L).c_str());
        printf("   HEAD RHS(ours)   = %s id:%u  %s\n", kindOf(R).c_str(),
               R ? R->UhdmId() : 0, spanOf(R).c_str());
        printf("        payload: %s\n", payload(R).c_str());

        auto* hl = L ? any_cast<const hier_path*>(L) : nullptr;
        auto* hr = R ? any_cast<const hier_path*>(R) : nullptr;
        if (!hl || !hr) {
            printf("   NOT a hier_path/hier_path head -- family exhausted.\n");
            break;
        }
        bisect(hl, hr);
        dumpElems("GOLDEN", hl);
        dumpElems("OURS  ", hr);

        // THE OWNER CHAIN -- read, not guessed.
        printf("   -- OWNER CHAIN (golden) --\n");
        const BaseClass* p = hl->VpiParent();
        for (int d = 0; d < 6 && p; d++) {
            printf("     %*s|vpiParent -> %s\n", d * 2, "",
                   payload(p).c_str());
            p = p->VpiParent();
        }
        printf("   -- OWNER CHAIN (ours) --\n");
        p = hr->VpiParent();
        for (int d = 0; d < 6 && p; d++) {
            printf("     %*s|vpiParent -> %s\n", d * 2, "",
                   payload(p).c_str());
            p = p->VpiParent();
        }
        // THE SIBLINGS -- the other operands of the owning operation.
        auto sibs = [](const char* tag, const hier_path* h) {
            auto* op = h->VpiParent()
                           ? any_cast<const operation*>(h->VpiParent())
                           : nullptr;
            if (!op || !op->Operands()) {
                printf("   %s siblings: owner is not an operation\n", tag);
                return;
            }
            printf("   %s siblings (%zu operands of optype %d):\n", tag,
                   op->Operands()->size(), op->VpiOpType());
            for (auto* o : *op->Operands()) {
                const BaseClass* v = o;
                if (auto* tp = any_cast<const tagged_pattern*>(o))
                    v = tp->Pattern();
                printf("      %s\n", payloadShort(v).c_str());
            }
        };
        sibs("GOLDEN", hl);
        sibs("OURS  ", hr);

        // MASK the head's NAME pair so the next family becomes visible:
        // set golden's VpiName to ours' and re-run (measurement only, on a
        // restored in-memory copy -- the databases on disk are untouched).
        const_cast<hier_path*>(hl)->VpiName(hr->VpiName());
        const_cast<hier_path*>(hl)->VpiSize(hr->VpiSize());
        const_cast<hier_path*>(hl)->Typespec(
            const_cast<ref_typespec*>(hr->Typespec()));
        printf("   MASKED golden head's VpiName/VpiSize/Typespec := ours';"
               " re-running.\n");
    }
    return 0;
}
