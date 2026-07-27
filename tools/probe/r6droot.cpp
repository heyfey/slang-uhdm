// Design-root container inventory: every design-level vector, size + members.
// Answers "which design vector is null/short on our side" for the
// design-root-family (cmptool first-fail at design(X) itself).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void lst(const std::string& tag, const V* v) {
    if (!v) { std::cout << tag << " <null>\n"; return; }
    std::cout << tag << " n=" << v->size() << "\n";
    int i = 0;
    for (auto* e : *v)
        std::cout << tag << "[" << i++ << "] " << UhdmName(e->UhdmType())
                  << " name='" << e->VpiName() << "' def='" << e->VpiDefName()
                  << "'\n";
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r6droot <file.uhdm>\n"; return 2; }
    Serializer s;
    std::vector<vpiHandle> hs = s.Restore(std::string(argv[1]));
    if (hs.empty()) { std::cerr << "restore failed\n"; return 1; }
    std::cout << "designs n=" << hs.size() << "\n";
    int di = 0;
    for (vpiHandle h : hs) {
        const design* d = (const design*)((const uhdm_handle*)h)->object;
        std::string t = "D" + std::to_string(di++);
        std::cout << t << ".name='" << d->VpiName() << "' def='"
                  << d->VpiDefName() << "' elab=" << d->VpiElaborated() << "\n";
        lst(t + ".IncludeFileInfos", d->Include_file_infos());
        lst(t + ".AllPackages", d->AllPackages());
        lst(t + ".TopPackages", d->TopPackages());
        lst(t + ".AllClasses", d->AllClasses());
        lst(t + ".AllInterfaces", d->AllInterfaces());
        lst(t + ".AllUdps", d->AllUdps());
        lst(t + ".AllPrograms", d->AllPrograms());
        lst(t + ".AllModules", d->AllModules());
        lst(t + ".Typespecs", d->Typespecs());
        lst(t + ".LetDecls", d->Let_decls());
        lst(t + ".TaskFuncs", d->Task_funcs());
        lst(t + ".Parameters", d->Parameters());
        lst(t + ".ParamAssigns", d->Param_assigns());
        lst(t + ".TopModules", d->TopModules());
    }
    return 0;
}
