// r10uvm3id: pointer-identity + instance-stamp probe across two packages of
// ONE database.  Answers: does an importing package SHARE the home package's
// listed objects, or hold clones?  And what does each listed object's typespec
// report as vpiInstance?
//   r10uvm3id <file.uhdm> <homePkg> <importerPkg>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static const package* find(design* d, const std::string& n, bool top) {
    auto* l = top ? d->TopPackages() : d->AllPackages();
    if (l)
        for (auto* p : *l)
            if (p->VpiName() == n) return p;
    return nullptr;
}

template <typename V>
static void ident(const char* tag, const V* a, const V* b) {
    if (!a || !b) { std::cout << tag << ": null " << (void*)a << " " << (void*)b << "\n"; return; }
    std::set<const void*> sa;
    for (auto* e : *a) sa.insert((const void*)e);
    long shared = 0;
    for (auto* e : *b) if (sa.count((const void*)e)) shared++;
    std::cout << tag << ": sizes " << a->size() << "/" << b->size()
              << " sharedPtrs=" << shared << "\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    for (int top = 0; top < 2; top++) {
        auto* home = find(d, argv[2], top);
        auto* imp = find(d, argv[3], top);
        const char* v = top ? "TOP" : "ALL";
        if (!home || !imp) { std::cout << v << ": missing\n"; continue; }
        std::cout << v << " home=" << (const void*)home << " imp=" << (const void*)imp << "\n";
        ident((std::string(v) + ".Task_funcs").c_str(), home->Task_funcs(), imp->Task_funcs());
        ident((std::string(v) + ".Variables").c_str(), home->Variables(), imp->Variables());
        ident((std::string(v) + ".Typespecs").c_str(), home->Typespecs(), imp->Typespecs());
        ident((std::string(v) + ".Parameters").c_str(), home->Parameters(), imp->Parameters());
        ident((std::string(v) + ".Param_assigns").c_str(), home->Param_assigns(), imp->Param_assigns());
    }
    // cross-view: home ALL vs importer TOP etc.
    auto* hAll = find(d, argv[2], false);
    auto* iTop = find(d, argv[3], true);
    auto* iAll = find(d, argv[3], false);
    if (hAll && iTop) ident("homeALL x impTOP.Task_funcs", hAll->Task_funcs(), iTop->Task_funcs());
    if (iAll && iTop) ident("impALL x impTOP.Task_funcs", iAll->Task_funcs(), iTop->Task_funcs());
    if (iAll && iTop) ident("impALL x impTOP.Typespecs", iAll->Typespecs(), iTop->Typespecs());
    // instance stamps on the home package's own variables
    if (hAll && hAll->Variables()) {
        long i = 0;
        for (auto* var : *hAll->Variables()) {
            if (i++ > 4) break;
            const typespec* ts = nullptr;
            if (auto* rt = var->Typespec()) ts = rt->Actual_typespec();
            std::cout << "homeALL.Var[" << (i - 1) << "] '" << var->VpiName()
                      << "' parent=" << (var->VpiParent() ? var->VpiParent()->VpiName() : "<null>")
                      << " ts=" << (ts ? UhdmName(ts->UhdmType()) : "<null>")
                      << " tsPtr=" << (const void*)ts
                      << " tsInst=" << (ts && ts->Instance() ? ts->Instance()->VpiName() : "<null>")
                      << "\n";
        }
    }
    if (iAll && iAll->Variables()) {
        long i = 0;
        for (auto* var : *iAll->Variables()) {
            if (i++ > 4) break;
            const typespec* ts = nullptr;
            if (auto* rt = var->Typespec()) ts = rt->Actual_typespec();
            std::cout << "impALL.Var[" << (i - 1) << "] '" << var->VpiName()
                      << "' parent=" << (var->VpiParent() ? var->VpiParent()->VpiName() : "<null>")
                      << " ts=" << (ts ? UhdmName(ts->UhdmType()) : "<null>")
                      << " tsPtr=" << (const void*)ts
                      << " tsInst=" << (ts && ts->Instance() ? ts->Instance()->VpiName() : "<null>")
                      << "\n";
        }
    }
    return 0;
}
