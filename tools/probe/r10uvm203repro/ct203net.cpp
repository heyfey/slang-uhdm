// r10uvm203 — ct203net.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// STEP 1 of the pass: enumerate the NET LISTING of every module_inst /
// interface_inst / program in a database, keyed by the instance's VpiDefName +
// VpiName and the VIEW it lives in (AllModules = def, TopModules = elab), and
// print each net's judge-visible face (kind, name, VpiNetType, span) plus the
// REFERRERS that point at it through ref_obj::Actual_group.
//
// build: g++ -O2 -std=c++17 ct203net.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203net
// usage: ct203net <db.uhdm> [--nets=<instance name>] [--refs]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    snprintf(b, sizeof b, "%s|%s|%u:%u-%u:%u", std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct203net <db.uhdm> [--nets=NAME] [--refs]\n"); return 2; }
    std::string want;
    bool refs = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a.rfind("--nets=", 0) == 0) want = a.substr(7);
        else if (a == "--refs") refs = true;
    }
    Serializer s;
    std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }

    // referrer index: net -> list of ref_obj that name it via Actual_group
    std::map<const BaseClass*, std::vector<const BaseClass*>> refmap;
    if (refs) {
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            if (o->UhdmType() == uhdmref_obj) {
                const ref_obj* r = (const ref_obj*)o;
                if (r->Actual_group()) refmap[r->Actual_group()].push_back(o);
            }
        }
    }

    auto dumpInst = [&](const char* view, const instance* inst) {
        std::string nm(inst->VpiName());
        if (!want.empty() && nm.find(want) == std::string::npos) return;
        const std::vector<net*>* nets = inst->Nets();
        size_t n = nets ? nets->size() : 0;
        printf("INST view=%s kind=%s name=%s defname=%s NETS=%zu\n", view,
               std::string(UhdmName(inst->UhdmType())).c_str(), nm.c_str(),
               std::string(inst->VpiDefName()).c_str(), n);
        if (!nets) return;
        for (const net* nt : *nets) {
            const char* ts = "-";
            std::string tsb;
            if (const ref_typespec* rt = nt->Typespec()) {
                tsb = rt->Actual_typespec() ? face(rt->Actual_typespec()) : std::string("ref-noactual");
                ts = tsb.c_str();
            }
            printf("  NET %s netType=%d file=%s ts=%s parent=%s\n",
                   face(nt).c_str(), (int)nt->VpiNetType(),
                   std::string(nt->VpiFile()).c_str(), ts,
                   nt->VpiParent() ? face(nt->VpiParent()).c_str() : "<null>");
            if (refs) {
                auto it = refmap.find(nt);
                if (it == refmap.end()) { printf("    REFERRERS 0\n"); continue; }
                printf("    REFERRERS %zu\n", it->second.size());
                for (const BaseClass* r : it->second)
                    printf("      REF %s file=%s parent=%s\n", face(r).c_str(),
                           std::string(r->VpiFile()).c_str(),
                           r->VpiParent() ? face(r->VpiParent()).c_str() : "<null>");
            }
        }
    };

    for (vpiHandle dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        if (d->AllModules())
            for (const module_inst* m : *d->AllModules()) dumpInst("def", m);
        if (d->TopModules())
            for (const module_inst* m : *d->TopModules()) dumpInst("elab", m);
        if (d->AllInterfaces())
            for (const interface_inst* m : *d->AllInterfaces()) dumpInst("defif", m);
        if (d->AllPrograms())
            for (const program* m : *d->AllPrograms()) dumpInst("defpg", m);
    }
    return 0;
}
