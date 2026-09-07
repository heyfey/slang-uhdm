// r10earl114 -- THE JUDGE, DECODED FIRST.  Owner-finder + FIELD BISECTOR +
// TYPESPEC-IDENTITY / SHARER finder for the pattern-carried `hier_path`
// TYPESPEC EDGE.
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
//          -> VpiSize             (int subtraction)     <- earl113 closed this
//          -> Typespec            (SafeCompare singular) <-- THIS PASS
//     -> Path_elems               (SafeCompare vector)
//     -> Root_value               (SafeCompare singular)
//     -> VpiName                  (string compare)
//
// and `ref_typespec::Compare` itself reads VpiName, VpiDefName and
// Actual_typespec -- NOT VpiFullName.  This tool prints all of that with each
// field's own result, and then answers THIS pass's three questions:
//
//   (1) IDENTITY -- is the typespec golden hangs on the path the SAME OBJECT
//       as the one hanging on the path's ROOT (Root_value), or a minted copy?
//       Printed as UhdmId equality of both the ref_typespec and its
//       Actual_typespec, on BOTH sides.
//   (2) SHARERS -- how many OTHER objects in the whole database point their
//       ref_typespec at the same Actual_typespec, and how many ref_typespec
//       objects point at it: the answer to "shared root typespec vs minted".
//   (3) THE LADDER -- after masking VpiDecompile/VpiSize/Typespec on the
//       golden copy IN MEMORY, the official design::Compare is re-run so the
//       NEXT field (the Path_elems element actual) is READ, never predicted.
//
// The databases on disk are never written.
//
// build:
//   g++ -O2 -std=c++17 own114.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own114
// usage:
//   own114 <golden.uhdm> <ours.uhdm> [maxIterations]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
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

static std::string tsEdge(const expr* e) {
    if (!e) return "<null>";
    auto* rt = e->Typespec();
    if (!rt) return "<null>";
    std::string s = "ref_typespec(id:" + std::to_string(rt->UhdmId());
    s += ",name='" + std::string(rt->VpiName()) + "'";
    s += ",dn='" + std::string(rt->VpiDefName()) + "'";
    s += ",full='" + std::string(rt->VpiFullName()) + "')";
    auto* a = rt->Actual_typespec();
    s += "->" + kindOf(a);
    if (a) {
        s += "(id:" + std::to_string(a->UhdmId());
        s += ",name='" + std::string(a->VpiName()) + "')";
    }
    return s;
}

static std::string payloadShort(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += "('" + std::string(o->VpiName()) + "')";
    if (auto* e = any_cast<const expr*>(o)) {
        s += "[sz=" + std::to_string(e->VpiSize()) + "]";
        if (!e->VpiDecompile().empty())
            s += "[dec=" + std::string(e->VpiDecompile()) + "]";
        s += "[ts=" + tsEdge(e) + "]";
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
        s += " ts=" + tsEdge(e);
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
        printf("      expr Typespec       : %s\n            vs %s\n",
               tsEdge(el).c_str(), tsEdge(er).c_str());
        // ref_typespec::Compare's OWN order, spelled out.
        auto* rl = el->Typespec();
        auto* rr = er->Typespec();
        if (rl && rr) {
            printf("        ref_typespec VpiName    : '%s' vs '%s' -> %d\n",
                   std::string(rl->VpiName()).c_str(),
                   std::string(rr->VpiName()).c_str(),
                   std::string(rl->VpiName())
                       .compare(std::string(rr->VpiName())));
            printf("        ref_typespec VpiDefName : '%s' vs '%s' -> %d\n",
                   std::string(rl->VpiDefName()).c_str(),
                   std::string(rr->VpiDefName()).c_str(),
                   std::string(rl->VpiDefName())
                       .compare(std::string(rr->VpiDefName())));
            printf("        Actual_typespec         : %s vs %s\n",
                   kindOf(rl->Actual_typespec()).c_str(),
                   kindOf(rr->Actual_typespec()).c_str());
        } else {
            printf("        ONE SIDE IS NULL -> SafeCompare singular names the "
                   "VALUE with the other side <null>\n");
        }
    }
    auto* hl = any_cast<const hier_path*>(L);
    auto* hr = any_cast<const hier_path*>(R);
    if (hl && hr) {
        printf("      hier_path Path_elems: %zu vs %zu\n",
               hl->Path_elems() ? hl->Path_elems()->size() : 0,
               hr->Path_elems() ? hr->Path_elems()->size() : 0);
        printf("      hier_path Root_value: %s\n            vs %s\n",
               payloadShort(hl->Root_value()).c_str(),
               payloadShort(hr->Root_value()).c_str());
    }
}

// (1) IDENTITY.  Is the path's typespec the ROOT's typespec, object for object?
static void identity(const char* tag, const BaseClass* o) {
    auto* hp = any_cast<const hier_path*>(o);
    if (!hp) return;
    auto* rv = hp->Root_value();
    auto* rvx = rv ? any_cast<const expr*>(rv) : nullptr;
    printf("   %s IDENTITY:\n", tag);
    printf("     path      Typespec = %s\n", tsEdge(any_cast<const expr*>(o)).c_str());
    printf("     Root_value          = %s id:%u\n", kindOf(rv).c_str(),
           rv ? rv->UhdmId() : 0);
    printf("     Root_value Typespec = %s\n", rvx ? tsEdge(rvx).c_str() : "<not-an-expr>");
    auto* pe = any_cast<const expr*>(o);
    const ref_typespec* prt = pe ? pe->Typespec() : nullptr;
    const ref_typespec* rrt = rvx ? rvx->Typespec() : nullptr;
    printf("     SAME ref_typespec OBJECT   : %s\n",
           (prt && rrt && prt == rrt) ? "YES" : "no");
    printf("     SAME Actual_typespec OBJECT: %s\n",
           (prt && rrt && prt->Actual_typespec() &&
            prt->Actual_typespec() == rrt->Actual_typespec())
               ? "YES"
               : "no");
}

// (2) SHARERS.  Every ref_typespec in the database pointing at the same
// Actual_typespec, and every object owning one of those.
static void sharers(const char* tag, Serializer& s, const BaseClass* o) {
    auto* e = any_cast<const expr*>(o);
    const ref_typespec* rt = e ? e->Typespec() : nullptr;
    const typespec* act = rt ? rt->Actual_typespec() : nullptr;
    if (!act) {
        printf("   %s SHARERS: no Actual_typespec -- none.\n", tag);
        return;
    }
    int nRef = 0;
    std::map<std::string, int> byOwner;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* q = p.first;
        if (!q || q->UhdmType() != uhdmref_typespec) continue;
        auto* r = (const ref_typespec*)q;
        if (r->Actual_typespec() != act) continue;
        nRef++;
        byOwner[kindOf(r->VpiParent())]++;
    }
    printf("   %s SHARERS of Actual_typespec %s id:%u ('%s'): %d ref_typespec "
           "objects\n",
           tag, kindOf(act).c_str(), act->UhdmId(),
           std::string(act->VpiName()).c_str(), nRef);
    for (auto& kv : byOwner)
        printf("        owner %-24s x%d\n", kv.first.c_str(), kv.second);
}

static void chain(const char* tag, const BaseClass* o) {
    printf("   -- OWNER CHAIN (%s) --\n", tag);
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    for (int d = 0; d < 7 && p; d++) {
        printf("     %*s|vpiParent -> %s\n", d * 2, "", payload(p).c_str());
        p = p->VpiParent();
    }
}

// EVERY sibling operand of the owning operation, both sides, with its typespec
// edge -- the answer to "is the law one cell or the whole operand list?".
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
        fprintf(stderr, "usage: own114 <golden> <ours> [iters]\n");
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
        // THE SINGULAR SafeCompare WITH `rhs == nullptr` NAMES THE VALUE, NOT
        // ITS OWNER (RESUME.md section 9).  When the head is a bare
        // `ref_typespec` with `RHS: <null>`, the object the judge is actually
        // walking is that ref_typespec's OWNER -- so climb to it and find OUR
        // counterpart by kind + name + span, which is exactly the join the
        // census uses.  Nothing is guessed: the chain is printed first.
        if (L && !R && L->UhdmType() == uhdmref_typespec) {
            printf("   RHS IS NULL -- the SINGULAR SafeCompare named the VALUE."
                   "  Climbing to the OWNER.\n");
            chain("golden(ref_typespec)", L);
            const BaseClass* ownerL = L->VpiParent();
            if (ownerL) {
                printf("   OWNER(golden) = %s\n", payload(ownerL).c_str());
                const BaseClass* ownerR = nullptr;
                for (const auto& p : so.AllObjects()) {
                    const BaseClass* q = p.first;
                    if (!q || q->UhdmType() != ownerL->UhdmType()) continue;
                    if (q->VpiName() != ownerL->VpiName()) continue;
                    if (q->VpiLineNo() != ownerL->VpiLineNo() ||
                        q->VpiColumnNo() != ownerL->VpiColumnNo() ||
                        q->VpiEndLineNo() != ownerL->VpiEndLineNo() ||
                        q->VpiEndColumnNo() != ownerL->VpiEndColumnNo())
                        continue;
                    ownerR = q;
                    break;
                }
                printf("   OWNER(ours)   = %s\n", payload(ownerR).c_str());
                if (ownerR && ownerR->UhdmType() == ownerL->UhdmType()) {
                    bisect(ownerL, ownerR);
                    identity("GOLDEN", ownerL);
                    identity("OURS  ", ownerR);
                    sharers("GOLDEN", sg, ownerL);
                    sharers("OURS  ", so, ownerR);
                    elems("GOLDEN", ownerL);
                    elems("OURS  ", ownerR);
                    chain("golden(owner)", ownerL);
                    chain("ours(owner)", ownerR);
                    sibs("GOLDEN", ownerL);
                    sibs("OURS  ", ownerR);
                    // MASK the owner's Typespec so the NEXT field is READ.
                    if (auto* ol = any_cast<const expr*>(ownerL)) {
                        auto* orr = any_cast<const expr*>(ownerR);
                        const_cast<expr*>(ol)->Typespec(
                            const_cast<ref_typespec*>(
                                orr ? orr->Typespec() : nullptr));
                        printf("   MASKED golden owner's Typespec := ours';"
                               " re-running.\n");
                        continue;
                    }
                }
            }
            printf("   could not pair the owner -- stop.\n");
            break;
        }
        if (!L || !R || L->UhdmType() != R->UhdmType()) {
            printf("   KIND MISMATCH or null side -- stop.\n");
            break;
        }
        bisect(L, R);
        identity("GOLDEN", L);
        identity("OURS  ", R);
        sharers("GOLDEN", sg, L);
        sharers("OURS  ", so, R);
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
