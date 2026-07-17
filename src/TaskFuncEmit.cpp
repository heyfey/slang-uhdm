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


void UhdmExporter::emitTaskFuncs(const InstanceBodySymbol& body, UHDM::module_inst* m,
                                 const std::string& prefix, DefInfo& info) {
    auto* tfs = s.MakeTask_funcVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Subroutine)
            continue;
        auto& sub = member.as<SubroutineSymbol>();
        bool isFunc = sub.subroutineKind == SubroutineKind::Function;
        std::string fullName = prefix + "." + std::string(sub.name);

        UHDM::task_func* tf = isFunc ? (UHDM::task_func*)s.MakeFunction()
                                     : (UHDM::task_func*)s.MakeTask();
        tf->VpiName(sub.name);
        tf->VpiFullName(fullName);
        tf->VpiParent(m);
        tf->VpiVisibility(1);
        if (sub.defaultLifetime == VariableLifetime::Automatic)
            tf->VpiAutomatic(true);
        if (auto syn = sub.getSyntax())
            setLoc(tf, syn->sourceRange());
        tf->Instance(m);

        SubInfo si;
        si.tf = tf;
        NetMap funcMap;
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
            rt->VpiFullName(fullName + "." + std::string(arg->name));
            rt->VpiParent(io);
            if (bareImplicit) {
                pendingIoTs.push_back({rt, argTsyn});
            }
            else {
                tfContext = true;
                ts = sharedTypespec(*arg, ioTs);
                tfContext = false;
                rt->Actual_typespec(ts);
            }
            io->Typespec(rt);
            ios->push_back(io);
            funcMap[arg] = io;
            si.argTs.push_back({ts, bareImplicit ? (const void*)argTsyn : nullptr});
        }
        if (!ios->empty())
            tf->Io_decls(ios);

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
                v->VpiFullName(fullName + "." + std::string(fmv.name));
                v->VpiParent(tf);
                if (auto dt = fmv.getDeclaredType()) {
                    if (auto tsyn2 = dt->getTypeSyntax()) {
                        auto sr = tsyn2->sourceRange();
                        if (sr.start() != SourceLocation::NoLocation)
                            setLoc(v, sr);
                    }
                }
                auto* vts = makeTypespec(fmv);
                auto* vrt = s.MakeRef_typespec();
                vrt->VpiFullName(fullName + "." + std::string(fmv.name));
                vrt->VpiParent(v);
                vrt->Actual_typespec(vts);
                v->Typespec(vrt);
                v->VpiAutomatic(true);
                funcMap[&fmv] = v;
                fvars->push_back(v);
            }
            if (!fvars->empty())
                tf->Variables(fvars);
        }

        // Body: refs to the return value bind a local var that Surelog only
        // creates in the write phase; record them for late patching.
        pendingFuncRet.push_back({&sub, fullName, {}});
        size_t pfIdx = pendingFuncRet.size() - 1;
        auto* savedSym = funcRetSym;
        auto* savedRefs = funcRetRefs;
        funcRetSym = sub.returnValVar;
        funcRetRefs = &pendingFuncRet[pfIdx].refs;
        auto* savedTf = currentTf;
        currentTf = tf;
        if (auto* st = emitStmt(sub.getBody(), tf, fullName, funcMap))
            tf->Stmt(st);
        currentTf = savedTf;
        funcRetSym = savedSym;
        funcRetRefs = savedRefs;

        subMap[&sub] = si;
        info.taskFuncs.push_back(tf);
        tfs->push_back(tf);
    }
    if (!tfs->empty())
        m->Task_funcs(tfs);
}

} // namespace slang_uhdm
