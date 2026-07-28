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
    return true;
}

void UhdmExporter::endSelTrack() {
    for (auto& [ref, sym] : selWholeRefs) {
        if (!selLhsSelVars.count(sym))
            continue;
        auto it = selFirstSelect.find(sym);
        if (it == selFirstSelect.end())
            continue;
        // A var ALSO written whole keeps the net for PLAIN part-select
        // targets (multiple_blocking_gate) but still repoints to an
        // INDEXED part-select (multiple_blocking/sign_part_assign).
        if (selWholeWrittenVars.count(sym) &&
            it->second->UhdmType() == UHDM::uhdmpart_select)
            continue;
        ref->Actual_group(it->second);
    }
    selTrackActive = false;
    selFirstSelect.clear();
    selLhsSelVars.clear();
    selWholeRefs.clear();
    selWholeWrittenVars.clear();
}

void UhdmExporter::noteSelectObj(const slang::ast::Symbol* base, UHDM::any* selObj) {
    if (!selTrackActive || !base)
        return;
    selFirstSelect.emplace(base, (UHDM::expr*)selObj);
    if (inLhs)
        selLhsSelVars.insert(base);
}

UHDM::delay_control* UhdmExporter::emitDelayControl(const TimingControl& tc,
                                                    UHDM::BaseClass* parent) {
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
        // "#dly" / "#(expr)": the value is not a Pound_delay token, so Surelog
        // takes it as a reference under Delay(). Its name is the value node's
        // SymName — the identifier for `#dly`, EMPTY for a parenthesized
        // expression (a Mintypmax_expression node carries no name).
        std::string name = raw.substr(numStart);
        if (!name.empty() && !(isalpha((unsigned char)name[0]) || name[0] == '_' ||
                               name[0] == '\\'))
            name.clear();
        auto* ref = s.MakeRef_obj();
        ref->VpiName(name);
        ref->VpiParent(parent);
        setLoc(ref, SourceRange(dr.start() + numStart, dr.end()));
        dc->Delay(ref);
    }
    return dc;
}

UHDM::any* UhdmExporter::emitEventExpr(const TimingControl& tc, UHDM::BaseClass* parent,
                                       const std::string& prefix,
                                       NetMap& netMap) {
    switch (tc.kind) {
        case TimingControlKind::SignalEvent: {
            auto& sec = tc.as<SignalEventControl>();
            if (sec.iffCondition) {
                noteUnsupported("iff event condition");
                return nullptr;
            }
            int32_t opType = 0;
            switch (sec.edge) {
                case EdgeKind::PosEdge:
                    opType = vpiPosedgeOp;
                    break;
                case EdgeKind::NegEdge:
                    opType = vpiNegedgeOp;
                    break;
                case EdgeKind::None:
                    return emitExpr(sec.expr, parent, prefix, netMap);
                default:
                    noteUnsupported("edge kind");
                    return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, tc.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitExpr(sec.expr, op, prefix, netMap))
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
                    auto* dc = emitDelayControl(timing, parent);
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
                if (inner->kind == StatementKind::ImmediateAssertion) {
                    std::string innerPfx = joinRef(prefix, bs.blockSymbol->name);
                    auto* ua = emitStmt(*inner, parent, innerPfx, netMap);
                    if (ua) {
                        if (ua->UhdmType() == UHDM::uhdmimmediate_assert)
                            ((UHDM::immediate_assert*)ua)->VpiName(bs.blockSymbol->name);
                        else if (ua->UhdmType() == UHDM::uhdmimmediate_assume)
                            ((UHDM::immediate_assume*)ua)->VpiName(bs.blockSymbol->name);
                        else if (ua->UhdmType() == UHDM::uhdmimmediate_cover)
                            ((UHDM::immediate_cover*)ua)->VpiName(bs.blockSymbol->name);
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
                    // Block-local var typespecs keep their range bounds
                    // UNFOLDED (Surelog's procedural-decl form).
                    bool savedTf = tfContext;
                    tfContext = true;
                    auto* ts = makeTypespec(bm);
                    tfContext = savedTf;
                    if (pkgScopeInst)
                        ts->Instance(pkgScopeInst);
                    std::string bfull = innerPrefix + "." + std::string(bm.name);
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
                    UHDM::variables* v = nullptr;
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
            if (body.kind == StatementKind::List) {
                for (auto st : body.as<StatementList>().list) {
                    if (st->kind == StatementKind::VariableDeclaration) {
                        // An initialized block-local var emits a blocking
                        // assignment (var = init) at its declaration site; the
                        // var re-parents to that assignment.
                        auto& vs = st->as<VariableDeclStatement>().symbol;
                        auto* init = vs.getDeclaredType()
                                         ? vs.getDeclaredType()->getInitializer()
                                         : nullptr;
                        auto vit = blockMap.find(&vs);
                        // A CLASS-HANDLE local initialized with `new()` emits
                        // NO assignment at all: golden keeps only the class_var
                        // (parented at the begin). Measured on `module m1;
                        // class C; ... initial begin C d = new(); end` and the
                        // program form — SimpleConstraint `frame_t frame =
                        // new();`.
                        if (init && init->kind == ExpressionKind::NewClass)
                            continue;
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
                        continue;
                    }
                    if (auto* u = emitStmt(*st, b, innerPrefix, blockMap))
                        stmts->push_back(u);
                }
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
            if (arrSym) {
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
                pendingForeachArrayTs.push_back({art, arrSym, implicitNetModule});
                rv->Typespec(art);
                fs->Variable(rv);
            }

            // vpiLoopVars: one variable per NAMED dimension, whose class and
            // typespec follow the array's ELEMENT type (Surelog resolves the
            // implicit declaration from the array, not from the index use); a
            // vpiNullOp operation stands in for each SKIPPED dimension.
            std::vector<std::string> declaredHere;
            auto* lvars = s.MakeAnyVec();
            auto declLoopVar = [&](std::string_view name, SourceRange span) {
                std::string lvn(name);
                // A NESTED foreach re-lists the enclosing loop's variable
                // OBJECT rather than declaring a second one.
                if (auto oit = openForeachVars.find(lvn); oit != openForeachVars.end()) {
                    lvars->push_back(oit->second);
                    return;
                }
                UHDM::typespec* lts = arrSym ? makeTypespec(*arrSym) : nullptr;
                // The loop variable takes the array's ELEMENT type, so an
                // array typespec is drilled through (Surelog's
                // getSimpleVarFromTypespec recurses the same way).
                while (lts && lts->UhdmType() == UHDM::uhdmarray_typespec) {
                    auto* ert = ((UHDM::array_typespec*)lts)->Elem_typespec();
                    if (!ert || !ert->Actual_typespec())
                        break;
                    lts = ert->Actual_typespec();
                }
                UHDM::variables* lv = lts ? varForTypespec(s, lts) : nullptr;
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
            };
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
                declLoopVar(ld.loopVar->name,
                            nameSpan(ld.loopVar->location, ld.loopVar->name));
                dimIdx++;
            }
            fs->VpiLoopVars(lvars);

            if (auto* b = emitStmt(fe.body, fs, prefix, netMap))
                fs->VpiStmt(b);
            for (auto& n : declaredHere)
                openForeachVars.erase(n);
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
            auto* fs = s.MakeFor_stmt();
            fs->VpiParent(parent);
            fs->VpiFullName(prefix);
            // Surelog anchors the for_stmt at the "for" keyword alone.
            setLoc(fs, SourceRange(stmt.sourceRange.start(), stmt.sourceRange.start() + 3));

            if (fl.loopVars.size() == 1 && fl.initializers.empty()) {
                auto* lv = fl.loopVars[0];
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
                if (ct.kind != SymbolKind::PredefinedIntegerType &&
                    !logicLoopVar) {
                    noteUnsupported("for loop var type");
                    return nullptr;
                }
                // `for (integer x = ..)` declares an integer_var (Surelog);
                // `for (int i = ..)` an int_var.
                UHDM::variables* v =
                    logicLoopVar
                        ? (UHDM::variables*)s.MakeLogic_var()
                    : ct.as<PredefinedIntegerType>().integerKind ==
                            PredefinedIntegerType::Integer
                        ? (UHDM::variables*)s.MakeInteger_var()
                        : (UHDM::variables*)s.MakeInt_var();
                if (!logicLoopVar)
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
                // Init spans the type through the initializer expression.
                if (auto declared = lv->getDeclaredType()) {
                    if (auto tsyn = declared->getTypeSyntax()) {
                        auto end = lv->getSyntax() ? lv->getSyntax()->sourceRange().end()
                                                   : stmt.sourceRange.end();
                        setLoc(init, SourceRange(tsyn->sourceRange().start(), end));
                    }
                }
                init->Lhs((UHDM::expr*)(UHDM::any*)v);
                if (auto ie = lv->getInitializer()) {
                    forceConstParent = true;
                    if (auto* r = emitExpr(*ie, init, prefix, netMap))
                        init->Rhs(r);
                    forceConstParent = false;
                }
                auto* inits = s.MakeAnyVec();
                inits->push_back(init);
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
            for (auto& g : cs.items) {
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
            if (cs.defaultCase) {
                auto* it = s.MakeCase_item();
                it->VpiParent(uc);
                itemLoc(*cs.defaultCase, it);
                if (auto* st = emitStmt(*cs.defaultCase, it, prefix, netMap))
                    it->Stmt(st);
                items->push_back(it);
            }
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
                if (auto* e = emitExpr(*rs.expr, r, prefix, netMap))
                    r->VpiCondition((UHDM::expr*)e);
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
            if (initCount + real.size() <= 1) {
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
            if (anch9)
                setLoc(ub, anch9->sourceRange());
            else if (sl.list.size() >= 2)
                setLoc(ub, sl.list[1]->sourceRange);
            else
                setLoc(ub, stmt.sourceRange);
            auto* bvars = s.MakeVariablesVec();
            bool pkgCtx = prefix.find("::") != std::string::npos;
            for (auto* vsym : declVars)
                if (auto it = netMap.find(vsym); it != netMap.end()) {
                    // Package-scope locals re-parent at the wrapper.
                    if (pkgCtx)
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
        case StatementKind::Empty:
            return nullptr;
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
