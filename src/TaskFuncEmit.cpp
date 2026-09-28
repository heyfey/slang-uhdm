#include <unistd.h>
//------------------------------------------------------------------------------
//! @file TaskFuncEmit.cpp
//! @brief User tasks and functions (module Task_funcs) and their io_decls
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include "slang/ast/EvalContext.h"
#include "slang/ast/statements/ConditionalStatements.h"
#include "slang/ast/statements/LoopStatements.h"
#include "slang/ast/symbols/SubroutineSymbols.h"

#include <algorithm>
#include <vector>
#include "R204.h"

namespace slang_uhdm {

// The r11u191 switches (tools/probe/r11u191dec/README.md): every r11u191 law
// reads its own R11U191_<LAW>_OFF switch; R11U191_OFF drops all of them, and
// so does R11U196_OFF (the laws landed with pass r11u196).
// R11U191_TRACE=<dir> names every firing of an r11u191 law (the mover
// census): one file per process, `<dir>/<pid>.TF`, its first line the
// `-o` database path read off the command line, then one law name per firing.
void noteQualTdRt196(const UHDM::ref_typespec* rt);
bool r11u196Law(const char* sw);  // the r11u196 switches (UhdmExporter.cpp)
void trace196(const char* law, const std::string& detail);
static void tr191TF(const char* law) {
    static FILE* tf = [] () -> FILE* {
        const char* d = getenv("R11U191_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".TF";
        FILE* fp = fopen(fn.c_str(), "a");
        if (!fp)
            return nullptr;
        std::string cl, prev, outp;
        if (FILE* c = fopen("/proc/self/cmdline", "r")) {
            int ch;
            while ((ch = fgetc(c)) != EOF) {
                if (ch == 0) {
                    if (prev == "-o")
                        outp = cl;
                    prev = cl;
                    cl.clear();
                }
                else
                    cl += (char)ch;
            }
            fclose(c);
        }
        fprintf(fp, "OUT %s\n", outp.c_str());
        return fp;
    }();
    if (tf) {
        fprintf(tf, "%s\n", law);
        fflush(tf);
    }
}
static bool r191TF(const char* sw) {
    if (getenv("R11U191_OFF") != nullptr || getenv("R11U196_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
bool r11u137Law(const char* sw);
bool r11u144Law(const char* sw);
void noteTpUse180(UHDM::typespec* ts, const slang::ast::Symbol& declSymbol,
                  const slang::syntax::SyntaxNode* typeSyn); // § classTpDefaultTsAtUse180 (TypeEmit.cpp)

// The r11u175 switches (tools/probe/r11u175uvm/README.md): every r11u175 law
// reads its own R11U175_<LAW>_OFF switch; R11U175_OFF drops all of them.
static bool r11u175LawB(const char* sw) {
    if (getenv("R11U175_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}

// § classHandleRetTsNameUnlessSameHomeComponent156 — the HOME DESIGN COMPONENT
// of a scope, keyed the way Surelog's class REGISTRY keys it
// (`Design::addClassDefinition`, and the `Compile class "…"` lines of its own
// log): a PACKAGE, a MODULE or a PROGRAM is a home; an INTERFACE and $unit are
// NOT — their classes are registered with no enclosing qualifier at all
// (`work@ifCls156`, `work@unitCls156`), so arm B's three lookup forms can never
// reach them.  The walk goes THROUGH class / subroutine / block scopes, which
// is what makes an out-of-body method answer with its home package.
static const slang::ast::Symbol* homeComp156(const slang::ast::Scope* sc) {
    for (int i = 0; i < 64 && sc; ++i) {
        auto& sym = sc->asSymbol();
        if (sym.kind == SymbolKind::Package)
            return &sym;
        if (sym.kind == SymbolKind::InstanceBody) {
            auto& def = sym.as<InstanceBodySymbol>().getDefinition();
            if (def.definitionKind == slang::ast::DefinitionKind::Interface)
                return nullptr;
            return &def;
        }
        if (sym.kind == SymbolKind::CompilationUnit)
            return nullptr;
        sc = sym.getParentScope();
    }
    return nullptr;
}

// The type name AS WRITTEN at the return-type token, which is Surelog's
// `typeName` (`compileTypespec`'s `fC->SymName(type)`, and for a `paClass_scope`
// node the `"<scope>::<name>"` it concatenates at CompileType.cpp:1524-1531).
// An UNMEASURED spelling returns empty, i.e. leaves the object anonymous —
// the pristine behaviour.
static std::string writtenTypeName156(const syntax::SyntaxNode* rsyn) {
    auto ident = [](const syntax::NameSyntax* n) -> std::string {
        if (auto* id = n->as_if<syntax::IdentifierNameSyntax>())
            return std::string(id->identifier.valueText());
        if (auto* cn = n->as_if<syntax::ClassNameSyntax>())
            return std::string(cn->identifier.valueText());
        return {};
    };
    auto* nt = rsyn ? rsyn->as_if<syntax::NamedTypeSyntax>() : nullptr;
    if (!nt || !nt->name)
        return {};
    if (auto* sn = nt->name->as_if<syntax::ScopedNameSyntax>()) {
        std::string l = ident(&*sn->left), r = ident(&*sn->right);
        if (l.empty() || r.empty())
            return {};
        return l + "::" + r;
    }
    return ident(nt->name);
}

// § dpiExportedPkgSubBareOwnTdUnsupported170 — is THIS subroutine's definition
// preceded, in its own package's item list, by an `export "DPI-C"` naming it?
//
// The test is the ITEM INDEX inside the package declaration, not a
// SourceLocation: Surelog's bail is produced by the ORDER of
// `CompilePackage::collectObjects_`'s single walk over that same list, and a
// raw `SourceLocation` compare across macro/include buffers is not a stable
// order (RESUME.md §9, "Emitter nondeterminism").  The per-package index maps
// are built once and memoised — uvm_pkg has one item list and hundreds of
// package-level subroutines.
bool UhdmExporter::dpiExportPrecedesDef170(const SubroutineSymbol& sub) {
    auto* ps = sub.getParentScope();
    if (!ps || ps->asSymbol().kind != SymbolKind::Package)
        return false;
    auto& pkgSym = ps->asSymbol();
    auto* pkgSyn = pkgSym.getSyntax();
    if (!pkgSyn || pkgSyn->kind != syntax::SyntaxKind::PackageDeclaration)
        return false;
    auto* subSyn = sub.getSyntax();
    if (!subSyn)
        return false;
    // The package ITEM that contains the definition (the definition syntax is
    // itself the member for a package-level `function`/`task`).
    const syntax::SyntaxNode* subMem = subSyn;
    for (int g = 0; g < 8 && subMem && subMem->parent != pkgSyn; ++g)
        subMem = subMem->parent;
    if (!subMem || subMem->parent != pkgSyn)
        return false;
    auto it = dpiExpOrder170.find((const void*)&pkgSym);
    if (it == dpiExpOrder170.end()) {
        DpiExpOrder170 ord;
        size_t i = 0;
        for (auto* mem : pkgSyn->as<syntax::ModuleDeclarationSyntax>().members) {
            ord.memberIdx[(const void*)mem] = i;
            if (mem->kind == syntax::SyntaxKind::DPIExport) {
                std::string nm(
                    mem->as<syntax::DPIExportSyntax>().name.valueText());
                if (!nm.empty())
                    ord.exportIdx.emplace(nm, i);
            }
            ++i;
        }
        it = dpiExpOrder170.emplace((const void*)&pkgSym, std::move(ord)).first;
    }
    auto mi = it->second.memberIdx.find((const void*)subMem);
    if (mi == it->second.memberIdx.end())
        return false;
    auto ei = it->second.exportIdx.find(std::string(sub.name));
    return ei != it->second.exportIdx.end() && ei->second < mi->second;
}

// § dpiExportListedAtExportItem216 — the ONE declaration node that can hold an
// `export "DPI-C"` item list.  A module, an interface, a program and a package
// all parse to `ModuleDeclarationSyntax`; nothing else has a `members` list an
// export item can sit in (a class body cannot legally carry one — slang
// rejects it at Compilation.cpp:1971 with `DPIExportDifferentScope`).
static bool dpiItemListHolder216(const slang::syntax::SyntaxNode* n) {
    switch (n->kind) {
        case syntax::SyntaxKind::ModuleDeclaration:
        case syntax::SyntaxKind::InterfaceDeclaration:
        case syntax::SyntaxKind::ProgramDeclaration:
        case syntax::SyntaxKind::PackageDeclaration:
            return true;
        default:
            return false;
    }
}

// § dpiExportListedAtExportItem216 — see the law on `DpiExportOrder216` in
// UhdmExporter.h.  Walks UP from `sym`'s syntax to the top-level item of the
// holder declaration that contains it, and memoises that holder's item table.
const UhdmExporter::DpiExportOrder216* UhdmExporter::dpiExportOrder216For(
    const Symbol& sym, size_t* itemIdxOut,
    const slang::syntax::SyntaxNode** itemOut) {
    const syntax::SyntaxNode* syn = sym.getSyntax();
    if (!syn)
        return nullptr;
    // The top-level ITEM is the ancestor whose parent IS the holder.  A member
    // nested in a generate region or a class body therefore maps to the index
    // of the item that CONTAINS it, which is what an item walk sees.
    const syntax::SyntaxNode* item = syn;
    const syntax::SyntaxNode* holder = nullptr;
    for (int g = 0; g < 32 && item && item->parent; ++g) {
        if (dpiItemListHolder216(item->parent)) {
            holder = item->parent;
            break;
        }
        item = item->parent;
    }
    if (!holder)
        return nullptr;
    auto it = dpiExportOrder216.find((const void*)holder);
    if (it == dpiExportOrder216.end()) {
        DpiExportOrder216 ord;
        size_t i = 0;
        for (auto* mem : holder->as<syntax::ModuleDeclarationSyntax>().members) {
            ord.itemIdx[(const void*)mem] = i;
            if (mem->kind == syntax::SyntaxKind::DPIExport) {
                std::string nm(
                    mem->as<syntax::DPIExportSyntax>().name.valueText());
                // FIRST export wins: Surelog's prototype is pushed by the
                // first `paDpi_import_export` item of that name and every
                // later one finds the object already listed.
                if (!nm.empty())
                    ord.exports.emplace(nm, std::make_pair(i, mem));
            }
            ++i;
        }
        it = dpiExportOrder216.emplace((const void*)holder, std::move(ord))
                 .first;
    }
    auto mi = it->second.itemIdx.find((const void*)item);
    if (mi == it->second.itemIdx.end())
        return nullptr;
    if (itemIdxOut)
        *itemIdxOut = mi->second;
    if (itemOut)
        *itemOut = item;
    return &it->second;
}

// § dpiExportListedAtExportItem216 — the `export "DPI-C"` item naming THIS
// subroutine in its own holder's item list.  Both fences are stated on the
// declaration in UhdmExporter.h.
const slang::syntax::SyntaxNode* UhdmExporter::dpiExportItem216(
    const SubroutineSymbol& sub) {
    // A DPI IMPORT is never also an export (slang: `DPIExportImportedFunc`).
    if ((sub.flags & MethodFlags::DPIImport) != MethodFlags::None)
        return nullptr;
    size_t idx = 0;
    const syntax::SyntaxNode* item = nullptr;
    const DpiExportOrder216* ord = dpiExportOrder216For(sub, &idx, &item);
    if (!ord || ord->exports.empty() || !item)
        return nullptr;
    // FENCE 1 — the subroutine's top-level item must be its OWN declaration.
    // Without this a class method would match an enclosing module's export of
    // the same bare name (the class declaration is the item we would find).
    if (item->kind != syntax::SyntaxKind::FunctionDeclaration &&
        item->kind != syntax::SyntaxKind::TaskDeclaration)
        return nullptr;
    auto e = ord->exports.find(std::string(sub.name));
    if (e == ord->exports.end())
        return nullptr;
    // FENCE 2 — the export's `function`/`task` keyword must match the
    // subroutine kind (slang's own check, Compilation.cpp:1959-1968).
    auto& de = e->second.second->as<syntax::DPIExportSyntax>();
    if (sub.subroutineKind == SubroutineKind::Function &&
        de.functionOrTask.kind == parsing::TokenKind::TaskKeyword)
        return nullptr;
    if (sub.subroutineKind == SubroutineKind::Task &&
        de.functionOrTask.kind == parsing::TokenKind::FunctionKeyword)
        return nullptr;
    // FENCE 3 (r10v216) — THE EXPORT ITEM MUST PRECEDE THE DEFINITION ITEM.
    // An export written BELOW its definition is a DIFFERENT Surelog shape and
    // this law does not describe it: the FUNCTION pass reaches the DEFINITION
    // first, `compileFunction`'s bare-name scan finds nothing, and it pushes an
    // UNSTAMPED entry at the definition's own slot; the later export item then
    // runs `compileFunctionPrototype` + `insertFunction`, which does NOT
    // re-scan, so golden ends up with TWO entries — the unstamped definition
    // where it stands, plus a SECOND, EMPTY `vpiAccessType=EXPORT` prototype at
    // the export's slot (measured: `v216_b1`/`b2`/`b3`/`b4`, every holder kind,
    // both views; the r10uvm216 README records the same shape as its R2 from
    // `r10v170repro/v170_p_export.sv`).  We emit ONE entry, so the best cell we
    // can hold is golden's UNSTAMPED DEFINITION at its own slot — which is
    // exactly what we already held.  Firing here instead moved that entry to
    // the export's slot AND stamped it, losing a cell we had:
    //   b1 (interface, separated)  ONLY-GOLDEN 3 -> 6, ONLY-OURS 1 -> 4
    //   b2 (module, separated)                 10 -> 12,           6 -> 8
    //   b3 (package, separated)                14 -> 18,          10 -> 14
    //   b4 (interface, ADJACENT below)          3 -> 5,            1 -> 3
    // so the below shape is FENCED OUT until R2 models the second entry.
    if (e->second.first > idx)
        return nullptr;
    return e->second.second;
}

// § dpiExportListedAtExportItem216 — move every DPI-exported entry of a
// FINISHED LISTING to the position its `export "DPI-C"` item occupies in the
// holder's item list, and leave every other entry's relative order EXACTLY as
// it was.
//
// THE LISTING, NOT THE EMISSION.  An earlier cut of this pass reordered
// `emitTaskFuncs`'s `items` walk instead, which is wrong twice over: CREATION
// ORDER IS LOAD-BEARING FOR BINDING (the package listing's own re-sort says so
// in `ParamEmit.cpp`, and the r10uvm216 measurement agrees — reordering the
// walk moved `BuildUVMPkg` x2 and `SeqDriver`/default by bytes with a
// BYTE-IDENTICAL `uhdm-dump`, i.e. it perturbed object creation order and
// nothing else), and a package with classes re-sorts its DEF listing
// afterwards anyway, undoing the walk's order. So the walk is left alone and
// only the LISTING is permuted, exactly as § pkgTfSeq9 already does.
//
// It is deliberately an INSERTION, not a sort by effective item index: this
// listing also receives entries that are not members of this holder at all (an
// interface that wildcard-imports a package carries that package's subroutines
// ahead of its own — 894 of MiniAmiq's 931), and an entry with no item index
// of its own must never migrate.  An exported entry is re-inserted before the
// FIRST remaining entry whose item index is >= the export's, so nothing else
// moves and an entry of unknown index is never a barrier.  An ADJACENT
// export/definition pair therefore returns to the slot it already held.
//
// `keys[i]` is entry i's item index (`kUnknown216` when it has none) and
// `expKey[i]` is its EXPORT item's index, or `kUnknown216` when it is not
// DPI-exported.
std::vector<size_t> UhdmExporter::dpiExportListingPerm216(
    const std::vector<size_t>& keys, const std::vector<size_t>& expKey) {
    std::vector<size_t> perm;
    if (keys.size() != expKey.size() || keys.size() < 2)
        return perm;
    std::vector<size_t> order;
    for (size_t i = 0; i < expKey.size(); ++i)
        if (expKey[i] != kUnknown216)
            order.push_back(i);
    if (order.empty())
        return perm;
    // ASCENDING export-item order — the order Surelog's FUNCTION pass pushes
    // the prototypes in.
    std::stable_sort(order.begin(), order.end(), [&](size_t a, size_t b) {
        return expKey[a] < expKey[b];
    });
    std::vector<size_t> outIdx;
    perm.reserve(keys.size());
    outIdx.reserve(keys.size());
    for (size_t i = 0; i < expKey.size(); ++i) {
        if (expKey[i] != kUnknown216)
            continue;
        perm.push_back(i);
        outIdx.push_back(keys[i]);
    }
    for (size_t i : order) {
        size_t x = expKey[i];
        size_t pos = perm.size();
        for (size_t j = 0; j < perm.size(); ++j)
            if (outIdx[j] != kUnknown216 && outIdx[j] >= x) {
                pos = j;
                break;
            }
        perm.insert(perm.begin() + (ptrdiff_t)pos, i);
        outIdx.insert(outIdx.begin() + (ptrdiff_t)pos, x);
    }
    // An IDENTITY permutation (every adjacent export/definition pair) is
    // reported as "nothing to do" so no caller ever rewrites a listing that
    // does not change.
    bool identity = true;
    for (size_t i = 0; i < perm.size(); ++i)
        if (perm[i] != i) {
            identity = false;
            break;
        }
    if (identity)
        perm.clear();
    return perm;
}

// Apply a permutation produced by `dpiExportListingPerm216` to the TAIL of a
// listing (the entries this `emitTaskFuncs` call contributed, which start at
// `base`).  `info->taskFuncs` can already hold entries from an earlier call
// against the same DefInfo, and those must not move.
void UhdmExporter::applyDpiExportPerm216(std::vector<UHDM::task_func*>& v,
                                         size_t base,
                                         const std::vector<size_t>& perm) {
    if (perm.empty() || v.size() != base + perm.size())
        return;
    std::vector<UHDM::task_func*> tail;
    tail.reserve(perm.size());
    for (size_t i : perm)
        tail.push_back(v[base + i]);
    for (size_t i = 0; i < tail.size(); ++i)
        v[base + i] = tail[i];
}

// § dpiExportedPkgSubBareOwnTdUnsupported170 — FENCE 2 (an import provides the
// name) and FENCE 3 (a forward typedef).  See the law on
// `dpiHomeStillResolves170` in UhdmExporter.h for both decodes; the arm is
// `tools/probe/r10v170repro/v170_t_fence.sv`.  Returns TRUE when golden
// RESOLVES the bare name anyway, in which case this law must keep its hands
// off the site.
bool UhdmExporter::dpiHomeStillResolves170(const Type& alias) {
    // FENCE 3 — the alias carries a FORWARD declaration.
    if (alias.kind == SymbolKind::TypeAlias &&
        alias.as<slang::ast::TypeAliasType>().getFirstForwardDecl())
        return true;
    // FENCE 2 — an import of the HOME package provides this simple name.
    if (!dpiExportPkgHome170)
        return false;
    std::string_view nm = alias.name;
    if (nm.empty())
        return false;
    auto* key = (const void*)&dpiExportPkgHome170->asSymbol();
    auto it = dpiImp170.find(key);
    if (it == dpiImp170.end()) {
        DpiImp170 imp;
        for (auto& mem : dpiExportPkgHome170->members()) {
            if (mem.kind == SymbolKind::ExplicitImport)
                imp.explicitNames.emplace(
                    mem.as<slang::ast::ExplicitImportSymbol>().importName);
            else if (mem.kind == SymbolKind::WildcardImport) {
                if (auto* dp =
                        mem.as<slang::ast::WildcardImportSymbol>().getPackage())
                    imp.wildcardPkgs.push_back(dp);
            }
        }
        it = dpiImp170.emplace(key, std::move(imp)).first;
    }
    if (it->second.explicitNames.count(std::string(nm)))
        return true;
    for (auto* dp : it->second.wildcardPkgs) {
        // `importPackage` copies the donor's data-type map, so only a TYPE of
        // that name can shadow the local one at `getDataType` time.
        if (auto* sym = dp->find(nm))
            if (sym->kind == SymbolKind::TypeAlias ||
                sym->kind == SymbolKind::ClassType ||
                sym->kind == SymbolKind::GenericClassDef ||
                sym->kind == SymbolKind::ForwardingTypedef)
                return true;
    }
    return false;
}

std::string UhdmExporter::classHandleRetTsName156(const SubroutineSymbol& sub,
                                                  const Type& rct) {
    // FENCE 1 — a CONSTRUCTOR.  Its return typespec is built at the
    // `classScope && sub.name == "new"` site above and never reaches this
    // mint; asserting the fence here keeps a future re-order from widening
    // the law onto a population golden answers by a different rule.
    if (sub.name == "new" ||
        (sub.flags & MethodFlags::Constructor) != MethodFlags::None)
        return {};
    // FENCE 2 — a class Surelog registers under its BARE name, i.e. a
    // builtin.sv class.  `Builtin::addBuiltinClasses`
    // (`~/git-repos/Surelog/src/DesignCompile/Builtin.cpp:385-392`) builds the
    // ClassDefinition as `work@process` but calls
    // `design->addClassDefinition(name, def)` with the SHORT name, so arm B's
    // FIRST form — `design->getClassDefinition(typeName)` — HITS for
    // `mailbox` / `process` / `semaphore` from anywhere at all.  Golden
    // therefore leaves builtin.sv's own `static function process self();`
    // ANONYMOUS even though its home differs from nothing: 9 corpus cells
    // (one per UVM row-mode) depend on this carve-out, and it was found by
    // scoring the predicate against golden, not reasoned.
    // Both faces are tested: slang's compiler-synthesized `std` package
    // (§ builtinClassTsLinksBuiltinFileDefn7's gate) and the injected
    // builtin.sv text the class_defns actually come from.
    if (isBuiltinStdClass(rct) ||
        (builtins && fullFilePath(rct.location) == builtinFilePath))
        return {};
    // FENCE 3 — a return written through a TYPEDEF is Surelog's arm A: a
    // different object with a context-dependent spelling, and one that does
    // not reach this mint (the typedef arms above claim it).  Recorded so the
    // boundary is explicit.
    if (sub.getReturnType().kind == SymbolKind::TypeAlias)
        return {};
    // ARM B — the three-form `design->getClassDefinition` lookup hits exactly
    // when the returned class shares its HOME DESIGN COMPONENT with the
    // declaring scope, and then the object is minted fresh and ANONYMOUS.
    const Scope* clsScope = rct.getParentScope();
    if (!clsScope)
        if (auto* gc = rct.as<ClassType>().genericClass)
            clsScope = gc->getParentScope();
    const Symbol* clsHome = homeComp156(clsScope);
    const Symbol* subHome = homeComp156(sub.getParentScope());
    if (clsHome && clsHome == subHome)
        return {};
    return writtenTypeName156(returnTypeSyntax(sub));
}

// § elabInvoked — every subroutine CALLED from a continuous / elaboration
// expression in the design.  The scan is a symbol+EXPRESSION walk of the root
// with STATEMENTS switched off, which is exactly the distinction Surelog
// draws (purpose-built golden, five call sites over one source):
//
//   assign a = fa(1'b1);        -> fa's io_decl gets a typespec
//   wire   f = fd(1'b1);        -> fd    "
//   parameter P2 = fc(1'b1);    -> fc    "
//   sub #(.M(w_1(X))) m1();     -> w_1   "   (ImplicitFuncArgAndReturn)
//   always @(*) r = fb(1'b1);   -> fb    NO typespec
//   function fe; fe = fa(val);  -> fe    NO typespec (a body statement)
//   initial t2(1'b0);           -> t2    NO typespec
//
// so "called somewhere" is too weak: a call reached only through a procedural
// statement leaves the formals uncompiled, exactly like never calling it.
namespace {
struct ElabCallScan
    : slang::ast::ASTVisitor<ElabCallScan, slang::ast::VisitFlags::Symbols |
                                               slang::ast::VisitFlags::Expressions> {
    std::set<const SubroutineSymbol*>& out;
    std::map<const slang::ast::ParameterSymbol*,
             const slang::ast::FormalArgumentSymbol*>& args;
    ElabCallScan(std::set<const SubroutineSymbol*>& o,
                 std::map<const slang::ast::ParameterSymbol*,
                          const slang::ast::FormalArgumentSymbol*>& a)
        : out(o), args(a) {}
    void handle(const slang::ast::CallExpression& ce) {
        if (auto* sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
            if (*sp) {
                out.insert(*sp);
                // Record which parameter each bare-name actual binds to, so
                // the parameter's elab constant can take the formal's
                // typespec (§ elabCallFormal).
                auto fs = (*sp)->getArguments();
                auto as = ce.arguments();
                for (size_t i = 0; i < as.size() && i < fs.size(); i++) {
                    if (!as[i] || !fs[i])
                        continue;
                    const slang::ast::Expression* a0 = as[i];
                    while (a0->kind == slang::ast::ExpressionKind::Conversion)
                        a0 = &a0->as<slang::ast::ConversionExpression>()
                                  .operand();
                    if (a0->kind != slang::ast::ExpressionKind::NamedValue)
                        continue;
                    auto& sy = a0->as<slang::ast::NamedValueExpression>().symbol;
                    if (sy.kind == SymbolKind::Parameter)
                        args.emplace(&sy.as<slang::ast::ParameterSymbol>(),
                                     fs[i]);
                }
            }
        visitDefault(ce);
    }
};

// § unpackedTdElem9 — the ELEMENT type of an unpacked-array formal when that
// element is a vector TYPEDEF whose typespec we already minted, and nullptr
// otherwise.  Surelog gives such a formal a fresh per-formal element typespec
// NAMED for the typedef (with a Typedef_alias back to the shared one); the
// shared-typespec fallback would leave it anonymous, and VpiName is a compared
// field.  Every unpacked shape counts — fixed-size, dynamic, queue and
// associative alike — and the typedef may be `logic`- or `bit`-based.
const Type* unpackedTdElem9(
    const Type& formalType,
    const std::map<const slang::ast::Symbol*, UHDM::typespec*>& typedefTs) {
    const Type* e0 = &formalType.getCanonicalType();
    bool arr = false;
    for (;;) {
        const Type& c0 = e0->getCanonicalType();
        if (c0.kind == SymbolKind::FixedSizeUnpackedArrayType)
            e0 = &c0.as<slang::ast::FixedSizeUnpackedArrayType>().elementType;
        else if (c0.kind == SymbolKind::DynamicArrayType)
            e0 = &c0.as<slang::ast::DynamicArrayType>().elementType;
        else if (c0.kind == SymbolKind::QueueType)
            e0 = &c0.as<slang::ast::QueueType>().elementType;
        else if (c0.kind == SymbolKind::AssociativeArrayType)
            e0 = &c0.as<slang::ast::AssociativeArrayType>().elementType;
        else
            break;
        arr = true;
    }
    if (!arr || e0->kind != SymbolKind::TypeAlias)
        return nullptr;
    auto it = typedefTs.find(e0);
    if (it == typedefTs.end())
        return nullptr;
    return (it->second->UhdmType() == UHDM::uhdmlogic_typespec ||
            it->second->UhdmType() == UHDM::uhdmbit_typespec)
               ? e0
               : nullptr;
}
// § tfItemLocalAutomaticIsNotWrittenStatic139 — THE TF-ITEM PRODUCTION'S OWN
// LIFETIME RULE, and the WRITTEN lifetime it reads.
//
// Surelog compiles a subroutine's declaration section in ONE of two places, and
// the two stamp `vpiAutomatic` by DIFFERENT rules:
//
//   * TF-ITEM production — `CompileHelper::compileTfPortDecl`
//     (CompileStmt.cpp:1576).  Its `paBlock_item_declaration` arm opens with
//     `bool is_static = false`, sets it true at a `paLifetime_Static` node and
//     leaves it false at `paLifetime_Automatic` or at no lifetime node at all
//     (:1663-1673), and then writes, for EVERY declarator of the declaration,
//         var->VpiAutomatic(!is_static);                    // :1690
//     It never looks at an initialiser, never looks at the declared type, and
//     never looks at the SUBROUTINE's own lifetime.
//   * BLOCK-ITEM production — the statement-level
//     `CompileHelper::compileDataDeclaration` (CompileStmt.cpp:1127), whose
//     `automatic_status` starts FALSE and is set only by a written `automatic`
//     (:1196).  That is § blockDeclAutomaticIsWrittenKw80 (StmtEmit.cpp) and
//     § r10fsv3 (the `else` arm below), and this pass does not touch it.
//
// `blockItems9` is already exactly the production selector (a FUNCTION takes
// the block shape iff its header carries a port-list paren; a TASK takes it
// unless the body declares io), so the law is a two-line transcription on the
// face it already names.
//
// MEASURED, golden, both views, every declaration kind
// (`g139_b_kinds.sv` `a1..q3`, 26 tf-item cells): with NO lifetime written the
// flag is 1 on int / logic / bit / real / enum / packed-struct / typedef'd /
// string-queue / dynamic-array / fixed-array / associative / class-handle
// locals alike, WITH `static` written it is 0 on every one of them, WITH
// `automatic` written it is 1 — with or without an initialiser in each case,
// and whether the subroutine is written `function f;`, `function static f;` or
// `function automatic f;` (`g139_a_homes.sv`).
enum class WrittenLife139 { None, Automatic, Static };
static WrittenLife139 writtenLife139(const slang::ast::Symbol& mv) {
    const syntax::SyntaxNode* dsyn = mv.getSyntax();
    if (!dsyn || dsyn->kind != syntax::SyntaxKind::Declarator)
        return WrittenLife139::None;
    // The declarator's parent is the whole data_declaration and the lifetime
    // keyword is one of ITS modifiers — so a MULTI-DECLARATOR declaration
    // (`static int a, b;`) answers Static for every declarator, which is what
    // Surelog does (the keyword is read once, off the shared declaration node,
    // and `!is_static` is written on each `Variable_decl_assignment`).
    const syntax::SyntaxNode* par = dsyn->parent;
    if (!par || par->kind != syntax::SyntaxKind::DataDeclaration)
        return WrittenLife139::None;
    for (auto md : par->as<syntax::DataDeclarationSyntax>().modifiers) {
        if (md.kind == parsing::TokenKind::AutomaticKeyword)
            return WrittenLife139::Automatic;
        if (md.kind == parsing::TokenKind::StaticKeyword)
            return WrittenLife139::Static;
    }
    return WrittenLife139::None;
}
}  // namespace

bool UhdmExporter::elabInvoked(const SubroutineSymbol& sub) {
    if (!elabCalledSubs) {
        elabCalledSubs.emplace();
        ElabCallScan scan(*elabCalledSubs, elabCallArgs);
        comp.getRoot().visit(scan);
    }
    return elabCalledSubs->count(&sub) != 0;
}

// § bareFormalTsReached — which subroutines get a typespec on a BARE formal.
//
// A formal written with no data type at all (`input a;` in the body, or
// `f(input a)` / `f(a)` in the header) leaves Surelog's def compile with NO
// typespec: CompileStmt's tf_item_declaration arm only builds one from a
// `paData_type` or a `paPacked_dimension` child (CompileStmt.cpp:1607-1622),
// and both are absent.  The typespec appears LATER — when the constant
// evaluator, reducing an elaboration/continuous expression, actually EXECUTES
// the subroutine and recompiles its formals.  So the question is exactly
// "does Surelog's evaluator reach this body", and the answer is a PREFIX
// walk: evalStmt aborts the moment a value it needs is not constant, and
// everything after that point in the body is never reached.
//
// Purpose-built goldens, one shape per module (arms a3/a4/a5/a6):
//   assign z = f(w);           / wire z = f(w)  -> f REACHED   (k2, k5)
//   parameter P = f(1);        (elab expression) -> f REACHED   (k3, k6)
//   always @(*) z = f(w);      (procedural)      -> NOT reached (k1 vs q2, s5)
//   never called                                 -> NOT reached (k1, k4, k8)
//   inner called from a reached body's plain stmt-> REACHED     (s1, s2, s6)
//   ...three deep, or twice in one statement     -> REACHED     (s4, u6)
//   ...inside an `if` the evaluator cannot fold  -> NOT reached (s3, u4)
//   ...inside `if (1'b1)` / a constant for loop  -> REACHED     (u1, u3)
//   ...anywhere AFTER such an `if`               -> NOT reached (u2)
//   ...BEFORE it                                 -> REACHED     (u5)
// FuncIoTypespec is the corpus instance: `assign z = fshl_s(a,s,...)` reaches
// fshl_s (whose `sbit` HAS the typespec) and its `if (arg2[width_s-1] ==
// 1'b0)` stops the walk, so fshl_u / fshl_u_1 / fshr_u — all called from
// inside that if — keep their bare `sbit` typespec-less.
//
// A formal WITH a written type is unaffected: its typespec comes from the def
// compile and exists whether or not anything calls the subroutine.
bool UhdmExporter::bareFormalTsReached(const SubroutineSymbol& sub) {
    if (!bareFormalReachSubs) {
        bareFormalReachSubs.emplace();
        // Roots: every subroutine an elaboration/continuous expression calls.
        (void)elabInvoked(sub);
        std::vector<const SubroutineSymbol*> work(elabCalledSubs->begin(),
                                                  elabCalledSubs->end());
        for (auto* r : work)
            bareFormalReachSubs->insert(r);
        while (!work.empty()) {
            const SubroutineSymbol* s0 = work.back();
            work.pop_back();
            std::vector<const SubroutineSymbol*> callees;
            evalReachedCallees(*s0, callees);
            for (auto* c : callees)
                if (bareFormalReachSubs->insert(c).second)
                    work.push_back(c);
        }
    }
    return bareFormalReachSubs->count(&sub) != 0;
}

// § evalReachedCallees — the calls Surelog's constant evaluator really makes
// while running one subroutine body.  evalStmt walks the body in order and
// gives up the moment it needs a value it does not have, so what it reaches is
// a PREFIX: statements before the give-up point, plus the branch/loop bodies
// whose controlling expression it could fold.  Modelled by TAINT rather than by
// interpretation — a value it cannot know is a FORMAL, a signal declared
// outside the subroutine, or a body local assigned from one of those.
//
// Purpose-built goldens (arms a5/a6/a7, one shape per module, plus a8/a9 for
// the call-argument side):
//   plain statement, however deeply nested in begin blocks -> REACHED (s1,s2,s6)
//   inside `if (formal)` / `case (formal)`                 -> not reached (s3,u4)
//   ANY statement after such an if                         -> not reached (u2)
//   before it                                              -> REACHED (u5)
//   inside `if (1'b1)`                                     -> REACHED (u1)
//   inside a for/while/repeat over body-local state        -> REACHED (u3,v2,v4,v5)
//   inside a loop whose bound reads a formal               -> not reached (v1)
//   after such a loop                                      -> not reached (v3)
void UhdmExporter::evalReachedCallees(
    const SubroutineSymbol& sub, std::vector<const SubroutineSymbol*>& outCallees) {
    {
        std::function<void(const Expression&, std::vector<const SubroutineSymbol*>&)>
            calls = [&](const Expression& e,
                        std::vector<const SubroutineSymbol*>& out) {
                e.visit(makeVisitor([&](auto& v, const CallExpression& ce) {
                    if (!ce.isSystemCall())
                        if (auto* sp = std::get_if<const SubroutineSymbol*>(
                                &ce.subroutine))
                            if (*sp)
                                out.push_back(*sp);
                    v.visitDefault(ce);
                }));
            };
        // The evaluator's own abort condition, modelled by TAINT rather than
        // by interpretation: a value it cannot know is a FORMAL, anything
        // outside the subroutine that is not a constant, or a body local that
        // was assigned from such a thing.  A controlling expression that reads
        // one aborts the run; everything else it can fold.  (Arm a7 is the
        // measurement that forced this over plain constant folding: `for (k =
        // 0; k < 2; ...)` over a body-local integer DOES run — the call after
        // it is reached — while the same loop written `k < a` does not, and a
        // `while (k < 2)` / `repeat (2)` runs exactly like the for.)
        std::set<const Symbol*> tainted;
        std::function<bool(const Expression&)> unknown =
            [&](const Expression& e) -> bool {
            bool bad = false;
            e.visit(makeVisitor(
                [&](auto& v, const NamedValueExpression& nv) {
                    auto k0 = nv.symbol.kind;
                    if (k0 == SymbolKind::FormalArgument || tainted.count(&nv.symbol))
                        bad = true;
                    else if (k0 == SymbolKind::Variable || k0 == SymbolKind::Net) {
                        // A signal declared outside the subroutine has no
                        // value at elaboration time.
                        bool local = false;
                        for (auto sc = nv.symbol.getParentScope(); sc;
                             sc = sc->asSymbol().getParentScope()) {
                            auto ks = sc->asSymbol().kind;
                            if (ks == SymbolKind::Subroutine ||
                                ks == SymbolKind::StatementBlock) {
                                local = true;
                                break;
                            }
                            if (ks == SymbolKind::InstanceBody ||
                                ks == SymbolKind::Package ||
                                ks == SymbolKind::CompilationUnit)
                                break;
                        }
                        if (!local)
                            bad = true;
                    }
                    v.visitDefault(nv);
                },
                [&](auto& v, const HierarchicalValueExpression& hv) {
                    if (hv.symbol.kind != SymbolKind::Parameter)
                        bad = true;
                    v.visitDefault(hv);
                }));
            return bad;
        };
        // Returns false when the evaluator would abort here — nothing after
        // this statement in the enclosing list is reached either.
        std::function<bool(const slang::ast::Statement&,
                           std::vector<const SubroutineSymbol*>&)>
            walk = [&](const slang::ast::Statement& st,
                       std::vector<const SubroutineSymbol*>& out) -> bool {
            switch (st.kind) {
                case StatementKind::List:
                    for (auto* s0 : st.as<slang::ast::StatementList>().list)
                        if (!walk(*s0, out))
                            return false;
                    return true;
                case StatementKind::Block:
                    return walk(st.as<slang::ast::BlockStatement>().body, out);
                case StatementKind::Empty:
                    return true;
                case StatementKind::VariableDeclaration: {
                    auto& vs = st.as<slang::ast::VariableDeclStatement>().symbol;
                    if (auto* iv = vs.getInitializer()) {
                        calls(*iv, out);
                        if (unknown(*iv))
                            tainted.insert(&vs);
                    }
                    return true;
                }
                case StatementKind::ExpressionStatement: {
                    auto& e0 = st.as<slang::ast::ExpressionStatement>().expr;
                    calls(e0, out);
                    if (e0.kind == ExpressionKind::Assignment) {
                        auto& ae = e0.as<AssignmentExpression>();
                        const Expression* l0 = &stripImplicitConv(ae.left());
                        while (l0->kind == ExpressionKind::ElementSelect ||
                               l0->kind == ExpressionKind::RangeSelect ||
                               l0->kind == ExpressionKind::MemberAccess) {
                            if (l0->kind == ExpressionKind::ElementSelect)
                                l0 = &stripImplicitConv(
                                    l0->as<ElementSelectExpression>().value());
                            else if (l0->kind == ExpressionKind::RangeSelect)
                                l0 = &stripImplicitConv(
                                    l0->as<RangeSelectExpression>().value());
                            else
                                l0 = &stripImplicitConv(
                                    l0->as<MemberAccessExpression>().value());
                        }
                        if (l0->kind == ExpressionKind::NamedValue) {
                            auto& ls = l0->as<NamedValueExpression>().symbol;
                            if (unknown(ae.right()))
                                tainted.insert(&ls);
                            else
                                tainted.erase(&ls);
                        }
                    }
                    return true;
                }
                case StatementKind::Return:
                    if (auto* re = st.as<slang::ast::ReturnStatement>().expr)
                        calls(*re, out);
                    return true;
                case StatementKind::Conditional: {
                    auto& cs = st.as<slang::ast::ConditionalStatement>();
                    for (auto& c0 : cs.conditions)
                        if (c0.pattern || unknown(*c0.expr))
                            return false;
                    // The condition is foldable; take the arm it selects, and
                    // both when the fold needs state this model does not keep.
                    ASTContext actx(comp.getRoot(), LookupLocation::max);
                    EvalContext ec(actx, EvalFlags::IsScript);
                    ec.pushEmptyFrame();
                    ConstantValue cv = cs.conditions.size() == 1
                                           ? cs.conditions[0].expr->eval(ec)
                                           : ConstantValue();
                    if (cv)
                        return cv.isTrue() ? walk(cs.ifTrue, out)
                                           : (cs.ifFalse ? walk(*cs.ifFalse, out)
                                                         : true);
                    if (!walk(cs.ifTrue, out))
                        return false;
                    return cs.ifFalse ? walk(*cs.ifFalse, out) : true;
                }
                case StatementKind::Case: {
                    auto& cs = st.as<slang::ast::CaseStatement>();
                    if (unknown(cs.expr))
                        return false;
                    for (auto& ig : cs.items)
                        if (!walk(*ig.stmt, out))
                            return false;
                    if (cs.defaultCase && !walk(*cs.defaultCase, out))
                        return false;
                    return true;
                }
                case StatementKind::ForLoop: {
                    auto& fl = st.as<slang::ast::ForLoopStatement>();
                    for (auto* i0 : fl.initializers)
                        if (unknown(*i0))
                            return false;
                    if (!fl.stopExpr || unknown(*fl.stopExpr))
                        return false;
                    return walk(fl.body, out);
                }
                case StatementKind::WhileLoop: {
                    auto& wl = st.as<slang::ast::WhileLoopStatement>();
                    if (unknown(wl.cond))
                        return false;
                    return walk(wl.body, out);
                }
                case StatementKind::DoWhileLoop: {
                    auto& wl = st.as<slang::ast::DoWhileLoopStatement>();
                    if (unknown(wl.cond))
                        return false;
                    return walk(wl.body, out);
                }
                case StatementKind::RepeatLoop: {
                    auto& rl = st.as<slang::ast::RepeatLoopStatement>();
                    if (unknown(rl.count))
                        return false;
                    return walk(rl.body, out);
                }
                default:
                    // Anything else (timing controls, waits, disables, ...)
                    // stops the evaluator.
                    return false;
            }
        };
        walk(sub.getBody(), outCallees);
    }
}

// § subCalledAsContAssignRhs — Surelog pushes the assignment's size through a
// call ONLY from a continuous assignment whose rhs IS the call: `assign a =
// f(x);` sizes every unbased-unsized literal in f's body to its return width,
// while `assign a = f(x) ^ g(y);`, a ternary operand and a procedural `<=`
// rhs all leave them unsized (measured mutation-by-mutation from
// func_forloop_onehot; Scr1SvTests width2axsize / mem_read are the unsized
// side).
bool UhdmExporter::subCalledAsContAssignRhs(const SubroutineSymbol& sub) {
    if (auto it = subContAssignRhsCache.find(&sub);
        it != subContAssignRhsCache.end())
        return it->second;
    bool found = false;
    // Only the subroutine's OWN instance body (and its generate scopes) can
    // hold such a call — a cross-module call would be hierarchical.
    const Scope* home = nullptr;
    for (auto sc = sub.getParentScope(); sc; sc = sc->asSymbol().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
            home = sc;
            break;
        }
    if (home) {
        std::function<void(const Scope&)> scan = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (found)
                    return;
                if (mem.kind == SymbolKind::ContinuousAssign) {
                    auto& asn = mem.as<ContinuousAssignSymbol>().getAssignment();
                    if (asn.kind != ExpressionKind::Assignment)
                        continue;
                    const Expression* r =
                        &stripImplicitConv(asn.as<AssignmentExpression>().right());
                    if (r->kind != ExpressionKind::Call)
                        continue;
                    if (auto* sp = std::get_if<const SubroutineSymbol*>(
                            &r->as<CallExpression>().subroutine))
                        if (*sp == &sub)
                            found = true;
                }
                else if (mem.kind == SymbolKind::GenerateBlock)
                    scan(mem.as<GenerateBlockSymbol>());
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan(*ge);
            }
        };
        scan(*home);
    }
    subContAssignRhsCache[&sub] = found;
    return found;
}

// § pkgFuncFillSizedInElab — the same size-through-the-call rule, reached from
// a PACKAGE function.  subCalledAsContAssignRhs looks in the subroutine's own
// InstanceBody, which a package function does not have, so the callers have to
// be found design-wide.  Measured (u.sv / v.sv): in the ELABORATED
// (uhdmtopPackages) copy of a package, a function CALLED as the DIRECT rhs of
// a continuous assignment has its whole-variable `'0` assignment RHS respelled
// at the variable's width, exactly like the module case; the DEF
// (uhdmallPackages) copy and a never-called function keep the raw `'0`.
// Corpus: aes_pkg::aes_transpose (`transpose = '0;` at
// logic [3:0][3:0][7:0]) reads 128 zeros / size 128 in golden's elaborated
// aes_pkg, and 13 Earlgrey AllModules def entries reach it through
// parameter::Compare's Instance() recursion.
bool UhdmExporter::pkgSubCalledAsContAssignRhs(const SubroutineSymbol& sub) {
    if (!contAssignRhsCalleesBuilt9) {
        contAssignRhsCalleesBuilt9 = true;
        std::function<void(const Scope&)> scan = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (mem.kind == SymbolKind::ContinuousAssign) {
                    auto& asn = mem.as<ContinuousAssignSymbol>().getAssignment();
                    if (asn.kind != ExpressionKind::Assignment)
                        continue;
                    const Expression* r = &stripImplicitConv(
                        asn.as<AssignmentExpression>().right());
                    if (r->kind != ExpressionKind::Call)
                        continue;
                    if (auto* sp = std::get_if<const SubroutineSymbol*>(
                            &r->as<CallExpression>().subroutine))
                        contAssignRhsCallees9.insert(*sp);
                }
                else if (mem.kind == SymbolKind::Instance)
                    scan(mem.as<InstanceSymbol>().body);
                else if (mem.kind == SymbolKind::InstanceArray) {
                    for (auto* e : mem.as<InstanceArraySymbol>().elements)
                        if (e->kind == SymbolKind::Instance)
                            scan(e->as<InstanceSymbol>().body);
                }
                else if (mem.kind == SymbolKind::GenerateBlock) {
                    if (!mem.as<GenerateBlockSymbol>().isUninstantiated)
                        scan(mem.as<GenerateBlockSymbol>());
                }
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan(*ge);
            }
        };
        for (auto* ti : comp.getRoot().topInstances)
            scan(ti->body);
    }
    return contAssignRhsCallees9.count(&sub) != 0;
}

// § pkgSubEvaluatedFromParamInit9 (r10earl6) — the OTHER shape that makes
// Surelog's evaluator run a function body, found DESIGN-WIDE so a package
// function is reachable: a call inside a parameter/localparam INITIALISER.
// § subEvaluatedFromParamInit models the same thing but keys on the
// subroutine's own InstanceBody, which a package function does not have —
// EvalFunc's `localparam log2RATIO4 = prim_util_pkg::vbits(RATIO);` is exactly
// that miss, and it is the regression that widened
// § pkgBodyArgTsCalledAsCaRhs from "cont-assign rhs" to "cont-assign rhs OR
// param initialiser".
bool UhdmExporter::pkgSubEvaluatedFromParamInit(const SubroutineSymbol& sub) {
    if (!paramInitCalleesBuilt9) {
        paramInitCalleesBuilt9 = true;
        auto harvest = [&](const Expression& init) {
            init.visit(makeVisitor([&](auto& v9, const CallExpression& ce9) {
                if (!ce9.isSystemCall())
                    if (auto sp9 =
                            std::get_if<const SubroutineSymbol*>(&ce9.subroutine))
                        if (*sp9)
                            paramInitCallees9.insert(*sp9);
                v9.visitDefault(ce9);
            }));
        };
        std::function<void(const Scope&)> scan = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (mem.kind == SymbolKind::Parameter) {
                    if (auto* pi = mem.as<ParameterSymbol>().getInitializer())
                        harvest(*pi);
                }
                else if (mem.kind == SymbolKind::Instance)
                    scan(mem.as<InstanceSymbol>().body);
                else if (mem.kind == SymbolKind::InstanceArray) {
                    for (auto* e : mem.as<InstanceArraySymbol>().elements)
                        if (e->kind == SymbolKind::Instance)
                            scan(e->as<InstanceSymbol>().body);
                }
                else if (mem.kind == SymbolKind::GenerateBlock) {
                    if (!mem.as<GenerateBlockSymbol>().isUninstantiated)
                        scan(mem.as<GenerateBlockSymbol>());
                }
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan(*ge);
            }
        };
        for (auto* ti : comp.getRoot().topInstances)
            scan(ti->body);
        for (auto* pk : comp.getPackages())
            scan(*pk);
    }
    return paramInitCallees9.count(&sub) != 0;
}

// § tfBodyConstArgNeedsEvaldBody60 (r10uvm60) — THE SET OF SUBROUTINE BODIES
// SURELOG'S EVALUATOR DESCENDS INTO, and it is a TRANSITIVE closure, not a
// one-hop test.
//
// The two predicates above name the two SEEDS: a subroutine called as the
// DIRECT rhs of a continuous assignment, and one called inside a parameter
// initialiser.  Surelog reduces those calls, and while reducing them it runs
// the bodies — and the bodies of everything THOSE call, to any depth.  Measured
// on tools/probe/r10uvm60repro/b6_reached.sv, whose six rows differ ONLY in how
// the body holding `g60(1)` is reached:
//
//   R1 body IS a cont-assign rhs callee        golden STAMPS (size 4)
//   R2 body reached from an always_comb        golden BARE   (size 64)
//   R3 body reached from an initial block      golden BARE   (size 64)
//   R4 body reached from a localparam init     golden STAMPS (size 4)
//   R5 body TWO LEVELS under a cont-assign     golden STAMPS (size 4)  <- the
//      transitive cell: `r5_inner` is called only by `r5_outer`, and only
//      `r5_outer` is the cont-assign rhs.  A one-hop predicate calls this cell
//      BARE and UNDER-FIRES on it.
//   R6 a CLASS METHOD as a cont-assign rhs is UNREACHABLE BY THE LANGUAGE
//      (slang -Wdynamic-non-procedural) — but the verifier proved a class
//      method DOES enter the closure through a PLAIN module function that a
//      seed reaches (v2_class.sv: cont-assign rhs `caller` calls `c62::sm`),
//      and golden is BARE inside it.  See the POISONING rule below.
//
// CORRECTED AT INTEGRATION (verifier findings F1-F3, each with its own arm,
// all corpus-price-0 by the verifier's two-corpora census):
//   SEEDS are not two but "every elaboration-time constant context".  Two more
//   are measured here and were UNDER-FIRES of the two-seed law — arms
//   v3_genif.sv / v4_dim.sv flipped from cmp-clean on PRISTINE to carrying a
//   HEAD on the patched binary, because golden STAMPS inside bodies reached
//   from (a) a GENERATE-IF/CASE CONDITION (v1_reach w1) and (b) a PACKED-
//   DIMENSION BOUND (`logic [w3(4'd1):0]`, v1_reach w3), both of which
//   Surelog's evaluator must run at elaboration time exactly like a param
//   initialiser.  slang retains the bound generate condition on
//   GenerateBlockSymbol (conditionExpression / caseItemExpressions); a packed
//   dimension bound is re-bound from the declaration's TYPE SYNTAX in the
//   declaring scope — the same ASTContext + Expression::bind idiom
//   TypeEmit.cpp already uses on dimension bounds.
//   POISONING (the verifier's mechanism correction, v5_class2.sv): golden's
//   rule is "the body was actually REDUCED", and ONE callee the evaluator
//   cannot run makes it abandon the WHOLE body — a constant actual sitting
//   BESIDE the class-method call in the seed body itself stays bare (golden
//   31:31 size 64 vs caller2's control 35:22 size 4).  Same family as the
//   precUnreduced9 / siblingCallArg9 left-to-right abort laws.  So a body
//   holding a CLASS-METHOD call (the one unreducible kind measured) is
//   neither inserted nor traversed.  Class-ness of the CALLEE'S OWNER is the
//   test — reachability alone was refuted twice (v2_class, v5_class2).
//
// The closure walks call edges only (no parameter edges: § subEvaluatedFrom-
// ParamInit already models the parameter side design-wide through the seed).
bool UhdmExporter::subBodyEvaluated60(const SubroutineSymbol& sub) {
    if (!evaldBodies60Built) {
        evaldBodies60Built = true;
        // Force both seed sets to exist.  Both predicates build their cache on
        // first call, so they are called ONCE here with the argument at hand;
        // the return values are deliberately unused.
        (void)pkgSubCalledAsContAssignRhs(sub);
        (void)pkgSubEvaluatedFromParamInit(sub);
        // Seeds (c) + (d): callees of generate-if/case conditions and of
        // packed-dimension bounds, harvested design-wide in the same walk
        // shape as the two predicates above.
        std::vector<const SubroutineSymbol*> elabSeeds60;
        auto harvest60 = [&](const Expression& e60) {
            e60.visit(makeVisitor([&](auto& v60, const CallExpression& ce60) {
                if (!ce60.isSystemCall())
                    if (auto* sp60 = std::get_if<const SubroutineSymbol*>(
                            &ce60.subroutine))
                        if (*sp60)
                            elabSeeds60.push_back(*sp60);
                v60.visitDefault(ce60);
            }));
        };
        auto harvestDims60 = [&](const Symbol& m60) {
            auto* dt60 = m60.getDeclaredType();
            if (!dt60)
                return;
            auto* tsyn60 = dt60->getTypeSyntax();
            if (!tsyn60 || tsyn60->kind == syntax::SyntaxKind::ImplicitType)
                return;
            auto* it60 = tsyn60->as_if<syntax::IntegerTypeSyntax>();
            if (!it60 || it60->dimensions.empty())
                return;
            auto* psc60 = m60.getParentScope();
            if (!psc60)
                return;
            ASTContext dctx60(*psc60, LookupLocation::max);
            for (auto* d60 : it60->dimensions) {
                if (!d60->specifier ||
                    d60->specifier->kind !=
                        syntax::SyntaxKind::RangeDimensionSpecifier)
                    continue;
                auto& sel60 = *d60->specifier
                                   ->as<syntax::RangeDimensionSpecifierSyntax>()
                                   .selector;
                std::vector<const syntax::ExpressionSyntax*> bs60;
                if (auto* b60 = sel60.as_if<syntax::BitSelectSyntax>())
                    bs60.push_back(b60->expr);
                else if (auto* r60 = sel60.as_if<syntax::RangeSelectSyntax>()) {
                    bs60.push_back(r60->left);
                    bs60.push_back(r60->right);
                }
                for (auto* b60 : bs60)
                    if (b60) {
                        auto& be60 = Expression::bind(*b60, dctx60);
                        if (!be60.bad())
                            harvest60(be60);
                    }
            }
        };
        std::function<void(const Scope&)> scan60 = [&](const Scope& sc60) {
            for (auto& mem : sc60.members()) {
                if (mem.kind == SymbolKind::Variable ||
                    mem.kind == SymbolKind::Net)
                    harvestDims60(mem);
                else if (mem.kind == SymbolKind::Instance)
                    scan60(mem.as<InstanceSymbol>().body);
                else if (mem.kind == SymbolKind::InstanceArray) {
                    for (auto* e : mem.as<InstanceArraySymbol>().elements)
                        if (e->kind == SymbolKind::Instance)
                            scan60(e->as<InstanceSymbol>().body);
                }
                else if (mem.kind == SymbolKind::GenerateBlock) {
                    auto& gb60 = mem.as<GenerateBlockSymbol>();
                    if (auto* ce60 = gb60.getConditionExpression())
                        harvest60(*ce60);
                    for (auto* ci60 : gb60.caseItemExpressions)
                        if (ci60)
                            harvest60(*ci60);
                    if (!gb60.isUninstantiated)
                        scan60(gb60);
                }
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan60(*ge);
            }
        };
        for (auto* ti : comp.getRoot().topInstances)
            scan60(ti->body);
        for (auto* pk : comp.getPackages())
            scan60(*pk);
        // The closure, with whole-body ABORT on a class-method callee.  A
        // separate seen-set (not insert().second) so a poisoned body is
        // remembered as visited without ever entering the evaluated set.
        std::set<const SubroutineSymbol*> seen60;
        std::function<void(const SubroutineSymbol&)> walk =
            [&](const SubroutineSymbol& s0) {
                if (!seen60.insert(&s0).second)
                    return;
                bool poisoned60 = false;
                s0.getBody().visit(makeVisitor(
                    [&](auto& v0, const CallExpression& ce0) {
                        if (!ce0.isSystemCall())
                            if (auto* sp0 = std::get_if<const SubroutineSymbol*>(
                                    &ce0.subroutine))
                                if (*sp0) {
                                    auto* oc0 = (*sp0)->getParentScope();
                                    if (oc0 && oc0->asSymbol().kind ==
                                                   SymbolKind::ClassType)
                                        poisoned60 = true;
                                }
                        v0.visitDefault(ce0);
                    }));
                if (poisoned60)
                    return;
                evaldBodies60.insert(&s0);
                s0.getBody().visit(makeVisitor(
                    [&](auto& v0, const CallExpression& ce0) {
                        if (!ce0.isSystemCall())
                            if (auto* sp0 = std::get_if<const SubroutineSymbol*>(
                                    &ce0.subroutine))
                                if (*sp0)
                                    walk(**sp0);
                        v0.visitDefault(ce0);
                    }));
            };
        for (auto* s0 : contAssignRhsCallees9)
            if (s0)
                walk(*s0);
        for (auto* s0 : paramInitCallees9)
            if (s0)
                walk(*s0);
        for (auto* s0 : elabSeeds60)
            walk(*s0);
    }
    return evaldBodies60.count(&sub) != 0;
}

// § subEvaluatedFromParamInit — the subroutines Surelog's ExprEval really
// RUNS while elaborating an instance's parameters.
//
// Reducing a parameter's Rhs executes every function it calls, and resolving a
// parameter REFERENCE inside such an Rhs demands that parameter's value, which
// executes the functions ITS Rhs calls, and so on.  Execution mutates the
// shared body: an unbased-unsized literal assigned to a whole variable is
// rewritten to that variable's width (the § subCalledAsContAssignRhs rule
// again, reached from the parameter side instead of the cont-assign side).
//
// The ENTRY points are the parameters Surelog reduces at all — a
// MULTIDIMENSIONAL one is compiled with Reduce::No, so its Rhs alone never
// runs anything.  Measured (r10fim probes t3/t5/t7), one function body holding
// `l = '0;` and only the parameter declarations varied:
//
//   localparam int             R1 = h2(N);   -> h2's `l = '0;` becomes 64 zeros
//   localparam bit [3:0][15:0] P1 = f1(N);   -> f1's `l = '0;` stays `'0`/-1
//   initial z = f9(1);                       -> f9's `l = '0;` stays `'0`/-1
//
// and the chain is transitive through the multidimensional parameters
// themselves: FuncInModule's only reduced parameter is `int NEXT_N =
// get_next_n(OFFSET_LIST)`, whose argument pulls OFFSET_LIST's value, which
// pulls SUB_N_LIST_P's, which finally runs get_sub_n_list — the function that
// owns the expanded literal.
bool UhdmExporter::subEvaluatedFromParamInit(const SubroutineSymbol& sub) {
    const Scope* home = nullptr;
    for (auto sc = sub.getParentScope(); sc; sc = sc->asSymbol().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
            home = sc;
            break;
        }
    if (!home)
        return false;
    auto it = paramEvalSubsCache.find(home);
    if (it == paramEvalSubsCache.end()) {
        std::set<const SubroutineSymbol*> reached;
        std::set<const slang::ast::ParameterSymbol*> seenParams;
        std::function<void(const Expression&)> walkExpr;
        std::function<void(const SubroutineSymbol&)> walkSub =
            [&](const SubroutineSymbol& s0) {
                if (!reached.insert(&s0).second)
                    return;
                s0.getBody().visit(makeVisitor(
                    [&](auto& v, std::derived_from<Expression> auto& e) {
                        walkExpr(e);
                        v.visitDefault(e);
                    }));
            };
        std::function<void(const slang::ast::ParameterSymbol&)> walkParam =
            [&](const slang::ast::ParameterSymbol& p0) {
                if (!seenParams.insert(&p0).second)
                    return;
                if (auto* pi = p0.getInitializer())
                    pi->visit(makeVisitor(
                        [&](auto& v, std::derived_from<Expression> auto& e) {
                            walkExpr(e);
                            v.visitDefault(e);
                        }));
            };
        walkExpr = [&](const Expression& e) {
            if (e.kind == ExpressionKind::Call) {
                auto& ce = e.as<CallExpression>();
                if (!ce.isSystemCall())
                    if (auto* sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
                        walkSub(**sp);
            }
            else if (e.kind == ExpressionKind::NamedValue) {
                auto& sy = e.as<NamedValueExpression>().symbol;
                if (sy.kind == SymbolKind::Parameter)
                    walkParam(sy.as<slang::ast::ParameterSymbol>());
            }
            else if (e.kind == ExpressionKind::HierarchicalValue) {
                auto& sy = e.as<HierarchicalValueExpression>().symbol;
                if (sy.kind == SymbolKind::Parameter)
                    walkParam(sy.as<slang::ast::ParameterSymbol>());
            }
        };
        std::function<void(const Scope&)> seed = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (mem.kind == SymbolKind::Parameter) {
                    auto& p0 = mem.as<slang::ast::ParameterSymbol>();
                    // Reduce::No for a multidimensional parameter: it is not
                    // an entry point, though it can still be REACHED as a
                    // value dependency of one that is.
                    int nd = 0;
                    const Type* ct = &p0.getType().getCanonicalType();
                    while (ct->kind == SymbolKind::PackedArrayType) {
                        nd++;
                        ct = &ct->as<slang::ast::PackedArrayType>()
                                  .elementType.getCanonicalType();
                    }
                    if (nd < 2)
                        walkParam(p0);
                }
                else if (mem.kind == SymbolKind::GenerateBlock)
                    seed(mem.as<GenerateBlockSymbol>());
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        seed(*ge);
            }
        };
        seed(*home);
        it = paramEvalSubsCache.emplace(home, std::move(reached)).first;
    }
    return it->second.count(&sub) != 0;
}

// § memberActualLeak — Surelog's constant evaluator LEAKS a function body's
// assignment into the struct TYPESPEC.
//
// `ExprEval::setValueInInstance` (UHDM ExprEval.cpp, the two
// `tmp->Actual_value(rhsexp)` sites) resolves an assignment whose Lhs is a
// hier_path through `decodeHierPath(..., ReturnType::MEMBER)`; when that
// lands on a `typespec_member` it stores reduceExpr(rhs) on the MEMBER
// itself — a per-declaration object shared by every user of the struct.  The
// evaluator only ever runs over a function body reached from a CONTINUOUS
// assignment's rhs call (an always-block call never folds), so the leak is a
// def-compile artifact of `assign x = f(...)`, not of the function.
//
// Measured, one mutation at a time, from scr1_ipic.sv (repros
// /tmp/r10scr6_v{1..6}.sv; Scr1SvTests is the corpus instance — its
// type_scr1_search_one_2_s members carry the `|din` / `~din[0]` operations of
// scr1_search_one_2's body, and that ONE object echoed through
// typespec->Instance() recursion into 49 of the test's 106 failing Compare
// vectors):
//   assign r = f(x);      f's body assignments stamp        (v1)
//   always_comb r = f(x); nothing stamps                    (v2)
//   f called from g's body, g the cont-assign rhs: f stamps  (v4/v6)
//   the stamped value is reduceExpr(rhs): a foldable rhs lands as a
//   CONSTANT, an unfoldable one as the rhs expression object itself (v5)
//
// evalStmt() aborts the whole walk the moment `invalidValue` goes true, so
// only a PREFIX of the body is ever reached; scr1_search_one_16's own
// `result.vd = |stage3_vd` is NOT stamped in golden because the for-loop
// ahead of it invalidates first (v4 vs v6 isolate exactly that).  Modelling
// Surelog's invalidation lattice would be an interpreter; we take the
// conservative prefix that is certainly reached — the leading run of
// member-assignments, stopping at the first statement of any other shape.
// Under-stamping loses nothing that was ever emitted; over-stamping would
// invent objects golden does not have.
void UhdmExporter::buildMemberActualLeak() {
    memberLeakAsgs.emplace();
    // Seed: every subroutine called as the DIRECT rhs of a continuous
    // assignment, anywhere in the design.
    std::set<const SubroutineSymbol*> reached;
    struct CaSeedScan
        : slang::ast::ASTVisitor<CaSeedScan, slang::ast::VisitFlags::Symbols> {
        std::set<const SubroutineSymbol*>& out;
        explicit CaSeedScan(std::set<const SubroutineSymbol*>& o) : out(o) {}
        void handle(const slang::ast::ContinuousAssignSymbol& ca) {
            auto& asn = ca.getAssignment();
            if (asn.kind == ExpressionKind::Assignment) {
                const Expression* r =
                    &stripImplicitConv(asn.as<AssignmentExpression>().right());
                if (r->kind == ExpressionKind::Call)
                    if (auto* sp = std::get_if<const SubroutineSymbol*>(
                            &r->as<CallExpression>().subroutine))
                        if (*sp)
                            out.insert(*sp);
            }
            visitDefault(ca);
        }
    };
    CaSeedScan seed(reached);
    comp.getRoot().visit(seed);
    // Closure: a call anywhere in a reached body may itself be evaluated.
    struct BodyCallScan
        : slang::ast::ASTVisitor<BodyCallScan, slang::ast::VisitFlags::Statements |
                                                  slang::ast::VisitFlags::Expressions> {
        std::vector<const SubroutineSymbol*>& out;
        explicit BodyCallScan(std::vector<const SubroutineSymbol*>& o) : out(o) {}
        void handle(const slang::ast::CallExpression& ce) {
            if (auto* sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
                if (*sp)
                    out.push_back(*sp);
            visitDefault(ce);
        }
    };
    std::vector<const SubroutineSymbol*> work(reached.begin(), reached.end());
    while (!work.empty()) {
        const SubroutineSymbol* sub = work.back();
        work.pop_back();
        std::vector<const SubroutineSymbol*> callees;
        BodyCallScan bs(callees);
        sub->getBody().visit(bs);
        for (auto* c : callees)
            if (reached.insert(c).second)
                work.push_back(c);
    }
    // Prefix run of member-assignments in each reached body.
    for (auto* sub : reached) {
        // Unwrap to the statement list Surelog's evalBlock_ walks: the
        // function's `begin ... end`, whose declarations are vpiVariables.
        const slang::ast::Statement* cur = &sub->getBody();
        std::vector<const slang::ast::Statement*> stmts;
        for (int guard = 0; guard < 8; guard++) {
            if (cur->kind == StatementKind::Block) {
                cur = &cur->as<slang::ast::BlockStatement>().body;
                continue;
            }
            stmts.clear();
            if (cur->kind == StatementKind::List) {
                for (auto* st : cur->as<slang::ast::StatementList>().list)
                    if (st->kind != StatementKind::VariableDeclaration)
                        stmts.push_back(st);
                if (stmts.size() == 1 &&
                    stmts[0]->kind == StatementKind::Block) {
                    cur = stmts[0];
                    continue;
                }
            }
            else {
                stmts.push_back(cur);
            }
            break;
        }
        for (auto* st : stmts) {
            // Declarations are the block's vpiVariables, not statements the
            // evaluator walks; they neither stamp nor stop the run.
            if (st->kind == StatementKind::VariableDeclaration)
                continue;
            if (st->kind != StatementKind::ExpressionStatement)
                break;
            auto& e = st->as<slang::ast::ExpressionStatement>().expr;
            if (e.kind != ExpressionKind::Assignment)
                break;
            auto& ae = e.as<AssignmentExpression>();
            if (ae.isCompound() || ae.isNonBlocking())
                break;
            const Expression* l = &stripImplicitConv(ae.left());
            if (l->kind != ExpressionKind::MemberAccess)
                break;
            const Expression* base =
                &stripImplicitConv(l->as<MemberAccessExpression>().value());
            if (base->kind != ExpressionKind::NamedValue)
                break;
            memberLeakAsgs->insert(&e);
        }
    }
}

bool UhdmExporter::memberActualLeak(const Expression& asnExpr) {
    if (!memberLeakAsgs)
        buildMemberActualLeak();
    return memberLeakAsgs->count(&asnExpr) != 0;
}

bool UhdmExporter::isTaskScopeParam9(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto* ps = sym.getParentScope();
    if (!ps)
        return false;
    auto& owner = ps->asSymbol();
    return owner.kind == SymbolKind::Subroutine &&
           owner.as<SubroutineSymbol>().subroutineKind == SubroutineKind::Task;
}

// § emptyFnBodyEndLabelBegin65 — a subroutine with a SYNTACTICALLY EMPTY body
// that is closed with `endfunction : <label>` carries, in golden, a vpiStmt:
// an EMPTY `begin` whose whole span IS THE LABEL'S TOKEN and whose only other
// field is the function's vpiFullName.  The corpus witness is the head of
// SimpleUVM (both modes) and Scoreboard at 575f51d:
//
//   544  protected virtual function void do_open(uvm_tr_stream stream,
//   545                                          time open_time,
//   546                                          string type_name);
//   547  endfunction : do_open
//        ^^^^^^^^^^^^^^^^^^^^^^  golden: begin @547:18-547:25 == `do_open`
//
// FOUR terms and NO others; each is a measured arm cell, not an assumption
// (b1_empty.sv, b2_scopes.sv, b3_taskport.sv — 47 subroutine cells between
// them):
//   * THE END LABEL MUST BE WRITTEN.  The block's span IS that label's token,
//     so an unlabelled `endfunction`/`endtask` leaves golden nothing to locate
//     and it emits none (c05/c07/c08/c20/e08 bare vs c01/c03/c04/c18 begin).
//     Spaces around the colon are irrelevant (`endfunction:d04_nospace`, d04;
//     `endtask: readmemh` is the corpus's own witness).
//   * THE BODY MUST BE SYNTACTICALLY EMPTY — `items` empty.  "No statements" is
//     NOT the test and would over-fire: a body holding only a variable
//     DECLARATION (c17, c21) or only a NULL STATEMENT `;` (d03) is golden-BARE
//     while our emitter gives all three of them a null body.
//   * THE CLASS CONSTRUCTOR IS EXCLUDED, unconditionally: c13 (portless), e22
//     (WITH a port) and e26 (out-of-body, with a port) are all golden-bare, so
//     the exclusion is not the port-list term below.  Surelog compiles the
//     constructor in compileClassConstructorDeclaration, the same split
//     § constructorBodyElementShift27 measures one node further along.
//   * A TASK ALSO NEEDS A NON-EMPTY tf_port_list; a FUNCTION never does.  This
//     is the term my first pass got WRONG and the whole-design per-cell audit
//     of SimpleUVM REFUTED: I wrote "FUNCTION only" off eight golden-bare task
//     cells, every one of which happened to be written `task foo();` — and
//     golden's `task uvm_reg_block::readmemh(string filename); endtask:
//     readmemh` HAS the begin.  b3 separates the two candidate discriminators
//     cell by cell: it is the PORT LIST, not out-of-body-ness (e06 OOB+port
//     fires, e10 OOB+portless bare, e01 in-body+port fires, e02 in-body
//     portless bare, and e03/e04/e09/e20/e21/e23/e24 fire in module, package,
//     interface, explicit-direction, `automatic` and `virtual` shapes).  Not
//     "portList present" but "ports NON-EMPTY": `task t();` and `task t;` are
//     both bare (e02, e28) while `function void f;` with no parens at all
//     fires (e27) — slang builds a FunctionPortList for written parens even
//     when it holds nothing.  The FUNCTION's analogue was tested and REFUTED:
//     a function with no written return type still fires (e12, e16, e19, e27).
// NOT in the gate, because each was measured to carry NO term: scope ($unit,
// module, interface, program, package, class, out-of-body definition),
// virtual / protected / static / automatic, the return type (void, explicit or
// omitted), the formals of a FUNCTION, and one-line vs multi-line layout.
const slang::syntax::NamedBlockClauseSyntax* UhdmExporter::emptyFnBodyEndLabel65(
    const SubroutineSymbol& sub) {
    if ((sub.flags & MethodFlags::Constructor) != MethodFlags::None)
        return nullptr;
    auto* syn = sub.getSyntax();
    if (!syn)
        return nullptr;
    // A TaskDeclaration shares this syntax NODE TYPE with a FunctionDeclaration,
    // which is why the task term below is read off the PORT LIST and not off the
    // node type.
    if (syn->kind != syntax::SyntaxKind::FunctionDeclaration &&
        syn->kind != syntax::SyntaxKind::TaskDeclaration)
        return nullptr;
    auto& fd = syn->as<syntax::FunctionDeclarationSyntax>();
    if (!fd.items.empty())
        return nullptr;
    if (sub.subroutineKind == SubroutineKind::Task &&
        (!fd.prototype->portList || fd.prototype->portList->ports.empty()))
        return nullptr;
    auto* ebn = fd.endBlockName;
    if (!ebn || ebn->name.range().start() == SourceLocation::NoLocation)
        return nullptr;
    return ebn;
}

const slang::ast::FormalArgumentSymbol* UhdmExporter::elabCallFormal(
    const slang::ast::ParameterSymbol& ps) {
    if (!elabCalledSubs) {
        elabCalledSubs.emplace();
        ElabCallScan scan(*elabCalledSubs, elabCallArgs);
        comp.getRoot().visit(scan);
    }
    auto it = elabCallArgs.find(&ps);
    return it == elabCallArgs.end() ? nullptr : it->second;
}

static void copyLoc(UHDM::BaseClass* dst, const UHDM::BaseClass* src) {
    if (dst->VpiFile().empty())
        dst->VpiFile(src->VpiFile());
    dst->VpiLineNo(src->VpiLineNo());
    dst->VpiColumnNo(src->VpiColumnNo());
    dst->VpiEndLineNo(src->VpiEndLineNo());
    dst->VpiEndColumnNo(src->VpiEndColumnNo());
}

// A packed-array typespec written over a vector TYPEDEF (`sha_word_t [7:0]`)
// owns a fresh NAMED element clone.  When the container takes a package's
// vpiInstance, Surelog stamps that clone too — the whole per-use family is
// resolved in the package's scope (PackedUnpackedIo).  An element that
// already carries an instance (its own home package) is left alone.
static void stampElemTsInstance(UHDM::typespec* t0, UHDM::instance* inst) {
    if (!t0 || !inst || t0->UhdmType() != UHDM::uhdmlogic_typespec)
        return;
    auto* et = ((UHDM::logic_typespec*)t0)->Elem_typespec();
    if (!et)
        return;
    auto* at = et->Actual_typespec();
    if (at && !at->VpiName().empty() && !at->Instance())
        at->Instance(inst);
}

// A QUEUE / DYNAMIC-array declaration (`C paths[$]`, `int d[]`) is the same
// array_var shape a fixed-size unpacked array takes, with vpiArrayType
// vpiQueueArray/vpiDynamicArray and an UNBOUNDED array_typespec range:
// [0 : $] (vpiUnboundedConst, size 1) for a queue, [0 : "unsized"]
// (vpiStringConst, size 0) for a dynamic array.  The element typespec is the
// declaration's own (makeTypespec looks through the array dims) and is SHARED
// by the reg and the array_typespec's Elem_typespec.  Surelog, probe-verified
// for class-handle and int elements (ClassVar / LocalScopeHierPath /
// ArrayMethodIterator), for subroutine locals and `begin` block locals alike
// (ApbSlave `svunit_testcase match[$]`).  Returns null when `vs` is not a
// queue or dynamic array.

// § classHomedTypeTsNoPkgInstance4 — a typespec whose TYPE is declared INSIDE A
// CLASS never carries a package `vpiInstance` in Surelog, whatever scope the
// DECLARATION that uses it sits in.
//
// The two facts meet in the array-local helpers because our emission creates ONE
// typespec per typedef and SHARES it: a class method's queue/assoc LOCAL stamps
// the home package (§ queueLocalElemTsInstance40 / § assocLocalArrayVar40, both
// correct for a PACKAGE-homed element type) onto the very object the class's own
// DATA MEMBER points at, and the data member is where uhdm-cmp reaches it.
//
// Measured cell for cell, the same program with the typedef inside the class vs
// in the package (grid q9/q10 for the queue arm, q11 for the associative arm):
//   class-homed typedef   golden `<null>`          ours (pristine) `TOP:p9`
//   package-homed typedef golden `ALL:p10 TOP:p10` ours `ALL:p10 TOP:p10`  PASS
// on the SAME declaration shape.  This is the head on BOTH BuildUVMPkg rows:
// `struct_typespec(m_inst_typename_alias_t)`, the element type of
// `uvm_default_factory::m_inst_aliases[$]`, stamped from that class's
// out-of-body method locals.
static bool classHomedType4(const Type* t) {
    if (!t)
        return false;
    if (const Scope* sc = t->getParentScope())
        if (sc->asSymbol().kind == SymbolKind::ClassType)
            return true;
    if (const Scope* sc = t->getCanonicalType().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::ClassType)
            return true;
    return false;
}

// § nameBasedArrayTdDeclIsRefVar166 — THE FACTORY.  One `ref_var`, bound to
// the typedef's own typespec, in place of the whole array_var / element pair.
//
// The typespec is `makeTypespec(vs)` under `tfContext`, which is EXACTLY how
// `makeQueueDynArrayVar` below computes its ELEMENT typespec — so the OBJECT
// this law binds is the very object the element variable binds today, kind,
// name and span alike (measured: grid166 `g166_a_core` `pqVal166` and the
// corpus head both already read `array_typespec (<td>)` spanned AT THE
// TYPEDEF, which is what golden binds).  Only the VARIABLE changes.
UHDM::ref_var* UhdmExporter::makeNameBasedArrayTdRefVar166(
    const Symbol& vs, const std::string& afull, UHDM::any* parent,
    UHDM::instance* tsInst) {
    if (!nameBasedArrayTdDeclIsRefVar166(vs))
        return nullptr;
    // `tsInst` is taken so this factory has the SAME signature as the three
    // array factories it stands in front of, and is deliberately UNUSED - see
    // the vpiInstance note below.
    (void)tsInst;
    bool savedTfCtx166 = tfContext;
    tfContext = true;
    UHDM::typespec* ts166 = makeTypespec(vs);
    tfContext = savedTfCtx166;
    if (!ts166)
        return nullptr;
    // NO vpiInstance STAMP, and § classHomedTypeTsNoPkgInstance4 is the reason
    // rather than an exception to it: the object bound here is the TYPEDEF's
    // own typespec and the law's HOME GATE has already required that typedef
    // to live in a CLASS, which is exactly the `classHomedType4` case the
    // queue / associative factories suppress the stamp for.  Asking
    // `classHomedType4` about the ELEMENT instead (which is what those
    // factories do, because THEIR typespec is the element's) stamps the class
    // typedef's shared object with the enclosing PACKAGE for an OUT-OF-BODY
    // method — golden reads `<noinst>` on all four of `g166_d_home`'s
    // `oobVal166` / `oobNestVal166` cells, in both views.
    auto* rv166 = s.MakeRef_var();
    rv166->VpiName(vs.name);
    rv166->VpiFullName(afull);
    rv166->VpiParent(parent);
    setLoc(rv166, nameSpan(vs.location, vs.name));
    auto* rt166 = s.MakeRef_typespec();
    rt166->VpiFullName(afull);
    rt166->VpiParent(rv166);
    rt166->Actual_typespec(ts166);
    rv166->Typespec(rt166);
    return rv166;
}

UHDM::array_var* UhdmExporter::makeQueueDynArrayVar(const Symbol& vs,
                                                    const std::string& afull,
                                                    UHDM::any* parent,
                                                    UHDM::instance* tsInst) {
    auto* dt0 = vs.getDeclaredType();
    if (!dt0)
        return nullptr;
    auto& qct0 = dt0->getType().getCanonicalType();
    if (qct0.kind != SymbolKind::QueueType &&
        qct0.kind != SymbolKind::DynamicArrayType)
        return nullptr;
    bool isQueue0 = qct0.kind == SymbolKind::QueueType;
    const Type* qelem0 = isQueue0 ? &qct0.as<QueueType>().elementType
                                  : &qct0.as<DynamicArrayType>().elementType;
    bool savedTfCtx0 = tfContext;
    tfContext = true;
    UHDM::typespec* elemTs = makeTypespec(vs);
    tfContext = savedTfCtx0;
    // § queueLocalElemTsInstance40 — the element typespec carries the same
    // vpiInstance the FIXED-array arm and the flat local already take: the
    // home PACKAGE for a package free function or an OUT-OF-BODY class method,
    // nothing for an IN-BODY one.  The earlier note here ("Surelog leaves a
    // class-method local's typespec unscoped") had only ever seen the in-body
    // spelling, where `tsInst` is null anyway; t57a measures BOTH halves in one
    // golden — `oob57::mQueue57`/`mDyn57` are `int_typespec@pk57` and
    // `inb57::iQueue57` is unscoped — and uhdm-cmp RECURSES a typespec's
    // Instance, so the missing stamp was a compared field.
    // § classHomedTypeTsNoPkgInstance4 gate (site 1 of 2) — see the predicate.
    if (elemTs && tsInst && !elemTs->Instance() && !classHomedType4(qelem0))
        elemTs->Instance(tsInst);
    // § classScopedTdDeclTsUnsupported11, SITE 4a of 5 (queue / dynamic) — the DECLARATOR-ARRAY
    // local.  Golden binds the SAME placeholder object to the array_typespec's
    // ELEMENT ref AND to the element variable's own ref (grid11 `g8`, all four
    // declarator forms, both directions), so the substitution is made on
    // `elemTs` itself — AFTER the vpiInstance stamp above, which golden's
    // placeholder never carries.
    if (auto* uts11 = makeScopedTdUnsupTs11(vs))
        elemTs = uts11;
    // § blockLocalTdDeclIsRefVarUnsupported155, SITE 3 of 6 — the QUEUE /
    // DYNAMIC-ARRAY element.  Same substitution point, same reason: golden's
    // placeholder sits on the ELEMENT (grid155 `warpQueue` / `warpDyn` /
    // `tongsQueue` / `tongsDyn`, both views), and the element VARIABLE becomes
    // a `ref_var` through `declArrayElemVarKind12`.  The vpiInstance stamp two
    // lines above has already run on the DISCARDED resolved typespec, so it is
    // re-applied here from the same `tsInst`.
    else if (auto* uts155 = makeStmtScopeTdUnsupTs155(vs)) {
        if (tsInst)
            uts155->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
        elemTs = uts155;
    }
    auto* av = s.MakeArray_var();
    av->VpiName(vs.name);
    av->VpiFullName(afull);
    av->VpiParent(parent);
    av->VpiArrayType(isQueue0 ? vpiQueueArray : vpiDynamicArray);
    setLoc(av, nameSpan(vs.location, vs.name));
    // The unsized dim: `[$]` for a queue, `[]` for a dynamic array.  Surelog
    // spans the array_typespec from the NAME through the end of that dim's
    // RANGE — the `$` token for a queue, the whole `[]` for a dynamic array.
    const syntax::VariableDimensionSyntax* qdim0 = nullptr;
    if (auto dsyn0 = vs.getSyntax();
        dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
        for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
            qdim0 = dim0;
    SourceRange qrng0(vs.location, vs.location + vs.name.size());
    if (qdim0) {
        auto ds0 = qdim0->sourceRange();
        qrng0 = isQueue0 ? SourceRange(ds0.start() + 1, ds0.end() - 1) : ds0;
    }
    auto* ats = s.MakeArray_typespec();
    setLoc(ats, SourceRange(vs.location, qrng0.end()));
    auto* rng0 = s.MakeRange();
    rng0->VpiParent(ats);
    setLoc(rng0, qrng0);
    auto* lc0 = s.MakeConstant();
    lc0->VpiParent(rng0);
    lc0->VpiDecompile("0");
    lc0->VpiSize(64);
    lc0->VpiValue("UINT:0");
    lc0->VpiConstType(vpiUIntConst);
    if (!isQueue0)
        setLoc(lc0, SourceRange(qrng0.start(), qrng0.start() + 1));
    rng0->Left_expr(lc0);
    auto* rc0 = s.MakeConstant();
    rc0->VpiParent(rng0);
    if (isQueue0) {
        rc0->VpiDecompile("$");
        rc0->VpiSize(1);
        rc0->VpiValue("STRING:$");
        rc0->VpiConstType(vpiUnboundedConst);
        setLoc(rc0, qrng0);
    }
    else {
        rc0->VpiDecompile("unsized");
        rc0->VpiSize(0);
        rc0->VpiValue("STRING:unsized");
        rc0->VpiConstType(vpiStringConst);
        setLoc(rc0, SourceRange(qrng0.start(), qrng0.start() + 1));
    }
    rng0->Right_expr(rc0);
    auto* rvec0 = s.MakeRangeVec();
    rvec0->push_back(rng0);
    ats->Ranges(rvec0);
    auto* ert0 = s.MakeRef_typespec();
    ert0->VpiParent(ats);
    ert0->Actual_typespec(elemTs);
    ats->Elem_typespec(ert0);
    auto* art0 = s.MakeRef_typespec();
    art0->VpiFullName(afull);
    art0->VpiParent(av);
    art0->Actual_typespec(ats);
    av->Typespec(art0);
    // § declArrayElemKindIsDeclKind12, SITE 1 of 4 (queue / dynamic) — the
    // element variable is the SCALAR variable Surelog's compileStmt builds from
    // the DATA-TYPE node and then re-parents under the array_var, so it takes
    // r10sd10's answer for the declaration's WRITTEN base type.  grid12 `h1`.
    auto* reg0 = makeDeclArrayElemVar12(s, vs, *qelem0,
                                        stmtScopeTdDegrades155(vs));
    reg0->VpiParent(av);
    reg0->VpiFullName(afull);
    setLoc(reg0, nameSpan(vs.location, vs.name));
    auto* rrt0 = s.MakeRef_typespec();
    rrt0->VpiFullName(afull);
    rrt0->VpiParent(reg0);
    rrt0->Actual_typespec(elemTs);
    reg0->Typespec(rrt0);
    // § typeParamRetIsRefVar58 — no vpiSigned on a ref_var; the same repeat of
    // the law as the block-item array factory at ~4428.  § declArrayElemKind-
    // IsDeclKind12 joins the same guard: Surelog's paClass_scope / bare-name
    // FALLBACKS compute no signedness at all, so a `class_var` / `ref_var`
    // minted by that law must not carry the flag either.
    // § declArrayElemVarSignedIsAtomKeyword129, SITE 1 of 4 (queue /
    // dynamic) — the flag is the WRITTEN base-type keyword's, not the
    // element type's.  Law + Surelog citations: EmitHelpers.h.
    reg0->VpiSigned(declArrayElemVarSigned129(vs, *qelem0) &&
                    !typeParamVarIsRefVar58(*qelem0) &&
                    declArrayElemVarKind12(vs, stmtScopeTdDegrades155(vs)) ==
                        TdLocalVarKind10::Resolved);
    auto* rv0 = s.MakeVariablesVec();
    rv0->push_back(reg0);
    av->Variables(rv0);
    // A foreach over this queue / dynamic array binds THIS array_typespec
    // (its loop variables still take the ELEMENT type — probe r10c4_p6).
    arrayVarArrayTs[&vs] = ats;
    return av;
}

// § assocLocalArrayVar40 — a BODY-LOCAL ASSOCIATIVE array is an `array_var`
// with its ELEMENT variable under vpiReg and an array_typespec carrying one
// range per written dimension, exactly like the queue / dynamic / fixed forms
// above.  We were emitting the ELEMENT type as a flat variable instead, which
// is 91 of the 383 right-NAME/wrong-UHDM-TYPE rows on all four UVM-4 tests —
// `bit pred_of_succ[uvm_phase]`, `int visited[uvm_phase]`,
// `uvm_port_component_base provided_to_port_list[string]`, every one of them a
// body local of an OUT-OF-BODY class method, every one of them `array_var` in
// golden and `logic_var` in ours.  Decoded on tools/probe/r10uvm40repro/t57a,
// which carries all five declaration forms and both negatives in ONE golden:
//
//   * REACH is every BLOCK-ITEM body — out-of-body class method, in-body class
//     method, package free function, task, nested `begin`, module subroutine.
//     The § blockItems9 TF-ITEM production is the negative: t57a's paren-less
//     `function void iNoParen57;` keeps a flat ELEMENT variable (`int npa` ->
//     int_var), so the caller applies the same gate the queue arm already has.
//   * The RANGE FORM follows Surelog's GRAMMAR, the same split
//     § assocIoRange9 decoded for an associative FORMAL: an index written as a
//     type KEYWORD (`[string]`, `[int]`) is paAssociative_dimension — a
//     `UINT:0 : STRING:associative` marker whose right constant carries the
//     index typespec — while an index written as a NAME (`[uvm_phase]`,
//     `[key57]`) parses as a constant_expression, i.e. a SIZE, and becomes the
//     ordinary `<name> - 1` decrement (an operation vpiSubOp over a ref_obj
//     and an INT:1) with NO vpiIndexTypespec at all.
//   * ...and only the ELABORATED package listing promotes the NAME spelling
//     back to the associative form (vpiArrayType 3 + vpiIndexTypespec).  t57a
//     measures BOTH halves of that: `oob57::mAssocCls57::acls`,
//     `tAssoc57::taq` and `fAssocCls57::facls` are size-model in the DEF
//     listing and assoc-model in the ELAB one, while a NESTED-`begin` local
//     (`fBlkAssoc57::bacls`) and an IN-BODY class method's local
//     (`inb57::iAssocCls57::iacls`) stay size-model in every view — Surelog's
//     ElaborationStep array_var pass reaches a package task_func's own
//     vpiVariables and nothing deeper.  `promoteNamed` IS that gate.
//   * the ELEMENT and INDEX typespecs carry the same vpiInstance the flat
//     local already took (the package for an out-of-body method, nothing for
//     an in-body one) — a compared field, since uhdm-cmp recurses Instance().
//
// Returns null for anything that is not an all-associative declaration; a
// MIXED shape (`int a[string][2]`) is deliberately left to the old path
// because no golden measures it.
// § assocIdxNameHoistNet135 — ONE pool push for ONE associative dimension whose
// index type was written as a NAME.  `ref` is the visible `ref_obj` of the SIZE
// model, or NULL for a dimension the elaborated listing promoted to the
// associative form (Surelog's own reference for that site is orphaned by
// `CompileHelper::compileRanges` and never reaches its database — it still
// mints and spans the wire, and that is the whole reason a ref-less entry
// exists).  The gate is `hoistHomePkg117()` and nothing else: an in-body class
// member's names belong to the CLASS component, whose late-binding list
// `UhdmWriter.cpp:1067` never walks.  The two-vector choice and the staging
// flush are § pkgFreeSubRefVarHoistNet117's own, unchanged.
void UhdmExporter::hoistAssocIdxName135(UHDM::ref_obj* ref,
                                        std::string_view name,
                                        slang::SourceRange range) {
    const Symbol* home135 = hoistHomePkg117();
    if (!home135 || name.empty())
        return;
    auto& pool135 = (inClassBodyEmit && classBodyHomePkg75)
                        ? classPropRefs
                        : pkgFreeSubPropRefs117;
    pool135.push_back({ref, std::string(name), range, home135});
}

// The r11u183 switches (tools/probe/r11u183dec/README.md): every r11u183 law
// reads its own R11U183_<LAW>_OFF switch; R11U183_OFF drops all of them.
// R11U183_TRACE=<dir> names every firing of an r11u183 law (the mover
// census): one file per process, `<dir>/<pid>.<unit>`, its first line the
// `-o` database path read off the command line, then one law name per firing.
static void tr183TF(const char* law) {
    static FILE* tf = [] () -> FILE* {
        const char* d = getenv("R11U183_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".TF";
        FILE* fp = fopen(fn.c_str(), "a");
        if (!fp)
            return nullptr;
        std::string cl, prev, outp;
        if (FILE* c = fopen("/proc/self/cmdline", "r")) {
            int ch;
            while ((ch = fgetc(c)) != EOF) {
                if (ch == 0) {
                    if (prev == "-o")
                        outp = cl;
                    prev = cl;
                    cl.clear();
                }
                else
                    cl += (char)ch;
            }
            fclose(c);
        }
        fprintf(fp, "OUT %s\n", outp.c_str());
        return fp;
    }();
    if (tf) {
        fprintf(tf, "%s\n", law);
        fflush(tf);
    }
}
bool r11u186Law(const char* sw);   // the r11u186 switches (UhdmExporter.cpp)
void trace186(const char* law, const std::string& detail); // R11U186_TRACE
static bool r11u183LawTF(const char* sw) {
    if (getenv("R11U183_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}

UHDM::array_var* UhdmExporter::makeAssocArrayVar(const Symbol& vs,
                                                 const std::string& afull,
                                                 UHDM::any* parent,
                                                 UHDM::instance* tsInst,
                                                 bool promoteNamed) {
    auto* dt0 = vs.getDeclaredType();
    if (!dt0)
        return nullptr;
    if (dt0->getType().getCanonicalType().kind !=
        SymbolKind::AssociativeArrayType)
        return nullptr;
    // Every associative dimension, outermost first, and the innermost element.
    std::vector<const Type*> aidx;
    const Type* elem0 = &dt0->getType();
    for (;;) {
        auto& cc0 = elem0->getCanonicalType();
        if (cc0.kind != SymbolKind::AssociativeArrayType)
            break;
        aidx.push_back(cc0.as<AssociativeArrayType>().indexType);
        elem0 = &cc0.as<AssociativeArrayType>().elementType;
    }
    if (aidx.empty())
        return nullptr;
    switch (elem0->getCanonicalType().kind) {
        case SymbolKind::FixedSizeUnpackedArrayType:
        case SymbolKind::DynamicArrayType:
        case SymbolKind::QueueType:
            return nullptr;
        default:
            break;
    }
    // The declarator's written dimensions, so each range and index typespec is
    // spanned at the `[...]` it came from and the KEYWORD/NAME split can be
    // read off the selector's syntax kind (the same test emitAssocDims makes).
    std::vector<const syntax::VariableDimensionSyntax*> dims;
    if (auto dsyn0 = vs.getSyntax();
        dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
        for (auto d0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
            dims.push_back(d0);
    auto selOf = [&](size_t i) -> const syntax::ExpressionSyntax* {
        if (i >= dims.size())
            return nullptr;
        auto* d0 = dims[i];
        if (!d0->specifier)
            return nullptr;
        auto* rd0 =
            d0->specifier->as_if<syntax::RangeDimensionSpecifierSyntax>();
        if (!rd0 || rd0->selector->kind != syntax::SyntaxKind::BitSelect)
            return nullptr;
        return rd0->selector->as<syntax::BitSelectSyntax>().expr.get();
    };
    auto namedIdx0 = [&](size_t i) {
        auto* e0 = selOf(i);
        return e0 && (e0->kind == syntax::SyntaxKind::IdentifierName ||
                      e0->kind == syntax::SyntaxKind::ScopedName);
    };
    // § assocIdxNameHoistNet135 — the index NAME exactly as written, which is
    // the name Surelog's `compileExpression` gives the `ref_obj` it mints for
    // the bracket text and therefore the name of the implicit wire.
    auto idxName135 = [&](size_t i) {
        std::string n135;
        auto* e0 = selOf(i);
        if (!e0)
            return n135;
        if (e0->kind == syntax::SyntaxKind::IdentifierName)
            n135 = std::string(
                e0->as<syntax::IdentifierNameSyntax>().identifier.valueText());
        else {
            n135 = e0->toString();
            while (!n135.empty() && std::isspace((unsigned char)n135.front()))
                n135.erase(n135.begin());
            while (!n135.empty() && std::isspace((unsigned char)n135.back()))
                n135.pop_back();
        }
        return n135;
    };
    // Is dimension i compiled as an ASSOCIATIVE dimension here?  A keyword
    // always is; a NAME only in the promoted (elaborated-listing) view.
    auto assocDim0 = [&](size_t i) { return !namedIdx0(i) || promoteNamed; };
    bool savedTfCtx0 = tfContext;
    tfContext = true;
    UHDM::typespec* elemTs = makeTypespec(vs);
    tfContext = savedTfCtx0;
    // § classHomedTypeTsNoPkgInstance4 gate (site 2 of 2) — the ASSOCIATIVE arm,
    // measured separately (grid q11) rather than generalised from the queue arm.
    if (elemTs && tsInst && !elemTs->Instance() && !classHomedType4(elem0))
        elemTs->Instance(tsInst);
    // § classScopedTdDeclTsUnsupported11, SITE 4b of 5 (associative) — the DECLARATOR-ARRAY
    // local.  Golden binds the SAME placeholder object to the array_typespec's
    // ELEMENT ref AND to the element variable's own ref (grid11 `g8`, all four
    // declarator forms, both directions), so the substitution is made on
    // `elemTs` itself — AFTER the vpiInstance stamp above, which golden's
    // placeholder never carries.
    if (auto* uts11 = makeScopedTdUnsupTs11(vs))
        elemTs = uts11;
    // § blockLocalTdDeclIsRefVarUnsupported155, SITE 4 of 6 — the ASSOCIATIVE
    // element (grid155 `warpAssoc` / `tongsAssoc`, both views).
    else if (auto* uts155 = makeStmtScopeTdUnsupTs155(vs)) {
        if (tsInst)
            uts155->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
        elemTs = uts155;
    }
    auto* av = s.MakeArray_var();
    av->VpiName(vs.name);
    av->VpiFullName(afull);
    av->VpiParent(parent);
    av->VpiArrayType(assocDim0(0) ? vpiAssocArray : vpiStaticArray);
    setLoc(av, nameSpan(vs.location, vs.name));
    auto* ats = s.MakeArray_typespec();
    {
        // Through the CLOSING bracket of the last written dimension — one
        // short of it while the leading dimension is still the un-promoted
        // SIZE form, which is where Surelog's two compiles differ.
        SourceLocation aEnd0 = vs.location + vs.name.size();
        if (!dims.empty())
            aEnd0 = dims.back()->sourceRange().end() -
                    (assocDim0(0) ? 0 : 1);
        setLoc(ats, SourceRange(vs.location, aEnd0));
    }
    auto* rs0 = s.MakeRangeVec();
    for (size_t i0 = 0; i0 < aidx.size(); i0++) {
        auto* d0 = i0 < dims.size() ? dims[i0] : nullptr;
        auto* sx0 = selOf(i0);
        auto* r0 = s.MakeRange();
        r0->VpiParent(ats);
        if (d0)
            setLoc(r0, d0->sourceRange());
        auto* lc0 = s.MakeConstant();
        lc0->VpiParent(r0);
        lc0->VpiDecompile("0");
        lc0->VpiSize(64);
        lc0->VpiValue("UINT:0");
        lc0->VpiConstType(vpiUIntConst);
        r0->Left_expr(lc0);
        // § assocPromotedBoundAtBracket183 (r11u183, R11U183_RANGEFILE_OFF) —
        // a NAME index the elaborated listing PROMOTES is built by
        // CompileHelper::compileRanges' reduce branch (CompileExpression.cpp,
        // the `rexp` ref_obj + compileTypespec arm), which populates BOTH
        // marker constants from the Packed_dimension node and then writes
        // VpiEndColumnNo(Column + 1): file, line and column of the `[`, one
        // column wide.  The keyword form (paAssociative_dimension arm) leaves
        // both constants unlocated, as the size model does.
        // Its own switch R11U183_ASSOCBRACKET_OFF (r11u186), beside the
        // family's R11U183_RANGEFILE_OFF.
        // § assocBracketPkgOnly186 (r11u186) — the refinement found on the
        // r11u183 grid (a/c18) and this pass's (A n05-n07): a `$unit` class
        // or subroutine (no package above the declaration) is compiled
        // without the elaborated listing that promotes the NAME index, so
        // golden leaves both markers unlocated there (c18 `bit m[e]` in
        // `function void c::f()`, golden `constant` with no location, the
        // law 6:9-6:10); only a declaration inside a package takes the
        // bracket.  Switch R11U186_ASSOCPKG_OFF.
        bool inPkg186 = true;
        if (r11u186Law("R11U186_ASSOCPKG_OFF")) {
            inPkg186 = false;
            for (auto* sc186 = vs.getParentScope(); sc186;
                 sc186 = sc186->asSymbol().getParentScope())
                if (sc186->asSymbol().kind == SymbolKind::Package) {
                    inPkg186 = true;
                    break;
                }
        }
        const bool atBracket183 = d0 && namedIdx0(i0) && assocDim0(i0) &&
                                  r11u183LawTF("R11U183_RANGEFILE_OFF") &&
                                  r11u183LawTF("R11U183_ASSOCBRACKET_OFF") &&
                                  (inPkg186 ||
                                   (trace186("assocBracketPkgOnly186", std::string(vs.name)),
                                    false));
        if (atBracket183) {
            tr183TF("assocPromotedBoundAtBracket183");
            setLoc(lc0, SourceRange(d0->sourceRange().start(),
                                    d0->sourceRange().start() + 1));
        }
        // The index typespec of this dimension, spanned at its selector.
        UHDM::typespec* its0 = nullptr;
        if (assocDim0(i0) && aidx[i0])
            if ((its0 = assocIndexTs(*aidx[i0], vs))) {
                // § sharedAliasNoStamp41 — a TYPEDEF-NAME index resolves to
                // the ONE shared typespec object every user of that typedef
                // points at, and golden USES IT AS IT STANDS: t58a's promoted
                // `int ab[b8]` index is `bit_typespec (b8) @31:11` — the
                // typedef's own span, name and vpiInstance — while pass 40
                // re-spanned it to the `[b8]` bracket and thereby moved a
                // module-level `pkb::b8 t` and every other user with it.  So
                // NONE of the three stamps below may touch a shared alias, and
                // the test is POINTER IDENTITY against the typedef registries
                // (EITHER view), not the index type's canonical kind — a
                // KIND:NAME test cannot answer an IDENTITY question.
                // `typedef int myint` is
                // canonically a PredefinedIntegerType and sailed through the
                // kind guard this replaces (measured: 6 `myint` occurrences
                // re-spanned to 60:12).
                // § arrayElemTdClone42 widens the same guard by one predicate:
                // a per-declaration named clone is not registry-shared, yet
                // golden keeps it at the TYPEDEF's span and shares it with the
                // array_var's element `reg`.
                const bool shared0 = isSharedAliasTs(*aidx[i0], its0) ||
                                     isTdVecClone42(its0);
                if (!shared0) {
                    if (sx0)
                        setLoc(its0, sx0->sourceRange());
                    else if (d0)
                        setLoc(its0,
                               SourceRange(d0->sourceRange().start() + 1,
                                           d0->sourceRange().end() - 1));
                    if (tsInst && !its0->Instance())
                        its0->Instance(tsInst);
                    // An `[int]`-style index keeps its SIGN.
                    // predefIntTypespec deliberately drops vpiSigned because
                    // the io_decl / local copy Surelog hands back is the
                    // unsigned-looking one (PreprocFunc), but the INDEX
                    // typespec of an associative dimension carries it — t57a
                    // `mAssocInt57::aint`, where it was the last cmp
                    // difference left in the arm.
                    if (aidx[i0]->getCanonicalType().kind ==
                            SymbolKind::PredefinedIntegerType &&
                        aidx[i0]->isSigned() &&
                        its0->UhdmType() == UHDM::uhdmint_typespec)
                        ((UHDM::int_typespec*)its0)->VpiSigned(true);
                }
            }
        if (!assocDim0(i0)) {
            // The SIZE model: `<name> - 1`, exactly as § assocIoRange9 builds
            // it for an associative formal written the same way.
            if (sx0)
                setLoc(r0, sx0->sourceRange());
            auto* op0 = s.MakeOperation();
            op0->VpiParent(r0);
            op0->VpiOpType(vpiSubOp);
            auto* ops0 = s.MakeAnyVec();
            auto* ro0 = s.MakeRef_obj();
            ro0->VpiParent(op0);
            std::string in0;
            if (sx0) {
                setLoc(op0, sx0->sourceRange());
                setLoc(ro0, sx0->sourceRange());
                if (sx0->kind == syntax::SyntaxKind::IdentifierName)
                    in0 = std::string(sx0->as<syntax::IdentifierNameSyntax>()
                                          .identifier.valueText());
                else {
                    in0 = sx0->toString();
                    while (!in0.empty() &&
                           std::isspace((unsigned char)in0.front()))
                        in0.erase(in0.begin());
                    while (!in0.empty() &&
                           std::isspace((unsigned char)in0.back()))
                        in0.pop_back();
                }
            }
            ro0->VpiName(in0);
            // § assocIdxNameHoistNet135 — the SIZE model keeps the reference,
            // so this entry BINDS it to the hoisted wire.
            if (sx0 && aidx[i0] && assocIdxNameHoistable135(*aidx[i0], sx0))
                hoistAssocIdxName135(ro0, in0, sx0->sourceRange());
            ops0->push_back(ro0);
            auto* one0 = s.MakeConstant();
            one0->VpiValue("INT:1");
            one0->VpiConstType(vpiIntConst);
            one0->VpiSize(64);
            ops0->push_back(one0);
            op0->Operands(ops0);
            r0->Right_expr(op0);
        }
        else {
            // § assocIdxNameHoistNet135 — the elaborated listing PROMOTED this
            // dimension, so Surelog's reference for it is orphaned: a REF-LESS
            // pool entry, which mints and spans the wire and binds nothing.
            if (sx0 && aidx[i0] && assocIdxNameHoistable135(*aidx[i0], sx0))
                hoistAssocIdxName135(nullptr, idxName135(i0),
                                     sx0->sourceRange());
            auto* rc0 = s.MakeConstant();
            rc0->VpiParent(r0);
            rc0->VpiDecompile("associative");
            rc0->VpiSize(0);
            rc0->VpiValue("STRING:associative");
            rc0->VpiConstType(vpiStringConst);
            // § assocPromotedBoundAtBracket183 — the right marker too.
            if (atBracket183)
                setLoc(rc0, SourceRange(d0->sourceRange().start(),
                                        d0->sourceRange().start() + 1));
            if (its0) {
                auto* irt0 = s.MakeRef_typespec();
                irt0->VpiParent(rc0);
                irt0->Actual_typespec(its0);
                rc0->Typespec(irt0);
            }
            r0->Right_expr(rc0);
        }
        // vpiIndexTypespec is the OUTERMOST dimension's index type only.
        if (i0 == 0 && its0) {
            auto* xrt0 = s.MakeRef_typespec();
            xrt0->VpiParent(ats);
            xrt0->Actual_typespec(its0);
            ats->Index_typespec(xrt0);
        }
        rs0->push_back(r0);
    }
    ats->Ranges(rs0);
    auto* ert0 = s.MakeRef_typespec();
    ert0->VpiParent(ats);
    ert0->Actual_typespec(elemTs);
    ats->Elem_typespec(ert0);
    auto* art0 = s.MakeRef_typespec();
    art0->VpiFullName(afull);
    art0->VpiParent(av);
    art0->Actual_typespec(ats);
    av->Typespec(art0);
    // § declArrayElemKindIsDeclKind12, SITE 2 of 4 (associative).  grid12 `h1`.
    auto* reg0 = makeDeclArrayElemVar12(s, vs, *elem0,
                                        stmtScopeTdDegrades155(vs));
    reg0->VpiParent(av);
    reg0->VpiFullName(afull);
    setLoc(reg0, nameSpan(vs.location, vs.name));
    auto* rrt0 = s.MakeRef_typespec();
    rrt0->VpiFullName(afull);
    rrt0->VpiParent(reg0);
    rrt0->Actual_typespec(elemTs);
    reg0->Typespec(rrt0);
    // § typeParamRetIsRefVar58 + § declArrayElemKindIsDeclKind12 — see the
    // queue arm's note; the same two guards, for the same reason.
    // § declArrayElemVarSignedIsAtomKeyword129, SITE 2 of 4 (associative)
    // — THIS is the BuildUVMPkg head: `uvm_check_e field_check_restore
    // [uvm_reg_field]`, an int-based enum typedef whose element enum_var
    // golden leaves unsigned.  Law + Surelog citations: EmitHelpers.h.
    reg0->VpiSigned(declArrayElemVarSigned129(vs, *elem0) &&
                    !typeParamVarIsRefVar58(*elem0) &&
                    declArrayElemVarKind12(vs, stmtScopeTdDegrades155(vs)) ==
                        TdLocalVarKind10::Resolved);
    auto* rv0 = s.MakeVariablesVec();
    rv0->push_back(reg0);
    av->Variables(rv0);
    // § foreachAssocLocalSharesDeclTs183 (r11u183, R11U183_UARANGE_OFF) — a
    // foreach over this associative local binds THIS array_typespec (ranges,
    // bound constants, index and element refs), as the queue arm above does:
    // golden's ref_var 'predecessors' in uvm_phase::get_adjacent_predecessor_
    // nodes is the declaration's own object (uvm_pkg.sv 34544:8-31), where the
    // drain's fallback minted a bare, rangeless array_typespec (map N0142).
    // Grid tools/probe/r11u183dec/cases/d f01, f02, f06.
    // Only a listing that compiled EVERY dimension associatively (a NAME
    // index is promoted in the elaborated listing alone): the definition
    // listing's size-model object is not the one golden binds (grid d f01).
    bool allAssoc183 = true;
    for (size_t i183 = 0; i183 < aidx.size(); i183++)
        if (!assocDim0(i183))
            allAssoc183 = false;
    if (allAssoc183 && r11u183LawTF("R11U183_UARANGE_OFF")) {
        tr183TF("foreachAssocLocalSharesDeclTs183");
        arrayVarArrayTs[&vs] = ats;
    }
    return av;
}

void UhdmExporter::emitTaskFuncs(const Scope& body, UHDM::BaseClass* m,
                                 const std::string& prefix, DefInfo* info,
                                 bool sharedScope, const Symbol* onlySub) {
    bool genScope = m->UhdmType() == UHDM::uhdmgen_scope;
    bool designScope = m->UhdmType() == UHDM::uhdmdesign;
    bool classScope = m->UhdmType() == UHDM::uhdmclass_defn;
    // Packages (and classes) use :: separators below the function name too.
    bool pkgScope = prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0;
    std::string sep = pkgScope ? "::" : ".";
    auto* savedPkgInst = pkgScopeInst;
    pkgScopeInst = (pkgScope && !classScope) ? (UHDM::instance*)m : nullptr;
    // The package these subroutines live in (null outside a package).
    const Symbol* homePkgSym =
        (pkgScope && !classScope) ? &body.asSymbol() : nullptr;
    // True when `ts0` IS the shared typedef object of a type declared in a
    // DIFFERENT package (`other_pkg::T` used here without an import clone).
    // Surelog creates that object once, in its declaring package, and the
    // using package neither re-instances nor relocates it — PackFunc's
    // b::foo_bar_t named by package aa's function. A freshly minted clone is
    // NOT the shared object and still takes this package's stamp.
    auto foreignSharedTs = [&](const Symbol& declSym,
                               const UHDM::typespec* ts0) {
        if (!ts0 || !foreignPkgTypedef(declSym, homePkgSym))
            return false;
        const auto* ty0 = &declSym.getDeclaredType()->getType();
        if (auto i0 = typedefTs.find(ty0);
            i0 != typedefTs.end() && i0->second == ts0)
            return true;
        auto t0 = pkgTopTypedefTs.find((const void*)ty0);
        return t0 != pkgTopTypedefTs.end() && t0->second == ts0;
    };
    // A use in the DEF pass binds the def-listing object because the home
    // package's ELABORATED listing does not exist yet (packages are emitted
    // def-pass-first). Surelog binds the elaborated object in BOTH views —
    // the same rule makeTypespec already applies to signal uses — so record
    // the ref and re-point it once the top listings are built (PackFunc).
    auto deferForeignTopTs = [&](const Symbol& declSym, UHDM::ref_typespec* rt0,
                                 const UHDM::typespec* ts0) {
        if (pkgTopEmit || !rt0 || !foreignSharedTs(declSym, ts0))
            return;
        pkgForeignTsTopFixups.emplace_back(
            rt0, &declSym.getDeclaredType()->getType());
    };
    auto* tfs = s.MakeTask_funcVec();
    // Captured here: the body-statement local below shadows `body`.
    const Symbol* scopeSym9 = &body.asSymbol();
    // ---------------------------------------------------------------- items
    // Ordinarily a scope emits its own members. A CLASS whose methods are
    // declared `extern` emits TWO groups: every prototype (in declaration
    // order) and then every OUT-OF-BODY DEFINITION. slang keeps those
    // definition SubroutineSymbols out of every scope's member list
    // (Compilation::addOutOfBlockDecl), so members() alone finds NOTHING for
    // such a class — they are reachable only through
    // MethodPrototypeSymbol::getSubroutine(). Surelog lists the definitions
    // in DEFINITION-FILE order with the CONSTRUCTOR moved LAST (it binds
    // constructors in a second pass), which is why svunit_base reads
    // get_name(68), report(77), get_results(87), new(59).
    std::vector<const Symbol*> memberList;
    for (auto& member : body.members())
        memberList.push_back(&member);
    // The def-view package CLONE pass emits the second group ALONE.
    bool cloneMode = pkgClassTfClone != nullptr && classScope;
    std::vector<const Symbol*> items;
    if (!cloneMode)
        items = memberList;
    // § dpiExportListedAtExportItem216 — the LISTING keys, recorded 1:1 with
    // `tfs` as it is filled and applied once the walk is over.  The walk
    // itself is NEVER reordered (creation order is load-bearing for binding).
    std::vector<size_t> tfItemKey216, tfExpKey216;
    bool anyDpiExport216 = false;
    const size_t infoBase216 = info ? info->taskFuncs.size() : 0;
    std::vector<const Symbol*> oobDefs;
    if (classScope) {
        for (auto& member : body.members()) {
            if (member.kind != SymbolKind::MethodPrototype)
                continue;
            auto& mp0 = member.as<MethodPrototypeSymbol>();
            if (mp0.flags.has(MethodFlags::Pure))
                continue;
            auto* impl0 = mp0.getSubroutine();
            // The definition's parentScope IS the class (slang re-parents it
            // there), so scope identity does not separate the two groups —
            // MEMBERSHIP does: an out-of-body definition is exactly the
            // subroutine members() never yields.
            if (!impl0 || !impl0->getSyntax())
                continue;
            if (std::find(memberList.begin(), memberList.end(),
                          (const Symbol*)impl0) != memberList.end())
                continue;
            oobDefs.push_back(impl0);
        }
        std::stable_sort(oobDefs.begin(), oobDefs.end(),
                         [](const Symbol* a, const Symbol* b) {
                             bool ca = a->name == "new", cb = b->name == "new";
                             if (ca != cb)
                                 return cb;
                             if (ca && cb)
                                 return false;
                             return a->location < b->location;
                         });
        for (auto* d0 : oobDefs) {
            if (cloneMode && (d0->name == "new") != pkgClassTfCloneCtors)
                continue;
            items.push_back(d0);
        }
    }
    // True for the second group: the definition's own listing fields differ
    // from an in-class method's (measured on ApbSlave's svunit classes).
    auto isOutOfBody = [&](const Symbol* sy) {
        return std::find(oobDefs.begin(), oobDefs.end(), sy) != oobDefs.end();
    };
    // § oobParamClassTypeParamFormalUnsupported31 — ...and because it is
    // compiled in the PACKAGE's scope, the class's own TYPE PARAMETERS are
    // not in scope there: a formal written as a bare `REQ` falls through
    // Surelog's CompileType catch-all to an `unsupported_typespec` NAMED AS
    // WRITTEN (the same catch-all the covergroup-handle and cover-cross arms
    // of TypeEmit already model), where we resolve it to the specialization's
    // actual type.  Returns the written parameter name, or empty.
    //
    // Measured on t41b, every cell BOTH directions, and the discriminator is
    // exactly out-of-body-ness — golden lists `uvm_sequencer::item_done`
    // TWICE in the elaborated uvm_pkg and gives the PROTOTYPE listing
    // `class_typespec 'uvm_sequence_item'` and the DEFINITION listing
    // `unsupported_typespec 'RSP'@uvm_pkg`, and we already agree on the first:
    //   e_mixed(input lit_t a, input REQ t) -> `lit_t` RESOLVED, `REQ` not
    //   in-body i_req(input REQ t)          -> RESOLVED  (not out-of-body)
    //   plainx31::e_plain (oob, class NOT parameterised) -> RESOLVED
    //   vparam31 #(int W) ... (input logic [W-1:0] a)    -> RESOLVED
    //     (a VALUE parameter is not a type parameter; the range folds)
    //   e_deflt(input REQ t = null) -> unsupported AND keeps its default
    //   pure virtual pv_cls(PT s) (in-class) -> RESOLVED
    // NOT modelled (measured, left): a typedef OF a type parameter
    // (`typedef REQ this_r_t;` used as a formal) is unsupported only in the
    // IMPORT COPIES of the definition and resolved in the declaring package's
    // own listing — an asymmetry no single predicate here can express; and
    // `uvm_resource_types::rsrc_q_t`, a SCOPED name into another class (21
    // rows), which is a different catch-all.
    auto oobClassTypeParamName31 =
        [&](const syntax::DataTypeSyntax* tsyn) -> std::string_view {
        if (!classScope || !tsyn ||
            tsyn->kind != syntax::SyntaxKind::NamedType)
            return {};
        auto& nt31 = tsyn->as<syntax::NamedTypeSyntax>();
        if (nt31.name->kind != syntax::SyntaxKind::IdentifierName)
            return {};
        auto id31 =
            nt31.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (id31.empty())
            return {};
        const Symbol* f31 = body.find(id31);
        if (f31 && f31->kind == SymbolKind::TypeParameter)
            return id31;
        return {};
    };
    // § oobClassTypeParamLocalUnsupported105 — THE BODY-LOCAL HALF OF
    // § oobParamClassTypeParamFormalUnsupported31, decoded from Surelog and
    // measured on golden in both views.
    //
    // > A subroutine DEFINED OUT OF BODY is compiled with the enclosing
    // > PACKAGE (or `$unit`, or the module) as the component
    // > (`CompilePackage.cpp:213` hands `m_package` to `compileFunction`;
    // > `CompileStmt.cpp:2692`'s `paClass_scope` arm only RENAMES the function
    // > `cls::meth` and never switches the scope).  The class's own type
    // > parameters are therefore not on that component's lexical chain, so a
    // > BODY LOCAL written as a bare `REQ` falls through
    // > `CompileHelper::compileDatastructureTypespec`'s catch-all
    // > (`CompileType.cpp:1053`) to an `unsupported_typespec` carrying the
    // > WRITTEN name, stamped with the component's instance
    // > (`CompileType.cpp:2135-2136`) — the DECLARING PACKAGE, and NOTHING when
    // > the class's home is `$unit` or a module.  `ElaborationStep::
    // > bindTypedefs_` repairs such a placeholder ONLY from its design-wide
    // > `specs` map (`ElaborationStep.cpp:328-357`), which is filled from
    // > TYPEDEFS ALONE — a type PARAMETER is never in it, so the placeholder is
    // > PERMANENT.
    //
    // The predicate is § 31's, unchanged and SHARED (`oobClassTypeParamName31`
    // below), plus ONE guard this arm measured and § 31 never had to:
    //
    //   g105_a3 `s105` — a package that ALSO declares a TYPEDEF of the same
    //   simple name as the class's type parameter.  Golden RESOLVES the
    //   out-of-body local to THAT TYPEDEF (`int_typespec 'T105COLLIDE'`), not
    //   to a placeholder and not to the parameter's default — because the
    //   package's own type table answers first.  So a name the class's HOME
    //   SCOPE CHAIN can answer with a typedef is NOT this law's.
    //
    // The whole grid, read off golden (LHS) in both views, `def` and `elab`:
    //   OUT-OF-BODY body local, the class's OWN parameter  (a1 `xo_t`)
    //                                          -> unsupported 'T'  @p105
    //   ...defaulted from another parameter    (a1 `xo_u`, `type U = T`)
    //                                          -> unsupported 'U'  @p105
    //   ...defaulted to an INT                 (a1 `xo_w`, `type W = int`)
    //                                          -> unsupported 'W'  @p105
    //     (the DEFAULT's kind is irrelevant — we emitted `int_typespec` there)
    //   ...in a task / a static method / a void method / a method with a
    //      RETURN type (a1 `to_t`, `so_t`, `zo_t`, `yo_t`)  -> all unsupported
    //   ...WITH AN INITIALISER (a3 `xo_init`)   -> unsupported 'XT' @x105
    //   ...two methods of one class (a3 `wo_1`/`wo_2`) -> ONE OBJECT EACH
    //   ...an INHERITED parameter, out-of-body (a2 `do_t`) -> unsupported @q105
    //   ...the class's home is `$unit` (a2 `uo_t`) or a MODULE (a2 `mo_t`)
    //                                          -> unsupported, NO vpiInstance
    //   ...the SPECIALISED copy in a module (a1 TOPMOD) / an IMPORTER package's
    //      copy (the corpus: MiniAmiq's `svaunit_pkg`) -> unsupported, and the
    //      instance stays the DECLARING package
    //   IN-BODY body local, same parameter (a1 `lo_t`, a2 `ib_u`)
    //                                          -> RESOLVED (`class_typespec`)
    //   OUT-OF-BODY local typed by a TYPEDEF OF the parameter (a1 `xo_td`)
    //                                          -> RESOLVED, named `my_t`
    //   OUT-OF-BODY local of a plain class / a plain typedef / an int
    //      (a1 `xo_cls`, `xo_pln`, a2 `po_c`, `po_i`)      -> RESOLVED
    //   OUT-OF-BODY local whose RANGE names a VALUE parameter (a2 `vo_v`)
    //                                          -> RESOLVED (`logic_typespec`)
    //   OUT-OF-BODY local shadowed by a package typedef (a3 `so_c`)
    //                                          -> RESOLVED to the TYPEDEF
    //
    // MEASURED AND DELIBERATELY NOT MODELLED (each a residue of this pass, all
    // with ZERO corpus reach — the fence over both pristine corpora found no
    // site):
    //   * the ARRAY spellings (a3 `uo_fix`/`uo_q`/`uo_dyn`): golden puts the
    //     placeholder on the ELEMENT `ref_var`, a different emission site;
    //   * the SCOPED spelling `c::T` as a local (a3 `vo_scoped`) or as an
    //     out-of-body RETURN type (a1 `oob_ret`, which is the only spelling
    //     slang accepts there): golden degrades those too, named with the
    //     written text;
    //   * an out-of-body NESTED-BLOCK local (`begin REQ l_oob2; ... end`,
    //     r10uvm87repro/v87_a3_oob.sv): golden degrades it exactly like a
    //     top-level body local, but our block-item declarations are emitted at
    //     a different site, which this branch does not reach.
    //
    // The guard walks the class's own SCOPE CHAIN and then every PACKAGE and
    // COMPILATION UNIT the compilation holds, because Surelog's `specs` map is
    // DESIGN-WIDE and keyed by the BARE name: arm a3's `t105` puts the
    // colliding typedef in a package `t105` does NOT import, and golden STILL
    // repairs the placeholder from it (`int_typespec 't105other::T105FAR'`).
    // The walk runs ONLY when the law is about to fire — an out-of-body local
    // written as a type parameter, six sites in the whole UVM tree — so it
    // never becomes a per-declaration cost.
    auto oobTpLocalShadowedByTd105 = [&](std::string_view id105) -> bool {
        auto isTd105 = [&](const Scope* sc105) {
            if (!sc105)
                return false;
            const Symbol* f105 = sc105->find(id105);
            return f105 != nullptr && f105->kind == SymbolKind::TypeAlias;
        };
        for (auto sc105 = body.asSymbol().getParentScope(); sc105;
             sc105 = sc105->asSymbol().getParentScope())
            if (isTd105(sc105))
                return true;
        for (auto* pk105 : comp.getPackages())
            if (isTd105(pk105))
                return true;
        for (auto* cu105 : comp.getCompilationUnits())
            if (isTd105(cu105))
                return true;
        return false;
    };
    // § baseClassTypeParamFormalUnsupported34 — the SAME catch-all,
    // one scope over.
    //
    // > A formal written as a TYPE PARAMETER the class does not itself
    // > declare — one it only INHERITS from a parameterised base — falls
    // > through Surelog's CompileType to an `unsupported_typespec` NAMED AS
    // > WRITTEN, with NO vpiInstance and its own object per declaration.
    //
    // § oobParamClassTypeParamFormalUnsupported31 found the same degradation
    // for an OUT-OF-BODY definition (compiled in the package's scope, where
    // the class's own parameters are not visible); this is an IN-BODY formal
    // whose name is simply not in the derived class's data-type table.
    // t46a pins the predicate on the SPELLING, not on the resolved type:
    // `deri46 extends basei46 #(int)` writing `di_node(IP46 n)` gets
    // `unsupported_typespec 'IP46'` where the identical `di_ctl(int n)` gets
    // `int_typespec ''`, and a name INHERITED as an ordinary typedef
    // (`ns46use46::e_scq(nsq46_t q)`) resolves normally — it is
    // type-parameter-ness plus not-declared-here.  Reach: 12 rows, three on
    // every UVM-4 test — `uvm_component_proxy::get_immediate_children`'s two
    // `STRUCTURE` formals and `uvm_component_name_check_visitor::visit`'s
    // `NODE`, both parameters of `uvm_structure_proxy` / `uvm_visitor`.
    auto baseTypeParamName34 =
        [&](const syntax::DataTypeSyntax* tsyn) -> std::string_view {
        if (!classScope || !tsyn ||
            tsyn->kind != syntax::SyntaxKind::NamedType)
            return {};
        auto& nt34 = tsyn->as<syntax::NamedTypeSyntax>();
        if (nt34.name->kind != syntax::SyntaxKind::IdentifierName)
            return {};
        auto id34 =
            nt34.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (id34.empty())
            return {};
        // slang re-publishes every inherited member into the derived class's
        // own scope as a TRANSPARENT wrapper, so `find` alone cannot tell
        // "declared here" from "inherited" — the wrapper IS the distinction.
        // slang's derived-class scope answers `find` with the BASE's own
        // parameter symbol, so the discriminator is not whether the name
        // resolves but WHERE it was declared.
        const Symbol* f34 = body.find(id34);
        if (!f34 || f34->kind != SymbolKind::TypeParameter ||
            f34->getParentScope() == &body)
            return {};
        return id34;
    };
    // § classScopedTdFormalUnsupported34 — the catch-all's THIRD spelling.
    //
    // > A formal written as a typedef reached through a CLASS SCOPE
    // > (`uvm_resource_types::rsrc_q_t`) keeps its written text and degrades
    // > to an `unsupported_typespec` — exactly when that typedef's WRITTEN
    // > TARGET is itself a NAME.  A typedef of a type declared IN PLACE
    // > resolves, named by its own simple name, array dimensions included.
    //
    // t46a reads twelve cells off ONE golden, all in one class, and the
    // FIRST reading of them was wrong: "class / struct / container degrade"
    // fitted every synthetic cell and then inverted a real UVM row
    // (`uvm_resource_base::init_access_record`, whose
    // `uvm_resource_types::access_t` is an unpacked STRUCT that golden
    // resolves).  The written target is the discriminator:
    //   `typedef el46 nsq46_t;`            -> unsupported 'ns46::nsq46_t'
    //   `typedef st46_t nss46_t;`          -> unsupported 'nsx46::nss46_t'
    //   `typedef el46 nsc46_t[string];`    -> unsupported 'nsx46::nsc46_t'
    //   `typedef el46 nsl46_t[$];`         -> unsupported 'nsx46::nsl46_t'
    //   `typedef int nsi46_t;`             -> int_typespec    'nsi46_t'
    //   `typedef enum int {…} nse46_t;`    -> enum_typespec   'nse46_t'
    //   `typedef logic [7:0] nsv46_t;`     -> logic_typespec  'nsv46_t'
    //   `typedef string nst46_t;`          -> string_typespec 'nst46_t'
    //   `typedef struct packed {…} nsp46_t;` -> struct_typespec 'nsp46_t'
    //   `typedef struct {…} nsu46_t;`      -> struct_typespec 'nsu46_t'
    //   `typedef int nsm46_t[string];`     -> array_typespec  'nsm46_t'
    //   `typedef int nsn46_t[4];`          -> array_typespec  'nsn46_t'
    // and the PACKAGE-scoped control says the `::` alone is not the trigger:
    // `q46use::qc_pkg(p46::acls46_t)` binds the ordinary shared listing
    // object.  Each degraded formal gets its OWN object (`q46use::qb_scq`
    // does not share `use46::b_scq`'s).  Reach: 21 rows,
    // `uvm_resource_types::rsrc_q_t` (`typedef uvm_queue#(uvm_resource_base)
    // rsrc_q_t;`) on all four UVM-4 tests.
    auto classScopedUnsupName34 =
        [&](const syntax::DataTypeSyntax* tsyn) -> std::string {
        if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
            return {};
        auto& nt34 = tsyn->as<syntax::NamedTypeSyntax>();
        if (nt34.name->kind != syntax::SyntaxKind::ScopedName)
            return {};
        // The chain of simple identifiers, left to right.
        std::vector<std::string_view> segs34;
        std::function<bool(const syntax::NameSyntax*)> walk34 =
            [&](const syntax::NameSyntax* n34) -> bool {
            if (!n34)
                return false;
            if (n34->kind == syntax::SyntaxKind::ScopedName) {
                auto& sn34 = n34->as<syntax::ScopedNameSyntax>();
                return walk34(sn34.left) && walk34(sn34.right);
            }
            if (n34->kind == syntax::SyntaxKind::IdentifierName) {
                segs34.push_back(n34->as<syntax::IdentifierNameSyntax>()
                                     .identifier.valueText());
                return true;
            }
            return false;
        };
        if (!walk34(nt34.name) || segs34.size() < 2)
            return {};
        // The ROOT must be a CLASS in scope — a package root is the control
        // that resolves.
        const Symbol* root34 = nullptr;
        for (const Scope* sc34 = &body; sc34 && !root34;
             sc34 = sc34->asSymbol().getParentScope())
            root34 = sc34->find(segs34.front());
        if (!root34)
            return {};
        const Scope* cur34 = nullptr;
        if (root34->kind == SymbolKind::ClassType)
            cur34 = &root34->as<ClassType>();
        else if (root34->kind == SymbolKind::GenericClassDef)
            if (auto* ds34 = root34->as<GenericClassDefSymbol>()
                                 .getDefaultSpecialization(body);
                ds34 && ds34->kind == SymbolKind::ClassType)
                cur34 = &ds34->as<ClassType>();
        if (!cur34)
            return {};
        const Symbol* leaf34 = nullptr;
        for (size_t i34 = 1; i34 < segs34.size(); i34++) {
            leaf34 = cur34->find(segs34[i34]);
            if (!leaf34)
                return {};
            if (i34 + 1 < segs34.size()) {
                if (leaf34->kind != SymbolKind::ClassType)
                    return {};
                cur34 = &leaf34->as<ClassType>();
            }
        }
        if (!leaf34 || leaf34->kind != SymbolKind::TypeAlias)
            return {};
        // The predicate is on the typedef's WRITTEN TARGET, not on the
        // resolved type: a class-scope typedef of ANOTHER NAME cannot be
        // re-resolved from outside the class, while one whose target is
        // declared IN PLACE can.  Array dimensions on the declarator make no
        // difference either way — `typedef int nsm46_t[string]` resolves and
        // `typedef el46 nsc46_t[string]` does not.
        auto* tdsyn34 = leaf34->as<TypeAliasType>().getSyntax();
        if (!tdsyn34 ||
            tdsyn34->kind != syntax::SyntaxKind::TypedefDeclaration)
            return {};
        const syntax::DataTypeSyntax* tdt34 =
            tdsyn34->as<syntax::TypedefDeclarationSyntax>().type;
        if (!tdt34 || tdt34->kind != syntax::SyntaxKind::NamedType)
            return {};
        std::string out34;
        for (auto& sg34 : segs34) {
            if (!out34.empty())
                out34 += "::";
            out34 += std::string(sg34);
        }
        return out34;
    };
    // § tdListingFormalAsWritten33 — the package TYPEDEF a formal is WRITTEN
    // as, recovered from the syntax rather than from the resolved type.
    //
    // Surelog compiles the written name against the scope's data-type table,
    // so a formal keeps the TYPEDEF it names; we resolve the slang Type, which
    // canonicalises two spellings away and loses the listing object with them:
    //
    //   (a) a formal written as one of the class's own TYPE PARAMETERS whose
    //       argument (here always the DEFAULT) is a package typedef —
    //       `uvm_tlm_if #(type P=uvm_tlm_phase_e)::nb_transport_fw(…, ref P p,
    //       …)`.  t44a pins it: golden's `f_pe(PE p)` binds the very SAME
    //       object as the directly-written control `g_pe(e44_t p)` — a type
    //       parameter is emitted exactly as if its argument had been written.
    //   (b) a formal written as a package CLASS-ALIAS typedef
    //       (`typedef uvm_time uvm_tlm_time;` used as `b_transport(…,
    //       uvm_tlm_time delay)`), where we name the CLASS (`uvm_time`).
    //
    // The lookup walks OUT of the class scope on purpose: `h_alias(alias44_t
    // d)` in a class writes a name its enclosing PACKAGE declares.
    auto writtenPkgTdAlias33 =
        [&](const syntax::DataTypeSyntax* tsyn,
            bool& viaTypeParam) -> const TypeAliasType* {
        viaTypeParam = false;
        if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
            return nullptr;
        auto& nt33 = tsyn->as<syntax::NamedTypeSyntax>();
        if (nt33.name->kind != syntax::SyntaxKind::IdentifierName)
            return nullptr;
        auto id33 =
            nt33.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (id33.empty())
            return nullptr;
        const Symbol* f33 = nullptr;
        for (const Scope* sc33 = &body; sc33 && !f33;
             sc33 = sc33->asSymbol().getParentScope())
            f33 = sc33->find(id33);
        if (!f33)
            return nullptr;
        const Type* t33 = nullptr;
        if (f33->kind == SymbolKind::TypeParameter) {
            viaTypeParam = true;
            t33 = &f33->as<TypeParameterSymbol>().targetType.getType();
        }
        else if (f33->kind == SymbolKind::TypeAlias)
            t33 = &f33->as<TypeAliasType>();
        return t33 ? pkgHomedTdAlias18(*t33) : nullptr;
    };
    // § tdListingFormalAsWritten33 / § pkgContainerTdFormalListing34 —
    // bind a formal to the PACKAGE TYPEDEF LISTING object its written name
    // selects, or return null.  Named (rather than inlined in the io_decl
    // if-chain) because the § pureVirtIoDecls30 PURE VIRTUAL prototype arm
    // needs the same law: `uvm_port_component_base::get_connected_to(ref
    // uvm_port_list list)` is a pure virtual, and it is 4 of the family's
    // 20 rows.
    auto writtenPkgTdListingTs34 =
        [&](const syntax::DataTypeSyntax* argTsyn,
            UHDM::ref_typespec* rt) -> UHDM::typespec* {
        bool viaTp33 = false;
        auto* al33 = writtenPkgTdAlias33(argTsyn, viaTp33);
        if (!al33)
            return nullptr;
        // Decide from the SLANG type, not from the UHDM object: a package
        // CLASS-ALIAS typedef has NO def listing at all (t44a:
        // `p44::alias44_t` is listed by `ELABPKG:p44` only), so in the def
        // pass there is nothing yet to inspect — and that is exactly the case
        // that must still be deferred.
        auto& ct33 = al33->targetType.getType().getCanonicalType();
        // (c) § pkgContainerTdFormalListing34 — a package typedef whose
        // target is a CONTAINER of a class (`typedef uvm_port_component_base
        // uvm_port_list[string];` used as `get_connected_to(ref uvm_port_list
        // list)`) binds the same package listing object a class ALIAS does;
        // we resolve through the alias and name the ELEMENT class instead.
        // t46a reads all four container kinds off one golden — associative,
        // queue, dynamic and fixed unpacked, each `class_typespec
        // \'p46::a*46_t\'@q46`, the very object the directly-scoped spelling
        // (`q46use::qd_pkg(ref p46::amap46_t)`) binds too.  A container over
        // a STRUCT or an INT is a DIFFERENT object kind in golden
        // (`array_typespec`) and is deliberately left.  Reach: 20 rows,
        // `uvm_pkg::uvm_port_list` on all four UVM-4 tests.
        auto contOfClass34 = [&]() {
            const Type* e34 = &ct33;
            bool cont34 = false;
            for (;;) {
                auto& c34 = e34->getCanonicalType();
                if (c34.kind != SymbolKind::AssociativeArrayType &&
                    c34.kind != SymbolKind::QueueType &&
                    c34.kind != SymbolKind::DynamicArrayType &&
                    c34.kind != SymbolKind::FixedSizeUnpackedArrayType)
                    break;
                const Type* n34 = c34.getArrayElementType();
                if (!n34)
                    return false;
                e34 = n34;
                cont34 = true;
            }
            return cont34 && e34->getCanonicalType().isClass();
        };
        if (ct33.isClass()) {
            // (a) and (b): a class ALIAS is the one spelling the
            // shared-typespec path resolves through.
        }
        else if (contOfClass34()) {
            // (c)
        }
        else if (viaTp33 && (ct33.kind == SymbolKind::EnumType ||
                             ct33.kind == SymbolKind::PackedStructType ||
                             ct33.kind == SymbolKind::UnpackedStructType ||
                             ct33.kind == SymbolKind::PackedUnionType ||
                             ct33.kind == SymbolKind::UnpackedUnionType)) {
            // (a) only: a DIRECTLY written aggregate already binds this
            // object through the shared path.
        }
        else
            return nullptr;
        UHDM::typespec* cand33 = nullptr;
        if (auto t33 = pkgTopTypedefTs.find((const void*)al33);
            t33 != pkgTopTypedefTs.end())
            cand33 = t33->second;
        if (!pkgTopEmit)
            pkgForeignTsTopFixups.emplace_back(rt, al33);
        if (!cand33 && !pkgTopEmit)
            if (auto d33 = typedefTs.find((const Type*)al33);
                d33 != typedefTs.end())
                cand33 = d33->second;
        return cand33;  // null: the deferred re-point still runs
    };
    // § classTypeParamTdGroupLastWins33c — the class-scope TYPE-PARAMETER
    // typespec GROUP.
    //
    // > A class holds ONE typespec per DISTINCT RESOLVED TYPE among its own
    // > TYPE PARAMETERS.  Every formal written as one of those parameters, or
    // > as a typedef of one of them, binds that single object, and its NAME is
    // > the typedef of the LAST such parameter IN PARAMETER-DECLARATION ORDER
    // > that has one.  A typedef that is NOT of a type parameter, and a formal
    // > written as the bare builtin, each keep their own object.
    //
    // t41b §(c) saw the shape on one cell and read the winner as "the last
    // typedef declared"; `t45a` refutes that and replaces it.  `ord45
    // #(type A=int, B=A, C=A)` declares `typedef C c_t; typedef A a_t;
    // typedef B b_t;` — LAST TYPEDEF is `b_t`, and golden names all six
    // formals `c_t`, the typedef of the LAST PARAMETER.  Every other cell
    // agrees, and UVM's `uvm_master_imp #(REQ=int, RSP=int, IMP=int,
    // REQ_IMP=IMP, RSP_IMP=IMP)` is the same reading: `REQ`/`RSP` have no
    // typedef and do not re-stamp, so the winner is `RSP_IMP`'s
    // `this_rsp_type` — which is exactly what golden writes on all four
    // UVM-4 tests.
    //
    // The rest of `t45a`, all read off one golden, both directions:
    //   * `one45 #(type A=int)`, a group of ONE: `g_par(A x)` binds the SAME
    //     object as `g_td(a1_t x)` and is named `a1_t` — the parameter
    //     spelling is bound even when the group has a single member.
    //   * `g_raw(int x)` and `mix45::h_raw(int x)` are NOT in the group
    //     (`int_typespec ''`, their own objects), and `mix45`'s
    //     `typedef int m_plain_t` — declared BETWEEN two parameter typedefs —
    //     keeps its own object and its own name.  Membership is
    //     type-parameter-ness, not the resolved type.
    //   * `kind45`: a `shortint` group of two (`t_t` wins) and a CLASS group
    //     of two (`v_t` wins) — the law is not about `int`.
    //   * `two45 #(type A=int, B=integer, C=A)`: `x_t`/`z_t` share one
    //     `int_typespec` named `z_t` while `y_t` keeps its own
    //     `integer_typespec` — the group key is the RESOLVED type.
    //   * `spec45`: the group re-forms per SPECIALIZATION.
    //
    // A parameter whose type is a package TYPEDEF is deliberately OUT: t41b's
    // `seqx31 #(type REQ = ven_t); typedef REQ this_r_t;` makes golden rename
    // the PACKAGE's shared `ven_t` listing object to `p31v::this_r_t` for the
    // whole compile (`p31a::a_ven` reads it too) — a whole-corpus re-point
    // with a different blast radius, and § tdListingFormalAsWritten33 already
    // owns that spelling.  Nothing here may touch a package listing object.
    std::map<const Type*, const TypeAliasType*> tpGroupWinner33c;
    std::map<const Symbol*, const Type*> tpGroupKeyOf33c;
    if (classScope) {
        // Which class typedef NAMES which type parameter — read off the
        // written syntax, because the slang type has already canonicalised
        // `typedef A a_t;` and `typedef int a_t;` to the same thing.
        std::map<const Symbol*, const TypeAliasType*> tdOfTp33c;
        for (auto& mem33c : body.members()) {
            if (mem33c.kind != SymbolKind::TypeAlias)
                continue;
            auto& al33c = mem33c.as<TypeAliasType>();
            auto* syn33c = al33c.getSyntax();
            if (!syn33c ||
                syn33c->kind != syntax::SyntaxKind::TypedefDeclaration)
                continue;
            const syntax::DataTypeSyntax* dt33c =
                syn33c->as<syntax::TypedefDeclarationSyntax>().type;
            if (!dt33c || dt33c->kind != syntax::SyntaxKind::NamedType)
                continue;
            auto& nt33c = dt33c->as<syntax::NamedTypeSyntax>();
            if (nt33c.name->kind != syntax::SyntaxKind::IdentifierName)
                continue;
            auto id33c = nt33c.name->as<syntax::IdentifierNameSyntax>()
                             .identifier.valueText();
            if (id33c.empty())
                continue;
            if (const Symbol* f33c = body.find(id33c);
                f33c && f33c->kind == SymbolKind::TypeParameter)
                tdOfTp33c[f33c] = &al33c;
        }
        // ...then walk the parameters IN DECLARATION ORDER so the last one
        // with a typedef owns the group's name.
        for (auto& mem33c : body.members()) {
            if (mem33c.kind != SymbolKind::TypeParameter)
                continue;
            auto& pty33c =
                mem33c.as<TypeParameterSymbol>().targetType.getType();
            // `type B = A` hands back A's own type-parameter alias, so the
            // group key has to be the CANONICAL type — that is what makes
            // `#(type A=int, B=A, C=A)` one group of three.
            if (pkgHomedTdAlias18(pty33c))
                continue;  // a package typedef — not this law (see above)
            auto& cty33c = pty33c.getCanonicalType();
            // Aggregates are the SHARED package-listing kinds that
            // § pkgImportAggCloneLastWriter32 and
            // § tdListingFormalAsWritten33 own; t45a has no aggregate cell and
            // this law must not reach into that graph.
            if (cty33c.kind == SymbolKind::EnumType ||
                cty33c.kind == SymbolKind::PackedStructType ||
                cty33c.kind == SymbolKind::UnpackedStructType ||
                cty33c.kind == SymbolKind::PackedUnionType ||
                cty33c.kind == SymbolKind::UnpackedUnionType)
                continue;
            const Type* key33c = &cty33c;
            // ONLY a parameter that HAS a typedef is in the group.  UVM is the
            // cell that pins this: `uvm_master_imp #(REQ=int, RSP=int, IMP=int,
            // REQ_IMP=IMP, RSP_IMP=IMP)` gives `get(output REQ t)` its own
            // ANONYMOUS `int_typespec` in golden while `new`'s three
            // typedef-aliased parameters share the named one.  Binding every
            // same-typed parameter measured +24 rows on BuildUVMPkg alone.
            auto t33c = tdOfTp33c.find(&mem33c);
            if (t33c == tdOfTp33c.end())
                continue;
            tpGroupKeyOf33c[&mem33c] = key33c;
            tpGroupWinner33c[key33c] = t33c->second;
            tpGroupKeyOf33c[t33c->second] = key33c;
        }
    }
    // The ONE object per group, for the duration of THIS listing.
    std::map<const Type*, UHDM::typespec*> tpGroupTs33c;
    auto tpGroupKey33c =
        [&](const syntax::DataTypeSyntax* tsyn) -> const Type* {
        if (tpGroupWinner33c.empty() || !tsyn ||
            tsyn->kind != syntax::SyntaxKind::NamedType)
            return nullptr;
        auto& nt33c = tsyn->as<syntax::NamedTypeSyntax>();
        if (nt33c.name->kind != syntax::SyntaxKind::IdentifierName)
            return nullptr;
        auto id33c =
            nt33c.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (id33c.empty())
            return nullptr;
        const Symbol* f33c = body.find(id33c);
        if (!f33c)
            return nullptr;
        auto k33c = tpGroupKeyOf33c.find(f33c);
        if (k33c == tpGroupKeyOf33c.end() ||
            !tpGroupWinner33c.count(k33c->second))
            return nullptr;
        return k33c->second;
    };
    // An out-of-body definition is compiled in the HOME PACKAGE's scope, not
    // the class header's: its own object, and every typespec its return type,
    // formals and body locals mint, carry vpiInstance = that package. An
    // in-class method (and every prototype) carries none.
    UHDM::instance* oobHomePkg = nullptr;
    if (classScope && !oobDefs.empty()) {
        UHDM::BaseClass* hp0 = cloneMode ? (UHDM::BaseClass*)pkgClassTfClone
                                         : ((UHDM::class_defn*)m)->VpiParent();
        if (hp0 && hp0->UhdmType() == UHDM::uhdmpackage)
            oobHomePkg = (UHDM::instance*)hp0;
    }
    // ...and the § oobParamClassTypeParamFormalUnsupported31 typespec takes
    // the package the class is DECLARED in even in a package CLONE pass,
    // where `oobHomePkg` deliberately names the clone target: golden reads
    // `DEFPKG adpcm_pkg::::uvm_sequencer::put` as `unsupported_typespec
    // 'REQ'@uvm_pkg`, and t41b reads the same shape as `@p31v` in both
    // importers' copies.  20 of the law's 210 rows are these copies.
    UHDM::instance* oobDeclPkg31 = nullptr;
    if (classScope && !oobDefs.empty())
        if (auto* hp31 = ((UHDM::class_defn*)m)->VpiParent();
            hp31 && hp31->UhdmType() == UHDM::uhdmpackage) {
            oobDeclPkg31 = (UHDM::instance*)hp31;
            // § oobClassTypeParamPlaceholderPerView213 — THE HOME PACKAGE'S
            // OWN **DEF** LISTING OF AN OUT-OF-BODY CLASS METHOD STAMPS ITS
            // TYPE-PARAMETER PLACEHOLDER WITH THE **DEF** PACKAGE.
            //
            // THE SURELOG DECODE, in one line each.
            //   * `FunctorCompilePackage::operator()` (CompilePackage.cpp
            //     :60-72) compiles a package TWICE: the elaborated `Package`
            //     with `Reduce::Yes`, then `m_package->getUnElabPackage()`
            //     with `Reduce::No`.  They are two DesignComponents.
            //   * A `function void C::m(); ... endfunction` written at package
            //     level is a package-level `paFunction_declaration`
            //     (CompilePackage.cpp:213-218), so BOTH compiles walk the same
            //     out-of-body body, each against ITS OWN component.
            //   * `CompileHelper::compileTypespec`'s catch-all closes with
            //     `result->Instance(component->getUhdmInstance())`
            //     (CompileType.cpp:2135-2136) — so the placeholder minted in
            //     the `Reduce::No` compile carries the UNELABORATED package's
            //     UHDM object...
            //   * ...and that object IS the `AllPackages` entry:
            //     `UhdmWriter` fills `d->AllPackages()` from
            //     `pack->getUnElabPackage()->getUhdmInstance()`
            //     (UhdmWriter.cpp:4959-4966) while `TopPackages` holds the
            //     elaborated twin.  Per-view compile, per-view instance.
            //
            // WHY WE GOT IT WRONG.  Our package classes ride the ELABORATED
            // view only (§ emitPackageClasses), so the DEF listing is built by
            // `emitPackageClassMethodClones` re-running `emitTaskFuncs` over
            // the class_defn — whose `VpiParent` is the TOP package, whatever
            // listing is being written.  `hp31` above therefore named the
            // elaborated twin in BOTH views, and `typespec::Compare` READS
            // `Instance` (generated typespec.cpp:94), so the judge followed
            // our def-view placeholder into the ELABORATED package and scored
            // golden's DEF `Param_assigns` against our elaborated ones — the
            // SeqDriver x2 fifty-line head, whose printed pair was a
            // `param_assign` Rhs that is identical on both sides (r10uvm210
            // measured that cell EQUAL in all four package listings).
            //
            // THE WINDOW, and why each conjunct is here.  `pkgClassTfClone`
            // is non-null in exactly two drivers: `emitPackageClassMethodClones`
            // (the HOME package's own DEF listing, `pkgImportCloneEmit` false)
            // and `emitImportedPkgClassMethodClones` (an IMPORTER's clone,
            // which sets `pkgImportCloneEmit`).  Only the first is this law's:
            // golden's import clones keep the ELABORATED home package in BOTH
            // importer views, measured on arm C and on the corpus (every
            // `package[*:adpcm_pkg]` copy reads `TOPPKG:uvm_pkg` on both
            // sides, pristine).  The identity test `!= hp31` keeps the stamp a
            // no-op on the elaborated listing, and the NAME test refuses any
            // future driver that points `pkgClassTfClone` at a package that is
            // not this class's own home.
            if (pkgClassTfClone && !pkgImportCloneEmit &&
                (UHDM::BaseClass*)pkgClassTfClone != hp31 &&
                pkgClassTfClone->VpiName() == hp31->VpiName())
                oobDeclPkg31 = (UHDM::instance*)pkgClassTfClone;
        }
    // § pureVirtIoRanges34 — a formal's io_decl RANGES: the unpacked, the
    // DYNAMIC-array, the QUEUE and the § assocIoRange9 associative arms, in
    // one place because a PURE VIRTUAL prototype carries exactly the same
    // ones.  § pureVirtIoDecls30 gave the prototype its io_decls but never
    // their Ranges, and t46a reads every cell off one golden: golden gives
    // `pure virtual function void p_str(output string q[$])` the same
    // `[0:$]` its DEFINED control `n_str` gets, and the same for a fixed
    // unpacked dim, a dynamic dim, an associative dim and `[$][$]`.  Reach:
    // 16 rows, 4 on every UVM-4 test — `uvm_report_server::get_id_set` /
    // `get_severity_set`, `uvm_reg_transaction_order_policy::order` and
    // `uvm_structure_proxy::get_immediate_children`, every one of them a
    // `pure virtual` with a queue formal.
    // `hoist135` — § assocIdxNameHoistNet135.  An io_decl range NEVER takes the
    // promoted associative form, so a NAME-spelled index here always carries a
    // visible `ref_obj`; it enters the hoist pool only from the OUT-OF-BODY
    // DEFINITION's own listing.  The `extern` PROTOTYPE listing runs this same
    // lambda over the SAME formal symbols and must NOT push: golden leaves the
    // prototype's reference unbound (`uvm_phase.svh:593:86`).
    auto emitIoRanges34 = [&](const slang::ast::FormalArgumentSymbol& arg0,
                              UHDM::io_decl* io0, const std::string& ioFull,
                              UHDM::instance* tsInst0, bool hoist135 = false) {
        const slang::ast::FormalArgumentSymbol* arg = &arg0;
        UHDM::io_decl* io = io0;
        // Unpacked-array formals carry one range per unpacked dimension;
        // a PARAM-sized dim ([CNT]) stays symbolic, scoped at the formal
        // (work@top.F.SRC.CNT) — Surelog (ArrayExprFuncArg).
        if (arg->getDeclaredType() &&
            arg->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            if (auto* ranges = buildUnpackedRanges(
                    *arg, io, ioFull))
                io->Ranges(ranges);
        // A DYNAMIC-array formal (`input real driver []`) gets the
        // unsized range Surelog mints for an unsized_dimension:
        // [0 : "unsized"] (CompileExpression.cpp paUnsized_dimension).
        if (arg->getDeclaredType() &&
            arg->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::DynamicArrayType) {
            const syntax::VariableDimensionSyntax* undim = nullptr;
            if (auto* dsyn = arg->getSyntax())
                if (dsyn->kind == syntax::SyntaxKind::Declarator)
                    for (auto dim : dsyn->as<syntax::DeclaratorSyntax>().dimensions)
                        if (!dim->specifier) {
                            undim = dim;
                            break;
                        }
            if (undim) {
                auto* r = s.MakeRange();
                r->VpiParent(io);
                setLoc(r, undim->sourceRange());
                auto* lc = s.MakeConstant();
                lc->VpiParent(r);
                lc->VpiDecompile("0");
                lc->VpiSize(64);
                lc->VpiValue("UINT:0");
                lc->VpiConstType(vpiUIntConst);
                setLoc(lc, undim->sourceRange());
                lc->VpiEndColumnNo(lc->VpiColumnNo() + 1);
                r->Left_expr(lc);
                auto* rc = s.MakeConstant();
                rc->VpiParent(r);
                rc->VpiDecompile("unsized");
                rc->VpiSize(0);
                rc->VpiValue("STRING:unsized");
                rc->VpiConstType(vpiStringConst);
                setLoc(rc, undim->sourceRange());
                rc->VpiEndColumnNo(rc->VpiColumnNo() + 1);
                r->Right_expr(rc);
                auto* rv = s.MakeRangeVec();
                rv->push_back(r);
                io->Ranges(rv);
            }
        }
        // A QUEUE formal (`ref string i[$]`) carries the range Surelog
        // mints for a `$` dimension: [0 : $].  Surelog has no queue arm —
        // it compiles the dimension as an ORDINARY expression, where `$`
        // becomes a vpiUnboundedConst (CompileExpression.cpp:3516), and
        // then SKIPS the `-1` decrement it applies to a sized dimension
        // because that const type marks the dimension associative
        // (:4094), so the bound is the `$` constant itself.  The left
        // bound is the same UINT:0 as the other unpacked arms and (unlike
        // the unsized arm) carries no location of its own; the range and
        // the right bound sit at the `$` token.  Measured on the UVM
        // corpus: 225 io_decls, every one of them a queue formal.
        if (arg->getDeclaredType() &&
            arg->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::QueueType) {
            std::vector<const syntax::QueueDimensionSpecifierSyntax*>
                qspecs;
            if (auto* dsyn = arg->getSyntax())
                if (dsyn->kind == syntax::SyntaxKind::Declarator)
                    for (auto dim :
                         dsyn->as<syntax::DeclaratorSyntax>().dimensions)
                        if (dim->specifier &&
                            dim->specifier->kind ==
                                syntax::SyntaxKind::QueueDimensionSpecifier)
                            qspecs.push_back(&dim->specifier->as<
                                syntax::QueueDimensionSpecifierSyntax>());
            UHDM::VectorOfrange* qrv = nullptr;
            // One range per `$` dimension: `ref int f[$][$]` carries two.
            for (auto* qspec : qspecs) {
                auto* r = s.MakeRange();
                r->VpiParent(io);
                setLoc(r, qspec->dollar.range());
                auto* lc = s.MakeConstant();
                lc->VpiParent(r);
                lc->VpiDecompile("0");
                lc->VpiSize(64);
                lc->VpiValue("UINT:0");
                lc->VpiConstType(vpiUIntConst);
                r->Left_expr(lc);
                auto* rc = s.MakeConstant();
                rc->VpiParent(r);
                rc->VpiDecompile("$");
                rc->VpiSize(1);
                rc->VpiValue("STRING:$");
                rc->VpiConstType(vpiUnboundedConst);
                setLoc(rc, qspec->dollar.range());
                r->Right_expr(rc);
                if (!qrv)
                    qrv = s.MakeRangeVec();
                qrv->push_back(r);
            }
            if (qrv)
                io->Ranges(qrv);
        }
        // § assocIoRange9 — an ASSOCIATIVE formal (`ref int c[string]`,
        // `ref int e[p1idx]`) carries one io_decl range per written
        // dimension, and Surelog's range compiler takes a DIFFERENT arm
        // per spelling because its GRAMMAR does:
        //   `[<type keyword>]`, `[*]` parse as paAssociative_dimension
        //      (CompileExpression.cpp:4187) -> [UINT:0 : STRING:
        //      "associative"], the index typespec riding the right
        //      constant as a ref_typespec; only the RANGE is spanned
        //      (at the brackets), neither constant is;
        //   `[<identifier>]` parses as a paConstant_expression -- a SIZE
        //      (:4037) -- so the right bound is the ordinary
        //      `<expr> - 1` decrement (:4137): an operation vpiSubOp
        //      over a ref_obj naming the index type and an INT:1
        //      constant, range/operation/ref_obj all at the identifier
        //      span, the left UINT:0 and the `1` unspanned (and the `1`
        //      unparented -- Surelog never sets its parent).
        // slang draws the same line: parsePrimaryExpression sends a type
        // KEYWORD to parseDataType and an identifier to parseName, so the
        // dimension's selector expression kind is the discriminator
        // (the same test emitAssocDims already makes for class props).
        if (arg->getDeclaredType() &&
            arg->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::AssociativeArrayType) {
            // `ioFull` arrives as a parameter.
            std::vector<const Type*> aidx;
            for (const Type* cur9 =
                     &arg->getDeclaredType()->getType();;) {
                auto& cc9 = cur9->getCanonicalType();
                if (cc9.kind != SymbolKind::AssociativeArrayType)
                    break;
                aidx.push_back(cc9.as<AssociativeArrayType>().indexType);
                cur9 = &cc9.as<AssociativeArrayType>().elementType;
            }
            std::vector<const syntax::VariableDimensionSyntax*> adims;
            if (auto* dsyn = arg->getSyntax())
                if (dsyn->kind == syntax::SyntaxKind::Declarator)
                    for (auto dim :
                         dsyn->as<syntax::DeclaratorSyntax>().dimensions)
                        adims.push_back(dim);
            UHDM::VectorOfrange* arv = nullptr;
            for (size_t i9 = 0; i9 < aidx.size() && i9 < adims.size();
                 i9++) {
                auto* d9 = adims[i9];
                // The selector expression, when the dimension was written
                // as one (`[*]` has no selector at all).
                const syntax::ExpressionSyntax* sx9 = nullptr;
                if (d9->specifier)
                    if (auto* rd9 = d9->specifier->as_if<
                            syntax::RangeDimensionSpecifierSyntax>())
                        if (rd9->selector->kind ==
                            syntax::SyntaxKind::BitSelect)
                            sx9 = rd9->selector
                                      ->as<syntax::BitSelectSyntax>()
                                      .expr.get();
                bool named9 =
                    sx9 && (sx9->kind == syntax::SyntaxKind::IdentifierName ||
                            sx9->kind == syntax::SyntaxKind::ScopedName);
                auto* r9 = s.MakeRange();
                r9->VpiParent(io);
                auto* lc9 = s.MakeConstant();
                lc9->VpiParent(r9);
                lc9->VpiDecompile("0");
                lc9->VpiSize(64);
                lc9->VpiValue("UINT:0");
                lc9->VpiConstType(vpiUIntConst);
                r9->Left_expr(lc9);
                if (named9) {
                    setLoc(r9, sx9->sourceRange());
                    auto* op9 = s.MakeOperation();
                    op9->VpiParent(r9);
                    op9->VpiOpType(vpiSubOp);
                    setLoc(op9, sx9->sourceRange());
                    auto* ops9 = s.MakeAnyVec();
                    auto* ro9 = s.MakeRef_obj();
                    ro9->VpiParent(op9);
                    std::string in9;
                    if (sx9->kind == syntax::SyntaxKind::IdentifierName)
                        in9 = std::string(
                            sx9->as<syntax::IdentifierNameSyntax>()
                                .identifier.valueText());
                    else {
                        in9 = sx9->toString();
                        while (!in9.empty() &&
                               std::isspace((unsigned char)in9.front()))
                            in9.erase(in9.begin());
                        while (!in9.empty() &&
                               std::isspace((unsigned char)in9.back()))
                            in9.pop_back();
                    }
                    ro9->VpiName(in9);
                    ro9->VpiFullName(ioFull + "::" + in9);
                    setLoc(ro9, sx9->sourceRange());
                    // § assocIdxNameHoistNet135
                    if (hoist135 && aidx[i9] &&
                        assocIdxNameHoistable135(*aidx[i9], sx9))
                        hoistAssocIdxName135(ro9, in9, sx9->sourceRange());
                    ops9->push_back(ro9);
                    auto* one9 = s.MakeConstant();
                    one9->VpiValue("INT:1");
                    one9->VpiConstType(vpiIntConst);
                    one9->VpiSize(64);
                    ops9->push_back(one9);
                    op9->Operands(ops9);
                    r9->Right_expr(op9);
                }
                else {
                    setLoc(r9, d9->sourceRange());
                    auto* rc9 = s.MakeConstant();
                    rc9->VpiParent(r9);
                    rc9->VpiDecompile("associative");
                    rc9->VpiSize(0);
                    rc9->VpiValue("STRING:associative");
                    rc9->VpiConstType(vpiStringConst);
                    if (aidx[i9])
                        if (auto* its9 = assocIndexTs(*aidx[i9], *arg)) {
                            // § sharedAliasNoStamp41, same invariant as the
                            // body-local arm.  INERT here today and recorded
                            // as such: this branch is the !named9 half, so the
                            // index was written as a type KEYWORD and can
                            // never resolve to a TypeAlias — the guard exists
                            // so the invariant holds by GREP at every
                            // assocIndexTs stamp site rather than by
                            // re-deriving the grammar split.
                            const bool sh9 = isSharedAliasTs(*aidx[i9], its9) ||
                                             isTdVecClone42(its9);
                            if (sx9 && !sh9)
                                setLoc(its9, sx9->sourceRange());
                            // The index typespec is a package-scope
                            // object like the formal's own (uhdm-cmp
                            // recurses a typespec's Instance).
                            if (tsInst0 && !its9->Instance() && !sh9)
                                its9->Instance(importCopyTsInst
                                                   ? importCopyTsInst
                                                   : tsInst0);
                            auto* irt9 = s.MakeRef_typespec();
                            irt9->VpiParent(rc9);
                            irt9->VpiFullName(ioFull);
                            irt9->Actual_typespec(its9);
                            rc9->Typespec(irt9);
                        }
                    r9->Right_expr(rc9);
                }
                if (!arv)
                    arv = s.MakeRangeVec();
                arv->push_back(r9);
            }
            if (arv)
                io->Ranges(arv);
        }
    };
    auto* baseScopeInst = pkgScopeInst;
    for (auto* memberPtr : items) {
        auto& member = *memberPtr;
        // `pure virtual` class methods have no body: slang keeps them as
        // prototypes, Surelog still emits the task/function shell (vpiDPIPure).
        // An `extern` prototype whose definition sits OUT OF BODY is emitted
        // as its own method listing (the class's first group): vpiMethod 1,
        // vpiAccessType 2 (vpiExternAcc), the DECLARED visibility (`new`
        // included, unlike an in-class constructor), vpiVirtual as written,
        // and NO Stmt. It runs the ordinary subroutine path over the
        // definition's SubroutineSymbol — the formals and return type are the
        // same objects the prototype declares — then stops before the body.
        const MethodPrototypeSymbol* protoOf = nullptr;
        const SubroutineSymbol* subPtr = nullptr;
        if (classScope && !onlySub && member.kind == SymbolKind::MethodPrototype) {
            auto& mp = member.as<MethodPrototypeSymbol>();
            if (!mp.flags.has(MethodFlags::Pure)) {
                auto* impl9 = mp.getSubroutine();
                if (!impl9 || !impl9->getSyntax() || !isOutOfBody(impl9))
                    continue;
                protoOf = &mp;
                subPtr = impl9;
            }
        }
        if (classScope && !onlySub && !protoOf &&
            member.kind == SymbolKind::MethodPrototype) {
            auto& mp = member.as<MethodPrototypeSymbol>();
            if (!mp.flags.has(MethodFlags::Pure))
                continue;
            auto* pt = mp.subroutineKind == SubroutineKind::Function
                           ? (UHDM::task_func*)s.MakeFunction()
                           : (UHDM::task_func*)s.MakeTask();
            pt->VpiName(mp.name);
            pt->VpiFullName(joinPath(prefix, mp.name));
            pt->VpiParent(m);
            pt->VpiMethod(true);
            pt->VpiVisibility(mp.visibility == Visibility::Protected
                                  ? 2
                                  : (mp.visibility == Visibility::Local ? 3 : 1));
            if (mp.isVirtual())
                pt->VpiVirtual(true);
            pt->VpiDPIPure(true);
            if (auto psyn = mp.getSyntax())
                setLoc(pt, psyn->parent && psyn->parent->kind ==
                                               syntax::SyntaxKind::ClassMethodPrototype
                               ? psyn->parent->sourceRange()
                               : psyn->sourceRange());
            // § pureVirtProtoSpan137 (r11u137) — golden's pure virtual
            // TASK ends at its prototype (the `;` is not in it: 10:5-10:33
            // for `pure virtual task door_fsm();`, ClassMini), and a pure
            // virtual FUNCTION ends at its last qualifier (`pure virtual`,
            // 3:5-3:17 for `pure virtual function int f();`), where ours
            // spanned the whole ClassMethodPrototype with its `;`.  Grid
            // tools/probe/r11u137repro/grid/pv.  Switch:
            // R11U137_PUREVIRTSPAN_OFF.
            if (auto psyn = mp.getSyntax(); psyn && r11u137Law("R11U137_PUREVIRTSPAN_OFF")) {
                const syntax::ClassMethodPrototypeSyntax* cmp137 = nullptr;
                if (psyn->kind == syntax::SyntaxKind::ClassMethodPrototype)
                    cmp137 = &psyn->as<syntax::ClassMethodPrototypeSyntax>();
                else if (psyn->parent &&
                         psyn->parent->kind == syntax::SyntaxKind::ClassMethodPrototype)
                    cmp137 = &psyn->parent->as<syntax::ClassMethodPrototypeSyntax>();
                if (cmp137) {
                    auto st137 = cmp137->sourceRange().start();
                    // § methodSpanSkipsAttrs144 (r11u144) — an attribute
                    // instance is not part of a method's span: golden starts
                    // at the first qualifier (`(* keep *) pure virtual
                    // function int f;` 2:14, grid at).  Switch:
                    // R11U144_METHATTR_OFF.
                    if (!cmp137->attributes.empty() &&
                        !cmp137->qualifiers.empty() &&
                        r11u144Law("R11U144_METHATTR_OFF"))
                        st137 = cmp137->qualifiers[0].range().start();
                    if (mp.subroutineKind == SubroutineKind::Function) {
                        // § pureVirtProtoSpan137, v11u137 refinement: the
                        // end is the `virtual` keyword of
                        // `pure virtual`, not a later qualifier (golden
                        // 3:3-3:15 for `pure virtual protected function int
                        // f();`, where the last qualifier read 3:25).
                        // Switch: R11V137_PVQUAL_OFF.
                        bool end137 = false;
                        if (!getenv("R11V137_PVQUAL_OFF") && !getenv("R11V137_OFF"))
                            for (auto q137 : cmp137->qualifiers)
                                if (q137.kind == parsing::TokenKind::VirtualKeyword) {
                                    end137 = true;
                                    setLoc(pt, SourceRange(st137, q137.range().end()));
                                    break;
                                }
                        if (!end137 && !cmp137->qualifiers.empty())
                            setLoc(pt, SourceRange(st137, cmp137->qualifiers.back()
                                                              .range()
                                                              .end()));
                    }
                    else
                        setLoc(pt, SourceRange(st137,
                                               cmp137->prototype->sourceRange().end()));
                }
            }
            // § pureVirtRet10 — a PURE VIRTUAL function prototype still
            // carries its Return variable, anchored at the return-type token
            // with a ref_typespec to that type, exactly as a defined function
            // does; only the body and the io_decls are absent.  Surelog
            // compiles the prototype's return through the same
            // compileVariable path, so the object kind follows the ordinary
            // return rules (repro t6: `pure virtual function Inner pvc(int
            // a);` -> class_var, `... int pvi();` -> int_var, `... string
            // pvs();` -> string_var, and a pure virtual TASK gets none).
            // Reach: 25 `Return | class_var vs <null>` rows on BuildUVMPkg
            // (uvm_coreservice_t's 16 pure-virtual getters alone) and the
            // same shape on all four UVM tests.
            if (mp.subroutineKind == SubroutineKind::Function &&
                !mp.getReturnType().isVoid()) {
                // § implicitRetSigningIsIntVar70, site 3 of 4 — the PURE
                // VIRTUAL prototype (arm a4 cells 12:27 `pv_u` and 13:27
                // `pv_s`, both golden int_var + vpiSigned:1 + logic_typespec).
                // THE RETURN-TYPE SYNTAX IS HOISTED ABOVE THE FACTORY for this
                // one reason: a prototype has no FunctionDeclaration, so
                // `returnTypeSyntax(sub)` cannot serve it and the predicate
                // needs the FunctionPrototypeSyntax's own returnType.  The
                // block below is byte-for-byte the one that used to sit AFTER
                // the factory call; only its position moved.
                const syntax::DataTypeSyntax* prsyn = nullptr;
                if (auto* psyn0 = mp.getSyntax()) {
                    if (psyn0->kind == syntax::SyntaxKind::ClassMethodPrototype)
                        psyn0 = psyn0->as<syntax::ClassMethodPrototypeSyntax>()
                                    .prototype;
                    if (psyn0 &&
                        psyn0->kind == syntax::SyntaxKind::FunctionPrototype)
                        prsyn = psyn0->as<syntax::FunctionPrototypeSyntax>()
                                    .returnType;
                }
                auto* prv = makeReturnVar(s, mp.getReturnType(),
                                          implicitRetWrittenSigning70(prsyn));
                // § atomVarSignedWritten68, site 1 of 7 — a PURE VIRTUAL
                // prototype's synthesized return var (arm a5 cell 18:25).
                clearNamedAtomSigned68(prv, mp.getReturnType());
                prv->VpiFullName(pt->VpiFullName());
                prv->VpiParent(pt);
                {
                    tfContext = true;
                    auto* pts = makeTypespec(mp, prsyn);
                    tfContext = false;
                    if (pts) {
                        // The class-handle return typespec is ANONYMOUS and
                        // uninstanced, the same rule the DEFINED function's
                        // return already follows (the makeTypespec naming
                        // walk cannot see it: a prototype's parent scope IS
                        // the class, with no subroutine in between, so it
                        // takes the class-PROPERTY arm and keeps the name).
                        // ...only for a class named DIRECTLY: an ALIAS shares
                        // the typedef's typespec object with every other use,
                        // so renaming it there would corrupt them.
                        if (pts->UhdmType() == UHDM::uhdmclass_typespec &&
                            mp.getReturnType().kind == SymbolKind::ClassType) {
                            pts->VpiName("");
                            pts->Instance(nullptr);
                        }
                        auto* prt = s.MakeRef_typespec();
                        prt->VpiFullName(pt->VpiFullName());
                        prt->VpiParent(prv);
                        prt->Actual_typespec(pts);
                        prv->Typespec(prt);
                        copyLoc(prv, pts);
                    }
                }
                ((UHDM::function*)pt)->Return(prv);
            }
            // § pureVirtIoDecls30 — a PURE VIRTUAL prototype carries its
            // FORMALS too.  § pureVirtRet10's aside ("only the body and the
            // io_decls are absent") was never measured: t40a reads golden's
            // `pure virtual function void pv_defint(int k = 3)` with a full
            // io_decl — name, vpiDirection, a ref_typespec to the same
            // typespec object an in-class method's formal takes (int_typespec
            // with NO vpiInstance; a named typedef's is the shared, stamped
            // one) and the default value under the very same
            // § noDirNamedTypeDefaultDropped30 rule (`pv_defenum(e40_t e=E1)`
            // drops it, `pv_definput(input e40_t e=E1)` keeps it).  Reach: the
            // whole 107-row io_decl population deficit on every UVM-4 test —
            // uvm_factory (39 rows), uvm_recorder (19), uvm_report_server
            // (18), uvm_coreservice_t, uvm_link_base, uvm_subscriber, ... —
            // every one of them an abstract UVM base class.
            // The prototype takes no funcMap/subMap registration: nothing
            // binds to a pure virtual's formals, there being no body.
            if (!mp.getArguments().empty()) {
                auto* pios = s.MakeIo_declVec();
                for (auto* parg : mp.getArguments()) {
                    auto* pio = s.MakeIo_decl();
                    pio->VpiName(parg->name);
                    pio->VpiParent(pt);
                    switch (parg->direction) {
                        case ArgumentDirection::In:
                            pio->VpiDirection(vpiInput);
                            break;
                        case ArgumentDirection::Out:
                            pio->VpiDirection(vpiOutput);
                            break;
                        case ArgumentDirection::InOut:
                            pio->VpiDirection(vpiInout);
                            break;
                        case ArgumentDirection::Ref:
                            pio->VpiDirection(vpiRef);
                            break;
                        default:
                            break;
                    }
                    setLoc(pio, nameSpan(parg->location, parg->name));
                    const syntax::DataTypeSyntax* ptsyn =
                        parg->getDeclaredType()->getTypeSyntax();
                    if (auto* dv0 = parg->getDefaultValue()) {
                        bool wroteDir0 = true;
                        for (auto q0 = parg->getSyntax(); q0; q0 = q0->parent)
                            if (q0->kind == syntax::SyntaxKind::FunctionPort) {
                                wroteDir0 = q0->as<syntax::FunctionPortSyntax>()
                                                .direction.valid();
                                break;
                            }
                        bool bareTy0 = false;
                        if (ptsyn &&
                            ptsyn->kind == syntax::SyntaxKind::NamedType) {
                            auto nk0 = ptsyn->as<syntax::NamedTypeSyntax>()
                                           .name->kind;
                            bareTy0 =
                                nk0 == syntax::SyntaxKind::IdentifierName ||
                                nk0 == syntax::SyntaxKind::ClassName;
                        }
                        if (wroteDir0 || !bareTy0) {
                            NetMap pmap;
                            // § formalDefaultBindsLikeBody13, SITE 2 of 2.  A
                            // `pure virtual` prototype is an IN-CLASS listing
                            // and nothing else — the keyword exists only inside
                            // a virtual class and it has no out-of-body form —
                            // so the body window it is bound in is
                            // classMethodNoBind = TRUE, unconditionally, and
                            // the formals map stays empty because that silence
                            // would swallow it anyway.  Arm v1 `v13::v_enumi`
                            // (`pure virtual function int v_enumi(int v =
                            // E13_B);`) is the cell: golden leaves the
                            // enum_const BARE and we bound it.
                            bool savedCMNB13p = classMethodNoBind;
                            classMethodNoBind = true;
                            // § formalDefaultNamedThroughFormal191, SITE 2
                            // of 2 (the pure virtual prototype's formal).
                            std::string pScope191(pt->VpiFullName());
                            auto k191 = stripImplicitConv(*dv0).kind;
                            if (!pScope191.empty() && !parg->name.empty() &&
                                k191 != ExpressionKind::NamedValue &&
                                k191 != ExpressionKind::IntegerLiteral &&
                                k191 != ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                                k191 != ExpressionKind::StringLiteral &&
                                k191 != ExpressionKind::RealLiteral &&
                                k191 != ExpressionKind::NullLiteral &&
                                r191TF("R11U191_REFFULL_OFF")) {
                                pScope191 = joinRef(pScope191, parg->name);
                                tr191TF("formalDefaultNamedThroughFormal191");
                            }
                            auto* pde =
                                emitExpr(*dv0, nullptr, pScope191, pmap);
                            classMethodNoBind = savedCMNB13p;
                            if (pde)
                                pio->Expr((UHDM::expr*)pde);
                        }
                    }
                    // A pure virtual's formal takes the SAME written-name
                    // laws a defined method's does — the prototype is not a
                    // different compile, it is the same declaration without a
                    // body.  `uvm_port_component_base::get_connected_to(ref
                    // uvm_port_list list)` is 4 of
                    // § pkgContainerTdFormalListing34's 20 rows and is a pure
                    // virtual, which is how the arm found this path at all.
                    UHDM::ref_typespec* prt0 = nullptr;
                    auto mkPrt34 = [&]() {
                        if (!prt0) {
                            prt0 = s.MakeRef_typespec();
                            prt0->VpiFullName(std::string(pt->VpiFullName()) +
                                              sep + std::string(parg->name));
                            prt0->VpiParent(pio);
                        }
                        return prt0;
                    };
                    UHDM::typespec* pts0 = nullptr;
                    if (auto pbtp34 = baseTypeParamName34(ptsyn);
                        !pbtp34.empty()) {
                        auto* pu34 = s.MakeUnsupported_typespec();
                        pu34->VpiName(pbtp34);
                        if (ptsyn)
                            setLoc(pu34, ptsyn->sourceRange());
                        pts0 = pu34;
                    }
                    else if (auto pcsn34 = classScopedUnsupName34(ptsyn);
                             !pcsn34.empty()) {
                        auto* pu34 = s.MakeUnsupported_typespec();
                        pu34->VpiName(pcsn34);
                        if (ptsyn)
                            setLoc(pu34, ptsyn->sourceRange());
                        pts0 = pu34;
                    }
                    else {
                        // Only mint the ref when the listing law can fire:
                        // it registers the deferred re-point against it.
                        bool pvia34 = false;
                        if (writtenPkgTdAlias33(ptsyn, pvia34))
                            pts0 = writtenPkgTdListingTs34(ptsyn, mkPrt34());
                    }
                    if (!pts0) {
                        tfContext = true;
                        pts0 = makeTypespec(*parg, ptsyn);
                        tfContext = false;
                    }
                    if (pts0) {
                        mkPrt34()->Actual_typespec(pts0);
                        pio->Typespec(prt0);
                    }
                    // § pureVirtIoRanges34 — the prototype's formal carries
                    // the SAME io_decl ranges a defined method's does; the
                    // instance a class method's typespecs take is null, which
                    // is exactly what the ordinary path computes here.
                    emitIoRanges34(*parg, pio,
                                   std::string(pt->VpiFullName()) + sep +
                                       std::string(parg->name),
                                   nullptr);
                    pios->push_back(pio);
                }
                pt->Io_decls(pios);
            }
            // § externProtoInBodyCallBinds12 — SITE 1 of 2, the PURE VIRTUAL
            // prototype.  slang answers a call to a pure method with the STUB
            // SubroutineSymbol `MethodPrototypeSymbol::getSubroutine()` mints
            // (SubroutineSymbols.cpp `createFromPrototype`), and that stub is in
            // no scope's member list and in no map — which is why every such
            // call fell into § classCallNoLink12 with no link at all.  Key the
            // prototype object by that stub, in DECLARATION ORDER: the bodies
            // below are emitted from the same loop, so a body sees exactly the
            // prototypes written ABOVE it.  Arm v1 `call_pv`, arm v2 `call_mpv`.
            if (pt->UhdmType() == UHDM::uhdmfunction)
                if (auto* stub12 = mp.getSubroutine())
                    classProtoFn12[stub12] = (UHDM::function*)pt;
            tfs->push_back(pt);
            continue;
        }
        if (!protoOf) {
            if (member.kind != SymbolKind::Subroutine)
                continue;
            if (onlySub && &member != onlySub)
                continue;
            subPtr = &member.as<SubroutineSymbol>();
        }
        auto& sub = *subPtr;
        // Class scopes skip slang's implicit built-ins (randomize etc.).
        if (classScope && !sub.getSyntax())
            continue;
        // A DPI import declared at COMPILATION-UNIT scope is not in the
        // model at all: Surelog binds the prototype for name resolution but
        // never writes it, so the design carries no vpiTaskFunc for it and
        // calls to it get NO vpiFunction link. Measured on a golden pair --
        // the same import inside a module IS emitted (work@m.dtick), and a
        // plain $unit-scope function IS emitted with its call link, so the
        // rule is DPI-import x unit-scope, not "unit scope" (DelayAssign).
        if (scopeSym9->kind == SymbolKind::CompilationUnit &&
            (sub.flags & MethodFlags::DPIImport) != MethodFlags::None)
            continue;
        // An out-of-body DEFINITION is not a method listing: vpiMethod is 0
        // (1 only for `new`, which Surelog still marks a method), the
        // vpiVisibility is the flat default 1 (unset for `new`), there is no
        // vpiAccessType, and vpiVirtual never rides it even when the
        // PROTOTYPE is virtual — the definition carries the body instead.
        bool oob = isOutOfBody(&member);
        bool oobCtor = oob && sub.name == "new";
        // § qualifiedCtorLosesPortListAndBody27 — CompileClass.cpp walks
        // `func_decl` past the class-item qualifiers to CLASSIFY the method
        // (:455), but then hands compileClassConstructorDeclaration the
        // UNADVANCED `fC->Child(id)` (:585) — which, when the constructor is
        // written `local`/`protected`/`static`, is the QUALIFIER node.
        // compileFunction re-runs setFuncTaskQualifiers internally
        // (CompileStmt.cpp:2304) and so is immune; the constructor routine is
        // not, and every node it derives from `Tf_port_list =
        // fC->Child(nodeId)` comes out invalid.  Measured (t37f, three arms
        // and two controls): the constructor keeps its name, vpiMethod and
        // return class_var and loses its io_decls, its whole body and the
        // return var's span.  This is all 21 `uvm_*_phase::new`
        // (`protected function new(string name="build"); super.new(name);`).
        bool qualCtor27 = false;
        if ((sub.flags & MethodFlags::Constructor) != MethodFlags::None)
            if (auto* csyn27 = sub.getSyntax())
                if (const syntax::SyntaxNode* p27 = csyn27->parent)
                    if (auto* cm27 =
                            p27->as_if<syntax::ClassMethodDeclarationSyntax>())
                        qualCtor27 = !cm27->qualifiers.empty();
        // § qualifiedLifetimeMethodLosesNamePortsBody46 — the SAME unadvanced
        // node, one function further along, and it costs the NAME as well.
        //
        // `CompileClass::compile_class_method_` hands `compileFunction` the
        // unadvanced `fC->Child(id)`, i.e. the QUALIFIER node.
        // `setFuncTaskQualifiers` unwraps a `Function_declaration` into its
        // child ONLY in its very first `if` (CompileStmt.cpp:1844), which is
        // reached only when the node handed in IS that Function_declaration —
        // with a qualifier in front, the qualifier loop consumes the qualifier
        // and RETURNS the Function_declaration still wrapped.  `compileFunction`
        // then takes `Child()` of it, which is the LIFETIME node whenever the
        // declaration writes `automatic`/`static`, instead of the
        // Function_body_declaration.  Everything derived from there comes out
        // invalid: the NAME, the `Tf_port_list` and the body.  vpiVisibility
        // survives (its own `if` did fire) and vpiAutomatic does NOT (its `if`
        // never saw the node) — which is exactly the field-for-field shape of
        // golden's object.
        //
        // MEASURED, not inferred, on three arms: t64a crosses `local` x
        // `automatic` x a two-token return type against six control spellings
        // and REFUTES BOTH of the handoff's candidate distinguishers (`local`
        // alone is named: f_loc_2tok, f_loc_1tok; a two-token `int unsigned`
        // return alone is named: f_auto_2tok, f_2tok).  t64b adds `protected`
        // (same artifact, vpiVisibility 2) and the multi-method collapse.  t64c
        // adds `virtual` and class-item `static` (same artifact) plus the
        // controls for each qualifier alone and for a lifetime alone, and its
        // c66c cell shows a written `static` LIFETIME does it too.
        //
        // Corpus reach is ONE object, and it is the whole remaining BuildUVMPkg
        // residue: `uvm_pkg.sv:75228 local function automatic int unsigned
        // ceil(...)` in class uvm_reg_map — confirmed to be the SAME object
        // behind LSTOTAL 2, r10uvm23m tf=2, IOTOTAL 2 and IOTOTAL2 3.  A census
        // over BOTH corpora (every UVM version included) finds exactly four
        // qualifier+lifetime sites: this one, its uvm_reg_map.svh original, and
        // two in Ibex (SLANG_REJECT).  uhdm2rtlil has none.
        //
        // NOT IMPLEMENTED, MEASURED AND RECORDED: when a class holds SEVERAL
        // such methods they COLLAPSE onto one object (t64a's six -> one
        // `function ''` at the LAST one's line but with the FIRST one's KIND;
        // t64b's c65d -> one, taking the last one's visibility) — and t64b's
        // c65b shows the collapse is not even uniform across kinds.  No corpus
        // test has two in one class, so this emits one stub per declaration and
        // leaves the collapse to the arm's record rather than guessing at it.
        // PROTOTYPES and OUT-OF-BODY definitions are excluded for the same
        // reason: they run through a different Surelog entry point
        // (`Method_prototype` / a package-scope compile) and no golden was read.
        bool qualLifetime46 = false;
        if (classScope && !protoOf && !oob && !cloneMode)
            if (auto* fsyn46 = sub.getSyntax())
                if (const syntax::SyntaxNode* p46 = fsyn46->parent)
                    if (auto* cm46 =
                            p46->as_if<syntax::ClassMethodDeclarationSyntax>())
                        if (!cm46->qualifiers.empty())
                            if (auto* fd46 =
                                    fsyn46->as_if<
                                        syntax::FunctionDeclarationSyntax>())
                                qualLifetime46 =
                                    !fd46->prototype->lifetime.valueText()
                                         .empty();
        // The OWNER path golden's stub carries in place of a full name: the
        // CLASS's own full name.  `prefix` here is the scope path WITH its
        // trailing separator (joinPath only appends the leaf), so drop it.
        std::string qualLifeOwner46 = prefix;
        if (qualLifeOwner46.size() >= 2 &&
            qualLifeOwner46.compare(qualLifeOwner46.size() - 2, 2, "::") == 0)
            qualLifeOwner46.resize(qualLifeOwner46.size() - 2);
        else if (!qualLifeOwner46.empty() && qualLifeOwner46.back() == '.')
            qualLifeOwner46.pop_back();
        // The CLASS's own copy of an out-of-body body is where Surelog's
        // module hoist re-binds unresolvable property names (the package
        // clone's stay unbound) — see classPropRefs.
        inClassBodyEmit = oob && classScope && !cloneMode;
        // § pkgVarBindsOnlyThroughInstance88 — the COMPLEMENT of the flag
        // above WITHIN a class: a method written inside the class body.  Read
        // straight off the same two locals that decide `pkgScopeInst` below
        // (`classScope && !oob` is exactly the case that leaves it null), so
        // the gate and the instance it models can never drift apart.
        inBodyClassMethod88 = classScope && !oob;
        // § dpiExportedPkgSubBareOwnTdUnsupported170 — the home package of a
        // package subroutine whose `export "DPI-C"` is written ABOVE its
        // definition.  Read off the SUBROUTINE's own declaring scope, not the
        // package being emitted, so a WILDCARD-IMPORT CLONE re-emitted into
        // another package keeps the same answer (golden degrades the clone's
        // copy too, and stamps it with the DECLARING package).
        dpiExportPkgHome170 =
            (!classScope && dpiExportPrecedesDef170(sub)) ? sub.getParentScope()
                                                          : nullptr;
        // § withIterRefBindsHoistNet75 — the same body's home PACKAGE, as a
        // slang symbol, for the refs that carry none of their own.  `body` IS
        // the class scope here (classScope), so its parent scope is the
        // package the class was declared in.
        classBodyHomePkg75 = nullptr;
        if (inClassBodyEmit)
            if (auto* cps75 = body.asSymbol().getParentScope();
                cps75 && cps75->asSymbol().kind == SymbolKind::Package)
                classBodyHomePkg75 = &cps75->asSymbol();
        // § pkgFreeSubRefVarHoistNet117 — the SAME pointer for the other body
        // kind Surelog's late binder treats identically (see UhdmExporter.h):
        // a package's OWN free function or task.  `homePkgSym` is already
        // `(pkgScope && !classScope) ? &body.asSymbol() : nullptr`, i.e. the
        // package itself, so the two states can never drift apart.
        //   * `pkgTopEmit` — the ELABORATED (top) package view ONLY.  Golden
        //     binds the wire on the `uhdmtopPackages` copy and leaves the
        //     `uhdmallPackages` copy unbound, and `design::Compare` walks
        //     AllPackages FIRST, so the def copy must stay as it is.
        //   * `!pkgImportCloneEmit` — a WILDCARD-IMPORT clone re-emitted into
        //     an IMPORTING package is not the home body; its home package is
        //     the importer, which is not where golden's pool lives.  Zero
        //     corpus HIT cells sit in a clone (the fence's four are all
        //     `uvm_pkg::uvm_process_report_message`, the home body).
        pkgFreeSubHomePkg117 = nullptr;
        if (pkgScope && !classScope && !cloneMode && pkgTopEmit &&
            !pkgImportCloneEmit)
            pkgFreeSubHomePkg117 = homePkgSym;
        // The instance every typespec minted for THIS subroutine takes.
        UHDM::instance* tsInst = (pkgScope && !classScope)
                                     ? (UHDM::instance*)m
                                     : (oob ? oobHomePkg : nullptr);
        pkgScopeInst = (pkgScope && !classScope) ? baseScopeInst : tsInst;
        bool isFunc = sub.subroutineKind == SubroutineKind::Function;
        // § fnLocalParamRangeNet — the subroutine's OWN declaration types
        // (return, formals, body locals) are compiled with its parameters out
        // of scope; a range bound naming one falls through to the module-level
        // late binding, which mints an implicit wire.  Both the scope and the
        // module to mint into must be live before the FIRST of those typespecs
        // is built (the return type, well ahead of the body).
        fnDeclTsSub = &sub;
        if (m->UhdmType() == UHDM::uhdmmodule_inst) {
            implicitNetModule = (UHDM::module_inst*)m;
            implicitNetPrefix = prefix;
        }
        // A DPI-EXPORTED subroutine is emitted as a function (even a task)
        // carrying DPI export attributes.
        bool dpiExport = false;
        const syntax::SyntaxNode* dpiExportSyn = nullptr;
        for (auto& ex : comp.getDPIExports())
            if (ex.subroutine == &sub) {
                dpiExport = true;
                dpiExportSyn = ex.syntax;
                break;
            }
        // § dpiExportListedAtExportItem216 — `getDPIExports()` is resolved ONCE,
        // inside `Compilation::elaborate()`, over the scopes reachable from
        // `getRoot()`; slang auto-instantiates only modules and programs as
        // tops, so a never-instantiated INTERFACE definition (which we still
        // list, because Surelog lists it in `AllInterfaces`) has its body
        // elaborated after that resolution and its export directives are never
        // resolved.  Surelog reads the export item straight out of the item
        // walk, so read it from the syntax too.  Both fences are on
        // `dpiExportItem216`.
        // (r10v216) Computed ONCE for the whole iteration: the fallback below,
        // the `pkgTfOrder9` key and the listing key all mean the same thing —
        // "this subroutine's own `export "DPI-C"` item, written ABOVE it".
        const syntax::SyntaxNode* dpiExportAbove216 =
            classScope ? nullptr : dpiExportItem216(sub);
        if (!dpiExport && dpiExportAbove216) {
            dpiExport = true;
            dpiExportSyn = dpiExportAbove216;
        }
        if (dpiExport)
            isFunc = true;
        std::string fullName = prefix.empty() ? std::string(sub.name)
                                              : joinPath(prefix, sub.name);

        // Reuse a shell created by an early (param-init) call site. Package
        // top-view re-emission must NOT reuse the def copy — a shell is
        // recognizable by its still-empty fullname.
        UHDM::task_func* tf = nullptr;
        bool reusedShell = false;
        if (auto sit = subMap.find(&sub);
            !protoOf && sit != subMap.end() && sit->second.tf &&
            (sharedScope || tfShells.count(sit->second.tf))) {
            tf = sit->second.tf;
            reusedShell = !sharedScope;
            tfShells.erase(sit->second.tf);
        }
        if (!tf)
            tf = isFunc ? (UHDM::task_func*)s.MakeFunction()
                        : (UHDM::task_func*)s.MakeTask();
        tf->VpiName(sub.name);
        tf->VpiFullName(fullName);
        // § qualifiedLifetimeMethodLosesNamePortsBody46 — no name, and the full
        // name stops at the CLASS (`uvm_pkg::uvm_reg_map`, not `...::ceil`),
        // because both come from the same invalid node.
        if (qualLifetime46) {
            tf->VpiName("");
            tf->VpiFullName(qualLifeOwner46);
        }
        tf->VpiParent(m);
        tfHomeSub9[tf] = &sub;
        // The def-view package listing names its clone "class::method" and
        // parents it at the package; the fullname is unchanged.
        if (cloneMode) {
            tf->VpiName(std::string(((UHDM::class_defn*)m)->VpiName()) +
                        "::" + std::string(sub.name));
            tf->VpiParent(pkgClassTfClone);
        }
        // An out-of-body DEFINITION carries vpiInstance = the HOME PACKAGE in
        // BOTH listings (Surelog compiles the definition in the package's
        // scope, not the class header's — the PROTOTYPE, compiled with the
        // class header, carries none).
        if (oob && oobHomePkg)
            tf->Instance(oobHomePkg);
        // A class CONSTRUCTOR carries no vpiVisibility (Surelog) — but an
        // `extern` PROTOTYPE of one does (vpiVisibility 1).
        if (protoOf) {
            tf->VpiVisibility(protoOf->visibility == Visibility::Protected ? 2
                              : protoOf->visibility == Visibility::Local   ? 3
                                                                          : 1);
            tf->VpiAccessType(2); // vpiExternAcc
            // The WRITTEN `virtual` keyword only: slang's isVirtual() is also
            // true for a method that merely OVERRIDES a virtual one
            // (svunit_testcase::report), where Surelog stamps nothing.
            if (protoOf->flags.has(MethodFlags::Virtual))
                tf->VpiVirtual(true);
        }
        else if (!(classScope && sub.name == "new"))
            tf->VpiVisibility(
                oob ? 1
                    : (classScope ? (sub.visibility == Visibility::Protected
                                         ? 2
                                         : (sub.visibility == Visibility::Local
                                                ? 3
                                                : 1))
                                  : 1));
        if (!protoOf && !oob && classScope &&
            (sub.flags & MethodFlags::Virtual) != MethodFlags::None)
            tf->VpiVirtual(true);
        bool dpiImport = (sub.flags & MethodFlags::DPIImport) != MethodFlags::None;
        if (dpiImport) {
            tf->VpiAccessType(4);
            if ((sub.flags & MethodFlags::DPIContext) != MethodFlags::None)
                tf->VpiDPIContext(true);
            tf->VpiDPICStr(2);
        }
        else if (dpiExport) {
            tf->VpiAccessType(3);
            tf->VpiDPICStr(2);
        }
        else if (sub.defaultLifetime == VariableLifetime::Automatic &&
                 !classScope) {
            // ...but only when the subroutine SAYS `automatic` itself. slang
            // reports the effective lifetime, which a `module automatic`
            // header hands down to every subroutine in it; Surelog reads the
            // declaration's own qualifier and leaves the inherited case
            // unmarked (FuncStatic: `module automatic test(); function
            // integer accumulate2(...)` carries no vpiAutomatic).
            bool ownAuto9 = true;
            if (auto lsyn9 = sub.getSyntax())
                if (auto* fd9 = lsyn9->as_if<syntax::FunctionDeclarationSyntax>())
                    ownAuto9 = fd9->prototype->lifetime.valueText() == "automatic";
            if (ownAuto9)
                tf->VpiAutomatic(true);
        }
        // An `extern` PROTOTYPE spans its own declaration, and the same
        // qualifier-collapse artifact applies as for `static`: a FUNCTION
        // prototype collapses onto the `extern` token alone, a TASK
        // prototype keeps the whole declaration up to (but not including)
        // its semicolon. Measured on every svunit prototype.
        if (protoOf) {
            if (auto psyn9 = protoOf->getSyntax()) {
                const auto* holder9 =
                    psyn9->kind == syntax::SyntaxKind::ClassMethodPrototype
                        ? &psyn9->as<syntax::ClassMethodPrototypeSyntax>()
                    : psyn9->parent && psyn9->parent->kind ==
                                           syntax::SyntaxKind::ClassMethodPrototype
                        ? &psyn9->parent->as<syntax::ClassMethodPrototypeSyntax>()
                        : nullptr;
                SourceRange r9 = psyn9->sourceRange();
                if (holder9 && !holder9->qualifiers.empty()) {
                    auto q9 = holder9->qualifiers[0].range();
                    r9 = protoOf->subroutineKind == SubroutineKind::Function
                             ? q9
                             : SourceRange(q9.start(),
                                           holder9->prototype->sourceRange().end());
                }
                setLoc(tf, r9);
            }
        }
        // An exported FUNCTION locates at the export DIRECTIVE's span
        // (an exported TASK keeps its definition span).
        else if (dpiExportSyn && sub.subroutineKind == SubroutineKind::Function)
            setLoc(tf, dpiExportSyn->sourceRange());
        else if (auto syn = sub.getSyntax()) {
            // A STATIC class method spans only its `static` qualifier token
            // (a Surelog populateCoreMembers artifact).
            const syntax::SyntaxNode* qualHolder =
                classScope && syn->parent &&
                        syn->parent->kind == syntax::SyntaxKind::ClassMethodDeclaration
                    ? syn->parent
                    : nullptr;
            bool staticSpan = false;
            bool virtualQual = false;
            // § classMethodQualSpan144 (r11u144) — measured on golden, grid
            // tools/probe/r11u144repro/grid/vf: a class FUNCTION written with
            // class-item qualifiers spans its FIRST qualifier token, `virtual`
            // included (`virtual function void f();` 2:3-2:10, `virtual
            // protected function` on `virtual`), while a class TASK spans the
            // whole declaration whatever its qualifiers (`static task`,
            // `protected virtual task`, `virtual protected task`: 2:3-3:10).
            // Switch: R11U144_METHQUALSPAN_OFF.
            static const bool mq144 = r11u144Law("R11U144_METHQUALSPAN_OFF");
            const bool isFn144 =
                sub.subroutineKind == SubroutineKind::Function;
            if (qualHolder && mq144)
                for (auto q : qualHolder->as<syntax::ClassMethodDeclarationSyntax>()
                                  .qualifiers) {
                    bool cq144 =
                        q.kind == slang::parsing::TokenKind::StaticKeyword ||
                        q.kind == slang::parsing::TokenKind::LocalKeyword ||
                        q.kind == slang::parsing::TokenKind::ProtectedKeyword ||
                        q.kind == slang::parsing::TokenKind::VirtualKeyword;
                    if (!cq144)
                        continue;
                    if (isFn144) {
                        setLoc(tf, q.range());
                        staticSpan = true;
                    }
                    else
                        virtualQual = true;
                    break;
                }
            if (qualHolder && !mq144)
                for (auto q : qualHolder->as<syntax::ClassMethodDeclarationSyntax>()
                                  .qualifiers) {
                    // `static` / `local` / `protected` collapse the span onto
                    // the qualifier token itself.
                    if (q.kind == slang::parsing::TokenKind::StaticKeyword ||
                        q.kind == slang::parsing::TokenKind::LocalKeyword ||
                        q.kind == slang::parsing::TokenKind::ProtectedKeyword) {
                        setLoc(tf, q.range());
                        staticSpan = true;
                        break;
                    }
                    if (q.kind == slang::parsing::TokenKind::VirtualKeyword)
                        virtualQual = true;
                }
            if (!staticSpan) {
                // A plain `virtual` method spans the WHOLE declaration,
                // qualifier included.
                SourceRange whole144 =
                    virtualQual ? qualHolder->sourceRange() : syn->sourceRange();
                // § methodSpanSkipsAttrs144 — ...but not its attributes
                // (`(* keep *) virtual task t();` 2:14-3:10, grid at/fe).
                if (virtualQual && r11u144Law("R11U144_METHATTR_OFF")) {
                    auto& cmd144 =
                        qualHolder->as<syntax::ClassMethodDeclarationSyntax>();
                    if (!cmd144.attributes.empty() && !cmd144.qualifiers.empty())
                        whole144 = SourceRange(cmd144.qualifiers[0].range().start(),
                                               whole144.end());
                }
                setLoc(tf, whole144);
            }
        }
        if (protoOf || ((designScope || classScope) && (!oob || oobCtor)))
            tf->VpiMethod(true);
        if (!genScope && !designScope && !classScope)
            tf->Instance((UHDM::instance*)m);

        // A class CONSTRUCTOR has no declared return type; Surelog still gives
        // it a class_var return typed by the enclosing class (an unnamed,
        // unlocated class_typespec), anchored at the FIRST formal's name span.
        if (classScope && sub.name == "new" && currentClassDefn) {
            auto* rv = s.MakeClass_var();
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            auto args0 = sub.getArguments();
            // ...unless a class-item qualifier displaced the anchor, in which
            // case the `varId` that span comes from is invalid too
            // (§ qualifiedCtorLosesPortListAndBody27, t37f).
            // § externProtoFormalsFromPrototype175, the CONSTRUCTOR half —
            // the class-body listing of an `extern function new(...)` is the
            // prototype compile (compileFunctionPrototype), whose return
            // class_var is never located: golden `class_var` 0:0 with no
            // file (grid f4/a03_ctor).  Switch R11U175_FSPAN_OFF.
            if (!args0.empty() && !qualCtor27 &&
                !(protoOf && r11u175LawB("R11U175_FSPAN_OFF")))
                setLoc(rv, nameSpan(args0[0]->location, args0[0]->name));
            auto* cts = s.MakeClass_typespec();
            // ...but only in the CLASS's own listing. The def-view package
            // CLONE of an out-of-body constructor leaves the link null:
            // Surelog compiles that listing before the class_defn exists.
            // (uhdm-dump prints a bare `class_typespec` either way — probe
            // tools/probe/r10dsg.cpp reads the link.)
            if (!cloneMode)
                cts->Class_defn(currentClassDefn);
            // Surelog names this typespec after the class's vpiName, which at
            // compile time is only set for a NESTED class (a top-level class
            // gets its name in the write phase, so its ctor typespec stays
            // anonymous). compileClassConstructorDeclaration, CompileStmt.cpp.
            if (auto* cp9 = currentClassDefn->VpiParent();
                cp9 && cp9->UhdmType() == UHDM::uhdmclass_defn)
                cts->VpiName(currentClassDefn->VpiName());
            // An `extern` ctor PROTOTYPE is different: Surelog compiles the
            // class HEADER, where the definition is already registered, so the
            // typespec takes the class's FULL name (`svunit_pkg::svunit_base`)
            // while the out-of-body DEFINITION's stays anonymous.
            if (protoOf)
                cts->VpiName(currentClassDefn->VpiFullName().empty()
                                 ? currentClassDefn->VpiName()
                                 : currentClassDefn->VpiFullName());
            auto* crt = s.MakeRef_typespec();
            crt->VpiFullName(fullName);
            crt->VpiParent(rv);
            crt->Actual_typespec(cts);
            rv->Typespec(crt);
            ((UHDM::function*)tf)->Return(rv);
        }

        SubInfo si;
        si.tf = tf;
        // Bodies see module-level nets too (shadowed formals override).
        NetMap funcMap;
        if (info)
            funcMap = info->nets;
        // § formalDefaultBindsLikeBody13 — the FORMALS-ONLY half of funcMap,
        // filled in DECLARATION ORDER as each io_decl is built, and read by a
        // later formal's DEFAULT VALUE (see the emission site below).  It is a
        // second map rather than funcMap itself because funcMap starts life
        // holding the enclosing module's NETS: golden binds those in a default
        // value too (arm v2 `mf_net`/`mf_var`, `ifb_net`), but that is a
        // POPULATION this pass measured at ZERO on both corpora and left
        // deliberately (residue R1), and a map that carried them would move
        // cells no census had predicted.
        NetMap dvFormals13;
        TsCache ioTs;

        // A DPI-IMPORT prototype has no returnValVar; synthesize its Return
        // var (anonymous, at the return-type token, ts ref to a fresh ts).
        if (isFunc && !sub.returnValVar && dpiImport && !sub.getReturnType().isVoid()) {
            // § implicitRetSigningIsIntVar70, site 2 of 4.  ZERO POPULATION AND
            // SAID SO: golden emits NO Return var at all for a DPI import whose
            // return type is implicit-plus-signing (arm a4 cell 18:27, golden
            // side empty), so this site's cell is an over-emit we already had
            // and the law only changes its CLASS.  Neither corpus contains the
            // spelling, so it moves no byte; it is gated here rather than left
            // behind so the factory's callers all state the same predicate.
            auto* rv = makeReturnVar(
                s, sub.getReturnType(),
                implicitRetWrittenSigning70(returnTypeSyntax(sub)));
            // § atomVarSignedWritten68, site 2 of 7 — a DPI-IMPORT prototype's
            // synthesized return var (arm a5 cell 27:27).
            clearNamedAtomSigned68(rv, sub.getReturnType());
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            if (auto* rsyn = returnTypeSyntax(sub)) {
                tfContext = true;
                auto* ts = makeTypespec(sub, rsyn);
                tfContext = false;
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(fullName);
                rt->VpiParent(rv);
                rt->Actual_typespec(ts);
                // A DPI import is a package subroutine like any other: its
                // return typespec takes the package vpiInstance, view-matched
                // (repro r3 `import "DPI-C" function int dpi_chk` — golden
                // p1#DEF in the def listing, p1#TOP in every elaborated one;
                // SeqDriver's 13 uvm_hdl_*/uvm_dpi_* returns x 4 listings).
                if (tsInst) {
                    ts->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
                    stampElemTsInstance(ts, (UHDM::instance*)ts->Instance());
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back(ts);
                }
                rv->Typespec(rt);
                copyLoc(rv, ts);
            }
            ((UHDM::function*)tf)->Return(rv);
        }
        // § qualifiedLifetimeMethodLosesNamePortsBody46 — the RETURN VAR too.
        // With the data-type node invalid, `returnType->init` never runs and
        // Surelog's default return class is LOGIC, so golden's stub returns a
        // bare `logic_var` carrying ONLY the class's full name: no name, no
        // typespec (not even a ref_typespec) and no location.  Measured on the
        // t64c/c66c cell and on every t64a/t64b stub.  VpiType is a COMPARED
        // field, so emitting our ordinary `int_var` here would keep the object
        // unequal even with the name fixed.
        if (isFunc && qualLifetime46 && !sub.getReturnType().isVoid()) {
            auto* rv46 = s.MakeLogic_var();
            rv46->VpiFullName(qualLifeOwner46);
            rv46->VpiParent(tf);
            ((UHDM::function*)tf)->Return(rv46);
        }
        // § externProtoFormalsFromPrototype175, the RETURN half — the
        // class-body listing of an `extern` method compiles its return
        // variable from the PROTOTYPE's return type (compileFunctionPrototype
        // -> compileVariable over the prototype's Function_data_type), so the
        // return var, its typespec and its range bounds sit at the
        // prototype's return-type token (grid f4/a04_class_formal
        // `extern function item get(...)` 4:21-4:25, f4/a05_ranges
        // `bit [3:0]` 3:21-3:30).  Switch R11U175_FSPAN_OFF.
        auto retTypeSyn175 = [&](const SubroutineSymbol& s175)
            -> const syntax::SyntaxNode* {
            if (protoOf && r11u175LawB("R11U175_FSPAN_OFF"))
                if (const syntax::SyntaxNode* p175 = protoOf->getSyntax()) {
                    if (p175->kind == syntax::SyntaxKind::ClassMethodPrototype)
                        p175 = p175->as<syntax::ClassMethodPrototypeSyntax>()
                                   .prototype;
                    if (p175 &&
                        p175->kind == syntax::SyntaxKind::FunctionPrototype)
                        return p175->as<syntax::FunctionPrototypeSyntax>()
                            .returnType;
                }
            return returnTypeSyntax(s175);
        };
        // Function return: an anonymous variable carrying only the full name,
        // anchored at the return-type syntax like its typespec.
        if (isFunc && !qualLifetime46 && sub.returnValVar &&
            !sub.getReturnType().isVoid()) {
            // A return type Surelog cannot resolve (the cover-cross implicit
            // CrossQueueType) leaves CompileType with no variable class to
            // pick: the return object is a bare ref_var pointing at the
            // unsupported_typespec makeTypespec mints for it (CrossFunc).
            bool crossImplicitRet = false;
            if (sub.getReturnType().kind == SymbolKind::TypeAlias)
                if (auto xsc =
                        sub.getReturnType().as<TypeAliasType>().getParentScope();
                    xsc && xsc->asSymbol().kind == SymbolKind::CoverCrossBody)
                    crossImplicitRet = true;
            // § implicitRetSigningIsIntVar70, site 1 of 4 — THE HEAD'S OWN
            // SITE.  The ordinary return variable: in-class method,
            // out-of-body `extern` body, package-homed free function and
            // module-homed function alike (arm a3 cells 16/24/29/52/59, arm a1
            // cells 8/11/16/19).  `uvm_tr_stream::get_recorders` @371:13 and
            // `uvm_tr_database::get_streams` @186:13 are this cell.
            // § classTdLocalVarKindFollowsCompileOrder10, SITE 3 of 5 — THE
            // RETURN VARIABLE.  Surelog compiles it with the same
            // `compileVariable`, so the same law governs it: grid `g7`'s
            // `r_late_struct` / `r_late_cls` are `class_var` in golden against
            // our `struct_var` / `ref_var`, and `r_ext_early` / `r_ext_own`
            // show the out-of-body arm.  On the corpus this is the
            // `uvm_resource_pool::lookup_name` family — six SeqDriver rows
            // returning `uvm_resource_types::rsrc_q_t`.
            // § externProtoRetVarKindIsPrototypeCompile185 — THE HEAD'S OWN
            // SITE.  In the CLASS-BODY PROTOTYPE listing of an `extern` method
            // (`protoOf` set) Surelog compiles the return variable from the
            // PROTOTYPE, in the class: law 10 must be asked about the
            // MethodPrototypeSymbol, not about the out-of-body definition whose
            // `outOfBlockIndex` and written spelling answer the DEFINITION
            // listing's question.  The BuildUVMPkg head is `uvm_printer::
            // object_printed` returning `uvm_policy::recursion_state_e`
            // (uvm_pkg.sv:19055) — golden `enum_var`, ours `class_var`.  Law,
            // Surelog's two `compileFunction` calls and the golden g7 table:
            // src/EmitHelpers.h.
            UHDM::variables* lateRv10 = nullptr;
            if (!crossImplicitRet)
                switch (externProtoRetVarKind185(sub, protoOf)) {
                    case TdLocalVarKind10::ClassVar:
                        lateRv10 = s.MakeClass_var();
                        break;
                    case TdLocalVarKind10::RefVar:
                        lateRv10 = s.MakeRef_var();
                        break;
                    case TdLocalVarKind10::Resolved:
                        break;
                }
            // § namedBaseUnpackedTdRetVar22 — the UNPACKED-ARRAY typedef
            // return.  It runs only where § classTdLocalVarKindFollowsCompile-
            // Order10 answered `Resolved`, so the OUT-OF-BODY arm that law owns
            // (golden `class_var`, cells `po_q_cls` / `po_q_int` / `po_f_cls`)
            // is untouched, and only where the return type is a typedef with
            // dimensions WRITTEN ON IT.  Law + the 190-cell golden table +
            // the corpus fence: src/EmitHelpers.h.
            if (!crossImplicitRet && !lateRv10)
                switch (unpackedTdRetVarKind22(
                    sub, sub.getReturnType(),
                    curPkgEmitSym && !pkgEmitTopView)) {
                    case UnpackedTdRetKind22::RefVar:
                        lateRv10 = s.MakeRef_var();
                        break;
                    case UnpackedTdRetKind22::ArrayVar:
                        lateRv10 = s.MakeArray_var();
                        break;
                    case UnpackedTdRetKind22::Unchanged:
                        break;
                }
            // § ownNamedAliasRetIsRefVar177 — THE HEAD'S OWN SITE.  A return
            // type written as a BARE NAME resolving to a typedef of a NAMED
            // TYPE declared in the very component compiling this listing has
            // no typespec yet when Surelog's `compileVariable` runs
            // (`ElaborationStep::bindTypedefs_` binds it afterwards), so
            // `getSimpleVarFromTypespec` is never reached and the object is
            // the bare `ref_var` of CompileType.cpp:421.  The SimpleUVM head
            // is `uvm_sequencer_base::get_arbitration` returning
            // `UVM_SEQ_ARB_TYPE` in the package's DEF listing.  Law, the
            // listing axis and the cells that must NOT move: src/EmitHelpers.h.
            if (!crossImplicitRet && !lateRv10 &&
                ownNamedAliasRetIsRefVar177(
                    sub, sub.getReturnType(), curPkgEmitSym && !pkgEmitTopView,
                    pkgClassTfClone != nullptr && !pkgImportCloneEmit))
                lateRv10 = s.MakeRef_var();
            auto* rv =
                crossImplicitRet
                    ? (UHDM::variables*)s.MakeRef_var()
                    : lateRv10
                          ? lateRv10
                          : makeReturnVar(
                                s, sub.getReturnType(),
                                implicitRetWrittenSigning70(retTypeSyn175(sub)));
            // § atomVarSignedWritten68, site 3 of 7 — THE ordinary return
            // variable, in-class, out-of-body `extern`, package-homed and
            // module-homed alike (arm a5 cells 12:12 pkf, 21:10 V5::ex_ret,
            // 29:12 selfref; arm a1 f_ret_t / f_mret_t).  The
            // `crossImplicitRet` arm above makes a ref_var and never reaches
            // the atom factory, so it is deliberately not gated.
            clearNamedAtomSigned68(rv, sub.getReturnType());
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            // An IMPLICIT return type ("function f;") yields a bare return var:
            // no typespec, no location.
            bool implicitRet = false;
            if (auto* rsyn = retTypeSyn175(sub)) {
                if (rsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    auto& its = rsyn->as<syntax::ImplicitTypeSyntax>();
                    implicitRet = its.dimensions.empty() && !its.signing.valid();
                }
            }
            else {
                implicitRet = true;
            }
            if (implicitRet) {
                ((UHDM::function*)tf)->Return(rv);
            }
            else {
            // Struct-typed returns reference the shared struct typedef
            // (matched by canonical type since the return type may be a
            // distinct alias instance).
            UHDM::typespec* ts = nullptr;
            auto& retCanon = sub.getReturnType().getCanonicalType();
            if (retCanon.kind == SymbolKind::PackedStructType ||
                retCanon.kind == SymbolKind::UnpackedStructType ||
                retCanon.kind == SymbolKind::EnumType) {
                // § retNamedTdWinsOverCanon140 — THE TYPEDEF THE RETURN TYPE
                // ACTUALLY NAMES WINS.  The canonical-type scan below answers
                // "some TypeAlias whose canonical type is this one", and with
                // an ALIAS OF A TYPEDEF (`typedef uvm_sequence_state
                // uvm_sequence_state_enum;`, uvm_object_globals.svh:412) TWO
                // aliases share one canonical enum, so the scan returned
                // whichever `typedefTs` (a pointer-keyed std::map) held first
                // -- the BASE.  Surelog resolves the return type by NAME:
                // `compileTypespec`'s named arm hands back the typespec
                // registered for the datatype the return token spells, so
                // golden's `enum_var uvm_pkg::uvm_sequence_base::
                // get_sequence_state` binds the `uvm_sequence_state_enum`
                // object (Typedef_alias -> the base) and never the base
                // itself.  Look the NAMED alias up first; the canonical scan
                // stays as the fallback for a return type that is not a
                // registered TypeAlias (a $unit duplicate instance, an
                // anonymous enum, an alias whose own object was never
                // listed) -- every one of those keeps its old answer.
                if (auto& rdt140 = sub.getReturnType();
                    rdt140.kind == SymbolKind::TypeAlias) {
                    if (auto it140 = typedefTs.find(&rdt140);
                        it140 != typedefTs.end())
                        ts = it140->second;
                }
                if (!ts)
                    for (auto& [sym, tsp] : typedefTs)
                        if (sym->kind == SymbolKind::TypeAlias &&
                            &sym->as<TypeAliasType>().getCanonicalType() ==
                                &retCanon) {
                            ts = tsp;
                            break;
                        }
            }
            // A typedef'd VECTOR return gets a fresh NAMED clone (at the
            // typedef site) with a Typedef_alias ref; the return var anchors
            // at the return-type token.
            bool typedefRetClone = false;
            bool pkgUnitRet9 = false;
            // A bare typedef return CLONE is instanced at the typedef's home
            // package even inside a CLASS listing, where a method's own
            // typespecs are otherwise uninstanced: the clone belongs to the
            // package compile, not to the class.  Carries the view-matched
            // listing object's own instance.
            UHDM::instance* retCloneInst9 = nullptr;
            if (!ts) {
                auto& rdt = sub.getReturnType();
                // The return alias may be a DISTINCT TypeAlias instance
                // ($unit): match the registered typedef by name+canonical.
                UHDM::typespec* retBase = nullptr;
                const TypeAliasType* retAlias = nullptr;
                if (rdt.kind == SymbolKind::TypeAlias) {
                    retAlias = &rdt.as<TypeAliasType>();
                    if (auto it0 = typedefTs.find(&rdt); it0 != typedefTs.end())
                        retBase = it0->second;
                    else
                        for (auto& [sym0, tsp0] : typedefTs)
                            if (sym0->kind == SymbolKind::TypeAlias &&
                                sym0->name == rdt.name &&
                                &sym0->as<TypeAliasType>().getCanonicalType() ==
                                    &rdt.getCanonicalType()) {
                                retBase = tsp0;
                                retAlias = &sym0->as<TypeAliasType>();
                                break;
                            }
                }
                // Pkg/$unit typedef returns SHARE the typedef ts (no clone) —
                // EXCEPT a function declared INSIDE the typedef's own package,
                // whose return gets a BARE-named clone with a Typedef_alias
                // ref to the shared ts (jeras_union imm_i_f -> imm_i_t).
                //
                // "INSIDE the package" reaches through CLASSES: a method of a
                // package class (in-body or out-of-body) is compiled in the
                // package too, and Surelog gives its return the same bare
                // clone — SeqDriver's uvm_pkg class methods returning
                // `uvm_reg_data_t`/`uvm_action` are 300+ of them, all bare and
                // all with a per-function object.  Walk the scope chain up
                // through class scopes to the enclosing package.
                bool sameScopePkgFn9 = false;
                const Scope* scrPkgOf9 = nullptr;
                if (retAlias)
                    if (auto scr9 = retAlias->getParentScope()) {
                        pkgUnitRet9 =
                            scr9->asSymbol().kind == SymbolKind::Package;
                        scrPkgOf9 = scr9;
                        const Scope* fsc9 = sub.getParentScope();
                        while (fsc9 && fsc9 != scr9 &&
                               (fsc9->asSymbol().kind == SymbolKind::ClassType ||
                                fsc9->asSymbol().kind ==
                                    SymbolKind::GenericClassDef))
                            fsc9 = fsc9->asSymbol().getParentScope();
                        if (pkgUnitRet9 && pkgScope && fsc9 == scr9)
                            sameScopePkgFn9 = true;
                    }
                // The clone is not a logic-typedef privilege: every SCALAR
                // typedef takes it (`typedef bit [63:0] uvm_reg_data_t`,
                // `typedef int uvm_action` — golden names both BARE, with a
                // Typedef_alias back to the qualified listing object).  Only
                // the aggregate kinds (struct/enum/array/class) keep sharing
                // the typedef object.
                bool scalarRetBase9 =
                    retBase && (retBase->UhdmType() == UHDM::uhdmlogic_typespec ||
                                retBase->UhdmType() == UHDM::uhdmbit_typespec ||
                                retBase->UhdmType() == UHDM::uhdmint_typespec ||
                                retBase->UhdmType() ==
                                    UHDM::uhdminteger_typespec ||
                                retBase->UhdmType() == UHDM::uhdmbyte_typespec ||
                                retBase->UhdmType() ==
                                    UHDM::uhdmshort_int_typespec ||
                                retBase->UhdmType() ==
                                    UHDM::uhdmlong_int_typespec);
                if (retBase && sameScopePkgFn9 && scalarRetBase9) {
                    const syntax::SyntaxNode* targetSyn9 = nullptr;
                    if (auto asyn9 = retAlias->getSyntax())
                        if (asyn9->kind ==
                            syntax::SyntaxKind::TypedefDeclaration)
                            targetSyn9 =
                                asyn9->as<syntax::TypedefDeclarationSyntax>()
                                    .type;
                    bypassTypedefShare = true;
                    // The DEF-view return clone stays SYMBOLIC; the TOP-view
                    // one FOLDS (Surelog re-elaborates it) — jeras_union
                    // imm_*_f.  § pkgTdRangeViewFold18 generalises "TOP view"
                    // from `pkgTopEmit` (which is already cleared by the time
                    // the package's CLASSES are emitted, so their methods'
                    // return clones stayed symbolic) to the whole view.
                    tfContext = pkgTdOwnDefView(*retAlias);
                    bool savedNb9 = tdCloneRefNoBind18;
                    tdCloneRefNoBind18 = true;  // § pkgTdCloneRefNoBind18
                    tfTypeScope = sub.getParentScope();
                    ts = makeTypespec(*sub.returnValVar, targetSyn9);
                    tdCloneRefNoBind18 = savedNb9;
                    // The return clone's alias binds the pkg LISTING object of
                    // its own view: the def listing for the def fn, the
                    // top/module listing for the elab fn (Surelog; the fresh
                    // per-function twin belongs to the BODY-local clone, not
                    // the return) — jeras_union imm_i_f.
                    UHDM::typespec* rtw9 = retBase;
                    // § pkgTdRangeViewFold18: "the elaborated view" is every
                    // view but the typedef's home package DEF listing — the
                    // package's own class methods seen from the ELAB view
                    // included, where `pkgTopEmit` is already cleared.
                    if (!pkgTdOwnDefView(*retAlias))
                        if (auto tt9 = pkgTopTypedefTs.find(
                                (const void*)retAlias);
                            tt9 != pkgTopTypedefTs.end() && tt9->second)
                            rtw9 = tt9->second;
                    tfTypeScope = nullptr;
                    tfContext = false;
                    bypassTypedefShare = false;
                    ts->VpiName(rdt.name);
                    auto* art9 = s.MakeRef_typespec();
                    art9->VpiFullName(std::string(rdt.name));
                    art9->VpiParent(ts);
                    art9->Actual_typespec(rtw9);
                    ts->Typedef_alias(art9);
                    // View-matched at the typedef's HOME package: the def
                    // listing's clone names the def copy, everything the
                    // ELABORATED pass mints (including the class's own method
                    // listing, where `tsInst` is deliberately null) names the
                    // top copy.  `pkgEmitTopView` — not `pkgTopEmit`, which is
                    // already cleared by the time the classes are emitted.
                    if (scrPkgOf9) {
                        const Symbol* hpk9 = &scrPkgOf9->asSymbol();
                        auto& hmap9 = pkgEmitTopView ? pkgTopMap : pkgDefMap;
                        if (auto hit9 = hmap9.find((const void*)hpk9);
                            hit9 != hmap9.end())
                            retCloneInst9 = (UHDM::instance*)hit9->second;
                    }
                    typedefRetClone = true;
                }
                else if (retBase && pkgUnitRet9) {
                    ts = retBase;
                }
                else if (retBase &&
                         retBase->UhdmType() == UHDM::uhdmlogic_typespec) {
                    const syntax::SyntaxNode* targetSyn = nullptr;
                    if (auto asyn = retAlias->getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            targetSyn =
                                asyn->as<syntax::TypedefDeclarationSyntax>().type;
                    bypassTypedefShare = true;
                    // § modTdRetCloneSymbolic20 (r10earl20) — the return
                    // clone of a MODULE-LOCAL scalar typedef keeps the
                    // typedef's range SYMBOLIC, the same way the package
                    // branch above does for its own def view.  Without
                    // tfContext the clone is built under the module rule and
                    // folds the bound, so `typedef logic [4:0][4:0][W-1:0]
                    // box_t;` reads back `[63:0]` where golden keeps the
                    // `W-1` operation.  pz20.sv is the two-line witness and
                    // bisects to the same field chain as the corpus head:
                    // cont_assign > func_call > function > Return logic_var >
                    // ref_typespec > logic_typespec 'box_t' > Ranges[2] >
                    // Left_expr.  Corpus: def:work@prim_keccak :24:28.
                    bool savedTf20 = tfContext;
                    tfContext = true;
                    ts = makeTypespec(*sub.returnValVar, targetSyn);
                    tfContext = savedTf20;
                    bypassTypedefShare = false;
                    // Pkg typedefs qualify the clone name (P::S).
                    std::string qn9(rdt.name);
                    if (auto scq9 = retAlias->getParentScope();
                        scq9 &&
                        scq9->asSymbol().kind == SymbolKind::Package)
                        qn9 = std::string(scq9->asSymbol().name) + "::" + qn9;
                    ts->VpiName(qn9);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(qn9);
                    art->VpiParent(ts);
                    art->Actual_typespec(retBase);
                    ((UHDM::logic_typespec*)ts)->Typedef_alias(art);
                    typedefRetClone = true;
                }
                else if (retBase &&
                         retBase->UhdmType() == UHDM::uhdmarray_typespec &&
                         retAlias) {
                    // An UNPACKED-ARRAY typedef return gets its OWN
                    // array_typespec twin — same shape as the module listing
                    // but BARE-scoped inner refs — carrying a Typedef_alias
                    // back to the listed object (Surelog; ArrayExprFuncArg,
                    // DefaultPattern*).
                    // § queueRetTwinDynShape191 (r11u191, R11U191_QUEUERANGE_OFF)
                    // — buildUnpackedArrayTypedefTs reads its alias through
                    // `as<FixedSizeUnpackedArrayType>()`, but this branch is
                    // taken for EVERY array_typespec return, so a QUEUE (or
                    // dynamic / associative) typedef return (uvm_misc.svh 642
                    // `typedef TYPE types_t[$];` returned by `find_all`) had
                    // its `range` read out of a QueueType: `left` = maxBound,
                    // `right` = the four padding bytes after it — arena
                    // garbage, the UVM `UINT:<n>` value coin (r11u190
                    // section 8, N9).  The twin of a dynamic container takes
                    // the listing's own shape instead
                    // (buildDynContainerTypedefTs: `UINT:0 .. STRING:$` at
                    // the `$` token for a queue; Surelog's typedef path stops
                    // at compileTypespec).  The twin is in the weakly
                    // referenced tail, so only the bytes move (grid
                    // tools/probe/r11u191dec/cases/Q).
                    UHDM::array_typespec* cl9 = nullptr;
                    if (retAlias->targetType.getType().getCanonicalType().kind !=
                            SymbolKind::FixedSizeUnpackedArrayType &&
                        r191TF("R11U191_QUEUERANGE_OFF")) {
                        const syntax::SyntaxNode* tsyn191 = nullptr;
                        if (auto asyn = retAlias->getSyntax())
                            if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                                tsyn191 =
                                    asyn->as<syntax::TypedefDeclarationSyntax>().type;
                        if (auto* d191 = buildDynContainerTypedefTs(*retAlias, tsyn191);
                            d191 && d191->UhdmType() == UHDM::uhdmarray_typespec) {
                            tr191TF("queueRetTwinDynShape191");
                            cl9 = (UHDM::array_typespec*)d191;
                        }
                    }
                    // § queueTwinKeepsElem204v (r11u204, R11V204_QTWINELEM_OFF;
                    // refines § queueRetTwinDynShape191) — the listing's
                    // dynamic-container shape carries no element typespec,
                    // where golden's return twin keeps the element's (golden
                    // cases/V191 qr3: `typedef e_t eq_t[$]` returned by a
                    // class method, the enum_typespec under the twin); the
                    // clone form's element (pristine's: its element read is
                    // sound, only its range read the queue as a fixed array)
                    // is carried over.
                    // A queue of a class TYPE PARAMETER (`typedef T tq_t[$]`,
                    // uvm_misc.svh 642 `typedef TYPE types_t[$]`) keeps no
                    // element in golden (cases/V191 qr2: no `<in>tq_t` record;
                    // the UVM rows' `types_t` twin likewise): not carried.
                    bool tpElem204 = false;
                    if (auto asyn = retAlias->getSyntax();
                        asyn && asyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                        const syntax::SyntaxNode* tsyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                        if (tsyn && tsyn->kind == syntax::SyntaxKind::NamedType)
                            if (auto* sc204 = retAlias->getParentScope()) {
                                std::string nm204 =
                                    tsyn->as<syntax::NamedTypeSyntax>().name->toString();
                                while (!nm204.empty() && isspace((unsigned char)nm204.front()))
                                    nm204.erase(nm204.begin());
                                while (!nm204.empty() && isspace((unsigned char)nm204.back()))
                                    nm204.pop_back();
                                // (in a class specialization the name finds the
                                // type parameter's own alias, declared by a
                                // TypeAssignment of the parameter port list)
                                if (auto* ls204 = sc204->lookupName(nm204);
                                    ls204 && (ls204->kind == SymbolKind::TypeParameter ||
                                              (ls204->kind == SymbolKind::TypeAlias &&
                                               ls204->getSyntax() &&
                                               ls204->getSyntax()->kind ==
                                                   syntax::SyntaxKind::TypeAssignment)))
                                    tpElem204 = true;
                            }
                    }
                    if (cl9 && !cl9->Elem_typespec() && !tpElem204 &&
                        r11v204Law("R11V204_QTWINELEM_OFF")) {
                        auto* cf204 = buildUnpackedArrayTypedefTs(
                            *retAlias, std::string(rdt.name), /*cloneForm=*/true);
                        // only a non-aggregate element: the clone form's struct
                        // element (a bare-scoped named clone) does not match
                        // golden's (cases/V191 qr3 pq_t / uq_t, r11u196repro
                        // V191/qr01: records golden lacks), so it is left out
                        auto* er204 = cf204 ? cf204->Elem_typespec() : nullptr;
                        if (auto* ea204 = er204 ? er204->Actual_typespec() : nullptr;
                            ea204 && (ea204->UhdmType() == UHDM::uhdmstruct_typespec ||
                                      ea204->UhdmType() == UHDM::uhdmunion_typespec))
                            er204 = nullptr;
                        if (er204) {
                            er204->VpiParent(cl9);
                            cl9->Elem_typespec(er204);
                            cf204->Elem_typespec(nullptr);
                            tr204("queueTwinKeepsElem204v", std::string(rdt.name));
                        }
                    }
                    if (!cl9)
                        cl9 = buildUnpackedArrayTypedefTs(
                            *retAlias, std::string(rdt.name), /*cloneForm=*/true);
                    cl9->VpiName(rdt.name);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(std::string(rdt.name));
                    art->VpiParent(cl9);
                    art->Actual_typespec(retBase);
                    cl9->Typedef_alias(art);
                    ts = cl9;
                    typedefRetClone = true;
                }
            }
            // A CLASS-HANDLE return: a class_typespec at the return-type
            // token, linked to the class_defn (Surelog).  ~~ANONYMOUS.~~
            // **STRUCK BY r10uvm156 IN ITS BLANKET FORM** — golden leaves this
            // object bare only when Surelog's `design->getClassDefinition`
            // fallback claims it, i.e. when the returned class's HOME DESIGN
            // COMPONENT is the declaring scope's; everywhere else it carries
            // the WRITTEN type name (§ classHandleRetTsNameUnlessSameHomeComponent156,
            // UhdmExporter.h).  Do not carry the superseded wording forward.
            if (!ts) {
                auto& rct9 = sub.getReturnType().getCanonicalType();
                if (rct9.kind == SymbolKind::ClassType) {
                    auto* cts9 = s.MakeClass_typespec();
                    if (auto cit9 = classDefnMap.find(&rct9); cit9 != classDefnMap.end())
                        cts9->Class_defn(cit9->second);
                    // ...and when the returned class is declared LATER in the
                    // package than the method (uvm_object::get_type @10873
                    // returns uvm_object_wrapper @12313), its class_defn does
                    // not exist yet: defer the link like every other forward
                    // class reference instead of leaving it null.
                    else
                        pendingClassTsLink.push_back({cts9, &rct9});
                    if (auto* rsyn9 = retTypeSyn175(sub))
                        setLoc(cts9, rsyn9->sourceRange());
                    // § classHandleRetTsNameUnlessSameHomeComponent156 —
                    // the class-handle return is anonymous ONLY when Surelog's
                    // `design->getClassDefinition` fallback claims it, i.e.
                    // when the returned class's home design component is the
                    // declaring scope's.  Everywhere else golden carries the
                    // WRITTEN type name.  Law, Surelog citations and the three
                    // fences: UhdmExporter.h.
                    if (auto rn156 = classHandleRetTsName156(sub, rct9);
                        !rn156.empty())
                        cts9->VpiName(rn156);
                    // § classTpTsResolvedNameEverySite87 — the RETURN site.
                    // `function REQ last_req(...)` in `uvm_sequencer_param_base`
                    // (and `get_current_item` / `last_rsp`): golden's return
                    // typespec is the class-scope type-parameter GROUP object,
                    // NAMED `rsp_type`, not the anonymous mint above.  The
                    // anonymity of a class-handle return is otherwise the
                    // SAME-HOME-COMPONENT half of § 156 (SeqDriver golden: 855
                    // anonymous return typespecs against 106 named ones), and
                    // is untouched — this fires only for a return written as one
                    // of the enclosing class's own type parameters whose group
                    // has a winning typedef.  Arm a2 `c_sites::m_ret`.
                    if (sub.returnValVar) {
                        if (auto gnR87 = classTpGroupDeclName87(
                                *sub.returnValVar, retTypeSyn175(sub));
                            !gnR87.empty()) {
                            cts9->VpiName(gnR87);
                            tpGroupTs87.insert(cts9);
                        }
                        // § classTpDefaultTsAtUse180 — the RETURN site (law at
                        // TypeEmit.cpp).
                        else
                            noteTpUse180(cts9, *sub.returnValVar,
                                         retTypeSyn175(sub));
                    }
                    ts = cts9;
                }
            }
            if (!ts) {
                // § pkgTdRangeViewFold18: a return typed by a PACKAGE typedef
                // inherits the TYPEDEF's range, so it follows the view law
                // rather than the blanket tf rule (a return that writes its
                // own range keeps the symbolic tree in every view).
                tfContext = true;
                bool savedNb18 = tdCloneRefNoBind18;
                if (auto* rta18 = pkgHomedTdAlias18(sub.getReturnType())) {
                    tfContext = pkgTdOwnDefView(*rta18);
                    tdCloneRefNoBind18 = true;  // § pkgTdCloneRefNoBind18
                }
                tfTypeScope = pkgScope ? sub.getParentScope() : nullptr;
                ts = makeTypespec(*sub.returnValVar, retTypeSyn175(sub));
                tdCloneRefNoBind18 = savedNb18;
                tfTypeScope = nullptr;
                tfContext = false;
            }
            // The ELABORATED package view's functions bind THAT view's typedef
            // listing object (rp32 enc32's op32_t return), not the def-listing
            // one the shared lookup returns. Only fires when `ts` IS the def
            // listing object — a freshly minted return clone is left alone.
            // § pkgTdRangeViewFold18 widens "the elaborated package view" to
            // EVERY view but the typedef's home package DEF listing: a MODULE
            // that imports the package lists the function too, and its return
            // shares the folded listing there as well (t28 mod28/free28).
            if (ts)
                for (auto& [sym0, tsp0] : typedefTs)
                    if (tsp0 == ts) {
                        bool fold18 = pkgTopEmit;
                        if (sym0->kind == SymbolKind::TypeAlias)
                            if (auto* hta18 = pkgHomedTdAlias18(
                                    sym0->as<TypeAliasType>()))
                                fold18 = !pkgTdOwnDefView(*hta18);
                        if (!fold18)
                            break;
                        if (auto t0 = pkgTopTypedefTs.find((const void*)sym0);
                            t0 != pkgTopTypedefTs.end() && t0->second)
                            ts = t0->second;
                        break;
                    }
            // A packed-array-of-enum return is a packed_array_var (range +
            // enum_var element) rather than a flat logic_var.
            if (auto* pav = makeEnumArrayVar(ts, fullName, tf))
                rv = pav;
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName);
            rt->VpiParent(rv);
            rt->Actual_typespec(ts);
            // § retPkgQualTdNoAlias196 (r11u196, R11U196_RETQUALTD_OFF;
            // func_typename_ret's `name(2)`) — a return type WRITTEN
            // package-qualified (`function automatic P::S func2;`) keeps the
            // package's own typedef object: compileTypespec's paPackage_scope
            // arm resolves `P::S` to the package DataType and hands back its
            // typespec, so the bare aliased copy LAW S makes for a return
            // (§ lawS's r6 cell: an UNQUALIFIED return) is not made here
            // (golden grid tools/probe/r11u196repro/cases/FR f01: `P::S`
            // 4:13-4:24 with no vpiTypedefAlias, where ours wrote `S` ->
            // `P::S`; an imported `B` return keeps `B` -> `P::B`, f02).  The
            // marker set is LAW S's skip, as § dpiListingIoRt33's is.
            if (ts && sub.getReturnType().kind == SymbolKind::TypeAlias &&
                r11u196Law("R11U196_RETQUALTD_OFF"))
                if (auto* rs196 = retTypeSyn175(sub);
                    rs196 && rs196->kind == syntax::SyntaxKind::NamedType)
                    if (const syntax::NameSyntax* qn196 =
                            rs196->as<syntax::NamedTypeSyntax>().name;
                        qn196 && qn196->kind == syntax::SyntaxKind::ScopedName) {
                        auto& sn196 = qn196->as<syntax::ScopedNameSyntax>();
                        std::string_view pk196;
                        if (sn196.left->kind == syntax::SyntaxKind::IdentifierName)
                            pk196 = sn196.left->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText();
                        auto* ps196 = sub.getReturnType().getParentScope();
                        if (sn196.separator.kind == parsing::TokenKind::DoubleColon &&
                            !pk196.empty() && comp.getPackage(pk196) && ps196 &&
                            &ps196->asSymbol() == comp.getPackage(pk196)) {
                            noteQualTdRt196(rt);
                            trace196("retPkgQualTdNoAlias196",
                                     std::string(pk196) + "::" +
                                         std::string(sub.getReturnType().name));
                        }
                    }
            // A CLASS scope is not a vpiInstance (Surelog leaves method
            // typespecs uninstanced, as the io_decl path already does) — the
            // bare typedef clone is the exception (§ retCloneInst9).
            UHDM::instance* useInst9 = tsInst ? tsInst : retCloneInst9;
            // An ANONYMOUS class_typespec — the class-HANDLE return minted at
            // the return-type token — never carries a vpiInstance, in any
            // listing and either view (SeqDriver golden: 855 of them, all
            // uninstanced; repro r2 `function D C::h()`).  Only a NAMED class
            // typespec takes one — and § 156's newly named returns take it by
            // exactly this line: golden's NAMED return typespec in a PACKAGE
            // FREE FUNCTION or an OUT-OF-BODY body carries `vpiInstance` = the
            // home package (`g156_a_mech.sv` lines 42/45/50/51), while the same
            // return inside a CLASS METHOD carries none — which is `tsInst`
            // read verbatim.
            if (ts->UhdmType() == UHDM::uhdmclass_typespec &&
                (ts->VpiName().empty() ||
                 tpGroupTs87.count((const UHDM::typespec*)ts)))
                useInst9 = nullptr;
            // § sharedTdRefNoRestamp9, SITE 2 of 4 — the RETURN type.
            // `foreignSharedTs` fenced only a typedef homed in ANOTHER
            // package; the shared object of a typedef homed in THIS package,
            // or in the class itself, was still re-stamped (arm v1 a8 / v4
            // d7_t).
            const SharedTd9 shRet9 =
                sub.returnValVar ? sharedTypedefTsRef9(*sub.returnValVar, ts)
                                 : SharedTd9::NotShared;
            if (useInst9 && shRet9 != SharedTd9::PkgClassTs &&
                shRet9 != SharedTd9::ClassOther &&
                !(sub.returnValVar && foreignSharedTs(*sub.returnValVar, ts))) {
                ts->Instance(importCopyTsInst ? importCopyTsInst : useInst9);
                stampElemTsInstance(ts, (UHDM::instance*)ts->Instance());
                if (importCopyTsInst && importCopyTsCollect)
                    importCopyTsCollect->push_back(ts);
            }
            rv->Typespec(rt);
            // § classScopedTdDeclTsUnsupported11, SITE 3 of 5 — the RETURN
            // variable.  `function uvm_resource_types::rsrc_q_t lookup_name(…)`
            // is the same declaration written at the return-type token: six
            // rows on every UVM design, at 868:12 / 1010:12 / 1065:12 /
            // 1076:12 / 1109:12 / 1269:12.
            if (auto* uts11 = makeScopedTdUnsupTs11(sub))
                rt->Actual_typespec(uts11);
            else if (sub.returnValVar)
                deferForeignTopTs(*sub.returnValVar, rt, ts);
            // A struct/enum/unpacked-array return's shared typespec sits at
            // the typedef, so the return var takes the return-TYPE syntax
            // span instead (a typedef'd-vector clone likewise).
            if (ts->UhdmType() == UHDM::uhdmstruct_typespec ||
                ts->UhdmType() == UHDM::uhdmenum_typespec ||
                ts->UhdmType() == UHDM::uhdmarray_typespec ||
                typedefRetClone || pkgUnitRet9) {
                if (auto* rsyn = retTypeSyn175(sub)) {
                    auto rr9 = rsyn->sourceRange();
                    std::string rw9 = rawText(rr9);
                    auto re9 = rr9.end();
                    while (!rw9.empty() &&
                           (rw9.back() == ' ' || rw9.back() == '\t')) {
                        rw9.pop_back();
                        re9 = re9 - 1;
                    }
                    setLoc(rv, SourceRange(rr9.start(), re9));
                }
            }
            else {
                copyLoc(rv, ts);
            }
            // A packed-array-of-VECTOR return (word[1:0], element a named
            // vector typedef) is a packed_array_var carrying the ARRAY range
            // and a bare logic_var element — Surelog. makeEnumArrayVar only
            // populates the enum-element form; add the vector form here.
            if (rv->UhdmType() == UHDM::uhdmpacked_array_var &&
                !((UHDM::packed_array_var*)rv)->Ranges()) {
                auto& rct = sub.getReturnType().getCanonicalType();
                if (rct.kind == SymbolKind::PackedArrayType) {
                    auto pr = rct.as<PackedArrayType>().range;
                    auto* rng = s.MakeRange();
                    rng->VpiParent(rv);
                    copyLoc(rng, ts);
                    // The range and its bounds anchor at the DIM tokens
                    // ([1:0] / 1 / 0) when the return-type syntax has them.
                    std::vector<DimSpan> rSpans;
                    if (auto* rsyn9 = retTypeSyn175(sub)) {
                        auto rr9 = rsyn9->sourceRange();
                        if (rr9.start() != SourceLocation::NoLocation)
                            rSpans = scanDimSpans(
                                std::string(rawText(rr9)), rr9.start());
                    }
                    const DimSpan* rds = rSpans.empty() ? nullptr : &rSpans[0];
                    if (rds)
                        setLoc(rng, rds->range);
                    auto mkC = [&](int32_t v,
                                   const SourceRange* bl) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        c->VpiDecompile(std::to_string(v));
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + std::to_string(v));
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(rng);
                        if (bl)
                            setLoc(c, *bl);
                        return c;
                    };
                    rng->Left_expr(mkC(pr.left, rds ? &rds->left : nullptr));
                    rng->Right_expr(mkC(pr.right, rds ? &rds->right : nullptr));
                    auto* rvec = s.MakeRangeVec();
                    rvec->push_back(rng);
                    ((UHDM::packed_array_var*)rv)->Ranges(rvec);
                    auto* ev = s.MakeLogic_var();
                    ev->VpiParent(rv);
                    ev->VpiFullName(fullName);
                    auto* elems = s.MakeAnyVec();
                    elems->push_back(ev);
                    ((UHDM::packed_array_var*)rv)->Elements(elems);
                    // The array logic_typespec carries an Elem_typespec ->
                    // the element typedef's (word) typespec.
                    if (ts->UhdmType() == UHDM::uhdmlogic_typespec &&
                        !((UHDM::logic_typespec*)ts)->Elem_typespec()) {
                        auto& et = rct.as<PackedArrayType>().elementType;
                        UHDM::typespec* wts = nullptr;
                        if (auto it0 = typedefTs.find(&et); it0 != typedefTs.end())
                            wts = it0->second;
                        else
                            for (auto& [sym0, tsp0] : typedefTs)
                                if (sym0->kind == SymbolKind::TypeAlias &&
                                    &sym0->as<TypeAliasType>()
                                            .getCanonicalType() ==
                                        &et.getCanonicalType()) {
                                    wts = tsp0;
                                    break;
                                }
                        if (wts && et.kind == SymbolKind::TypeAlias) {
                            // The element ref points at a fresh NAMED clone of
                            // the typedef (Typedef_alias -> the shared/canonical
                            // ts), matching Surelog — not the canonical directly
                            // (mirrors the typedef'd-arg path below).
                            auto& elAlias = et.as<TypeAliasType>();
                            const syntax::SyntaxNode* targetSyn = nullptr;
                            if (auto asyn = elAlias.getSyntax())
                                if (asyn->kind ==
                                    syntax::SyntaxKind::TypedefDeclaration)
                                    targetSyn =
                                        asyn->as<syntax::TypedefDeclarationSyntax>()
                                            .type;
                            bypassTypedefShare = true;
                            auto* cl = makeTypespec(elAlias, targetSyn);
                            bypassTypedefShare = false;
                            cl->VpiName(elAlias.name);
                            auto* art = s.MakeRef_typespec();
                            art->VpiFullName(elAlias.name);
                            art->VpiParent(cl);
                            art->Actual_typespec(wts);
                            ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                            // This element clone is minted AFTER the return
                            // typespec was instanced, so it misses that stamp;
                            // in a package the whole per-use family carries
                            // the package (PackedUnpackedIo).
                            if (!cl->Instance())
                                if (auto* ci0 = ts->Instance())
                                    cl->Instance((UHDM::instance*)ci0);
                            auto* ert = s.MakeRef_typespec();
                            ert->VpiParent(ts);
                            ert->Actual_typespec(cl);
                            ((UHDM::logic_typespec*)ts)->Elem_typespec(ert);
                        }
                        else if (wts) {
                            auto* ert = s.MakeRef_typespec();
                            ert->VpiParent(ts);
                            ert->Actual_typespec(wts);
                            ((UHDM::logic_typespec*)ts)->Elem_typespec(ert);
                        }
                        // The outer ts carries its OWN [1:0] range (dim-token
                        // locs), parented at the ts (Surelog).
                        if (!((UHDM::logic_typespec*)ts)->Ranges()) {
                            auto* trng = s.MakeRange();
                            trng->VpiParent(ts);
                            const DimSpan* tds =
                                rSpans.empty() ? nullptr : &rSpans[0];
                            if (tds)
                                setLoc(trng, tds->range);
                            auto mkT = [&](int32_t bv,
                                           const SourceRange* bl)
                                -> UHDM::expr* {
                                auto* c9 = s.MakeConstant();
                                c9->VpiDecompile(std::to_string(bv));
                                c9->VpiSize(64);
                                c9->VpiValue("UINT:" + std::to_string(bv));
                                c9->VpiConstType(vpiUIntConst);
                                c9->VpiParent(trng);
                                if (bl)
                                    setLoc(c9, *bl);
                                return c9;
                            };
                            trng->Left_expr(
                                mkT(pr.left, tds ? &tds->left : nullptr));
                            trng->Right_expr(
                                mkT(pr.right, tds ? &tds->right : nullptr));
                            auto* tvec = s.MakeRangeVec();
                            tvec->push_back(trng);
                            ((UHDM::logic_typespec*)ts)->Ranges(tvec);
                        }
                    }
                }
            }
            ((UHDM::function*)tf)->Return(rv);
            }
        }

        auto* ios = s.MakeIo_declVec();
        // § externProtoFormalsFromPrototype175 (r11u175) — the CLASS-BODY
        // listing of an `extern` method (`protoOf` set) lists the formals
        // Surelog compiled from the PROTOTYPE, not the out-of-body
        // definition's: CompileHelper::compileFunctionPrototype /
        // compileTaskPrototype (CompileStmt.cpp) run compileTfPortList over
        // the prototype's own Tf_port_list, and the definition's later
        // compile finds that object already populated (`if (func->Io_decls()
        // || ...) return true;`, CompileStmt.cpp compileFunction) and leaves
        // it.  So every io_decl of that listing, its default constant, its
        // typespec and its range bounds are located at the PROTOTYPE's
        // tokens (golden uvm_component::new io_decl `name` 76:31-76:35, the
        // prototype, where ours read the definition 1728:37-1728:41).  The
        // package listing's definition (`C::m`) keeps the definition's
        // formals.  Grid tools/probe/r11u175uvm/cases/f4.  Switch
        // R11U175_FSPAN_OFF (R11U175_OFF drops every r11u175 law).
        auto args175 = sub.getArguments();
        if (protoOf && r11u175LawB("R11U175_FSPAN_OFF") &&
            protoOf->getArguments().size() == args175.size())
            args175 = protoOf->getArguments();
        for (auto arg : args175) {
            auto* io = s.MakeIo_decl();
            io->VpiName(arg->name);
            io->VpiParent(tf);
            switch (arg->direction) {
                case ArgumentDirection::In:
                    io->VpiDirection(vpiInput);
                    break;
                case ArgumentDirection::Out:
                    io->VpiDirection(vpiOutput);
                    break;
                case ArgumentDirection::InOut:
                    io->VpiDirection(vpiInout);
                    break;
                case ArgumentDirection::Ref:
                    io->VpiDirection(vpiRef);
                    break;
                default:
                    noteUnsupported("subroutine arg direction");
                    break;
            }
            setLoc(io, nameSpan(arg->location, arg->name));
            // A DEFAULT VALUE becomes the io_decl's vpiExpr (unparented, at the
            // default expression's own span).
            // § noDirNamedTypeDefaultDropped30 — ...except on a formal written
            // with NO tf_port_direction KEYWORD whose DATA TYPE is a plain type
            // IDENTIFIER, where Surelog drops the default value entirely.  The
            // rule this replaces read the drop off `= null` alone (r10uvm7/c5:
            // `f1(input K k=null)` keeps the vpiNullConst, `f2(K k=null)` does
            // not) and generalised it to every no-direction null; the 2x2 says
            // the null was incidental and the TYPE SPELLING is the whole key.
            // Measured both directions on t40a/t40b/t40c, every cell:
            //   DROPPED   `e40_t e = E1`, `i40_t k = 3` (typedef of int),
            //             `s40_t s = "x"` (typedef of string), `s40_t v='{..}`,
            //             `h40 h = null`, `pc40#(int) h = null`,
            //             `e40_t e = e40_t'(1)` — any bare type identifier,
            //             parameterised or not, whatever the default's shape.
            //   KEPT      every BUILT-IN keyword type (`int`, `int unsigned`,
            //             `bit[3:0]`, `logic`, `logic[7:0]`, `byte`, `real`,
            //             `time`, `string`, and — the cells that refute the
            //             old rule — `chandle h = null` and `event e = null`);
            //             an INLINE anonymous `enum`/packed `struct`; a SCOPED
            //             type name (`q40b::f40_t v = q40b::F1`, `q40b::g40 h
            //             = null`); a `virtual if40c vi = null`; and anything
            //             at all once the formal carries its OWN direction
            //             keyword.  An INHERITED direction does not count
            //             (`f(input string s, e40_t e=E1)` drops `e`).
            // It is a SUBROUTINE rule, not a class-method rule: the same cells
            // drop in a package function, a module function, a module task and
            // at $unit scope, in extern prototypes and out-of-body definitions
            // alike.  Reach: 89 io_decl keys on Scoreboard alone — every
            // `uvm_radix_enum radix=UVM_NORADIX`, `uvm_predict_e kind=
            // UVM_PREDICT_DIRECT`, `uvm_hier_e hier=UVM_HIER` and
            // `uvm_reg_addr_t offset=0` written without a direction, while the
            // 152 `input uvm_path_e path=UVM_DEFAULT_PATH`-shaped ones stay.
            // A `null` in a RETURN always keeps its vpiNullConst.
            if (auto* dv = arg->getDefaultValue()) {
                bool wroteDir9 = true;
                for (auto q9 = arg->getSyntax(); q9; q9 = q9->parent)
                    if (q9->kind == syntax::SyntaxKind::FunctionPort) {
                        wroteDir9 =
                            q9->as<syntax::FunctionPortSyntax>()
                                .direction.valid();
                        break;
                    }
                // A bare type IDENTIFIER: `NamedType` over an IdentifierName
                // or a ClassName (`cls#(int)`).  A ScopedName is not one, and
                // neither is a builtin keyword type, an inline enum/struct or
                // a `virtual` interface — those are other DataTypeSyntax kinds.
                bool bareTyId30 = false;
                {
                    const syntax::DataTypeSyntax* tsyn30 =
                        arg->getDeclaredType()->getTypeSyntax();
                    if (tsyn30 &&
                        tsyn30->kind == syntax::SyntaxKind::NamedType) {
                        auto nk30 =
                            tsyn30->as<syntax::NamedTypeSyntax>().name->kind;
                        bareTyId30 =
                            nk30 == syntax::SyntaxKind::IdentifierName ||
                            nk30 == syntax::SyntaxKind::ClassName;
                    }
                }
                if (!wroteDir9 && bareTyId30) {
                    // nothing to emit at all
                } else {
                    // § formalDefaultBindsLikeBody13 — A FORMAL'S DEFAULT
                    // VALUE IS BOUND BY THE SAME BINDER WINDOW AS THE
                    // SUBROUTINE'S OWN BODY.
                    //
                    // Surelog does not bind a default value when it compiles
                    // it: CompileHelper::compileTfPortList (CompileStmt.cpp
                    // :1824) calls compileExpression with the io_decl as the
                    // parent and NO pexpr, so every name in it comes out an
                    // unresolved ref_obj registered on the component's
                    // getLateBinding() list.  UhdmWriter::lateBinding
                    // (UhdmWriter.cpp:3293) then walks that ref's VpiParent
                    // CHAIN in the WRITE phase — and the chain of a default
                    // value's ref runs ref -> operation(s) -> io_decl ->
                    // task_func, so the `uhdmfunction` / `uhdmtask` arm fires
                    // and matches the name against `func->Io_decls()`,
                    // `Variables()`, `Parameters()` and, one level up, the
                    // enclosing module's nets.  THE FORMAL IT FINDS IS AN
                    // io_decl OF THE SAME SUBROUTINE.
                    //
                    // Two of our cells were wrong, in OPPOSITE directions, and
                    // both came from this one site emitting the expression
                    // OUTSIDE the subroutine's binder window:
                    //   * `NetMap emptyMap` meant a ref to an EARLIER FORMAL
                    //     never had anything to bind — the head this pass
                    //     owns (`io_decl(severity)` under
                    //     `function(uvm_pkg::uvm_report)`, RHS <null>: the
                    //     SINGULAR SafeCompare on `ref_obj::Actual_group()`,
                    //     which is the only overload that can set m_failedLhs
                    //     to an ELEMENT and leave m_failedRhs null);
                    //   * classMethodNoBind was NOT in force here, so an ENUM
                    //     CONSTANT in an IN-CLASS listing's default bound while
                    //     golden left it bare — 74 cells on BuildUVMPkg alone.
                    //
                    // The window is the body's own, and nothing else:
                    // classMethodNoBind (`classScope && !oob`) and
                    // unitSubNoBind9 are set here exactly as
                    // emitTaskFuncs sets them around `emitStmt(sub.getBody())`
                    // below.  MEASURED, arm v1/v2, cell -> golden:
                    //   package free function / task   `int b = a`  -> BIND
                    //   module   function / task       `int b = a`  -> BIND
                    //   INSTANTIATED interface fn      `int b = a`  -> BIND
                    //   UNinstantiated MODULE fn       `int b = a`  -> BIND
                    //   class OUT-OF-BODY definition   `int b = a`  -> BIND
                    //   class IN-BODY method           `int b = a`  -> bare
                    //   class extern PROTOTYPE listing `int v=E13_B`-> bare
                    //   `pure virtual` prototype       `int v=E13_B`-> bare
                    //   `$unit`-scope function         `int b = a`  -> bare
                    // and the two fences that are NOT this law:
                    //   UNinstantiated INTERFACE fn    `int b = a`  -> bare
                    //     (Surelog never runs lateBinding on a component it
                    //      never elaborates; the same shape in an
                    //      UNinstantiated MODULE binds, so it is not a
                    //      "definition view" rule -- residue R2)
                    //   module/interface NET or VAR in a default -> golden
                    //     BINDS and we do not (residue R1, population 0)
                    //   module PARAMETER / localparam in a default -> golden
                    //     leaves it BARE in a module and binds a folded
                    //     `constant` in a package; we fold the ref away
                    //     entirely (a ParamEmit family, residue R3)
                    // A LATER formal is not reachable: naming one in a default
                    // is not legal SV, the map is filled in declaration order,
                    // and the corpus census found ZERO such cells.
                    // THE ONE FENCE THE CORPUS ADDED, AND IT IS MEASURED, NOT
                    // GUESSED: a WILDCARD-IMPORT CLONE binds NOTHING in a
                    // default value.  MiniAmiq's golden holds both copies of
                    // the same text and disagrees with itself about them —
                    // `uvm_pkg::uvm_report` (the HOME copy) carries
                    // `vpiActual -> io_decl(severity)` on both its `severity`
                    // refs, and `svaunit_pkg::uvm_report` (the clone the
                    // wildcard import materialises) carries none, on either
                    // ref, in either view; SeqDriver says the same with
                    // `adpcm_pkg::uvm_report`.  Surelog's clone is a
                    // `clone_tree` copy made in the WRITE phase, so its refs
                    // were never on the importing component's
                    // `getLateBinding()` list and lateBinding never sees them.
                    // Our clone already leaves the ENUM CONSTANTS of the same
                    // expression bare, so this restores the clone to the one
                    // behaviour it already had rather than inventing a new one:
                    // 16 cells (MiniAmiq 4 + SeqDriver 4, x2 modes) that the
                    // corpus census caught as pristine-right -> patched-wrong.
                    NetMap noBind13;
                    bool savedCMNB13 = classMethodNoBind;
                    bool savedUSNB13 = unitSubNoBind9;
                    // THE IN-CLASS LISTING (in-body method, `extern`
                    // prototype): golden binds NOTHING in its default value.
                    bool inClass13 = classScope && !oob;
                    classMethodNoBind = inClass13;
                    // THE `$unit` REACH, AND IT WALKS OUT THROUGH ANY
                    // ENCLOSING CLASS (verifier arm a5 `gc5`).  Surelog never
                    // revisits the compilation unit with a symbol table, so a
                    // $unit-scope class's OUT-OF-BODY definition binds nothing
                    // either — golden leaves `gc5::gx_earlier`'s `a`, its
                    // `gx_call`'s `a` and its `gx_enumi`'s enum constant all
                    // BARE, while a class declared in a MODULE or a PACKAGE
                    // binds in its out-of-body definition (arm v2
                    // `m13::cm13::cx_earlier`, arm a2 `pa2::pc2::p_x`).  The
                    // one-level test this replaces read the SUBROUTINE's own
                    // parent scope, which for an out-of-body definition is the
                    // CLASS, so it missed every $unit class method.
                    bool unitSub13 = false;
                    {
                        const Scope* usc13 = sub.getParentScope();
                        while (usc13 &&
                               (usc13->asSymbol().kind ==
                                    SymbolKind::ClassType ||
                                usc13->asSymbol().kind ==
                                    SymbolKind::GenericClassDef))
                            usc13 = usc13->asSymbol().getParentScope();
                        unitSub13 = usc13 && usc13->asSymbol().kind ==
                                                 SymbolKind::CompilationUnit;
                    }
                    unitSubNoBind9 = unitSub13;
                    // THE MAP IS WITHHELD, not merely silenced, wherever
                    // golden binds nothing — because `classMethodNoBind`'s
                    // silence is LIFTED inside a call's argument list
                    // (§ classArgBind12: the bind gate reads
                    // `classMethodNoBind && classArgBindDepth12 == 0`), and a
                    // default value may hold a call.  Withholding the formals
                    // reproduces the pristine emitter cell for cell in exactly
                    // the places golden is bare:
                    //   * IN-CLASS listing — arm a3 measures SEVEN shapes that
                    //     the silence alone let through (`r3(a)`, `r3b(a,a)`,
                    //     `r3(r3(a))`, `r3(a+1)`, `helper(a)`, `int'(r3(a))`,
                    //     `(a>0)?r3(a):0`) plus the `extern` PROTOTYPE
                    //     listing's ELAB copy; a CONCAT argument (`r3({a,a})`)
                    //     and a SYSTEM call (`$bits(a+1)`) never opened the
                    //     window and were already right.
                    //   * `$unit` reach — see unitSub13 above.
                    //   * an IMPORT CLONE, and `importCopyTsInst` is the test
                    //     that names ALL THREE clone paths.  The shipped
                    //     `pkgImportCloneEmit` covers only the WILDCARD ones
                    //     (ParamEmit's `wpkg9` arm and
                    //     emitImportedPkgClassMethodClones); an EXPLICIT
                    //     single-name `import p::f;` re-emits through the same
                    //     emitTaskFuncs with `importCopyTsInst` set and
                    //     `pkgImportCloneEmit` FALSE, and golden leaves that
                    //     clone's default bare too (arm a4 `pe4::hf_earlier`,
                    //     arm a5 `pex5::hf_earlier` + `pex5::ht_earlier`).
                    bool noBindDv13 = inClass13 || unitSub13 ||
                                      pkgImportCloneEmit || importCloneEmit ||
                                      importCopyTsInst != nullptr;
                    // § formalDefaultNamedThroughFormal191 (r11u191,
                    // R11U191_REFFULL_OFF) — Surelog compiles a formal's
                    // default value with the io_decl as its parent and stores
                    // NO full name on the references in it (compileTfPortList
                    // -> compileExpression, no pexpr), so UHDM's
                    // ComputeFullName (BaseClass.cpp:100) derives each one from
                    // the parent chain, which runs through the io_decl: the
                    // formal's own name is a component (golden
                    // `uvm_pkg::uvm_report::verbosity::severity`,
                    // `work@top.f.b.a`, and the cast's ref_typespec
                    // `p::rep::verbosity`); ours joined the subroutine's name.
                    // The scope handed to the expression is therefore the
                    // FORMAL's full name (N0215 / N0229; grid
                    // tools/probe/r11u191dec/cases/F).
                    // A literal or a lone name has no reference BELOW the
                    // io_decl's direct child (a lone name already reads the
                    // chained name, f02 `int d = base`): those keep the
                    // pristine scope, and bytes.
                    std::string dvScope191 = fullName;
                    auto k191 = stripImplicitConv(*dv).kind;
                    if (!fullName.empty() && !arg->name.empty() &&
                        k191 != ExpressionKind::NamedValue &&
                        k191 != ExpressionKind::IntegerLiteral &&
                        k191 != ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                        k191 != ExpressionKind::StringLiteral &&
                        k191 != ExpressionKind::RealLiteral &&
                        k191 != ExpressionKind::NullLiteral &&
                        r191TF("R11U191_REFFULL_OFF")) {
                        dvScope191 = joinRef(fullName, arg->name);
                        tr191TF("formalDefaultNamedThroughFormal191");
                    }
                    auto* de = emitExpr(*dv, nullptr, dvScope191,
                                        noBindDv13 ? noBind13 : dvFormals13);
                    classMethodNoBind = savedCMNB13;
                    unitSubNoBind9 = savedUSNB13;
                    // § formalRealDefaultRawValue30 — the io_decl half of
                    // § classPropRealInitRawValue29: a REAL formal default's
                    // vpiValue is the SOURCE TEXT, not a `%f` rendering of the
                    // double.  t40c reads golden REAL:1.5 / REAL:1.0e-9 /
                    // REAL:3.0 for `real`, `realtime` and `shortreal` alike,
                    // with and without an `input` keyword, always equal to the
                    // decompile — where the shared RealLiteral arm printed
                    // REAL:1.500000 and, for `1.0e-9`, REAL:0.000000.  Two UVM
                    // formals reach it and the r10uvm29iom projection (kind +
                    // name only) could not see either.  The negated spelling
                    // (`real r = -2.5`) is an operation whose operand golden
                    // and we already agree on, so only the bare literal moves.
                    if (de && de->UhdmType() == UHDM::uhdmconstant &&
                        ((UHDM::constant*)de)->VpiConstType() == vpiRealConst &&
                        stripImplicitConv(*dv).kind ==
                            ExpressionKind::RealLiteral) {
                        std::string rtx30 =
                            rawText(stripImplicitConv(*dv).sourceRange);
                        if (!rtx30.empty())
                            ((UHDM::constant*)de)->VpiValue("REAL:" + rtx30);
                    }
                    if (de)
                        io->Expr((UHDM::expr*)de);
                }
            }
            // Bare implicit arg types ("input x;") get an unlocated typespec
            // created at the very end of the write phase.
            UHDM::typespec* ts = nullptr;
            bool bareImplicit = false;
            auto argTsyn = arg->getDeclaredType() ? arg->getDeclaredType()->getTypeSyntax()
                                                  : nullptr;
            if (argTsyn && argTsyn->kind == syntax::SyntaxKind::ImplicitType) {
                auto& its = argTsyn->as<syntax::ImplicitTypeSyntax>();
                if (its.dimensions.empty() && !its.signing.valid())
                    bareImplicit = true;
            }
            // A formal written with NO DATA TYPE — an ANSI bare name (task
            // put(message);), an ANSI direction-only port (f(input a)) or a
            // body-style `input a;` alike — gets NO typespec out of Surelog's
            // definition compile: CompileStmt builds one only from a
            // `paData_type` or a `paPacked_dimension`, and a bare formal has
            // neither.  It acquires one only when the constant evaluator
            // REACHES the subroutine and recompiles the formals
            // (§ bareFormalTsReached).  `signed`/`unsigned` alone is still no
            // data type (arm a4/k9: `input signed a;` in an unreached
            // function has no typespec either), so the reach test — not the
            // written spelling — is the whole rule.
            // ...unless the body REDECLARES the formal with a type (`input B;
            // integer B;`): that declaration is compiled whatever the
            // evaluator does, and the io_decl takes its typespec (TaskDecls'
            // uncalled task A — the branch that owns this is `redeclSym`
            // below, so only the decision to drop needs the test here).
            bool noDataType9 =
                argTsyn && argTsyn->kind == syntax::SyntaxKind::ImplicitType &&
                argTsyn->as<syntax::ImplicitTypeSyntax>().dimensions.empty();
            if (noDataType9)
                for (auto& mv9 : sub.members())
                    if (mv9.kind == SymbolKind::Variable &&
                        &mv9 != sub.returnValVar && !mv9.name.empty() &&
                        mv9.name == arg->name) {
                        noDataType9 = false;
                        break;
                    }
            if (noDataType9 && !bareFormalTsReached(sub)) {
                ios->push_back(io);
                if (!classScope)
                    funcMap[arg] = io;
                dvFormals13[arg] = io; // § formalDefaultBindsLikeBody13
                si.argTs.push_back({nullptr, nullptr});
                continue;
            }
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName + sep + std::string(arg->name));
            rt->VpiParent(io);
            // A PACKAGE subroutine's formal typespecs are resolved in the
            // package's scope, so every one of them — including the fresh
            // per-formal typedef CLONES the branches below mint — carries the
            // package as vpiInstance.  The shared-typespec branch at the end
            // already stamped its own; these clone branches did not
            // (PackedUnpackedIo).
            // § pkgClassFormalCloneInst18 — and a package CLASS METHOD's
            // per-formal typedef clone carries the SAME instance the method's
            // shared-typespec formals already take (`tsInst`, the out-of-body
            // home package).  The clone branches skipped it because the guard
            // read `!pkgScope || classScope`, so every `uvm_bitstream_t` /
            // `uvm_reg_data_t` formal clone in a UVM class method came out
            // with a null vpiInstance where golden names the package — 524
            // first-fails on SeqDriver alone, and the row is invisible until
            // the range agrees (Compare stops at the first difference).
            auto stampPkgFormalTs = [&](UHDM::typespec* t0) {
                if (!t0 || !pkgScope)
                    return;
                UHDM::instance* inst0 =
                    classScope ? tsInst : (UHDM::instance*)m;
                // An IN-BODY class method has `tsInst` deliberately null (its
                // SHARED formal typespecs carry no instance) — but its
                // per-declaration CLONES still name the enclosing package, of
                // the view being emitted (t28 `C28::m28`).
                if (!inst0 && classScope)
                    for (auto sc0 = sub.getParentScope(); sc0;
                         sc0 = sc0->asSymbol().getParentScope())
                        if (sc0->asSymbol().kind == SymbolKind::Package) {
                            auto& hm0 = pkgEmitTopView ? pkgTopMap : pkgDefMap;
                            if (auto hit0 =
                                    hm0.find((const void*)&sc0->asSymbol());
                                hit0 != hm0.end())
                                inst0 = (UHDM::instance*)hit0->second;
                            break;
                        }
                if (!inst0)
                    return;
                if (pkgTopEmit && defPassOwnedTs.count(t0))
                    return;
                t0->Instance(importCopyTsInst ? importCopyTsInst : inst0);
                stampElemTsInstance(t0, (UHDM::instance*)t0->Instance());
            };
            // A formal REDECLARED in the function body with an explicit type
            // (input [4:0] r; reg [4:0] r; / input x; integer x;) — Surelog
            // binds the io_decl's actual typespec to the REDECLARATION's type
            // object (at the redecl span), not the port's own declared type.
            // The redecl is a direct body Variable member sharing the name;
            // a block-nested shadow (begin:s integer r) is NOT a redecl.
            const Symbol* redeclSym = nullptr;
            for (auto& mv : sub.members()) {
                if (mv.kind != SymbolKind::Variable || &mv == sub.returnValVar ||
                    mv.name.empty() || mv.name == "this" ||
                    mv.name != arg->name)
                    continue;
                redeclSym = &mv;
                break;
            }
            // An UNPACKED array's io_decl typespec is its ELEMENT type — the
            // unpacked dims live on the io_decl's own Ranges — so the packed
            // form the branches below build from is the type with those
            // wrappers stripped (`sha_word_t [7:0] hh_ii [16:0]`).
            const Type* formalPkTy = nullptr;
            if (auto adt5 = arg->getDeclaredType()) {
                formalPkTy = &adt5->getType();
                while (formalPkTy->getCanonicalType().kind ==
                       SymbolKind::FixedSizeUnpackedArrayType)
                    formalPkTy = &formalPkTy->getCanonicalType()
                                      .as<FixedSizeUnpackedArrayType>()
                                      .elementType;
            }
            // § oobParamClassTypeParamFormalUnsupported31 — the OUT-OF-BODY
            // definition's formal written as one of the class's own TYPE
            // PARAMETERS.  Only the KIND and the NAME move: the instance is
            // the package the CLASS is declared in (`oobDeclPkg31`; `tsInst`
            // is the fallback outside a package, and is the clone target, not
            // the declaring package, in a clone pass).  Reach: 210 rows on the
            // UVM-4, all four tests (`uvm_sequencer`'s REQ/RSP methods, every
            // view).  See the lambda for the matrix and the two open cells.
            std::string_view oobTp31 =
                oob ? oobClassTypeParamName31(argTsyn) : std::string_view{};
            // § classTypeParamTdGroupLastWins33c — see the lambda for the law.
            // IN-BODY only: every measured cell is, and an out-of-body formal
            // written as a type parameter is already owned by
            // § oobParamClassTypeParamFormalUnsupported31 above.
            const Type* grpKey33c = oob ? nullptr : tpGroupKey33c(argTsyn);
            // § dpiImportFormalListingTd33 / § dpiImportCopyFormalUnsupported33
            //
            // A **DPI IMPORT**'s formal typed by a typedef declared in the
            // SAME package binds the package's ELABORATED typedef LISTING
            // object — the qualified `p::t` one — where the identical formal
            // of a plain SV subroutine takes a fresh per-declaration BARE
            // clone.  Pass 32 decoded the shape and proved the fix cannot be
            // a LAW-S guard (the io_decl never holds the listing object by
            // the time LAW S runs, because the clone arms below run first);
            // this is the emission site the note there points at.
            //
            // `t43a` reads every cell off one golden, both directions:
            //   FIRES   `import "DPI-C" context function int dv_lit(string,
            //           v_t)` in p43v -> `logic_typespec 'p43v::v_t'`, and
            //           the same for a `bit` typedef, an UNRANGED `int`
            //           typedef and an ALIAS-OF-ALIAS; `context` is
            //           irrelevant (`dv_np`) and so is function-vs-task
            //           (`import "DPI-C" context task dv_task`) — UVM's own
            //           counter-example `uvm_hdl_force_time` is a plain SV
            //           TASK, not a DPI import, and golden leaves its
            //           identical formal bare, which is what pins the
            //           predicate on DPI-ness alone.
            //   OBJECT  the ELABORATED listing, in EVERY view (the home
            //           package's own DEF listing included).  With importers
            //           that object is the shared second-generation clone
            //           whose vpiInstance the last importer owns
            //           (§ pkgImportAggCloneLastWriter32 / the `otherTds`
            //           arm) — golden's `@p43b`, and UVM's `@adpcm_pkg`
            //           where we said `@uvm_pkg`.  p43n, which NOBODY
            //           imports, is the cell that says the pointer is
            //           `pkgTopTypedefTs` and not "the last importer's
            //           copy": golden binds `p43n::n_t`@p43n!top there.
            //   NOT     a typedef imported from ANOTHER package (`dx_lit` in
            //           p43x over p43v's `v_t` -> a bare clone, exactly like
            //           its plain-function control), a DPI import inside a
            //           MODULE (`dm_lit`), and an ENUM/STRUCT typedef, which
            //           degrades to `unsupported_typespec` named as written
            //           in the DEF view of its own package but binds the
            //           shared listing object in the ELAB view — a
            //           view-asymmetry with ZERO reach in UVM, left unmodelled
            //           (pass 32 recorded the same cell off t41b).
            //
            // The IMPORT COPY is the other half: a wildcard/explicit import
            // clone of a DPI import degrades EVERY typedef formal to an
            // `unsupported_typespec` named as written, instanced at the home
            // package (the ordinary `importCopyTsInst`), while the copies of
            // plain subroutines keep their clones and their shared aggregate
            // listings.  A builtin-typed formal (`string path`) is untouched
            // on both halves.
            // § classScopedTdImportCopyUnsupported36 — the same degradation
            // for a formal typed by the class's OWN class-scope typedef,
            // inside a wildcard-import CLONE.
            //
            // The row only exists because a class method DEFINED OUT OF BODY
            // is a PACKAGE-scope item, so an importer clones it as a package
            // subroutine — and in that copy `this_type` has no class scope to
            // resolve against.  `t48c` reads the cell and its control off one
            // golden: `c50::m50(k50_t key, this_type lib)` declared `extern
            // static` and defined out of body, wildcard-imported by `aa50`,
            //   DEFPKG  aa50::::c50::m50 io1  unsupported_typespec 'this_type'
            //                                 @home50!TOP
            //   ELABPKG aa50::::c50::m50 io1  the same, a second object
            //   DEFPKG  aa50::::c50::m50 io0  int_typespec 'k50_t'@home50!TOP
            //                                 (the CONTROL: an ordinary
            //                                 package typedef does NOT
            //                                 degrade in the same body)
            // while every non-clone view — the home's own out-of-body copy,
            // the class views, the module views — keeps the class_typespec
            // § classKeyTsScopeOwner35 gives it.  SeqDriver's
            // `uvm_sequence_library::m_check(uvm_object_wrapper, this_type)`
            // is the identical shape, and its 2 rows are the last of the
            // io_decl typespec residue.
            const slang::ast::TypeAliasType* clsTdCopyUnsup36 = nullptr;
            if (importCopyTsInst && arg->getDeclaredType()) {
                const auto& fty36 = arg->getDeclaredType()->getType();
                if (fty36.kind == SymbolKind::TypeAlias)
                    if (auto* ps36 =
                            fty36.as<TypeAliasType>().getParentScope();
                        ps36 &&
                        (ps36->asSymbol().kind == SymbolKind::ClassType ||
                         ps36->asSymbol().kind == SymbolKind::GenericClassDef))
                        clsTdCopyUnsup36 = &fty36.as<TypeAliasType>();
            }
            const slang::ast::TypeAliasType* dpiTd33 = nullptr;
            UHDM::typespec* dpiListingTs33 = nullptr;
            bool dpiCopyUnsup33 = false;
            if (sub.flags.has(MethodFlags::DPIImport) && arg->getDeclaredType())
                if ((dpiTd33 =
                         pkgHomedTdAlias18(arg->getDeclaredType()->getType()))) {
                    if (importCopyTsInst)
                        dpiCopyUnsup33 = true;
                    else if (pkgScope && !classScope &&
                             dpiTd33->getParentScope() == sub.getParentScope()) {
                        // The ELABORATED listing does not exist yet in the DEF
                        // pass (packages are emitted def-view first), so bind
                        // the def object now and re-point at the drain — the
                        // same two-step `pkgForeignTsTopFixups` already runs
                        // for a foreign package typedef.
                        auto t33 = pkgTopTypedefTs.find((const void*)dpiTd33);
                        UHDM::typespec* cand33 =
                            t33 != pkgTopTypedefTs.end() ? t33->second
                                                         : nullptr;
                        if (!cand33)
                            if (auto d33 = typedefTs.find(
                                    (const slang::ast::Type*)dpiTd33);
                                d33 != typedefTs.end())
                                cand33 = d33->second;
                        if (cand33)
                            switch (cand33->UhdmType()) {
                                // The LAW-S scalar/vector kind set: the
                                // aggregate ones take the DEF-view
                                // degradation above and are not modelled.
                                case UHDM::uhdmlogic_typespec:
                                case UHDM::uhdmbit_typespec:
                                case UHDM::uhdmint_typespec:
                                case UHDM::uhdminteger_typespec:
                                case UHDM::uhdmbyte_typespec:
                                case UHDM::uhdmshort_int_typespec:
                                case UHDM::uhdmlong_int_typespec:
                                    dpiListingTs33 = cand33;
                                    break;
                                default:
                                    break;
                            }
                    }
                }
            if (dpiCopyUnsup33 || clsTdCopyUnsup36) {
                auto* uts33 = s.MakeUnsupported_typespec();
                uts33->VpiName(dpiCopyUnsup33 ? dpiTd33->name
                                              : clsTdCopyUnsup36->name);
                if (argTsyn)
                    setLoc(uts33, argTsyn->sourceRange());
                ts = uts33;
                stampPkgFormalTs(ts);
                // ...and, like every other clone typespec, it re-points at the
                // ELABORATED home package once both views exist.
                if (importCopyTsCollect)
                    importCopyTsCollect->push_back((UHDM::typespec*)ts);
                rt->Actual_typespec(ts);
            }
            else if (dpiListingTs33) {
                // NO stamp: this object's vpiInstance belongs to the listing
                // law, and re-stamping it here is exactly the inversion
                // § importCopyAggFormalOwnCopy32 had to undo.  LAW S must
                // leave it alone too — hence the marker.
                ts = dpiListingTs33;
                rt->Actual_typespec(ts);
                dpiListingIoRt33.insert(rt);
                if (!pkgTopEmit)
                    pkgForeignTsTopFixups.emplace_back(rt, dpiTd33);
            }
            else if (!oobTp31.empty()) {
                auto* uts31 = s.MakeUnsupported_typespec();
                uts31->VpiName(oobTp31);
                if (argTsyn)
                    setLoc(uts31, argTsyn->sourceRange());
                if (auto* ui31 = oobDeclPkg31 ? oobDeclPkg31 : tsInst)
                    uts31->Instance(ui31);
                ts = uts31;
                rt->Actual_typespec(ts);
            }
            // § baseClassTypeParamFormalUnsupported34 /
            // § classScopedTdFormalUnsupported34 — the same catch-all for a
            // written name the class's own data-type table cannot answer.
            // NO vpiInstance on either (t46a, every cell), and a fresh
            // object per declaration.
            else if (auto btp34 = baseTypeParamName34(argTsyn); !btp34.empty()) {
                auto* uts34 = s.MakeUnsupported_typespec();
                uts34->VpiName(btp34);
                if (argTsyn)
                    setLoc(uts34, argTsyn->sourceRange());
                ts = uts34;
                rt->Actual_typespec(ts);
            }
            else if (auto csn34 = classScopedUnsupName34(argTsyn);
                     !csn34.empty()) {
                auto* uts34 = s.MakeUnsupported_typespec();
                uts34->VpiName(csn34);
                if (argTsyn)
                    setLoc(uts34, argTsyn->sourceRange());
                ts = uts34;
                rt->Actual_typespec(ts);
            }
            else if (redeclSym) {
                ts = makeTypespec(*redeclSym);
                rt->Actual_typespec(ts);
            }
            else if (bareImplicit) {
                pendingIoTs.push_back({rt, argTsyn});
            }
            // § tdListingFormalAsWritten33 — see the lambda for the law.  Only
            // the AGGREGATE/CLASS listing kinds are bound here: those are the
            // ones golden SHARES, so binding the listing object is the whole
            // fix.  A vector/scalar typedef takes a per-declaration CLONE
            // instead (t44a's `f_pv`: golden mints a fresh `'v44_t'` for the
            // type-parameter formal, a different object from the control's) —
            // rebuilding that clone from a type the syntax does not name is a
            // different job and has no measured UVM reach, so it is left.
            else if (auto* tdl34 = writtenPkgTdListingTs34(argTsyn, rt)) {
                ts = tdl34;
                rt->Actual_typespec(ts);
            }
            // § classTypeParamTdGroupLastWins33c, the SHARE half: every formal
            // after the first in a group binds the object the first one built.
            // (The NAME half is applied once the object exists, just before
            // `io->Typespec` below — the group's first formal may be written
            // as any member, not necessarily as the winning typedef.)
            else if (grpKey33c && tpGroupTs33c.count(grpKey33c)) {
                ts = tpGroupTs33c[grpKey33c];
                rt->Actual_typespec(ts);
            }
            else if (formalPkTy &&
                     formalPkTy->getCanonicalType().kind ==
                         SymbolKind::PackedArrayType &&
                     [&]() -> bool {
                         // A PACKED ARRAY over a vector typedef (word [1:0] w).
                         auto& at0 = *formalPkTy;
                         if (at0.kind != SymbolKind::PackedArrayType)
                             return false;
                         auto& el0 = at0.as<PackedArrayType>().elementType;
                         return el0.kind == SymbolKind::TypeAlias &&
                                typedefTs.count(&el0) &&
                                typedefTs[&el0]->UhdmType() ==
                                    UHDM::uhdmlogic_typespec;
                     }()) {
                // The formal ts spans type..dims: a logic_typespec whose
                // Elem_typespec (bare ref) is a fresh NAMED typedef clone
                // (Typedef_alias -> shared) and whose Ranges hold the ARRAY
                // dims (UINT bounds at the source dim spans).
                auto& at0 = *formalPkTy;
                auto& el0 = at0.as<PackedArrayType>().elementType;
                auto& elAlias = el0.as<TypeAliasType>();
                const syntax::SyntaxNode* targetSyn = nullptr;
                if (auto asyn = elAlias.getSyntax())
                    if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl = makeTypespec(elAlias, targetSyn);
                bypassTypedefShare = false;
                cl->VpiName(elAlias.name);
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(elAlias.name);
                art->VpiParent(cl);
                art->Actual_typespec(typedefTs[&el0]);
                ((UHDM::logic_typespec*)cl)->Typedef_alias(art);

                auto* outer = s.MakeLogic_typespec();
                SourceLocation tStart = arg->location;
                if (auto tsn0 = arg->getDeclaredType()->getTypeSyntax())
                    tStart = tsn0->sourceRange().start();
                std::vector<DimSpan> spans;
                if (tStart < arg->location)
                    spans = scanDimSpans(
                        std::string(rawText(SourceRange(tStart, arg->location))),
                        tStart);
                SourceLocation tEnd = arg->location;
                if (!spans.empty())
                    tEnd = spans.back().range.end();
                setLoc(outer, SourceRange(tStart, tEnd));
                std::vector<ConstantRange> arrRanges;
                for (const Type* t2 = formalPkTy;
                     t2->getCanonicalType().kind == SymbolKind::PackedArrayType;) {
                    arrRanges.push_back(
                        t2->getCanonicalType().as<PackedArrayType>().range);
                    t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
                    if (t2->kind == SymbolKind::TypeAlias)
                        break;
                }
                auto* rvec = s.MakeRangeVec();
                for (size_t ri = 0; ri < arrRanges.size(); ri++) {
                    auto* r = s.MakeRange();
                    r->VpiParent(outer);
                    const DimSpan* ds = ri < spans.size() ? &spans[ri] : nullptr;
                    if (ds)
                        setLoc(r, ds->range);
                    auto mkB = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(r);
                        if (loc)
                            setLoc(c, *loc);
                        return c;
                    };
                    r->Left_expr(mkB(arrRanges[ri].left, ds ? &ds->left : nullptr));
                    r->Right_expr(mkB(arrRanges[ri].right, ds ? &ds->right : nullptr));
                    rvec->push_back(r);
                }
                outer->Ranges(rvec);
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(outer);
                ert->Actual_typespec(cl);
                outer->Elem_typespec(ert);
                stampPkgFormalTs(cl);
                ts = outer;
                stampPkgFormalTs(ts);
                rt->Actual_typespec(ts);
            }
            else if (arg->getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
                     typedefTs.count(&arg->getDeclaredType()->getType()) &&
                     typedefTs[&arg->getDeclaredType()->getType()]->UhdmType() ==
                         UHDM::uhdmlogic_typespec) {
                // A typedef'd formal gets a fresh NAMED clone at the formal's
                // type token, with a Typedef_alias ref to the shared typedef.
                auto& at = arg->getDeclaredType()->getType();
                const syntax::SyntaxNode* targetSyn = nullptr;
                if (auto asyn = at.as<TypeAliasType>().getSyntax())
                    if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                // § pkgTdRangeViewFold18 — the clone's packed RANGE follows
                // the LISTING of the view it belongs to: symbolic only in the
                // typedef's home package DEF listing, folded everywhere else.
                bool savedTf18 = tfContext, savedNb18 = tdCloneRefNoBind18;
                if (auto* hta18 = pkgHomedTdAlias18(at)) {
                    tfContext = pkgTdOwnDefView(*hta18);
                    tdCloneRefNoBind18 = true;  // § pkgTdCloneRefNoBind18
                }
                // § modTdRetCloneSymbolic20 — the FORMAL half.  § tfFormalTs
                // records that "a task/function FORMAL's own typespec has its
                // range bound folded like a module one (the return type and
                // body locals do not)"; that law was measured on a formal
                // that WRITES its own range.  A formal typed by a MODULE-LOCAL
                // typedef inherits the TYPEDEF's clone rule instead and keeps
                // the bound SYMBOLIC — pz20.sv holds both spellings side by
                // side (`theta(box_t st)` vs `phi(logic [W-1:0] v)`).
                // Corpus: def:work@prim_keccak, `theta(box_t state)` :120:40.
                else if (at.kind == SymbolKind::TypeAlias)
                    tfContext = true;
                ts = makeTypespec(*arg, targetSyn);
                tdCloneRefNoBind18 = savedNb18;
                tfContext = savedTf18;
                bypassTypedefShare = false;
                ts->VpiName(at.name);
                if (argTsyn)
                    setLoc((UHDM::BaseClass*)ts, argTsyn->sourceRange());
                // § tfFormalTdCloneFile196 (r11u196, R11U196_FORMALCLONEFILE_OFF;
                // MiniAmiq #1694 / #1858 / #2014 / #2546, SeqDriver #1677 /
                // #1841 / #1997 / #2529) — the per-formal clone of a vector /
                // scalar typedef is compiled AT the formal's type token
                // (compileTfPortList's populateCoreMembers(type, type, ts)
                // writes vpiFile with the span), so it files at the formal's
                // file: golden `uvm_bitstream_t` uvm_misc.svh 483:42-483:57,
                // where ours kept the typedef's uvm_object_globals.svh (setLoc
                // fills only an EMPTY file, and makeTypespec had filed the
                // clone at the typedef).  Grid tools/probe/r11u196repro/cases/SF.
                if (argTsyn && r11u196Law("R11U196_FORMALCLONEFILE_OFF"))
                    if (auto st196 = argTsyn->sourceRange().start();
                        st196 != SourceLocation::NoLocation)
                        if (auto f196 = fullFilePath(st196);
                            !f196.empty() && f196 != ts->VpiFile()) {
                            ts->VpiFile(f196);
                            trace196("tfFormalTdCloneFile196", std::string(at.name));
                        }
                auto* mainTs = typedefTs[&at];
                // ...and the ALIAS half of the same law: the clone points at
                // the LISTING OBJECT OF ITS OWN VIEW.  typedefTs holds the DEF
                // listing, which is the right target only in the typedef's
                // home package DEF view; every folded view aliases the
                // ELABORATED listing (§ pkgTdRangeViewFold18).  Doing only the
                // range half leaves a folded clone pointing at a symbolic
                // listing, which Compare walks straight into.
                if (auto* hta18 = pkgHomedTdAlias18(at))
                    if (!pkgTdOwnDefView(*hta18))
                        if (auto t18 = pkgTopTypedefTs.find((const void*)hta18);
                            t18 != pkgTopTypedefTs.end() && t18->second)
                            mainTs = t18->second;
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(at.name);
                art->VpiParent(ts);
                art->Actual_typespec(mainTs);
                ((UHDM::logic_typespec*)ts)->Typedef_alias(art);
                stampPkgFormalTs(ts);
                rt->Actual_typespec(ts);
            }
            // An UNPACKED array over a vector typedef (sha_word_t ww [16:0])
            // gets the same NAMED per-formal clone: the io_decl's typespec is
            // the ELEMENT type (its unpacked dims live on the io_decl's own
            // Ranges), so the shared-typespec fallback below would leave it
            // anonymous (PackedUnpackedIo).  EVERY unpacked array shape does
            // it, not just the fixed-size one — a dynamic (`ref bt a[]`),
            // queue or associative formal names its element typespec too, and
            // a `bit`-based typedef mints a bit_typespec where a `logic`-based
            // one mints a logic_typespec (both carry Typedef_alias, which
            // lives on the typespec base class).  Measured on the UVM corpus:
            // 225 io_decl element typespecs golden names and we left bare.
            else if (unpackedTdElem9(arg->getDeclaredType()->getType(),
                                     typedefTs) != nullptr) {
                const Type* e0 =
                    unpackedTdElem9(arg->getDeclaredType()->getType(), typedefTs);
                auto& elAl0 = e0->as<TypeAliasType>();
                const syntax::SyntaxNode* targetSyn0 = nullptr;
                if (auto asyn0 = elAl0.getSyntax())
                    if (asyn0->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn0 =
                            asyn0->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                // § pkgTdRangeViewFold18, the ELEMENT half (pass 19).  A bare
                // alias formal (the arm above) already follows the view law;
                // an UNPACKED ARRAY over that same alias inherits the typedef's
                // packed range through its element and must follow it too —
                // `ref uvm_reg_addr_t addr[]` in uvm_mem::get_addresses is the
                // measured case, 33 io_decl/Stmt rows on BuildUVMPkg alone.
                bool savedTf19 = tfContext, savedNb19 = tdCloneRefNoBind18;
                if (auto* eta19 = pkgHomedTdAlias18(*e0)) {
                    tfContext = pkgTdOwnDefView(*eta19);
                    tdCloneRefNoBind18 = true;  // § pkgTdCloneRefNoBind18
                }
                ts = makeTypespec(elAl0, targetSyn0);
                tdCloneRefNoBind18 = savedNb19;
                tfContext = savedTf19;
                bypassTypedefShare = false;
                ts->VpiName(elAl0.name);
                if (argTsyn)
                    setLoc((UHDM::BaseClass*)ts, argTsyn->sourceRange());
                // § tfFormalTdCloneFile196 — the unpacked-array formal's
                // element clone, the same compile at the type token.
                if (argTsyn && r11u196Law("R11U196_FORMALCLONEFILE_OFF"))
                    if (auto st196 = argTsyn->sourceRange().start();
                        st196 != SourceLocation::NoLocation)
                        if (auto f196 = fullFilePath(st196);
                            !f196.empty() && f196 != ts->VpiFile()) {
                            ts->VpiFile(f196);
                            trace196("tfFormalTdCloneFile196", std::string(elAl0.name));
                        }
                auto* art0 = s.MakeRef_typespec();
                art0->VpiFullName(std::string(elAl0.name));
                art0->VpiParent(ts);
                UHDM::typespec* elMain19 = typedefTs[e0];
                // ...and the ALIAS half: the element clone aliases the LISTING
                // OBJECT OF ITS OWN VIEW, or Compare walks from a folded clone
                // straight into the symbolic def listing.
                if (auto* eta19 = pkgHomedTdAlias18(*e0))
                    if (!pkgTdOwnDefView(*eta19))
                        if (auto e18 = pkgTopTypedefTs.find((const void*)eta19);
                            e18 != pkgTopTypedefTs.end() && e18->second)
                            elMain19 = e18->second;
                art0->Actual_typespec(elMain19);
                ((UHDM::typespec*)ts)->Typedef_alias(art0);
                stampPkgFormalTs(ts);
                rt->Actual_typespec(ts);
            }
            else {
                tfContext = true;
                // ONE tf-context range Surelog FOLDS: a BODY-style (non-ANSI)
                // io declaration that names an explicit data type —
                // `input reg [WIDTH_A-1:0] s;` lands as an INT constant at the
                // bound's left-operand token, in every home (module fn, task,
                // package fn, cross-package bound) and for literal-only,
                // localparam and overridable-param bounds alike. Everything
                // else in a subroutine keeps the symbolic op tree: the return
                // type, every body local, an IMPLICIT-type body io
                // (`input [SIZE-1:0] state;` — FSMFunction) and EVERY
                // ANSI-header formal (`f(logic [16-1:0] op)` — UnionCast).
                // Measured on an 11-way golden matrix over one source.
                bool bodyIoTyped9 =
                    argTsyn && argTsyn->kind != syntax::SyntaxKind::ImplicitType;
                if (bodyIoTyped9) {
                    bool bodyIo9 = false;
                    for (auto q = arg->getSyntax(); q; q = q->parent) {
                        if (q->kind == syntax::SyntaxKind::FunctionPort)
                            break;
                        if (q->kind == syntax::SyntaxKind::PortDeclaration) {
                            bodyIo9 = true;
                            break;
                        }
                        if (q->kind == syntax::SyntaxKind::FunctionDeclaration ||
                            q->kind == syntax::SyntaxKind::TaskDeclaration)
                            break;
                    }
                    bodyIoTyped9 = bodyIo9;
                }
                tfFormalTs = bodyIoTyped9;
                tfTypeScope = pkgScope ? sub.getParentScope() : nullptr;
                // § impCloneDeclRangeNoBind200, SITE 1 of 2 — the FORMAL.
                // The corpus head lives here (uvm-1.2 uvm_globals.svh:434
                // `function string uvm_bits_to_string(logic
                // [UVM_LARGE_STRING:0] str)` cloned into adpcm_pkg /
                // svaunit_pkg).  Not the return: the clone lists the HOME's
                // return variable, which was bound before the clone existed.
                impCloneDeclRangeNoBind200 = pkgImportCloneEmit;
                ts = sharedTypespec(*arg, ioTs);
                impCloneDeclRangeNoBind200 = false;
                tfTypeScope = nullptr;
                tfFormalTs = false;
                tfContext = false;
                // A formal typed by an IMPORTED package typedef binds THIS
                // package's import CLONE, not the home object: the stamp
                // below would otherwise move the home typedef's vpiInstance
                // to the importing package (rp32 riscv_isa_pkg::isa_t as the
                // riscv_isa_i_pkg enc32/dec32 formal).
                if (pkgScope && !classScope)
                    if (auto adt0 = arg->getDeclaredType();
                        adt0 && adt0->getType().kind == SymbolKind::TypeAlias)
                        if (auto ic0 = pkgImportCloneTs.find(&adt0->getType());
                            ic0 != pkgImportCloneTs.end() && ic0->second &&
                            ic0->second != ts)
                            ts = ic0->second;
                // ...and the ELABORATED view's formals bind that view's
                // typedef listing object (see the return above).
                if (pkgTopEmit && ts)
                    for (auto& [sym0, tsp0] : typedefTs)
                        if (tsp0 == ts) {
                            if (auto t0 =
                                    pkgTopTypedefTs.find((const void*)sym0);
                                t0 != pkgTopTypedefTs.end() && t0->second)
                                ts = t0->second;
                            break;
                        }
                // DIRECTIONLESS explicit-keyword arg types anchor at the
                // keyword token only (ranges keep their own spans); formals
                // with a direction keyword keep the whole type span.
                bool hasDir = false;
                for (auto q = arg->getSyntax(); q; q = q->parent) {
                    if (q->kind == syntax::SyntaxKind::FunctionPort) {
                        hasDir = q->as<syntax::FunctionPortSyntax>().direction.valid();
                        break;
                    }
                    // Body-style io declarations (input reg [2:0] x;) always
                    // carry a direction keyword.
                    if (q->kind == syntax::SyntaxKind::PortDeclaration) {
                        hasDir = true;
                        break;
                    }
                    if (q->kind == syntax::SyntaxKind::FunctionDeclaration)
                        break;
                }
                if (!hasDir && argTsyn && argTsyn->kind != syntax::SyntaxKind::ImplicitType) {
                    // A SIGNING keyword (int unsigned SRC) is outside the
                    // formal's typespec span too — Surelog anchors it on the
                    // base keyword alone (ArrayExprFuncArg).
                    if (auto* its2 = argTsyn->as_if<syntax::IntegerTypeSyntax>();
                        its2 && (!its2->dimensions.empty() || its2->signing))
                        setLoc((UHDM::BaseClass*)ts, its2->keyword.range());
                }
                // The ELABORATED pass must not move a DEF-pass-owned shared
                // typespec (an import CLONE) onto the top package view:
                // Surelog keeps one object at its def-view instance. Fresh
                // top-built formal typespecs are absent from the marker and
                // still take the elaborated instance.
                // § importCopyAggFormalOwnCopy32 — a wildcard-import CLONE's
                // AGGREGATE formal must not re-stamp the SHARED listing clone
                // it is bound to: that object is owned by the last importer
                // (§ pkgImportAggCloneLastWriter32) while the clone's own
                // formals name the HOME package.  Golden splits them into two
                // objects (t42a: `uses=7` shared vs `uses=1` per clone
                // formal); take a private copy and let the stamp below write
                // that.  Aggregates only — a scalar/vector formal already
                // holds a per-declaration LAW-S copy and never touches the
                // shared object.
                if (importCopyTsInst && ts &&
                    pkgImportCloneOwner32.count((UHDM::typespec*)ts))
                    if (auto* acp32 =
                            aggImportCloneCopy32((UHDM::typespec*)ts)) {
                        ts = acp32;
                        // § importCloneAliasEnumBareName36 — inside a clone
                        // body that private copy is BARE-named when the
                        // typedef is an ALIAS OF AN ALIAS, and only then.
                        // § importCloneBareTdAlias16's reason ("the clone's
                        // chain is re-minted against the IMPORTING package,
                        // so nothing in it is the object writeDataTypes
                        // prefixed") reaches one typespec kind further than
                        // LAW S ever did, because LAW S deliberately excludes
                        // an alias-of-alias from taking a copy at all.
                        // t48b holds the control in the same golden:
                        //   DEFPKG aa49::use_ae48 io0 'ae48_t'@home49!TOP
                        //     (alias of an alias -> BARE)
                        //   DEFPKG aa49::use_de48 io0
                        //     'home49::de48_t'@home49!TOP  (direct enum ->
                        //     QUALIFIED, and we already matched it)
                        // SeqDriver's `UVM_SEQ_ARB_TYPE` is the alias arm:
                        // `typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE`.
                        if (auto adt36 = arg->getDeclaredType();
                            adt36 &&
                            adt36->getType().kind == SymbolKind::TypeAlias &&
                            adt36->getType()
                                    .as<TypeAliasType>()
                                    .targetType.getType()
                                    .kind == SymbolKind::TypeAlias) {
                            std::string qn36(acp32->VpiName());
                            if (auto p36 = qn36.rfind("::");
                                p36 != std::string::npos)
                                acp32->VpiName(qn36.substr(p36 + 2));
                        }
                    }
                // § sharedTdRefNoRestamp9, SITE 3 of 4 — the FORMAL.
                const SharedTd9 shArg9 =
                    sharedTypedefTsRef9(*arg, (const UHDM::typespec*)ts);
                if (tsInst &&
                    !foreignSharedTs(*arg, (const UHDM::typespec*)ts) &&
                    shArg9 != SharedTd9::PkgClassTs &&
                    shArg9 != SharedTd9::ClassOther &&
                    !(pkgTopEmit &&
                      defPassOwnedTs.count((UHDM::typespec*)ts))) {
                    ((UHDM::typespec*)ts)->Instance(
                        importCopyTsInst ? importCopyTsInst : tsInst);
                    stampElemTsInstance(
                        (UHDM::typespec*)ts,
                        (UHDM::instance*)((UHDM::typespec*)ts)->Instance());
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back((UHDM::typespec*)ts);
                }
                rt->Actual_typespec(ts);
            }
            // § classTypeParamTdGroupLastWins33c, the NAME half.  The group's
            // first formal built the object through its own ordinary arm — so
            // its KIND is already the resolved type's — and this renames it to
            // the winning typedef and publishes it for the rest of the group.
            if (grpKey33c && ts)
                if (auto& slot33c = tpGroupTs33c[grpKey33c]; !slot33c) {
                    ((UHDM::typespec*)ts)
                        ->VpiName(tpGroupWinner33c[grpKey33c]->name);
                    slot33c = (UHDM::typespec*)ts;
                }
            io->Typespec(rt);
            deferForeignTopTs(*arg, rt, (const UHDM::typespec*)ts);
            emitIoRanges34(*arg, io, fullName + sep + std::string(arg->name),
                           tsInst, !protoOf);
            ios->push_back(io);
            // A class-method formal IS reachable from the body, but only an
            // if/case CONDITION ref actually binds it (classMethodNoBind).
            funcMap[arg] = io;
            dvFormals13[arg] = io; // § formalDefaultBindsLikeBody13
            si.argTs.push_back({ts, bareImplicit ? (const void*)argTsyn : nullptr});
        }
        // § qualifiedLifetimeMethodLosesNamePortsBody46 attaches no formals for
        // the same reason § 27 attaches none: the `Tf_port_list` derives from a
        // node that came out invalid.  The io_decls are still BUILT (the body
        // binder's maps are populated from them) and then left unattached,
        // exactly as § 27 leaves a qualified constructor's.
        if (!ios->empty() && !qualCtor27 && !qualLifetime46)
            tf->Io_decls(ios);

        // The prototype listing ends here: no body, no locals, no params, and
        // no subMap registration (calls bind the DEFINITION object, which the
        // second group emits from the same SubroutineSymbol).
        if (protoOf) {
            // § externProtoInBodyCallBinds12 — SITE 2 of 2, the `extern`
            // prototype.  The comment two lines up ("calls bind the DEFINITION
            // object") is the defect: golden binds THIS object, the one the
            // class_defn lists, for every call written inside the class body.
            // The key is the DEFINITION's SubroutineSymbol, because that is
            // what slang resolves the call to (`createOutOfBlock`), and it is
            // also the key `subMap` will later hold the definition object
            // under -- so the call sites read this map FIRST and the redirect
            // needs no second lookup.  Arm v1 `call_ef` / `call_es` /
            // `call_etv` / `prop_es` / `prop_esb`, arm v2 `call_mef`.
            if (tf->UhdmType() == UHDM::uhdmfunction)
                classProtoFn12[&sub] = (UHDM::function*)tf;
            tfs->push_back(tf);
            continue;
        }

        emitParameters(sub, tf, fullName, funcMap, /*topView=*/false, nullptr,
                       /*inPackage=*/false, /*topShareTs=*/false, /*funcScope=*/true);
        // A TASK-scope parameter is a body STATEMENT, not a task property:
        // Surelog drops the vpiParameter listing entirely and keeps the
        // parameter only as its param_assign's Lhs -- whole-declarator span
        // (the assign's own), vpiLocalParam, no typespec and no value -- with
        // the value expression left unparented and untyped. The param_assign
        // itself moves into the body begin (StmtEmit's statement-list arm
        // prepends it and re-parents it there). A FUNCTION keeps the ordinary
        // function-level model: probe r10c4_p1's `function int F; parameter
        // flen = 11; ...` dumps vpiParameter + a function-parented
        // param_assign byte-identically today.
        std::vector<UHDM::param_assign*> taskBodyPa9;
        std::vector<SourceRange> taskBodyPaAnchor9;
        if (sub.subroutineKind == SubroutineKind::Task && tf->Param_assigns()) {
            for (auto* pa9 : *tf->Param_assigns()) {
                taskBodyPa9.push_back(pa9);
                if (auto* lhs9 = pa9->Lhs();
                    lhs9 && lhs9->UhdmType() == UHDM::uhdmparameter) {
                    auto* pv9 = (UHDM::parameter*)lhs9;
                    pv9->VpiLineNo(pa9->VpiLineNo());
                    pv9->VpiColumnNo(pa9->VpiColumnNo());
                    pv9->VpiEndLineNo(pa9->VpiEndLineNo());
                    pv9->VpiEndColumnNo(pa9->VpiEndColumnNo());
                    pv9->VpiLocalParam(true);
                    pv9->Typespec(nullptr);
                    pv9->VpiValue(std::string());
                }
                if (auto* rhs9 = pa9->Rhs();
                    rhs9 && rhs9->UhdmType() == UHDM::uhdmconstant) {
                    ((UHDM::constant*)rhs9)->Typespec(nullptr);
                    rhs9->VpiParent(nullptr);
                }
            }
            tf->Parameters(nullptr);
            // ...and it is not in the body's scope either: a body reference to
            // the name resolves to NOTHING and mints an implicit wire in the
            // enclosing module, exactly like any other unresolved bare name
            // (probe r10c4_p1 C/D: `$display(clen)` binds work@m.clen, a
            // module-level logic_net, not the parameter).
            for (auto& pm9 : sub.members())
                if (pm9.kind == SymbolKind::Parameter)
                    funcMap.erase(&pm9);
            // The declaration's WHOLE statement span (`parameter x = 1;`,
            // keyword through semicolon) is what the wrapper anchors at when
            // a parameter happens to be the body's second item.
            for (auto& pm9 : sub.members()) {
                if (pm9.kind != SymbolKind::Parameter)
                    continue;
                auto* psyn9 = pm9.getSyntax();
                while (psyn9 && psyn9->parent &&
                       psyn9->kind !=
                           syntax::SyntaxKind::ParameterDeclarationStatement)
                    psyn9 = psyn9->parent;
                if (psyn9)
                    taskBodyPaAnchor9.push_back(psyn9->sourceRange());
            }
            taskBodyPaAnchor9.resize(taskBodyPa9.size(),
                                     SourceRange::NoLocation);
        }
        if (m->UhdmType() == UHDM::uhdmmodule_inst) {
            implicitNetModule = (UHDM::module_inst*)m;
            implicitNetPrefix = prefix;
        }

        // Function-local variables attach to the function's Variables.
        std::vector<UHDM::variables*> fnBlockLocalPav;
        // Which LRM production the body parsed under decides the whole local
        // model — `{ tf_item_declaration }` (the paren-less header) versus
        // `{ block_item_declaration }` (the parenthesized one):
        //   * TF-ITEM shape: locals stay FUNCTION-parented at the declared-
        //     type span, carry vpiAutomatic, and get NO wrapper begin
        //     (func_block, const_fold_func, PackFunc, FuncNoArgs,
        //     LocalVarTypespec, TaskDecls).
        //   * BLOCK-ITEM shape: name-span, NON-automatic locals owned by a
        //     synthesized body `begin` and dual-listed under the subroutine
        //     (func_upto, func_local_array, PackFuncParent, VarInFor,
        //     FuncParam).
        // Probe-verified against Surelog across module / package / class
        // scope, static and automatic, task and function: a FUNCTION takes
        // the block shape exactly when its header carries a port-list paren
        // (`function int f();` blockifies, `function int f;` does not), while
        // a TASK takes it whenever the body declares no io — a paren-less
        // `task t; int x; ...` blockifies, and only a body-style
        // `input`/`output`/`inout` declaration pushes it back to tf-items.
        // This supersedes the implicit-vs-explicit-body and
        // static-with-unpacked-local proxies: a body that IS one explicit
        // `begin` blockifies its locals just the same, and the wrapper the
        // static-unpacked arm used to synthesize is the plain body wrapper
        // StmtEmit's statement-list arm now builds.
        bool bodyIoDecl9 = false;
        bool portParens9 = false;
        if (auto fsyn9 = sub.getSyntax())
            if (auto* fd9 = fsyn9->as_if<syntax::FunctionDeclarationSyntax>()) {
                portParens9 = fd9->prototype->portList != nullptr;
                for (auto* it9 : fd9->items)
                    if (it9->kind == syntax::SyntaxKind::PortDeclaration)
                        bodyIoDecl9 = true;
            }
        bool blockItems9 =
            !bodyIoDecl9 &&
            (portParens9 || sub.subroutineKind == SubroutineKind::Task);
        // § ctorBodyLocalsNotOnFunc71 — the body locals this block collects.
        // Hoisted out of the block ONLY so the `$bits(<formal>)` io_decl
        // binding below keeps running over exactly the set it ran over before
        // this pass: that loop used to read `tf->Variables()`, and a
        // constructor no longer HAS one.  Reading the collected vector instead
        // of the emitted vector keeps the binder's input identical for
        // constructor and non-constructor alike, so the gate below changes
        // what is EMITTED and nothing else.
        UHDM::VectorOfvariables* fvarsAll71 = nullptr;
        {
            auto* fvars = s.MakeVariablesVec();
            for (auto& fmv : sub.members()) {
                // The implicit `this` handle is not a local.
                if (fmv.name == "this")
                    continue;
                if (fmv.kind != SymbolKind::Variable || &fmv == sub.returnValVar)
                    continue;
                bool isArg = false;
                for (auto arg : sub.getArguments())
                    // A body re-declaration of a formal (input [4:0] r;
                    // reg [4:0] r;) merges into the formal — no separate
                    // local var (match by NAME, not symbol).
                    if (arg == &fmv || arg->name == fmv.name)
                        isArg = true;
                if (isArg)
                    continue;
                // A QUEUE / DYNAMIC-array local (`C paths[$]`, `int d[]`) is
                // the same array_var shape as the fixed-size one below, with
                // vpiArrayType vpiQueueArray/vpiDynamicArray and an UNBOUNDED
                // array_typespec range: [0 : $] (vpiUnboundedConst, size 1)
                // for a queue, [0 : "unsized"] (vpiStringConst, size 0) for a
                // dynamic array.  The element typespec is the declaration's
                // own (makeTypespec looks through the array dims) and is
                // SHARED by the reg and the array_typespec's Elem_typespec.
                // Surelog, probe-verified for class-handle and int elements
                // (ClassVar / LocalScopeHierPath / ArrayMethodIterator).
                // ...but ONLY under the BLOCK-ITEM production. A TF-ITEM body
                // (paren-less function header) models every array local as a
                // plain ELEMENT variable at the declared-type span instead —
                // no array_var, no element reg, no unpacked range — for
                // queues, dynamic arrays and fixed-size arrays alike (probes
                // r10c4_p9/p10: `function int f; int lq[$];` dumps an
                // automatic int_var, its `function int f();` twin an
                // array_var).
                // § nameBasedArrayTdDeclIsRefVar166, SITE 2 of 2 — the
                // SUBROUTINE-BODY (TF-ITEM) local, which is the listing the
                // `uvm_utils::find` cell also reaches.  Same law, same
                // question, asked before all three array factories; gated on
                // `blockItems9` exactly like them, so a PAREN-LESS function
                // header keeps the flat model it has today.
                if (auto* rv166 =
                        !blockItems9
                            ? nullptr
                            : makeNameBasedArrayTdRefVar166(
                                  fmv, fullName + sep + std::string(fmv.name),
                                  tf,
                                  importCopyTsInst ? importCopyTsInst
                                                   : tsInst)) {
                    funcMap[&fmv] = rv166;
                    fvars->push_back(rv166);
                    continue;
                }
                if (auto* av = !blockItems9
                                   ? nullptr
                                   : makeQueueDynArrayVar(
                                         fmv,
                                         fullName + sep + std::string(fmv.name),
                                         tf,
                                         importCopyTsInst ? importCopyTsInst
                                                          : tsInst)) {
                    funcMap[&fmv] = av;
                    fvars->push_back(av);
                    continue;
                }
                // § assocLocalArrayVar40 — the ASSOCIATIVE half of the same
                // rule, under the same BLOCK-ITEM gate.  `promoteNamed` names
                // the ELABORATED listing, and it is spelled per LISTING rather
                // than per view flag because the three listings that carry a
                // package task_func are built at three different times:
                //   * an OUT-OF-BODY definition's own listing (`oob`) is
                //     emitted once, from emitPackageClasses, in the top view —
                //     promoted; its DEF-view twin comes from
                //     emitPackageClassMethodClones, which is exactly
                //     `cloneMode` — not promoted;
                //   * a package FREE function is emitted once per view with
                //     `pkgTopEmit` set accordingly;
                //   * an IN-BODY class method is never promoted at all
                //     (t57a `inb57::iAssocCls57::iacls` keeps the SIZE model).
                // § assocIdxNamePromoteInImportClone189 adds the FOURTH
                // listing — a WILDCARD-IMPORT CLONE, in BOTH views — to the
                // promoted set; see include/UhdmExporter.h,
                // `grep -n assocIdxNamePromoteInImportClone189`.
                if (auto* aav = !blockItems9
                                    ? nullptr
                                    : makeAssocArrayVar(
                                          fmv,
                                          fullName + sep + std::string(fmv.name),
                                          tf,
                                          importCopyTsInst ? importCopyTsInst
                                                           : tsInst,
                                          promoteAssocIdxName189(oob, cloneMode,
                                                                 classScope))) {
                    funcMap[&fmv] = aav;
                    fvars->push_back(aav);
                    continue;
                }
                // An UNPACKED-array local (int a [2]) is an array_var whose
                // vpiReg is the element var (int_var); the array_typespec
                // (not the array_var) carries the unpacked-dim range, and its
                // Elem_typespec is SHARED with the reg. Not a flat var.
                if (blockItems9 &&
                    fmv.getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType) {
                    std::string afull = fullName + sep + std::string(fmv.name);
                    const Type* leaf = &fmv.getDeclaredType()->getType().getCanonicalType();
                    while (leaf->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        leaf = &leaf->getCanonicalType()
                                    .as<FixedSizeUnpackedArrayType>()
                                    .elementType;
                    // The element typespec (int_typespec for int/...), shared
                    // by the reg AND the array_typespec's Elem_typespec.
                    UHDM::typespec* elemTs = nullptr;
                    // § declArrayElemTsIsWrittenKeyword126 — Surelog's
                    // `compileBuiltinTypespec` dispatch, asked of the WRITTEN
                    // base-type KEYWORD instead of the element's integral
                    // shape.  This arm answers `string` / `real` / `shortreal`
                    // / `chandle` / `event` / `byte` / `shortint` / `longint`
                    // / `integer` / `time` (and `int`, with the object it
                    // already had); `logic` / `reg` / `bit` and every NAMED
                    // type fall through to the two arms below unchanged.  Law
                    // + Surelog citations: EmitHelpers.h.
                    const syntax::SyntaxNode* tsynK126 =
                        fmv.getDeclaredType()->getTypeSyntax();
                    if (auto* kwTs126 = writtenKeywordElemTs126(
                            s, tsynK126, leaf->isSigned())) {
                        // The SAME span the int arm below already took: the
                        // keyword token itself, which is the node Surelog's
                        // populateCoreMembers spans these typespecs over.
                        setLoc(kwTs126, tsynK126->getFirstToken().range());
                        elemTs = kwTs126;
                    }
                    else if (leaf->getCanonicalType().kind ==
                        SymbolKind::PredefinedIntegerType) {
                        auto* its = s.MakeInt_typespec();
                        its->VpiSigned(leaf->isSigned());
                        if (auto tsyn3 = fmv.getDeclaredType()->getTypeSyntax())
                            setLoc(its, tsyn3->getFirstToken().range());
                        elemTs = its;
                    }
                    else {
                        // A packed-vector leaf (reg [3:0]) gets a LOCATED
                        // logic_typespec spanning the element-type syntax with
                        // its packed range (Surelog) — not a bare loc-less ts.
                        // A TWO-STATE leaf (`bit ub [2]`) gets a bit_typespec
                        // instead, exactly like makeTypespec's own unpacked-
                        // leaf rule (AllPackageSignal's `bit unused_bit [..]`).
                        auto& lct = leaf->getCanonicalType();
                        UHDM::logic_typespec* lts = nullptr;
                        UHDM::bit_typespec* bts = nullptr;
                        if (lct.isIntegral() && !lct.isFourState())
                            bts = s.MakeBit_typespec();
                        else
                            lts = s.MakeLogic_typespec();
                        UHDM::typespec* ets =
                            lts ? (UHDM::typespec*)lts : (UHDM::typespec*)bts;
                        if (auto tsyn3 = fmv.getDeclaredType()->getTypeSyntax()) {
                            auto sr3 = tsyn3->sourceRange();
                            setLoc(ets, sr3);
                            if (lct.kind == SymbolKind::PackedArrayType) {
                                auto pr3 = lct.as<PackedArrayType>().range;
                                std::vector<DimSpan> spans3;
                                if (sr3.start() != SourceLocation::NoLocation)
                                    spans3 = scanDimSpans(
                                        std::string(rawText(sr3)), sr3.start());
                                const DimSpan* ds3 =
                                    spans3.empty() ? nullptr : &spans3.back();
                                auto* rng3 = s.MakeRange();
                                rng3->VpiParent(ets);
                                if (ds3)
                                    setLoc(rng3, ds3->range);
                                // A SYMBOLIC element bound (`logic [WIDTH-1:0]
                                // set_clear[2]` in a function) stays UNFOLDED,
                                // exactly like the same declaration without the
                                // unpacked dim — Surelog keeps the WIDTH-1
                                // operation in the element typespec of both
                                // views (rggen_bit_field get_sw_next_value).
                                const syntax::ExpressionSyntax* sl3 = nullptr;
                                const syntax::ExpressionSyntax* sr4 = nullptr;
                                if (tsyn3->kind == syntax::SyntaxKind::LogicType ||
                                    tsyn3->kind == syntax::SyntaxKind::RegType ||
                                    tsyn3->kind == syntax::SyntaxKind::BitType) {
                                    auto& ity3 =
                                        tsyn3->as<syntax::IntegerTypeSyntax>();
                                    if (!ity3.dimensions.empty()) {
                                        auto* dim3 = ity3.dimensions.back();
                                        if (dim3->specifier &&
                                            dim3->specifier->kind ==
                                                syntax::SyntaxKind::
                                                    RangeDimensionSpecifier) {
                                            auto& sel3 =
                                                *dim3->specifier
                                                     ->as<syntax::RangeDimensionSpecifierSyntax>()
                                                     .selector;
                                            if (sel3.kind ==
                                                syntax::SyntaxKind::
                                                    SimpleRangeSelect) {
                                                auto& rss3 =
                                                    sel3.as<syntax::RangeSelectSyntax>();
                                                sl3 = rss3.left;
                                                sr4 = rss3.right;
                                            }
                                        }
                                    }
                                }
                                auto symB3 =
                                    [&](const syntax::ExpressionSyntax* e3)
                                    -> UHDM::expr* {
                                    if (!e3 ||
                                        e3->kind ==
                                            syntax::SyntaxKind::IntegerLiteralExpression)
                                        return nullptr;
                                    return (UHDM::expr*)emitSyntaxExpr(*e3,
                                                                       rng3);
                                };
                                auto mkR3 = [&](int64_t bv,
                                                const SourceRange* bl)
                                    -> UHDM::expr* {
                                    auto* c3 = s.MakeConstant();
                                    std::string d3 = std::to_string(bv);
                                    c3->VpiDecompile(d3);
                                    c3->VpiSize(64);
                                    c3->VpiValue("UINT:" + d3);
                                    c3->VpiConstType(vpiUIntConst);
                                    c3->VpiParent(rng3);
                                    if (bl)
                                        setLoc(c3, *bl);
                                    return c3;
                                };
                                auto* le3 = symB3(sl3);
                                auto* re3 = symB3(sr4);
                                rng3->Left_expr(
                                    le3 ? le3
                                        : mkR3(pr3.left,
                                               ds3 ? &ds3->left : nullptr));
                                rng3->Right_expr(
                                    re3 ? re3
                                        : mkR3(pr3.right,
                                               ds3 ? &ds3->right : nullptr));
                                auto* rvec3 = s.MakeRangeVec();
                                rvec3->push_back(rng3);
                                if (lts)
                                    lts->Ranges(rvec3);
                                else
                                    bts->Ranges(rvec3);
                            }
                        }
                        elemTs = ets;
                    }
                    // A PACKAGE-scope function's locals resolve in the
                    // package, so their element typespecs carry it as
                    // vpiInstance — same rule (and same tsInst) the flat-local
                    // arm below already applies (AllPackageSignal).
                    if (elemTs && tsInst && !elemTs->Instance())
                        elemTs->Instance(importCopyTsInst ? importCopyTsInst
                                                          : tsInst);
                    // § classScopedTdDeclTsUnsupported11, SITE 4c of 5 —
                    // the FIXED-SIZE declarator array, tf-item form.  grid11
                    // `g8` `a_fx` / `k_fx`.
                    if (auto* uts11 = makeScopedTdUnsupTs11(fmv))
                        elemTs = uts11;
                    // § blockLocalTdDeclIsRefVarUnsupported155, SITE 5 of 6 —
                    // the FIXED-SIZE declarator array, tf-item form (grid155
                    // `tongsFixed` in a module task, both views).
                    else if (auto* uts155 = makeStmtScopeTdUnsupTs155(fmv)) {
                        if (tsInst)
                            uts155->Instance(importCopyTsInst ? importCopyTsInst
                                                              : tsInst);
                        elemTs = uts155;
                    }

                    auto* av = s.MakeArray_var();
                    av->VpiName(fmv.name);
                    av->VpiFullName(afull);
                    av->VpiParent(tf);
                    av->VpiArrayType(vpiStaticArray);
                    setLoc(av, nameSpan(fmv.location, fmv.name));
                    auto* ats = s.MakeArray_typespec();
                    {
                        SourceLocation aEnd = fmv.location + fmv.name.size();
                        if (auto dsyn0 = fmv.getSyntax();
                            dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
                            for (auto dim0 :
                                 dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
                                aEnd = dim0->sourceRange().end() - 1;
                        setLoc(ats, SourceRange(fmv.location, aEnd));
                    }
                    if (auto* arng = buildUnpackedRanges(fmv, ats))
                        ats->Ranges(arng);
                    auto* ert = s.MakeRef_typespec();
                    ert->VpiParent(ats);
                    ert->Actual_typespec(elemTs);
                    ats->Elem_typespec(ert);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(afull);
                    art->VpiParent(av);
                    art->Actual_typespec(ats);
                    av->Typespec(art);
                    // § declArrayElemKindIsDeclKind12, SITE 3 of 4 — the
                    // FIXED-SIZE declarator array, tf-item form.  grid12 `h1`
                    // `a_fx` / `k_fx`.
                    auto* reg = makeDeclArrayElemVar12(s, fmv, *leaf,
                                        stmtScopeTdDegrades155(fmv));
                    reg->VpiParent(av);
                    setLoc(reg, nameSpan(fmv.location, fmv.name));
                    auto* regRt = s.MakeRef_typespec();
                    regRt->VpiFullName(afull);
                    regRt->VpiParent(reg);
                    regRt->Actual_typespec(elemTs);
                    reg->Typespec(regRt);
                    // § typeParamRetIsRefVar58 — the ONE call site that stamps
                    // vpiSigned AFTER the factory, so the law's "no vpiSigned"
                    // half has to be repeated here or a ref_var would carry a
                    // flag golden never puts on one (v4_contprop's `T qloc [$];`
                    // subroutine-local element: golden ref_var with no
                    // vpiSigned, ours ref_var,S before this guard).
                    // § declArrayElemVarSignedIsAtomKeyword129, SITE 3 of
                    // 4 — the FIXED-SIZE tf block-item array.
                    reg->VpiSigned(
                        declArrayElemVarSigned129(fmv, *leaf) &&
                        !typeParamVarIsRefVar58(*leaf) &&
                        declArrayElemVarKind12(
                            fmv, stmtScopeTdDegrades155(fmv)) ==
                            TdLocalVarKind10::Resolved);
                    auto* rv = s.MakeVariablesVec();
                    rv->push_back(reg);
                    av->Variables(rv);
                    funcMap[&fmv] = av;
                    // A foreach over this array binds THIS array_typespec —
                    // both for the iterated-array ref (which used to mint a
                    // fresh unlocated one) and for the loop variables.
                    arrayVarArrayTs[&fmv] = ats;
                    tfLocalArrayTs9[&fmv] = ats;
                    fvars->push_back(av);
                    continue;
                }
                std::string vfull = fullName + sep + std::string(fmv.name);
                bool hasInit = fmv.getDeclaredType()->getInitializer() != nullptr;
                // A local declared via a NAMED typedef (box_t result) is a
                // body-BLOCK member in Surelog's model: name-loc, no
                // vpiAutomatic, re-parented to the body begin after the body
                // emits. Builtin-typed locals (reg/integer/logic) stay at the
                // function with the type-span loc + vpiAutomatic.
                bool namedTypeLocal = false;
                if (!hasInit && !pkgScope)
                    if (auto tsyn0 = fmv.getDeclaredType()->getTypeSyntax())
                        namedTypeLocal = tsyn0->kind == syntax::SyntaxKind::NamedType;
                // § builtinClassLocalUnsupportedBeforeClassPhase115 — the law
                // is in UhdmExporter.h with its Surelog citations.  Computed
                // HERE, ahead of the typespec, because the FOURTH conjunct is
                // a NEGATIVE one this site owns: an IN-BODY class method's
                // body local is compiled in Surelog's LATER class pass, sees
                // the registered builtin and keeps `class_var` + an UNNAMED
                // `class_typespec` — which is already ours (grid cell `kp`,
                // both views, byte-identical on both sides).  `classScope &&
                // !oob` is exactly that case; it is the same pair
                // § pkgVarBindsOnlyThroughInstance88 reads for
                // `inBodyClassMethod88` and the same pair that leaves `tsInst`
                // null, so the gate and the instance can never drift apart.
                // ...and the VIEW conjunct: a GENERATE SCOPE's subroutine is
                // built during ELABORATION, after the builtin classes are
                // registered, so its body local RESOLVES (grid cell `gtp`, a
                // generate-block TASK).  `genScope` is `m->UhdmType() ==
                // uhdmgen_scope` — the DEF listing builds no gen_scope at all.
                const std::string_view stdBi115 =
                    (genScope || (classScope && !oob))
                        ? std::string_view{}
                        : builtinStdClassToken115(fmv.getDeclaredType());
                // A VECTOR-typedef block-local binds a fresh NAMED clone (at
                // the typedef target syntax, with a Typedef_alias ref to the
                // shared typedef and its own unfolded ranges) instead of the
                // shared typedef itself.
                UHDM::typespec* vts = nullptr;
                if (namedTypeLocal) {
                    auto& vdt = fmv.getDeclaredType()->getType();
                    if (vdt.kind == SymbolKind::TypeAlias) {
                        if (auto it0 = typedefTs.find(&vdt);
                            it0 != typedefTs.end() &&
                            it0->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                            const syntax::SyntaxNode* targetSyn = nullptr;
                            if (auto asyn = vdt.as<TypeAliasType>().getSyntax())
                                if (asyn->kind ==
                                    syntax::SyntaxKind::TypedefDeclaration)
                                    targetSyn = asyn->as<
                                                    syntax::TypedefDeclarationSyntax>()
                                                    .type;
                            bypassTypedefShare = true;
                            // § pkgTdRangeViewFold18 (see below): the clone
                            // mirrors its own view's listing.
                            tfContext = true;
                            bool savedNb18 = tdCloneRefNoBind18;
                            if (auto* vta18 = pkgHomedTdAlias18(vdt)) {
                                tfContext = pkgTdOwnDefView(*vta18);
                                tdCloneRefNoBind18 = true;
                            }
                            auto* cl = makeTypespec(fmv, targetSyn);
                            tdCloneRefNoBind18 = savedNb18;
                            tfContext = false;
                            bypassTypedefShare = false;
                            cl->VpiName(vdt.name);
                            auto* art = s.MakeRef_typespec();
                            art->VpiFullName(std::string(vdt.name));
                            art->VpiParent(cl);
                            art->Actual_typespec(it0->second);
                            ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                            vts = cl;
                        }
                    }
                }
                if (!vts) {
                    tfContext = true;
                    // § pkgTdRangeViewFold18.  A local declared with a PACKAGE
                    // TYPEDEF (`pt loc_p;`) inherits the TYPEDEF's range, and
                    // that range is view-dependent: symbolic only in the
                    // typedef's home package DEF listing.  A local that WRITES
                    // its own range keeps the S3 rule below unchanged.
                    bool savedNb18 = tdCloneRefNoBind18;
                    if (auto* lta18 = pkgHomedTdAlias18(
                            fmv.getDeclaredType()->getType())) {
                        tfContext = pkgTdOwnDefView(*lta18);
                        tdCloneRefNoBind18 = true;
                    }
                    // § r10fsv3 S3.  A body-local's own type range is bound the
                    // same way a return/arg range is: `logic [NrMaxRules-1:0]
                    // pass;` inside a package function keeps the unfolded op
                    // tree, and its ref_obj carries vpiActual = the package
                    // param's folded constant.  The subroutine (not the
                    // package) is the lookup scope so a same-named body local
                    // shadows, and the constant is THIS VIEW's.
                    auto* savedTfS3 = tfTypeScope;
                    bool savedTfV3 = tfTypeScopeViewLocal;
                    if (pkgScope && !classScope && !tfTypeScope) {
                        tfTypeScope = &sub;
                        tfTypeScopeViewLocal = true;
                    }
                    // § tfItemLocalClassTsNamedByCompileTypespec142 — the
                    // PRODUCTION, handed to the one arm that needs it.  Read
                    // ONLY by TypeEmit's class-handle arm, where it narrows
                    // § localClassTsUnnamed15's same-component suppression; the
                    // law and its Surelog citations are in UhdmExporter.h.
                    // `blockItems9` is the production selector this loop
                    // already computed, so the gate cannot drift from the
                    // shape the rest of the loop models.
                    // VERIFIER FIX (r10v142) —
                    // § tfItemLocalClassTsNotAConstructor142v.
                    // A CLASS CONSTRUCTOR IS NEVER THE
                    // TF-ITEM PRODUCTION, whatever its header looks like:
                    // Surelog compiles a constructor body through
                    // `CompileHelper::compileClassConstructorDeclaration`
                    // (CompileStmt.cpp:2165), which never reaches
                    // `compileTfPortDecl`'s `paBlock_item_declaration` arm at
                    // all, so the local's typespec stays `compileVariable`'s
                    // unnamed fallback even for a PAREN-LESS `function new;`.
                    // `blockItems9` only reads the port-list paren, so without
                    // this term the gate calls `function new;` TF-ITEM and
                    // NAMES a local golden leaves anonymous.
                    // MEASURED (verifier arms v142_a_ctor / v142_d_ctor2, both
                    // views): four RIGHT->WRONG cells without this term —
                    // `Cv1142::new` 14:7, `Bv4142::new` 12:7,
                    // `Dv4142::new` (an extended class) 18:7 and a MODULE
                    // class's `Mc4142::new` 43:7 — all golden-anonymous, all
                    // named by the ungated gate.  Zero with it.
                    // CONSTRUCTOR-NESS IS SLANG'S OWN FLAG, NOT THE NAME
                    // (§ ctorNoVars71's lesson): an ESCAPED identifier is
                    // exempt from keyword rules, so `function void \new ;` is
                    // an ORDINARY paren-less method whose locals golden DOES
                    // name — arm v142_d_ctor2 cells 24:7 / 25:7, WRONG->RIGHT
                    // under this fix and RIGHT->WRONG under a `sub.name ==
                    // "new"` test.
                    bool savedTfi142 = tfItemLocalClassTs142;
                    tfItemLocalClassTs142 =
                        !blockItems9 &&
                        (sub.flags & MethodFlags::Constructor) ==
                            MethodFlags::None;
                    // § impCloneDeclRangeNoBind200, SITE 2 of 2 — the BODY
                    // LOCAL.  Same clone, same pre-late-binding state (grid
                    // arm A `loc1`, arm C `mloc`).
                    impCloneDeclRangeNoBind200 = pkgImportCloneEmit;
                    vts = makeTypespec(fmv);
                    impCloneDeclRangeNoBind200 = false;
                    tfItemLocalClassTs142 = savedTfi142;
                    tdCloneRefNoBind18 = savedNb18;
                    tfTypeScope = savedTfS3;
                    tfTypeScopeViewLocal = savedTfV3;
                    tfContext = false;
                }
                // A RANGED-typedef local (logic4 [1:0] out): the outer ts
                // carries an Elem ref -> a fresh NAMED typedef clone
                // (Typedef_alias -> shared), like the ranged-typedef ARG /
                // RETURN paths (74f18de).
                if (vts && vts->UhdmType() == UHDM::uhdmlogic_typespec &&
                    !((UHDM::logic_typespec*)vts)->Elem_typespec()) {
                    auto& vdt2 = fmv.getDeclaredType()->getType();
                    if (vdt2.kind == SymbolKind::PackedArrayType) {
                        auto& el2 = vdt2.as<PackedArrayType>().elementType;
                        if (auto it1 = typedefTs.find(&el2);
                            el2.kind == SymbolKind::TypeAlias &&
                            it1 != typedefTs.end() &&
                            it1->second->UhdmType() ==
                                UHDM::uhdmlogic_typespec) {
                            auto& elAl2 = el2.as<TypeAliasType>();
                            const syntax::SyntaxNode* tgt2 = nullptr;
                            if (auto asyn2 = elAl2.getSyntax())
                                if (asyn2->kind ==
                                    syntax::SyntaxKind::TypedefDeclaration)
                                    tgt2 = asyn2
                                               ->as<syntax::
                                                        TypedefDeclarationSyntax>()
                                               .type;
                            bypassTypedefShare = true;
                            auto* cl2 = makeTypespec(elAl2, tgt2);
                            bypassTypedefShare = false;
                            cl2->VpiName(elAl2.name);
                            auto* art2 = s.MakeRef_typespec();
                            art2->VpiFullName(std::string(elAl2.name));
                            art2->VpiParent(cl2);
                            art2->Actual_typespec(it1->second);
                            ((UHDM::logic_typespec*)cl2)->Typedef_alias(art2);
                            auto* ert2 = s.MakeRef_typespec();
                            ert2->VpiParent(vts);
                            ert2->Actual_typespec(cl2);
                            ((UHDM::logic_typespec*)vts)->Elem_typespec(ert2);
                            // The outer ts owns its [N:M] range (UINT bounds).
                            if (!((UHDM::logic_typespec*)vts)->Ranges()) {
                                auto pr2 = vdt2.as<PackedArrayType>().range;
                                auto* rng2 = s.MakeRange();
                                rng2->VpiParent(vts);
                                // Range/bounds anchor at the dim tokens.
                                std::vector<DimSpan> vSpans;
                                {
                                    SourceLocation vS = fmv.location;
                                    if (auto tsy2 = fmv.getDeclaredType()
                                                        ->getTypeSyntax())
                                        vS = tsy2->sourceRange().start();
                                    if (vS < fmv.location)
                                        vSpans = scanDimSpans(
                                            std::string(rawText(SourceRange(
                                                vS, fmv.location))),
                                            vS);
                                }
                                const DimSpan* vds =
                                    vSpans.empty() ? nullptr : &vSpans[0];
                                if (vds)
                                    setLoc(rng2, vds->range);
                                auto mkB3 = [&](int64_t vv,
                                                const SourceRange* bl)
                                    -> UHDM::expr* {
                                    auto* c3 = s.MakeConstant();
                                    std::string d3 = std::to_string(vv);
                                    c3->VpiDecompile(d3);
                                    c3->VpiSize(64);
                                    c3->VpiValue("UINT:" + d3);
                                    c3->VpiConstType(vpiUIntConst);
                                    c3->VpiParent(rng2);
                                    if (bl)
                                        setLoc(c3, *bl);
                                    return c3;
                                };
                                rng2->Left_expr(mkB3(
                                    pr2.left, vds ? &vds->left : nullptr));
                                rng2->Right_expr(mkB3(
                                    pr2.right, vds ? &vds->right : nullptr));
                                auto* rv2 = s.MakeRangeVec();
                                rv2->push_back(rng2);
                                ((UHDM::logic_typespec*)vts)->Ranges(rv2);
                            }
                        }
                    }
                }
                // § sharedTdRefNoRestamp9, SITE 4 of 4 — the SUBROUTINE-BODY
                // local.  A CLASS-NESTED typedef object is shared with its
                // owning class_defn's vpiTypedef listing and stays unscoped —
                // stamping it here would scope the whole typedef to the
                // referencing class (IOClassStruct).  The predicate lives in
                // ONE place now and every reference site asks it; what THIS
                // site gains is the PACKAGE arm (arm v4 d2_t: our stamp
                // re-pointed the package's ELABORATED listing entry at the def
                // twin).  It keeps the SHIPPED class-scope semantics — ANY
                // kind, `class_typespec` INCLUDED, unlike sites 1-3: narrowing
                // it here moved uvm83's v83_a12 `plain_td` from NONE to the def
                // package, so the shipped answer stays the answer.
                // § classPkgAliasKeepsStamp9v is INCLUDED here (it is neither
                // NotShared nor PkgOther): the pre-law `sharedClassTypedef9`
                // skipped the stamp for ANY class-scope shared typedef, alias
                // of a package typedef included, so this site keeps that.
                const SharedTd9 shLoc9 = sharedTypedefTsRef9(fmv, vts);
                const bool sharedClassTypedef9 =
                    shLoc9 != SharedTd9::NotShared &&
                    shLoc9 != SharedTd9::PkgOther;
                // `m` is the CLASS_DEFN for a method, and a class scope is not
                // a vpiInstance: an out-of-body method's body locals are
                // resolved in the home PACKAGE and carry it, an in-class
                // method's carry nothing. tsInst already encodes exactly that
                // (ApbSlave svunit_testsuite::report's pass_cnt/success_str).
                // § builtinClassLocalUnsupportedBeforeClassPhase115 — when the
                // law fires this `vts` is DISCARDED (the binding below takes a
                // freshly minted unsupported_typespec instead), and stamping a
                // possibly SHARED class_typespec on the way out would be a
                // visible side effect on an object this declaration no longer
                // owns.  Skipping the stamp keeps the change to the two fields
                // the law names.
                if (tsInst && stdBi115.empty() && !sharedClassTypedef9 &&
                    !foreignSharedTs(fmv, vts)) {
                    vts->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back(vts);
                }
                // A packed-array-of-enum local is a packed_array_var (range +
                // enum_var element), anchored at its name and NOT automatic.
                UHDM::variables* v = makeEnumArrayVar(vts, vfull, tf);
                bool isEnumArr = v != nullptr;
                // § classTdLocalVarKindFollowsCompileOrder10, SITE 1 of 2 —
                // the SUBROUTINE-BODY local.  A class-nested typedef whose
                // owning class Surelog has not compiled yet has no typespec
                // when the variable class is picked, so the declaration falls
                // back to a bare `class_var` (scoped spelling) or a bare
                // `ref_var` (bare spelling) while still binding the same
                // typespec.  See EmitHelpers.h for the law, its three
                // questions and the grid cell behind each one.
                //
                // THIS REPLACES the `onDemandClassTypedefs` PROXY, which asked
                // whether OUR OWN emission order had had to build the owner's
                // typedefs on demand.  That proxy is our order, not Surelog's:
                // it MISSED the SeqDriver head (we emit `uvm_resource_types`
                // before `uvm_resource_base`, so the typedef was already
                // registered and no on-demand build happened) and it OVER-FIRED
                // on the bare spelling (grid `g5` `v_inherited_bare`: golden
                // `ref_var`, the proxy's `class_var`).
                // § builtinClassLocalUnsupportedBeforeClassPhase115 — the KIND
                // half: `compileVariable`'s final arm (CompileType.cpp:421).
                // Ahead of § classTdLocalVarKindFollowsCompileOrder10 because
                // that law reasons about a class-nested TYPEDEF's compile
                // order, and this declaration names no typedef at all.
                if (!v && !stdBi115.empty())
                    v = s.MakeRef_var();
                // § blockLocalTdDeclIsRefVarUnsupported155, SITE 1 of 6 (the
                // KIND half) — the SUBROUTINE-BODY local.  A typedef declared
                // as a STATEMENT is registered in NO DesignComponent, so
                // `compileVariable` finds no `getDataType` and no class and
                // takes its final `ref_var` arm (CompileType.cpp:421-431).
                // src/EmitHelpers.h carries the law and the grid155 cell
                // behind each of its three questions.  Asked AFTER the
                // builtin-class arm so that older, separately measured law
                // keeps its own name (`process` / `mailbox` / `semaphore`),
                // and BEFORE r10sd10's, whose typedef lives in a CLASS and
                // can never be this one.
                const bool td155 = !v && stmtScopeTdDegrades155(fmv);
                if (td155)
                    v = s.MakeRef_var();
                if (!v)
                    switch (classTdLocalVarKind10(fmv)) {
                        case TdLocalVarKind10::ClassVar:
                            v = s.MakeClass_var();
                            break;
                        case TdLocalVarKind10::RefVar:
                            v = s.MakeRef_var();
                            break;
                        case TdLocalVarKind10::Resolved:
                            break;
                    }
                if (!v) {
                    const Type* lt9 = &fmv.getDeclaredType()->getType();
                    // A TF-ITEM body models an array local by its ELEMENT
                    // variable — the array_var arms above are BLOCK-item only
                    // (probes r10c4_p9/p10) — matching the element typespec
                    // makeTypespec already looks through the dims for.
                    while (!blockItems9) {
                        auto& ct9 = lt9->getCanonicalType();
                        if (ct9.kind == SymbolKind::FixedSizeUnpackedArrayType)
                            lt9 = &ct9.as<FixedSizeUnpackedArrayType>()
                                       .elementType;
                        else if (ct9.kind == SymbolKind::QueueType)
                            lt9 = &ct9.as<QueueType>().elementType;
                        else if (ct9.kind == SymbolKind::DynamicArrayType)
                            lt9 = &ct9.as<DynamicArrayType>().elementType;
                        // § assocLocalArrayVar40's TF-ITEM negative: the
                        // ASSOCIATIVE spelling is modelled by its element too
                        // (t57a's paren-less `function void iNoParen57; int
                        // npa[key57];` is an int_var in golden, and was a
                        // logic_var here because this drill stopped short of
                        // the assoc arm while makeTypespec did not).
                        else if (ct9.kind == SymbolKind::AssociativeArrayType)
                            lt9 = &ct9.as<AssociativeArrayType>().elementType;
                        else
                            break;
                    }
                    v = makeReturnVar(s, *lt9);
                    // § atomVarSignedWritten68, site 4 of 7 — a subroutine BODY
                    // LOCAL (arm a1 t_loc / t_loci / t_tsk / t_mfloc, arm a5
                    // 22:13 ex_loc).  GATED ON `lt9 == decl9`: when the loop
                    // above DESCENDED into an array element, the object is an
                    // element var and its signedness is
                    // § arrayVarSignedWritten8 / § arrayElemTsSignedParented9
                    // territory, measured there and not here.
                    if (lt9 == &fmv.getDeclaredType()->getType())
                        clearNamedAtomSigned68(v, *lt9);
                }
                v->VpiName(fmv.name);
                v->VpiFullName(vfull);
                v->VpiParent(tf);
                bool blockLocal = isEnumArr || namedTypeLocal;
                // Initialized locals anchor at the name (and are later
                // re-parented at their init assignment, without the
                // automatic flag).
                if (blockLocal || hasInit || blockItems9) {
                    // BLOCK-item locals anchor at the NAME token; the tf_item
                    // form keeps the declared-type span.
                    setLoc(v, nameSpan(fmv.location, fmv.name));
                }
                else if (auto dt = fmv.getDeclaredType()) {
                    if (auto tsyn2 = dt->getTypeSyntax()) {
                        auto sr = tsyn2->sourceRange();
                        // An IMPLICIT type carrying a signing keyword
                        // (function signed [3:0] f) anchors at the signing
                        // token alone, exactly like its typespec — Surelog.
                        if (tsyn2->kind == syntax::SyntaxKind::ImplicitType) {
                            auto& its2 =
                                tsyn2->as<syntax::ImplicitTypeSyntax>();
                            if (its2.signing.valid())
                                sr = its2.signing.range();
                        }
                        if (sr.start() != SourceLocation::NoLocation)
                            setLoc(v, sr);
                    }
                }
                // A packed-array-of-VECTOR local carries the ARRAY range
                // (dim-token locs) and a bare logic_var element (Surelog).
                if (v->UhdmType() == UHDM::uhdmpacked_array_var &&
                    !((UHDM::packed_array_var*)v)->Ranges()) {
                    auto& lct9 =
                        fmv.getDeclaredType()->getType().getCanonicalType();
                    if (lct9.kind == SymbolKind::PackedArrayType) {
                        auto pr9 = lct9.as<PackedArrayType>().range;
                        SourceLocation tS9 = fmv.location;
                        if (auto tsyn9 = fmv.getDeclaredType()->getTypeSyntax())
                            tS9 = tsyn9->sourceRange().start();
                        std::vector<DimSpan> spans9;
                        if (tS9 < fmv.location)
                            spans9 = scanDimSpans(
                                std::string(
                                    rawText(SourceRange(tS9, fmv.location))),
                                tS9);
                        auto* rng9 = s.MakeRange();
                        rng9->VpiParent(v);
                        const DimSpan* ds9 =
                            spans9.empty() ? nullptr : &spans9[0];
                        if (ds9)
                            setLoc(rng9, ds9->range);
                        auto mkL9 = [&](int32_t bv,
                                        const SourceRange* bl) -> UHDM::expr* {
                            auto* c9 = s.MakeConstant();
                            c9->VpiDecompile(std::to_string(bv));
                            c9->VpiSize(64);
                            c9->VpiValue("UINT:" + std::to_string(bv));
                            c9->VpiConstType(vpiUIntConst);
                            c9->VpiParent(rng9);
                            if (bl)
                                setLoc(c9, *bl);
                            return c9;
                        };
                        rng9->Left_expr(mkL9(pr9.left,
                                             ds9 ? &ds9->left : nullptr));
                        rng9->Right_expr(mkL9(pr9.right,
                                              ds9 ? &ds9->right : nullptr));
                        auto* rvec9 = s.MakeRangeVec();
                        rvec9->push_back(rng9);
                        ((UHDM::packed_array_var*)v)->Ranges(rvec9);
                        auto* ev9 = s.MakeLogic_var();
                        ev9->VpiParent(v);
                        ev9->VpiFullName(vfull);
                        auto* elems9 = s.MakeAnyVec();
                        elems9->push_back(ev9);
                        ((UHDM::packed_array_var*)v)->Elements(elems9);
                    }
                }
                auto* vrt = s.MakeRef_typespec();
                vrt->VpiFullName(vfull);
                vrt->VpiParent(v);
                v->Typespec(vrt);
                // § classScopedTdDeclTsUnsupported11, SITE 1 of 5 — the
                // SUBROUTINE-BODY local.  `Owner::td` never reaches a class
                // through Surelog's compileTypespec, so the declaration keeps
                // the catch-all placeholder unless `td` CLAIMED its target's
                // typespec slot; EmitHelpers.h carries the law and the grid11
                // cell behind each of its four questions.  Applied to the
                // BINDING and nothing else: the variable's own class, span and
                // parent are § classTdLocalVarKindFollowsCompileOrder10's and
                // are already golden-exact.
                // § oobClassTypeParamLocalUnsupported105 — see the law
                // and its whole grid at the lambda above.  Only the KIND, the
                // NAME and the INSTANCE move; the variable's own class, span
                // and parent stay § classTdLocalVarKindFollowsCompileOrder10's.
                // FENCED to the SCALAR spelling: an array local's placeholder
                // lives on the ELEMENT `ref_var`, which is not this site.
                std::string_view oobTpLoc105;
                if (oob)
                    if (auto* ldt105 = fmv.getDeclaredType()) {
                        auto& lct105 =
                            ldt105->getType().getCanonicalType();
                        bool arr105 =
                            lct105.kind ==
                                SymbolKind::FixedSizeUnpackedArrayType ||
                            lct105.kind == SymbolKind::QueueType ||
                            lct105.kind == SymbolKind::DynamicArrayType ||
                            lct105.kind == SymbolKind::AssociativeArrayType;
                        if (!arr105)
                            if (auto* lsyn105 = ldt105->getTypeSyntax()) {
                                oobTpLoc105 =
                                    oobClassTypeParamName31(lsyn105);
                                if (!oobTpLoc105.empty() &&
                                    oobTpLocalShadowedByTd105(oobTpLoc105))
                                    oobTpLoc105 = {};
                            }
                    }
                // § builtinClassLocalUnsupportedBeforeClassPhase115 — the
                // TYPESPEC half.  Only the KIND, the NAME and the INSTANCE
                // move; the variable's own span, parent, full name and
                // vpiAutomatic stay exactly where the surrounding laws put
                // them.  The instance is the one every other typespec of this
                // subroutine takes (`tsInst` — the declaring PACKAGE for a
                // package function and for an out-of-body method, NOTHING for
                // a module), and an explicit-import COPY keeps the HOME
                // package and joins the def/elab re-point list, exactly as the
                // discarded class_typespec did three dozen lines up.
                if (!stdBi115.empty()) {
                    auto* uts115 = s.MakeUnsupported_typespec();
                    uts115->VpiName(stdBi115);
                    setLoc(uts115,
                           fmv.getDeclaredType()->getTypeSyntax()->sourceRange());
                    if (auto* ui115 = importCopyTsInst ? importCopyTsInst
                                                       : tsInst)
                        uts115->Instance(ui115);
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back(uts115);
                    vrt->Actual_typespec(uts115);
                }
                else if (!oobTpLoc105.empty()) {
                    auto* uts105 = s.MakeUnsupported_typespec();
                    uts105->VpiName(oobTpLoc105);
                    setLoc(uts105,
                           fmv.getDeclaredType()->getTypeSyntax()->sourceRange());
                    // The package the CLASS is DECLARED in, exactly as
                    // § 31's formals take it (`oobDeclPkg31`), so an
                    // IMPORTER's copy still reads `@uvm_pkg` and a
                    // `$unit`/module home reads NOTHING.
                    if (auto* ui105 = oobDeclPkg31 ? oobDeclPkg31 : tsInst)
                        uts105->Instance(ui105);
                    vrt->Actual_typespec(uts105);
                }
                else if (auto* uts155 =
                             td155 ? makeStmtScopeTdUnsupTs155(fmv) : nullptr) {
                    // § blockLocalTdDeclIsRefVarUnsupported155, SITE 1 of 6
                    // (the TYPESPEC half).  Only the KIND, the NAME and the
                    // SPAN move; the variable's own name, full name, parent,
                    // span and vpiAutomatic stay exactly where the surrounding
                    // laws put them (measured field by field on grid155's
                    // `vInt` / `vStruct`: golden's record carries vpiParent,
                    // vpiTypespec, vpiName, vpiFullName AND NOTHING ELSE).
                    // The instance is the one every other typespec of this
                    // subroutine takes — § scopedTdUnsupTsHomePkgInstance83's
                    // `tsInst`: the home PACKAGE for a package free function
                    // and for an out-of-body method (grid155 `flockVal` /
                    // `perchVal` read `@Hive155`), NOTHING for an in-body one
                    // or a module (`broodVal`, `wingVal`, `initialVal`).
                    if (tsInst) {
                        uts155->Instance(importCopyTsInst ? importCopyTsInst
                                                          : tsInst);
                        if (importCopyTsInst && importCopyTsCollect)
                            importCopyTsCollect->push_back(uts155);
                    }
                    vrt->Actual_typespec(uts155);
                }
                else if (auto* uts11 = makeScopedTdUnsupTs11(fmv)) {
                    // § scopedTdUnsupTsHomePkgInstance83 — THE WALL.  This
                    // placeholder takes the SAME `vpiInstance` the RESOLVED
                    // typespec of this very declaration takes two dozen lines up:
                    // the HOME PACKAGE for an out-of-body class method (`tsInst` ==
                    // `oobHomePkg`) and NOTHING for an in-body one, where `tsInst`
                    // is null and this stamp is inert.  The substitution above
                    // THREW THE STAMP AWAY, and `typespec::Compare` reads
                    // `Instance` — so the discarded pointer was the official head
                    // of all five UVM NE rows (`uvm_sequencer_base.svh:1434:3`
                    // `uvm_resource_types::rsrc_q_t rq`, reached through
                    // `unsupported_typespec::Instance` from golden's ELABORATED
                    // `package uvm_pkg`, which is why the head PRINTED as that
                    // package with `RHS: <null>`: SafeCompare(lhs, nullptr) sets
                    // m_failedLhs to the TARGET and leaves m_failedRhs unset).
                    //
                    // WHY A DUMP READING MISSED IT, EXACTLY.  The visitor prints
                    // a REFERENCED object as ONE identity line and none of its
                    // own fields; only a decompile ROOT gets its fields printed.
                    // Inside the old 1,450,011-line head, this very placeholder
                    // appears as
                    //   \_unsupported_typespec: (uvm_resource_types::rsrc_q_t),
                    //     id:25354, line:1434:3, endln:1434:23
                    // and nothing else — which is literally the "prints one line"
                    // the earlier note here cited when it concluded the object
                    // "carries a vpiName and a span and NOTHING else ... no
                    // vpiInstance".  Decompiled AS A ROOT the same object prints
                    // `|vpiInstance:` and the package under it (measured on
                    // golden #25349/#25354).  So the reading was of the LEAF form,
                    // and the leaf form cannot show this field.
                    //
                    // MEASURED, not generalised: over ALL 36 `Owner::td`-named
                    // placeholders in SimpleUVM's golden, exactly THREE span-groups
                    // carry an instance (496:12, 1260:4, 1434:3) and 33 carry none
                    // — and the three are precisely the OUT-OF-BODY method
                    // declarations (`uvm_reg_block::find_blocks`,
                    // `uvm_sequencer_base::start_phase_sequence`), while every
                    // in-body one (`uvm_resource_pool::set` at 717:5,
                    // `lookup_name` at 868:12, ...) is uninstanced on BOTH sides
                    // already.  `tsInst` IS that distinguisher, so the gate is the
                    // pointer itself and no new predicate is introduced.
                    if (tsInst) {
                        uts11->Instance(importCopyTsInst ? importCopyTsInst
                                                         : tsInst);
                        if (importCopyTsInst && importCopyTsCollect)
                            importCopyTsCollect->push_back(uts11);
                    }
                    vrt->Actual_typespec(uts11);
                }
                // § classScopedTdImportCopyLocalUnsupported198, SITE 1 of 2 —
                // the SUBROUTINE-BODY local.  src/EmitHelpers.h carries the
                // law, the Surelog decode and the grid198 cell behind every
                // one of its clauses.  Only the KIND, the NAME and the
                // INSTANCE move; the variable's own class, span, parent, full
                // name and vpiAutomatic stay exactly where the surrounding
                // laws put them (golden's clone cell is the `ref_var` /
                // `class_var` we already emit, arm A/B/C/D every cell).
                //
                // LAST in the chain on purpose: § 115's builtin class, § 105's
                // out-of-body class TYPE PARAMETER, § 155's statement-scope
                // typedef and § 11's claim-losing `Owner::td` each own their
                // cells in EVERY view, home included, and this law owns only
                // what is left over inside a CLONE.  The instance is the one
                // every other typespec of a cloned body takes — the HOME
                // package, re-pointed at its ELABORATED view by
                // `importCopyTsFixups` once both views exist, the same
                // hand-off § 36 gives the FORMAL half.
                //
                // § clsScopedTdLocalCloneIsClassMethodOnly198v (VERIFIER FIX).
                // `importCopyTsInst` alone is THREE clone drivers, not one:
                // ParamEmit.cpp:20962 and :21044 clone an imported package
                // FREE SUBROUTINE, and only :23646 clones an out-of-body CLASS
                // METHOD — which is the construct this law was decoded on
                // ("a class method DEFINED OUT OF BODY is a package-scope
                // item").  `pkgClassTfClone` is set by that third driver and
                // by nothing the free-subroutine halves do, so
                // `importCopyTsInst && pkgClassTfClone` is exactly the
                // imported class-method clone (ParamEmit.cpp:23244's own-class
                // pass sets `pkgClassTfClone` with `importCopyTsInst` NULL, so
                // the conjunction excludes it too).
                //
                // MEASURED, one real Surelog golden, arm `v198_5_imports`
                // (`AditV5::clsStV5 scopedV5;` written in the package FREE
                // function `freeV5`, cloned by `import quarryV5::freeV5` and
                // by two wildcard importers): in the ELABORATED view golden
                // keeps the copies that land under a `class_defn` or a
                // `module_inst` RESOLVED (`struct_typespec clsStV5`, no
                // instance) and degrades only the ones directly under the
                // importing PACKAGE — and OUR free-subroutine clone hands the
                // same typespec to both, so firing here wrote
                // `unsupported_typespec` into NINE cells that the pristine
                // binary had RIGHT (AWAY-GOLDEN 9).  The class-method clone
                // has no such coupling: its package-listing copy and its
                // class/module copies are separate objects from separate
                // drivers, and the same arm scores that half TO-GOLDEN with
                // AWAY-GOLDEN 0 (`clsStV5 tfClsV5` / `blkClsV5`).  The free
                // subroutine's own degradation is left as this pass's residue,
                // not guessed at.
                else if (std::string nm198 =
                             (importCopyTsInst && pkgClassTfClone)
                                 ? clsScopedTdLocalName198(fmv)
                                 : std::string{};
                         !nm198.empty()) {
                    auto* uts198 = s.MakeUnsupported_typespec();
                    uts198->VpiName(nm198);
                    if (auto* lsyn198 = fmv.getDeclaredType()->getTypeSyntax())
                        setLoc(uts198, lsyn198->sourceRange());
                    uts198->Instance(importCopyTsInst);
                    if (importCopyTsCollect)
                        importCopyTsCollect->push_back(uts198);
                    vrt->Actual_typespec(uts198);
                }
                // § pkgClassTdImportCopyLocalUnsupported202, SITE 1 of 2 — the
                // SUBROUTINE-BODY local.  src/EmitHelpers.h carries the law,
                // its Surelog decode and the arm A cell behind every clause.
                // The SAME gate as § 198's arm above (`importCopyTsInst &&
                // pkgClassTfClone` = the imported out-of-body CLASS METHOD
                // clone, § clsScopedTdLocalCloneIsClassMethodOnly198v), the
                // same instance (the HOME package, re-pointed at its
                // ELABORATED view by `importCopyTsFixups`), and the same
                // narrow write: only the KIND, the NAME and the INSTANCE move.
                // It sits AFTER § 198 and the two predicates are DISJOINT by
                // construction — § 198 requires the typedef's parent scope to
                // be a ClassType/GenericClassDef, this one requires a Package.
                else if (std::string nm202 =
                             (importCopyTsInst && pkgClassTfClone)
                                 ? pkgClassTdLocalName202(fmv)
                                 : std::string{};
                         !nm202.empty()) {
                    auto* uts202 = s.MakeUnsupported_typespec();
                    uts202->VpiName(nm202);
                    if (auto* lsyn202 = fmv.getDeclaredType()->getTypeSyntax())
                        setLoc(uts202, lsyn202->sourceRange());
                    uts202->Instance(importCopyTsInst);
                    if (importCopyTsCollect)
                        importCopyTsCollect->push_back(uts202);
                    vrt->Actual_typespec(uts202);
                }
                else {
                    vrt->Actual_typespec(vts);
                    deferForeignTopTs(fmv, vrt, vts);
                }
                const WrittenLife139 wlife139 = writtenLife139(fmv);
                if (!blockLocal && !blockItems9) {
                    // § tfItemLocalAutomaticIsNotWrittenStatic139 — the
                    // TF-ITEM production, Surelog CompileStmt.cpp:1690
                    // `var->VpiAutomatic(!is_static)`.  An INITIALISER is not
                    // part of that rule (it used to gate this arm, so every
                    // initialised tf-item local read 0 against golden's 1 —
                    // MiniAmiq's `uvm_cmdline_processor clp = ...` at
                    // uvm_component.svh:3383), and neither is a written
                    // `static`, which used to be ignored here (the head:
                    // `static string values[$]` at :3380 read 1 against
                    // golden's absent flag).
                    if (wlife139 != WrittenLife139::Static)
                        v->VpiAutomatic(true);
                }
                // § r10fsv3.  A BLOCK-ITEM body local written with the
                // `automatic` KEYWORD carries vpiAutomatic even in the form
                // that otherwise drops it — the flag follows the written
                // lifetime, not the position (golden FuncStructVal:
                // is_inside_cacheable_regions' `automatic logic [..] pass` has
                // it, its two initializer-less siblings at 437/447 do not).
                else if (wlife139 == WrittenLife139::Automatic)
                    v->VpiAutomatic(true);
                if (blockLocal)
                    fnBlockLocalPav.push_back(v);
                funcMap[&fmv] = v;
                fvars->push_back(v);
            }
            fvarsAll71 = fvars;
            // § ctorBodyLocalsNotOnFunc71 — A CLASS CONSTRUCTOR carries NO
            // vpiVariables vector.  Its body locals are listed on the BODY
            // SCOPE alone, which already lists them identically (measured:
            // SimpleUVM's `uvm_objection::new` begin block is byte-identical
            // to golden's, all four entries), so nothing is orphaned; and
            // where a constructor has no body scope at all, golden keeps only
            // the ref_obj USE and no variable object (arm a1 `c_auto::new`).
            // EVERY OTHER SUBROUTINE IS UNTOUCHED — golden puts variables on
            // 665 of SimpleUVM's non-constructor subroutines and we already
            // matched all 665 before this pass.
            //
            // CONSTRUCTOR-NESS IS SLANG'S OWN FLAG, NOT THE NAME.  A NAME test
            // (`sub.name == "new"`) OVER-FIRES: an ESCAPED IDENTIFIER is exempt
            // from keyword rules, so `function int \new (int a);` is an
            // ORDINARY class method that slang also names "new", and golden
            // KEEPS its body local on the function (verifier arm a4_escnew:
            // golden 1, base 1, name-gate 0 — a regression the corpora cannot
            // see because no corpus source uses `\new`).  `MethodFlags::
            // Constructor` is set on the in-body constructor AND on the
            // out-of-body DEFINITION, so all THREE prints of arm a1's
            // `c_oob::new` are covered — including the package-parented one,
            // which was that arm's own cmp head.
            bool ctorNoVars71 =
                (sub.flags & MethodFlags::Constructor) != MethodFlags::None;
            // § qualLifetimeStubListsNoBodyLocals141 — the LAST vector the
            // pass-46 stub was still carrying.  When a class method is written
            // with a QUALIFIER *and* a written LIFETIME,
            // `CompileClass::compile_class_method_` hands `compileFunction`
            // the unadvanced qualifier node, so `Child()` of it is the
            // LIFETIME node instead of the `Function_body_declaration`
            // (CompileStmt.cpp:1844's unwrap `if` never fires) and EVERY node
            // derived from there is invalid: the name, the `Tf_port_list`,
            // and the `Statement_or_null` the body's declarations are
            // compiled from.  § qualifiedLifetimeMethodLosesNamePortsBody46
            // already drops the name (:3104), the io_decls (:4938) and the
            // body (:6125/:6240) for exactly this predicate; the BODY LOCALS
            // are the same casualty and were the only thing left.
            //
            // MEASURED on arm A (g141_a_vars.sv), eleven single-method classes
            // in both views: golden's stub prints vpiParent, vpiFullName,
            // vpiMethod, vpiVisibility, [vpiVirtual] and — for a FUNCTION —
            // vpiReturn, and NOTHING else, whether the locals are
            // initialised (ca1/ca3/ca4/ca5), bare (ca8), inside a named begin
            // block (ca7) or absent (ca2), and whether the subroutine is a
            // function or a TASK (ca6).  The three controls that write only
            // ONE of the two features (cb1 lifetime-only, cb2 qualifier-only,
            // cb3 neither) keep their locals on BOTH sides and are untouched.
            //
            // Corpus reach is the SAME single object pass 46 named:
            // `uvm_pkg.sv:75228 local function automatic int unsigned ceil`
            // in `uvm_reg_map`, whose `int r`/`int r0` are BuildUVMPkg's whole
            // remaining head (`scope::Compare` reaches Variables at
            // generated/src/scope.cpp:340, well before Return/Io_decls/Stmt,
            // and golden's vector is null — hence `LHS: <null>` with the
            // FUNCTION as RHS, the vector overload's lhs-null branch).
            if (!fvars->empty() && !ctorNoVars71 && !qualLifetime46)
                tf->Variables(fvars);
        }

        // Register before the body so recursive calls bind this function.
        // A wildcard-import CLONE takes the registration over for the rest of
        // the importing package's emission: every call written THERE binds the
        // importer's own copy (probe r10evfn 2 — p2::g's body calls p2::f, not
        // p1::f). emitPackage restores the home entry when the view finishes.
        if (sharedScope || reusedShell || !subMap.count(&sub) ||
            pkgImportCloneEmit)
            subMap[&sub] = si;
        // The package's ELABORATED pass builds the twin whose typespecs are
        // folded; remember it so importing modules can list and bind it.
        // A wildcard-import CLONE is not that twin — the home package's own
        // object is, and the clone must not displace it.
        if (pkgScope && !classScope && pkgTopEmit && !pkgImportCloneEmit)
            pkgElabSubTf[&sub] = tf;
        // An ELAB instance's call site sees its OWN per-instance
        // SubroutineSymbol, but the elab view lists (and Surelog binds) the
        // DEF function object: remember the def-emitted subroutine keyed by
        // (definition, name) so such call sites can reach it.
        if (body.asSymbol().kind == SymbolKind::InstanceBody)
            defSubByName.emplace(
                std::make_pair((const Symbol*)&body.asSymbol()
                                   .as<InstanceBodySymbol>()
                                   .getDefinition(),
                               std::string(sub.name)),
                (const Symbol*)&sub);

        // A `$bits(<formal>)` inside a LOCAL's type binds that formal's
        // io_decl (Surelog). The deferred module-net drain never reaches it —
        // it walks up to an InstanceBody and binds DEF nets, while a
        // subroutine's formals are io_decls (PackFunc's
        // `reg [$bits(a)-1:0] a_vec`). Both exist by now, so bind by name
        // against this function's own io_decls.
        if (!ios->empty() && fvarsAll71 && !fvarsAll71->empty())
            for (auto* fv0 : *fvarsAll71) {
                auto* frt0 = fv0->Typespec();
                auto* fts0 = frt0 ? frt0->Actual_typespec() : nullptr;
                if (!fts0 || fts0->UhdmType() != UHDM::uhdmlogic_typespec)
                    continue;
                auto* rgs0 = ((UHDM::logic_typespec*)fts0)->Ranges();
                if (!rgs0)
                    continue;
                std::function<void(UHDM::any*)> bindIo = [&](UHDM::any* n0) {
                    if (!n0)
                        return;
                    if (n0->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r2 = (UHDM::ref_obj*)n0;
                        if (r2->Actual_group())
                            return;
                        for (auto* io0 : *ios)
                            if (io0->VpiName() == r2->VpiName()) {
                                r2->Actual_group(io0);
                                break;
                            }
                    }
                    else if (n0->UhdmType() == UHDM::uhdmoperation) {
                        if (auto* ops2 = ((UHDM::operation*)n0)->Operands())
                            for (auto* o2 : *ops2)
                                bindIo(o2);
                    }
                    else if (n0->UhdmType() == UHDM::uhdmsys_func_call) {
                        if (auto* ar2 =
                                ((UHDM::sys_func_call*)n0)->Tf_call_args())
                            for (auto* o2 : *ar2)
                                bindIo(o2);
                    }
                };
                for (auto* rg0 : *rgs0) {
                    bindIo(rg0->Left_expr());
                    bindIo(rg0->Right_expr());
                }
            }

        // Body: refs to the return value bind a local var that Surelog only
        // creates in the write phase; record them for late patching.
        // § retVarTdViewFold19 — the fold state of a BARE package-typedef
        // return is view-dependent (§ pkgTdRangeViewFold18) and the drain runs
        // after every view is emitted, so decide it HERE while
        // curPkgEmitSym/pkgEmitTopView/pkgClassTfClone still describe the body
        // being walked.
        bool tdOwnDef19 = true;
        if (auto* rta19 = pkgHomedTdAlias18(sub.getReturnType()))
            tdOwnDef19 = pkgTdOwnDefView(*rta19);
        pendingFuncRet.push_back(
            {&sub, fullName, {}, pkgScope ? (UHDM::instance*)m : nullptr,
             pkgImportCloneEmit ? pkgImportCloneRetVar : nullptr,
             pkgImportCloneEmit ? pkgImportCloneHomePkg : nullptr, tdOwnDef19,
             tf, classScope, pkgImportCloneEmit, tsInst});
        size_t pfIdx = pendingFuncRet.size() - 1;
        auto* savedSym = funcRetSym;
        auto* savedRefs = funcRetRefs;
        funcRetSym = sub.returnValVar;
        funcRetRefs = &pendingFuncRet[pfIdx].refs;
        // § retNameSelBindsHomeReturnInCloneOnly171 — the collector is armed
        // for a WILDCARD-IMPORT CLONE body and for nothing else.  The gate is
        // the pointer itself, so every home-package and class body walks with
        // it null and cannot push a single object: that is what makes the
        // four mint sites incapable of moving a cell outside the clone views.
        // Its lifetime is exactly `funcRetRefs`' — same entry, same save and
        // restore around the body walk.
        auto* savedSelRefs171 = funcRetSelRefs171;
        funcRetSelRefs171 =
            pkgImportCloneEmit ? &pendingFuncRet[pfIdx].selRefs171 : nullptr;
        auto* savedTf = currentTf;
        currentTf = tf;
        auto* savedSubSym = currentSubSym;
        currentSubSym = &sub;
        // The BODY is compiled with the subroutine's own scope on the lookup
        // path, so a reference there resolves the parameter normally — the
        // declaration-type rule ends here (arm a2/n5: the same `p5` binds the
        // net in the reg range and the PARAMETER one line down).
        fnDeclTsSub = nullptr;
        bool selOwner = beginSelTrack();
        bool savedCMNB = classMethodNoBind;
        // ...but only for a method written INSIDE the class. An OUT-OF-BODY
        // definition is compiled in the home PACKAGE's scope, where Surelog
        // has a full symbol table: its refs bind their io_decl / body local /
        // enum const everywhere, exactly like a package function's. Measured
        // on a purpose-built golden holding both spellings of one method
        // (r10apb2 repro 5) — the in-class twin's identical body binds
        // nothing outside the if condition.
        classMethodNoBind = classScope && !oob;
        // LAW C's stable half (see UhdmExporter.h): unlike classMethodNoBind
        // these are NOT toggled inside conditions — a call's binding does not
        // depend on where in the body it sits.
        bool savedSCS9 = curSubClassScope9;
        bool savedSOB9 = curSubOob9;
        curSubClassScope9 = classScope;
        curSubOob9 = oob;
        // A `$unit`-scope subroutine's body binds NOTHING — not its formals'
        // io_decls, not its block locals, not its for-loop iterators.  The
        // compilation unit is compiled before any instance exists and
        // Surelog never revisits it with a symbol table, the same shape
        // classMethodNoBind describes for an in-class method.  Scr1SvTests
        // measures it exactly: of the 73 references inside the design-level
        // `scr1_lead_zeros_cnt_2` / `scr1_lead_zeros_cnt_32` bodies (from
        // `scr1_search_ms1.svh`, included at $unit scope), golden binds ZERO
        // and we bound 35 — while the byte-identical `scr1_search_one_2`
        // body compiled inside module scr1_ipic binds its `din` io_decl.
        bool savedUSNB9 = unitSubNoBind9;
        if (auto* usc9 = sub.getParentScope())
            unitSubNoBind9 =
                usc9->asSymbol().kind == SymbolKind::CompilationUnit;
        bool savedPDV9 = pkgDefViewBody9;
        // The un-elaborated package view: its own functions during the def
        // pass, and the class-method clones emitPackageClassMethodClones
        // appends to it (see pkgDefViewBody9).
        pkgDefViewBody9 =
            cloneMode || (pkgScope && !classScope && !pkgTopEmit);
        // § negLitPkgRetFold86 — the ELABORATED-package compile's own window
        // (see UhdmExporter.h).  The HOME test is a PACKAGE-scope subroutine:
        // the package's own function/task, or an out-of-body class-method
        // DEFINITION whose class is declared in a package.  The VIEW test
        // excludes only the home package's DEF twin — an IMPORT CLONE keeps
        // the fold in both of the importer's views, because golden's clone is
        // a copy of the elaborated object (arm a4).
        bool savedPRF86 = pkgRetFoldHome86;
        bool savedPKH17 = curSubPkgHome17;
        {
            bool homePkg86 = pkgScope && !classScope;
            if (!homePkg86 && classScope && oob)
                if (auto* hp86 = ((UHDM::class_defn*)m)->VpiParent())
                    homePkg86 = hp86->UhdmType() == UHDM::uhdmpackage;
            pkgRetFoldHome86 =
                homePkg86 && !(pkgDefViewBody9 && !pkgImportCloneEmit);
            // § foreachElabLoopVarAnyKindBinds17's home half (see
            // UhdmExporter.h) — the SAME home test, without the view clause:
            // the def twin lists an unresolved `ref_var` loop variable and so
            // registers nothing anyway.
            curSubPkgHome17 = homePkg86;
        }
        auto* savedBodyStmt9 = tfBodyStmt9;
        bool savedBodyIo9 = tfBodyTfItems9;
        auto savedBodyPa9 = std::move(tfBodyPa9);
        auto savedBodyPaAnch9 = std::move(tfBodyPaAnchor9);
        tfBodyStmt9 = (const void*)&sub.getBody();
        tfBodyTfItems9 = !blockItems9;
        tfBodyPa9 = taskBodyPa9;
        tfBodyPaAnchor9 = taskBodyPaAnchor9;
        bool savedPaUsed9 = tfBodyPaUsed9;
        tfBodyPaUsed9 = false;
        // § stmtScopeTdListedOnEnclosingScope157 — the SITE 2 / SITE 3
        // handshake (see UhdmExporter.h).  Saved and restored with the other
        // per-body flags so a NESTED subroutine emission cannot answer for its
        // caller.
        bool savedTdListed157 = tfBodyTdListed157;
        tfBodyTdListed157 = false;
        // § constructorBodyElementShift27 — a CLASS CONSTRUCTOR's body is
        // compiled by compileClassConstructorDeclaration, not by
        // compileFunction, and the two laws that separates out live in
        // StmtEmit's statement-list arm.  `NoPorts` is the load-bearing half:
        // with no tf_port_list the routine's `fC->Child(nodeId)` is the first
        // BODY element, and the statement walk starts one element late.
        bool savedCtor27 = tfBodyCtor27;
        bool savedCtorNP27 = tfBodyCtorNoPorts27;
        tfBodyCtor27 =
            (sub.flags & MethodFlags::Constructor) != MethodFlags::None;
        tfBodyCtorNoPorts27 = tfBodyCtor27 && sub.getArguments().empty();
        // § stmtScopeTdListedOnEnclosingScope157 — SITE 3 runs AFTER both
        // `tfBodyTfItems9` and `tfBodyCtor27` have been restored to the
        // ENCLOSING subroutine's values, so its two gates are captured here,
        // while they still describe THIS body.
        const bool tdTfItems157 = tfBodyTfItems9;
        const bool tdCtor157 = tfBodyCtor27;
        // § qualifiedCtorLosesPortListAndBody27: the routine never reaches a
        // statement at all when a qualifier displaced its anchor.
        // § qualifiedLifetimeMethodLosesNamePortsBody46: same, one node further
        // along (a written lifetime behind a class-item qualifier).
        auto* body = (qualCtor27 || qualLifetime46)
                         ? nullptr
                         : emitStmt(sub.getBody(), tf, fullName, funcMap);
        // A constructor body that is one bare `super.new(...)` never reaches
        // the statement-list arm.  Golden emits NOTHING for it: with no
        // tf_port_list the super.new IS the mistaken port list, so the
        // statement walk starts past it and counts zero (t37b c_np_s_0,
        // uvm_table_printer::new / every empty uvm_*_phase::new).
        if (tfBodyCtorNoPorts27 && body &&
            sub.getBody().kind != StatementKind::List &&
            isSuperNewStmt27(sub.getBody()))
            body = nullptr;
        // § thisSuperNewAssignNoStmt3 — CALL SITE 5 of 5: a body slang did NOT
        // wrap in a StatementList reaches emitStmt's ExpressionStatement arm
        // directly, so the three list call sites never see it; golden gives such
        // a subroutine NO vpiStmt (arms a1 m4/m8/m9, a2 n3/n4/n5/n8, a3 p1/p3).
        // THE CONSTRUCTOR IS EXCLUDED and the exclusion is the gate that makes
        // this law match golden rather than exceed it: a3 p2 and a2 `new` are a
        // constructor whose WHOLE body is the assignment and golden KEEPS an
        // (Lhs-less, Rhs-less) assignment there.  `tfBodyCtor27` is still live
        // at this point — it is restored on the next line — so it is the
        // constructor test, matching the `super.new` drop just above.
        if (body && !tfBodyCtor27 &&
            sub.getBody().kind != StatementKind::List &&
            thisSuperNewAssignNoStmt3(sub.getBody()))
            body = nullptr;
        tfBodyCtor27 = savedCtor27;
        tfBodyCtorNoPorts27 = savedCtorNP27;
        // § pkgCloneHierBind9 — record this body's own locals+formals by NAME
        // when it is a WILDCARD-IMPORT package CLONE.  Surelog re-resolves a
        // clone's dotted references against the importing package's symbol
        // table, so the BASE of every hier_path and the PREFIX of every
        // method_func_call binds there while the home package's identical
        // body leaves them null (census r10uvm9e on SeqDriver: of golden's
        // i0 hier_path element refs, adpcm_pkg -- the `package adpcm_pkg;
        // import uvm_pkg::*;` clone -- has 3544 SET and uvm_pkg 0, and the
        // same split holds for method_func_call prefixes, 1016 vs 0; our
        // clone matched the HOME view everywhere).  The bind targets are
        // subroutine-LOCAL objects only: `this` and class PROPERTIES stay
        // null in golden's clone too (1254 of the 1256 remaining nulls).
        // Applied in the deferred pass so the hier_paths built by all ~15
        // ExprEmit shapes are covered from one place.
        if (pkgImportCloneEmit && tf) {
            // § importCloneBareTdAlias16 — the clone bodies are also the ones
            // whose package-typedef alias chain stays BARE all the way down.
            pkgImportCloneTfs16.insert(tf);
            // § cloneStmtHomeVarRef17 — the home subroutine this clone was
            // re-emitted from (emitTaskFuncs is called with onlySub = the
            // home symbol, so `sub` IS it).
            pkgCloneHomeSub17[tf] = (const Symbol*)&sub;
            std::map<std::string, UHDM::any*> lm9;
            for (auto& [sy9, ob9] : funcMap) {
                if (!sy9 || !ob9 || sy9->name.empty())
                    continue;
                bool local9 = false;
                for (auto* sc9 = sy9->getParentScope(); sc9;
                     sc9 = sc9->asSymbol().getParentScope())
                    if (&sc9->asSymbol() == (const Symbol*)&sub) {
                        local9 = true;
                        break;
                    }
                if (local9)
                    lm9.emplace(std::string(sy9->name), ob9);
            }
            // § cloneBodyIsAScopeEvenWithNoOwnLocals181 — REGISTER THE BODY
            // WHETHER OR NOT `lm9` HAS ANYTHING IN IT.  `lm9` holds only the
            // subroutine's OWN formals and function-scope locals; the two
            // targets that matter most to a clone are found by the CLIMB in
            // `pkgCloneHierBind9`'s `bind9`, not by this map at all — a
            // BLOCK-local (`blockVar9`) and a foreach LOOP VARIABLE
            // (`loopVar37`, § pkgCloneLoopVarBind37, whose object is in no
            // Variables() listing anywhere).  `bind9` reaches that climb only
            // after `pkgCloneBodyLocals9.find(tf9)` succeeds, so an
            // `if (!lm9.empty())` guard silently switched the WHOLE clone-body
            // binding law off for any subroutine that declares nothing at its
            // own level.
            //
            // `uvm_table_printer::calculate_max_widths` (uvm-1.2
            // base/uvm_printer.svh:1013) is exactly that shape — `function
            // void ...();` with no formals, no return variable and every
            // declaration inside the `foreach (m_rows[j])` block — so its
            // clone's `m_rows[j]` index reference stayed BARE where golden
            // binds it to the § cloneLoopVarShared37 object, while
            // `uvm_table_printer::emit` (:1036, which owns `string s;` …)
            // bound its `foreach (m_rows[i])` index normally.  That pair is
            // the whole distinguisher: same package, same class, same
            // statement shape, one line of difference in the DECLARATION
            // count of the enclosing subroutine.
            //
            // Surelog has no such condition: `importPackage` re-resolves a
            // clone body's names against the IMPORTING package's symbol table
            // for every cloned subroutine alike, so an empty own-scope is not
            // a reason to stop being a clone-binding scope.  The map itself
            // is still the last resort in `bind9`, and an empty one simply
            // finds nothing — no cell can move on the map's account.
            pkgCloneBodyLocals9[tf] = std::move(lm9);
        }
        bool paUsed9 = tfBodyPaUsed9;
        bool tdListed157 = tfBodyTdListed157;
        tfBodyTdListed157 = savedTdListed157;
        tfBodyPaUsed9 = savedPaUsed9;
        tfBodyStmt9 = savedBodyStmt9;
        tfBodyTfItems9 = savedBodyIo9;
        tfBodyPa9 = std::move(savedBodyPa9);
        tfBodyPaAnchor9 = std::move(savedBodyPaAnch9);
        // A body that is a SINGLE statement (an explicit `begin..end`, or one
        // bare statement) never reaches the statement-list arm, so the
        // param-carrying wrapper is built here instead — same shape, same
        // second-item anchor (probe r10c4_p1 C/D).
        if (body && !taskBodyPa9.empty() && !paUsed9) {
            auto* ub9 = s.MakeBegin();
            ub9->VpiFullName(fullName);
            ub9->VpiParent(tf);
            std::vector<SourceRange> items9;
            for (auto& pr9 : taskBodyPaAnchor9)
                if (pr9.start())
                    items9.push_back(pr9);
            const Statement& bstmt9 = sub.getBody();
            items9.push_back(bstmt9.syntax ? bstmt9.syntax->sourceRange()
                                           : bstmt9.sourceRange);
            std::stable_sort(items9.begin(), items9.end(),
                             [](const SourceRange& a, const SourceRange& b) {
                                 return a.start() < b.start();
                             });
            setLoc(ub9, items9.size() >= 2 ? items9[1] : items9[0]);
            auto* bstmts9 = s.MakeAnyVec();
            for (auto* pa9 : taskBodyPa9) {
                pa9->VpiParent(ub9);
                bstmts9->push_back(pa9);
            }
            body->VpiParent(ub9);
            bstmts9->push_back(body);
            ub9->Stmts(bstmts9);
            body = ub9;
        }
        // § emptyFnBodyEndLabelBegin65 — the empty-bodied labelled subroutine's
        // own `begin`.  Placed here, after every body-DROP rule above, so the
        // gate can never fire on a body those rules emptied: it is a SYNTAX
        // test (`items` empty), and every dropped body has items — EXCEPT the
        // § qualifiedLifetimeMethodLosesNamePortsBody46 family, whose body is
        // nulled at 5213 WITHOUT looking at it (verifier F1, arm v1_qualdrop.sv
        // q01-q06: a syntactically-empty qualified+lifetime method would take
        // this arm while golden collapses the whole method to a stub with
        // -NONE- at vpiStmt — six surplus blocks, 0 corpus sites).  The
        // !qualLifetime46 term makes the stated argument true instead of
        // merely unviolated.  qualCtor27's family is already excluded by the
        // predicate's constructor term.
        if (!body && !qualLifetime46)
            if (auto* ebn65 = emptyFnBodyEndLabel65(sub)) {
                auto* eb65 = s.MakeBegin();
                eb65->VpiParent(tf);
                eb65->VpiFullName(fullName);
                setLoc(eb65, ebn65->name.range());
                body = eb65;
            }
        curSubPkgHome17 = savedPKH17;
        classMethodNoBind = savedCMNB;
        curSubClassScope9 = savedSCS9;
        curSubOob9 = savedSOB9;
        unitSubNoBind9 = savedUSNB9;
        pkgDefViewBody9 = savedPDV9;
        pkgRetFoldHome86 = savedPRF86;
        if (body)
            tf->Stmt(body);
        // § stmtScopeTdListedOnEnclosingScope157, SITE 3 of 3 — the SUBROUTINE
        // WITH NO SYNTHESISED WRAPPER.  Surelog's "Page 983, 2017 Standard:
        // 0 or 1 Stmt" arm passes the `task`/`function` ITSELF as `pstmt`
        // (`CompileStmt.cpp:2115-2121` / `:2560-2566`), so a body whose only
        // item is the typedef lists on the task_func.  Reached only when SITE 2
        // did not fire — a wrapper that exists owns the listing, and an
        // explicit `begin` body owns its own typedefs through SITE 1 (they are
        // members of the BLOCK symbol, not of the subroutine, so this call
        // finds nothing there).  grid157 `e_edge` `soleTd*` score it.
        // ...and ONLY when Surelog's own item count is exactly ONE, which is
        // the whole condition for its "0 or 1 Stmt" arm
        // (`subroutineBodyItemCount157`, src/EmitHelpers.h, carries the count
        // rule and the five measured golden answers).  A body of a typedef
        // AND anything else — a second typedef, a local, a task parameter, a
        // statement — puts the listing on the SYNTHESISED `begin`, which our
        // wrapper threshold does not always build; listing on the task_func
        // there is an AWAY, and `g157_d_sub` `emberDeclOnly157` /
        // `emberReturn157` are the two cells that convicted the first cut.
        // The TF-ITEM and CONSTRUCTOR gates are SITE 2's, repeated here
        // because this site is reached without passing through it.
        if (!tdListed157 && !tdTfItems157 && !tdCtor157 &&
            subroutineBodyItemCount157(sub) == 1)
            if (auto* tdl157 = makeStmtScopeTdListing157(sub))
                tf->Typespecs(tdl157);
        // A packed-array-of-enum local is a body-block member in Surelog's
        // model; re-parent the function-var-loop copy from the function to
        // that block (the body's begin) so both listings agree.
        if (body && (body->UhdmType() == UHDM::uhdmbegin ||
                     body->UhdmType() == UHDM::uhdmnamed_begin))
            for (auto* pav : fnBlockLocalPav)
                pav->VpiParent(body);
        if (selOwner)
            endSelTrack();
        currentTf = savedTf;
        currentSubSym = savedSubSym;
        funcRetSym = savedSym;
        funcRetRefs = savedRefs;
        funcRetSelRefs171 = savedSelRefs171;

        if (info)
            info->taskFuncs.push_back(tf);
        // A module that imports this class's home package HOISTS the class's
        // own out-of-body DEFINITION objects into its Task_funcs; record them
        // here, in listing order (see emitImportArtifacts).
        if (oob && classScope && !cloneMode) {
            classOobTfs[scopeSym9].push_back(tf);
            // ...and it carries the SAME listing key its package clone will
            // get (both come from this `member`), so a materialized group can
            // be re-sorted into the package's one source-ordered pass
            // (§ materializedPkgTfGroup).
            pkgTfOrder9[tf] = {sub.name == "new" ? 1 : 0, member.location};
        }
        // Package listing order key (see pkgTfOrder9): the clone pass and the
        // package's own free-subroutine pass feed the SAME vector, so both
        // record here.
        //
        // § dpiExportListedAtExportItem216 — for a DPI-EXPORTED free
        // subroutine the key is the EXPORT ITEM'S location, not the
        // definition's.  `pkgTfOrder9` drives the package DEF-listing re-sort
        // (`emitPackageClassMethodClones`) AND `materializedPkgTfGroup`, the
        // hoisted copy every wildcard IMPORTER of the package carries — and
        // golden's hoisted copy mirrors the package's own listing, so both
        // must read the same order.  In the corpus this key never changes an
        // order (`uvm_globals.svh:161/162` and `uvm_pkg.sv:9577/9578` are
        // adjacent items, and nothing else is declared between them); grid
        // arm B is where it is visible.
        // (r10v216) The key is the export item's ONLY when the export is written
        // ABOVE the definition — `dpiExportAbove216`, not `dpiExportSyn`, which
        // slang also sets for a BELOW export (FENCE 3 on `dpiExportItem216`).
        if (cloneMode || (pkgScope && !classScope))
            pkgTfOrder9[tf] = {sub.name == "new" ? 1 : 0,
                               dpiExportAbove216
                                   ? dpiExportAbove216->sourceRange().start()
                                   : member.location};
        // § dpiExportListedAtExportItem216 — this entry's LISTING keys: its own
        // top-level item index, and its `export "DPI-C"` item's index when it
        // has one.  Recorded 1:1 with `tfs`; the permutation is applied once
        // the walk is over, so the walk's own (creation) order is untouched.
        {
            size_t itemKey216 = kUnknown216, expKey216 = kUnknown216;
            if (!classScope && !genScope && !designScope && !cloneMode)
                if (const DpiExportOrder216* ord216 =
                        dpiExportOrder216For(sub, &itemKey216, nullptr))
                    if (dpiExportAbove216) {
                        auto e216 = ord216->exports.find(std::string(sub.name));
                        if (e216 != ord216->exports.end()) {
                            expKey216 = e216->second.first;
                            anyDpiExport216 = true;
                        }
                    }
            tfItemKey216.push_back(itemKey216);
            tfExpKey216.push_back(expKey216);
        }
        tfs->push_back(tf);
    }
    // § dpiExportListedAtExportItem216 — permute the finished listing, and the
    // DefInfo copy a module/interface view is rebuilt from, which carries the
    // same entries in the same order.
    if (anyDpiExport216) {
        auto perm216 = dpiExportListingPerm216(tfItemKey216, tfExpKey216);
        applyDpiExportPerm216(*tfs, 0, perm216);
        if (info)
            applyDpiExportPerm216(info->taskFuncs, infoBase216, perm216);
    }
    inClassBodyEmit = false;
    inBodyClassMethod88 = false;
    dpiExportPkgHome170 = nullptr;
    classBodyHomePkg75 = nullptr;
    pkgFreeSubHomePkg117 = nullptr;
    if (!tfs->empty()) {
        if (cloneMode) {
            if (auto* ex0 = pkgClassTfClone->Task_funcs())
                for (auto* t0 : *tfs)
                    ex0->push_back(t0);
            else
                pkgClassTfClone->Task_funcs(tfs);
        }
        else if (genScope)
            ((UHDM::gen_scope*)m)->Task_funcs(tfs);
        else if (designScope)
            ((UHDM::design*)m)->Task_funcs(tfs);
        else if (classScope)
            ((UHDM::class_defn*)m)->Task_funcs(tfs);
        else {
            auto* inst9 = (UHDM::instance*)m;
            if (auto* ex9 = inst9->Task_funcs())
                for (auto* t9 : *tfs)
                    ex9->push_back(t9);
            else
                inst9->Task_funcs(tfs);
        }
    }
    pkgScopeInst = savedPkgInst;
}

} // namespace slang_uhdm
