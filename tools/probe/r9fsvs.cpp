// r9fsvs: which VIEW of a shared struct typespec carries typespec_member
// vpiExpr stamps? EvalFunc's member-assignment leftovers are stamped on ONE of
// the two package copies (uhdmallPackages vs uhdmtopPackages) and on the
// module parameter's own ts pointer, and object identity is invisible in a
// uhdm-dump (repeated objects print abbreviated). Prints, per file, every
// struct_typespec reachable from the four design containers with a stable
// per-file object index, so `same ptr` vs `distinct copy` is decidable.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <functional>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const BaseClass*, int> g_ids;
static int g_next = 0;

static int oid(const BaseClass* o) {
    if (!o) return -1;
    auto it = g_ids.find(o);
    if (it != g_ids.end()) return it->second;
    return g_ids[o] = g_next++;
}

static std::string cst(const any* e) {
    if (!e) return "<null>";
    std::string t = UhdmName(e->UhdmType());
    if (e->UhdmType() != uhdmconstant)
        return t + "@" + std::to_string(e->VpiLineNo()) + ":" +
               std::to_string(e->VpiColumnNo());
    auto* c = (const constant*)e;
    std::string d(c->VpiDecompile());
    if (d.size() > 12) d = d.substr(0, 6) + ".." + std::to_string(d.size()) + "ch";
    return "const{id=" + std::to_string(oid(c)) + " ct=" +
           std::to_string(c->VpiConstType()) + " sz=" +
           std::to_string(c->VpiSize()) + " dc=" + d + " @" +
           std::to_string(c->VpiLineNo()) + ":" +
           std::to_string(c->VpiColumnNo()) + "}";
}

static void sts(const std::string& tag, const typespec* t) {
    if (!t) { std::cout << tag << " <null ts>\n"; return; }
    if (t->UhdmType() != uhdmstruct_typespec) {
        std::cout << tag << " " << UhdmName(t->UhdmType()) << " id=" << oid(t)
                  << "\n";
        return;
    }
    auto* st = (const struct_typespec*)t;
    std::cout << tag << " struct_typespec id=" << oid(st) << " '" << st->VpiName()
              << "' @" << st->VpiLineNo() << ":" << st->VpiColumnNo() << "-"
              << st->VpiEndLineNo() << ":" << st->VpiEndColumnNo()
              << " inst=" << (st->Instance() ? std::string(st->Instance()->VpiName())
                                             : std::string("-"))
              << "\n";
    if (!st->Members()) return;
    for (auto* m : *st->Members())
        std::cout << "    ." << m->VpiName() << " mid=" << oid(m)
                  << " dflt=" << cst(m->Default_value()) << " actual=" << cst(m->Actual_value()) << "\n";
}

static const typespec* pts(const BaseClass* b) {
    if (!b || b->UhdmType() != uhdmparameter) return nullptr;
    auto* p = (const parameter*)b;
    auto* rt = p->Typespec();
    return rt ? rt->Actual_typespec() : nullptr;
}

static void doDesign(const char* tag, const design* d) {
    std::cout << "===== " << tag << "\n";
    auto pkgs = [&](const char* t, const VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (p->Typespecs())
                for (auto* t2 : *p->Typespecs())
                    sts(std::string(t) + " " + std::string(p->VpiName()) +
                            ".Typespecs",
                        t2);
            if (p->Parameters())
                for (auto* pa : *p->Parameters())
                    sts(std::string(t) + " " + std::string(p->VpiName()) + ".param " +
                            std::string(pa->VpiName()) + ".ts",
                        pts(pa));
        }
    };
    pkgs("defPkg", d->AllPackages());
    pkgs("topPkg", d->TopPackages());
    std::function<void(const char*, const module_inst*)> mod =
        [&](const char* t, const module_inst* m) {
            if (m->Parameters())
                for (auto* pa : *m->Parameters())
                    sts(std::string(t) + " " + std::string(m->VpiFullName()) +
                            ".param " + std::string(pa->VpiName()) + ".ts",
                        pts(pa));
            if (m->Param_assigns())
                for (auto* pv : *m->Param_assigns())
                    std::cout << t << " " << m->VpiFullName() << ".paramAssign rhs="
                              << cst(pv->Rhs()) << "\n";
            if (m->Modules())
                for (auto* sub : *m->Modules()) mod(t, sub);
        };
    if (d->AllModules())
        for (auto* m : *d->AllModules()) mod("defMod", m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) mod("topMod", m);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer sr;
        auto h = sr.Restore(std::filesystem::path(argv[i]));
        g_ids.clear();
        g_next = 0;
        doDesign(argv[i], (design*)((uhdm_handle*)h[0])->object);
    }
    return 0;
}
