// r10rgg4hp: hier_path shape census — every path element with its name,
// fullname, span and index/base/width children, plus the parent chain.  Used to
// copy the golden's shape for a DOTTED port-connection actual in a def-view
// gen-block ref_module (`register_if[3].value[16+:1]`).
//   r10rgg4hp <file.uhdm> [fullname-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo()) + "-" +
                    std::to_string(o->VpiEndLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo() ? o->VpiEndColumnNo() : 0);
    switch (o->UhdmType()) {
#define F(T) \
    case uhdm##T: s += " full='" + std::string(((const T*)o)->VpiFullName()) + "'"; break;
        F(hier_path)
        F(ref_obj)
        F(bit_select)
        F(part_select)
        F(indexed_part_select)
        F(var_select)
#undef F
        default: break;
    }
    if (o->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)o;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" +
             std::string(c->VpiDecompile()) + "'}";
    }
    return s;
}

static std::string chain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p; p = p->VpiParent())
        s += " <- " + std::string(UhdmName(p->UhdmType())) + "(" +
             std::string(p->VpiName()) + ")";
    return s;
}

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 2 ? argv[2] : "";
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        auto* h = (const hier_path*)o;
        std::string full(h->VpiFullName()), name(h->VpiName());
        if (!want.empty() && full.find(want) == std::string::npos &&
            name.find(want) == std::string::npos)
            continue;
        std::string r = nm(h) + chain(h) + "\n";
        if (auto* es = h->Path_elems())
            for (auto* e : *es) {
                r += "    elem " + nm(e) + " parent=" +
                     (e->VpiParent()
                          ? std::string(UhdmName(e->VpiParent()->UhdmType()))
                          : std::string("<null>")) +
                     "\n";
                if (e->UhdmType() == uhdmbit_select)
                    r += "        index " + nm(((const bit_select*)e)->VpiIndex()) +
                         "\n";
                if (e->UhdmType() == uhdmindexed_part_select) {
                    auto* ip = (const indexed_part_select*)e;
                    r += "        base " + nm(ip->Base_expr()) + " width " +
                         nm(ip->Width_expr()) +
                         " type=" + std::to_string(ip->VpiIndexedPartSelectType()) +
                         " constSel=" + std::to_string(ip->VpiConstantSelect()) +
                         "\n";
                }
                if (e->UhdmType() == uhdmpart_select) {
                    auto* ps = (const part_select*)e;
                    r += "        L " + nm(ps->Left_range()) + " R " +
                         nm(ps->Right_range()) + "\n";
                }
            }
        rows.push_back(r);
    }
    std::sort(rows.begin(), rows.end());
    rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
    std::cout << "COUNT " << rows.size() << " unique shapes\n";
    for (auto& r : rows) std::cout << r;
    return 0;
}
