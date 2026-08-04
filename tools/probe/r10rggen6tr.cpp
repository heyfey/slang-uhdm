// r10rggen6tr: census of PARAMETER typespec RANGE bounds — one row per
// parameter whose (actual) typespec carries ranges: owner fullname, name, and
// each range's Left/Right object kind (+ value when constant).  Shows where an
// ELABORATED copy folds a symbolic bound to a constant.
//   r10rggen6tr <file.uhdm> [name-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string ownerName(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (const scope* sc = any_cast<const scope*>(p)) {
            std::string n(sc->VpiFullName());
            if (!n.empty()) return n;
        }
    return "<?>";
}

static std::string ex(const any* e) {
    if (!e) return "<null>";
    std::string s(UhdmName(e->UhdmType()));
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        s += "{ct=" + std::to_string(c->VpiConstType()) + " sz=" +
             std::to_string(c->VpiSize()) + " " + std::string(c->VpiDecompile()) +
             "}";
    }
    return s;
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
        const typespec* ts = p->Typespec() ? p->Typespec()->Actual_typespec() : nullptr;
        if (!ts) continue;
        const VectorOfrange* rg = nullptr;
        if (ts->UhdmType() == uhdmbit_typespec)
            rg = ((const bit_typespec*)ts)->Ranges();
        else if (ts->UhdmType() == uhdmlogic_typespec)
            rg = ((const logic_typespec*)ts)->Ranges();
        else if (ts->UhdmType() == uhdmint_typespec)
            rg = nullptr;
        std::string r = "no-ranges";
        if (rg) {
            r.clear();
            for (auto* q : *rg)
                r += "[" + ex(q->Left_expr()) + ":" + ex(q->Right_expr()) + "]";
        }
        rows[ownerName(p) + " | " + n + " | " +
             std::string(UhdmName(ts->UhdmType())) + "@" +
             std::to_string(ts->VpiLineNo()) + " | " + r]++;
    }
    for (auto& [k, v] : rows) std::cout << k << " | x" << v << "\n";
    return 0;
}
