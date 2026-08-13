// r10sd3 — WHERE do the class_defn-valued vpiInstance slots live?  Parent chains
// on OUR side, plus the matching GOLDEN object's VpiFile (ours is empty — sd2 R7,
// so the FILE has to come from golden's copy of the same span key).
//
// ct3cls.cpp answers "what does golden hold there" (the fix DIRECTION).  This
// answers "which construct emits it" (the fix SITE): for every object whose
// Instance() is a class_defn it prints
//     ownerType|name|span  <- parent chain (type(name) x N)  file=<golden's>
// and a histogram of the chain SHAPES, which is what actually names the emitter.
//
// build: g++ -O2 -std=c++17 ct3site.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct3site
// usage: ct3site <golden.uhdm> <ours.uhdm> [maxexamples]
#include <uhdm/uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    std::ostringstream k;
    k << UhdmName(p->UhdmType()) << "|" << p->VpiName() << "|" << p->VpiLineNo()
      << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo() << ":"
      << p->VpiEndColumnNo();
    return k.str();
}
static std::string spanOnly(const BaseClass* p) {
    std::ostringstream k;
    k << p->VpiLineNo() << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo()
      << ":" << p->VpiEndColumnNo();
    return k.str();
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct3site <golden> <ours> [maxex]\n"; return 2; }
    int maxex = argc > 3 ? atoi(argv[3]) : 40;

    // golden: key -> file (for the span the emitter used)
    std::map<std::string, std::string> gfile;
    {
        Serializer ser;
        auto h = ser.Restore(std::filesystem::path(argv[1]));
        if (h.empty()) { std::cerr << "RESTORE_FAIL golden\n"; return 3; }
        for (const auto& [p, id] : ser.AllObjects()) {
            if (!p) continue;
            if (!p->VpiFile().empty() && !gfile.count(span(p)))
                gfile[span(p)] = std::string(p->VpiFile());
        }
    }

    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[2]));
    if (h.empty()) { std::cerr << "RESTORE_FAIL ours\n"; return 3; }
    auto* dOurs = (design*)((uhdm_handle*)h[0])->object;
    std::map<const BaseClass*, std::string> pkgState;
    if (dOurs->AllPackages())
        for (auto* p : *dOurs->AllPackages()) pkgState[p] = "ALL:" + std::string(p->VpiName());
    if (dOurs->TopPackages())
        for (auto* p : *dOurs->TopPackages()) pkgState[p] = "TOP:" + std::string(p->VpiName());
    std::map<std::string, int> homeHist;
    std::map<std::string, int> shapes;
    std::map<std::string, int> fileHist;
    std::map<std::string, std::vector<std::string>> shapeEx;
    int n = 0;
    for (const auto& [p, id] : ser.AllObjects()) {
        if (!p) continue;
        const typespec* t = any_cast<const typespec*>(p);
        const variables* v = any_cast<const variables*>(p);
        const task_func* f = any_cast<const task_func*>(p);
        if (!(t || v || f)) continue;
        const instance* val = t ? t->Instance() : v ? v->Instance() : f->Instance();
        if (!val || val->UhdmType() != uhdmclass_defn) continue;
        n++;
        // WHERE would "the class's HOME scope" point?  Walk the class_defn's
        // VpiParent chain to the first object that can legally hold an instance
        // and report which VIEW's package copy that is.
        {
            const BaseClass* hp = val->VpiParent();
            int hops = 0;
            while (hp && hp->UhdmType() != uhdmpackage &&
                   hp->UhdmType() != uhdmmodule_inst &&
                   hp->UhdmType() != uhdminterface_inst &&
                   hp->UhdmType() != uhdmdesign && hops++ < 8)
                hp = hp->VpiParent();
            std::string hs = "<none>";
            if (hp) {
                auto it = pkgState.find(hp);
                hs = it != pkgState.end()
                         ? it->second
                         : (std::string(UhdmName(hp->UhdmType())) + "(" +
                            std::string(hp->VpiName()) + ")");
            }
            homeHist[hs]++;
        }
        std::ostringstream chain, shape;
        chain << span(p) << " -> INST class_defn(" << val->VpiName() << ")";
        shape << UhdmName(p->UhdmType());
        const BaseClass* q = p->VpiParent();
        for (int i = 0; i < 8 && q; i++) {
            chain << "\n      ^" << i << " " << UhdmName(q->UhdmType()) << "("
                  << q->VpiName() << ")@" << spanOnly(q);
            shape << " < " << UhdmName(q->UhdmType());
            q = q->VpiParent();
        }
        std::string fl = gfile.count(span(p)) ? gfile[span(p)] : "<no golden twin>";
        chain << "\n      file(golden twin)=" << fl;
        // strip directory for the histogram
        auto sl = fl.find_last_of('/');
        fileHist[sl == std::string::npos ? fl : fl.substr(sl + 1)]++;
        shapes[shape.str()]++;
        if ((int)shapeEx[shape.str()].size() < 3) shapeEx[shape.str()].push_back(chain.str());
    }
    std::cout << "class_defn-valued Instance() slots on OUR side: " << n << "\n";
    std::cout << "\nPARENT-CHAIN SHAPES\n";
    std::vector<std::pair<int, std::string>> sv;
    for (auto& [k, c] : shapes) sv.push_back({c, k});
    std::sort(sv.rbegin(), sv.rend());
    for (auto& [c, k] : sv) printf("%6d  %s\n", c, k.c_str());
    std::cout << "\nHOME SCOPE the class_defn would re-point to (its VpiParent chain)\n";
    for (auto& [k, c] : homeHist) printf("%6d  %s\n", c, k.c_str());
    std::cout << "\nBY SOURCE FILE (from golden's twin at the same span key)\n";
    for (auto& [k, c] : fileHist) printf("%6d  %s\n", c, k.c_str());
    std::cout << "\nEXAMPLES\n";
    int shown = 0;
    for (auto& [k, ex] : shapeEx)
        for (auto& e : ex) { if (shown++ >= maxex) break; std::cout << "  " << e << "\n"; }
    return 0;
}
