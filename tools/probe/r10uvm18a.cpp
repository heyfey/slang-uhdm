// r10uvm18a — § pkgTdRangeViewFold18 instrument.  For every task_func in every
// VIEW (package def/elab listings, their class methods, module def/elab
// bodies), print each io_decl / return / body-local typespec: its OBJECT ID,
// its name, its packed-range LEFT bound KIND (operation = symbolic, constant =
// folded), and the same triple for its Typedef_alias target.  Reading the fold
// state and the alias target side by side is the whole question the law asks.
//   r10uvm18a <file.uhdm> [nameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, int> g_id;
static int idOf(const BaseClass* o) {
    if (!o) return 0;
    auto it = g_id.find(o);
    if (it != g_id.end()) return it->second;
    int n = (int)g_id.size() + 1;
    g_id[o] = n;
    return n;
}

// "op" when the first packed range's LEFT bound is an operation, "const:<v>"
// when it folded, "-" when there is no range at all.
static std::string boundOf(const typespec* t) {
    if (!t) return "<null>";
    const VectorOfrange* rs = nullptr;
    if (auto* lt = any_cast<const logic_typespec*>(t)) rs = lt->Ranges();
    else if (auto* bt = any_cast<const bit_typespec*>(t)) rs = bt->Ranges();
    else if (auto* at = any_cast<const array_typespec*>(t)) rs = at->Ranges();
    if (!rs || rs->empty()) return "-";
    const expr* l = (*rs)[0]->Left_expr();
    if (!l) return "<noleft>";
    if (l->UhdmType() == uhdmconstant)
        return "const:" + std::string(((const constant*)l)->VpiDecompile());
    return std::string(UhdmName(l->UhdmType()));
}

// The whole left-bound EXPRESSION, operand by operand, with each ref_obj's
// vpiActual — what a bound that "is an operation" in both databases still
// disagrees about (t28's residual `<null> vs constant` rows).
static std::string exprTree(const any* e, int d = 0) {
    if (!e) return "<null>";
    std::string r = std::string(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += " '" + std::string(e->VpiName()) + "'";
    if (e->UhdmType() == uhdmconstant)
        r += "=" + std::string(((const constant*)e)->VpiDecompile());
    if (e->UhdmType() == uhdmref_obj) {
        auto* a = ((const ref_obj*)e)->Actual_group();
        r += " ->" + (a ? std::string(UhdmName(a->UhdmType())) + "@" +
                              std::to_string(a->VpiLineNo()) + ":" +
                              std::to_string(a->VpiColumnNo())
                        : std::string("<null>"));
    }
    if (d < 4)
        if (auto* op = any_cast<const operation*>(e))
            if (auto* os = op->Operands()) {
                r += "(";
                for (size_t i = 0; i < os->size(); i++)
                    r += (i ? ", " : "") + exprTree((*os)[i], d + 1);
                r += ")";
            }
    return r;
}

static const expr* leftOf(const typespec* t) {
    const VectorOfrange* rs = nullptr;
    if (auto* lt = any_cast<const logic_typespec*>(t)) rs = lt->Ranges();
    else if (auto* bt = any_cast<const bit_typespec*>(t)) rs = bt->Ranges();
    return (rs && !rs->empty()) ? (*rs)[0]->Left_expr() : nullptr;
}

static bool g_deep = false;
// "listing" mode prints each package's own Typespecs vector instead of its
// bodies: the LISTING objects the per-declaration clones alias.
static bool g_listing = false;

static std::string tsLine(const typespec* t) {
    if (!t) return "<null>";
    std::string r = "#" + std::to_string(idOf(t)) + " " +
                    std::string(UhdmName(t->UhdmType())) + " '" +
                    std::string(t->VpiName()) + "'@" +
                    std::to_string(t->VpiLineNo()) + ":" +
                    std::to_string(t->VpiColumnNo()) + " [" + boundOf(t) + "]";
    // vpiInstance is cmp-relevant (Compare recurses it) and is the other half
    // of "which view's listing is this?".
    r += " inst=" + (t->Instance()
                         ? std::string(UhdmName(t->Instance()->UhdmType())) +
                               ":" + std::string(t->Instance()->VpiName())
                         : std::string("-"));
    if (g_deep) r += " {" + exprTree(leftOf(t)) + "}";
    if (auto* al = t->Typedef_alias())
        r += "  ->  " + tsLine(al->Actual_typespec());
    return r;
}

static const typespec* actOf(const ref_typespec* r) {
    return r ? r->Actual_typespec() : nullptr;
}

static std::string g_filt;
static void emitTf(const std::string& view, const task_func* tf) {
    std::string nm(tf->VpiName());
    if (!g_filt.empty() && nm.find(g_filt) == std::string::npos) return;
    std::string pre = view + "/" + nm;
    if (auto* ios = tf->Io_decls())
        for (size_t i = 0; i < ios->size(); i++)
            std::cout << pre << ".io[" << i << " " << (*ios)[i]->VpiName()
                      << "] " << tsLine(actOf((*ios)[i]->Typespec())) << "\n";
    if (auto* rv = tf->Return())
        std::cout << pre << ".ret " << tsLine(actOf(rv->Typespec())) << "\n";
    // body locals: the tf's own Variables plus one level of begin/named_begin
    auto vars = [&](const VectorOfvariables* vs, const char* tag) {
        if (!vs) return;
        for (auto* v : *vs)
            std::cout << pre << "." << tag << "[" << v->VpiName() << "] "
                      << tsLine(actOf(v->Typespec())) << "\n";
    };
    vars(tf->Variables(), "var");
    if (auto* st = tf->Stmt()) {
        if (auto* b = any_cast<const begin*>(st)) vars(b->Variables(), "bvar");
        if (auto* b = any_cast<const named_begin*>(st)) vars(b->Variables(), "bvar");
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    g_filt = argc > 2 ? argv[2] : "";
    g_deep = argc > 3 && std::string(argv[3]) == "deep";
    g_listing = argc > 3 && std::string(argv[3]) == "listing";
    auto pkgs = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v) {
            std::string view = std::string(tag) + "[" + std::string(p->VpiName()) + "]";
            if (g_listing) {
                if (auto* tss = p->Typespecs())
                    for (auto* t : *tss) {
                        std::string nm(t->VpiName());
                        if (!g_filt.empty() &&
                            nm.find(g_filt) == std::string::npos)
                            continue;
                        std::cout << view << ".TS " << tsLine(t) << "\n";
                    }
                continue;
            }
            if (auto* tfs = p->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
            if (auto* cds = p->Class_defns())
                for (auto* c : *cds)
                    if (auto* ms = c->Task_funcs())
                        for (auto* tf : *ms)
                            emitTf(view + "::" + std::string(c->VpiName()), tf);
        }
    };
    // Same view names r10uvm7b uses: AllPackages is the DEF listing,
    // TopPackages the ELABORATED one.
    pkgs(d->AllPackages(), "DEFPKG");
    pkgs(d->TopPackages(), "ELABPKG");
    auto mods = [&](const VectorOfmodule_inst* v, const char* tag) {
        if (!v) return;
        for (auto* m : *v) {
            std::string view = std::string(tag) + "[" + std::string(m->VpiName()) + "]";
            if (auto* tfs = m->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
        }
    };
    mods(d->AllModules(), "DEFMOD");
    mods(d->TopModules(), "ELABMOD");
    return 0;
}
