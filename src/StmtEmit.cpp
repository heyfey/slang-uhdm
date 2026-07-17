//------------------------------------------------------------------------------
//! @file StmtEmit.cpp
//! @brief Processes, statements, event expressions
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

UHDM::process_stmt* UhdmExporter::emitProcess(const ProceduralBlockSymbol& block,
                                              UHDM::module_inst* m, const std::string& prefix,
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
        default:
            noteUnsupported("procedure kind: " + std::string(toString(block.procedureKind)));
            return nullptr;
    }

    proc->VpiParent(m);
    if (auto syntax = block.getSyntax())
        setLoc(proc, syntax->sourceRange());

    if (auto* body = emitStmt(block.getBody(), proc, prefix, netMap))
        proc->Stmt(body);
    return proc;
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
            auto* op = s.MakeOperation();
            // "a or b" -> vpiEventOrOp; "a, b" -> vpiListOp. The AST doesn't
            // keep the separator, so peek at the source between events.
            int32_t lop = vpiEventOrOp;
            if (el.events.size() >= 2) {
                auto between = rawText(SourceRange(el.events[0]->sourceRange.end(),
                                                   el.events[1]->sourceRange.start()));
                if (between.find(',') != std::string::npos)
                    lop = vpiListOp;
            }
            op->VpiOpType(lop);
            op->VpiParent(parent);
            // slang's event list range includes the parens; Surelog spans the
            // events only.
            if (!el.events.empty()) {
                setLoc(op, SourceRange(el.events.front()->sourceRange.start(),
                                       el.events.back()->sourceRange.end()));
            }
            auto* operands = s.MakeAnyVec();
            for (auto ev : el.events) {
                if (auto* e = emitEventExpr(*ev, op, prefix, netMap))
                    operands->push_back(e);
            }
            op->Operands(operands);
            return op;
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
            if (bs.blockKind != StatementBlockKind::Sequential) {
                noteUnsupported("parallel block");
                return nullptr;
            }
            // slang wraps for-loops with inline declarations in an implicit
            // block; Surelog has no such wrapper.
            if (bs.syntax && bs.syntax->kind == syntax::SyntaxKind::ForLoopStatement) {
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
            UHDM::scope* b = nullptr;
            std::string innerPrefix = prefix;
            if (bs.blockSymbol && !bs.blockSymbol->name.empty()) {
                auto* nb = s.MakeNamed_begin();
                nb->VpiName(bs.blockSymbol->name);
                innerPrefix = prefix + "." + std::string(bs.blockSymbol->name);
                nb->VpiFullName(innerPrefix);
                // Anchored at the block name token.
                auto nl = bs.blockSymbol->location;
                setLoc(nb, SourceRange(nl, nl + bs.blockSymbol->name.size()));
                b = nb;
            }
            else {
                auto* ub = s.MakeBegin();
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
            auto* stmts = s.MakeAnyVec();
            auto& body = bs.body;
            if (body.kind == StatementKind::List) {
                for (auto st : body.as<StatementList>().list) {
                    if (auto* u = emitStmt(*st, b, innerPrefix, netMap))
                        stmts->push_back(u);
                }
            }
            else if (auto* u = emitStmt(body, b, innerPrefix, netMap)) {
                stmts->push_back(u);
            }
            if (b->UhdmType() == UHDM::uhdmnamed_begin)
                ((UHDM::named_begin*)b)->Stmts(stmts);
            else
                ((UHDM::begin*)b)->Stmts(stmts);
            return b;
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
                if (auto* c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap))
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
            if (auto* c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap))
                is->VpiCondition((UHDM::expr*)c);
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
                if (ct.kind != SymbolKind::PredefinedIntegerType) {
                    noteUnsupported("for loop var type");
                    return nullptr;
                }
                auto* v = s.MakeInt_var();
                v->VpiSigned(ct.as<PredefinedIntegerType>().isSigned);
                v->VpiName(lv->name);
                v->VpiFullName(prefix + "." + std::string(lv->name));
                setLoc(v, SourceRange(lv->location, lv->location + lv->name.size()));
                auto* ts = makeTypespec(*lv);
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(lv->name));
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
                auto* inits = s.MakeAnyVec();
                for (auto ie : fl.initializers) {
                    if (auto* u = emitExpr(*ie, fs, prefix, netMap))
                        inits->push_back(u);
                }
                fs->VpiForInitStmts(inits);
            }
            else {
                noteUnsupported("for init form");
            }

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
            if (auto* b = emitStmt(fl.body, fs, prefix, netMap))
                fs->VpiStmt(b);
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
                default:
                    noteUnsupported("case condition kind");
                    break;
            }
            // Like if conditions, the case condition parents at the
            // enclosing scope.
            if (auto* c = emitExpr(cs.expr, parent, prefix, netMap))
                uc->VpiCondition((UHDM::expr*)c);

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
                for (auto e : g.expressions) {
                    if (auto* ue = emitExpr(*e, it, prefix, netMap)) {
                        // Case-item expr refs parent at the enclosing scope
                        // (constants stay parented at the case_item).
                        if (ue->UhdmType() == UHDM::uhdmref_obj)
                            ((UHDM::ref_obj*)ue)->VpiParent(parent);
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
        case StatementKind::Empty:
            return nullptr;
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
