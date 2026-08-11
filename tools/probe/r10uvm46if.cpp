// r10uvm46if — the interface_inst OBJECT + CONTAINER-POSITION census.
//
// Pass 45 ranked "SimpleUVM's MISSING interface_inst" first: golden holds THREE
// interface_inst objects (`add_sub_if0` TWICE) where we hold TWO, which is the
// `r=1 failLhs=<container>` vector-SIZE class — a MISSING OBJECT, not a wrong
// field.  A KIND:NAME count cannot say WHERE the third one sits, so this probe
// prints BOTH halves:
//
//   OBJ  interface_inst '<name>' def='<defname>' full='<fullname>' <view>
//        parent=<kind> '<parent fullname>'
//   CTR  <kind> '<fullname>'<view> Interfaces n=<k> | <name>@<defname> | ...
//   CTR  <kind> '<fullname>'<view> Interface_arrays n=<k> | ...
//
// `<view>` is /top when VpiTop() is set (the elaborated view) and /def
// otherwise — a DEF-vs-TOP confusion is the standard trap for this class of
// residue, and two views of one module carry the SAME VpiName.
//
// The OBJ half answers "does the object exist at all"; the CTR half answers
// "which vector position holds it", and an object can exist while being in NO
// container (which is exactly what a `bind` instance published only into the
// serializer would look like).  Ordering is by printed text: AllObjects is
// pointer-keyed and its iteration order changes between runs.
//
//   r10uvm46if <file.uhdm> [nameFilter]
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sv(std::string_view s) { return std::string(s); }

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm46if <file.uhdm> [nameFilter]\n";
        return 2;
    }
    std::string filt;
    // -p adds POINTER IDENTITY of each interface_inst's child vectors and their
    // elements.  A COUNT cannot answer "does the twin SHARE the object it twins
    // or hold a copy?", and that decides whether the implementation shares a
    // vector or clones one.  Pointer text is unstable run to run, so it is off
    // by default to keep the ordinary projection diff-stable.
    bool ptrs = false;
    for (int i = 2; i < argc; i++) {
        if (std::string(argv[i]) == "-p")
            ptrs = true;
        else
            filt = argv[i];
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "FATAL: restore produced no design from " << argv[1]
                  << "\n";
        return 1;
    }
    std::vector<std::string> out;
    auto view = [](bool top) { return std::string(top ? "/top" : "/def"); };
    auto pname = [](const any* p) -> std::string {
        if (!p)
            return "<none> '<none>'";
        std::string n(p->VpiName());
        if (auto* i = any_cast<const instance*>(p)) {
            std::string f(i->VpiFullName());
            if (!f.empty())
                n = f;
        }
        return std::string(UhdmName(p->UhdmType())) + " '" + n + "'";
    };
    auto ctr = [&](const std::string& who, const char* which,
                   const std::vector<interface_inst*>* v) {
        std::string l = "CTR  " + who + " " + which + " n=" +
                        std::to_string(v ? v->size() : 0);
        for (auto* i : v ? *v : std::vector<interface_inst*>{})
            l += " | " + sv(i->VpiName()) + "@" + sv(i->VpiDefName());
        out.push_back(l);
    };
    auto ctrA = [&](const std::string& who, const char* which,
                    const std::vector<interface_array*>* v) {
        std::string l = "CTR  " + who + " " + which + " n=" +
                        std::to_string(v ? v->size() : 0);
        for (auto* i : v ? *v : std::vector<interface_array*>{})
            l += " | " + sv(i->VpiName()) + "@" + sv(i->VpiDefName());
        out.push_back(l);
    };
    for (auto& [o, id] : s.AllObjects()) {
        if (auto* i = any_cast<const interface_inst*>(o)) {
            // The PRODUCTION-SITE discriminator.  Surelog mints an
            // interface_inst at TWO sites and they leave different traces:
            // NetlistElaboration::elab_interface_ sets VpiFile/VpiLineNo and
            // NO VpiDefFile, NO VpiFullName, NO Instance(); UhdmWriter's
            // child-instance walk sets VpiFullName, VpiDefFile/VpiDefLineNo and
            // Instance() when the holder is a module.  A count cannot tell the
            // two apart, so print the trace.
            out.push_back(
                "OBJ  interface_inst '" + sv(i->VpiName()) + "' def='" +
                sv(i->VpiDefName()) + "' full='" + sv(i->VpiFullName()) + "' " +
                view(i->VpiTop()) + " parent=" + pname(i->VpiParent()) +
                " deffile=" + (i->VpiDefFile().empty() ? "-" : "SET") +
                " defline=" + std::to_string(i->VpiDefLineNo()) +
                " inst=" + (i->Instance() ? pname(i->Instance()) : "<none>") +
                " loc=" + std::to_string(i->VpiLineNo()) + ":" +
                std::to_string(i->VpiColumnNo()) +
                " ntypespecs=" +
                std::to_string(i->Typespecs() ? i->Typespecs()->size() : 0) +
                " nports=" + std::to_string(i->Ports() ? i->Ports()->size() : 0) +
                " nmodports=" +
                std::to_string(i->Modports() ? i->Modports()->size() : 0) +
                // Every remaining child vector, because the implementation
                // question is "is the TWIN structurally identical to the object
                // it twins?" and cmp recurses into all of them.  Printing only
                // the three I happened to think of would answer it by inference.
                " nvars=" +
                std::to_string(i->Variables() ? i->Variables()->size() : 0) +
                " nnets=" + std::to_string(i->Nets() ? i->Nets()->size() : 0) +
                " ncassign=" +
                std::to_string(i->Cont_assigns() ? i->Cont_assigns()->size()
                                                 : 0) +
                " nproc=" +
                std::to_string(i->Process() ? i->Process()->size() : 0) +
                " nparam=" +
                std::to_string(i->Parameters() ? i->Parameters()->size() : 0) +
                " nparamassign=" +
                std::to_string(i->Param_assigns() ? i->Param_assigns()->size()
                                                  : 0) +
                " ntf=" +
                std::to_string(i->Task_funcs() ? i->Task_funcs()->size() : 0) +
                " nclk=" +
                std::to_string(i->Clocking_blocks()
                                   ? i->Clocking_blocks()->size()
                                   : 0) +
                " ngsa=" +
                std::to_string(i->Gen_scope_arrays()
                                   ? i->Gen_scope_arrays()->size()
                                   : 0) +
                " nassert=" +
                std::to_string(i->Assertions() ? i->Assertions()->size() : 0) +
                " nnamedev=" +
                std::to_string(i->Named_events() ? i->Named_events()->size()
                                                 : 0) +
                " nitems=" +
                std::to_string(i->Instance_items()
                                   ? i->Instance_items()->size()
                                   : 0) +
                (!ptrs ? std::string()
                       : [&] {
                             char b[512];
                             std::string r = " portsvec=";
                             snprintf(b, sizeof b, "%p", (void*)i->Ports());
                             r += b;
                             r += " varsvec=";
                             snprintf(b, sizeof b, "%p", (void*)i->Variables());
                             r += b;
                             r += " netsvec=";
                             snprintf(b, sizeof b, "%p", (void*)i->Nets());
                             r += b;
                             r += " P[";
                             for (auto* p : i->Ports()
                                                ? *i->Ports()
                                                : std::vector<port*>{}) {
                                 snprintf(b, sizeof b, "%p,", (void*)p);
                                 r += b;
                             }
                             r += "] V[";
                             for (auto* v : i->Variables()
                                                ? *i->Variables()
                                                : std::vector<variables*>{}) {
                                 snprintf(b, sizeof b, "%p,", (void*)v);
                                 r += b;
                             }
                             r += "]";
                             return r;
                         }()));
            std::string who = "interface_inst '" + sv(i->VpiFullName()) + "'" +
                              view(i->VpiTop());
            ctr(who, "Interfaces", i->Interfaces());
            ctrA(who, "Interface_arrays", i->Interface_arrays());
        }
        else if (auto* m = any_cast<const module_inst*>(o)) {
            std::string who = "module_inst '" + sv(m->VpiFullName()) + "'" +
                              view(m->VpiTop());
            ctr(who, "Interfaces", m->Interfaces());
            ctrA(who, "Interface_arrays", m->Interface_arrays());
        }
        else if (auto* d = any_cast<const design*>(o)) {
            std::string l = "DSG  AllInterfaces n=" +
                            std::to_string(d->AllInterfaces()
                                               ? d->AllInterfaces()->size()
                                               : 0);
            for (auto* i :
                 d->AllInterfaces() ? *d->AllInterfaces()
                                    : std::vector<interface_inst*>{})
                l += " | " + sv(i->VpiName()) + "@" + sv(i->VpiDefName()) +
                     view(i->VpiTop());
            out.push_back(l);
            std::string t = "DSG  TopModules n=" +
                            std::to_string(d->TopModules()
                                               ? d->TopModules()->size()
                                               : 0);
            for (auto* m :
                 d->TopModules() ? *d->TopModules()
                                 : std::vector<module_inst*>{})
                t += " | " + sv(m->VpiName());
            out.push_back(t);
        }
    }
    std::sort(out.begin(), out.end());
    size_t nobj = 0;
    for (auto& l : out)
        if (l.rfind("OBJ ", 0) == 0)
            nobj++;
    if (nobj == 0) {
        std::cerr << "FATAL: ZERO interface_inst objects seen in " << argv[1]
                  << " — a census that can see nothing is indistinguishable "
                     "from an empty population; refusing to print\n";
        return 4;
    }
    for (auto& l : out)
        if (filt.empty() || l.find(filt) != std::string::npos)
            std::cout << l << "\n";
    std::cerr << "OBJcount=" << nobj << "\n";
    return 0;
}
