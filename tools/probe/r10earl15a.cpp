// r10earl15a — EVERY typespec in a database with its Instance() back-edge,
// projected onto (kind, name, file:line:col) -> (instance kind, instance name,
// instance def, vpiTop).  § pkgTypespecInstanceIsTop is a back-edge bug and
// UhdmListener never follows a back-edge, so no listener probe can see it; the
// serializer's object table can.  Print both sides and diff the projection to
// find WHICH typespec shape points at the wrong package copy.
// Build: bash tools/probe/r10earl15build.sh r10earl15a
// Usage: r10earl15a <a.uhdm> [b.uhdm]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static const instance* tsInst(const typespec* t) {
    if (auto* x = any_cast<const int_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const integer_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const struct_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const enum_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const union_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const byte_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const short_int_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const long_int_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const string_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const class_typespec*>((const any*)t))
        return x->Instance();
    return nullptr;
}

static void dumpOne(const char* path, const char* tag) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) {
        std::cout << tag << " restore-failed\n";
        return;
    }
    std::map<std::string, int> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        (void)id;
        if (!obj)
            continue;
        auto* t = any_cast<const typespec*>((const any*)obj);
        if (!t)
            continue;
        const instance* in = tsInst(t);
        std::string k = std::string(UhdmName(t->UhdmType())) + " '" +
                        std::string(t->VpiName()) + "' @" +
                        base(t->VpiFile()) + ":" +
                        std::to_string(t->VpiLineNo()) + ":" +
                        std::to_string(t->VpiColumnNo()) + " -> ";
        if (!in)
            k += "<null>";
        else
            k += std::string(UhdmName(in->UhdmType())) + " '" +
                 std::string(in->VpiName()) + "' def='" +
                 std::string(in->VpiDefName()) + "' top=" +
                 std::to_string((int)in->VpiTop());
        rows[k]++;
    }
    for (auto& [k, n] : rows)
        std::cout << tag << " x" << n << "  " << k << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2)
        return 1;
    dumpOne(argv[1], "A");
    if (argc > 2)
        dumpOne(argv[2], "B");
    return 0;
}
