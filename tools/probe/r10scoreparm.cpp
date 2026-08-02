// r10scoreparm: list a named package's Parameters / Param_assigns / Typedefs
// side by side (name + type + line), for size-mismatch triage.
//   r10scoreparm <golden.uhdm> <ours.uhdm> <pkgname> [what]
// what: parameters (default) | paramassigns | typespecs | variables | classdefns
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename V>
static std::vector<std::string> names(const V* v) {
    std::vector<std::string> out;
    if (!v) return out;
    for (auto* e : *v) out.push_back(nm(e));
    return out;
}

static const package* find(const design* d, const std::string& n) {
    if (!d->AllPackages()) return nullptr;
    for (auto* p : *d->AllPackages())
        if (std::string(p->VpiName()) == n) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string pn = argv[3];
    std::string what = argc > 4 ? argv[4] : "parameters";
    const package* pa = find(da, pn);
    const package* pb = find(db, pn);
    if (!pa || !pb) {
        std::cout << "package not found\n";
        return 1;
    }
    std::vector<std::string> A, B;
    if (what == "parameters") {
        A = names(pa->Parameters());
        B = names(pb->Parameters());
    } else if (what == "paramassigns") {
        A = names(pa->Param_assigns());
        B = names(pb->Param_assigns());
    } else if (what == "typespecs") {
        A = names(pa->Typespecs());
        B = names(pb->Typespecs());
    } else if (what == "variables") {
        A = names(pa->Variables());
        B = names(pb->Variables());
    } else if (what == "classdefns") {
        A = names(pa->Class_defns());
        B = names(pb->Class_defns());
    } else if (what == "taskfuncs") {
        A = names(pa->Task_funcs());
        B = names(pb->Task_funcs());
    }
    std::cout << "LHS " << A.size() << " RHS " << B.size() << "\n";
    size_t n = A.size() > B.size() ? A.size() : B.size();
    for (size_t i = 0; i < n; i++) {
        std::string a = i < A.size() ? A[i] : "-";
        std::string b = i < B.size() ? B[i] : "-";
        std::cout << (a == b ? "    " : ">>> ") << i << "  " << a << "  |  " << b
                  << "\n";
    }
    return 0;
}
