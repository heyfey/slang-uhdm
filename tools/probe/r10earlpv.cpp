// r10earlpv: per-VECTOR compare of one named package (or module) between two
// databases.  uhdm-cmp only names the first failing pair for the WHOLE design;
// this splits the container so the SLOT that carries the head is named.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10earlpv.cpp -o /tmp/r10earlpv \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10earlpv <golden.uhdm> <ours.uhdm> <pkgname> [allpkg|toppkg|allmod|topmod]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " id" +
                    std::to_string(n->UhdmId()) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    return s;
}
static std::string chain(const BaseClass* n) {
    std::string s;
    int i = 0;
    const any* p = n ? n->VpiParent() : nullptr;
    while (p && i++ < 6) {
        s += "\n        ^ " + at(p);
        p = p->VpiParent();
    }
    return s;
}

template <class V>
static void go(const char* tag, V* va, V* vb) {
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    if (na != nb) {
        std::cout << "  " << tag << ": SIZE " << na << " vs " << nb << "\n";
        size_t n = na < nb ? na : nb;
        for (size_t i = 0; i < n; i++) {
            CompareContext ctx;
            if ((*va)[i]->Compare((*vb)[i], &ctx) != 0) {
                std::cout << "    first-unequal-common[" << i
                          << "] " << at((*va)[i]) << " vs " << at((*vb)[i])
                          << "\n";
                break;
            }
        }
        for (size_t i = n; i < na; i++)
            std::cout << "    LHS-extra[" << i << "] " << at((*va)[i]) << "\n";
        for (size_t i = n; i < nb; i++)
            std::cout << "    RHS-extra[" << i << "] " << at((*vb)[i]) << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        CompareContext ctx;
        int r = (*va)[i]->Compare((*vb)[i], &ctx);
        if (r == 0) continue;
        std::cout << "  " << tag << "[" << i << "] '"
                  << std::string((*va)[i]->VpiName()) << "': r=" << r
                  << "\n      failLhs " << at(ctx.m_failedLhs)
                  << chain(ctx.m_failedLhs) << "\n      failRhs "
                  << at(ctx.m_failedRhs) << chain(ctx.m_failedRhs) << "\n";
    }
}

static void cmpScope(const scope* a, const scope* b) {
    go("Parameters", a->Parameters(), b->Parameters());
    go("Param_assigns", a->Param_assigns(), b->Param_assigns());
    go("Typespecs", a->Typespecs(), b->Typespecs());
    go("Variables", a->Variables(), b->Variables());
    go("Logic_vars", a->Logic_vars(), b->Logic_vars());
    go("Array_vars", a->Array_vars(), b->Array_vars());
    go("Named_events", a->Named_events(), b->Named_events());
    go("Instance_items", a->Instance_items(), b->Instance_items());
    go("Let_decls", a->Let_decls(), b->Let_decls());
    go("Attributes", a->Attributes(), b->Attributes());
    go("Scopes", a->Scopes(), b->Scopes());
    go("Property_decls", a->Property_decls(), b->Property_decls());
    go("Sequence_decls", a->Sequence_decls(), b->Sequence_decls());
    go("Concurrent_assertions", a->Concurrent_assertions(),
       b->Concurrent_assertions());
}
static void cmpInst(const instance* a, const instance* b) {
    cmpScope(a, b);
    go("Class_defns", a->Class_defns(), b->Class_defns());
    go("Task_funcs", a->Task_funcs(), b->Task_funcs());
    go("Nets", a->Nets(), b->Nets());
    go("Array_nets", a->Array_nets(), b->Array_nets());
    go("Spec_params", a->Spec_params(), b->Spec_params());
    go("Assertions", a->Assertions(), b->Assertions());
    go("Programs", a->Programs(), b->Programs());
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    std::string want = argv[3];
    std::string which = argc > 4 ? argv[4] : "allpkg";
    auto pick = [&](const design* d) -> const instance* {
        if (which == "allpkg" || which == "toppkg") {
            auto* v = which == "allpkg" ? d->AllPackages() : d->TopPackages();
            if (v)
                for (auto* p : *v)
                    if (std::string(p->VpiName()) == want) return p;
        }
        else {
            auto* v = which == "allmod" ? d->AllModules() : d->TopModules();
            if (v)
                for (auto* m : *v)
                    if (std::string(m->VpiName()) == want) return m;
        }
        return nullptr;
    };
    const instance* a = pick(da);
    const instance* b = pick(db);
    if (!a || !b) {
        std::cout << "not found: lhs=" << (void*)a << " rhs=" << (void*)b << "\n";
        return 3;
    }
    std::cout << "== " << which << " " << want << "\n";
    cmpInst(a, b);
    std::cout << "== done\n";
    return 0;
}
