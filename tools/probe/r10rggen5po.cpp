// r10rggen5po: port / interface_inst singular-field census for one elab
// instance.  Prints High_conn, Low_conn, Typespec and the interface_inst's own
// vectors side by side (golden | ours) so a "port r=-1 failLhs <null>" says
// WHICH field golden leaves unset.
//   r10rggen5po <golden.uhdm> <ours.uhdm> <inst-fullname-substring>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <functional>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename T>
static void vsz(const char* tag, const std::vector<T*>* a,
                const std::vector<T*>* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (!sa && !sb) return;
    std::cout << "      " << tag << " " << sa << " | " << sb;
    if (sa == sb && sa) {
        for (size_t i = 0; i < sa; i++) {
            CompareContext c;
            if ((*a)[i]->Compare((*b)[i], &c) != 0)
                std::cout << "   [" << i << "] failLhs " << nm(c.m_failedLhs)
                          << " failRhs " << nm(c.m_failedRhs);
        }
    }
    std::cout << "\n";
}

static void dumpIface(const interface_inst* a, const interface_inst* b) {
    std::cout << "    IFACE " << a->VpiFullName() << " | " << b->VpiFullName()
              << "\n";
    vsz("Ports", a->Ports(), b->Ports());
    vsz("Nets", a->Nets(), b->Nets());
    vsz("Modports", a->Modports(), b->Modports());
    vsz("Variables", a->Variables(), b->Variables());
    vsz("Cont_assigns", a->Cont_assigns(), b->Cont_assigns());
    vsz("Parameters", a->Parameters(), b->Parameters());
    vsz("Param_assigns", a->Param_assigns(), b->Param_assigns());
    vsz("Typespecs", a->Typespecs(), b->Typespecs());
    vsz("Task_funcs", a->Task_funcs(), b->Task_funcs());
    vsz("Interfaces", a->Interfaces(), b->Interfaces());
    vsz("Gen_scope_arrays", a->Gen_scope_arrays(), b->Gen_scope_arrays());
    vsz("Instance_items", a->Instance_items(), b->Instance_items());
    vsz("Process", a->Process(), b->Process());
    vsz("Interface_arrays", a->Interface_arrays(), b->Interface_arrays());
}

static void dumpInst(const module_inst* A, const module_inst* B) {
    std::cout << "MOD " << A->VpiFullName() << "\n";
    auto* pa = A->Ports();
    auto* pb = B->Ports();
    if (pa && pb && pa->size() == pb->size())
        for (size_t i = 0; i < pa->size(); i++) {
            CompareContext c;
            if ((*pa)[i]->Compare((*pb)[i], &c) == 0) continue;
            std::cout << "  PORT " << (*pa)[i]->VpiName() << "\n"
                      << "      High_conn " << nm((*pa)[i]->High_conn())
                      << " | " << nm((*pb)[i]->High_conn()) << "\n"
                      << "      Low_conn  " << nm((*pa)[i]->Low_conn())
                      << " | " << nm((*pb)[i]->Low_conn()) << "\n"
                      << "      Typespec  " << nm((*pa)[i]->Typespec())
                      << " | " << nm((*pb)[i]->Typespec()) << "\n"
                      << "      fail      " << nm(c.m_failedLhs) << " | "
                      << nm(c.m_failedRhs) << "\n";
        }
    auto* ia = A->Interfaces();
    auto* ib = B->Interfaces();
    if (ia && ib && ia->size() == ib->size())
        for (size_t i = 0; i < ia->size(); i++) {
            CompareContext c;
            if ((*ia)[i]->Compare((*ib)[i], &c) != 0)
                dumpIface((*ia)[i], (*ib)[i]);
        }
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
        auto* ma = ((const gen_scope*)A)->Modules();
        auto* mb = ((const gen_scope*)B)->Modules();
        if (ma && mb && ma->size() == mb->size())
            for (size_t i = 0; i < ma->size(); i++) doMod((*ma)[i], (*mb)[i]);
        auto* ga = ((const gen_scope*)A)->Gen_scope_arrays();
        auto* gb = ((const gen_scope*)B)->Gen_scope_arrays();
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
            dumpInst(A, B);
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
