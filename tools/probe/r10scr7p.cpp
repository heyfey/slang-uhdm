// r10scr7p: PARAMETER typespec census.  One sorted line per parameter object
// (enclosing instance, name, site) with the typespec its ref_typespec resolves
// to, so `diff golden ours` names exactly the parameters whose typing
// disagrees.
//   r10scr7p <file.uhdm> [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string encl(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmmodule_inst)
            return std::string(((const module_inst*)p)->VpiFullName());
        if (p->UhdmType() == uhdmpackage)
            return std::string(((const package*)p)->VpiFullName());
    }
    return "<noscope>";
}

static std::string tsName(const typespec* t) {
    if (!t) return "<null>";
    std::string r = std::string(UhdmName(t->UhdmType())) + "(" +
                    std::string(t->VpiName()) + ")";
    if (t->UhdmType() == uhdmlogic_typespec) {
        auto* lt = (const logic_typespec*)t;
        r += lt->Ranges() ? "[r" + std::to_string(lt->Ranges()->size()) + "]"
                          : "[scalar]";
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 2 ? argv[2] : "";
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmparameter) continue;
        auto* p = (const parameter*)o;
        std::string n(p->VpiName());
        if (!want.empty() && n.find(want) == std::string::npos) continue;
        auto* rt = p->Typespec();
        rows.push_back(encl(o) + " | " + n + "@" + std::to_string(o->VpiLineNo()) +
                       ":" + std::to_string(o->VpiColumnNo()) + " | ts=" +
                       (rt ? tsName(rt->Actual_typespec()) : std::string("<noref>")));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& x : rows) std::cout << x << "\n";
    return 0;
}
