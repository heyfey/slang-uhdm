// r10uvm8a: dump the uhdm-dump subtree of ONE subroutine body, addressed by
//   <all|top> <package> <subroutine> [class]
// so golden and ours can be diffed at exactly the body a differ row named.
// Without a class the subroutine is looked up in the package's Task_funcs;
// with one, in that Class_defn's Task_funcs.
//   r10uvm8a <file.uhdm> <all|top> <pkg> <sub> [class]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cerr << "usage: r10uvm8a <file.uhdm> <all|top> <pkg> <sub> "
                     "[class]\n";
        return 1;
    }
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    bool top = std::string(argv[2]) == "top";
    std::string wpkg = argv[3], wsub = argv[4];
    std::string wcls = argc > 5 ? argv[5] : "";
    auto* pkgs = top ? d->TopPackages() : d->AllPackages();
    if (!pkgs) return 3;
    for (auto* p : *pkgs) {
        if (std::string(p->VpiName()) != wpkg &&
            std::string(p->VpiDefName()) != wpkg)
            continue;
        const VectorOftask_func* tfs = p->Task_funcs();
        if (!wcls.empty()) {
            tfs = nullptr;
            if (auto* cs = p->Class_defns())
                for (auto* c : *cs) {
                    std::string cn(c->VpiName());
                    if (cn == wcls || cn.size() > wcls.size() +
                                          2 &&
                                          cn.rfind("::" + wcls) ==
                                              cn.size() - wcls.size() - 2)
                        tfs = c->Task_funcs();
                }
        }
        if (!tfs) { std::cerr << "no such class\n"; return 2; }
        for (auto* tf : *tfs) {
            std::string n(tf->VpiName());
            if (n != wsub &&
                !(n.size() > wsub.size() + 2 &&
                  n.rfind("::" + wsub) == n.size() - wsub.size() - 2))
                continue;
            uhdm_handle h(tf->UhdmType(), tf);
            visit_object((vpiHandle)&h, std::cout);
            return 0;
        }
        std::cerr << "no such subroutine\n";
        return 2;
    }
    std::cerr << "no such package\n";
    return 3;
}
