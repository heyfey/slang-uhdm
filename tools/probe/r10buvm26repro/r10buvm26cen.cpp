// r10buvm26 — THE DROPPED-CALL-ON-A-SUBSCRIPTED-RECEIVER CENSUS.
// MEASUREMENT ONLY; nothing here is an acceptance judge (the official
// `uhdm-cmp` and `scripts/verify_golden.py` are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// § droppedIdxRecvCall26's site is where GOLDEN holds a two-element
// `hier_path` [`bit_select`, `method_func_call`] and OURS holds the bare
// `bit_select` alone.  This walks a whole database and prints one row per
// candidate object of EITHER shape, so the two sides can be joined by
// LOCATION in `predict26.py`:
//
//   HP\t<line>:<col>-<eline>:<ecol>\t<path-name>\t<elem0-kind>/<elem0-name>
//      \t<elem1-kind>/<elem1-name>\t<parent-kind>
//   BS\t<line>:<col>-<eline>:<ecol>\t<bit-select-name>\t<parent-kind>
//   MF\t<line>:<col>-<eline>:<ecol>\t<method-name>\t<prefix-name>\t<parent-kind>
//
// The separator is a TAB, never a space: a hier_path NAME can CONTAIN spaces
// (`qu29[i + 1].get_comp` -- an operation index is prettyPrinted with its
// operators spaced), and a space-split join silently shifted those rows.
//
// The FILE is deliberately NOT part of any key: our expression nodes carry an
// EMPTY `VpiFile` (buvm16 §4), so a file-keyed join would drop every row.
// `VpiFullName` is not printed either — no generated `Compare` reads it.
//
// usage: r10buvm26cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>

using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string nm(const any* t) {
    if (!t) return "-";
    std::string n(t->VpiName());
    return n.empty() ? "''" : n;
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10buvm26cen <file.uhdm> [tag]\n";
        return 2;
    }
    const std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        return 3;
    }
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t == uhdmhier_path) {
            const hier_path* h = (const hier_path*)o;
            const VectorOfany* pe = h->Path_elems();
            if (!pe || pe->size() != 2) continue;
            const any* e0 = pe->at(0);
            const any* e1 = pe->at(1);
            if (!e0 || !e1) continue;
            if (e0->UhdmType() != uhdmbit_select) continue;
            if (e1->UhdmType() != uhdmmethod_func_call) continue;
            std::cout << tag << "\tHP\t" << span(h) << "\t" << nm(h) << "\t"
                      << kd(e0) << "/" << nm(e0) << "\t" << kd(e1) << "/"
                      << nm(e1) << "\t" << kd(h->VpiParent()) << "\n";
        }
        else if (t == uhdmbit_select) {
            std::cout << tag << "\tBS\t" << span(o) << "\t" << nm(o) << "\t"
                      << kd(o->VpiParent()) << "\n";
        }
        else if (t == uhdmmethod_func_call) {
            const method_func_call* m = (const method_func_call*)o;
            std::cout << tag << "\tMF\t" << span(m) << "\t" << nm(m) << "\t"
                      << nm(m->Prefix()) << "\t" << kd(m->VpiParent()) << "\n";
        }
    }
    return 0;
}
