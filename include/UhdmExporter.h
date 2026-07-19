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
class Type;
class AssertionExpr;
class ProceduralBlockSymbol;
class PortSymbol;
class InterfacePortSymbol;
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
        std::vector<UHDM::concurrent_assertions*> assertions;
        UHDM::clocking_block* defaultClocking = nullptr;
    };
    // Concurrent assertion (folded pre-elab form: label, clocking event as
    // a property_spec, else action). Returns null if not an assertion block.
    UHDM::concurrent_assertions* emitAssertion(const slang::ast::ProceduralBlockSymbol& pb,
                                               UHDM::module_inst* m, const std::string& prefix,
                                               NetMap& netMap);
    // A property/sequence expression tree -> UHDM operation/leaf.
    UHDM::any* emitAssertionExpr(const slang::ast::AssertionExpr& ae, UHDM::BaseClass* parent,
                                 const std::string& prefix, NetMap& netMap);
    // The module's default clocking block (default clocking @(...);), or null.
    UHDM::clocking_block* emitDefaultClocking(const slang::ast::InstanceBodySymbol& body,
                                              UHDM::module_inst* m, const std::string& prefix,
                                              NetMap& netMap);

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
        UHDM::instance* inst = nullptr; // package owner (ts vpiInstance)
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
    UHDM::module_inst* emitModuleDefPorts(const slang::ast::InstanceSymbol& inst);
    UHDM::module_inst* emitInstance(const slang::ast::InstanceSymbol& inst,
                                    const std::string& path, UHDM::module_inst* parentM,
                                    NetMap* parentNets,
                                    std::set<const slang::ast::Symbol*>* parentRefs, bool isTop);
    // Interfaces are emitted as interface_inst (design->AllInterfaces), not
    // module_inst. emitInterfaceDef builds the generic def (nets); the elab
    // instance (vars + init) is referenced from a parent module via
    // Interfaces() (elab) and a ref_module whose Actual is the def (def view).
    // The interface_typespec for an InterfacePort: a modport typespec
    // (vpiIsModPort) whose parent is the base interface typespec.
    UHDM::interface_typespec* makeIfacePortTs(const slang::ast::InterfacePortSymbol& ip);
    // Dotted interface-member path (s.req.adr) -> hier_path with per-token
    // ref_obj elements; the LAST element carries a module-scoped fullname.
    UHDM::hier_path* buildDottedHierPath(const slang::ast::Expression& expr,
                                         const std::string& dotted,
                                         UHDM::BaseClass* parent, const std::string& prefix);
    // Surelog dump-artifact: a col-0 "reference-style" interface_inst duplicate
    // of an interface's home view. It shares the home view's variable objects
    // and is referenced only weakly (from a receiving module port's HighConn
    // ref_obj), so the dumper lists it in the weaklyReferenced tail. Semantically
    // redundant (see NOTES) — a future switch (default off) can skip it.
    UHDM::interface_inst* makeIfaceRefDup(const slang::ast::InstanceSymbol& inst,
                                          const std::string& path,
                                          UHDM::module_inst* parentM, NetMap& sharedNets);
    // Package enum-const module-fold constants (shared across views).
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgEnumFoldConst;
    // Named begin/fork blocks by symbol (disable targets resolve to these).
    std::map<const void*, UHDM::scope*> namedBlockMap;
    // Interface instance -> its col-0 tail duplicate (see makeIfaceRefDup).
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifaceTailDup;
    UHDM::interface_inst* emitInterfaceDef(const slang::ast::InstanceSymbol& inst);
    UHDM::interface_inst* emitInterfaceInstance(const slang::ast::InstanceSymbol& inst,
                                                const std::string& path,
                                                UHDM::module_inst* parentM, NetMap* parentNets,
                                                std::set<const slang::ast::Symbol*>* parentRefs,
                                                const slang::ast::InstanceSymbol* portView = nullptr);
    void emitTopPorts(TopPending& tp);
    void emitGenScopes(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                       const std::string& prefix, NetMap& netMap);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                   const std::string& prefix, NetMap& netMap, bool topView, TsCache* sharedTs);
    void emitParameters(const slang::ast::Scope& body, UHDM::scope* m, const std::string& prefix,
                        NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                        bool topShareTs = false, bool funcScope = false);
    UHDM::package* emitPackage(const slang::ast::PackageSymbol& pkg, bool topView);
    void emitTaskFuncs(const slang::ast::Scope& body, UHDM::BaseClass* m,
                       const std::string& prefix, DefInfo* info, bool sharedScope = true);
    void emitTypedefs(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                      const std::string& prefix, DefInfo& info);
    UHDM::enum_typespec* buildEnumTs(const slang::ast::EnumType& et,
                                     const slang::syntax::SyntaxNode* enumSyn,
                                     const std::string& refFullName,
                                     bool implicitBaseRef = false);
    UHDM::union_typespec* buildUnionTs(const slang::ast::Scope& unionScope, bool packed,
                                       const std::string& aliasName,
                                       const std::string& memberSep = ".");
    UHDM::struct_typespec* buildStructTs(const slang::ast::Scope& structScope, bool packed,
                                         const std::string& aliasName,
                                         const std::string& memberSep = ".");
    void emitContAssigns(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                         const std::string& prefix, NetMap& netMap, bool topView,
                         DefInfo* defInfo, bool shareWithDef,
                         std::set<const slang::ast::Symbol*>* instRefs,
                         std::set<const slang::ast::Symbol*>* lhsSyms);
    UHDM::process_stmt* emitProcess(const slang::ast::ProceduralBlockSymbol& block,
                                    UHDM::instance* m, const std::string& prefix,
                                    NetMap& netMap);
    UHDM::any* emitStmt(const slang::ast::Statement& stmt, UHDM::BaseClass* parent,
                        const std::string& prefix, NetMap& netMap);
    UHDM::any* emitEventExpr(const slang::ast::TimingControl& tc, UHDM::BaseClass* parent,
                             const std::string& prefix, NetMap& netMap);
    UHDM::any* emitExpr(const slang::ast::Expression& expr, UHDM::BaseClass* parent,
                        const std::string& prefix, NetMap& netMap);
    // b.a[0].x / a[0].min_v -> hier_path threading bit_select elements through
    // selected members. Returns null (caller notes unsupported) if the chain
    // has a shape this doesn't handle yet (e.g. multi-select on one member).
    UHDM::hier_path* emitMixedHierPath(const slang::ast::Expression& expr,
                                       UHDM::BaseClass* parent, const std::string& prefix,
                                       NetMap& netMap);
    UHDM::any* tryFoldConst(const slang::ast::Expression& expr);
    bool isIntEncoded(const slang::ast::Expression& e);
    void analyzeParamEnc(const slang::ast::InstanceBodySymbol& body);
    void patchParamTypespecs(size_t lo, size_t hi);
    UHDM::typespec* makeBareVecParamTs(const slang::ast::ParameterSymbol& ps,
                                       bool parentBounds);
    UHDM::typespec* makeParamTs(const slang::ast::ParameterSymbol& ps, bool typedParam,
                                bool parentBounds = false);
    bool isRangedUntypedParam(const slang::ast::ParameterSymbol& ps);

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
    // Instance-view array_var for unpacked-array signals (null otherwise).
    UHDM::array_var* emitArrayVar(const slang::ast::Symbol& sym, const std::string& name,
                                  const std::string& fullName, UHDM::module_inst* m,
                                  UHDM::typespec* elemTs);
    // Top(elab)-view packed-array-of-struct var (filter_ctl_t [1:0][2:0] a):
    // packed_array_var { vpiRange x N + vpiElement = struct_var }.
    UHDM::packed_array_var* emitPackedStructArrayVar(const slang::ast::Symbol& sym,
                                                     const std::string& name,
                                                     const std::string& fullName,
                                                     UHDM::module_inst* m);
    // One uhdm range per unpacked dimension (bounds from ConstantRange, loc
    // from the declarator dimension syntax), each parented at `parent`.
    UHDM::VectorOfrange* buildUnpackedRanges(const slang::ast::Symbol& sym,
                                             UHDM::BaseClass* parent);

    void setLoc(UHDM::BaseClass* obj, slang::SourceRange range);
    void setLocNamed(UHDM::BaseClass* obj, const slang::ast::Symbol& symbol);
    /// Name span at loc; escaped identifiers get Surelog's name+6 width.
    slang::SourceRange nameSpan(slang::SourceLocation loc, std::string_view name);
    // A net's anchor span: the name token, or the whole declarator (name..init)
    // for a reg variable emitted as a net with an initializer (reg b = 0).
    slang::SourceRange regNetSpan(const slang::ast::Symbol& sym);
    std::string fullFilePath(slang::SourceLocation loc);
    std::string rawText(slang::SourceRange range);
    void noteUnsupported(const std::string& what);

    slang::ast::Compilation& comp;
    UHDM::Serializer& s;
    const slang::SourceManager* sm;
    UHDM::design* d = nullptr;
    std::map<const slang::ast::DefinitionSymbol*, DefInfo> defMap;
    // Interface definitions -> their def-view interface_inst shell (referenced
    // by a parent module's ref_module Actual in the def view).
    std::map<const slang::ast::DefinitionSymbol*, UHDM::interface_inst*> ifaceDefMap;
    // (interface definition, modport name) -> emitted modport object, so an
    // InterfacePort can bind its LowConn to the modport.
    std::map<const slang::ast::DefinitionSymbol*, std::map<std::string, UHDM::modport*>>
        modportsByDef;
    // Elaborated interface instance -> its interface_inst, so a sibling
    // module's InterfacePort HighConn can point at the connected instance.
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifaceInstMap;
    std::map<const slang::ast::Symbol*, UHDM::net*> ifaceConnNet;
    std::set<std::string> unsupportedKinds;
    bool suppressConstParent = false;
    bool reemitting = false;
    // True while emitting elements of an enclosing assignment pattern (so
    // nested-pattern element constants keep the bare-decimal default size).
    bool inAssignPattern = false;
    bool forceConstParent = false;
    bool inLhs = false;
    // True while emitting an elaborated generate-scope process: refs to outer
    // (module) signals are left unbound (no Actual_group), as Surelog does.
    bool suppressRefActual = false;
    bool callStmtContext = false;
    // Parameter-init contexts keep name-token-only sys call spans.
    bool inParamInit = false;
    // Surelog can't resolve block-scoped localparams; refs to them bind an
    // implicit module-level wire created at the first reference.
    std::map<const slang::ast::Symbol*, UHDM::logic_net*> implicitNetMap;
    UHDM::module_inst* implicitNetModule = nullptr;
    std::string implicitNetPrefix;
    // Package scope currently emitting task_funcs (ts vpiInstance owner).
    UHDM::instance* pkgScopeInst = nullptr;
    // Unqualified calls to package functions, per module def body.
    std::map<const void*, std::vector<UHDM::task_func*>> importedTfCalls;
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
    bool rangeRefsOverriddenParam(const slang::ast::Symbol& sym);
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
        // Type casts: build the target-type typespec at drain instead.
        const slang::ast::Type* castType = nullptr;
    };
    std::vector<PendingCastTs> pendingCastTs;
    // Net-declaration-assignment Lhs typespecs: created at the very end of the
    // write phase so they land last in the arena (matching Surelog's tail).
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Symbol*>> pendingNetDeclTs;
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
    // Refs to enum values whose enum_const is built later (anonymous enums,
    // materialized in the deferred typespec pass) are bound at the very end.
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>> pendingEnumRefs;
    // $signed/$unsigned sys_func_call result typespecs share the LHS port's
    // (deferred) actual typespec; fall back to a fresh typespec if unresolved.
    struct PendingSysFuncTs {
        UHDM::ref_typespec* rt;
        UHDM::module_inst* mod;
        const slang::ast::Symbol* sym;
    };
    std::vector<PendingSysFuncTs> pendingSysFuncTs;
    std::map<const slang::ast::Symbol*, std::vector<UHDM::attribute*>> attrMap;
    std::vector<PendingFuncRet> pendingFuncRet;
    void drainFuncRet(bool pkgOnly = false);
    void emitImportArtifacts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m);
    // Straight-line constant reduction of user calls / simple exprs.
    struct CallFold {
        const slang::ast::Expression* lit = nullptr;
        const slang::ast::ParameterSymbol* param = nullptr;
        const slang::ast::Expression* site = nullptr;
        const slang::ast::SubroutineSymbol* directSub = nullptr;
        // True when this fold came from an executed return (so an enclosing
        // straight-line list must stop, not fall through to a later return).
        bool terminal = false;
        explicit operator bool() const { return lit || param; }
    };
    CallFold constCallFold(const slang::ast::Expression& expr);
    CallFold resolveConstExpr(const slang::ast::Expression& expr);
    bool pkgTopEmit = false;
    // Child-instance CA re-emission folds type casts (top modules keep them).
    bool foldTypeCasts = false;
    const slang::ast::SubroutineSymbol* currentSubSym = nullptr;
    std::map<const void*, UHDM::constant*> foldedRet;
    std::map<const void*, UHDM::typespec*> foldCloneTs;
    struct PendingParamCloneTs {
        UHDM::ref_typespec* rt;
        const slang::ast::ParameterSymbol* ps;
    };
    std::vector<PendingParamCloneTs> pendingParamCloneTs;
    std::map<const void*, UHDM::package*> pkgDefMap;
    // Package TypeAlias -> its TOP-view typespec (interfaces that import it
    // re-parent/list the SHARED object).
    std::map<const void*, UHDM::typespec*> pkgTopTypedefTs;
    // Def-view type-cast typespecs, pre-created at module-compile time.
    std::map<const void*, UHDM::typespec*> castTsCache;
    // Bare implicit io-decl typespecs (unlocated) are created at the very
    // end of the write phase; keyed by type syntax for decl-group sharing.
    std::vector<std::pair<UHDM::ref_typespec*, const void*>> pendingIoTs;
    // Gen-scope genvar param int_typespecs drain LAST (after net-decl typespecs).
    std::vector<UHDM::ref_typespec*> pendingGenvarTs;
    // Signed size-cast fold result typespecs (signed logic_typespec) drain at
    // the very end of the arena tail.
    std::vector<UHDM::ref_typespec*> pendingSignedCastTs;
    const slang::ast::Symbol* funcRetSym = nullptr;
    std::vector<UHDM::ref_obj*>* funcRetRefs = nullptr;
    // In shared processes, only call-argument refs count for var typespec
    // reparenting (Surelog computes arg types; plain refs don't touch ts).
    bool inProcessEmit = false;
    // Surelog quirk: inside a procedural/function body, a WHOLE reference to a
    // variable that is elsewhere WRITTEN via a bit/part/indexed-select binds its
    // Actual to that variable's first select object (not its net/var/io_decl).
    // Tracked per body and back-patched at the end.
    bool selTrackActive = false;
    std::map<const slang::ast::Symbol*, UHDM::expr*> selFirstSelect;
    std::set<const slang::ast::Symbol*> selLhsSelVars;
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>> selWholeRefs;
    bool beginSelTrack();  // returns true if it newly activated tracking
    void endSelTrack();    // back-patches whole-refs and clears state
    void noteSelectObj(const slang::ast::Symbol* base, UHDM::any* selObj);
    int callArgDepth = 0;
    // Task/function typespecs keep unfolded range expressions; module-level
    // typespecs fold them to INT constants.
    bool tfContext = false;
    // True only while emitting a NAMED typedef's typespec: Surelog folds
    // type-query bounds ($bits(t)) there, but keeps them as sys_func_call in a
    // variable's inline/anonymous type. Gates the $bits fold in emitSyntaxExpr.
    bool typedefTsContext = false;
    // Skip the shared-typedef shortcut (def-net drains clone vector
    // typedefs fresh).
    bool bypassTypedefShare = false;
    // Set while emitting a task/function body: case-item expr refs parent
    // at the tf object.
    UHDM::task_func* currentTf = nullptr;
    // When set, emitSyntaxExpr refs carry this scope prefix in VpiFullName.
    std::string syntaxRefPrefix;
    std::string syntaxRefSep = ".";
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgParamConst;
    // Def-view fold-constant ts refs of VECTOR-typed params: bound late to a
    // fresh LOC-LESS bare clone (see patchParamTypespecs).
    std::map<const slang::ast::Symbol*, UHDM::ref_typespec*> pendingBareVecTs;
    std::set<const slang::ast::Symbol*>* refCollector = nullptr;
};

} // namespace slang_uhdm
