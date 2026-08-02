// r10cls: class_defn / package Task_funcs census with the fields
// class_defn::Compare and task_func::Compare actually read.
//
// Written for ApbSlave (r10apb), where `extern` prototypes with OUT-OF-BODY
// definitions produce THREE separate listings (class methods, package
// clones, module hoist) and only the full per-object field listing shows
// which listing an object belongs to.
//
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10cls.cpp -o /tmp/r10cls \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Run:  /tmp/r10cls <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void tfs(const std::string& tag, const VectorOftask_func* v) {
    if (!v) {
        std::cout << tag << " Task_funcs: <null>\n";
        return;
    }
    std::cout << tag << " Task_funcs: " << v->size() << "\n";
    int i = 0;
    for (auto* tf : *v) {
        std::cout << "  [" << i++ << "] " << UhdmName(tf->UhdmType()) << " '"
                  << tf->VpiName() << "' full='" << tf->VpiFullName() << "' @"
                  << tf->VpiLineNo() << ":" << tf->VpiColumnNo() << "-"
                  << tf->VpiEndLineNo() << ":" << tf->VpiEndColumnNo()
                  << " method=" << tf->VpiMethod()
                  << " vis=" << tf->VpiVisibility()
                  << " acc=" << tf->VpiAccessType()
                  << " virt=" << tf->VpiVirtual()
                  << " auto=" << tf->VpiAutomatic() << " stmt="
                  << (tf->Stmt() ? UhdmName(tf->Stmt()->UhdmType()) : "-")
                  << " io=" << (tf->Io_decls() ? (int)tf->Io_decls()->size() : -1)
                  << " parent=";
        if (auto* p = tf->VpiParent())
            std::cout << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")";
        else
            std::cout << "<null>";
        std::cout << "\n";
    }
}

static void vars(const std::string& tag, const VectorOfvariables* v) {
    if (!v) return;
    std::cout << tag << " Variables: " << v->size() << "\n";
    int i = 0;
    for (auto* x : *v)
        std::cout << "  [" << i++ << "] " << UhdmName(x->UhdmType()) << " '"
                  << x->VpiName() << "' @" << x->VpiLineNo() << ":"
                  << x->VpiColumnNo() << " vis=" << x->VpiVisibility()
                  << " auto=" << x->VpiAutomatic()
                  << " const=" << x->VpiConstantVariable() << " expr="
                  << (x->Expr() ? UhdmName(x->Expr()->UhdmType()) : "-") << "\n";
}

static void cls(const std::string& tag, const class_defn* c) {
    std::cout << "=== " << tag << " class_defn '" << c->VpiName() << "' full='"
              << c->VpiFullName() << "'\n";
    vars(tag, c->Variables());
    tfs(tag, c->Task_funcs());
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    auto pkgs = [&](const VectorOfpackage* v, const char* view) {
        if (!v) return;
        for (auto* p : *v) {
            if (p->VpiName() == "builtin") continue;
            std::string t = std::string(view) + ":" + std::string(p->VpiName());
            tfs(t, p->Task_funcs());
            vars(t, p->Variables());
            if (auto* cds = p->Class_defns())
                for (auto* c : *cds) cls(t, c);
        }
    };
    pkgs(d->AllPackages(), "AllPkg");
    pkgs(d->TopPackages(), "TopPkg");
    if (auto* v = d->AllClasses())
        for (auto* c : *v)
            if (c->VpiFullName().find("builtin") == std::string::npos)
                cls("AllClasses", c);
    auto mods = [&](const VectorOfmodule_inst* v, const char* view) {
        if (!v) return;
        for (auto* m : *v) {
            std::string t = std::string(view) + ":" + std::string(m->VpiFullName());
            tfs(t, m->Task_funcs());
            vars(t, m->Variables());
            if (auto* n = m->Nets()) {
                std::cout << t << " Nets: " << n->size() << "\n";
                int i = 0;
                for (auto* x : *n)
                    std::cout << "  [" << i++ << "] " << UhdmName(x->UhdmType())
                              << " '" << x->VpiName() << "' @" << x->VpiLineNo()
                              << ":" << x->VpiColumnNo() << "\n";
            }
        }
    };
    mods(d->AllModules(), "AllMod");
    mods(d->TopModules(), "TopMod");
    return 0;
}
