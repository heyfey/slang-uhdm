// r10earlpa: print every param_assign of a named package (both the AllPackages
// "def" entry and the TopPackages/elab entry if distinct) as a compact
// expression projection, so folded-vs-symbolic state is visible at a glance.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10earlpa.cpp -o /tmp/r10earlpa \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10earlpa <file.uhdm> <pkgname> [maxdepth]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

static std::string xpr(const any* e, int d = 0) {
    if (!e) return "<null>";
    if (d > 6) return "...";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "C{ct" + std::to_string(c->VpiConstType()) + ",sz" +
                   std::to_string(c->VpiSize()) + ",d=" +
                   std::string(c->VpiDecompile()) + ",v=" +
                   std::string(c->VpiValue()) + "}";
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "Op" + std::to_string(o->VpiOpType()) + "(";
            if (auto* ops = o->Operands())
                for (size_t i = 0; i < ops->size(); i++)
                    s += (i ? "," : "") + xpr((*ops)[i], d + 1);
            return s + ")";
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            std::string s = "R{" + std::string(r->VpiFullName());
            if (auto* a = r->Actual_group())
                s += "->" + std::string(UhdmName(a->UhdmType())) + "@" + loc(a);
            else
                s += "->NULL";
            return s + "}";
        }
        case uhdmsys_func_call: {
            auto* f = (const sys_func_call*)e;
            std::string s = "SF" + std::string(f->VpiName()) + "(";
            if (auto* a = f->Tf_call_args())
                for (size_t i = 0; i < a->size(); i++)
                    s += (i ? "," : "") + xpr((*a)[i], d + 1);
            return s + ")";
        }
        default:
            return std::string(UhdmName(e->UhdmType())) + "@" + loc(e);
    }
}

static void dumpPkg(const package* p, const char* tag) {
    std::cout << "== " << tag << " " << p->VpiName() << " top=" << p->VpiTop()
              << " id" << p->UhdmId() << "\n";
    if (auto* prs = p->Parameters())
        for (auto* pr : *prs) {
            if (pr->UhdmType() != uhdmparameter) continue;
            auto* q = (const parameter*)pr;
            std::cout << "  PARAM " << q->VpiName() << " @" << loc(q)
                      << " expr=" << xpr(q->Expr())
                      << " nranges=" << (q->Ranges() ? q->Ranges()->size() : 0)
                      << "\n";
        }
    if (auto* pas = p->Param_assigns())
        for (auto* pa : *pas) {
            std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "?";
            std::cout << "  " << nm << " @" << loc(pa) << " = "
                      << xpr(pa->Rhs()) << "\n";
        }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    if (ha.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)ha[0])->object;
    std::string want = argv[2];
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            if (want == "*" || std::string(p->VpiName()) == want)
                dumpPkg(p, "ALLPKG");
    if (auto* v = d->TopPackages())
        for (auto* p : *v)
            if (want == "*" || std::string(p->VpiName()) == want)
                dumpPkg(p, "TOPPKG");
    return 0;
}
