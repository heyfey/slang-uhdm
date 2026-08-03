// r10scr7b: BINDING census.  One sorted line per ref_obj (optionally filtered
// by name substring) giving the enclosing instance, the site, the parent-kind
// chain and what Actual_group points at — so `diff golden ours` names exactly
// the references whose boundness disagrees.  Compare treats bound-vs-null as a
// mismatch and reports it as (failLhs=<null>, failRhs=<the pointee>), which
// hides the site; this probe supplies it.
//   r10scr7b <file.uhdm> [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string encl(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmmodule_inst)
            return std::string(((const module_inst*)p)->VpiFullName());
        if (p->UhdmType() == uhdmpackage)
            return std::string(((const package*)p)->VpiFullName());
    }
    return "<noscope>";
}

static std::string ctx(const BaseClass* o) {
    std::string r;
    int n = 0;
    for (const BaseClass* p = o->VpiParent(); p && n < 10; p = p->VpiParent(), n++) {
        if (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdmpackage) break;
        r += std::string(UhdmName(p->UhdmType())) + "<";
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 2 ? argv[2] : "";
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmref_obj) continue;
        auto* r = (const ref_obj*)o;
        std::string n(r->VpiName());
        if (!want.empty() && n.find(want) == std::string::npos) continue;
        const any* act = r->Actual_group();
        rows.push_back(encl(o) + " | " + n + "@" + std::to_string(o->VpiLineNo()) +
                       ":" + std::to_string(o->VpiColumnNo()) + " | ctx=" + ctx(o) +
                       " | act=" +
                       (act ? std::string(UhdmName(act->UhdmType())) + "(" +
                                  std::string(act->VpiName()) + ")/par=" +
                                  (act->VpiParent()
                                       ? UhdmName(act->VpiParent()->UhdmType())
                                       : "<null>")
                            : std::string("<null>")));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& x : rows) std::cout << x << "\n";
    return 0;
}
