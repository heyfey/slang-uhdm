// r10earl111 -- THE OWNER FINDER for a `ref_typespec` head whose RHS is <null>.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9, head-decode discipline: BaseClass::SafeCompare's
// SINGULAR overload, called with `rhs == nullptr`, names the VALUE as
// m_failedLhs and leaves m_failedRhs unset -- so the head print says
// `RHS: <null>` and NEVER names the OWNER.  For a `ref_typespec` the owner is
// reachable WITHOUT masking, because Surelog parents the ref at its holder
// (`rt->VpiParent(c)`), so this tool READS the parent chain instead of
// guessing, and then prints EVERY Compare-visible field of the object golden
// hangs there:
//
//   ref_typespec::Compare  -> BaseClass(VpiType/VpiName/VpiDefName)
//                             + Actual_typespec
//   int_typespec::Compare  -> typespec(VpiName, Typedef_alias, Instance)
//                             + Cast_to_expr + VpiSigned + Ranges
//
// (VpiFullName, VpiFile and the span are NOT read by any generated Compare --
// they are printed here only to locate the cell in the source.)
//
// It then MASKS golden's own edge (`owner->Typespec(nullptr)`) in a FRESH
// CompareContext and re-runs the OFFICIAL design::Compare, which walks the
// whole reachable family and COUNTS it -- earl60's tsinst60 technique.
//
// build:
//   g++ -O2 -std=c++17 own111.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own111
// usage:
//   own111 <golden.uhdm> <ours.uhdm> [maxIterations]
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

// Every field the generated Compare of a typespec (and of the four integral
// typespec kinds that can appear here) actually reads.
static std::string tsPayload(const typespec* t) {
    if (!t) return "<null>";
    std::string s = kindOf(t);
    s += " name='" + std::string(t->VpiName()) + "'";
    s += " defname='" + std::string(t->VpiDefName()) + "'";
    s += " alias=" + kindOf(t->Typedef_alias());
    s += " instance=" + kindOf(t->Instance());
    if (t->Instance())
        s += "('" + std::string(t->Instance()->VpiName()) + "')";
    if (auto* i = any_cast<const int_typespec*>(t)) {
        s += " signed=" + std::to_string((int)i->VpiSigned());
        s += " cast=" + kindOf(i->Cast_to_expr());
        s += " ranges=" +
             std::to_string(i->Ranges() ? i->Ranges()->size() : 0);
        if (!i->VpiValue().empty())
            s += " value='" + std::string(i->VpiValue()) + "'";
    }
    if (auto* l = any_cast<const logic_typespec*>(t)) {
        s += " signed=" + std::to_string((int)l->VpiSigned());
        s += " ranges=" +
             std::to_string(l->Ranges() ? l->Ranges()->size() : 0);
    }
    if (auto* b = any_cast<const bit_typespec*>(t)) {
        s += " signed=" + std::to_string((int)b->VpiSigned());
        s += " ranges=" +
             std::to_string(b->Ranges() ? b->Ranges()->size() : 0);
    }
    s += "  @" + spanOf(t);
    return s;
}

static std::string exprPayload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    s += " name='" + std::string(o->VpiName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
        if (!e->VpiValue().empty())
            s += " value='" + std::string(e->VpiValue()) + "'";
    }
    if (auto* c = any_cast<const constant*>(o))
        s += " ct=" + std::to_string(c->VpiConstType());
    s += "  @" + spanOf(o);
    return s;
}

// The Typespec() edge of the kinds that can own a ref_typespec here.
static const ref_typespec* ownerTs(const BaseClass* o) {
    if (!o) return nullptr;
    if (auto* e = any_cast<const expr*>(o)) return e->Typespec();
    return nullptr;
}
static bool clearOwnerTs(BaseClass* o) {
    if (!o) return false;
    if (auto* c = any_cast<constant*>(o)) { c->Typespec(nullptr); return true; }
    if (auto* op = any_cast<operation*>(o)) { op->Typespec(nullptr); return true; }
    if (auto* r = any_cast<ref_obj*>(o)) { r->Typespec(nullptr); return true; }
    if (auto* hp = any_cast<hier_path*>(o)) { hp->Typespec(nullptr); return true; }
    return false;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own111 <golden> <ours> [iters]\n");
        return 2;
    }
    int maxIt = argc > 3 ? atoi(argv[3]) : 1;
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: load failed\n"); return 3; }
    if (hg.size() != ho.size()) {
        fprintf(stderr, "FATAL: design count %zu vs %zu\n", hg.size(), ho.size());
        return 3;
    }
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
        auto* rt = L ? any_cast<const ref_typespec*>(L) : nullptr;
        if (!rt || R != nullptr) {
            printf("   NOT a singular ref_typespec-with-null-RHS head -- family exhausted.\n");
            if (L) printf("   LHS payload: %s\n", exprPayload(L).c_str());
            if (R) printf("   RHS payload: %s\n", exprPayload(R).c_str());
            break;
        }
        printf("   ref_typespec fullname='%s' name='%s' defname='%s'\n",
               std::string(rt->VpiFullName()).c_str(),
               std::string(rt->VpiName()).c_str(),
               std::string(rt->VpiDefName()).c_str());
        printf("   |vpiActual -> %s\n",
               tsPayload(rt->Actual_typespec()).c_str());
        // The OWNER chain, read (not guessed).
        const BaseClass* p1 = rt->VpiParent();
        printf("   |vpiParent -> %s\n", exprPayload(p1).c_str());
        const BaseClass* p2 = p1 ? p1->VpiParent() : nullptr;
        printf("       |vpiParent -> %s\n", exprPayload(p2).c_str());
        const BaseClass* p3 = p2 ? p2->VpiParent() : nullptr;
        printf("           |vpiParent -> %s\n", exprPayload(p3).c_str());
        const BaseClass* p4 = p3 ? p3->VpiParent() : nullptr;
        printf("               |vpiParent -> %s\n", exprPayload(p4).c_str());
        if (p1) {
            const ref_typespec* back = ownerTs(p1);
            printf("   OWNER->Typespec() is %s the head\n",
                   back == rt ? "EXACTLY" : "NOT");
        }
        if (!clearOwnerTs(const_cast<BaseClass*>(p1))) {
            printf("   cannot mask this owner kind -- stopping.\n");
            break;
        }
        printf("   MASKED golden owner's Typespec := <null>; re-running.\n");
    }
    return 0;
}
