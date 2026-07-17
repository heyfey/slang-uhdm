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
class PackageSymbol;
class Scope;
class TimingControl;
class SubroutineSymbol;
class EnumType;
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
        TsCache defTs;
        std::vector<UHDM::task_func*> taskFuncs;
        std::vector<UHDM::typespec*> typedefs;
    };

    /// Per-subroutine emission products (call sites link to these). An arg
    /// typespec may be deferred (bare implicit): ts null, key set.
    struct SubInfo {
        UHDM::task_func* tf = nullptr;
        std::vector<std::pair<UHDM::typespec*, const void*>> argTs;
    };

    /// Function return-value local vars are created in the write phase; body
    /// refs to them are patched then.
    struct PendingFuncRet {
        const slang::ast::SubroutineSymbol* sub;
        std::string fullName;
        std::vector<UHDM::ref_obj*> refs;
    };

    struct PendingParamTs {
        const slang::ast::ParameterSymbol* ps;
        UHDM::parameter* up;
        UHDM::ref_typespec* prt;
        UHDM::ref_typespec* rhsRt;
        bool typedParam;
    };

    // Per top instance: state carried from the netlist pass to the second
    // (port + deferred-typespec) pass.
    struct TopPending {
        const slang::ast::InstanceSymbol* inst;
        UHDM::module_inst* m;
        std::string prefix;
        NetMap nets;
        size_t paramLo, paramHi, netTsLo, netTsHi;
    };

    UHDM::module_inst* emitModuleDef(const slang::ast::InstanceSymbol& inst, bool topDef);
    UHDM::module_inst* emitInstance(const slang::ast::InstanceSymbol& inst,
                                    const std::string& path, UHDM::module_inst* parentM,
                                    NetMap* parentNets,
                                    std::set<const slang::ast::Symbol*>* parentRefs, bool isTop);
    void emitTopPorts(TopPending& tp);
    void emitGenScopes(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                       const std::string& prefix, NetMap& netMap);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                   const std::string& prefix, NetMap& netMap, bool topView, TsCache* sharedTs);
    void emitParameters(const slang::ast::Scope& body, UHDM::scope* m, const std::string& prefix,
                        NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                        bool topShareTs = false, bool funcScope = false);
    UHDM::package* emitPackage(const slang::ast::PackageSymbol& pkg, bool topView);
    void emitTaskFuncs(const slang::ast::Scope& body, UHDM::instance* m,
                       const std::string& prefix, DefInfo* info, bool sharedScope = true);
    void emitTypedefs(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                      const std::string& prefix, DefInfo& info);
    UHDM::enum_typespec* buildEnumTs(const slang::ast::EnumType& et,
                                     const slang::syntax::SyntaxNode* enumSyn,
                                     const std::string& refFullName);
    UHDM::struct_typespec* buildStructTs(const slang::ast::Scope& structScope, bool packed,
                                         const std::string& aliasName);
    void emitContAssigns(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                         const std::string& prefix, NetMap& netMap, bool topView,
                         DefInfo* defInfo, bool shareWithDef,
                         std::set<const slang::ast::Symbol*>* instRefs,
                         std::set<const slang::ast::Symbol*>* lhsSyms);
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
    void patchParamTypespecs(size_t lo, size_t hi);
    UHDM::typespec* makeParamTs(const slang::ast::ParameterSymbol& ps, bool typedParam,
                                bool parentBounds = false);

    UHDM::typespec* makeTypespec(const slang::ast::Symbol& declSymbol,
                                 const slang::syntax::SyntaxNode* typeSynOverride = nullptr,
                                 const slang::ast::PortSymbol* portCtx = nullptr);
    UHDM::typespec* sharedTypespec(const slang::ast::Symbol& declSymbol, TsCache& cache,
                                   const slang::ast::PortSymbol* portCtx = nullptr);
    UHDM::constant* makeBoundConst(const slang::syntax::SyntaxNode* syn, int64_t value,
                                   UHDM::BaseClass* parent);
    /// Unfolded range-bound expression built from syntax (function/typedef
    /// typespecs keep "SIZE-1" as an operation tree with name-only refs).
    UHDM::any* emitSyntaxExpr(const slang::syntax::SyntaxNode& syn, UHDM::BaseClass* parent);
    /// Creates a top-view variable object for symbols whose type makes them
    /// variables in Surelog's model (int, integer, ...); null if the symbol
    /// stays a net.
    UHDM::variables* makeVar(const slang::ast::Symbol& internal, bool portBacked);

    void setLoc(UHDM::BaseClass* obj, slang::SourceRange range);
    void setLocNamed(UHDM::BaseClass* obj, const slang::ast::Symbol& symbol);
    /// Name span at loc; escaped identifiers get Surelog's name+6 width.
    slang::SourceRange nameSpan(slang::SourceLocation loc, std::string_view name);
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
    bool callStmtContext = false;
    // Parameter-init contexts keep name-token-only sys call spans.
    bool inParamInit = false;
    // Surelog can't resolve block-scoped localparams; refs to them bind an
    // implicit module-level wire created at the first reference.
    std::map<const slang::ast::Symbol*, UHDM::logic_net*> implicitNetMap;
    UHDM::module_inst* implicitNetModule = nullptr;
    std::string implicitNetPrefix;
    // Cast-size exprs also keep name-token-only call spans.
    bool inCastSize = false;
    // Refs inside indexed-part-select base/width exprs are scoped by the
    // select base name.
    std::string selectBasePrefix;
    // Root prefix of the top instance currently being emitted (bind
    // instances DISPLAY directly under it while contents keep real paths).
    std::string currentTopPrefix;
    std::string bindDisplayPath;
    NetMap* currentTopNets = nullptr;
    // Scope for late syntax binding (cast size exprs).
    const slang::ast::Scope* currentScope = nullptr;
    std::map<const slang::ast::Symbol*, bool> paramIntEnc;
    std::vector<PendingParamTs> pendingParamTs;
    // Def-view local-net typespecs are created only after the top-level
    // instance's ports have been elaborated (Surelog arena order).
    struct PendingNetTs {
        const slang::ast::Symbol* sym;
        UHDM::ref_typespec* rt;
        DefInfo* di;
    };
    std::vector<PendingNetTs> pendingNetTs;
    void materializeDefNetTs(PendingNetTs& pn);
    std::vector<TopPending> topPendings;
    std::map<const slang::ast::Symbol*, SubInfo> subMap;
    // Typedef typespecs shared across views; enum consts for value refs.
    std::map<const slang::ast::Symbol*, UHDM::typespec*> typedefTs;
    // Vector typedefs: the write-side clone referenced via TypedefAlias.
    std::map<const slang::ast::Symbol*, UHDM::typespec*> typedefClone;
    // Instance-view refs to vector typedefs, patched with the late wrapper.
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Symbol*>> pendingAliasRefs;
    // Re-emitted size-cast typespecs are created at the end of the write
    // phase: {ref to patch, literal range, INT value string}.
    struct PendingCastTs {
        UHDM::ref_typespec* rt;
        uint32_t line, col, endLine, endCol;
        std::string value;
        // Non-literal sizes: the bound size expression emitted at drain.
        const slang::ast::Expression* sizeExpr = nullptr;
        std::string prefix;
    };
    std::vector<PendingCastTs> pendingCastTs;
    // Abandoned first-compile of re-emitted pattern cont_assigns: an orphan
    // op sharing the def operands, typed by the pattern's target typespec.
    struct PendingPatternOrphan {
        UHDM::cont_assign* defCa;
        UHDM::operation* defOp;
        uint32_t line, col, endLine, endCol;
        UHDM::typespec* ts;
    };
    std::vector<PendingPatternOrphan> pendingPatternOrphans;
    std::map<const slang::ast::Symbol*, UHDM::any*> enumConstMap;
    std::map<const slang::ast::Symbol*, UHDM::attribute*> attrMap;
    std::vector<PendingFuncRet> pendingFuncRet;
    // Bare implicit io-decl typespecs (unlocated) are created at the very
    // end of the write phase; keyed by type syntax for decl-group sharing.
    std::vector<std::pair<UHDM::ref_typespec*, const void*>> pendingIoTs;
    const slang::ast::Symbol* funcRetSym = nullptr;
    std::vector<UHDM::ref_obj*>* funcRetRefs = nullptr;
    // In shared processes, only call-argument refs count for var typespec
    // reparenting (Surelog computes arg types; plain refs don't touch ts).
    bool inProcessEmit = false;
    int callArgDepth = 0;
    // Task/function typespecs keep unfolded range expressions; module-level
    // typespecs fold them to INT constants.
    bool tfContext = false;
    // Skip the shared-typedef shortcut (def-net drains clone vector
    // typedefs fresh).
    bool bypassTypedefShare = false;
    // Set while emitting a task/function body: case-item expr refs parent
    // at the tf object.
    UHDM::task_func* currentTf = nullptr;
    // When set, emitSyntaxExpr refs carry this scope prefix in VpiFullName.
    std::string syntaxRefPrefix;
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgParamConst;
    std::set<const slang::ast::Symbol*>* refCollector = nullptr;
};

} // namespace slang_uhdm
