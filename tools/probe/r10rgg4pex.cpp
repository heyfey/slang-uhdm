// r10rgg4pex: def-view parameter singular-field census — Expr / Left_range /
// Right_range / Ranges per (module def, parameter).  Ranks the "unlocated
// ref_obj hanging off some parameters and not others" class.
//   r10rgg4pex <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
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
    std::vector<std::string> rows;
    if (auto* A = d->AllModules())
        for (auto* m : *A) {
            if (!m->Parameters()) continue;
            for (auto* p : *m->Parameters()) {
                if (p->UhdmType() != uhdmparameter) continue;
                auto* pp = (const parameter*)p;
                const typespec* ts =
                    pp->Typespec() ? pp->Typespec()->Actual_typespec() : nullptr;
                std::string cast = "-";
                if (ts && ts->UhdmType() == uhdmint_typespec)
                    cast = nm(((const int_typespec*)ts)->Cast_to_expr());
                rows.push_back(
                    std::string(m->VpiDefName()) + " | " +
                    std::string(pp->VpiName()) + "@" +
                    std::to_string(pp->VpiLineNo()) + " | ts=" + nm(ts) +
                    " cast_to_expr=" + cast);
            }
        }
    std::sort(rows.begin(), rows.end());
    rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
