// r10sd11 — THE VARIABLE-TYPESPEC CENSUS and ARTIFACT-BASED MOVER PREDICTION
// for § classScopedTdLocalTsUnsupported11.
//
// The law changes exactly ONE thing about a declaration: the object its
// `vpiTypespec` ref_typespec points at.  The variable itself — class, name,
// full name, span, parent — is untouched (r10sd10 already put the variable
// CLASS where golden has it).  So the population this pass can move is
// readable from the two artifacts alone: join every `variables` object of the
// two databases on (vpiFullName, line:col) — a total key, since a declaration
// produces one variable at one place — and report the rows where the two sides
// disagree about the BOUND TYPESPEC.
//
// FIVE BUCKETS, never netted:
//   G_UNSUP   golden binds an unsupported_typespec, ours binds something else
//             <- exactly what this pass converts
//   O_UNSUP   OURS binds an unsupported_typespec and golden does not
//             <- an OVER-fire; must stay 0 -> 0
//   TS_KIND   both bind a real typespec, different UHDM class
//   TS_NAME   same class, different vpiName
//   TS_SPAN   same class and name, different line:col
// A pass that only counted "typespec differs" would net an over-fire against
// an under-fire and read as progress while moving nothing.
//
// WHAT THIS INSTRUMENT CANNOT DO, STATED FIRST.  It sees the disagreement and
// not its CAUSE: golden's `unsupported_typespec` at a given place may come from
// this law or from any other arm of Surelog's compileTypespec catch-all (the
// type-parameter families § oobParamClassTypeParamFormalUnsupported31 and
// § baseClassTypeParamFormalUnsupported34 mint the same object class).  The
// number is therefore a SUPERSET of the movable set, and the procedure that
// closes it is the one r10sd9/r10sd10 used: score PRISTINE and DELIVERED with
// the same instrument and let the DIFFERENCE be the claim.
//
// CALIBRATION IS PART OF THE INSTRUMENT: golden-vs-golden must be 0.
//
// build: g++ -O2 -std=c++17 ct11pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct11pred
// usage: ct11pred <golden.uhdm> <ours.uhdm> [-v]
// The machine-readable line is `[S] TS ...`.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>

using namespace UHDM;

namespace {

struct Row {
    std::string kind;  // UHDM class of the ACTUAL typespec ("<none>" if unbound)
    std::string name;  // its vpiName
    std::string loc;   // line:col of the typespec
};

struct DB {
    Serializer s;
    design* d = nullptr;
    std::map<std::string, Row> rows;
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
        // `any_cast` is IS-A; ask whether the object is a `variables` through
        // the C++ hierarchy rather than enumerating every leaf class by hand.
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
        Row r;
        r.kind = "<none>";
        if (const ref_typespec* rt = v->Typespec())
            if (const typespec* ts = rt->Actual_typespec()) {
                r.kind = UhdmName(ts->UhdmType());
                r.name = std::string(ts->VpiName());
                r.loc = std::to_string(ts->VpiLineNo()) + ":" +
                        std::to_string(ts->VpiColumnNo());
            }
        auto it = db.rows.find(key);
        // A duplicated key would silently drop a row; mark it instead so the
        // count can never quietly shrink.
        if (it != db.rows.end() &&
            (it->second.kind != r.kind || it->second.name != r.name ||
             it->second.loc != r.loc))
            it->second.kind = "<AMBIGUOUS>";
        else
            db.rows[key] = r;
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct11pred <golden.uhdm> <ours.uhdm> [-v]\n";
        return 2;
    }
    bool verbose = argc > 3 && std::string(argv[3]) == "-v";
    DB g, o;
    load(argv[1], g);
    load(argv[2], o);
    size_t shared = 0, same = 0, gUn = 0, oUn = 0, tsKind = 0, tsName = 0,
           tsSpan = 0, amb = 0;
    for (auto& [k, gr] : g.rows) {
        auto it = o.rows.find(k);
        if (it == o.rows.end())
            continue;
        shared++;
        const Row& orow = it->second;
        if (gr.kind == orow.kind && gr.name == orow.name &&
            gr.loc == orow.loc) {
            same++;
            continue;
        }
        if (gr.kind == "<AMBIGUOUS>" || orow.kind == "<AMBIGUOUS>") {
            amb++;
            continue;
        }
        const char* bucket = nullptr;
        if (gr.kind == "unsupported_typespec" &&
            orow.kind != "unsupported_typespec")
            bucket = "G_UNSUP", gUn++;
        else if (orow.kind == "unsupported_typespec" &&
                 gr.kind != "unsupported_typespec")
            bucket = "O_UNSUP", oUn++;
        else if (gr.kind != orow.kind)
            bucket = "TS_KIND", tsKind++;
        else if (gr.name != orow.name)
            bucket = "TS_NAME", tsName++;
        else
            bucket = "TS_SPAN", tsSpan++;
        if (verbose)
            std::cout << bucket << "  " << k << "\n    G " << gr.kind << " ("
                      << gr.name << ") @" << gr.loc << "\n    O " << orow.kind
                      << " (" << orow.name << ") @" << orow.loc << "\n";
    }
    // An EMPTY join is not a clean score: it is a broken pairing.  r10sd10's
    // ct10scan.sh silently scanned 687 of 1358 databases behind exactly this,
    // so it is a hard error here.
    if (shared == 0) {
        std::cout << "[S] TS shared=0 EMPTY-JOIN\n";
        return 5;
    }
    std::cout << "[S] TS shared=" << shared << " same=" << same
              << " G_UNSUP=" << gUn << " O_UNSUP=" << oUn
              << " TS_KIND=" << tsKind << " TS_NAME=" << tsName
              << " TS_SPAN=" << tsSpan << " AMBIG=" << amb << "\n";
    return 0;
}
