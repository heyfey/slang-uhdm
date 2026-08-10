// r10uvm44ls — the TYPESPEC-LISTING census.
//
// uhdm-cmp walks a scope's vpiTypedef vector pairwise and compares each entry's
// VpiType and VpiName.  So a scope's listing is fully characterised, FOR CMP
// PURPOSES, by the ORDERED sequence of (uhdm kind, VpiName) of its entries plus
// the vector's SIZE.  This probe prints exactly that, one line per scope:
//
//   <scopekind> '<scopename>' n=<count> | <kind>:<name> | <kind>:<name> | ...
//
// WHY: pass 43 ranked "the three missing listing objects" first BY REACH and
// the deficit is a POPULATION one — objects we never mint at all.  A referrer
// census (LISTDIRECT) and a container-position census (CPTOTAL) are both BLIND
// to an object that does not exist: nobody refers to it and it sits in no
// position.  Only the listing vector itself can show a missing entry, and the
// vector is what cmp reads first (`r=1 failLhs=<container>` = SIZE mismatch).
//
// Two same-named scopes are the norm here, not an edge case: a package and a
// module each appear as a DEF view and an ELABORATED view under one VpiName, so
// the scope key carries VpiTop() (`/def` vs `/top`).  Without it the two views'
// listings are indistinguishable and a deficit in one can be read off the
// other's line ('r=1 failLhs=<container>' being a DEF-vs-TOP view pointer is
// the same trap).
//
// Ordering: scopes are sorted by their printed text (Serializer::AllObjects is
// pointer-keyed and its order changes run to run); the ENTRY order inside a
// scope is PRESERVED, because that order is itself compared.
//
//   r10uvm44ls <file.uhdm> [nameFilter] [-e]
// nameFilter matches the whole printed line; -e switches to ONE LINE PER ENTRY
// (`<scope> [i] kind:name`), which makes a diff count ENTRIES rather than
// scopes.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm44ls <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt;
    bool perEntry = false;
    for (int i = 2; i < argc; i++) {
        if (std::string(argv[i]) == "-e")
            perEntry = true;
        else
            filt = argv[i];
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 1;

    std::vector<std::string> out;
    auto render = [&](const std::string& scope,
                      const std::vector<typespec*>* v) {
        std::string head = scope + " n=" + std::to_string(v ? v->size() : 0);
        std::string line = head;
        size_t i = 0;
        for (auto* t : v ? *v : std::vector<typespec*>{}) {
            std::string n(t->VpiName());
            std::string e = std::string(UhdmName(t->UhdmType())) + ":" +
                            (n.empty() ? std::string("<unnamed>") : n);
            if (perEntry) {
                char ix[24];
                snprintf(ix, sizeof ix, " [%03zu] ", i);
                std::string el = scope + ix + e;
                if (filt.empty() || el.find(filt) != std::string::npos)
                    out.push_back(el);
            }
            else
                line += " | " + e;
            i++;
        }
        if (perEntry) {
            if (filt.empty() || head.find(filt) != std::string::npos)
                out.push_back(head);
        }
        else if (filt.empty() || line.find(filt) != std::string::npos)
            out.push_back(line);
    };

    // The DEF/TOP disambiguator: VpiTop() is set on the elaborated view only.
    auto view = [](const BaseClass* b, bool top) {
        return std::string(top ? "/top" : "/def");
    };
    for (auto& [o, id] : s.AllObjects()) {
        if (auto* p = any_cast<const package*>(o))
            render("package '" + std::string(p->VpiName()) + "'" +
                       view(p, p->VpiTop()),
                   p->Typespecs());
        else if (auto* m = any_cast<const module_inst*>(o))
            render("module_inst '" + std::string(m->VpiName()) + "'" +
                       view(m, m->VpiTop()),
                   m->Typespecs());
        else if (auto* c = any_cast<const class_defn*>(o))
            render("class_defn '" + std::string(c->VpiName()) + "'",
                   c->Typespecs());
        else if (auto* i = any_cast<const interface_inst*>(o))
            render("interface_inst '" + std::string(i->VpiName()) + "'" +
                       view(i, i->VpiTop()),
                   i->Typespecs());
        else if (auto* f = any_cast<const task_func*>(o))
            render("task_func '" + std::string(f->VpiName()) + "'",
                   f->Typespecs());
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out)
        std::cout << l << "\n";
    return 0;
}
