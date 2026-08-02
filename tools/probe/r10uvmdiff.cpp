// r10uvmdiff: side-by-side listing of one class_defn vector (Variables /
// Named_events / Typespecs / Deriveds) for named classes, ours vs golden.
//   r10uvmdiff <ours.uhdm> <golden.uhdm> <vector> <classname>...
// vector in {vars,events,ts,der,tf,parms}
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string brief(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static void collectClasses(design* d, std::map<std::string, class_defn*>& out) {
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) out[std::string(c->VpiName())] = c;
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            if (p->Class_defns())
                for (auto* c : *p->Class_defns())
                    out.emplace(std::string(c->VpiName()), c);
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            if (p->Class_defns())
                for (auto* c : *p->Class_defns())
                    out.emplace(std::string(c->VpiName()), c);
}

template <typename V>
static void show(const char* side, const V* v) {
    if (!v) {
        std::cout << "  " << side << ": <null>\n";
        return;
    }
    std::cout << "  " << side << ": " << v->size() << "\n";
    int i = 0;
    for (auto* x : *v) std::cout << "    [" << i++ << "] " << brief(x) << "\n";
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::map<std::string, class_defn*> ca, cb;
    collectClasses(da, ca);
    collectClasses(db, cb);
    std::string vec = argv[3];
    for (int i = 4; i < argc; i++) {
        std::string n = argv[i];
        std::cout << "=== " << n << " (" << (ca.count(n) ? "ours ok" : "ours MISSING")
                  << ", " << (cb.count(n) ? "gold ok" : "gold MISSING") << ")\n";
        auto* A = ca.count(n) ? ca[n] : nullptr;
        auto* B = cb.count(n) ? cb[n] : nullptr;
        if (vec == "vars") {
            show("ours", A ? A->Variables() : nullptr);
            show("gold", B ? B->Variables() : nullptr);
        } else if (vec == "events") {
            show("ours", A ? A->Named_events() : nullptr);
            show("gold", B ? B->Named_events() : nullptr);
        } else if (vec == "ts") {
            show("ours", A ? A->Typespecs() : nullptr);
            show("gold", B ? B->Typespecs() : nullptr);
        } else if (vec == "der") {
            show("ours", A ? A->Deriveds() : nullptr);
            show("gold", B ? B->Deriveds() : nullptr);
        } else if (vec == "tf") {
            show("ours", A ? A->Task_funcs() : nullptr);
            show("gold", B ? B->Task_funcs() : nullptr);
        } else if (vec == "parms") {
            show("ours", A ? A->Parameters() : nullptr);
            show("gold", B ? B->Parameters() : nullptr);
        }
    }
    return 0;
}
