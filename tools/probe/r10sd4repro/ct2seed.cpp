// r10sd2 — DELTA-DEBUG THE HEAD: bisect over the GOLDEN OBJECT SET.
//
// `ct2bisect.cpp` reported "no child owns the head" at the design, and that is
// TRUE, not a bug: the culprit object is reachable through MANY paths, so
// suppressing any ONE path leaves the head standing.  What suppresses it is
// suppressing the OBJECT.
//
// Every generated `Compare` opens with `if (!context->m_visited.insert(this)
// .second) return 0;` — keyed on the LHS (golden) object.  So pre-seeding a
// golden pointer makes the real `Compare` treat that object as already-equal,
// wherever it is reached from.  Bisect the whole golden object set on that
// operation and the last surviving singleton is the golden object whose slot is
// NULL where ours is filled — the head's owner, read out of `Compare` itself
// rather than out of a re-implementation of it.
//
// build: g++ -O2 -std=c++17 ct2seed.cpp -I ~/.local/include -I. \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2seed
// usage: ct2seed <golden.uhdm> <ours.uhdm> <targetPkgName>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string g_target;

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

static bool isTarget(const BaseClass* p) {
    return p && p->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage &&
           std::string(p->VpiName()) == g_target;
}

static const BaseClass *G, *O;

// true == the head signature `LHS:<null>` / `RHS: package <target>` is STILL
// present when the given golden objects are pre-declared equal.
static bool headWith(const std::vector<const BaseClass*>& seed,
                     const BaseClass** outLhs, const BaseClass** outRhs) {
    CompareContext c;
    for (const BaseClass* s : seed) c.m_visited.insert(s);
    int r = G->Compare(O, &c);
    if (outLhs) *outLhs = c.m_failedLhs;
    if (outRhs) *outRhs = c.m_failedRhs;
    return r != 0 && c.m_failedLhs == nullptr && isTarget(c.m_failedRhs);
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: ct2seed <golden.uhdm> <ours.uhdm> <pkg>\n";
        return 2;
    }
    g_target = argv[3];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    G = (design*)((uhdm_handle*)ha[0])->object;
    O = (design*)((uhdm_handle*)hb[0])->object;

    const BaseClass *fl = nullptr, *fr = nullptr;
    if (!headWith({}, &fl, &fr)) {
        std::cout << "HEAD SIGNATURE ABSENT: lhs=" << ident(fl)
                  << " rhs=" << ident(fr) << "\n";
        return 1;
    }
    std::cout << "head present: lhs=<null> rhs=" << ident(fr) << "\n";

    std::vector<const BaseClass*> all;
    for (const auto& [p, id] : sa.AllObjects())
        if (p && p != G) all.push_back(p);
    std::cout << "golden objects: " << all.size() << "\n";
    if (headWith(all, &fl, &fr))
        std::cout << "WARNING: seeding EVERY golden object still shows the head "
                     "(so it is not owned by any single golden object)\n";

    // Delta-debug down to one object.
    std::vector<const BaseClass*> cand = all;
    while (cand.size() > 1) {
        size_t half = cand.size() / 2;
        std::vector<const BaseClass*> a(cand.begin(), cand.begin() + half);
        std::vector<const BaseClass*> b(cand.begin() + half, cand.end());
        if (!headWith(a, nullptr, nullptr)) {
            cand = a;
        } else if (!headWith(b, nullptr, nullptr)) {
            cand = b;
        } else {
            std::cout << "SPLIT STALLED at " << cand.size()
                      << " candidates — more than one golden object must be "
                         "suppressed; reporting the set's first 20:\n";
            for (size_t i = 0; i < cand.size() && i < 20; i++)
                std::cout << "    " << ident(cand[i]) << "\n";
            return 3;
        }
        std::cout << "  narrowed to " << cand.size() << "\n";
    }
    std::cout << "\n>>> THE HEAD'S GOLDEN OWNER: " << ident(cand[0]) << "\n";
    const BaseClass* owner = cand[0];
    std::cout << ">>> parent chain:";
    int guard = 0;
    for (const BaseClass* p = owner; p && guard < 12;
         p = (const BaseClass*)p->VpiParent(), guard++)
        std::cout << " < " << ident(p);
    std::cout << "\n";
    // What does Compare report once this object is out of the way?
    std::vector<const BaseClass*> one{owner};
    bool still = headWith(one, &fl, &fr);
    std::cout << ">>> with it suppressed, the next failure is lhs=" << ident(fl)
              << " rhs=" << ident(fr) << "  (sameSignature=" << still << ")\n";
    return 0;
}
