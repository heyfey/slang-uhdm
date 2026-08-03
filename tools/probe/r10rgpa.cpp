// r10rgpa: print, for every interface_inst under a module whose full name
// contains <modSubstr>, the interface's param_assigns (Lhs name, Rhs value,
// vpiOverriden) and its modports' io_decl typespec ranges. One file at a time
// so golden and ours can be diffed as text.
//   r10rgpa <design.uhdm> <modFullNameSubstr> [ifaceNameSubstr]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string cv(const any* e) {
    if (!e) return "<null>";
    if (e->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)e;
        std::string v(c->VpiValue());
        if (v.size() > 30) v = v.substr(0, 30) + "..";
        return "const{" + v + " sz=" + std::to_string(c->VpiSize()) + "}";
    }
    return std::string(UhdmName(e->UhdmType())) + "(" + std::string(e->VpiName()) + ")";
}

static void dumpIf(const interface_inst* i) {
    std::cout << "IFACE " << i->VpiFullName() << " def=" << i->VpiDefName() << "\n";
    if (auto* ps = i->Param_assigns())
        for (auto* pa : *ps)
            std::cout << "  PA lhs=" << (pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "-")
                      << " rhs=" << cv(pa->Rhs())
                      << " ovr=" << pa->VpiOverriden() << "\n";
    if (auto* pv = i->Parameters())
        for (auto* p : *pv)
            std::cout << "  P  " << p->VpiName() << " = "
                      << (p->UhdmType() == uhdmparameter
                              ? std::string(((const parameter*)p)->VpiValue())
                              : std::string("?"))
                      << "\n";
    if (auto* mp = i->Modports())
        for (auto* m : *mp) {
            std::cout << "  MP " << m->VpiName() << " iface="
                      << (m->Interface_inst() ? std::string(m->Interface_inst()->VpiFullName())
                                              : std::string("<null>"))
                      << "\n";
        }
}

static void scanMod(const module_inst* a, const std::string& mw, const std::string& iw) {
    std::string fn(a->VpiFullName());
    if (fn.find(mw) != std::string::npos && a->Interfaces())
        for (auto* i : *a->Interfaces()) {
            std::string in(i->VpiName());
            if (!iw.empty() && in.find(iw) == std::string::npos) continue;
            dumpIf(i);
        }
    if (a->Modules())
        for (auto* m : *a->Modules()) scanMod(m, mw, iw);
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    std::string mw = argc > 2 ? argv[2] : "";
    std::string iw = argc > 3 ? argv[3] : "";
    if (da->TopModules())
        for (auto* t : *da->TopModules()) scanMod(t, mw, iw);
    if (da->AllInterfaces())
        for (auto* i : *da->AllInterfaces()) {
            std::string in(i->VpiFullName());
            if (in.find(mw) != std::string::npos) dumpIf(i);
        }
    return 0;
}
