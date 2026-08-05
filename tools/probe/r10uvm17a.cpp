// r10uvm17a — list every package's Task_funcs by name, with object id and the
// owner of each STATEMENT reference's Actual_group (which body the reference
// reaches).  The instrument for § cloneStmtHomeVarRef17: it answers "whose
// object does this clone's statement bind?" for a whole body, not just the
// first three assignments.
//   r10uvm17a <file.uhdm> [mode] [tfFilter]
// mode = list (default, one line per tf) | refs (per-reference owner census)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, std::string> g_owner;

static std::string ownerOf(const any* o) {
    for (int g = 0; o && g < 60; g++, o = (const any*)o->VpiParent()) {
        auto it = g_owner.find((const BaseClass*)o);
        if (it != g_owner.end())
            return it->second;
    }
    return "<none>";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string mode = argc > 2 ? argv[2] : "list";
    std::string filt = argc > 3 ? argv[3] : "";
    std::vector<std::pair<std::string, const task_func*>> tfs;
    auto run = [&](const char* lbl, auto* v) {
        if (!v)
            return;
        for (auto* p : *v) {
            std::string sc =
                std::string(lbl) + "[" + std::string(p->VpiName()) + "]";
            g_owner[(const BaseClass*)p] = sc;
            if (p->Task_funcs())
                for (auto* tf : *p->Task_funcs()) {
                    g_owner[(const BaseClass*)tf] =
                        sc + "/" + std::string(tf->VpiName());
                    tfs.emplace_back(sc, tf);
                }
            if constexpr (requires { p->Class_defns(); }) {
                if (p->Class_defns())
                    for (auto* c : *p->Class_defns()) {
                        std::string cs = sc + "::" + std::string(c->VpiName());
                        g_owner[(const BaseClass*)c] = cs;
                        if (c->Task_funcs())
                            for (auto* tf : *c->Task_funcs()) {
                                g_owner[(const BaseClass*)tf] =
                                    cs + "/" + std::string(tf->VpiName());
                                tfs.emplace_back(cs, tf);
                            }
                    }
            }
        }
    };
    run("DEFPKG", d->AllPackages());
    run("ELABPKG", d->TopPackages());
    run("DEFMOD", d->AllModules());
    run("ELABMOD", d->TopModules());
    if (mode == "list") {
        for (auto& [sc, tf] : tfs) {
            if (!filt.empty() &&
                std::string(tf->VpiName()).find(filt) == std::string::npos)
                continue;
            std::cout << sc << " #" << tf->UhdmId() << " " << tf->VpiName()
                      << "\n";
        }
        return 0;
    }
    if (mode == "refid") {
        for (auto& kv : s.AllObjects()) {
            auto* o = (const any*)kv.first;
            if (!o || o->UhdmType() != uhdmref_obj)
                continue;
            auto* r = (const ref_obj*)o;
            std::string src = ownerOf(o);
            if (!filt.empty() && src.find(filt) == std::string::npos)
                continue;
            auto* act = r->Actual_group();
            std::cout << src << "  ref#" << o->UhdmId() << " '" << r->VpiName()
                      << "' -> ";
            if (act)
                std::cout << "#" << act->UhdmId() << " "
                          << UhdmName(act->UhdmType()) << " '" << act->VpiName()
                          << "' owner=" << ownerOf(act);
            else
                std::cout << "<null>";
            std::cout << "\n";
        }
        return 0;
    }
    // refs: for every ref_obj in the arena, report (owner body, target owner).
    std::map<std::string, int> cnt;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const any*)kv.first;
        if (!o || o->UhdmType() != uhdmref_obj)
            continue;
        auto* r = (const ref_obj*)o;
        auto* act = r->Actual_group();
        std::string src = ownerOf(o);
        if (!filt.empty() && src.find(filt) == std::string::npos)
            continue;
        std::string tgt = act ? ownerOf(act) : "<null>";
        std::string kind = act ? std::string(UhdmName(act->UhdmType())) : "-";
        cnt[src + "  ->  " + tgt + "  " + kind]++;
    }
    std::vector<std::pair<int, std::string>> v;
    for (auto& [k, n] : cnt)
        v.emplace_back(n, k);
    std::sort(v.rbegin(), v.rend());
    for (auto& [n, k] : v)
        std::cout << n << "  " << k << "\n";
    return 0;
}
