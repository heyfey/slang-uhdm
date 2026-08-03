// r10rggen5mi: descend the ELAB gen tree to a named module_inst inside a
// gen_scope and step ITS vectors pairwise (golden vs ours), so a
// "gen_scope.Modules[i] r=-1" says which container of the child diverges.
//   r10rggen5mi <golden.uhdm> <ours.uhdm> <module-inst-fullname-substring>
// Build: g++ -std=c++20 -O1 tools/probe/r10rggen5mi.cpp -o /tmp/r10rggen5_mi \
//        -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <functional>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename T>
static void step(const std::string& tag, const std::vector<T*>* a,
                 const std::vector<T*>* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    bool bad = sa != sb;
    std::vector<size_t> diffs;
    if (!bad)
        for (size_t i = 0; i < sa; i++) {
            CompareContext c;
            if ((*a)[i]->Compare((*b)[i], &c) != 0) diffs.push_back(i);
        }
    if (!bad && diffs.empty()) return;
    std::cout << "  " << tag << ": " << (bad ? "SIZE" : "ELEM") << " lhs=" << (int)sa
              << " rhs=" << (int)sb << "\n";
    for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 40; i++) {
        bool d = bad || (std::find(diffs.begin(), diffs.end(), i) != diffs.end());
        std::cout << "      " << (d ? "* " : "  ") << "[" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
        if (d && !bad) {
            CompareContext c;
            (*a)[i]->Compare((*b)[i], &c);
            std::cout << "            failLhs " << nm(c.m_failedLhs)
                      << "  failRhs " << nm(c.m_failedRhs) << "\n";
        }
    }
}

static void dumpMod(const module_inst* a, const module_inst* b) {
    std::cout << "MOD " << a->VpiFullName() << "\n";
#define S(X) step(#X, a->X(), b->X())
    S(Ports); S(Nets); S(Variables); S(Parameters); S(Param_assigns);
    S(Typespecs); S(Cont_assigns); S(Process); S(Modules); S(Interfaces);
    S(Interface_arrays); S(Module_arrays); S(Gen_scope_arrays); S(Task_funcs);
    S(Ref_modules); S(Instance_items); S(Scopes); S(Primitives);
#undef S
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "";
    std::function<void(const module_inst*, const module_inst*)> doMod;
    std::function<void(const gen_scope_array*, const gen_scope_array*)> doGsa;
    auto doScope = [&](const scope* A, const scope* B) {
        auto* ga = ((const gen_scope*)A)->Gen_scope_arrays();
        auto* gb = ((const gen_scope*)B)->Gen_scope_arrays();
        auto* ma = ((const gen_scope*)A)->Modules();
        auto* mb = ((const gen_scope*)B)->Modules();
        if (ma && mb && ma->size() == mb->size())
            for (size_t i = 0; i < ma->size(); i++) doMod((*ma)[i], (*mb)[i]);
        if (ga && gb && ga->size() == gb->size())
            for (size_t i = 0; i < ga->size(); i++) doGsa((*ga)[i], (*gb)[i]);
    };
    doGsa = [&](const gen_scope_array* A, const gen_scope_array* B) {
        auto* a = A->Gen_scopes();
        auto* b = B->Gen_scopes();
        if (a && b && a->size() == b->size())
            for (size_t i = 0; i < a->size(); i++) doScope((*a)[i], (*b)[i]);
    };
    doMod = [&](const module_inst* A, const module_inst* B) {
        std::string fn(A->VpiFullName());
        CompareContext c;
        if (!want.empty() && fn.find(want) != std::string::npos &&
            A->Compare(B, &c) != 0)
            dumpMod(A, B);
        auto* ma = A->Modules();
        auto* mb = B->Modules();
        if (ma && mb && ma->size() == mb->size())
            for (size_t i = 0; i < ma->size(); i++) doMod((*ma)[i], (*mb)[i]);
        auto* ga = A->Gen_scope_arrays();
        auto* gb = B->Gen_scope_arrays();
        if (ga && gb && ga->size() == gb->size())
            for (size_t i = 0; i < ga->size(); i++) doGsa((*ga)[i], (*gb)[i]);
    };
    auto* A = da->TopModules();
    auto* B = db->TopModules();
    if (A && B && A->size() == B->size())
        for (size_t i = 0; i < A->size(); i++) doMod((*A)[i], (*B)[i]);
    return 0;
}
