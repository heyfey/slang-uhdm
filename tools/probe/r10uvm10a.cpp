// r10uvm10a: struct_typespec provenance — for every struct_typespec, print its
// name, full name, Instance() kind/name and VpiParent chain head.  Decides how
// the pkgCloneMember10 drain can tell a PACKAGE-scope struct typedef
// (uvm_printer_row_info -> members bind) from a CLASS-scope one
// (uvm_component::m_verbosity_setting -> golden leaves every member null).
//   r10uvm10a <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o || o->UhdmType() != uhdmstruct_typespec) continue;
        auto* t = (const struct_typespec*)o;
        const BaseClass* p = t->VpiParent();
        std::string chain;
        for (int g = 0; p && g < 6; g++, p = p->VpiParent())
            chain += std::string(UhdmName(p->UhdmType())) + ":" +
                     std::string(p->VpiName()) + ">";
        std::cout << "name=" << t->VpiName() << "|inst=" << (t->Instance()
                                      ? std::string(UhdmName(
                                            t->Instance()->UhdmType())) +
                                            ":" +
                                            std::string(
                                                t->Instance()->VpiName())
                                      : std::string("-"))
                  << "|parents=" << chain << "|line=" << t->VpiLineNo() << "\n";
    }
    return 0;
}
