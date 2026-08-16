// r10sd8 — ARTIFACT-BASED MOVER PREDICTION, made BEFORE any delivered database
// is compared.
//
// It restores a database and counts exactly what § importCopyElemVarTsNoInstance8
// rewrites, using only what is visible in the artifact:
//
//   a CLASS-listing variable that is an `array_var` whose NAME is also a
//   PACKAGE-scope variable's name (the import-copy signature sd5 established),
//   whose ELEMENT VARIABLE carries a typespec whose `vpiInstance` names a
//   package OTHER than the class's own home package — i.e. the stamp the clone
//   inherited from the package it was copied out of, which is precisely the
//   gate the code applies.
//
// CALIBRATION (the only thing that makes a predictor worth reading): GOLDEN
// SeqDriver must score 0, our PRISTINE SeqDriver 5, our DELIVERED SeqDriver 0.
//
// GUARD: a database with no class_defns at all is reported, not silently 0.
//
// build: g++ -O2 -std=c++17 ct8pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8pred
// usage: ct8pred <db.uhdm>...      (prints one PREDICT line per database)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>

using namespace UHDM;

static std::string homePkg(const BaseClass* o) {
    for (int i = 0; i < 12 && o; i++) {
        if (o->UhdmType() == uhdmpackage) return std::string(o->VpiName());
        o = o->VpiParent();
    }
    return std::string();
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct8pred <db>...\n"; return 2; }
    int rc = 0;
    for (int a = 1; a < argc; a++) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(argv[a]));
        if (h.empty()) { std::cout << "RESTORE_FAILED " << argv[a] << "\n"; rc = 3; continue; }
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        std::set<std::string> pkgVarNames;
        auto scan = [&](const VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v)
                if (p->Variables())
                    for (auto* x : *p->Variables())
                        if (x && !x->VpiName().empty()) pkgVarNames.insert(std::string(x->VpiName()));
        };
        scan(d->AllPackages());
        scan(d->TopPackages());
        size_t classes = 0, stamped = 0;
        for (const auto& [obj, id] : s.AllObjects()) {
            if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
            auto* cd = (class_defn*)obj;
            classes++;
            if (!cd->Variables()) continue;
            std::string home = homePkg(cd);
            for (auto* v : *cd->Variables()) {
                if (!v || v->UhdmType() != uhdmarray_var) continue;
                if (!pkgVarNames.count(std::string(v->VpiName()))) continue;
                auto* av = (array_var*)v;
                if (!av->Variables()) continue;
                for (auto* ev : *av->Variables()) {
                    if (!ev || !ev->Typespec()) continue;
                    auto* t = ev->Typespec()->Actual_typespec();
                    if (!t || !t->Instance()) continue;
                    if (std::string(t->Instance()->VpiName()) != home) stamped++;
                }
            }
        }
        std::cout << "PREDICT " << argv[a] << "  stamped=" << stamped
                  << "  classes=" << classes
                  << (classes == 0 ? "  [NO CLASS_DEFNS — predictor saw nothing]" : "") << "\n";
    }
    return rc;
}
