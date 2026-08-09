// r10earl14b — WHO POINTS AT THIS OBJECT?  r10earl11p/13p hard-code "a package
// with name X"; the pass-14 residues are reached through an ordinary expression
// (an operation, a constant, a ref_typespec) whose only identity is its type and
// source position, and the interesting fact is the LINKING member, i.e. the
// listener callstack's immediate parent.  Matches on <type>:<line>:<col> and
// prints every visit's callstack.
// Build: bash tools/probe/r10earl14build.sh r10earl14b
// Usage: r10earl14b <a.uhdm> <all|top|allpkg|toppkg> <Name> <type> <line> [col]
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string wtype;
static int wline = -1, wcol = -1;

class Finder : public UhdmListener {
public:
    int shown = 0;
    void enterAny(const any* const o) override {
        if (std::string(UhdmName(o->UhdmType())) != wtype)
            return;
        if (wline >= 0 && (int)o->VpiLineNo() != wline)
            return;
        if (wcol >= 0 && (int)o->VpiColumnNo() != wcol)
            return;
        if (shown++ > 8)
            return;
        // EVERY link, not just the first: the listener's visited set hides the
        // second and later pointers to the same object, and the interesting
        // pointer in a SafeCompare-null head is usually NOT the first one.
        getVisited().erase(o);
        std::cout << "  HIT " << UhdmName(o->UhdmType()) << " '" << o->VpiName()
                  << "' " << o->VpiLineNo() << ":" << o->VpiColumnNo()
                  << " uid=" << o->UhdmId() << "\n";
        int d = 0;
        for (auto it = getCallstack().rbegin(); it != getCallstack().rend(); ++it) {
            const any* a = *it;
            std::cout << "     ^ " << UhdmName(a->UhdmType()) << " '" << a->VpiName()
                      << "' " << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << " uid=" << a->UhdmId() << "\n";
            if (++d > 8)
                break;
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 6)
        return 1;
    std::string vec = argv[2], want = argv[3];
    wtype = argv[4];
    wline = atoi(argv[5]);
    if (argc > 6)
        wcol = atoi(argv[6]);
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 2;
    auto* d = (const design*)((uhdm_handle*)h[0])->object;
    auto run = [&](const instance* m) {
        std::cout << "== " << m->VpiDefName() << " uid=" << m->UhdmId()
                  << " top=" << (int)m->VpiTop() << "\n";
        Finder f;
        f.getVisited().insert(d);
        f.listenAny(m);
    };
    auto scan = [&](auto* v) {
        if (!v)
            return;
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                run(x);
        }
    };
    if (vec == "all")
        scan(d->AllModules());
    else if (vec == "top")
        scan(d->TopModules());
    else if (vec == "allpkg")
        scan(d->AllPackages());
    else
        scan(d->TopPackages());
    return 0;
}
