// r10sd4 — THE DECODE.  Everything both sides emit at ONE span key, with the
// `vpiInstance` value and the owner chain of every copy.
//
// The head's owner pair is now named by `ct4bt` (a gdb watchpoint on
// `CompareContext::m_failedRhs`, which is the only thing in this campaign that
// READS the caller instead of inferring it):
//
//   SeqDriver     golden `bit_typespec@26:1-26:4`      Instance NULL
//                 ours   `bit_typespec@26:1-26:4`      Instance TOP:uvm_pkg
//                 owner  `bit_var(uvm_start_uvm_declarations)@26:5`
//                 inside `class_defn(adpcm_seq_item)` reached through
//                        `class_typespec(type_id)@440:12 -> type_parameter(T)`
//   BuildUVMPkg   golden `struct_typespec(m_inst_typename_alias_t)@11964:11`
//                 ours   same key, Instance TOP:uvm_pkg
//                 owner  `struct_var@11973:38` inside
//                        `class_defn(uvm_default_factory)`
//
// The question a FIX needs answered is not "is golden null here" — that is
// measured — but "is golden null on THIS OBJECT, or does golden emit a DIFFERENT
// COPY per context and null only the class-member one?".  Those are different
// patches, and a census that keeps one value per key cannot tell them apart
// (sd2 §4.5).  This tool prints the whole MULTISET at a key, per side, with each
// copy's owner chain, so the answer is read rather than assumed.
//
// build: g++ -O2 -std=c++17 ct4key.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4key
// usage: ct4key <golden.uhdm> <ours.uhdm> <substring-of-key> [more keys...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}
static const instance* instOf(const BaseClass* p) {
    if (auto* t = any_cast<const typespec*>(p)) return t->Instance();
    if (auto* v = any_cast<const variables*>(p)) return v->Instance();
    if (auto* f = any_cast<const task_func*>(p)) return f->Instance();
    if (auto* q = any_cast<const ports*>(p)) return q->Instance();
    if (auto* cb = any_cast<const clocking_block*>(p)) return cb->Instance();
    if (auto* in = any_cast<const instance*>(p)) return in->Instance();
    return nullptr;
}
static std::map<const BaseClass*, std::string> pkgStateOf(design* d) {
    std::map<const BaseClass*, std::string> m;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) m[p] = "ALL:" + std::string(p->VpiName());
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) m[p] = "TOP:" + std::string(p->VpiName());
    return m;
}
static std::string classify(const std::map<const BaseClass*, std::string>& ps,
                            const instance* v) {
    if (!v) return "<null>";
    auto it = ps.find((const BaseClass*)v);
    if (it != ps.end()) return it->second;
    return "OTHER:" + std::string(UhdmName(v->UhdmType())) + "(" +
           std::string(v->VpiName()) + ")";
}
static std::string chain(const BaseClass* p) {
    std::ostringstream o;
    const BaseClass* q = p->VpiParent();
    for (int d = 0; d < 6 && q; d++) { o << " <- " << ident(q); q = q->VpiParent(); }
    if (o.str().empty()) o << " <- <no VpiParent>";
    return o.str();
}

static void dumpKey(const char* tag, Serializer& s, design* d,
                    const std::string& want) {
    auto ps = pkgStateOf(d);
    std::cout << "\n--- " << tag << "  key~=" << want << "\n";
    std::map<std::string, int> hist;
    int n = 0;
    for (const auto& [p, i] : s.AllObjects()) {
        if (!p) continue;
        std::string id = ident(p);
        if (id.find(want) == std::string::npos) continue;
        std::string st = classify(ps, instOf(p));
        hist[st]++;
        if (n++ < 24)
            std::cout << "    " << id << "  inst=" << st << chain(p) << "\n";
    }
    std::cout << "    TOTAL " << n << " copies:";
    for (auto& [k, c] : hist) std::cout << "  " << k << "=" << c;
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: ct4key <golden> <ours> <key-substring> ...\n";
        return 2;
    }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;
    for (int i = 3; i < argc; i++) {
        dumpKey("GOLDEN", sa, DA, argv[i]);
        dumpKey("OURS", sb, DB, argv[i]);
    }
    return 0;
}
