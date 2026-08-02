// r10uvmlist: dump one package vector's element names (type(name)@line:col)
// one per line, so two runs can be diffed with plain `diff`.
//   r10uvmlist <db.uhdm> <pkgname> <Variables|Task_funcs|Typespecs|Parameters>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename V>
static void dump(const V* v) {
    if (!v) return;
    for (size_t i = 0; i < v->size(); i++) std::cout << nm((*v)[i]) << "\n";
}

static const package* find(const design* d, const std::string& n) {
    bool top = false;
    std::string want = n;
    if (want.size() > 4 && want.compare(0, 4, "top:") == 0) {
        top = true;
        want = want.substr(4);
    }
    const VectorOfpackage* v = top ? d->TopPackages() : d->AllPackages();
    if (!v) return nullptr;
    for (auto* p : *v)
        if (std::string(p->VpiName()) == want) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    const package* a = find(da, argv[2]);
    if (!a) { std::cout << "package not found\n"; return 1; }
    std::string w = argv[3];
    if (w == "Variables") dump(a->Variables());
    else if (w == "Task_funcs") dump(a->Task_funcs());
    else if (w == "Typespecs") dump(a->Typespecs());
    else if (w == "Parameters") dump(a->Parameters());
    else if (w == "Class_defns") dump(a->Class_defns());
    else if (w == "Nets") dump(a->Nets());
    return 0;
}
