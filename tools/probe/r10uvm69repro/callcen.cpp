// r10uvm69repro/callcen.cpp — SPAN-KEYED CENSUS OF EVERY CALL OBJECT in a
// database, built so golden's `func_call` and ours' `method_func_call` for the
// SAME written statement land on the SAME key.
//
// WHY NOT KEY ON THE OBJECT'S OWN SPAN: golden's func_call for
// `open_recorder.m_do_open(this, m_time, type_name);` spans 343:13-343:61 (the
// WHOLE expression, from the RECEIVER token) while ours' method_func_call spans
// 343:27-343:36 (the METHOD token only).  A key built from the call object's own
// start pairs NOTHING and would report every cell as "golden-only + ours-only",
// which is the classic add+drop artefact this campaign keeps paying for.
//
// THE KEY IS THE ARGUMENT SPANS: `line|argstart,argstart,...`.  Both sides carry
// the identical three vpiArgument children at 343:37 / 343:43 / 343:51, so the
// key pairs them exactly and is blind to the shape disagreement being measured.
// A call with NO arguments falls back to `line|@col` on its own start, which is
// stable across both shapes only when the shapes agree — those cells are marked
// NOARG so a reader never mistakes an unpaired one for a real cell.
//
// One line per call object:
//   <kind> <name> <start>-<end> args=<n> [<argspans>] prefix=<name>@<span>
//     fn=<vpiFunction target or -> owner=<enclosing routine fullname>
//     RETNAME=<0/1>
//
// RETNAME is the head's own predicate, computed HERE rather than assumed: it is
// 1 when the call's PREFIX name (ours) or the call's OWN name (golden) equals
// the last `::`/`.` segment of the ENCLOSING routine's fullname — i.e. the
// receiver is spelled with the enclosing function's own return-variable name.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string lastSeg(std::string s) {
    auto p = s.rfind("::");
    if (p != std::string::npos) s = s.substr(p + 2);
    p = s.rfind('.');
    if (p != std::string::npos) s = s.substr(p + 1);
    return s;
}

static std::string spanOf(const BaseClass* o) {
    std::ostringstream os;
    os << o->VpiLineNo() << ":" << o->VpiColumnNo() << "-" << o->VpiEndLineNo()
       << ":" << o->VpiEndColumnNo();
    return os.str();
}

// Walk vpiParent up to the nearest enclosing task/function and return its
// fullname.  The head's begin-block parent is named for the routine, but a
// NESTED begin is not, so the walk must continue to the routine OBJECT itself.
static std::string ownerOf(const BaseClass* o) {
    const BaseClass* p = o;
    for (int guard = 0; p && guard < 200; guard++) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) {
            auto* tf = (const task_func*)p;
            return tf->VpiFullName().empty() ? std::string(tf->VpiName())
                                             : std::string(tf->VpiFullName());
        }
        p = p->VpiParent();
    }
    return "";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: callcen <file.uhdm>\n";
        return 2;
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "NO_RESTORE " << argv[1] << "\n";
        return 6;
    }
    auto all = s.AllObjects();
    int nfc = 0, nmfc = 0;
    for (auto& [obj, id] : all) {
        if (!obj) continue;
        UHDM_OBJECT_TYPE t = obj->UhdmType();
        if (t != uhdmfunc_call && t != uhdmmethod_func_call && t != uhdmtask_call &&
            t != uhdmmethod_task_call)
            continue;
        const char* kind = t == uhdmfunc_call          ? "func_call"
                           : t == uhdmmethod_func_call ? "method_func_call"
                           : t == uhdmtask_call        ? "task_call"
                                                       : "method_task_call";
        auto* tfc = (const tf_call*)obj;
        std::string name(tfc->VpiName());
        // argument spans — the pairing key
        std::vector<std::string> argst;
        if (tfc->Tf_call_args())
            for (auto* a : *tfc->Tf_call_args()) {
                std::ostringstream as;
                as << a->VpiLineNo() << ":" << a->VpiColumnNo();
                argst.push_back(as.str());
            }
        std::string key;
        {
            std::ostringstream ks;
            ks << obj->VpiLineNo() << "|";
            if (argst.empty())
                ks << "@" << obj->VpiColumnNo() << "NOARG";
            else
                for (size_t i = 0; i < argst.size(); i++)
                    ks << (i ? "," : "") << argst[i];
            key = ks.str();
        }
        // prefix (ours' shape only)
        std::string pfx = "-";
        if (t == uhdmmethod_func_call || t == uhdmmethod_task_call) {
            const any* pr = t == uhdmmethod_func_call
                                ? ((const method_func_call*)obj)->Prefix()
                                : ((const method_task_call*)obj)->Prefix();
            if (pr) {
                std::ostringstream ps;
                ps << pr->VpiName() << "@" << pr->VpiLineNo() << ":"
                   << pr->VpiColumnNo();
                pfx = ps.str();
            }
        }
        // vpiFunction / vpiTask link target
        std::string tgt = "-";
        if (t == uhdmfunc_call) {
            if (auto* f = ((const func_call*)obj)->Function())
                tgt = f->VpiFullName().empty() ? std::string(f->VpiName())
                                               : std::string(f->VpiFullName());
        } else if (t == uhdmtask_call) {
            if (auto* f = ((const task_call*)obj)->Task())
                tgt = f->VpiFullName().empty() ? std::string(f->VpiName())
                                               : std::string(f->VpiFullName());
        }
        std::string owner = ownerOf(obj);
        std::string oseg = lastSeg(owner);
        // RETNAME: the receiver is spelled with the enclosing routine's name.
        // Golden carries it as the call's OWN name; ours as the PREFIX's name.
        std::string recvName;
        if (t == uhdmmethod_func_call || t == uhdmmethod_task_call) {
            const any* pr = t == uhdmmethod_func_call
                                ? ((const method_func_call*)obj)->Prefix()
                                : ((const method_task_call*)obj)->Prefix();
            if (pr) recvName = std::string(pr->VpiName());
        } else {
            recvName = name;
        }
        int retname = (!oseg.empty() && recvName == oseg) ? 1 : 0;
        if (t == uhdmfunc_call) nfc++;
        if (t == uhdmmethod_func_call) nmfc++;
        std::cout << "KEY " << key << "\t" << kind << "\t" << name << "\t"
                  << spanOf(obj) << "\targs=" << argst.size() << "\tprefix="
                  << pfx << "\ttgt=" << tgt << "\towner=" << owner
                  << "\tRETNAME=" << retname << "\n";
    }
    std::cerr << "func_call=" << nfc << " method_func_call=" << nmfc << "\n";
    return 0;
}
