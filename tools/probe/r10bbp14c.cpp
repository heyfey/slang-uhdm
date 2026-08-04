// r10bbp14c: DEF-vs-TOP port/net typespec identity + range-bound SHAPE.
// Prints, per module_inst view, `<name> port ts id<..> range <left>|<right>` so
// "is the elab bound folded, and is its typespec object shared with the def
// port's" is answered in one line per port.  Nets get the same treatment.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp14c.cpp -o /tmp/r10bbp14cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp14cq <db.uhdm> [nets]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string sh(const any* e) {
    if (!e) return "<null>";
    std::string s = std::string(UhdmName(e->UhdmType()));
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        s += "(" + std::string(c->VpiDecompile()) + " sz" +
             std::to_string(c->VpiSize()) + " ct" +
             std::to_string(c->VpiConstType()) + ")";
    }
    else if (e->UhdmType() == uhdmref_obj) {
        s += "(" + std::string(e->VpiName()) + ")";
    }
    return s + " id" + std::to_string(e->UhdmId());
}

static void tsline(const std::string& tag, const ref_typespec* rt) {
    if (!rt) {
        std::cout << tag << " <no ref_typespec>\n";
        return;
    }
    auto* ts = rt->Actual_typespec();
    if (!ts) {
        std::cout << tag << " rt id" << rt->UhdmId() << " actual=<NULL>\n";
        return;
    }
    std::cout << tag << " rt id" << rt->UhdmId() << " ts "
              << UhdmName(ts->UhdmType()) << " id" << ts->UhdmId();
    if (ts->UhdmType() == uhdmlogic_typespec) {
        auto* r = ((const logic_typespec*)ts)->Ranges();
        if (r)
            for (auto* rg : *r)
                std::cout << "  range id" << rg->UhdmId() << " ["
                          << sh(rg->Left_expr()) << " : " << sh(rg->Right_expr())
                          << "]";
    }
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    bool nets = argc > 2;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    auto view = [&](const char* tag, const module_inst* m) {
        std::cout << "== " << tag << " module id" << m->UhdmId() << "\n";
        if (m->Ports())
            for (auto* p : *m->Ports())
                tsline("  port " + std::string(p->VpiName()) + " id" +
                           std::to_string(p->UhdmId()),
                       p->Typespec());
        if (nets && m->Nets())
            for (auto* n : *m->Nets())
                tsline("  net " + std::string(n->VpiName()) + " " +
                           std::string(UhdmName(n->UhdmType())) + " id" +
                           std::to_string(n->UhdmId()),
                       n->Typespec());
    };
    view("ALLMOD[0]", (*d->AllModules())[0]);
    view("TOPMOD[0]", (*d->TopModules())[0]);
    return 0;
}
