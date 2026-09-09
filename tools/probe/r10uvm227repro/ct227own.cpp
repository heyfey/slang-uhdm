// r10uvm227 — THE OWNER-FINDER for the FREE-FUNCTION LOCAL BINDING head, plus
// the TOPOLOGY reader for the function the process calls.
// MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head r10uvm226 handed on is the SINGULAR SafeCompare signature with the
// VALUE on the GOLDEN side (`BaseClass.h:191-193`): golden's value is a
// `class_var cs`, ours is `<null>`.  So the failing EDGE lives in GOLDEN's
// database and the scan runs golden-first: enumerate every edge of every
// golden object that lands on the head, print the owner, then print OUR
// counterpart's SAME edge (matched by face = kind+name+span, and by the
// ancestor-face path so a clone and its home are not confused).
// `GetByVpiType` is the generated, kind-agnostic edge accessor, so no field is
// named by hand and none can be missed by omission.
//
// STEP 2 answers the TOPOLOGY question this pass must settle first: it lists
// EVERY `function`/`task` object whose name matches the argument, on both
// sides, with its parent chain — so "package object vs clone vs listing" is
// read off the databases, not guessed — and for each one, its io_decls,
// Variables(), and every reference in its body with the object each reference
// binds to (or BARE).
//
// STEP 3 lists every `func_call`/`method_func_call` whose callee name matches,
// on both sides, with the identity of the callee it points at.
//
// build: g++ -O2 -std=c++17 ct227own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct227own
// usage: ct227own <golden.uhdm> <ours.uhdm> [<function name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64;
         p = p->VpiParent(), ++guard) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    return any_cast<const ref_obj*>(o) || any_cast<const ref_var*>(o);
}
// Does `o` sit inside a function/task whose name contains `want`?
static const BaseClass* enclosingFn(const BaseClass* o, const char* want) {
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64;
         p = p->VpiParent(), ++guard)
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
            const std::string n(p->VpiName());
            if (n.find(want) != std::string::npos) return p;
            return nullptr;
        }
    return nullptr;
}

static void dumpFn(const BaseClass* fnb) {
    const task_func* tf = any_cast<const task_func*>(fnb);
    if (!tf) return;
    printf("      parent chain:");
    int guard = 0;
    for (const BaseClass* p = fnb->VpiParent(); p && guard < 12;
         p = p->VpiParent(), ++guard)
        printf(" < %s", ident(p).c_str());
    printf("\n");
    if (auto* io = tf->Io_decls()) {
        printf("      io_decls %zu:", io->size());
        for (auto* d : *io) printf(" %s", std::string(d->VpiName()).c_str());
        printf("\n");
    } else
        printf("      io_decls <null>\n");
    if (auto* v = tf->Variables()) {
        printf("      Variables %zu:\n", v->size());
        for (auto* d : *v) printf("        %s\n", ident(d).c_str());
    } else
        printf("      Variables <null>\n");
    printf("      Stmt %s\n", ident(tf->Stmt()).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct227own <golden> <ours> [fn-name-substring]\n");
        return 2;
    }
    const char* fnWant = argc > 3 ? argv[3] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    printf("# ct227own MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    printf("# GOLDEN %s\n# OURS   %s\n", argv[1], argv[2]);
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    // The design-level walk names the CONTAINER (the vector overload sets both
    // sides), so when an interface name is given the head is re-taken on the
    // `Process()` ELEMENT pair in a FRESH context, exactly as ct226inner does —
    // that is the object pair the judge actually stopped on.
    if (const char* ifn = getenv("CT227_IFACE")) {
        const interface_inst* gi = nullptr;
        const interface_inst* oi = nullptr;
        for (auto& kv : sg.AllObjects())
            if (kv.first && kv.first->UhdmType() == uhdminterface_inst &&
                ((const interface_inst*)kv.first)->VpiFullName() == ifn)
                gi = (const interface_inst*)kv.first;
        for (auto& kv : so.AllObjects())
            if (kv.first && kv.first->UhdmType() == uhdminterface_inst &&
                ((const interface_inst*)kv.first)->VpiFullName() == ifn)
                oi = (const interface_inst*)kv.first;
        printf("CT227_IFACE=%s golden=%d ours=%d\n", ifn, gi != nullptr, oi != nullptr);
        if (gi && oi && gi->Process() && oi->Process()) {
            auto* gv = gi->Process();
            auto* ov = oi->Process();
            size_t n = gv->size() < ov->size() ? gv->size() : ov->size();
            for (size_t i = 0; i < n; i++) {
                CompareContext c2;
                int r2 = gv->at(i)->Compare(ov->at(i), &c2);
                printf("PROCESS[%zu] r=%d\n", i, r2);
                if (r2) { HL = c2.m_failedLhs; HR = c2.m_failedRhs; break; }
            }
        }
    }
    printf("HEAD LHS(golden) = %s\n", ident(HL).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(HR).c_str());

    // ---- STEP 1 — GOLDEN-FIRST OWNER SCAN ------------------------------
    if (HL && !HR) {
        printf("HEAD LHS parent chain:\n");
        int guard = 0;
        for (const BaseClass* p = HL->VpiParent(); p && guard < 32;
             p = p->VpiParent(), ++guard)
            printf("    < %s\n", ident(p).c_str());
        printf("OWNER SCAN — every GOLDEN edge that lands on the head, and ours:\n");
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                int idx = -1;
                if (one == HL) idx = -2;
                if (vec)
                    for (size_t i = 0; i < vec->size(); ++i)
                        if (vec->at(i) == HL) idx = (int)i;
                if (idx == -1) continue;
                printf("  golden %s\n      edge vpiType=%d %s\n", ident(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) + ")").c_str());
                printf("      golden owner parents:");
                int g2 = 0;
                for (const BaseClass* p = X->VpiParent(); p && g2 < 8;
                     p = p->VpiParent(), ++g2)
                    printf(" < %s", ident(p).c_str());
                printf("\n");
                int nm = 0;
                for (auto& kv2 : so.AllObjects()) {
                    const BaseClass* Y = kv2.first;
                    if (!Y || !sameFace(X, Y)) continue;
                    const bool samePath = parentPath(X) == parentPath(Y);
                    ++nm;
                    auto tu2 = Y->GetByVpiType(t);
                    const BaseClass* o2 = std::get<0>(tu2);
                    const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                    if (idx == -2)
                        printf("      ours%s %s -> singular %s\n",
                               samePath ? "" : "(OTHER PATH)", ident(Y).c_str(),
                               ident(o2).c_str());
                    else
                        printf("      ours%s %s -> vector %s size %zu, [%d] = %s\n",
                               samePath ? "" : "(OTHER PATH)", ident(Y).c_str(),
                               v2 ? "present" : "NULL", v2 ? v2->size() : 0, idx,
                               (v2 && (size_t)idx < v2->size())
                                   ? ident(v2->at(idx)).c_str()
                                   : "-");
                }
                if (!nm) printf("      ours NO COUNTERPART for the referrer\n");
            }
        }
    }

    // ---- STEP 2 — TOPOLOGY: every matching function object, both sides ---
    if (fnWant) {
        printf("FUNCTION OBJECTS MATCHING \"%s\" — golden then ours:\n", fnWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            int n = 0;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o) continue;
                if (o->UhdmType() != uhdmfunction && o->UhdmType() != uhdmtask)
                    continue;
                if (std::string(o->VpiName()).find(fnWant) == std::string::npos)
                    continue;
                printf("    #%d %s\n", n++, ident(o).c_str());
                dumpFn(o);
            }
            printf("    total=%d\n", n);
        }
        printf("REFERENCES IN FUNCTIONS MATCHING \"%s\" — golden then ours:\n", fnWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !isRef(o)) continue;
                const BaseClass* fn = enclosingFn(o, fnWant);
                if (!fn) continue;
                char b[1400];
                const std::string val =
                    actualOf(o) ? ("BOUND -> " + ident(actualOf(o))) : std::string("BARE");
                snprintf(b, sizeof b, "    %4u:%-3u %-12s %-22s owner=%s %s",
                         o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                         std::string(o->VpiName()).c_str(),
                         UhdmName(o->UhdmType()).data(),
                         ident(fn).c_str(), val.c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (no references found)\n");
        }
        // ---- STEP 3 — the CALLERS ---------------------------------------
        printf("CALLS TO \"%s\" — golden then ours:\n", fnWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            int n = 0;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o) continue;
                const tf_call* tc = any_cast<const tf_call*>(o);
                if (!tc) continue;
                if (std::string(o->VpiName()).find(fnWant) == std::string::npos)
                    continue;
                const BaseClass* callee = nullptr;
                if (const func_call* fc = any_cast<const func_call*>(o))
                    callee = fc->Function();
                else if (const task_call* tk = any_cast<const task_call*>(o))
                    callee = tk->Task();
                printf("    %s\n      callee = %s\n", ident(o).c_str(),
                       ident(callee).c_str());
                printf("      call parents:");
                int g3 = 0;
                for (const BaseClass* p = o->VpiParent(); p && g3 < 8;
                     p = p->VpiParent(), ++g3)
                    printf(" < %s", ident(p).c_str());
                printf("\n");
                ++n;
            }
            printf("    total=%d\n", n);
        }
    }
    return 0;
}
