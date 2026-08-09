// r10uvm30io — the io_decl FORMAL census, pass 30's decode probe.
// r10uvm29io only printed rows for methods that HAVE an Io_decls() vector, so
// a method whose formals we drop entirely is invisible in it (Scoreboard's 107
// golden-only rows are exactly that shape).  This one prints a row for EVERY
// class method — `io[-] <none>` when the vector is null/empty — and projects
// each formal onto the fields uhdm-cmp reads plus vpiDirection and the
// default's decompile/value, which the keep-vs-drop decode needs.
//   r10uvm30io <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static const char* dirs(int d) {
    switch (d) {
        case vpiInput: return "in";
        case vpiOutput: return "out";
        case vpiInout: return "inout";
        case vpiRef: return "ref";
        default: return "?";
    }
}
static std::string vals(const any* e) {
    if (!e) return "";
    if (const expr* x = any_cast<const expr*>(e)) {
        std::string v(x->VpiValue()), d(x->VpiDecompile());
        return " v=" + v + " d=" + d;
    }
    return "";
}
// The io_decl's typespec projected the way uhdm-cmp reads it: the
// ref_typespec's ACTUAL, its kind, its name and the vpiInstance the typespec
// carries (the field § pkgClassFormalCloneInst18 turns on).
static std::string ats(const io_decl* io) {
    const ref_typespec* r = io->Typespec();
    if (!r) return "-";
    const typespec* a = r->Actual_typespec();
    if (!a) return "ref/null";
    std::string o = tn(a) + "'" + std::string(a->VpiName()) + "'";
    if (const instance* in = a->Instance())
        o += "@" + std::string(in->VpiName());
    if (io->Ranges() && !io->Ranges()->empty())
        o += " iorng=" + std::to_string(io->Ranges()->size());
    return o;
}
static std::set<const class_defn*> seen;

static void doClass(const char* tag, const class_defn* c) {
    if (!c || !seen.insert(c).second) return;
    std::string nm(c->VpiFullName().empty() ? c->VpiName() : c->VpiFullName());
    if (!c->Task_funcs()) return;
    for (auto* tf : *c->Task_funcs()) {
        std::string h =
            std::string(tag) + " " + nm + "::" + std::string(tf->VpiName());
        if (!tf->Io_decls() || tf->Io_decls()->empty()) {
            std::cout << h << " io[-] <none>\n";
            continue;
        }
        size_t i = 0;
        for (auto* io : *tf->Io_decls()) {
            std::cout << h << " io[" << i++ << "] '" << io->VpiName() << "' "
                      << dirs(io->VpiDirection()) << " ts=" << ats(io)
                      << " expr=" << (io->Expr() ? tn(io->Expr()) : "-") << " '"
                      << (io->Expr() ? io->Expr()->VpiName() : "")
                      << "'" << vals(io->Expr()) << "\n";
        }
    }
}

// The same projection over a NON-class scope's own task_funcs (a package's,
// a module's, the compilation unit's) — pass 30's control asks whether the
// formal-default law is a class-method rule or a subroutine rule.
static void doTfs(const char* tag, const std::string& nm,
                  const VectorOftask_func* tfs) {
    if (!tfs) return;
    for (auto* tf : *tfs) {
        std::string h = std::string(tag) + " " + nm + "::" +
                        std::string(tf->VpiName());
        if (!tf->Io_decls() || tf->Io_decls()->empty()) {
            std::cout << h << " io[-] <none>\n";
            continue;
        }
        size_t i = 0;
        for (auto* io : *tf->Io_decls())
            std::cout << h << " io[" << i++ << "] '" << io->VpiName() << "' "
                      << dirs(io->VpiDirection()) << " ts=" << ats(io)
                      << " expr=" << (io->Expr() ? tn(io->Expr()) : "-") << " '"
                      << (io->Expr() ? io->Expr()->VpiName() : "")
                      << "'" << vals(io->Expr()) << "\n";
    }
}

template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiFullName().empty() ? p->VpiName()
                                                : p->VpiFullName());
        doTfs(tag, nm, p->Task_funcs());
        if (p->Class_defns())
            for (auto* cd : *p->Class_defns()) doClass(tag, cd);
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    doScope("DEFMOD", d->AllModules());
    doScope("TOPMOD", d->TopModules());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    return 0;
}
