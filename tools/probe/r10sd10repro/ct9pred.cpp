// r10sd9 — ARTIFACT-BASED MOVER PREDICTION for
// § classPropElemTsFollowsScalarTd9 + § arrayElemTdIsScalarTd9.
//
// The rule the patch implements is "the array element binds the object the
// SCALAR declaration of that element type would bind", so the population it can
// move is exactly:
//
//   an array_var element typespec where GOLDEN names a TYPEDEF and we name the
//   RESOLVED underlying type, AND our database ALREADY CONTAINS a listing
//   typespec (a package `vpiTypedef` entry or a class_defn `vpiTypespecs`
//   entry) of the SAME KIND whose name is golden's name (bare, or with any
//   `pkg::` prefix stripped on either side).
//
// WHAT THIS INSTRUMENT CANNOT DO, STATED FIRST.  `reachable` is a SUPERSET, not
// the moved set, and the excess is MEASURED rather than hand-waved: on
// `SeqDriver` it scores 13 on the pristine database and 3 on the delivered one,
// and the 3 it cannot discriminate are the TYPE-PARAMETER shapes
// (`uvm_enum_wrapper::map`, `uvm_sequencer_param_base::m_last_req_buffer` /
// `m_last_rsp_buffer`).  Golden SPELLS those with a typedef's name because
// Surelog's type-parameter path reuses the alias object, but the DECLARED
// element type in the source is the parameter `T` / `RSP` and not a TypeAlias
// at all — so `sharedAliasTs` returns null and the patch provably cannot reach
// them.  That distinction lives in the SOURCE, not in either artifact, so no
// artifact-side clause can draw it.  The instrument therefore predicts
//     movers = pristine_reachable - delivered_reachable
// and the delivered score is what closes it.
//
// CALIBRATION IS PART OF THE INSTRUMENT: run it on golden-vs-golden (expect 0),
// on golden-vs-PRISTINE and on golden-vs-DELIVERED before believing any
// sweep-wide number.
//
// Usage:  ct9pred <golden.uhdm> <ours.uhdm> [-v]
// Exit 0 always; the machine-readable line is `[S] PREDICT ...`.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

namespace {

struct Elem {
    std::string kind, name;
};

std::string bare(std::string n) {
    auto p = n.rfind("::");
    return p == std::string::npos ? n : n.substr(p + 2);
}

struct DB {
    Serializer s;
    design* d = nullptr;
    std::map<std::string, Elem> elems;          // key -> element typespec identity
    std::set<std::string> listing;              // "kind|barename" of every listing ts
};

std::string spanOf(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo());
}

void load(const char* path, DB& db, bool wantListing) {
    auto h = db.s.Restore(std::filesystem::path(path));
    if (h.empty()) {
        std::cerr << "RESTORE FAILED " << path << "\n";
        exit(3);
    }
    db.d = (design*)((uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> all, top;
    if (auto* v = db.d->AllPackages())
        for (auto* p : *v)
            all.insert(p);
    if (auto* v = db.d->TopPackages())
        for (auto* p : *v)
            top.insert(p);
    auto view = [&](const instance* i) -> std::string {
        if (!i)
            return "<null>";
        std::string nm(i->VpiName());
        return (top.count(i) ? "TOP:" : all.count(i) ? "ALL:" : "OTHER:") + nm;
    };
    auto doVar = [&](const std::string& owner, variables* v) {
        if (!v || v->UhdmType() != uhdmarray_var)
            return;
        auto* av = (array_var*)v;
        if (!av->Variables())
            return;
        size_t ord = 0;
        for (auto* ev : *av->Variables()) {
            std::string key = owner + " :: " + std::string(v->VpiName()) + " #" +
                              std::to_string(ord++);
            Elem e{"<no-ts>", ""};
            if (ev && ev->Typespec())
                if (auto* t = ev->Typespec()->Actual_typespec()) {
                    e.kind = UhdmName(t->UhdmType());
                    e.name = t->VpiName();
                }
            db.elems[key] = e;
        }
    };
    for (const auto& [obj, id] : db.s.AllObjects()) {
        if (!obj)
            continue;
        if (obj->UhdmType() == uhdmclass_defn) {
            auto* cd = (class_defn*)obj;
            std::string cn(cd->VpiFullName().empty() ? cd->VpiName()
                                                     : cd->VpiFullName());
            if (cd->Variables())
                for (auto* v : *cd->Variables())
                    doVar("CLS " + cn + "@" + spanOf(cd), v);
            if (wantListing && cd->Typespecs())
                for (auto* t : *cd->Typespecs())
                    if (t)
                        db.listing.insert(std::string(UhdmName(t->UhdmType())) +
                                          "|" + bare(std::string(t->VpiName())));
        }
        else if (obj->UhdmType() == uhdmpackage) {
            auto* p = (package*)obj;
            if (p->Variables())
                for (auto* v : *p->Variables())
                    doVar("PKG " + view(p), v);
            if (wantListing && p->Typespecs())
                for (auto* t : *p->Typespecs())
                    if (t)
                        db.listing.insert(std::string(UhdmName(t->UhdmType())) +
                                          "|" + bare(std::string(t->VpiName())));
        }
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct9pred <golden.uhdm> <ours.uhdm> [-v]\n";
        return 2;
    }
    bool verbose = argc > 3 && std::string(argv[3]) == "-v";
    DB g, o;
    load(argv[1], g, false);
    load(argv[2], o, true);
    size_t shared = 0, nameDiff = 0, reachable = 0, unreachable = 0;
    for (auto& [k, ge] : g.elems) {
        auto it = o.elems.find(k);
        if (it == o.elems.end())
            continue;
        shared++;
        if (ge.kind == "<no-ts>" || it->second.kind == "<no-ts>")
            continue;
        if (bare(ge.name) == bare(it->second.name))
            continue;
        nameDiff++;
        bool have = o.listing.count(ge.kind + "|" + bare(ge.name)) > 0;
        if (have)
            reachable++;
        else
            unreachable++;
        if (verbose)
            std::cout << (have ? "REACH   " : "NOREACH ") << k << "\n    G "
                      << ge.kind << "(" << ge.name << ")\n    O " << it->second.kind
                      << "(" << it->second.name << ")\n";
    }
    std::cout << "[S] PREDICT shared=" << shared << " name_diff=" << nameDiff
              << " reachable=" << reachable << " unreachable=" << unreachable << "\n";
    return 0;
}
