//------------------------------------------------------------------------------
//! @file TaskFuncEmit.cpp
//! @brief User tasks and functions (module Task_funcs) and their io_decls
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include "slang/ast/symbols/SubroutineSymbols.h"

namespace slang_uhdm {

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
    for (auto& member : body.members()) {
        // `pure virtual` class methods have no body: slang keeps them as
        // prototypes, Surelog still emits the task/function shell (vpiDPIPure).
        if (classScope && !onlySub && member.kind == SymbolKind::MethodPrototype) {
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
        if (member.kind != SymbolKind::Subroutine)
            continue;
        if (onlySub && &member != onlySub)
            continue;
        auto& sub = member.as<SubroutineSymbol>();
        // Class scopes skip slang's implicit built-ins (randomize etc.).
        if (classScope && !sub.getSyntax())
            continue;
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
        if (auto sit = subMap.find(&sub); sit != subMap.end() && sit->second.tf &&
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
        // A class CONSTRUCTOR carries no vpiVisibility (Surelog).
        if (!(classScope && sub.name == "new"))
            tf->VpiVisibility(
                classScope ? (sub.visibility == Visibility::Protected
                                  ? 2
                                  : (sub.visibility == Visibility::Local ? 3 : 1))
                           : 1);
        if (classScope && (sub.flags & MethodFlags::Virtual) != MethodFlags::None)
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
        else if (sub.defaultLifetime == VariableLifetime::Automatic && !classScope) {
            tf->VpiAutomatic(true);
        }
        // An exported FUNCTION locates at the export DIRECTIVE's span
        // (an exported TASK keeps its definition span).
        if (dpiExportSyn && sub.subroutineKind == SubroutineKind::Function)
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
        if (designScope || classScope)
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
            cts->Class_defn(currentClassDefn);
            // Surelog names this typespec after the class's vpiName, which at
            // compile time is only set for a NESTED class (a top-level class
            // gets its name in the write phase, so its ctor typespec stays
            // anonymous). compileClassConstructorDeclaration, CompileStmt.cpp.
            if (auto* cp9 = currentClassDefn->VpiParent();
                cp9 && cp9->UhdmType() == UHDM::uhdmclass_defn)
                cts->VpiName(currentClassDefn->VpiName());
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
            if (pkgScope && !classScope &&
                !(sub.returnValVar && foreignSharedTs(*sub.returnValVar, ts))) {
                ts->Instance(importCopyTsInst ? importCopyTsInst
                                              : (UHDM::instance*)m);
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
            if (auto* dv = arg->getDefaultValue()) {
                NetMap emptyMap;
                if (auto* de = emitExpr(*dv, nullptr, fullName, emptyMap))
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
                if (noTypeNode) {
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
                if (pkgScope && !classScope &&
                    !foreignSharedTs(*arg, (const UHDM::typespec*)ts) &&
                    !(pkgTopEmit &&
                      defPassOwnedTs.count((UHDM::typespec*)ts))) {
                    ((UHDM::typespec*)ts)->Instance(
                        importCopyTsInst ? importCopyTsInst
                                         : (UHDM::instance*)m);
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

        emitParameters(sub, tf, fullName, funcMap, /*topView=*/false, nullptr,
                       /*inPackage=*/false, /*topShareTs=*/false, /*funcScope=*/true);
        if (m->UhdmType() == UHDM::uhdmmodule_inst) {
            implicitNetModule = (UHDM::module_inst*)m;
            implicitNetPrefix = prefix;
        }

        // Function-local variables attach to the function's Variables
        // (loc = the declared type span).
        std::vector<UHDM::variables*> fnBlockLocalPav;
        // A STATIC (non-automatic) module function that owns an UNPACKED-ARRAY
        // local models ALL its locals under a synthesized BEGIN wrapping the
        // body: locals dual-listed (also under the function), located at the
        // NAME token, NO vpiAutomatic; the begin spans the LAST local
        // declaration statement (Surelog). Functions without an unpacked-array
        // local keep the flat form (decl-span loc + vpiAutomatic, no wrapper).
        bool autoFunc = (sub.defaultLifetime == VariableLifetime::Automatic);
        bool hasUnpackedLocal = false;
        for (auto& fmv : sub.members()) {
            if (fmv.kind != SymbolKind::Variable || &fmv == sub.returnValVar ||
                fmv.name == "this")
                continue;
            bool isArg = false;
            for (auto arg : sub.getArguments())
                if (arg == &fmv || arg->name == fmv.name) {
                    isArg = true;
                    break;
                }
            if (!isArg && fmv.getDeclaredType() &&
                fmv.getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType) {
                hasUnpackedLocal = true;
                break;
            }
        }
        bool staticFnModel = (m->UhdmType() == UHDM::uhdmmodule_inst) &&
                             !autoFunc && !classScope && hasUnpackedLocal;
        std::vector<UHDM::variables*> staticBeginVars;  // begin.Variables order
        // AUTOMATIC module-fn locals reparent to the body begin
        // (func_upto: parent=begin, name span, no per-var Automatic).
        std::vector<UHDM::variables*> autoShareLocals9;
        // Only fns whose body is an IMPLICIT statement list (no source
        // `begin`) use the begin-share local shape (func_upto); an explicit
        // begin keeps decl-span fn-parented Automatic locals
        // (const_fold_func/func_block).
        bool implicitFnBody9 = true;
        if (auto fsyn9 = sub.getSyntax()) {
            for (size_t i9 = 0; i9 < fsyn9->getChildCount(); i9++)
                if (auto* cn9 = fsyn9->childNode(i9)) {
                    if (cn9->kind ==
                        syntax::SyntaxKind::SequentialBlockStatement)
                        implicitFnBody9 = false;
                    // items live in a list node one level down
                    for (size_t j9 = 0; j9 < cn9->getChildCount(); j9++)
                        if (auto* gn9 = cn9->childNode(j9);
                            gn9 && gn9->kind ==
                                       syntax::SyntaxKind::
                                           SequentialBlockStatement)
                            implicitFnBody9 = false;
                }
        }
        // The same implicit-vs-explicit-body split governs a PACKAGE
        // automatic function: a body that IS one explicit `begin` keeps
        // decl-span, function-parented AUTOMATIC locals (PackFunc), while a
        // bare statement list keeps name-span non-automatic ones
        // (PackFuncParent, VarInFor). The blanket pkgScope exclusion below was
        // calibrated on the latter. `implicitFnBody9` is deliberately NOT
        // reused: its grandchild scan also fires on a `for (...) begin`
        // nested inside the statement list (VarInFor), which is not a body
        // block. Only a DIRECT item counts.
        bool pkgBodyBlock9 = false;
        if (auto fsyn8 = sub.getSyntax())
            if (auto* fd8 = fsyn8->as_if<syntax::FunctionDeclarationSyntax>())
                for (auto* it8 : fd8->items)
                    if (it8->kind == syntax::SyntaxKind::SequentialBlockStatement)
                        pkgBodyBlock9 = true;
        bool pkgAutoBlockLocal9 = pkgScope && autoFunc && pkgBodyBlock9;
        std::vector<UHDM::variables*> staticTopLocals;  // reparent to begin
        const syntax::SyntaxNode* lastLocalDeclSyn = nullptr;
        auto declStmtSpan = [&](const Symbol& v) -> const syntax::SyntaxNode* {
            if (auto sy = v.getSyntax())
                for (auto p = sy->parent; p; p = p->parent)
                    if (p->kind == syntax::SyntaxKind::DataDeclaration)
                        return p;
            return nullptr;
        };
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
                // An UNPACKED-array local (int a [2]) is an array_var whose
                // vpiReg is the element var (int_var); the array_typespec
                // (not the array_var) carries the unpacked-dim range, and its
                // Elem_typespec is SHARED with the reg. Not a flat var.
                if (fmv.getDeclaredType()->getType().getCanonicalType().kind ==
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
                    fvars->push_back(av);
                    if (staticFnModel) {
                        // begin.Variables lists the element reg THEN the
                        // array_var; only the array_var re-parents to begin.
                        staticBeginVars.push_back(reg);
                        staticBeginVars.push_back(av);
                        staticTopLocals.push_back(av);
                        if (auto* d = declStmtSpan(fmv))
                            lastLocalDeclSyn = d;
                    }
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
                if (pkgScope && !foreignSharedTs(fmv, vts)) {
                    vts->Instance(importCopyTsInst ? importCopyTsInst
                                                   : (UHDM::instance*)m);
                    if (importCopyTsInst && importCopyTsCollect)
                        importCopyTsCollect->push_back(vts);
                }
                // A packed-array-of-enum local is a packed_array_var (range +
                // enum_var element), anchored at its name and NOT automatic.
                UHDM::variables* v = makeEnumArrayVar(vts, vfull, tf);
                bool isEnumArr = v != nullptr;
                if (!v)
                    v = makeReturnVar(s, fmv.getDeclaredType()->getType());
                v->VpiName(fmv.name);
                v->VpiFullName(vfull);
                v->VpiParent(tf);
                bool blockLocal = isEnumArr || namedTypeLocal;
                // Initialized locals anchor at the name (and are later
                // re-parented at their init assignment, without the
                // automatic flag).
                bool autoFnLocal9 = autoFunc && !classScope && !pkgScope &&
                                    implicitFnBody9 &&
                                    m->UhdmType() == UHDM::uhdmmodule_inst;
                if (blockLocal || hasInit ||
                    (pkgScope && !pkgAutoBlockLocal9) || staticFnModel ||
                    autoFnLocal9) {
                    // Static-function locals anchor at the NAME token; the
                    // automatic-function form keeps the declared-type span.
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
                if (!hasInit && (!pkgScope || pkgAutoBlockLocal9) &&
                    !blockLocal && !staticFnModel && !autoFnLocal9)
                    v->VpiAutomatic(true);
                if (autoFnLocal9 && !blockLocal && !hasInit)
                    autoShareLocals9.push_back(v);
                if (blockLocal)
                    fnBlockLocalPav.push_back(v);
                if (staticFnModel && !blockLocal) {
                    staticBeginVars.push_back(v);
                    staticTopLocals.push_back(v);
                    if (auto* d = declStmtSpan(fmv))
                        lastLocalDeclSyn = d;
                }
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
        classMethodNoBind = classScope;
        auto* body = emitStmt(sub.getBody(), tf, fullName, funcMap);
        classMethodNoBind = savedCMNB;
        if (!autoShareLocals9.empty() && body &&
            body->UhdmType() == UHDM::uhdmbegin)
            for (auto* av9 : autoShareLocals9)
                av9->VpiParent(body);
        // A static module function with locals wraps its body in a synthesized
        // begin (spanning the last local decl) that owns the locals; the
        // source begin nests inside it (Surelog).
        if (body && staticFnModel && !staticBeginVars.empty() &&
            (body->UhdmType() == UHDM::uhdmbegin ||
             body->UhdmType() == UHDM::uhdmnamed_begin)) {
            auto* outer = s.MakeBegin();
            outer->VpiParent(tf);
            outer->VpiFullName(fullName);
            if (lastLocalDeclSyn)
                setLoc(outer, lastLocalDeclSyn->sourceRange());
            for (auto* tl : staticTopLocals)
                tl->VpiParent(outer);
            auto* bvars = s.MakeVariablesVec();
            for (auto* bv : staticBeginVars)
                bvars->push_back(bv);
            outer->Variables(bvars);
            body->VpiParent(outer);
            auto* ostmts = s.MakeAnyVec();
            ostmts->push_back(body);
            outer->Stmts(ostmts);
            tf->Stmt(outer);
        }
        else if (body)
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
        tfs->push_back(tf);
    }
    if (!tfs->empty()) {
        if (genScope)
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
