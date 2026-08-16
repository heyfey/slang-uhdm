// r10sd7 — ARTIFACT-BASED MOVER PREDICTION.
//
// Restores a database the PRISTINE sweep produced and counts exactly what the
// patch rewrites: for every variable listed in a `class_defn` whose NAME is also
// listed by some PACKAGE in the same design (the import-copy signature), every
// typespec at DEPTH >= 1 in its typespec subtree — reached through
// `vpiIndexTypespec` / `vpiElemTypespec`, which are the two links the code
// walks — whose `vpiInstance` is NOT null.
//
// CALIBRATION IS THE POINT.  A predicate is only worth quoting if the TARGET
// state scores zero on it:
//
//   golden   SeqDriver  ->  0     (this is what we are converging to)
//   ours     SeqDriver  ->  5     (pristine f0d93e1)
//   ours     SeqDriver  ->  0     (delivered)
//
// It is run over every pristine database BEFORE any delivered database is
// compared, so the mover count is a PREDICTION and not a description.
//
// GUARD: a database that restores to nothing is reported, never counted as 0.
//
// build: g++ -O2 -std=c++17 ct7pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7pred
// usage: ct7pred <db.uhdm> [more...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>

using namespace UHDM;

static int countSub(const typespec* t, int depth) {
    if (!t || depth > 4) return 0;
    int n = (depth > 0 && t->Instance()) ? 1 : 0;
    auto sub = [&](const ref_typespec* r) {
        if (r) n += countSub(r->Actual_typespec(), depth + 1);
    };
    if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)t;
        sub(a->Index_typespec());
        sub(a->Elem_typespec());
    } else if (t->UhdmType() == uhdmpacked_array_typespec) {
        sub(((const packed_array_typespec*)t)->Elem_typespec());
    }
    return n;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7pred <db>...\n"; return 2; }
    size_t files = 0, hits = 0;
    for (int i = 1; i < argc; i++) {
        Serializer s;
        std::error_code ec;
        auto h = s.Restore(std::filesystem::path(argv[i]));
        if (h.empty()) { std::cout << "RESTORE_FAILED " << argv[i] << "\n"; continue; }
        files++;
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        // The import-copy signature: a NAME that some package also lists.
        std::set<std::string> pkgVarNames;
        auto scanPkg = [&](VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v)
                if (p->Variables())
                    for (auto* x : *p->Variables())
                        if (x) pkgVarNames.insert(std::string(x->VpiName()));
        };
        scanPkg(d->AllPackages());
        scanPkg(d->TopPackages());
        int n = 0, cls = 0;
        for (const auto& [obj, id] : s.AllObjects()) {
            if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
            auto* cd = (class_defn*)obj;
            cls++;
            if (!cd->Variables()) continue;
            for (auto* v : *cd->Variables()) {
                if (!v || !v->Typespec()) continue;
                if (!pkgVarNames.count(std::string(v->VpiName()))) continue;
                n += countSub(v->Typespec()->Actual_typespec(), 0);
            }
        }
        if (n) hits++;
        std::cout << (n ? "PREDICT " : "zero    ") << argv[i] << "  stamped=" << n
                  << "  classes=" << cls << "\n";
    }
    std::cout << "[S] databases=" << files << "  predicted movers=" << hits << "\n";
    return 0;
}
