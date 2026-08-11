// r10uvm47pf — the FOLD census, keyed on SOURCE SPAN.
//
// The head pass 47 exposed behind § pkgInitRefBindsOwnListing47 is a FOLD
// disagreement, not a missing object: at uvm_comparer.svh:154:15-154:29 golden
// holds an unbound `ref_obj` named `UVM_STREAMBITS` and we hold a `constant`
// 4096.  Neither a KIND:NAME census nor an object count can see that — a
// constant has no name, so the two objects have nothing in common EXCEPT their
// span.  So the census is keyed on the span:
//
//   FOLD <file>:<l>:<c>-<el>:<ec> <kind> '<name>' dec='<decompile>' size=<n>
//        parent=<kind>@<span>
//
// Diffing this projection between golden and ours names every position where one
// side folded and the other did not, in both directions, and the parent span
// tells apart two reads of the same parameter in one statement.
//
// POSITIVE CONTROL: a restore with no design is FATAL; a database holding ZERO
// ref_obj AND ZERO constant objects is FATAL (that is a blind read, not a
// closed residue); and a filter that selects nothing is announced on stderr
// with the population rather than printed as a zero total.
//
//   r10uvm47pf <file.uhdm> [filter] [-c]
//     filter  substring matched against the object's name, its fullname, its
//             decompile text AND its file path — so `UVM_STREAMBITS` finds the
//             unfolded ref_obj and `4096` finds the folded constant
//     -c      constants only (the folded half)
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sv(std::string_view s) { return std::string(s); }

static std::string leaf(std::string_view f) {
    std::string s(f);
    auto p = s.find_last_of('/');
    return p == std::string::npos ? s : s.substr(p + 1);
}

static std::string spanOf(const any* o) {
    if (!o)
        return "<none>";
    auto* b = (const BaseClass*)o;
    return std::to_string(b->VpiLineNo()) + ":" +
           std::to_string(b->VpiColumnNo()) + "-" +
           std::to_string(b->VpiEndLineNo()) + ":" +
           std::to_string(b->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm47pf <file.uhdm> [filter] [-c]\n";
        return 2;
    }
    std::string filt;
    bool constOnly = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "-c")
            constOnly = true;
        else
            filt = a;
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "FATAL: restore produced no design from " << argv[1]
                  << "\n";
        return 1;
    }
    std::vector<std::string> out;
    size_t population = 0;
    for (auto& [o, id] : s.AllObjects()) {
        (void)id;
        if (!o)
            continue;
        bool isRef = o->UhdmType() == uhdmref_obj || o->UhdmType() == uhdmref_var;
        auto* c = any_cast<const constant*>(o);
        if (!isRef && !c)
            continue;
        population++;
        if (constOnly && !c)
            continue;
        std::string nm(o->VpiName());
        std::string full;
        if (auto* r = any_cast<const ref_obj*>(o))
            full = sv(r->VpiFullName());
        std::string dec = c ? sv(c->VpiDecompile()) : std::string();
        std::string file = leaf(((const BaseClass*)o)->VpiFile());
        if (!filt.empty() && nm.find(filt) == std::string::npos &&
            full.find(filt) == std::string::npos &&
            dec.find(filt) == std::string::npos &&
            file.find(filt) == std::string::npos)
            continue;
        const any* par = ((const BaseClass*)o)->VpiParent();
        out.push_back("FOLD " + file + ":" + spanOf(o) + " " +
                      sv(UhdmName(o->UhdmType())) + " '" + nm + "' full='" +
                      full + "' dec='" + dec + "'" +
                      (c ? " size=" + std::to_string(c->VpiSize()) +
                               " ctype=" + std::to_string(c->VpiConstType())
                         : std::string()) +
                      " parent=" +
                      (par ? sv(UhdmName(par->UhdmType())) + "@" + spanOf(par)
                           : std::string("<none>")));
    }
    if (population == 0) {
        std::cerr << "FATAL: database holds ZERO ref_obj AND ZERO constant "
                     "objects — BLIND, not a zero residue\n";
        return 1;
    }
    if (out.empty())
        std::cerr << "EMPTY: population=" << population
                  << " ref/constant objects, filter selected none — on stderr "
                     "so it cannot pass for a census line\n";
    std::sort(out.begin(), out.end());
    for (auto& l : out)
        std::cout << l << "\n";
    std::cout << "PFTOTAL=" << out.size() << " population=" << population
              << "\n";
    return 0;
}
