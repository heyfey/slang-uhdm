// r11u45/tslist45 — THE SHAPE LISTER beside the census (RESUME.md §9).
//
// Walks Serializer::AllObjects after a Restore and prints EVERY typespec:
//
//   TS #<id> <kind> loc=<l:c..l:c> ranges=<n|-1 null|-2 n/a> name=<vpiName>
//      parent=<kind>(<name>)
//
// and EVERY ref_typespec:
//
//   RT #<id> name=<vpiName> full=<vpiFullName> -> ts#<id> parent=<kind>(<name>)
//
// The id is the pointer interned in first-seen order — stable within ONE
// database, meaningless across two.  Two rows sharing an id is a PROVEN share;
// two rows printing the same dump text is not (uhdm-dump elides repeats).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size() + 1;
    ids[p] = n;
    return n;
}
static std::string loc(const any* a) {
    if (!a) return "-";
    char b[64];
    snprintf(b, sizeof b, "%d:%d..%d:%d", (int)a->VpiLineNo(), (int)a->VpiColumnNo(),
             (int)a->VpiEndLineNo(), (int)a->VpiEndColumnNo());
    return b;
}
static int nRanges(const typespec* ts) {
    if (!ts) return -1;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: { auto* v = ((logic_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmbit_typespec: { auto* v = ((bit_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmpacked_array_typespec: { auto* v = ((packed_array_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmarray_typespec: { auto* v = ((array_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        default: return -2;
    }
}
static std::string par(const any* a) {
    const any* p = a ? a->VpiParent() : nullptr;
    if (!p) return "<null>";
    return std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")";
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: tslist45 <file.uhdm>\n"; return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cerr << "FATAL: restore empty\n"; return 3; }
    // Intern ids in AllObjects order so the listing is deterministic.
    auto all = s.AllObjects();
    for (auto& [ptr, id] : all) (void)id, idOf(ptr);
    for (auto& [ptr, id] : all) {
        (void)id;
        const any* a = (const any*)ptr;
        if (!a) continue;
        if (a->UhdmType() == uhdmref_typespec) {
            auto* rt = (const ref_typespec*)a;
            std::cout << "RT #" << idOf(a) << " name=" << rt->VpiName()
                      << " full=" << rt->VpiFullName()
                      << " -> ts#" << idOf(rt->Actual_typespec())
                      << " parent=" << par(a) << "\n";
            continue;
        }
        if (const typespec* ts = any_cast<const typespec*>(a)) {
            std::cout << "TS #" << idOf(a) << " " << UhdmName(a->UhdmType())
                      << " loc=" << loc(a) << " ranges=" << nRanges(ts)
                      << " name=" << a->VpiName() << " parent=" << par(a) << "\n";
        }
    }
    return 0;
}
