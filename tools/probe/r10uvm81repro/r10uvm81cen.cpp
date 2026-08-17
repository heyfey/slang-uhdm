// r10uvm81cen — the CENSUS INSTRUMENT for § pkgSubRefBindsPkgVarOverFormal81.
//
// Reads one .uhdm database with UHDM's own Serializer and walks
// Serializer::AllObjects(), so it sees objects a dump cannot (a dump prints
// only what some parent points at), it reads the FIELD rather than a rendering,
// and it counts each object ONCE (a dump reprints an object at every reference,
// so a census over dump text MULTIPLIES — SimpleUVM's `set_arbitration::val`
// alone is printed three times).
//
// It prints a TOTALS line ALWAYS — including on RESTORE_FAIL, because a run
// that reached nothing must never read as perfection.
//
//   usage: r10uvm81cen <file.uhdm> [tag]
//
//   R10UVM81_LIST=1   one BIND row per reference object that CARRIES a
//                     vpiActual:
//                       BIND <tag> <line>:<col> <refkind> <actualkind>
//                            <actual line:col> <ref fullname> <actual fullname>
//                     Golden and ours are JOINED on (ref fullname, ref
//                     line:col) — a MULTISET join, because 2 346 of SimpleUVM's
//                     objects share a key with another object and a set-valued
//                     join would mask a per-object regression inside a key.
//
//   R10UVM81_NAMES=1  carried from r10uvm80cen: one NAME row per object that
//                     carries a fullname.  This is the per-NAME judge law 2's
//                     canary acceptance test is written against.
//
// The detector this pass is about (reported per-object and in TOTALS):
//   B1  a reference whose vpiActual is an `io_decl`      — the FORMAL binding
//   B2  a reference whose vpiActual is a `variables`     — the VARIABLE binding
// Neither is a defect detector on its own: the DEFECT is a DISAGREEMENT
// between golden and ours, which only the join can see.  A single-side detector
// is a COUNTER and is labelled as one here.

#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <string>

using namespace UHDM;

static std::string kindOf(const any* o) {
    if (!o) return "-";
    return UhdmName(o->UhdmType());
}

// Every object class that carries a cached fullname (r10uvm80cen's list,
// unchanged — the per-NAME judge must not change shape between passes or the
// canary numbers stop being comparable).
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

// A reference object's (fullname, actual).  ref_obj and ref_var are the two
// classes this law can move; both carry Actual_group.
static bool refOf(const any* o, std::string& full, const any*& act) {
    if (auto* r = dynamic_cast<const ref_obj*>(o)) {
        full = r->VpiFullName();
        act = r->Actual_group();
        return true;
    }
    if (auto* r = dynamic_cast<const ref_var*>(o)) {
        full = r->VpiFullName();
        act = r->Actual_group();
        return true;
    }
    return false;
}

static std::string actFull(const any* a) {
    if (!a) return "-";
    std::string f;
    if (fullOf(a, f) && !f.empty()) return f;
    // An io_decl carries no cached fullname; its NAME plus its span is the
    // identity (the span is printed in its own column).
    if (auto* io = dynamic_cast<const io_decl*>(a)) return std::string(io->VpiName());
    return "-";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm81cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    const bool list = getenv("R10UVM81_LIST") != nullptr;
    const bool names = getenv("R10UVM81_NAMES") != nullptr;

    Serializer s;
    long nref = 0, b1 = 0, b2 = 0;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        std::cout << "TOTALS " << tag << " nref=0 b1=0 b2=0\n";
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
        std::string full;
        const any* act = nullptr;
        if (!refOf(o, full, act)) continue;
        if (!act) continue;
        nref++;
        if (act->UhdmType() == uhdmio_decl) b1++;
        else if (dynamic_cast<const variables*>(act)) b2++;
        if (list)
            std::cout << "BIND\t" << tag << "\t" << o->VpiLineNo() << ":"
                      << o->VpiColumnNo() << "\t" << kindOf(o) << "\t"
                      << kindOf(act) << "\t" << act->VpiLineNo() << ":"
                      << act->VpiColumnNo() << "\t" << full << "\t"
                      << actFull(act) << "\n";
    }
    std::cout << "TOTALS " << tag << " nref=" << nref << " b1=" << b1
              << " b2=" << b2 << "\n";
    return 0;
}
