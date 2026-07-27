// Localiser: every object of a given typespec NAME in the arena, with its
// parent chain and range fold state. Answers "how many twins of this typedef
// exist, and which view does each belong to" -- the question a listing-scoped
// probe cannot reach (rp32 fn3_t under a function return-value local var).
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
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: w4tsdup <uhdm> <ts-name>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int n = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmlogic_typespec) continue;
        auto* t = (const logic_typespec*)obj;
        if (std::string(t->VpiName()) != want) continue;
        std::string fold = "-";
        if (auto* rs = t->Ranges())
            if (!rs->empty() && (*rs)[0]->Left_expr())
                fold = UhdmName((*rs)[0]->Left_expr()->UhdmType());
        std::cout << "#" << n++ << " L=" << fold;
        if (auto* i = t->Instance())
            std::cout << " inst=" << i->VpiName()
                      << (i->UhdmType() == uhdmpackage &&
                                  ((const package*)i)->VpiTop()
                              ? "#TOP"
                              : "#DEF");
        std::cout << "\n   " << chain(t) << "\n";
    }
    return 0;
}
