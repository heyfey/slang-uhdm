// r10rggen6pt: census of PARAMETER typespecs — one row per parameter object:
// owner-instance fullname, param name, decl file:line, and the actual typespec
// kind+location.  Run on golden and ours and diff to see where Surelog swaps a
// declared `bit` for a `logic` typespec.
//   r10rggen6pt <file.uhdm> [name-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string ownerName(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (const scope* sc = any_cast<const scope*>(p)) {
            std::string n(sc->VpiFullName());
            if (!n.empty()) return n;
        }
    }
    return "<?>";
}

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string filt = argc > 2 ? argv[2] : "";
    std::map<std::string, int> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmparameter) continue;
        auto* p = (const parameter*)obj;
        std::string n(p->VpiName());
        if (!filt.empty() && n.find(filt) == std::string::npos) continue;
        const typespec* ts = nullptr;
        if (p->Typespec()) ts = p->Typespec()->Actual_typespec();
        std::string cast;
        if (ts && ts->UhdmType() == uhdmint_typespec)
            cast = ((const int_typespec*)ts)->Cast_to_expr() ? " +cast" : " -cast";
        rows[ownerName(p) + " | " + n + " | L" +
             std::to_string(p->VpiLineNo()) + " | " +
             (ts ? std::string(UhdmName(ts->UhdmType())) + "@" +
                       std::to_string(ts->VpiLineNo()) + ":" +
                       std::to_string(ts->VpiColumnNo()) + cast
                 : std::string("<null>"))]++;
    }
    for (auto& [k, v] : rows) std::cout << k << " | x" << v << "\n";
    return 0;
}
