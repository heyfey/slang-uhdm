//------------------------------------------------------------------------------
//! @file StmtEmit.cpp
//! @brief Processes, statements, event expressions
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include <functional>

namespace slang_uhdm {

// § controlBodyNoBind28 — the BODY of a conditional or loop statement.  See
// UhdmExporter.h's ctrlBodyDepth28: a class method's reference-binding
// windows are top-level only, and a plain begin/end block is transparent, so
// the counter is raised exactly where a control statement takes a substatement
// and nowhere else.
struct CtrlBody28 {
    int* p;
    explicit CtrlBody28(int& d) : p(&d) { ++*p; }
    ~CtrlBody28() { --*p; }
};

// § blockLocalSameCtrlDepthArgBinds57 — records, for the whole time a
// STATEMENT BLOCK is being emitted, the ctrlBodyDepth28 at which that block
// was ENTERED.  The reference binder then asks whether a candidate symbol's
// declaring block is open at the SAME depth it is reading at; see
// UhdmExporter.h's blkCtrlDepth57 for the law and every measured cell.
// A block with no blockSymbol pushes nothing (there is nothing to key on).
// § refVarLocalWindowBinds5 — the CONDITION window, as a counter.
//
// It was first raised at only the three sites that clear `classMethodNoBind`
// with the comment "condition refs DO bind"; a while/for condition is
// deliberately NOT one of them (arm a2 b04 is golden-bare there, and § 64's
// c13 measured the same boundary for the in-body law).
//
// V-FIX vbuvm5 — THREE MORE SITES, each one a measured pristine-RIGHT ->
// patched-WRONG cell that the three-site version created:
//   SITE 4  the case ITEM EXPRESSION (plain/casex/casez/unique case, but NOT
//           `case … inside`)                       arms v3 w01/w02/w03/w04/w13,
//                                                  v3 w06, v5 z09
//   SITE 5  the IMMEDIATE ASSERT / ASSUME / COVER condition
//                                                  arms v4 y01/y02/y03/y05,
//                                                  v5 z07/z08
//   SITE 6  the EVENT CONTROL expression `@(v)` / `@(posedge v)`
//                                                  arm v5 z01/z03/z04
// Every one of the six sites keeps the SAME depth half of the law: the
// one-body-deeper twin of each new cell is golden-bare and stays bare (v3 w05,
// v5 z05, v4 y04, v5 z06, v4 y10, v5 z02).
//
// This counter has exactly ONE reader, `refVarLocalNoBind5`, so widening it
// cannot reach any other law.
struct CondWindow5 {
    int* p;
    explicit CondWindow5(int& d) : p(&d) { ++*p; }
    ~CondWindow5() { --*p; }
};

struct BlkCtrl57 {
    std::vector<std::pair<const void*, int>>* v = nullptr;
    BlkCtrl57(std::vector<std::pair<const void*, int>>& st, const void* key, int d) {
        if (key) {
            v = &st;
            v->emplace_back(key, d);
        }
    }
    ~BlkCtrl57() {
        if (v)
            v->pop_back();
    }
};

// § blockDeclAutomaticIsWrittenKw80 — THE predicate, one definition, four call
// sites in the block-local loop.
//
// A BLOCK-SCOPE (statement) variable declaration carries `vpiAutomatic` iff the
// `automatic` KEYWORD is WRITTEN on that data declaration.  Surelog's
// STATEMENT-level `CompileHelper::compileDataDeclaration`
// (CompileStmt.cpp:1127) opens with `bool automatic_status = false`, sets it
// true ONLY at a `paLifetime_Automatic` node and false at `paLifetime_Static`,
// and writes `var->VpiAutomatic(automatic_status)` at :1196 — there is no
// scope-default fallback anywhere on that path.  That is a DIFFERENT rule from
// the two other Surelog sites this campaign already transcribes: the
// tf-block-item one (:1690, `VpiAutomatic(!is_static)` — automatic unless
// `static` is written; § r10fsv3, TaskFuncEmit) and the Signal/elaboration one
// (ElaborationStep:2350, `VpiAutomatic(!sig->isStatic())`;
// § packageVarAutomaticIsDataDeclShape26, ParamEmit).
//
// MEASURED on arm c1, 23 cells, golden — `automatic` reads 1 in a fork arm, a
// begin, a NAMED begin, a module `initial`, an `always` body, a module task's
// begin and a for-loop body's begin, with AND without an initializer; and
// EVERY keyword-less cell reads 0 in those same positions, including a local of
// a `function automatic`, whose subroutine lifetime does NOT propagate, and a
// `for (int i = 0; ...)` init variable.  A written `static` reads 0, i.e. the
// same as nothing.
//
// SLANG'S `VariableSymbol::lifetime` IS DELIBERATELY NOT READ: it is the
// SEMANTIC lifetime, default-filled from the enclosing scope
// (VariableSymbols.cpp:81, `lifetime = getDefaultLifetime(scope)`), so it is
// Automatic for every block local of a class method — which golden reads 0.
// Measured refutation in the README's RF-1.
static bool writtenAutomaticKw80(const slang::ast::Symbol& bm) {
    const syntax::SyntaxNode* dsyn = bm.getSyntax();
    if (!dsyn || dsyn->kind != syntax::SyntaxKind::Declarator)
        return false;
    // The declarator's parent is the whole data_declaration, and the lifetime
    // keyword is one of ITS modifiers — so a MULTI-DECLARATOR declaration
    // (`automatic int a = 1, b = 2;`) answers true for every declarator, which
    // is what golden does (arm c2 k_m1/k_m2).
    const syntax::SyntaxNode* par = dsyn->parent;
    if (!par || par->kind != syntax::SyntaxKind::DataDeclaration)
        return false;
    for (auto md : par->as<syntax::DataDeclarationSyntax>().modifiers)
        if (md.kind == parsing::TokenKind::AutomaticKeyword)
            return true;
    return false;
}

// The variable class a typespec implies — UHDM's own
// CompileHelper::getSimpleVarFromTypespec mapping, which is what Surelog uses
// to materialize an IMPLICITLY declared variable (a foreach loop variable)
// from the type it was resolved against. Null for typespecs it does not map.
static UHDM::variables* varForTypespec(UHDM::Serializer& s, const UHDM::typespec* ts) {
    switch (ts->UhdmType()) {
        case UHDM::uhdmint_typespec: return s.MakeInt_var();
        case UHDM::uhdminteger_typespec: return s.MakeInteger_var();
        case UHDM::uhdmlong_int_typespec: return s.MakeLong_int_var();
        case UHDM::uhdmshort_int_typespec: return s.MakeShort_int_var();
        case UHDM::uhdmbyte_typespec: return s.MakeByte_var();
        case UHDM::uhdmstring_typespec: return s.MakeString_var();
        case UHDM::uhdmreal_typespec: return s.MakeReal_var();
        case UHDM::uhdmshort_real_typespec: return s.MakeShort_real_var();
        case UHDM::uhdmtime_typespec: return s.MakeTime_var();
        case UHDM::uhdmbit_typespec: return s.MakeBit_var();
        case UHDM::uhdmclass_typespec: return s.MakeClass_var();
        case UHDM::uhdmenum_typespec: return s.MakeEnum_var();
        case UHDM::uhdmunion_typespec: return s.MakeUnion_var();
        case UHDM::uhdmstruct_typespec: return s.MakeStruct_var();
        case UHDM::uhdmlogic_typespec:
        case UHDM::uhdmvoid_typespec: return s.MakeLogic_var();
        default: return nullptr;
    }
}

// § classPropUnitImport21 (see the use site for the law and its measurements).
// Surelog's CompileHelper::importPackage copies the imported package's WHOLE
// `needLateTypedefBinding` list into the importing scope — unfiltered, so an
// explicit `import p::C;` copies exactly as much as `import p::*` — and
// UhdmWriter::write runs the FileContent pass over that list AFTER the package
// pass (UhdmWriter.cpp:4991 vs :1302).  A `$unit`-scope import therefore gets
// the LAST word on every class-property name, resolves none of them, and
// overwrites the package pass's answer with swapForSpecifiedVar's int_var
// fallback (UhdmWriter.cpp:2550).
bool UhdmExporter::pkgImportedByUnit21(const Symbol& pkgSym) {
    auto it = pkgUnitImp21.find((const void*)&pkgSym);
    if (it != pkgUnitImp21.end())
        return it->second;
    bool any = false;
    for (auto* cu : comp.getCompilationUnits()) {
        for (auto& m : cu->members()) {
            const Symbol* ip = nullptr;
            if (m.kind == SymbolKind::WildcardImport)
                ip = (const Symbol*)m.as<WildcardImportSymbol>().getPackage();
            else if (m.kind == SymbolKind::ExplicitImport)
                ip = (const Symbol*)m.as<ExplicitImportSymbol>().package();
            if (ip == &pkgSym) {
                any = true;
                break;
            }
        }
        if (any)
            break;
    }
    pkgUnitImp21[(const void*)&pkgSym] = any;
    return any;
}

UHDM::process_stmt* UhdmExporter::emitProcess(const ProceduralBlockSymbol& block,
                                              UHDM::instance* m, const std::string& prefix,
                                              NetMap& netMap) {
    UHDM::process_stmt* proc = nullptr;
    switch (block.procedureKind) {
        case ProceduralBlockKind::Always: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlways);
            proc = a;
            break;
        }
        case ProceduralBlockKind::AlwaysComb: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlwaysComb);
            proc = a;
            break;
        }
        case ProceduralBlockKind::AlwaysFF: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlwaysFF);
            proc = a;
            break;
        }
        case ProceduralBlockKind::AlwaysLatch: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlwaysLatch);
            proc = a;
            break;
        }
        case ProceduralBlockKind::Initial:
            proc = s.MakeInitial();
            break;
        case ProceduralBlockKind::Final:
            proc = s.MakeFinal_stmt();
            break;
        default:
            noteUnsupported("procedure kind: " + std::string(toString(block.procedureKind)));
            return nullptr;
    }

    proc->VpiParent(m);
    if (auto syntax = block.getSyntax())
        setLoc(proc, syntax->sourceRange());

    bool selOwner = beginSelTrack();
    if (auto* body = emitStmt(block.getBody(), proc, prefix, netMap))
        proc->Stmt(body);
    if (selOwner)
        endSelTrack();
    return proc;
}

// See selTrackActive in the header. beginSelTrack activates per-body tracking
// (no-op / returns false if already inside a tracked body, so only the
// outermost owner back-patches).
bool UhdmExporter::beginSelTrack() {
    if (selTrackActive)
        return false;
    selTrackActive = true;
    selFirstSelect.clear();
    selLhsSelVars.clear();
    selWholeRefs.clear();
    selWholeWrittenVars.clear();
    selScopeStack.clear();
    return true;
}

void UhdmExporter::endSelTrack() {
    for (auto& wr : selWholeRefs) {
        if (!selLhsSelVars.count(wr.sym))
            continue;
        // Innermost enclosing block first, then its ancestors: a whole ref in
        // a nested block DOES see an outer block's select, but never the
        // reverse (purpose-built golden /tmp/r10scr5_e a1/a3).
        UHDM::expr* sel = nullptr;
        for (int sc : wr.chain) {
            auto it = selFirstSelect.find({sc, wr.sym});
            if (it != selFirstSelect.end()) {
                sel = it->second;
                break;
            }
        }
        if (!sel)
            continue;
        // A var ALSO written whole keeps the net for PLAIN part-select
        // targets (multiple_blocking_gate) but still repoints to an
        // INDEXED part-select (multiple_blocking/sign_part_assign).
        // § r10fsv3 S9: ...but only while that part-select's bounds are
        // FOLDED.  A select whose left bound is still an expression
        // (`padded_input[INPUT_WIDTH-1:0] = data_i;` next to `padded_input =
        // '0;` in FuncStructVal's popcount) re-points like an indexed one —
        // Surelog's scope map holds the last object compiled for the name
        // either way, and the constant-bounds carve-out is what
        // multiple_blocking_gate pinned.
        // § dollarBoundNotFolded6v — an UNBOUNDED (`$`) bound is NOT a FOLDED
        // bound, and this carve-out must not read it as one.  § dollarBoundIsConst6
        // made `q[$:0]`'s left bound an OBJECT (a vpiUnboundedConst constant)
        // where it used to be nullptr, which silently flipped this test from
        // false to true and left the whole-write ref bound to the NET.  Golden
        // re-points it to the part_select: arm `v4_seltrackdollar.sv` cell s1
        // (`a1 = '{...}; a1[$:0] = '{...}`) is golden `part_select`, and the
        // pristine binary already produced `part_select` there — so reading `$`
        // as a folded bound is a PRISTINE-RIGHT -> PATCHED-WRONG regression, and
        // this clause is exactly its repair.  It is deliberately narrow: the
        // FOLDED-bound carve-out itself still fires for every ordinary constant
        // bound (cell s4 `a4[1:0]`, cell s6 `v1[3:0]`, which
        // multiple_blocking_gate pins), and a `$` bound can only exist on a
        // QUEUE part-select.
        if (selWholeWrittenVars.count(wr.sym) &&
            sel->UhdmType() == UHDM::uhdmpart_select &&
            ((UHDM::part_select*)sel)->Left_range() &&
            ((UHDM::part_select*)sel)->Left_range()->UhdmType() ==
                UHDM::uhdmconstant &&
            ((const UHDM::constant*)((UHDM::part_select*)sel)->Left_range())
                    ->VpiConstType() != vpiUnboundedConst)
            continue;
        wr.ref->Actual_group(sel);
        // A function-return-name ref is ALSO queued in pendingFuncRet, whose
        // drain would overwrite this with a freshly minted return variable.
        if (funcRetSym && wr.sym == funcRetSym)
            funcRetSelBound.insert(wr.ref);
    }
    selTrackActive = false;
    selFirstSelect.clear();
    selLhsSelVars.clear();
    selWholeRefs.clear();
    selWholeWrittenVars.clear();
    selScopeStack.clear();
}

void UhdmExporter::noteSelectObj(const slang::ast::Symbol* base, UHDM::any* selObj) {
    if (!selTrackActive || !base)
        return;
    // Register in the block the select is a DIRECT statement of; a select
    // under a bare `if`/`case` arm has a non-block innermost scope and
    // registers nowhere.
    if (selScopeStack.empty() || !selScopeStack.back().isBlock)
        return;
    selFirstSelect.emplace(std::make_pair(selScopeStack.back().id, base),
                           (UHDM::expr*)selObj);
    if (inLhs)
        selLhsSelVars.insert(base);
}

UHDM::delay_control* UhdmExporter::emitDelayControl(const TimingControl& tc,
                                                    UHDM::BaseClass* parent,
                                                    const std::string* stmtRefPrefix) {
    auto* dc = s.MakeDelay_control();
    dc->VpiParent(parent);

    // slang's DelayControl range starts at the value for some forms; Surelog's
    // pound_delay_value always includes the '#'.
    SourceRange dr = tc.sourceRange;
    std::string raw = rawText(dr);
    if (raw.empty() || raw[0] != '#') {
        dr = SourceRange(dr.start() - 1, dr.end());
        raw = rawText(dr);
    }
    setLoc(dc, dr);

    // Split the raw text the way Surelog's lexer does: Pound_delay is
    // '#' ' '* [0-9] [0-9_.]* and any trailing time_unit is a separate token.
    size_t i = raw.empty() ? 0 : 1;
    while (i < raw.size() && raw[i] == ' ')
        ++i;
    size_t numStart = i;
    while (i < raw.size() && (isdigit((unsigned char)raw[i]) || raw[i] == '_' || raw[i] == '.'))
        ++i;
    if (i > numStart) {
        dc->VpiDelay(raw.substr(0, i));
    }
    else if (!raw.empty()) {
        // The value is not a Pound_delay token ("#Tp", "#dly", "#(expr)",
        // "#Tp.unit"). What Surelog records then depends on POSITION,
        // measured on a golden covering every spelling in both positions:
        //   STATEMENT delay (`#Tp e <= d;`, `forever #pclk clk=~clk;`) keeps
        //     a Delay() ref_obj named for the identifier, scope-qualified
        //     (work@m.Tp) and spanning the WHOLE `#Tp`, parented where the
        //     delay_control itself is parented;
        //   INTRA-ASSIGNMENT delay (`a <= #Tp d;`) records NOTHING — no
        //     vpiDelay string, no Delay() ref (YosysOldSpi's 51 `<= #Tp`).
        // A PARENTHESISED value also shrinks the delay_control span to the
        // expression inside the parens (`#(Tp+1)` -> 6:12-6:16).
        if (raw[numStart] == '(') {
            size_t close = raw.find_last_of(')');
            if (close != std::string::npos && close > numStart + 1)
                setLoc(dc, SourceRange(dr.start() + numStart + 1,
                                       dr.start() + close));
        }
        else if (stmtRefPrefix) {
            std::string name = raw.substr(numStart);
            if (!name.empty() && !(isalpha((unsigned char)name[0]) ||
                                   name[0] == '_' || name[0] == '\\'))
                name.clear();
            auto* ref = s.MakeRef_obj();
            ref->VpiName(name);
            if (!name.empty())
                ref->VpiFullName(joinRef(*stmtRefPrefix, name));
            ref->VpiParent(parent);
            setLoc(ref, dr);
            dc->Delay(ref);
        }
    }
    return dc;
}

// § parensLessEventPathBaseRef9 — THE LAW (definition; ONE call site, tagged
// with the same §, in the `EdgeKind::None` arm of emitEventExpr just below).
//
//   An event control written WITHOUT PARENTHESES over a DOT-separated path is
//   ONE `ref_obj` in golden: `vpiName` is the path's BASE identifier ALONE,
//   `vpiFullName` is that name joined to the enclosing prefix, and the SPAN is
//   the WHOLE dotted text.  Everything after the first dot is DROPPED — no
//   hier_path, no path elements, however deep the path is written.
//
//     SVSwitch/Environemnt.sv:63   repeat (4) @ input_intf.clock;
//       golden  ref_obj (work@Environment::reset::input_intf) @63:16-63:32
//       ours    hier_path (input_intf.clock) @63:16-63:32 + 2 elements
//
//   The PARENTHESIZED spelling of the very same path in the very same file
//   (Environemnt.sv:121, `repeat(10000) @(input_intf.clock);`) keeps the FULL
//   two-element hier_path, which is what makes the parentheses — and not the
//   base's type, not the member's kind — the discriminator.  Measured across
//   five arms: a virtual-interface handle, a real interface INSTANCE, a
//   hierarchical module reference, a packed-struct member and a class-object
//   event member ALL collapse, and the clocking block `cb` collapses whether it
//   is the leaf (`@ vif.cb`) or an intermediate (`@ vif.cb.rdy`).
//
// WHERE THE COLLAPSE COMES FROM.  `@ <hierarchical_identifier>` and
// `@ ( <event_expression> )` are DIFFERENT grammar productions, and slang keeps
// them apart to the last:
//
//   slang/source/ast/TimingControl.cpp:59   case SyntaxKind::EventControl:
//                                  :60       SignalEventControl::fromSyntax(…EventControlSyntax…)
//                                  :63   case SyntaxKind::EventControlWithExpression:
//                                  :64       EventListControl::fromSyntax(…)
//                                  :86   result->syntax = &syntax;
//
// so the AST node's own `syntax` kind IS the written form, with no text
// scanning and no guessing.  Surelog's parens-less production evidently binds
// only the leading identifier and then stretches that one reference over the
// whole `hierarchical_identifier` node — which is exactly the object golden
// ships, name from the first token and span from the last.
//
// STATED GATE == CODE GATE.  Each clause below is one clause of the code, in
// the code's order, with the arm cell that EXECUTES it:
//
//   (1) the event control is the PARENS-LESS form.
//       `tc.syntax->kind != SyntaxKind::EventControl -> null`
//       executed by: every `@( … )` twin — a1 c2/c4/c6/c13, a2 d2/d4/d6/d8/d10,
//       a3 g2, a4 h2/h6 — all of which DECLINE and keep their hier_path.
//   (2) there is no edge and no `iff` — both unspellable in this production, so
//       this clause is an ASSERTION, not a filter.
//       `sec.edge != EdgeKind::None || sec.iffCondition -> null`
//       executed by: a1 c7 `@(posedge vif.clock)` (which also fails clause 1).
//   (3) the written name is a DOT-separated path, every separator on its left
//       spine a `.` and not a `::`.
//       `kind != ScopedName -> null`; `separator.kind != TokenKind::Dot -> null`
//       executed by: a1 c8 `@ loc` (not dotted, DECLINES — and is already
//       byte-identical to golden), a2 d11 `@ pk::pev` (`::`, DECLINES — also
//       already byte-identical).
//   (4) the left spine bottoms out in a PLAIN IDENTIFIER, whose TOKEN supplies
//       the name.  Reading the token and not the source text is what keeps an
//       ESCAPED identifier whose own text CONTAINS A DOT (`\esc.h .clock`)
//       from being split in half.
//       `n->kind != IdentifierName -> null`
//       executed by: a3 g1 (escaped base, FIRES, name `esc.h`), a4 h1
//       (`this.…`) and a4 h7 (`$root.…`), whose leftmost element is a keyword
//       token — see the README's residues for what golden does with those.
//
// The law NEVER MOVES A SPAN: the emitted ref_obj is located at
// `sec.expr.sourceRange`, the same range the hier_path it replaces was already
// located at, in every cell of every arm.  So a spelling that made our span
// disagree with golden's (a3 g1's escaped identifier) disagrees by exactly the
// same amount after this change as before it.
const slang::syntax::IdentifierNameSyntax* UhdmExporter::parensLessEventPathBase9(
    const TimingControl& tc) const {
    // (1) THE PARENS-LESS FORM.  `@(x)` is EventControlWithExpression.
    if (!tc.syntax || tc.syntax->kind != syntax::SyntaxKind::EventControl)
        return nullptr;
    if (tc.kind != TimingControlKind::SignalEvent)
        return nullptr;
    // (2) no edge, no `iff` — asserted rather than assumed.
    auto& sec = tc.as<SignalEventControl>();
    if (sec.edge != EdgeKind::None || sec.iffCondition)
        return nullptr;
    // (3) a DOT-separated path, all the way down the left spine.
    const syntax::ExpressionSyntax* n =
        tc.syntax->as<syntax::EventControlSyntax>().eventName;
    if (!n || n->kind != syntax::SyntaxKind::ScopedName)
        return nullptr;
    while (n->kind == syntax::SyntaxKind::ScopedName) {
        auto& sn = n->as<syntax::ScopedNameSyntax>();
        if (sn.separator.kind != parsing::TokenKind::Dot)
            return nullptr;
        n = sn.left;
    }
    // (4) a plain identifier at the bottom; its TOKEN carries the name.
    if (n->kind != syntax::SyntaxKind::IdentifierName)
        return nullptr;
    return &n->as<syntax::IdentifierNameSyntax>();
}

UHDM::any* UhdmExporter::emitEventExpr(const TimingControl& tc, UHDM::BaseClass* parent,
                                       const std::string& prefix,
                                       NetMap& netMap) {
    switch (tc.kind) {
        case TimingControlKind::Invalid: {
            // A clocking event over a property/sequence FORMAL (`@clk` in
            // `property p(..., clk = $inferred_clock);`) cannot bind — the
            // formal reference is an Invalid expression, so slang wraps the
            // whole SignalEventControl in an InvalidTimingControl.  Surelog
            // keeps the formal reference (bound to the module wire the formal
            // leaks), so unwrap and re-emit.
            auto* ch = propDeclScope ? tc.as<InvalidTimingControl>().child : nullptr;
            if (!ch) {
                noteUnsupported("timing control: " + std::string(toString(tc.kind)));
                return nullptr;
            }
            return emitEventExpr(*ch, parent, prefix, netMap);
        }
        case TimingControlKind::SignalEvent: {
            auto& sec = tc.as<SignalEventControl>();
            // `@(posedge clk iff en)`: an operation(vpiIffOp=68) with
            // [signal, condition] operands, located at the SIGNAL's span, sits
            // between the edge operation and the signal reference.  Measured
            // (4-row probe: `posedge clk iff en`, `negedge clk iff en == 1`,
            // `a iff b`, and an event list mixing the two):
            //
            //   * with an edge  -> op(edge)[whole span]( op(iff)[signal span](
            //                      signal, cond) );
            //   * with NO edge  -> op(iff)[whole span]( op(iff)[signal span](
            //                      signal, cond), cond ) — Surelog applies the
            //                      iff wrapper twice, once from the expression
            //                      compile and once from the event-expression
            //                      handler, and the inner condition object is
            //                      SHARED with the outer one.
            //
            // The condition operands parent at the INNER iff op in both shapes.
            auto iffWrap9 = [&](UHDM::BaseClass* op9,
                                UHDM::BaseClass* p9) -> UHDM::any* {
                auto* io9 = s.MakeOperation();
                io9->VpiOpType(vpiIffOp);
                io9->VpiParent(p9);
                setLoc(io9, sec.expr.sourceRange);
                auto* iv9 = s.MakeAnyVec();
                if (auto* e9 = emitExpr(sec.expr, io9, prefix, netMap))
                    iv9->push_back(e9);
                if (auto* c9 = emitExpr(*sec.iffCondition, io9, prefix, netMap))
                    iv9->push_back(c9);
                io9->Operands(iv9);
                (void)op9;
                return io9;
            };
            if (sec.iffCondition && sec.edge == EdgeKind::None) {
                auto* outer9 = s.MakeOperation();
                outer9->VpiOpType(vpiIffOp);
                outer9->VpiParent(parent);
                setLoc(outer9, tc.sourceRange);
                auto* ov9 = s.MakeAnyVec();
                auto* inner9 = (UHDM::operation*)iffWrap9(nullptr, outer9);
                ov9->push_back(inner9);
                // The outer operand is the SAME condition object the inner one
                // holds (Surelog shares it), so re-use rather than re-emit.
                if (auto* iops9 = inner9->Operands())
                    if (iops9->size() > 1)
                        ov9->push_back((*iops9)[1]);
                outer9->Operands(ov9);
                return outer9;
            }
            int32_t opType = 0;
            switch (sec.edge) {
                case EdgeKind::PosEdge:
                    opType = vpiPosedgeOp;
                    break;
                case EdgeKind::NegEdge:
                    opType = vpiNegedgeOp;
                    break;
                case EdgeKind::None: {
                    // A bare `@formal` clocking event inside a property
                    // declaration: the formal ref, spanning the `@` too when
                    // this is the property_spec's own clocking event.
                    if (propDeclScope &&
                        sec.expr.kind == ExpressionKind::Invalid) {
                        SourceRange nr = sec.expr.sourceRange;
                        std::string nm;
                        if (nr.start() != SourceLocation::NoLocation &&
                            nr.start().valid())
                            nm = rawText(nr);
                        if (nm.empty() && sec.expr.syntax &&
                            sec.expr.syntax->kind ==
                                syntax::SyntaxKind::IdentifierName) {
                            nm = std::string(
                                sec.expr.syntax
                                    ->as<syntax::IdentifierNameSyntax>()
                                    .identifier.valueText());
                            nr = sec.expr.syntax->sourceRange();
                        }
                        if (!nm.empty()) {
                            if (propSpecClockEvent &&
                                tc.sourceRange.start() !=
                                    SourceLocation::NoLocation)
                                nr = tc.sourceRange;
                            if (auto* fr =
                                    emitPropFormalRef(nm, nr, parent, prefix))
                                return fr;
                        }
                    }
                    // § parensLessEventPathBaseRef9 — THE SOLE CALL SITE.  A
                    // parens-less `@ a.b(.c…)` is ONE ref_obj named for the
                    // BASE, spanning the whole dotted text; the predicate above
                    // carries the law, its four clauses and their arm cells.
                    // The span is `sec.expr.sourceRange` — the SAME range the
                    // hier_path this replaces already used — so the law changes
                    // the object's KIND, NAME and FULLNAME and never its span.
                    if (auto* bs9 = parensLessEventPathBase9(tc)) {
                        auto* r9 = s.MakeRef_obj();
                        std::string nm9(bs9->identifier.valueText());
                        r9->VpiName(nm9);
                        r9->VpiFullName(joinRef(prefix, nm9));
                        r9->VpiParent(parent);
                        setLoc(r9, sec.expr.sourceRange);
                        return r9;
                    }
                    return emitExpr(sec.expr, parent, prefix, netMap);
                }
                default:
                    noteUnsupported("edge kind");
                    return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, tc.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (sec.iffCondition) {
                if (auto* iw = iffWrap9(nullptr, op))
                    operands->push_back(iw);
            }
            else if (auto* e = emitExpr(sec.expr, op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case TimingControlKind::EventList: {
            auto& el = tc.as<EventListControl>();
            // Flatten slang's event nesting to leaves, then rebuild the
            // Surelog shape: a LEFT-ASSOCIATIVE tree ((a or b) or c), each
            // operation spanning the first leaf through its last operand.
            std::vector<const TimingControl*> leaves;
            std::function<void(const EventListControl&)> collect =
                [&](const EventListControl& e) {
                    for (auto ev : e.events) {
                        if (ev->kind == TimingControlKind::EventList)
                            collect(ev->as<EventListControl>());
                        else
                            leaves.push_back(ev);
                    }
                };
            collect(el);
            if (leaves.empty())
                return nullptr;
            // "a or b" -> vpiEventOrOp; "a, b" -> vpiListOp (source separator).
            int32_t lop = vpiEventOrOp;
            if (leaves.size() >= 2) {
                auto between = rawText(SourceRange(leaves[0]->sourceRange.end(),
                                                   leaves[1]->sourceRange.start()));
                if (between.find(',') != std::string::npos)
                    lop = vpiListOp;
            }
            UHDM::any* acc = emitEventExpr(*leaves[0], parent, prefix, netMap);
            for (size_t i = 1; i < leaves.size(); ++i) {
                auto* op = s.MakeOperation();
                op->VpiOpType(lop);
                op->VpiParent(parent);
                setLoc(op, SourceRange(leaves[0]->sourceRange.start(),
                                       leaves[i]->sourceRange.end()));
                auto* operands = s.MakeAnyVec();
                if (acc) {
                    ((UHDM::any*)acc)->VpiParent(op);
                    operands->push_back(acc);
                }
                if (auto* e = emitEventExpr(*leaves[i], op, prefix, netMap))
                    operands->push_back(e);
                op->Operands(operands);
                acc = op;
            }
            return acc;
        }
        default:
            noteUnsupported("timing control: " + std::string(toString(tc.kind)));
            return nullptr;
    }
}

bool UhdmExporter::isSuperNewStmt27(const Statement& st, bool* parens) {
    if (st.kind != StatementKind::ExpressionStatement)
        return false;
    auto& ex = st.as<ExpressionStatement>().expr;
    if (ex.kind != ExpressionKind::NewClass ||
        !ex.as<NewClassExpression>().isSuperClass)
        return false;
    if (parens) {
        // Surelog's `class_constructor_declaration` production spells the
        // argument list as a SIBLING `list_of_arguments` element of the
        // `super.new` element — present whenever the source wrote the
        // parentheses, EMPTY ones included.  `super.new;` has no such
        // sibling, and that one node decides where the shifted walk lands
        // (t37b c_np_s_1 vs t37c d_supernoparen_1).
        *parens = false;
        if (auto* syn = ex.syntax)
            *parens = syn->getLastToken().kind ==
                      slang::parsing::TokenKind::CloseParenthesis;
    }
    return true;
}

// § thisSuperNewAssignNoStmt3 — an assignment written
//     <this|super>[.<name>]... = new[...]      (dynamic-array construction)
//     <this|super>[.<name>]... = new(...)      (class construction)
// contributes NO ELEMENT to a Surelog statement LIST.  The statement is simply
// absent from the enclosing `begin`'s vpiStmt list; the `begin` itself survives,
// even when every element it had was such an assignment (it is then an EMPTY
// begin), and when the assignment is the WHOLE body of a plain subroutine the
// subroutine gets NO vpiStmt at all.
//
// THE GATE IS THE `this`/`super` KEYWORD ON THE LHS **AND** A WRITTEN `new` ON
// THE RHS — both halves are load-bearing, and each was measured on its own.
// SVSwitch/Packet.sv is the natural experiment, two ADJACENT methods of ONE
// class, one `new[...]` each:
//     line 71 byte_pack    `bytes = new[data.size + 4];`      golden KEEPS it
//     line 87 byte_unpack  `this.data = new[bytes.size - 4];` golden DROPS it
// and the arms in tools/probe/r10svs3repro separate every property that differs
// between those two lines (arm a1, 10 cells; arm a2, 13; arm a3, 12; arm a4, 10;
// LHS is golden throughout):
//     KEPT   `loc = new[3]` (local) · `bytes = new[d.size+4]` (ref formal) ·
//            `d = new[3]` and `d = new[bytes.size-4]` (BARE property, i.e. an
//            IMPLICIT this) · `h.d = new[3]` (another object's property) ·
//            `this.s = 5` and `this.d = e` (this-LHS, NON-new RHS)
//     DROPPED `this.d = new[3]` · `this.d = new[e.size+4]` · `this.d = new[7]` ·
//            `this.d = new[3](e)` (the copy form) · `this.h = new()` ·
//            `this.h = new(1)` · `this.h.d = new[3]` (a DEEPER this path) ·
//            `super.d = new[3]`
// so it is neither "a member-select lvalue" (`h.d` is kept) nor "a `new[]`
// assignment" (`d = new[3]` is kept) nor "a class-property lvalue" (the bare
// spelling of the SAME property is kept): it is the written KEYWORD.  Read the
// SYNTAX, not the bound AST — an IMPLICIT class-property reference is a
// MemberAccess on an implicit `this` in slang, so the AST cannot tell `d` from
// `this.d` at all (the same reason § classPropIterThisRefVar21 reads the syntax).
//
// STATEMENT POSITION IS PART OF THE LAW, and it is why this predicate is a
// LIST-APPEND test and not an "emit nothing, ever" test.  Surelog does not drop
// the construct — it builds an assignment with NEITHER vpiLhs NOR vpiRhs (an
// EMPTY assignment, vpiOpType 82 / vpiBlocking 1) and then whether that object
// survives depends ENTIRELY on the slot it lands in.  Measured, golden side:
//   OMITTED  · element of a `begin`'s statement list  (a2 n10/n11, a3 p9/p10)
//            · element of an EXPLICIT `begin`'s list even when it is the only
//              one — the begin survives EMPTY, golden BLOCK n=0 (a3 p4, and
//              a4 q8 / a5 r4 at TWO list levels)
//            · statement list of a `fork` — the fork_stmt survives with an
//              EMPTY list, golden BLOCK n=0 (a3 p8, a5 r3)
//            · the WHOLE body of a plain function/task — no vpiStmt (a1 m4/m8/
//              m9, a2 n3/n4/n5/n8, a3 p1/p3)
//   KEPT as the EMPTY assignment (this predicate must NOT fire) ·
//              sole branch of an `if` (a2 n6) · sole body of a `while` (a3 p5) ·
//              of a `foreach` (a3 p6) · a `case_item`'s statement (a3 p7) ·
//              and — the exception that decides the whole shape of the law —
//              a CLASS CONSTRUCTOR'S **OWN** STATEMENT LIST: sole statement
//              (a2 `new`, a3 `new`) AND list element alike (a4 `new`, golden
//              STMTS=3 with the drop present; a5 `ctorplain::new`).  Surelog
//              compiles constructor bodies through
//              `compileClassConstructorDeclaration`, which shares no code with
//              compileFunction (§ constructorBodyElementShift27), so that slot
//              is reached through emitCtorBody27 and never through call sites
//              3/4 below (emitStmt diverts on `tfBodyCtor27 && tfBodyStmt9 ==
//              &stmt`) nor through call site 5 (which tests `!tfBodyCtor27`).
//
//              THE CONSTRUCTOR EXCEPTION IS THAT SLOT ONLY — **NOT** "anywhere
//              inside a constructor", and an earlier draft of this comment said
//              "ANYWHERE INSIDE A CLASS CONSTRUCTOR", which arm a5 REFUTES.
//              a5 `ctornest::new` is a constructor whose body is
//              `s = k; begin this.d = new[3]; s = 2; end` and golden's INNER
//              begin has n=1 (only `s = 2`): one block level down, golden DROPS
//              it exactly as it does outside a constructor.  That is why call
//              sites 1 and 2 carry NO constructor gate — emitCtorBody27's
//              EK_FSN case recurses straight back into emitStmt, so a nested
//              block inside a constructor reaches them, and firing there is
//              CORRECT.  Gating them on the constructor would have re-broken
//              a5 r1.
//
// REFUTATION THIS PASS OWES ITS BRIEF: the brief framed the site as a `new[...]`
// / dynamic-array question.  It is not.  `new()` on a class handle drops exactly
// the same way (a1 m9, a4 q9), and `new[...]` on a bare property does not drop
// at all (a1 m3/m7).  The dynamic array is a coincidence of the corpus site.
bool UhdmExporter::thisSuperNewAssignNoStmt3(const Statement& st) {
    const syntax::SyntaxNode* sn = st.syntax;
    if (!sn || sn->kind != syntax::SyntaxKind::ExpressionStatement)
        return false;
    const syntax::ExpressionSyntax* ex =
        &*sn->as<syntax::ExpressionStatementSyntax>().expr;
    // Only the SIMPLE assignment operator: `+=`/`<=` and friends are separate
    // SyntaxKinds and none of them can take a `new` on the right, so requiring
    // this kind is exact rather than merely conservative.
    if (ex->kind != syntax::SyntaxKind::AssignmentExpression)
        return false;
    auto& be = ex->as<syntax::BinaryExpressionSyntax>();
    // RHS HALF: a WRITTEN `new` construction.  `new[n]`, `new[n](src)` are
    // NewArrayExpression; `new`, `new()`, `new(a, b)` are NewClassExpression.
    // NewCovergroupExpression is deliberately NOT included: no arm measured it
    // and a covergroup handle is not assignable through `this.` in this corpus.
    auto rk = be.right->kind;
    if (rk != syntax::SyntaxKind::NewArrayExpression &&
        rk != syntax::SyntaxKind::NewClassExpression)
        return false;
    // LHS HALF: the path ROOT is the `this` or `super` KEYWORD.  A bare name is
    // an IdentifierName and never a ScopedName, which is what keeps the
    // implicit-this spelling (`d = new[3]`, golden KEEPS it) out.
    const syntax::SyntaxNode* lhsNode = &*be.left;
    if (lhsNode->kind != syntax::SyntaxKind::ScopedName)
        return false;
    const syntax::NameSyntax* root =
        &*lhsNode->as<syntax::ScopedNameSyntax>().left;
    while (root->kind == syntax::SyntaxKind::ScopedName)
        root = &*root->as<syntax::ScopedNameSyntax>().left;
    return root->kind == syntax::SyntaxKind::ThisHandle ||
           root->kind == syntax::SyntaxKind::SuperHandle;
}

// § declInitWrittenNewNoStmt66 — a local variable DECLARATION whose WRITTEN
// initializer is a `new` construction
//     <type> v = new;   <type> v = new(...);        (class construction)
//     <type> v[] = new[n];  = new[n](src);          (dynamic-array construction)
// contributes NO ELEMENT to the enclosing Surelog statement LIST, and the
// variable therefore keeps the enclosing BLOCK as its vpiParent instead of
// re-parenting onto the declaration assignment.  Every OTHER initializer
// contributes a leading blocking `assignment` in declaration order and DOES own
// the variable — so this is a per-declaration term, not a per-declaration-kind
// one.
//
// THE TERM IS THE WRITTEN `new` AND NOTHING ELSE, and each half of that was
// measured against its own counterexample (arms a1/a2, 40 subroutine cells; LHS
// golden throughout).  The corpus witness is the r10uvm66 head,
// uvm-1.2 src/base/uvm_links.svh:251-257:
//
//   254     uvm_cause_effect_link ce_link = new(name);
//   255     ce_link.set(lhs, rhs);
//   256     return ce_link;
//
// golden's body begin @255:7-255:29 holds TWO statements and parents `ce_link`
// on the BEGIN; ours held THREE and parented it on the surplus `assignment`.
//
//   NOT THE VARIABLE'S TYPE.  A class handle initialized from a FUNCTION CALL
//     (a1 m06) or from `null` (a1 m17) KEEPS its assignment, and a QUEUE
//     initialized from a concatenation (a1 m21) keeps its own — while a
//     DYNAMIC ARRAY initialized `new[3]` drops it (a1 m08, a2 n10b).  Both
//     directions measured, so neither `class_var` nor `array_var` is the term.
//   NOT "ANY INITIALIZER".  int/string/expression/ref/`automatic` initializers
//     all keep their assignment (a1 m04/m05/m15/m18/m22).
//   NOT THE `new[...]` FORM ALONE.  `new`, `new()`, `new(arg)`, `new[n]` and
//     `new[n](src)` all drop (a2 n09/n10, a1 m01/m02) — including `new` written
//     with NO PARENTHESES (a2 n09), which is why the gate reads the SYNTAX KIND
//     and not an argument list.
//   NOT A STATEMENT-POSITION LAW.  The SAME construction written as a
//     STATEMENT over a bare local — `a1c ce; ce = new(name);` — is KEPT by
//     golden (a1 m07); § thisSuperNewAssignNoStmt3 owns that family and needs a
//     `this`/`super` LHS to fire.  This law needs no LHS spelling at all,
//     because a declaration has none.
//   NOT SCOPE- OR SLOT-DEPENDENT among statement lists: class method, package
//     free function, module/interface/program/$unit function, task,
//     out-of-body definition, parameterized and typedef'd handles, a written
//     `begin`/named `begin`/`fork`/for/while body/case item and a module
//     `initial`/`always` all drop it (a1 m01/m02/m13/m16/m20/m24/m26,
//     a2 n02/n02b/n03/n04/n05/n06/n11/n12/n13/n14/n15/n19/n20/n22/n23).
//
// THE CLASS CONSTRUCTOR IS THE ONE STATEMENT LIST THIS LAW DOES **NOT** REACH,
// and that is measured, not assumed.  a2 n01 is a constructor WITH A PORT LIST
// (so § constructorBodyElementShift27 does not eat its first element and the
// cell is really measured) whose body opens `a2c ce = new();`: golden KEEPS the
// assignment there and parents `ce` on it.  That is § 27's model (2) exactly —
// compileClassConstructorDeclaration has no Rhs-less-assignment filter, and an
// initializer that compiles to nothing leaves precisely such an assignment —
// so emitCtorBody27's EK_BID arm is deliberately NOT a call site of this
// predicate.  a2 n01b (`int x = 5;` in the same constructor) is the control.
//
// THE COUNT IS NOT TOUCHED, and arm a3 is why.  The dropped element still
// counts toward the body's `begin`-wrapper decision: a2 n07, a body whose EVERY
// element is a `new`-initialized declaration, gets golden's wrapper and it is
// EMPTY (`begin@128:10-128:24[]`), with both locals parented on it.  So this
// predicate only ever skips a LIST APPEND; `initCount`/`eff9` and the wrapper
// anchor are left exactly as they were.
bool UhdmExporter::declInitWrittenNewNoStmt66(const slang::ast::VariableSymbol& vs) {
    // `getDeclaredType()` is a not_null<> on ValueSymbol, so there is nothing to
    // null-check here — the one thing that can be absent is the initializer.
    const slang::ast::DeclaredType* dt = vs.getDeclaredType();
    // The WRITTEN node, not the bound expression: the same SyntaxKinds
    // § thisSuperNewAssignNoStmt3 reads on its RHS half, so the two laws share
    // one vocabulary.  NewCovergroupExpression is deliberately NOT included —
    // no arm measured it and no corpus site reaches it.
    // CopyClassExpression ADDED AT INTEGRATION (verifier F1, arm
    // v1_qualcopy.sv w05/w06): `v1c ce = new src;` is a `new` construction
    // too — golden emits no declaration assignment and parents the var on the
    // BEGIN, and ParamEmit.cpp already lists the copy form beside the other
    // two (§ copyClassIsNewCall4's family).  0 corpus sites; the gate was one
    // term short of its own headline.
    auto* isyn = dt->getInitializerSyntax();
    if (!isyn)
        return false;
    return isyn->kind == syntax::SyntaxKind::NewClassExpression ||
           isyn->kind == syntax::SyntaxKind::NewArrayExpression ||
           isyn->kind == syntax::SyntaxKind::CopyClassExpression;
}

// § constructorBodyElementShift27 — a class CONSTRUCTOR body is compiled by
// `CompileHelper::compileClassConstructorDeclaration` (CompileStmt.cpp:2165),
// a routine that shares no code with compileFunction/compileTask, and it
// differs from them in two measured ways.
//
// (1) THE ELEMENT SHIFT.  The routine reads `Tf_port_list = fC->Child(nodeId)`
// (after stepping over a `class_scope` for an out-of-body definition) and only
// afterwards works out where the statements begin.  When the constructor
// declares NO port list there is no `tf_port_list` node, so what it grabs is
// the FIRST BODY ELEMENT — and the walk it then runs
// (`Stmt = fC->Sibling(Tf_port_list)`) starts one element LATE.  Concretely,
// over the raw grammar element sequence
//     { block_item_declaration } [ super.new [ list_of_arguments ] ]
//     { function_statement_or_null }
// (the argument list is its OWN element):
//     firstCounted = portList ? 0 : (elem[0] is a plain statement ? 0 : 1)
//     nb           = number of NON-argument-list elements from firstCounted
//     nb == 0  -> the constructor gets NO body statement
//     nb == 1  -> the ONE element at firstCounted, emitted BARE (no begin)
//     nb >  1  -> a `begin` (carrying no span at all, only vpiFullName) over
//                 every element from index `portList ? 0 : 1`
// so a port-less constructor loses its first element whatever that element is:
// `super.new()` when it leads (uvm_tree_printer::new, uvm_root::new), the
// first ASSIGNMENT when there is no super.new at all (t37b c_np_ns_3), the
// first declaration otherwise (t37d e_2bid_1).
//
// (2) THE DECLARATION STATEMENTS (§ ctorDeclIsRhslessAssignment27).  Every
// surviving block-item declaration is compiled as a body STATEMENT: an
// `assignment` whose Lhs is the declared variable and whose Rhs is present
// only when the declaration has an initializer.  compileFunction/compileTask
// filter exactly that Rhs-less assignment back out (CompileStmt.cpp ~2130);
// the constructor routine has no such filter.  Measured on t37e for int,
// string and unpacked-array locals, with the ordinary function/task controls
// keeping the filtered shape, and it is what uvm_component::new (3 leading
// Rhs-less assignments), uvm_port_base::new (2) and uvm_cmdline_processor::new
// (2) are missing on our side.
//
// 21 purpose-built cells across t37a..t37e agree with this model in both
// package views, port-list and port-less, in-body and out-of-body.
UHDM::any* UhdmExporter::emitCtorBody27(const Statement& slStmt,
                                        UHDM::BaseClass* parent,
                                        const std::string& prefix,
                                        NetMap& netMap) {
    auto& sl = slStmt.as<StatementList>();
    enum EK { EK_BID, EK_SUPER, EK_ARGS, EK_FSN };
    struct El {
        EK k;
        const Statement* st;
    };
    std::vector<El> el;
    for (auto st : sl.list) {
        if (st->kind == StatementKind::VariableDeclaration) {
            el.push_back({EK_BID, st});
            continue;
        }
        bool parens = false;
        if (isSuperNewStmt27(*st, &parens)) {
            el.push_back({EK_SUPER, st});
            if (parens)
                el.push_back({EK_ARGS, st});
            continue;
        }
        el.push_back({EK_FSN, st});
    }
    size_t firstCounted =
        tfBodyCtorNoPorts27 ? (el.empty() || el[0].k == EK_FSN ? 0u : 1u) : 0u;
    size_t walkFrom = tfBodyCtorNoPorts27 ? 1u : 0u;
    size_t nb = 0;
    for (size_t i = firstCounted; i < el.size(); ++i)
        if (el[i].k != EK_ARGS)
            nb++;
    if (nb == 0)
        return nullptr;
    // The wrapper: golden never calls populateCoreMembers on it, so it carries
    // vpiFullName and NO span (unlike every other synthesized body begin).
    UHDM::begin* ub = nullptr;
    if (nb > 1) {
        ub = s.MakeBegin();
        ub->VpiFullName(prefix);
        ub->VpiParent(parent);
    }
    UHDM::BaseClass* sparent = ub ? (UHDM::BaseClass*)ub : parent;
    auto* stmts = s.MakeAnyVec();
    auto* bvars = s.MakeVariablesVec();
    size_t from = nb > 1 ? walkFrom : firstCounted;
    size_t to = nb > 1 ? el.size() : firstCounted + 1;
    for (size_t i = from; i < to && i < el.size(); ++i) {
        switch (el[i].k) {
            case EK_ARGS:
                // An orphaned `list_of_arguments` (the walk started ON it, its
                // `super.new` having been shifted past) compiles to nothing:
                // compileStmt is handed the argument EXPRESSION, which matches
                // no statement production (t37b c_np_s_1, t37d e_supera_2).
                break;
            case EK_BID: {
                auto& vs = el[i].st->as<VariableDeclStatement>().symbol;
                auto it = netMap.find(&vs);
                if (it == netMap.end())
                    break;
                auto* v = (UHDM::variables*)it->second;
                auto* as = s.MakeAssignment();
                as->VpiParent(sparent);
                as->VpiOpType(vpiAssignmentOp);
                as->VpiBlocking(true);
                if (auto syn = vs.getSyntax())
                    setLoc(as, syn->sourceRange());
                v->VpiParent(as);
                as->Lhs((UHDM::expr*)v);
                if (auto* init = vs.getDeclaredType()->getInitializer())
                    if (auto* r = emitExpr(*init, as, prefix, netMap))
                        as->Rhs((UHDM::expr*)r);
                stmts->push_back(as);
                // An unpacked-array local ALSO lists its element reg before
                // the array_var, exactly as the ordinary block wrapper does.
                if (v->UhdmType() == UHDM::uhdmarray_var) {
                    auto* av = (UHDM::array_var*)v;
                    if (av->Variables() && !av->Variables()->empty())
                        bvars->push_back((*av->Variables())[0]);
                }
                bvars->push_back(v);
                break;
            }
            case EK_SUPER:
            case EK_FSN:
                if (auto* u = emitStmt(*el[i].st, sparent, prefix, netMap))
                    stmts->push_back(u);
                break;
        }
    }
    if (!ub)
        return stmts->empty() ? nullptr : (*stmts)[0];
    if (!bvars->empty())
        ub->Variables(bvars);
    ub->Stmts(stmts);
    return ub;
}

UHDM::any* UhdmExporter::emitStmt(const Statement& stmt, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    // Select-alias block scoping (see selScopeStack): every COMPOUND statement
    // opens a scope; only begin/end blocks (and the statement lists inside
    // them) are select-registering scopes.
    struct SelScopeGuard {
        UhdmExporter* self = nullptr;
        ~SelScopeGuard() {
            if (self)
                self->selScopeStack.pop_back();
        }
    } selGuard;
    // § droppedCall14 — remember the statement syntax for the Invalid-
    // expression re-entry (see UhdmExporter::stmtSyntax14).
    struct StmtSyn14 {
        const syntax::SyntaxNode** p;
        const syntax::SyntaxNode* saved;
        ~StmtSyn14() { *p = saved; }
    } ssGuard14{&stmtSyntax14, stmtSyntax14};
    if (stmt.syntax)
        stmtSyntax14 = stmt.syntax;
    if (selTrackActive) {
        bool isBlock = false, compound = false;
        switch (stmt.kind) {
            case StatementKind::Block:
            case StatementKind::List:
                isBlock = compound = true;
                break;
            case StatementKind::Conditional:
            case StatementKind::Case:
            case StatementKind::PatternCase:
            case StatementKind::ForLoop:
            case StatementKind::RepeatLoop:
            case StatementKind::ForeachLoop:
            case StatementKind::WhileLoop:
            case StatementKind::DoWhileLoop:
            case StatementKind::ForeverLoop:
            case StatementKind::Timed:
                compound = true;
                break;
            default:
                break;
        }
        if (compound) {
            selScopeStack.push_back({selScopeNextId++, isBlock});
            selGuard.self = this;
        }
    }
    switch (stmt.kind) {
        case StatementKind::Timed: {
            auto& timed = stmt.as<TimedStatement>();
            auto& timing = timed.timing;
            switch (timing.kind) {
                case TimingControlKind::ImplicitEvent:
                case TimingControlKind::SignalEvent:
                case TimingControlKind::EventList: {
                    auto* ec = s.MakeEvent_control();
                    ec->VpiParent(parent);
                    // The event_control covers the whole "@(...)" region: from
                    // the statement start through the closing paren (implicit
                    // event syntax already includes it).
                    if (timing.kind == TimingControlKind::ImplicitEvent) {
                        setLoc(ec, timing.sourceRange);
                    }
                    else {
                        // The timing-control syntax node spans "@(...)"
                        // including both parens.
                        SourceRange ecRange = stmt.sourceRange;
                        if (stmt.syntax &&
                            stmt.syntax->kind == syntax::SyntaxKind::TimingControlStatement) {
                            ecRange = stmt.syntax->as<syntax::TimingControlStatementSyntax>()
                                          .timingControl->sourceRange();
                        }
                        else {
                            // Event list ranges include the closing paren; a
                            // bare signal event does not.
                            auto end = timing.sourceRange.end();
                            if (timing.kind == TimingControlKind::SignalEvent)
                                end = end + 1;
                            ecRange = SourceRange(stmt.sourceRange.start(), end);
                        }
                        setLoc(ec, ecRange);
                        // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW
                        // SITE 6 of 6.  An EVENT CONTROL expression is a
                        // binding window with the same depth law.  Measured
                        // golden, out-of-body tasks, arm v5:
                        //   z01 34:7  `@(vz) …`, decl d0 read d0        BIND
                        //   z04 56:15 `@(posedge vz) …`, d0==d0         BIND
                        //   z03 49:9  decl inside that same block, d1==d1 BIND
                        //   z02 41:9  `@(vz)` one body DEEPER than decl  bare
                        // Module-level `always @(...)` cannot reach the
                        // predicate at all (it needs `currentSubSym`), so this
                        // window is procedural-subroutine-only by construction.
                        CondWindow5 cw5ev(condBindDepth5);
                        if (auto* cond = emitEventExpr(timing, ec, prefix, netMap))
                            ec->VpiCondition(cond);
                    }
                    if (auto* inner = emitStmt(timed.stmt, ec, prefix, netMap))
                        ec->Stmt(inner);
                    return ec;
                }
                case TimingControlKind::Delay: {
                    // "#1 t;" / "always #5 clk = !clk;": a delay_control whose
                    // Stmt is the delayed statement.
                    auto* dc = emitDelayControl(timing, parent, &prefix);
                    if (auto* inner = emitStmt(timed.stmt, dc, prefix, netMap))
                        dc->Stmt(inner);
                    return dc;
                }
                default:
                    noteUnsupported("timing control: " + std::string(toString(timing.kind)));
                    return nullptr;
            }
        }
        case StatementKind::ExpressionStatement: {
            auto& es = stmt.as<ExpressionStatement>();
            // Statement-context sys calls ($display...) span the whole call
            // and parent their literal arguments.
            // A REJECTED call reaches here as an Invalid expression (see
            // § droppedCall14) and needs the same statement-position flag.
            if (es.expr.kind == ExpressionKind::Call ||
                es.expr.kind == ExpressionKind::Invalid)
                callStmtContext = true;
            auto* r = emitExpr(es.expr, parent, prefix, netMap);
            callStmtContext = false;
            return r;
        }
        case StatementKind::Block: {
            auto& bs = stmt.as<BlockStatement>();
            bool isFork = bs.blockKind != StatementBlockKind::Sequential;
            // slang wraps for-loops with inline declarations, and every
            // foreach (its loop variables are block-scoped), in an implicit
            // block; Surelog has no such wrapper.
            if (bs.syntax &&
                (bs.syntax->kind == syntax::SyntaxKind::ForLoopStatement ||
                 bs.syntax->kind == syntax::SyntaxKind::ForeachLoopStatement)) {
                UHDM::any* result = nullptr;
                auto& fbody = bs.body;
                if (fbody.kind == StatementKind::List) {
                    for (auto st : fbody.as<StatementList>().list) {
                        if (st->kind == StatementKind::VariableDeclaration)
                            continue;
                        if (auto* u = emitStmt(*st, parent, prefix, netMap))
                            result = u;
                    }
                }
                else {
                    result = emitStmt(fbody, parent, prefix, netMap);
                }
                return result;
            }
            // A LABELED immediate assertion (eff3: assert(x);) gets NO
            // named_begin wrapper: the label becomes the assertion's own
            // name (refs still scope through the label).
            if (bs.blockSymbol && !bs.blockSymbol->name.empty() && !isFork &&
                (!bs.syntax ||
                 bs.syntax->kind != syntax::SyntaxKind::SequentialBlockStatement)) {
                const Statement* inner = &bs.body;
                if (inner->kind == StatementKind::List) {
                    auto lst = inner->as<StatementList>().list;
                    if (lst.size() == 1)
                        inner = lst[0];
                }
                // A labelled CONCURRENT assertion inside a statement block
                // (`else begin a3: assert property(...); end`) is not wrapped
                // either: the block statement IS the assert_stmt, named and
                // fullnamed by the label (SequenceInst a3).
                if (inner->kind == StatementKind::ImmediateAssertion ||
                    inner->kind == StatementKind::ConcurrentAssertion) {
                    std::string innerPfx = joinRef(prefix, bs.blockSymbol->name);
                    auto* ua = emitStmt(*inner, parent, innerPfx, netMap);
                    if (ua) {
                        if (ua->UhdmType() == UHDM::uhdmimmediate_assert)
                            ((UHDM::immediate_assert*)ua)->VpiName(bs.blockSymbol->name);
                        else if (ua->UhdmType() == UHDM::uhdmimmediate_assume)
                            ((UHDM::immediate_assume*)ua)->VpiName(bs.blockSymbol->name);
                        else if (ua->UhdmType() == UHDM::uhdmimmediate_cover)
                            ((UHDM::immediate_cover*)ua)->VpiName(bs.blockSymbol->name);
                        else if (auto* cc = any_cast<UHDM::concurrent_assertions*>(ua))
                            cc->VpiName(bs.blockSymbol->name);
                    }
                    return ua;
                }
            }
            UHDM::scope* b = nullptr;
            std::string innerPrefix = prefix;
            if (bs.blockSymbol && !bs.blockSymbol->name.empty()) {
                UHDM::scope* nb;
                if (isFork) {
                    auto* nf = s.MakeNamed_fork();
                    nf->VpiName(bs.blockSymbol->name);
                    nb = nf;
                }
                else {
                    auto* nbg = s.MakeNamed_begin();
                    nbg->VpiName(bs.blockSymbol->name);
                    nb = nbg;
                }
                innerPrefix = joinRef(prefix, bs.blockSymbol->name);
                nb->VpiFullName(innerPrefix);
                // Anchored at the block name token.
                auto nl = bs.blockSymbol->location;
                setLoc(nb, SourceRange(nl, nl + bs.blockSymbol->name.size()));
                // § endBlockLabelAllOwners62 — `end : lbl` AND
                // `join/join_any/join_none : lbl`.  A ParallelBlockStatement is
                // the same BlockStatementSyntax with the same `endBlockName`,
                // and named_fork owns a vpiEndLabel slot that fork_stmt does
                // not — so the label is stamped on the NAMED fork only, which
                // is exactly the set the old `!isFork` test threw away.
                // MEASURED, not assumed: golden labels all three join
                // flavours (c3 rows f_all/f_any/guard) and labels neither an
                // unlabelled join (f_bare) nor an unnamed fork.
                if (stmt.syntax &&
                    syntax::BlockStatementSyntax::isKind(stmt.syntax->kind))
                    if (auto* ebn = stmt.syntax->as<syntax::BlockStatementSyntax>()
                                        .endBlockName) {
                        if (isFork)
                            ((UHDM::named_fork*)nb)->VpiEndLabel(ebn->name.valueText());
                        else
                            ((UHDM::named_begin*)nb)
                                ->VpiEndLabel(ebn->name.valueText());
                    }
                namedBlockMap[bs.blockSymbol] = nb;
                b = nb;
            }
            else {
                UHDM::scope* ub;
                if (isFork) {
                    auto* fk = s.MakeFork_stmt();
                    if (bs.blockKind == StatementBlockKind::JoinNone)
                        fk->VpiJoinType(vpiJoinNone);
                    else if (bs.blockKind == StatementBlockKind::JoinAny)
                        fk->VpiJoinType(vpiJoinAny);
                    ub = fk;
                }
                else
                    ub = s.MakeBegin();
                ub->VpiFullName(prefix);
                // stmt.sourceRange covers only the body; the syntax node
                // covers the full begin..end region that Surelog reports.
                if (stmt.syntax)
                    setLoc(ub, stmt.syntax->sourceRange());
                else
                    setLoc(ub, stmt.sourceRange);
                b = ub;
            }
            b->VpiParent(parent);
            // § blockLocalSameCtrlDepthArgBinds57 — CALL SITE 2 of 5 (the
            // recorder).  From here to this case's `return b` this block is
            // OPEN at the current ctrlBodyDepth28, which is what lets a
            // call-argument reference tell "declared where I am reading"
            // (binds) from "declared one control body out" (stays bare).
            // A FORK arm is recorded exactly like a sequential begin because
            // a fork raises no depth (b4 e9:120/121 — golden binds both the
            // arm's own local and the enclosing if-body local).
            BlkCtrl57 bcd57(blkCtrlDepth57, (const void*)bs.blockSymbol,
                            ctrlBodyDepth28);
            // Block-local variable declarations become scope Variables
            // (module-scoped fullnames, no visibility flag).
            NetMap blockMap = netMap;
            std::vector<UHDM::any*> forkDeclStmts9;
            if (bs.blockSymbol) {
                auto* vars = s.MakeVariablesVec();
                for (auto& bm : bs.blockSymbol->members()) {
                    if (bm.kind != SymbolKind::Variable)
                        continue;
                    // § blockDeclAutomaticIsWrittenKw80 — computed ONCE per
                    // declaration and read at all FOUR factories below.
                    const bool auto80 = writtenAutomaticKw80(bm);
                    // Package/class scopes keep `::` all the way down: a body
                    // local of svunit_testsuite::report is
                    // svunit_pkg::svunit_testsuite::report::match, matching
                    // every sibling declaration (VpiName/VpiFullName are
                    // cmp-compared).
                    std::string bfull = joinRef(innerPrefix, bm.name);
                    // A QUEUE / DYNAMIC-array block local is a PAIR: the
                    // element var (listed FIRST, parented at the array) and
                    // the array_var itself. ApbSlave's
                    // `svunit_testcase match[$]`.
                    if (auto* qav =
                            makeQueueDynArrayVar(bm, bfull, b, pkgScopeInst)) {
                        if (auto* qregs = qav->Variables())
                            for (auto* qr : *qregs) {
                                // § blockDeclAutomaticIsWrittenKw80, SITE 1 of
                                // 4 — the ELEMENT variable, never the
                                // array_var (arm c2 d_que/e_dyn: golden reads
                                // 1 on the inner int_var and 0 on its
                                // array_var, and Surelog's CompileStmt.cpp:1196
                                // is why — the flag is written on
                                // compileVariable's result, BEFORE the
                                // unpacked-dimension wrapper is minted).
                                if (auto80)
                                    qr->VpiAutomatic(true);
                                vars->push_back(qr);
                            }
                        vars->push_back(qav);
                        blockMap[&bm] = qav;
                        continue;
                    }
                    // § assocLocalArrayVar40 — and so is an ASSOCIATIVE one.
                    // NEVER promoted here: Surelog's elaboration pass reaches
                    // a package task_func's own vpiVariables and no deeper, so
                    // a NESTED-`begin` local keeps the SIZE model in both
                    // views (t57a `fBlkAssoc57::bacls`).
                    if (auto* aav = makeAssocArrayVar(bm, bfull, b,
                                                      pkgScopeInst, false)) {
                        if (auto* aregs = aav->Variables())
                            for (auto* ar : *aregs) {
                                // § blockDeclAutomaticIsWrittenKw80, SITE 2 of
                                // 4 (arm c2 f_asc).
                                if (auto80)
                                    ar->VpiAutomatic(true);
                                vars->push_back(ar);
                            }
                        vars->push_back(aav);
                        blockMap[&bm] = aav;
                        continue;
                    }
                    // Block-local var typespecs keep their range bounds
                    // UNFOLDED (Surelog's procedural-decl form).
                    bool savedTf = tfContext;
                    tfContext = true;
                    auto* ts = makeTypespec(bm);
                    tfContext = savedTf;
                    if (pkgScopeInst)
                        ts->Instance(pkgScopeInst);
                    // Surelog's VERILOG-mode lexer (a `.v` root file — see
                    // verilogLexMode) has no `logic` keyword, so a block-local
                    // `logic x;` parses as "user type `logic`, variable x".
                    // CompileType's unresolved-name fallback then emits a
                    // ref_var (name + typespec ref, never bound to storage) —
                    // the procedural twin of the module-level rule already in
                    // materializeDefNetTs.  Every procedural reference to it
                    // therefore fails to bind and leaks an implicit module
                    // wire instead (emitExpr's NamedValue case).  UnitElabBlock.
                    bool vlogHiddenTy = false;
                    if (verilogLexMode(bm.location))
                        if (auto* dt9 = bm.getDeclaredType())
                            if (auto* tsy9 = dt9->getTypeSyntax())
                                vlogHiddenTy =
                                    rawText(tsy9->sourceRange()) == "logic";
                    // A FIXED-SIZE unpacked-array block local is the same
                    // PAIR the tf BLOCK-ITEM local already emits (element var
                    // listed FIRST, parented at the array_var; the
                    // array_typespec — not the array_var — carries the
                    // unpacked dims, and shares the declaration's element
                    // typespec with the reg).  The block arm only had the
                    // queue/dynamic-array form, so `logic idx [7:0]` inside a
                    // function's `begin` lost its element reg entirely
                    // (golden /tmp/r10scr6_v7.sv; Scr1SvTests
                    // scr1_search_one_16's stage1_idx/stage2_idx/stage3_idx —
                    // 3 missing vars in one begin, the def-compile Compare
                    // head after the memberActualLeak fix).
                    UHDM::variables* v = nullptr;
                    if (!vlogHiddenTy &&
                        bm.getDeclaredType()->getType().getCanonicalType().kind ==
                            SymbolKind::FixedSizeUnpackedArrayType) {
                        const Type* leaf0 =
                            &bm.getDeclaredType()->getType().getCanonicalType();
                        while (leaf0->getCanonicalType().kind ==
                               SymbolKind::FixedSizeUnpackedArrayType)
                            leaf0 = &leaf0->getCanonicalType()
                                         .as<FixedSizeUnpackedArrayType>()
                                         .elementType;
                        auto* av0 = s.MakeArray_var();
                        av0->VpiName(bm.name);
                        av0->VpiFullName(bfull);
                        av0->VpiParent(b);
                        av0->VpiArrayType(vpiStaticArray);
                        setLoc(av0, nameSpan(bm.location, bm.name));
                        auto* ats0 = s.MakeArray_typespec();
                        {
                            SourceLocation aEnd0 = bm.location + bm.name.size();
                            if (auto dsyn0 = bm.getSyntax();
                                dsyn0 &&
                                dsyn0->kind == syntax::SyntaxKind::Declarator)
                                for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>()
                                                     .dimensions)
                                    // Through the CLOSING bracket (the tf
                                    // BLOCK-ITEM twin stops one short).
                                    aEnd0 = dim0->sourceRange().end();
                            setLoc(ats0, SourceRange(bm.location, aEnd0));
                        }
                        if (auto* arng0 = buildUnpackedRanges(bm, ats0))
                            ats0->Ranges(arng0);
                        // § classScopedTdDeclTsUnsupported11, SITE 5 of 5 —
                        // the FIXED-SIZE declarator array, BLOCK-item form.
                        // grid11 `g8` `a_fx` / `k_fx`.
                        UHDM::typespec* ets0 = ts;
                        if (auto* uts11 = makeScopedTdUnsupTs11(bm))
                            ets0 = uts11;
                        auto* ert0 = s.MakeRef_typespec();
                        ert0->VpiParent(ats0);
                        ert0->Actual_typespec(ets0);
                        ats0->Elem_typespec(ert0);
                        auto* art0 = s.MakeRef_typespec();
                        art0->VpiFullName(bfull);
                        art0->VpiParent(av0);
                        art0->Actual_typespec(ats0);
                        av0->Typespec(art0);
                        // § declArrayElemKindIsDeclKind12, SITE 4 of 4 — the
                        // FIXED-SIZE declarator array, BLOCK-item form.
                        // grid12 `h1` `a_fx` / `k_fx` in a `begin` body.
                        auto* reg0 = makeDeclArrayElemVar12(s, bm, *leaf0);
                        reg0->VpiParent(av0);
                        setLoc(reg0, nameSpan(bm.location, bm.name));
                        auto* rrt0 = s.MakeRef_typespec();
                        rrt0->VpiFullName(bfull);
                        rrt0->VpiParent(reg0);
                        rrt0->Actual_typespec(ets0);
                        reg0->Typespec(rrt0);
                        // § typeParamRetIsRefVar58 — no vpiSigned on a
                        // ref_var; the same repeat of the law as the
                        // block-item array factory at TaskFuncEmit ~4428.
                        if (leaf0->isSigned() &&
                            !typeParamVarIsRefVar58(*leaf0) &&
                            declArrayElemVarKind12(bm) ==
                                TdLocalVarKind10::Resolved)
                            reg0->VpiSigned(true);
                        // § blockDeclAutomaticIsWrittenKw80, SITE 3 of 4 — the
                        // FIXED-SIZE unpacked array's element (arm c2 c_fix,
                        // n_marr).
                        if (auto80)
                            reg0->VpiAutomatic(true);
                        auto* rv0 = s.MakeVariablesVec();
                        rv0->push_back(reg0);
                        av0->Variables(rv0);
                        vars->push_back(reg0);
                        vars->push_back(av0);
                        blockMap[&bm] = av0;
                        continue;
                    }
                    if (vlogHiddenTy) {
                        v = s.MakeRef_var();
                        vlogHiddenBlockVars.insert(&bm);
                    }
                    else {
                        v = makeEnumArrayVar(ts, bfull, b);
                        // § classTdLocalVarKindFollowsCompileOrder10,
                        // SITE 2 of 2 — the BLOCK-ITEM local (`begin`/`fork`
                        // body, an `initial` body).  Same law, same order,
                        // measured on the same grid: `g2`'s `b_scoped_struct`
                        // is a begin-block local of a late-sorting owner's
                        // struct typedef and golden gives it the same bare
                        // `class_var` it gives the function-body local two
                        // lines above it.  EmitHelpers.h carries the law.
                        if (!v)
                            switch (classTdLocalVarKind10(bm)) {
                                case TdLocalVarKind10::ClassVar:
                                    v = s.MakeClass_var();
                                    break;
                                case TdLocalVarKind10::RefVar:
                                    v = s.MakeRef_var();
                                    break;
                                case TdLocalVarKind10::Resolved:
                                    break;
                            }
                        if (!v)
                            v = makeReturnVar(s,
                                              bm.getDeclaredType()->getType());
                    }
                    // § atomVarSignedWritten68, site 5 of 7 — a BLOCK-item
                    // local: `begin`, a NAMED begin, a `fork` arm, an
                    // `initial` / `always_comb` body (arm a1 t_blk / t_ini, arm
                    // a5 33:9 ac_loc / 37:9 nb_loc / 40:13 fk_loc).  The
                    // array/queue arm ABOVE this `else` mints an element reg of
                    // its own and is left alone for the same reason site 4 is
                    // gated: element signedness is § arrayVarSignedWritten8's.
                    clearNamedAtomSigned68(v, bm.getDeclaredType()->getType());
                    v->VpiName(bm.name);
                    v->VpiFullName(bfull);
                    v->VpiParent(b);
                    setLoc(v, nameSpan(bm.location, bm.name));
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(bfull);
                    rt->VpiParent(v);
                    // § classScopedTdDeclTsUnsupported11, SITE 2 of 5 — the
                    // BLOCK-ITEM local (`begin` / `fork` body, an `initial`
                    // body).  Same law, same three questions; grid11 `g3`
                    // `blk3::l_blk` is the cell that scores this site on its
                    // own.
                    if (auto* uts11 = makeScopedTdUnsupTs11(bm))
                        rt->Actual_typespec(uts11);
                    else
                        rt->Actual_typespec(ts);
                    v->Typespec(rt);
                    // § blockDeclAutomaticIsWrittenKw80, SITE 4 of 4 — the
                    // SCALAR / vector / string / class-handle / enum / struct
                    // declaration, which is the whole corpus population (arm c1
                    // c1/c3/c6/c12/c14/c17/c19/c22, arm c2
                    // a_scal/b_vec/g_str/h_cls/i_enum/j_str2/k_m1/k_m2).
                    if (auto80)
                        v->VpiAutomatic(true);
                    if (!vlogHiddenTy)
                        blockMap[&bm] = v;
                    vars->push_back(v);
                    // PAR_BLOCK (fork...join) quirk: CompileStmt's par_block
                    // arm marks a declaration "handled" only while the scope's
                    // Variables vector is still NULL, so a fork-local
                    // declaration WITHOUT an initialiser lands in Variables
                    // TWICE and its (Rhs-less) declaration `assignment` also
                    // survives as a statement.  Measured on UnitElabBlock's
                    // `fork : innerwave reg hold; join`; the multi-declaration
                    // shape is unmeasured.
                    if (isFork &&
                        !bm.as<VariableSymbol>().getInitializer()) {
                        vars->push_back(v);
                        auto* da9 = s.MakeAssignment();
                        da9->VpiParent(b);
                        da9->VpiOpType(vpiAssignmentOp);
                        da9->VpiBlocking(true);
                        setLoc(da9, nameSpan(bm.location, bm.name));
                        da9->Lhs(v);
                        forkDeclStmts9.push_back(da9);
                    }
                }
                if (!vars->empty())
                    b->Variables(vars);
            }
            auto* stmts = s.MakeAnyVec();
            for (auto* ds9 : forkDeclStmts9)
                stmts->push_back(ds9);
            // Block-scoped localparams appear as inline param_assign stmts
            // (bare parameter, folded unparented rhs, no typespecs).
            if (bs.blockSymbol) {
                for (auto& bm : bs.blockSymbol->members()) {
                    if (bm.kind != SymbolKind::Parameter)
                        continue;
                    auto& ps = bm.as<ParameterSymbol>();
                    auto* pa = s.MakeParam_assign();
                    pa->VpiParent(b);
                    auto* up = s.MakeParameter();
                    up->VpiName(ps.name);
                    up->VpiFullName(innerPrefix + "." + std::string(ps.name));
                    up->VpiParent(pa);
                    up->VpiLocalParam(true);
                    if (auto syn = ps.getSyntax()) {
                        setLoc(pa, syn->sourceRange());
                        setLoc(up, syn->sourceRange());
                    }
                    pa->Lhs(up);
                    if (auto pinit = ps.getInitializer()) {
                        auto& cv = ps.getValue();
                        if (cv.isInteger() && !cv.integer().hasUnknown()) {
                            auto& iv = cv.integer();
                            bool neg = iv.isSigned() && iv.isNegative();
                            std::string digits = iv.toString(LiteralBase::Decimal, false);
                            auto* c = s.MakeConstant();
                            c->VpiValue((neg ? "INT:" : "UINT:") + digits);
                            c->VpiDecompile((neg ? "-" : "") + digits);
                            c->VpiSize(64);
                            c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
                            setLoc(c, pinit->sourceRange);
                            pa->Rhs(c);
                        }
                    }
                    stmts->push_back(pa);
                }
            }
            auto& body = bs.body;
            // An initialized block-local var emits a blocking assignment
            // (var = init) at its declaration site; the var re-parents to
            // that assignment.
            auto emitDeclStmt9 = [&](const Statement& st) {
                auto& vs = st.as<VariableDeclStatement>().symbol;
                auto* init =
                    vs.getDeclaredType() ? vs.getDeclaredType()->getInitializer()
                                         : nullptr;
                auto vit = blockMap.find(&vs);
                // § declInitWrittenNewNoStmt66 — CALL SITE 1 of 2: the
                // statement list of a WRITTEN block (begin / named begin /
                // fork / loop body / case item) and of a module `initial` /
                // `always`.  A local whose written initializer is a `new`
                // emits NO assignment at all: golden keeps only the variable,
                // parented at the block.
                //
                // THIS SITE ALREADY CARRIED THE LAW — for `NewClass` ONLY, and
                // it was ONE TERM SHORT.  The clause it replaces read
                // `init->kind == ExpressionKind::NewClass`, measured on
                // `initial begin C d = new(); end` and SimpleConstraint's
                // `frame_t frame = new();`.  Arm a2 n02/n03 are the DYNAMIC-
                // ARRAY twins of exactly those two cells — `int d[] =
                // new[3];` in a written begin and in a module `initial` — and
                // golden drops them too, while we kept the assignment and
                // re-parented the array_var onto it.  The predicate now covers
                // both `new` forms from one place.
                if (declInitWrittenNewNoStmt66(vs))
                    return;
                // RESIDUE (ranked, measured on `program p1; initial
                // begin integer j = 0; j = 1; end`): when the block is
                // a PROGRAM's, golden's decl assignment takes a
                // ref_obj Lhs, not the integer_var — the var-as-Lhs
                // form below matches the module case and
                // SimpleConstraint (whose `j = 0` golden IS the var),
                // so the program-only variant is unresolved and no
                // corpus test reaches it.
                if (init && vit != blockMap.end()) {
                    auto* asn = s.MakeAssignment();
                    asn->VpiOpType(kVpiAssignmentOp);
                    asn->VpiBlocking(true);
                    asn->VpiParent(b);
                    if (auto dsyn = vs.getSyntax())
                        setLoc(asn, dsyn->sourceRange());
                    vit->second->VpiParent(asn);
                    asn->Lhs((UHDM::expr*)vit->second);
                    if (auto* rhs = emitExpr(*init, asn, innerPrefix, blockMap))
                        asn->Rhs((UHDM::expr*)rhs);
                    stmts->push_back(asn);
                }
            };
            if (body.kind == StatementKind::List) {
                for (auto st : body.as<StatementList>().list) {
                    if (st->kind == StatementKind::VariableDeclaration) {
                        emitDeclStmt9(*st);
                        continue;
                    }
                    // § thisSuperNewAssignNoStmt3 — CALL SITE 1 of 5: the
                    // statement list of a WRITTEN `begin`/`fork`.  The block
                    // itself is built either way, so an all-dropped block comes
                    // out EMPTY, which is what golden does (a3 p9, a4 q8).
                    if (thisSuperNewAssignNoStmt3(*st))
                        continue;
                    if (auto* u = emitStmt(*st, b, innerPrefix, blockMap))
                        stmts->push_back(u);
                }
            }
            // A block whose ONLY statement is a declaration (`begin string
            // p_ = e; end`) is not wrapped in a StatementList by slang — it
            // takes the same declaration path, not the generic one, which
            // has no VariableDeclaration arm (LocalScopeHierPath).
            else if (body.kind == StatementKind::VariableDeclaration) {
                emitDeclStmt9(body);
            }
            // § thisSuperNewAssignNoStmt3 — CALL SITE 2 of 5: a WRITTEN
            // `begin`'s SINGLE statement is still a list element (slang skips
            // the StatementList wrapper for it), and golden keeps the begin and
            // empties it — arm a3 p4, `begin this.d = new[3]; end`.
            else if (thisSuperNewAssignNoStmt3(body)) {
                // no element
            }
            else if (auto* u = emitStmt(body, b, innerPrefix, blockMap)) {
                stmts->push_back(u);
            }
            if (b->UhdmType() == UHDM::uhdmnamed_begin)
                ((UHDM::named_begin*)b)->Stmts(stmts);
            else if (b->UhdmType() == UHDM::uhdmnamed_fork)
                ((UHDM::named_fork*)b)->Stmts(stmts);
            else if (b->UhdmType() == UHDM::uhdmfork_stmt)
                ((UHDM::fork_stmt*)b)->Stmts(stmts);
            else
                ((UHDM::begin*)b)->Stmts(stmts);
            return b;
        }
        case StatementKind::Disable: {
            auto& ds = stmt.as<DisableStatement>();
            auto* d = s.MakeDisable();
            d->VpiParent(parent);
            setLoc(d, stmt.sourceRange);
            // The disable target: the named block's scope object.
            auto& t = stripImplicitConv(ds.target);
            const Symbol* tgt = nullptr;
            if (t.kind == ExpressionKind::NamedValue)
                tgt = &t.as<NamedValueExpression>().symbol;
            else if (t.kind == ExpressionKind::ArbitrarySymbol)
                tgt = t.as<ArbitrarySymbolExpression>().symbol;
            if (tgt)
                if (auto it2 = namedBlockMap.find(tgt); it2 != namedBlockMap.end())
                    d->VpiExpr((UHDM::expr*)(UHDM::any*)it2->second);
            // Surelog can't resolve the block label: it also mints an implicit
            // module wire named after the target (at the label token).
            if (tgt && implicitNetModule) {
                auto& inet = implicitNetMap[tgt];
                if (!inet) {
                    inet = s.MakeLogic_net();
                    inet->VpiName(tgt->name);
                    inet->VpiFullName(implicitNetPrefix + "." + std::string(tgt->name));
                    inet->VpiParent(implicitNetModule);
                    inet->VpiNetType(1);
                    auto tl = ds.target.sourceRange;
                    setLoc(inet, tl);
                    auto* nets2 = implicitNetModule->Nets();
                    if (!nets2) {
                        nets2 = s.MakeNetVec();
                        implicitNetModule->Nets(nets2);
                    }
                    nets2->push_back(inet);
                }
            }
            return d;
        }
        case StatementKind::DisableFork: {
            auto* df = s.MakeDisable_fork();
            df->VpiParent(parent);
            setLoc(df, stmt.sourceRange);
            return df;
        }
        // An event TRIGGER (`-> output_eof;`) is an event_stmt carrying the
        // event's NAME only: Surelog leaves vpiNamedEvent unset and stamps
        // vpiBlocking for the `->` form (`->>` is the non-blocking one).
        // We emitted nothing at all, which dropped the whole statement from
        // its begin block (YosysBigSimSoft bench.v:115).
        case StatementKind::EventTrigger: {
            auto& es9 = stmt.as<EventTriggerStatement>();
            auto* ev9 = s.MakeEvent_stmt();
            ev9->VpiParent(parent);
            setLoc(ev9, stmt.sourceRange);
            auto& tg9 = stripImplicitConv(es9.target);
            const Symbol* tsym9 = nullptr;
            if (tg9.kind == ExpressionKind::NamedValue)
                tsym9 = &tg9.as<NamedValueExpression>().symbol;
            else if (tg9.kind == ExpressionKind::ArbitrarySymbol)
                tsym9 = tg9.as<ArbitrarySymbolExpression>().symbol;
            if (tsym9)
                ev9->VpiName(tsym9->name);
            if (!es9.isNonBlocking)
                ev9->VpiBlocking(true);
            return ev9;
        }
        case StatementKind::ProceduralAssign: {
            auto& pas = stmt.as<ProceduralAssignStatement>();
            if (pas.assignment.kind == ExpressionKind::Assignment) {
                auto& ae = pas.assignment.as<AssignmentExpression>();
                auto* as2 = s.MakeAssign_stmt();
                as2->VpiParent(parent);
                // Span reaches the RHS end (not the trailing ';'), matching
                // Surelog.
                setLoc(as2, SourceRange(stmt.sourceRange.start(),
                                        ae.right().sourceRange.end()));
                // Surelog parents an assign_stmt's RHS constant at the
                // assign_stmt (in every context, incl. package tasks).
                bool sfcp = forceConstParent;
                forceConstParent = true;
                if (auto* r = emitExpr(ae.right(), as2, prefix, netMap))
                    as2->Rhs((UHDM::expr*)r);
                forceConstParent = sfcp;
                inLhs = true;
                if (auto* l = emitExpr(ae.left(), as2, prefix, netMap))
                    as2->Lhs((UHDM::expr*)l);
                inLhs = false;
                return as2;
            }
            noteUnsupported("procedural assign form");
            return nullptr;
        }
        case StatementKind::RepeatLoop: {
            auto& rl = stmt.as<RepeatLoopStatement>();
            auto* r = s.MakeRepeat();
            r->VpiParent(parent);
            setLoc(r, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 6));
            suppressConstParent = true;
            if (auto* c = emitExpr(rl.count, r, prefix, netMap))
                r->VpiCondition((UHDM::expr*)c);
            suppressConstParent = false;
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(rl.body, r, prefix, netMap))
                    r->VpiStmt(b);
            }
            return r;
        }
        case StatementKind::WhileLoop: {
            auto& wl = stmt.as<WhileLoopStatement>();
            auto* w = s.MakeWhile_stmt();
            w->VpiParent(parent);
            // Keyword-only span ("while").
            setLoc(w, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 5));
            if (auto* c = emitExpr(wl.cond, w, prefix, netMap))
                w->VpiCondition((UHDM::expr*)c);
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(wl.body, w, prefix, netMap))
                    w->VpiStmt(b);
            }
            return w;
        }
        case StatementKind::DoWhileLoop: {
            auto& dw = stmt.as<DoWhileLoopStatement>();
            auto* w = s.MakeDo_while();
            w->VpiParent(parent);
            setLoc(w, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 2));
            if (auto* c = emitExpr(dw.cond, w, prefix, netMap))
                w->VpiCondition((UHDM::expr*)c);
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(dw.body, w, prefix, netMap))
                    w->VpiStmt(b);
            }
            return w;
        }
        case StatementKind::ForeverLoop: {
            auto& fl = stmt.as<ForeverLoopStatement>();
            auto* f = s.MakeForever_stmt();
            f->VpiParent(parent);
            setLoc(f, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 7));
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(fl.body, f, prefix, netMap))
                    f->VpiStmt(b);
            }
            return f;
        }
        case StatementKind::ForeachLoop: {
            auto& fe = stmt.as<ForeachLoopStatement>();
            auto* fs = s.MakeForeach_stmt();
            fs->VpiParent(parent);
            fs->VpiFullName(prefix);
            // Surelog anchors the foreach_stmt at the "foreach" keyword alone.
            setLoc(fs, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 7));

            const syntax::ForeachLoopListSyntax* ll = nullptr;
            if (stmt.syntax &&
                stmt.syntax->kind == syntax::SyntaxKind::ForeachLoopStatement)
                ll = stmt.syntax->as<syntax::ForeachLoopStatementSyntax>().loopList;

            // slang folds the LEADING index groups of a `foreach(a[i][j])` into
            // the array reference and keeps only the last group as loop dims.
            // Surelog keeps one flat index list against the BARE array, so peel
            // the folded groups back off — outermost first. Each carries an
            // already-open loop variable (declared by an enclosing foreach).
            std::vector<const syntax::SyntaxNode*> foldedIdx;
            const syntax::ExpressionSyntax* arrBase = ll ? &*ll->arrayName : nullptr;
            while (arrBase &&
                   arrBase->kind == syntax::SyntaxKind::ElementSelectExpression) {
                auto& ese = arrBase->as<syntax::ElementSelectExpressionSyntax>();
                foldedIdx.push_back(&*ese.select);
                arrBase = &*ese.left;
            }
            std::reverse(foldedIdx.begin(), foldedIdx.end());
            // A name-context parse yields identifier+selectors instead.
            if (arrBase && arrBase->kind == syntax::SyntaxKind::IdentifierSelectName)
                for (auto* sel : arrBase->as<syntax::IdentifierSelectNameSyntax>().selectors)
                    foldedIdx.push_back(sel);

            // vpiVariables: a ref_var naming the iterated array, its ref
            // typespec bound to the array's OWN array_typespec.
            const Symbol* arrSym = fe.arrayRef.getSymbolReference();
            // § classPropIterThisRefVar21 — slang models an IMPLICIT class
            // property reference as a MemberAccess on an implicit `this`, so
            // `fe.arrayRef.kind` alone cannot tell `foreach (q[i])` from
            // `foreach (other.q[i])`; read the written syntax instead.  Three
            // spellings, three golden shapes, pinned on t32f/t32g (both views,
            // with and without a $unit import):
            //   `q[i]`        ref_var 'q' bound to an unsupported_typespec 'q'
            //   `this.q[i]`   ref_var 'q' with NO typespec at all
            //   `other.q[i]`  hier_path (VpiName cleared) — the only hier_path
            // and only the third resolves its loop variable unconditionally
            // (§ foreachHierPathAlwaysRes21 below); the first two obey the
            // $unit gate together.
            bool arrThis21 = false, arrDotted21 = false;
            if (arrSym && fe.arrayRef.kind == ExpressionKind::MemberAccess) {
                if (arrBase && arrBase->kind == syntax::SyntaxKind::ScopedName) {
                    const syntax::NameSyntax* root21 =
                        &*arrBase->as<syntax::ScopedNameSyntax>().left;
                    while (root21->kind == syntax::SyntaxKind::ScopedName)
                        root21 = &*root21->as<syntax::ScopedNameSyntax>().left;
                    if (root21->kind == syntax::SyntaxKind::ThisHandle)
                        arrThis21 = true;
                    else
                        arrDotted21 = true;
                }
                else
                    arrDotted21 = true;
            }
            // § foreachShadowFormalWins22 — `this.<name>` where the ENCLOSING
            // SUBROUTINE also declares <name> resolves its LOOP VARIABLE
            // through the SUBROUTINE's declaration, not the class property.
            // uvm_reg_block writes exactly that four times
            // (`function void get_registers(ref uvm_reg regs[$]); foreach
            // (this.regs[rg])`, and get_memories / get_maps / get_blocks;
            // uvm_vreg::get_fields is a fifth), and golden answers
            // `class_var 'uvm_reg'` — the FORMAL's element typespec — in
            // Scoreboard and SimpleUVM, where § classPropUnitImport21's $unit
            // import says a class property must NOT resolve at all.
            //
            // Measured on a purpose-built pair whose two candidate routes give
            // DIFFERENT answers (tools/probe/r10uvm22repro/t33d + t33e): a
            // property `int p_a[string]` (property route -> string_var by the
            // assoc INDEX rule) shadowed by a formal `ref Cel p_a[$]` (formal
            // route -> class_var 'Cel', an io_decl carrying the ELEMENT
            // typespec).  Golden reads `class_var 'Cel'` in BOTH arms — with
            // the $unit import (t33d) and without it (t33e) — so the formal
            // wins unconditionally, while the same file's un-shadowed `p_b`
            // still tracks the gate (int_var in t33d, string_var in t33e).
            // Only the LOOP VARIABLE moves: golden's iterated reference is
            // still § classPropIterThisRefVar21's typespec-less `ref_var`.
            //
            // The BARE spelling needs no rule — slang's own name resolution
            // already binds it to the shadowing declaration.
            bool shadowFormal22 = false;
            if (arrThis21 && arrSym && currentSubSym)
                if (auto* sh22 = currentSubSym->find(arrSym->name))
                    if (sh22 != arrSym &&
                        (sh22->kind == SymbolKind::FormalArgument ||
                         sh22->kind == SymbolKind::Variable)) {
                        arrSym = sh22;
                        shadowFormal22 = true;
                    }
            // A foreach over a MEMBER of a local (`foreach (path.slices[j])`)
            // lists the whole dotted reference as a hier_path, not a ref_var
            // (Surelog resolves the loop list as an expression before it
            // decides the iterated object). LocalScopeHierPath.
            bool arrMember9 = arrDotted21;
            if (arrMember9) {
                if (auto* hp9 = emitExpr(fe.arrayRef, fs, prefix, netMap)) {
                    hp9->VpiParent(fs);
                    // The loop-list hier_path carries no name of its own
                    // (an expression-context one would be `path.slices`).
                    if (hp9->UhdmType() == UHDM::uhdmhier_path)
                        ((UHDM::hier_path*)hp9)->VpiName(std::string());
                    fs->Variable((UHDM::variables*)(UHDM::any*)hp9);
                }
                else
                    arrMember9 = arrDotted21 = false;
            }
            // A foreach over a CLASS PROPERTY stays unresolved in the
            // ELABORATED listing too: that listing is the copy Surelog
            // recompiles in the scope that HOISTS the out-of-body definition
            // (the importing module), where the bare property name is no
            // array at all. The array reference takes an unsupported_typespec
            // and the loop variable falls back to the default int_var —
            // measured against `class C; int q[$]; extern function void
            // rep(); endclass function void C::rep(); foreach (q[k]) ...`
            // with and without a `import p::*` module: the array's own
            // array_typespec survives only when nothing hoists the method.
            bool classPropArr9 = false;
            if (arrSym && !classMethodNoBind && !pkgDefViewBody9)
                if (auto* apc9 = arrSym->getParentScope())
                    classPropArr9 =
                        apc9->asSymbol().kind == SymbolKind::ClassType;
            bool foreachUnres9 =
                classMethodNoBind || pkgDefViewBody9 || classPropArr9;
            // § classPropUnitImport21 — the class property's array REFERENCE
            // stays unresolved (classPropArr9 above), but its LOOP VARIABLE is
            // answered by a different Surelog pass and usually DOES resolve.
            // `swapForSpecifiedVar` (UhdmWriter.cpp:2490) re-resolves the bare
            // property NAME through `decodeHierPath` against the DesignComponent
            // whose `needLateTypedefBinding` list it is walking, and feeds the
            // result to `getSimpleVarFromTypespec`.  The home package's own pass
            // (UhdmWriter.cpp:1302) resolves it; what breaks it is that
            // `CompileHelper::importPackage` copies the imported package's WHOLE
            // late-binding list into the importing scope and `write()` runs the
            // FileContent pass over that copy LAST (UhdmWriter.cpp:4991, after
            // the package loop) — so ONE `$unit`-scope import of the class's
            // home package anywhere in the design gets the last word, fails to
            // resolve a class-property name at file scope, and overwrites every
            // such loop variable with the int_var fallback (:2550).
            //
            // Measured BOTH DIRECTIONS on the corpus sources themselves, one
            // line each (tools/probe/r10uvm21repro/README.md):
            //   SeqDriver + `import uvm_pkg::*;` at $unit  ->  ELABPKG
            //     900 array_var / 630 class_var / 180 string_var / 12 int_var
            //     becomes 486 / 132 / 36 / 1074 — SimpleUVM's shape exactly;
            //   SimpleUVM with its $unit import and classes moved INTO a package
            //     -> DEFMOD 179 int_var / 81 array_var becomes 150 array_var /
            //     105 class_var / 2 int_var — SeqDriver's shape exactly.
            // and isolated on a 25-line design in t32a..t32e: no import (a),
            // module-scope import (b) and package-scope import (d) all resolve
            // {queue,dynamic,fixed} -> array_var, `[string]` -> string_var,
            // `[Cel]` -> class_var 'Cel'; a $unit-scope import resolves NOTHING,
            // whether it is a WILDCARD (c) or EXPLICIT (e) — which is what
            // importPackage's unfiltered list copy predicts.
            //
            // This SUPERSEDES § foreachAssocIdxImporterView19, whose gate ("some
            // other PACKAGE wildcard-imports the home package") agreed with the
            // truth on three of the UVM-4 by coincidence and was wrong on
            // BuildUVMPkg, which has no importer at all and resolves.
            //
            // § foreachHierPathAlwaysRes21 — and a DOTTED iterated reference
            // (`foreach (phase.m_predecessors[pred])`, arrMember9 above) is
            // EXEMPT from the gate: it resolves in all four tests, $unit import
            // or not.  Source-first, that is the OTHER arm of
            // swapForSpecifiedVar: a hier_path loop list is fed to
            // decodeHierPath AS WRITTEN (:2511), so the path root — a local, a
            // formal, `this` — carries the type in whatever DesignComponent the
            // pass is walking, where the synthetic one-element path the BARE
            // name arm builds (:2529) has nothing but the name and needs the
            // class scope the FileContent pass does not have.  144 sites over
            // the UVM-4, `array_var` / `class_var` / `struct_var` / `bit_var`
            // in golden against our int_var, present in BuildUVMPkg and
            // SeqDriver (no $unit import) exactly as in SimpleUVM and
            // Scoreboard (one).
            // `this.q[i]` is NOT exempt: t32f writes all five properties as
            // `this.<prop>` under a $unit import and golden answers int_var for
            // every one, exactly as for the bare spelling, while the same file's
            // `other.<prop>` still gives array_var / string_var / class_var.
            // uvm-1.2 writes both spellings, so this cell is load-bearing:
            // `uvm_mem_mam::reserve_region`'s `foreach (this.in_use[i])` is an
            // array_var in BuildUVMPkg and an int_var in Scoreboard.
            bool classPropRes21 = false;
            if (classPropArr9) {
                if (arrDotted21)
                    classPropRes21 = true;
                else {
                    const Scope* hp21 = arrSym->getParentScope();
                    while (hp21 && hp21->asSymbol().kind != SymbolKind::Package)
                        hp21 = hp21->asSymbol().getParentScope();
                    classPropRes21 =
                        hp21 && !pkgImportedByUnit21(hp21->asSymbol());
                }
            }
            // § foreachLocalArrayVar20 — is the iterated array a SUBROUTINE
            // LOCAL declaration?  Surelog's loop variable is
            // getSimpleVarFromTypespec applied to whatever the DECLARATION
            // object carries, and only a subroutine local carries the
            // array_typespec itself: a FORMAL's io_decl and a module/class
            // variable both hand it the ELEMENT typespec, so those drill.
            // Measured on the t30/t31 matrix pair, both views.
            bool tfLocalArr20 = false;
            if (arrSym && arrSym->kind == SymbolKind::Variable)
                for (const Scope* sc20 = arrSym->getParentScope(); sc20;
                     sc20 = sc20->asSymbol().getParentScope()) {
                    auto k20 = sc20->asSymbol().kind;
                    if (k20 == SymbolKind::Subroutine) {
                        tfLocalArr20 = true;
                        break;
                    }
                    if (k20 != SymbolKind::StatementBlock)
                        break;
                }
            if (arrSym && !arrMember9) {
                auto* rv = s.MakeRef_var();
                rv->VpiName(arrSym->name);
                std::string afn = joinRef(prefix, std::string(arrSym->name));
                rv->VpiFullName(afn);
                rv->VpiParent(fs);
                setLoc(rv, arrBase ? nameSpan(arrBase->sourceRange().start(), arrSym->name)
                                   : fe.arrayRef.sourceRange);
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(afn);
                art->VpiParent(rv);
                // Inside a CLASS METHOD Surelog never resolves the iterated
                // name: its class-body CompileType falls through to the
                // catch-all and mints an unsupported_typespec NAMED as
                // written, at the identifier span. Probe-verified for queue,
                // dynamic AND fixed-size arrays alike — a module function's
                // foreach still binds the real array_typespec (ClassVar,
                // LocalScopeHierPath).
                if (arrThis21) {
                    // § classPropIterThisRefVar21: typespec-LESS (see the note
                    // at rv->Typespec below) — nothing to bind, nothing to
                    // defer, and in particular no pendingForeachArrayTs entry.
                }
                else if (foreachUnres9) {
                    auto* uts = s.MakeUnsupported_typespec();
                    uts->VpiName(arrSym->name);
                    uts->VpiLineNo(rv->VpiLineNo());
                    uts->VpiColumnNo(rv->VpiColumnNo());
                    uts->VpiEndLineNo(rv->VpiEndLineNo());
                    uts->VpiEndColumnNo(rv->VpiEndColumnNo());
                    // Out-of-body and package-level bodies mint it inside the
                    // home package; an IN-CLASS body's carries no instance.
                    if (pkgScopeInst)
                        uts->Instance(pkgScopeInst);
                    art->Actual_typespec(uts);
                }
                else {
                    // § foreachFormalArrayTs9 — a foreach over a subroutine
                    // FORMAL has no array_typespec to bind: an unpacked
                    // formal's dimensions live on the io_decl's own Ranges
                    // and its typespec IS the element type (TaskFuncEmit
                    // ~1616), so Surelog hands the array reference that very
                    // typespec object.  Measured on repro q1/q3: golden's
                    // `foreach (i[k])` over `ref string i[$]` binds the
                    // io_decl's string_typespec and over `input int a[4]`
                    // its int_typespec, where we minted a bare, nameless
                    // array_typespec.  A module VARIABLE array keeps the real
                    // array_typespec (q3's `int arr[4]` in a module function
                    // — golden binds array_typespec there), so this is the
                    // io_decl arm only.
                    UHDM::ref_typespec* ioRt9 = nullptr;
                    if (auto fit9 = netMap.find(arrSym); fit9 != netMap.end())
                        if (fit9->second &&
                            fit9->second->UhdmType() == UHDM::uhdmio_decl)
                            ioRt9 = ((UHDM::io_decl*)fit9->second)->Typespec();
                    if (ioRt9 && ioRt9->Actual_typespec())
                        art->Actual_typespec(ioRt9->Actual_typespec());
                    else if (ioRt9)
                        pendingLoopVarTs9.push_back({art, ioRt9});
                    else
                        pendingForeachArrayTs.push_back(
                            {art, arrSym, implicitNetModule});
                }
                // § classPropIterThisRefVar21 — an EXPLICIT `this.` prefix
                // leaves the reference typespec-LESS.  Golden's `this.p_q` is
                // `ref_var 'p_q'` with a null Typespec() in every view of both
                // t32f and t32g, where the bare `p_q` of t32a carries the
                // unsupported_typespec: Surelog compiles the `this` handle
                // select, finds no typespec for the selected member and binds
                // nothing rather than minting the catch-all.
                if (!arrThis21)
                    rv->Typespec(art);
                fs->Variable(rv);
            }

            // vpiLoopVars: one variable per NAMED dimension, whose class and
            // typespec follow the array's ELEMENT type (Surelog resolves the
            // implicit declaration from the array, not from the index use); a
            // vpiNullOp operation stands in for each SKIPPED dimension.
            std::vector<std::string> declaredHere;
            auto* lvars = s.MakeAnyVec();
            // The scope the loop-variable names are resolved AGAINST: the one
            // enclosing the foreach, skipping the implicit blocks slang wraps
            // the loop (and any enclosing foreach) in, so only real
            // declarations are found.
            const Scope* lvScope9 = nullptr;
            for (auto& ld0 : fe.loopDims)
                if (ld0.loopVar) {
                    lvScope9 = ld0.loopVar->getParentScope();
                    break;
                }
            while (lvScope9 &&
                   lvScope9->asSymbol().kind == SymbolKind::StatementBlock)
                lvScope9 = lvScope9->asSymbol().getParentScope();
            // The emitted object's own typespec, for the ref_var arm below.
            auto lvActualTs9 = [](UHDM::any* o) -> UHDM::ref_typespec* {
                if (!o)
                    return nullptr;
                if (auto* v0 = any_cast<UHDM::variables*>(o))
                    return v0->Typespec();
                if (o->UhdmType() == UHDM::uhdmio_decl)
                    return ((UHDM::io_decl*)o)->Typespec();
                if (auto* n0 = any_cast<UHDM::net*>(o))
                    return n0->Typespec();
                return nullptr;
            };
            auto declLoopVar = [&](std::string_view name,
                                   SourceRange span) -> UHDM::variables* {
                std::string lvn(name);
                // A loop-variable name that ALREADY RESOLVES in the enclosing
                // scope declares nothing: Surelog emits a ref_var over the
                // existing object's OWN typespec — a formal, a subroutine
                // local or a module variable alike — and builds a fresh one
                // per foreach, so a nested loop naming the same formal gets a
                // second object (probe r10c4_p7 g3).
                if (lvScope9 && !classMethodNoBind && !pkgDefViewBody9)
                    if (auto* sh9 = Lookup::unqualified(*lvScope9, lvn))
                        if (auto sit9 = netMap.find(sh9); sit9 != netMap.end())
                            if (auto* srcRt9 = lvActualTs9(sit9->second)) {
                                auto* rv9 = s.MakeRef_var();
                                rv9->VpiName(name);
                                rv9->VpiFullName(joinRef(prefix, lvn));
                                rv9->VpiParent(fs);
                                setLoc(rv9, span);
                                auto* srt9 = s.MakeRef_typespec();
                                srt9->VpiFullName(joinRef(prefix, lvn));
                                srt9->VpiParent(rv9);
                                // A module net's own typespec is bound in a
                                // later pass, so mirror it there too.
                                if (srcRt9->Actual_typespec())
                                    srt9->Actual_typespec(
                                        srcRt9->Actual_typespec());
                                else
                                    pendingLoopVarTs9.push_back({srt9, srcRt9});
                                rv9->Typespec(srt9);
                                lvars->push_back(rv9);
                                return nullptr;
                            }
                // A NESTED foreach re-lists the enclosing loop's variable
                // OBJECT rather than declaring a second one.
                if (auto oit = openForeachVars.find(lvn); oit != openForeachVars.end()) {
                    lvars->push_back(oit->second);
                    return nullptr;
                }
                // Class-method foreach: the loop variable is unresolved the
                // same way the array reference is — a ref_var over a
                // freshly minted unsupported_typespec named for the index.
                // § cloneForeachLoopVarUnresolved37 — and so is a WILDCARD-
                // IMPORT CLONE's, in BOTH package views.  `pkgDefViewBody9`
                // covers a CLASS-METHOD clone in either view (cloneMode) and a
                // free function in the DEF view, but the importer's ELABORATED
                // listing of a cloned FREE function fell through to the
                // resolved arm and listed an array_var where golden lists a
                // ref_var (t51a, `ELABPKG imp51::f51`): the clone re-uses the
                // home's UN-elaborated body whichever listing it lands in.
                if (classMethodNoBind || pkgDefViewBody9 ||
                    pkgImportCloneEmit) {
                    auto* lv0 = s.MakeRef_var();
                    lv0->VpiName(name);
                    lv0->VpiFullName(joinRef(prefix, lvn));
                    lv0->VpiParent(fs);
                    setLoc(lv0, span);
                    auto* uts0 = s.MakeUnsupported_typespec();
                    uts0->VpiName(name);
                    uts0->VpiParent(lv0);
                    setLoc(uts0, span);
                    auto* lrt0 = s.MakeRef_typespec();
                    lrt0->VpiFullName(joinRef(prefix, lvn));
                    lrt0->VpiParent(lv0);
                    lrt0->Actual_typespec(uts0);
                    lv0->Typespec(lrt0);
                    // § pkgCloneLoopVarBind37 — inside a WILDCARD-IMPORT CLONE
                    // this listing object is not the end of the chain: golden
                    // binds it, and every body reference to the name, to ONE
                    // further unresolved ref_var shared by both clone views
                    // (see § cloneLoopVarShared37 for what that object is in
                    // Surelog).  Minted here, at the one site that builds a
                    // clone's loop variable, and keyed by the DECLARATION site
                    // so the def and elab views of the same clone — and every
                    // importer's copy — reach the same object.
                    if (pkgImportCloneEmit) {
                        std::string k37 =
                            std::string(name) + "@" +
                            std::to_string(lv0->VpiLineNo()) + ":" +
                            std::to_string(lv0->VpiColumnNo());
                        auto& sh37 = cloneLoopVarShared37[k37];
                        if (!sh37) {
                            sh37 = s.MakeRef_var();
                            sh37->VpiName(name);
                            sh37->VpiFullName(joinRef(prefix, lvn));
                            sh37->VpiParent(fs);
                            setLoc(sh37, span);
                            auto* uts37 = s.MakeUnsupported_typespec();
                            uts37->VpiName(name);
                            uts37->VpiParent(sh37);
                            setLoc(uts37, span);
                            auto* lrt37 = s.MakeRef_typespec();
                            lrt37->VpiFullName(joinRef(prefix, lvn));
                            lrt37->VpiParent(sh37);
                            lrt37->Actual_typespec(uts37);
                            sh37->Typespec(lrt37);
                        }
                        lv0->Actual_group(sh37);
                    }
                    lvars->push_back(lv0);
                    openForeachVars[lvn] = lv0;
                    declaredHere.push_back(lvn);
                    return nullptr;
                }
                // The array reference itself did not resolve (classPropArr9),
                // so Surelog's getSimpleVarFromTypespec has nothing to read
                // and the loop variable takes the bare int default.
                UHDM::typespec* lts = nullptr;
                UHDM::variables* lv = nullptr;
                // A pass-22 arm that RESOLVED the loop variable: golden binds
                // such an object in the body exactly as it binds an int_var
                // (§ foreachLoopVarObjs9's registration test at the return).
                bool res22 = shadowFormal22;
                // A SUBROUTINE-LOCAL fixed-size unpacked array hands its whole
                // array_typespec to the loop variable — shared, not drilled —
                // which makes the variable an array_var. Module-scope arrays,
                // queues and dynamic arrays all keep the element form below
                // (probes r10c4_p4/p5/p6: `task t; int tq[5]; foreach(tq[i])`
                // yields array_var, `int lq[$]` yields int_var).
                if (arrSym && !foreachUnres9)
                    if (auto lat9 = tfLocalArrayTs9.find(arrSym);
                        lat9 != tfLocalArrayTs9.end()) {
                        lts = lat9->second;
                        lv = s.MakeArray_var();
                    }
                // § foreachLocalArrayVar20 — the QUEUE / DYNAMIC-array half of
                // the same rule (§ foreachLoopVarIsRefTs19 as pass 19 ranked
                // it).  Surelog does NOT drill for a subroutine local: its
                // declaration carries the array_typespec, and
                // getSimpleVarFromTypespec's uhdmarray_typespec arm
                // (CompileType.cpp:220) makes an ARRAY_VAR out of it whenever
                // there is no Index_typespec to recurse into.  So every
                // non-associative local — fixed, queue or dynamic, and whatever
                // the element type — gets an array_var loop variable sharing
                // the declaration's own object.
                //
                // The pass-19 note deferred this because the recorded r10c4 pin
                // said `int lq[$]` yields an int_var.  The purpose-built matrix
                // refutes that pin outright: tools/probe/r10uvm20repro/t31
                // `task tone; int lq[$]; foreach (lq[i])` gives golden
                // `array_var array_typespec''` in BOTH views, and t30 shows the
                // same for all four element types (int, string, class handle,
                // struct) over queue, dynamic AND fixed.  What the pin really
                // saw is the FUNCTION-local case: t31's `function int fone; int
                // rq[$];` loses the unsized dimension at declaration time (its
                // local is a bare int_var, which we already reproduce), so
                // there is no array_typespec to read and the loop variable is
                // an int_var for that reason alone.  Keying off the emitted
                // DECLARATION (arrayVarArrayTs) rather than off the slang type
                // therefore answers both cells with one lookup.
                if (!lv && arrSym && !foreachUnres9 && tfLocalArr20)
                    if (auto avt20 = arrayVarArrayTs.find(arrSym);
                        avt20 != arrayVarArrayTs.end() && avt20->second &&
                        avt20->second->UhdmType() ==
                            UHDM::uhdmarray_typespec &&
                        !((UHDM::array_typespec*)avt20->second)
                             ->Index_typespec()) {
                        lts = avt20->second;
                        lv = s.MakeArray_var();
                    }
                // § foreachClassPropArrayVar21 — the CLASS-PROPERTY half of
                // § foreachLocalArrayVar20, now that § classPropUnitImport21
                // supplies the gate pass 20 could not find.  A property that is
                // a queue / dynamic / fixed array hands `decodeHierPath` an
                // array_typespec with no Index_typespec, and
                // getSimpleVarFromTypespec's `else` arm (CompileType.cpp:220)
                // mints a FRESH, EMPTY array_typespec inside a new array_var —
                // it does NOT share the declaration's object the way the
                // subroutine-local arm above does, which is why golden prints
                // `array_var array_typespec''` for a property whose own
                // reference is still an unsupported_typespec.
                if (!lv && classPropRes21)
                    if (auto* pdt21 = arrSym->getDeclaredType()) {
                        auto k21 = pdt21->getType().getCanonicalType().kind;
                        if (k21 == SymbolKind::QueueType ||
                            k21 == SymbolKind::DynamicArrayType ||
                            k21 == SymbolKind::FixedSizeUnpackedArrayType) {
                            lts = s.MakeArray_typespec();
                            lv = s.MakeArray_var();
                        }
                        // § foreachClassPropStringVar22 — and a resolving
                        // property that is a plain `string` is iterated over
                        // its CHARACTERS: getSimpleVarFromTypespec of a
                        // string_typespec is a string_var, where we answered
                        // the bare int default.  uvm_component::get_depth's
                        // `foreach (m_name[i])` over `protected string m_name`
                        // is the corpus site (4, all in views we emit); t33e
                        // pins it directly, bare and `this.`-prefixed alike.
                        else if (k21 == SymbolKind::StringType) {
                            lts = s.MakeString_typespec();
                            lv = s.MakeString_var();
                            res22 = true;
                        }
                    }
                if (!lv)
                    lts = (arrSym && !foreachUnres9) ? makeTypespec(*arrSym)
                                                     : nullptr;
                // The loop variable takes the array's ELEMENT type, so an
                // array typespec is drilled through (Surelog's
                // getSimpleVarFromTypespec recurses the same way).
                while (!lv && lts && lts->UhdmType() == UHDM::uhdmarray_typespec) {
                    auto* ert = ((UHDM::array_typespec*)lts)->Elem_typespec();
                    if (!ert || !ert->Actual_typespec())
                        break;
                    lts = ert->Actual_typespec();
                }
                // § foreachAssocIndexVar19 — an ASSOCIATIVE array's loop
                // variable is its INDEX, not its element (LRM 12.7.3): golden
                // types `foreach (m_children[i])` over
                // `uvm_component m_children[string]` as a string_var and
                // `foreach (m_maps[map])` over `bit m_maps[uvm_reg_map]` as a
                // class_var NAMED for the key class, where the classPropArr9
                // note above leaves us the int default.  The earlier r10c4
                // probes could not see this: an `int q[$]`'s element type and
                // the int fallback are the same object kind.
                //
                // For a CLASS PROPERTY the index rule fires exactly when
                // § classPropUnitImport21 says the property resolves at all —
                // the same one gate that decides the array_var arm above, and
                // for the same reason: both are `getSimpleVarFromTypespec` of
                // whatever `decodeHierPath` returned, an `[string]` property
                // recursing into its Index_typespec where a queue has none.
                // This REPLACES § foreachAssocIdxImporterView19 ("some other
                // package wildcard-imports the home package"), which described
                // SeqDriver's adpcm_pkg correctly but was only coincidentally
                // right about the other three: BuildUVMPkg has no importing
                // package at all and its golden resolves 23 string_var + 107
                // class_var that the old gate withheld.  The ARRAY reference
                // stays the unresolved unsupported_typespec either way.
                // § foreachAssocIdxLocalOnly20 — and the index rule is a
                // SUBROUTINE-LOCAL one.  Pass 19 applied it to every resolved
                // associative array; the t30/t31 matrix shows golden drills to
                // the ELEMENT for the two declarations that do not carry the
                // array_typespec themselves: a FORMAL (`ref int fa[string]` ->
                // int_var, `ref Cel ca[string]` -> class_var 'Cel') and a
                // MODULE variable (`Cel m_a_cls[string]` -> class_var, `int
                // m_a_int[string]` -> int_var).  Only a subroutine local hands
                // getSimpleVarFromTypespec an array_typespec with an
                // Index_typespec to recurse into.  The class-property arm keeps
                // its own gate (§ classPropUnitImport21).
                bool assocIdx19 =
                    !lv && arrSym != nullptr && (foreachUnres9 || tfLocalArr20);
                if (assocIdx19 && foreachUnres9)
                    assocIdx19 = classPropRes21;
                if (assocIdx19)
                    if (auto* adt19 = arrSym->getDeclaredType()) {
                        auto& ac19 = adt19->getType().getCanonicalType();
                        if (ac19.kind == SymbolKind::AssociativeArrayType)
                            if (auto* ix19 =
                                    ac19.as<AssociativeArrayType>().indexType) {
                                auto& ick19 = ix19->getCanonicalType();
                                if (ick19.kind == SymbolKind::StringType)
                                    lts = s.MakeString_typespec();
                                else if (ick19.kind == SymbolKind::ClassType) {
                                    auto* cts19 = s.MakeClass_typespec();
                                    cts19->VpiName(ick19.name);
                                    if (auto* cd19 = classDefnFor(ick19))
                                        cts19->Class_defn(cd19);
                                    else
                                        pendingClassTsLink.push_back(
                                            {cts19, &ick19});
                                    lts = cts19;
                                }
                                // § foreachAssocIdxAliasTs22 — the index rule is
                                // not limited to `[string]` and `[<class>]`.
                                // getSimpleVarFromTypespec is handed whatever
                                // typespec the INDEX TYPE compiled to, so an
                                // index written as a TYPEDEF NAME resolves to
                                // that typedef's own emitted object and the loop
                                // variable takes the var class UHDM's mapping
                                // gives it: `uvm_reg_map_addr_range` (a struct)
                                // -> struct_var, `uvm_reg_addr_t` (a bit vector)
                                // -> bit_var, each carrying the typedef's
                                // typespec BY NAME.  sharedAliasTs is the
                                // Type-keyed lookup that already backs
                                // assocIndexTs for the DECLARATION's
                                // vpiIndexTypespec, so the loop variable and the
                                // declaration agree by construction.  Only kinds
                                // varForTypespec maps are taken; anything else
                                // still falls back to the int default rather
                                // than registering an unmappable loop variable.
                                else if (auto* sh22 = sharedAliasTs(*ix19);
                                         sh22 && varForTypespec(s, sh22))
                                    lts = sh22;
                                else
                                    assocIdx19 = false;
                            }
                            else
                                assocIdx19 = false;
                        else
                            assocIdx19 = false;
                    }
                    else
                        assocIdx19 = false;
                if (!lv)
                    lv = lts ? varForTypespec(s, lts) : nullptr;
                if (!lv) {
                    lv = s.MakeInt_var();
                    lts = s.MakeInt_typespec();
                }
                lv->VpiName(name);
                lv->VpiFullName(joinRef(prefix, lvn));
                lv->VpiParent(fs);
                setLoc(lv, span);
                auto* lrt = s.MakeRef_typespec();
                lrt->VpiFullName(joinRef(prefix, lvn));
                lrt->VpiParent(lv);
                lrt->Actual_typespec(lts);
                lv->Typespec(lrt);
                lvars->push_back(lv);
                openForeachVars[lvn] = lv;
                declaredHere.push_back(lvn);
                // Only the INT_VAR shape is registered as bindable.  Widening
                // it to every resolved kind is measurably wrong: on SeqDriver
                // that bound 161 string_var, 99 bit_var and 56 logic_var refs
                // golden leaves alone (its own loop-variable object there is
                // an unresolved ref_var — 2112 of them, residue R-lv), while
                // the int_var population went from 72 short to exact.
                // ...and the § foreachAssocIndexVar19 shape binds too: once the
                // loop variable is the resolved INDEX object, golden's body
                // references bind it exactly as they bind an int_var (235
                // class_var + 41 string_var `golden vs <null>` rows appeared
                // the moment the kind stopped being int_var, and nothing else
                // moved).
                // ...and so does the § foreachLocalArrayVar20 shape: the
                // moment the non-associative loop variable stopped being the
                // drilled element var, 283 `array_var vs <null>` rows appeared
                // — golden binds the array_var object in the body exactly as
                // it binds an int_var.
                return (lv->UhdmType() == UHDM::uhdmint_var ||
                        lv->UhdmType() == UHDM::uhdmarray_var || assocIdx19 ||
                        res22)
                           ? lv
                           : nullptr;
            };
            // § foreachLoopVarObjs9 — a body reference to a foreach LOOP
            // VARIABLE binds the object the loop lists in vpiLoopVars, but
            // ONLY where that object is the RESOLVED one: measured on repro
            // q3 (one `foreach (a[i]) s = s + a[i] + i` compiled four ways),
            // the ELABORATED package listing binds its int_var while the
            // un-elaborated listing and a class method — the two that list an
            // unresolved ref_var — bind nothing, and a module body binds the
            // implicit wire Surelog mints instead (ExprEmit's Iterator arm,
            // which already matched).  So only the resolved arm registers;
            // the unresolved and nested-relist arms deliberately return null.
            std::vector<std::pair<const slang::ast::Symbol*, UHDM::any*>>
                lvSaved9;
            for (auto* sel : foldedIdx) {
                auto& esy = sel->as<syntax::ElementSelectSyntax>();
                const syntax::ExpressionSyntax* ie =
                    esy.selector && esy.selector->kind == syntax::SyntaxKind::BitSelect
                        ? &*esy.selector->as<syntax::BitSelectSyntax>().expr
                        : nullptr;
                if (ie && ie->kind == syntax::SyntaxKind::IdentifierName) {
                    auto tok = ie->as<syntax::IdentifierNameSyntax>().identifier;
                    declLoopVar(tok.valueText(), tok.range());
                }
                else {
                    auto* op = s.MakeOperation();
                    op->VpiOpType(vpiNullOp);
                    lvars->push_back(op);
                }
            }
            size_t dimIdx = 0;
            for (auto& ld : fe.loopDims) {
                if (!ld.loopVar) {
                    // Surelog locates the placeholder at the comma PRECEDING
                    // the empty slot.
                    auto* op = s.MakeOperation();
                    op->VpiOpType(vpiNullOp);
                    if (ll && dimIdx > 0) {
                        auto& lvl = ll->loopVariables;
                        if (size_t sep = dimIdx * 2 - 1; sep < lvl.getChildCount())
                            if (auto ch = lvl.getChild(sep); ch.isToken())
                                setLoc(op, ch.range());
                    }
                    lvars->push_back(op);
                    dimIdx++;
                    continue;
                }
                if (auto* lvo9 = declLoopVar(
                        ld.loopVar->name,
                        nameSpan(ld.loopVar->location, ld.loopVar->name))) {
                    auto pit9 = foreachLoopVarObjs9.find(ld.loopVar);
                    lvSaved9.push_back(
                        {ld.loopVar, pit9 == foreachLoopVarObjs9.end()
                                         ? nullptr
                                         : pit9->second});
                    foreachLoopVarObjs9[ld.loopVar] = lvo9;
                }
                dimIdx++;
            }
            fs->VpiLoopVars(lvars);

            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(fe.body, fs, prefix, netMap))
                    fs->VpiStmt(b);
            }
            for (auto& n : declaredHere)
                openForeachVars.erase(n);
            for (auto& [sy9, prev9] : lvSaved9) {
                if (prev9)
                    foreachLoopVarObjs9[sy9] = prev9;
                else
                    foreachLoopVarObjs9.erase(sy9);
            }
            return fs;
        }
        case StatementKind::Conditional: {
            auto& cs = stmt.as<ConditionalStatement>();
            if (cs.conditions.size() != 1 || cs.conditions[0].pattern) {
                noteUnsupported("complex if condition");
                return nullptr;
            }
            // Surelog parents the condition expression at the if's enclosing
            // scope, not the if statement itself.
            if (cs.ifFalse) {
                auto* ie = s.MakeIf_else();
                ie->VpiParent(parent);
                setLoc(ie, stmt.sourceRange);
                if (cs.check == UniquePriorityCheck::Unique)
                    ie->VpiQualifier(vpiUniqueQualifier);
                else if (cs.check == UniquePriorityCheck::Priority)
                    ie->VpiQualifier(vpiPriorityQualifier);
                bool sCM9 = classMethodNoBind;
                classMethodNoBind = false; // condition refs DO bind
                UHDM::any* c = nullptr;
                {   // § refVarLocalWindowBinds5 — WINDOW SITE 1 of 3
                    CondWindow5 cw5(condBindDepth5);
                    c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap);
                }
                classMethodNoBind = sCM9;
                if (c)
                    ie->VpiCondition((UHDM::expr*)c);
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* t = emitStmt(cs.ifTrue, ie, prefix, netMap))
                    ie->VpiStmt(t);
                if (auto* f = emitStmt(*cs.ifFalse, ie, prefix, netMap))
                    ie->VpiElseStmt(f);
                return ie;
            }
            auto* is = s.MakeIf_stmt();
            is->VpiParent(parent);
            setLoc(is, stmt.sourceRange);
            if (cs.check == UniquePriorityCheck::Unique)
                is->VpiQualifier(vpiUniqueQualifier);
            else if (cs.check == UniquePriorityCheck::Priority)
                is->VpiQualifier(vpiPriorityQualifier);
            bool sCM8 = classMethodNoBind;
            classMethodNoBind = false; // condition refs DO bind
            UHDM::any* c8 = nullptr;
            {   // § refVarLocalWindowBinds5 — WINDOW SITE 2 of 3
                CondWindow5 cw5(condBindDepth5);
                c8 = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap);
            }
            classMethodNoBind = sCM8;
            if (c8)
                is->VpiCondition((UHDM::expr*)c8);
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* t = emitStmt(cs.ifTrue, is, prefix, netMap))
                    is->VpiStmt(t);
            }
            return is;
        }
        case StatementKind::ForLoop: {
            auto& fl = stmt.as<ForLoopStatement>();
            // § genProcParamFold — the whole for-stmt (header included) is a
            // no-fold region for an elab gen-scope process's module-param
            // refs; procForDepth covers only the body.
            struct ForAllGuard9 {
                int& d;
                ~ForAllGuard9() { d--; }
            } forAll9{++procForAllDepth9};
            auto* fs = s.MakeFor_stmt();
            fs->VpiParent(parent);
            fs->VpiFullName(prefix);
            // Surelog anchors the for_stmt at the "for" keyword alone.
            setLoc(fs, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 3));

            if (!fl.loopVars.empty() && fl.initializers.empty()) {
                // `for (integer a=0, integer b=0; ...)` declares SEVERAL typed
                // loop vars; each gets its own vpiForInitStmt assignment, in
                // declaration order (ForLoop).  The single-var case is just
                // this loop with one iteration.
                auto* inits = s.MakeAnyVec();
                for (auto* lv : fl.loopVars) {
                    auto& ct = lv->getType().getCanonicalType();
                    // A 4-state `logic`/`reg` loop variable, scalar or packed
                    // vector (`for (logic [31:0] i = 0; ...)`), is a logic_var
                    // bound to the declaration's logic_typespec — Surelog
                    // (CrossFunc myFunc2).
                    bool logicLoopVar = false;
                    {
                        const Type* lf0 = &ct;
                        while (lf0->getCanonicalType().kind ==
                               SymbolKind::PackedArrayType)
                            lf0 = &lf0->getCanonicalType()
                                       .as<PackedArrayType>()
                                       .elementType;
                        auto& lfc0 = lf0->getCanonicalType();
                        logicLoopVar = lfc0.kind == SymbolKind::ScalarType &&
                                       lfc0.isFourState();
                    }
                    bool intLoopVar =
                        ct.kind == SymbolKind::PredefinedIntegerType;
                    // § classLoopVar11 — a for-header loop variable of ANY
                    // other type used to abort the WHOLE for statement
                    // (`noteUnsupported` + return nullptr), so the header, the
                    // condition, the increment and the entire body vanished
                    // from our model.  The UVM callback-iteration idiom
                    //     for (uvm_reg_cbs cb = cbs.first(); cb != null;
                    //          cb = cbs.next())
                    // (uvm_reg_field.svh:1135 and ~60 more sites, plus every
                    // `uvm_vreg`/`uvm_reg_cbs` twin) is exactly that shape,
                    // which is why golden emitted 244 `hier_path[ref_obj cbs,
                    // method_func_call first]` where we emitted 4: the calls
                    // were never reached, not mis-shaped.  Surelog compiles
                    // the declaration with the ordinary statement-scope
                    // variable factory, so the loop variable takes the same
                    // object kind a subroutine local would (class_var for a
                    // directly-named class, ref_var through a typedef alias
                    // per aliasClassRefVar10, string_var, enum_var, ...) and
                    // the init assignment keeps the existing shape.  Verified
                    // on repro t1: class-typed and string-typed headers, with
                    // a call initialiser and with a `null` initialiser.
                    // Deliberately ADDITIVE — the integral/logic arms below
                    // are byte-for-byte what they were, so no loop that
                    // already emitted can change kind.
                    UHDM::variables* v =
                        logicLoopVar ? (UHDM::variables*)s.MakeLogic_var()
                        : !intLoopVar
                            ? makeReturnVar(s, lv->getType())
                        : ct.as<PredefinedIntegerType>().integerKind ==
                                PredefinedIntegerType::Integer
                            ? (UHDM::variables*)s.MakeInteger_var()
                            : (UHDM::variables*)s.MakeInt_var();
                    if (!v) {
                        noteUnsupported("for loop var type");
                        return nullptr;
                    }
                    if (intLoopVar && !logicLoopVar)
                        v->VpiSigned(ct.as<PredefinedIntegerType>().isSigned);
                    // § atomVarSignedWritten68, site 6 of 7 — a FOR-HEADER loop
                    // variable (arm a1 t_for).  This arm does NOT go through
                    // makeReturnVar for an integer atom (`intLoopVar` mints the
                    // var itself and the line above stamps the flag off the
                    // CANONICAL type, which is precisely the typedef-piercing
                    // this law forbids), so the clear is applied to whatever the
                    // arm produced.
                    clearNamedAtomSigned68(v, lv->getType());
                    v->VpiName(lv->name);
                    v->VpiFullName(joinRef(prefix, lv->name));
                    setLoc(v, SourceRange(lv->location, lv->location + lv->name.size()));
                    auto* ts = makeTypespec(*lv);
                    if (pkgScopeInst)
                        ts->Instance(pkgScopeInst);
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(joinRef(prefix, lv->name));
                    rt->VpiParent(v);
                    rt->Actual_typespec(ts);
                    v->Typespec(rt);
                    netMap[lv] = v;

                    auto* init = s.MakeAssignment();
                    init->VpiParent(fs);
                    v->VpiParent(init);
                    // Init spans the type through the initializer expression --
                    // and from the `var` keyword when the declaration has one
                    // (`for (var integer a=0; ...)`), which slang keeps on the
                    // enclosing ForVariableDeclarationSyntax, not the type.
                    if (auto declared = lv->getDeclaredType()) {
                        if (auto tsyn = declared->getTypeSyntax()) {
                            auto end = lv->getSyntax() ? lv->getSyntax()->sourceRange().end()
                                                       : stmt.sourceRange.end();
                            auto start = tsyn->sourceRange().start();
                            if (auto* lsyn = lv->getSyntax()) {
                                if (syntax::SyntaxNode* par = lsyn->parent.get()) {
                                    if (par->kind ==
                                            syntax::SyntaxKind::ForVariableDeclaration &&
                                        par->as<syntax::ForVariableDeclarationSyntax>()
                                            .varKeyword)
                                        start = par->sourceRange().start();
                                }
                            }
                            setLoc(init, SourceRange(start, end));
                        }
                    }
                    init->Lhs((UHDM::expr*)(UHDM::any*)v);
                    if (auto ie = lv->getInitializer()) {
                        forceConstParent = true;
                        if (auto* r = emitExpr(*ie, init, prefix, netMap))
                            init->Rhs(r);
                        forceConstParent = false;
                    }
                    inits->push_back(init);
                }
                fs->VpiForInitStmts(inits);
            }
            else if (!fl.initializers.empty() && fl.loopVars.empty()) {
                // Externally-declared loop vars use the SINGULAR init/inc
                // fields; the init assignment drops opType/blocking and its
                // Lhs is an unbound ref_var.
                if (fl.initializers.size() == 1 &&
                    fl.initializers[0]->kind == ExpressionKind::Assignment) {
                    auto& iae = fl.initializers[0]->as<AssignmentExpression>();
                    auto* asn = s.MakeAssignment();
                    asn->VpiParent(fs);
                    setLoc(asn, fl.initializers[0]->sourceRange);
                    auto& lhs = stripImplicitConv(iae.left());
                    if (lhs.kind == ExpressionKind::NamedValue) {
                        auto& lnv = lhs.as<NamedValueExpression>();
                        auto* rv = s.MakeRef_var();
                        rv->VpiName(lnv.symbol.name);
                        rv->VpiFullName(joinRef(prefix, lnv.symbol.name));
                        rv->VpiParent(asn);
                        setLoc(rv, lhs.sourceRange);
                        asn->Lhs((UHDM::expr*)(UHDM::any*)rv);
                    }
                    bool forceSaved = forceConstParent;
                    forceConstParent = true;
                    if (auto* r = emitExpr(iae.right(), asn, prefix, netMap))
                        asn->Rhs(r);
                    forceConstParent = forceSaved;
                    auto* inits = s.MakeAnyVec();
                    inits->push_back(asn);
                    fs->VpiForInitStmts(inits);
                }
                else {
                    auto* inits = s.MakeAnyVec();
                    for (auto ie : fl.initializers) {
                        if (auto* u = emitExpr(*ie, fs, prefix, netMap))
                            inits->push_back(u);
                    }
                    fs->VpiForInitStmts(inits);
                }
            }
            else {
                noteUnsupported("for init form");
            }

            std::vector<const Symbol*> ctrlSyms;
            for (auto* lv2 : fl.loopVars)
                ctrlSyms.push_back(lv2);
            for (auto init2 : fl.initializers)
                if (init2->kind == ExpressionKind::Assignment) {
                    auto& il2 = stripImplicitConv(
                        init2->as<AssignmentExpression>().left());
                    if (il2.kind == ExpressionKind::NamedValue)
                        ctrlSyms.push_back(
                            &il2.as<NamedValueExpression>().symbol);
                }
            // Active BEFORE condition/inc emission — elab gen-instance
            // condition/inc refs bind the loop var too (hier_path).
            for (auto* cs2 : ctrlSyms)
                activeForVars.insert(cs2);
            if (fl.stopExpr) {
                if (auto* c = emitExpr(*fl.stopExpr, fs, prefix, netMap))
                    fs->VpiCondition((UHDM::expr*)c);
            }
            if (!fl.steps.empty()) {
                auto* incs = s.MakeAnyVec();
                for (auto st : fl.steps) {
                    if (auto* u = emitExpr(*st, fs, prefix, netMap))
                        incs->push_back(u);
                }
                fs->VpiForIncStmts(incs);
            }
            procForDepth++;
            {
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* b = emitStmt(fl.body, fs, prefix, netMap))
                    fs->VpiStmt(b);
            }
            procForDepth--;
            for (auto* cs2 : ctrlSyms)
                activeForVars.erase(cs2);
            return fs;
        }
        case StatementKind::Case: {
            auto& cs = stmt.as<CaseStatement>();
            auto* uc = s.MakeCase_stmt();
            uc->VpiParent(parent);
            setLoc(uc, stmt.sourceRange);
            // (* full_case/parallel_case *) attributes anchor the case at
            // the case keyword and attach attribute objects.
            if (auto attrs = comp.getAttributes(stmt); !attrs.empty()) {
                if (stmt.syntax && stmt.syntax->kind == syntax::SyntaxKind::CaseStatement) {
                    auto kw = stmt.syntax->as<syntax::CaseStatementSyntax>().caseKeyword;
                    if (kw.valid())
                        setLoc(uc, SourceRange(kw.location(), stmt.sourceRange.end()));
                }
                auto* av = s.MakeAttributeVec();
                for (auto a : attrs) {
                    auto* ua = s.MakeAttribute();
                    ua->VpiName(a->name);
                    if (auto asyn = a->getSyntax())
                        setLoc(ua, asyn->sourceRange());
                    ua->VpiParent(uc);
                    av->push_back(ua);
                }
                uc->Attributes(av);
            }
            switch (cs.check) {
                case UniquePriorityCheck::Unique:
                    uc->VpiQualifier(vpiUniqueQualifier);
                    break;
                case UniquePriorityCheck::Priority:
                    uc->VpiQualifier(vpiPriorityQualifier);
                    break;
                default:
                    break;
            }
            switch (cs.condition) {
                case CaseStatementCondition::Normal:
                    uc->VpiCaseType(vpiCaseExact);
                    break;
                case CaseStatementCondition::WildcardXOrZ:
                    uc->VpiCaseType(vpiCaseX);
                    break;
                case CaseStatementCondition::WildcardJustZ:
                    uc->VpiCaseType(vpiCaseZ);
                    break;
                case CaseStatementCondition::Inside:
                    // case-inside prints as a plain exact case (Surelog).
                    uc->VpiCaseType(vpiCaseExact);
                    break;
                default:
                    noteUnsupported("case condition kind");
                    break;
            }
            // Like if conditions, the case condition parents at the
            // enclosing scope — but FOLDED condition constants parent at
            // the case_stmt itself.
            bool sCM7 = classMethodNoBind;
            classMethodNoBind = false; // condition refs DO bind
            UHDM::any* c7 = nullptr;
            {   // § refVarLocalWindowBinds5 — WINDOW SITE 3 of 3
                CondWindow5 cw5(condBindDepth5);
                c7 = emitExpr(cs.expr, parent, prefix, netMap);
            }
            classMethodNoBind = sCM7;
            if (c7) {
                if (c7->UhdmType() == UHDM::uhdmconstant)
                    ((UHDM::constant*)c7)->VpiParent(uc);
                uc->VpiCondition((UHDM::expr*)c7);
            }

            // Item location comes from the case-item syntax (covers the
            // expressions through the trailing semicolon).
            auto itemLoc = [&](const Statement& st, UHDM::BaseClass* obj) {
                for (auto p = st.syntax ? st.syntax->parent : nullptr; p; p = p->parent) {
                    if (p->kind == syntax::SyntaxKind::StandardCaseItem ||
                        p->kind == syntax::SyntaxKind::DefaultCaseItem) {
                        setLoc(obj, p->sourceRange());
                        return;
                    }
                    if (p->kind == syntax::SyntaxKind::CaseStatement)
                        break;
                }
                setLoc(obj, st.sourceRange);
            };

            auto* items = s.MakeCase_itemVec();
            // The DEFAULT arm keeps its SOURCE position in the item list
            // (Surelog walks the case items as written); slang hands it back
            // separately from `items`, so splice it back in by location.
            // A `default:` written FIRST leads the list (YosysBigSimReed's
            // BM_lamda `case (Step) default: ... Step2: ...`).
            bool defDone9 = false;
            auto emitDefault9 = [&]() {
                if (defDone9 || !cs.defaultCase)
                    return;
                defDone9 = true;
                auto* it = s.MakeCase_item();
                it->VpiParent(uc);
                itemLoc(*cs.defaultCase, it);
                CtrlBody28 cb28(ctrlBodyDepth28);
                if (auto* st = emitStmt(*cs.defaultCase, it, prefix, netMap))
                    it->Stmt(st);
                items->push_back(it);
            };
            for (auto& g : cs.items) {
                if (cs.defaultCase && !defDone9 && g.stmt->syntax &&
                    cs.defaultCase->syntax &&
                    cs.defaultCase->syntax->sourceRange().start() <
                        g.stmt->syntax->sourceRange().start())
                    emitDefault9();
                auto* it = s.MakeCase_item();
                it->VpiParent(uc);
                itemLoc(*g.stmt, it);
                auto* exprs = s.MakeAnyVec();
                if (cs.condition == CaseStatementCondition::Inside) {
                    // case-inside item: ONE inside-op spanning the whole item
                    // list; each member wraps in a list-op (ranges already are).
                    auto* oi = s.MakeOperation();
                    oi->VpiOpType(vpiInsideOp);
                    oi->VpiParent(it);
                    if (!g.expressions.empty())
                        setLoc(oi, SourceRange(g.expressions.front()->sourceRange.start(),
                                               g.expressions.back()->sourceRange.end()));
                    auto* iops = s.MakeAnyVec();
                    for (auto e : g.expressions) {
                        // A bare constant member carries NO parent (it nests in
                        // the wrapping list-op); range bounds re-force their own.
                        bool scp3 = suppressConstParent;
                        suppressConstParent = true;
                        auto* ue = emitExpr(*e, oi, prefix, netMap);
                        suppressConstParent = scp3;
                        if (!ue)
                            continue;
                        if (ue->UhdmType() == UHDM::uhdmoperation &&
                            ((UHDM::operation*)ue)->VpiOpType() == vpiListOp) {
                            ((UHDM::operation*)ue)->VpiParent(oi);
                            iops->push_back(ue);
                        }
                        else {
                            auto* ol = s.MakeOperation();
                            ol->VpiOpType(vpiListOp);
                            ol->VpiParent(oi);
                            setLoc(ol, e->sourceRange);
                            auto* one = s.MakeAnyVec();
                            one->push_back(ue);
                            ol->Operands(one);
                            iops->push_back(ol);
                        }
                    }
                    oi->Operands(iops);
                    exprs->push_back(oi);
                }
                else
                // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW SITE 4.
                // A case ITEM EXPRESSION is a binding window on exactly the
                // same terms as the case CONDITION, and the shipped patch
                // raised the window only for the condition.  Measured golden,
                // out-of-body methods, arm v3/v5:
                //   v3 w01 45:7/45:11  a MULTI-expression item, d0==d0  BIND
                //   v3 w02 55:7  casex item, d0==d0                     BIND
                //   v3 w03 65:7  casez item, d0==d0                     BIND
                //   v3 w04 75:7  unique-case item, d0==d0               BIND
                //   v3 w13 154:8 item that is an OPERATION `(uw + 1)`   BIND
                //   v3 w06 99:9  item in a block that also DECLARES it,
                //                d1==d1                                 BIND
                //   v5 z09 104:14 nested case, decl d1 read d1          BIND
                //   v3 w05 86:9  case one control body DEEPER than decl bare
                //   v5 z05 66:11 case TWO bodies deeper than the decl   bare
                // so the depth half of the law is unchanged; only the position
                // was missing.  `case (x) inside` is DELIBERATELY excluded —
                // it is the other arm of this `if` and golden leaves its item
                // members BARE (arm v4 y06 69:7, decl d0 read d0), which is
                // why the window is raised here and not around both arms.
                for (auto e : g.expressions) {
                    CondWindow5 cw5(condBindDepth5);
                    if (auto* ue = emitExpr(*e, it, prefix, netMap)) {
                        // Case-item expr refs and calls parent at the
                        // enclosing scope (constants stay at the case_item).
                        if (ue->UhdmType() == UHDM::uhdmref_obj ||
                            ue->UhdmType() == UHDM::uhdmsys_func_call ||
                            ue->UhdmType() == UHDM::uhdmfunc_call)
                            ((UHDM::expr*)ue)->VpiParent(parent);
                        exprs->push_back(ue);
                    }
                }
                it->VpiExprs(exprs);
                {
                    CtrlBody28 cb28(ctrlBodyDepth28);
                    if (auto* st = emitStmt(*g.stmt, it, prefix, netMap))
                        it->Stmt(st);
                }
                items->push_back(it);
            }
            emitDefault9();
            uc->Case_items(items);
            return uc;
        }
        // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW SITE 5 of 6, three
        // spellings.  An IMMEDIATE ASSERTION's condition is a binding window
        // on the same terms as an if condition; the shipped patch left it out.
        // Measured golden, out-of-body methods, arms v4/v5:
        //   v4 y03 45:13 `assert (vy != null) …; else …`, d0==d0      BIND
        //   v4 y01 33:13 `assume (vy != null) …`, d0==d0              BIND
        //   v4 y02 39:12 `cover  (vy != null) …`, d0==d0              BIND
        //   v4 y05 60:15 assert whose block DECLARES vy, d1==d1       BIND
        //   v5 z07 85:13 / z08 92:13 the same, d0==d0                 BIND
        //   v4 y04 52:15 assert one control body DEEPER than the decl bare
        //   v5 z06 77:15 assert inside a `for` body, decl at d0       bare
        //   v4 y10 96:18 assert inside a case ITEM, decl at d0        bare
        // The ACTION BLOCK is NOT a window and is left alone: v5 z07 85:41 and
        // z08 93:26 read `uz` from the action / else-action block as a CALL
        // ARGUMENT and golden binds them through § classArgBind12's window,
        // before and after — which is also why the action block must not be
        // given a CtrlBody28 it does not have.
        case StatementKind::ImmediateAssertion: {
            auto& ia = stmt.as<ImmediateAssertionStatement>();
            UHDM::any* ua = nullptr;
            UHDM::expr* cond = nullptr;
            switch (ia.assertionKind) {
                case AssertionKind::Assert: {
                    auto* a = s.MakeImmediate_assert();
                    a->VpiParent(parent);
                    setLoc(a, stmt.sourceRange);
                    // `assert #0 (...)` / `assert final (...)`: Surelog stamps
                    // the deferred/final qualifier on the immediate_assert.
                    if (ia.isDeferred)
                        a->VpiIsDeferred(1);
                    if (ia.isFinal)
                        a->VpiIsFinal(1);
                    // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW SITE 5.
                    if (auto* c = [&] {
                            CondWindow5 cw5(condBindDepth5);
                            return emitExpr(ia.cond, a, prefix, netMap);
                        }())
                        a->Expr((UHDM::expr*)c);
                    if (ia.ifTrue) {
                        if (auto* t = emitStmt(*ia.ifTrue, a, prefix, netMap))
                            a->Stmt(t);
                    }
                    if (ia.ifFalse) {
                        if (auto* f = emitStmt(*ia.ifFalse, a, prefix, netMap))
                            a->Else_stmt(f);
                    }
                    ua = a;
                    break;
                }
                case AssertionKind::Assume: {
                    auto* a = s.MakeImmediate_assume();
                    a->VpiParent(parent);
                    setLoc(a, stmt.sourceRange);
                    if (ia.isDeferred)
                        a->VpiIsDeferred(1);
                    if (ia.isFinal)
                        a->VpiIsFinal(1);
                    // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW SITE 5.
                    if (auto* c = [&] {
                            CondWindow5 cw5(condBindDepth5);
                            return emitExpr(ia.cond, a, prefix, netMap);
                        }())
                        a->Expr((UHDM::expr*)c);
                    if (ia.ifTrue) {
                        if (auto* t = emitStmt(*ia.ifTrue, a, prefix, netMap))
                            a->Stmt(t);
                    }
                    if (ia.ifFalse) {
                        if (auto* f = emitStmt(*ia.ifFalse, a, prefix, netMap))
                            a->Else_stmt(f);
                    }
                    ua = a;
                    break;
                }
                case AssertionKind::CoverProperty: {
                    auto* a = s.MakeImmediate_cover();
                    a->VpiParent(parent);
                    setLoc(a, stmt.sourceRange);
                    if (ia.isDeferred)
                        a->VpiIsDeferred(1);
                    if (ia.isFinal)
                        a->VpiIsFinal(1);
                    // V-FIX vbuvm5 — § refVarLocalWindowBinds5 WINDOW SITE 5.
                    if (auto* c = [&] {
                            CondWindow5 cw5(condBindDepth5);
                            return emitExpr(ia.cond, a, prefix, netMap);
                        }())
                        a->Expr((UHDM::expr*)c);
                    if (ia.ifTrue) {
                        if (auto* t = emitStmt(*ia.ifTrue, a, prefix, netMap))
                            a->Stmt(t);
                    }
                    ua = a;
                    break;
                }
                default:
                    noteUnsupported("assertion kind");
                    return nullptr;
            }
            (void)cond;
            return ua;
        }
        case StatementKind::Return: {
            auto& rs = stmt.as<ReturnStatement>();
            auto* r = s.MakeReturn_stmt();
            r->VpiParent(parent);
            // Keyword-only span, expr as vpiCondition.
            setLoc(r, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 6));
            if (rs.expr) {
                // Def-view package compile pre-creates the param-ts clone
                // the top copy's fold will reference.
                if (pkgScopeInst && !pkgTopEmit && currentSubSym &&
                    !foldCloneTs.count(currentSubSym)) {
                    auto cf0 = resolveConstExpr(*rs.expr);
                    if (cf0.param) {
                        auto* its0 = makeParamTs(*cf0.param, /*typedParam=*/true);
                        if (auto sc0 = cf0.param->getParentScope())
                            if (auto pit0 = pkgDefMap.find(&sc0->asSymbol());
                                pit0 != pkgDefMap.end())
                                its0->Instance(pit0->second);
                        foldCloneTs[currentSubSym] = its0;
                    }
                }
                // Top-view package re-emission folds constant returns.
                if (pkgTopEmit) {
                    auto cf = resolveConstExpr(*rs.expr);
                    // A called sub's param-backed fold is reused verbatim.
                    if (cf.directSub && foldedRet.count(cf.directSub)) {
                        r->VpiCondition(foldedRet[cf.directSub]);
                        return r;
                    }
                    if (cf.param) {
                        // Constant at the ref site, parented at the DEF
                        // param_assign, ts ref naming the package with a
                        // fresh param-ts clone.
                        auto& ps2 = *cf.param;
                        auto& cv2 = ps2.getValue();
                        if (cv2.isInteger() && !cv2.integer().hasUnknown()) {
                            auto& iv2 = cv2.integer();
                            bool neg2 = iv2.isSigned() && iv2.isNegative();
                            std::string digits2 =
                                iv2.toString(LiteralBase::Decimal, false);
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(digits2);
                            c->VpiSize((int32_t)ps2.getType().getBitWidth());
                            c->VpiValue((neg2 ? "INT:" : "UINT:") + digits2);
                            c->VpiConstType(neg2 ? vpiIntConst : vpiUIntConst);
                            setLoc(c, cf.site->sourceRange);
                            if (auto pit = pkgParamConst.find(&ps2);
                                pit != pkgParamConst.end())
                                c->VpiParent(pit->second->VpiParent());
                            auto* rt2 = s.MakeRef_typespec();
                            std::string pkgName;
                            if (auto sc2 = ps2.getParentScope())
                                pkgName = std::string(sc2->asSymbol().name);
                            rt2->VpiFullName(pkgName);
                            rt2->VpiParent(c);
                            c->Typespec(rt2);
                            UHDM::typespec* its2 = nullptr;
                            if (currentSubSym)
                                if (auto fit = foldCloneTs.find(currentSubSym);
                                    fit != foldCloneTs.end())
                                    its2 = fit->second;
                            if (!its2) {
                                its2 = makeParamTs(ps2, /*typedParam=*/true);
                                if (auto sc2 = ps2.getParentScope())
                                    if (auto pit2 = pkgDefMap.find(&sc2->asSymbol());
                                        pit2 != pkgDefMap.end())
                                        its2->Instance(pit2->second);
                            }
                            its2->VpiParent(rt2);
                            rt2->Actual_typespec(its2);
                            if (currentSubSym)
                                foldedRet[currentSubSym] = c;
                            r->VpiCondition(c);
                            return r;
                        }
                    }
                    if (cf.lit) {
                        if (auto* e = emitExpr(*cf.lit, r, prefix, netMap)) {
                            r->VpiCondition((UHDM::expr*)e);
                            return r;
                        }
                    }
                }
                if (auto* e = emitExpr(*rs.expr, r, prefix, netMap)) {
                    r->VpiCondition((UHDM::expr*)e);
                    // § retUnbasedSizing — an UNBASED-UNSIZED return literal is
                    // sized to the FUNCTION RETURN TYPE and loses its QUOTE:
                    // the decompile becomes the digit repeated to the width, a
                    // BIN constant.  A WRITTEN unbased-unsized elsewhere keeps
                    // the quote (`assign o = '0` stays decompile "'0" even
                    // where its size is set) — the return context is what drops
                    // it.  Purpose-built golden (repro t9.sv, one module):
                    //   function logic [3:0] f(); return '1;  -> BIN:1111 sz 4
                    //   function logic       g(); return '1;  -> BIN:1    sz 1
                    //   assign o = '0; (o 4-bit)              -> "'0"    sz 4
                    //   assign p = '1; (p 1-bit)              -> "'1"    sz -1
                    // Rggen: rggen_adapter_common's `pre_decode` else-arm
                    // `return '1`, 9 vectors.
                    // ...and it is a MODULE-function rule only: a PACKAGE
                    // function's `return '1;` keeps the raw literal at size -1
                    // in BOTH package views, however the function is called
                    // (w.sv rows H/I — one function reached as a continuous
                    // assignment's DIRECT rhs, its twin only under an
                    // operation; golden reads `'1`/-1 for both, in
                    // uhdmallPackages and uhdmtopPackages alike).  pkgScopeInst
                    // is set exactly for a package's own (non-class)
                    // subroutines, in both views.
                    auto& rl9 = stripImplicitConv(*rs.expr);
                    if (rl9.kind ==
                            ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                        !pkgScopeInst &&
                        e->UhdmType() == UHDM::uhdmconstant && rs.expr->type &&
                        rs.expr->type->isIntegral()) {
                        logic_t b9 = rl9.as<UnbasedUnsizedIntegerLiteral>()
                                         .getLiteralValue();
                        int32_t w9 = (int32_t)rs.expr->type->getBitWidth();
                        if (!b9.isUnknown() && w9 > 0) {
                            std::string dg9((size_t)w9, b9.value ? '1' : '0');
                            auto* c9 = (UHDM::constant*)e;
                            c9->VpiDecompile(dg9);
                            c9->VpiSize(w9);
                            c9->VpiValue("BIN:" + dg9);
                            c9->VpiConstType(vpiBinaryConst);
                        }
                    }
                }
            }
            return r;
        }
        case StatementKind::Break: {
            auto* b = s.MakeBreak_stmt();
            b->VpiParent(parent);
            // Surelog spans the keyword only, not the semicolon.
            setLoc(b, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 5));
            return b;
        }
        case StatementKind::Continue: {
            auto* c = s.MakeContinue_stmt();
            c->VpiParent(parent);
            setLoc(c, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 8));
            return c;
        }
        case StatementKind::List: {
            // Declaration-bearing lists (function bodies): decls with
            // initializers become leading assignment stmts; two or more
            // effective stmts get an unnamed begin wrapper.
            auto& sl = stmt.as<StatementList>();
            // A CLASS CONSTRUCTOR body is not compiled by this arm's model at
            // all — see emitCtorBody27.
            if (tfBodyCtor27 && tfBodyStmt9 == (const void*)&stmt)
                return emitCtorBody27(stmt, parent, prefix, netMap);
            std::vector<const VariableSymbol*> declVars;
            std::vector<const Statement*> real;
            size_t initCount = 0;
            for (auto st : sl.list) {
                if (st->kind == StatementKind::VariableDeclaration) {
                    auto& vs = st->as<VariableDeclStatement>().symbol;
                    declVars.push_back(&vs);
                    if (vs.getDeclaredType()->getInitializer())
                        initCount++;
                    continue;
                }
                real.push_back(st);
            }
            // A subroutine BODY whose declarations are BLOCK items (see
            // tfBodyTfItems9) always models them inside a synthesized `begin`,
            // even when a SINGLE statement follows — Surelog wraps
            // `int t; return a;` exactly like `int t; x=1; x=2;`. A body with
            // no statement at all takes no wrapper (`task t; int u; endtask`
            // keeps a bare task), and a TF-ITEM body keeps the two-statement
            // threshold it has always had.
            bool bodyBlockDecls9 = tfBodyStmt9 == (const void*)&stmt &&
                                   !tfBodyTfItems9 && !declVars.empty();
            // Task-scope parameters are body statements (see tfBodyPa9), so
            // they force the wrapper too: `task t; parameter p = 1; x = 1;
            // endtask` dumps begin[param_assign, assignment] where the
            // parameter-free twin dumps the bare assignment. A body with no
            // statement at all still takes none — the param_assign then stays
            // parented at the task (probe r10c4_p2 B).
            bool bodyParams9 =
                tfBodyStmt9 == (const void*)&stmt && !tfBodyPa9.empty();
            // A TF-ITEM subroutine body: its locals belong to the subroutine,
            // so a wrapper begin here neither lists nor owns them.
            bool bodyTfItems9 =
                tfBodyStmt9 == (const void*)&stmt && tfBodyTfItems9;
            size_t eff9 = initCount + real.size();
            if (eff9 == 0 || (eff9 <= 1 && !bodyBlockDecls9 && !bodyParams9)) {
                UHDM::any* result = nullptr;
                for (auto st : real) {
                    // § thisSuperNewAssignNoStmt3 — CALL SITE 3 of 5: a
                    // single-effective-statement list takes NO wrapper, so
                    // dropping the element here is what makes a subroutine
                    // whose WHOLE body is the assignment come out with no
                    // vpiStmt at all — golden's shape in arms a1 m4/m8/m9,
                    // a2 n3/n4/n5/n8 and a3 p1/p3.  A CONSTRUCTOR body never
                    // reaches this line: the arm returns to emitCtorBody27
                    // above, which is exactly the exception a4's `new` cell
                    // measured (golden KEEPS the drop inside a constructor).
                    if (thisSuperNewAssignNoStmt3(*st))
                        continue;
                    if (auto* u = emitStmt(*st, parent, prefix, netMap))
                        result = u;
                }
                return result;
            }
            auto* ub = s.MakeBegin();
            ub->VpiFullName(prefix);
            ub->VpiParent(parent);
            // Anchored at the SECOND source item (decls count as items). A
            // DECLARATION item spans its whole declaration statement — type
            // keyword through semicolon (`op32_r_t t_op ;`, rp32 enc32) — not
            // the declarator alone, which is all slang's statement range is.
            const syntax::SyntaxNode* anch9 = nullptr;
            if (sl.list.size() >= 2 &&
                sl.list[1]->kind == StatementKind::VariableDeclaration)
                if (auto* dsyn9 = sl.list[1]
                                      ->as<VariableDeclStatement>()
                                      .symbol.getSyntax())
                    if (dsyn9->parent && dsyn9->parent->kind ==
                                             syntax::SyntaxKind::DataDeclaration)
                        anch9 = dsyn9->parent;
            // A BLOCK item's own statement range covers the body only; the
            // wrapper anchors at the whole `begin..end` region (t_noio).
            if (!anch9 && sl.list.size() >= 2 &&
                sl.list[1]->kind == StatementKind::Block && sl.list[1]->syntax)
                anch9 = sl.list[1]->syntax;
            // The item list the "second item" is counted over is the LRM
            // one, so it excludes a TF-ITEM body's local declarations (they
            // are tf_item_declarations, not block items) and includes
            // task-scope parameter declarations, which Surelog turns into
            // body statements. Probe r10c4_p3: `task A; input B; integer B;
            // integer internal; internal = 1; B = internal; endtask` anchors
            // its begin at the SECOND ASSIGNMENT, stepping over the local —
            // while the block-item twin (no body io) still anchors at its
            // second item counting the local. TaskDecls and r10c4_p2 C are
            // the parameter-bearing halves of the same rule.
            if (bodyParams9 || bodyTfItems9) {
                std::vector<SourceRange> items9;
                if (bodyParams9)
                    for (auto& pr9 : tfBodyPaAnchor9)
                        if (pr9.start())
                            items9.push_back(pr9);
                for (auto st9 : sl.list) {
                    if (st9->kind == StatementKind::VariableDeclaration) {
                        if (bodyTfItems9)
                            continue;
                        if (auto* dsyn0 = st9->as<VariableDeclStatement>()
                                              .symbol.getSyntax())
                            if (dsyn0->parent &&
                                dsyn0->parent->kind ==
                                    syntax::SyntaxKind::DataDeclaration) {
                                items9.push_back(dsyn0->parent->sourceRange());
                                continue;
                            }
                    }
                    items9.push_back(st9->syntax ? st9->syntax->sourceRange()
                                                 : st9->sourceRange);
                }
                std::stable_sort(items9.begin(), items9.end(),
                                 [](const SourceRange& a, const SourceRange& b) {
                                     return a.start() < b.start();
                                 });
                setLoc(ub, items9.size() >= 2 ? items9[1] : items9[0]);
            }
            else if (anch9)
                setLoc(ub, anch9->sourceRange());
            else if (sl.list.size() >= 2)
                setLoc(ub, sl.list[1]->sourceRange);
            else
                setLoc(ub, stmt.sourceRange);
            auto* bvars = s.MakeVariablesVec();
            bool pkgCtx = prefix.find("::") != std::string::npos;
            for (auto* vsym : declVars)
                if (auto it = netMap.find(vsym);
                    it != netMap.end() && !bodyTfItems9) {
                    // Block-item locals (and package-scope locals, whose
                    // shape has always been the block one) re-parent at the
                    // wrapper: it is their declaring scope. A TF-ITEM body's
                    // locals stay with the subroutine and are not listed here
                    // at all (probe r10c4_p3).
                    if (pkgCtx || bodyBlockDecls9)
                        it->second->VpiParent(ub);
                    // An unpacked-array local ALSO lists its element reg
                    // (int_var) as a sibling BEFORE the array_var.
                    if (it->second->UhdmType() == UHDM::uhdmarray_var) {
                        auto* av = (UHDM::array_var*)it->second;
                        if (av->Variables() && !av->Variables()->empty())
                            bvars->push_back((*av->Variables())[0]);
                    }
                    bvars->push_back((UHDM::variables*)it->second);
                }
            if (!bvars->empty())
                ub->Variables(bvars);
            auto* stmts = s.MakeAnyVec();
            // Task-scope param_assigns LEAD the block and re-parent to it
            // (they stay listed under the task as vpiParamAssign too).
            if (bodyParams9) {
                for (auto* pa9 : tfBodyPa9) {
                    pa9->VpiParent(ub);
                    stmts->push_back(pa9);
                }
                tfBodyPaUsed9 = true;
            }
            for (auto* vsym : declVars) {
                auto* init = vsym->getDeclaredType()->getInitializer();
                if (!init)
                    continue;
                // § declInitWrittenNewNoStmt66 — CALL SITE 2 of 2: THE HEAD'S
                // SITE.  A SUBROUTINE BODY's statement list.  `initCount` above
                // deliberately still counts this declaration, so the wrapper
                // begin is built and anchored exactly as before and an
                // all-dropped body comes out as golden's EMPTY begin (a2 n07);
                // only the list APPEND is skipped, which also leaves the
                // variable on the vpiParent the wrapper loop above gave it.
                if (declInitWrittenNewNoStmt66(*vsym))
                    continue;
                auto* as = s.MakeAssignment();
                as->VpiParent(ub);
                as->VpiOpType(vpiAssignmentOp);
                as->VpiBlocking(true);
                if (auto syn = vsym->getSyntax())
                    setLoc(as, syn->sourceRange());
                if (auto it = netMap.find(vsym); it != netMap.end()) {
                    auto* v = (UHDM::variables*)it->second;
                    v->VpiParent(as);
                    as->Lhs((UHDM::expr*)v);
                }
                if (auto* r = emitExpr(*init, as, prefix, netMap))
                    as->Rhs((UHDM::expr*)r);
                stmts->push_back(as);
            }
            for (auto st : real) {
                // § thisSuperNewAssignNoStmt3 — CALL SITE 4 of 5: THE SVSwitch
                // SITE.  `byte_unpack`'s body is a 8-element statement list and
                // `this.data = new[bytes.size - 4];` is element [4]; golden's
                // list has 7 elements and ours had 8, which is the vector-SIZE
                // mismatch uhdm-cmp reports as the whole head.  A CONSTRUCTOR
                // body cannot reach here (emitCtorBody27 above).
                if (thisSuperNewAssignNoStmt3(*st))
                    continue;
                if (auto* u = emitStmt(*st, ub, prefix, netMap))
                    stmts->push_back(u);
            }
            ub->Stmts(stmts);
            return ub;
        }
        case StatementKind::ConcurrentAssertion: {
            // Procedural `assert property (...)`: an assert_stmt statement
            // whose property_spec wraps the property expression.
            auto& ca = stmt.as<ConcurrentAssertionStatement>();
            // `expect (@(posedge clk) a ##1 b);` is NOT a concurrent_assertion
            // in UHDM: it is an atomic_stmt (`expect_stmt`) carrying the same
            // property_spec, and — unlike assert/assume/cover — it takes NO
            // vpiFullName (ExpectStmt).
            if (ca.assertionKind == AssertionKind::Expect) {
                auto* ex9 = s.MakeExpect_stmt();
                ex9->VpiParent(parent);
                setLoc(ex9, SourceRange(stmt.sourceRange.start(),
                                        stmt.sourceRange.end() -
                                            basedLiteralSpaceCount(
                                                rawText(stmt.sourceRange))));
                if (ca.ifFalse)
                    if (auto* st9 = emitStmt(*ca.ifFalse, ex9, prefix, netMap))
                        ex9->Stmt(st9);
                auto* ps9 = s.MakeProperty_spec();
                ps9->VpiParent(ex9);
                if (ca.propertySpec.syntax) {
                    auto pr9 = ca.propertySpec.syntax->sourceRange();
                    setLoc(ps9,
                           SourceRange(pr9.start(),
                                       pr9.end() - basedLiteralSpaceCount(
                                                       rawText(pr9))));
                }
                const AssertionExpr* pe9 = &ca.propertySpec;
                if (pe9->kind == AssertionExprKind::Clocking) {
                    auto& clk9 = pe9->as<ClockingAssertionExpr>().clocking;
                    pe9 = &pe9->as<ClockingAssertionExpr>().expr;
                    if (auto* ce9 = emitEventExpr(clk9, ps9, prefix, netMap))
                        ps9->VpiClockingEvent((UHDM::expr*)ce9);
                }
                if (auto* pb9 = emitAssertionExpr(*pe9, ps9, prefix, netMap))
                    ps9->VpiPropertyExpr(pb9);
                ex9->Property_spec(ps9);
                return ex9;
            }
            UHDM::concurrent_assertions* as = nullptr;
            switch (ca.assertionKind) {
                case AssertionKind::Assert:
                    as = s.MakeAssert_stmt();
                    break;
                case AssertionKind::Assume:
                    as = s.MakeAssume();
                    break;
                case AssertionKind::CoverProperty:
                case AssertionKind::CoverSequence:
                    as = s.MakeCover();
                    break;
                case AssertionKind::Restrict:
                    as = s.MakeRestrict();
                    break;
                default:
                    noteUnsupported("assertion kind: " +
                                    std::string(toString(ca.assertionKind)));
                    return nullptr;
            }
            as->VpiFullName(prefix);
            as->VpiParent(parent);
            setLoc(as, SourceRange(stmt.sourceRange.start(),
                                   stmt.sourceRange.end() -
                                       basedLiteralSpaceCount(
                                           rawText(stmt.sourceRange))));
            if (ca.ifFalse)
                if (auto* st = emitStmt(*ca.ifFalse, as, prefix, netMap))
                    as->Stmt(st);
            auto* ps = s.MakeProperty_spec();
            ps->VpiParent(as);
            if (ca.propertySpec.syntax) {
                auto pr = ca.propertySpec.syntax->sourceRange();
                setLoc(ps, SourceRange(pr.start(),
                                       pr.end() -
                                           basedLiteralSpaceCount(rawText(pr))));
            }
            const AssertionExpr* pe = &ca.propertySpec;
            const TimingControl* clocking = nullptr;
            if (pe->kind == AssertionExprKind::Clocking) {
                clocking = &pe->as<ClockingAssertionExpr>().clocking;
                pe = &pe->as<ClockingAssertionExpr>().expr;
            }
            if (ca.assertionKind == AssertionKind::Assert && clocking) {
                if (auto* clk = emitEventExpr(*clocking, ps, prefix, netMap))
                    ps->VpiPropertyExpr(clk);
            }
            else {
                if (clocking)
                    if (auto* clk = emitEventExpr(*clocking, ps, prefix, netMap))
                        ps->VpiClockingEvent((UHDM::expr*)clk);
                if (auto* pbody = emitAssertionExpr(*pe, ps, prefix, netMap))
                    ps->VpiPropertyExpr(pbody);
            }
            as->VpiProperty(ps);
            return as;
        }
        // § waitStmt11 — `wait (cond) [stmt];` is a `wait_stmt` carrying the
        // condition and, when the wait guards one, the guarded statement.
        // There was no arm at all, so the wait AND everything it guarded
        // vanished (uvm_objection / uvm_sequence_base / uvm_resource:
        // 22 source sites, and a task whose whole body is a `wait` lost its
        // body outright — repro t3 w_plain/w_block, byte-identical after).
        case StatementKind::Wait: {
            auto& ws = stmt.as<WaitStatement>();
            auto* w = s.MakeWait_stmt();
            w->VpiParent(parent);
            setLoc(w, stmt.sourceRange);
            if (auto* c = emitExpr(ws.cond, w, prefix, netMap))
                w->VpiCondition(c);
            if (auto* inner = emitStmt(ws.stmt, w, prefix, netMap))
                w->VpiStmt(inner);
            return w;
        }
        // § waitFork11 — `wait fork;` is a bare `wait_fork` object with no
        // fields at all (repro t3 w_fork: golden's fork/join_none begin held
        // TWO statements, ours only the fork).
        case StatementKind::WaitFork: {
            auto* w = s.MakeWait_fork();
            w->VpiParent(parent);
            setLoc(w, stmt.sourceRange);
            return w;
        }
        case StatementKind::Empty:
            return nullptr;
        // § droppedCall14 — slang REJECTED this statement and handed back an
        // InvalidStatement; the reference tool accepted it.  Re-emit from the
        // SYNTAX (see emitInvalidStmt14).
        case StatementKind::Invalid: {
            if (auto* r14 = emitInvalidStmt14(stmt, parent, prefix, netMap))
                return r14;
            // § invalidChild14 — a compound statement is bad when ANY of its
            // parts is, and slang hands the PARTIALLY BUILT statement back as
            // the InvalidStatement's `child` (`badStmt(comp, result)`), fully
            // populated apart from the one bad part.  So `if (req_imp == null)
            // $cast(req_imp, imp);` — where the comparison is against an
            // unspecialized type parameter — still carries its condition
            // operands and its whole true branch, and the reference tool emits
            // exactly the shape that partial tree describes.  Re-entering
            // emitStmt on the child recovers it; emitExpr already does the
            // same for `InvalidExpression::child`, so the bad LEAF is the only
            // thing that can still go missing.  29 conditional sites on
            // SeqDriver (`UVM_MS_IMP_COMMON`, uvm_misc, uvm_pool,
            // uvm_registry, uvm_tlm2_sockets); repro
            // `tools/probe/r10uvm14repro/t18`.
            if (auto* ch14 = stmt.as<InvalidStatement>().child;
                ch14 && ch14->kind != StatementKind::Invalid)
                return emitStmt(*ch14, parent, prefix, netMap);
            noteUnsupportedAt(
                "statement kind: Invalid/" +
                    std::string(stmt.syntax ? toString(stmt.syntax->kind)
                                            : "<nosyntax>"),
                stmt.syntax ? stmt.syntax->sourceRange().start()
                            : stmt.sourceRange.start());
            return nullptr;
        }
        default:
            noteUnsupportedAt("statement kind: " + std::string(toString(stmt.kind)),
                              stmt.syntax ? stmt.syntax->sourceRange().start()
                                          : stmt.sourceRange.start());
            return nullptr;
    }
}

// § droppedCall14 — a call on a handle whose declared type is an UNSPECIALIZED
// type PARAMETER.  `class impc #(type IMP = int); IMP m_imp; ... m_imp.put(a);`
// binds `m_imp` as the default `int` in slang, which has no member `put`, so
// the expression is bad and the WHOLE statement comes back as
// `StatementKind::Invalid` and was dropped.  The reference tool does no such
// check at this level: it emits the very same dotted-call shapes `emitExpr`
// already produces for a VALID dotted call, so the missing piece is a
// SYNTAX-driven re-entry, not a new model.  133 sites on SeqDriver (82 of them
// the `UVM_*_IMP` macro bodies in `tlm1/uvm_imps.svh`, whose whole body is one
// `imp.method(arg);` or `return imp.method(arg);`).
//
// Deliberately narrow: the receiver must be a plain identifier and every
// argument a plain identifier or a plain dotted pair.  Anything else falls
// through to the caller's note so the residue stays visible and measurable
// instead of being emitted in a guessed shape (repros
// `tools/probe/r10uvm13repro/t17`, `tools/probe/r10uvm14repro/t19`).
//
// `a.b` in EXPRESSION position parses as a ScopedName with a DOT separator
// (slang keeps `::` and `.` in one node), so the receiver is the scoped name's
// LEFT and the method its RIGHT -- not a MemberAccessExpression.
static const slang::syntax::ScopedNameSyntax* droppedCallShape14(
    const slang::syntax::ExpressionSyntax& e) {
    if (e.kind != syntax::SyntaxKind::InvocationExpression)
        return nullptr;
    auto& inv = e.as<syntax::InvocationExpressionSyntax>();
    if (inv.left->kind != syntax::SyntaxKind::ScopedName)
        return nullptr;
    auto& sn = inv.left->as<syntax::ScopedNameSyntax>();
    if (sn.separator.kind != slang::parsing::TokenKind::Dot)
        return nullptr;
    if (sn.left->kind != syntax::SyntaxKind::IdentifierName ||
        sn.right->kind != syntax::SyntaxKind::IdentifierName)
        return nullptr;
    if (sn.left->as<syntax::IdentifierNameSyntax>().identifier.valueText().empty() ||
        sn.right->as<syntax::IdentifierNameSyntax>().identifier.valueText().empty())
        return nullptr;
    // Every actual must be a plain identifier or a plain DOTTED pair (see
    // above); anything with a literal, a select or an operator in it is left
    // to the caller's note.
    if (inv.arguments)
        for (auto* a : inv.arguments->parameters) {
            if (a->kind != syntax::SyntaxKind::OrderedArgument)
                return nullptr;
            auto* ae = connActualSyntax(a->as<syntax::OrderedArgumentSyntax>().expr);
            if (!ae)
                return nullptr;
            if (ae->kind == syntax::SyntaxKind::IdentifierName)
                continue;
            if (ae->kind != syntax::SyntaxKind::ScopedName)
                return nullptr;
            auto& asn = ae->as<syntax::ScopedNameSyntax>();
            if (asn.separator.kind != slang::parsing::TokenKind::Dot ||
                asn.left->kind != syntax::SyntaxKind::IdentifierName ||
                asn.right->kind != syntax::SyntaxKind::IdentifierName)
                return nullptr;
        }
    return &sn;
}

// The dropped call's ACTUAL, in the one name scope § droppedCall14 established
// (`argPfx`): a plain identifier is a ref_obj named after it, a dotted pair is
// a hier_path over two ref_objs whose LEAF alone carries the scoped fullname
// (the base stays name-only) -- measured on `first.copy(rhs_.first)` in BOTH
// positions (repro `tools/probe/r10uvm14repro/t19`).
UHDM::any* UhdmExporter::emitDroppedArg14(const syntax::ExpressionSyntax& ae,
                                          UHDM::BaseClass* parent,
                                          const std::string& argPfx,
                                          NetMap& netMap, bool bind) {
    if (ae.kind == syntax::SyntaxKind::IdentifierName) {
        std::string an(ae.as<syntax::IdentifierNameSyntax>().identifier.valueText());
        auto* ar = s.MakeRef_obj();
        ar->VpiName(an);
        ar->VpiFullName(joinRef(argPfx, an));
        ar->VpiParent(parent);
        setLoc(ar, ae.sourceRange());
        if (bind && currentSubSym)
            if (auto* sym = currentSubSym->find(an))
                if (auto it = netMap.find(sym); it != netMap.end())
                    ar->Actual_group(it->second);
        return ar;
    }
    auto& asn = ae.as<syntax::ScopedNameSyntax>();
    std::string ab(asn.left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
    std::string al(asn.right->as<syntax::IdentifierNameSyntax>().identifier.valueText());
    auto* ahp = s.MakeHier_path();
    ahp->VpiName(ab + "." + al);
    ahp->VpiFullName(ab + "." + al);
    ahp->VpiParent(parent);
    setLoc(ahp, ae.sourceRange());
    auto* aels = s.MakeAnyVec();
    auto* a0 = s.MakeRef_obj();
    a0->VpiName(ab);
    a0->VpiFullName(ab); // name-only
    a0->VpiParent(ahp);
    setLoc(a0, asn.left->sourceRange());
    aels->push_back(a0);
    auto* a1 = s.MakeRef_obj();
    a1->VpiName(al);
    a1->VpiFullName(joinRef(argPfx, al));
    a1->VpiParent(ahp);
    setLoc(a1, asn.right->sourceRange());
    aels->push_back(a1);
    ahp->Path_elems(aels);
    return ahp;
}

UHDM::any* UhdmExporter::emitDroppedCall14(const syntax::ExpressionSyntax& e,
                                           UHDM::BaseClass* parent,
                                           const std::string& prefix,
                                           NetMap& netMap, bool stmtCtx) {
    const auto* sn = droppedCallShape14(e);
    if (!sn)
        return nullptr;
    auto& inv = e.as<syntax::InvocationExpressionSyntax>();
    auto methTok = sn->right->as<syntax::IdentifierNameSyntax>().identifier;
    std::string base(
        sn->left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
    std::string meth(methTok.valueText());
    SourceRange baseRng = sn->left->sourceRange();
    SourceRange methRng = nameSpan(methTok.location(), meth);

    // STATEMENT position: a bare method_func_call named after the METHOD,
    // spanned at the method identifier, whose vpiPrefix is an UNBOUND ref to
    // the receiver; the arguments are ordinary refs and DO bind their io_decl
    // (the same ClassArgBind12 window a valid class-method call opens).
    if (stmtCtx) {
        auto* mfc = s.MakeMethod_func_call();
        mfc->VpiName(meth);
        mfc->VpiParent(parent);
        setLoc(mfc, methRng);
        auto* pr = s.MakeRef_obj();
        pr->VpiName(base);
        pr->VpiFullName(joinRef(prefix, base));
        pr->VpiParent(mfc);
        setLoc(pr, baseRng);
        mfc->Prefix(pr);
        auto* args = s.MakeAnyVec();
        if (inv.arguments)
            for (auto* a : inv.arguments->parameters)
                args->push_back(emitDroppedArg14(
                    *connActualSyntax(a->as<syntax::OrderedArgumentSyntax>().expr),
                    mfc, prefix, netMap, /*bind=*/true));
        if (!args->empty())
            mfc->Tf_call_args(args);
        return mfc;
    }

    // EXPRESSION position: a hier_path named `<recv>.<method>` spanning the
    // WHOLE call, over a name-only ref_obj for the receiver plus a
    // method_func_call carrying the arguments.  The hier_path opens a NAME
    // SCOPE: each argument ref is UNBOUND and its fullname nests under the
    // path's own name (`p1::impc::try_put::m_imp.try_put::arg`).
    std::string dotted = base + "." + meth;
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    setLoc(hp, e.sourceRange());
    auto* elems = s.MakeAnyVec();
    auto* r0 = s.MakeRef_obj();
    r0->VpiName(base);
    r0->VpiFullName(base); // name-only (the dump omits an equal fullname)
    r0->VpiParent(hp);
    setLoc(r0, baseRng);
    elems->push_back(r0);
    auto* mfc = s.MakeMethod_func_call();
    mfc->VpiName(meth);
    mfc->VpiParent(hp);
    setLoc(mfc, methRng);
    auto* args = s.MakeAnyVec();
    if (inv.arguments)
        for (auto* a : inv.arguments->parameters)
            args->push_back(emitDroppedArg14(
                *connActualSyntax(a->as<syntax::OrderedArgumentSyntax>().expr),
                mfc, joinRef(prefix, dotted), netMap, /*bind=*/false));
    if (!args->empty())
        mfc->Tf_call_args(args);
    elems->push_back(mfc);
    hp->Path_elems(elems);
    return hp;
}

// slang leaves an invocation's Expression with a NULL `syntax` pointer
// (`Expression::create` refuses to overwrite it there, for let-decl expansion),
// and the RECEIVER it hands back as the Invalid node's child has none either.
// So the only way back to the call text is the enclosing STATEMENT's syntax:
// find the invocation whose callee starts exactly where that receiver does.
const syntax::ExpressionSyntax* UhdmExporter::findDroppedCallAt14(
    const syntax::SyntaxNode& root, slang::SourceLocation loc) {
    if (root.kind == syntax::SyntaxKind::InvocationExpression) {
        auto& inv = root.as<syntax::InvocationExpressionSyntax>();
        if (inv.left->getFirstToken().location() == loc &&
            droppedCallShape14(root.as<syntax::ExpressionSyntax>()))
            return &root.as<syntax::ExpressionSyntax>();
    }
    for (size_t i = 0; i < root.getChildCount(); i++)
        if (auto* c = root.childNode(i))
            if (auto* r = findDroppedCallAt14(*c, loc))
                return r;
    return nullptr;
}

UHDM::any* UhdmExporter::emitInvalidStmt14(const Statement& stmt,
                                           UHDM::BaseClass* parent,
                                           const std::string& prefix,
                                           NetMap& netMap) {
    const auto* syn = stmt.syntax;
    if (!syn)
        return nullptr;
    if (syn->kind == syntax::SyntaxKind::ExpressionStatement)
        return emitDroppedCall14(*syn->as<syntax::ExpressionStatementSyntax>().expr,
                                 parent, prefix, netMap, /*stmtCtx=*/true);
    if (syn->kind == syntax::SyntaxKind::ReturnStatement) {
        auto& rs = syn->as<syntax::ReturnStatementSyntax>();
        // Shape-check BEFORE minting anything: serializer GC is off, so an
        // abandoned object would still reach the database.
        if (!rs.returnValue || !droppedCallShape14(*rs.returnValue))
            return nullptr;
        auto* r = s.MakeReturn_stmt();
        r->VpiParent(parent);
        // Keyword-only span, expr as vpiCondition (as the valid arm above).
        auto kw = rs.returnKeyword.location();
        setLoc(r, SourceRange(kw, kw + 6));
        if (auto* v = emitDroppedCall14(*rs.returnValue, r, prefix, netMap,
                                        /*stmtCtx=*/false))
            r->VpiCondition((UHDM::expr*)v);
        return r;
    }
    return nullptr;
}

} // namespace slang_uhdm
