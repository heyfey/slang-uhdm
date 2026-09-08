// r10uvm216 — THE SUBROUTINE-LISTING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.  This
// tool only reads and prints.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS
// ours.
//
// The r10uvm214 R0 head is an ELEMENT-WISE mismatch inside an
// `interface_inst`'s `Task_funcs` vector (both sides size 931; golden's [900]
// is `pass_info_to_sv_dpi`, ours is `set_test_name`), so the census must be
// keyed by POSITION as well as by identity.  It emits TWO key families:
//
//   POS| holder x INDEX x (kind,name,acc,cstr,ctx,cid,#io,has-body)
//        — sensitive to ORDER.  This is the family the head lives in.
//   MEM| holder x (kind,name,acc,cstr,ctx,cid,#io,has-body)
//        — order-blind MEMBERSHIP + FIELDS.  Separates "we hold the wrong
//          object here" from "we stamp the right object wrongly".
//
// The holder key is `<uhdm-kind>:<VpiDefName or VpiName>` and deliberately
// carries NO view label and NO span: the DEF and ELAB producers label the view
// differently (RESUME §9, census traps) and `Compare` never reads a span.
// Every listing in `Serializer::AllObjects` that is an `instance` (module_inst,
// interface_inst, package, program) or a `class_defn` is walked, so the census
// is depth-blind by construction rather than slot-keyed.
//
// build: g++ -O2 -std=c++17 ct216cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct216cen
// usage: ct216cen <db.uhdm>                  -> one key per line, sorted, with counts
//        ct216cen <db.uhdm> --dpi            -> only rows whose payload is DPI-marked
//        ct216cen <db.uhdm> --nobuiltin      -> drop the SIMULATOR BUILT-IN
//              holders (`std`'s mailbox / process / semaphore, the
//              `any_sverilog_class` family, `package:builtin`).  For the GRID
//              only: the grid runs Surelog with `-nobuiltin`, so golden has no
//              such holder and every one of ours reads as a phantom
//              `ONLY-OURS` row (r10uvm210's recorded caution).  The corpus
//              census never uses it — there both sides carry them.
//        ct216cen <db.uhdm> --files          -> the distinct SOURCE FILES the
//              database's objects point into.  This is the a-priori corpus
//              predictor's input: an `export "DPI-C"` item can only reach a row
//              whose database actually compiled the file that carries it, and
//              `cmds.txt` does not list `include`d files.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string accName(int a) {
    if (a == 0) return "-";
    if (a == vpiDPIExportAcc) return "EXPORT";
    if (a == vpiDPIImportAcc) return "IMPORT";
    if (a == 2) return "EXTERN";
    return "acc" + std::to_string(a);
}

static std::string payload(const task_func *f) {
    if (!f) return "<null>";
    size_t nio = f->Io_decls() ? f->Io_decls()->size() : 0;
    bool body = false;
    if (const function *fn = dynamic_cast<const function *>(f))
        body = fn->Stmt() != nullptr;
    else if (const task *tk = dynamic_cast<const task *>(f))
        body = tk->Stmt() != nullptr;
    std::string s;
    s += UhdmName(f->UhdmType());
    s += "|" + std::string(f->VpiName());
    s += "|acc=" + accName(f->VpiAccessType());
    s += "|cstr=" + std::to_string(f->VpiDPICStr());
    s += "|ctx=" + std::to_string((int)f->VpiDPIContext());
    s += "|pure=" + std::to_string((int)f->VpiDPIPure());
    s += "|cid=" +
         (f->VpiDPICIdentifier().empty() ? std::string("-")
                                         : std::string(f->VpiDPICIdentifier()));
    s += "|io=" + std::to_string(nio);
    s += "|body=" + std::to_string((int)body);
    return s;
}

static std::string holderKey(const BaseClass *o) {
    std::string n(o->VpiDefName());
    if (n.empty()) n = std::string(o->VpiName());
    return std::string(UhdmName(o->UhdmType())) + ":" + n;
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct216cen <db.uhdm> [--dpi]\n"); return 2; }
    bool dpiOnly = (argc > 2 && strcmp(argv[2], "--dpi") == 0);
    bool filesOnly = (argc > 2 && strcmp(argv[2], "--files") == 0);
    bool noBuiltin = false;
    for (int a = 2; a < argc; ++a)
        if (strcmp(argv[a], "--nobuiltin") == 0) noBuiltin = true;
    Serializer s;
    s.Restore(std::string(argv[1]));

    if (filesOnly) {
        std::map<std::string, int> files;
        for (auto &kv : s.AllObjects()) {
            const BaseClass *o = kv.first;
            if (!o) continue;
            std::string f(o->VpiFile());
            if (!f.empty()) files[f]++;
        }
        for (auto &kv : files) printf("%s\n", kv.first.c_str());
        return 0;
    }

    std::map<std::string, int> counts;
    for (auto &kv : s.AllObjects()) {
        const BaseClass *o = kv.first;
        if (!o) continue;
        VectorOftask_func *tf = nullptr;
        if (const instance *in = dynamic_cast<const instance *>(o))
            tf = in->Task_funcs();
        else if (const class_defn *cd = dynamic_cast<const class_defn *>(o))
            tf = cd->Task_funcs();
        else
            continue;
        if (noBuiltin) {
            std::string h = holderKey(o);
            if (h == "class_defn:work@mailbox" || h == "class_defn:work@process" ||
                h == "class_defn:work@semaphore" ||
                h == "class_defn:any_sverilog_class" || h == "class_defn:array" ||
                h == "class_defn:queue" || h == "class_defn:string" ||
                h == "class_defn:system" || h == "package:builtin" ||
                h == "package:std")
                continue;
        }
        if (!tf) {
            counts["POS|" + holderKey(o) + "|NULLVEC"]++;
            continue;
        }
        for (size_t i = 0; i < tf->size(); i++) {
            std::string p = payload((*tf)[i]);
            if (dpiOnly && p.find("acc=EXPORT") == std::string::npos &&
                p.find("acc=IMPORT") == std::string::npos)
                continue;
            char idx[32];
            snprintf(idx, sizeof idx, "%05u", (unsigned)i);
            counts["POS|" + holderKey(o) + "|idx=" + idx + "|" + p]++;
            counts["MEM|" + holderKey(o) + "|" + p]++;
        }
    }
    for (auto &kv : counts) printf("%d\t%s\n", kv.second, kv.first.c_str());
    return 0;
}
