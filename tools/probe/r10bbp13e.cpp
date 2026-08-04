// r10bbp13e: side-by-side typespec-Instance drill for the Parameters and
// Param_assigns slots of one design view.  For each requested index it prints
// the parameter's name, its ref_typespec fullname, the actual typespec's kind /
// span, and the actual's vpiInstance on BOTH sides -- the exact chain
// typespec::Compare walks when the whole-design cmp reports
// `failLhs package(<pkg>) failRhs <null>`.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13e.cpp -o /tmp/r10bbp13eq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13eq <golden.uhdm> <ours.uhdm> P|A <idx>[,<idx>...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    return std::string(UhdmName(n->UhdmType())) + " id" +
           std::to_string(n->UhdmId()) + " '" + std::string(n->VpiName()) +
           "' " + std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

static void chain(const char* tag, const any* o) {
    if (!o) { std::cout << "   " << tag << " <null>\n"; return; }
    const parameter* p = nullptr;
    if (o->UhdmType() == uhdmparameter) p = (const parameter*)o;
    std::cout << "   " << tag << " " << at(o);
    if (p) std::cout << " imported='" << p->VpiImported() << "'";
    std::cout << "\n";
    if (!p) return;
    const ref_typespec* rt = p->Typespec();
    if (!rt) { std::cout << "      ts=<null>\n"; return; }
    const typespec* a = rt->Actual_typespec();
    std::cout << "      rt id" << rt->UhdmId() << " full='" << rt->VpiFullName()
              << "' -> " << at(a);
    if (a) std::cout << "\n      actual.Instance=" << at(a->Instance())
                     << "  actual.parent=" << at(a->VpiParent());
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 5) return 1;
    bool doPa = std::string(argv[3]) == "A";
    std::vector<int> idx;
    {
        std::string in(argv[4]);
        size_t p = 0;
        while (p < in.size()) {
            size_t q = in.find(',', p);
            if (q == std::string::npos) q = in.size();
            idx.push_back(atoi(in.substr(p, q - p).c_str()));
            p = q + 1;
        }
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const scope* va = (const scope*)(*da->TopModules())[0];
    const scope* vb = (const scope*)(*db->TopModules())[0];
    for (int i : idx) {
        std::cout << "== " << (doPa ? "Param_assigns[" : "Parameters[") << i
                  << "]\n";
        const any *oa = nullptr, *ob = nullptr;
        if (doPa) {
            if (va->Param_assigns() && i < (int)va->Param_assigns()->size())
                oa = (*va->Param_assigns())[i]->Lhs();
            if (vb->Param_assigns() && i < (int)vb->Param_assigns()->size())
                ob = (*vb->Param_assigns())[i]->Lhs();
        }
        else {
            if (va->Parameters() && i < (int)va->Parameters()->size())
                oa = (*va->Parameters())[i];
            if (vb->Parameters() && i < (int)vb->Parameters()->size())
                ob = (*vb->Parameters())[i];
        }
        chain("G", oa);
        chain("S", ob);
    }
    return 0;
}
