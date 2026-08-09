// r10earl17b — THE SUBTREE DUMPER.  Every earlier r10earl probe hand-writes a
// descent for the node kinds it expects to meet, so a failure one level below
// the author's imagination is invisible.  UHDM already ships a GENERIC
// subtree printer (UHDM::visit_object, the engine behind uhdm-dump); point it
// at ONE child of ONE listing on each side and diff the two texts and the
// pointer that differs falls out without any new descent code.
//
// Selector forms (argv[5]):
//   refmod:<name>    a Ref_modules entry            genstmt:<i>  Gen_stmts[i]
//   net:<name>       port:<name>      var:<name>    param:<name>
//   ts:<i>           Typespecs[i]     ca:<i>        Cont_assigns[i]
//   proc:<i>         Process[i]       gsa:<name>    Gen_scope_arrays entry
//   pa:<i>           Param_assigns[i] whole         the listing itself
// Build: bash tools/probe/r10earl17build.sh r10earl17b
// Usage: r10earl17b <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Listing> <sel>
//        <outA> <outB>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
using namespace UHDM;

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
    if (argc < 8)
        return 1;
    std::string vec = argv[3], want = argv[4], sel = argv[5];
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
    std::cout << "A " << (oa ? UhdmName(oa->UhdmType()) : "<null>") << "  B "
              << (ob ? UhdmName(ob->UhdmType()) : "<null>") << "\n";
    if (!oa || !ob)
        return 4;
    {
        std::ofstream f(argv[6]);
        vpiHandle h = NewVpiHandle(oa);
        visit_object(h, f, false);
        vpi_release_handle(h);
    }
    {
        std::ofstream f(argv[7]);
        vpiHandle h = NewVpiHandle(ob);
        visit_object(h, f, false);
        vpi_release_handle(h);
    }
    std::cout << "wrote " << argv[6] << " " << argv[7] << "\n";
    return 0;
}
