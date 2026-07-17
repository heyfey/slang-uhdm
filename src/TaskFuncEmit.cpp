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


void UhdmExporter::emitTaskFuncs(const Scope& body, UHDM::instance* m,
                                 const std::string& prefix, DefInfo* info,
                                 bool sharedScope) {
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
        std::string fullName = joinPath(prefix, sub.name);

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
            tf->VpiDPICStr(2);
        }
        else if (sub.defaultLifetime == VariableLifetime::Automatic) {
            tf->VpiAutomatic(true);
        }
        if (auto syn = sub.getSyntax())
            setLoc(tf, syn->sourceRange());
        tf->Instance(m);

        SubInfo si;
        si.tf = tf;
        // Bodies see module-level nets too (shadowed formals override).
        NetMap funcMap;
        if (info)
            funcMap = info->nets;
        TsCache ioTs;

        // Function return: an anonymous variable carrying only the full name,
        // anchored at the return-type syntax like its typespec.
        if (isFunc && sub.returnValVar && !sub.getReturnType().isVoid()) {
            auto* rv = makeReturnVar(s, sub.getReturnType());
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            tfContext = true;
            auto* ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
            tfContext = false;
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName);
            rt->VpiParent(rv);
            rt->Actual_typespec(ts);
            if (pkgScope)
                ts->Instance(m);
            rv->Typespec(rt);
            copyLoc(rv, ts);
            ((UHDM::function*)tf)->Return(rv);
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
                    ((UHDM::typespec*)ts)->Instance(m);
                rt->Actual_typespec(ts);
            }
            io->Typespec(rt);
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
                auto* vts = makeTypespec(fmv);
                if (pkgScope)
                    vts->Instance(m);
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
        if (auto* st = emitStmt(sub.getBody(), tf, fullName, funcMap))
            tf->Stmt(st);
        currentTf = savedTf;
        currentSubSym = savedSubSym;
        funcRetSym = savedSym;
        funcRetRefs = savedRefs;

        if (info)
            info->taskFuncs.push_back(tf);
        tfs->push_back(tf);
    }
    if (!tfs->empty())
        m->Task_funcs(tfs);
    pkgScopeInst = savedPkgInst;
}

} // namespace slang_uhdm
