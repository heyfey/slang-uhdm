// r11u119 locdump: every object of a UHDM database as ONE row of the five
// fields the judge never reads and uhdm2rtlil's get_src_attribute does:
//   <type>(<name>) <VpiFile basename or -> <line>.<col>-<endline>.<endcol> <- parent chain
// Rows are sorted (multiset) so two producers' databases diff order-blind.
//   locdump <file.uhdm> [--full] [--val]   (--full keeps the whole VpiFile path;
//   --val appends the raw VpiValue of attributes and constants)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string base(std::string_view f, bool full) {
    if (f.empty()) return "-";
    std::string s(f);
    if (full) return s;
    auto p = s.find_last_of('/');
    return p == std::string::npos ? s : s.substr(p + 1);
}
static std::string span(const BaseClass* o) {
    return std::to_string(o->VpiLineNo()) + "." + std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + "." + std::to_string(o->VpiEndColumnNo());
}
static std::string chain(const BaseClass* o) {
    std::string s;
    int d = 0;
    for (const BaseClass* p = o->VpiParent(); p && d < 6; p = p->VpiParent(), d++)
        s += " <- " + std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) +
             ")@" + std::to_string(p->VpiLineNo()) + "." + std::to_string(p->VpiColumnNo());
    return s;
}
int main(int argc, char** argv) {
    bool full = false, val = false;
    for (int i = 2; i < argc; i++) {
        if (std::string(argv[i]) == "--full") full = true;
        if (std::string(argv[i]) == "--val") val = true;
    }
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        rows.push_back(std::string(UhdmName(obj->UhdmType())) + "(" + std::string(obj->VpiName()) +
                       ") " + base(obj->VpiFile(), full) + " " + span(obj) +
                       (val && obj->UhdmType() == uhdmattribute
                            ? " val=" + std::string(((const attribute*)obj)->VpiValue())
                        : val && obj->UhdmType() == uhdmconstant
                            ? " val=" + std::string(((const constant*)obj)->VpiValue())
                            : "") +
                       chain(obj));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
