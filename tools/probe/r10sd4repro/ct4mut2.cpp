// r10sd4 — THE SLOT, read by SINGLE-SLOT mutation of OUR side.
//
// WHY THE SUPPRESSION SCAN CANNOT FINISH THE JOB.  Suppressing a golden object
// is detected by asking "did the head's SIGNATURE go away?".  That test has a
// blind spot this database walks straight into: Surelog emits every package
// TWICE (def view in `uhdmallPackages`, elab view in `uhdmtopPackages`), so when
// the failure inside the DEF view's subtree is suppressed, the SAME-SHAPED
// failure recurs inside the ELAB view's subtree and the signature test reads
// "still alive".  That is exactly why sd2 found seeding golden's package objects
// left the head "byte-identical" and concluded the VECTOR arm was ruled out —
// the arm conclusion is right, the reason recorded for it is not.  Measured
// here in section [D].
//
// WHY SINGLE-SLOT MUTATION IS SOUND WHERE sd2'S BULK MUTATION WAS NOT.  sd2 §4.4
// nulled `Instance()` on ALL objects of an owner TYPE at once and got the arm to
// FLIP to `r=1 LHS=package RHS=<null>` — an INTRODUCED, EARLIER failure, which
// is why a bulk null-mutation bisect converges on "the first typespec in
// traversal order".  One slot at a time the two cases are DISTINGUISHABLE by the
// outcome itself:
//
//   * nulling a slot where GOLDEN IS NON-NULL introduces an earlier failure and
//     `m_failedLhs` is SET (r=1).  Discarded by the tool, by name.
//   * nulling THE failing slot removes the `SafeCompare(nullptr, pkg)` call, and
//     `Compare` advances to whatever is next.
//   * nulling a slot that is never compared changes nothing at all.
//
// The candidate pool is OUR objects whose singular `Instance()` IS the exact
// `m_failedRhs` pointer — nothing else can be the RHS of that call.
//
// build: g++ -O2 -std=c++17 ct4mut2.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4mut2
// usage: ct4mut2 <golden.uhdm> <ours.uhdm> [maxreport]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static design *DA, *DB;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}
struct Out {
    int r = 0;
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    size_t vis = 0;
    bool operator==(const Out& o) const {
        return r == o.r && lhs == o.lhs && rhs == o.rhs && vis == o.vis;
    }
    std::string str() const {
        return "r=" + std::to_string(r) + " lhs=" + ident(lhs) +
               " rhs=" + ident(rhs) + " visited=" + std::to_string(vis);
    }
};
static Out run(const std::vector<const BaseClass*>& seed = {}) {
    CompareContext c;
    for (auto* s : seed) c.m_visited.insert(s);
    Out o;
    o.r = DA->Compare(DB, &c);
    o.lhs = c.m_failedLhs;
    o.rhs = c.m_failedRhs;
    o.vis = c.m_visited.size();
    return o;
}

// Settable singular Instance() by owner class.  Only the classes that HAVE one.
static bool setInst(BaseClass* p, instance* v) {
    if (auto* t = any_cast<typespec*>(p)) { t->Instance(v); return true; }
    if (auto* x = any_cast<variables*>(p)) { x->Instance(v); return true; }
    if (auto* f = any_cast<task_func*>(p)) { f->Instance(v); return true; }
    if (auto* q = any_cast<ports*>(p)) { q->Instance(v); return true; }
    if (auto* cb = any_cast<clocking_block*>(p)) { cb->Instance(v); return true; }
    if (auto* in = any_cast<instance*>(p)) { in->Instance(v); return true; }
    return false;
}
static instance* getInst(BaseClass* p) {
    if (auto* t = any_cast<typespec*>(p)) return t->Instance();
    if (auto* x = any_cast<variables*>(p)) return x->Instance();
    if (auto* f = any_cast<task_func*>(p)) return f->Instance();
    if (auto* q = any_cast<ports*>(p)) return q->Instance();
    if (auto* cb = any_cast<clocking_block*>(p)) return cb->Instance();
    if (auto* in = any_cast<instance*>(p)) return in->Instance();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4mut2 <golden> <ours> [max]\n"; return 2; }
    int maxrep = argc > 3 ? atoi(argv[3]) : 40;
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;

    Out base = run();
    std::cout << "[B] BASELINE " << base.str() << "\n";
    if (!(base.r != 0 && base.lhs == nullptr && base.rhs &&
          base.rhs->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage)) {
        std::cout << "HEAD ABSENT — abort\n";
        return 1;
    }
    const BaseClass* RHS = base.rhs;

    // [D] the DUPLICATE-VIEW diagnostic: why suppressing golden's package
    // objects leaves the signature untouched.
    std::cout << "\n[D] suppressing golden's package objects, one at a time\n";
    auto show = [&](const char* tag, const package* p) {
        if (!p) return;
        Out o = run({(const BaseClass*)p});
        std::cout << "    " << tag << " " << ident(p) << " vpiTop=" << (int)p->VpiTop()
                  << "  ->  " << o.str()
                  << (o == base ? "   [IDENTICAL]" : "   [CHANGED]") << "\n";
    };
    if (DA->AllPackages()) for (auto* p : *DA->AllPackages()) show("golden ALL", p);
    if (DA->TopPackages()) for (auto* p : *DA->TopPackages()) show("golden TOP", p);

    // [M] the single-slot mutation scan.
    std::vector<BaseClass*> cand;
    for (const auto& [p, i] : sb.AllObjects()) {
        if (!p) continue;
        BaseClass* q = const_cast<BaseClass*>(p);
        if (getInst(q) == (const instance*)RHS) cand.push_back(q);
    }
    std::cout << "\n[M] OUR objects whose singular Instance() IS the failing RHS "
                 "pointer: "
              << cand.size() << "\n";
    int changed = 0, introduced = 0, shown = 0;
    std::vector<BaseClass*> real;
    for (BaseClass* q : cand) {
        instance* keep = getInst(q);
        setInst(q, nullptr);
        Out o = run();
        setInst(q, keep);
        if (o == base) continue;
        changed++;
        if (o.lhs != nullptr) {
            introduced++;  // an EARLIER, INTRODUCED failure (sd2 §4.4.2)
            if (shown < maxrep) {
                std::cout << "    INTRODUCED " << ident(q) << "  -> " << o.str()
                          << "\n";
                shown++;
            }
            continue;
        }
        real.push_back(q);
        std::cout << "    >>> SLOT " << ident(q) << "  file="
                  << std::filesystem::path(std::string(q->VpiFile()))
                         .filename()
                         .string()
                  << "\n        parent=" << ident(q->VpiParent()) << "\n"
                  << "        after nulling: " << o.str() << "\n";
    }
    // restore control — the whole point of a mutation probe
    Out ctl = run();
    std::cout << "\n[C] RESTORE CONTROL (must equal BASELINE): " << ctl.str()
              << (ctl == base ? "   OK" : "   *** MISMATCH ***") << "\n";
    std::cout << "[M] candidates=" << cand.size() << " changed=" << changed
              << " introduced-earlier=" << introduced
              << " REAL-SLOT-CANDIDATES=" << real.size() << "\n";
    return 0;
}
