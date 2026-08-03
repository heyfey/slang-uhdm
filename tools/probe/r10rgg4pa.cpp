// r10rgg4pa: param_assign LISTING order for one module def and every elaborated
// instance of it — Lhs name + span, in vector order.  Ranks the "materialized
// imported params sort AFTER the body params in the ELAB view but BEFORE them
// in the DEF view" question.
//   r10rgg4pa <file.uhdm> <defname-substring>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dump(const module_inst* m, const std::string& tag) {
    std::cout << tag << " " << m->VpiDefName() << " / " << m->VpiFullName()
              << " top=" << m->VpiTop() << "\n";
    if (!m->Param_assigns()) return;
    size_t i = 0;
    for (auto* pa : *m->Param_assigns()) {
        const any* l = pa->Lhs();
        std::cout << "   [" << i++ << "] "
                  << (l ? std::string(l->VpiName()) : std::string("<null>"))
                  << " @" << pa->VpiLineNo() << ":" << pa->VpiColumnNo()
                  << (l && l->UhdmType() == uhdmparameter &&
                              ((const parameter*)l)->VpiImported().empty()
                          ? ""
                          : " IMPORTED")
                  << "\n";
    }
}

static void walk(const module_inst* m, const std::string& want,
                 const std::string& tag) {
    if (std::string(m->VpiDefName()).find(want) != std::string::npos)
        dump(m, tag);
    if (m->Modules())
        for (auto* c : *m->Modules())
            walk(c, want, tag + "." + std::string(c->VpiName()));
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::string want = argv[2];
    if (auto* A = d->AllModules())
        for (auto* m : *A)
            if (std::string(m->VpiDefName()).find(want) != std::string::npos)
                dump(m, "DEF");
    if (auto* T = d->TopModules())
        for (auto* m : *T) walk(m, want, "ELAB");
    return 0;
}
