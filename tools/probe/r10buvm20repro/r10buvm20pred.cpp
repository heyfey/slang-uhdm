// r10buvm20 — THE A-PRIORI MOVER PREDICTOR.  Reads ONLY a GOLDEN database and
// reports the cells § pkgClassOobRetNameBareClone20 can possibly move, so the
// mover set is named BEFORE the patched sweep is looked at.
//
// MEASUREMENT ONLY.
//
// The law's window is the BODY-LOCAL return variable a body reference binds:
//   ref_typespec R  whose VpiParent is a `variables` V
//                   whose VpiParent is a `ref_obj`      (NOT a function --
//                                                        that is vpiReturn)
//   R->Actual_typespec()  a logic_typespec
//   the enclosing subroutine written OUT OF BODY in a package class, which on
//   the GOLDEN side shows up as a ref fullname of the form
//   `pkg::class::method::method` (>= 4 `::`-separated components with the last
//   two equal).
//
// prints one PRED line per cell + a COUNT line.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::vector<std::string> split(std::string_view s) {
    std::vector<std::string> o;
    size_t i = 0;
    while (true) {
        size_t j = s.find("::", i);
        if (j == std::string_view::npos) { o.emplace_back(s.substr(i)); break; }
        o.emplace_back(s.substr(i, j - i));
        i = j + 2;
    }
    return o;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm20pred <golden.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_typespec) continue;
        const ref_typespec* r = (const ref_typespec*)o;
        const any* v = r->VpiParent();
        if (!v || !any_cast<const variables*>(v)) continue;
        const any* p = v->VpiParent();
        if (!p || p->UhdmType() != uhdmref_obj) continue;
        const typespec* a = r->Actual_typespec();
        if (!a || a->UhdmType() != uhdmlogic_typespec) continue;
        auto c = split(r->VpiFullName());
        if (c.size() < 4) continue;
        if (c[c.size() - 1] != c[c.size() - 2]) continue;
        n++;
        std::cout << "PRED " << tag << " " << r->VpiFullName()
                  << " actual=" << UhdmName(a->UhdmType()) << "(" << a->VpiName() << ")"
                  << (a->Typedef_alias() ? " alias" : " noalias") << "\n";
    }
    std::cout << "COUNT " << tag << " " << n << "\n";
    return 0;
}
