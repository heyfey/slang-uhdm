// r10sd7 — THE OWNER CENSUS.  Every `array_var` in the WHOLE serializer, with
// the object identity of its typespec chain and that typespec's `vpiInstance`.
//
// WHY IT EXISTS.  `ct4bt`'s watchpoint (sd4's method, re-run here) reads the
// failing frame:
//
//     #0 typespec::Compare           <- the singular vpiInstance arm
//     #1 array_typespec::Compare
//     #2 variables::Compare
//     #3 array_var::Compare
//     #4 SafeCompare<variables>      <- scope::Compare's Variables VECTOR
//     #5 scope::Compare
//     #6 class_defn::Compare
//
// so the failing object is an `array_typespec` owned by an `array_var` listed in
// a `class_defn`'s `Variables`.  But `ct5cls` — which walks `AllClasses()` —
// reports the class listings AGREEING cell for cell on that name.  Both readings
// cannot be true of the same object, so the population `ct5cls` walks is not the
// population `Compare` reaches.  This tool drops the reachability assumption
// entirely and walks `Serializer::AllObjects()`.
//
// GUARD (measure the measurer): zero array_vars is a hard error — an empty
// population agrees with anything.
//
// build: g++ -O2 -std=c++17 ct7own.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7own
// usage: ct7own <db.uhdm> [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    if (!p) return "-";
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7own <db> [filter]\n"; return 2; }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }

    // Every class_defn in the serializer, and the vars it lists, keyed by the
    // OWNER CLASS so golden and ours can be joined by name rather than pointer.
    std::map<std::string, int> summary;
    size_t nvar = 0, ncls = 0;
    // ORDER-PRESERVING.  `scope::Compare` walks the `Variables` VECTOR
    // ELEMENT-WISE BY INDEX, so a sorted (multiset) census is blind to exactly
    // the failure mode a vector compare reports: two listings that hold the same
    // entries in a different ORDER mismatch at the first index where they
    // diverge, and every per-key census reads them as agreeing.
    std::map<std::string, std::vector<std::string>> rows;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto* cd = (class_defn*)obj;
        if (obj->UhdmType() != uhdmclass_defn) continue;
        ncls++;
        auto* vs = cd->Variables();
        if (!vs) continue;
        for (auto* v : *vs) {
            if (!v) continue;
            std::string vn(v->VpiName());
            if (!filt.empty() && vn.find(filt) == std::string::npos) continue;
            nvar++;
            const typespec* ats = nullptr;
            if (auto* rt = v->Typespec()) ats = rt->Actual_typespec();
            const instance* in = ats ? ats->Instance() : nullptr;
            std::string inm = in ? std::string(in->VpiName()) : "<null>";
            std::string row = std::string(UhdmName(v->UhdmType())) + " " + vn + "@" +
                              span(v) + "  ats=" + ident(ats) + "  inst=" + inm;
            rows[std::string(cd->VpiFullName().empty() ? cd->VpiName()
                                                       : cd->VpiFullName()) +
                 "@" + span(cd)]
                .push_back(row);
            summary["inst=" + inm]++;
        }
    }
    for (auto& [k, v] : rows) {
        std::cout << "== " << k << "\n";
        for (auto& r : v) std::cout << "   " << r << "\n";
    }
    std::cout << "[S] class_defn objects=" << ncls << "  matching vars=" << nvar << "\n";
    for (auto& [k, n] : summary) std::cout << "    " << k << "  " << n << "\n";
    if (nvar == 0) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
