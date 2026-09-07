// r10earl113 -- THE JUDGE, DECODED FIRST.  Owner-finder + FIELD BISECTOR for
// the assignment-pattern FIRST-OPERAND head.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9 head-decode discipline: read the generated Compare ORDER
// before naming a field.  For any `expr` the order is
//
//   <kind>::Compare
//     -> expr::Compare
//          -> BaseClass::Compare  (VpiType, VpiName, VpiDefName)
//          -> VpiDecompile        (string compare)
//          -> VpiSize             (int subtraction)      <-- THIS PASS
//          -> Typespec            (SafeCompare, singular)
//     -> the kind's own fields
//
// This tool prints EVERY one of those with its own result, so "the failing
// field is VpiSize NOW" is measured on the pass's own pristine databases and
// never inherited from a previous pass's write-up.  It then prints
//
//   * the OWNER CHAIN above the head (parent, grandparent, ...) -- the carrier
//     and the scope, read and not guessed;
//   * EVERY SIBLING OPERAND of the owning operation on BOTH sides with its
//     kind and its VpiSize, which is the question "is it only operand 0?";
//   * for a hier_path head, both Path_elems lists;
//
// and finally MASKS VpiSize on the golden copy in memory and re-runs the
// OFFICIAL design::Compare, so the NEXT field in line (the ladder) is read
// rather than predicted.  The databases on disk are never written.
//
// build:
//   g++ -O2 -std=c++17 own113.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own113
// usage:
//   own113 <golden.uhdm> <ours.uhdm> [maxIterations]
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

static std::string payloadShort(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += "('" + std::string(o->VpiName()) + "')";
    if (auto* e = any_cast<const expr*>(o)) {
        s += "[sz=" + std::to_string(e->VpiSize()) + "]";
        if (!e->VpiDecompile().empty())
            s += "[dec=" + std::string(e->VpiDecompile()) + "]";
        if (!e->VpiValue().empty())
            s += "[val=" + std::string(e->VpiValue()) + "]";
        s += "[ts=" + kindOf(e->Typespec());
        if (auto* rt = e->Typespec())
            s += "->" + kindOf(rt->Actual_typespec());
        s += "]";
    }
    return s;
}

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
    s += "  @" + spanOf(o);
    return s;
}

static void bisect(const BaseClass* L, const BaseClass* R) {
    printf("   -- FIELD BISECTION (generated Compare order) --\n");
    printf("      BaseClass VpiType   : %d vs %d -> %d\n", (int)L->VpiType(),
           (int)R->VpiType(), (int)L->VpiType() - (int)R->VpiType());
    printf("      BaseClass VpiName   : '%s' vs '%s' -> %d\n",
           std::string(L->VpiName()).c_str(), std::string(R->VpiName()).c_str(),
           std::string(L->VpiName()).compare(std::string(R->VpiName())));
    printf("      BaseClass VpiDefName: '%s' vs '%s' -> %d\n",
           std::string(L->VpiDefName()).c_str(),
           std::string(R->VpiDefName()).c_str(),
           std::string(L->VpiDefName()).compare(std::string(R->VpiDefName())));
    auto* el = any_cast<const expr*>(L);
    auto* er = any_cast<const expr*>(R);
    if (el && er) {
        printf("      expr VpiDecompile   : '%s' vs '%s' -> %d\n",
               std::string(el->VpiDecompile()).c_str(),
               std::string(er->VpiDecompile()).c_str(),
               std::string(el->VpiDecompile())
                   .compare(std::string(er->VpiDecompile())));
        printf("      expr VpiSize        : %d vs %d -> %d\n", el->VpiSize(),
               er->VpiSize(), el->VpiSize() - er->VpiSize());
        printf("      expr Typespec       : %s vs %s\n",
               payloadShort(el->Typespec()).c_str(),
               payloadShort(er->Typespec()).c_str());
        if (el->Typespec() && er->Typespec())
            printf("        actual            : %s vs %s\n",
                   kindOf(el->Typespec()->Actual_typespec()).c_str(),
                   kindOf(er->Typespec()->Actual_typespec()).c_str());
    }
    auto* hl = any_cast<const hier_path*>(L);
    auto* hr = any_cast<const hier_path*>(R);
    if (hl && hr) {
        printf("      hier_path Path_elems: %zu vs %zu\n",
               hl->Path_elems() ? hl->Path_elems()->size() : 0,
               hr->Path_elems() ? hr->Path_elems()->size() : 0);
        printf("      hier_path Root_value: %s vs %s\n",
               kindOf(hl->Root_value()).c_str(),
               kindOf(hr->Root_value()).c_str());
    }
}

static void chain(const char* tag, const BaseClass* o) {
    printf("   -- OWNER CHAIN (%s) --\n", tag);
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    for (int d = 0; d < 7 && p; d++) {
        printf("     %*s|vpiParent -> %s\n", d * 2, "", payload(p).c_str());
        p = p->VpiParent();
    }
}

// EVERY sibling operand of the owning operation, both sides, with its size --
// the answer to "is the law one cell or the whole operand list?".
static void sibs(const char* tag, const BaseClass* h) {
    const BaseClass* par = h ? h->VpiParent() : nullptr;
    auto* op = par ? any_cast<const operation*>(par) : nullptr;
    if (!op || !op->Operands()) {
        printf("   %s siblings: owner is not an operation (%s)\n", tag,
               kindOf(par).c_str());
        return;
    }
    printf("   %s siblings (%zu operands of optype %d, op size=%d):\n", tag,
           op->Operands()->size(), op->VpiOpType(), op->VpiSize());
    size_t i = 0;
    for (auto* o : *op->Operands()) {
        const BaseClass* v = o;
        if (auto* tp = any_cast<const tagged_pattern*>(o)) v = tp->Pattern();
        printf("      [%zu] %s%s\n", i++, payloadShort(v).c_str(),
               v == h ? "   <-- THE HEAD" : "");
    }
}

static void elems(const char* tag, const BaseClass* o) {
    auto* hp = any_cast<const hier_path*>(o);
    if (!hp) return;
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

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own113 <golden> <ours> [iters]\n");
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
        if (!L || !R || L->UhdmType() != R->UhdmType()) {
            printf("   KIND MISMATCH or null side -- stop.\n");
            break;
        }
        bisect(L, R);
        elems("GOLDEN", L);
        elems("OURS  ", R);
        chain("golden", L);
        chain("ours", R);
        sibs("GOLDEN", L);
        sibs("OURS  ", R);

        // MASK the head's expr fields (in memory only) so the NEXT field in
        // line becomes visible: the ladder is READ, never predicted.
        auto* el = any_cast<const expr*>(L);
        auto* er = any_cast<const expr*>(R);
        if (el && er) {
            const_cast<expr*>(el)->VpiSize(er->VpiSize());
            const_cast<expr*>(el)->VpiDecompile(er->VpiDecompile());
            const_cast<expr*>(el)->Typespec(
                const_cast<ref_typespec*>(er->Typespec()));
            printf("   MASKED golden head's VpiDecompile/VpiSize/"
                   "Typespec := ours'; re-running.\n");
        } else {
            printf("   head is not an expr -- cannot mask; stop.\n");
            break;
        }
    }
    return 0;
}
