// r10earl120 — WHICH package object, and how many edges point at it.
//
// MEASUREMENT ONLY.
//
// A design holds each package TWICE: `design::AllPackages` (the unelaborated
// definition) and `design::TopPackages` (the elaborated instance).  Surelog's
// `reInstanceTypespec` (UhdmWriter.cpp:1109-1176, "Non-elaborated package
// typespec Instance relation need to point to non-elaborated package")
// deliberately re-points a typespec's `Instance` from one to the other, so a
// count of "edges to a package named X" is meaningless until the two objects
// are told apart.  This prints, per database: every `package` object of the
// wanted name, its identity, its AllPackages / TopPackages index, and the
// number of `typespec::Instance` edges that land on THAT object (and how many
// typespecs sit under it).
//
// build: g++ -O2 -std=c++17 pkgobj120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pkgobj120
// usage: pkgobj120 <db.uhdm> <tag> <pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}

int main(int argc, char** argv) {
    if (argc < 4) { fprintf(stderr, "usage: pkgobj120 <db> <tag> <pkgname>\n"); return 2; }
    const std::string tag(argv[2]), want(argv[3]);
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    std::map<const BaseClass*, std::string> role;
    if (d->AllPackages())
        for (size_t i = 0; i < d->AllPackages()->size(); i++)
            if (std::string(d->AllPackages()->at(i)->VpiName()) == want)
                role[d->AllPackages()->at(i)] += "AllPackages[" + std::to_string(i) + "] ";
    if (d->TopPackages())
        for (size_t i = 0; i < d->TopPackages()->size(); i++)
            if (std::string(d->TopPackages()->at(i)->VpiName()) == want)
                role[d->TopPackages()->at(i)] += "TopPackages[" + std::to_string(i) + "] ";

    std::map<const BaseClass*, size_t> edges;   // typespec::Instance -> pkg obj
    std::map<const BaseClass*, size_t> under;   // typespecs whose parent chain hits pkg
    for (const auto& [obj, id] : s.AllObjects()) {
        const typespec* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        const instance* i = t->Instance();
        if (i && std::string(i->VpiName()) == want) edges[(const BaseClass*)i]++;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent())
            if (kindOf(p) == "package" && std::string(p->VpiName()) == want) { under[p]++; break; }
    }
    // every package object of that name, whether or not it is in a vector
    std::map<const BaseClass*, int> objs;
    for (const auto& [obj, id] : s.AllObjects())
        if (kindOf(obj) == "package" && std::string(obj->VpiName()) == want) objs[obj] = 1;
    for (const auto& [o, e] : edges) objs[o] = 1;
    for (const auto& [o, e] : under) objs[o] = 1;

    printf("%s package objects named '%s': %zu\n", tag.c_str(), want.c_str(), objs.size());
    for (const auto& [o, x] : objs) {
        const package* p = (const package*)o;
        printf("%s   id=%-8u role='%s' params=%zu paramAssigns=%zu typespecs=%zu"
               " Instance=%s  <-typespec::Instance edges=%zu  typespecs-under=%zu\n",
               tag.c_str(), o->UhdmId(), role.count(o) ? role[o].c_str() : "(none)",
               p->Parameters() ? p->Parameters()->size() : 0,
               p->Param_assigns() ? p->Param_assigns()->size() : 0,
               p->Typespecs() ? p->Typespecs()->size() : 0,
               kindOf((const BaseClass*)p->Instance()).c_str(),
               edges.count(o) ? edges[o] : 0, under.count(o) ? under[o] : 0);
    }
    return 0;
}
