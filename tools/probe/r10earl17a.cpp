// r10earl17a — THE COMPLETE SUB-CENSUS.  r10earl15b enumerates 21 child
// vectors chosen by hand; module_inst::Compare walks FORTY-ONE vectors plus
// five single-object pointers (scope::Compare, then instance::Compare, then
// module_inst::Compare — read out of ~/git-repos/UHDM/build/generated/src/).
// A head whose WHOLE r != 0 with every 15b vector clean (pass-16 residue (2),
// work@tlul_adapter_host) is failing in one of the twenty vectors 15b never
// looks at.  This probe enumerates ALL of them IN COMPARE ORDER, so the first
// non-clean line is literally the pair uhdm-cmp trips on.
// Build: bash tools/probe/r10earl17build.sh r10earl17a
// Usage: r10earl17a <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg|def2top> <Name> [-v]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static bool verbose = false;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + base(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) +
             " def=" + std::string(in->VpiDefName()) +
             " uid=" + std::to_string(in->UhdmId()) + "}";
    return s;
}

static std::string chain(const BaseClass* n) {
    std::string s;
    int i = 0;
    const any* p = n ? n->VpiParent() : nullptr;
    while (p && i++ < 6) {
        s += "\n        ^ " + at(p);
        p = p->VpiParent();
    }
    return s;
}

static void report(const char* tag, int idx, int r, const BaseClass* own,
                   CompareContext& ctx) {
    std::cout << "  " << tag;
    if (idx >= 0)
        std::cout << "[" << idx << "]";
    std::cout << " r=" << r << "  own=" << at(own) << "\n      failLhs "
              << at(ctx.m_failedLhs) << chain(ctx.m_failedLhs)
              << "\n      failRhs " << at(ctx.m_failedRhs)
              << chain(ctx.m_failedRhs) << "\n";
}

template <class V>
static void vecCmp(const char* tag, V* va, V* vb) {
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    if (!na && !nb)
        return;
    if (na != nb) {
        std::cout << "  " << tag << " SIZE " << na << " vs " << nb << "\n";
        return;
    }
    int bad = 0;
    for (size_t i = 0; i < na; i++) {
        CompareContext ctx;
        int r = (*va)[i]->Compare((*vb)[i], &ctx);
        if (r == 0)
            continue;
        bad++;
        report(tag, (int)i, r, (*va)[i], ctx);
        if (!verbose && bad >= 3)
            break;
    }
    if (!bad)
        std::cout << "  " << tag << " OK (" << na << ")\n";
}

// A SINGLE-object child pointer (Module_array, Instance(), ...).  SafeCompare
// treats a null/non-null mismatch as a failure too, so report that shape.
static void oneCmp(const char* tag, const BaseClass* a, const BaseClass* b) {
    if (!a && !b)
        return;
    if (!a || !b) {
        std::cout << "  " << tag << " NULLNESS " << (a ? "set" : "null")
                  << " vs " << (b ? "set" : "null") << "\n      lhs " << at(a)
                  << "\n      rhs " << at(b) << "\n";
        return;
    }
    CompareContext ctx;
    int r = a->Compare(b, &ctx);
    if (r == 0) {
        std::cout << "  " << tag << " OK\n";
        return;
    }
    report(tag, -1, r, a, ctx);
}

template <class V>
static const instance* pick(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                return x;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[3], want = argv[4];
    verbose = argc > 5 && std::string(argv[5]) == "-v";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const instance* ia = nullptr;
    const instance* ib = nullptr;
    if (vec == "all") {
        ia = pick(da->AllModules(), want);
        ib = pick(db->AllModules(), want);
    }
    else if (vec == "top") {
        ia = pick(da->TopModules(), want);
        ib = pick(db->TopModules(), want);
    }
    else if (vec == "allpkg") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->AllPackages(), want);
    }
    else if (vec == "def2top") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    else {
        ia = pick(da->TopPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    if (!ia || !ib) {
        std::cout << "not found\n";
        return 3;
    }
    {
        CompareContext ctx;
        int r = ia->Compare(ib, &ctx);
        std::cout << "WHOLE r=" << r << "\n";
        if (r != 0)
            std::cout << "      failLhs " << at(ctx.m_failedLhs)
                      << chain(ctx.m_failedLhs) << "\n      failRhs "
                      << at(ctx.m_failedRhs) << chain(ctx.m_failedRhs) << "\n";
    }
    // ---- scope::Compare order -------------------------------------------
    vecCmp("Property_decls", ia->Property_decls(), ib->Property_decls());
    vecCmp("Sequence_decls", ia->Sequence_decls(), ib->Sequence_decls());
    vecCmp("Concurrent_assertions", ia->Concurrent_assertions(),
           ib->Concurrent_assertions());
    vecCmp("Named_events", ia->Named_events(), ib->Named_events());
    vecCmp("Named_event_arrays", ia->Named_event_arrays(),
           ib->Named_event_arrays());
    vecCmp("Variables", ia->Variables(), ib->Variables());
    vecCmp("Virtual_interface_vars", ia->Virtual_interface_vars(),
           ib->Virtual_interface_vars());
    vecCmp("Logic_vars", ia->Logic_vars(), ib->Logic_vars());
    vecCmp("Array_vars", ia->Array_vars(), ib->Array_vars());
    vecCmp("Array_var_mems", ia->Array_var_mems(), ib->Array_var_mems());
    vecCmp("Parameters", ia->Parameters(), ib->Parameters());
    vecCmp("Param_assigns", ia->Param_assigns(), ib->Param_assigns());
    vecCmp("Scopes", ia->Scopes(), ib->Scopes());
    vecCmp("Typespecs", ia->Typespecs(), ib->Typespecs());
    vecCmp("Instance_items", ia->Instance_items(), ib->Instance_items());
    vecCmp("Let_decls", ia->Let_decls(), ib->Let_decls());
    vecCmp("Attributes", ia->Attributes(), ib->Attributes());
    // ---- instance::Compare order ----------------------------------------
    vecCmp("Programs", ia->Programs(), ib->Programs());
    vecCmp("Program_arrays", ia->Program_arrays(), ib->Program_arrays());
    vecCmp("Class_defns", ia->Class_defns(), ib->Class_defns());
    vecCmp("Task_funcs", ia->Task_funcs(), ib->Task_funcs());
    vecCmp("Nets", ia->Nets(), ib->Nets());
    vecCmp("Array_nets", ia->Array_nets(), ib->Array_nets());
    vecCmp("Spec_params", ia->Spec_params(), ib->Spec_params());
    vecCmp("Assertions", ia->Assertions(), ib->Assertions());
    oneCmp("Module_inst()", ia->Module_inst(), ib->Module_inst());
    oneCmp("Instance()", ia->Instance(), ib->Instance());
    // ---- module_inst::Compare order --------------------------------------
    if (auto* ma = any_cast<const module_inst*>((const any*)ia))
        if (auto* mb = any_cast<const module_inst*>((const any*)ib)) {
            oneCmp("Global_clocking", ma->Global_clocking(),
                   mb->Global_clocking());
            oneCmp("Default_clocking", ma->Default_clocking(),
                   mb->Default_clocking());
            oneCmp("Expr_dist", ma->Expr_dist(), mb->Expr_dist());
            oneCmp("Module_array", ma->Module_array(), mb->Module_array());
            oneCmp("Instance_array", ma->Instance_array(),
                   mb->Instance_array());
            vecCmp("Ports", ma->Ports(), mb->Ports());
            vecCmp("Interfaces", ma->Interfaces(), mb->Interfaces());
            vecCmp("Interface_arrays", ma->Interface_arrays(),
                   mb->Interface_arrays());
            vecCmp("Process", ma->Process(), mb->Process());
            vecCmp("Modules", ma->Modules(), mb->Modules());
            vecCmp("Module_arrays", ma->Module_arrays(), mb->Module_arrays());
            vecCmp("Gen_scope_arrays", ma->Gen_scope_arrays(),
                   mb->Gen_scope_arrays());
            vecCmp("Cont_assigns", ma->Cont_assigns(), mb->Cont_assigns());
            vecCmp("Primitives", ma->Primitives(), mb->Primitives());
            vecCmp("Primitive_arrays", ma->Primitive_arrays(),
                   mb->Primitive_arrays());
            vecCmp("Mod_paths", ma->Mod_paths(), mb->Mod_paths());
            vecCmp("Tchks", ma->Tchks(), mb->Tchks());
            vecCmp("Def_params", ma->Def_params(), mb->Def_params());
            vecCmp("Io_decls", ma->Io_decls(), mb->Io_decls());
            vecCmp("Alias_stmts", ma->Alias_stmts(), mb->Alias_stmts());
            vecCmp("Clocking_blocks", ma->Clocking_blocks(),
                   mb->Clocking_blocks());
            vecCmp("Elab_tasks", ma->Elab_tasks(), mb->Elab_tasks());
            vecCmp("Ref_modules", ma->Ref_modules(), mb->Ref_modules());
            vecCmp("Gen_stmts", ma->Gen_stmts(), mb->Gen_stmts());
        }
    if (auto* pa = any_cast<const package*>((const any*)ia))
        if (auto* pb = any_cast<const package*>((const any*)ib))
            oneCmp("pkg Instance()", pa->Instance(), pb->Instance());
    return 0;
}
