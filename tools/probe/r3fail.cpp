// Compare-failure localiser: runs design::Compare on a golden/slang pair and,
// when the reported failing pair is an instance (package/module/gen_scope),
// prints every vector's size SIDE BY SIDE so the container-size mismatch that
// BaseClass::SafeCompare reports as `failLhs=<container>` is immediately
// visible.  `r=1 failLhs=<container>` is otherwise indistinguishable from a
// scalar mismatch in the dump.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename V>
static void row(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    bool nulla = !a, nullb = !b;
    if (sa == sb && nulla == nullb) return;
    std::cout << "  DIFF " << tag << ": lhs=" << (nulla ? -1 : (int)sa)
              << " rhs=" << (nullb ? -1 : (int)sb) << "\n";
    size_t n = sa > sb ? sa : sb;
    for (size_t i = 0; i < n; i++) {
        std::cout << "        [" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
    }
}

template <typename T>
static void dumpInst(const T* a, const T* b) {
    // instance::Compare checks these scalars BEFORE any vector — a DEF-view
    // object matched against a TOP-view one differs only in VpiTop.
    std::cout << "  scal lhs: top=" << a->VpiTop() << " def='" << a->VpiDefName()
              << "' endlbl='" << a->VpiEndLabel() << "' cell='" << a->VpiCell()
              << "' lib='" << a->VpiLibrary() << "'\n";
    std::cout << "  scal rhs: top=" << b->VpiTop() << " def='" << b->VpiDefName()
              << "' endlbl='" << b->VpiEndLabel() << "' cell='" << b->VpiCell()
              << "' lib='" << b->VpiLibrary() << "'\n";
    row("Typespecs", a->Typespecs(), b->Typespecs());
    row("TaskFuncs", a->Task_funcs(), b->Task_funcs());
    row("Parameters", a->Parameters(), b->Parameters());
    row("ParamAssigns", a->Param_assigns(), b->Param_assigns());
    row("Variables", a->Variables(), b->Variables());
    row("Nets", a->Nets(), b->Nets());
    row("ArrayNets", a->Array_nets(), b->Array_nets());
    row("ArrayVars", a->Array_vars(), b->Array_vars());
    row("LogicVars", a->Logic_vars(), b->Logic_vars());
    row("InstanceItems", a->Instance_items(), b->Instance_items());
    row("ClassDefns", a->Class_defns(), b->Class_defns());
    row("Scopes", a->Scopes(), b->Scopes());
    row("NamedEvents", a->Named_events(), b->Named_events());
    row("Attributes", a->Attributes(), b->Attributes());
    row("SpecParams", a->Spec_params(), b->Spec_params());
}

static void dumpStructTs(const struct_typespec* a, const struct_typespec* b) {
    row("Members", a->Members(), b->Members());
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    CompareContext c;
    int r = da->Compare(db, &c);
    std::cout << "design r=" << r << "\n";
    std::cout << "failLhs " << nm(c.m_failedLhs) << "\n";
    std::cout << "failRhs " << nm(c.m_failedRhs) << "\n";
    const BaseClass* x = c.m_failedLhs;
    const BaseClass* y = c.m_failedRhs;
    // A container-form mismatch (`SafeCompare(lhs, vec, rhs, vec)`) leaves
    // failedRhs UNSET: the vector is null on our side. Print the lhs vector
    // contents so the missing list is named.
    if (x && !y && x->UhdmType() == uhdmio_decl) {
        auto* a = (const io_decl*)x;
        std::cout << "  lhs io_decl ranges=" << (a->Ranges() ? (int)a->Ranges()->size() : -1)
                  << " expr=" << (a->Expr() ? 1 : 0) << " ts="
                  << (a->Typespec() ? 1 : 0) << " size=" << a->VpiSize() << "\n";
        if (a->Ranges())
            for (auto* r0 : *a->Ranges())
                std::cout << "    range @" << r0->VpiLineNo() << ":"
                          << r0->VpiColumnNo() << "-" << r0->VpiEndLineNo()
                          << ":" << r0->VpiEndColumnNo() << "\n";
    }
    if (!x || !y) return 0;
    if (x->UhdmType() != y->UhdmType()) return 0;
    if (x->UhdmType() == uhdmpackage)
        dumpInst((const package*)x, (const package*)y);
    else if (x->UhdmType() == uhdmmodule_inst)
        dumpInst((const module_inst*)x, (const module_inst*)y);
    else if (x->UhdmType() == uhdmstruct_typespec)
        dumpStructTs((const struct_typespec*)x, (const struct_typespec*)y);
    else if (x->UhdmType() == uhdmconstant) {
        auto* a = (const constant*)x;
        auto* b = (const constant*)y;
        auto pr = [](const char* tag, const constant* c) {
            std::cout << "  " << tag << " decomp='" << c->VpiDecompile()
                      << "' size=" << c->VpiSize() << " ct=" << c->VpiConstType()
                      << " val='" << c->VpiValue() << "' ts="
                      << (c->Typespec() ? 1 : 0) << "\n";
        };
        pr("lhs", a);
        pr("rhs", b);
    }
    else if (x->UhdmType() == uhdmio_decl) {
        auto* a = (const io_decl*)x;
        auto* b = (const io_decl*)y;
        row("Ranges", a->Ranges(), b->Ranges());
        std::cout << "  expr " << (a->Expr() ? 1 : 0) << "/"
                  << (b->Expr() ? 1 : 0) << " left " << (a->Left_expr() ? 1 : 0)
                  << "/" << (b->Left_expr() ? 1 : 0) << " right "
                  << (a->Right_expr() ? 1 : 0) << "/"
                  << (b->Right_expr() ? 1 : 0) << " ts "
                  << (a->Typespec() ? 1 : 0) << "/" << (b->Typespec() ? 1 : 0)
                  << " size " << a->VpiSize() << "/" << b->VpiSize() << "\n";
    }
    return 0;
}
