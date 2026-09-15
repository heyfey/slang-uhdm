// r11u45/cmpid45 — NAME THE HEAD'S SLOT.
//
// uhdm-cmp prints the failed object but not WHICH SLOT of WHICH OWNER it sat
// in, and the two SafeCompare overloads print the same text for two different
// causes (a null VECTOR on the owner vs a null SINGULAR value) — RESUME.md §9.
// This runs the OFFICIAL design::Compare and then reports, for the failed LHS:
//   its pointer id (same interning as tslist45), its kind, loc, and the whole
//   VpiParent chain, so the slot is named from the database rather than guessed
//   from the printed text.
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
static std::string desc(const any* a) {
    if (!a) return "<null>";
    char b[256];
    snprintf(b, sizeof b, "#%d %s (%s) loc=%d:%d..%d:%d", idOf(a),
             std::string(UhdmName(a->UhdmType())).c_str(), std::string(a->VpiName()).c_str(),
             (int)a->VpiLineNo(), (int)a->VpiColumnNo(), (int)a->VpiEndLineNo(),
             (int)a->VpiEndColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: cmpid45 <golden.uhdm> <ours.uhdm>\n"; return 2; }
    Serializer sg, so;
    auto g = sg.Restore(std::string(argv[1]));
    auto o = so.Restore(std::string(argv[2]));
    if (g.empty() || o.empty()) { std::cerr << "FATAL: restore empty\n"; return 3; }
    // Intern golden's ids in the SAME AllObjects order tslist45 uses, so the
    // id printed here indexes that listing.
    for (auto& [ptr, id] : sg.AllObjects()) (void)id, idOf(ptr);
    auto* dg = (design*)((uhdm_handle*)g[0])->object;
    auto* dob = (design*)((uhdm_handle*)o[0])->object;
    CompareContext ctx;
    int r = dg->Compare(dob, &ctx);
    std::cout << "Compare r=" << r << "\n";
    std::cout << "failedLhs: " << desc(ctx.m_failedLhs) << "\n";
    std::cout << "failedRhs: " << (ctx.m_failedRhs ? desc(ctx.m_failedRhs)
                                                   : std::string("<unset>")) << "\n";
    const any* p = ctx.m_failedLhs;
    int d = 0;
    while (p && d++ < 12) {
        std::cout << "  parent[" << d << "]: " << desc(p->VpiParent()) << "\n";
        p = p->VpiParent();
    }
    // WHO POINTS AT IT: a null SINGULAR on our side names the golden VALUE, so
    // the slot is found by asking which golden ref_typespec (or elem/index
    // slot) targets the failed object.
    for (auto& [ptr, id] : sg.AllObjects()) {
        (void)id;
        const any* a = (const any*)ptr;
        if (!a || a->UhdmType() != uhdmref_typespec) continue;
        auto* rt = (const ref_typespec*)a;
        if ((const any*)rt->Actual_typespec() != ctx.m_failedLhs) continue;
        std::cout << "  ownerRef: " << desc(a) << " full=" << rt->VpiFullName()
                  << "\n            refParent: " << desc(a->VpiParent());
        if (a->VpiParent())
            std::cout << "\n            refGrandparent: " << desc(a->VpiParent()->VpiParent());
        std::cout << "\n";
    }
    return 0;
}
