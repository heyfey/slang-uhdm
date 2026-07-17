//------------------------------------------------------------------------------
//! @file ExprEmit.cpp
//! @brief Expressions, constant folding, value encoding
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr) {
    // Surelog's netlist elaboration re-compiles top-view cont_assign
    // expressions with constant reduction. Fold only genuine expressions,
    // not plain literals (evaluating an implicitly-converted literal can
    // also truncate through slang's 32-bit unsized literal type).
    if (stripImplicitConv(expr).kind == ExpressionKind::IntegerLiteral)
        return nullptr;
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    ConstantValue cv = ctx.tryEval(expr);
    if (!cv || !cv.isInteger())
        return nullptr;
    auto& iv = cv.integer();
    if (iv.hasUnknown() || (iv.isSigned() && iv.isNegative()))
        return nullptr;
    std::string digits = iv.toString(LiteralBase::Decimal, /*includeBase*/ false);
    auto* c = s.MakeConstant();
    c->VpiDecompile(digits);
    c->VpiSize((int32_t)expr.type->getBitWidth());
    // Surelog's reduce encodes division results (and anything referencing a
    // param whose value was so encoded) as INT; everything else as UINT.
    if (isIntEncoded(expr)) {
        c->VpiValue("INT:" + digits);
        c->VpiConstType(vpiIntConst);
    }
    else {
        c->VpiValue("UINT:" + digits);
        c->VpiConstType(vpiUIntConst);
    }
    return c;
}

bool UhdmExporter::isIntEncoded(const Expression& e) {
    switch (e.kind) {
        case ExpressionKind::Conversion:
            return e.as<ConversionExpression>().isImplicit() &&
                   isIntEncoded(e.as<ConversionExpression>().operand());
        case ExpressionKind::UnaryOp:
            return isIntEncoded(e.as<UnaryExpression>().operand());
        case ExpressionKind::BinaryOp: {
            auto& be = e.as<BinaryExpression>();
            if (be.op == BinaryOperator::Divide || be.op == BinaryOperator::Mod)
                return true;
            return isIntEncoded(be.left()) || isIntEncoded(be.right());
        }
        case ExpressionKind::NamedValue: {
            auto it = paramIntEnc.find(&e.as<NamedValueExpression>().symbol);
            return it != paramIntEnc.end() && it->second;
        }
        default:
            return false;
    }
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
            auto* asn = s.MakeAssignment();
            asn->VpiOpType(kVpiAssignmentOp);
            asn->VpiBlocking(!ae.isNonBlocking());
            asn->VpiParent(parent);
            setLoc(asn, expr.sourceRange);
            inLhs = true;
            if (auto* lhs = emitExpr(ae.left(), asn, prefix, netMap))
                asn->Lhs((UHDM::expr*)lhs);
            inLhs = false;
            if (auto* rhs = emitExpr(ae.right(), asn, prefix, netMap))
                asn->Rhs(rhs);
            // Intra-assignment delay ("state <= #1 next;").
            if (ae.timingControl && ae.timingControl->kind == TimingControlKind::Delay) {
                auto& delay = ae.timingControl->as<DelayControl>();
                auto* dc = s.MakeDelay_control();
                dc->VpiParent(asn);
                SourceRange dr = ae.timingControl->sourceRange;
                std::string raw = rawText(dr);
                if (raw.empty() || raw[0] != '#') {
                    dr = SourceRange(dr.start() - 1, dr.end());
                    raw = rawText(dr);
                }
                dc->VpiDelay(raw);
                setLoc(dc, dr);
                (void)delay;
                asn->Delay_control(dc);
            }
            return asn;
        }
        case ExpressionKind::ConditionalOp: {
            auto& cond = expr.as<ConditionalExpression>();
            if (cond.conditions.size() != 1 || cond.conditions[0].pattern) {
                noteUnsupported("complex conditional");
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConditionOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* c = emitExpr(*cond.conditions[0].expr, op, prefix, netMap))
                operands->push_back(c);
            if (auto* t = emitExpr(cond.left(), op, prefix, netMap))
                operands->push_back(t);
            if (auto* f = emitExpr(cond.right(), op, prefix, netMap))
                operands->push_back(f);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::NamedValue: {
            auto& nv = expr.as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            auto* ref = s.MakeRef_obj();
            ref->VpiName(nv.symbol.name);
            auto scope = nv.symbol.getParentScope();
            if (scope && scope->asSymbol().kind == SymbolKind::Package &&
                nv.symbol.kind == SymbolKind::Parameter) {
                // Module-side references to package params are folded inline
                // to constants carrying the reference's location.
                auto& psym = nv.symbol.as<ParameterSymbol>();
                auto& cv = psym.getValue();
                if (cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    setLoc(c, expr.sourceRange);
                    if (parent && parent->UhdmType() == UHDM::uhdmoperation)
                        c->VpiParent(parent);
                    return c;
                }
                ref->VpiFullName(std::string(scope->asSymbol().name) + "::" +
                                 std::string(nv.symbol.name));
            }
            else {
                ref->VpiFullName(prefix + "." + std::string(nv.symbol.name));
                if (auto it = netMap.find(&nv.symbol); it != netMap.end())
                    ref->Actual_group(it->second);
                else if (funcRetRefs && &nv.symbol == funcRetSym)
                    funcRetRefs->push_back(ref);
            }
            ref->VpiParent(parent);
            if (rawText(SourceRange(expr.sourceRange.start(), expr.sourceRange.start() + 1)) ==
                "\\")
                setLoc(ref, nameSpan(expr.sourceRange.start(), nv.symbol.name));
            else
                setLoc(ref, expr.sourceRange);
            return ref;
        }
        case ExpressionKind::UnaryOp: {
            auto& ue = expr.as<UnaryExpression>();
            int32_t opType = mapUnaryOp(ue.op);
            if (!opType) {
                noteUnsupported("unary op: " + std::string(toString(ue.op)));
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitExpr(ue.operand(), op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::BinaryOp: {
            auto& be = expr.as<BinaryExpression>();
            int32_t opType = mapBinaryOp(be.op);
            if (!opType) {
                noteUnsupported("binary op: " + std::string(toString(be.op)));
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* l = emitExpr(be.left(), op, prefix, netMap))
                operands->push_back(l);
            if (auto* r = emitExpr(be.right(), op, prefix, netMap))
                operands->push_back(r);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::IntegerLiteral: {
            auto& il = expr.as<IntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)expr.type->getBitWidth());
            setLoc(c, expr.sourceRange);
            // Surelog parents constants only as operation operands and
            // bit_select indices (not assignment sides or select ranges).
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select ||
                  parent->UhdmType() == UHDM::uhdmcase_item)))
                c->VpiParent(parent);

            auto tick = raw.find('\'');
            if (tick == std::string::npos) {
                // Bare decimal literals: Surelog encodes as 64-bit UINT.
                c->VpiSize(64);
                c->VpiValue("UINT:" + raw);
                c->VpiConstType(vpiUIntConst);
            }
            else {
                size_t basePos = tick + 1;
                if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                    basePos++;
                char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                std::string digits = raw.substr(basePos + 1);
                switch (base) {
                    case 'b':
                        c->VpiValue("BIN:" + digits);
                        c->VpiConstType(vpiBinaryConst);
                        break;
                    case 'h':
                        c->VpiValue("HEX:" + digits);
                        c->VpiConstType(vpiHexConst);
                        break;
                    case 'o':
                        c->VpiValue("OCT:" + digits);
                        c->VpiConstType(vpiOctConst);
                        break;
                    default:
                        c->VpiValue("DEC:" + digits);
                        c->VpiConstType(vpiDecConst);
                        break;
                }
            }
            (void)il;
            return c;
        }
        case ExpressionKind::StringLiteral: {
            auto& sl = expr.as<StringLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)expr.type->getBitWidth());
            c->VpiValue("STRING:" + std::string(sl.getValue()));
            c->VpiConstType(vpiStringConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select ||
                  parent->UhdmType() == UHDM::uhdmcase_item)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::Conversion: {
            auto& conv = expr.as<ConversionExpression>();
            if (conv.isImplicit())
                return emitExpr(conv.operand(), parent, prefix, netMap);
            // Explicit cast: operation(vpiCastOp) with a typespec ref.
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCastOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            UHDM::typespec* cts = nullptr;
            // Size casts ("4'(x)") carry an integer_typespec at the size
            // literal; type casts use the target type's typespec.
            if (expr.syntax && expr.syntax->kind == syntax::SyntaxKind::SignedCastExpression) {
                noteUnsupported("signed cast form");
            }
            if (expr.syntax && expr.syntax->kind == syntax::SyntaxKind::CastExpression) {
                auto& cesyn = expr.syntax->as<syntax::CastExpressionSyntax>();
                if (cesyn.left->kind == syntax::SyntaxKind::IntegerLiteralExpression) {
                    auto* its = s.MakeInteger_typespec();
                    setLoc(its, cesyn.left->sourceRange());
                    its->VpiValue("INT:" + rawText(cesyn.left->sourceRange()));
                    cts = its;
                }
            }
            if (!cts) {
                auto& ct = expr.type->getCanonicalType();
                if (ct.kind == SymbolKind::PredefinedIntegerType) {
                    auto* its = s.MakeInt_typespec();
                    its->VpiSigned(ct.isSigned());
                    cts = its;
                }
                else {
                    auto* lts = s.MakeLogic_typespec();
                    cts = lts;
                }
                if (expr.syntax && expr.syntax->kind == syntax::SyntaxKind::CastExpression)
                    setLoc(cts, expr.syntax->as<syntax::CastExpressionSyntax>().left->sourceRange());
            }
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix);
            rt->VpiParent(op);
            rt->Actual_typespec(cts);
            // Re-elaborated contexts parent the cast typespec at its ref.
            if (reemitting)
                cts->VpiParent(rt);
            op->Typespec(rt);
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::Call: {
            auto& call = expr.as<CallExpression>();
            if (!call.isSystemCall()) {
                callStmtContext = false;
                auto& sub = *std::get<const SubroutineSymbol*>(call.subroutine);
                auto it = subMap.find(&sub);
                if (it == subMap.end()) {
                    noteUnsupported("user function call");
                    return nullptr;
                }
                auto& si = it->second;
                bool isFunc = sub.subroutineKind == SubroutineKind::Function;
                UHDM::tf_call* fc = isFunc ? (UHDM::tf_call*)s.MakeFunc_call()
                                           : (UHDM::tf_call*)s.MakeTask_call();
                fc->VpiName(sub.name);
                fc->VpiParent(parent);
                setLoc(fc, expr.sourceRange);
                if (isFunc)
                    ((UHDM::func_call*)fc)->Function((UHDM::function*)si.tf);
                else
                    ((UHDM::task_call*)fc)->Task((UHDM::task*)si.tf);
                auto* args = s.MakeAnyVec();
                size_t argIdx = 0;
                callArgDepth++;
                for (auto arg : call.arguments()) {
                    // Output args come wrapped as Assignment(lval, Empty).
                    if (arg->kind == ExpressionKind::Assignment) {
                        auto& ae = arg->as<AssignmentExpression>();
                        if (ae.right().kind == ExpressionKind::EmptyArgument)
                            arg = &ae.left();
                    }
                    // Direct literal args are parented at the call.
                    bool forceSaved = forceConstParent;
                    if (isLiteralExpr(*arg))
                        forceConstParent = true;
                    auto* a = emitExpr(*arg, fc, prefix, netMap);
                    forceConstParent = forceSaved;
                    if (a) {
                        // Function call arg refs carry a typespec ref to the
                        // formal's typespec (tasks don't).
                        if (isFunc && a->UhdmType() == UHDM::uhdmref_obj &&
                            argIdx < si.argTs.size()) {
                            auto* r = (UHDM::ref_obj*)a;
                            auto* rt = s.MakeRef_typespec();
                            rt->VpiFullName(r->VpiFullName());
                            rt->VpiParent(r);
                            auto [ats, bareKey] = si.argTs[argIdx];
                            if (ats)
                                rt->Actual_typespec(ats);
                            else if (bareKey)
                                pendingIoTs.push_back({rt, bareKey});
                            r->Typespec(rt);
                        }
                        args->push_back(a);
                    }
                    argIdx++;
                }
                callArgDepth--;
                if (!args->empty())
                    fc->Tf_call_args(args);
                return fc;
            }
            bool stmtCtx = callStmtContext;
            callStmtContext = false;
            auto* sc = s.MakeSys_func_call();
            std::string name = std::string(call.getSubroutineName());
            if (name.empty() || name[0] != '$')
                name = "$" + name;
            sc->VpiName(name);
            sc->VpiParent(parent);
            // Statement-context calls span the whole call; expression-context
            // calls span the name token only.
            if (stmtCtx)
                setLoc(sc, expr.sourceRange);
            else
                setLoc(sc, SourceRange(expr.sourceRange.start(),
                                       expr.sourceRange.start() + name.size()));
            auto* args = s.MakeAnyVec();
            callArgDepth++;
            for (auto arg : call.arguments()) {
                // Statement-context calls parent their direct literal args.
                bool forceSaved = forceConstParent;
                if (stmtCtx && isLiteralExpr(*arg))
                    forceConstParent = true;
                if (auto* a = emitExpr(*arg, sc, prefix, netMap))
                    args->push_back(a);
                forceConstParent = forceSaved;
            }
            callArgDepth--;
            if (!args->empty())
                sc->Tf_call_args(args);
            return sc;
        }
        case ExpressionKind::Concatenation: {
            auto& ce = expr.as<ConcatenationExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConcatOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // Direct literal operands of a concat are unparented in
            // module-compile context, parented in re-elaborated (instance)
            // context. Nested expressions keep the normal rules.
            for (auto o : ce.operands()) {
                bool saved = suppressConstParent;
                if (!reemitting && isLiteralExpr(*o))
                    suppressConstParent = true;
                if (auto* e = emitExpr(*o, op, prefix, netMap))
                    operands->push_back(e);
                suppressConstParent = saved;
            }
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::Replication: {
            auto& re = expr.as<ReplicationExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiMultiConcatOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // The repeat count constant is unparented in module-compile
            // context, but parented in re-elaborated (instance) context.
            bool saved = suppressConstParent;
            suppressConstParent = !reemitting;
            auto* cnt = emitExpr(re.count(), op, prefix, netMap);
            suppressConstParent = saved;
            if (cnt)
                operands->push_back(cnt);
            if (auto* inner = emitExpr(re.concat(), op, prefix, netMap))
                operands->push_back(inner);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::UnbasedUnsizedIntegerLiteral: {
            auto& ul = expr.as<UnbasedUnsizedIntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            logic_t bit = ul.getLiteralValue();
            std::string digit = bit.isUnknown() ? (bit.value == logic_t::X_VALUE ? "x" : "z")
                                                : (bit.value ? "1" : "0");
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            setLoc(c, expr.sourceRange);
            if (parent && (parent->UhdmType() == UHDM::uhdmoperation ||
                           parent->UhdmType() == UHDM::uhdmbit_select))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::ElementSelect: {
            auto& es = expr.as<ElementSelectExpression>();
            if (es.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("element select base");
                return nullptr;
            }
            auto& nv = es.value().as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            auto* bs = s.MakeBit_select();
            bs->VpiName(nv.symbol.name);
            bs->VpiFullName(prefix + "." + std::string(nv.symbol.name));
            bs->VpiParent(parent);
            // Surelog anchors rvalue bit_selects at the index expression,
            // but lvalue ones span the whole select.
            setLoc(bs, inLhs ? expr.sourceRange : es.selector().sourceRange);
            if (auto* ix = emitExpr(es.selector(), bs, prefix, netMap))
                bs->VpiIndex((UHDM::expr*)ix);
            return bs;
        }
        case ExpressionKind::RangeSelect: {
            auto& rs = expr.as<RangeSelectExpression>();
            if (rs.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("range select base");
                return nullptr;
            }
            auto& nv = rs.value().as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            if (rs.getSelectionKind() != RangeSelectionKind::Simple) {
                auto* ips = s.MakeIndexed_part_select();
                ips->VpiName(nv.symbol.name);
                ips->VpiDefName(nv.symbol.name);
                ips->VpiFullName(prefix + "." + std::string(nv.symbol.name));
                ips->VpiParent(parent);
                setLoc(ips, SourceRange(rs.left().sourceRange.start(),
                                        rs.right().sourceRange.end()));
                ips->VpiIndexedPartSelectType(
                    rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1 : 2);
                if (rs.left().kind == ExpressionKind::IntegerLiteral &&
                    rs.right().kind == ExpressionKind::IntegerLiteral)
                    ips->VpiConstantSelect(true);
                suppressConstParent = true;
                if (auto* b = emitExpr(rs.left(), ips, prefix, netMap))
                    ips->Base_expr((UHDM::expr*)b);
                if (auto* w = emitExpr(rs.right(), ips, prefix, netMap))
                    ips->Width_expr((UHDM::expr*)w);
                suppressConstParent = false;
                return ips;
            }
            auto* psel = s.MakePart_select();
            psel->VpiName(nv.symbol.name);
            psel->VpiDefName(nv.symbol.name);
            psel->VpiFullName(prefix + "." + std::string(nv.symbol.name));
            psel->VpiParent(parent);
            setLoc(psel, expr.sourceRange);
            bool constSel = rs.left().kind == ExpressionKind::IntegerLiteral &&
                            rs.right().kind == ExpressionKind::IntegerLiteral;
            if (constSel)
                psel->VpiConstantSelect(true);
            if (auto* l = emitExpr(rs.left(), psel, prefix, netMap))
                psel->Left_range((UHDM::expr*)l);
            if (auto* r = emitExpr(rs.right(), psel, prefix, netMap))
                psel->Right_range((UHDM::expr*)r);
            return psel;
        }
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
