// r10uvm212 — THE class_typespec SPECIALIZATION-LISTING CENSUS.  MEASUREMENT
// ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `class_typespec` in a database, keyed so the two producers can be
// joined as MULTISETS (§9's census law: a last-writer dict drops rows).  The
// key deliberately EXCLUDES uhdmId and VpiFullName (never compared) and
// EXCLUDES the DEF/ELAB view (the two producers label it differently).  It
// carries exactly the fields `class_typespec::Compare` reads and this pass's
// question needs:
//
//   NAME   the class_typespec's own VpiName (a class-scope typedef is named
//          after the ALIAS, so `type_id` here)
//   PAR    the vpiParent's kind:name — the DECLARING scope
//   DEFN   Class_defn()'s VpiName — the GENERIC class the typedef targets
//   AL     Typedef_alias present (`typespec::Compare` walks it BEFORE Instance)
//   IN     Instance present
//   P/PA   Parameters() and Param_assigns(): `NUL` for a NULL VECTOR POINTER,
//          `n<k>` for a vector of size k.  THE WHOLE POINT: BaseClass.h:220
//          fires only for NULL-vs-non-empty, so `NUL` and `n0` are different
//          answers and must never be collapsed.
//   SPAN   line:col-line:col (reported, NOT in the key — Compare never reads it)
//
// usage: ct212cen <db.uhdm> [--full]
//        default prints only rows whose NAME or DEFN mentions a registry
//        typedef family; --full prints every class_typespec.
// build: g++ -O2 -std=c++17 ct212cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct212cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string vecCell(const std::vector<const BaseClass*>* v) {
    if (!v) return "NUL";
    char b[32];
    snprintf(b, sizeof b, "n%zu", v->size());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct212cen <db.uhdm> [--full]\n"); return 2; }
    const bool full = (argc > 2 && strcmp(argv[2], "--full") == 0);
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::map<std::string, int> rows;
    size_t total = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        ++total;
        const class_typespec* ct = (const class_typespec*)o;
        const BaseClass* p = ct->VpiParent();
        std::string parent = p ? (std::string(UhdmName(p->UhdmType())) + ":" +
                                  std::string(p->VpiName()))
                               : std::string("<none>");
        std::string defn = ct->Class_defn()
                               ? std::string(ct->Class_defn()->VpiName())
                               : std::string("<none>");
        char b[1400];
        snprintf(b, sizeof b,
                 "NAME=%-24s PAR=%-46s DEFN=%-40s AL=%d IN=%d P=%-5s PA=%-5s",
                 std::string(ct->VpiName()).c_str(), parent.c_str(), defn.c_str(),
                 ct->Typedef_alias() ? 1 : 0, ct->Instance() ? 1 : 0,
                 vecCell((const std::vector<const BaseClass*>*)ct->Parameters()).c_str(),
                 vecCell((const std::vector<const BaseClass*>*)ct->Param_assigns()).c_str());
        std::string key = b;
        if (!full) {
            const std::string nm(ct->VpiName());
            if (nm != "type_id" && nm != "this_type" && nm != "super_type" &&
                defn.find("registry") == std::string::npos)
                continue;
        }
        rows[key]++;
    }
    printf("# class_typespec total=%zu  distinct rows printed=%zu\n", total, rows.size());
    for (auto& kv : rows) printf("x%-4d %s\n", kv.second, kv.first.c_str());
    return 0;
}
