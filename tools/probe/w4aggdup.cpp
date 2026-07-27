// Generalised w4tsdup: every typespec object in the arena whose VpiName
// matches (substring), regardless of typespec KIND, with parent chain,
// vpiInstance view (#TOP/#DEF) and — for aggregates — the member list with
// each member actual's name/kind. w4tsdup only walks logic_typespec, which
// hides the CONTAINER half of a clone forest (rp32 op32_t under enc32's
// return-value var).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string viewOf(const BaseClass* i) {
    if (!i) return "";
    std::string v(i->VpiName());
    if (i->UhdmType() == uhdmpackage)
        v += ((const package*)i)->VpiTop() ? "#TOP" : "#DEF";
    else if (i->UhdmType() == uhdmmodule_inst)
        v += ((const module_inst*)i)->VpiTop() ? "#TOP" : "#DEF";
    return v;
}

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 24;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
    }
    return out;
}

// Fold state of a typespec's first range bound: "constant" = folded,
// "operation"/"ref_obj" = symbolic.
static std::string fold(const typespec* t) {
    const VectorOfrange* rs = nullptr;
    if (t->UhdmType() == uhdmlogic_typespec)
        rs = ((const logic_typespec*)t)->Ranges();
    else if (t->UhdmType() == uhdmbit_typespec)
        rs = ((const bit_typespec*)t)->Ranges();
    else if (t->UhdmType() == uhdmarray_typespec)
        rs = ((const array_typespec*)t)->Ranges();
    if (rs && !rs->empty() && (*rs)[0]->Left_expr())
        return UhdmName((*rs)[0]->Left_expr()->UhdmType());
    return "-";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: w4aggdup <uhdm> <ts-name-substr> [--members]\n";
        return 2;
    }
    std::string want = argv[2];
    bool showMembers = argc > 3 && std::string(argv[3]) == "--members";
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int n = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto ut = obj->UhdmType();
        if (ut != uhdmlogic_typespec && ut != uhdmstruct_typespec &&
            ut != uhdmunion_typespec && ut != uhdmenum_typespec &&
            ut != uhdmbit_typespec && ut != uhdmarray_typespec &&
            ut != uhdminteger_typespec && ut != uhdmpacked_array_typespec)
            continue;
        auto* t = (const typespec*)obj;
        if (std::string(t->VpiName()).find(want) == std::string::npos) continue;
        std::cout << "#" << n++ << " " << UhdmName(ut) << "(" << t->VpiName()
                  << ") L=" << fold(t) << " inst=" << viewOf(t->Instance())
                  << "\n   " << chain((const BaseClass*)t->VpiParent()) << "\n";
        if (!showMembers) continue;
        const VectorOftypespec_member* ms = nullptr;
        if (ut == uhdmstruct_typespec) ms = ((const struct_typespec*)t)->Members();
        else if (ut == uhdmunion_typespec) ms = ((const union_typespec*)t)->Members();
        if (!ms) continue;
        for (auto* m : *ms) {
            std::cout << "     ." << m->VpiName() << " -> ";
            if (auto* rt = m->Typespec())
                if (auto* a = rt->Actual_typespec())
                    std::cout << UhdmName(a->UhdmType()) << "(" << a->VpiName()
                              << ") L=" << fold(a)
                              << " inst=" << viewOf(a->Instance());
            std::cout << "\n";
        }
    }
    return 0;
}
