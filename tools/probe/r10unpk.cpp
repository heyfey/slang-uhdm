// Identity probe for the unpacked-array typedef forest: for every module view
// (def + top) print the Typespecs listing, the Variables/Nets typespec ACTUALS
// and the Expr of each array_var, all keyed by UhdmId so clone identity (which
// uhdm-dump hides behind its already-visited abbreviation) is visible.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
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

static std::string idn(const any* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "#" +
           std::to_string(o->UhdmId()) + "'" + std::string(o->VpiName()) + "'@" +
           loc(o);
}

static void tsline(const std::string& tag, const typespec* t) {
    if (!t) { std::cout << tag << " <null>\n"; return; }
    std::cout << tag << " " << idn(t);
    if (t->Instance()) std::cout << " inst=" << idn(t->Instance());
    if (t->VpiParent()) std::cout << " par=" << idn(t->VpiParent());
    const ref_typespec* al = nullptr;
    const ref_typespec* el = nullptr;
    size_t nr = 0;
    switch (t->UhdmType()) {
        case uhdmarray_typespec: {
            auto* a = (const array_typespec*)t;
            al = a->Typedef_alias();
            el = a->Elem_typespec();
            nr = a->Ranges() ? a->Ranges()->size() : 0;
            break;
        }
        case uhdmpacked_array_typespec: {
            auto* a = (const packed_array_typespec*)t;
            al = a->Typedef_alias();
            el = a->Elem_typespec();
            nr = a->Ranges() ? a->Ranges()->size() : 0;
            break;
        }
        case uhdmlogic_typespec: {
            auto* a = (const logic_typespec*)t;
            al = a->Typedef_alias();
            nr = a->Ranges() ? a->Ranges()->size() : 0;
            break;
        }
        default: break;
    }
    std::cout << " nranges=" << nr;
    if (al) std::cout << " ALIAS->" << idn(al->Actual_typespec());
    if (el) std::cout << " ELEM'" << el->VpiFullName() << "'->"
                      << idn(el->Actual_typespec());
    std::cout << "\n";
}

template <typename V>
static void doInst(const std::string& tag, V* insts) {
    if (!insts) return;
    for (auto* p : *insts) {
        std::string t0 = tag + "[" + std::string(p->VpiName()) + "#" +
                         std::to_string(p->UhdmId()) + "]";
        if (auto* tds = p->Typespecs())
            for (auto* td : *tds) tsline(t0 + " TD", td);
        if (auto* vs = p->Variables())
            for (auto* v : *vs) {
                std::cout << t0 << " VAR " << idn(v);
                if (auto* e = v->Expr()) std::cout << " EXPR=" << idn(e);
                else std::cout << " EXPR=<null>";
                std::cout << "\n";
                if (auto* rt = v->Typespec())
                    tsline(t0 + " VAR." + std::string(v->VpiName()) + ".ts",
                           rt->Actual_typespec());
            }
        if (auto* ns = p->Nets())
            for (auto* n : *ns)
                if (auto* rt = n->Typespec())
                    tsline(t0 + " NET." + std::string(n->VpiName()) + ".ts",
                           rt->Actual_typespec());
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10unpk <uhdm>\n"; return 2; }
    Serializer s;
    auto hs = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    doInst("AllMod", d->AllModules());
    doInst("TopMod", d->TopModules());
    return 0;
}
