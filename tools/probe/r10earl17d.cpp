// r10earl17d — THE NULLNESS WALK.  r10earl17c bisects by re-Comparing, which
// costs a full subtree Compare per candidate child and blows past five minutes
// on a listing whose ports reach a package.  For the MISSING-INSTANCE class
// (golden stamps a pointer we leave null) no Compare is needed at all: walk the
// two subtrees in LOCKSTEP through the generic VPI relation ids and report
// every place where one side has a pointer and the other does not, plus every
// vector whose sizes differ.  Linear, no Compare, and it names the OWNER of the
// missing pointer — which is the one thing CompareContext never tells you.
//
// Pruning: the walk does NOT descend through a child that is an instance
// (module_inst / package / interface / program) or the design — those are
// back-edges into the rest of the world and are exactly what we are trying to
// report, not traverse.  Pass `-deep` to descend anyway.
//
// Build: bash tools/probe/r10earl17build.sh r10earl17d
// Usage: r10earl17d <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Listing> <sel>
//                   [-deep]
//   sel: whole | net:<n> | port:<n> | var:<n> | param:<n> | ts:<i> | pa:<i> |
//        tf:<n> | refmod:<n> | genstmt:<i> | ca:<i> | proc:<i> | gsa:<n>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static const int MAXREL = 3000;
static bool deep = false;
static int reports = 0;

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
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) + " def=" +
             std::string(in->VpiDefName()) + "}";
    return s;
}

static bool isWorld(const BaseClass* n) {
    if (!n)
        return false;
    if (n->UhdmType() == uhdmdesign)
        return true;
    return any_cast<const instance*>((const any*)n) != nullptr;
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

// Keyed on the PAIR, not on the golden node: one golden object routinely pairs
// with DIFFERENT objects of ours along different paths (a shared typespec in
// golden against per-declaration clones in ours), and a golden-only key silently
// skipped the very pairing that carried the missing pointer.
static std::set<std::pair<const BaseClass*, const BaseClass*>> seen;
static long visits = 0;

static void walk(const BaseClass* a, const BaseClass* b,
                 const std::string& path) {
    visits++;
    vpiHandle ha = NewVpiHandle((const any*)a);
    vpiHandle hb = NewVpiHandle((const any*)b);
    for (int rel = 1; rel < MAXREL; rel++) {
        // vpiParent is a back-edge Compare never follows (see r10earl17c).
        if (rel == vpiParent)
            continue;
        vpiHandle ca = vpi_handle(rel, ha);
        vpiHandle cb = vpi_handle(rel, hb);
        const BaseClass* xa = obj(ca);
        const BaseClass* xb = obj(cb);
        if (ca) vpi_release_handle(ca);
        if (cb) vpi_release_handle(cb);
        if ((xa == nullptr) != (xb == nullptr)) {
            std::cout << path << " .rel" << rel << "  A=" << at(xa)
                      << "  B=" << at(xb) << "\n    OWNER " << at(a) << "\n";
            reports++;
        }
        else if (xa && xb && (deep || !isWorld(xa)) &&
                 seen.insert({xa, xb}).second)
            walk(xa, xb, path + ".rel" + std::to_string(rel));

        vpiHandle ia = vpi_iterate(rel, ha);
        vpiHandle ib = vpi_iterate(rel, hb);
        if (!ia && !ib)
            continue;
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
            std::cout << path << " *rel" << rel << "  VECTOR SIZE " << va.size()
                      << " vs " << vb.size() << "\n    OWNER " << at(a) << "\n";
            reports++;
        }
        for (size_t i = 0; i < va.size() && i < vb.size(); i++)
            if (va[i] && vb[i] && (deep || !isWorld(va[i])) &&
                seen.insert({va[i], vb[i]}).second)
                walk(va[i], vb[i],
                     path + "*rel" + std::to_string(rel) + "[" +
                         std::to_string(i) + "]");
    }
    vpi_release_handle(ha);
    vpi_release_handle(hb);
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
    for (int i = 6; i < argc; i++)
        if (std::string(argv[i]) == "-deep")
            deep = true;
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
        std::cout << "selector missed\n";
        return 4;
    }
    seen.insert({(const BaseClass*)oa, (const BaseClass*)ob});
    std::cout << "ROOT " << at(oa) << "\n";
    walk((const BaseClass*)oa, (const BaseClass*)ob, "");
    std::cout << "-> " << reports << " nullness/size report(s), " << visits
              << " node pairs walked\n";
    return 0;
}
