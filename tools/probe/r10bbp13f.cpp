// r10bbp13f: module_inst-SPECIFIC slot drill (r10bbp10b only walks the scope /
// instance slots, so Ports, Cont_assigns, Process, Gen_scope_arrays, Modules,
// Ref_modules and Io_decls were invisible to it -- and a whole-view Compare
// reaches those AFTER the scope slots, so a shared-context walk that skips an
// already-visited scope residue lands there).  Each element gets a FRESH
// CompareContext.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13f.cpp -o /tmp/r10bbp13fq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13fq <golden.uhdm> <ours.uhdm> [ALLMOD|TOPMOD]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " id" +
                    std::to_string(n->UhdmId()) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    return s;
}

template <typename V>
static void repVec(const std::string& tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << tag << ": SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        CompareContext ctx;
        if ((*a)[i]->Compare((*b)[i], &ctx) == 0) continue;
        std::cout << tag << "[" << i << "]("
                  << std::string((*a)[i]->VpiName()) << "): DIFF\n    failLhs "
                  << at(ctx.m_failedLhs) << "\n    failRhs "
                  << at(ctx.m_failedRhs) << "\n";
    }
}

static void drill(const std::string& tag, const module_inst* a,
                  const module_inst* b) {
    repVec(tag + ".Ports", a->Ports(), b->Ports());
    repVec(tag + ".Interfaces", a->Interfaces(), b->Interfaces());
    repVec(tag + ".Process", a->Process(), b->Process());
    repVec(tag + ".Modules", a->Modules(), b->Modules());
    repVec(tag + ".Module_arrays", a->Module_arrays(), b->Module_arrays());
    repVec(tag + ".Gen_scope_arrays", a->Gen_scope_arrays(),
           b->Gen_scope_arrays());
    repVec(tag + ".Cont_assigns", a->Cont_assigns(), b->Cont_assigns());
    repVec(tag + ".Primitives", a->Primitives(), b->Primitives());
    repVec(tag + ".Def_params", a->Def_params(), b->Def_params());
    repVec(tag + ".Io_decls", a->Io_decls(), b->Io_decls());
    repVec(tag + ".Ref_modules", a->Ref_modules(), b->Ref_modules());
    repVec(tag + ".Gen_stmts", a->Gen_stmts(), b->Gen_stmts());
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string which = argc > 3 ? argv[3] : "";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    auto go = [&](const char* tag, auto* va, auto* vb) {
        if (!which.empty() && which != tag) return;
        if (!va || !vb || va->size() != vb->size()) {
            std::cout << tag << ": SIZE mismatch\n";
            return;
        }
        for (size_t i = 0; i < va->size(); i++)
            drill(std::string(tag) + "[" + std::to_string(i) + "]" +
                      std::string((*va)[i]->VpiName()),
                  (*va)[i], (*vb)[i]);
    };
    go("ALLMOD", da->AllModules(), db->AllModules());
    go("TOPMOD", da->TopModules(), db->TopModules());
    std::cout << "== done\n";
    return 0;
}
