// r10pashape: elab param_assign Rhs CONSTANT shapes per instance path.
//   r10pashape <a.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void walk(const std::string& tag, const module_inst* m) {
    if (m->Param_assigns())
        for (auto* pa : *m->Param_assigns()) {
            std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "?";
            std::cout << tag << " " << nm << " = ";
            if (auto* c = any_cast<const constant*>(pa->Rhs()))
                std::cout << (c->Typespec() ? (c->Typespec()->Actual_typespec() ? std::string("TS:")+UhdmName(c->Typespec()->Actual_typespec()->UhdmType()) : std::string("TS:<unbound>")) : std::string("TS:none")) << " constant{" << c->VpiValue() << ",dc="
                          << c->VpiDecompile() << ",sz=" << c->VpiSize()
                          << ",ct=" << c->VpiConstType() << "}";
            else
                std::cout << (pa->Rhs() ? UhdmName(pa->Rhs()->UhdmType())
                                        : "<null>");
            std::cout << "\n";
        }
    if (m->Modules())
        for (auto* c : *m->Modules())
            walk(tag + "." + std::string(c->VpiName()), c);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            walk(std::string("TOP:") + std::string(m->VpiName()), m);
    return 0;
}
