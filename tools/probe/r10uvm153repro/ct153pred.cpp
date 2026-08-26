// r10uvm153 — THE A-PRIORI PREDICTOR.  Reads ONE database (ours, PRISTINE) and
// reports every cell the law would move, WITHOUT consulting golden — that is
// the whole point: the mover set has to be named before the patched sweep runs.
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.
//
// It re-runs Surelog's own walk (`UhdmWriter::lateBinding`,
// src/DesignCompile/UhdmWriter.cpp:3294) on the emitted tree:
//   a ref_obj with NO vpiActual, whose VpiParent chain reaches a function or a
//   task whose Instance() is a PACKAGE that lists a variable of the same name.
// The first matching listing entry is the one Surelog binds (it `break`s).
//
// build: g++ -O2 -std=c++17 ct153pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct153pred
// usage: ct153pred <ours.uhdm> [--quiet]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct153pred ours.uhdm [--quiet]\n"); return 2; }
    bool quiet = false, nofence = false;
    for (int a = 2; a < argc; a++) {
        if (!strcmp(argv[a], "--quiet")) quiet = true;
        else if (!strcmp(argv[a], "--nofence")) nofence = true;
    }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed %s\n", argv[1]); return 3; }
    long hits = 0;
    std::set<std::string> cells;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_obj) continue;
        const ref_obj* r = (const ref_obj*)obj;
        if (r->Actual_group()) continue;
        const std::string nm(r->VpiName());
        if (nm.empty() || nm.find("::") != std::string::npos) continue;
        const BaseClass* p = r->VpiParent();
        const instance* inst = nullptr;
        while (p) {
            if (p->UhdmType() == uhdmfunction) { inst = ((const function*)p)->Instance(); break; }
            if (p->UhdmType() == uhdmtask)     { inst = ((const task*)p)->Instance();     break; }
            if (p->UhdmType() == uhdmpackage || p->UhdmType() == uhdmmodule_inst ||
                p->UhdmType() == uhdmdesign || p->UhdmType() == uhdmclass_defn) break;
            p = p->VpiParent();
        }
        if (!inst || inst->UhdmType() != uhdmpackage) continue;
        const BaseClass* rp = r->VpiParent();
        const std::string pks(rp ? std::string(UhdmName(rp->UhdmType())) : std::string("none"));
        const char* pk = pks.c_str();
        // THE THREE FENCES, measured on goldens g153_b_pos.sv / g153_c_home.sv
        // and confirmed on the corpus: a hier_path ELEMENT, a CALL RECEIVER and
        // a `= new` LVALUE are BARE in golden, and our emitter builds all three
        // outside the binding site (the `= new` lvalue is a hier_path here too).
        if (!nofence && (pks == "hier_path" || pks == "method_func_call" ||
                         pks == "method_task_call"))
            continue;
        auto* vars = ((const package*)inst)->Variables();
        if (!vars) continue;
        for (auto* v : *vars)
            if (v && v->VpiName() == nm) {
                char b[600];
                snprintf(b, sizeof b, "[%s] %s@%u:%u-%u:%u -> %s(%s)@%u:%u in %s",
                         pk, nm.c_str(), r->VpiLineNo(), (unsigned)r->VpiColumnNo(),
                         r->VpiEndLineNo(), (unsigned)r->VpiEndColumnNo(),
                         std::string(UhdmName(v->UhdmType())).c_str(),
                         std::string(v->VpiName()).c_str(), v->VpiLineNo(),
                         (unsigned)v->VpiColumnNo(),
                         std::string(inst->VpiName()).c_str());
                cells.insert(b);
                hits++;
                break;
            }
    }
    if (!quiet) for (const auto& c : cells) printf("PRED %s\n", c.c_str());
    printf("-- %s objects=%zu predicted-cells=%ld distinct=%zu\n", argv[1],
           s.AllObjects().size(), hits, cells.size());
    return 0;
}
