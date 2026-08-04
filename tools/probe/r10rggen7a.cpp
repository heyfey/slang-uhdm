// r10rggen7a: drill the rggen_adapter_common DEF view -- print Task_funcs,
// Gen_stmts/gen_region contents, and the cont_assign[0] Rhs shape on both
// sides, so 'failLhs <null> failRhs function(get_local_address)' names the
// container it really lives in.
//   r10rggen7a <golden.uhdm> <ours.uhdm> [defname-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" +
           std::string(o->VpiName()) + ")@" + std::to_string(o->VpiLineNo()) +
           ":" + std::to_string(o->VpiColumnNo());
}

template <typename V>
static void lst(const std::string& tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    std::cout << tag << ": " << na << " vs " << nb;
    if (na == nb) {
        bool same = true;
        for (size_t i = 0; i < na; i++)
            if (d1((*a)[i]) != d1((*b)[i])) same = false;
        if (same) {
            std::cout << " (names equal)\n";
            return;
        }
    }
    std::cout << "\n";
    for (size_t i = 0; i < (na > nb ? na : nb); i++)
        std::cout << "    [" << i << "] " << (i < na ? d1((*a)[i]) : "-")
                  << "  |  " << (i < nb ? d1((*b)[i]) : "-") << "\n";
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "rggen_adapter_common";
    auto* A = da->AllModules();
    auto* B = db->AllModules();
    for (size_t i = 0; i < A->size() && i < B->size(); i++) {
        std::string dn((*A)[i]->VpiDefName());
        if (dn.find(want) == std::string::npos) continue;
        const module_inst* ma = (*A)[i];
        const module_inst* mb = (*B)[i];
        std::cout << "== DEF " << dn << "\n";
        lst("  Task_funcs", ma->Task_funcs(), mb->Task_funcs());
        lst("  Gen_stmts", ma->Gen_stmts(), mb->Gen_stmts());
        lst("  Gen_scope_arrays", ma->Gen_scope_arrays(),
            mb->Gen_scope_arrays());
        lst("  Scopes", ma->Scopes(), mb->Scopes());
        lst("  Instance_items", ma->Instance_items(), mb->Instance_items());
        // gen_region drill
        auto* gsa = ma->Gen_stmts();
        auto* gsb = mb->Gen_stmts();
        if (gsa && gsb)
            for (size_t k = 0; k < gsa->size() && k < gsb->size(); k++) {
                if ((*gsa)[k]->UhdmType() != uhdmgen_region) continue;
                auto* ra = (const gen_region*)(*gsa)[k];
                auto* rb = (const gen_region*)(*gsb)[k];
                std::cout << "  -- gen_region[" << k << "]\n";
                lst("    Task_funcs", ra->Task_funcs(), rb->Task_funcs());
                lst("    Gen_stmts", ra->Gen_stmts(), rb->Gen_stmts());
                lst("    Variables", ra->Variables(), rb->Variables());
                lst("    Cont_assigns", ra->Cont_assigns(), rb->Cont_assigns());
                lst("    Parameters", ra->Parameters(), rb->Parameters());
                lst("    Typespecs", ra->Typespecs(), rb->Typespecs());
                lst("    Nets", ra->Nets(), rb->Nets());
                lst("    Process", ra->Process(), rb->Process());
                lst("    Modules", ra->Modules(), rb->Modules());
            }
    }
    return 0;
}
