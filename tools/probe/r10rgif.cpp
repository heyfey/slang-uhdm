// r10rgif: step the vectors of a named interface_inst under a named module
// instance, so an interface-level r=N says WHICH container/field diverges.
//   r10rgif <golden.uhdm> <ours.uhdm> <modFullNameSubstr> <ifaceNameSubstr>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
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
        if (d.size() > 40) d = d.substr(0, 40) + "...";
        std::string v(c->VpiValue());
        if (v.size() > 40) v = v.substr(0, 40) + "...";
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" + d + "' val='" +
             v + "'}";
    }
    if (o->UhdmType() == uhdmref_typespec) {
        const ref_typespec* r = (const ref_typespec*)o;
        s += " {act=" +
             (r->Actual_typespec()
                  ? std::string(UhdmName(r->Actual_typespec()->UhdmType())) + "(" +
                        std::string(r->Actual_typespec()->VpiName()) + ")"
                  : std::string("<null>")) +
             "}";
    }
    return s;
}

template <typename T>
static void step(const std::string& tag, const std::vector<T*>* a,
                 const std::vector<T*>* b) {
    CompareContext c;
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) {
        std::cout << tag << ": SIZE lhs=" << (int)sa << " rhs=" << (int)sb << "\n";
        for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 60; i++)
            std::cout << "    [" << i << "] "
                      << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                      << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
        return;
    }
    for (size_t i = 0; i < sa; i++) {
        c.m_failedLhs = nullptr;
        c.m_failedRhs = nullptr;
        const BaseClass* la = (*a)[i];
        const BaseClass* lb = (*b)[i];
        int r = (la && lb) ? la->Compare(lb, &c) : (la ? 1 : (lb ? -1 : 0));
        if (r != 0) {
            std::cout << tag << "[" << i << "] r=" << r << " " << nm(la) << " vs "
                      << nm(lb) << "\n";
            std::cout << "    failLhs " << nm(c.m_failedLhs) << "\n";
            std::cout << "    failRhs " << nm(c.m_failedRhs) << "\n";
        }
    }
}

static void walkIf(const interface_inst* a, const interface_inst* b,
                   const std::string& tag) {
    std::cout << "== " << tag << " " << a->VpiDefName() << " / " << a->VpiFullName()
              << "\n";
#define S(X) step(tag + "." #X, a->X(), b->X())
    S(Ports);
    S(Nets);
    S(Array_nets);
    S(Variables);
    S(Array_vars);
    S(Logic_vars);
    S(Named_events);
    S(Parameters);
    S(Param_assigns);
    S(Typespecs);
    S(Cont_assigns);
    S(Process);
    S(Gen_stmts);
    S(Gen_scope_arrays);
    S(Modports);
    S(Interfaces);
    S(Interface_arrays);
    S(Task_funcs);
    S(Class_defns);
    S(Instance_items);
    S(Concurrent_assertions);
    S(Assertions);
    S(Scopes);
    S(Variables);
#undef S
}

static void scanMod(const module_inst* a, const module_inst* b,
                    const std::string& mwant, const std::string& iwant) {
    std::string fn(a->VpiFullName());
    if (fn.find(mwant) != std::string::npos) {
        auto* ia = a->Interfaces();
        auto* ib = b->Interfaces();
        if (ia && ib && ia->size() == ib->size())
            for (size_t i = 0; i < ia->size(); i++) {
                std::string in((*ia)[i]->VpiName());
                if (!iwant.empty() && in.find(iwant) == std::string::npos) continue;
                CompareContext c;
                if ((*ia)[i]->Compare((*ib)[i], &c) != 0)
                    walkIf((*ia)[i], (*ib)[i], fn + "/" + in);
            }
        else
            std::cout << fn << " Interfaces SIZE " << (ia ? ia->size() : 0) << " vs "
                      << (ib ? ib->size() : 0) << "\n";
    }
    auto* ma = a->Modules();
    auto* mb = b->Modules();
    if (ma && mb && ma->size() == mb->size())
        for (size_t i = 0; i < ma->size(); i++) scanMod((*ma)[i], (*mb)[i], mwant, iwant);
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string mw = argc > 3 ? argv[3] : "";
    std::string iw = argc > 4 ? argv[4] : "";
    auto* TA = da->TopModules();
    auto* TB = db->TopModules();
    if (TA && TB && TA->size() == TB->size())
        for (size_t i = 0; i < TA->size(); i++) scanMod((*TA)[i], (*TB)[i], mw, iw);
    return 0;
}
