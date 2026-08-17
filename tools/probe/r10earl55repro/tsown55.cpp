// r10earl55 — TYPESPEC OWNER PROBE.
//
// MEASUREMENT-ONLY.  Answers ONE question the ladder cannot: for a LOC-LESS
// object that has NO `vpiParent` (`KINDP=<root>` on the ladder), WHO POINTS AT
// IT?  A typespec reached only through a field of some other object is
// invisible to a parent walk, and guessing its owner is exactly the mistake
// this pass had to avoid.
//
// It builds the same outgoing-edge table the ladder uses (`ctfields.inc`,
// generated from UHDM's own `Compare` bodies) and inverts it, then walks the
// referrer chain UP from the named object, printing (field, owner) at every
// level with the owner's own span/name/parent chain.
//
// Every index is built in **UhdmId order**, never `AllObjects()` address
// order: the campaign's standing law is that address order must never reach a
// result.
//
// build:
//   g++ -O2 -std=c++17 tsown55.cpp -I ~/.local/include -I ../r10ladder1repro \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o tsown55
// usage: tsown55 <db.uhdm> <UhdmId> [--depth=N] [--kind=<kindname>] [--all]
//   --kind=K  instead of one id, report EVERY object of kind K (loc-less only
//             unless --withloc), with its referrer field — the census view.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <variant>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field {
    const char* name;
    int sel;
    FKind kind;
};
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
    char b[192];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = UhdmName(o->UhdmType());
    if (!o->VpiName().empty()) s += "(" + std::string(o->VpiName()) + ")";
    { auto pv = o->GetVpiPropertyValue(vpiFullName);
      if (std::holds_alternative<const char*>(pv)) {
          const char* fn = std::get<const char*>(pv);
          if (fn && *fn && std::string(fn) != std::string(o->VpiName()))
              s += "{" + std::string(fn) + "}";
      } }
    return s + "@" + spanOf(o) + "#" + std::to_string(o->UhdmId());
}
static std::string chainOf(const BaseClass* o, int n = 8) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? " < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}

// hand-written fallbacks for the fields UHDM exposes no selector for; only the
// ones this probe needs (kept deliberately small — an absent edge is printed
// as absent, never silently dropped, because the referrer set is the answer).
static bool fallbackVecPtr(const BaseClass* o, const char* f,
                           std::vector<const BaseClass*>& out) {
    auto push = [&](auto* v) {
        if (!v) return false;
        for (auto* e : *v) out.push_back(e);
        return true;
    };
    if (auto* d = any_cast<const design*>((const any*)o)) {
        if (!strcmp(f, "AllModules")) return push(d->AllModules());
        if (!strcmp(f, "TopModules")) return push(d->TopModules());
        if (!strcmp(f, "AllPackages")) return push(d->AllPackages());
        if (!strcmp(f, "TopPackages")) return push(d->TopPackages());
        if (!strcmp(f, "AllClasses")) return push(d->AllClasses());
        if (!strcmp(f, "AllInterfaces")) return push(d->AllInterfaces());
        if (!strcmp(f, "AllPrograms")) return push(d->AllPrograms());
        if (!strcmp(f, "AllUdps")) return push(d->AllUdps());
        if (!strcmp(f, "Typespecs")) return push(d->Typespecs());
        if (!strcmp(f, "Let_decls")) return push(d->Let_decls());
        if (!strcmp(f, "Task_funcs")) return push(d->Task_funcs());
        if (!strcmp(f, "Parameters")) return push(d->Parameters());
        if (!strcmp(f, "Param_assigns")) return push(d->Param_assigns());
    }
    return false;
}
static bool fallbackRel1(const BaseClass* o, const char* f, const BaseClass*& out) {
    if (auto* tm = any_cast<const typespec_member*>((const any*)o))
        if (!strcmp(f, "Default_value")) {
            out = tm->Default_value();
            return true;
        }
    return false;
}
static void edgesOf(const BaseClass* o,
                    std::vector<std::pair<const char*, const BaseClass*>>& out) {
    auto it = kFields.find(UhdmName(o->UhdmType()));
    if (it == kFields.end()) return;
    for (const Field& f : it->second) {
        if (f.kind == F_REL1) {
            const BaseClass* t = nullptr;
            if (f.sel) t = std::get<0>(o->GetByVpiType(f.sel));
            else if (!fallbackRel1(o, f.name, t)) continue;
            if (t) out.push_back({f.name, t});
        } else if (f.kind == F_RELV) {
            if (f.sel) {
                if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
                    for (auto* e : *v)
                        if (e) out.push_back({f.name, e});
            } else {
                std::vector<const BaseClass*> tmp;
                if (fallbackVecPtr(o, f.name, tmp))
                    for (auto* e : tmp)
                        if (e) out.push_back({f.name, e});
            }
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: tsown55 <db.uhdm> <UhdmId|--kind=K> [--depth=N] [--withloc] [--max=N]\n");
        return 2;
    }
    std::string dbp = argv[1];
    unsigned wantId = 0;
    std::string wantKind;
    int depth = 4, maxRep = 40;
    bool withloc = false;
    for (int i = 2; i < argc; i++) {
        std::string s = argv[i];
        if (s.rfind("--kind=", 0) == 0) wantKind = s.substr(7);
        else if (s.rfind("--depth=", 0) == 0) depth = atoi(s.c_str() + 8);
        else if (s.rfind("--max=", 0) == 0) maxRep = atoi(s.c_str() + 6);
        else if (s == "--withloc") withloc = true;
        else wantId = strtoul(s.c_str(), nullptr, 10);
    }
    Serializer s;
    const std::vector<vpiHandle>& restored = s.Restore(dbp);
    if (restored.empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", dbp.c_str());
        return 3;
    }
    // UhdmId order, never address order.
    std::vector<const BaseClass*> all;
    for (const auto& [obj, id] : s.AllObjects())
        if (obj) all.push_back(obj);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    printf("# tsown55 db=%s objs=%zu\n", base(dbp).c_str(), all.size());

    std::unordered_multimap<const BaseClass*, std::pair<const BaseClass*, const char*>> ref;
    std::vector<std::pair<const char*, const BaseClass*>> e;
    for (const BaseClass* o : all) {
        e.clear();
        edgesOf(o, e);
        for (auto& [f, t] : e) ref.emplace(t, std::make_pair(o, f));
    }

    auto report = [&](const BaseClass* t) {
        printf("OBJ %s\n", ident(t).c_str());
        printf("  PARENTCHAIN %s\n", chainOf(t).c_str());
        std::vector<const BaseClass*> level{t};
        std::unordered_set<const BaseClass*> seen{t};
        for (int d = 0; d < depth && !level.empty(); d++) {
            std::vector<const BaseClass*> next;
            int n = 0;
            for (const BaseClass* cur : level) {
                auto rg = ref.equal_range(cur);
                for (auto it = rg.first; it != rg.second; ++it) {
                    if (++n > maxRep) break;
                    printf("  REF[d%d] %-24s <- %s\n", d, it->second.second,
                           ident(it->second.first).c_str());
                    printf("          owner-chain %s\n", chainOf(it->second.first, 6).c_str());
                    if (seen.insert(it->second.first).second) next.push_back(it->second.first);
                }
            }
            if (n == 0) printf("  REF[d%d] <NONE — nothing in the database points at it>\n", d);
            level = next;
        }
    };

    if (!wantKind.empty()) {
        int n = 0;
        std::map<std::string, int> byField;
        for (const BaseClass* o : all) {
            if (UhdmName(o->UhdmType()) != wantKind) continue;
            bool locless = o->VpiLineNo() == 0 && o->VpiColumnNo() == 0;
            if (!withloc && !locless) continue;
            auto rg = ref.equal_range(o);
            std::string k = "<no-referrer>";
            if (rg.first != rg.second)
                k = std::string(UhdmName(rg.first->second.first->UhdmType())) + "." +
                    rg.first->second.second;
            byField[k]++;
            if (++n <= maxRep) report(o);
        }
        printf("KIND %s locless=%s count=%d\n", wantKind.c_str(), withloc ? "any" : "yes", n);
        for (auto& [k, c] : byField) printf("  BY-REFERRER %-46s %d\n", k.c_str(), c);
        return 0;
    }
    for (const BaseClass* o : all)
        if (o->UhdmId() == wantId) report(o);
    return 0;
}
