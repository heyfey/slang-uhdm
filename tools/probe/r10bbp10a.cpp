// r10bbp10a: per-view param_assign LHS POINTER IDENTITY probe.
// For every top-level view (ALLPKG/TOPPKG/ALLMOD/TOPMOD) and every
// param_assign whose Lhs has the requested name, print:
//   - the Lhs object's UhdmId (pointer identity proxy) and loc
//   - whether that Lhs is ALSO a member of the view's own Parameters() list
//     (index) or is a DEDICATED clone (not in the list)
//   - the Lhs parameter's every CMP-relevant child slot: Typespec chain,
//     Expr, Ranges, and its VpiParent
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp10a.cpp -o /tmp/r10bbp10aq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp10aq <db.uhdm> <param-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const any* n) {
    if (!n) return "NULL";
    std::string s = std::string(UhdmName(n->UhdmType())) + "#" +
                    std::to_string(n->UhdmId()) + "@" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    std::string nm(n->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s;
}

static std::string want;

static void dumpParam(const std::string& pre, const parameter* p) {
    std::cout << pre << " LHS " << at(p) << " par=" << at(p->VpiParent())
              << "\n";
    if (auto* rt = p->Typespec()) {
        std::cout << pre << "   ts=" << at(rt)
                  << " par=" << at(rt->VpiParent())
                  << " actual=" << at(rt->Actual_typespec());
        if (auto* a = rt->Actual_typespec())
            std::cout << " actualpar=" << at(a->VpiParent());
        std::cout << "\n";
    }
    else
        std::cout << pre << "   ts=NULL\n";
    std::cout << pre << "   expr=" << at(p->Expr())
              << " ranges=" << (p->Ranges() ? p->Ranges()->size() : 0)
              << " local=" << p->VpiLocalParam()
              << " imported=" << p->VpiImported() << "\n";
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* inst : *v) {
        std::string vw(tag + "/" + std::string(inst->VpiName()));
        if (inst->UhdmType() == uhdmpackage)
            vw += ((const package*)inst)->VpiTop() ? "[TOP]" : "[DEF]";
        if (!inst->Param_assigns()) continue;
        int i = 0;
        for (auto* pas : *inst->Param_assigns()) {
            int idx = i++;
            auto* l = pas->Lhs();
            if (!l) continue;
            if (std::string(l->VpiName()) != want) continue;
            std::cout << "== " << vw << " Param_assigns[" << idx << "] "
                      << at(pas) << " par=" << at(pas->VpiParent()) << "\n";
            // is the Lhs also in the view's Parameters() list?
            int found = -1;
            if (inst->Parameters()) {
                int j = 0;
                for (auto* q : *inst->Parameters()) {
                    if ((const any*)q == (const any*)l) { found = j; break; }
                    j++;
                }
            }
            std::cout << "   inParametersList=" << found << "\n";
            if (l->UhdmType() == uhdmparameter)
                dumpParam("  ", (const parameter*)l);
            else
                std::cout << "   LHS " << at(l) << " (not a parameter)\n";
        }
        // also: which entries of Parameters() carry this name
        if (inst->Parameters()) {
            int j = 0;
            for (auto* q : *inst->Parameters()) {
                if (std::string(q->VpiName()) == want)
                    std::cout << "-- " << vw << " Parameters[" << j
                              << "] " << at(q) << " par="
                              << at(q->VpiParent()) << "\n";
                j++;
            }
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
