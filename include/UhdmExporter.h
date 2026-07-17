//------------------------------------------------------------------------------
//! @file UhdmExporter.h
//! @brief Exports a slang Compilation to a UHDM database (Surelog-compatible)
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <map>
#include <set>
#include <string>
#include <vector>

namespace slang::ast {
class Compilation;
class InstanceSymbol;
class InstanceBodySymbol;
class DefinitionSymbol;
class Symbol;
class Statement;
class Expression;
class ProceduralBlockSymbol;
class PortSymbol;
} // namespace slang::ast

namespace slang {
class SourceManager;
class SourceRange;
class SourceLocation;
} // namespace slang

#include <uhdm/uhdm.h>

namespace slang_uhdm {

/// Exports a slang elaborated design as a UHDM database, mirroring the
/// structure Surelog produces for its default (folded / pre-elab) output.
class UhdmExporter {
public:
    UhdmExporter(slang::ast::Compilation& compilation, UHDM::Serializer& serializer);

    /// Builds the UHDM design object tree. Returns the design root.
    UHDM::design* exportDesign();

    /// Names of AST node kinds that could not be mapped (empty on full success).
    const std::set<std::string>& unsupported() const { return unsupportedKinds; }

private:
    struct DefInfo {
        UHDM::module_inst* mod = nullptr;
        std::map<const slang::ast::Symbol*, UHDM::logic_net*> nets;
        std::vector<UHDM::process_stmt*> processes;
    };

    using TsCache = std::map<const void*, UHDM::logic_typespec*>;

    UHDM::module_inst* emitModuleDef(const slang::ast::InstanceSymbol& inst);
    UHDM::module_inst* emitTopModule(const slang::ast::InstanceSymbol& inst, DefInfo& def);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                   const std::string& prefix,
                   std::map<const slang::ast::Symbol*, UHDM::logic_net*>& netMap,
                   bool topView, TsCache* sharedTs);
    UHDM::process_stmt* emitProcess(const slang::ast::ProceduralBlockSymbol& block,
                                    UHDM::module_inst* m, const std::string& prefix,
                                    std::map<const slang::ast::Symbol*, UHDM::logic_net*>& netMap);
    UHDM::any* emitStmt(const slang::ast::Statement& stmt, UHDM::BaseClass* parent,
                        const std::string& prefix,
                        std::map<const slang::ast::Symbol*, UHDM::logic_net*>& netMap);
    UHDM::any* emitExpr(const slang::ast::Expression& expr, UHDM::BaseClass* parent,
                        const std::string& prefix,
                        std::map<const slang::ast::Symbol*, UHDM::logic_net*>& netMap);
    UHDM::logic_typespec* makeTypespec(const slang::ast::Symbol& declSymbol);
    UHDM::logic_typespec* sharedTypespec(const slang::ast::Symbol& declSymbol, TsCache& cache);

    void setLoc(UHDM::BaseClass* obj, slang::SourceRange range);
    void setLocNamed(UHDM::BaseClass* obj, const slang::ast::Symbol& symbol);
    std::string fullFilePath(slang::SourceLocation loc);
    void noteUnsupported(const std::string& what);

    slang::ast::Compilation& comp;
    UHDM::Serializer& s;
    const slang::SourceManager* sm;
    UHDM::design* d = nullptr;
    std::map<const slang::ast::DefinitionSymbol*, DefInfo> defMap;
    std::set<std::string> unsupportedKinds;
};

} // namespace slang_uhdm
