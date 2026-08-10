// r10uvm43cp — the CONTAINER-POSITION census: for every array_typespec /
// packed_array_typespec, WHAT OBJECT sits in its ELEMENT and INDEX position,
// projected onto the fields uhdm-cmp actually compares (kind + VpiName) plus
// the one identity bit the name cannot carry: is that object a member of some
// scope's typespec LISTING, a per-declaration CLONE (it has a Typedef_alias of
// its own), or a plain fresh object?
//
// WHY THIS PROBE EXISTS.  § arrayElemTdClone42 (pass 42) is stated as "a
// container position never binds a LISTING object", and pass 42's LISTDIRECT
// metric counts violations of exactly that.  But LISTDIRECT is measured FROM
// THE LISTING OBJECT'S SIDE (r10uvm42tw's referrer multiset), so it can only
// say that a direct reference exists — it cannot say what golden puts there
// INSTEAD.  Widening the law's kind gate lowers LISTDIRECT by construction,
// and that is NOT the same as agreeing with golden: if golden's element is an
// UNNAMED typespec, then swapping a qualified listing object for a bare clone
// changes one non-matching VpiName for another and the verdict does not move.
// A METRIC THAT ONLY EVER LOOKED FROM ONE SIDE HAS AN UNMEASURED HALF.
//
// Ordering is a TOTAL ORDER on the printed text (Serializer::AllObjects is
// keyed by POINTER and its order changes run to run).
//
//   r10uvm43cp <file.uhdm> [nameFilter]
// nameFilter matches the array_typespec's own name OR either position's name.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm43cp <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 1;

    std::set<const typespec*> listed;
    auto noteList = [&](const std::vector<typespec*>* v) {
        if (v)
            for (auto* t : *v) listed.insert(t);
    };
    for (auto& [o, id] : s.AllObjects()) {
        if (auto* p = any_cast<const package*>(o)) noteList(p->Typespecs());
        else if (auto* m = any_cast<const module_inst*>(o)) noteList(m->Typespecs());
        else if (auto* c = any_cast<const class_defn*>(o)) noteList(c->Typespecs());
        else if (auto* i = any_cast<const interface_inst*>(o)) noteList(i->Typespecs());
        else if (auto* f = any_cast<const task_func*>(o)) noteList(f->Typespecs());
    }

    auto spanOf = [](const BaseClass* b) {
        char buf[64];
        snprintf(buf, sizeof buf, "%u:%u-%u:%u", b->VpiLineNo(),
                 (unsigned)b->VpiColumnNo(), b->VpiEndLineNo(),
                 (unsigned)b->VpiEndColumnNo());
        return std::string(buf);
    };
    // One position, rendered: kind, name, the identity bit, and the span,
    // which is what separates a clone at the TYPEDEF from a clone re-spanned
    // at the declaration.
    auto pos = [&](const ref_typespec* r) {
        if (!r) return std::string("<noref>");
        const typespec* t = r->Actual_typespec();
        if (!t) return std::string("<null>");
        std::string n(t->VpiName());
        std::string tag = listed.count(t) ? "LISTED"
                          : t->Typedef_alias() ? "CLONE"
                                               : "plain";
        return std::string(UhdmName(t->UhdmType())) + "'" +
               (n.empty() ? std::string("<unnamed>") : n) + "'/" + tag + "@" +
               spanOf(t);
    };

    std::vector<std::string> out;
    for (auto& [o, id] : s.AllObjects()) {
        std::string line;
        if (auto* a = any_cast<const array_typespec*>(o)) {
            line = spanOf(a) + " array_typespec '" +
                   std::string(a->VpiName()) + "'" +
                   (listed.count(a) ? "/LISTED" : (a->Typedef_alias() ? "/CLONE" : "/plain")) +
                   " elem=" + pos(a->Elem_typespec()) +
                   " idx=" + pos(a->Index_typespec());
        }
        else if (auto* p = any_cast<const packed_array_typespec*>(o)) {
            line = spanOf(p) + " packed_array_typespec '" +
                   std::string(p->VpiName()) + "'" +
                   (listed.count(p) ? "/LISTED" : (p->Typedef_alias() ? "/CLONE" : "/plain")) +
                   " elem=" + pos(p->Elem_typespec());
        }
        else
            continue;
        if (!filt.empty() && line.find(filt) == std::string::npos) continue;
        out.push_back(line);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
