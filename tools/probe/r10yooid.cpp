// r10yooid: pointer-identity probe. For a module def name, print the object
// addresses of the DEF-view (AllModules) and ELAB-view (TopModules/instance)
// nets and cont_assigns, and for each cont_assign operand ref_obj print which
// net object it actually points at (DEF net / ELAB net / neither).  Answers
// "does the elab view share the def view's statement objects?".
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10yooid.cpp -o /tmp/r10yooid \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const BaseClass*, std::string> tagOf;

static void tagNets(const module_inst* m, const char* view) {
    if (!m->Nets()) return;
    for (auto* n : *m->Nets())
        tagOf[n] = std::string(view) + ":" + std::string(n->VpiName());
}

static void report(const module_inst* m, const char* view) {
    std::cout << view << " " << m->VpiDefName() << " / " << m->VpiFullName()
              << " top=" << m->VpiTop() << " ptr=" << (const void*)m << "\n";
    if (m->Nets())
        for (auto* n : *m->Nets())
            std::cout << "  net " << n->VpiName() << " ptr=" << (const void*)n
                      << " ts=" << (n->Typespec() ? "yes" : "NULL") << "\n";
    if (m->Cont_assigns())
        for (auto* ca : *m->Cont_assigns()) {
            std::cout << "  cont_assign@" << ca->VpiLineNo()
                      << " ptr=" << (const void*)ca << "\n";
            std::function<void(const any*, int)> walk = [&](const any* e,
                                                            int depth) {
                if (!e) return;
                if (e->UhdmType() == uhdmref_obj) {
                    auto* r = (const ref_obj*)e;
                    const any* act = r->Actual_group();
                    auto it = tagOf.find(act);
                    std::cout << "    ref_obj " << r->VpiName()
                              << " actual=" << (const void*)act << " ["
                              << (it == tagOf.end() ? std::string("?")
                                                    : it->second)
                              << "]\n";
                } else if (e->UhdmType() == uhdmoperation) {
                    auto* op = (const operation*)e;
                    if (op->Operands())
                        for (auto* o : *op->Operands()) walk(o, depth + 1);
                }
            };
            walk(ca->Rhs(), 0);
            walk(ca->Lhs(), 0);
        }
    if (m->Modules())
        for (auto* s : *m->Modules()) report(s, view);
}

int main(int argc, char** argv) {
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    std::string want = argc > 2 ? argv[2] : "";
    auto match = [&](const module_inst* m) {
        return want.empty() ||
               std::string(m->VpiDefName()).find(want) != std::string::npos;
    };
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if (match(m)) tagNets(m, "DEF");
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            if (match(m)) tagNets(m, "TOP");
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if (match(m)) report(m, "DEF");
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            if (match(m)) report(m, "TOP");
    return 0;
}
