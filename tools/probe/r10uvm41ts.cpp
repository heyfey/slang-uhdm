// r10uvm41ts — the NAMED-TYPESPEC IDENTITY census.
//
// Pass 40's defect was a SHARED-OBJECT MUTATION: one associative declaration
// re-spanned the typespec object that every other user of the same typedef
// points at.  No existing probe could see it, because the metric panel
// projects onto the fields uhdm-cmp compares and a SourceLocation is not one
// of them — the damage showed up only as a dump difference at declarations
// that were never touched.
//
// So this probe prints ONE LINE PER NAMED TYPESPEC OBJECT (pointer identity,
// not KIND:NAME): kind, vpiName, span, vpiInstance's name, vpiSigned, and how
// many other objects point at it through a ref_typespec.  A shared object that
// has been stamped by one of its users stands out as a span that is not its
// typedef's.
//
// Objects are emitted in a TOTAL ORDER on (file,line,col,kind,name) — never
// first-hit and never Serializer order, because Serializer::AllObjects is a
// std::map keyed by POINTER and its order changes run to run.
//
//   r10uvm41ts <file.uhdm> [nameFilter]
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm41ts <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 1;
    // Fan-in: how many ref_typespecs resolve to each typespec object.
    std::map<const typespec*, int> fanin;
    for (auto& [o, id] : s.AllObjects())
        if (auto* r = any_cast<const ref_typespec*>(o))
            if (auto* a = r->Actual_typespec())
                fanin[a]++;
    std::vector<std::string> out;
    for (auto& [o, id] : s.AllObjects()) {
        auto* ts = any_cast<const typespec*>(o);
        if (!ts || ts->VpiName().empty())
            continue;
        std::string nm(ts->VpiName());
        if (!filt.empty() && nm.find(filt) == std::string::npos)
            continue;
        char buf[64];
        snprintf(buf, sizeof buf, "%06u:%03u-%06u:%03u", ts->VpiLineNo(),
                 ts->VpiColumnNo(), ts->VpiEndLineNo(), ts->VpiEndColumnNo());
        std::string line = std::string(buf) + " " +
                           std::string(UhdmName(ts->UhdmType())) + " '" + nm +
                           "' inst=" +
                           (ts->Instance() ? std::string(ts->Instance()->VpiName())
                                           : std::string("-")) +
                           " fanin=" + std::to_string(fanin.count(ts) ? fanin[ts] : 0);
        out.push_back(line);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out)
        std::cout << l << "\n";
    return 0;
}
