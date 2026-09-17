// r11u64 SHAPE LISTER — every ASSIGNMENT-PATTERN operation (vpiOpType 75) in a
// database, keyed by the elaborated owner it hangs under, its CARRIER (parent
// kind + the carrier's own name: a cont_assign is named by its Lhs), and its
// written line:col.  The payload is the COMPARE-VISIBLE shape of the operand
// vector: per operand the UHDM kind, VpiSize, VpiConstType and VpiValue (and
// VpiName for a reference), which is exactly what constant::Compare and
// operation::Compare read.  DEF and ELAB rows are BOTH scored (the owner string
// distinguishes them), so neither can hide.  Encoding-aware by construction.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* b) {
    return b ? std::string(UhdmName(b->UhdmType())) : std::string("<none>");
}
static std::string ownerOf(const BaseClass* b) {
    for (const BaseClass* p = b ? b->VpiParent() : nullptr; p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmmodule_inst || t == uhdminterface_inst || t == uhdmgen_scope ||
            t == uhdmpackage || t == uhdmfunction || t == uhdmtask) {
            std::string f;
            if (auto* si = any_cast<const scope*>(p)) f = std::string(si->VpiFullName());
            if (f.empty()) f = std::string(p->VpiName());
            return kindName(p) + ":" + f;
        }
    }
    return "<noowner>";
}
// The carrier's own name, so two patterns under one module never collide.
static std::string carrierOf(const BaseClass* op) {
    const BaseClass* p = op ? op->VpiParent() : nullptr;
    if (!p) return "<nocarrier>";
    std::string n;
    if (p->UhdmType() == uhdmcont_assign) {
        auto* ca = (const cont_assign*)p;
        if (ca->Lhs()) n = std::string(ca->Lhs()->VpiName());
    } else {
        n = std::string(p->VpiName());
    }
    return kindName(p) + "(" + n + ")";
}
static std::string operandShape(const any* o) {
    if (!o) return "<null>";
    std::ostringstream v;
    v << kindName(o);
    if (auto* e = any_cast<const expr*>(o)) v << " sz=" << e->VpiSize();
    if (o->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)o;
        v << " ct=" << c->VpiConstType() << " val=" << c->VpiValue()
          << " dec=" << c->VpiDecompile();
    } else {
        std::string n(o->VpiName());
        if (!n.empty()) v << " name=" << n;
        if (o->UhdmType() == uhdmoperation)
            v << " op=" << ((const operation*)o)->VpiOpType();
        if (o->UhdmType() == uhdmtagged_pattern) v << " TAGGED";
    }
    return v.str();
}

int main(int argc, char** argv) {
    bool rows = false;
    std::vector<std::string> files;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--rows")
            rows = true;
        else
            files.push_back(a);
    }
    auto read = [&](const std::string& f, std::map<std::string, std::vector<std::string>>& out) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(f));
        (void)h;
        for (auto& [obj, id] : s.AllObjects()) {
            if (!obj || obj->UhdmType() != uhdmoperation) continue;
            auto* op = (const operation*)obj;
            if (op->VpiOpType() != vpiAssignmentPatternOp) continue;
            // REACHABILITY THROUGH THE COMPARED EDGE.  Both producers leave
            // orphan operations in the serializer (an op whose operand vector
            // was moved onto another op is still an AllObjects row); the judge
            // never sees them.  Score an op75 only when its CARRIER actually
            // points AT it, which is the same edge uhdm-cmp walks.
            {
                const BaseClass* p = op->VpiParent();
                if (p && p->UhdmType() == uhdmcont_assign &&
                    ((const cont_assign*)p)->Rhs() != (const expr*)op)
                    continue;
                if (p && p->UhdmType() == uhdmparam_assign &&
                    ((const param_assign*)p)->Rhs() != (const any*)op)
                    continue;
                if (p && p->UhdmType() == uhdmport &&
                    ((const port*)p)->High_conn() != (const expr*)op)
                    continue;
            }
            std::ostringstream k, v;
            k << ownerOf(op) << " | " << carrierOf(op) << " | " << op->VpiLineNo() << ":"
              << op->VpiColumnNo();
            const ref_typespec* rt = op->Typespec();
            const typespec* at = rt ? rt->Actual_typespec() : nullptr;
            v << "ts=" << (rt ? (at ? kindName(at) + ":" + std::string(at->VpiName())
                                    : std::string("ref:<null-actual>"))
                              : std::string("<none>"))
              << " opsz=" << op->VpiSize() << " ops=[";
            if (op->Operands()) {
                bool first = true;
                for (auto* o : *op->Operands()) {
                    if (!first) v << " ; ";
                    first = false;
                    v << operandShape(o);
                }
            }
            v << "]";
            // MULTISET, NOT A LAST-WRITER DICT, AND NOT AN ORDER-DEPENDENT
            // `#N` SUFFIX.  Two op75 can share a key (an instance array, a
            // def/elab pair under one owner); `Serializer::AllObjects` hands
            // them back in an order that is NOT stable across two `Restore`
            // calls of the SAME file, so a positional suffix made
            // golden-vs-golden read DIFF 2 on iface_zero_width_field.  Collect
            // the payloads per key and SORT them, so the join is order-blind.
            out[k.str()].push_back(v.str());
        }
    };
    std::map<std::string, std::vector<std::string>> A, B;
    read(files[0], A);
    if (files.size() > 1) read(files[1], B);
    for (auto& [k, v] : A) std::sort(v.begin(), v.end());
    for (auto& [k, v] : B) std::sort(v.begin(), v.end());
    auto join = [](const std::vector<std::string>& v) {
        std::string r;
        for (size_t i = 0; i < v.size(); i++) {
            if (i) r += "\n      + ";
            r += v[i];
        }
        return r;
    };
    if (files.size() == 1) {
        for (auto& [k, v] : A) std::cout << "SHAPE " << k << "  ->  " << join(v) << "\n";
        return 0;
    }
    int same = 0, diff = 0, onlyA = 0, onlyB = 0;
    for (auto& [k, v] : A) {
        auto it = B.find(k);
        if (it == B.end()) {
            onlyA++;
            if (rows) std::cout << "ONLY-GOLDEN " << k << "  ->  " << join(v) << "\n";
            continue;
        }
        if (it->second == v) {
            same++;
            if (rows) std::cout << "SAME        " << k << "  ->  " << join(v) << "\n";
        } else {
            diff++;
            std::cout << "DIFF        " << k << "\n   G: " << join(v) << "\n   O: "
                      << join(it->second) << "\n";
        }
    }
    for (auto& [k, v] : B)
        if (!A.count(k)) {
            onlyB++;
            std::cout << "ONLY-OURS   " << k << "  ->  " << join(v) << "\n";
        }
    std::cout << "ROWS " << A.size() << " SAME " << same << " DIFF " << diff
              << " ONLY-GOLDEN " << onlyA << " ONLY-OURS " << onlyB << "\n";
    return 0;
}
