//------------------------------------------------------------------------------
//! @file ExprEmit.cpp
//! @brief Expressions, constant folding, value encoding
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <algorithm>

#include "EmitHelpers.h"

#include "slang/ast/expressions/Operator.h"

namespace slang_uhdm {

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr) {
    // Surelog's netlist elaboration re-compiles top-view cont_assign
    // expressions with constant reduction. Fold only genuine expressions,
    // not plain literals (evaluating an implicitly-converted literal can
    // also truncate through slang's 32-bit unsized literal type).
    if (stripImplicitConv(expr).kind == ExpressionKind::IntegerLiteral)
        return nullptr;
    // Explicit TYPE casts (logic'/int'...) are re-emitted in TOP modules,
    // never folded; child-instance CAs and size casts still fold.
    if (!foldTypeCasts) {
        auto& c0 = stripImplicitConv(expr);
        if (c0.kind == ExpressionKind::Conversion && c0.syntax &&
            c0.syntax->kind == syntax::SyntaxKind::CastExpression &&
            isTypeSyntaxKind(
                c0.syntax->as<syntax::CastExpressionSyntax>().left->kind))
            return nullptr;
    }
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    ConstantValue cv = ctx.tryEval(expr);
    if (!cv || !cv.isInteger())
        return nullptr;
    auto& iv = cv.integer();
    if (iv.hasUnknown())
        return nullptr;
    // A SIZE cast whose OPERAND is a signed non-literal (N'(signed_ref)) folds
    // to a SIGNED constant reinterpreted at the cast width (2'(3) -> -1),
    // carrying a signed logic_typespec and no decompile. A literal operand
    // (3'(31)) stays unsigned, and TYPE casts (int'(x)) are excluded.
    auto& sc = stripImplicitConv(expr);
    bool signedSizeCast = false;
    if (sc.kind == ExpressionKind::Conversion &&
        !sc.as<ConversionExpression>().isImplicit() && sc.type &&
        sc.type->isSigned() && sc.syntax &&
        sc.syntax->kind == syntax::SyntaxKind::CastExpression &&
        !isTypeSyntaxKind(sc.syntax->as<syntax::CastExpressionSyntax>().left->kind)) {
        auto& op = stripImplicitConv(sc.as<ConversionExpression>().operand());
        signedSizeCast = op.kind != ExpressionKind::IntegerLiteral && op.type &&
                         op.type->isSigned();
    }
    if (signedSizeCast) {
        int w = (int)sc.type->getBitWidth();
        uint64_t uv = iv.as<uint64_t>().value_or(0);
        int64_t sv = (int64_t)uv;
        if (w > 0 && w < 64 && (uv & (1ULL << (w - 1))))
            sv = (int64_t)(uv | (~0ULL << w));
        auto* c = s.MakeConstant();
        c->VpiSize(w);
        c->VpiValue("INT:" + std::to_string(sv));
        c->VpiConstType(vpiIntConst);
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(c);
        c->Typespec(rt);
        // The signed logic_typespec actual is created at the very end of the
        // write phase (Surelog's arena tail).
        pendingSignedCastTs.push_back(rt);
        return c;
    }
    if (iv.isSigned() && iv.isNegative())
        return nullptr;
    std::string digits = iv.toString(LiteralBase::Decimal, /*includeBase*/ false);
    auto* c = s.MakeConstant();
    c->VpiDecompile(digits);
    c->VpiSize((int32_t)expr.type->getBitWidth());
    // A folded comparison/logical result is a 1-bit boolean; Surelog's reduce
    // encodes it as a binary constant, not UINT.
    bool boolFold = false;
    if (auto& folded = stripImplicitConv(expr); folded.kind == ExpressionKind::BinaryOp) {
        auto bop = folded.as<BinaryExpression>().op;
        boolFold = OpInfo::isComparison(bop) || bop == BinaryOperator::LogicalAnd ||
                   bop == BinaryOperator::LogicalOr ||
                   bop == BinaryOperator::LogicalImplication ||
                   bop == BinaryOperator::LogicalEquivalence;
    }
    // Surelog's reduce encodes division results (and anything referencing a
    // param whose value was so encoded) as INT; everything else as UINT.
    if (boolFold) {
        c->VpiValue("BIN:" + digits);
        c->VpiConstType(vpiBinaryConst);
    }
    else if (isIntEncoded(expr)) {
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

UHDM::hier_path* UhdmExporter::emitMixedHierPath(const Expression& expr,
                                                 UHDM::BaseClass* parent,
                                                 const std::string& prefix, NetMap& netMap) {
    // Flatten the whole access chain (members + single element-selects) into
    // components, innermost first, then reverse to base..outer order.
    struct Sel {
        const Expression* sel;
        SourceLocation selEnd;
    };
    struct Comp {
        std::string name;
        std::vector<Sel> sels; // one or more element selects on this component
        SourceRange nameSpan;  // the member/base name token
        bool isBase = false;
    };
    std::vector<Comp> comps;
    const Expression* cur = &expr;
    std::vector<Sel> pendingSels; // collected outer-to-inner
    const NamedValueExpression* baseNv = nullptr;
    auto attachSels = [&](Comp& c) {
        // pendingSels are outer-to-inner; the component wants first-dim first.
        for (auto it = pendingSels.rbegin(); it != pendingSels.rend(); ++it)
            c.sels.push_back(*it);
        pendingSels.clear();
    };
    while (true) {
        if (cur->kind == ExpressionKind::MemberAccess) {
            auto& ma = cur->as<MemberAccessExpression>();
            auto end = cur->sourceRange.end();
            Comp c;
            c.name = std::string(ma.member.name);
            c.nameSpan = SourceRange(end - ma.member.name.size(), end);
            attachSels(c);
            comps.push_back(c);
            cur = &ma.value();
        }
        else if (cur->kind == ExpressionKind::ElementSelect) {
            auto& es = cur->as<ElementSelectExpression>();
            pendingSels.push_back({&es.selector(), cur->sourceRange.end()});
            cur = &es.value();
        }
        else if (cur->kind == ExpressionKind::NamedValue) {
            baseNv = &cur->as<NamedValueExpression>();
            Comp c;
            c.name = std::string(baseNv->symbol.name);
            c.nameSpan = cur->sourceRange;
            c.isBase = true;
            attachSels(c);
            comps.push_back(c);
            break;
        }
        else {
            return nullptr;
        }
    }
    if (!baseNv)
        return nullptr;
    std::reverse(comps.begin(), comps.end());

    std::string dotted;
    for (size_t i = 0; i < comps.size(); ++i) {
        dotted += (i == 0 ? comps[i].name : "." + comps[i].name);
        for (auto& sel : comps[i].sels)
            dotted += "[" + rawText(sel.sel->sourceRange) + "]";
    }

    // A multi-dim element select on the BASE array (group_status[0][0].a)
    // emits one bit_select per dim with simple dotted fullnames and a special
    // loc chain, distinct from the member-select (b.a[0].x) work@-doubled form.
    bool baseSelMode = !comps.empty() && comps[0].isBase && !comps[0].sels.empty();

    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
        refCollector->insert(&baseNv->symbol);
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    setLoc(hp, baseSelMode ? comps[0].nameSpan : expr.sourceRange);
    auto* elems = s.MakeAnyVec();
    // The first member's name token (used to anchor an lvalue base ref).
    SourceRange firstMemberSpan =
        comps.size() > 1 ? comps[1].nameSpan : comps[0].nameSpan;
    std::string dottedAt;
    for (size_t i = 0; i < comps.size(); ++i) {
        auto& comp = comps[i];
        bool lastMember = i + 1 == comps.size();
        dottedAt += (i == 0 ? comp.name : "." + comp.name);
        if (comp.isBase && baseSelMode) {
            // Base multi-dim element select: one bit_select per dim. Simple
            // dotted fullnames; each bit_select's loc is the base name (first
            // dim) or the prior selector's span (later dims).
            for (size_t k = 0; k < comp.sels.size(); ++k) {
                dottedAt += "[" + rawText(comp.sels[k].sel->sourceRange) + "]";
                auto* bs = s.MakeBit_select();
                if (k == 0) // only the first dim carries vpiName
                    bs->VpiName(comp.name);
                bs->VpiParent(hp);
                bs->VpiFullName(dottedAt);
                setLoc(bs, k == 0 ? comp.nameSpan : comp.sels[k - 1].sel->sourceRange);
                // Base-select index constants are not parented to the bit_select.
                bool savedSCP = suppressConstParent;
                suppressConstParent = true;
                if (auto* ix = emitExpr(*comp.sels[k].sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
                suppressConstParent = savedSCP;
                elems->push_back(bs);
            }
        }
        else if (!comp.sels.empty()) {
            auto& sel = comp.sels[0];
            dottedAt += "[" + rawText(sel.sel->sourceRange) + "]";
            auto* bs = s.MakeBit_select();
            bs->VpiName(comp.name);
            bs->VpiParent(hp);
            // Lvalue: loc spans member+index, fullname lazily freezes to the
            // work@-prefixed doubled form, index constant parents to the
            // bit_select. Rvalue: loc is the member token only, fullname is the
            // dotted path so far, index constant is unparented.
            if (inLhs) {
                setLoc(bs, SourceRange(comp.nameSpan.start(), sel.selEnd));
                (void)bs->VpiFullName();
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else {
                setLoc(bs, comp.nameSpan);
                bs->VpiFullName(dottedAt);
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            elems->push_back(bs);
        }
        else {
            auto* r = s.MakeRef_obj();
            r->VpiName(comp.name);
            (void)r->VpiFullName();
            if (baseSelMode && !comp.isBase) {
                // Trailing member of a base-select path: member name, full
                // dotted fullname.
                r->VpiFullName(dottedAt);
            }
            else if (!inLhs && lastMember && !comp.isBase)
                r->VpiFullName(prefix + "." + comp.name);
            r->VpiParent(hp);
            // Lvalue paths anchor the base ref at the first member token.
            if (comp.isBase && inLhs && comps.size() > 1)
                setLoc(r, firstMemberSpan);
            else
                setLoc(r, comp.nameSpan);
            elems->push_back(r);
        }
    }
    hp->Path_elems(elems);
    return hp;
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
            auto* asn = s.MakeAssignment();
            // Compound assignments (o += 10) carry the operator as the
            // assignment op type; the Rhs is the value operand (the implicit
            // LValueReference self-reference is dropped).
            const Expression* rhsExpr = &ae.right();
            if (ae.isCompound() && ae.op) {
                asn->VpiOpType(mapBinaryOp(*ae.op));
                auto& rc = stripImplicitConv(ae.right());
                if (rc.kind == ExpressionKind::BinaryOp) {
                    auto& be = rc.as<BinaryExpression>();
                    rhsExpr = stripImplicitConv(be.left()).kind ==
                                      ExpressionKind::LValueReference
                                  ? &be.right()
                                  : &be.left();
                }
            }
            else {
                asn->VpiOpType(kVpiAssignmentOp);
            }
            asn->VpiBlocking(!ae.isNonBlocking());
            asn->VpiParent(parent);
            setLoc(asn, expr.sourceRange);
            inLhs = true;
            if (auto* lhs = emitExpr(ae.left(), asn, prefix, netMap))
                asn->Lhs((UHDM::expr*)lhs);
            inLhs = false;
            if (auto* rhs = emitExpr(*rhsExpr, asn, prefix, netMap)) {
                // In a FUNCTION body, an unbased-unsized '0/'1/'x RHS takes the
                // LHS width (an always-block leaves it unsized). Only the direct
                // assignment RHS is sized, not '0 as an operation operand.
                if (currentSubSym && rhs->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::expr*)rhs)->VpiSize() == -1 &&
                    stripImplicitConv(*rhsExpr).kind ==
                        ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    int32_t w = (int32_t)ae.left().type->getBitWidth();
                    if (w > 0) {
                        auto* c = (UHDM::constant*)rhs;
                        std::string v(c->VpiValue());
                        char d = v.empty() ? '0' : v.back();
                        std::string rep((size_t)w, d);
                        c->VpiSize(w);
                        c->VpiValue("BIN:" + rep);
                        c->VpiDecompile(rep);
                    }
                }
                asn->Rhs(rhs);
            }
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
                // Package-function bodies keep a ref bound to the param's
                // def-view constant.
                if (currentTf && pkgScopeInst) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    if (auto pit = pkgParamConst.find(&nv.symbol);
                        pit != pkgParamConst.end())
                        ref->Actual_group(pit->second);
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
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
                ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                if (suppressRefActual) {
                    // Gen-scope process ref: left unbound.
                }
                else if (auto it = netMap.find(&nv.symbol); it != netMap.end())
                    ref->Actual_group(it->second);
                else if (auto eit = enumConstMap.find(&nv.symbol); eit != enumConstMap.end())
                    ref->Actual_group(eit->second);
                else if (nv.symbol.kind == SymbolKind::EnumValue)
                    // Anonymous-enum const built later in the deferred pass.
                    pendingEnumRefs.push_back({ref, &nv.symbol});
                else if (funcRetRefs && &nv.symbol == funcRetSym)
                    funcRetRefs->push_back(ref);
                else if (nv.symbol.kind == SymbolKind::Parameter && implicitNetModule &&
                         nv.symbol.getParentScope() &&
                         nv.symbol.getParentScope()->asSymbol().kind ==
                             SymbolKind::StatementBlock) {
                    // Surelog can't resolve block-scoped localparams: refs
                    // bind an implicit module wire minted at the first ref.
                    auto& inet = implicitNetMap[&nv.symbol];
                    if (!inet) {
                        inet = s.MakeLogic_net();
                        inet->VpiName(nv.symbol.name);
                        inet->VpiFullName(implicitNetPrefix + "." +
                                          std::string(nv.symbol.name));
                        inet->VpiParent(implicitNetModule);
                        inet->VpiNetType(1);
                        setLoc(inet, expr.sourceRange);
                        auto* nets = implicitNetModule->Nets();
                        if (!nets) {
                            nets = s.MakeNetVec();
                            implicitNetModule->Nets(nets);
                        }
                        nets->push_back(inet);
                    }
                    ref->Actual_group(inet);
                }
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
            // bit_select indices (not assignment sides or select ranges);
            // re-elaborated contexts also parent part_select bounds.
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select ||
                  parent->UhdmType() == UHDM::uhdmcase_item ||
                  parent->UhdmType() == UHDM::uhdmimmediate_assert ||
                  (reemitting && parent->UhdmType() == UHDM::uhdmpart_select))))
                c->VpiParent(parent);

            auto tick = raw.find('\'');
            if (tick == std::string::npos) {
                // Bare decimal literals: Surelog encodes as 64-bit UINT.
                c->VpiSize(64);
                c->VpiValue("UINT:" + raw);
                c->VpiConstType(vpiUIntConst);
            }
            else {
                // Unsized based literals ('b0, 'h1): -1 in most contexts
                // (operands, procedural/net-decl assignment RHS), but no
                // explicit size (0) as a BARE continuous-assignment RHS.
                if (tick == 0) {
                    bool bareContAssign =
                        parent && parent->UhdmType() == UHDM::uhdmcont_assign &&
                        !((UHDM::cont_assign*)parent)->VpiNetDeclAssign();
                    c->VpiSize(bareContAssign ? 0 : -1);
                }
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
        case ExpressionKind::RealLiteral: {
            auto& rl = expr.as<RealLiteral>();
            auto* c = s.MakeConstant();
            c->VpiDecompile(rawText(expr.sourceRange));
            c->VpiSize(64);
            char buf[64];
            snprintf(buf, sizeof(buf), "%f", rl.getValue());
            c->VpiValue(std::string("REAL:") + buf);
            c->VpiConstType(vpiRealConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::StringLiteral: {
            auto& sl = expr.as<StringLiteral>();
            (void)sl;
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            // Surelog stores the RAW source characters (escapes like \n stay
            // as backslash+n), not the interpreted value; size follows suit.
            std::string inner = raw;
            if (inner.size() >= 2 && inner.front() == '"' && inner.back() == '"')
                inner = inner.substr(1, inner.size() - 2);
            c->VpiSize((int32_t)(inner.size() * 8));
            c->VpiValue("STRING:" + inner);
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
            bool deferredCast = false;
            if (expr.syntax && expr.syntax->kind == syntax::SyntaxKind::CastExpression) {
                auto& cesyn = expr.syntax->as<syntax::CastExpressionSyntax>();
                if (cesyn.left->kind == syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (reemitting) {
                        // Created at the end of the write phase.
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        auto lr = cesyn.left->sourceRange();
                        pendingCastTs.push_back(
                            {rt0, sm->getLineNumber(lr.start()),
                             sm->getColumnNumber(lr.start()),
                             sm->getLineNumber(lr.end()), sm->getColumnNumber(lr.end()),
                             "INT:" + rawText(lr)});
                        op->Typespec(rt0);
                        deferredCast = true;
                    }
                    else {
                        auto* its = s.MakeInteger_typespec();
                        setLoc(its, cesyn.left->sourceRange());
                        its->VpiValue("INT:" + rawText(cesyn.left->sourceRange()));
                        cts = its;
                    }
                }
                else if (isTypeSyntaxKind(cesyn.left->kind)) {
                    // Type casts: re-emitted contexts defer the target-type
                    // typespec to the end of the write phase; otherwise fall
                    // through to the fallback below.
                    if (reemitting) {
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        auto lr = cesyn.left->sourceRange();
                        pendingCastTs.push_back({rt0, sm->getLineNumber(lr.start()),
                                                 sm->getColumnNumber(lr.start()),
                                                 sm->getLineNumber(lr.end()),
                                                 sm->getColumnNumber(lr.end()), "",
                                                 nullptr, prefix, expr.type});
                        op->Typespec(rt0);
                        deferredCast = true;
                    }
                }
                else if (currentScope) {
                    // Non-literal cast sizes: integer_typespec carrying the
                    // freshly-bound size expression as vpiExpr (parented at
                    // the cast operation, name-only call spans). Parens
                    // anchor at the inner expression. Re-emitted contexts
                    // create the ts at the end of the write phase.
                    const syntax::ExpressionSyntax* leftSyn = cesyn.left;
                    while (leftSyn->kind == syntax::SyntaxKind::ParenthesizedExpression)
                        leftSyn = leftSyn->as<syntax::ParenthesizedExpressionSyntax>()
                                      .expression;
                    ASTContext bctx(*currentScope, LookupLocation::max);
                    auto& sizeExpr = Expression::bind(*cesyn.left, bctx);
                    auto lr = leftSyn->sourceRange();
                    if (reemitting) {
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        pendingCastTs.push_back({rt0, sm->getLineNumber(lr.start()),
                                                 sm->getColumnNumber(lr.start()),
                                                 sm->getLineNumber(lr.end()),
                                                 sm->getColumnNumber(lr.end()), "",
                                                 &sizeExpr, prefix});
                        op->Typespec(rt0);
                        auto* operandsD = s.MakeAnyVec();
                        if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                            operandsD->push_back(e);
                        op->Operands(operandsD);
                        return op;
                    }
                    auto* its = s.MakeInteger_typespec();
                    setLoc(its, lr);
                    bool savedCS = inCastSize;
                    inCastSize = true;
                    if (auto* e = emitExpr(sizeExpr, op, prefix, netMap))
                        its->Expr((UHDM::expr*)e);
                    inCastSize = savedCS;
                    cts = its;
                }
            }
            if (deferredCast) {
                auto* operandsD = s.MakeAnyVec();
                if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                    operandsD->push_back(e);
                op->Operands(operandsD);
                return op;
            }
            if (!cts && expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::CastExpression) {
                auto it2 = castTsCache.find(
                    expr.syntax->as<syntax::CastExpressionSyntax>().left);
                if (it2 != castTsCache.end())
                    cts = it2->second;
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
                    // Calls seen before the def fill (param inits): create a
                    // shell now; emitTaskFuncs fills it later.
                    auto pscope = sub.getParentScope();
                    if (pscope &&
                        pscope->asSymbol().kind == SymbolKind::InstanceBody) {
                        SubInfo shell;
                        shell.tf = sub.subroutineKind == SubroutineKind::Function
                                       ? (UHDM::task_func*)s.MakeFunction()
                                       : (UHDM::task_func*)s.MakeTask();
                        shell.tf->VpiName(sub.name);
                        it = subMap.emplace(&sub, shell).first;
                    }
                    else if (pscope && pscope->asSymbol().kind ==
                                           SymbolKind::GenerateBlock) {
                        // Def-view gen contents compile before the gen
                        // function exists: a name-only, unlinked call.
                        auto* fc0 = sub.subroutineKind == SubroutineKind::Function
                                        ? (UHDM::tf_call*)s.MakeFunc_call()
                                        : (UHDM::tf_call*)s.MakeTask_call();
                        fc0->VpiName(sub.name);
                        fc0->VpiParent(parent);
                        setLoc(fc0, expr.sourceRange);
                        return fc0;
                    }
                    else {
                        noteUnsupported("user function call");
                        return nullptr;
                    }
                }
                auto& si = it->second;
                bool isFunc = sub.subroutineKind == SubroutineKind::Function;
                UHDM::tf_call* fc = isFunc ? (UHDM::tf_call*)s.MakeFunc_call()
                                           : (UHDM::tf_call*)s.MakeTask_call();
                fc->VpiName(sub.name);
                fc->VpiParent(parent);
                if (inParamInit)
                    setLoc(fc, nameSpan(expr.sourceRange.start(), sub.name));
                else
                    setLoc(fc, expr.sourceRange);
                // Package functions: qualified calls carry the scoped name
                // and anchor at the package-name token only.
                if (auto ps2 = sub.getParentScope();
                    ps2 && ps2->asSymbol().kind == SymbolKind::Package) {
                    std::string pkgName(ps2->asSymbol().name);
                    std::string raw = rawText(expr.sourceRange);
                    if (raw.rfind(pkgName + "::", 0) == 0) {
                        fc->VpiName(pkgName + "::" + std::string(sub.name));
                        setLoc(fc, nameSpan(expr.sourceRange.start(), pkgName));
                    }
                    else if (currentScope && si.tf) {
                        // Import-resolved call: the module lists the shared
                        // package function in its own Task_funcs.
                        auto& v2 = importedTfCalls[currentScope];
                        if (std::find(v2.begin(), v2.end(), si.tf) == v2.end())
                            v2.push_back(si.tf);
                    }
                }
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
                        // formal's typespec (tasks don't; procedural-context
                        // calls don't either).
                        bool refArg = a->UhdmType() == UHDM::uhdmref_obj ||
                                      a->UhdmType() == UHDM::uhdmbit_select ||
                                      a->UhdmType() == UHDM::uhdmpart_select ||
                                      a->UhdmType() == UHDM::uhdmindexed_part_select;
                        bool otherArg = a->UhdmType() == UHDM::uhdmconstant ||
                                        a->UhdmType() == UHDM::uhdmfunc_call;
                        // Only outermost-call args carry formal-ts refs, and
                        // def-view function bodies never do (top pkg copies
                        // re-attach them).
                        bool argCtxOk = currentTf ? pkgTopEmit : callArgDepth == 1;
                        if (isFunc && !inProcessEmit && argCtxOk &&
                            (refArg || otherArg) && argIdx < si.argTs.size()) {
                            auto* r = (UHDM::expr*)a;
                            auto* rt = s.MakeRef_typespec();
                            // Constant args (param-init context) name the
                            // enclosing scope; refs name themselves.
                            std::string argFull = prefix;
                            if (a->UhdmType() == UHDM::uhdmref_obj)
                                argFull = ((UHDM::ref_obj*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmbit_select)
                                argFull = ((UHDM::bit_select*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmpart_select)
                                argFull = ((UHDM::part_select*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmindexed_part_select)
                                argFull =
                                    ((UHDM::indexed_part_select*)a)->VpiFullName();
                            rt->VpiFullName(argFull);
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
            std::string name = std::string(call.getSubroutineName());
            // Built-in METHOD calls (e.first(), arr.size(): no leading $)
            // become hier_path shapes - not yet supported.
            if (name.empty() || name[0] != '$') {
                noteUnsupported("system method call: " + name);
                return nullptr;
            }
            // Type-query calls ($bits/$size) fold to constants when
            // evaluable.
            if (name == "$bits") {
                ASTContext qctx(comp.getRoot(), LookupLocation::max);
                if (auto cv = qctx.tryEval(expr); cv && cv.isInteger()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    setLoc(c, expr.sourceRange);
                    if (forceConstParent ||
                        (!suppressConstParent && parent &&
                         (parent->UhdmType() == UHDM::uhdmoperation ||
                          parent->UhdmType() == UHDM::uhdmbit_select ||
                          parent->UhdmType() == UHDM::uhdmcase_item)))
                        c->VpiParent(parent);
                    return c;
                }
            }
            auto* sc = s.MakeSys_func_call();
            sc->VpiName(name);
            sc->VpiParent(parent);
            // Conversion/query functions keep name-token-only spans in
            // expression contexts; other sys calls span the whole call.
            static const std::set<std::string> kNameOnlyFuncs = {"$signed", "$unsigned"};
            if (stmtCtx || (!kNameOnlyFuncs.count(name) && !inCastSize))
                setLoc(sc, expr.sourceRange);
            else
                setLoc(sc, SourceRange(expr.sourceRange.start(),
                                       expr.sourceRange.start() + name.size()));
            auto* args = s.MakeAnyVec();
            callArgDepth++;
            for (auto arg : call.arguments()) {
                // System-call direct literal args parent to the call.
                bool forceSaved = forceConstParent;
                if (isLiteralExpr(*arg))
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
            // A DIRECT literal repeat count is unparented in module-compile
            // context (nested expression constants keep normal rules).
            bool saved = suppressConstParent;
            if (!reemitting && isLiteralExpr(re.count()))
                suppressConstParent = true;
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
            // 'x/'z uppercase their digit in the decompile ('x -> 'X).
            for (auto& ch : raw)
                if (ch == 'x' || ch == 'z')
                    ch = (char)toupper(ch);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            logic_t bit = ul.getLiteralValue();
            std::string digit = bit.isUnknown() ? (bit.value == logic_t::X_VALUE ? "X" : "Z")
                                                : (bit.value ? "1" : "0");
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (parent && (parent->UhdmType() == UHDM::uhdmoperation ||
                            parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::ElementSelect: {
            auto& es = expr.as<ElementSelectExpression>();
            // Selects on member access become hier_paths whose last element
            // is the select object (lazily-frozen fullname).
            if (es.value().kind == ExpressionKind::MemberAccess) {
                std::vector<const Expression*> chain;
                const Expression* base = &es.value();
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &base->as<MemberAccessExpression>().value();
                }
                if (base->kind != ExpressionKind::NamedValue) {
                    noteUnsupported("member select base");
                    return nullptr;
                }
                auto& bnv = base->as<NamedValueExpression>();
                auto* hp = s.MakeHier_path();
                std::string dotted(bnv.symbol.name);
                for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                    dotted +=
                        "." + std::string((*it2)->as<MemberAccessExpression>().member.name);
                dotted += "[" + rawText(es.selector().sourceRange) + "]";
                hp->VpiName(dotted);
                hp->VpiFullName(dotted);
                hp->VpiParent(parent);
                setLoc(hp, expr.sourceRange);
                auto* elems = s.MakeAnyVec();
                {
                    auto* r = s.MakeRef_obj();
                    r->VpiName(bnv.symbol.name);
                    (void)r->VpiFullName();
                    r->VpiParent(hp);
                    setLoc(r, base->sourceRange);
                    elems->push_back(r);
                }
                for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                    auto& ma = (*it2)->as<MemberAccessExpression>();
                    bool last = *it2 == chain.front();
                    if (!last) {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(ma.member.name);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        auto end = (*it2)->sourceRange.end();
                        setLoc(r, SourceRange(end - ma.member.name.size(), end));
                        elems->push_back(r);
                    }
                    else {
                        auto* bs2 = s.MakeBit_select();
                        bs2->VpiName(ma.member.name);
                        bs2->VpiParent(hp);
                        setLoc(bs2, es.selector().sourceRange);
                        (void)bs2->VpiFullName();
                        if (auto* ix = emitExpr(es.selector(), bs2, prefix, netMap))
                            bs2->VpiIndex((UHDM::expr*)ix);
                        elems->push_back(bs2);
                    }
                }
                hp->Path_elems(elems);
                return hp;
            }
            // Nested element selects (unpacked arrays) flatten to a
            // var_select with one index per dimension, base-prefixed refs.
            if (es.value().kind == ExpressionKind::ElementSelect) {
                std::vector<const Expression*> sels;
                const Expression* base = &expr;
                while (base->kind == ExpressionKind::ElementSelect) {
                    sels.push_back(&base->as<ElementSelectExpression>().selector());
                    base = &base->as<ElementSelectExpression>().value();
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& nv2 = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&nv2.symbol);
                    auto* vs = s.MakeVar_select();
                    vs->VpiName(nv2.symbol.name);
                    std::string baseFull = joinRef(prefix, nv2.symbol.name);
                    vs->VpiFullName(baseFull);
                    vs->VpiParent(parent);
                    setLoc(vs, expr.sourceRange);
                    auto* idxs = s.MakeExprVec();
                    bool savedFCP = forceConstParent;
                    for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2) {
                        forceConstParent = isLiteralExpr(**it2);
                        if (auto* ix = emitExpr(**it2, vs, baseFull, netMap))
                            idxs->push_back((UHDM::expr*)ix);
                    }
                    forceConstParent = savedFCP;
                    vs->Exprs(idxs);
                    return vs;
                }
                // Nested selects whose leaf is a member access (bar.l[2][1])
                // -> hier_path with a var_select last element.
                if (base->kind == ExpressionKind::MemberAccess) {
                    std::vector<const Expression*> chain;
                    const Expression* mbase = base;
                    while (mbase->kind == ExpressionKind::MemberAccess) {
                        chain.push_back(mbase);
                        mbase = &mbase->as<MemberAccessExpression>().value();
                    }
                    if (mbase->kind == ExpressionKind::NamedValue) {
                        auto& bnv = mbase->as<NamedValueExpression>();
                        if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                            refCollector->insert(&bnv.symbol);
                        auto* hp = s.MakeHier_path();
                        std::string dotted(bnv.symbol.name);
                        for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                            dotted += "." +
                                      std::string(
                                          (*it2)->as<MemberAccessExpression>().member.name);
                        for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2)
                            dotted += "[" + rawText((*it2)->sourceRange) + "]";
                        hp->VpiName(dotted);
                        hp->VpiFullName(dotted);
                        hp->VpiParent(parent);
                        // Lvalue hier_paths anchor the base ref and last elem
                        // at the FINAL member's name span (Surelog quirk).
                        auto& frontMa = chain.front()->as<MemberAccessExpression>();
                        auto memEnd = chain.front()->sourceRange.end();
                        SourceRange memSpan(memEnd - frontMa.member.name.size(), memEnd);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        {
                            auto* r = s.MakeRef_obj();
                            r->VpiName(bnv.symbol.name);
                            (void)r->VpiFullName();
                            r->VpiParent(hp);
                            setLoc(r, inLhs ? memSpan : mbase->sourceRange);
                            elems->push_back(r);
                        }
                        for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                            auto& ma = (*it2)->as<MemberAccessExpression>();
                            bool last = *it2 == chain.front();
                            if (!last) {
                                auto* r = s.MakeRef_obj();
                                r->VpiName(ma.member.name);
                                (void)r->VpiFullName();
                                r->VpiParent(hp);
                                auto end = (*it2)->sourceRange.end();
                                setLoc(r, SourceRange(end - ma.member.name.size(), end));
                                elems->push_back(r);
                                continue;
                            }
                            auto* vs = s.MakeVar_select();
                            vs->VpiName(ma.member.name);
                            vs->VpiParent(hp);
                            (void)vs->VpiFullName();
                            setLoc(vs, inLhs ? SourceRange(memSpan.start(),
                                                           expr.sourceRange.end())
                                             : expr.sourceRange);
                            auto* idxs = s.MakeExprVec();
                            bool savedFCP = forceConstParent;
                            for (auto it3 = sels.rbegin(); it3 != sels.rend(); ++it3) {
                                forceConstParent = isLiteralExpr(**it3);
                                if (auto* ix = emitExpr(**it3, vs, dotted, netMap))
                                    idxs->push_back((UHDM::expr*)ix);
                            }
                            forceConstParent = savedFCP;
                            vs->Exprs(idxs);
                            elems->push_back(vs);
                        }
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
            }
            if (es.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("element select base");
                return nullptr;
            }
            auto& nv = es.value().as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            auto* bs = s.MakeBit_select();
            bs->VpiName(nv.symbol.name);
            bs->VpiFullName(joinRef(prefix, nv.symbol.name));
            bs->VpiParent(parent);
            // Surelog anchors rvalue bit_selects at the index expression,
            // but lvalue ones span the whole select.
            setLoc(bs, inLhs ? expr.sourceRange : es.selector().sourceRange);
            // Refs nested in index OPERATIONS scope by the base name;
            // direct index refs stay module-scoped.
            std::string idxPrefix = prefix;
            if (stripImplicitConv(es.selector()).kind != ExpressionKind::NamedValue)
                idxPrefix = prefix + "." + std::string(nv.symbol.name);
            if (auto* ix = emitExpr(es.selector(), bs, idxPrefix, netMap))
                bs->VpiIndex((UHDM::expr*)ix);
            return bs;
        }
        case ExpressionKind::RangeSelect: {
            auto& rs = expr.as<RangeSelectExpression>();
            // Range select of an element select (x[0][1:0]) flattens to a
            // var_select whose leading indices are the element selectors and
            // whose final index is the (indexed_)part_select.
            if (rs.value().kind == ExpressionKind::ElementSelect) {
                std::vector<const Expression*> sels;
                const Expression* base = &rs.value();
                while (base->kind == ExpressionKind::ElementSelect) {
                    sels.push_back(&base->as<ElementSelectExpression>().selector());
                    base = &base->as<ElementSelectExpression>().value();
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& nvb = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&nvb.symbol);
                    auto* vs = s.MakeVar_select();
                    vs->VpiName(nvb.symbol.name);
                    std::string baseFull = joinRef(prefix, nvb.symbol.name);
                    vs->VpiFullName(baseFull);
                    vs->VpiParent(parent);
                    setLoc(vs, expr.sourceRange);
                    auto* idxs = s.MakeExprVec();
                    bool savedFCP = forceConstParent;
                    for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2) {
                        // Only literal indices force-parent; select indices
                        // (part_select) keep their own bound rules.
                        forceConstParent = isLiteralExpr(**it2);
                        if (auto* ix = emitExpr(**it2, vs, baseFull, netMap))
                            idxs->push_back((UHDM::expr*)ix);
                    }
                    forceConstParent = savedFCP;
                    // Final selector: a part_select (or indexed_part_select).
                    SourceRange selRange(rs.left().sourceRange.start(),
                                         rs.right().sourceRange.end());
                    bool constSel = false;
                    {
                        ASTContext cctx(comp.getRoot(), LookupLocation::max);
                        constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                    cctx.tryEval(rs.left())) &&
                                   (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                    cctx.tryEval(rs.right()));
                    }
                    if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                        auto* ps = s.MakePart_select();
                        ps->VpiName(nvb.symbol.name);
                        ps->VpiDefName(nvb.symbol.name);
                        ps->VpiFullName(baseFull + "." + std::string(nvb.symbol.name));
                        ps->VpiParent(vs);
                        setLoc(ps, selRange);
                        if (constSel)
                            ps->VpiConstantSelect(true);
                        bool savedSup = suppressConstParent;
                        suppressConstParent = true;
                        if (auto* l = emitExpr(rs.left(), ps, baseFull, netMap))
                            ps->Left_range((UHDM::expr*)l);
                        if (auto* r = emitExpr(rs.right(), ps, baseFull, netMap))
                            ps->Right_range((UHDM::expr*)r);
                        suppressConstParent = savedSup;
                        idxs->push_back(ps);
                    }
                    else {
                        auto* ips = s.MakeIndexed_part_select();
                        ips->VpiName(nvb.symbol.name);
                        ips->VpiDefName(nvb.symbol.name);
                        ips->VpiFullName(baseFull + "." + std::string(nvb.symbol.name));
                        ips->VpiParent(vs);
                        setLoc(ips, selRange);
                        ips->VpiIndexedPartSelectType(
                            rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1 : 2);
                        if (constSel)
                            ips->VpiConstantSelect(true);
                        bool savedSup = suppressConstParent;
                        suppressConstParent = isLiteralExpr(rs.left());
                        if (auto* b = emitExpr(rs.left(), ips, baseFull, netMap))
                            ips->Base_expr((UHDM::expr*)b);
                        suppressConstParent = isLiteralExpr(rs.right());
                        if (auto* w = emitExpr(rs.right(), ips, baseFull, netMap))
                            ips->Width_expr((UHDM::expr*)w);
                        suppressConstParent = savedSup;
                        idxs->push_back(ips);
                    }
                    vs->Exprs(idxs);
                    return vs;
                }
            }
            // Range select of a member access (a.b[0+:8]) becomes a hier_path
            // whose last element is an (indexed_)part_select.
            if (rs.value().kind == ExpressionKind::MemberAccess) {
                std::vector<const Expression*> chain;
                const Expression* base = &rs.value();
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &base->as<MemberAccessExpression>().value();
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& bnv = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&bnv.symbol);
                    auto* hp = s.MakeHier_path();
                    std::string dotted(bnv.symbol.name);
                    for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                        dotted += "." +
                                  std::string(
                                      (*it2)->as<MemberAccessExpression>().member.name);
                    std::string selText = rawText(SourceRange(rs.left().sourceRange.start(),
                                                              rs.right().sourceRange.end()));
                    dotted += "[" + selText + "]";
                    hp->VpiName(dotted);
                    hp->VpiFullName(dotted);
                    hp->VpiParent(parent);
                    setLoc(hp, expr.sourceRange);
                    auto* elems = s.MakeAnyVec();
                    {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(bnv.symbol.name);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        setLoc(r, base->sourceRange);
                        elems->push_back(r);
                    }
                    for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                        auto& ma = (*it2)->as<MemberAccessExpression>();
                        bool last = *it2 == chain.front();
                        if (!last) {
                            auto* r = s.MakeRef_obj();
                            r->VpiName(ma.member.name);
                            (void)r->VpiFullName();
                            r->VpiParent(hp);
                            auto end = (*it2)->sourceRange.end();
                            setLoc(r, SourceRange(end - ma.member.name.size(), end));
                            elems->push_back(r);
                            continue;
                        }
                        SourceRange elemLoc(
                            (*it2)->sourceRange.end() - ma.member.name.size(),
                            rs.right().sourceRange.end() + 1);
                        bool constSel = false;
                        {
                            ASTContext cctx(comp.getRoot(), LookupLocation::max);
                            constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                        cctx.tryEval(rs.left())) &&
                                       (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                        cctx.tryEval(rs.right()));
                        }
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                            auto* ps = s.MakePart_select();
                            ps->VpiName(ma.member.name);
                            ps->VpiParent(hp);
                            (void)ps->VpiFullName();
                            setLoc(ps, elemLoc);
                            if (constSel)
                                ps->VpiConstantSelect(true);
                            bool sup = suppressConstParent;
                            suppressConstParent = true;
                            if (auto* l = emitExpr(rs.left(), ps, prefix, netMap))
                                ps->Left_range((UHDM::expr*)l);
                            if (auto* r2 = emitExpr(rs.right(), ps, prefix, netMap))
                                ps->Right_range((UHDM::expr*)r2);
                            suppressConstParent = sup;
                            elems->push_back(ps);
                        }
                        else {
                            auto* ips = s.MakeIndexed_part_select();
                            ips->VpiName(ma.member.name);
                            ips->VpiParent(hp);
                            (void)ips->VpiFullName();
                            setLoc(ips, elemLoc);
                            ips->VpiIndexedPartSelectType(
                                rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1
                                                                                       : 2);
                            if (constSel)
                                ips->VpiConstantSelect(true);
                            bool sup = suppressConstParent;
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* b = emitExpr(rs.left(), ips, prefix, netMap))
                                ips->Base_expr((UHDM::expr*)b);
                            suppressConstParent = isLiteralExpr(rs.right());
                            if (auto* w = emitExpr(rs.right(), ips, prefix, netMap))
                                ips->Width_expr((UHDM::expr*)w);
                            suppressConstParent = sup;
                            elems->push_back(ips);
                        }
                    }
                    hp->Path_elems(elems);
                    return hp;
                }
            }
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
                ips->VpiFullName(joinRef(prefix, nv.symbol.name));
                ips->VpiParent(parent);
                // Lvalue selects span the whole expression.
                if (inLhs)
                    setLoc(ips, expr.sourceRange);
                else
                    setLoc(ips, SourceRange(rs.left().sourceRange.start(),
                                            rs.right().sourceRange.end()));
                ips->VpiIndexedPartSelectType(
                    rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1 : 2);
                // Constant width suffices (the base may be a variable).
                {
                    ASTContext cctx(comp.getRoot(), LookupLocation::max);
                    if (rs.right().kind == ExpressionKind::IntegerLiteral ||
                        cctx.tryEval(rs.right()))
                        ips->VpiConstantSelect(true);
                }
                // Refs nested in OPERATIONS scope by the base name; DIRECT
                // refs stay module-scoped. Only DIRECT literal bounds
                // suppress constant parents.
                auto savedSel = selectBasePrefix;
                std::string basePfx = prefix + "." + std::string(nv.symbol.name);
                auto boundPfx = [&](const Expression& e) -> const std::string& {
                    return stripImplicitConv(e).kind == ExpressionKind::NamedValue ? prefix
                                                                                   : basePfx;
                };
                bool savedSup = suppressConstParent;
                selectBasePrefix = basePfx;
                suppressConstParent = isLiteralExpr(rs.left());
                if (auto* b = emitExpr(rs.left(), ips, boundPfx(rs.left()), netMap))
                    ips->Base_expr((UHDM::expr*)b);
                suppressConstParent = isLiteralExpr(rs.right());
                if (auto* w = emitExpr(rs.right(), ips, boundPfx(rs.right()), netMap))
                    ips->Width_expr((UHDM::expr*)w);
                suppressConstParent = savedSup;
                selectBasePrefix = savedSel;
                return ips;
            }
            auto* psel = s.MakePart_select();
            psel->VpiName(nv.symbol.name);
            psel->VpiDefName(nv.symbol.name);
            psel->VpiParent(parent);
            // Fullname is frozen from the parent chain (matches Surelog's
            // lazily-computed values, incl. the doubled name under a
            // bit_select index).
            (void)psel->VpiFullName();
            setLoc(psel, expr.sourceRange);
            bool constSel = false;
            {
                ASTContext cctx(comp.getRoot(), LookupLocation::max);
                constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                            cctx.tryEval(rs.left())) &&
                           (rs.right().kind == ExpressionKind::IntegerLiteral ||
                            cctx.tryEval(rs.right()));
            }
            if (constSel)
                psel->VpiConstantSelect(true);
            // Refs nested in bound OPERATIONS scope by the base name; in a
            // function/task body EVERY bound ref (incl. bare params) scopes by
            // the base name (Surelog's doubled part-select-bound fullname).
            std::string basePfx = prefix + "." + std::string(nv.symbol.name);
            auto boundPfx = [&](const Expression& e) -> const std::string& {
                if (currentSubSym)
                    return basePfx;
                return stripImplicitConv(e).kind == ExpressionKind::NamedValue ? prefix
                                                                               : basePfx;
            };
            if (auto* l = emitExpr(rs.left(), psel, boundPfx(rs.left()), netMap))
                psel->Left_range((UHDM::expr*)l);
            if (auto* r = emitExpr(rs.right(), psel, boundPfx(rs.right()), netMap))
                psel->Right_range((UHDM::expr*)r);
            return psel;
        }
        case ExpressionKind::MemberAccess: {
            // p.hi -> hier_path with unbound ref elements: base ref has
            // name only; member refs carry module-scoped fullnames.
            std::vector<const Expression*> chain;
            const Expression* base = &expr;
            while (base->kind == ExpressionKind::MemberAccess) {
                chain.push_back(base);
                base = &base->as<MemberAccessExpression>().value();
            }
            // A member whose base chain threads through element selects
            // (b.a[0].x, a[0][0].min_v) -> hier_path with bit_select elements
            // for each selected member.
            if (base->kind == ExpressionKind::ElementSelect) {
                if (auto* hp = emitMixedHierPath(expr, parent, prefix, netMap))
                    return hp;
            }
            if (base->kind != ExpressionKind::NamedValue) {
                noteUnsupported("member access base");
                return nullptr;
            }
            auto& nv = base->as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            auto* hp = s.MakeHier_path();
            std::string dotted(nv.symbol.name);
            for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                dotted += "." + std::string((*it2)->as<MemberAccessExpression>().member.name);
            hp->VpiName(dotted);
            hp->VpiFullName(dotted);
            hp->VpiParent(parent);
            setLoc(hp, expr.sourceRange);
            auto* elems = s.MakeAnyVec();
            {
                auto* r = s.MakeRef_obj();
                r->VpiName(nv.symbol.name);
                // Freeze the lazily-computed fullname before parenting
                // (Surelog's refs cache name-only fullnames).
                (void)r->VpiFullName();
                r->VpiParent(hp);
                // Lvalue paths anchor the base ref at the FIRST member's
                // token span.
                if (inLhs && !chain.empty()) {
                    auto& fm = *chain.back();
                    auto end = fm.sourceRange.end();
                    setLoc(r, SourceRange(
                                  end - fm.as<MemberAccessExpression>().member.name.size(),
                                  end));
                }
                else {
                    setLoc(r, base->sourceRange);
                }
                elems->push_back(r);
            }
            for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                auto& ma = (*it2)->as<MemberAccessExpression>();
                auto* r = s.MakeRef_obj();
                r->VpiName(ma.member.name);
                (void)r->VpiFullName();
                // Only the last member of an rvalue path gets a fullname.
                if (!inLhs && *it2 == chain.front())
                    r->VpiFullName(prefix + "." + std::string(ma.member.name));
                r->VpiParent(hp);
                auto end = (*it2)->sourceRange.end();
                setLoc(r, SourceRange(end - ma.member.name.size(), end));
                elems->push_back(r);
            }
            hp->Path_elems(elems);
            return hp;
        }
        case ExpressionKind::SimpleAssignmentPattern: {
            auto& ap = expr.as<SimpleAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            bool wasInPattern = inAssignPattern;
            inAssignPattern = true;
            for (auto el : ap.elements()) {
                if (auto* e = emitExpr(*el, op, prefix, netMap)) {
                    // Re-emitted patterns size their FIRST operand. In the
                    // OUTERMOST pattern (a direct var initializer) Surelog
                    // resizes each bare-decimal element (default 64) to the
                    // element type; nested-pattern elements keep 64.
                    if (reemitting) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                    }
                    // A param-default pattern ('{0,1}) keeps its bare-decimal
                    // elements at 64 and leaves them UNparented (unlike a var
                    // initializer, which resizes each element to its type).
                    else if (inParamInit && !wasInPattern) {
                        if (e->UhdmType() == UHDM::uhdmconstant)
                            ((UHDM::expr*)e)->VpiParent(nullptr);
                    }
                    else if (!wasInPattern && e->UhdmType() == UHDM::uhdmconstant &&
                             ((UHDM::expr*)e)->VpiSize() == 64) {
                        ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                    }
                    operands->push_back(e);
                }
            }
            inAssignPattern = wasInPattern;
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::ReplicatedAssignmentPattern: {
            // '{N{a, b}} -> vpiMultiAssignmentPatternOp(count const, concat of
            // the replicated elements).
            auto& rap = expr.as<ReplicatedAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiMultiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* c = emitExpr(rap.count(), op, prefix, netMap)) {
                // The replication count is a 32-bit constant.
                if (c->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::expr*)c)->VpiSize() == 64)
                    ((UHDM::expr*)c)->VpiSize(32);
                operands->push_back(c);
            }
            auto* inner = s.MakeOperation();
            inner->VpiOpType(vpiConcatOp);
            inner->VpiParent(op);
            if (!rap.elements().empty())
                setLoc(inner, SourceRange(rap.elements().front()->sourceRange.start(),
                                          rap.elements().front()->sourceRange.end()));
            auto* innerOps = s.MakeAnyVec();
            for (auto el : rap.elements())
                if (auto* e = emitExpr(*el, inner, prefix, netMap))
                    innerOps->push_back(e);
            inner->Operands(innerOps);
            operands->push_back(inner);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::StructuredAssignmentPattern: {
            auto& ap = expr.as<StructuredAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // Tag key locations come from the pattern item syntax, matched
            // to member setters by name.
            const syntax::StructuredAssignmentPatternSyntax* psyn = nullptr;
            if (expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::AssignmentPatternExpression) {
                const syntax::AssignmentPatternSyntax* pat =
                    expr.syntax->as<syntax::AssignmentPatternExpressionSyntax>().pattern;
                if (pat && pat->kind == syntax::SyntaxKind::StructuredAssignmentPattern)
                    psyn = &pat->as<syntax::StructuredAssignmentPatternSyntax>();
            }
            for (auto& setter : ap.memberSetters) {
                // Re-emitted (instance) patterns drop the tags: operands are
                // the raw values, and the first one carries VpiSize.
                if (reemitting) {
                    if (auto* e = emitExpr(*setter.expr, op, prefix, netMap)) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)setter.expr->type->getBitWidth());
                        operands->push_back(e);
                    }
                    continue;
                }
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                setLoc(tp, setter.expr->sourceRange);
                // The pattern value parents at the OPERATION.
                if (auto* e = emitExpr(*setter.expr, op, prefix, netMap))
                    tp->Pattern((UHDM::expr*)e);
                // Tag: a string_typespec named by the member key.
                auto* sts = s.MakeString_typespec();
                sts->VpiName(setter.member->name);
                sts->VpiParent(tp);
                if (psyn) {
                    for (auto item : psyn->items) {
                        if (item->kind != syntax::SyntaxKind::AssignmentPatternItem)
                            continue;
                        auto& it2 = item->as<syntax::AssignmentPatternItemSyntax>();
                        if (rawText(it2.key->sourceRange()) == setter.member->name) {
                            setLoc(sts, it2.key->sourceRange());
                            break;
                        }
                    }
                }
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix);
                rt->VpiParent(tp);
                rt->Actual_typespec(sts);
                tp->Typespec(rt);
                operands->push_back(tp);
            }
            // Index setters ('{0:1, 3:1}): tagged_pattern with a string_typespec
            // tag named by the (source-text) index key.
            for (auto& setter : ap.indexSetters) {
                if (reemitting) {
                    if (auto* e = emitExpr(*setter.expr, op, prefix, netMap)) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)setter.expr->type->getBitWidth());
                        operands->push_back(e);
                    }
                    continue;
                }
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                setLoc(tp, setter.expr->sourceRange);
                bool sup0 = suppressConstParent, fcp0 = forceConstParent;
                suppressConstParent = true;
                forceConstParent = false;
                if (auto* e = emitExpr(*setter.expr, op, prefix, netMap))
                    tp->Pattern((UHDM::expr*)e);
                suppressConstParent = sup0;
                forceConstParent = fcp0;
                // Numeric index tag: an integer_typespec carrying the index
                // value (INT), located at the index span.
                auto* its = s.MakeInteger_typespec();
                setLoc(its, setter.index->sourceRange);
                {
                    ASTContext ictx(comp.getRoot(), LookupLocation::max);
                    ConstantValue icv = ictx.tryEval(*setter.index);
                    if (icv && icv.isInteger())
                        its->VpiValue(
                            "INT:" + icv.integer().toString(LiteralBase::Decimal, false));
                }
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix);
                rt->VpiParent(tp);
                rt->Actual_typespec(its);
                tp->Typespec(rt);
                operands->push_back(tp);
            }
            // Default setter ('{default: X}): tagged_pattern with a
            // string_typespec named "default" at the keyword span.
            if (ap.defaultSetter) {
                if (reemitting) {
                    if (auto* e = emitExpr(*ap.defaultSetter, op, prefix, netMap)) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)ap.defaultSetter->type->getBitWidth());
                        operands->push_back(e);
                    }
                }
                else {
                    auto* tp = s.MakeTagged_pattern();
                    tp->VpiParent(op);
                    setLoc(tp, ap.defaultSetter->sourceRange);
                    bool sup0 = suppressConstParent, fcp0 = forceConstParent;
                    suppressConstParent = true;
                    forceConstParent = false;
                    if (auto* e = emitExpr(*ap.defaultSetter, op, prefix, netMap))
                        tp->Pattern((UHDM::expr*)e);
                    suppressConstParent = sup0;
                    forceConstParent = fcp0;
                    auto* sts = s.MakeString_typespec();
                    sts->VpiName("default");
                    sts->VpiParent(tp);
                    if (psyn) {
                        for (auto item : psyn->items) {
                            if (item->kind != syntax::SyntaxKind::AssignmentPatternItem)
                                continue;
                            auto& it2 = item->as<syntax::AssignmentPatternItemSyntax>();
                            if (rawText(it2.key->sourceRange()) == "default") {
                                setLoc(sts, it2.key->sourceRange());
                                break;
                            }
                        }
                    }
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(prefix);
                    rt->VpiParent(tp);
                    rt->Actual_typespec(sts);
                    tp->Typespec(rt);
                    operands->push_back(tp);
                }
            }
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::HierarchicalValue: {
            // Cross-instance references (u1.cnt) share the member-access
            // hier_path shape; elements come from the dotted source text.
            std::string raw = rawText(expr.sourceRange);
            std::vector<std::pair<std::string, size_t>> parts;
            {
                size_t pos = 0;
                while (pos <= raw.size()) {
                    size_t dot = raw.find('.', pos);
                    if (dot == std::string::npos)
                        dot = raw.size();
                    parts.emplace_back(raw.substr(pos, dot - pos), pos);
                    if (dot == raw.size())
                        break;
                    pos = dot + 1;
                }
            }
            if (parts.size() < 2) {
                noteUnsupported("hierarchical reference form");
                return nullptr;
            }
            auto* hp = s.MakeHier_path();
            hp->VpiName(raw);
            hp->VpiFullName(raw);
            hp->VpiParent(parent);
            setLoc(hp, expr.sourceRange);
            auto* elems = s.MakeAnyVec();
            auto exprStart = expr.sourceRange.start();
            std::string dottedSoFar;
            for (size_t i = 0; i < parts.size(); i++) {
                auto& [pname, off] = parts[i];
                dottedSoFar += (i == 0 ? pname : "." + pname);
                // A gen-block / array index element (gen_blk[0]) is a
                // bit_select: name-only ref + a bare UINT index constant.
                auto lb = pname.find('[');
                auto rb = pname.find(']');
                if (lb != std::string::npos && rb != std::string::npos && rb > lb + 1 &&
                    pname.find_first_not_of("0123456789", lb + 1) == rb) {
                    std::string base = pname.substr(0, lb);
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(dottedSoFar);
                    setLoc(bs, SourceRange(exprStart + off, exprStart + off + base.size()));
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(idx);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + idx);
                    c->VpiConstType(vpiUIntConst);
                    size_t digitOff = off + lb + 1;
                    setLoc(c, SourceRange(exprStart + digitOff, exprStart + digitOff + idx.size()));
                    bs->VpiIndex(c);
                    elems->push_back(bs);
                    continue;
                }
                auto* r = s.MakeRef_obj();
                r->VpiName(pname);
                (void)r->VpiFullName();
                // Only the last element of an rvalue path gets a fullname.
                if (!inLhs && i + 1 == parts.size())
                    r->VpiFullName(prefix + "." + pname);
                r->VpiParent(hp);
                // Lvalue paths anchor the base ref at the SECOND element.
                size_t locIdx = (inLhs && i == 0 && parts.size() > 1) ? 1 : i;
                auto& [lname, loff] = parts[locIdx];
                setLoc(r, SourceRange(exprStart + loff, exprStart + loff + lname.size()));
                elems->push_back(r);
            }
            hp->Path_elems(elems);
            return hp;
        }
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
