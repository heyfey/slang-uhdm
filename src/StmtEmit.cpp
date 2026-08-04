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
        if (selWholeWrittenVars.count(wr.sym) &&
            sel->UhdmType() == UHDM::uhdmpart_select &&
            ((UHDM::part_select*)sel)->Left_range() &&
            ((UHDM::part_select*)sel)->Left_range()->UhdmType() ==
                UHDM::uhdmconstant)
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
            if (es.expr.kind == ExpressionKind::Call)
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
                // end : label
                if (stmt.syntax &&
                    stmt.syntax->kind == syntax::SyntaxKind::SequentialBlockStatement)
                    if (auto* ebn = stmt.syntax->as<syntax::BlockStatementSyntax>()
                                        .endBlockName) {
                        if (!isFork)
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
            // Block-local variable declarations become scope Variables
            // (module-scoped fullnames, no visibility flag).
            NetMap blockMap = netMap;
            std::vector<UHDM::any*> forkDeclStmts9;
            if (bs.blockSymbol) {
                auto* vars = s.MakeVariablesVec();
                for (auto& bm : bs.blockSymbol->members()) {
                    if (bm.kind != SymbolKind::Variable)
                        continue;
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
                    if (auto* qav = makeQueueDynArrayVar(bm, bfull, b)) {
                        if (auto* qregs = qav->Variables())
                            for (auto* qr : *qregs)
                                vars->push_back(qr);
                        vars->push_back(qav);
                        blockMap[&bm] = qav;
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
                        auto* ert0 = s.MakeRef_typespec();
                        ert0->VpiParent(ats0);
                        ert0->Actual_typespec(ts);
                        ats0->Elem_typespec(ert0);
                        auto* art0 = s.MakeRef_typespec();
                        art0->VpiFullName(bfull);
                        art0->VpiParent(av0);
                        art0->Actual_typespec(ats0);
                        av0->Typespec(art0);
                        auto* reg0 = makeReturnVar(s, *leaf0);
                        reg0->VpiParent(av0);
                        setLoc(reg0, nameSpan(bm.location, bm.name));
                        auto* rrt0 = s.MakeRef_typespec();
                        rrt0->VpiFullName(bfull);
                        rrt0->VpiParent(reg0);
                        rrt0->Actual_typespec(ts);
                        reg0->Typespec(rrt0);
                        if (leaf0->isSigned())
                            reg0->VpiSigned(true);
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
                        if (!v)
                            v = makeReturnVar(s,
                                              bm.getDeclaredType()->getType());
                    }
                    v->VpiName(bm.name);
                    v->VpiFullName(bfull);
                    v->VpiParent(b);
                    setLoc(v, nameSpan(bm.location, bm.name));
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(bfull);
                    rt->VpiParent(v);
                    rt->Actual_typespec(ts);
                    v->Typespec(rt);
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
                // A CLASS-HANDLE local initialized with `new()` emits
                // NO assignment at all: golden keeps only the class_var
                // (parented at the begin). Measured on `module m1;
                // class C; ... initial begin C d = new(); end` and the
                // program form — SimpleConstraint `frame_t frame =
                // new();`.
                if (init && init->kind == ExpressionKind::NewClass)
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
            if (auto* b = emitStmt(rl.body, r, prefix, netMap))
                r->VpiStmt(b);
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
            if (auto* b = emitStmt(wl.body, w, prefix, netMap))
                w->VpiStmt(b);
            return w;
        }
        case StatementKind::DoWhileLoop: {
            auto& dw = stmt.as<DoWhileLoopStatement>();
            auto* w = s.MakeDo_while();
            w->VpiParent(parent);
            setLoc(w, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 2));
            if (auto* c = emitExpr(dw.cond, w, prefix, netMap))
                w->VpiCondition((UHDM::expr*)c);
            if (auto* b = emitStmt(dw.body, w, prefix, netMap))
                w->VpiStmt(b);
            return w;
        }
        case StatementKind::ForeverLoop: {
            auto& fl = stmt.as<ForeverLoopStatement>();
            auto* f = s.MakeForever_stmt();
            f->VpiParent(parent);
            setLoc(f, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 7));
            if (auto* b = emitStmt(fl.body, f, prefix, netMap))
                f->VpiStmt(b);
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
            // A foreach over a MEMBER of a local (`foreach (path.slices[j])`)
            // lists the whole dotted reference as a hier_path, not a ref_var
            // (Surelog resolves the loop list as an expression before it
            // decides the iterated object). LocalScopeHierPath.
            bool arrMember9 =
                arrSym && fe.arrayRef.kind == ExpressionKind::MemberAccess;
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
                    arrMember9 = false;
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
                if (foreachUnres9) {
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
                if (classMethodNoBind || pkgDefViewBody9) {
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
                return lv->UhdmType() == UHDM::uhdmint_var ? lv : nullptr;
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

            if (auto* b = emitStmt(fe.body, fs, prefix, netMap))
                fs->VpiStmt(b);
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
                auto* c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap);
                classMethodNoBind = sCM9;
                if (c)
                    ie->VpiCondition((UHDM::expr*)c);
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
            auto* c8 = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap);
            classMethodNoBind = sCM8;
            if (c8)
                is->VpiCondition((UHDM::expr*)c8);
            if (auto* t = emitStmt(cs.ifTrue, is, prefix, netMap))
                is->VpiStmt(t);
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
            if (auto* b = emitStmt(fl.body, fs, prefix, netMap))
                fs->VpiStmt(b);
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
            auto* c7 = emitExpr(cs.expr, parent, prefix, netMap);
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
                for (auto e : g.expressions) {
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
                if (auto* st = emitStmt(*g.stmt, it, prefix, netMap))
                    it->Stmt(st);
                items->push_back(it);
            }
            emitDefault9();
            uc->Case_items(items);
            return uc;
        }
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
                    if (auto* c = emitExpr(ia.cond, a, prefix, netMap))
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
                    if (auto* c = emitExpr(ia.cond, a, prefix, netMap))
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
                    if (auto* c = emitExpr(ia.cond, a, prefix, netMap))
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
                    auto& rl9 = stripImplicitConv(*rs.expr);
                    if (rl9.kind ==
                            ExpressionKind::UnbasedUnsizedIntegerLiteral &&
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
                for (auto st : real)
                    if (auto* u = emitStmt(*st, parent, prefix, netMap))
                        result = u;
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
            for (auto st : real)
                if (auto* u = emitStmt(*st, ub, prefix, netMap))
                    stmts->push_back(u);
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
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
