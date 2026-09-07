// r10earl117 -- THE JUDGE, DECODED FIRST.  Owner-finder + FIELD BISECTOR for a
// SELECT-BOUND head (golden a folded `constant`, ours a bound `ref_obj`), plus
// the LADDER behind it.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9 head-decode discipline: read the generated Compare ORDER
// before naming a field.  The two kinds that meet at this head compare as
//
//   constant::Compare                    ref_obj::Compare
//     -> expr::Compare                     -> expr::Compare
//          -> BaseClass::Compare                -> BaseClass::Compare
//               VpiType, VpiName, VpiDefName         VpiType, VpiName, VpiDefName
//          -> VpiDecompile                      -> VpiDecompile
//          -> VpiSize                           -> VpiSize
//          -> Typespec                          -> Typespec
//     -> VpiValue / VpiConstType           -> Actual_group, ...
//
// so a `constant` against a `ref_obj` fails at BaseClass::Compare's VERY FIRST
// field, VpiType, and every later field is unreachable.  This tool prints that
// arithmetic rather than asserting it, then reads the OWNER CHAIN, the owning
// select object, and the SIBLING operands of the owning assignment pattern.
//
// THE LADDER: after printing a head it MASKS it (it copies golden's failing
// object out of the way by making our side's object answer golden's fields for
// the compared fields it can) and re-runs the official design::Compare, so the
// NEXT object is named by measurement.  Masking reorders the walk (RESUME
// section 9's ladder law), so the count is a LOWER BOUND and the census, not
// this ladder, is the arbiter.
//
// build:
//   g++ -O2 -std=c++17 own117.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own117
// usage:
//   own117 <golden.uhdm> <ours.uhdm> [maxIterations]
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
        if (!e->VpiDecompile().empty())
            s += "[dec=" + std::string(e->VpiDecompile()) + "]";
        if (!e->VpiValue().empty())
            s += "[val=" + std::string(e->VpiValue()) + "]";
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
    if (auto* r = any_cast<const ref_obj*>(o))
        s += " actual=" + payloadShort(r->Actual_group());
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

static void bisect(const BaseClass* L, const BaseClass* R) {
    printf("   -- FIELD BISECTION (generated Compare order) --\n");
    printf("      BaseClass VpiType   : %d (%s) vs %d (%s) -> %d\n",
           (int)L->VpiType(), kindOf(L).c_str(), (int)R->VpiType(),
           kindOf(R).c_str(), (int)L->VpiType() - (int)R->VpiType());
    if (L->VpiType() != R->VpiType()) {
        printf("      *** the head is decided HERE; every later field is\n"
               "          unreachable (BaseClass::Compare returns on VpiType).\n");
    }
    printf("      BaseClass VpiName   : '%s' vs '%s' -> %d\n",
           std::string(L->VpiName()).c_str(), std::string(R->VpiName()).c_str(),
           std::string(L->VpiName()).compare(std::string(R->VpiName())));
    auto* le = any_cast<const expr*>(L);
    auto* re = any_cast<const expr*>(R);
    if (le && re) {
        printf("      expr VpiDecompile   : '%s' vs '%s'\n",
               std::string(le->VpiDecompile()).c_str(),
               std::string(re->VpiDecompile()).c_str());
        printf("      expr VpiSize        : %d vs %d -> %d\n", le->VpiSize(),
               re->VpiSize(), le->VpiSize() - re->VpiSize());
        printf("      expr Typespec       : %s vs %s\n",
               kindOf(le->Typespec()).c_str(), kindOf(re->Typespec()).c_str());
        printf("      expr VpiValue       : '%s' vs '%s'\n",
               std::string(le->VpiValue()).c_str(),
               std::string(re->VpiValue()).c_str());
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

// the SIBLINGS: walk up to the nearest assignment-pattern operation and print
// every operand's value (a tagged_pattern's Pattern, or the bare operand).
static void sibs(const char* tag, const BaseClass* o) {
    const BaseClass* p = o;
    for (int d = 0; d < 7 && p; d++) {
        if (auto* op = any_cast<const operation*>(p)) {
            if (op->VpiOpType() == vpiAssignmentPatternOp && op->Operands()) {
                printf("   %s pattern siblings (%zu operands of optype %d):\n",
                       tag, op->Operands()->size(), op->VpiOpType());
                for (auto* x : *op->Operands()) {
                    const BaseClass* v = x;
                    std::string key;
                    if (auto* tp = any_cast<const tagged_pattern*>(x)) {
                        v = tp->Pattern();
                        if (auto* rt = tp->Typespec())
                            if (auto* at = rt->Actual_typespec())
                                key = std::string(at->VpiName());
                    }
                    printf("      %-12s %s\n", key.c_str(),
                           payload(v).c_str());
                }
                return;
            }
        }
        p = p->VpiParent();
    }
    printf("   %s pattern siblings: no assignment-pattern owner within 7 hops\n",
           tag);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own117 <golden> <ours> [iters]\n");
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
        if (!L || !R) {
            printf("   ONE SIDE IS NULL -- read BaseClass.h SafeCompare before\n"
                   "   naming a field (RESUME section 9).\n");
            break;
        }
        bisect(L, R);
        chain("golden", L);
        chain("ours  ", R);
        sibs("GOLDEN", L);
        sibs("OURS  ", R);

        // THE LADDER STEP.  Make golden's head object answer OURS for the
        // fields BaseClass/expr::Compare reads, so the walk continues past it.
        // In-memory only; the databases on disk are untouched.
        if (L->UhdmType() == uhdmconstant && R->UhdmType() == uhdmref_obj) {
            // A kind mismatch cannot be masked field-wise.  Replace golden's
            // owner reference instead: if the owner is a bit_select, point its
            // VpiIndex at OUR ref_obj.
            auto* ob = L->VpiParent()
                           ? any_cast<const bit_select*>(L->VpiParent())
                           : nullptr;
            if (ob) {
                const_cast<bit_select*>(ob)->VpiIndex(
                    (expr*)const_cast<BaseClass*>(R));
                printf("   MASKED golden bit_select's VpiIndex := OURS;"
                       " re-running.\n");
                continue;
            }
            printf("   cannot mask: golden head's parent is %s, not a"
                   " bit_select.\n",
                   kindOf(L->VpiParent()).c_str());
            break;
        }
        // generic field mask for same-kind heads
        if (L->UhdmType() == R->UhdmType()) {
            if (auto* le = any_cast<const expr*>(L)) {
                auto* re = any_cast<const expr*>(R);
                const_cast<expr*>(le)->VpiDecompile(re->VpiDecompile());
                const_cast<expr*>(le)->VpiSize(re->VpiSize());
                const_cast<expr*>(le)->VpiValue(re->VpiValue());
                const_cast<expr*>(le)->Typespec(
                    const_cast<ref_typespec*>(re->Typespec()));
            }
            printf("   MASKED golden head's compared scalar fields := ours';"
                   " re-running.\n");
            continue;
        }
        printf("   head kinds %s vs %s -- no mask rule; stopping.\n",
               kindOf(L).c_str(), kindOf(R).c_str());
        break;
    }
    return 0;
}
