// r10uvm184 — THE METHOD-CALL ARGUMENT BINDING CENSUS.  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is
// ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `ref_obj` / `ref_var` whose IMMEDIATE parent is a
// `method_func_call` — the argument face the head lives on.  Beside the
// argument's own `vpiActual` the row carries the RECEIVER's actual: the
// `method_func_call`'s `Prefix()` when it has one, else the actual of the
// `hier_path` element that precedes the call in `Path_elems` (that is how a
// written `<recv>.<method>(...)` is modelled — the call is the LAST element and
// the receiver the one before it).  `SAME` in the last column means the
// argument was bound to the RECEIVER, which is the law's whole subject.
//
// KEY (id-free): LISTING | SUBR | LINE:COL | NAME | ARGIDX | ACT | RECV | VERDICT
//
// build: g++ -O2 -std=c++17 ct184mfc.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184mfc
// usage: ct184mfc <db.uhdm> [subr-name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string face(const BaseClass* o) {
    if (!o) return "BARE";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static std::string listingOf(const BaseClass* o) {
    std::string root = "-";
    bool cls = false;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmclass_defn) cls = true;
        if (p->UhdmType() == uhdmdesign) break;
        root = kindOf(p) + ":" + std::string(p->VpiName());
    }
    return root + (cls ? "+cls" : "");
}
static std::string subrOf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)
            return std::string(p->VpiName());
    return "-";
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
// The receiver of a method_func_call, as written.
static const BaseClass* receiverOf(const method_func_call* mfc) {
    if (const any* p = mfc->Prefix()) return p;
    const BaseClass* par = mfc->VpiParent();
    const hier_path* hp = par ? any_cast<const hier_path*>(par) : nullptr;
    if (!hp || !hp->Path_elems()) return nullptr;
    const VectorOfany* v = hp->Path_elems();
    for (size_t i = 0; i < v->size(); ++i)
        if (v->at(i) == (const any*)mfc) return i ? (const BaseClass*)v->at(i - 1) : nullptr;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct184mfc <db.uhdm> [subr-substr]\n"); return 2; }
    const char* want = argc > 2 ? argv[2] : nullptr;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    size_t nSame = 0, nBare = 0, nOther = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var) continue;
        const BaseClass* par = o->VpiParent();
        const method_func_call* mfc = par ? any_cast<const method_func_call*>(par) : nullptr;
        if (!mfc) continue;
        const std::string sub = subrOf(o);
        if (want && sub.find(want) == std::string::npos) continue;
        int argIdx = -1;
        if (mfc->Tf_call_args())
            for (size_t i = 0; i < mfc->Tf_call_args()->size(); ++i)
                if (mfc->Tf_call_args()->at(i) == (const any*)o) argIdx = (int)i;
        const BaseClass* act = actualOf(o);
        const BaseClass* recv = receiverOf(mfc);
        const BaseClass* recvAct = recv ? actualOf(recv) : nullptr;
        const bool userDefn = mfc->Function() != nullptr;
        const char* verdict = !act ? "BARE"
                              : (act == recvAct || act == recv) ? "SAME-AS-RECEIVER"
                                                                : "OTHER";
        if (!act) ++nBare;
        else if (act == recvAct || act == recv) ++nSame;
        else ++nOther;
        char b[2400];
        snprintf(b, sizeof b, "%-22s %-34s %5u:%-3u %-22s arg%-2d m=%-14s fn=%d %-34s recv=%-30s %s",
                 listingOf(o).c_str(), sub.c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), std::string(o->VpiName()).c_str(),
                 argIdx, std::string(mfc->VpiName()).c_str(), (int)userDefn,
                 face(act).c_str(),
                 (face(recv) + "->" + face(recvAct)).c_str(), verdict);
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("ROWS %zu  BARE %zu  SAME-AS-RECEIVER %zu  OTHER %zu\n", rows.size(),
           nBare, nSame, nOther);
    return 0;
}
