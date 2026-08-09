// r10earl15b — SUB-CENSUS of ONE listing.  r10earl4h names the first failing
// pair of a whole module_inst, but when the failure is reached through a
// typespec's Instance() back-edge the parent chain lands in a PACKAGE and says
// nothing about WHICH child of the module carried the bad pointer.  This
// Compares the listing CHILD VECTOR BY CHILD VECTOR, index by index, each with
// a FRESH CompareContext, so the owning port / net / variable / typespec /
// parameter is named directly.
// Build: bash tools/probe/r10earl15build.sh r10earl15b
// Usage: r10earl15b <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name> [-v]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static bool verbose = false;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + base(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) +
             " def=" + std::string(in->VpiDefName()) +
             " uid=" + std::to_string(in->UhdmId()) + "}";
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
static void vecCmp(const char* tag, V* va, V* vb) {
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    if (!na && !nb)
        return;
    if (na != nb) {
        std::cout << "  " << tag << " SIZE " << na << " vs " << nb << "\n";
        return;
    }
    int bad = 0;
    for (size_t i = 0; i < na; i++) {
        CompareContext ctx;
        int r = (*va)[i]->Compare((*vb)[i], &ctx);
        if (r == 0)
            continue;
        bad++;
        std::cout << "  " << tag << "[" << i << "] r=" << r << "  own="
                  << at((*va)[i]) << "\n      failLhs " << at(ctx.m_failedLhs)
                  << chain(ctx.m_failedLhs) << "\n      failRhs "
                  << at(ctx.m_failedRhs) << chain(ctx.m_failedRhs) << "\n";
        if (!verbose && bad >= 3)
            break;
    }
    if (!bad)
        std::cout << "  " << tag << " OK (" << na << ")\n";
}

template <class V>
static const instance* pick(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                return x;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[3], want = argv[4];
    verbose = argc > 5 && std::string(argv[5]) == "-v";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const instance* ia = nullptr;
    const instance* ib = nullptr;
    if (vec == "all") {
        ia = pick(da->AllModules(), want);
        ib = pick(db->AllModules(), want);
    }
    else if (vec == "top") {
        ia = pick(da->TopModules(), want);
        ib = pick(db->TopModules(), want);
    }
    else if (vec == "allpkg") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->AllPackages(), want);
    }
    // CROSS-VIEW: A's DEF package against B's TOP package.  Pass the same file
    // twice to ask "do this database's own two package copies differ?", which
    // is the question behind § pkgTypespecInstanceIsTop (golden's module
    // typespecs point at the TOP copy, ours at the DEF one).
    else if (vec == "def2top") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    else {
        ia = pick(da->TopPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    if (!ia || !ib) {
        std::cout << "not found\n";
        return 3;
    }
    {
        CompareContext ctx;
        std::cout << "WHOLE r=" << ia->Compare(ib, &ctx) << "\n";
    }
    vecCmp("Parameters", ia->Parameters(), ib->Parameters());
    vecCmp("Param_assigns", ia->Param_assigns(), ib->Param_assigns());
    vecCmp("Typespecs", ia->Typespecs(), ib->Typespecs());
    vecCmp("Variables", ia->Variables(), ib->Variables());
    vecCmp("Nets", ia->Nets(), ib->Nets());
    vecCmp("Task_funcs", ia->Task_funcs(), ib->Task_funcs());
    if (auto* ma = any_cast<const module_inst*>((const any*)ia))
        if (auto* mb = any_cast<const module_inst*>((const any*)ib)) {
            vecCmp("Ports", ma->Ports(), mb->Ports());
            vecCmp("Cont_assigns", ma->Cont_assigns(), mb->Cont_assigns());
            vecCmp("Process", ma->Process(), mb->Process());
            vecCmp("Modules", ma->Modules(), mb->Modules());
            vecCmp("Ref_modules", ma->Ref_modules(), mb->Ref_modules());
            vecCmp("Gen_scope_arrays", ma->Gen_scope_arrays(),
                   mb->Gen_scope_arrays());
            vecCmp("Interfaces", ma->Interfaces(), mb->Interfaces());
            vecCmp("Module_arrays", ma->Module_arrays(), mb->Module_arrays());
            vecCmp("Named_events", ma->Named_events(), mb->Named_events());
            vecCmp("Array_nets", ma->Array_nets(), mb->Array_nets());
            vecCmp("Assertions", ma->Assertions(), mb->Assertions());
            vecCmp("Primitives", ma->Primitives(), mb->Primitives());
            vecCmp("Def_params", ma->Def_params(), mb->Def_params());
            vecCmp("Property_decls", ma->Property_decls(), mb->Property_decls());
            vecCmp("Let_decls", ma->Let_decls(), mb->Let_decls());
        }
    return 0;
}
