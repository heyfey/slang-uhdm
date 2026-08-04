// r10rggen6pa: census of param_assign Rhs CONSTANTS — one row per param_assign
// whose Rhs is a constant: owner-instance fullname, Lhs param name, and the
// constant's ConstType / size / decompile / typespec kind.  Run on golden and
// ours and diff to see where Surelog's OVERRIDE fold picks a different literal
// form.
//   r10rggen6pa <file.uhdm> [name-filter]
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

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string filt = argc > 2 ? argv[2] : "";
    std::map<std::string, int> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmparam_assign) continue;
        auto* pa = (const param_assign*)obj;
        if (!pa->Rhs() || pa->Rhs()->UhdmType() != uhdmconstant) continue;
        auto* c = (const constant*)pa->Rhs();
        std::string ln = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "<?>";
        if (!filt.empty() && ln.find(filt) == std::string::npos) continue;
        std::string ts("<null>");
        if (c->Typespec()) {
            const typespec* at = c->Typespec()->Actual_typespec();
            ts = at ? std::string(UhdmName(at->UhdmType()))
                    : std::string("<unbound>");
            const VectorOfrange* rg = nullptr;
            if (at && at->UhdmType() == uhdmbit_typespec)
                rg = ((const bit_typespec*)at)->Ranges();
            else if (at && at->UhdmType() == uhdmlogic_typespec)
                rg = ((const logic_typespec*)at)->Ranges();
            if (rg)
                for (auto* q : *rg) {
                    auto sh = [](const any* e) {
                        if (!e) return std::string("-");
                        if (e->UhdmType() != uhdmconstant)
                            return std::string(UhdmName(e->UhdmType()));
                        auto* k = (const constant*)e;
                        return "c{" + std::to_string(k->VpiConstType()) + "," +
                               std::to_string(k->VpiSize()) + ",'" +
                               std::string(k->VpiDecompile()) + "'," +
                               std::string(k->VpiValue()) + "@" +
                               std::to_string(k->VpiLineNo()) + ":" +
                               std::to_string(k->VpiColumnNo()) + "}";
                    };
                    ts += "[" + sh(q->Left_expr()) + ":" + sh(q->Right_expr()) +
                          "]";
                }
        }
        std::string d(c->VpiDecompile());
        if (d.size() > 24) d = d.substr(0, 24) + "..";
        rows[ownerName(pa) + " | " + ln + " | L" + std::to_string(pa->VpiLineNo()) +
             ":" + std::to_string(pa->VpiColumnNo()) + " | ct=" +
             std::to_string(c->VpiConstType()) + " sz=" +
             std::to_string(c->VpiSize()) + " dec=" + d + " ts=" + ts]++;
    }
    for (auto& [k, v] : rows) std::cout << k << " | x" << v << "\n";
    return 0;
}
