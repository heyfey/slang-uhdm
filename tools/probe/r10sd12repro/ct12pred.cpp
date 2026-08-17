// r10sd12 — THE DECLARATOR-ARRAY ELEMENT-VARIABLE KIND CENSUS and
// ARTIFACT-BASED MOVER PREDICTION for § declArrayElemKindIsDeclKind12.
//
// WHY A NEW INSTRUMENT AND NOT r10sd10's ct10pred.  ct10pred keys every
// `variables` object on (vpiFullName, line:col) and calls a COLLIDING key
// `<AMBIGUOUS>`.  A declarator array is exactly a collision: the `array_var`
// and its ELEMENT variable carry the SAME vpiFullName and the SAME
// line:col (Surelog's CompileStmt populates both from the declarator NAME
// node).  So the whole population this pass moves lands in ct10pred's AMBIG
// bucket and is INVISIBLE there — measured, not assumed: on `default/SeqDriver`
// ct10pred reports `G_CLASSVAR=0 ... AMBIG=8` while the cmp head at
// uvm_resource.svh:955:34 is precisely a golden `class_var` against our
// `ref_var` under an `array_var`.  AN INSTRUMENT THAT CANNOT SEE THE HEAD
// CANNOT PREDICT THE MOVERS.
//
// THIS instrument therefore joins on the ARRAY_VAR and reports the classes of
// the variables hanging under its `vpiReg` (`Variables()`), which is where the
// element lives:
//
//   key   = <array_var vpiFullName>@<line>:<col>
//   value = the ORDERED list of UHDM class names of that array_var's elements
//
// FIVE BUCKETS, never netted:
//   G_CLASSVAR  golden's element is a class_var, ours is not   <- this pass
//   G_REFVAR    golden's element is a ref_var,   ours is not
//   O_CLASSVAR  OURS is a class_var and golden is not          <- an OVER-fire
//   O_REFVAR    OURS is a ref_var and golden is not
//   ELEM_COUNT  the two sides disagree about HOW MANY elements the array has
//               (a structural difference this pass must never create)
//
// WHAT THIS INSTRUMENT CANNOT DO, STATED FIRST.  Like every census in this
// campaign it sees the DISAGREEMENT and not its CAUSE: golden's `class_var`
// element may equally come from a bare class NAME written at the declaration,
// which is not this law's arm at all.  The number is a SUPERSET of the movable
// set and the claim is the DIFFERENCE between the pristine and delivered
// scores measured with the SAME binary of this tool.
//
// CALIBRATION IS PART OF THE INSTRUMENT: golden-vs-golden must be 0 in every
// bucket, and an EMPTY JOIN is exit 5, not a clean score.
//
// build: g++ -O2 -std=c++17 ct12pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct12pred
// usage: ct12pred <golden.uhdm> <ours.uhdm> [-v]
// The machine-readable line is `[S] ELEM ...`.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

namespace {

struct DB {
    Serializer s;
    design* d = nullptr;
    // array_var key -> the element classes, in listing order.
    std::map<std::string, std::vector<std::string>> elems;
};

std::string join(const std::vector<std::string>& v) {
    std::string r;
    for (auto& e : v) {
        if (!r.empty())
            r += ",";
        r += e;
    }
    return r.empty() ? std::string("<none>") : r;
}

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
        // `any_cast` is IS-A; ask the object's OWN UhdmType so a subclass of
        // array_var (there is none today) could not silently join this set.
        if (obj->UhdmType() != uhdmarray_var)
            continue;
        auto* av = (const array_var*)obj;
        std::string fn(av->VpiFullName());
        if (fn.empty())
            fn = std::string(av->VpiName());
        if (fn.empty())
            continue;
        std::string key = fn + "@" + std::to_string(av->VpiLineNo()) + ":" +
                          std::to_string(av->VpiColumnNo());
        std::vector<std::string> kinds;
        if (auto* vs = av->Variables())
            for (auto* v : *vs)
                kinds.push_back(v ? UhdmName(v->UhdmType())
                                  : std::string("<null>"));
        auto it = db.elems.find(key);
        if (it != db.elems.end() && it->second != kinds)
            it->second = {"<AMBIGUOUS>"};
        else
            db.elems[key] = kinds;
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct12pred <golden.uhdm> <ours.uhdm> [-v]\n";
        return 2;
    }
    bool verbose = argc > 3 && std::string(argv[3]) == "-v";
    DB g, o;
    load(argv[1], g);
    load(argv[2], o);
    size_t shared = 0, same = 0, gClass = 0, gRef = 0, oClass = 0, oRef = 0,
           count = 0, other = 0, amb = 0;
    for (auto& [k, gv] : g.elems) {
        auto it = o.elems.find(k);
        if (it == o.elems.end())
            continue;
        shared++;
        const std::vector<std::string>& ov = it->second;
        if (gv == ov) {
            same++;
            continue;
        }
        if ((gv.size() == 1 && gv[0] == "<AMBIGUOUS>") ||
            (ov.size() == 1 && ov[0] == "<AMBIGUOUS>")) {
            amb++;
            continue;
        }
        const char* bucket = nullptr;
        if (gv.size() != ov.size())
            bucket = "ELEM_COUNT", count++;
        else {
            // The classes disagree at some position; bucket on the FIRST
            // disagreement, golden-side first so an over-fire can never be
            // netted against an under-fire.
            size_t i = 0;
            while (i < gv.size() && gv[i] == ov[i])
                i++;
            if (gv[i] == "class_var")
                bucket = "G_CLASSVAR", gClass++;
            else if (gv[i] == "ref_var")
                bucket = "G_REFVAR", gRef++;
            else if (ov[i] == "class_var")
                bucket = "O_CLASSVAR", oClass++;
            else if (ov[i] == "ref_var")
                bucket = "O_REFVAR", oRef++;
            else
                bucket = "OTHER", other++;
        }
        if (verbose)
            std::cout << bucket << "  " << k << "\n    G " << join(gv)
                      << "\n    O " << join(ov) << "\n";
    }
    if (!shared) {
        std::cout << "[S] ELEM shared=0 EMPTY-JOIN\n"
                     "REFUSING TO REPORT: empty join\n";
        return 5;
    }
    std::cout << "[S] ELEM shared=" << shared << " same=" << same
              << " G_CLASSVAR=" << gClass << " G_REFVAR=" << gRef
              << " O_CLASSVAR=" << oClass << " O_REFVAR=" << oRef
              << " ELEM_COUNT=" << count << " OTHER=" << other
              << " AMBIG=" << amb << "\n";
    return 0;
}
