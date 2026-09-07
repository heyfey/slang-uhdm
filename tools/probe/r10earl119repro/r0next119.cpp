// r10earl119 — R0 DECODE: the NEXT head, named with the same discipline as
// this pass's own.  After the fold lands, Earlgrey_0_1/default's head is
// `LHS: package top_pkg` with `RHS: <null>`, which the PRISTINE ladder already
// named at rung 1 (so it is pre-existing and merely unmasked).
//
// A `<null>` RHS is AMBIGUOUS from the print alone (RESUME.md section 9): the
// SINGULAR SafeCompare overload sets `m_failedLhs` to THE VALUE, the VECTOR
// overload sets it to the ELEMENT (a != null, b == null) or to the CONTAINER
// (rhs vector null, lhs non-empty).  This probe removes the ambiguity by
// re-running each container of `design::Compare`'s package list and then each
// container of the package pair IN THE GENERATED ORDER with a FRESH context.
//
// MEASUREMENT ONLY.  build:
//   g++ -O2 -std=c++17 r0next119.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o r0next119
// usage: r0next119 <golden.uhdm> <ours.uhdm> <package-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static std::string pay(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o) + " '" + std::string(o->VpiName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
    }
    return s;
}

// BaseClass::SafeCompare is protected; the VECTOR overload is transcribed here
// VERBATIM from ~/.local/include/uhdm/BaseClass.h (checked against that file).
template <typename T>
static int32_t vecSafeCompare(const BaseClass* lhs_obj,
                              const std::vector<T*>* lhs,
                              const BaseClass* rhs_obj,
                              const std::vector<T*>* rhs,
                              CompareContext* context) {
    if ((lhs != nullptr) && (rhs != nullptr)) {
        int32_t r = 0;
        if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
            context->m_failedLhs = lhs_obj;
            context->m_failedRhs = rhs_obj;
            return 1;
        }
        for (size_t i = 0, n = lhs->size(); i < n; ++i) {
            const BaseClass* a = lhs->at(i);
            const BaseClass* b = rhs->at(i);
            if ((a != nullptr) && (b != nullptr)) {
                if ((r = a->Compare(b, context)) != 0) return r;
            } else if ((a != nullptr) && (b == nullptr)) {
                context->m_failedLhs = a;
                return 1;
            } else if ((a == nullptr) && (b != nullptr)) {
                context->m_failedRhs = b;
                return -1;
            }
        }
    } else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
        context->m_failedLhs = lhs_obj;
        return 1;
    } else if ((lhs == nullptr) && (rhs != nullptr) && !rhs->empty()) {
        context->m_failedRhs = rhs_obj;
        return -1;
    }
    return 0;
}

#define CELL(NAME, GET)                                                       \
    do {                                                                      \
        CompareContext c;                                                     \
        int32_t r = vecSafeCompare(L, L->GET, R, R->GET, &c);                 \
        printf("      %-28s L=%-5s R=%-5s -> %d%s\n", NAME,                   \
               L->GET ? std::to_string(L->GET->size()).c_str() : "null",      \
               R->GET ? std::to_string(R->GET->size()).c_str() : "null", r,   \
               r ? "   <== FAILS" : "");                                      \
    } while (0)

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: r0next119 <golden> <ours> <pkgname>\n");
        return 2;
    }
    std::string want(argv[3]);
    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    // `design::Compare` (design.cpp:295-302) reads, IN ORDER:
    //   Include_file_infos, AllPackages, TopPackages, AllClasses,
    //   AllInterfaces, AllUdps, AllPrograms, AllModules.
    // A `<null>` RHS whose LHS is an ELEMENT (not the design) is the vector
    // overload's `a != nullptr && b == nullptr` branch -- i.e. OUR vector has
    // a NULL ENTRY where golden has the package.  So both package vectors are
    // scanned for null entries before anything else is claimed.
    auto scan = [](const char* tag, const char* which, const VectorOfpackage* v) {
        if (!v) { printf("   %-7s %-12s <NULL VECTOR>\n", tag, which); return; }
        size_t nulls = 0;
        for (size_t i = 0; i < v->size(); i++)
            if (v->at(i) == nullptr) { nulls++; if (nulls < 4) printf("   %-7s %-12s NULL ENTRY at index %zu\n", tag, which, i); }
        printf("   %-7s %-12s size=%zu nulls=%zu\n", tag, which, v->size(), nulls);
    };
    scan("GOLDEN", "AllPackages", dg->AllPackages());
    scan("OURS", "AllPackages", dd->AllPackages());
    scan("GOLDEN", "TopPackages", dg->TopPackages());
    scan("OURS", "TopPackages", dd->TopPackages());
    if (dg->AllPackages() && dd->AllPackages() &&
        dg->AllPackages()->size() == dd->AllPackages()->size())
        for (size_t i = 0; i < dg->AllPackages()->size(); i++) {
            const package* a = dg->AllPackages()->at(i);
            const package* b = dd->AllPackages()->at(i);
            if (!a || !b || std::string(a->VpiName()) != std::string(b->VpiName()))
                printf("   AllPackages[%zu] golden='%s' ours='%s'  <== PAIRING\n", i,
                       a ? std::string(a->VpiName()).c_str() : "<null>",
                       b ? std::string(b->VpiName()).c_str() : "<null>");
        }
    if (dg->TopPackages() && dd->TopPackages() &&
        dg->TopPackages()->size() == dd->TopPackages()->size())
        for (size_t i = 0; i < dg->TopPackages()->size(); i++) {
            const package* a = dg->TopPackages()->at(i);
            const package* b = dd->TopPackages()->at(i);
            if (!a || !b || std::string(a->VpiName()) != std::string(b->VpiName()))
                printf("   TopPackages[%zu] golden='%s' ours='%s'  <== PAIRING\n", i,
                       a ? std::string(a->VpiName()).c_str() : "<null>",
                       b ? std::string(b->VpiName()).c_str() : "<null>");
        }
    printf("== design::AllPackages  golden=%zu ours=%zu\n",
           dg->AllPackages() ? dg->AllPackages()->size() : 0,
           dd->AllPackages() ? dd->AllPackages()->size() : 0);
    const package* L = nullptr;
    const package* R = nullptr;
    size_t li = 0, ri = 0;
    if (dg->AllPackages())
        for (size_t i = 0; i < dg->AllPackages()->size(); i++)
            if (std::string(dg->AllPackages()->at(i)->VpiName()) == want) {
                L = dg->AllPackages()->at(i);
                li = i;
            }
    if (dd->AllPackages())
        for (size_t i = 0; i < dd->AllPackages()->size(); i++)
            if (std::string(dd->AllPackages()->at(i)->VpiName()) == want) {
                R = dd->AllPackages()->at(i);
                ri = i;
            }
    printf("   '%s' golden index=%zu present=%s   ours index=%zu present=%s\n",
           want.c_str(), li, L ? "yes" : "NO", ri, R ? "yes" : "NO");
    if (!L || !R) return 0;
    {
        CompareContext c;
        int32_t r = L->Compare(R, &c);
        printf("== package::Compare -> %d\n", r);
        printf("   failedLhs = %s\n", pay(c.m_failedLhs).c_str());
        printf("   failedRhs = %s\n", pay(c.m_failedRhs).c_str());
    }
    printf("== CONTAINER BISECTION (generated scope/instance order, fresh"
           " context each)\n");
    CELL("scope::Named_events", Named_events());
    CELL("scope::Variables", Variables());
    CELL("scope::Logic_vars", Logic_vars());
    CELL("scope::Array_vars", Array_vars());
    CELL("scope::Parameters", Parameters());
    CELL("scope::Param_assigns", Param_assigns());
    CELL("scope::Scopes", Scopes());
    CELL("scope::Typespecs", Typespecs());
    CELL("scope::Instance_items", Instance_items());
    // `package` carries only the scope/instance containers below; the
    // module-only ones (Modules, Interfaces, Process, Cont_assigns,
    // Named_begins, Gen_scope_arrays) are not members of it at all.
    CELL("instance::Programs", Programs());
    CELL("instance::Nets", Nets());
    CELL("instance::Array_nets", Array_nets());
    CELL("instance::Task_funcs", Task_funcs());
    return 0;
}
