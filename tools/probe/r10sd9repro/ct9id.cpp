// r10sd9 — THE ELEMENT-TYPESPEC IDENTITY CENSUS.
//
// sd8's verifier (README.verifier.md F2) re-keyed `ct8pop`'s `d1 var/ts` cell BY
// HAND because ct8pop's key carries the TYPESPEC's KIND+NAME, so the very rows
// where the two sides DISAGREE about the element type's identity never join at
// all.  This instrument does that re-keying mechanically and in one process:
//
//   key = (owner full name + span, variable name, ordinal of the element var)
//   value = element typespec KIND, NAME, SPAN, vpiInstance VIEW
//
// An `array_var` carries exactly one element variable on both sides in these
// databases (measured), so the ordinal is a formality that keeps the key total
// rather than a discriminator.
//
// Usage:  ct9id <golden.uhdm> <ours.uhdm> [--all]
//   default prints only DISAGREEING rows plus the summary
//   --all    prints every joined row
//
// GUARD (measure the measurer): an empty population on either side is exit 5.
// A census that silently joins nothing reports "0 disagreements", which is
// exactly the failure that reads as perfection.
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

struct Side {
    std::set<const BaseClass*> all, top;
    std::map<std::string, std::string> rows;  // key -> "kind(name)@span inst=view"
    std::map<std::string, std::string> ident; // key -> "kind(name)@span"  (no stamp)
    std::map<std::string, std::string> stamp; // key -> view
};

std::string spanOf(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) +
           "-" + std::to_string(p->VpiEndLineNo()) + ":" +
           std::to_string(p->VpiEndColumnNo());
}

// DEFECT FIXED BEFORE SHIPPING — this function used to end with
// `return "OTHER:" + std::string(i->VpiName())`, and that produced a FALSE
// DIFFERENCE the first time it was pointed at `SimpleUVM`.  `vpiInstance` is
// typed `instance*`, but Surelog (and we, copying it) store a `design` there for
// a class-NESTED typedef's listing typespec — and a `design` is NOT an
// `instance` in the installed UHDM, so `i->VpiName()` reads through the wrong
// vtable and returns garbage that differs run to run and side to side.  The
// census reported `BOTH_SET_VIEW_DIFF=4` on `SimpleUVM`/`Scoreboard` for four
// rows whose dumps are `|vpiInstance:` -> `\_design: (work@top)` on BOTH SIDES.
// The label now leads with the object's UhdmType, which is read off the object
// and not through a cast, and only reads VpiName for an object that really is
// one of the design's packages.
std::string viewOf(const Side& sd, const instance* i) {
    if (!i)
        return "<null>";
    if (sd.top.count(i))
        return "TOP:" + std::string(i->VpiName());
    if (sd.all.count(i))
        return "ALL:" + std::string(i->VpiName());
    return std::string("OTHER<") + UhdmName(((const BaseClass*)i)->UhdmType()) + ">";
}

void load(const char* path, Side& sd) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) {
        std::cerr << "RESTORE FAILED " << path << "\n";
        exit(3);
    }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            sd.all.insert(p);
    if (auto* v = d->TopPackages())
        for (auto* p : *v)
            sd.top.insert(p);

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
            std::string id = "<no-ts>";
            std::string vw = "<no-ts>";
            if (ev && ev->Typespec())
                if (auto* t = ev->Typespec()->Actual_typespec()) {
                    id = std::string(UhdmName(t->UhdmType())) + "(" +
                         std::string(t->VpiName()) + ")@" + spanOf(t);
                    vw = viewOf(sd, t->Instance());
                }
            sd.ident[key] = id;
            sd.stamp[key] = vw;
            sd.rows[key] = id + " inst=" + vw;
        }
    };

    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj)
            continue;
        if (obj->UhdmType() == uhdmclass_defn) {
            auto* cd = (class_defn*)obj;
            if (!cd->Variables())
                continue;
            std::string cn(cd->VpiFullName().empty() ? cd->VpiName()
                                                     : cd->VpiFullName());
            for (auto* v : *cd->Variables())
                doVar("CLS " + cn + "@" + spanOf(cd), v);
        }
        else if (obj->UhdmType() == uhdmpackage) {
            auto* p = (package*)obj;
            if (!p->Variables())
                continue;
            for (auto* v : *p->Variables())
                doVar("PKG " + viewOf(sd, p), v);
        }
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct9id <golden.uhdm> <ours.uhdm> [--all]\n";
        return 2;
    }
    bool all = argc > 3 && std::string(argv[3]) == "--all";
    Side g, o;
    load(argv[1], g);
    load(argv[2], o);
    if (g.rows.empty() || o.rows.empty()) {
        std::cerr << "EMPTY POPULATION golden=" << g.rows.size()
                  << " ours=" << o.rows.size() << "\n";
        return 5;
    }
    size_t shared = 0, idMatch = 0, idDiff = 0, stampMatch = 0;
    size_t goldSetOursNull = 0, oursSetGoldNull = 0, bothSetDiff = 0;
    std::map<std::string, size_t> idDiffShape;
    for (auto& [k, gv] : g.rows) {
        auto it = o.rows.find(k);
        if (it == o.rows.end())
            continue;
        shared++;
        bool sameId = g.ident[k] == o.ident[k];
        bool sameStamp = g.stamp[k] == o.stamp[k];
        if (sameId)
            idMatch++;
        else {
            idDiff++;
            std::string gk = g.ident[k].substr(0, g.ident[k].find('('));
            std::string ok = o.ident[k].substr(0, o.ident[k].find('('));
            idDiffShape[gk + " <- " + ok]++;
        }
        if (sameStamp)
            stampMatch++;
        else {
            if (g.stamp[k] != "<null>" && o.stamp[k] == "<null>")
                goldSetOursNull++;
            else if (g.stamp[k] == "<null>" && o.stamp[k] != "<null>")
                oursSetGoldNull++;
            else
                bothSetDiff++;
        }
        if (all || !sameId || !sameStamp) {
            std::cout << (sameId ? (sameStamp ? "OK   " : "STAMP") : "IDENT")
                      << "  " << k << "\n";
            std::cout << "    G " << gv << "\n";
            std::cout << "    O " << it->second << "\n";
        }
    }
    std::cout << "[S] golden_rows=" << g.rows.size() << " ours_rows=" << o.rows.size()
              << " shared=" << shared << " IDENT_MATCH=" << idMatch
              << " IDENT_DIFF=" << idDiff << " STAMP_MATCH=" << stampMatch
              << " GOLD_SET_OURS_NULL=" << goldSetOursNull
              << " OURS_SET_GOLD_NULL=" << oursSetGoldNull
              << " BOTH_SET_VIEW_DIFF=" << bothSetDiff << "\n";
    for (auto& [k, n] : idDiffShape)
        std::cout << "[S] IDENT_DIFF_SHAPE  " << k << "  " << n << "\n";
    return 0;
}
