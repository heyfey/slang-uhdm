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
class ParameterSymbol;
class TimingControl;
} // namespace slang::ast

namespace slang {
class SourceManager;
class SourceRange;
class SourceLocation;
} // namespace slang

namespace slang::syntax {
class SyntaxNode;
} // namespace slang::syntax

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
    /// Maps slang value symbols to the UHDM net/variable object of the
    /// current view (definition or top instance).
    using NetMap = std::map<const slang::ast::Symbol*, UHDM::any*>;
    /// Shares typespec objects per declaration (Surelog TypespecCache).
    using TsCache = std::map<const void*, UHDM::typespec*>;

    struct DefInfo {
        UHDM::module_inst* mod = nullptr;
        bool filled = false;
        NetMap nets;
        std::vector<UHDM::process_stmt*> processes;
        std::vector<UHDM::cont_assign*> contAssigns;
        std::set<const slang::ast::Symbol*> processRefs;
        std::map<const slang::ast::Symbol*, UHDM::typespec*> paramTs;
    };

    struct PendingParamTs {
        const slang::ast::ParameterSymbol* ps;
        UHDM::parameter* up;
        UHDM::ref_typespec* prt;
        UHDM::ref_typespec* rhsRt;
        bool typedParam;
    };

    UHDM::module_inst* emitModuleDef(const slang::ast::InstanceSymbol& inst);
    UHDM::module_inst* emitInstance(const slang::ast::InstanceSymbol& inst,
                                    const std::string& path, UHDM::module_inst* parentM,
                                    NetMap* parentNets,
                                    std::set<const slang::ast::Symbol*>* parentRefs, bool isTop);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                   const std::string& prefix, NetMap& netMap, bool topView, TsCache* sharedTs);
    void emitParameters(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                        const std::string& prefix, NetMap& netMap, bool topView, DefInfo* di);
    void emitContAssigns(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                         const std::string& prefix, NetMap& netMap, bool topView,
                         DefInfo* defInfo, bool shareWithDef,
                         std::set<const slang::ast::Symbol*>* instRefs);
    UHDM::process_stmt* emitProcess(const slang::ast::ProceduralBlockSymbol& block,
                                    UHDM::module_inst* m, const std::string& prefix,
                                    NetMap& netMap);
    UHDM::any* emitStmt(const slang::ast::Statement& stmt, UHDM::BaseClass* parent,
                        const std::string& prefix, NetMap& netMap);
    UHDM::any* emitEventExpr(const slang::ast::TimingControl& tc, UHDM::BaseClass* parent,
                             const std::string& prefix, NetMap& netMap);
    UHDM::any* emitExpr(const slang::ast::Expression& expr, UHDM::BaseClass* parent,
                        const std::string& prefix, NetMap& netMap);
    UHDM::any* tryFoldConst(const slang::ast::Expression& expr);
    bool isIntEncoded(const slang::ast::Expression& e);
    void analyzeParamEnc(const slang::ast::InstanceBodySymbol& body);
    void patchParamTypespecs();
    UHDM::typespec* makeParamTs(const slang::ast::ParameterSymbol& ps, bool typedParam);

    UHDM::typespec* makeTypespec(const slang::ast::Symbol& declSymbol);
    UHDM::typespec* sharedTypespec(const slang::ast::Symbol& declSymbol, TsCache& cache);
    UHDM::constant* makeBoundConst(const slang::syntax::SyntaxNode* syn, int64_t value,
                                   UHDM::BaseClass* parent);
    /// Creates a top-view variable object for symbols whose type makes them
    /// variables in Surelog's model (int, integer, ...); null if the symbol
    /// stays a net.
    UHDM::variables* makeVar(const slang::ast::Symbol& internal, bool portBacked);

    void setLoc(UHDM::BaseClass* obj, slang::SourceRange range);
    void setLocNamed(UHDM::BaseClass* obj, const slang::ast::Symbol& symbol);
    std::string fullFilePath(slang::SourceLocation loc);
    std::string rawText(slang::SourceRange range);
    void noteUnsupported(const std::string& what);

    slang::ast::Compilation& comp;
    UHDM::Serializer& s;
    const slang::SourceManager* sm;
    UHDM::design* d = nullptr;
    std::map<const slang::ast::DefinitionSymbol*, DefInfo> defMap;
    std::set<std::string> unsupportedKinds;
    bool suppressConstParent = false;
    bool reemitting = false;
    bool forceConstParent = false;
    bool inLhs = false;
    std::map<const slang::ast::Symbol*, bool> paramIntEnc;
    std::vector<PendingParamTs> pendingParamTs;
    std::set<const slang::ast::Symbol*>* refCollector = nullptr;
};

} // namespace slang_uhdm
