// r10uvm55repro/asgat.cpp — every `assignment` (and every `method_func_call`)
// at a given LINE of a given FILE, with the fields `assignment::Compare` reads:
// VpiOpType / VpiBlocking / Lhs / Rhs / Delay_control, plus the parent chain.
//
// WHY: uhdm-cmp's `LHS: method_func_call (new) / RHS: <null>` is the SCALAR
// SafeCompare artefact (BaseClass.h: lhs non-null, rhs null -> m_failedLhs=lhs,
// m_failedRhs left UNSET), so the head names the object golden HAS, not the
// field.  This probe names the field and tells an ABSENT object from an absent
// POINTER.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
//   usage: asgat <db.uhdm> <fileSubstring> <line|all>
//     `all` matches EVERY line (for a small arm); a NUMBER matches that line
//     only, and 0 therefore selects the LOC-LESS objects — which is meaningful
//     here, because golden's `new` method_func_call is deliberately loc-less.
//
// GUARDS:
//   * zero matches is `UNMEASURED: 0 objects matched` and exit 4 — a filter that
//     reaches nothing must never read as "the object is absent".
//   * the method_func_call census is printed even when its count is 0, so
//     "golden has one and we have none" and "both have none" are distinguishable.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "-";
    std::string s(o->VpiName());
    if (s.empty()) s = "<anon>";
    return s;
}
static std::string kd(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string at(const BaseClass* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 4) { std::cerr << "usage: asgat <db.uhdm> <fileSubstring> <line>\n"; return 2; }
    std::string wf = argv[2];
    bool anyLine = std::string(argv[3]) == "all";
    uint32_t wl = (uint32_t)atoi(argv[3]);
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "UNMEASURED: no design\n"; return 4; }
    int na = 0, nm_ = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (!anyLine && o->VpiLineNo() != wl) continue;
        if (std::string(o->VpiFile()).find(wf) == std::string::npos) continue;
        if (o->UhdmType() == uhdmassignment) {
            const assignment* a = (const assignment*)o;
            na++;
            std::cout << "ASSIGN @" << at(a) << " file='" << a->VpiFile()
                      << "' opType=" << a->VpiOpType()
                      << " blocking=" << (a->VpiBlocking() ? 1 : 0)
                      << " lhs=" << kd(a->Lhs()) << ":" << nm(a->Lhs())
                      << " rhs=" << kd(a->Rhs()) << ":" << nm(a->Rhs())
                      << " rhsAt=" << at(a->Rhs())
                      << " delay=" << (a->Delay_control() ? 1 : 0)
                      << " parent=" << kd(a->VpiParent()) << ":" << nm(a->VpiParent())
                      << " gparent=" << kd(a->VpiParent() ? a->VpiParent()->VpiParent() : nullptr)
                      << ":" << nm(a->VpiParent() ? a->VpiParent()->VpiParent() : nullptr)
                      << "\n";
        } else if (o->UhdmType() == uhdmmethod_func_call) {
            const method_func_call* m = (const method_func_call*)o;
            nm_++;
            std::cout << "MFCALL '" << nm(m) << "' @" << at(m)
                      << " parent=" << kd(m->VpiParent()) << ":" << nm(m->VpiParent())
                      << " parentAt=" << at(m->VpiParent())
                      << " prefix=" << kd(m->Prefix())
                      << " args=" << (m->Tf_call_args() ? (int)m->Tf_call_args()->size() : -1)
                      << " func=" << (m->Function() ? nm((const BaseClass*)m->Function()) : "-")
                      << "\n";
        }
    }
    std::cout << "-- assignment=" << na << "  method_func_call=" << nm_
              << "  (file~'" << wf << "' line=" << wl << ")\n";
    if (na == 0 && nm_ == 0) { std::cout << "UNMEASURED: 0 objects matched\n"; return 4; }
    return 0;
}
