// r10c16b: print, per VIEW (AllPackages/TopPackages), the param_assign Rhs of
// named struct-pattern package parameters as a tagged_pattern LIST — each
// member's name plus the UhdmId/kind/decompile of the VALUE object — so that
// OBJECT SHARING between two different parameters' patterns is visible
// (uhdm-dump abbreviates a repeat visit; only UhdmId proves identity).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10c16b.cpp -o /tmp/r10c16bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10c16bq <db.uhdm> [param-name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string id(const any* o) {
    if (!o) return "-";
    return "#" + std::to_string(o->UhdmId());
}
static std::string brief(const any* e) {
    if (!e) return "-";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "const" + id(c) + "{" + std::string(c->VpiDecompile()) +
                   ",sz" + std::to_string(c->VpiSize()) + ",ct" +
                   std::to_string(c->VpiConstType()) + "}@" + loc(c);
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            return "ref" + id(r) + "{" + std::string(r->VpiName()) + "}@" +
                   loc(r);
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "op" + std::to_string(o->VpiOpType()) + id(o) + "(";
            if (o->Operands())
                for (auto* p : *o->Operands()) s += brief(p) + " ";
            return s + ")@" + loc(o);
        }
        case uhdmhier_path: {
            auto* h = (const hier_path*)e;
            return "hier_path" + id(h) + "{" + std::string(h->VpiName()) +
                   "}@" + loc(h);
        }
        default:
            return std::string(UhdmName(e->UhdmType())) + id(e) + "{" +
                   std::string(e->VpiName()) + "}@" + loc(e);
    }
}

static void dumpRhs(const any* rhs) {
    if (!rhs) {
        std::cout << "    <null rhs>\n";
        return;
    }
    if (rhs->UhdmType() != uhdmoperation) {
        std::cout << "    rhs=" << brief(rhs) << "\n";
        return;
    }
    auto* op = (const operation*)rhs;
    std::cout << "    op" << op->VpiOpType() << id(op) << "@" << loc(op)
              << " nops=" << (op->Operands() ? op->Operands()->size() : 0)
              << "\n";
    if (!op->Operands()) return;
    int i = 0;
    for (auto* p : *op->Operands()) {
        std::string nm = "-";
        const any* val = p;
        if (p->UhdmType() == uhdmtagged_pattern) {
            auto* tp = (const tagged_pattern*)p;
            if (tp->Typespec() && tp->Typespec()->Actual_typespec())
                nm = std::string(tp->Typespec()->Actual_typespec()->VpiName());
            if (nm.empty() && tp->Typespec())
                nm = std::string(tp->Typespec()->VpiName());
            val = tp->Pattern();
            std::cout << "      [" << i << "] tagged" << id(tp) << "@" << loc(tp)
                      << " name=" << nm << " tsref=" << id(tp->Typespec())
                      << " pat=" << brief(val) << "\n";
        } else {
            std::cout << "      [" << i << "] " << brief(p) << "\n";
        }
        ++i;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer ser;
    std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    auto pkgs = [&](const std::string& tag, VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (std::string(p->VpiName()) == "builtin") continue;
            if (!p->Param_assigns()) continue;
            for (auto* pa : *p->Param_assigns()) {
                std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName())
                                           : std::string("?");
                if (!filt.empty() && nm.find(filt) == std::string::npos)
                    continue;
                std::cout << "== " << tag << " pkg " << p->VpiName()
                          << " top=" << p->VpiTop() << " passign" << id(pa)
                          << " " << nm << " lhs=" << id(pa->Lhs()) << "\n";
                dumpRhs(pa->Rhs());
            }
        }
    };
    pkgs("ALL", d->AllPackages());
    pkgs("TOP", d->TopPackages());
    return 0;
}
