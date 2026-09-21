// r11u81 ts81probe — THE JUDGE-READ TYPESPEC FIELDS THE DUMP CANNOT PRINT.
//
// `uhdm-dump` prints NO children under an `int_typespec` on the constant
// operand path (r11v78's RV-3), so neither `vpiSigned` nor `Ranges` is
// visible there — and `int_typespec::Compare` READS BOTH, as
// `byte_typespec::Compare` / `short_int_typespec::Compare` read `VpiSigned`.
// This probe opens a database and prints, for every `param_assign` whose Rhs
// is an operation, one line per operand constant with its size / constType /
// value AND the full typespec chain: the actual's KIND, its `VpiSigned` and
// its `Ranges` (left/right VpiValue), so golden's field can be read rather
// than inferred.  MEASUREMENT ONLY — the acceptance judge stays `uhdm-cmp`.
//
// build:
//   g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tsOf(const expr* e) {
    const ref_typespec* rt = e->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref()/NOACTUAL";
    std::string out = std::string(UhdmName(a->UhdmType()));
    const VectorOfrange* rs = nullptr;
    switch (a->UhdmType()) {
        case uhdmint_typespec: {
            auto* t = (const int_typespec*)a;
            out += t->VpiSigned() ? "/S" : "/U";
            rs = t->Ranges();
            break;
        }
        case uhdmlogic_typespec: {
            auto* t = (const logic_typespec*)a;
            out += t->VpiSigned() ? "/S" : "/U";
            rs = t->Ranges();
            break;
        }
        case uhdmbyte_typespec:
            out += ((const byte_typespec*)a)->VpiSigned() ? "/S" : "/U";
            break;
        case uhdmshort_int_typespec:
            out += ((const short_int_typespec*)a)->VpiSigned() ? "/S" : "/U";
            break;
        case uhdmlong_int_typespec:
            out += ((const long_int_typespec*)a)->VpiSigned() ? "/S" : "/U";
            break;
        case uhdminteger_typespec:
            out += ((const integer_typespec*)a)->VpiSigned() ? "/S" : "/U";
            break;
        default:
            break;
    }
    if (!a->VpiName().empty()) out += "(" + std::string(a->VpiName()) + ")";
    if (rs && !rs->empty()) {
        out += "[";
        for (auto* r : *rs) {
            auto val = [](const expr* x) -> std::string {
                if (!x) return "<null>";
                std::string v(x->VpiValue());
                if (x->UhdmType() == uhdmconstant) {
                    auto* c = (const constant*)x;
                    v += "/ct" + std::to_string(c->VpiConstType()) + "/sz" +
                         std::to_string(c->VpiSize());
                    if (!c->VpiDecompile().empty())
                        v += "/d" + std::string(c->VpiDecompile());
                }
                return v;
            };
            out += val(r->Left_expr()) + ":" + val(r->Right_expr());
            out += "@sz" + std::to_string(r->VpiSize());
        }
        out += "]";
    }
    else if (rs) {
        out += "[empty]";
    }
    return out;
}

static void one(const param_assign* pa, const char* sect) {
    const any* lhs = pa->Lhs();
    const any* rhs = pa->Rhs();
    if (!rhs || rhs->UhdmType() != uhdmoperation) return;
    auto* op = (const operation*)rhs;
    if (!op->Operands()) return;
    std::cout << sect << " " << (lhs ? lhs->VpiName() : "?") << " op"
              << op->VpiOpType() << " n=" << op->Operands()->size() << "\n";
    int i = 0;
    for (auto* o : *op->Operands()) {
        std::cout << "   [" << i++ << "] " << UhdmName(o->UhdmType());
        if (o->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)o;
            std::cout << " sz=" << c->VpiSize() << " ct=" << c->VpiConstType()
                      << " v=" << c->VpiValue() << " d=" << c->VpiDecompile()
                      << " ts=" << tsOf(c);
        }
        std::cout << "\n";
    }
}

static void walkMod(const module_inst* m, const char* sect) {
    if (m->Param_assigns())
        for (auto* pa : *m->Param_assigns()) one(pa, sect);
    if (m->Modules())
        for (auto* c : *m->Modules()) walkMod(c, sect);
}

int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 3;
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkMod(m, "TOPMOD");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            if (p->Param_assigns())
                for (auto* pa : *p->Param_assigns()) one(pa, "TOPPKG");
    return 0;
}
