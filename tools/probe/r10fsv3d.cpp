// r10fsv3d: CUT-INSTANCE localizer.  typespec::Compare recurses Instance(), so
// ONE wrong package pointer makes every typespec in the design report the same
// far-away failure and hides the local diffs behind it.  package::Compare and
// design::Compare both start with `if (!m_visited.insert(this).second) return
// 0;` and m_visited is public -- so pre-seeding every package/design object
// turns Instance() recursion into a no-op and each Compare becomes LOCAL.
// Run this to see the diffs that are really in a scope, not the ones it merely
// points at.
//   g++ -std=c++17 -I$HOME/.local/include r10fsv3d.cpp -o r10fsv3d \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10fsv3d <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::vector<const BaseClass*> g_cut;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " id" +
           std::to_string(o->UhdmId()) + " '" + std::string(o->VpiName()) +
           "' " + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static void cmp(const std::string& tag, const BaseClass* a, const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << tag << ": ONE SIDE NULL (" << (a ? "rhs" : "lhs")
                  << " missing)\n";
        return;
    }
    CompareContext ctx;
    for (auto* c : g_cut) ctx.m_visited.insert(c);
    if (a->Compare(b, &ctx) == 0) return;
    std::cout << tag << ": DIFF\n    L " << d1(ctx.m_failedLhs) << "\n    R "
              << d1(ctx.m_failedRhs) << "\n";
}

template <typename V>
static void cmpVec(const std::string& tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << tag << ": SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        std::string nm((*a)[i]->VpiName());
        cmp(tag + "[" + std::to_string(i) + "]" +
                (nm.empty() ? "" : "(" + nm + ")"),
            (*a)[i], (*b)[i]);
    }
}

// A struct/union typespec compares member-by-member; drill so a single wrong
// member Actual_value names ITSELF instead of the whole typespec.
static void drillTs(const std::string& tag, const typespec* a,
                    const typespec* b) {
    if (!a || !b || a->UhdmType() != b->UhdmType()) return;
    const VectorOftypespec_member *ma = nullptr, *mb = nullptr;
    if (a->UhdmType() == uhdmstruct_typespec) {
        ma = ((const struct_typespec*)a)->Members();
        mb = ((const struct_typespec*)b)->Members();
    } else if (a->UhdmType() == uhdmunion_typespec) {
        ma = ((const union_typespec*)a)->Members();
        mb = ((const union_typespec*)b)->Members();
    } else
        return;
    size_t na = ma ? ma->size() : 0, nb = mb ? mb->size() : 0;
    if (na != nb) {
        std::cout << tag << ".Members: SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++)
        cmp(tag + ".M(" + std::string((*ma)[i]->VpiName()) + ")", (*ma)[i],
            (*mb)[i]);
}

static void doInst(const std::string& tag, const instance* a,
                   const instance* b) {
    cmpVec(tag + ".Typespecs", a->Typespecs(), b->Typespecs());
    if (a->Typespecs() && b->Typespecs() &&
        a->Typespecs()->size() == b->Typespecs()->size())
        for (size_t i = 0; i < a->Typespecs()->size(); i++)
            drillTs(tag + ".Typespecs[" +
                        std::string((*a->Typespecs())[i]->VpiName()) + "]",
                    (*a->Typespecs())[i], (*b->Typespecs())[i]);
    cmpVec(tag + ".Parameters", a->Parameters(), b->Parameters());
    cmpVec(tag + ".Param_assigns", a->Param_assigns(), b->Param_assigns());
    cmpVec(tag + ".Task_funcs", a->Task_funcs(), b->Task_funcs());
    cmpVec(tag + ".Variables", a->Variables(), b->Variables());
    cmpVec(tag + ".Nets", a->Nets(), b->Nets());
    cmpVec(tag + ".Scopes", a->Scopes(), b->Scopes());
    cmpVec(tag + ".Instance_items", a->Instance_items(), b->Instance_items());
    cmpVec(tag + ".Class_defns", a->Class_defns(), b->Class_defns());
    if (a->UhdmType() != uhdmmodule_inst || b->UhdmType() != uhdmmodule_inst)
        return;
    auto* ma = (const module_inst*)a;
    auto* mb = (const module_inst*)b;
    cmpVec(tag + ".Ports", ma->Ports(), mb->Ports());
    cmpVec(tag + ".Process", ma->Process(), mb->Process());
    cmpVec(tag + ".Cont_assigns", ma->Cont_assigns(), mb->Cont_assigns());
    cmpVec(tag + ".Gen_scope_arrays", ma->Gen_scope_arrays(),
           mb->Gen_scope_arrays());
    cmpVec(tag + ".Modules", ma->Modules(), mb->Modules());
    if (ma->Modules() && mb->Modules() &&
        ma->Modules()->size() == mb->Modules()->size())
        for (size_t i = 0; i < ma->Modules()->size(); i++)
            doInst(tag + "/" + std::string((*ma->Modules())[i]->VpiName()),
                   (*ma->Modules())[i], (*mb->Modules())[i]);
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    g_cut.push_back(da);
    auto cut = [&](auto* v) {
        if (v)
            for (auto* e : *v) g_cut.push_back(e);
    };
    cut(da->AllPackages());
    cut(da->TopPackages());
    cut(da->AllModules());
    cut(da->TopModules());
    auto run = [&](const char* lbl, auto* pa, auto* pb) {
        if (!pa || !pb || pa->size() != pb->size()) {
            std::cout << lbl << ": LIST SIZE MISMATCH\n";
            return;
        }
        for (size_t i = 0; i < pa->size(); i++)
            doInst(std::string(lbl) + "[" + std::string((*pa)[i]->VpiName()) +
                       "#" + std::to_string(i) + "]",
                   (*pa)[i], (*pb)[i]);
    };
    run("DEFPKG", da->AllPackages(), db->AllPackages());
    run("ELABPKG", da->TopPackages(), db->TopPackages());
    run("DEFMOD", da->AllModules(), db->AllModules());
    run("ELABMOD", da->TopModules(), db->TopModules());
    return 0;
}
