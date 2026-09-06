// r10uvm172 — THE CALL-CHAIN LISTING INSTRUMENT.  MEASUREMENT ONLY; the
// official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// It prints ONE ROW per statement-position call object — `func_call`,
// `task_call`, `method_func_call`, `method_task_call` — plus the `hier_path`
// that carries a call element, keyed on the SPAN so the two producers' rows
// line up.  The payload is exactly what `BaseClass::Compare` reads for these
// kinds: the UhdmType, the VpiName, whether a Function/Task LINK is set (and
// its name), whether a vpiPrefix is set (and its name), and the argument
// count.  The enclosing subroutine's NAME is printed too — the law's whole
// question is whether the chain's BASE identifier equals it.
//
// The home chain is EVIDENCE, never a key: the DEF view, the home package's
// elaborated copy and a wildcard-import clone label it differently
// (RESUME.md §9), so a scorer must not join on it.
//
// build: g++ -O2 -std=c++17 ct172list.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct172list
// usage: ct172list <db.uhdm> [<name substring filter>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("<null>");
}
// Only the NAMED scopes: package / class_defn / module_inst / function / task.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += " <";
        s += kn(p);
        s += ":";
        s += nm(p);
    }
    return s;
}
static const BaseClass* encSub(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct172list <db.uhdm> [name]\n"); return 2; }
    const char* want = argc > 2 ? argv[2] : nullptr;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        const bool isCall = (t == uhdmfunc_call || t == uhdmtask_call ||
                             t == uhdmmethod_func_call ||
                             t == uhdmmethod_task_call);
        const bool isPath = (t == uhdmhier_path);
        if (!isCall && !isPath) continue;
        // A hier_path is listed only when it CARRIES a call element — the
        // shape this law's population competes with.
        std::string pelems;
        if (isPath) {
            const hier_path* hp = any_cast<const hier_path*>(o);
            bool hasCall = false;
            if (hp->Path_elems())
                for (const any* e : *hp->Path_elems()) {
                    if (!pelems.empty()) pelems += "+";
                    pelems += kn(e) + "(" + nm(e) + ")";
                    const UHDM_OBJECT_TYPE et = e->UhdmType();
                    if (et == uhdmmethod_func_call || et == uhdmmethod_task_call ||
                        et == uhdmfunc_call || et == uhdmtask_call)
                        hasCall = true;
                }
            if (!hasCall) continue;
        }
        const BaseClass* sub = encSub(o);
        std::string link = "-", pfx = "-";
        int nargs = -1;
        if (t == uhdmfunc_call) {
            const func_call* f = any_cast<const func_call*>(o);
            link = f->Function() ? ("F:" + nm(f->Function())) : "F:<null>";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else if (t == uhdmtask_call) {
            const task_call* f = any_cast<const task_call*>(o);
            link = f->Task() ? ("T:" + nm(f->Task())) : "T:<null>";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else if (t == uhdmmethod_func_call) {
            const method_func_call* f = any_cast<const method_func_call*>(o);
            link = f->Function() ? ("F:" + nm(f->Function())) : "F:<null>";
            pfx = f->Prefix() ? (kn(f->Prefix()) + "(" + nm(f->Prefix()) + ")") : "-";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else if (t == uhdmmethod_task_call) {
            const method_task_call* f = any_cast<const method_task_call*>(o);
            link = f->Task() ? ("T:" + nm(f->Task())) : "T:<null>";
            pfx = f->Prefix() ? (kn(f->Prefix()) + "(" + nm(f->Prefix()) + ")") : "-";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        }
        char buf[2048];
        snprintf(buf, sizeof(buf),
                 "%s:%u:%u-%u:%u kind=%s name=%s link=%s pfx=%s args=%d sub=%s%s%s",
                 "@", (unsigned)o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                 (unsigned)o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(),
                 kn(o).c_str(), nm(o).c_str(), link.c_str(), pfx.c_str(), nargs,
                 sub ? nm(sub).c_str() : "-",
                 pelems.empty() ? "" : " elems=", pelems.c_str());
        std::string r(buf);
        r += " home=" + homeChain(o);
        if (want && r.find(want) == std::string::npos) continue;
        rows.push_back(r);
    }
    std::sort(rows.begin(), rows.end());
    for (const std::string& r : rows) printf("%s\n", r.c_str());
    return 0;
}
