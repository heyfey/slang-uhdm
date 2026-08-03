//------------------------------------------------------------------------------
//! @file UhdmExporter.h
//! @brief Exports a slang Compilation to a UHDM database (Surelog-compatible)
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <algorithm>
#include <functional>
#include <map>
#include <optional>
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
class FormalArgumentSymbol;
class EnumType;
class GenerateBlockSymbol;
class GenerateBlockArraySymbol;
class TypeAliasType;
class PrimitiveSymbol;
class LetDeclSymbol;
} // namespace slang::ast

namespace slang {
class SourceManager;
class SourceRange;
class SourceLocation;
} // namespace slang

#include "slang/text/SourceLocation.h"

namespace slang::syntax {
class SyntaxNode;
struct DataTypeSyntax;
struct ExpressionSyntax;
struct VariableDimensionSyntax;
struct TimingControlSyntax;
} // namespace slang::syntax

#include <uhdm/uhdm.h>

namespace slang_uhdm {

/// Encoding an EvalFunc member-assignment leftover constant carries: the
/// ASSIGNMENT RHS's, not the struct member's type (see ParamEmit's
/// srlgEvalFuncMemberLeftovers).
enum class SrlgMemLeftEnc { Uint, Int, Bin };

/// Exports a slang elaborated design as a UHDM database, mirroring the
/// structure Surelog produces for its default (folded / pre-elab) output.
class UhdmExporter {
public:
    UhdmExporter(slang::ast::Compilation& compilation, UHDM::Serializer& serializer);

    /// Builds the UHDM design object tree. Returns the design root.
    UHDM::design* exportDesign();

    /// Mirrors Surelog without -nobuiltin: synthesize the `builtin` package
    /// (five empty class_defns) and treat @a builtinFile as the fake
    /// <cwd>/builtin.sv compilation unit holding mailbox/process/semaphore.
    void enableBuiltins(std::string builtinFile) {
        builtins = true;
        builtinFilePath = std::move(builtinFile);
    }

    /// Names of AST node kinds that could not be mapped (empty on full success).
    const std::set<std::string>& unsupported() const { return unsupportedKinds; }

    /// Module names the DRIVER added as extra tops only so their bind
    /// directives elaborate (a `bind` inside an otherwise-uninstantiated
    /// module fires only when that module is instantiated — Surelog applies
    /// such binds globally). These are NOT design tops: they are emitted as
    /// uninstantiated def views only, and the bound children they produce
    /// appear under the real tops (mriscv_bind_sva Wrapper).
    void setSyntheticTops(std::set<std::string> names) {
        syntheticTops = std::move(names);
    }

    /// Surelog `-bb_mod <module>` / `-bb_inst <instance>`: blackbox the named
    /// module DEFINITION (`work@core`) or elaborated instance path
    /// (`work@top.u1`, gen scopes included). Surelog implements both by
    /// returning early from CompileModule (no body is collected at all) and
    /// from DesignElaboration::elaborateInstance_ (no sub-instances are
    /// created), so a blackboxed object keeps only its shell.
    void setBlackBoxes(std::set<std::string> mods, std::set<std::string> insts) {
        bbModules = std::move(mods);
        bbInstances = std::move(insts);
    }

    /// Surelog `--disable-feature=parametersubstitution`. See
    /// `paramSubstRefused()` for the decoded semantics; when this is never
    /// called every predicate below short-circuits to "substitute", so the
    /// whole feature is a hard no-op.
    void setNoParamSubst() { noParamSubst = true; }

    /// Surelog `--disable-feature=letexprsubstitution`. See `emitLetExprCall()`
    /// for the decoded semantics. Not calling this is Surelog's default, and
    /// leaves the emitter byte-identical to `--enable-feature=` (verified).
    /// The `let` handling as a WHOLE is a hard no-op on any design that
    /// declares no `let`: nothing indexes, nothing allocates, and the one test
    /// at the head of `emitExpr` is against an empty map.
    void setNoLetSubst() { noLetSubst = true; }

    /// Surelog `-P<name>=<value>` / `-pvalue+<name>=<value>` (slang spells it
    /// `-G`): a command-line parameter override applied to TOP-LEVEL instances
    /// only. @a raw maps the parameter name to the value string EXACTLY as
    /// Surelog stores it (`StringUtils::unquoted`, no expression parsing).
    /// See `cliOverrideConst()` for the decoded semantics.
    void setCmdLineParams(std::map<std::string, std::string> raw) {
        cliParams = std::move(raw);
    }

private:
    // ---- --disable-feature=parametersubstitution -----------------------
    // Surelog gates ONE function on this flag
    // (CompileHelper::substituteAssignedValue, CompileExpression.cpp:83):
    // a parameter reference is replaced by that parameter's `param_assign`
    // Rhs *unless* the Rhs expression tree contains a `vpiAssignmentPatternOp`
    // or a `vpiConcatOp`, in which case the reference is left symbolic.
    // Everything else the flag appears to do is downstream of that one
    // refusal: an expression that reads an unsubstitutable parameter can no
    // longer be constant-folded, so ITS value is unavailable too, and so on
    // transitively.  Hence two predicates:
    //
    //   paramSubstRefused(ps)  -- Surelog's own test, on ps's own init;
    //   paramValueUnavailable(ps) / exprValueUnavailable(e)
    //                          -- the transitive closure: this expression
    //                             cannot fold to a constant any more.
    //
    // All three answer `false` instantly when the flag is absent.

    /// Surelog's `substituteAssignedValue` == false: @a ps's own initializer
    /// tree contains an assignment pattern or a concatenation, so a reference
    /// to @a ps is never replaced by its value.
    bool paramSubstRefused(const slang::ast::ParameterSymbol& ps);
    /// @a ps's value cannot be computed with substitution disabled: either
    /// substitution of @a ps itself is refused, or its initializer reads a
    /// parameter whose value is unavailable.
    bool paramValueUnavailable(const slang::ast::ParameterSymbol& ps);
    /// @a e reads (transitively) a parameter whose value is unavailable, so
    /// the fold sites that would collapse @a e to a constant must not fire.
    bool exprValueUnavailable(const slang::ast::Expression& e);
    /// The expression a no-substitution Rhs is emitted FROM: follows bare
    /// parameter references through parameters that Surelog would still
    /// substitute (`.RESVAL(RESVAL)` re-passing a parameter whose own Rhs is
    /// itself a plain reference resolves to that reference), and stops at the
    /// first one whose substitution is refused. Returns @a e unchanged when
    /// nothing substitutes.
    /// @a hopped, when non-null, receives the LAST parameter the loop
    /// substituted through (null when nothing substituted).
    const slang::ast::Expression& noSubstSourceExpr(
        const slang::ast::Expression& e,
        const slang::ast::ParameterSymbol** hopped = nullptr);

    // ---- assignment-pattern params that never acquire a value -----------
    // ALWAYS ON (unlike the three predicates above, which are the
    // `--disable-feature=parametersubstitution` ablation).  Surelog's
    // pattern expansion collapses `'{...}` only against a packed-VECTOR
    // target: `logic [3:0] V = '{default:1}` folds to a constant, but
    // `int P = '{default:1}` keeps its `vpiAssignmentPatternOp` in every
    // view, and a reader of P is given the pattern OP TREE, never a value.
    // Measured on a purpose-built golden that varied ONLY the target type
    // and then read each parameter from arithmetic, a cont-assign and an
    // instance-parameter override.

    /// @a ps's initializer is an assignment pattern whose target is not a
    /// packed vector, so the pattern never reduces to a constant.
    bool patParamNoFold(const slang::ast::ParameterSymbol& ps);
    /// @a e reads (transitively) such a parameter, so the fold sites that
    /// would collapse @a e to a constant must not fire.
    bool exprPatNoFold(const slang::ast::Expression& e);
    /// @a ps's DEF-view `param_assign` Rhs stays an OPERATION instead of
    /// reducing to a constant (assignment pattern, concatenation — bare or
    /// wrapped in an explicit cast — or replication).  Surelog's `getObject`
    /// substitutes a parameter reference by the referenced param's Rhs and then
    /// reduces; when that Rhs is one of these the reduce fails and the
    /// REFERENCE survives, which is why `parameter P = PkgConcatParam` keeps a
    /// ref_obj in the def view where `parameter D = PkgIntParam` folds.
    bool paramDefRhsIsOp(const slang::ast::ParameterSymbol& ps);
    /// @a e reads a parameter whose ALREADY-EMITTED elaborated `param_assign`
    /// Rhs is not a constant, so Surelog's elab reduce of @a e has no value to
    /// work with and the reference survives.  Only meaningful after the
    /// enclosing instance's parameters have been emitted (`elabParamPa`).
    bool exprElabParamUnreduced(const slang::ast::Expression& e);

    /// True when the module DEFINITION named @a defName (`work@<name>`) is
    /// blackboxed. Mirrors CompileModule.cpp: a `-bb_inst` argument that names
    /// a bare module also matches here (Surelog tests `modName` against BOTH
    /// sets), which is why `-bb_inst work@top` and `-bb_mod work@top` produce
    /// identical databases.
    bool blackboxedDef(const std::string& defName) const {
        if (bbModules.empty() && bbInstances.empty())
            return false;
        return bbModules.count(defName) != 0 || bbInstances.count(defName) != 0;
    }
    /// True when an ELABORATED object is blackboxed: either its definition is
    /// (above) or its full hierarchical path is a `-bb_inst` argument.
    bool blackboxedInst(const std::string& defName, const std::string& fullPath) const {
        if (bbModules.empty() && bbInstances.empty())
            return false;
        return blackboxedDef(defName) || bbInstances.count(fullPath) != 0;
    }

    /// Maps slang value symbols to the UHDM net/variable object of the
    /// current view (definition or top instance).
    using NetMap = std::map<const slang::ast::Symbol*, UHDM::any*>;
    /// Shares typespec objects per declaration (Surelog TypespecCache).
    using TsCache = std::map<const void*, UHDM::typespec*>;

    struct DefInfo {
        // module_inst for a module def, program for a `program` def (both are
        // UHDM::instance; interface defs use ifaceDefMap instead). Surelog
        // writes program blocks into design->AllPrograms / instance->Programs,
        // so the def shell's runtime type has to be decided up front.
        UHDM::instance* mod = nullptr;
        bool filled = false;
        NetMap nets;
        std::vector<UHDM::process_stmt*> processes;
        std::vector<UHDM::cont_assign*> contAssigns;
        std::set<const slang::ast::Symbol*> processRefs;
        std::map<const slang::ast::Symbol*, UHDM::typespec*> paramTs;
        TsCache defTs;
        std::vector<UHDM::task_func*> taskFuncs;
        std::vector<UHDM::typespec*> typedefs;
        // Set once emitTypedefs has run for this def (the def-param pre-pass
        // may run it early so the typedef's member typespecs precede the
        // params that are typed by it — Surelog compiles them in source order).
        bool typedefsDone = false;
        // Ordered vpiAssertion contents: concurrent_assertions AND
        // checker_insts, interleaved in member order (Surelog appends both to
        // the same vector as it walks the module items).
        std::vector<UHDM::any*> assertions;
        UHDM::clocking_block* defaultClocking = nullptr;
        UHDM::clocking_block* globalClocking = nullptr;
    };
    // Concurrent assertion (folded pre-elab form: label, clocking event as
    // a property_spec, else action). Returns null if not an assertion block.
    // `m` is only the parent object -- a module_inst for a module-level
    // assertion, a gen_scope for one written inside a generate block.
    UHDM::concurrent_assertions* emitAssertion(const slang::ast::ProceduralBlockSymbol& pb,
                                               UHDM::BaseClass* m, const std::string& prefix,
                                               NetMap& netMap);
    // A property/sequence expression tree -> UHDM operation/leaf.
    UHDM::any* emitAssertionExpr(const slang::ast::AssertionExpr& ae, UHDM::BaseClass* parent,
                                 const std::string& prefix, NetMap& netMap);
    // The module's `default clocking @(...);` (global=false) or
    // `global clocking @(...);` (global=true) block, or null.  Each VIEW gets
    // its own object.
    UHDM::clocking_block* emitScopeClocking(const slang::ast::InstanceBodySymbol& body,
                                            UHDM::module_inst* m, const std::string& prefix,
                                            NetMap& netMap, bool global);
    // `<checker> <name>(...)` -> checker_inst on the module's vpiAssertion
    // vector.  Surelog emits the instance HEAD only (name + def name + span):
    // neither the checker's body nor its port connections are elaborated
    // into the database.  The object is SHARED with the elab view, like every
    // other member of that vector.
    UHDM::checker_inst* emitCheckerInst(const slang::ast::Symbol& sym, UHDM::BaseClass* m,
                                        const std::string& prefix);
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
        // A wildcard-import CLONE's body binds the HOME function's own return
        // variable instead of minting a per-reference local (Surelog) — and
        // the home object is the ELABORATED package's, which does not exist
        // while the def clone emits, so the lookup is deferred to the drain.
        UHDM::variables* bindVar = nullptr;
        const slang::ast::Symbol* bindHomePkg = nullptr;
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
    // ELAB aggregate (struct/union) param typespec clone, keyed by
    // (definition, param name). Surelog emits ONE clone per struct/union
    // param, parented at the ELAB ref and instanced at the typedef's package;
    // a bare-package-typedef aggregate param's DEF view SHARES this single
    // object (rather than minting its own def-scoped clone).
    std::map<std::pair<const void*, std::string>, UHDM::typespec*>
        elabAggParamClone;
    struct DefAggShare {
        UHDM::ref_typespec* prt;
        UHDM::ref_typespec* rhsRt;
        DefInfo* di;
        const slang::ast::Symbol* member;
        const void* def;
        std::string name;
    };
    std::vector<DefAggShare> pendingDefAggShare;
    // Re-point every deferred def-view bare-package-typedef aggregate param
    // ref at the matching ELAB clone (run after all top instances emit).
    void shareDefAggParamTs();
    // Surelog's `isDecreasingRange` reorder, applied to package parameters
    // once their typespecs are bound (see the definition in ParamEmit.cpp).
    void applyPkgParamPatternReorder();
    // Give every FOLDED struct/union member packed-array bound that came from
    // a package-param identifier Surelog's metadata (vpiSize:32 + a fresh
    // instance-less int_typespec ref named by the member's ts fullname).
    void attachFoldedBoundMeta(UHDM::typespec* container,
                               UHDM::instance* pkgInst = nullptr);
    // Surelog clones a NAMED vector-typedef typespec at every REFERENCE
    // instead of sharing the module's object, and the copy DROPS vpiInstance
    // (the shared object's instance is the def-view module). Copies the fields
    // uhdm-cmp compares; DeepClone cannot be used here — it recurses forever
    // through the self-referential Typedef_alias (r9tdclone).
    UHDM::typespec* copyNamedVecTs(const UHDM::typespec* src,
                                   UHDM::any* parent);
    // Replace `dst`'s still-symbolic single-dim packed-vector bounds with the
    // folded literal range (no-op when they already are constants).
    void foldVecBounds(UHDM::typespec* dst, int64_t left, int64_t right);
    // True while building an elab struct/union param ts CLONE: member leaf
    // typespecs parent at the member's ref_typespec (Surelog clone form)
    // instead of the typespec_member.
    bool structCloneMemberRefParent = false;
    // True while that clone belongs to a MATERIALIZED IMPORT COPY of a package
    // parameter (the parameter symbol's home scope is a package). Only THOSE
    // clones re-bind their vector-typedef member alias to an UNQUALIFIED copy
    // of the pkg fold twin; a module's OWN parameter typed by the same package
    // struct typedef keeps the pkg-NAMED twin (measured, one golden each:
    // StructUnsizedVal work@dut.InitDefault.pkg::init_t.key.key -> `key` vs
    // work@top.d.Init.pkg::init_t.key.key -> `pkg::key`; LargeValue2Struct
    // RndCnstScrmblKeyInitDefault -> `sram_key_t` vs RndCnstScrmblKeyInit ->
    // `pack::sram_key_t`).
    bool paramCloneImportedCopy = false;
    // True while building the ELAB *operation* ts clone of an aggregate param
    // (the flat op75's own typespec, rhsRt), as opposed to the parameter's own
    // clone. Surelog's op clone is INSTANCE-FREE all the way down: its
    // vector-typedef member's alias target is a fresh instance-less copy of
    // the module's shared typedef object, where the PARAMETER clone's alias
    // target keeps the shared object's def-view instance
    // (r9tdclone / ParamSubstituteComplex).
    bool paramOpCloneCtx = false;
    // Building a module CAST's aggregate clone tree: struct-typedef members
    // get FRESH threaded clones and vector-typedef members fresh folded twins
    // (Surelog re-elaborates the cast target — jeras_union op32_t'(ins)).
    bool castAggCloneCtx = false;
    std::map<const slang::ast::Type*, UHDM::typespec*> castUnionClone;
    // True while emitting a TYPE-dimension bound expression: syntax
    // func_calls anchor at the callee NAME token (Surelog).
    bool boundCallNameSpan = false;
    // True while drainDefParamTs builds DEF-view param typespec clones —
    // those omit the module Instance link the ELAB clones carry.
    bool defViewParamTs = false;
    // True while building the param typespec of an ELABORATED (top) package
    // listing: a packed-array param typespec FOLDS its dim bounds there and
    // keeps them symbolic in the def listing (THE LAW — the def listing
    // reduces nothing, top+import copies reduce everything).
    bool paramTsElabPkgView = false;
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
        UHDM::instance* m;
        std::string prefix;
        NetMap nets;
        size_t paramLo, paramHi, netTsLo, netTsHi;
    };

    UHDM::instance* emitModuleDef(const slang::ast::InstanceSymbol& inst, bool topDef);
    UHDM::instance* emitModuleDefPorts(const slang::ast::InstanceSymbol& inst);
    UHDM::instance* emitInstance(const slang::ast::InstanceSymbol& inst,
                                 const std::string& path, UHDM::instance* parentM,
                                 NetMap* parentNets,
                                 std::set<const slang::ast::Symbol*>* parentRefs, bool isTop);
    // Interfaces are emitted as interface_inst (design->AllInterfaces), not
    // module_inst. emitInterfaceDef builds the generic def (nets); the elab
    // instance (vars + init) is referenced from a parent module via
    // Interfaces() (elab) and a ref_module whose Actual is the def (def view).
    // The interface_typespec for an InterfacePort: a modport typespec
    // (vpiIsModPort) whose parent is the base interface typespec.
    UHDM::interface_typespec* makeIfacePortTs(const slang::ast::InterfacePortSymbol& ip);
    // An ARRAY interface port (myif.man m [2-1:0]): the port's actual typespec
    // is an array_typespec wrapping the modport interface_typespec; the owning
    // module_inst ALSO carries a def-view interface_array (name=port, fullname=
    // the TYPE.MODPORT text). Returns the array_typespec (port actual) or null
    // when the port is not an array.
    UHDM::array_typespec* makeIfaceArrayPortTs(
        const slang::ast::InterfacePortSymbol& ip, UHDM::instance* mod,
        const std::string& prefix);
    // A SIZE-specified unpacked dimension (`[E]`, not `[msb:lsb]`) is built by
    // Surelog's CompileHelper::compileRanges as `0 : E-1` with the decrement
    // left as an EXPLICIT vpiSubOp operation, never folded — in BOTH the def
    // and the elab view (`CompileExpression.cpp:4046-4151`).  The `[msb:lsb]`
    // form is the other branch and DOES reduce its bounds, which is why an
    // elab `m[2-1:0]` carries two constants while an elab `m[N]` carries
    // `0 : (N-1)`.  Fills `r` with that pair; returns false when `dim` is not
    // the size form (caller keeps its own msb:lsb handling).
    // `foldScope`/`foldVal` are the ELAB view's extra step: `compileExpression`
    // runs there with `Reduce::Yes`, so `E` itself collapses to the instance's
    // value (a parameter reference takes its own elab param_assign constant
    // verbatim — same value string, size and const type — and a literal
    // ARITHMETIC bound becomes a signed INT).  Left null/-1 for the def view,
    // where `E` stays the written tree.
    bool fillSizeDimRange(UHDM::range* r,
                          const slang::syntax::VariableDimensionSyntax& dim,
                          const slang::ast::Scope* foldScope = nullptr,
                          int64_t foldVal = -1,
                          const UHDM::instance* mInst = nullptr);
    // Surelog's `ExprBuilder::evalExpr` is what sizes a size-specified
    // dimension, and in the port-elaboration slot it does NOT see the
    // instance's parameter values, so `m[N]` sizes to 1 while `m[2*2]` sizes
    // to 4 (measured on a 5-way golden: literal / literal-arithmetic /
    // defaulted param / overridden param / `[P-1:0]`).  True when every leaf
    // of the size expression is a literal, i.e. when Surelog would fold it.
    static bool sizeDimFoldsWithoutParams(
        const slang::syntax::ExpressionSyntax& e);
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
                                          UHDM::instance* parentM, NetMap& sharedNets,
                                          UHDM::interface_inst* dup0 = nullptr,
                                          UHDM::interface_inst* home = nullptr);
    // DEF-view package struct typespecs, for the cross-view member-actual
    // swap (Surelog wires the first-created member ts into the TOP struct).
    std::map<const slang::ast::Symbol*, UHDM::struct_typespec*> pkgDefStructTs;
    // DEF-view package union typespecs, for the same cross-view swap.
    std::map<const slang::ast::Symbol*, UHDM::union_typespec*> pkgDefUnionTs;
    // Aggregate member actuals the DEF package pass instanced at its own
    // package object. A TOP-pass member landing on one of THESE is the very
    // same object shared by both views, and Surelog leaves it on the def
    // instance; a top-pass member that merely happens to carry a def
    // instance (a freshly built member clone stamped with its typedef's home
    // package) still takes the elab one. Identity is the only distinguisher.
    std::set<const UHDM::typespec*> pkgDefMemberActual;
    // Elaborated-listing objects PINNED to the def-package instance (the
    // alias-target rule in emitPackage). Every later stamp — aggregate
    // members included — must leave them alone.
    std::set<const UHDM::typespec*> pkgDefInstPinned;
    // Unified def-ownership test: two agents independently implemented
    // creation-pass markers (defPassOwnedTs / pkgDefMemberActual+pinned);
    // every keep-def-instance guard must honor all of them.
    bool defOwnedTs(const UHDM::typespec* t) const {
        return defPassOwnedTs.count(t) || pkgDefMemberActual.count(t) ||
               pkgDefInstPinned.count(t);
    }
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
    // See setSyntheticTops().
    std::set<std::string> syntheticTops;
    // File-scope `program`s pulled out of the top list (they are never design
    // tops for Surelog). With no elaborated instance to compile the body in,
    // the DEF pass emits their processes itself instead of waiting for the
    // emitInstance fold-back (see the progDef gate in emitModuleDef).
    std::set<const slang::ast::Symbol*> uninstProgDefs;
    // See setBlackBoxes(): Surelog -bb_mod / -bb_inst arguments, verbatim.
    std::set<std::string> bbModules;
    std::set<std::string> bbInstances;
    // ---- -P<name>=<value> command-line parameter overrides --------------
    // See setCmdLineParams(). Surelog applies these in
    // DesignElaboration::elaborateInstance_ under `instance->getParent() ==
    // nullptr` (top level ONLY), and the effect is three-fold:
    //   1. the value comes from ExprBuilder::fromString -- the raw STRING,
    //      with no reference to the parameter's declared type (a bare decimal
    //      is a 64-bit unsigned, `'d7_200` is a SIZELESS 7200, `/blah` is a
    //      string), see cliOverrideConst();
    //   2. the parameter's typespec is NULLED (`p->setTypespec(nullptr)` plus
    //      `param->Typespec(nullptr)`) on the DEFINITION's Parameter object,
    //      so BOTH the def view and every instance view lose it;
    //   3. the override is recorded in a LOCAL `overridenParams` set, not via
    //      `instance->setOverridenParam()`, so the param_assign carries NO
    //      vpiOverriden -- unlike an instantiation override.
    // Name -> raw value string (already `unquoted`).
    std::map<std::string, std::string> cliParams;
    // Definition symbols of the design's top-level instances (the only place
    // a -P override applies).
    std::set<const slang::ast::Symbol*> cliTopDefs;
    /// True when @a ps is a `-P` target: named on the command line AND
    /// declared by a TOP-LEVEL module's definition.
    bool cliOverridden(const slang::ast::ParameterSymbol& ps) const;
    /// The constant Surelog's ExprBuilder::fromString + UhdmWriter produce for
    /// a `-P` value. Pair-measured (12-value matrix, tests/DecValue and
    /// tests/CmdLineOverride among them), NOT inferred from the declared type.
    UHDM::constant* cliOverrideConst(const std::string& raw);
    // See setNoParamSubst(). `false` makes every predicate above a no-op.
    bool noParamSubst = false;
    // See setNoLetSubst(). `false` makes emitLetExprCall() return immediately.
    bool noLetSubst = false;
    // Memoized paramSubstRefused / paramValueUnavailable; the second carries a
    // recursion guard (an in-flight parameter answers "available" so a cyclic
    // default cannot spin).
    std::map<const slang::ast::ParameterSymbol*, bool> substRefusedCache;
    std::map<const slang::ast::ParameterSymbol*, bool> valueUnavailCache;
    std::set<const slang::ast::ParameterSymbol*> valueUnavailInFlight;
    // Memoized patParamNoFold, with the same in-flight recursion guard.
    std::map<const slang::ast::ParameterSymbol*, bool> patNoFoldCache;
    std::set<const slang::ast::ParameterSymbol*> patNoFoldInFlight;
    // Set while emitParameters re-emits an ELAB-view parameter Rhs it declined
    // to fold: a reference to a patParamNoFold() parameter is replaced there by
    // the pattern's own operation tree (Surelog substitutes the Rhs it cannot
    // reduce), where the DEF view keeps the bare ref_obj.
    bool patSubstElab = false;
    // Set while emitParameters emits a DEF-view module parameter Rhs: a bare
    // reference to a parameter whose own def Rhs is an OPERATION survives as a
    // ref_obj instead of folding (see paramDefRhsIsOp).
    bool paramRhsDefView = false;
    // Typespec refs minted on a substituted ref_obj, paired with the hopped
    // parameter's own ref: the source's Actual_typespec is often still
    // deferred when the ref is built, so it is copied again at write time.
    std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_typespec*>> noSubstRefTs;
    // Defs whose instances are BIND children: display path of the bound
    // instance ("work@top.S2QED_BIND"). Surelog compiles such a module's
    // property declarations from the BOUND instance, so the shared
    // property_decl objects carry the bind path and the elab parent even in
    // the def view (mriscv_bind_sva).
    std::map<const slang::ast::DefinitionSymbol*, std::string> bindDefDisplay;
    // InterfacePortSymbol -> its instance-scoped port view (passthrough
    // children bind their HighConn at the enclosing module's view).
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifacePortViewMap;
    // Interface instance -> its col-0 tail duplicate (see makeIfaceRefDup).
    std::map<const slang::ast::Symbol*, UHDM::interface_inst*> ifaceTailDup;
    UHDM::interface_inst* emitInterfaceDef(const slang::ast::InstanceSymbol& inst);
    UHDM::interface_inst* emitInterfaceInstance(const slang::ast::InstanceSymbol& inst,
                                                const std::string& path,
                                                UHDM::instance* parentM, NetMap* parentNets,
                                                std::set<const slang::ast::Symbol*>* parentRefs,
                                                const slang::ast::InstanceSymbol* portView = nullptr,
                                                const std::string& connModport = "",
                                                bool forceTailDup = false);
    void emitTopPorts(TopPending& tp);
    void emitGenScopes(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                       const std::string& prefix, NetMap& netMap);
    // Uninstantiated else-less gen-if that Surelog's own evaluator TAKES
    // (typedef_param): its errored gen scope with $error placeholder args.
    UHDM::gen_scope_array* emitSurelogMisevalGenIf(
        const slang::ast::GenerateBlockSymbol& blk, const std::string& name,
        const std::string& prefix, UHDM::instance* m);
    // Claim an unpacked-array param element-select's fold constant at the
    // source pattern LEAF span + re-parent it at the cont_assign.
    bool claimUnpackedParamLeaf(const slang::ast::Expression& sel,
                                const slang::ast::ParameterSymbol& pbase,
                                UHDM::constant* foldC, UHDM::any* caParent);
    void emitDefGenStmts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                         const std::string& prefix);

    void emitPorts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                   const std::string& prefix, NetMap& netMap, bool topView, TsCache* sharedTs);
    // The port object a non-ANSI header port written over an EXPRESSION
    // (`.op({\op[79] ,\op[78] })`) contributes: a LowConn concat operation
    // whose operands are port-scoped ref_objs onto the operands' own nets.
    // Identical in the def and elab views. Null when `pb` is not one.
    UHDM::port* emitPortExprPort(const slang::ast::Symbol& pb, UHDM::instance* m,
                                 const std::string& prefix, NetMap& netMap);
    void emitParameters(const slang::ast::Scope& body, UHDM::scope* m, const std::string& prefix,
                        NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                        bool topShareTs = false, bool funcScope = false);
    UHDM::package* emitPackage(const slang::ast::PackageSymbol& pkg, bool topView);
    // A same-named typedef in a package WILDCARD-imported by ta's home package
    // (Surelog's symbol table lets the import overwrite the local typedef —
    // rp32 riscv_isa_i_pkg::csr_adr_t vs riscv_priv_pkg::csr_adr_t). Returns
    // the shadowing imported TypeAlias, or null.
    const slang::ast::Symbol* importShadowOf(const slang::ast::Symbol& ta);
    void emitTaskFuncs(const slang::ast::Scope& body, UHDM::BaseClass* m,
                       const std::string& prefix, DefInfo* info, bool sharedScope = true,
                       const slang::ast::Symbol* onlySub = nullptr);
    void emitTypedefs(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m,
                      const std::string& prefix, DefInfo& info);
    // The array_typespec of an unpacked-array typedef.  `qname` qualifies the
    // object's inner refs (module-scoped for the Typespecs listing, bare for a
    // function-return clone).
    UHDM::array_typespec* buildUnpackedArrayTypedefTs(
        const slang::ast::TypeAliasType& ta, const std::string& qname,
        bool cloneForm = false);
    // Surelog never SHARES a named unpacked-array typedef's array_typespec
    // with the declarations that name it — every reference gets a copy
    // carrying the typedef's BARE name, its span/ranges and a bare-named Elem
    // ref. A MODULE-homed elab copy drops vpiInstance; a PACKAGE-homed one
    // keeps the package; a DEF-view net copy keeps the instance and links
    // Typedef_alias back to the shared object. Both fields are compared by
    // typespec::Compare, so the sharing is a hard cmp failure even though a
    // dump cannot see it (UnpackedTypespec).
    UHDM::array_typespec* copyArrayTypedefTs(const UHDM::array_typespec* src,
                                             const std::string& bareName,
                                             bool keepInstance, bool withAlias);
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
    // Primitives (gates/switches/udps) declared in `body` into `m`, which is
    // a module_inst (module body) or a gen_scope (generate block): Surelog
    // fills vpiPrimitive/vpiPrimitiveArray on BOTH (GenerateUnnamed).
    void emitGates(const slang::ast::Scope& body, UHDM::BaseClass* m,
                   const std::string& prefix, NetMap& netMap, bool topView);
    // `primitive ... endprimitive` -> design->AllUdps.  Surelog builds one
    // udp_defn per UDP declaration at module-compile time and hangs it off the
    // design; the module-side `udp` instances (emitGates) point back at it in
    // the elaborated view only.
    void emitUdpDefns();
    UHDM::udp_defn* buildUdpDefn(const slang::ast::PrimitiveSymbol& prim);
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
    // "#5", "#10ns", "#dly": Surelog's delay_control. Sets VpiDelay to the
    // Pound_delay TOKEN text (SV3_1aLexer.g4:65, '#' plus [0-9][0-9_.]*, so a
    // trailing time_unit is NOT part of it) while the object's SPAN covers the
    // whole pound_delay_value including that unit. A non-numeric delay value
    // gets a ref_obj under Delay() only in STATEMENT position -- pass the
    // enclosing scope prefix as `stmtRefPrefix` there; an INTRA-ASSIGNMENT
    // delay (`a <= #Tp b;`) records no value at all.
    UHDM::delay_control* emitDelayControl(const slang::ast::TimingControl& tc,
                                          UHDM::BaseClass* parent,
                                          const std::string* stmtRefPrefix = nullptr);
    UHDM::any* emitExpr(const slang::ast::Expression& expr, UHDM::BaseClass* parent,
                        const std::string& prefix, NetMap& netMap);
    // b.a[0].x / a[0].min_v -> hier_path threading bit_select elements through
    // selected members. Returns null (caller notes unsupported) if the chain
    // has a shape this doesn't handle yet (e.g. multi-select on one member).
    UHDM::hier_path* emitMixedHierPath(const slang::ast::Expression& expr,
                                       UHDM::BaseClass* parent, const std::string& prefix,
                                       NetMap& netMap);
    // `paramCtx` marks a fold that becomes a PARAMETER's value (a param_assign
    // Rhs) rather than an rvalue: those always carry a vpiDecompile.
    UHDM::any* tryFoldConst(const slang::ast::Expression& expr,
                            const slang::ast::Expression* typedConv = nullptr,
                            bool paramCtx = false);
    // For an element select of an unpacked-array PARAMETER (LP[0],
    // P[1][2][1]) whose initializer is an assignment pattern, returns the
    // pattern's LEAF element expression the select reads. Surelog's elab
    // fold CLAIMS that leaf's source span for the reduced constant, so the
    // reader needs the leaf, not just the value. Null when any level is not
    // a constant-index select over a simple pattern.
    const slang::ast::Expression* unpackedParamPatternLeaf(
        const slang::ast::Expression& sel);
    bool isIntEncoded(const slang::ast::Expression& e);
    void analyzeParamEnc(const slang::ast::Scope& body);
    // Design-global pre-pass: definitions instantiated with MULTIPLE DISTINCT
    // parameter-value tuples (Surelog uniquifies these; their untyped overrides
    // encode UINT/size32/ct9, and parameterized interface port-views keep a
    // param_assign). Populated by computeParamMultiplicity().
    std::set<const slang::ast::DefinitionSymbol*> multiParamDefs;
    // Defs with >1 DISTINCT #(...) override raw text (pre-elab textual
    // uniquification, realexpr).
    std::set<const slang::ast::DefinitionSymbol*> textMultiParamDefs;
    // Defs instantiated with ANY #(...) override text. Syntax-based, so it
    // stays reliable for uniquified/cloned bodies where isOverriddenParam
    // misses the override. Gates the non-top def PORT-dim symbolic rule.
    std::set<const slang::ast::DefinitionSymbol*> overriddenTextDefs;
    void computeParamMultiplicity();
    bool isMultiParamDef(const slang::ast::Scope& body) const;
    // COMPILE-order comparator for cross-file sorts. Raw SourceLocation
    // compare orders by BufferID, but slang loads source files with a thread
    // pool, so buffer NUMBERING follows load-completion order and varies run
    // to run. Compile order is recovered from the compilation units: units in
    // insertion (command-line) order, members in parse order; the first
    // top-level member seen in a buffer fixes that buffer's rank. Populated
    // lazily by srcOrderLess().
    mutable std::map<slang::BufferID, size_t> bufRank;
    bool srcOrderLess(slang::SourceLocation a, slang::SourceLocation b) const;
    // A module compiled out of a `-y` library directory or a `-v` library
    // file. Surelog's UhdmWriter tests isLibraryFile() at both module_inst
    // emission sites and stamps vpiCellInstance; it also drops UNUSED library
    // cells from allModules (already handled in exportDesign).
    static bool isLibraryCell(const slang::ast::DefinitionSymbol& def);
    // Surelog never keeps digit separators in a constant's value or in a
    // based-literal decompile (32'h8000_0000 -> HEX:80000000, decompile
    // 32'h80000000; source SPANS keep the underscore width). Applied wherever
    // RAW source digits flow into VpiValue/VpiDecompile; folded paths print
    // digits and cannot carry separators.
    static std::string stripSep(std::string t) {
        t.erase(std::remove(t.begin(), t.end(), '_'), t.end());
        return t;
    }
    // Surelog's writer finishes an instance (params, ports, nets, cont
    // assigns) BEFORE descending into its child instances, so a child's elab
    // param typespecs land after the parent's deferred body typespecs. The
    // drain therefore runs in two passes over the same [lo,hi) window:
    // ownBody==nullptr keeps the single-pass behaviour; otherwise pass 1
    // (descendants=false) takes the entries owned by ownBody and pass 2 takes
    // everything below it.
    void patchParamTypespecs(size_t lo, size_t hi,
                             const slang::ast::InstanceBodySymbol* ownBody = nullptr,
                             bool descendants = false);
    // An aggregate (struct/union) param whose ELAB pattern RHS carries its own
    // module-scoped typespec clone: Surelog mints that clone while ELABORATING
    // the param assign, i.e. before the instance's net/port typespecs, not in
    // the write-phase param drain. Minted here, consumed by
    // patchParamTypespecs.
    // Keyed by the pending entry's own RHS ref (one instance's param assign):
    // two instances sharing a slang body share the ParameterSymbol but not the
    // ref, so each gets its own clone.
    void mintParamOpClones(size_t lo, size_t hi);
    std::map<UHDM::ref_typespec*, UHDM::typespec*> paramOpClones;
    // A struct-pattern OVERRIDE substituted from a param of a DIFFERENT struct
    // type (a shadowed `struct_t` in the instantiating module): the flattened
    // op75 carries the ACTUAL's struct typespec, not the formal's, so the op
    // clone has to be built off that param instead of the pending entry's.
    // EnumConstElab.
    std::map<UHDM::ref_typespec*, const slang::ast::ParameterSymbol*>
        paramOpTsSrcParam;
    UHDM::typespec* makeBareVecParamTs(const slang::ast::ParameterSymbol& ps,
                                       bool parentBounds);
    UHDM::typespec* makeParamTs(const slang::ast::ParameterSymbol& ps, bool typedParam,
                                bool parentBounds = false);
    // A package parameter typed by an ENUM-TYPEDEF ALIAS (typedef e_t f_t):
    // its MATERIALIZED IMPORT copy in a module carries a per-copy clone pair
    // instead of the package's listing object — see buildImportAliasEnumTs.
    bool importAliasEnumParam(const slang::ast::ParameterSymbol& ps);
    UHDM::enum_typespec* buildImportAliasEnumTs(
        const slang::ast::TypeAliasType& ta, const slang::ast::EnumType& et,
        const std::string& refPrefix);
    // An aggregate import clone's members bind their own typedefs' import
    // clones; an enum-ALIAS import clone is the design's ONLY object for that
    // typedef, so the home package's aggregates re-bind to it.
    void bindImportCloneMembers(UHDM::typespec* cl, const slang::ast::Type& ct);
    // Surelog's strtoull reduce of a size cast over a `?`-bearing based
    // literal (see ParamEmit).
    bool unknownBasedCastFold(const slang::ast::Expression& init,
                              uint64_t& out);
    void rebindAggMemberTs(const slang::ast::PackageSymbol& pkg,
                           UHDM::typespec* from, UHDM::typespec* to);
    bool isRangedUntypedParam(const slang::ast::ParameterSymbol& ps);
    // § elabRangedRerender — the width the ELAB view re-renders a ranged
    // untyped parameter's literal at (see ParamEmit).
    int32_t srlgRangedElabWidth(const slang::ast::ParameterSymbol& ps);
    // § elabUnitMisevalNoFold — parameters whose ELAB Rhs Surelog leaves
    // UNFOLDED because their value depends on a $unit parameter it could not
    // value; readers of these inherit the property (see ParamEmit).
    std::set<const slang::ast::Symbol*> elabMisevalParams;
    bool srlgElabMiseval(const slang::ast::ParameterSymbol& ps);
    bool srlgMisevalSyntax(const slang::syntax::SyntaxNode* n0,
                           const slang::ast::Scope* look0,
                           const std::string& root0);
    int unitParamRoots9 = -1;
    bool unitParamsMultiRoot();
    // § genIfUnitMisevalFalse — which arm of a generate-if chain Surelog
    // elaborates when a condition reads a $unit parameter it could not value
    // (see ModuleEmit).  `NotApplicable` = no condition in the chain is
    // misevaluated, so slang's own selection stands.
    enum class GenIfPick { NotApplicable, Skip, Emit };
    GenIfPick genIfUnitMisevalFalse(const slang::ast::GenerateBlockSymbol& blk);
    // § elabVarRangeMisevalSubst — when set, emitSyntaxExpr resolves
    // identifiers in this scope and SPLICES the init of any parameter in
    // elabMisevalParams at the use site (see TypeEmit).
    const slang::ast::Scope* misevalSubstScope = nullptr;
    // Substitutes parameter leaves inside an elab child's part-select bound
    // OPERATION (see ModuleEmit).
    bool foldBareParamBoundIn(const slang::ast::InstanceBodySymbol* body,
                              const UHDM::instance* parentM, UHDM::any* be,
                              const std::string& tsName);
    // True when Surelog's ExprEval reduces this const function to one
    // constant (the three measured bail rules — see ParamEmit).
    bool srlgEvalFuncFolds(const slang::ast::SubroutineSymbol& sub);
    // True when this MODULE parameter's ELAB Rhs stays the symbolic func_call
    // the def view holds — the parameter then has no value to substitute at a
    // reference, and Surelog inlines the call itself instead (see the
    // symCallParam arm in TypeEmit's packed-range bounds).
    bool elabParamCallSymbolic(const slang::ast::ParameterSymbol& ps);

    // ---- EvalFunc member-assignment leftovers -------------------------------
    // A const function that builds its packed-struct result MEMBER BY MEMBER
    // (`cfg.FETCH_WIDTH = 32; ... return cfg;`) leaks the constants its
    // evaluation produced onto the SHARED struct typespec: UHDM's
    // `ExprEval::setValueInInstance` decodes a hier_path LHS to the
    // `typespec_member` and calls `Actual_value(rhs)` on it (ExprEval.cpp
    // ~5074/~5385, both the integer and the non-integer arm). The struct
    // typespec is shared, so the leftovers are visible on every view that
    // resolved the typedef AFTER elaboration — the TOP package copy and the
    // instance parameter's copy — while the DEF package listing stays clean.
    // Encoding is the assignment RHS's, not the member's type (measured on
    // FuncStructValSimple: literal -> UINT/64, ternary -> INT/64, wide member
    // copy from a formal -> BIN at the member width with a ts ref).
    struct SrlgMemLeft {
        std::string name;
        SrlgMemLeftEnc enc = SrlgMemLeftEnc::Uint;
    };
    // Non-empty when `sub` is a member-by-member struct builder, one entry per
    // WRITTEN member in declaration order. Cached per subroutine.
    const std::vector<SrlgMemLeft>* srlgEvalFuncMemberLeftovers(
        const slang::ast::SubroutineSymbol& sub);
    std::map<const slang::ast::SubroutineSymbol*, std::vector<SrlgMemLeft>>
        memLeftCache;
    // The call whose result initializes a parameter, when that call reaches
    // srlgEvalFuncMemberLeftovers. Returns the subroutine or null.
    const slang::ast::SubroutineSymbol* memLeftInitCall(
        const slang::ast::Expression& init);
    // Recorded while emitting parameters: every struct-valued parameter whose
    // initializer is such a call, with the per-member leftover constants the
    // evaluation produced. Drained by stampEvalFuncLeftovers.
    struct SrlgMemLeftStamp {
        std::vector<std::string> names;      // struct field names, in order
        std::vector<UHDM::constant*> values; // one per WRITTEN member (or null)
    };
    std::vector<SrlgMemLeftStamp> memLeftStamps;
    // The elab param_assign Rhs struct_vars minted for such a parameter, with
    // the parameter object whose typespec their own ts ref must copy (the
    // param's typespec is patched later, in the deferred drain).
    std::vector<std::pair<UHDM::struct_var*, UHDM::parameter*>> memLeftStructVars;
    // Stamps the recorded leftovers onto the struct typespecs reachable from
    // the ELABORATED views only (TopPackages/TopModules). The constants
    // themselves are built by a file-static helper in ParamEmit.cpp, where
    // FieldSymbol/SVInt are complete types.
    void stampEvalFuncLeftovers(UHDM::design* d);
    // When `init` reads `<param>.<member>` and that member carries an INT-
    // encoded leftover, the override fold keeps vpiIntConst (work@top.u1
    // INPUT_WIDTH: INT:2/ct 7, not UINT:2/ct 9).
    bool memLeftIntRead(const slang::ast::Expression& init);
    std::optional<SrlgMemLeftEnc> memLeftReadEnc(
        const slang::ast::Expression& e);
    // True when this instance's parameter overrides read a member-leftover
    // struct parameter: Surelog's DESIGN elaboration runs BEFORE the leftovers
    // exist, so the generate conditions never fold and the instance gets NO
    // gen_scope_array at all (work@top.u1 has none in golden).
    bool memLeftGenScopeBlocked(const slang::ast::InstanceBodySymbol& body);
    // True when the parameter's NAME appears anywhere in its enclosing
    // module/interface declaration beyond its own declarator (srlgReadFoldsTs
    // — see patchParamTypespecs). Cached per enclosing declaration syntax.
    bool paramNameIsRead(const slang::ast::ParameterSymbol& ps);
    std::map<const slang::syntax::SyntaxNode*,
             std::map<std::string_view, int>> declIdentCounts;
    // The same walk restricted to the CONSTANT-EVALUATED select positions — a
    // RANGED-UNTYPED parameter reaches getObject only from those (see the
    // ablation table at collectSrlgReadNames).
    std::map<const slang::syntax::SyntaxNode*,
             std::map<std::string_view, int>> declIdentCountsNarrow;
    // True when the parameter is read anywhere inside a continuous assign
    // whose RHS constant-FOLDS (Surelog's reduction resolves each name it
    // meets through getObject/setRange).  Cached per instance body.
    bool paramCaFoldRead(const slang::ast::ParameterSymbol& ps);
    std::map<const slang::ast::Scope*, std::set<std::string_view>>
        caFoldReadNames;
    UHDM::typespec* predefIntTypespec(const slang::ast::Type& ct,
                                      const slang::ast::Symbol& sym);

    slang::SourceLocation structTypedefUseEnd(
        const slang::ast::InstanceBodySymbol& body,
        const slang::ast::Type& ta);
    UHDM::typespec* makeTypespec(const slang::ast::Symbol& declSymbol,
                                 const slang::syntax::SyntaxNode* typeSynOverride = nullptr,
                                 const slang::ast::PortSymbol* portCtx = nullptr);
    /// A type reference SCOPED INSIDE A CLASS (`C#(t_t0,3)::t_vector`).
    /// Surelog never resolves one — it records an unsupported_typespec named
    /// `<class>::<member>` and leaves every signal so typed untyped in the
    /// instance view (VirtualClass). Returns the ScopedNameSyntax (as a plain
    /// node) when @a typeSyn has that shape, else null.
    const slang::syntax::SyntaxNode* classScopeTypeRef(
        const slang::syntax::SyntaxNode* typeSyn);
    /// Same, off a declaration's own type syntax.
    const slang::syntax::SyntaxNode* classScopeTypeRef(
        const slang::ast::Symbol& declSymbol);
    /// The unsupported_typespec for such a reference.
    UHDM::typespec* makeClassScopeTs(const slang::syntax::SyntaxNode& scopedName);
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
    /// The element typespec of an aggregate member with an ANONYMOUS element
    /// type (`logic [31:0] pair [2]`); null for kinds not modelled.
    UHDM::typespec* anonAggregateElemTs(
        const slang::ast::Type& elemType,
        const slang::syntax::SyntaxNode* memberTypeSyn);
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
    // Instance-view array_var for a MODULE/INTERFACE-scope declaration with
    // any DYNAMIC / ASSOCIATIVE / QUEUE dimension (null otherwise).
    UHDM::array_var* emitDynArrayVar(const slang::ast::Symbol& sym,
                                     const std::string& name,
                                     const std::string& fullName,
                                     UHDM::BaseClass* m,
                                     UHDM::typespec* elemTs);
    // Instance-view array_net for an unpacked array of a NET-type leaf
    // (reg/logic memory): array_net { vpiRange x N + vpiNet = logic_net }.
    UHDM::array_net* emitArrayNet(const slang::ast::Symbol& sym, const std::string& name,
                                  const std::string& fullName, UHDM::BaseClass* m,
                                  UHDM::typespec* elemTs);
    // True when an unpacked-array signal's leaf element resolves to a NET
    // (reg, ANSI net port, 4-state packed struct) rather than a variable.
    // `elemTs` is the EMITTED element typespec when one is available: a
    // packed-struct leaf is a net only while every member is logic/struct
    // (structTsIsNetLike), the same test Surelog's elab_signal_ runs.
    bool unpackedArrayLeafIsNet(const slang::ast::Symbol& sym, bool portBacked,
                                const UHDM::typespec* elemTs = nullptr);
    // Top(elab)-view packed-array-of-struct var (filter_ctl_t [1:0][2:0] a):
    // packed_array_var { vpiRange x N + vpiElement = struct_var }.
    // Packed array over a VECTOR TYPEDEF (logic4 [1:0] v): packed_array_var
    // with the ARRAY dims as Ranges, a bare logic_var element, and a ts ref
    // to the SHARED named typedef logic_typespec (Surelog).
    UHDM::packed_array_var* emitVectorTypedefArrayVar(
        const slang::ast::Symbol& sym, const std::string& name,
        const std::string& fullName, UHDM::instance* m);
    UHDM::packed_array_var* emitPackedStructArrayVar(const slang::ast::Symbol& sym,
                                                     const std::string& name,
                                                     const std::string& fullName,
                                                     UHDM::instance* m);
    UHDM::packed_array_net* emitPackedStructArrayNet(const slang::ast::Symbol& sym,
                                                     const std::string& name,
                                                     const std::string& fullName,
                                                     UHDM::instance* m);
    UHDM::typespec* packedStructArrayElemTs(const slang::ast::Symbol& sym);
    // ELAB fix-ups for a flattened (struct) assignment-pattern cont_assign
    // RHS: the CA was deep-cloned, so every select constant carries a parent,
    // and each path operand's vpiExpr binds the elaborated base signal.
    void flattenPatternCaRhs(UHDM::operation* op,
                             const slang::ast::Expression& patExpr,
                             const NetMap& netMap);
    // If `ts` is a packed_array_typespec whose element is an enum, returns a
    // fresh packed_array_var mirroring its ranges (bounds+loc cloned) with an
    // enum_var element referencing the shared enum_typespec; else nullptr.
    // The caller sets vpiName / loc / the var's own typespec ref.
    UHDM::packed_array_var* makeEnumArrayVar(UHDM::typespec* ts,
                                             const std::string& fullName,
                                             UHDM::BaseClass* parent);
    // The array_var (+ element `vpiReg` + unbounded array_typespec) Surelog
    // gives a QUEUE / DYNAMIC-array declaration; null for any other type.
    // See the decode at the definition (TaskFuncEmit.cpp).
    UHDM::array_var* makeQueueDynArrayVar(const slang::ast::Symbol& vs,
                                          const std::string& afull,
                                          UHDM::any* parent);
    // One uhdm range per unpacked dimension (bounds from ConstantRange, loc
    // from the declarator dimension syntax), each parented at `parent`.
    // `defDimRefPrefix` (def-view port array_typespec only): a PARAM-sized
    // dim ([N]) keeps a bare ref_obj <prefix>.N instead of folding.
    UHDM::VectorOfrange* buildUnpackedRanges(const slang::ast::Symbol& sym,
                                             UHDM::BaseClass* parent,
                                             const std::string& defDimRefPrefix = {});
    // Would Surelog's DEFINITION compile fold `$bits(<arg>)` to a constant?
    // `CompileHelper::compileBits` folds only when `getTypespec()` finds a
    // typespec for the argument AND `ExprEval::isFullySpecified()` accepts it
    // (CompileExpression.cpp:4729); otherwise the `sys_func_call` survives —
    // in the elaborated views too, since those only re-reduce what UHDM's
    // ExprEval can size.  `srlgFullySpecType` is the second half of that
    // test: no declaration dimension anywhere in the type may name something
    // the definition compile had not already resolved (a MODULE parameter or
    // a genvar leaves a ref_obj; a PACKAGE parameter does not).
    bool srlgBitsFoldArg(const slang::ast::Expression& arg);
    // True when a declaration-bound SYNTAX tree reads a `$unit`-scope
    // parameter. Surelog never substitutes one, so such a bound stays an
    // unfolded operation in every view.
    bool syntaxReadsUnitParam(const slang::syntax::SyntaxNode& n,
                              const slang::ast::Scope* scope);
    // The first `<name>'(...)` size cast under `n`, as the cast's type-name
    // node (where Surelog anchors the typespec it mints for the name).
    const slang::syntax::SyntaxNode* findParamSizeCast(
        const slang::syntax::SyntaxNode& n, std::string_view name);
    // Parameters whose ONLY typespec is the one Surelog mints for a `P'(x)`
    // size cast on their name -> that cast's type-name node.
    std::map<const slang::ast::Symbol*, const slang::syntax::SyntaxNode*>
        castSizeParamTs;
    // The object stampCastSizeParamTs actually built for such a parameter, per
    // VIEW (the map is keyed by the view's own ParameterSymbol, so a def entry
    // and an elab entry coexist).  The elaborated RE-EMIT of a `P'(x)` cast
    // reads it to copy that shape instead of minting the folded-value form.
    std::map<const slang::ast::Symbol*, UHDM::int_typespec*> castSizeStampedTs;
    // Reshape such a parameter's typespec into Surelog's form: named after
    // the parameter, located at the cast, carrying a vpiExpr ref_obj back to
    // it. ExprEmit's cast path then reuses this very object.
    void stampCastSizeParamTs(const slang::ast::ParameterSymbol& ps,
                              UHDM::parameter* up, UHDM::typespec* its);
    // A `(P)'(x)` PAREN-cast width parameter (isParenCastWidthParam): Surelog
    // reuses P's own declaration int_typespec as the cast target, and the
    // marks that leaves -- vpiInstance = the package the cast is written in,
    // plus a vpiExpr ref_obj bound back to the parameter -- are properties of
    // the PARAMETER, so EVERY copy of its declaration typespec carries them,
    // in every view and every importing scope (the elaborated listings fold
    // the cast away entirely and golden's copies are marked all the same).
    // ExprEmit's cast path reaches the def-package copy through
    // pkgScopeParamTs and stamps it there; this is the same stamp for the
    // copies no cast site ever visits.
    void stampParenCastWidthTs(const slang::ast::ParameterSymbol& ps,
                               UHDM::parameter* up, UHDM::typespec* its,
                               UHDM::instance* inst);
    bool srlgFullySpecType(const slang::ast::Type& type, int depth);
    // Surelog's value for a declaration-dimension bound that calls
    // $high/$low/$left/$right on an UNPACKED array: those four never resolve
    // there and come back as $bits(arg), so `$high(a)-$low(a)+1` is 1, not the
    // LRM's 2 (measured on three array shapes; SystemCallSize).  Returns false
    // when no such call is present -- the caller then keeps slang's bound.
    bool srlgBoundCallDim(const slang::syntax::ExpressionSyntax* es,
                          int64_t& out);
    // array_typespec for an unpacked-array param: unpacked-dim Ranges +
    // The package instance a symbol declared in a package links its minted
    // typespecs to (the ELABORATED package once it exists), or null.
    UHDM::instance* homePkgInstOf(const slang::ast::Symbol& sym);
    // Elem_typespec ref (int/logic at the type-keyword span). `elemFull` is
    // the Elem_typespec ref fullname; `parent` the ts's vpiParent.
    // `elabClone` marks an ELABORATION clone: its freshly built element
    // typespec is parented at the Elem_typespec ref that holds it (the
    // compile-time def-view object leaves that element typespec parentless).
    UHDM::array_typespec* makeUnpackedArrayParamTs(
        const slang::ast::ParameterSymbol& ps, const std::string& elemFull,
        UHDM::BaseClass* parent, UHDM::VectorOfrange* sharedRanges,
        bool elabClone = false, const std::string& dimRefPrefix = {});

    // Surelog's ELAB fold of an unpacked-array-of-packed-struct '{..} pattern:
    // an op75 carrying `arrTs` (fullname tsFullName); the array element struct
    // is absorbed (its members become the op's direct operands); each member
    // value folds recursively (all-scalar struct -> constant, struct-with-
    // sub-struct -> nested op75 tagged with that struct's typespec). Returns
    // nullptr for any shape it cannot fold exactly.
    // `connFold` selects the INSTANCE-CONNECTION flavour of the fold: there
    // each nested member op carries vpiSize = that member type's bit width
    // (the param_assign flavour leaves the nested ops sizeless).
    UHDM::operation* foldUnpackedStructArrayPattern(
        const slang::ast::Expression& init, const slang::ast::Type& arrType,
        UHDM::typespec* arrTs, const std::string& tsFullName,
        UHDM::any* parent, const std::string& prefix, NetMap& netMap,
        bool connFold = false);

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
    // A redundant `signed` on a predefined integer type is NOT part of the
    // typespec span (integer signed -> "integer"); `unsigned` IS.
    slang::SourceRange trimTypeSigning(const slang::syntax::SyntaxNode* tsyn,
                                       slang::SourceRange r);
    std::string fullFilePath(slang::SourceLocation loc);
    /// Path of the COMMAND-LINE file this location ultimately came from:
    /// Surelog's `FileContent` is per command-line file with `include`s
    /// textually inlined, so anything Surelog scopes "per file" (see
    /// `fileScopeImportPkgs`) must key on the root of the include chain.
    std::string rootFilePath(slang::SourceLocation loc);
    /// Packages imported at FILE scope (`import pkg::*;` outside any design
    /// element) in the same command-line file as `modLoc`.  Surelog's
    /// `CompileModule` replays every `paPackage_import_item` registered on the
    /// module's FileContent into the module itself (`importPackage`, WITHOUT
    /// `compileImportDeclaration`) -- so the package's typedefs join the
    /// module's Typespecs but NO import_typespec is emitted.  Each entry is
    /// (import symbol, imported TypeAlias).
    std::vector<std::pair<const slang::ast::Symbol*, const slang::ast::Symbol*>>
    fileScopeImportTypedefs(slang::SourceLocation modLoc);
    /// True when Surelog would lex this location's ROOT source file in
    /// Verilog (non-SystemVerilog) mode: `ParseFile.cpp` sets the lexer's
    /// `sverilog` flag from the file EXTENSION (`.sv`) alone -- `-sv <file>`
    /// keys on the command-line path and so never matches the preprocessed
    /// file the parser actually reads.  The mode changes the parse tree, and
    /// with it the emitted spans, so it is a model input (see the `logic`
    /// net-declaration rule in materializeDefNetTs).
    bool verilogLexMode(slang::SourceLocation loc);
    /// A MODULE-scope `logic x;` (bare keyword, no dims/signing, no
    /// initializer) that Surelog never resolves: its Verilog-mode lexer has
    /// no `logic` keyword, so the declaration parses as "user type `logic`,
    /// signal x", and a NON-ANSI-header component cannot resolve a bare type
    /// NAME while writing its definition (the same gap `namedTypeNet`
    /// already models for a real typedef).  Such a declaration stays a NET in
    /// BOTH views -- def net with no typespec and no vpiNetType, and
    /// elaboration never promotes it to a logic_var.  See the definition
    /// (ModuleEmit.cpp) for the measured matrix.
    bool vlogUnresolvedLogicNet(const slang::ast::Symbol& sym);
    /// The vpiDelay expression of a continuous assign / net-decl-assign
    /// (`assign #0.1 a = b;`, `wire #3 w = a;`), or null when the statement
    /// carries no delay.  See the definition (ModuleEmit.cpp) for the model.
    UHDM::expr* emitAssignDelay(const slang::syntax::TimingControlSyntax* dsyn,
                                UHDM::BaseClass* parent);
    std::string rawText(slang::SourceRange range);
    /// The node's text as the PREPROCESSED token stream reads it: outside a
    /// macro this is `rawText(syn.sourceRange())`, inside one it is the
    /// node's own tokens concatenated (which already carry the substituted
    /// macro ARGUMENTS).  See the definition (UhdmExporter.cpp).
    std::string rawTextExp(const slang::syntax::SyntaxNode& syn);
    /// `rawTextExp` for a bound EXPRESSION: the expanded spelling when the
    /// expression carries syntax, else plain `rawText` of its span.  Used by
    /// the dotted-hier_path arms, which key on finding a `.` in the text and
    /// so go silently null when a macro body's span reads back empty.
    std::string rawTextExpr(const slang::ast::Expression& e);
    // See the decode at the definition (ExprEmit.cpp): a package-QUALIFIED
    // reference to a package variable, which Surelog resolves only whole.
    bool isPkgQualifiedVarRef(const slang::ast::Expression& e);
    /// The literal's source spelling, rebuilt from its tokens when the span
    /// crosses a macro boundary (a macro-sized based literal).
    std::string rawTextLit(const slang::ast::Expression& expr);
    /// One `include_file_info` per ACTIVE `include directive, hung off the
    /// design (Surelog's "Compile Include file info" pass).
    void emitIncludeFileInfos();
    /// True when a packed struct/union has at least one member whose packed
    /// dimension is written with an IDENTIFIER bound (`pad_type_e
    /// [NDioPads-1:0] m`).  Surelog never flattens such a struct's pattern
    /// param in the package views.
    bool structHasSymbolicMemberDim(const slang::ast::Type& ty);
    /// True when `pkg::<name>` appears as a SCOPED reference anywhere in the
    /// sources.  Surelog only reduces a package parameter's ELABORATED
    /// param_assign when something resolves it through the package scope; a
    /// wildcard-imported (unqualified) read, or no read at all, leaves the
    /// elaborated RHS in its declared shape.
    bool hasScopedPkgRef(std::string_view pkgName, std::string_view name);
    std::set<std::string> scopedPkgRefs;
    bool scopedPkgRefsBuilt = false;
    /// True when `<name>.<member>` appears as a MEMBER SELECT anywhere in the
    /// sources.  Surelog's substituteAssignedValue reduces the selected
    /// parameter's own elaborated value in place, and that reduce is what
    /// FLATTENS a wide struct-pattern package parameter's elab listing; a
    /// parameter nothing member-selects keeps its tagged_pattern tree.
    bool hasMemberSelectOf(std::string_view name);
    std::set<std::string> memberSelectBases;
    bool memberSelectBasesBuilt = false;
    /// True when `(<name>)'(x)` appears anywhere: a PARENTHESIZED parameter
    /// size cast reuses the referenced parameter's own declaration
    /// int_typespec as the cast target, and Surelog stamps vpiInstance = the
    /// package on that shared object.  The stamp is a property of the
    /// PARAMETER, not of the cast site: it is present in every view, including
    /// the elaborated listing where the cast itself has folded away.
    bool isParenCastWidthParam(std::string_view name);
    /// True when the parameter's DECLARED default (its declarator's initializer
    /// syntax, not the elaborated/overridden value) is a literal.  Decides a
    /// `P'(x)` cast target's shape — see the definition in ExprEmit.cpp.
    bool castTgtDefaultIsLiteral(const slang::ast::ParameterSymbol& ps);
    std::set<std::string> parenCastWidthNames;
    bool parenCastWidthBuilt = false;
    /// `arr[3]` -> the span of the bare index token (`3`).  Surelog anchors the
    /// synthesized interface-array-element bit_select (and its index constant)
    /// there, not over the whole select expression.  Returns `range` unchanged
    /// when the text is not a bracketed select.
    slang::SourceRange ifaceElemIndexRange(slang::SourceRange range);
    bool macroInvLineCol(slang::SourceLocation loc, uint32_t& line, uint32_t& col);
    void fileLineCol(slang::SourceLocation lc, uint32_t& line, uint32_t& col);
    // (file buffer id, line) -> sorted [(usage start col, col delta)]
    std::map<std::pair<uint32_t, uint32_t>,
             std::vector<std::pair<uint32_t, int32_t>>>
        lineShifts;
    // Surelog's lexer swallows the whitespace that TRAILS a based number
    // literal (1'b0/4'd2/...) into the number token, so a run of N spaces
    // there counts as ONE column: every position later on that line moves
    // LEFT by N-1. Memoized per (buffer id, line):
    // sorted [(last space col, -(N-1))].
    std::map<std::pair<uint32_t, uint32_t>,
             std::vector<std::pair<uint32_t, int32_t>>>
        numLitWsShifts;
    const std::vector<std::pair<uint32_t, int32_t>>& numLitWsShift(
        slang::SourceLocation lc, uint32_t line, uint32_t col);
    // One text replacement inside a macro body: Surelog lays a body out with
    // each `formal` replaced by the actual argument text AND each nested macro
    // call replaced by its (recursively) expanded body. Every body position
    // past a replacement moves right by (replacementLen - replacedLen).
    struct MacroRepl {
        uint32_t start;    // offset of the replaced text within the body buffer
        uint32_t end;      // one past its last byte
        int32_t delta;     // expandedLen(parts) - (end - start)
        uint32_t defLine;  // def-file line of the replaced text (multi-line bodies)
        // Expansion buffers pasted over [start, end). slang gives every token
        // of a multi-token macro argument its own buffer, so one replacement
        // can have several parts.
        std::vector<uint32_t> parts;
    };
    // body-expansion buffer id -> top-level replacements, sorted by start.
    std::map<uint32_t, std::vector<MacroRepl>> macroRepls;
    // Offset of a continuation part's text within its replacement: slang puts
    // every token of a multi-token macro argument in its own buffer at offset
    // 0, but Surelog lays them out one after another.
    std::map<uint32_t, uint32_t> macroPartOffset;
    bool macroExpBuilt = false;
    void buildMacroExpansions();
    // Column delta a macro-expanded token acquires from replacements (argument
    // substitutions and nested macro expansions) that precede it within its
    // macro body line (0 for non-macro tokens).
    int32_t macroArgShift(slang::SourceLocation loc);
    // vpiDirection for a modport interface port (Surelog rule).
    int32_t interfacePortDirection(
        const slang::ast::InterfacePortSymbol& ip);
    // A module_array (vpiModuleArray) for an interface/module instance array.
    // withInstances: the elab view carries the per-index interface_inst
    // elements; the def view omits them (Surelog).
    // modElems (module instance arrays): the already-emitted per-index
    // module_inst elements to list under vpiModule; passing it selects the
    // MODULE flavour (no broadcast ports, ELAB view only).
    UHDM::module_array* emitModuleArray(
        const slang::ast::InstanceArraySymbol& arr, UHDM::module_inst* m,
        const std::string& prefix, NetMap& nets, bool withInstances,
        UHDM::VectorOfmodule_inst* modElems = nullptr);
    void noteUnsupported(const std::string& what);
    /// Whether `sub` is invoked from a CONTINUOUS / ELABORATION expression
    /// anywhere in the design (continuous assign, net-decl assign, parameter
    /// or localparam value, instance parameter override) — as opposed to only
    /// from procedural statements, or not at all.  Surelog compiles such a
    /// subroutine's formal types eagerly, which is what puts the unlocated
    /// logic_typespec on a BARE-IMPLICIT formal's io_decl (§ elabInvoked).
    bool elabInvoked(const slang::ast::SubroutineSymbol& sub);
    /// The FORMAL a parameter is bound to when it is passed, by bare name, as
    /// an argument of a constant-function call in one of those same
    /// elaboration expressions.  Surelog binds actual to formal and runs
    /// `adjustSize` on the SHARED constant, so the parameter's own elab
    /// param_assign Rhs ends up carrying the FORMAL's typespec and width
    /// (§ elabInvoked, argument side).  Null when the parameter is not so
    /// used.
    const slang::ast::FormalArgumentSymbol* elabCallFormal(
        const slang::ast::ParameterSymbol& ps);

    slang::ast::Compilation& comp;
    // Lazily built by elabInvoked(); empty optional = not yet scanned.
    std::optional<std::set<const slang::ast::SubroutineSymbol*>> elabCalledSubs;
    // Lazily built by elabCallFormal() alongside elabCalledSubs.
    std::map<const slang::ast::ParameterSymbol*,
             const slang::ast::FormalArgumentSymbol*>
        elabCallArgs;
    UHDM::Serializer& s;
    const slang::SourceManager* sm;
    UHDM::design* d = nullptr;
    std::map<const slang::ast::DefinitionSymbol*, DefInfo> defMap;
    // Interface definitions -> their def-view interface_inst shell (referenced
    // by a parent module's ref_module Actual in the def view).
    std::map<const slang::ast::DefinitionSymbol*, UHDM::interface_inst*> ifaceDefMap;
    // UDP declaration -> its design-level udp_defn (vpiUdpDefn of the
    // elaborated `udp` instances).
    std::map<const slang::ast::PrimitiveSymbol*, UHDM::udp_defn*> udpDefnMap;
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
    // The UHDM struct_typespec the assignment pattern currently being
    // re-emitted is assigned TO — the `tps` argument of Surelog's
    // ExprEval::flattenPatternAssignments.  Non-null only at the two call
    // sites that reproduce a flatten (a struct-typed cont_assign RHS and an
    // unpacked-struct declaration initializer); everywhere else the older
    // tag-dropping re-emit is kept verbatim.
    const UHDM::typespec* patFlatTs = nullptr;
    // True when the flatten runs in a context that ALSO runs Surelog's
    // expandPatternAssignment (the cont_assign RHS): its untagged arm calls
    // adjustOpSize on the flattened operands, which stamps the member width
    // onto them.  A declaration initializer flattens WITHOUT that pass.
    bool patFlatAdjust = false;
    // True while a module's DEF (allModules) view is being built — the
    // elaborated view of the same declaration folds bounds the def listing
    // keeps written (InterfArrayBind).  Set by emitModuleDef for the inline
    // body AND by materializeDefNetTs for the def-net typespecs it fills in
    // afterwards; any new deferred def-view builder must set it too.
    bool moduleDefEmit = false;
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
    // Root source file of the $unit PARAMETER whose own typespec range bound is
    // being emitted, while that bound was classified CROSS-FILE (see
    // makeTypespec's `unitParamTs`). A $unit param ref inside it that resolves
    // to a parameter declared in a DIFFERENT root file stays UNBOUND: Surelog
    // never saw that declaration while compiling this file, so its ref_obj
    // carries no vpiActual. Empty = inactive.
    std::string unitXFileRoot;
    // True while emitting a construct whose $unit parameter reads are left
    // UNBOUND (no vpiActual): if-generate CONDITIONS and DEF-view gen-block
    // continuous assigns. Surelog resolves those against the compilation-unit
    // VALUE, never its object, so the ref_obj it records dangles — the same
    // reason def-view gen CA refs to module signals carry no actual.
    // Module/package param and enum-const refs still bind.
    bool noUnitParamActual = false;
    // True while emitDefGenStmts stmt-ifies the DECLARATIONS of a generate
    // block in the DEF view.  Those typespecs are compiled detached from the
    // instance, so a range bound that names a `$unit` parameter stays an
    // UNBOUND ref_obj (see the unit-param binder in TypeEmit).  Deliberately
    // NOT set for the rest of the def-gen emission -- a gen-if condition in
    // the same region DOES bind its $unit refs.
    bool inDefGenDeclTs = false;
    // True while emitting DEF-view gen-block processes (all refs unbound,
    // including enum consts).
    bool defGenProcessEmit = false;
    // True while emitDefGenStmts stmt-ifies a generate block's CONT-ASSIGN in
    // the DEF view.  An enum-constant reference there stays UNBOUND, exactly
    // as in a gen-block process — a generate scope binds no enum const in
    // either view (see the unit-enum binder in TypeEmit).
    bool inDefGenCaExpr = false;
    // True while emitting a CLASS METHOD body outside an if/case CONDITION.
    // Measured (purpose-built goldens, package/module/program-scoped classes):
    // Surelog binds a class-method body ref to its io_decl/local var ONLY in
    // the condition of an if_stmt/if_else/case_stmt; every other position —
    // assignment lhs/rhs, call arguments, loop conditions and increments,
    // select indexes, case-ITEM expressions — stays unbound, enum consts
    // included (SimpleConstraint getType/print).
    bool classMethodNoBind = false;
    // True while emitting a `$unit`-scope subroutine's BODY: the compilation
    // unit is compiled before any instance and Surelog never revisits it with
    // a symbol table, so no reference in the body takes an actual (formals,
    // block locals and loop iterators alike).
    bool unitSubNoBind9 = false;
    // True while emitting a subroutine body that belongs to the package's
    // UN-ELABORATED (def) view: a package function in the def pass, or an
    // out-of-body class-method CLONE in the def package's Task_funcs. Surelog
    // compiles that view before it has a symbol table, so every `foreach`
    // loop list there is unresolved — the iterated array AND every loop
    // variable become ref_vars over freshly minted unsupported_typespecs
    // named as written (measured on a package holding a plain function, an
    // out-of-body class method and an in-class one: the def listing is
    // uniformly unresolved, the elaborated listing resolves what it can).
    bool pkgDefViewBody9 = false;
    // The package variables/nets of the package view currently being
    // emitted, by declaring symbol. A reference from one of that package's
    // own subroutines or class methods binds them (Surelog compiles those
    // bodies in the package's scope); OUTSIDE the package emit the map is
    // empty, so a module-body reference still mints its implicit wire.
    std::map<const slang::ast::Symbol*, UHDM::any*> pkgViewVarObjs9;
    // The same objects, kept for the whole run: a package-QUALIFIED read
    // (`p::iv`) from anywhere binds them.
    std::map<const slang::ast::Symbol*, UHDM::any*> pkgVarObjsAll9;
    // The subroutine BODY statement currently being emitted, and whether its
    // declarations parsed as `{ tf_item_declaration }` rather than
    // `{ block_item_declaration }` (see the decode at the top of
    // emitTaskFuncs's local loop). TF-items are function-scoped locals at the
    // declared-type span carrying vpiAutomatic, with NO wrapper begin; block
    // items are name-span, non-automatic locals owned by a `begin` that wraps
    // the body statement(s).
    const void* tfBodyStmt9 = nullptr;
    bool tfBodyTfItems9 = false;
    // A TASK-scope `parameter`/`localparam` is a body STATEMENT in Surelog:
    // its param_assign moves into the body `begin` (synthesized for the
    // purpose when the body has none) and is parented there, while the
    // parameter object survives only as the assign's Lhs. Carried from
    // emitTaskFuncs into StmtEmit's statement-list arm, which owns the
    // wrapper. `tfBodyPaAnchor9` holds each declaration's WHOLE-statement
    // span: parameter declarations count as body items when the wrapper picks
    // its anchor (the SECOND item). Functions keep the ordinary
    // function-level parameter model.
    std::vector<UHDM::param_assign*> tfBodyPa9;
    std::vector<slang::SourceRange> tfBodyPaAnchor9;
    // Set when the statement-list arm took ownership of them; a body that is
    // a SINGLE statement (`task t; parameter p = 1; x = 1; endtask`) never
    // reaches that arm, so emitTaskFuncs builds the wrapper itself.
    bool tfBodyPaUsed9 = false;
    bool callStmtContext = false;
    // Set while emitting an ELABORATED (top-view) module/interface PARAMETER.
    // Surelog builds the [N] -> [0:N-1] "decr by 1" op with an UNPARENTED
    // synthetic INT:1 (CompileExpression.cpp "Decr by 1"), but the elaborator
    // DEEP-CLONES module parameters (and their array_typespecs) into the
    // instance and clone_tree re-parents every child — so only the elaborated
    // copies carry vpiParent on that operand. Package params and net/var
    // ranges are never cloned, hence never parented.
    bool elabParamDim = false;
    // The param_assign Rhs object most recently emitted per parameter symbol.
    // A package DEF-view unpacked-dim ref binds the sized param's own constant
    // through it (DefaultPatternInt pack::V::CNT -> the CNT constant).
    std::map<const slang::ast::Symbol*, UHDM::any*> paramRhsObj;
    // The MODULE DEF view's array_typespec for an unpacked-array parameter,
    // keyed by its declarator syntax (the def body and every instance body get
    // their own ParameterSymbol, but they share one declarator).  Surelog's
    // ELAB `'{default:X}` array_expr points its ts ref at THIS object rather
    // than at a fresh clone — which is what makes UHDM's ElaboratorListener
    // reach the def-view unpacked dim's `N-1` ref_obj while an instance scope
    // is on its stack and bind that ref's Actual (ParamArrayUnsizedPattern
    // -elabuhdm: only the array_expr-valued param's def-view dim ref is bound;
    // its two operation-valued siblings, whose elab ts IS a fresh clone, stay
    // unbound in golden too).
    std::map<const slang::syntax::SyntaxNode*, UHDM::array_typespec*>
        defParamArrayTs;
    // Fullname of the parameter that owns the unpacked dim being built; set
    // while a PARAMETER's ranges are constructed so a folded param-sized dim
    // can name its typespec ref after the holder (DefaultPatternInt).
    std::string dimFoldOwner;
    // Set while emitting a MATERIALIZED IMPORTED package parameter's init in a
    // module: that parameter is a clone_tree copy of the package one, so its
    // concat literal operands carry vpiParent (the package original does not).
    bool importedParamClone = false;
    // ELAB view: an operation SUBSTITUTED for a no-fold pattern parameter's
    // reference carries a ts ref to that parameter's own ELAB typespec (the
    // clone patchParamTypespecs mints).  The substitution happens while the
    // READER's Rhs is emitted, before the referenced param's clone exists, so
    // the ref is parked here and bound (and dropped) in patchParamTypespecs.
    std::vector<std::pair<const slang::ast::ParameterSymbol*,
                          UHDM::ref_typespec*>>
        pendingSubstOpTs;
    // The elab typespec clone patchParamTypespecs last minted per parameter —
    // lets a LATER reader (a child instance's override) bind directly instead
    // of parking, since that parameter's patch pass has already run.
    std::map<const slang::ast::Symbol*, UHDM::typespec*> elabParamOwnTs;
    // Bind `rt` to `p`'s elab typespec, or park it until that clone exists.
    void bindOrParkParamTs(const slang::ast::ParameterSymbol& p,
                           UHDM::ref_typespec* rt);
    // The constant Surelog substitutes for a reference to an ENUM MEMBER
    // inside a PACKAGE struct-pattern parameter: the member's OWN literal
    // form (an implicit member -> INT at the enum base width; `= 4'h6` ->
    // HEX:6 / decompile "4'h6"). Null when `sym` is not an enum member or its
    // value is not reconstructible. Located by the caller.
    UHDM::constant* enumMemberSubstConst(const slang::ast::Symbol& sym);
    // True when the enum member has a LITERAL form to substitute: an integer
    // literal initializer, or none at all (an implicit member, which carries
    // its computed decimal).  A member initialized by an EXPRESSION (rp32's
    // `RV32I = {RV_32I, RV_NONE}`) has no literal form — enumConstMap holds
    // its SOURCE TEXT as the decompile, which is not what a struct-pattern
    // member substitution wants.  EnumConstElab / rp32_r5p_alu.
    bool enumMemberLiteralForm(const slang::ast::Symbol& sym);
    // Set while the ELAB flatten of a PACKAGE-ORIGIN struct param re-emits a
    // NESTED member pattern. That recursion runs before paramInitPkg /
    // importedParamClone are set for this parameter, so it needs its own flag
    // to reach the enum substitution above.
    bool pkgEnumSubstPat = false;
    // Set while emitting a DEF-view ref_module port's HighConn expression.
    // A tagged_pattern's literal value there is built by compileConst and never
    // re-parented (Surelog parents pattern values only under a param_assign Rhs
    // or an ELABORATED cont_assign Rhs).
    bool defRefModConn = false;
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
    // ELAB package view of a MULTIDIMENSIONAL param (>1 packed range): Surelog
    // compiles its value with Reduce::No (CompileHelper::isMultidimensional
    // gates the reduce), so same-package param references inside the init stay
    // ref_objs in the elab view instead of folding to constants.
    bool pkgElabSymOperands = false;
    // ELAB (top) view of a MODULE-scope MULTIDIMENSIONAL param (>1 packed
    // range) — the same CompileHelper::isMultidimensional / Reduce::No gate
    // pkgElabSymOperands names for packages.  Its func_call Rhs keeps the DEF
    // argument tree: a localparam ref argument stays a ref_obj instead of
    // folding to the parameter's elaborated value (FuncInModule OFFSET_LIST).
    bool elabMdimParamInit = false;
    // ELAB package view of a struct param whose tagged_pattern tree SURVIVES
    // (no `pkg::NAME` reference drives the flatten pass): Surelog still reduces
    // each member VALUE that is an expression to a constant in place, leaving
    // an already-constant value untouched.
    bool paramInitElabFold = false;
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
    // True while emitPackage builds the DEF-view listing of a package struct
    // typedef for a package that ANOTHER package imports: the top view shares
    // the importer's clone instead of building, so the def/top member
    // cross-wire never runs and the def listing must be built symbolic
    // directly (BlackBePipeInt bp_common_pkg::rv64_instr_btype_s).
    bool pkgDefListingSymBound = false;
    // The PACKAGE scope declaring the struct currently being built (null for a
    // module/$unit struct) — a member dim bound that resolves to a param of a
    // DIFFERENT package folds instead of staying symbolic.
    const slang::ast::Scope* structPkgScope = nullptr;
    // Which cont-assign RHS view is being emitted: 0 = not in a cont-assign
    // RHS, 1 = def (allModules), 2 = elab (topModules). Unbased-unsized
    // func-call args key their formal-ts/fold behavior on this.
    int contAssignView = 0;
    // Emitting a NET-DECL-ASSIGN's RHS (`wire x = ...;`, elab view only —
    // contAssignView stays 0 there because Surelog compiles these in the
    // netlist pass, not the cont-assign one).  A func call NESTED UNDER AN
    // OPERATION in such an RHS stamps no formal typespec on its argument refs.
    bool ndaRhsEmit = false;
    // Inside the BRANCHES of a cont-assign-RHS ternary whose condition did not
    // fold to a constant: Surelog's reduction abandons the expression at that
    // first unfoldable operand, so nothing below binds actuals to formals.
    bool caCondReduceStop = false;
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
    // Interface-def function-body signal refs awaiting their ELAB-view
    // variable binding (Surelog binds the shared def function at elab).
    std::map<const slang::ast::DefinitionSymbol*,
             std::vector<std::pair<const slang::ast::Symbol*, UHDM::ref_obj*>>>
        ifaceFnRefFixups;
    // Elab child-instance packed-range bounds that reach an interface param
    // through a modport/interface port fold at the interface's DEFAULT param
    // value (the AllModules width), NOT the connected override — Surelog.
    // Keyed by the interface definition; the cached default instance supplies
    // each through-port param's default value.
    std::map<const void*, const slang::ast::InstanceSymbol*> moduleDefaultInst;
    // Surelog can't resolve block-scoped localparams; refs to them bind an
    // implicit module-level wire created at the first reference.
    std::map<const slang::ast::Symbol*, UHDM::logic_net*> implicitNetMap;
    /// Block-local variables whose TYPE KEYWORD the Verilog-mode lexer hides
    /// (`logic` in a `.v` file): Surelog emits them as unbound `ref_var`s, so
    /// every procedural reference leaks an implicit module wire instead.
    std::set<const slang::ast::Symbol*> vlogHiddenBlockVars;
    UHDM::instance* implicitNetModule = nullptr;
    std::string implicitNetPrefix;
    // foreach_stmt: the iterated array's ref_typespec binds the array's OWN
    // array_typespec, which the instance view only mints later — so the ref is
    // recorded here and filled in the deferred drain.
    struct PendingForeachTs {
        UHDM::ref_typespec* rt;
        const slang::ast::Symbol* sym;
        UHDM::instance* mod;
    };
    std::vector<PendingForeachTs> pendingForeachArrayTs;
    std::map<const slang::ast::Symbol*, UHDM::typespec*> arrayVarArrayTs;
    // Subroutine-LOCAL fixed-size unpacked arrays, mapped to the very
    // array_typespec their array_var carries. A `foreach` over one of these
    // hands that whole typespec to its implicitly declared loop variables, so
    // they come out array_var — Surelog's getSimpleVarFromTypespec never sees
    // an element type here, unlike the module-scope, queue and dynamic-array
    // cases, which all drill to the element (probes r10c4_p4/p5/p6).
    std::map<const slang::ast::Symbol*, UHDM::typespec*> tfLocalArrayTs9;
    // foreach loop variables that shadow an existing declaration share that
    // declaration's typespec; when the shared ref_typespec is itself bound in
    // a later pass (module nets), mirror it afterwards.
    std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_typespec*>>
        pendingLoopVarTs9;
    // Loop variables of the foreach statements currently open, by name: a
    // NESTED foreach re-lists the enclosing loop's variable OBJECT (Surelog's
    // late-binding swap), it does not declare a second one.
    std::map<std::string, UHDM::variables*> openForeachVars;
    // Package scope currently emitting task_funcs (ts vpiInstance owner).
    UHDM::instance* pkgScopeInst = nullptr;
    // During an explicit-import subroutine COPY re-emission, the typespecs of
    // the clone keep vpiInstance = the HOME package (where the function is
    // defined), not the importing package. Non-null only inside that clone.
    UHDM::instance* importCopyTsInst = nullptr;
    // While re-emitting an IMPORTED package param's initializer in a MODULE
    // view: size-cast typespecs of that copy keep vpiInstance = the home
    // package (like the package view) and parent at their own ref_typespec.
    UHDM::instance* importedInitPkgInst = nullptr;
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
    // The WILDCARD-import subroutine CLONE a package materializes, keyed by
    // (importing package symbol, home subroutine symbol) — one entry per
    // package VIEW pass, cleared as each view finishes (§ collectPkgTfListing).
    std::map<std::pair<const slang::ast::Symbol*, const slang::ast::Symbol*>,
             UHDM::task_func*>
        pkgWildcardCloneTf;
    // True while a wildcard-import clone re-emits: the clone must not claim
    // the home subroutine's elab-twin / def-name registrations.
    bool pkgImportCloneEmit = false;
    // ...and its body's return-value references bind THIS variable (the home
    // function's own vpiReturn object) rather than a fresh per-ref local.
    UHDM::variables* pkgImportCloneRetVar = nullptr;
    const slang::ast::Symbol* pkgImportCloneHomePkg = nullptr;
    // (clone function, home package symbol): once the ELABORATED package
    // views exist, every clone's vpiReturn is re-pointed at the TOP home
    // function's return variable — Surelog's clone shares that object, not
    // the def listing's (golden EvalFuncNamed prints my_module_types'
    // def-view clone Return in full and abbreviates it inside my_funcs' TOP
    // listing, so the two are one object).
    std::vector<std::pair<UHDM::function*, const slang::ast::Symbol*>>
        pkgCloneRetFixups9;
    // Unqualified calls to package functions, per module def body.
    std::map<const void*,
             std::vector<std::pair<UHDM::task_func*, slang::SourceRange>>>
        importedTfCalls;
    // Gen-scope conn CALLS materialize an implicit wire named after the
    // function in the gen scope (Surelog): {name, call range}.
    std::vector<std::pair<std::string, slang::SourceRange>> pendingGenCallNets;
    // (enclosing module, imported fn) — listed on the module AFTER the
    // shared-def Task_funcs assignment.
    std::vector<std::pair<UHDM::instance*, UHDM::task_func*>>
        pendingConnTfList;
    // Cast-size exprs also keep name-token-only call spans.
    bool inCastSize = false;
    // Refs inside indexed-part-select base/width exprs are scoped by the
    // select base name.
    std::string selectBasePrefix;
    // >0 while emitting a select INDEX whose nested refs are re-scoped under
    // the select base name (work@m.mem.idx): Surelog synthesizes that same
    // bogus hier path and then fails to resolve it, so such refs carry no
    // actual in the elaborated gen-scope cont_assign RHS.
    int selIdxScopeDepth = 0;
    // True while emitting an elaborated gen-scope cont_assign RHS.
    bool inGenScopeCaRhs = false;
    // True while emitting a FOR-generate gen-scope cont_assign RHS: module
    // params in select bounds fold to typed constants (outside call args).
    bool genCaLoopParamFold = false;
    // Root prefix of the top instance currently being emitted (bind
    // instances DISPLAY directly under it while contents keep real paths).
    std::string currentTopPrefix;
    std::string bindDisplayPath;
    NetMap* currentTopNets = nullptr;
    // Scope for late syntax binding (cast size exprs).
    const slang::ast::Scope* currentScope = nullptr;
    // Fallback for the same binding while emitting a PACKAGE parameter's
    // init: emitParameters never sets currentScope for a package body, so a
    // size cast written there (`(dev_id_width_gp+dev_addr_width_gp)'('h...)`)
    // could not re-bind its width syntax and fell through to the catch-all
    // logic_typespec instead of minting the integer_typespec + vpiExpr shape
    // Surelog builds (BlackBePipeInt bp_common_pkg host_base_addr_gp).
    const slang::ast::Scope* castBindScope = nullptr;
    std::map<const slang::ast::Symbol*, bool> paramIntEnc;
    std::vector<PendingParamTs> pendingParamTs;
    // An ELAB unpacked-array param's own array_typespec clone is built after
    // the instance's net/port typespecs (Surelog arena order); each entry
    // mints one (idempotent — the folded-pattern path forces it early).
    std::vector<std::function<void()>> pendingElabArrayTs;
    // Def-view local-net typespecs are created only after the top-level
    // instance's ports have been elaborated (Surelog arena order).
    struct PendingNetTs {
        const slang::ast::Symbol* sym;
        UHDM::ref_typespec* rt;
        DefInfo* di;
    };
    std::vector<PendingNetTs> pendingNetTs;
    // (target, source) ref_typespec pairs that must end up sharing ONE
    // typespec object; resolved after the pendingNetTs drain.
    std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_typespec*>> netTsAlias;
    void materializeDefNetTs(PendingNetTs& pn);
    /// Elaborated instances count per definition (non-top instances only), so
    /// the LAST instance of a def can be recognised while it is emitted.
    std::map<const slang::ast::DefinitionSymbol*, unsigned> defInstTotal;
    std::map<const slang::ast::DefinitionSymbol*, unsigned> defInstSeen;
    /// Elaborated instances per definition INCLUDING top instances — the
    /// number of times Surelog's DesignElaboration re-enters CompileModule on
    /// the definition for each plain item of an explicit generate region.
    std::map<const slang::ast::DefinitionSymbol*, unsigned> defAllInstCount;
    /// The port typespecs of a def's LAST elaborated instance are created in
    /// the WRITE phase (name-sorted def walk), not inline (Surelog arena
    /// order): every earlier instance keeps its inline slot.
    struct PendingElabPortTs {
        UHDM::ref_typespec* rt;
        const slang::ast::Symbol* internal;
        const slang::ast::PortSymbol* ps;
        const slang::ast::DefinitionSymbol* def;
        const slang::ast::Scope* scope;
        bool elabTs;
        bool tfCtx;
    };
    std::vector<PendingElabPortTs> pendingElabPortTs;
    void drainElabPortTs(const slang::ast::DefinitionSymbol* def);
    bool defPortTsInterchangeable(const slang::ast::DefinitionSymbol& def);
    // anyParam widens the trigger to ANY parameter reference (a NON-TOP def
    // view keeps every param-ref dim symbolic, localparams included).
    bool rangeRefsOverriddenParam(const slang::ast::Symbol& sym,
                                  bool anyParam = false);
    // True when the definition is instantiated as an ARRAY (arr[N] ())
    // anywhere in the design; cached per definition.
    bool defInstantiatedAsArray(const slang::ast::DefinitionSymbol& def);
    std::map<const void*, bool> defArrayInstCache;
    // ELAB interface-port LowConn ref_objs by their vpiFullName
    // (<inst-path>.<port>): a child's kept-symbolic bound reuses the SAME
    // object as the hier_path's vpiExpr (Surelog aliases it).
    std::map<std::string, UHDM::ref_obj*> ifacePortLowConnByPath;
    std::map<const slang::ast::Symbol*, UHDM::ref_obj*> ifacePortLowConnBySym;
    // True when the expression reads a PARAMETER of an INTERFACE through an
    // interface/modport PORT of `body` (s.CFG.DAT) — Surelog never reduces
    // such a read, in either view.
    bool ifacePortParamHopRead(const slang::ast::Expression& e,
                               const slang::ast::InstanceBodySymbol& body);
    std::vector<TopPending> topPendings;
    std::map<const slang::ast::Symbol*, SubInfo> subMap;
    /// (module definition, subroutine name) -> the DEF-emitted subroutine
    /// symbol, so an ELAB instance's param-init call site can bind the shared
    /// def function object instead of minting an empty shell.
    std::map<std::pair<const slang::ast::Symbol*, std::string>,
             const slang::ast::Symbol*>
        defSubByName;
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
        // Home-package instance the deferred typespec belongs to (a
        // package-scope cast, or a module-view copy of an imported param's
        // init) — stamped as vpiInstance at drain.
        UHDM::instance* pkgInst = nullptr;
    };
    std::vector<PendingCastTs> pendingCastTs;
    // A cast to a packed-ARRAY-of-struct typedef: the fresh per-cast clone
    // (array ts + its own element struct clone) is created at the very end of
    // the write phase, after the def-net typespecs (Surelog arena order).
    struct PendingCastAggTs {
        UHDM::ref_typespec* rt;
        UHDM::packed_array_typespec* shared;
        const slang::ast::Type* aliasType;
        std::string prefix;
    };
    std::vector<PendingCastAggTs> pendingCastAggTs;
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
        UHDM::instance* mod;
        const slang::ast::Symbol* sym;
        // Surelog copies the bound variable's typespec verbatim, so an
        // IMPLICIT net (which has none) leaves the ref UNRESOLVED rather than
        // minting one (HighLow's `assign ccc = $high(a)`). The older
        // $signed/$unsigned entries keep their synthesized fallback.
        bool nullIfNoTs = false;
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
    // A parameter declared in a TASK body: Surelog models it as a body
    // statement, so it is invisible to the body's own name resolution.
    static bool isTaskScopeParam9(const slang::ast::Symbol& sym);
    bool implicitNetFromPatternKey(const slang::ast::Symbol* sym,
                                   const slang::ast::InstanceBodySymbol& body);
    std::vector<PendingFuncRet> pendingFuncRet;
    void drainFuncRet(bool pkgOnly = false);
    // A pkg ALIAS-of-vector-typedef's bare clone aliases the TARGET's
    // TOP/module listing object (jeras_union imm_l_t); the top listing does
    // not exist at def-pkg time, so the binding resolves after the top walk.
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Symbol*>>
        pendingAliasChainTgt;
    void emitImportArtifacts(const slang::ast::InstanceBodySymbol& body, UHDM::instance* m);
    /// The subroutine group a wildcard `import <pkg>::*` MATERIALIZES at the
    /// importing scope: the package's own subroutines (the ELABORATED twin)
    /// and its classes' out-of-body method DEFINITION objects, merged into
    /// the package's ONE source-ordered listing pass (§ pkgTfOrder9) — i.e.
    /// the same order and length as the package's DEF-view listing, but with
    /// each `C::m` clone replaced by the class_defn-parented definition.
    std::vector<UHDM::task_func*> materializedPkgTfGroup(
        const slang::ast::PackageSymbol& pkg);
    /// The COMPILATION-UNIT-scope wildcard imports of the whole design, in
    /// source order.  These — and only these — feed `design->vpiTaskFunc`.
    std::vector<const slang::ast::PackageSymbol*> unitScopeWildcardImports();
    /// The DEF view's tail of nets: every bare name a HOISTED class method
    /// body (see classPropRefs) failed to resolve binds a net of that name
    /// here, and one is minted into @a nets when the module declares none.
    void bindHoistedClassPropRefs(const slang::ast::InstanceBodySymbol& body,
                                  UHDM::instance* m, const std::string& prefix,
                                  UHDM::VectorOfnet* nets);
    /// A `$unit` enum CONSTANT referenced from a file other than the one that
    /// declared the enum is unresolvable to Surelog: mint the implicit module
    /// wire it falls back to, one per name, in source order of first use.
    void mintUnitEnumNets(const slang::ast::InstanceBodySymbol& body,
                          UHDM::instance* m, const std::string& prefix,
                          NetMap& netMap, bool defView);
    /// Those wires, per module DEFINITION — the elab views share them.
    std::map<const void*, std::map<const slang::ast::Symbol*, UHDM::logic_net*>>
        unitEnumNetsByDef;
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
    // The package currently being emitted by emitPackage (both views); null
    // outside package emission. Distinguishes a HOME-package typedef listing
    // from an import-clone build (whose enum's parent differs).
    const slang::ast::Symbol* curPkgEmitSym = nullptr;
    // Which VIEW of curPkgEmitSym is being emitted. Unlike pkgTopEmit (set
    // only for the typedef/task-func arms) this covers the whole emitPackage
    // body, including the PARAMETER arm — where a package param's own
    // typespec range bound is view-dependent (makeTypespec's pkgParamTsRef).
    bool pkgEmitTopView = false;
    // True while buildEnumTs builds an IMPORT-LISTING clone of another
    // package's enum typedef (emitPackage import arm): concat enum-const
    // decompiles follow Surelog's clone rules (all-ref concat drops the
    // decompile; op-containing concats fold each operand).
    bool importCloneEmit = false;
    // True while buildEnumTs builds a package's own DEF-LISTING enum object
    // (emitPackage enum arms, def pass): sys-call base bounds stay SYMBOLIC
    // there (member-use clones and import clones fold) — rp32 fn3_alu_et.
    bool pkgListingEnumBuild = false;
    // Child-instance CA re-emission folds type casts (top modules keep them).
    bool foldTypeCasts = false;
    const slang::ast::SubroutineSymbol* currentSubSym = nullptr;
    // True when some CONTINUOUS assignment in the subroutine's own instance
    // body calls it as its DIRECT rhs (the only context that pushes an
    // assignment size through the call into the body — see the
    // unbased-unsized RHS rule in ExprEmit). Memoized per subroutine.
    bool subCalledAsContAssignRhs(const slang::ast::SubroutineSymbol& sub);
    std::map<const slang::ast::SubroutineSymbol*, bool> subContAssignRhsCache;
    // True when Surelog's ExprEval actually EXECUTES this subroutine while
    // reducing a parameter of its own instance body — see TaskFuncEmit.cpp.
    bool subEvaluatedFromParamInit(const slang::ast::SubroutineSymbol& sub);
    std::map<const slang::ast::Scope*, std::set<const slang::ast::SubroutineSymbol*>>
        paramEvalSubsCache;
    // § memberActualLeak — the blocking assignments whose LHS member of a
    // local struct variable Surelog's constant evaluator stamps onto the
    // struct typespec_member as vpiActual_value.  See TaskFuncEmit.cpp.
    bool memberActualLeak(const slang::ast::Expression& asnExpr);
    void buildMemberActualLeak();
    std::optional<std::set<const slang::ast::Expression*>> memberLeakAsgs;
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
    // ...and the FALLBACK for the ones no CA fold ever claims: Surelog gives
    // EVERY overridden no-default param an elab Rhs, whether or not the body
    // reads it.  Measured (purpose-built golden, one instantiation each):
    // typed `int unsigned N` + `.N(8)` -> loc-less UINT 8 at the VALUE width
    // (32) WITH a ts ref to the param's own elab typespec; untyped
    // `parameter N` + `.N(8)` -> UINT 8 at width 64, NO typespec; a BASED
    // literal (`68'h2...`, `4'hA`) keeps its own base/digits at its WRITTEN
    // size in both cases.  Drained (Rhs-still-null only, so the CA-fold
    // sharing above always wins) in emitTopPorts, before the param typespecs
    // are patched.  PartSelect4.
    struct NoDefOvFallback {
        UHDM::param_assign* pa;
        const slang::ast::ParameterSymbol* ps;
        std::string prefix;
    };
    std::vector<NoDefOvFallback> noDefOvRhsFallback;
    void drainNoDefOvRhs();
    // Named property declarations (shared def objects, listed in elab views).
    std::map<const slang::ast::Symbol*, UHDM::property_decl*> propertyDeclMap;
    // `let` declarations (shared def objects, listed in elab views too), and
    // the reverse index from a let's BODY syntax -- which is what a let
    // expansion carries as its own `syntax` -- back to the declaration.
    std::map<const slang::ast::Symbol*, UHDM::let_decl*> letDeclMap;
    std::map<const slang::syntax::SyntaxNode*, const slang::ast::LetDeclSymbol*>
        letBodySyntax;
    // Set while emitting a let_decl body: formal refs (which bind Invalid,
    // exactly like property formals) resolve through this scope -- but to a
    // bare ref_obj, NOT to an implicit module wire (Surelog leaks property
    // formals as module nets and let formals not at all).
    const slang::ast::LetDeclSymbol* letDeclScope = nullptr;
    // Class definitions (design->AllClasses), keyed by the ClassType symbol.
    std::map<const slang::ast::Symbol*, UHDM::class_defn*> classDefnMap;
    // A PARAMETERIZED class has one class_defn in Surelog (compiled from its
    // DEFAULT specialization), but slang mints a distinct ClassType per
    // specialization, so `resource#(T)` inside another class is a symbol
    // classDefnMap never saw. Key the same class_defn by the generic
    // declaration too, so any specialization resolves to it.
    std::map<const slang::ast::Symbol*, UHDM::class_defn*> genericDefnMap;
    // class_defn for a class type, following a specialization back to its
    // generic declaration when the specialization itself was never emitted.
    UHDM::class_defn* classDefnFor(const slang::ast::Type& ct);
    // --builtins: mirror Surelog's default (no -nobuiltin) content.
    bool builtins = false;
    std::string builtinFilePath;
    // The synthesized `builtin` package (Part A), prepended to AllPackages /
    // TopPackages exactly as Surelog's UhdmWriter does.
    void emitBuiltinPackage(UHDM::VectorOfpackage*& allP, UHDM::VectorOfpackage*& topP);
    // True for the injected <cwd>/builtin.sv compilation unit.
    bool isBuiltinUnit(const slang::ast::Scope& unit);
    // Class-scope typedefs (vpiTypedef on a class_defn). Surelog writes the
    // class's DataTypeMap (a name-keyed std::map, hence NAME order) and, unlike
    // every other scope, gives a class_defn's typespecs no vpiInstance
    // (UhdmWriter::writeDataTypes). Enum aliases stay behind --builtins (the
    // builtin `process::state` shape); CLASS-handle aliases are always listed.
    void emitClassTypedefs(const slang::ast::ClassType& cls, UHDM::class_defn* cd);
    void buildClassTypedefTs(const slang::ast::ClassType& cls,
                             const std::string& clsName);
    // Reentrancy guard for buildClassTypedefTs.
    std::set<const void*> buildingClassTypedefs;
    // Class-nested typedefs whose typespec had to be built on demand by a
    // reference from an EARLIER-sorted class: Surelog's variable-class
    // fallback for such a forward reference is a class_var (IOClassStruct).
    std::set<const void*> onDemandClassTypedefs;
    // PACKAGE-scope class definitions, listed under the ELABORATED (top-view)
    // package only — Surelog's un-elaborated Package carries an empty class map
    // (UhdmWriter.cpp writePackage/getUnElabPackage). Listed name-sorted, the
    // order of Surelog's multimap<name, ClassDefinition*>.
    void emitPackageClasses(const slang::ast::PackageSymbol& pkg, UHDM::package* up,
                            const std::string& prefix);
    // The DEF-view package's Task_funcs listing for classes whose methods are
    // declared `extern`: ONE SEPARATE CLONE per out-of-body definition, named
    // "class::method" (qualified) and parented at the un-elaborated package.
    // Order is every class's NON-constructor definitions in class-declaration
    // order, THEN every class's constructor definitions in the same order —
    // Surelog binds constructors in a second pass. The ELABORATED package
    // carries no Task_funcs at all; it lists the class_defns instead.
    void emitPackageClassMethodClones(const slang::ast::PackageSymbol& pkg,
                                      const std::string& prefix);
    // R-J1: a package that wildcard-imports another materializes the home's
    // WHOLE DEF-view listing, out-of-body class methods included, as DISTINCT
    // objects in BOTH of its own views.  The free-subroutine half rides the
    // import loop in emitPackage; this is the CLASS half, which has to wait
    // until the home package's class_defns exist — those are built in its TOP
    // pass, and the DEF views of ALL packages are emitted before any TOP view,
    // so the def-view copies cannot be made in the def pass.  Called once per
    // view (target = this package's DEF object, then its TOP object) from the
    // TOP pass.
    void emitImportedPkgClassMethodClones(const slang::ast::PackageSymbol& pkg,
                                          const std::string& prefix,
                                          UHDM::package* target);
    // One PACKAGE-scope data declaration that is NOT a net (see the net/var
    // split documented at the call site in emitPackage): appends the matching
    // variables object to `out`, or appends nothing for a shape that is not
    // modelled yet (unpacked arrays).
    // Also builds the ELAB-view copy an importing MODULE materializes (same
    // shape, module parent/prefix) — there @a stampTsInstance is false: the
    // copy's typespec is re-created at the module and carries no vpiInstance
    // (Surelog resolves it outside the package's scope).
    void emitPackageVar(const slang::ast::Symbol& vs, UHDM::instance* up,
                        const std::string& prefix,
                        UHDM::VectorOfvariables* out,
                        bool stampTsInstance = true);
    // One PACKAGE-scope DYNAMIC-container declaration (`C q[$];`,
    // `C t[string];`, `int d[];`): an array_var carrying vpiSize 1,
    // vpiArrayType, a BARE array_typespec (no name, no span, no ranges, no
    // element ref -- unlike the subroutine-local shape makeQueueDynArrayVar
    // builds) and ONE vpiReg element variable whose own typespec is the
    // declaration's element type.  Returns false when `vs` is not one of the
    // three container kinds.
    bool emitPkgArrayVar(const slang::ast::Symbol& vs, UHDM::instance* up,
                         const std::string& prefix,
                         UHDM::VectorOfvariables* out);
    // The body locals of the package's OUT-OF-BODY CONSTRUCTOR definitions,
    // in source order, nested `begin` blocks included: Surelog lists a
    // DUPLICATE of each as a package variable (see the call site).
    void collectOobCtorLocals(
        const slang::ast::PackageSymbol& pkg,
        std::vector<const slang::ast::Symbol*>& out);
    // A class's `extends` wiring is deferred: the base class_defn may not exist
    // yet (another package, a later file-level class). Drained once every
    // class_defn is built, derived-class-name-sorted so vpiDerivedClasses lands
    // in Surelog's design-wide multimap order.
    struct PendingExtends {
        UHDM::class_defn* cd;
        const slang::ast::ClassType* cls;
    };
    std::vector<PendingExtends> pendingExtends;
    void drainPendingExtends();
    // class_typespecs whose vpiClassDefn target may not have been emitted yet
    // (name-sorted class lists put a base class after its user). Patched
    // alongside the extends drain.
    std::vector<std::pair<UHDM::class_typespec*, const slang::ast::Type*>>
        pendingClassTsLink;
    // A SPECIALIZED class handle (`config_db#(object#(longint)) misc2;`) carries
    // the specialization on the class_typespec itself: one vpiParameter
    // type_parameter per formal, holding the ACTUAL type, plus a vpiParamAssign
    // whose Lhs is the class_defn's own formal and whose Rhs is that local
    // type_parameter. A class-typed actual recurses, so the shape nests.
    // Fullnames chain off the typespec name: `config_db.T`, then
    // `config_db.T.object.T` for the actual's own formal.
    void emitClassTsParams(UHDM::class_typespec* cts,
                           const slang::ast::ClassType& cls,
                           const std::string& prefix);
    // param_assigns of a class_typespec specialization whose class_defn was not
    // emitted yet: the Lhs (the class_defn's own formal) is bound at the drain.
    struct PendingClassTsPa {
        UHDM::param_assign* pa;
        const slang::ast::Type* cls;
        std::string paramName;
    };
    std::vector<PendingClassTsPa> pendingClassTsPa;
    // Class-scope `parameter` / `localparam` / `parameter type` declarations:
    // vpiParameter + vpiParamAssign on the class_defn.
    void emitClassParameters(const slang::ast::ClassType& cls, UHDM::class_defn* cd,
                             const std::string& fullName);
    // The vpiReg element variable of a class-scope dynamic-array / queue /
    // assoc property, typed by the shared element typespec. Null when the
    // element type has no variable form here.
    UHDM::variables* classElemVar(const slang::ast::Type& elemType);
    // The vpiReg element of an ASSOCIATIVE class property, which is
    // classElemVar except when the element type is a typedef Surelog cannot
    // see from the declaring class (a BASE class's nested typedef, reached
    // bare or through `base::`) — those degrade to a bare logic_var.
    UHDM::variables* classAssocElemVar(const slang::ast::Symbol& cp,
                                       const slang::ast::Type& elemType,
                                       const slang::ast::ClassType& owner);
    // The associative dimensions of a class property: vpiIndexTypespec for
    // the outermost, a `STRING:associative` marker vpiRange per inner one.
    void emitAssocDims(const slang::ast::Symbol& cp,
                       const std::vector<const slang::ast::Type*>& idx,
                       UHDM::array_var* av, UHDM::array_typespec* ats);
    // One associative INDEX type as a typespec (string / class / enum
    // typedef / integral); null when the index type has no form here.
    UHDM::typespec* assocIndexTs(const slang::ast::Type& idx,
                                 const slang::ast::Symbol& sym);
    // A class-scope typedef of a queue / dynamic / associative array: a bare
    // array_typespec carrying one raw marker range per written dimension.
    UHDM::typespec* buildDynContainerTypedefTs(
        const slang::ast::TypeAliasType& ta,
        const slang::syntax::SyntaxNode* typeSyn);
    // The already-emitted typespec object for a package/module/class TYPEDEF
    // (the elaborated copy wins, as in makeTypespec); null when unregistered.
    UHDM::typespec* sharedAliasTs(const slang::ast::Type& t);
    // The class_defn currently being filled (a `new` constructor's synthesized
    // return class_var points its class_typespec at it).
    UHDM::class_defn* currentClassDefn = nullptr;
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
    // § unitRefSubst — the emitted param_assign Rhs of every $unit parameter,
    // keyed by its symbol.  An UNFOLDED $unit init SPLICES these in place of
    // the references it could resolve (see emitSyntaxExpr's IdentifierName
    // arm), so the tree has to be reachable after the fact.
    std::map<const slang::ast::Symbol*, UHDM::expr*> unitParamRhs;
    // Set only while an unfolded $unit parameter init is being emitted from
    // syntax: the compilation-unit scope its references resolve through, and
    // the root file that owns the declaration (a reference reaching ANOTHER
    // root file is one Surelog's reducer never saw, so it stays dangling).
    const slang::ast::Scope* unitSubstScope = nullptr;
    std::string unitSubstRoot;
    // ref_typespecs minted on spliced values, resolved to the SUBSTITUTED
    // parameter's own typespec in the pendingUnitParamTs drain (that typespec
    // does not exist yet when the splice happens).
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Symbol*>>
        pendingUnitSubstTs;
    // Deep-copy a $unit parameter's value tree for a splice (constant /
    // ref_obj / operation; null for any other shape, which leaves the
    // reference alone).
    UHDM::expr* cloneUnitParamRhs(const UHDM::expr* src,
                                  UHDM::BaseClass* parent);
    // § genLoopUnitMiseval — $unit parameters Surelog's reducer could NOT
    // give a value (unfolded init).  Anything whose evaluation depends on one
    // is evaluated by Surelog as "no result", and a GENERATE LOOP with no
    // result produces NO gen_scope_array at all.
    std::set<const slang::ast::Symbol*> unitParamNoValue;
    bool genLoopUnitMiseval(const slang::ast::GenerateBlockArraySymbol& arr);
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
    // The property-scoped ref prefix (work@m.<prop>) that goes with
    // `propDeclScope`, for formal refs reached from a raw-syntax path.
    std::string propDeclRefPrefix;
    // Set only while emitting a property_spec's OWN vpiClockingEvent: the
    // formal ref there spans the `@` too (`@clk` -> 9:5-9:9), and so does the
    // module wire it leaks.  A clocking event nested inside the sequence (the
    // clocked_seq case) spans the NAME alone (`clkx` -> 13:18-13:22).
    bool propSpecClockEvent = false;
    // Set inside a clocked_seq: its formal refs carry no vpiFullName.
    bool bareFormalRefNames = false;
    UHDM::ref_obj* emitPropFormalRef(std::string_view nm, slang::SourceRange nr,
                                     UHDM::BaseClass* parent, const std::string& prefix);

    // ---- let declarations / --disable-feature=letexprsubstitution --------
    // Surelog builds a `let_decl` (name + the body expression, formals left as
    // unbound `ref_obj`s) for every `let` in a module/interface/gen scope and
    // lists it on both the def and the elab view -- in BOTH feature modes.
    // slang-uhdm wires this up for MODULE bodies only, the one shape the pair
    // was measured on; a `let` in an interface or a gen scope emits no
    // let_decl (and so no let_expr either -- emitLetExprCall needs the
    // declaration), which is a gap, not a decision.
    // What the feature gates is the USE site, in exactly one function
    // (`CompileHelper::compileTfCall`, CompileHelper.cpp:4257): with
    // substitution ON a `let` call is replaced by the declaration's body
    // expression, with it OFF the call stays a `let_expr` carrying the actual
    // arguments and a pointer to the `let_decl`.
    //
    // slang has no call site to gate: `AssertionInstanceExpression::fromLookup`
    // answers a `let` call with the EXPANDED body expression
    // ("Let declarations expand directly to an expression"), so by the time the
    // emitter sees it the call is gone.  The full decode of what IS recoverable
    // (the expansion's syntax is the let's body; the substituted actuals are
    // re-anchored onto the FORMAL identifiers, which is what finds them) lives
    // at the head of the `let` block in ExprEmit.cpp -- read that before
    // touching any of this.

    /// Emits the `let_decl` objects for every `let` declared in @a body and
    /// hangs them off @a m. Runs in both feature modes.
    void emitLetDecls(const slang::ast::Scope& body, UHDM::scope* m,
                      const std::string& prefix);
    /// The `let` whose expansion @a expr is, or null when @a expr is not one.
    const slang::ast::LetDeclSymbol* letDeclFor(const slang::ast::Expression& expr);
    /// `--disable-feature=letexprsubstitution`: @a expr is a `let` expansion,
    /// so emit the un-substituted `let_expr` instead of the body. Null (and
    /// instant, without touching @a expr) when the flag is absent.
    UHDM::any* emitLetExprCall(const slang::ast::Expression& expr,
                               UHDM::BaseClass* parent, const std::string& prefix,
                               NetMap& netMap);
    /// Substitution ON (the default): @a expr is a `let` expansion, so it IS
    /// the declaration's shared body object -- Surelog inlines by pointer, not
    /// by substituting the actuals. Null when @a expr is not an expansion or
    /// the flag turned substitution off.
    UHDM::any* emitLetInlined(const slang::ast::Expression& expr, UHDM::BaseClass* parent);
    // Expansions currently being turned into a let_expr; `let id(x) = x;`
    // expands to its own argument, so emitting it would otherwise re-enter.
    std::set<const slang::ast::Expression*> letInFlight;
    // Non-null while emitPackageClassMethodClones runs: emitTaskFuncs over a
    // class scope then emits ONLY the out-of-body definition group, as fresh
    // objects renamed "class::method" and parented at (and appended to) this
    // package instead of the class_defn.
    UHDM::package* pkgClassTfClone = nullptr;
    // Second clone pass: constructors only (the first pass skips them).
    bool pkgClassTfCloneCtors = false;
    // Every task_func that lands in a PACKAGE's own Task_funcs vector — its
    // free subroutines and the out-of-body class-method clones alike — keyed
    // to (is-constructor, declaration location).  The vector is re-ordered by
    // that key once both clone passes are done: Surelog's package listing is
    // ONE SOURCE-ORDERED pass over everything that is not a constructor,
    // then one over the constructors (see emitPackageClassMethodClones).
    std::map<const UHDM::BaseClass*, std::pair<int, slang::SourceLocation>>
        pkgTfOrder9;
    // Tie-break for pkgTfOrder9: every clone a single `import q::*`
    // materializes carries the IMPORT STATEMENT's location, so the key alone
    // cannot order the group.  This is the entry's slot within that group,
    // i.e. its index in the home package's DEF-view listing
    // (§ collectPkgTfListing).  Only import clones are keyed; everything else
    // reads 0 and is separated by its own distinct location.
    std::map<const UHDM::BaseClass*, uint64_t> pkgTfSeq9;
    // The package Task_funcs listing order: one source-ordered pass over
    // everything that is not a constructor, then one over the constructors,
    // with an import group held together in the home listing's order.
    bool pkgTfListingLess(const UHDM::BaseClass* a, const UHDM::BaseClass* b);
    // Per CLASS, the out-of-body method DEFINITION objects of its own
    // (class_defn-parented, bare-named) listing, in emission order —
    // non-constructors by definition-file order, the constructor last. A
    // module that IMPORTS the class's home package HOISTS exactly these
    // objects into its own Task_funcs (see emitImportArtifacts).
    std::map<const slang::ast::Symbol*, std::vector<UHDM::task_func*>> classOobTfs;
    // Every emitted task/function object -> the SubroutineSymbol it was built
    // from.  A wildcard-import CLONE and the home object it clones share that
    // symbol, which is what makes a MODULE importing both a package and one of
    // its importers list each subroutine ONCE (§ emitImportArtifacts): the
    // group objects differ, the symbol does not.
    std::map<const UHDM::task_func*, const slang::ast::Symbol*> tfHomeSub9;
    // Bare identifier references inside a class method BODY that resolved to
    // nothing at class scope (a class PROPERTY: Surelog compiles an
    // out-of-body definition in the package's scope, where the class's own
    // members are invisible). Recorded in emission order; a module that
    // hoists the class then binds each to a module net of that name, minting
    // an implicit wire at the FIRST reference when the module declares none
    // (ApbSlave success/error_count/running/test_count).
    struct ClassPropRef {
        UHDM::ref_obj* ref;
        std::string name;
        slang::SourceRange range;
        const slang::ast::Symbol* homePkg; // the class's package, or null
    };
    std::vector<ClassPropRef> classPropRefs;
    // Set while a CLASS-OWNED method body is emitted (not the package clone
    // pass, whose refs Surelog leaves unbound).
    bool inClassBodyEmit = false;
    std::map<const void*, UHDM::package*> pkgDefMap;
    // ELAB/top-view package objects (filled in emitPackage when topView).
    // Module- and package-side cross-view links whose Surelog equivalents reach
    // the ELAB pkg (folded param constants) flip from pkgDefMap to this.
    std::map<const void*, UHDM::package*> pkgTopMap;
    // Materialized-import param typespecs created during the DEF package pass:
    // their vpiInstance must reach the ELABORATED home package, which does not
    // exist yet at creation time. Re-pointed once topPackages are built.
    std::vector<std::pair<UHDM::typespec*, const void*>> pkgImportTsTopFixups;
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
    // Folded twins of pkg VECTOR typedefs whose shared object kept symbolic
    // bounds (jeras_union imm_*), one per typedef symbol.
    std::map<std::pair<const slang::ast::Symbol*, std::string>,
             UHDM::typespec*>
        vectorTdFoldClone;
    UHDM::typespec* pkgVectorFoldTwin(const slang::ast::Symbol& taSym,
                                      UHDM::typespec* sharedTs);
    void foldVectorTsBounds(UHDM::typespec* t, const slang::ast::Type& canon);
    // True while building a TOP-pkg-view struct/union typedef ts (its member
    // vector clones fold — jeras_union imm_*).
    bool inPkgTopStructBuild = false;
    // Per-function symbolic pkg-named twin backing a same-scope pkg fn's
    // typedef'd return clone chain (jeras_union imm_i_f).
    // Fresh pkg-named twin backing a same-scope pkg fn's BODY-local return
    // var clone — one per (function, view): the def fn's twin stays symbolic,
    // the elab fn's folds (jeras_union imm_*_f).
    std::map<std::pair<const slang::ast::Symbol*, const void*>,
             UHDM::typespec*>
        pkgSameScopeRetTwin;
    // Package TypeAlias -> its TOP-view typespec (interfaces that import it
    // re-parent/list the SHARED object).
    std::map<const void*, UHDM::typespec*> pkgTopTypedefTs;
    // Name -> the int_typespec of a parameter DECLARED in the package view
    // currently being emitted. A package-scope PARENTHESIZED size cast
    // (`(dev_addr_width_gp)'('h0_0000)`) does not mint its own cast typespec:
    // Surelog reuses the referenced parameter's declaration typespec object
    // and stamps vpiInstance = the package on it, so the parameter itself
    // ends up instanced while its untouched siblings stay Instance-less
    // (BlackBePipeInt bp_common_pkg). Rebuilt per package view.
    std::map<std::string, std::pair<UHDM::typespec*, UHDM::parameter*>>
        pkgScopeParamTs;
    // DEF-pass package-subroutine refs to a typedef homed in ANOTHER package:
    // the home package's ELABORATED listing did not exist yet, so they bound
    // the def object. Re-pointed once both views are built (see PackFunc).
    std::vector<std::pair<UHDM::ref_typespec*, const slang::ast::Type*>>
        pkgForeignTsTopFixups;
    // Def-view type-cast typespecs, pre-created at module-compile time.
    std::map<const void*, UHDM::typespec*> castTsCache;
    // Bare implicit io-decl typespecs (unlocated) are created at the very
    // end of the write phase; keyed by type syntax for decl-group sharing.
    std::vector<std::pair<UHDM::ref_typespec*, const void*>> pendingIoTs;
    // A PARAM-INIT func_call arg's formal-typespec ref: the callee's io_decls
    // are emitted AFTER the param_assigns, so the stamp is resolved in the
    // write phase (func_upto's kept F(A_CONST,B_CONST) constant args).
    struct PendingCallArgTs {
        UHDM::ref_typespec* rt;
        UHDM::task_func* tf;
        size_t idx;
    };
    std::vector<PendingCallArgTs> pendingCallArgTs;
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
        // A GENVAR localparam entry: `rt` alone, resolved to a bare
        // int_typespec. Genvar and real-localparam typespecs share ONE
        // ordered list so the drain reproduces Surelog's depth-first
        // per-gen-scope interleave (LAST_START, i, j, j, ... — gen_test5).
        bool genvarOnly = false;
        // Gen-local var INITS that folded this localparam share its ts too
        // (logic [127:0] b = y; -> constant with a ref to y's typespec).
        std::vector<UHDM::ref_typespec*> shareRts;
        // The fold encoded INT (negative/multiplicative): such a constant
        // SHARES the param's typespec instead of binding a bare clone.
        bool intFold = false;
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
    // § modDefReExportTs — did package P's OWN DEF listing put a typespec ref
    // on this parameter's Rhs operation?  A module's DEF-view import copy that
    // comes from a RE-EXPORTING item (`import bp_be_pkg::*` carrying
    // bp_common_pkg's parameters) reproduces the re-exporter's DEF listing
    // row for row, so its op-typespec decision has to be read back from there
    // rather than re-derived.  Keyed by (immediately-imported package name,
    // parameter symbol); filled while the package DEF listings emit, which
    // always precede the module ones.
    std::map<std::pair<std::string, const slang::ast::Symbol*>, bool>
        pkgDefOpTs9;
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
    // ...and the alias is BLOCK-SCOPED, not body-wide: a select registers in
    // the begin/end block it is a DIRECT statement of, and a whole ref only
    // sees selects registered in its own block or an ANCESTOR block.  A select
    // one level deeper (`if (e) begin a[i] = 1; end`) is invisible to a whole
    // ref in the enclosing block, and a select under a bare `if`/`case` arm
    // (no begin) registers nowhere at all — Surelog pre-scans each block's
    // DIRECT statement list.  Purpose-built goldens /tmp/r10scr5_{d,e}.
    struct SelScope {
        int id;
        bool isBlock;
    };
    std::vector<SelScope> selScopeStack;
    int selScopeNextId = 0;
    std::map<std::pair<int, const slang::ast::Symbol*>, UHDM::expr*> selFirstSelect;
    std::set<const slang::ast::Symbol*> selLhsSelVars;
    struct SelWholeRef {
        UHDM::ref_obj* ref;
        const slang::ast::Symbol* sym;
        std::vector<int> chain;  // enclosing block scope ids, innermost first
    };
    std::vector<SelWholeRef> selWholeRefs;
    // Vars ALSO written whole (dout = ...) never repoint their whole refs
    // (multiple_blocking_gate).
    std::set<const slang::ast::Symbol*> selWholeWrittenVars;
    // The function-RETURN-name refs endSelTrack already re-pointed at a select
    // object.  drainFuncRet mints a per-ref return variable for everything in
    // `pendingFuncRet`, which would clobber that binding, so it skips these.
    std::set<const UHDM::ref_obj*> funcRetSelBound;
    bool beginSelTrack();  // returns true if it newly activated tracking
    void endSelTrack();    // back-patches whole-refs and clears state
    void noteSelectObj(const slang::ast::Symbol* base, UHDM::any* selObj);
    // The enclosing block scope ids, innermost first (empty outside a body).
    std::vector<int> selScopeChain() const {
        std::vector<int> c;
        for (auto it = selScopeStack.rbegin(); it != selScopeStack.rend(); ++it)
            if (it->isBlock)
                c.push_back(it->id);
        return c;
    }
    int callArgDepth = 0;
    // Task/function typespecs keep unfolded range expressions; module-level
    // typespecs fold them to INT constants.
    bool tfContext = false;
    // ...except a task/function FORMAL's own typespec, whose range bound
    // Surelog folds like a module one (the return type and body locals do
    // not). Set only inside the io_decl typespec build.
    bool tfFormalTs = false;
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
    // Non-null while materializing a DEF-view net/var typespec: its unfolded
    // range bounds keep module-param refs symbolic, but a reference to an
    // IMPORTED PACKAGE parameter resolves to that parameter's value
    // (Surelog compiles package constants before the module def).
    const slang::ast::Scope* defNetTsScope = nullptr;
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
    // While emitting a bit_select INDEX under genCaLhsParamFold: the SELECT
    // BASE's fullname.  A module-param read folded there scopes its
    // ref_typespec at the base, not at the gen scope (BasicOh
    // `sync_pipe[SYNCPIPE]` vs the plain `DELAY` operand beside it).
    std::string genCaSelBasePfx;
    // Depth of unpacked-array var_select INDEX emission (`ram[x[P-1:0]][i]`).
    int varSelIdxDepth = 0;
    // True inside a RANGED part_select's Left/Right range emission.  Measured
    // (purpose-built gen-for golden, `child m(A[i+1:i], A[i*W +: W], A[i+1],
    // A[i], C[i+1:i])`): Surelog's per-iteration gen-scope conns fold a
    // bit_select index and an indexed_part_select base/width to constants, but
    // a RANGED part_select keeps its bound TREES — Left_range stays
    // operation(ref_obj(i), 1) and Right_range stays ref_obj(i).  So the
    // genvarConnFold leaf fold is suppressed in exactly this scope.
    bool inPsRangeBound = false;
    // Elab (top-view) param_assign Rhs constants, shared into RHS select
    // bound folds.
    std::map<const slang::ast::Symbol*, UHDM::constant*> elabParamConst;
    // ELAB (top-view) param_assign object per param symbol (gen-scope
    // bound folds claim it as the fold constant's parent).
    std::map<const slang::ast::Symbol*, UHDM::param_assign*> elabParamPa;
    // DEF-view (module allModules) param_assign Rhs constants: a LATER
    // struct-pattern param whose member setter is a BARE reference to one
    // SHARES that very object (r9psc rule 1 — the constant keeps its own
    // param_assign parent and typespec inside the pattern).
    std::map<const slang::ast::Symbol*, UHDM::constant*> defParamRhsConst;
    // Unbased-unsized override pa Rhs constants (CA-claimed sharing).
    std::map<const slang::ast::Symbol*, UHDM::constant*> unbasedOvConst;
    // Ts ref of an unbased-unsized override pa Rhs constant: bound to the
    // param's OWN elab ts object once patchParamTypespecs creates it.
    std::map<const slang::ast::Symbol*, UHDM::ref_typespec*> unbasedOvTsRef;
    // Ts refs of COPIES of that constant (a '1 fill read by a cont-assign):
    // each binds a FRESH clone of the param ts, parented at the ref.
    std::map<const slang::ast::Symbol*, std::vector<UHDM::ref_typespec*>>
        unbasedOvCloneTsRef;
    // Elab (top-view) param_assign Rhs constants for TYPED params whose init is
    // a DEGENERATE unbased-unsized literal ('0/'x/'z, NOT '1). Surelog shares
    // this SAME constant object into the reading cont-assign (a bare stub) and
    // stamps its parent = that CA (last-writer claim).
    std::map<const slang::ast::Symbol*, UHDM::constant*> unbasedSharedPaConst;
    // Params whose ELAB param_assign Rhs went through the SIGNED-BINARY
    // decimal re-encode (see ParamEmit's measured table). Surelog gives that
    // re-encoded constant a FRESH BARE int_typespec, never the param's own
    // (ranged) one — SignedBinConst.
    std::set<const slang::ast::Symbol*> signedBinFoldParams;
    // Elab gen-scope net objects (for nested-scope CA LHS binding only).
    std::map<const slang::ast::Symbol*, UHDM::any*> genScopeNets;
    // ELAB hier refs into gen scopes bind their last elem to the gen net
    // late (the CA emits before the gen scopes) — hierdefparam.
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>>
        pendingGenHierBinds;
    // True while emitting ELAB-view cont assigns (gen-hier last-elem binds
    // only apply there — single-instance defs share body symbols with the
    // elab view, so symbol-based gating alone is not enough).
    bool elabCaEmit = false;
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
    // True while building a CLASS-scope typedef's typespec: its dimension
    // bounds stay SYMBOLIC (`SIZE-1` as an operation over a bare ref_obj)
    // because a class's formal parameters are never folded into its ONE
    // class_defn — Surelog compiles the class body once, unspecialized
    // (VirtualClass). buildUnpackedArrayTypedefTs consults it for the
    // [l:r] dimension form, which otherwise folds both bounds.
    bool unfoldedTypedefDims = false;
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
    // ---- in-body func_call operation-arg formal-ts stamps (drainBodyOpArgTs)
    // Subroutines called from a func_call emitted OUTSIDE any task/func body
    // (a live entry point), and the call graph between bodies. A call that
    // constant-folded away is never emitted, so it contributes no edge.
    std::set<const slang::ast::SubroutineSymbol*> liveCalledSubs;
    std::map<const slang::ast::SubroutineSymbol*,
             std::set<const slang::ast::SubroutineSymbol*>>
        subCallEdges;
    struct PendingBodyOpArgTs {
        UHDM::ref_typespec* rt;
        UHDM::expr* owner;
        const slang::ast::SubroutineSymbol* encl;
    };
    std::vector<PendingBodyOpArgTs> pendingBodyOpArgTs;
    void drainBodyOpArgTs();
    // When set, emitSyntaxExpr refs carry this scope prefix in VpiFullName.
    std::string syntaxRefPrefix;
    std::string syntaxRefSep = ".";
    // $bits(SIGNAL) typespec-bound arg refs bind their DEF nets once the
    // nets exist (drained at the end of exportDesign).
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>>
        pendingBitsBoundRefs;
    // ENUM-CONSTANT array-index refs (peripheral_io_bus[IO_ONES]) bind their
    // enum_const as vpiActual; the enum's typespec is minted after the def
    // view that first references it, so the link is drained at the end of
    // exportDesign (InterfArrayBind).
    std::vector<std::pair<UHDM::ref_obj*, const slang::ast::Symbol*>>
        pendingEnumIdxRefs;
    std::map<const slang::ast::Symbol*, UHDM::constant*> pkgParamConst;
    // Pkg param OBJECTS (def view) — bound by qualified member-access base
    // refs (pkg::P.member).
    std::map<const slang::ast::Symbol*, UHDM::parameter*> pkgParamObj;
    // MATERIALIZED IMPORT copies of package params in the module DEF view,
    // keyed by the package's own ParameterSymbol (which is what a wildcard
    // import resolves to). A generate CONDITION reading one folds to its
    // value with a ts ref to THIS copy's typespec, so the fold needs the
    // copy object. Rebuilt per def-view emitParameters call.
    std::map<const slang::ast::Symbol*, UHDM::parameter*> defModImportParam;
    // Set only while a generate if/case CONDITION is being emitted from
    // syntax in the module DEF view (see defModImportParam).
    bool genCondImportFold9 = false;
    // Emitting a struct-pattern member VALUE (tagged_pattern Pattern).
    bool inPatternValue = false;
    // DEF-view Rhs node of each package param (any kind) — a later same-pkg
    // param ref chains its vpiActual to this node (Surelog).
    std::map<const slang::ast::Symbol*, UHDM::any*> pkgParamDefRhs;
    // Substitution of a package struct-pattern member VALUE written as a
    // MEMBER SELECT of another struct-pattern parameter (see the call site in
    // ExprEmit's tagged_pattern arm). Answers the value OBJECT the referenced
    // parameter's own pattern holds for that member, IN THE CURRENT VIEW.
    UHDM::any* pkgPatSubstValue(const slang::ast::Expression& e, int depth);
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
    // Creation-pass marker. A package member typespec the DEF pass created
    // (and instanced at the def-view package) keeps that instance forever:
    // Surelog emits ONE shared object whose vpiInstance is the def view, and
    // the TOP pass must not re-stamp it. A member the TOP pass built fresh is
    // absent here and DOES take the elaborated instance. Ownership — not the
    // current Instance() value — is the only thing that separates the cases
    // (a value-based guard measured net-worse; see the NOTE in ParamEmit).
    std::set<const UHDM::typespec*> defPassOwnedTs;
    // A package subroutine is emitted TWICE (def view, then elaborated view).
    // subMap keeps the DEF twin (first writer); this keeps the ELAB twin,
    // whose return/formal typespecs are the FOLDED elab typedefs. A module
    // that imports the package lists — and binds its calls to — the elab twin
    // (Surelog: rp32 dec32's dec_t is [2:0], the def twin's stays 3-1).
    std::map<const slang::ast::Symbol*, UHDM::task_func*> pkgElabSubTf;
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
    // Sibling of enumOriginHexRecode for PLAIN param chains: when `init`
    // chains (through one or more param references, package boundaries
    // included) to a BASED integer literal, the fold keeps that literal's
    // SOURCE encoding (20'b0110... -> BIN / vpiBinaryConst / the literal
    // text as the decompile) instead of a plain decimal UINT.
    bool paramOriginBaseRecode(UHDM::constant* c,
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
    // DEF-view module params: their own ref_typespec. A param passed as a
    // direct actual argument of a function call in a CONTINUOUS assign has
    // this ref REBOUND to the formal's typespec (Surelog's arg-binding writes
    // through the param's ts ref; the last such call in source order wins).
    // Procedural calls and the elab-view param never rebind.
    std::map<const slang::ast::Symbol*, UHDM::ref_typespec*> defParamTsRef;
    // An elab param_assign Rhs ts ref waiting to be pointed at the module DEF
    // parameter's FINAL typespec object (see patchParamTypespecs' defParamTs
    // note). Resolved last: several deferred passes re-bind a def parameter's
    // typespec after the elab params are written, and binding early would pin
    // a clone the def view has since discarded.
    struct ShareDefParamTs {
        UHDM::ref_typespec* rt;
        const slang::ast::DefinitionSymbol* def;
        std::string name;
    };
    std::vector<ShareDefParamTs> pendingShareDefParamTs;
    void drainShareDefParamTs();
    std::set<const slang::ast::Symbol*>* refCollector = nullptr;
};

} // namespace slang_uhdm
