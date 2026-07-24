//------------------------------------------------------------------------------
//! @file UhdmExporter.h
//! @brief Exports a slang Compilation to a UHDM database (Surelog-compatible)
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace slang::ast {
class Compilation;
class ClassType;
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
class InstanceArraySymbol;
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
struct DataTypeSyntax;
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
    // NAMED clocking blocks (clocking cb @(posedge clk); input a; ...) on
    // interfaces: clocking_block + event + clocking_io_decls. Def-view event
    // refs bind cross-view (the ELAB var) — collected in pendingCbRefs and
    // drained at the end of exportDesign.
    void emitNamedClockingBlocks(const slang::ast::InstanceBodySymbol& body,
                                 UHDM::instance* m, const std::string& prefix,
                                 NetMap& nm, bool defView);
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>>
        pendingCbRefs;

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

    // DEF-view params typed by a NAMED AGGREGATE typedef (struct/union/enum
    // alias): their ts binding defers past emitTypedefs so they can share the
    // named typedef typespec (Surelog's def param ref points at the ONE
    // typedef object). Drained in exportDesign after the def-content loop.
    struct PendingDefParamTs {
        const slang::ast::ParameterSymbol* ps;
        UHDM::parameter* up;
        UHDM::ref_typespec* prt;
        UHDM::ref_typespec* rhsRt;
        bool typedParam;
        UHDM::scope* m;
        const slang::ast::Symbol* member;
        DefInfo* di;
        bool inPackage;
        std::string refFullName;
    };
    std::vector<PendingDefParamTs> pendingDefParamTs;
    void drainDefParamTs();
    // True while building an elab struct/union param ts CLONE: member leaf
    // typespecs parent at the member's ref_typespec (Surelog clone form)
    // instead of the typespec_member.
    bool structCloneMemberRefParent = false;
    // True while emitting a TYPE-dimension bound expression: syntax
    // func_calls anchor at the callee NAME token (Surelog).
    bool boundCallNameSpan = false;
    // True while drainDefParamTs builds DEF-view param typespec clones —
    // those omit the module Instance link the ELAB clones carry.
    bool defViewParamTs = false;
    // True while emitting a NON-TOP elaborated child-instance body: a packed
    // range bound that reaches an interface param through a modport/interface
    // port FOLDS to its concrete per-instance width here (Surelog), whereas the
    // generic DEF view keeps the symbolic op tree.
    bool elabInstanceTs = false;
    // True while emitting a gen-scope child instance's conns: genvar/localparam
    // refs belonging to a GenerateBlock fold to their per-index constants
    // (Surelog folds them in INSTANCE CONNS but not process bodies).
    bool genvarConnFold = false;
    // Conn-name prefix for gen-scope children (the gen scope's fullname).
    std::string genConnPrefix;

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
    UHDM::class_defn* emitClassDefn(const slang::ast::ClassType& cls,
                                    const std::string& dispName,
                                    const std::string& fullName,
                                    UHDM::BaseClass* parent);
    UHDM::interface_inst* makeIfaceRefDup(const slang::ast::InstanceSymbol& inst,
                                          const std::string& path,
                                          UHDM::module_inst* parentM, NetMap& sharedNets,
                                          UHDM::interface_inst* dup0 = nullptr,
                                          UHDM::interface_inst* home = nullptr);
    // DEF-view package struct typespecs, for the cross-view member-actual
    // swap (Surelog wires the first-created member ts into the TOP struct).
    std::map<const slang::ast::Symbol*, UHDM::struct_typespec*> pkgDefStructTs;
    // DEF-view package union typespecs, for the same cross-view swap.
    std::map<const slang::ast::Symbol*, UHDM::union_typespec*> pkgDefUnionTs;
    // Package enum-const module-fold constants (shared across views).
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgEnumFoldConst;
    // Named begin/fork blocks by symbol (disable targets resolve to these).
    std::map<const void*, UHDM::scope*> namedBlockMap;
    // Plain (no-modport) DEF iface-port typespec refs; their actuals are
    // created after the receiving child's port-view emission (arena order).
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::InterfacePortSymbol*>>
        pendingIfacePortTs;
    // Defs whose ONLY instance was a dropped in-generate bind: their port
    // phase runs in the write phase instead.
    std::set<const slang::ast::Symbol*> droppedBindDefs;
    // InterfacePortSymbol -> its instance-scoped port view (passthrough
    // children bind their HighConn at the enclosing module's view).
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifacePortViewMap;
    // Interface instance -> its col-0 tail duplicate (see makeIfaceRefDup).
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifaceTailDup;
    UHDM::interface_inst* emitInterfaceDef(const slang::ast::InstanceSymbol& inst);
    UHDM::interface_inst* emitInterfaceInstance(const slang::ast::InstanceSymbol& inst,
                                                const std::string& path,
                                                UHDM::module_inst* parentM, NetMap* parentNets,
                                                std::set<const slang::ast::Symbol*>* parentRefs,
                                                const slang::ast::InstanceSymbol* portView = nullptr,
                                                const std::string& connModport = "");
    void emitTopPorts(TopPending& tp);
    void emitGenScopes(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                       const std::string& prefix, NetMap& netMap);
    void emitDefGenStmts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                         const std::string& prefix);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                   const std::string& prefix, NetMap& netMap, bool topView, TsCache* sharedTs);
    void emitParameters(const slang::ast::Scope& body, UHDM::scope* m, const std::string& prefix,
                        NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                        bool topShareTs = false, bool funcScope = false);
    UHDM::package* emitPackage(const slang::ast::PackageSymbol& pkg, bool topView);
    void emitTaskFuncs(const slang::ast::Scope& body, UHDM::BaseClass* m,
                       const std::string& prefix, DefInfo* info, bool sharedScope = true,
                       const slang::ast::Symbol* onlySub = nullptr);
    void emitTypedefs(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
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
    void emitGates(const slang::ast::InstanceBodySymbol& body, UHDM::module_inst* m,
                   const std::string& prefix, NetMap& netMap, bool topView);
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
    UHDM::any* tryFoldConst(const slang::ast::Expression& expr,
                            const slang::ast::Expression* typedConv = nullptr);
    bool isIntEncoded(const slang::ast::Expression& e);
    void analyzeParamEnc(const slang::ast::InstanceBodySymbol& body);
    // Design-global pre-pass: definitions instantiated with MULTIPLE DISTINCT
    // parameter-value tuples (Surelog uniquifies these; their untyped overrides
    // encode UINT/size32/ct9, and parameterized interface port-views keep a
    // param_assign). Populated by computeParamMultiplicity().
    std::set<const slang::ast::DefinitionSymbol*> multiParamDefs;
    // Defs with >1 DISTINCT #(...) override raw text (pre-elab textual
    // uniquification, realexpr).
    std::set<const slang::ast::DefinitionSymbol*> textMultiParamDefs;
    void computeParamMultiplicity();
    bool isMultiParamDef(const slang::ast::Scope& body) const;
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
    /// A port typed by a vector typedef (file-level or module-local net) gets
    /// its vpiTypedef its OWN self-alias clone (a fresh logic_typespec named
    /// after the typedef, Typedef_alias -> the shared base ts) instead of the
    /// bare shared base — mirroring what the net's typespec gets. Returns
    /// nullptr when the port's type does not qualify (share the base instead).
    UHDM::logic_typespec* portVectorTypedefClone(const slang::ast::Symbol& internal,
                                                 bool withInstance = false);
    /// Def-view typespec for a `parameter type T = <default>` — resolved from
    /// the DEFAULT type syntax (the instance body borrowed for the def view may
    /// carry an override), independent of any instance parameterization.
    UHDM::typespec* makeTypeParamDefaultTs(const slang::syntax::DataTypeSyntax& defSyn,
                                           const slang::ast::Scope& body);
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
                                  const std::string& fullName, UHDM::BaseClass* m,
                                  UHDM::typespec* elemTs);
    // Instance-view array_net for an unpacked array of a NET-type leaf
    // (reg/logic memory): array_net { vpiRange x N + vpiNet = logic_net }.
    UHDM::array_net* emitArrayNet(const slang::ast::Symbol& sym, const std::string& name,
                                  const std::string& fullName, UHDM::BaseClass* m,
                                  UHDM::typespec* elemTs);
    // True when an unpacked-array signal's leaf element resolves to a NET
    // (reg, ANSI net port, 4-state packed struct) rather than a variable.
    bool unpackedArrayLeafIsNet(const slang::ast::Symbol& sym, bool portBacked);
    // Top(elab)-view packed-array-of-struct var (filter_ctl_t [1:0][2:0] a):
    // packed_array_var { vpiRange x N + vpiElement = struct_var }.
    // Packed array over a VECTOR TYPEDEF (logic4 [1:0] v): packed_array_var
    // with the ARRAY dims as Ranges, a bare logic_var element, and a ts ref
    // to the SHARED named typedef logic_typespec (Surelog).
    UHDM::packed_array_var* emitVectorTypedefArrayVar(
        const slang::ast::Symbol& sym, const std::string& name,
        const std::string& fullName, UHDM::module_inst* m);
    UHDM::packed_array_var* emitPackedStructArrayVar(const slang::ast::Symbol& sym,
                                                     const std::string& name,
                                                     const std::string& fullName,
                                                     UHDM::module_inst* m);
    UHDM::packed_array_net* emitPackedStructArrayNet(const slang::ast::Symbol& sym,
                                                     const std::string& name,
                                                     const std::string& fullName,
                                                     UHDM::module_inst* m);
    // If `ts` is a packed_array_typespec whose element is an enum, returns a
    // fresh packed_array_var mirroring its ranges (bounds+loc cloned) with an
    // enum_var element referencing the shared enum_typespec; else nullptr.
    // The caller sets vpiName / loc / the var's own typespec ref.
    UHDM::packed_array_var* makeEnumArrayVar(UHDM::typespec* ts,
                                             const std::string& fullName,
                                             UHDM::BaseClass* parent);
    // One uhdm range per unpacked dimension (bounds from ConstantRange, loc
    // from the declarator dimension syntax), each parented at `parent`.
    // `defDimRefPrefix` (def-view port array_typespec only): a PARAM-sized
    // dim ([N]) keeps a bare ref_obj <prefix>.N instead of folding.
    UHDM::VectorOfrange* buildUnpackedRanges(const slang::ast::Symbol& sym,
                                             UHDM::BaseClass* parent,
                                             const std::string& defDimRefPrefix = {});
    // array_typespec for an unpacked-array param: unpacked-dim Ranges +
    // Elem_typespec ref (int/logic at the type-keyword span). `elemFull` is
    // the Elem_typespec ref fullname; `parent` the ts's vpiParent.
    UHDM::array_typespec* makeUnpackedArrayParamTs(
        const slang::ast::ParameterSymbol& ps, const std::string& elemFull,
        UHDM::BaseClass* parent, UHDM::VectorOfrange* sharedRanges);

    // Surelog's ELAB fold of an unpacked-array-of-packed-struct '{..} pattern:
    // an op75 carrying `arrTs` (fullname tsFullName); the array element struct
    // is absorbed (its members become the op's direct operands); each member
    // value folds recursively (all-scalar struct -> constant, struct-with-
    // sub-struct -> nested op75 tagged with that struct's typespec). Returns
    // nullptr for any shape it cannot fold exactly.
    UHDM::operation* foldUnpackedStructArrayPattern(
        const slang::ast::Expression& init, const slang::ast::Type& arrType,
        UHDM::typespec* arrTs, const std::string& tsFullName,
        UHDM::any* parent, const std::string& prefix, NetMap& netMap);

    void setLoc(UHDM::BaseClass* obj, slang::SourceRange range);
    // setLoc with the end shrunk by whitespace Surelog compacts out of
    // spaced based literals within the range (8'd 3 -> 8'd3).
    void setLocCompact(UHDM::BaseClass* obj, slang::SourceRange range);
    void setLocNamed(UHDM::BaseClass* obj, const slang::ast::Symbol& symbol);
    /// Name span at loc; escaped identifiers get Surelog's name+6 width.
    slang::SourceRange nameSpan(slang::SourceLocation loc, std::string_view name);
    // A net's anchor span: the name token, or the whole declarator (name..init)
    // for a reg variable emitted as a net with an initializer (reg b = 0).
    slang::SourceRange regNetSpan(const slang::ast::Symbol& sym);
    std::string fullFilePath(slang::SourceLocation loc);
    std::string rawText(slang::SourceRange range);
    bool macroInvLineCol(slang::SourceLocation loc, uint32_t& line, uint32_t& col);
    void buildLineShifts();
    void fileLineCol(slang::SourceLocation lc, uint32_t& line, uint32_t& col);
    bool lineShiftsBuilt = false;
    // (file buffer id, line) -> sorted [(usage start col, col delta)]
    std::map<std::pair<uint32_t, uint32_t>,
             std::vector<std::pair<uint32_t, int32_t>>>
        lineShifts;
    // Intra-macro-body column shift from formal->actual argument substitution.
    // Surelog lays a macro body out with each `formal` replaced in place by the
    // actual argument text; every body position after a substitution moves right
    // by (actualArgLen - formalLen). A body token on a def line inherits the sum
    // of deltas of all substitutions earlier on that same def line.
    struct MacroArgSub {
        uint32_t formalOffset;  // byte offset of the formal within the body buffer
        int32_t delta;          // actualArgLen - formalLen
    };
    // (body-expansion buffer id, def line) -> subs sorted by formalOffset.
    std::map<std::pair<uint32_t, uint32_t>, std::vector<MacroArgSub>> macroArgSubs;
    bool macroArgSubsBuilt = false;
    void buildMacroArgSubs();
    // Column delta a macro-expanded token acquires from argument substitutions
    // that precede it within its macro body line (0 for non-macro tokens).
    int32_t macroArgShift(slang::SourceLocation loc);
    // vpiDirection for a modport interface port (Surelog rule).
    int32_t interfacePortDirection(
        const slang::ast::InterfacePortSymbol& ip);
    // A module_array (vpiModuleArray) for an interface/module instance array.
    // withInstances: the elab view carries the per-index interface_inst
    // elements; the def view omits them (Surelog).
    UHDM::module_array* emitModuleArray(
        const slang::ast::InstanceArraySymbol& arr, UHDM::module_inst* m,
        const std::string& prefix, NetMap& nets, bool withInstances);
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
    // Tri-state signedness of the target an implicit conversion is coercing a
    // signed based-literal to (-1 unknown, 0 unsigned, 1 signed). Used to model
    // Surelog's signed-literal int_typespec: an UNSIGNED continuous-assign
    // target yields a plain (unsigned) parented typespec.
    int implicitConvTargetSigned = -1;
    bool inLhs = false;
    // True while emitting an elaborated generate-scope process: refs to outer
    // (module) signals are left unbound (no Actual_group), as Surelog does.
    bool suppressRefActual = false;
    // True while emitting DEF-view gen-block processes (all refs unbound,
    // including enum consts).
    bool defGenProcessEmit = false;
    bool callStmtContext = false;
    // Parameter-init contexts keep name-token-only sys call spans.
    bool inParamInit = false;
    // Set while emitting a port's initializer expression (output w = bar(4));
    // its call args carry no formal-ts refs.
    bool portInitCtx = false;
    // DEF-view param inits leave UNARY-op operand constants unparented
    // (binary operands stay parented).
    bool paramInitDef = false;
    // PACKAGE param inits: concat operands unparent in both views.
    bool paramInitPkg = false;
    // Set during an ELAB (top-view) cont-assign LHS emission — single-dim
    // base-select indices parent only here.
    bool elabContAssignLhs = false;
    // True while emitting an elab cont-assign LHS whose RHS triggers netlist
    // re-elaboration (literal/operation): a PACKED multi-dim member-select LHS
    // then parents its index constants (group_status[0][0].a).
    bool elabLhsReelab = false;
    // True while building a struct/union MEMBER typespec: a multi-dim packed
    // array member keeps its full span (a signal/net decl truncates to dim 1).
    bool structMemberTsCtx = false;
    // True while building the members of a MODULE-scope NAMED struct typedef:
    // Surelog keeps such members' packed-dim OPERATION bounds symbolic in the
    // elab view too (anonymous structs and PACKAGE typedefs fold them).
    bool structMemberSymBound = false;
    // Which cont-assign RHS view is being emitted: 0 = not in a cont-assign
    // RHS, 1 = def (allModules), 2 = elab (topModules). Unbased-unsized
    // func-call args key their formal-ts/fold behavior on this.
    int contAssignView = 0;
    // The nearest enclosing assignment/op-82 object — an embedded assignment
    // expression's LHS ref parents here (not at its own op).
    UHDM::BaseClass* enclosingAssign = nullptr;
    // Nested casts lose the inner conversion's syntax; the outer cast
    // emission passes the recovered CastExpression down through this.
    const slang::syntax::SyntaxNode* castSynOverride = nullptr;
    // ELAB interface views fold param-dependent bounds at the DEFAULT param
    // values (Surelog reads widths from the AllModules form): points at a
    // default-instantiated body while the iface vars' typespecs are built.
    const slang::ast::Scope* ifaceDefaultScope = nullptr;
    std::map<const void*, const slang::ast::InstanceSymbol*> ifaceDefaultInst;
    // Elab child-instance packed-range bounds that reach an interface param
    // through a modport/interface port fold at the interface's DEFAULT param
    // value (the AllModules width), NOT the connected override — Surelog.
    // Keyed by the interface definition; the cached default instance supplies
    // each through-port param's default value.
    std::map<const void*, const slang::ast::InstanceSymbol*> moduleDefaultInst;
    // Surelog can't resolve block-scoped localparams; refs to them bind an
    // implicit module-level wire created at the first reference.
    std::map<const slang::ast::Symbol*, UHDM::logic_net*> implicitNetMap;
    UHDM::module_inst* implicitNetModule = nullptr;
    std::string implicitNetPrefix;
    // Package scope currently emitting task_funcs (ts vpiInstance owner).
    UHDM::instance* pkgScopeInst = nullptr;
    // During an explicit-import subroutine COPY re-emission, the typespecs of
    // the clone keep vpiInstance = the HOME package (where the function is
    // defined), not the importing package. Non-null only inside that clone.
    UHDM::instance* importCopyTsInst = nullptr;
    // While the clone emits, its own typespecs are collected here so their
    // vpiInstance can be re-pointed at the ELABORATED (top) home package once
    // both package views exist (the top view is built after all def views).
    std::vector<UHDM::typespec*>* importCopyTsCollect = nullptr;
    // Deferred: (clone typespec, home package name) to re-instance at the end.
    std::vector<std::pair<UHDM::typespec*, std::string>> importCopyTsFixups;
    // The explicit-import subroutine CLONE, keyed by (importing package symbol,
    // home subroutine symbol): a P::f() call through the importer binds this.
    std::map<std::pair<const slang::ast::Symbol*, const slang::ast::Symbol*>,
             UHDM::function*>
        importCopyFunc;
    // Unqualified calls to package functions, per module def body.
    std::map<const void*,
             std::vector<std::pair<UHDM::task_func*, slang::SourceRange>>>
        importedTfCalls;
    // Gen-scope conn CALLS materialize an implicit wire named after the
    // function in the gen scope (Surelog): {name, call range}.
    std::vector<std::pair<std::string, slang::SourceRange>> pendingGenCallNets;
    // (enclosing module, imported fn) — listed on the module AFTER the
    // shared-def Task_funcs assignment.
    std::vector<std::pair<UHDM::module_inst*, UHDM::task_func*>>
        pendingConnTfList;
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
    // task_func SHELLS created by pre-def call sites, awaiting their def fill.
    std::set<UHDM::task_func*> tfShells;
    // Typedef typespecs shared across views; enum consts for value refs.
    std::map<const slang::ast::Symbol*, UHDM::typespec*> typedefTs;
    // Canonical types of module-scope struct typedefs whose member refs are
    // MODULE-PREFIXED (neither nested-typedef nor whole-assigned). Def-view
    // nets of such structs (scalar or unpacked-array; NOT packed-array) carry
    // no typespec ref (Surelog).
    std::set<const void*> modulePrefixedStructs;
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
    // Array-of-struct net-decl-assign Lhs: resolves to the ELEMENT struct
    // typespec (via typedefTs) rather than the array net's own typespec.
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Type*>> pendingNetDeclElemTs;
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
    // Elab instances past the first carry DISTINCT body symbols; fall back
    // to name+location identity when the pointer key misses.
    const std::vector<UHDM::attribute*>* findAttrs(const slang::ast::Symbol* sym);
    // ONE attribute object per (* *) spec, shared across a multi-declarator
    // group (parent = the LAST net emitted with it — Surelog).
    std::map<const void*, UHDM::attribute*> sharedAttrObjs;
    // Pkg struct typedef ts spans stretch to the FIRST module-signal use
    // declarator (patched after defs are built).
    std::vector<std::pair<UHDM::typespec*, const slang::ast::Type*>>
        pendingPkgTsStretch;
    bool implicitNetKeptInElab(const slang::ast::Symbol* sym,
                               const slang::ast::InstanceBodySymbol& body);
    bool implicitNetFromPatternKey(const slang::ast::Symbol* sym,
                                   const slang::ast::InstanceBodySymbol& body);
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
    // True only while emitting a package's typedef listing (both views). Lets
    // buildEnumTs keep a DEF-view PACKAGE enum base bound symbolic while
    // leaving module-context pkg-enum clones folded (distinguishes def-package
    // from module context, which both have pkgTopEmit == false).
    bool inPkgTypedefEmit = false;
    // Child-instance CA re-emission folds type casts (top modules keep them).
    bool foldTypeCasts = false;
    const slang::ast::SubroutineSymbol* currentSubSym = nullptr;
    // Scope for resolving identifiers inside a pkg-function's return/arg TYPE
    // ranges (logic [PARAM-1:0]) — SL binds such refs to the pkg param's
    // def-init constant (pkgParamConst). Set only around those typespec builds.
    const slang::ast::Scope* tfTypeScope = nullptr;
    std::map<const void*, UHDM::constant*> foldedRet;
    std::map<const void*, UHDM::typespec*> foldCloneTs;
    struct PendingParamCloneTs {
        UHDM::ref_typespec* rt;
        const slang::ast::ParameterSymbol* ps;
    };
    std::vector<PendingParamCloneTs> pendingParamCloneTs;
    // NO-DEFAULT overridden params: elab param_assigns awaiting the CA fold
    // constant as their shared Rhs, and fold-const ts refs awaiting the elab
    // param typespec.
    std::map<const slang::ast::Symbol*, std::vector<UHDM::param_assign*>> noDefOvPa;
    std::map<const slang::ast::Symbol*, std::vector<UHDM::ref_typespec*>> noDefOvTsRef;
    // Named property declarations (shared def objects, listed in elab views).
    std::map<const slang::ast::Symbol*, UHDM::property_decl*> propertyDeclMap;
    // Class definitions (design->AllClasses), keyed by the ClassType symbol.
    std::map<const slang::ast::Symbol*, UHDM::class_defn*> classDefnMap;
    // File-level ($unit) parameters -> design-level parameter objects (refs
    // bind these); their typespecs materialize at the very end.
    std::map<const slang::ast::Symbol*, UHDM::parameter*> unitParamMap;
    struct PendingUnitParamTs {
        UHDM::parameter* up;
        UHDM::ref_typespec* prt;
        UHDM::ref_typespec* rhsRt;
        const slang::ast::ParameterSymbol* ps;
    };
    std::vector<PendingUnitParamTs> pendingUnitParamTs;
    // Class property ts refs patched in the write phase (arena order).
    struct PendingClassPropTs {
        UHDM::ref_typespec* rt;
        const slang::ast::Symbol* sym;
        UHDM::variables* var;
    };
    std::vector<PendingClassPropTs> pendingClassPropTs;
    // Set around ELAB net-ts creation: the owning net/var's fullname (bare
    // param-ref bounds clone a ts ref scoped by it).
    std::string boundOwnerFullName;
    // Set while emitting a property-decl body: formal refs (which bind as
    // Invalid) resolve through this scope to implicit module wires.
    const slang::ast::Scope* propDeclScope = nullptr;
    UHDM::ref_obj* emitPropFormalRef(std::string_view nm, slang::SourceRange nr,
                                     UHDM::BaseClass* parent, const std::string& prefix);
    std::map<const void*, UHDM::package*> pkgDefMap;
    // ELAB/top-view package objects (filled in emitPackage when topView).
    // Module- and package-side cross-view links whose Surelog equivalents reach
    // the ELAB pkg (folded param constants) flip from pkgDefMap to this.
    std::map<const void*, UHDM::package*> pkgTopMap;
    // Def-view package param inits that reference ANOTHER package's param
    // (pkg::otherpkg::P): the ref_obj is created during the def-package pass
    // (before top packages exist), so record it and re-point its Actual at the
    // ELAB (top) home-package parameter after topPackages are built — Surelog's
    // cross-package init refs reach the elaborated (folded) home param.
    std::vector<std::tuple<UHDM::ref_obj*, const void*, std::string>>
        pkgCrossRefTopFixups;
    // Transitive wildcard-import typedef clones, shared def+elab per
    // (typedef symbol, module def-name).
    std::map<std::pair<const slang::ast::Symbol*, std::string>,
             UHDM::enum_typespec*>
        transitiveTdClone;
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
    // Gen-block REAL localparams: their typed ts + the CA-shared constant's
    // bare clone are write-phase objects (after the top-port ts, before the
    // genvar int ts — Surelog arena order). crt gets the clone, rt the ts.
    struct PendingGenLpTs {
        UHDM::ref_typespec* rt;
        UHDM::ref_typespec* crt;
        const slang::ast::ParameterSymbol* ps;
        bool typedLp;
        // A gen-scope localparam whose init is a direct element-select of a
        // top array param (localparam int O = RhoOffset[1]) adopts THAT elab
        // pattern operand: the operand gains a ts ref (operandRt) whose actual
        // is this localparam's own int typespec (Surelog shares the constant).
        UHDM::ref_typespec* operandRt = nullptr;
        // A hier-path index that folded this localparam: its use-site
        // constant's ts ref shares the drain-built int ts (gen_test4).
        UHDM::ref_typespec* hierIdxRt = nullptr;
    };
    std::vector<PendingGenLpTs> pendingGenLpTs;
    // Gen-scope localparam fold constants keyed by <genScopeFullName>.<name>
    // so hier-path indexes can fold + claim the shared param_assign
    // (gen_test4 foo[PREV].temp).
    struct GenLpFoldInfo {
        UHDM::param_assign* pa;
        UHDM::constant* c;
        const slang::ast::ParameterSymbol* ps;
    };
    std::map<std::string, GenLpFoldInfo> genLpFoldByPath;
    // The elab (topView) assignment-pattern operation of each unpacked-array
    // param, so a gen-scope localparam that element-selects it can adopt the
    // matching operand constant (Surelog shares it).
    std::map<const slang::ast::ParameterSymbol*, UHDM::operation*>
        elabArrayPatternOp;
    // DEF-view gen-block localparam typespecs, SHARED into the elab param ref
    // (which parents them); a dangling unparented copy closes the tail.
    std::map<const slang::ast::ParameterSymbol*, UHDM::typespec*> defGenLpTs;
    // Packages wildcard-imported by some module (their nested-container struct
    // typedefs take the single-prefix dot-scoped unparented TOP form).
    std::set<const slang::ast::Symbol*> wildcardImportedPkgs;
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
    // Vars ALSO written whole (dout = ...) never repoint their whole refs
    // (multiple_blocking_gate).
    std::set<const slang::ast::Symbol*> selWholeWrittenVars;
    bool beginSelTrack();  // returns true if it newly activated tracking
    void endSelTrack();    // back-patches whole-refs and clears state
    void noteSelectObj(const slang::ast::Symbol* base, UHDM::any* selObj);
    int callArgDepth = 0;
    // Task/function typespecs keep unfolded range expressions; module-level
    // typespecs fold them to INT constants.
    bool tfContext = false;
    // True while emitting a NON-TOP module def's ports: a packed-dim bound
    // referencing an OVERRIDABLE module parameter (parameter, not localparam)
    // stays symbolic — the param is unresolved in the unelaborated child def
    // (instances override it). Safe because a non-top def's port typespec is
    // NOT shared with the elab (child) port ts (that one is re-made folded);
    // a TOP def's ports are handled by the write-phase swap instead.
    bool defPortDim = false;
    // Non-null while emitting a type bound for a local var of a function that
    // lives in an elaborated GEN block: its module-param-ref bounds fold to
    // their values (concrete instance). Set off declSymbol because the local
    // var typespec drains in a deferred pass where currentSubSym is null.
    const slang::ast::Scope* genBlockFnScope = nullptr;
    // True while emitting a PROCESS body inside an elaborated gen-scope: a
    // module-param ref folds to its value (the gen block is a concrete
    // instance), like the gen-block-function case.
    bool inGenScopeProc = false;
    // True when the gen scope whose processes are being emitted sits under a
    // LOOP generate (its refs stay unbound; if/named scopes bind locals).
    bool genScopeProcInLoop = false;
    // The gen block whose processes are currently being emitted (elab).
    const slang::ast::Scope* currentGenBlkScope = nullptr;
    // True while emitting an ELAB gen-scope CA LHS: param refs in select
    // bounds fold to typed constants (Surelog).
    bool genCaLhsParamFold = false;
    // ...and when its RHS is a literal (netlist re-elab), direct literal
    // bounds parent at the part_select.
    bool genCaLhsReelab = false;
    // True inside part_select bound emission (fold scope for the above).
    bool inPsBound = false;
    // Elab (top-view) param_assign Rhs constants, shared into RHS select
    // bound folds.
    std::map<const slang::ast::Symbol*, UHDM::constant*> elabParamConst;
    // Elab gen-scope net objects (for nested-scope CA LHS binding only).
    std::map<const slang::ast::Symbol*, UHDM::any*> genScopeNets;
    // Depth of procedural for-stmt bodies being emitted (refs escaping the
    // loop stay unbound in gen-scope processes).
    int procForDepth = 0;
    // Control vars of for-stmts currently being emitted: their refs bind
    // even inside the loop body.
    std::set<const slang::ast::Symbol*> activeForVars;
    // True only while emitting a NAMED typedef's typespec: Surelog folds
    // type-query bounds ($bits(t)) there, but keeps them as sys_func_call in a
    // variable's inline/anonymous type. Gates the $bits fold in emitSyntaxExpr.
    bool typedefTsContext = false;
    // Set during a vector-typedef signal CLONE emission: a COMPUTED range
    // bound (cW-1) folds to a BARE constant (no loc, no parent).
    bool bareCloneComputedBounds = false;
    // HEADER-imported pkg typedefs (module top import pkg::T; ...): the def
    // listing shows a QUALIFIED clone (Typedef_alias -> shared pkg ts, no
    // parent) created in the WRITE phase and inserted at the recorded index.
    struct PendingHeaderImportTs {
        const slang::ast::Symbol* imported;
        UHDM::VectorOftypespec* tds;
        size_t idx;
    };
    std::vector<PendingHeaderImportTs> pendingHeaderImportTs;
    // Skip the shared-typedef shortcut (def-net drains clone vector
    // typedefs fresh).
    bool bypassTypedefShare = false;
    // Set while emitting a task/function body: case-item expr refs parent
    // at the tf object.
    UHDM::task_func* currentTf = nullptr;
    // When set, emitSyntaxExpr refs carry this scope prefix in VpiFullName.
    std::string syntaxRefPrefix;
    std::string syntaxRefSep = ".";
    // $bits(SIGNAL) typespec-bound arg refs bind their DEF nets once the
    // nets exist (drained at the end of exportDesign).
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>>
        pendingBitsBoundRefs;
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgParamConst;
    // Pkg param OBJECTS (def view) — bound by qualified member-access base
    // refs (pkg::P.member).
    std::map<const slang::ast::Symbol*, UHDM::parameter*> pkgParamObj;
    // Emitting a struct-pattern member VALUE (tagged_pattern Pattern).
    bool inPatternValue = false;
    // DEF-view Rhs node of each package param (any kind) — a later same-pkg
    // param ref chains its vpiActual to this node (Surelog).
    std::map<const slang::ast::Symbol*, UHDM::any*> pkgParamDefRhs;
    // A DEF-pass FOLDED struct/union member packed_array_typespec bound
    // constant ([K:0]->2) records the pkg PARAM it folded, so the post-swap
    // TOP member pass can attach Surelog's vpiSize:32 + vpiTypespec
    // (ref_typespec -> fresh int_typespec = the param's type).
    std::map<UHDM::constant*, const slang::ast::Symbol*> foldedMemberBoundParam;
    // True while emitting a def gen-CA RHS: select-index subexpressions
    // scope through the select base (prefix.base.<name>) — Surelog.
    bool selBaseScopeIdx = false;
    // An imported typedef listed by an IMPORTING package's def view SHARES
    // the home package's def object; module import listings share it too
    // (last-writer scoping). Filled by drainPkgImportLists.
    std::map<const slang::ast::Symbol*, UHDM::typespec*> pkgImportCloneTs;
    // Deferred def-view pkg import listings: the home def object may not
    // exist yet at emit time (AllPackages order is alphabetical). Drained
    // after the AllPackages loop.
    struct PendingPkgImportList {
        UHDM::package* up;
        UHDM::VectorOftypespec* tds;
        size_t index;
        const slang::ast::Symbol* sym;
    };
    std::vector<PendingPkgImportList> pendingPkgImportLists;
    void drainPkgImportLists();
    // Packages imported by ANOTHER package: their top-view enum typedef
    // LISTING shares the def object (the top object still backs module
    // import listings via pkgTopTypedefTs).
    std::set<const slang::ast::Symbol*> pkgImportedByPkg;
    // Re-encode a folded constant in the enum literal's source HEX form when
    // `init` chains (through param refs) to an enum value (Surelog).
    bool enumOriginHexRecode(UHDM::constant* c,
                             const slang::ast::Expression* init);
    // Elab-view fold constant of a module STRING localparam (shared into a
    // cont-assign that reads it — o = X).
    std::map<const slang::ast::Symbol*, UHDM::constant*> moduleStringParamConst;
    // Elab-view BIN fold constant of a typed part-select localparam (shared
    // into a reading cont-assign, like the string case).
    std::map<const slang::ast::Symbol*, UHDM::constant*> moduleParamFoldConst;
    // An imported param's DEF-view int_typespec (instanced at its package),
    // keyed by the package parameter symbol — attached to the def-view
    // cont-assign fold constant that reads it (Surelog gives that fold a
    // ref_typespec -> this typespec).
    std::map<const slang::ast::Symbol*, UHDM::typespec*> importedParamDefTs;
    // The elab-view resolved typespec of each `parameter type T` — shared with
    // the type-param-typed port variable's typespec (Surelog uses one object).
    std::map<const slang::ast::Symbol*, UHDM::typespec*> typeParamElabTs;
    // The def-view DEFAULT typespec of each `parameter type T`, keyed by
    // (definition, param name). Every type-param-typed port's vpiTypedef (def
    // and elab views alike) shares this one object (Surelog).
    std::map<std::pair<const void*, std::string>, UHDM::typespec*>
        typeParamDefaultTs;
    // Part-select fold constants' own logic_typespecs (bare-bound range),
    // materialized in the write-phase tail.
    struct PendingPartSelTs {
        UHDM::ref_typespec* rt;
        int64_t left, right;
    };
    std::vector<PendingPartSelTs> pendingPartSelFoldTs;
    // Def-view fold-constant ts refs of VECTOR-typed params: bound late to a
    // fresh LOC-LESS bare clone (see patchParamTypespecs).
    std::map<const slang::ast::Symbol*, UHDM::ref_typespec*> pendingBareVecTs;
    std::set<const slang::ast::Symbol*>* refCollector = nullptr;
};

} // namespace slang_uhdm
