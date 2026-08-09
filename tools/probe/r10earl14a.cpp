// r10earl14a — WHICH CHILD VECTOR of one listing entry fails, element by
// element, with a FRESH CompareContext per element.  The design census names
// one head per entry and instance::Compare recurses Instance(), so a
// § pkgTypespecInstanceIsTop head prints only "package X" with the design as
// its whole parent chain and no dump can say which child reached it.  This
// splits an entry into its child vectors and Compares each pair positionally,
// so the answer is "Typespecs()[7]" or "Parameters()[3]" instead of a package
// name.
// Build: bash tools/probe/r10earl14build.sh r10earl14a
// Usage: r10earl14a <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + std::string(n->VpiFile()) +
                    ":" + std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo()) +
                    " uid=" + std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) + "}";
    return s;
}

// § cutInstance — seed m_visited with the entry itself so a child's
// Instance() back-edge short-circuits.  Without it EVERY child of a package
// listing reports the same head (the first difference anywhere in the listing),
// because instance::Compare recurses Instance() and typespec::Compare recurses
// into the owning package.  With it, each child names its OWN difference.
static const BaseClass* cutA = nullptr;
static const BaseClass* cutB = nullptr;
static bool cutMode = false;

template <class V>
static void cmpVec(const char* tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (!na && !nb)
        return;
    if (na != nb) {
        std::cout << "  " << tag << " SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        CompareContext ctx;
        if (cutA)
            ctx.m_visited.insert(cutA);
        if (cutB)
            ctx.m_visited.insert(cutB);
        int r = (*a)[i]->Compare((*b)[i], &ctx);
        if (r == 0)
            continue;
        std::cout << "  " << tag << "[" << i << "] r=" << r << " lhs=" << at((*a)[i])
                  << "\n      failLhs " << at(ctx.m_failedLhs) << "\n      failRhs "
                  << at(ctx.m_failedRhs) << "\n";
    }
}

static void doInst(const instance* a, const instance* b) {
    std::cout << "== " << at(a) << "\n   vs " << at(b) << "\n";
    if (cutMode) {
        cutA = a;
        cutB = b;
    }
    cmpVec("Parameters", a->Parameters(), b->Parameters());
    cmpVec("Param_assigns", a->Param_assigns(), b->Param_assigns());
    cmpVec("Typespecs", a->Typespecs(), b->Typespecs());
    cmpVec("Variables", a->Variables(), b->Variables());
    cmpVec("Nets", a->Nets(), b->Nets());
    cmpVec("Array_nets", a->Array_nets(), b->Array_nets());
    cmpVec("Task_funcs", a->Task_funcs(), b->Task_funcs());
    cmpVec("Named_events", a->Named_events(), b->Named_events());
    cmpVec("Class_defns", a->Class_defns(), b->Class_defns());
    if (a->UhdmType() == uhdmmodule_inst && b->UhdmType() == uhdmmodule_inst) {
        auto* ma = (const module_inst*)a;
        auto* mb = (const module_inst*)b;
        cmpVec("Ports", ma->Ports(), mb->Ports());
        cmpVec("Cont_assigns", ma->Cont_assigns(), mb->Cont_assigns());
        cmpVec("Process", ma->Process(), mb->Process());
        cmpVec("Modules", ma->Modules(), mb->Modules());
        cmpVec("Gen_scope_arrays", ma->Gen_scope_arrays(), mb->Gen_scope_arrays());
        cmpVec("Ref_modules", ma->Ref_modules(), mb->Ref_modules());
        cmpVec("Interfaces", ma->Interfaces(), mb->Interfaces());
        cmpVec("Primitives", ma->Primitives(), mb->Primitives());
        cmpVec("Def_params", ma->Def_params(), mb->Def_params());
        cmpVec("Assertions", ma->Assertions(), mb->Assertions());
    }
}

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[3], want = argv[4];
    cutMode = argc > 5 && std::string(argv[5]) == "--cut";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    auto pick = [&](auto* v) -> std::vector<const instance*> {
        std::vector<const instance*> out;
        if (v)
            for (auto* x : *v) {
                std::string n(x->VpiName()), d(x->VpiDefName());
                if (n == want || d == want || ("def:" + d) == want)
                    out.push_back(x);
            }
        return out;
    };
    std::vector<const instance*> A, B;
    if (vec == "all") {
        A = pick(da->AllModules());
        B = pick(db->AllModules());
    }
    else if (vec == "top") {
        A = pick(da->TopModules());
        B = pick(db->TopModules());
    }
    else if (vec == "allpkg") {
        A = pick(da->AllPackages());
        B = pick(db->AllPackages());
    }
    else {
        A = pick(da->TopPackages());
        B = pick(db->TopPackages());
    }
    for (size_t i = 0; i < A.size() && i < B.size(); i++)
        doInst(A[i], B[i]);
    if (A.empty() || B.empty())
        std::cout << "not found (" << A.size() << " vs " << B.size() << ")\n";
    return 0;
}
