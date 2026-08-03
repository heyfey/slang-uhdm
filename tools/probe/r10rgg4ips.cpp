// r10rgg4ips: census of indexed_part_select objects in a .uhdm — every field
// uhdm-cmp looks at plus spans/parents, so the golden's shape for
// `RIF.read_mask[LSB+:WIDTH]` inside a macro-expanded gen-block cont_assign can
// be copied exactly.
//   r10rgg4ips <file.uhdm> [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo()) + "-" +
                    std::to_string(o->VpiEndLineNo()) + ":" +
                    std::to_string(o->VpiEndColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)o;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" +
             std::string(c->VpiDecompile()) + "' val='" +
             std::string(c->VpiValue()) + "'}";
    }
    return s;
}

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 2 ? argv[2] : "";
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmindexed_part_select) continue;
        auto* p = (const indexed_part_select*)o;
        std::string full(p->VpiFullName());
        if (!want.empty() && full.find(want) == std::string::npos &&
            std::string(p->VpiName()).find(want) == std::string::npos)
            continue;
        rows.push_back(
            nm(p) + " full='" + full + "'" +
            " type=" + std::to_string(p->VpiIndexedPartSelectType()) +
            " constSel=" + std::to_string(p->VpiConstantSelect()) +
            " parent=" + nm(p->VpiParent()) + "\n    base=" +
            nm(p->Base_expr()) + "\n    width=" + nm(p->Width_expr()) +
            "\n    baseParent=" +
            nm(p->Base_expr() ? p->Base_expr()->VpiParent() : nullptr) +
            " widthParent=" +
            nm(p->Width_expr() ? p->Width_expr()->VpiParent() : nullptr));
    }
    std::sort(rows.begin(), rows.end());
    rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
    std::cout << "COUNT " << rows.size() << " unique shapes\n";
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
