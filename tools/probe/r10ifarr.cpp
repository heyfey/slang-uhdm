// r10ifarr: interface-array structure probe.
//   r10ifarr <a.uhdm> [b.uhdm] [instpath-substring]
// For every module_inst (def + elab views), print Interfaces / Interface_arrays
// with the array's own member Instances list, so a
// `Interfaces: SIZE lhs=1 rhs=27` first-fail says which container the array
// members were listed in.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string filt;

static void dumpMod(const std::string& side, const module_inst* m);

static void dumpIfaces(const std::string& side, const std::string& path,
                       const module_inst* m) {
    auto* ifs = m->Interfaces();
    auto* arr = m->Interface_arrays();
    std::cout << side << " " << path << " top=" << m->VpiTop()
              << " Interfaces=" << (ifs ? (int)ifs->size() : -1)
              << " Interface_arrays=" << (arr ? (int)arr->size() : -1) << "\n";
    if (ifs) {
        int i = 0;
        for (auto* p : *ifs)
            std::cout << side << "   IF[" << i++ << "] '" << p->VpiName()
                      << "' def='" << p->VpiDefName() << "' arrmem="
                      << p->VpiArrayMember() << "\n";
    }
    if (arr) {
        int i = 0;
        for (auto* a : *arr) {
            std::cout << side << "   IARR[" << i++ << "] '" << a->VpiName()
                      << "' def='" << a->VpiDefName() << "'\n";
            auto* r = a->Ranges();
            if (r)
                for (auto* rr : *r)
                    std::cout << side << "       range lhs="
                              << (rr->Left_expr() ? UhdmName(rr->Left_expr()->UhdmType())
                                                  : "<null>")
                              << " rhs="
                              << (rr->Right_expr() ? UhdmName(rr->Right_expr()->UhdmType())
                                                   : "<null>")
                              << "\n";
            else
                std::cout << side << "       ranges=<null>\n";
            auto* mem = a->Instances();
            std::cout << side << "       Instances="
                      << (mem ? (int)mem->size() : -1) << "\n";
            if (mem) {
                int j = 0;
                for (auto* p : *mem)
                    std::cout << side << "         M[" << j++ << "] '"
                              << p->VpiName() << "' arrmem=" << p->VpiArrayMember()
                              << "\n";
            }
        }
    }
}

static void walk(const std::string& side, const std::string& path,
                 const module_inst* m) {
    if (filt.empty() || path.find(filt) != std::string::npos)
        dumpIfaces(side, path, m);
    if (m->Modules())
        for (auto* s : *m->Modules())
            walk(side, path + "." + std::string(s->VpiName()), s);
}

int main(int argc, char** argv) {
    if (argc > 2) filt = argv[2];
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            walk("X", std::string("DEF:") + std::string(m->VpiDefName()), m);
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            walk("X", std::string("TOP:") + std::string(m->VpiName()), m);
    return 0;
}
