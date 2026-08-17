// r10uvm80cen — the pass's CENSUS INSTRUMENT for vpiAutomatic on VARIABLES.
//
// Reads one .uhdm database with UHDM's own Serializer and walks
// Serializer::AllObjects(), so it sees objects a dump cannot (a dump prints
// only what some parent points at), it reads the FIELD rather than a
// rendering, and it counts each object ONCE (a dump reprints an object at
// every reference, so a shape census over dump text multiplies).
//
// It prints a TOTALS line ALWAYS — including on RESTORE_FAIL, because a run
// that reached nothing must never read as perfection.
//
//   usage: r10uvm80cen <file.uhdm> [tag]
//
//   R10UVM80_NAMES=1  one NAME row per object that CARRIES a fullname (ref_obj,
//                     bit_select, part_select, indexed_part_select, var_select,
//                     hier_path, variables).  This is the cheap substitute for
//                     `uhdm-dump | grep vpiFullName` on the very large
//                     databases: Earlgrey's dump is a QUARTER OF A GIGABYTE of
//                     text and takes tens of minutes per read, while the
//                     serializer restore takes about a minute — and the dump
//                     reprints an object at every reference, which this does
//                     not.
//
//   R10UVM80_LIST=1   one VAR row per `variables` object:
//                       VAR <tag> <file> <line>:<col> <auto> <kind> <parentkind> <fullname>
//                     This is the AUTHORITATIVE instrument: golden and ours are
//                     JOINED on (file, line:col, fullname) and the vpiAutomatic
//                     columns compared, so every claim is read off the artifact
//                     instead of off a text predicate.
//
// Detectors (both are reported per-object and in TOTALS):
//   A1  a variable whose vpiAutomatic is SET and whose vpiParent is an
//       ASSIGNMENT — the corpus head's shape (a block-scope declaration with an
//       initializer re-parents its variable onto the decl assignment).
//   A2  a variable whose vpiAutomatic is SET, any parent — the population the
//       fix could move.
// Neither is a "defect" detector on its own: the DEFECT is a DISAGREEMENT
// between golden and ours, which only the join can see.  A detector that reads
// a single side is a counter, and it is labelled as one here.

#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <string>

using namespace UHDM;

// Every object class that carries a cached fullname; the joint family's laws
// are all ABOUT these strings, so this is the instrument that judges them.
static bool fullOf(const any* o, std::string& out) {
    if (!o) return false;
    if (auto* r = dynamic_cast<const ref_obj*>(o)) { out = r->VpiFullName(); return true; }
    if (auto* b = dynamic_cast<const bit_select*>(o)) { out = b->VpiFullName(); return true; }
    if (auto* p = dynamic_cast<const part_select*>(o)) { out = p->VpiFullName(); return true; }
    if (auto* i = dynamic_cast<const indexed_part_select*>(o)) { out = i->VpiFullName(); return true; }
    if (auto* v = dynamic_cast<const var_select*>(o)) { out = v->VpiFullName(); return true; }
    if (auto* h = dynamic_cast<const hier_path*>(o)) { out = h->VpiFullName(); return true; }
    if (auto* v = dynamic_cast<const variables*>(o)) { out = v->VpiFullName(); return true; }
    return false;
}

static std::string kindOf(const any* o) {
    if (!o) return "-";
    return UhdmName(o->UhdmType());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm80cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    const bool list = getenv("R10UVM80_LIST") != nullptr;
    const bool names = getenv("R10UVM80_NAMES") != nullptr;

    Serializer s;
    long nvar = 0, a1 = 0, a2 = 0;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        std::cout << "TOTALS " << tag << " nvar=0 a1=0 a2=0\n";
        return 3;
    }
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (names) {
            std::string f;
            if (fullOf(o, f) && !f.empty())
                std::cout << "NAME\t" << f << "\n";
        }
        auto* v = dynamic_cast<const variables*>(o);
        if (!v) continue;
        nvar++;
        const bool au = v->VpiAutomatic();
        const any* par = v->VpiParent();
        if (au) {
            a2++;
            if (par && par->UhdmType() == uhdmassignment) a1++;
        }
        if (list)
            std::cout << "VAR\t" << tag << "\t" << v->VpiFile() << "\t"
                      << v->VpiLineNo() << ":" << v->VpiColumnNo() << "\t"
                      << (au ? 1 : 0) << "\t" << kindOf(v) << "\t"
                      << kindOf(par) << "\t" << v->VpiFullName() << "\n";
    }
    std::cout << "TOTALS " << tag << " nvar=" << nvar << " a1=" << a1
              << " a2=" << a2 << "\n";
    return 0;
}
