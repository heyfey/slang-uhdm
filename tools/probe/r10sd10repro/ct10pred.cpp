// r10sd10 — THE VARIABLE-KIND CENSUS and ARTIFACT-BASED MOVER PREDICTION for
// § classTdLocalVarKindFollowsCompileOrder10.
//
// The law changes exactly ONE thing about a variable: its OBJECT CLASS.  Name,
// full name, span, parent and typespec are identical in every arm.  So the
// population it can move is readable from the two artifacts alone: join every
// `variables` object of the two databases on (vpiFullName, line:col) — a total
// key, since a declaration produces one variable at one place — and report the
// rows where the two sides disagree about the CLASS.
//
// FOUR BUCKETS, and they are not interchangeable:
//   G_CLASSVAR  golden class_var, ours something else  <- the fix CONVERTS these
//   G_REFVAR    golden ref_var,   ours something else  <- ditto
//   O_CLASSVAR  ours class_var,   golden something else <- an OVER-fire of ours
//   O_REFVAR    ours ref_var,     golden something else <- ditto
// A pass that only counted "kind differs" would net an over-fire against an
// under-fire and read as progress while moving nothing.
//
// WHAT THIS INSTRUMENT CANNOT DO, STATED FIRST.  It sees the CLASS disagreement
// and not its CAUSE: golden's `class_var` at a given place may come from this
// law or from any other arm of Surelog's compileVariable, and `ref_var` in
// particular is also § aliasClassRefVar10's and § typeParamRetIsRefVar58's
// answer.  The number is therefore a SUPERSET of the movable set, and the
// procedure that closes it is the same one r10sd9 used: score PRISTINE and
// DELIVERED with the same instrument and let the DIFFERENCE be the claim.
//
// CALIBRATION IS PART OF THE INSTRUMENT: golden-vs-golden must be 0.
//
// build: g++ -O2 -std=c++17 ct10pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct10pred
// usage: ct10pred <golden.uhdm> <ours.uhdm> [-v]
// The machine-readable line is `[S] KINDS ...`.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>

using namespace UHDM;

namespace {

struct DB {
    Serializer s;
    design* d = nullptr;
    std::map<std::string, std::string> kinds;  // fullname@line:col -> uhdm class
};

void load(const char* path, DB& db) {
    auto h = db.s.Restore(std::filesystem::path(path));
    if (h.empty()) {
        std::cerr << "RESTORE FAILED " << path << "\n";
        exit(3);
    }
    db.d = (design*)((uhdm_handle*)h[0])->object;
    for (const auto& [obj, id] : db.s.AllObjects()) {
        if (!obj)
            continue;
        // `any_cast` is IS-A; dispatch on the object's own UhdmType and take
        // every leaf variable class there is by asking whether the object is a
        // `variables` through the serializer's own name table.
        auto* v = dynamic_cast<const variables*>(obj);
        if (!v)
            continue;
        std::string fn(v->VpiFullName());
        if (fn.empty())
            fn = std::string(v->VpiName());
        if (fn.empty())
            continue;
        std::string key = fn + "@" + std::to_string(v->VpiLineNo()) + ":" +
                          std::to_string(v->VpiColumnNo());
        // A duplicated key would silently drop a row; mark it instead so the
        // count can never quietly shrink.
        auto it = db.kinds.find(key);
        if (it != db.kinds.end() && it->second != UhdmName(v->UhdmType()))
            it->second = "<AMBIGUOUS>";
        else
            db.kinds[key] = UhdmName(v->UhdmType());
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct10pred <golden.uhdm> <ours.uhdm> [-v]\n";
        return 2;
    }
    bool verbose = argc > 3 && std::string(argv[3]) == "-v";
    DB g, o;
    load(argv[1], g);
    load(argv[2], o);
    size_t shared = 0, same = 0, gClass = 0, gRef = 0, oClass = 0, oRef = 0,
           other = 0, amb = 0;
    for (auto& [k, gk] : g.kinds) {
        auto it = o.kinds.find(k);
        if (it == o.kinds.end())
            continue;
        shared++;
        const std::string& ok = it->second;
        if (gk == ok) {
            same++;
            continue;
        }
        if (gk == "<AMBIGUOUS>" || ok == "<AMBIGUOUS>") {
            amb++;
            continue;
        }
        const char* bucket = nullptr;
        if (gk == "class_var")
            bucket = "G_CLASSVAR", gClass++;
        else if (gk == "ref_var")
            bucket = "G_REFVAR", gRef++;
        else if (ok == "class_var")
            bucket = "O_CLASSVAR", oClass++;
        else if (ok == "ref_var")
            bucket = "O_REFVAR", oRef++;
        else
            bucket = "OTHER", other++;
        if (verbose)
            std::cout << bucket << "  " << k << "\n    G " << gk << "\n    O "
                      << ok << "\n";
    }
    if (!shared) {
        std::cout << "[S] KINDS shared=0\nREFUSING TO REPORT: empty join\n";
        return 5;
    }
    std::cout << "[S] KINDS shared=" << shared << " same=" << same
              << " G_CLASSVAR=" << gClass << " G_REFVAR=" << gRef
              << " O_CLASSVAR=" << oClass << " O_REFVAR=" << oRef
              << " OTHER=" << other << " AMBIG=" << amb << "\n";
    return 0;
}
