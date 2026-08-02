//------------------------------------------------------------------------------
//! @file TaskFuncEmit.cpp
//! @brief User tasks and functions (module Task_funcs) and their io_decls
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include "slang/ast/symbols/SubroutineSymbols.h"

#include <algorithm>
#include <vector>

namespace slang_uhdm {

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
    explicit ElabCallScan(std::set<const SubroutineSymbol*>& o) : out(o) {}
    void handle(const slang::ast::CallExpression& ce) {
        if (auto* sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
            if (*sp)
                out.insert(*sp);
        visitDefault(ce);
    }
};
}  // namespace

bool UhdmExporter::elabInvoked(const SubroutineSymbol& sub) {
    if (!elabCalledSubs) {
        elabCalledSubs.emplace();
        ElabCallScan scan(*elabCalledSubs);
        comp.getRoot().visit(scan);
    }
    return elabCalledSubs->count(&sub) != 0;
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

static void copyLoc(UHDM::BaseClass* dst, const UHDM::BaseClass* src) {
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
UHDM::array_var* UhdmExporter::makeQueueDynArrayVar(const Symbol& vs,
                                                    const std::string& afull,
                                                    UHDM::any* parent) {
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
    // NOTE: no vpiInstance on the element ts — Surelog leaves a class-method
    // local's typespec unscoped (measured).
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
    auto* reg0 = makeReturnVar(s, *qelem0);
    reg0->VpiParent(av);
    reg0->VpiFullName(afull);
    setLoc(reg0, nameSpan(vs.location, vs.name));
    auto* rrt0 = s.MakeRef_typespec();
    rrt0->VpiFullName(afull);
    rrt0->VpiParent(reg0);
    rrt0->Actual_typespec(elemTs);
    reg0->Typespec(rrt0);
    if (qelem0->isSigned())
        reg0->VpiSigned(true);
    auto* rv0 = s.MakeVariablesVec();
    rv0->push_back(reg0);
    av->Variables(rv0);
    // A foreach over this queue / dynamic array binds THIS array_typespec
    // (its loop variables still take the ELEMENT type — probe r10c4_p6).
    arrayVarArrayTs[&vs] = ats;
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
        // An out-of-body DEFINITION is not a method listing: vpiMethod is 0
        // (1 only for `new`, which Surelog still marks a method), the
        // vpiVisibility is the flat default 1 (unset for `new`), there is no
        // vpiAccessType, and vpiVirtual never rides it even when the
        // PROTOTYPE is virtual — the definition carries the body instead.
        bool oob = isOutOfBody(&member);
        bool oobCtor = oob && sub.name == "new";
        // The CLASS's own copy of an out-of-body body is where Surelog's
        // module hoist re-binds unresolvable property names (the package
        // clone's stay unbound) — see classPropRefs.
        inClassBodyEmit = oob && classScope && !cloneMode;
        // The instance every typespec minted for THIS subroutine takes.
        UHDM::instance* tsInst = (pkgScope && !classScope)
                                     ? (UHDM::instance*)m
                                     : (oob ? oobHomePkg : nullptr);
        pkgScopeInst = (pkgScope && !classScope) ? baseScopeInst : tsInst;
        bool isFunc = sub.subroutineKind == SubroutineKind::Function;
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
        tf->VpiParent(m);
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
            if (qualHolder)
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
            if (!staticSpan)
                // A plain `virtual` method spans the WHOLE declaration,
                // qualifier included.
                setLoc(tf, virtualQual ? qualHolder->sourceRange()
                                       : syn->sourceRange());
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
            if (!args0.empty())
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
        TsCache ioTs;

        // A DPI-IMPORT prototype has no returnValVar; synthesize its Return
        // var (anonymous, at the return-type token, ts ref to a fresh ts).
        if (isFunc && !sub.returnValVar && dpiImport && !sub.getReturnType().isVoid()) {
            auto* rv = makeReturnVar(s, sub.getReturnType(),
                                     [&] {
                                         auto* rs0 = returnTypeSyntax(sub);
                                         return rs0 && rs0->kind ==
                                             slang::syntax::SyntaxKind::ImplicitType;
                                     }());
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
                rv->Typespec(rt);
                copyLoc(rv, ts);
            }
            ((UHDM::function*)tf)->Return(rv);
        }
        // Function return: an anonymous variable carrying only the full name,
        // anchored at the return-type syntax like its typespec.
        if (isFunc && sub.returnValVar && !sub.getReturnType().isVoid()) {
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
            auto* rv =
                crossImplicitRet
                    ? (UHDM::variables*)s.MakeRef_var()
                    : makeReturnVar(s, sub.getReturnType(),
                                    [&] {
                                        auto* rs0 = returnTypeSyntax(sub);
                                        return rs0 && rs0->kind ==
                                            slang::syntax::SyntaxKind::ImplicitType;
                                    }());
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            // An IMPLICIT return type ("function f;") yields a bare return var:
            // no typespec, no location.
            bool implicitRet = false;
            if (auto* rsyn = returnTypeSyntax(sub)) {
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
                for (auto& [sym, tsp] : typedefTs)
                    if (sym->kind == SymbolKind::TypeAlias &&
                        &sym->as<TypeAliasType>().getCanonicalType() == &retCanon) {
                        ts = tsp;
                        break;
                    }
            }
            // A typedef'd VECTOR return gets a fresh NAMED clone (at the
            // typedef site) with a Typedef_alias ref; the return var anchors
            // at the return-type token.
            bool typedefRetClone = false;
            bool pkgUnitRet9 = false;
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
                bool sameScopePkgFn9 = false;
                if (retAlias)
                    if (auto scr9 = retAlias->getParentScope()) {
                        pkgUnitRet9 =
                            scr9->asSymbol().kind == SymbolKind::Package;
                        if (pkgUnitRet9 && pkgScope &&
                            sub.getParentScope() == scr9)
                            sameScopePkgFn9 = true;
                    }
                if (retBase && sameScopePkgFn9 &&
                    retBase->UhdmType() == UHDM::uhdmlogic_typespec) {
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
                    // imm_*_f.
                    tfContext = !pkgTopEmit;
                    tfTypeScope = sub.getParentScope();
                    ts = makeTypespec(*sub.returnValVar, targetSyn9);
                    // The return clone's alias binds the pkg LISTING object of
                    // its own view: the def listing for the def fn, the
                    // top/module listing for the elab fn (Surelog; the fresh
                    // per-function twin belongs to the BODY-local clone, not
                    // the return) — jeras_union imm_i_f.
                    UHDM::typespec* rtw9 = retBase;
                    if (pkgTopEmit)
                        if (auto tt9 = pkgTopTypedefTs.find(
                                (const void*)retAlias);
                            tt9 != pkgTopTypedefTs.end())
                            rtw9 = tt9->second;
                    tfTypeScope = nullptr;
                    tfContext = false;
                    bypassTypedefShare = false;
                    ts->VpiName(rdt.name);
                    auto* art9 = s.MakeRef_typespec();
                    art9->VpiFullName(std::string(rdt.name));
                    art9->VpiParent(ts);
                    art9->Actual_typespec(rtw9);
                    ((UHDM::logic_typespec*)ts)->Typedef_alias(art9);
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
                    ts = makeTypespec(*sub.returnValVar, targetSyn);
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
                    auto* cl9 = buildUnpackedArrayTypedefTs(
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
            // A CLASS-HANDLE return: an ANONYMOUS class_typespec at the
            // return-type token, linked to the class_defn (Surelog).
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
                    if (auto* rsyn9 = returnTypeSyntax(sub))
                        setLoc(cts9, rsyn9->sourceRange());
                    ts = cts9;
                }
            }
            if (!ts) {
                tfContext = true;
                tfTypeScope = pkgScope ? sub.getParentScope() : nullptr;
                ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
                tfTypeScope = nullptr;
                tfContext = false;
            }
            // The ELABORATED package view's functions bind THAT view's typedef
            // listing object (rp32 enc32's op32_t return), not the def-listing
            // one the shared lookup returns. Only fires when `ts` IS the def
            // listing object — a freshly minted return clone is left alone.
            if (pkgTopEmit && ts)
                for (auto& [sym0, tsp0] : typedefTs)
                    if (tsp0 == ts) {
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
            // A CLASS scope is not a vpiInstance (Surelog leaves method
            // typespecs uninstanced, as the io_decl path already does).
            if (tsInst &&
                !(sub.returnValVar && foreignSharedTs(*sub.returnValVar, ts))) {
                ts->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
                stampElemTsInstance(ts, (UHDM::instance*)ts->Instance());
                if (importCopyTsInst && importCopyTsCollect)
                    importCopyTsCollect->push_back(ts);
            }
            rv->Typespec(rt);
            if (sub.returnValVar)
                deferForeignTopTs(*sub.returnValVar, rt, ts);
            // A struct/enum/unpacked-array return's shared typespec sits at
            // the typedef, so the return var takes the return-TYPE syntax
            // span instead (a typedef'd-vector clone likewise).
            if (ts->UhdmType() == UHDM::uhdmstruct_typespec ||
                ts->UhdmType() == UHDM::uhdmenum_typespec ||
                ts->UhdmType() == UHDM::uhdmarray_typespec ||
                typedefRetClone || pkgUnitRet9) {
                if (auto* rsyn = returnTypeSyntax(sub)) {
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
                    if (auto* rsyn9 = returnTypeSyntax(sub)) {
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
        for (auto arg : sub.getArguments()) {
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
            // ...except `= null`, which Surelog leaves off entirely: the
            // io_decl of `function void uvm_object::print(uvm_printer
            // printer=null)` carries no vpiExpr, while the `= ""` one right
            // beside it does.  A `null` in a RETURN does get its
            // vpiNullConst, so this is an io_decl rule, not an expression one.
            if (auto* dv = arg->getDefaultValue()) {
                NetMap emptyMap;
                auto* de = emitExpr(*dv, nullptr, fullName, emptyMap);
                // (the literal arrives wrapped in slang's implicit conversion
                // to the handle type, so the emitted object is what to test)
                if (de && de->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::constant*)de)->VpiConstType() == vpiNullConst)
                    de = nullptr;
                if (de)
                    io->Expr((UHDM::expr*)de);
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
            // An ANSI formal written as a BARE NAME (task put(message); /
            // task get(ref message);) has no data-type node at all, so Surelog
            // gives its io_decl NO typespec. A body-style "input x;" does keep
            // one (there the direction keyword is the type declaration).
            if (bareImplicit) {
                bool noTypeNode = false;
                for (auto q = arg->getSyntax(); q; q = q->parent) {
                    if (q->kind == syntax::SyntaxKind::FunctionPort) {
                        noTypeNode = q->as<syntax::FunctionPortSyntax>().dataType == nullptr;
                        break;
                    }
                    if (q->kind == syntax::SyntaxKind::PortDeclaration ||
                        q->kind == syntax::SyntaxKind::FunctionDeclaration ||
                        q->kind == syntax::SyntaxKind::TaskDeclaration)
                        break;
                }
                // ...unless the subroutine is INVOKED from a continuous /
                // elaboration expression, which makes Surelog compile its
                // formals after all — then even the bare-name formal takes
                // the unlocated logic_typespec (§ elabInvoked;
                // ImplicitFuncArgAndReturn's `sub #(.M_SECURE({w_1(...)}))`).
                // The UVM `task put(message)` counterexamples this branch was
                // written for are all uncalled, so they keep dropping it.
                if (noTypeNode && !elabInvoked(sub)) {
                    ios->push_back(io);
                    if (!classScope)
                        funcMap[arg] = io;
                    si.argTs.push_back({nullptr, nullptr});
                    continue;
                }
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
            auto stampPkgFormalTs = [&](UHDM::typespec* t0) {
                if (!t0 || !pkgScope || classScope)
                    return;
                if (pkgTopEmit && defPassOwnedTs.count(t0))
                    return;
                t0->Instance(importCopyTsInst ? importCopyTsInst
                                              : (UHDM::instance*)m);
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
            if (redeclSym) {
                ts = makeTypespec(*redeclSym);
                rt->Actual_typespec(ts);
            }
            else if (bareImplicit) {
                pendingIoTs.push_back({rt, argTsyn});
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
                ts = makeTypespec(*arg, targetSyn);
                bypassTypedefShare = false;
                ts->VpiName(at.name);
                if (argTsyn)
                    setLoc((UHDM::BaseClass*)ts, argTsyn->sourceRange());
                auto* mainTs = typedefTs[&at];
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
            // anonymous (PackedUnpackedIo).
            else if (arg->getDeclaredType()->getType().getCanonicalType().kind ==
                         SymbolKind::FixedSizeUnpackedArrayType &&
                     [&]() -> const Type* {
                         const Type* e0 =
                             &arg->getDeclaredType()->getType().getCanonicalType();
                         while (e0->getCanonicalType().kind ==
                                SymbolKind::FixedSizeUnpackedArrayType)
                             e0 = &e0->getCanonicalType()
                                       .as<FixedSizeUnpackedArrayType>()
                                       .elementType;
                         return e0->kind == SymbolKind::TypeAlias &&
                                        typedefTs.count(e0) &&
                                        typedefTs[e0]->UhdmType() ==
                                            UHDM::uhdmlogic_typespec
                                    ? e0
                                    : nullptr;
                     }() != nullptr) {
                const Type* e0 =
                    &arg->getDeclaredType()->getType().getCanonicalType();
                while (e0->getCanonicalType().kind ==
                       SymbolKind::FixedSizeUnpackedArrayType)
                    e0 = &e0->getCanonicalType()
                              .as<FixedSizeUnpackedArrayType>()
                              .elementType;
                auto& elAl0 = e0->as<TypeAliasType>();
                const syntax::SyntaxNode* targetSyn0 = nullptr;
                if (auto asyn0 = elAl0.getSyntax())
                    if (asyn0->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn0 =
                            asyn0->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                ts = makeTypespec(elAl0, targetSyn0);
                bypassTypedefShare = false;
                ts->VpiName(elAl0.name);
                if (argTsyn)
                    setLoc((UHDM::BaseClass*)ts, argTsyn->sourceRange());
                auto* art0 = s.MakeRef_typespec();
                art0->VpiFullName(std::string(elAl0.name));
                art0->VpiParent(ts);
                art0->Actual_typespec(typedefTs[e0]);
                ((UHDM::logic_typespec*)ts)->Typedef_alias(art0);
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
                ts = sharedTypespec(*arg, ioTs);
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
                if (tsInst &&
                    !foreignSharedTs(*arg, (const UHDM::typespec*)ts) &&
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
            io->Typespec(rt);
            deferForeignTopTs(*arg, rt, (const UHDM::typespec*)ts);
            // Unpacked-array formals carry one range per unpacked dimension;
            // a PARAM-sized dim ([CNT]) stays symbolic, scoped at the formal
            // (work@top.F.SRC.CNT) — Surelog (ArrayExprFuncArg).
            if (arg->getDeclaredType() &&
                arg->getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType)
                if (auto* ranges = buildUnpackedRanges(
                        *arg, io, fullName + sep + std::string(arg->name)))
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
            ios->push_back(io);
            // A class-method formal IS reachable from the body, but only an
            // if/case CONDITION ref actually binds it (classMethodNoBind).
            funcMap[arg] = io;
            si.argTs.push_back({ts, bareImplicit ? (const void*)argTsyn : nullptr});
        }
        if (!ios->empty())
            tf->Io_decls(ios);

        // The prototype listing ends here: no body, no locals, no params, and
        // no subMap registration (calls bind the DEFINITION object, which the
        // second group emits from the same SubroutineSymbol).
        if (protoOf) {
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
                if (auto* av = !blockItems9
                                   ? nullptr
                                   : makeQueueDynArrayVar(
                                         fmv,
                                         fullName + sep + std::string(fmv.name),
                                         tf)) {
                    funcMap[&fmv] = av;
                    fvars->push_back(av);
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
                    if (leaf->getCanonicalType().kind ==
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
                        auto* lts = s.MakeLogic_typespec();
                        auto& lct = leaf->getCanonicalType();
                        if (auto tsyn3 = fmv.getDeclaredType()->getTypeSyntax()) {
                            auto sr3 = tsyn3->sourceRange();
                            setLoc(lts, sr3);
                            if (lct.kind == SymbolKind::PackedArrayType) {
                                auto pr3 = lct.as<PackedArrayType>().range;
                                std::vector<DimSpan> spans3;
                                if (sr3.start() != SourceLocation::NoLocation)
                                    spans3 = scanDimSpans(
                                        std::string(rawText(sr3)), sr3.start());
                                const DimSpan* ds3 =
                                    spans3.empty() ? nullptr : &spans3.back();
                                auto* rng3 = s.MakeRange();
                                rng3->VpiParent(lts);
                                if (ds3)
                                    setLoc(rng3, ds3->range);
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
                                rng3->Left_expr(
                                    mkR3(pr3.left, ds3 ? &ds3->left : nullptr));
                                rng3->Right_expr(
                                    mkR3(pr3.right, ds3 ? &ds3->right : nullptr));
                                auto* rvec3 = s.MakeRangeVec();
                                rvec3->push_back(rng3);
                                lts->Ranges(rvec3);
                            }
                        }
                        elemTs = lts;
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
                    auto* reg = makeReturnVar(s, *leaf);
                    reg->VpiParent(av);
                    setLoc(reg, nameSpan(fmv.location, fmv.name));
                    auto* regRt = s.MakeRef_typespec();
                    regRt->VpiFullName(afull);
                    regRt->VpiParent(reg);
                    regRt->Actual_typespec(elemTs);
                    reg->Typespec(regRt);
                    if (leaf->isSigned())
                        reg->VpiSigned(true);
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
                            tfContext = true;
                            auto* cl = makeTypespec(fmv, targetSyn);
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
                    vts = makeTypespec(fmv);
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
                // A CLASS-NESTED typedef object is shared with its owning
                // class_defn's vpiTypedef listing and stays unscoped —
                // stamping it here would scope the whole typedef to the
                // referencing class (IOClassStruct).
                bool sharedClassTypedef9 = false;
                if (auto itS9 = typedefTs.find(&fmv.getDeclaredType()->getType());
                    itS9 != typedefTs.end() && itS9->second == vts)
                    if (auto* oscS9 = fmv.getDeclaredType()->getType().getParentScope())
                        sharedClassTypedef9 =
                            oscS9->asSymbol().kind == SymbolKind::ClassType;
                // `m` is the CLASS_DEFN for a method, and a class scope is not
                // a vpiInstance: an out-of-body method's body locals are
                // resolved in the home PACKAGE and carry it, an in-class
                // method's carry nothing. tsInst already encodes exactly that
                // (ApbSlave svunit_testsuite::report's pass_cnt/success_str).
                if (tsInst && !sharedClassTypedef9 && !foreignSharedTs(fmv, vts)) {
                    vts->Instance(importCopyTsInst ? importCopyTsInst : tsInst);
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back(vts);
                }
                // A packed-array-of-enum local is a packed_array_var (range +
                // enum_var element), anchored at its name and NOT automatic.
                UHDM::variables* v = makeEnumArrayVar(vts, vfull, tf);
                bool isEnumArr = v != nullptr;
                // A FORWARD reference to a class-nested typedef (the owning
                // class sorts after this one) has no compiled type yet when
                // Surelog picks the variable class, so it falls back to a
                // class_var while still binding the shared struct_typespec
                // (IOClassStruct; see makeTypespec's on-demand build).
                if (!v && onDemandClassTypedefs.count(
                              (const void*)&fmv.getDeclaredType()->getType()))
                    v = s.MakeClass_var();
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
                        else
                            break;
                    }
                    v = makeReturnVar(s, *lt9);
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
                vrt->Actual_typespec(vts);
                v->Typespec(vrt);
                deferForeignTopTs(fmv, vrt, vts);
                if (!hasInit && !blockLocal && !blockItems9)
                    v->VpiAutomatic(true);
                if (blockLocal)
                    fnBlockLocalPav.push_back(v);
                funcMap[&fmv] = v;
                fvars->push_back(v);
            }
            if (!fvars->empty())
                tf->Variables(fvars);
        }

        // Register before the body so recursive calls bind this function.
        if (sharedScope || reusedShell || !subMap.count(&sub))
            subMap[&sub] = si;
        // The package's ELABORATED pass builds the twin whose typespecs are
        // folded; remember it so importing modules can list and bind it.
        if (pkgScope && !classScope && pkgTopEmit)
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
        if (!ios->empty() && tf->Variables())
            for (auto* fv0 : *tf->Variables()) {
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
        pendingFuncRet.push_back(
            {&sub, fullName, {}, pkgScope ? (UHDM::instance*)m : nullptr});
        size_t pfIdx = pendingFuncRet.size() - 1;
        auto* savedSym = funcRetSym;
        auto* savedRefs = funcRetRefs;
        funcRetSym = sub.returnValVar;
        funcRetRefs = &pendingFuncRet[pfIdx].refs;
        auto* savedTf = currentTf;
        currentTf = tf;
        auto* savedSubSym = currentSubSym;
        currentSubSym = &sub;
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
        bool savedPDV9 = pkgDefViewBody9;
        // The un-elaborated package view: its own functions during the def
        // pass, and the class-method clones emitPackageClassMethodClones
        // appends to it (see pkgDefViewBody9).
        pkgDefViewBody9 =
            cloneMode || (pkgScope && !classScope && !pkgTopEmit);
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
        auto* body = emitStmt(sub.getBody(), tf, fullName, funcMap);
        bool paUsed9 = tfBodyPaUsed9;
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
        classMethodNoBind = savedCMNB;
        pkgDefViewBody9 = savedPDV9;
        if (body)
            tf->Stmt(body);
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

        if (info)
            info->taskFuncs.push_back(tf);
        // A module that imports this class's home package HOISTS the class's
        // own out-of-body DEFINITION objects into its Task_funcs; record them
        // here, in listing order (see emitImportArtifacts).
        if (oob && classScope && !cloneMode)
            classOobTfs[scopeSym9].push_back(tf);
        // Package listing order key (see pkgTfOrder9): the clone pass and the
        // package's own free-subroutine pass feed the SAME vector, so both
        // record here.
        if (cloneMode || (pkgScope && !classScope))
            pkgTfOrder9[tf] = {sub.name == "new" ? 1 : 0, member.location};
        tfs->push_back(tf);
    }
    inClassBodyEmit = false;
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
