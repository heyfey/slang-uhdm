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
            auto* rv = s.MakeLogic_var();
            rv->VpiFullName(fullName);
            rv->VpiParent(tf);
            auto* ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
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
            auto* ts = sharedTypespec(*arg, ioTs);
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName + "." + std::string(arg->name));
            rt->VpiParent(io);
            rt->Actual_typespec(ts);
            io->Typespec(rt);
            ios->push_back(io);
            funcMap[arg] = io;
            si.argTs.push_back(ts);
        }
        if (!ios->empty())
            tf->Io_decls(ios);

        // Body: refs to the return value bind a local var that Surelog only
        // creates in the write phase; record them for late patching.
        pendingFuncRet.push_back({&sub, fullName, {}});
        size_t pfIdx = pendingFuncRet.size() - 1;
        auto* savedSym = funcRetSym;
        auto* savedRefs = funcRetRefs;
        funcRetSym = sub.returnValVar;
        funcRetRefs = &pendingFuncRet[pfIdx].refs;
        if (auto* st = emitStmt(sub.getBody(), tf, fullName, funcMap))
            tf->Stmt(st);
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
