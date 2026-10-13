//------------------------------------------------------------------------------
//! @file LawState.h
//! @brief The per-pass state the landed laws keep between emitter calls
//
// One section per pass that needs state (a registry, a memo, a record
// type), in pass order; the law names and their cases are in
// tests/LAWS.md and each pass's tools/probe/r11uNNNrepro/README.md.
// New passes add their state here (or keep it static in the owning
// .cpp); there are no per-pass headers.
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once
#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
#include <slang/numeric/SVInt.h>
#include <string>
#include <string_view>
#include <uhdm/BaseClass.h>
#include <uhdm/uhdm.h>
#include <uhdm/uhdm_forward_decl.h>
#include <uhdm/uhdm_types.h>
#include <unistd.h>
#include <unordered_set>
#include <utility>
#include <vector>
#include "slang/text/SourceLocation.h"
#include "LawSwitch.h"

namespace UHDM {
class ref_typespec;
class ref_obj;
class variables;
class foreach_stmt;
class ref_var;
class typespec;
class BaseClass;
}

namespace slang_uhdm {

// ---- pass 223 (tests/LAWS.md; tools/probe/r11u223repro) ----
// v11u223 (the adversarial verification of r11u223,
// tools/probe/v11u223repro/README.md): every refinement reads its own
// R11V223_<NAME>_OFF switch; R11V223_OFF drops all of them, R11U223_OFF drops
// them with the laws they refine.
// § tfArgScalarTdWriter223 — every subroutine formal whose data type is
// written as a bare type identifier, with that identifier's source range, in
// emission order (TaskFuncEmit records, the design-final pass in
// UhdmExporter::exportDesign reads; a vector, so the copies it mints follow
// emission order, never an address order).  The storage is reserved once (one
// mapping, never reallocated): a vector grown by push_back during emission
// frees and re-allocates heap blocks, which moved the heap addresses of later
// UHDM objects, and § refFullNameThroughNamedExpr175 (ExprEmit, the sister's
// ground) iterates Serializer::AllObjects() in ADDRESS order while registering
// fresh full-name strings, so the symbol table's tail order became a coin
// (BuildUVMPkg default: 4 of 16 concurrent draws on the unreserved draft, 0 of
// 16 reserved; 0 of 16 on the base binary; README section 9).
inline std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>>& formalTdTokHeap223() {
    static std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>> v = [] {
        std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>> r;
        r.reserve(1u << 16);
        return r;
    }();
    return v;
}
// § formalRegNoHeap223v (v11u223, the adversarial verification of r11u223) —
// the reserved heap vector above did not keep MiniAmiq deterministic: its one
// 1.5 MB reservation, made at the first recorded formal DURING emission, still
// changed the heap state ahead of § refFullNameThroughNamedExpr175's
// address-order walk (ParamEmit drainPaNameCopySrc38, which runs before the
// design-final pass that reads this registry), and MiniAmiq default drew two
// hashes 8 : 8 in 16 concurrent draws on the law binary (identical uhdm-dump,
// 100 symbol-table tail strings of that family reordered) where the base
// binary and the law binary under R11U223_OFF drew one hash in 32 of 32 and 16
// of 16 (tools/probe/v11u223repro/README.md).  The registry now lives in
// static storage (no allocation at all during emission; entries beyond its
// capacity spill to the heap vector in the same order), so emission's heap
// traffic is the base's.  Switch R11V223_DETREG_OFF (the reserved heap
// vector of r11u223, R11V223_OFF with every v11u223 refinement).
struct FormalTdReg223 {
    using E = std::pair<UHDM::ref_typespec*, slang::SourceRange>;
    static constexpr size_t kCap = 1u << 16;
    E fixed[kCap];
    size_t n = 0;
    int heapMode = -1;
    void push_back(const E& e) {
        if (heapMode < 0)
            heapMode = lawFixOn(223, "R11V223_DETREG_OFF") ? 0 : 1;
        if (heapMode == 1 || n >= kCap)
            formalTdTokHeap223().push_back(e);
        else
            fixed[n++] = e;
    }
    // Emission order: the static entries, then the spilled (or heap-mode) ones.
    template <typename F>
    void forEach(F&& f) {
        for (size_t i = 0; i < n; i++)
            f(fixed[i]);
        for (auto& e : formalTdTokHeap223())
            f(e);
    }
};
inline FormalTdReg223& formalTdTok223() {
    static FormalTdReg223 reg;
    return reg;
}

// ---- pass 225 (tests/LAWS.md; tools/probe/r11u225repro) ----
} // namespace slang_uhdm
#include <utility>
#include <vector>
namespace slang_uhdm {
// § initHierFillKept225 — the declared signals whose packed range carries a
// substituted struct-member path (§ initHierAtRefToken225's site records them,
// ModuleEmit's unbased-fill fold reads them): (declaring scope, name).  Empty
// (no heap block) until the substitution fires, so a design it never reaches
// allocates nothing here (§ formalRegNoHeap223v's lesson: an allocation during
// emission moves later objects' addresses, and § refFullNameThroughNamedExpr175
// registers names in address order).
inline std::vector<std::pair<const void*, std::string>>& initHierOwners225() {
    static std::vector<std::pair<const void*, std::string>> v;
    return v;
}
inline bool initHierOwner225(const void* sc, std::string_view n) {
    for (auto& e : initHierOwners225())
        if (e.first == sc && e.second == n)
            return true;
    return false;
}
} // namespace slang_uhdm
namespace slang_uhdm {
// § fillSymbolicRootOnly225v (v11u225, the adversarial verification of r11u225):
// the refinements' switches.  R11V225_OFF drops every one of them.

// ---- pass 228 (tests/LAWS.md; tools/probe/r11u228repro) ----
} // namespace slang_uhdm

// v11u228 (the adversarial verification of r11u228,
// tools/probe/v11u228repro/README.md): the refinements read their own
// R11V228_<LAW>_OFF switches; R11V228_OFF drops them all (r11u228's bytes).
// Their firings trace to the same R11U228_TRACE file, law names ending `228v`.
namespace slang_uhdm {
inline void trv228(const char* law, const std::string& detail = std::string()) {
    lawTrace(228, law, detail);
}

// ---- pass 231 (tests/LAWS.md; tools/probe/r11u231repro) ----
} // namespace slang_uhdm

// § cloneAliasTargetOwnCopy231's record: the typedef-alias refs
// § cloneAliasFormalOwnChain214 (TaskFuncEmit) gives an import clone's formal
// copy, filled at emission and read design-final (UhdmExporter).
#include <vector>
namespace slang_uhdm {
inline std::vector<void*>& r231CloneAliasRefs() {
    static std::vector<void*> v;
    return v;
}
} // namespace slang_uhdm

// § oobClassTdFirstClassKey231's record: (the out-of-body definition's formal
// ref_typespec, the bare type name written there),
// filled at emission (TaskFuncEmit), read design-final (UhdmExporter).
#include <string>
#include <utility>
namespace slang_uhdm {
inline std::vector<std::pair<void*, std::string>>& r231OobClassTdRefs() {
    static std::vector<std::pair<void*, std::string>> v;
    return v;
}

// ---- pass 236 (tests/LAWS.md; tools/probe/r11u236repro) ----
// v11u236 (the adversarial verification, tools/probe/v11u236repro/README.md):
// each refinement reads its own R11V236_<X>_OFF; R11V236_OFF (or R11U236_OFF)
// drops all of them.
// § pkgDefPatSubstShared236 (ExprEmit pkgPatSubstValue arm, ParamEmit
// emitParameters): set while the declaring package's definition listing
// (AllPackages, not topView, not an import) emits a parameter's initializer;
// the map holds the one copy per substituted source object.
inline bool& pkgDefPatShare236() {
    static bool on = false;
    return on;
}
// § pkgDefPatHomeOnly236v (v11u236): the declaring package's scope (slang
// Scope*) while pkgDefPatShare236() is set; a read shares only when every
// parameter it names is declared in this scope.
inline const void*& pkgDefPatShareScope236() {
    static const void* sc = nullptr;
    return sc;
}
inline std::map<const void*, void*>& pkgDefPatShareMemo236() {
    static std::map<const void*, void*> m;
    return m;
}

// ---- pass 238 (tests/LAWS.md; tools/probe/r11u238repro) ----
// v11u238 (the adversarial verification, tools/probe/v11u238repro/README.md):
// each refinement reads its own R11V238_<NAME>_OFF; R11V238_OFF drops all of
// them, and R11U238_OFF drops them with the laws they refine.
// § cloneForIncBindsHomeVar238 (StmtEmit ForLoop arm, drained in ParamEmit
// drainPaNameCopySrc38): a for-header loop variable -> the HOME listing's
// emitted object (the last and the first emission outside any import clone),
// and the import clones' loop-variable references waiting for it.
inline std::map<const slang::ast::Symbol*, UHDM::variables*>& homeForVar238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
inline std::map<const slang::ast::Symbol*, UHDM::variables*>&
homeForVarFirst238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
struct CloneForIncRef238 {
    UHDM::ref_obj* ref;
    const slang::ast::Symbol* sym;
    bool classClone;  // an out-of-body class method's clone: the FIRST home
                      // emission (the class listing), else the LAST
};
inline std::vector<CloneForIncRef238>& cloneForIncRefs238() {
    static std::vector<CloneForIncRef238> v;
    return v;
}
// § foreachClassPropStringTsShared238: loop-variable ref_typespecs left to
// pendingLoopVarTs9's mirror; ParamEmit drainShareDefParamTs gives any the
// mirror missed the old fresh string_typespec.
inline std::vector<UHDM::ref_typespec*>& deferredStrTs238() {
    static std::vector<UHDM::ref_typespec*> v;
    return v;
}

// ---- pass 248 (tests/LAWS.md; tools/probe/r11u248repro) ----
// v11u248 (adversarial verification of r11u248): every fix reads its own
// R11V248_<FIX>_OFF switch; R11V248_OFF drops all of them (R11U248_OFF still
// restores the base's bytes: each fix lives inside a law's branch).
// § callArgCopyElabNearestOp248v: true while the exporter writes the
// --elabuhdm view (set by ParamEmit before drainCallArgCopyTs246).
inline bool& callArgCopyElabView248v() {
    static bool b = false;
    return b;
}
// § cloneLoopVarClassPropStringTs248: a shared clone loop variable whose
// property typespec is bound only by the class listing's drain (mirrored by
// pendingLoopVarTs9); ParamEmit drainShareDefParamTs gives any the mirror
// missed the base's unsupported placeholder, named and located as the
// shared object.
inline std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_var*>>& deferredCloneStrTs248() {
    static std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_var*>> v;
    return v;
}

// ---- pass 249 (tests/LAWS.md; tools/probe/r11u249repro) ----
// § unitDynArrTd249 / § modDynArrTd249 — set by a typedef writer around its
// buildUnpackedArrayTypedefTs call to ask the builder's dynamic-container
// branch for the kind-marker range (defined in TypeEmit.cpp).
extern bool g249DynRangeReq;
}  // namespace slang_uhdm
namespace slang::ast {
class TypeAliasType;
}
namespace slang_uhdm {
// The one-dimension dynamic / queue / associative typedef shapes the two
// writers list (TypeEmit.cpp).
bool unitDynTdShape249(const slang::ast::TypeAliasType& ta);

// ---- pass 251 (tests/LAWS.md; tools/probe/r11u251repro) ----
// § regTdArrElabIsNet251 — the elaborated array_vars ModuleEmit placed among
// the nets (the design-final $unit typedef pass leaves their typespec
// unfolded: the net branch reads the typedef's own typespec).
extern std::unordered_set<const void*> g251RegNetVars;

// ---- pass 255 (tests/LAWS.md; tools/probe/r11u255repro) ----
// § fwWinnerListedObject255's record: every object § bareTdNameFirstWriterWins98
// handed out (fwWinnerTs98) with the winning TypeAliasType symbol, in emission
// order; drained design-final in UhdmExporter.
inline std::vector<std::pair<void*, const void*>>& r255Fw98() {
    static std::vector<std::pair<void*, const void*>> v;
    return v;
}

// ---- pass 258 (tests/LAWS.md; tools/probe/r11u258repro) ----
// § cloneLoopVarAssocIdxTs258: the clone's shared loop-variable object of a
// foreach over an associative array whose index is not a class, string or int
// gets the index typespec only after UhdmExporter's clone-body member binder
// (§ pkgCloneMember10) has run, at the head of ParamEmit
// drainUnsizedBasedRhs106, and is parented there at its home foreach_stmt:
// golden's DeepClone resolved the body's `range.min` while the shared object
// was still unresolved, so the member reference stays unbound.
struct AssocIdx258 {
    UHDM::ref_typespec* rt = nullptr;
    UHDM::typespec* ts = nullptr;
    UHDM::ref_var* sh = nullptr;
    std::string key;
};
inline std::vector<AssocIdx258>& deferredAssocIdxTs258() {
    static std::vector<AssocIdx258> v;
    return v;
}
// The HOME foreach_stmt of every non-copy foreach, by the foreach keyword's
// location: [0] the definition-view listing's, [1] the elaborated body's.
inline std::map<std::string, std::pair<UHDM::foreach_stmt*, UHDM::foreach_stmt*>>& homeForeach258() {
    static std::map<std::string, std::pair<UHDM::foreach_stmt*, UHDM::foreach_stmt*>> m;
    return m;
}

// ---- pass 263 (tests/LAWS.md; tools/probe/r11u263repro) ----
}  // namespace slang_uhdm

// v11u263 (adversarial verification of r11u263,
// tools/probe/v11u263repro/README.md): every refinement reads its own
// R11V263_<FIX>_OFF switch; R11V263_OFF drops all of them (the law's bytes);
// R11U263_OFF still restores the base's bytes.
namespace slang_uhdm {

// ---- pass 266 (tests/LAWS.md; tools/probe/r11u266repro) ----
// § sgnLitElabFreshIntTs266: the parameters the law marked (ParamEmit), read
// back at the generate-scope fold sites (ExprEmit).
inline std::set<const void*>& sgnLit266() {
    static std::set<const void*> s;
    return s;
}

// ---- pass 269 (tests/LAWS.md; tools/probe/r11u269repro) ----
// § retTopRangeOwnPkg269: the elaborated package object whose subroutine's
// per-reference return-name local ModuleEmit drainFuncRet is compiling (null
// everywhere else); TypeEmit's package-parameter range binding reads it.
inline const void* retTopPkg269 = nullptr;
// v11u269 (the adversarial verification of r11u269,
// tools/probe/v11u269repro/README.md): every refinement reads its own
// R11V269_<FIX>_OFF switch; R11V269_OFF drops all of them (the law's bytes),
// R11U269_OFF still drops the laws and the refinements together (pristine).

// ---- pass 270 (tests/LAWS.md; tools/probe/r11u270repro) ----
// (r11u272: the r11v270On helper pre-written here for a verifier that wrote
// no fix was never called; removed, v11u270repro README's finding.)
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
}  // namespace slang_uhdm

namespace slang_uhdm {
// § insideSetParamFoldKeepsPa270 — the design-final half (defined in
// ExprEmit.cpp, called from ParamEmit's drainPaNameCopySrc38).
void insideSetParamPaDrain270();
// § insideSetParamFoldKeepsPa270 — the case-inside item record (StmtEmit).
void insidePaRecordCase270(const slang::ast::Expression& member, UHDM::BaseClass* e,
                           const UHDM::BaseClass* op);
// § enumAliasCastBindsImportCopy270 — the casts ExprEmit recorded (read by
// ParamEmit's drainPaNameCopySrc38).
size_t enumAliasCastN270();
void enumAliasCastRec270(size_t i, UHDM::ref_typespec*& rt,
                         const slang::ast::Symbol*& sym);

// ---- pass 272 (tests/LAWS.md; tools/probe/r11u272repro) ----
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
}  // namespace slang_uhdm

namespace slang_uhdm {
// § leftoverTsCopyPerElabUse272 — the record: the elaborated param_assigns
// whose value is the parameter's default written as a bare or
// package-qualified parameter name (ParamEmit emitParameters).
void lotsValueCopyRec272(const UHDM::BaseClass* pa);
bool lotsValueCopy272(const UHDM::BaseClass* pa);

// ---- pass 275 (tests/LAWS.md; tools/probe/r11u275repro) ----
// v11u275 (the adversarial verification of r11u275,
// tools/probe/v11u275repro/README.md): each refinement reads its own
// R11V275_<FIX>_OFF switch; R11V275_OFF drops all of them, giving the
// law's bytes (R11U275_OFF still gives the base's).
// § defNetTpPatKeepsActual275v (UhdmExporter.cpp): after the ElaboratorListener.
void defNetTpPatKeepActual275v();

// ---- pass 278 (tests/LAWS.md; tools/probe/r11u278repro) ----
}  // namespace slang_uhdm

// v11u278 (adversarial verification of r11u278): the verifier's refinements
// read their own R11V278_<FIX>_OFF switch; R11V278_OFF drops all of them
// (giving the r11u278 law's bytes) and R11U278_OFF still drops everything.
namespace slang_uhdm {

// ---- pass 280 (tests/LAWS.md; tools/probe/r11u280repro) ----
}  // namespace slang_uhdm

// § hpMemVarSelNamesFinal280: ExprEmit's design-final drain, called at the
// end of ParamEmit's drainShareDefParamTs.
namespace slang_uhdm {
void hpMemVarSelNamesDrain280();

// ---- pass 282 (tests/LAWS.md; tools/probe/r11u282repro) ----
// v11u282 (the adversarial verification of r11u282,
// tools/probe/v11u282repro/README.md): a refinement reads its own
// R11V282_<X>_OFF switch; R11V282_OFF drops every refinement (the law's
// bytes), R11U282_OFF still drops the law with it (pristine's bytes).
}  // namespace slang_uhdm

// ExprEmit's design-final drain of the generate-scope fold names, called at
// the end of ParamEmit's drainShareDefParamTs (after pass 280's).
namespace UHDM { class Serializer; }
namespace slang_uhdm {
void foldTsNameFinalDrain282(UHDM::Serializer& s);

// ---- pass 284 (tests/LAWS.md; tools/probe/r11u284repro) ----
// The verifier's refinements (v11u284, tools/probe/v11u284repro/README.md):
// R11V284_<X>_OFF each, R11V284_OFF all; R11U284_OFF still drops everything.
}  // namespace slang_uhdm

// ExprEmit's design-final drain of the generate-scope fold names, called at
// the end of ParamEmit's drainShareDefParamTs (after pass 280's).
namespace UHDM { class Serializer; }
namespace slang_uhdm {
void foldTsNameFinalDrain282(UHDM::Serializer& s);
}  // namespace slang_uhdm

namespace slang_uhdm {
// § pkgAliasTdRefNameByParent284: the package alias-of-typedef listing
// objects' Typedef_alias references (ParamEmit emitPackage), with the alias
// symbol and the package name, named design-final in drainShareDefParamTs.
struct PkgAliasRec284 {
    UHDM::ref_typespec* ref = nullptr;
    const void* alias = nullptr; // const slang::ast::TypeAliasType*
    std::string pkg;
};
inline std::vector<PkgAliasRec284>& pkgAliasRecs284() {
    static std::vector<PkgAliasRec284> v;
    return v;
}
// § pkgTdNamedDimsElemByChain284: FACE 3's listing objects (L, built by
// buildTdOfNamedDims111), whose Elem reference is named by its final chain.
inline std::vector<UHDM::logic_typespec*>& namedDimsListings284() {
    static std::vector<UHDM::logic_typespec*> v;
    return v;
}
// § f3ParamCopyDeep284: every FACE 3 listing object L built (a set, read by
// makeParamTs's elaborated-parameter copy).
inline std::set<const UHDM::typespec*>& namedDimsSet284() {
    static std::set<const UHDM::typespec*> v;
    return v;
}
// § hpSelPortConnFoldChain284: the references of package-parameter folds
// named after a hier_path select (ExprEmit), named design-final when their
// chain runs through a port.
inline std::vector<const UHDM::ref_typespec*>& hpSelFoldRefs284() {
    static std::vector<const UHDM::ref_typespec*> v;
    return v;
}
// UHDM's BaseClass::ComputeFullName (protected there): the name the
// VpiFullName getter gives an object that stores none, from its parent chain.
inline std::string chainFullName284(const UHDM::BaseClass* self) {
    std::vector<std::string_view> names;
    const UHDM::BaseClass* parent = self;
    const UHDM::BaseClass* child = nullptr;
    bool column = false;
    while (parent) {
        const UHDM::BaseClass* ap = parent->VpiParent();
        auto pt = parent->UhdmType();
        auto apt = ap ? ap->UhdmType() : UHDM::uhdmunsupported_stmt;
        if (pt == UHDM::uhdmdesign)
            break;
        if (pt == UHDM::uhdmpackage || pt == UHDM::uhdmclass_defn)
            column = true;
        std::string_view name = parent->VpiName().empty() ? parent->VpiDefName() : parent->VpiName();
        bool skip = apt == UHDM::uhdmref_obj || pt == UHDM::uhdmmethod_func_call ||
                    pt == UHDM::uhdmmethod_task_call || pt == UHDM::uhdmfunc_call ||
                    pt == UHDM::uhdmtask_call || pt == UHDM::uhdmsys_func_call ||
                    pt == UHDM::uhdmsys_task_call;
        if (child) {
            auto ct = child->UhdmType();
            if ((ct == UHDM::uhdmbit_select && pt == UHDM::uhdmport) ||
                (ct == UHDM::uhdmref_obj &&
                 (pt == UHDM::uhdmbit_select || pt == UHDM::uhdmindexed_part_select ||
                  pt == UHDM::uhdmhier_path)))
                skip = true;
        }
        if (!name.empty() && !skip)
            names.push_back(name);
        child = parent;
        parent = parent->VpiParent();
    }
    std::string f;
    for (int i = (int)names.size() - 1; i >= 0; --i) {
        f += names[i];
        if (i)
            f += column ? "::" : ".";
    }
    return f;
}

// ---- pass 286 (tests/LAWS.md; tools/probe/r11u286repro) ----
// The verifier's refinements (v11u286): R11V286_<X>_OFF each; R11U286_OFF
// drops them with the laws.
// § elabCastKeyBindsDefNet286: the definition listing's minted cast-pattern
// key wires, by (definition name, key name).
inline std::map<std::pair<std::string, std::string>, UHDM::logic_net*>& castKeyDefNets286() {
    static std::map<std::pair<std::string, std::string>, UHDM::logic_net*> m;
    return m;
}
// The wires an elaborated instance minted under the definition's name, not
// yet adopted by the definition listing.
inline std::set<UHDM::logic_net*>& castKeyAdopt286() {
    static std::set<UHDM::logic_net*> v;
    return v;
}

// ---- pass 287 (tests/LAWS.md; tools/probe/r11u287repro) ----
// § pvRecvBodyParamTs287: (the constant's ref_typespec, the receiver's
// ParameterSymbol), bound design-final to that parameter's elaborated typespec.
inline std::vector<std::pair<void*, const void*>>& pvRecvTs287() {
    static std::vector<std::pair<void*, const void*>> v;
    return v;
}
// § pvPatFlattenTsUnparented287: the port-view pattern operations'
// ref_typespecs, unparented and unnamed design-final.
inline std::vector<const void*>& pvFlatTs287() {
    static std::vector<const void*> v;
    return v;
}

// ---- pass 288 (tests/LAWS.md; tools/probe/r11u288repro) ----
}  // namespace slang_uhdm
// § randWithCallParentByConsumer288: every with-form scope randomize
// method_func_call § scopeRandomizeIsBareCall116 mints, with its constraint
// and the parent its emitExpr call was handed.
#include <vector>
#include <uhdm/uhdm.h>
namespace slang_uhdm {
struct RzRec288 {
    UHDM::method_func_call* mfc;
    UHDM::constraint* cons;
    UHDM::any* parent0;
};
inline std::vector<RzRec288>& rzWith288() {
    static std::vector<RzRec288> v;
    return v;
}
// The call's identifier-list arguments as Surelog's compileTfCallArguments
// leaves them under a parented call: no stored full name, so the name is the
// parent chain's (bareArgName116 stored the bare name on the parentless call).
inline void rzScopeArgs288(UHDM::method_func_call* m) {
    if (auto* args = m->Tf_call_args())
        for (auto* a : *args)
            if (a && a->UhdmType() == UHDM::uhdmref_obj) {
                auto* r = (UHDM::ref_obj*)a;
                if (r->VpiFullName() == r->VpiName())
                    r->VpiFullName("");
            }
}
inline bool rzIsRec288(const UHDM::any* o) {
    if (!o || o->UhdmType() != UHDM::uhdmmethod_func_call)
        return false;
    for (auto& r : rzWith288())
        if (r.mfc == o)
            return true;
    return false;
}
// design-final, from ParamEmit's drain list (ExprEmit holds the law).
void rzWithParentDrain288();
// v11u288 (the adversarial verification of r11u288): the verifier's
// refinements read R11V288_<X>_OFF, R11V288_OFF drops them all (giving the
// law's bytes) and R11U288_OFF still drops the whole pass.
// § rzMemberNoReparentDefView288v: whether this run writes the elaborated
// view (--elabuhdm), set by ParamEmit before rzWithParentDrain288 runs.
inline bool& rzElabView288v() {
    static bool v = false;
    return v;
}

// ---- pass 290 (tests/LAWS.md; tools/probe/r11u290repro) ----
// v11u290 (adversarial verification of r11u290): the verifier's
// refinements read r11v290On; R11V290_OFF drops them all (the law's bytes),
// R11U290_OFF still drops every law and refinement (pristine's bytes).
//   R11V290_SHAREOPND_OFF  § misevalShareOperandOnly290v (ExprEmit.cpp, § elabMisevalCompositeShares290)
//   R11V290_OVSIBOP_OFF    § ovCloneChainSiblingOperand290v (ParamEmit.cpp + ExprEmit.cpp + TypeEmit.cpp drain)
//   R11V290_WRITERKIND_OFF § pkgTdPackedWriterKindOrder290v (ModuleEmit.cpp, materializeDefNetTs)
//   R11V290_SPLICEOPND_OFF § ovSpliceTopOperandStaysHome290v (TypeEmit.cpp, § elabOvSpliceTopCopy290's branch)
//   R11V290_SPLICESW_OFF   § spliceChainSwitchOwnOnly290v (TypeEmit.cpp, drainMisevalSpliceChain290; switch semantics only)
// § ovCloneChainSiblingOperand290v — set beside misevalOvRhs290(): true when
// another parameter of the overridden parameter's own body reads it as an
// operand of an operator (through operators only).
inline bool& misevalOvSibOp290v() {
    static bool v = false;
    return v;
}
// § elabOvMisevalCloneChain290 — set while an ELABORATED parameter's Rhs
// is emitted on the § elabOvMisevalNoFold road (the override actual's
// tree, siblings substituted from the PARENT scope), read by
// § elabMisevalRefSubst.
inline bool& misevalOvRhs290() {
    static bool v = false;
    return v;
}
// § elabOvSpliceTopCopy290 — how deep the § elabVarRangeMisevalSubst
// splice is (0: the bound names the parameter itself).
inline int& misevalSpliceDepth290() {
    static int d = 0;
    return d;
}
// Defined in TypeEmit.cpp: register a spliced / cloned tree whose
// references are named design-final from their parent chain (force 0: an
// empty or bare stored name; 1: any stored name, and the ref_typespecs, for
// a clone that copied names; 2: any stored name, references only).
void noteMisevalSplice290(UHDM::any* e, int force = 0);
void noteMisevalCopyNames290(UHDM::any* c, const UHDM::any* src);

// ---- pass 300 (tests/LAWS.md; tools/probe/r11u300repro) ----
// v11u300 (adversarial verification of r11u300): the verifier's refinement
//   § retShareActualFoldAbstain300v R11V300_ACTFOLD_OFF (ExprEmit, inside the
//                                      law's site); R11V300_OFF drops it and
//                                      gives the law's bytes, R11U300_OFF still
//                                      gives pristine's.  Its firing traces as
//                                      `ACTFOLD300V <caller>-><callee> <why>`.
// § pkgRetCallFoldSharesCalleeRet300's registry: the expression object a
// direct `return` of a package function was emitted with in an ELABORATED
// (TopPackages) listing, keyed by (the listing's package object, the
// subroutine's home symbol); and, for the home package's own listing, by the
// symbol alone (a package-qualified call into another package reads that one).
inline std::map<std::pair<const void*, const void*>, UHDM::any*>& retCondReg300() {
    static std::map<std::pair<const void*, const void*>, UHDM::any*> m;
    return m;
}
inline std::map<const void*, UHDM::any*>& retCondHome300() {
    static std::map<const void*, UHDM::any*> m;
    return m;
}

// ---- pass 302 (tests/LAWS.md; tools/probe/r11u302repro) ----
// § pkgPatLeftoverSrcPkgListing302's record: a package parameter's elaborated
// Rhs object in the package's OWN (TopPackages) listing, keyed by its symbol.
inline std::map<const void*, UHDM::any*>& pkgOwnElabRhs302() {
    static std::map<const void*, UHDM::any*> m;
    return m;
}
// § elabImpSelFlatKeepsParent302's record: `pkg::NAME` of every package
// pattern parameter § modDefImportPkgSelFlat60 flattened in a DEF import copy.
inline std::set<std::string>& impSelFlat302() {
    static std::set<std::string> m;
    return m;
}
// § modFnLitLeftoverAtLiteral302's record: every emitted copy (emission
// order) of a literal assignment right side in a non-package subroutine,
// keyed by the slang right-side expression.
inline std::map<const void*, std::vector<UHDM::any*>>& modFnBodyLit302() {
    static std::map<const void*, std::vector<UHDM::any*>> m;
    return m;
}
// § modFnLitLeftoverValueGate302v's record: the folded member bits each
// minted leftover constant was cut from (makeMemLeftConst's slice), keyed by
// the minted constant.
inline std::map<const void*, slang::SVInt>& mintSlice302v() {
    static std::map<const void*, slang::SVInt> m;
    return m;
}

}  // namespace slang_uhdm
