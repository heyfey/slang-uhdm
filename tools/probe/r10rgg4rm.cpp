// r10rgg4rm: def-view ref_module port census — one row per (module def,
// ref_module, port): the port span plus the High_conn/Low_conn object and,
// for a ref_obj High_conn, whether it carries an Actual_group.
//   r10rgg4rm <file.uhdm> <defname-substring>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const any* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::string want = argv[2];
    if (auto* A = d->AllModules())
        for (auto* m : *A) {
            if (std::string(m->VpiDefName()).find(want) == std::string::npos)
                continue;
            if (!m->Ref_modules()) continue;
            for (auto* rm : *m->Ref_modules()) {
                std::cout << m->VpiDefName() << " | ref_module(" << rm->VpiName()
                          << ") def=" << rm->VpiDefName()
                          << " actual=" << nm(rm->Actual_group()) << "\n";
                if (!rm->Ports()) continue;
                size_t i = 0;
                for (auto* p : *rm->Ports()) {
                    std::cout << "    [" << i++ << "] port(" << p->VpiName()
                              << ")@" << p->VpiLineNo() << ":" << p->VpiColumnNo()
                              << " high=" << nm(p->High_conn())
                              << " low=" << nm(p->Low_conn());
                    if (p->High_conn() &&
                        p->High_conn()->UhdmType() == uhdmref_obj)
                        std::cout << " highActual="
                                  << nm(((const ref_obj*)p->High_conn())
                                            ->Actual_group());
                    std::cout << "\n";
                }
            }
        }
    return 0;
}
