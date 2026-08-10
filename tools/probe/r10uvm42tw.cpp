// r10uvm42tw — the TWIN-USE census: which of a package typedef's typespec
// TWINS does each REFERENCE POSITION take?
//
// Pass 41 closed on a question no probe could answer.  `r10uvm41ts` prints one
// line per NAMED typespec object with its fan-in, which is enough to see a
// shared object being re-spanned, but not enough to see WHO points at it: a
// packed-vector package typedef ends up with a whole FAMILY of typespec
// objects in both databases (a def-listing object, an elaborated-listing
// object, and one per-declaration NAMED CLONE), and the cmp-relevant question
// is which family member each declaration's ref_typespec resolves to.  A
// KIND:NAME census cannot answer an IDENTITY question, and a fan-in count
// cannot answer a WHO question.
//
// So for every named typespec object matching the filter this prints
//   <span> <kind> '<name>' inst=<i> LISTED|- alias=<target-name|-> fanin=N
//     <- <count> x <referring ref_typespec's parent kind>['<parent name>']
// where LISTED means the object is a member of some scope's vpiTypespec
// listing (i.e. it is one of the two SHARED listing objects, not a clone) and
// alias= reports the object's own Typedef_alias target, the marker Surelog
// puts on a per-declaration clone.
//
// Ordering is a TOTAL ORDER on the printed text; Serializer::AllObjects is a
// std::map keyed by POINTER and its order changes run to run.
//
//   r10uvm42tw <file.uhdm> [nameFilter]
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
        std::cerr << "usage: r10uvm42tw <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 1;

    // Which objects are LISTING objects (a member of some scope's typespec
    // vector)?  That is what separates the two shared twins from every
    // per-declaration clone.
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

    // Fan-in, and WHO: for each typespec, the multiset of referring
    // ref_typespec PARENT kinds (with the parent's own name when it has one).
    std::map<const typespec*, int> fanin;
    std::map<const typespec*, std::map<std::string, int>> who;
    for (auto& [o, id] : s.AllObjects()) {
        auto* r = any_cast<const ref_typespec*>(o);
        if (!r) continue;
        auto* a = r->Actual_typespec();
        if (!a) continue;
        fanin[a]++;
        const any* par = r->VpiParent();
        std::string k = par ? std::string(UhdmName(par->UhdmType())) : "<null>";
        if (par && !par->VpiName().empty())
            k += "'" + std::string(par->VpiName()) + "'";
        who[a][k]++;
    }

    std::vector<std::string> out;
    for (auto& [o, id] : s.AllObjects()) {
        auto* ts = any_cast<const typespec*>(o);
        if (!ts || ts->VpiName().empty()) continue;
        std::string nm(ts->VpiName());
        if (!filt.empty() && nm.find(filt) == std::string::npos) continue;
        char buf[64];
        snprintf(buf, sizeof buf, "%06u:%03u-%06u:%03u", ts->VpiLineNo(),
                 ts->VpiColumnNo(), ts->VpiEndLineNo(), ts->VpiEndColumnNo());
        std::string al = "-";
        if (auto* ar = ts->Typedef_alias()) {
            al = "ref";
            if (auto* at = ar->Actual_typespec())
                al = at->VpiName().empty() ? std::string("<unnamed>")
                                           : std::string(at->VpiName());
        }
        std::string line =
            std::string(buf) + " " + std::string(UhdmName(ts->UhdmType())) +
            " '" + nm + "' inst=" +
            (ts->Instance() ? std::string(ts->Instance()->VpiName())
                            : std::string("-")) +
            (listed.count(ts) ? " LISTED" : " -") + " alias=" + al +
            " fanin=" + std::to_string(fanin.count(ts) ? fanin[ts] : 0);
        // The WHO block is folded into the SAME line so the whole census stays
        // one sortable record per object.
        if (who.count(ts))
            for (auto& [k, n] : who[ts])
                line += " | " + std::to_string(n) + "x" + k;
        out.push_back(line);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
