// r10uvmdsg: design-level vector census + per-package vector census for every
// package object reachable from the design (AllPackages and TopPackages).
//   r10uvmdsg <a.uhdm> <b.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) + ")";
}

template <typename V>
static void cmpv(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) std::cout << "SIZE " << tag << ": " << sa << " vs " << sb << "\n";
    size_t n = sa < sb ? sa : sb;
    int shown = 0;
    for (size_t i = 0; i < n; i++) {
        std::string x = nm((*a)[i]), y = nm((*b)[i]);
        if (x != y && shown < 6) {
            std::cout << "  NAME " << tag << "[" << i << "] " << x << " | " << y << "\n";
            shown++;
        }
    }
    if (sa != sb) {
        const V* big = sa > sb ? a : b;
        const char* side = sa > sb ? "LHSONLY" : "RHSONLY";
        for (size_t i = n; i < (sa > sb ? sa : sb) && i < n + 10; i++)
            std::cout << "  " << side << " " << tag << "[" << i << "] " << nm((*big)[i]) << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    cmpv("AllPackages", da->AllPackages(), db->AllPackages());
    cmpv("TopPackages", da->TopPackages(), db->TopPackages());
    cmpv("AllClasses", da->AllClasses(), db->AllClasses());
    cmpv("AllModules", da->AllModules(), db->AllModules());
    cmpv("TopModules", da->TopModules(), db->TopModules());
    cmpv("Typespecs", da->Typespecs(), db->Typespecs());
    cmpv("Task_funcs", da->Task_funcs(), db->Task_funcs());
    auto pkgCensus = [&](const char* tag, const VectorOfpackage* pa,
                         const VectorOfpackage* pb) {
        if (!pa || !pb || pa->size() != pb->size()) return;
        for (size_t i = 0; i < pa->size(); i++) {
            auto* a = (*pa)[i];
            auto* b = (*pb)[i];
            std::string t = std::string(tag) + "[" + std::string(a->VpiName()) + "]";
            cmpv((t + ".Variables").c_str(), a->Variables(), b->Variables());
            cmpv((t + ".Nets").c_str(), a->Nets(), b->Nets());
            cmpv((t + ".Task_funcs").c_str(), a->Task_funcs(), b->Task_funcs());
            cmpv((t + ".Typespecs").c_str(), a->Typespecs(), b->Typespecs());
            cmpv((t + ".Parameters").c_str(), a->Parameters(), b->Parameters());
            cmpv((t + ".Param_assigns").c_str(), a->Param_assigns(), b->Param_assigns());
            cmpv((t + ".Class_defns").c_str(), a->Class_defns(), b->Class_defns());
        }
    };
    pkgCensus("AllPkg", da->AllPackages(), db->AllPackages());
    pkgCensus("TopPkg", da->TopPackages(), db->TopPackages());
    if (da->AllClasses() && db->AllClasses() &&
        da->AllClasses()->size() == db->AllClasses()->size()) {
        for (size_t i = 0; i < da->AllClasses()->size(); i++) {
            auto* ca = (*da->AllClasses())[i];
            auto* cb = (*db->AllClasses())[i];
            std::string t = "class " + std::string(ca->VpiName());
            cmpv((t + ".Variables").c_str(), ca->Variables(), cb->Variables());
            cmpv((t + ".Task_funcs").c_str(), ca->Task_funcs(), cb->Task_funcs());
            cmpv((t + ".Typespecs").c_str(), ca->Typespecs(), cb->Typespecs());
            cmpv((t + ".Parameters").c_str(), ca->Parameters(), cb->Parameters());
            cmpv((t + ".Deriveds").c_str(), ca->Deriveds(), cb->Deriveds());
            bool ea = ca->Extends() != nullptr, eb = cb->Extends() != nullptr;
            if (ea != eb) std::cout << "EXTENDS " << t << ": " << ea << " vs " << eb << "\n";
            if (ea && eb) {
                auto pr = [](const extends* e) -> std::string {
                    auto* r = e->Class_typespec();
                    if (!r) return "<no cts>";
                    auto* cd = ((class_typespec*)r)->Class_defn();
                    return std::string(r->VpiName()) + " defn=" +
                           (cd ? std::string(cd->VpiName()) : "<null>");
                };
                std::string xa = pr(ca->Extends()), xb = pr(cb->Extends());
                if (xa != xb) std::cout << "EXTCTS " << t << ": " << xa << " | " << xb << "\n";
            }
            // Class-level typespec-bearing members: every variable's typespec
            // actual, shallow.
            auto vts = [](const class_defn* c) {
                std::string out;
                if (c->Variables())
                    for (auto* v : *c->Variables()) {
                        auto* r = v->Typespec();
                        auto* at = r ? r->Actual_typespec() : nullptr;
                        out += std::string(v->VpiName()) + ":";
                        if (!at) { out += "<null>;"; continue; }
                        out += std::string(UhdmName(at->UhdmType())) + "(" +
                               std::string(at->VpiName()) + ")";
                        if (at->UhdmType() == uhdmclass_typespec) {
                            auto* cd = ((class_typespec*)at)->Class_defn();
                            out += "->" + (cd ? std::string(cd->VpiName()) : std::string("<null>"));
                        }
                        out += ";";
                    }
                return out;
            };
            std::string va = vts(ca), vb = vts(cb);
            if (va != vb) std::cout << "VARTS " << t << ":\n  L " << va << "\n  R " << vb << "\n";
        }
    }
    std::cout << "done\n";
    return 0;
}
