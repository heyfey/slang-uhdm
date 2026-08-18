// r10buvm15cen — THE CENSUS INSTRUMENT for SUBROUTINE-CALL ARGUMENT BINDING,
// with the § retNameRecvCollapse69 COLLAPSED call (a func_call whose callee IS
// the ENCLOSING function, i.e. the receiver named the return variable) as its
// named sub-family and ORDINARY in-body calls in the same bodies as controls.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours (cenjoin15.py).
//
// Reads a .uhdm out of Serializer::AllObjects() (NEVER dump TEXT) and prints
// one row per tf_call that sits inside a function/task body:
//
//   CALL <tag> key=<file>|<line>:<col> ck=<func_call|task_call|method_func_call>
//        nm=<VpiName> coll=<0|1> sub=<enclosing subroutine name>
//        sk=<function|task> sp=<subroutine's VpiParent UhdmType>
//        si=<0|1 the subroutine carries a vpiInstance>  st=<0|1 vpiAutomatic>
//        na=<#args> a=<i:kind(name)->actualkind(actualname);...>
//
// KEY = the CALL's own file:line:col.  This pass changes the ARGUMENTS'
// Actual_group, never the call's location, so the key is stable across the
// change on BOTH sides — the census can see its own subject move as a DISAGREE
// rather than as MISSING/EXTRA.  The VIEW is deliberately NOT in the key
// (buvm14's measured decision: the two producers label the same object's
// DEF/ELAB view differently and keying on it turns every row into a
// MISSING/EXTRA pair).
//
// usage: r10buvm15cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string nm(const any* t) {
    if (!t) return "-";
    return std::string(t->VpiName());
}
static std::string kindOf(const any* t) {
    if (!t) return "NULL";
    return std::string(UhdmName(t->UhdmType()));
}
// OUR objects carry an EMPTY VpiFile on many expression nodes while Surelog's
// carry the source path, so the file is inherited from the nearest ANCESTOR
// that has one (buvm14's measured fix; without it every one of our rows keys
// on "" and the join reports 100% MISSING/EXTRA).
static std::string fileOf(const any* o) {
    for (const any* p = o; p; p = p->VpiParent()) {
        std::string f(p->VpiFile());
        if (f.empty()) continue;
        auto sl = f.rfind('/');
        return sl == std::string::npos ? f : f.substr(sl + 1);
    }
    return "";
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm15cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    long ncall = 0, ncoll = 0, nargs = 0, nbound = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE ot = o->UhdmType();
        if (ot != uhdmfunc_call && ot != uhdmtask_call &&
            ot != uhdmmethod_func_call && ot != uhdmmethod_task_call)
            continue;
        auto* call = (const tf_call*)o;
        // Walk to the enclosing subroutine.  A call NOT inside one is skipped:
        // this census is about a subroutine BODY's bind window.
        const any* encl = nullptr;
        int guard = 0;
        for (const any* p = o->VpiParent(); p && guard < 80; p = p->VpiParent(), guard++) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (t == uhdmfunction || t == uhdmtask) { encl = p; break; }
            if (t == uhdmdesign) break;
        }
        if (!encl) continue;
        auto* sub = (const task_func*)encl;
        ncall++;
        int coll = 0;
        if (ot == uhdmfunc_call) {
            auto* fc = (const func_call*)o;
            if (fc->Function() == (const function*)encl) coll = 1;
            else if (encl->UhdmType() == uhdmfunction && !nm(o).empty() &&
                     nm(o) == nm(encl))
                coll = 1;
        }
        if (coll) ncoll++;
        std::string sp = kindOf(sub->VpiParent());
        int si = sub->Instance() ? 1 : 0;
        int st = sub->VpiAutomatic() ? 1 : 0;
        std::string as;
        int na = 0;
        if (auto* av = call->Tf_call_args()) {
            for (auto* a : *av) {
                if (!as.empty()) as += ";";
                std::string ak = kindOf(a), an = nm(a), act = "n/a", actn = "-";
                if (a && (a->UhdmType() == uhdmref_obj)) {
                    auto* r = (const ref_obj*)a;
                    const any* ag = r->Actual_group();
                    act = ag ? kindOf(ag) : "NULL";
                    actn = ag ? nm(ag) : "-";
                    nargs++;
                    if (ag) nbound++;
                }
                as += std::to_string(na) + ":" + ak + "(" + an + ")->" + act +
                      "(" + actn + ")";
                na++;
            }
        }
        rows.push_back("CALL " + tag + " key=" + fileOf(o) + "|" + loc(o) +
                       " ck=" + std::string(UhdmName(ot)) + " nm=" + nm(o) +
                       " coll=" + std::to_string(coll) + " sub=" + nm(encl) +
                       " sk=" + kindOf(encl) + " sp=" + sp +
                       " si=" + std::to_string(si) + " st=" + std::to_string(st) +
                       " na=" + std::to_string(na) +
                       " a=" + (as.empty() ? "<none>" : as));
    }
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " calls=" << ncall << " collapsed=" << ncoll
              << " refargs=" << nargs << " boundrefargs=" << nbound << "\n";
    return 0;
}
