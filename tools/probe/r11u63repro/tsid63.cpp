// r11u63: identity of the ref_typespec / Actual_typespec a hier_path carries,
// and of every typespec in the database, so SHARE vs CLONE is provable.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size();
    ids[p] = n;
    return n;
}
static std::string nm(const BaseClass* b) {
    if (!b) return "<null>";
    std::string s(UhdmName(b->UhdmType()));
    s += "(";
    s += b->VpiName();
    s += ")";
    return s;
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    // stable ids in serializer order
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        idOf((const void*)obj);
    }
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        UHDM_OBJECT_TYPE t = obj->UhdmType();
        if (t == uhdmhier_path) {
            auto* hp = (const hier_path*)obj;
            const ref_typespec* rt = hp->Typespec();
            std::cout << "HIER_PATH #" << idOf(hp) << " name=" << hp->VpiName()
                      << " size=" << hp->VpiSize()
                      << " parent=" << nm(hp->VpiParent())
                      << " parent#" << idOf(hp->VpiParent())
                      << " ref_ts#" << idOf(rt)
                      << " actual#" << idOf(rt ? (const void*)rt->Actual_typespec() : nullptr)
                      << " actual=" << (rt && rt->Actual_typespec() ? nm(rt->Actual_typespec()) : "<null>")
                      << " rtFull=" << (rt ? rt->VpiFullName() : "")
                      << " rootval=" << nm(hp->Root_value()) << " rootval#" << idOf(hp->Root_value())
                      << " elems=" << (hp->Path_elems() ? hp->Path_elems()->size() : 0)
                      << "\n";
        } else if (t == uhdmstruct_typespec || t == uhdmlogic_typespec ||
                   t == uhdmint_typespec || t == uhdmunion_typespec ||
                   t == uhdmarray_typespec || t == uhdmpacked_array_typespec ||
                   t == uhdmenum_typespec || t == uhdmbit_typespec ||
                   t == uhdminteger_typespec) {
            auto* ts = (const typespec*)obj;
            std::cout << "TYPESPEC #" << idOf(ts) << " " << UhdmName(t)
                      << " name=" << ts->VpiName()
                      << " parent=" << nm(ts->VpiParent()) << " parent#"
                      << idOf(ts->VpiParent()) << " line=" << ts->VpiLineNo()
                      << ":" << ts->VpiColumnNo() << "\n";
        } else if (t == uhdmref_typespec) {
            auto* rt = (const ref_typespec*)obj;
            std::cout << "REF_TS #" << idOf(rt) << " full=" << rt->VpiFullName()
                      << " parent=" << nm(rt->VpiParent()) << " parent#"
                      << idOf(rt->VpiParent()) << " actual#"
                      << idOf((const void*)rt->Actual_typespec()) << " actual="
                      << (rt->Actual_typespec() ? nm(rt->Actual_typespec()) : "<null>")
                      << "\n";
        }
    }
    return 0;
}
