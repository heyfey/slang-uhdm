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


void UhdmExporter::emitTaskFuncs(const Scope& body, UHDM::BaseClass* m,
                                 const std::string& prefix, DefInfo* info,
                                 bool sharedScope) {
    bool genScope = m->UhdmType() == UHDM::uhdmgen_scope;
    bool designScope = m->UhdmType() == UHDM::uhdmdesign;
    // Packages use :: separators below the function name too.
    bool pkgScope = prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0;
    std::string sep = pkgScope ? "::" : ".";
    auto* savedPkgInst = pkgScopeInst;
    pkgScopeInst = pkgScope ? (UHDM::instance*)m : nullptr;
    auto* tfs = s.MakeTask_funcVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Subroutine)
            continue;
        auto& sub = member.as<SubroutineSymbol>();
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
        // top-view re-emission must NOT reuse the def copy.
        UHDM::task_func* tf = nullptr;
        if (sharedScope)
            if (auto sit = subMap.find(&sub); sit != subMap.end() && sit->second.tf)
                tf = sit->second.tf;
        if (!tf)
            tf = isFunc ? (UHDM::task_func*)s.MakeFunction()
                        : (UHDM::task_func*)s.MakeTask();
        tf->VpiName(sub.name);
        tf->VpiFullName(fullName);
        tf->VpiParent(m);
        tf->VpiVisibility(1);
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
        else if (sub.defaultLifetime == VariableLifetime::Automatic) {
            tf->VpiAutomatic(true);
        }
        // An exported function locates at the export DIRECTIVE's span.
        if (dpiExportSyn)
            setLoc(tf, dpiExportSyn->sourceRange());
        else if (auto syn = sub.getSyntax())
            setLoc(tf, syn->sourceRange());
        if (designScope)
            tf->VpiMethod(true);
        if (!genScope && !designScope)
            tf->Instance((UHDM::instance*)m);

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
            auto* rv = makeReturnVar(s, sub.getReturnType());
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
            auto* rv = makeReturnVar(s, sub.getReturnType());
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
            if (!ts) {
                tfContext = true;
                ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
                tfContext = false;
            }
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName);
            rt->VpiParent(rv);
            rt->Actual_typespec(ts);
            if (pkgScope)
                ts->Instance((UHDM::instance*)m);
            rv->Typespec(rt);
            // A struct/enum return's shared typespec sits at the typedef, so
            // the return var takes the return-TYPE syntax span instead.
            if (ts->UhdmType() == UHDM::uhdmstruct_typespec ||
                ts->UhdmType() == UHDM::uhdmenum_typespec) {
                if (auto* rsyn = returnTypeSyntax(sub))
                    setLoc(rv, rsyn->sourceRange());
            }
            else {
                copyLoc(rv, ts);
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
                default:
                    noteUnsupported("subroutine arg direction");
                    break;
            }
            setLoc(io, nameSpan(arg->location, arg->name));
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
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName + sep + std::string(arg->name));
            rt->VpiParent(io);
            if (bareImplicit) {
                pendingIoTs.push_back({rt, argTsyn});
            }
            else {
                tfContext = true;
                ts = sharedTypespec(*arg, ioTs);
                tfContext = false;
                // DIRECTIONLESS explicit-keyword arg types anchor at the
                // keyword token only (ranges keep their own spans); formals
                // with a direction keyword keep the whole type span.
                bool hasDir = false;
                for (auto q = arg->getSyntax(); q; q = q->parent) {
                    if (q->kind == syntax::SyntaxKind::FunctionPort) {
                        hasDir = q->as<syntax::FunctionPortSyntax>().direction.valid();
                        break;
                    }
                    if (q->kind == syntax::SyntaxKind::PortDeclaration ||
                        q->kind == syntax::SyntaxKind::FunctionDeclaration)
                        break;
                }
                if (!hasDir && argTsyn && argTsyn->kind != syntax::SyntaxKind::ImplicitType) {
                    if (auto* its2 = argTsyn->as_if<syntax::IntegerTypeSyntax>();
                        its2 && !its2->dimensions.empty())
                        setLoc((UHDM::BaseClass*)ts, its2->keyword.range());
                }
                if (pkgScope)
                    ((UHDM::typespec*)ts)->Instance((UHDM::instance*)m);
                rt->Actual_typespec(ts);
            }
            io->Typespec(rt);
            // Unpacked-array formals carry one range per unpacked dimension.
            if (arg->getDeclaredType() &&
                arg->getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType)
                if (auto* ranges = buildUnpackedRanges(*arg, io))
                    io->Ranges(ranges);
            ios->push_back(io);
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
        {
            auto* fvars = s.MakeVariablesVec();
            for (auto& fmv : sub.members()) {
                if (fmv.kind != SymbolKind::Variable || &fmv == sub.returnValVar)
                    continue;
                bool isArg = false;
                for (auto arg : sub.getArguments())
                    if (arg == &fmv)
                        isArg = true;
                if (isArg)
                    continue;
                auto* v = makeReturnVar(s, fmv.getDeclaredType()->getType());
                v->VpiName(fmv.name);
                v->VpiFullName(fullName + sep + std::string(fmv.name));
                v->VpiParent(tf);
                // Initialized locals anchor at the name (and are later
                // re-parented at their init assignment, without the
                // automatic flag).
                bool hasInit = fmv.getDeclaredType()->getInitializer() != nullptr;
                if (hasInit || pkgScope) {
                    setLoc(v, nameSpan(fmv.location, fmv.name));
                }
                else if (auto dt = fmv.getDeclaredType()) {
                    if (auto tsyn2 = dt->getTypeSyntax()) {
                        auto sr = tsyn2->sourceRange();
                        if (sr.start() != SourceLocation::NoLocation)
                            setLoc(v, sr);
                    }
                }
                tfContext = true;
                auto* vts = makeTypespec(fmv);
                tfContext = false;
                if (pkgScope)
                    vts->Instance((UHDM::instance*)m);
                auto* vrt = s.MakeRef_typespec();
                vrt->VpiFullName(fullName + sep + std::string(fmv.name));
                vrt->VpiParent(v);
                vrt->Actual_typespec(vts);
                v->Typespec(vrt);
                if (!hasInit && !pkgScope)
                    v->VpiAutomatic(true);
                funcMap[&fmv] = v;
                fvars->push_back(v);
            }
            if (!fvars->empty())
                tf->Variables(fvars);
        }

        // Register before the body so recursive calls bind this function.
        if (sharedScope || !subMap.count(&sub))
            subMap[&sub] = si;

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
        if (auto* st = emitStmt(sub.getBody(), tf, fullName, funcMap))
            tf->Stmt(st);
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
        else
            ((UHDM::instance*)m)->Task_funcs(tfs);
    }
    pkgScopeInst = savedPkgInst;
}

} // namespace slang_uhdm
