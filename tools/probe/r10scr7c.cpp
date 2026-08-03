// r10scr7c: print the cont_assign subtrees of one module, DEF view and ELAB
// view side by side, annotating every expr node with whether it carries a
// Typespec() ref and what that ref points at.  Built to settle "does golden
// stamp the formal typespec on this call argument, and in which view".
//   r10scr7c <file.uhdm> <module-defname-substring> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string tsOf(const any* o) {
    const ref_typespec* rt = nullptr;
    if (auto* e = dynamic_cast<const expr*>(o)) rt = e->Typespec();
    if (!rt) return "ts=<none>";
    return std::string("ts=") +
           (rt->Actual_typespec()
                ? std::string(UhdmName(rt->Actual_typespec()->UhdmType())) + "(" +
                      std::string(rt->Actual_typespec()->VpiName()) + ")"
                : std::string("<unbound>"));
}

static std::string nm(const any* o) {
    if (!o) return "<null>";
    std::string r = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)o;
        r += "{ct=" + std::to_string(c->VpiConstType()) + ",sz=" +
             std::to_string(c->VpiSize()) + ",v=" + std::string(c->VpiValue()) + "}";
    }
    if (o->UhdmType() == uhdmoperation)
        r += "{op=" + std::to_string(((const operation*)o)->VpiOpType()) + "}";
    r += " " + tsOf(o);
    return r;
}

static void walk(const any* o, int d) {
    if (!o || d > 12) return;
    std::cout << std::string(2 * d, ' ') << nm(o) << "\n";
    switch (o->UhdmType()) {
        case uhdmcont_assign: {
            auto* ca = (const cont_assign*)o;
            walk(ca->Lhs(), d + 1);
            walk(ca->Rhs(), d + 1);
            break;
        }
        case uhdmoperation: {
            auto* op = (const operation*)o;
            if (op->Operands())
                for (auto* x : *op->Operands()) walk(x, d + 1);
            break;
        }
        case uhdmfunc_call:
        case uhdmmethod_func_call: {
            auto* fc = (const func_call*)o;
            if (fc->Tf_call_args())
                for (auto* x : *fc->Tf_call_args()) walk(x, d + 1);
            break;
        }
        case uhdmbit_select: {
            auto* b = (const bit_select*)o;
            walk(b->VpiIndex(), d + 1);
            break;
        }
        case uhdmhier_path: {
            auto* h = (const hier_path*)o;
            if (h->Path_elems())
                for (auto* x : *h->Path_elems()) walk(x, d + 1);
            break;
        }
        default:
            break;
    }
}

static void doMod(const module_inst* m, const std::string& tag, int line) {
    if (!m->Cont_assigns()) return;
    bool any1 = false;
    for (auto* ca : *m->Cont_assigns()) {
        if (line && (int)ca->VpiLineNo() != line) continue;
        if (!any1) {
            std::cout << "== " << tag << " " << m->VpiDefName() << " / "
                      << m->VpiFullName() << " top=" << m->VpiTop() << "\n";
            any1 = true;
        }
        walk(ca, 1);
    }
}

static void rec(const module_inst* m, const std::string& want, int line) {
    if (std::string(m->VpiDefName()).find(want) != std::string::npos)
        doMod(m, "ELAB", line);
    if (m->Modules())
        for (auto* s : *m->Modules()) rec(s, want, line);
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::string want = argv[2];
    int line = argc > 3 ? atoi(argv[3]) : 0;
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if (std::string(m->VpiDefName()).find(want) != std::string::npos)
                doMod(m, "DEF", line);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) rec(m, want, line);
    return 0;
}
