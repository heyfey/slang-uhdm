// r10bbp11l: WHOLE-ARENA CMP-projection LOCALIZER.  Walks the design with
// UhdmListener and tallies one normalized signature per object using only the
// fields uhdm-cmp reads (UhdmType / VpiName / VpiDefName, plus constant's
// VpiConstType / VpiDecompile / VpiSize and whether it carries a vpiTypespec),
// keyed by source line:col so a surviving difference can be located.  Run on
// both databases and multiset-diff the two tallies: the residue count is a
// monotone progress metric that, unlike a fresh-CompareContext drill, cannot
// over-report objects that whole-object Compare never reaches unequal.
//
// The signature deliberately includes line:col.  That is NOT a CMP field, so a
// pure location difference shows up as a residue pair — read the output as a
// LOCALIZER, and confirm any candidate against tools/cmptool (the DESIGN line
// is the authority).
//
// MEASURED CAVEAT (r10bbp11, BlackBePipeInt).  On a design this size the
// listener reaches far more than Compare does: golden tallied 10297 distinct
// signatures over 718623 visits, ours 36989 over 289780, and the location-free
// key diff was 3074 ours-only vs 7 golden-only — 3028 of the ours-only rows
// were hier_paths (`bp_default_cfg_p.<field>`) inside package parameter
// initializers whose packages nonetheless compare EQUAL whole-object.  So this
// probe is NOT a progress metric here; the honest ones are cmptool's DESIGN
// head and the r10bbp10b per-slot drill tallied by (failLhs type, failRhs
// type, line:col).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp11l.cpp -o /tmp/r10bbp11lq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp11lq <db.uhdm> > tally.txt      (then `diff` the two tallies)
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<std::string, int> tally;

class L : public UhdmListener {
 public:
    void enterAny(const any* const o) override {
        if (!o) return;
        std::string k = std::string(UhdmName(o->UhdmType())) + " '" +
                        std::string(o->VpiName()) + "'";
        std::string dn(o->VpiDefName());
        if (!dn.empty()) k += " def'" + dn + "'";
        if (o->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)o;
            k += " {ct=" + std::to_string(c->VpiConstType()) +
                 " sz=" + std::to_string(c->VpiSize()) + " dec=" +
                 std::string(c->VpiDecompile()) +
                 " ts=" + (c->Typespec() ? "y" : "n") + "}";
        }
        k += " @" + std::to_string(o->VpiLineNo()) + ":" +
             std::to_string(o->VpiColumnNo());
        tally[k]++;
    }
};

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    L l;
    l.listenAny(d);
    for (auto& [k, n] : tally) std::cout << n << "\t" << k << "\n";
    return 0;
}
