// r11u63 SHAPE LISTER — every hier_path in a database, keyed by the elaborated
// owner it hangs under, its immediate parent KIND, and its written text; the
// payload is the COMPARED shape (Typespec actual kind+name, Root_value kind+
// name, VpiSize, VpiDecompile, Path_elems size).  Compare-visible fields only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kindName(const BaseClass* b) {
    return b ? std::string(UhdmName(b->UhdmType())) : std::string("<none>");
}
static std::string ownerOf(const BaseClass* b) {
    for (const BaseClass* p = b ? b->VpiParent() : nullptr; p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmmodule_inst || t == uhdminterface_inst ||
            t == uhdmgen_scope || t == uhdmpackage || t == uhdmfunction ||
            t == uhdmtask) {
            std::string f;
            if (auto* si = any_cast<const scope*>(p)) f = std::string(si->VpiFullName());
            if (f.empty()) f = std::string(p->VpiName());
            return kindName(p) + ":" + f;
        }
    }
    return "<noowner>";
}

int main(int argc, char** argv) {
    bool rows = false;
    std::vector<std::string> files;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--rows") rows = true;
        else files.push_back(a);
    }
    auto read = [&](const std::string& f, std::map<std::string, std::string>& out) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(f));
        (void)h;
        for (auto& [obj, id] : s.AllObjects()) {
            if (!obj || obj->UhdmType() != uhdmhier_path) continue;
            auto* hp = (const hier_path*)obj;
            std::ostringstream k, v;
            k << ownerOf(hp) << " | " << kindName(hp->VpiParent()) << "("
              << (hp->VpiParent() ? hp->VpiParent()->VpiName() : "") << ") | "
              << hp->VpiName();
            const ref_typespec* rt = hp->Typespec();
            const typespec* at = rt ? rt->Actual_typespec() : nullptr;
            v << "ts=" << (rt ? (at ? kindName(at) + ":" + std::string(at->VpiName())
                                    : std::string("ref:<null-actual>"))
                              : std::string("<none>"))
              << " rv=" << (hp->Root_value()
                                ? kindName(hp->Root_value()) + ":" +
                                      std::string(hp->Root_value()->VpiName())
                                : std::string("<none>"))
              << " sz=" << hp->VpiSize() << " dec=" << hp->VpiDecompile()
              << " elems=" << (hp->Path_elems() ? hp->Path_elems()->size() : 0);
            std::string key = k.str();
            int n = 0;
            std::string uk = key;
            while (out.count(uk)) uk = key + " #" + std::to_string(++n);
            out[uk] = v.str();
        }
    };
    std::map<std::string, std::string> A, B;
    read(files[0], A);
    if (files.size() > 1) read(files[1], B);
    if (files.size() == 1) {
        for (auto& [k, v] : A) std::cout << "SHAPE " << k << "  ->  " << v << "\n";
        return 0;
    }
    int same = 0, diff = 0, onlyA = 0, onlyB = 0;
    for (auto& [k, v] : A) {
        auto it = B.find(k);
        if (it == B.end()) { onlyA++; if (rows) std::cout << "ONLY-GOLDEN " << k << "  ->  " << v << "\n"; continue; }
        if (it->second == v) { same++; if (rows) std::cout << "SAME        " << k << "  ->  " << v << "\n"; }
        else { diff++; std::cout << "DIFF        " << k << "\n   G: " << v << "\n   O: " << it->second << "\n"; }
    }
    for (auto& [k, v] : B)
        if (!A.count(k)) { onlyB++; std::cout << "ONLY-OURS   " << k << "  ->  " << v << "\n"; }
    std::cout << "ROWS " << A.size() << " SAME " << same << " DIFF " << diff
              << " ONLY-GOLDEN " << onlyA << " ONLY-OURS " << onlyB << "\n";
    return 0;
}
