// r10earl17c — THE GENERIC BISECTOR.  Every r10earl probe before this one
// hand-writes a descent for the node kinds its author expected to meet, so a
// failure one level below that imagination is invisible (pass 16's whole
// method problem, and the reason work@tlul_adapter_host sat at "no failing
// child" for two passes).  CompareContext already names the failing LEAF pair;
// what it never tells you is WHICH FIELD OF WHICH PARENT led there, because
// m_failedLhs's own VpiParent chain runs off into a package or the design.
//
// This walks DOWNWARD instead.  Children are enumerated GENERICALLY through
// the VPI relation ids (vpi_handle for one-to-one, vpi_iterate for one-to-many,
// every id in [1, MAXREL)), so no per-type code exists at all; at each step it
// re-Compares each child pair with a FRESH context and follows the first pair
// that is unequal.  The printed path is the exact field chain uhdm-cmp walks
// to reach the difference, e.g.
//     [1] rel=vpiTypespec logic_typespec ...
//     [2] rel=vpiElemTypespec ...
// Pairing is POSITIONAL inside a relation, which is exactly what SafeCompare
// does, so the bisect and uhdm-cmp agree by construction.
//
// Build: bash tools/probe/r10earl17build.sh r10earl17c
// Usage: r10earl17c <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Listing> <sel>
//   sel as in r10earl17b: whole | net:<n> | port:<n> | var:<n> | param:<n> |
//                         ts:<i> | pa:<i> | refmod:<n> | genstmt:<i> |
//                         ca:<i> | proc:<i> | gsa:<n>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

// vpiUhdm* relation ids run well past the 1.0 vpi range; 3000 covers every id
// UHDM generates today with room to spare.
static const int MAXREL = 3000;
static int maxDepth = 40;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + base(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo()) +
                    " uid=" + std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmoperation)
        s += " {op=" + std::to_string(((const operation*)n)->VpiOpType()) + "}";
    // VpiSigned is cmp-relevant on the integer typespecs and is the field that
    // separates two otherwise identical mint sites in the emitter.
    if (n->UhdmType() == uhdmint_typespec)
        s += " {signed=" +
             std::to_string((int)((const int_typespec*)n)->VpiSigned()) +
             " val=" + std::string(((const int_typespec*)n)->VpiValue()) + "}";
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) + " def=" +
             std::string(in->VpiDefName()) + "}";
    return s;
}

// The OWNER of a missing pointer is only half the answer -- which listing it
// hangs off decides which emitter pass should have stamped it.
static std::string chain(const BaseClass* n) {
    std::string s;
    const any* p = n ? n->VpiParent() : nullptr;
    for (int i = 0; p && i < 8; i++) {
        s += "\n          ^ " + at(p);
        p = p->VpiParent();
    }
    return s;
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

struct Child {
    int rel;
    int idx;
    const BaseClass* a;
    const BaseClass* b;
};

// Enumerate the children of a PAIR of nodes, relation by relation, pairing
// positionally.  A relation present on one side only is itself the answer, so
// it is returned with the missing half null.
static std::vector<Child> childrenOf(const BaseClass* a, const BaseClass* b) {
    std::vector<Child> out;
    vpiHandle ha = NewVpiHandle((const any*)a);
    vpiHandle hb = NewVpiHandle((const any*)b);
    for (int rel = 1; rel < MAXREL; rel++) {
        // vpiParent (81) is a pure BACK-EDGE and no Compare ever follows it;
        // descending it walks OUT of the subtree and into the design, which is
        // how the first cut of this probe bisected an unrelated module.
        // Compare's graph has no upward edge, so neither has this walk.
        if (rel == vpiParent)
            continue;
        // one-to-one
        vpiHandle ca = vpi_handle(rel, ha);
        vpiHandle cb = vpi_handle(rel, hb);
        if (ca || cb) {
            out.push_back({rel, -1, obj(ca), obj(cb)});
            if (ca) vpi_release_handle(ca);
            if (cb) vpi_release_handle(cb);
        }
        // one-to-many
        vpiHandle ia = vpi_iterate(rel, ha);
        vpiHandle ib = vpi_iterate(rel, hb);
        if (ia || ib) {
            std::vector<const BaseClass*> va, vb;
            if (ia) {
                while (vpiHandle x = vpi_scan(ia)) {
                    va.push_back(obj(x));
                    vpi_release_handle(x);
                }
                vpi_release_handle(ia);
            }
            if (ib) {
                while (vpiHandle x = vpi_scan(ib)) {
                    vb.push_back(obj(x));
                    vpi_release_handle(x);
                }
                vpi_release_handle(ib);
            }
            if (va.size() != vb.size()) {
                std::cout << "    rel=" << rel << " VECTOR SIZE " << va.size()
                          << " vs " << vb.size() << "\n";
            }
            for (size_t i = 0; i < va.size() && i < vb.size(); i++)
                out.push_back({rel, (int)i, va[i], vb[i]});
        }
    }
    vpi_release_handle(ha);
    vpi_release_handle(hb);
    return out;
}

int main(int argc, char** argv);

// UHDM's relations include BACK-EDGES (vpiParent, vpiInstance, vpiActual, ...),
// so a naive descent ping-pongs parent<->child forever.  One global seen-set on
// the A side keeps the walk a tree; a node already descended into cannot be the
// step that explains a NEW difference.
// Keyed on the PAIR: one golden node pairs with different nodes of ours along
// different paths (shared typespec vs per-declaration clone), and a
// golden-only key hides the very pairing that carries the difference — it also
// makes the walk report "no child reproduces it" when the real child was
// skipped as already-seen.
static std::set<std::pair<const BaseClass*, const BaseClass*>> seen;

// THE ANCESTOR SEED.  A fresh CompareContext per child makes the walk report
// PHANTOM failures: a typespec's Instance() points back at the module we
// started from, so comparing it standalone re-compares the whole module and
// "fails", while the real Compare's m_visited makes that edge a no-op.  Seed
// every child's context with the ancestor path so the walk sees what uhdm-cmp
// sees.  Children that fail ONLY without the seed are printed as CYCLE lines
// instead of being followed.
static std::vector<const BaseClass*> ancestors;

static int cmpSeeded(const BaseClass* a, const BaseClass* b,
                     CompareContext& ctx) {
    for (const BaseClass* p : ancestors)
        ctx.m_visited.insert((const any*)p);
    return a->Compare(b, &ctx);
}

static std::string line(const Child& c, int r, const BaseClass* a,
                        const BaseClass* b) {
    return "rel=" + std::to_string(c.rel) +
           (c.idx >= 0 ? "[" + std::to_string(c.idx) + "]" : "") +
           " r=" + std::to_string(r) + "\n      A " + at(a) + "\n      B " +
           at(b);
}

static void bisect(const BaseClass* a, const BaseClass* b, int depth) {
    if (depth > maxDepth) {
        std::cout << "  (depth cap)\n";
        return;
    }
    std::vector<Child> kids = childrenOf(a, b);
    ancestors.push_back(a);
    std::vector<std::string> cyc;
    for (const Child& c : kids) {
        if (!c.a || !c.b) {
            std::cout << "  [" << depth << "] rel=" << c.rel
                      << (c.idx >= 0 ? "[" + std::to_string(c.idx) + "]" : "")
                      << " NULLNESS  A=" << at(c.a) << "  B=" << at(c.b)
                      << "\n  *** THE MISSING POINTER ***\n      ownerA "
                      << at(a) << chain(a) << "\n      ownerB " << at(b)
                      << chain(b) << "\n";
            ancestors.pop_back();
            return;
        }
        CompareContext ctx;
        int r = cmpSeeded(c.a, c.b, ctx);
        if (r == 0)
            continue;
        if (!seen.insert({c.a, c.b}).second) {
            cyc.push_back(line(c, r, c.a, c.b));
            continue;
        }
        std::cout << "  [" << depth << "] " << line(c, r, c.a, c.b) << "\n";
        bisect(c.a, c.b, depth + 1);
        ancestors.pop_back();
        return;
    }
    ancestors.pop_back();
    std::cout << "  [" << depth
              << "] NO CHILD REPRODUCES IT.  Child table (rel: A | B):\n";
    for (const Child& c : kids)
        std::cout << "      rel=" << c.rel
                  << (c.idx >= 0 ? "[" + std::to_string(c.idx) + "]" : "")
                  << "\n        A " << at(c.a) << "\n        B " << at(c.b)
                  << "\n";
    for (const std::string& l : cyc)
        std::cout << "      CYCLE (fails only unseeded) " << l << "\n";
}

template <class V>
static const instance* pick(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                return x;
        }
    return nullptr;
}

template <class V>
static const any* byName(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v)
            if (std::string(x->VpiName()) == want)
                return (const any*)x;
    return nullptr;
}

template <class V>
static const any* byIdx(V* v, const std::string& idx) {
    if (!v)
        return nullptr;
    size_t i = (size_t)std::stoul(idx);
    return i < v->size() ? (const any*)(*v)[i] : nullptr;
}

static const any* select(const instance* in, const std::string& sel) {
    auto pos = sel.find(':');
    std::string k = pos == std::string::npos ? sel : sel.substr(0, pos);
    std::string a = pos == std::string::npos ? "" : sel.substr(pos + 1);
    const module_inst* m = any_cast<const module_inst*>((const any*)in);
    if (k == "whole")
        return (const any*)in;
    if (k == "net")
        return byName(in->Nets(), a);
    if (k == "var")
        return byName(in->Variables(), a);
    if (k == "param")
        return byName(in->Parameters(), a);
    if (k == "ts")
        return byIdx(in->Typespecs(), a);
    if (k == "pa")
        return byIdx(in->Param_assigns(), a);
    if (k == "tf")
        return byName(in->Task_funcs(), a);
    if (!m)
        return nullptr;
    if (k == "refmod")
        return byName(m->Ref_modules(), a);
    if (k == "genstmt")
        return byIdx(m->Gen_stmts(), a);
    if (k == "port")
        return byName(m->Ports(), a);
    if (k == "ca")
        return byIdx(m->Cont_assigns(), a);
    if (k == "proc")
        return byIdx(m->Process(), a);
    if (k == "gsa")
        return byName(m->Gen_scope_arrays(), a);
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 6)
        return 1;
    std::string vec = argv[3], want = argv[4], sel = argv[5];
    if (argc > 6)
        maxDepth = std::stoi(argv[6]);
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const instance* ia = nullptr;
    const instance* ib = nullptr;
    if (vec == "all") {
        ia = pick(da->AllModules(), want);
        ib = pick(db->AllModules(), want);
    }
    else if (vec == "top") {
        ia = pick(da->TopModules(), want);
        ib = pick(db->TopModules(), want);
    }
    else if (vec == "allpkg") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->AllPackages(), want);
    }
    else {
        ia = pick(da->TopPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    if (!ia || !ib) {
        std::cout << "listing not found\n";
        return 3;
    }
    const any* oa = select(ia, sel);
    const any* ob = select(ib, sel);
    if (!oa || !ob) {
        std::cout << "selector missed: A " << (oa ? "ok" : "null") << " B "
                  << (ob ? "ok" : "null") << "\n";
        return 4;
    }
    seen.insert({(const BaseClass*)oa, (const BaseClass*)ob});
    CompareContext ctx;
    int r = oa->Compare(ob, &ctx);
    std::cout << "ROOT " << at(oa) << "\n  r=" << r << "\n      failLhs "
              << at(ctx.m_failedLhs) << "\n      failRhs "
              << at(ctx.m_failedRhs) << "\n";
    if (r == 0)
        return 0;
    bisect(oa, ob, 1);
    return 0;
}
