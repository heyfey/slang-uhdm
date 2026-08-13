// r10sd2 — EXACT LOCALIZER: bisect the head by SEEDING `CompareContext::m_visited`.
//
// THE INSTRUMENT THAT ACTUALLY WORKS, and why the two before it did not:
//   * `ct2pkgv`   — censused every vector `package::Compare` walks.  All equal,
//                   NULL-ness included.  Rules out the vector arm on uvm_pkg.
//   * `ct2find`   — fresh CompareContext per candidate child.  WRONG: uvm_pkg is
//                   reachable from almost everything under it (`param_assign ->
//                   parameter -> ref_typespec -> int_typespec -> vpiInstance ->
//                   uvm_pkg` is a cycle), so every child "reproduces" and the
//                   walk chases the cycle.
//   * `ct2slot`   — mirror walk with a shared visited set.  Its relation ORDER
//                   is not `Compare`'s, so past the first real divergence the
//                   two walks pair up different objects and the census is noise
//                   (20 689 "shapes").  Kept as the record of that failure.
//
// This tool never re-implements `Compare`; it USES it.  `CompareContext::
// m_visited` is an `AnySet` seeded by every generated `Compare` with `this` —
// the LHS object — so pre-inserting a GOLDEN child pointer makes the real
// `Compare` skip exactly that subtree and nothing else.  Bisection follows:
// at each pair, seed one child at a time; the child whose suppression makes the
// head SIGNATURE disappear is the one that owns it.  When no child owns it, the
// slot is a field of the current object, and the relation table names it.
//
// build: g++ -O2 -std=c++17 ct2bisect.cpp -I ~/.local/include -I. \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2bisect
// usage: ct2bisect <golden.uhdm> <ours.uhdm> <targetPkgName>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <set>
#include <string>
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

static std::string g_target;

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

static bool isTarget(const BaseClass* p) {
    return p && p->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage &&
           std::string(p->VpiName()) == g_target;
}

// THE HEAD SIGNATURE: `LHS: <null>` / `RHS: package <target>`.
//
// SUPPRESS-ALL-BUT-ONE, not suppress-one.  Suppressing a single child leaves the
// head standing whenever the culprit is reachable by another path — which it is,
// every time, in a UVM database (measured: at the design, suppressing any one
// child removed nothing).  Suppressing every child EXCEPT one is ancestor-closed
// by construction and answers the only question that matters: is the head
// reachable THROUGH THIS CHILD?
static bool sig(const BaseClass* g, const BaseClass* o,
                const std::vector<const BaseClass*>& skip) {
    CompareContext c;
    for (const BaseClass* s : skip) c.m_visited.insert(s);
    int r = g->Compare(o, &c);
    return r != 0 && c.m_failedLhs == nullptr && isTarget(c.m_failedRhs);
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

struct Child {
    const BaseClass* g;
    const BaseClass* o;
    std::string label;
};

// Every (golden,ours) child pair reachable through the VPI relation API, both
// sides present.  Pairs with one side missing are reported separately: those
// ARE candidate slots, not traversal steps.
static std::vector<Child> children(const BaseClass* g, const BaseClass* o,
                                   std::vector<std::string>& oneSided) {
    std::vector<Child> out;
    vpiHandle gh = NewVpiHandle(g), oh = NewVpiHandle(o);
    for (int k = 0; k < kNRels; k++) {
        const int rel = kRels[k].id;
        const BaseClass* a = obj(vpi_handle(rel, gh));
        const BaseClass* b = obj(vpi_handle(rel, oh));
        if (a && b)
            out.push_back({a, b, kRels[k].name});
        else if (!a && b)
            oneSided.push_back(std::string("LHS<null>  .") + kRels[k].name +
                               " -> ours " + ident(b) +
                               (isTarget(b) ? "   *** IS THE TARGET ***" : ""));
        else if (a && !b)
            oneSided.push_back(std::string("RHS<null>  .") + kRels[k].name +
                               " -> golden " + ident(a));
        std::vector<const BaseClass*> va, vb;
        if (vpiHandle it = vpi_iterate(rel, gh))
            while (vpiHandle e = vpi_scan(it)) va.push_back(obj(e));
        if (vpiHandle it = vpi_iterate(rel, oh))
            while (vpiHandle e = vpi_scan(it)) vb.push_back(obj(e));
        if (va.empty() && !vb.empty())
            oneSided.push_back(std::string("LHSVEC<null> .") + kRels[k].name +
                               " ours has " + std::to_string(vb.size()) +
                               ", first " + ident(vb[0]));
        else if (!va.empty() && vb.empty())
            oneSided.push_back(std::string("RHSVEC<null> .") + kRels[k].name +
                               " golden has " + std::to_string(va.size()) +
                               ", first " + ident(va[0]));
        else if (va.size() != vb.size())
            oneSided.push_back(std::string("VECSIZE .") + kRels[k].name +
                               " golden=" + std::to_string(va.size()) +
                               " ours=" + std::to_string(vb.size()));
        for (size_t i = 0; i < va.size() && i < vb.size(); i++)
            out.push_back({va[i], vb[i],
                           std::string(kRels[k].name) + "[" +
                               std::to_string(i) + "]"});
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: ct2bisect <golden.uhdm> <ours.uhdm> <pkg>\n";
        return 2;
    }
    g_target = argv[3];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const BaseClass* g = (design*)((uhdm_handle*)ha[0])->object;
    const BaseClass* o = (design*)((uhdm_handle*)hb[0])->object;
    if (!sig(g, o, {})) {
        std::cout << "HEAD SIGNATURE ABSENT at the design; nothing to bisect\n";
        return 1;
    }
    std::string path = "design";
    std::set<const BaseClass*> guard;
    for (int depth = 0; depth < 64; depth++) {
        std::cout << "[" << depth << "] " << path << "\n      golden=" << ident(g)
                  << "\n      ours  =" << ident(o) << "\n";
        if (!guard.insert(g).second) {
            std::cout << "  REVISIT of a golden object already on the path — stop\n";
            break;
        }
        std::vector<std::string> oneSided;
        std::vector<Child> cs = children(g, o, oneSided);
        std::vector<const BaseClass*> allKids;
        for (const Child& c : cs) allKids.push_back(c.g);
        // If the head survives with EVERY child suppressed, it is a field of the
        // current object and no descent can find it.
        if (sig(g, o, allKids)) {
            std::cout << "  >>> HEAD SURVIVES WITH ALL " << cs.size()
                      << " CHILDREN SUPPRESSED — the slot is a field of THIS "
                         "object.\n";
            std::cout << "  one-sided relations on this object ("
                      << oneSided.size() << "):\n";
            for (const auto& s : oneSided) std::cout << "      " << s << "\n";
            break;
        }
        const Child* owner = nullptr;
        for (size_t i = 0; i < cs.size(); i++) {
            std::vector<const BaseClass*> skip;
            for (size_t j = 0; j < cs.size(); j++)
                if (j != i) skip.push_back(cs[j].g);
            if (sig(g, o, skip)) {
                owner = &cs[i];
                break;
            }
        }
        if (!owner) {
            std::cout << "  >>> NO SINGLE CHILD CARRIES THE HEAD (and it does not"
                         " survive full suppression) — it needs two or more "
                         "children; " << cs.size() << " children, "
                      << oneSided.size() << " one-sided relations:\n";
            for (const auto& s : oneSided) std::cout << "      " << s << "\n";
            break;
        }
        std::cout << "  -> owned via ." << owner->label << "\n";
        path += "/" + owner->label;
        const BaseClass* ng = owner->g;
        const BaseClass* no = owner->o;
        g = ng;
        o = no;
    }
    return 0;
}
