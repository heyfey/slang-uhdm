// Reverse lookup for an UNPARENTED typespec: cmptool prints a failing
// object's chain by walking VpiParent, which dead-ends on typespecs Surelog
// leaves unparented (port/io_decl typespecs). Given a source line:col, this
// lists every ref_typespec in the arena whose Actual_typespec sits there,
// with the REFERRER's parent chain and the actual's fold state — the only
// way to say WHICH port a "logic_typespec@30:10" belongs to.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 20;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
    }
    return out;
}

static std::string fold(const typespec* t) {
    const VectorOfrange* rs = nullptr;
    if (t->UhdmType() == uhdmlogic_typespec)
        rs = ((const logic_typespec*)t)->Ranges();
    else if (t->UhdmType() == uhdmbit_typespec)
        rs = ((const bit_typespec*)t)->Ranges();
    if (rs && !rs->empty() && (*rs)[0]->Left_expr())
        return UhdmName((*rs)[0]->Left_expr()->UhdmType());
    return "-";
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: w4tsref <uhdm> <line> <col>\n";
        return 2;
    }
    unsigned wl = atoi(argv[2]), wc = atoi(argv[3]);
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int n = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
        auto* r = (const ref_typespec*)obj;
        auto* a = r->Actual_typespec();
        if (!a || a->VpiLineNo() != wl || a->VpiColumnNo() != wc) continue;
        std::cout << "#" << n++ << " actual=" << UhdmName(a->UhdmType()) << "("
                  << a->VpiName() << ") L=" << fold(a) << " @"
                  << (const void*)a << "\n   ref < " << chain(r->VpiParent())
                  << "\n";
    }
    return 0;
}
