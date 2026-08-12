// r10uvm60repro/argts60.cpp — CENSUS: which CALL ACTUALS carry a formal
// typespec (`vpiTypespec` -> ref_typespec), keyed by the SCOPE the call sits
// in, so "a class method binds no formal typespec" can be MEASURED on both
// sides instead of asserted.
//
//   usage: argts60 <db.uhdm> [list]
//
// For every func_call / task_call in the WHOLE database (Serializer::
// AllObjects, so no listing is missed), the probe walks VpiParent to the first
// enclosing function/task and then on up to the first class_defn / package /
// module_inst, and prints one row per (call-scope class, actual kind,
// has-typespec) cell.  With `list` it also prints every class-method actual
// that DOES carry a typespec, with the constant's size — the exact cell the
// r10uvm60 head lives in.
//
// GUARD: a missing/unreadable database is exit 3, never an empty census.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string scopeClass(const BaseClass* o, std::string& tfName) {
    // first enclosing task_func
    const BaseClass* p = o->VpiParent();
    const BaseClass* tf = nullptr;
    while (p) {
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
            tf = p;
            break;
        }
        if (p->UhdmType() == uhdmclass_defn || p->UhdmType() == uhdmpackage ||
            p->UhdmType() == uhdmmodule_inst)
            break;
        p = p->VpiParent();
    }
    if (tf)
        tfName = std::string(tf->VpiName());
    const BaseClass* q = tf ? tf->VpiParent() : o->VpiParent();
    while (q) {
        if (q->UhdmType() == uhdmclass_defn)
            return tf ? "CLASS_METHOD" : "CLASS_BODY";
        if (q->UhdmType() == uhdmpackage)
            return tf ? "PKG_FUNC" : "PKG_BODY";
        if (q->UhdmType() == uhdmmodule_inst)
            return tf ? "MOD_FUNC" : "MOD_BODY";
        q = q->VpiParent();
    }
    return tf ? "TF_ORPHAN" : "ORPHAN";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cout << "usage: argts60 <db.uhdm> [list]\n";
        return 3;
    }
    bool doList = argc > 2 && std::string(argv[2]) == "list";
    // `rows` mode: ONE LINE PER ACTUAL, sorted by source position, for the
    // grid tables — scope, call, arg kind, size/value/constType, typespec.
    bool doRows = argc > 2 && std::string(argv[2]) == "rows";
    std::error_code ec;
    if (!std::filesystem::exists(std::filesystem::path(argv[1]), ec)) {
        std::cout << "FATAL: no such database: " << argv[1] << "\n";
        return 3;
    }
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    if (ha.empty()) {
        std::cout << "FATAL: restore produced nothing\n";
        return 3;
    }
    std::map<std::string, long> cells;
    std::map<std::string, std::string> rows;  // sort key -> row text
    long calls = 0;
    // AllObjects() is keyed BY THE OBJECT (BaseClass* -> id), not the other way
    // round — reading it the other way silently casts an id to a pointer.
    for (auto& [obj, id] : sa.AllObjects()) {
        if (!obj)
            continue;
        UHDM_OBJECT_TYPE t = obj->UhdmType();
        // METHOD calls count too: a class method call is a method_func_call /
        // method_task_call, NOT a func_call, and leaving them out would have
        // made "no class-method actual carries a typespec" a statement about
        // the wrong objects.
        if (t != uhdmfunc_call && t != uhdmtask_call &&
            t != uhdmmethod_func_call && t != uhdmmethod_task_call)
            continue;
        calls++;
        auto* c = (const tf_call*)obj;
        if (!c->Tf_call_args())
            continue;
        std::string tfName;
        std::string sc = scopeClass(obj, tfName);
        for (auto* a : *c->Tf_call_args()) {
            if (!a)
                continue;
            std::string kind = UhdmName(a->UhdmType());
            const ref_typespec* rt = nullptr;
            if (auto* e = any_cast<const expr*>(a))
                rt = e->Typespec();
            std::string key = sc + "\t" + kind + "\t" +
                              (rt ? "TS" : "bare");
            cells[key]++;
            // SIZECELL: the same cell REFINED by the constant's own compared
            // fields (size + vpiConstType + value ENCODING prefix).  Positions
            // cannot be used as a key across a macro boundary — golden and ours
            // disagree on the macro-expanded column by construction — so the
            // size claim is proved as a MULTISET over these cells instead.
            if (a->UhdmType() == uhdmconstant) {
                auto* k = (const constant*)a;
                std::string v(k->VpiValue());
                std::string pfx = v.substr(0, v.find(':') == std::string::npos
                                                  ? 0
                                                  : v.find(':'));
                cells["SIZECELL\t" + sc + "\t" + pfx + "\tsize=" +
                      std::to_string(k->VpiSize()) + "\tct=" +
                      std::to_string(k->VpiConstType()) + "\t" +
                      (rt ? "TS" : "bare")]++;
            }
            if (doRows) {
                char pos[64];
                snprintf(pos, sizeof(pos), "%06u:%06u", a->VpiLineNo(),
                         (unsigned)a->VpiColumnNo());
                std::string r = std::string(pos) + "  " + sc + "  call=" +
                                std::string(c->VpiName()) + "  arg=" + kind;
                if (a->UhdmType() == uhdmconstant) {
                    auto* k = (const constant*)a;
                    r += "  size=" + std::to_string(k->VpiSize()) + "  val=" +
                         std::string(k->VpiValue()) + "  ct=" +
                         std::to_string(k->VpiConstType());
                }
                r += std::string("  ts=") +
                     (rt ? (rt->Actual_typespec()
                                ? UhdmName(rt->Actual_typespec()->UhdmType())
                                : "<null-actual>")
                         : "-");
                rows[r] = r;
            }
            if (doList && rt && sc == "CLASS_METHOD") {
                std::cout << "LIST " << sc << " tf=" << tfName
                          << " call=" << c->VpiName() << " arg=" << kind;
                if (a->UhdmType() == uhdmconstant) {
                    auto* k = (constant*)a;
                    std::cout << " size=" << k->VpiSize() << " val="
                              << k->VpiValue() << " ct=" << k->VpiConstType();
                }
                std::cout << " ts="
                          << (rt->Actual_typespec()
                                  ? UhdmName(rt->Actual_typespec()->UhdmType())
                                  : "<null>")
                          << " @" << a->VpiLineNo() << ":" << a->VpiColumnNo()
                          << "\n";
            }
        }
    }
    if (doRows)
        for (auto& [k, r] : rows)
            std::cout << r << "\n";
    std::cout << "calls=" << calls << "\n";
    for (auto& [k, v] : cells)
        std::cout << "CELL\t" << k << "\t" << v << "\n";
    return 0;
}
