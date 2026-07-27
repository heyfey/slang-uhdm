// Per-container vector inventory: names in order for each package/module list.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void lst(const std::string& tag, const V* v) {
    if (!v) { std::cout << tag << " <null>\n"; return; }
    std::cout << tag << " n=" << v->size() << "\n";
    int i = 0;
    for (auto* e : *v)
        std::cout << tag << "[" << i++ << "] " << UhdmName(e->UhdmType()) << " '"
                  << e->VpiName() << "'\n";
}

template <typename V>
static void doInst(const std::string& tag, V* insts) {
    if (!insts) return;
    int idx = 0;
    for (auto* p : *insts) {
        std::string t0 = tag + "[" + std::to_string(idx++) + ":" +
                         std::string(p->VpiName()) + "]";
        std::cout << t0 << ".scalars name='" << p->VpiName() << "' def='"
                  << p->VpiDefName() << "' endlbl='" << p->VpiEndLabel()
                  << "' top=" << p->VpiTop()
                  << " arrmem=" << p->VpiArrayMember()
                  << " cellinst=" << p->VpiCellInstance()
                  << " defnet=" << p->VpiDefNetType()
                  << " defdly=" << p->VpiDefDelayMode()
                  << " prot=" << p->VpiProtected()
                  << " tprec=" << p->VpiTimePrecision()
                  << " tunit=" << p->VpiTimeUnit()
                  << " unconn=" << p->VpiUnconnDrive()
                  << " lib='" << p->VpiLibrary() << "' cell='" << p->VpiCell()
                  << "' modinst=" << (p->Module_inst() ? 1 : 0)
                  << " inst=" << (p->Instance() ? 1 : 0) << "\n";
        lst(t0 + ".Typespecs", p->Typespecs());
        lst(t0 + ".TaskFuncs", p->Task_funcs());
        lst(t0 + ".Parameters", p->Parameters());
        lst(t0 + ".ParamAssigns", p->Param_assigns());
        lst(t0 + ".Variables", p->Variables());
        lst(t0 + ".Nets", p->Nets());
        lst(t0 + ".Assertions", p->Assertions());
        lst(t0 + ".InstanceItems", p->Instance_items());
        lst(t0 + ".ArrayNets", p->Array_nets());
        lst(t0 + ".ArrayVars", p->Array_vars());
        lst(t0 + ".ArrayVarMems", p->Array_var_mems());
        lst(t0 + ".Attributes", p->Attributes());
        lst(t0 + ".ClassDefns", p->Class_defns());
        lst(t0 + ".ConcurrentAssertions", p->Concurrent_assertions());
        lst(t0 + ".LetDecls", p->Let_decls());
        lst(t0 + ".LogicVars", p->Logic_vars());
        lst(t0 + ".NamedEvents", p->Named_events());
        lst(t0 + ".NamedEventArrays", p->Named_event_arrays());
        lst(t0 + ".Programs", p->Programs());
        lst(t0 + ".ProgramArrays", p->Program_arrays());
        lst(t0 + ".PropertyDecls", p->Property_decls());
        lst(t0 + ".Scopes", p->Scopes());
        lst(t0 + ".SequenceDecls", p->Sequence_decls());
        lst(t0 + ".SpecParams", p->Spec_params());
        lst(t0 + ".VirtualInterfaceVars", p->Virtual_interface_vars());
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto hs = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    doInst("Pkg", d->AllPackages());
    doInst("TopPkg", d->TopPackages());
    doInst("AllMod", d->AllModules());
    doInst("TopMod", d->TopModules());
    return 0;
}
