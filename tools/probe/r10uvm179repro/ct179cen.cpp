// r10uvm179 (r10uvm176's, reused) — THE CALL-ARGUMENT BIND CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge of equality.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// Reads a database out of `Serializer::AllObjects()` (never dump TEXT) and
// prints one row per family:
//
//   ARG| every reference that sits DIRECTLY in a `tf_call`'s
//       `vpiArgument` vector, keyed by
//         CALL   the call's UHDM kind (func_call / task_call /
//                method_func_call / method_task_call / sys_func_call /
//                sys_task_call) and its vpiName
//         RECV   the call's vpiPrefix: NONE, or <kind>:<name> — the receiver
//                spelling as the DATABASE has it, not as the source wrote it
//         LINK   whether the call carries a vpiFunction / vpiTask link
//         POS    the argument's index in the vector
//         REF    the reference's own kind and vpiName (+ span unless --nospan)
//         HOME   the enclosing subroutine kind and the container it finally
//                hangs off (function/task/process × class_defn/package/
//                module_inst/design) — the discriminator Surelog's
//                `bindVariable` walk and its late-binding fallback both need
//       and the value BOUND=<kind:name> / BARE.
//
//   REF| EVERY reference object in the database (ref_obj/ref_var/ref_module/
//       chandle_var and their IS-A selects) with its bind state.  This is the
//       MUST-NOT-MOVE family: a law that only ever ADDS one ARG cell must
//       leave every other REF row alone.
//
//   OBJ| one row per UHDM kind with its count — nothing may be created or
//       destroyed.
//
// The DEF/ELAB view is deliberately NOT part of any key (RESUME.md §9: the two
// producers label it differently); the caller tags each run.
//
// build: g++ -O2 -std=c++17 ct179cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct179cen
// usage: ct179cen <db.uhdm> <tag> [--nospan]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static bool NOSPAN = false;
// --face: r10uvm179 REDEFINES the face its parent tool (r10uvm176's
// ct176cen.cpp) carried.  r10uvm176's law lived on a `method_func_call` with a
// **vpiPrefix**, the shape `CompileHelper::compileTfCall`'s dotted STATEMENT
// arm builds.  THIS law lives on the OTHER road: a `method_func_call` that is
// an ELEMENT OF A `hier_path`, which is what
// `CompileHelper::compileComplexFuncCall` (CompileExpression.cpp:5678-5708)
// builds for an EXPRESSION-position call on a hierarchical receiver — the road
// that never parents the call before compiling its arguments.  So `--face`
// keeps exactly the ARG rows whose call is parented by a `hier_path`.  A
// whole-corpus run of the full families would be 40M rows; this face is a few
// dozen per database.
static bool FACEONLY = false;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("");
}
static std::string actOf(const BaseClass* a) {
    if (!a) return "BARE";
    return "BOUND=" + kindOf(a) + ":" + nameOf(a);
}
static std::string spanOf(const BaseClass* o) {
    if (NOSPAN || !o) return "";
    char b[64];
    snprintf(b, sizeof b, "@%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}

// The HOME chain: the nearest enclosing subroutine/process, then the container
// that subroutine finally hangs off.  Kind names only where a name would be a
// span-like accident; the SUBROUTINE and the CONTAINER are named because they
// are what a reader needs to find the cell in the source.
static std::string homeOf(const BaseClass* o) {
    std::string sub = "-", subk = "-", cont = "-", contn = "-";
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 128;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (sub == "-" &&
            (t == uhdmfunction || t == uhdmtask || t == uhdmprocess_stmt ||
             t == uhdminitial || t == uhdmalways)) {
            subk = UhdmName(t);
            sub = nameOf(p);
            if (sub.empty()) sub = "<anon>";
            continue;
        }
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
            t == uhdminterface_inst || t == uhdmdesign) {
            cont = UhdmName(t);
            contn = nameOf(p);
            if (contn.empty()) contn = "<anon>";
            break;
        }
    }
    return subk + ":" + sub + "/" + cont + ":" + contn;
}

// Is this object one of the reference kinds whose bind state we track?
static bool isRefKind(UHDM_OBJECT_TYPE t) {
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmref_module ||
           t == uhdmbit_select || t == uhdmindexed_part_select ||
           t == uhdmpart_select || t == uhdmvar_select;
}

static const any* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (const ref_module* r = any_cast<const ref_module*>(o))
        return r->Actual_group();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct179cen <db.uhdm> <tag> [--nospan]\n");
        return 2;
    }
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
        if (!strcmp(argv[i], "--face")) FACEONLY = true;
    }

    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: nothing restored from %s\n", argv[1]);
        return 3;
    }
    const std::string tag = argv[2];

    std::map<std::string, int> objs;
    std::vector<std::string> argRows, refRows;

    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        objs[std::string(UhdmName(o->UhdmType()))]++;
    }

    // ARG rows.
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* call = any_cast<const tf_call*>(o);
        if (!call) continue;
        const VectorOfany* as = call->Tf_call_args();
        if (!as) continue;
        std::string recv = "NONE";
        if (const method_func_call* m = any_cast<const method_func_call*>(o)) {
            if (const expr* p = m->Prefix())
                recv = kindOf(p) + ":" + nameOf(p);
        } else if (const method_task_call* m =
                       any_cast<const method_task_call*>(o)) {
            if (const expr* p = m->Prefix())
                recv = kindOf(p) + ":" + nameOf(p);
        }
        // r10uvm179 — THE RECEIVER AXIS THIS LAW LIVES ON.  A call with no
        // vpiPrefix may still HAVE a receiver: the hier_path road spells it as
        // the path elements standing BEFORE the call.  `HP` records the SHAPE
        // (how many receiver steps, and each step's kind+name), which is what
        // separates a bare one-name receiver from an `a.b` chain, an indexed
        // receiver and a `this.`-rooted one.
        bool hpRecv = false;
        if (const hier_path* hp = any_cast<const hier_path*>(o->VpiParent())) {
            if (const VectorOfany* pe = hp->Path_elems()) {
                size_t at = pe->size();
                for (size_t i = 0; i < pe->size(); i++)
                    if ((const BaseClass*)(*pe)[i] == o) { at = i; break; }
                if (at < pe->size()) {
                    hpRecv = true;
                    recv = "HP" + std::to_string(at);
                    for (size_t i = 0; i < at; i++) {
                        const BaseClass* e = (const BaseClass*)(*pe)[i];
                        recv += "/" + kindOf(e) + ":" + nameOf(e);
                    }
                }
            }
        }
        std::string link = "NOLINK";
        if (const func_call* f = any_cast<const func_call*>(o)) {
            if (f->Function()) link = "FUNC";
        } else if (const task_call* t = any_cast<const task_call*>(o)) {
            if (t->Task()) link = "TASK";
        } else if (const method_func_call* m =
                       any_cast<const method_func_call*>(o)) {
            if (m->Function()) link = "FUNC";
        } else if (const method_task_call* m =
                       any_cast<const method_task_call*>(o)) {
            if (m->Task()) link = "TASK";
        }
        if (FACEONLY && !hpRecv) continue;
        for (size_t i = 0; i < as->size(); i++) {
            const BaseClass* a = (const BaseClass*)(*as)[i];
            if (!a || !isRefKind(a->UhdmType())) continue;
            char pos[16];
            snprintf(pos, sizeof pos, "%zu", i);
            argRows.push_back("ARG|" + tag + "|CALL=" +
                              kindOf(o) + ":" + nameOf(o) + "|RECV=" + recv +
                              "|" + link + "|POS=" + pos + "|REF=" +
                              kindOf(a) + ":" + nameOf(a) + spanOf(a) +
                              "|HOME=" + homeOf(a) + "|" + actOf(actualOf(a)));
        }
    }

    // REF rows — the must-not-move family.
    for (auto& kv : s.AllObjects()) {
        if (FACEONLY) break;
        const BaseClass* o = kv.first;
        if (!o || !isRefKind(o->UhdmType())) continue;
        refRows.push_back("REF|" + tag + "|" + kindOf(o) + ":" + nameOf(o) +
                          spanOf(o) + "|HOME=" + homeOf(o) + "|" +
                          actOf(actualOf(o)));
    }

    std::sort(argRows.begin(), argRows.end());
    std::sort(refRows.begin(), refRows.end());
    for (auto& r : argRows) printf("%s\n", r.c_str());
    for (auto& r : refRows) printf("%s\n", r.c_str());
    if (!FACEONLY)
        for (auto& kv : objs)
            printf("OBJ|%s|%s|%d\n", tag.c_str(), kv.first.c_str(), kv.second);
    return 0;
}
