// r10rggen6gs: descend the ELAB gen tree to a named gen_scope_array and step
// the gen_scope's OWN vectors pairwise (golden vs ours), recursing into nested
// gen_scope_arrays / module_insts that still differ.  Answers
// "gen_scope_array(X) r=1 failLhs logic_typespec" -> WHICH container/element.
//   r10rggen6gs <golden.uhdm> <ours.uhdm> <gen-scope-fullname-substring>
// Build: g++ -std=c++20 -O1 tools/probe/r10rggen6gs.cpp -o /tmp/r10rggen6_gs \
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
    std::string s = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)o;
        std::string d(c->VpiDecompile());
        if (d.size() > 40) d = d.substr(0, 40) + "..";
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" + d + "'}";
    }
    if (o->UhdmType() == uhdmref_typespec) {
        const ref_typespec* r = (const ref_typespec*)o;
        s += " {act=" +
             (r->Actual_typespec()
                  ? nm(r->Actual_typespec())
                  : std::string("<null>")) +
             "}";
    }
    return s;
}

static int gN = 0;

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
    gN++;
    std::cout << "  " << tag << ": " << (bad ? "SIZE" : "ELEM") << " lhs=" << (int)sa
              << " rhs=" << (int)sb << "\n";
    for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 60; i++) {
        bool d = bad || (std::find(diffs.begin(), diffs.end(), i) != diffs.end());
        if (!d && !bad) continue;
        std::cout << "      * [" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
        if (d && !bad) {
            CompareContext c;
            int r = (*a)[i]->Compare((*b)[i], &c);
            std::cout << "            r=" << r << " failLhs " << nm(c.m_failedLhs)
                      << "  failRhs " << nm(c.m_failedRhs) << "\n";
        }
    }
}

static void dumpScope(const gen_scope* a, const gen_scope* b,
                      const std::string& tag) {
    std::cout << "GS " << tag << " @" << a->VpiLineNo() << "\n";
#define S(X) step(#X, a->X(), b->X())
    S(Nets); S(Array_nets); S(Variables); S(Array_vars); S(Logic_vars);
    S(Parameters); S(Param_assigns); S(Typespecs); S(Cont_assigns); S(Process);
    S(Modules); S(Interfaces); S(Interface_arrays); S(Module_arrays);
    S(Gen_scope_arrays); S(Task_funcs); S(Instance_items); S(Primitives);
    S(Named_events); S(Def_params); S(Assertions); S(Property_decls);
    S(Let_decls); S(Scopes);
#undef S
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "";
    bool all = argc > 4;
    std::function<void(const module_inst*, const module_inst*)> doMod;
    std::function<void(const gen_scope_array*, const gen_scope_array*,
                       const std::string&)> doGsa;
    doGsa = [&](const gen_scope_array* A, const gen_scope_array* B,
                const std::string& pfx) {
        std::string fn = pfx + "." + std::string(A->VpiName());
        CompareContext c0;
        if (A->Compare(B, &c0) == 0) return;
        bool hit = !want.empty() && fn.find(want) != std::string::npos;
        auto* a = A->Gen_scopes();
        auto* b = B->Gen_scopes();
        if (!a || !b || a->size() != b->size()) {
            if (hit)
                std::cout << "GSA " << fn << " Gen_scopes SIZE "
                          << (a ? a->size() : 0) << " vs " << (b ? b->size() : 0)
                          << "\n";
            return;
        }
        for (size_t i = 0; i < a->size(); i++) {
            CompareContext c;
            if ((*a)[i]->Compare((*b)[i], &c) == 0) continue;
            if (hit) dumpScope((*a)[i], (*b)[i], fn + "[" + std::to_string(i) + "]");
            auto* ga = (*a)[i]->Gen_scope_arrays();
            auto* gb = (*b)[i]->Gen_scope_arrays();
            if (ga && gb && ga->size() == gb->size())
                for (size_t k = 0; k < ga->size(); k++)
                    doGsa((*ga)[k], (*gb)[k], fn + "[" + std::to_string(i) + "]");
            auto* ma = (*a)[i]->Modules();
            auto* mb = (*b)[i]->Modules();
            if (ma && mb && ma->size() == mb->size())
                for (size_t k = 0; k < ma->size(); k++) doMod((*ma)[k], (*mb)[k]);
            if (!all && hit) return;
        }
    };
    doMod = [&](const module_inst* A, const module_inst* B) {
        CompareContext c0;
        if (A->Compare(B, &c0) == 0) return;
        std::string fn(A->VpiFullName());
        auto* ma = A->Modules();
        auto* mb = B->Modules();
        if (ma && mb && ma->size() == mb->size())
            for (size_t i = 0; i < ma->size(); i++) doMod((*ma)[i], (*mb)[i]);
        auto* ga = A->Gen_scope_arrays();
        auto* gb = B->Gen_scope_arrays();
        if (ga && gb && ga->size() == gb->size())
            for (size_t i = 0; i < ga->size(); i++) doGsa((*ga)[i], (*gb)[i], fn);
    };
    auto* A = da->TopModules();
    auto* B = db->TopModules();
    if (A && B && A->size() == B->size())
        for (size_t i = 0; i < A->size(); i++) doMod((*A)[i], (*B)[i]);
    std::cout << "diffvecs=" << gN << "\n";
    return 0;
}
