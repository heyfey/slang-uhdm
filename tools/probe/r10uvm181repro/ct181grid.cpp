// r10uvm181 — THE SINGLE-DATABASE ROW DUMPER for the golden grid.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  One line per REFERENCE (`ref_obj` / `ref_var` / `bit_select`),
// carrying the same classification `ct181cen.cpp` joins on, so golden's rows
// and each binary's rows can be diffed as TEXT.
//
// The rows carry NO object ids and NO file paths (a dump path embeds the
// workdir), so a golden row and a slang row are comparable byte for byte.
//
// build: g++ -O2 -std=c++17 ct181grid.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct181grid
// usage: ct181grid <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "BARE";
    char b[600];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    snprintf(b, sizeof b, "%s:%s@%u:%u", k.c_str(), n.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const bit_select*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    auto t = o->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
static bool loopVarName(const BaseClass* o, std::string_view nm) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmforeach_stmt)
            if (auto* lv = ((const foreach_stmt*)p)->VpiLoopVars())
                for (auto* v : *lv)
                    if (v && v->VpiName() == nm) return true;
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) break;
    }
    return false;
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct181grid <db> <tag>\n"); return 2; }
    const std::string tag = argv[2];
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    std::map<std::string, int> rank;
    // Deterministic order so the per-key occurrence rank is reproducible.
    std::vector<const BaseClass*> objs;
    for (auto& kv : S.AllObjects())
        if (kv.first && isRef(kv.first)) objs.push_back(kv.first);
    std::sort(objs.begin(), objs.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() < b->UhdmId();
    });
    for (const BaseClass* o : objs) {
        const task_func* tf = nullptr;
        std::string pkg = "-";
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (!tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                tf = (const task_func*)p;
            if (p->UhdmType() == uhdmpackage) { pkg = std::string(p->VpiName()); break; }
            if (p->UhdmType() == uhdmmodule_inst) { pkg = "MOD:" + std::string(p->VpiName()); break; }
        }
        bool io = tf && tf->Io_decls() && !tf->Io_decls()->empty();
        bool vs = tf && tf->Variables() && !tf->Variables()->empty();
        const std::string nm(o->VpiName());
        std::string key = pkg + "|" +
                          (tf ? std::string(tf->VpiName()) : "-") + "|" +
                          ((tf && !io && !vs) ? "EMPTYTF" : "HASLOCALS") + "|" +
                          (loopVarName(o, nm) ? "LOOPVAR" : "OTHER") + "|" +
                          std::string(UhdmName(o->UhdmType())) + ":" + nm +
                          "@" + std::to_string(o->VpiLineNo()) + ":" +
                          std::to_string((unsigned)o->VpiColumnNo());
        key += "#" + std::to_string(rank[key]++);
        // <tag>\t<key>\t<value> — the format score181.py joins on.
        rows.push_back(tag + "\t" + key + "\t" + face(actualOf(o)));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    return 0;
}
