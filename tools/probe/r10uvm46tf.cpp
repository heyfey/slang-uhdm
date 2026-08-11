// r10uvm46tf — the TASK_FUNC OBJECT census: one line per task_func object in a
// database, with the fields that decide what an EMPTY-NAMED one actually is.
//
// BuildUVMPkg's whole remaining residue is one function that golden leaves
// EMPTY-NAMED and formal-less.  A class LISTING census cannot answer how many
// objects there are, because `vpiTaskFunc` on a class_defn is built from a
// NAME-KEYED map and every unnamed method collapses onto the same key — so a
// listing showing ONE empty entry is equally consistent with one unnamed method
// and with six.  This walks the SERIALIZER instead, where every object appears
// exactly once.
//
//   r10uvm46tf <file.uhdm> [nameFilter]
// Prints: kind, VpiName, owner (parent kind+name), #io_decls and their names,
// return-var presence, VpiMethod/VpiVisibility/VpiAutomatic, and file:line.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm46tf <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "FATAL: restore produced no design\n";
        return 1;
    }
    std::vector<std::string> out;
    size_t n = 0;
    for (auto& [o, id] : s.AllObjects()) {
        auto* f = any_cast<const task_func*>(o);
        if (!f)
            continue;
        n++;
        const any* p = f->VpiParent();
        std::string owner = p ? std::string(UhdmName(p->UhdmType())) + " '" +
                                    std::string(p->VpiName()) + "'"
                              : "<none>";
        std::string ios;
        for (auto* io : f->Io_decls() ? *f->Io_decls()
                                      : std::vector<io_decl*>{})
            ios += std::string(io->VpiName()) + ",";
        out.push_back(
            std::string(UhdmName(f->UhdmType())) + " '" +
            std::string(f->VpiName()) + "' owner=" + owner +
            " full='" + std::string(f->VpiFullName()) + "'" +
            " nio=" +
            std::to_string(f->Io_decls() ? f->Io_decls()->size() : 0) + " [" +
            ios + "]" + " ret=" + (f->Return() ? "SET" : "-") +
            " stmt=" + (f->Stmt() ? "SET" : "-") +
            " method=" + std::to_string(f->VpiMethod()) +
            " vis=" + std::to_string(f->VpiVisibility()) +
            " autom=" + std::to_string(f->VpiAutomatic()) +
            " loc=" + std::to_string(f->VpiLineNo()) + ":" +
            std::to_string(f->VpiColumnNo()));
    }
    if (n == 0) {
        std::cerr << "FATAL: ZERO task_func objects in " << argv[1]
                  << " — refusing to report an unmeasurable population\n";
        return 4;
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out)
        if (filt.empty() || l.find(filt) != std::string::npos)
            std::cout << l << "\n";
    std::cerr << "TFcount=" << n << "\n";
    return 0;
}
