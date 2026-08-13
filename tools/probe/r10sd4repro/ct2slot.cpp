// r10sd2 — THE SLOT CENSUS: every place golden and ours disagree about whether
// a relation is FILLED, walked with the SAME visited-pair discipline `Compare`
// uses.
//
// WHY A NEW INSTRUMENT.  `ct2find.cpp` (fresh CompareContext per candidate
// child) is WRONG for this head and says so out loud: `uvm_pkg` is reachable
// from nearly every object under it — `param_assign -> parameter ->
// ref_typespec -> int_typespec -> vpiInstance -> uvm_pkg` is a CYCLE — so with a
// fresh context EVERY child "reproduces" and the walk chases the cycle instead
// of the defect.  In a real `Compare` the cycle is cut by `context->m_visited`.
// This tool therefore keeps ONE visited set of (golden,ours) PAIRS for the whole
// walk, exactly as `Compare` does, and records every slot where one side has a
// relation filled and the other does not.
//
// It is a MIRROR, not a re-implementation: relation ORDER here is the
// alphabetical table in ct2rels.inc, not `Compare`'s field order, so the FIRST
// divergence it prints need not be uhdm-cmp's head.  What it is authoritative
// about is the SET of divergent slots and their owners — which is what a law
// needs.  vpiParent is excluded from the table: it is a back-pointer no
// `Compare` body reads.
//
// build: g++ -O2 -std=c++17 ct2slot.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2slot
// usage: ct2slot <golden.uhdm> <ours.uhdm> [maxexamples] [filterTypeName]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>

using namespace UHDM;

struct Rel {
    int id;
    const char* name;
};
static const Rel kRels[] = {
#include "ct2rels.inc"
};
static const int kNRels = sizeof(kRels) / sizeof(kRels[0]);

static int g_maxex = 4;
static std::string g_filter;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

static std::set<std::pair<const BaseClass*, const BaseClass*>> visited;
static std::map<std::string, int> counts;
static std::map<std::string, std::vector<std::string>> examples;

static void record(const std::string& kind, const char* rel,
                   const BaseClass* owner, const BaseClass* val,
                   const std::string& path) {
    std::string key =
        kind + " | " + UhdmName(owner->UhdmType()) + " . " + rel + " -> " +
        (val ? UhdmName(val->UhdmType()) : std::string("?")) +
        (val && !std::string(val->VpiName()).empty()
             ? "(" + std::string(val->VpiName()) + ")"
             : "");
    counts[key]++;
    auto& ex = examples[key];
    if ((int)ex.size() < g_maxex)
        ex.push_back("owner=" + ident(owner) + "  val=" + ident(val) +
                     "  path=" + path);
}

static void walk(const BaseClass* g, const BaseClass* o,
                 const std::string& path) {
    if (!g || !o) return;
    if (!visited.insert({g, o}).second) return;
    vpiHandle gh = NewVpiHandle(g), oh = NewVpiHandle(o);
    for (int k = 0; k < kNRels; k++) {
        const int rel = kRels[k].id;
        vpiHandle a = vpi_handle(rel, gh), b = vpi_handle(rel, oh);
        const BaseClass* ga = obj(a);
        const BaseClass* ob = obj(b);
        if (!ga && ob)
            record("LHS<null>", kRels[k].name, o, ob, path);
        else if (ga && !ob)
            record("RHS<null>", kRels[k].name, g, ga, path);
        else if (ga && ob)
            walk(ga, ob, path + "/" + kRels[k].name);

        vpiHandle ig = vpi_iterate(rel, gh), io = vpi_iterate(rel, oh);
        if (!ig && !io) continue;
        std::vector<const BaseClass*> va, vb;
        if (ig)
            while (vpiHandle e = vpi_scan(ig)) va.push_back(obj(e));
        if (io)
            while (vpiHandle e = vpi_scan(io)) vb.push_back(obj(e));
        if (va.empty() && !vb.empty())
            record("LHSVEC<null>", kRels[k].name, o, vb[0], path);
        else if (!va.empty() && vb.empty())
            record("RHSVEC<null>", kRels[k].name, g, va[0], path);
        else if (va.size() != vb.size())
            record("VECSIZE g=" + std::to_string(va.size()) + " o=" +
                       std::to_string(vb.size()),
                   kRels[k].name, o, vb.empty() ? nullptr : vb[0], path);
        for (size_t i = 0; i < va.size() && i < vb.size(); i++)
            walk(va[i], vb[i],
                 path + "/" + kRels[k].name + "[" + std::to_string(i) + "]");
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct2slot <golden.uhdm> <ours.uhdm> [maxex] [filter]\n";
        return 2;
    }
    if (argc > 3) g_maxex = atoi(argv[3]);
    if (argc > 4) g_filter = argv[4];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::cout << "relations in table: " << kNRels << "\n";
    walk(da, db, "design");
    std::cout << "visited pairs: " << visited.size() << "\n";
    std::cout << "distinct divergent slot shapes: " << counts.size() << "\n";
    std::vector<std::pair<int, std::string>> v;
    for (const auto& [k, c] : counts) v.push_back({c, k});
    std::sort(v.rbegin(), v.rend());
    for (const auto& [c, k] : v) {
        if (!g_filter.empty() && k.find(g_filter) == std::string::npos) continue;
        std::cout << "\n" << c << "  " << k << "\n";
        for (const auto& e : examples[k]) std::cout << "      " << e << "\n";
    }
    return 0;
}
