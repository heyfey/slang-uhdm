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

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr, const Expression* typedConv) {
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
    // Expressions CONTAINING unbased-unsized literals ('0 << 8) never fold:
    // Surelog's folded model re-emits the operation.
    {
        bool hasUnbased = false;
        expr.visit(makeVisitor([&](auto& v, const UnbasedUnsizedIntegerLiteral& u) {
            hasUnbased = true;
            v.visitDefault(u);
        }));
        // Only OPERATIONS over unbased literals stay unfolded (casts and
        // direct literals still fold — param defaults/size casts re-encode).
        auto k0 = stripImplicitConv(expr).kind;
        if (hasUnbased &&
            (k0 == ExpressionKind::BinaryOp || k0 == ExpressionKind::UnaryOp ||
             k0 == ExpressionKind::ConditionalOp ||
             k0 == ExpressionKind::Concatenation))
            return nullptr;
    }
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    ConstantValue cv = ctx.tryEval(expr);
    if (!cv || !cv.isInteger())
        return nullptr;
    slang::SVInt iv = cv.integer();
    // A CONCAT with x/z bits ({12'h800, 4'b001x, 16'bx...}) still folds — to
    // a full-width BINARY constant preserving the 0/1/x/z bits. Other
    // unknown-valued expressions refuse.
    if (iv.hasUnknown()) {
        if (stripImplicitConv(expr).kind != ExpressionKind::Concatenation)
            return nullptr;
        auto* c = s.MakeConstant();
        c->VpiSize((int32_t)expr.type->getBitWidth());
        std::string bits;
        for (int32_t i = (int32_t)expr.type->getBitWidth() - 1; i >= 0; i--) {
            auto b = iv[i];
            bits += b.isUnknown() ? (b.value == slang::logic_t::Z_VALUE ? 'z' : 'x')
                    : (b.value ? '1' : '0');
        }
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        c->VpiDecompile(std::to_string((int32_t)expr.type->getBitWidth()) + "'b" +
                        bits);
        return c;
    }
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
        // Only a size cast that actually yields a NEGATIVE value (truncation
        // sets the new high bit) reinterprets as signed; a positive result
        // (32'(1)) stays unsigned.
        if (signedSizeCast) {
            int w = (int)sc.type->getBitWidth();
            uint64_t uv = iv.as<uint64_t>().value_or(0);
            if (!(w > 0 && w < 64 && (uv & (1ULL << (w - 1)))))
                signedSizeCast = false;
        }
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
    if (iv.isSigned() && iv.isNegative()) {
        if (!typedConv)
            return nullptr;
        // A SIGNED integral typed param keeps the negative value as a signed
        // INT constant at the type width (integer y = -1 -> INT:-1/32). An
        // UNSIGNED typed param instead re-folds the negative intermediate
        // (logic[17:0] X = ~(15) -> UINT:262128) through its conversion to
        // the unsigned type width. The TARGET (param) type governs — NOT the
        // init expression's self-determined type (~(15) is self-typed int).
        if (!(typedConv->type && typedConv->type->isSigned() &&
              typedConv->type->isIntegral())) {
            ConstantValue cv2 = ctx.tryEval(*typedConv);
            if (!cv2 || !cv2.isInteger())
                return nullptr;
            slang::SVInt iv2 = cv2.integer();
            if (iv2.hasUnknown() || (iv2.isSigned() && iv2.isNegative()))
                return nullptr;
            iv = iv2;
        }
    }
    // A folded CONCAT encodes as full-width binary, with no decompile.
    if (stripImplicitConv(expr).kind == ExpressionKind::Concatenation) {
        auto* c = s.MakeConstant();
        c->VpiSize((int32_t)expr.type->getBitWidth());
        std::string bits;
        for (int32_t i = (int32_t)expr.type->getBitWidth() - 1; i >= 0; i--)
            bits += (iv[i] == slang::logic_t(1)) ? '1' : '0';
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        return c;
    }
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
    // A NEGATIVE signed result always encodes as a signed INT (Surelog):
    // integer y = -1 -> INT:-1, never UINT:-1 (which serializes as 0).
    else if (isIntEncoded(expr) || (iv.isSigned() && iv.isNegative())) {
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
            // A signed power (2**n) reduces to a signed (INT) constant.
            if (be.op == BinaryOperator::Power && e.type && e.type->isSigned())
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

// A dotted interface-member reference (s.req.adr): hier_path whose ref_obj
// elements anchor at their own token; the LAST element carries the
// module-scoped fullname (work@mod.<last>) — Surelog quirk.
UHDM::hier_path* UhdmExporter::buildDottedHierPath(const Expression& expr,
                                                   const std::string& dotted,
                                                   UHDM::BaseClass* parent,
                                                   const std::string& prefix) {
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    setLoc(hp, expr.sourceRange);
    // this.member: the hier_path spans the `this` token; the this ref
    // anchors at the MEMBER token; the member ref is loc-less with a
    // scope-prefixed fullname.
    if (dotted.rfind("this.", 0) == 0 && dotted.find('.', 5) == std::string::npos) {
        std::string member = dotted.substr(5);
        auto st = expr.sourceRange.start();
        setLoc(hp, SourceRange(st, st + 4));
        auto* elems = s.MakeAnyVec();
        auto* rt = s.MakeRef_obj();
        rt->VpiName("this");
        rt->VpiFullName("this");
        rt->VpiParent(hp);
        setLoc(rt, SourceRange(st + 5, st + 5 + member.size()));
        elems->push_back(rt);
        auto* rm = s.MakeRef_obj();
        rm->VpiName(member);
        rm->VpiFullName(joinRef(prefix, member));
        rm->VpiParent(hp);
        elems->push_back(rm);
        hp->Path_elems(elems);
        return hp;
    }
    auto* elems = s.MakeAnyVec();
    auto exprStart = expr.sourceRange.start();
    // Split into (name, offset) components.
    std::vector<std::pair<std::string, size_t>> parts;
    for (size_t start = 0; start <= dotted.size();) {
        auto dot = dotted.find('.', start);
        if (dot == std::string::npos)
            dot = dotted.size();
        parts.emplace_back(dotted.substr(start, dot - start), start);
        if (dot == dotted.size())
            break;
        start = dot + 1;
    }
    for (size_t i = 0; i < parts.size(); i++) {
        auto& [pname, off] = parts[i];
        auto* r = s.MakeRef_obj();
        r->VpiName(pname);
        // Only the last element of an RVALUE path gets a scoped fullname; the
        // others cache a NAME-ONLY fullname (the dump omits fullname == name,
        // and it blocks the dump-time lazy scoped recompute).
        if (!inLhs && i + 1 == parts.size())
            r->VpiFullName(prefix + "." + pname);
        else
            r->VpiFullName(pname);
        r->VpiParent(hp);
        // Lvalue paths anchor the base ref at the SECOND element's span.
        size_t locIdx = (inLhs && i == 0 && parts.size() > 1) ? 1 : i;
        auto& [lname, loff] = parts[locIdx];
        setLoc(r, SourceRange(exprStart + loff, exprStart + loff + lname.size()));
        elems->push_back(r);
    }
    hp->Path_elems(elems);
    return hp;
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
    // A base multi-dim select LVALUE anchors the hier_path at the base name;
    // an RVALUE spans the whole path (a[0][0].min_v).
    setLoc(hp, (baseSelMode && inLhs) ? comps[0].nameSpan : expr.sourceRange);
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
                // Base-select index constants parent to the bit_select when:
                //  - an ELAB cont-assign LHS single-dim select (flash_rsp_o[0]
                //    .ack), or a multi-dim PACKED select whose RHS re-elaborates
                //    (group_status[0][0].a = 1'b1); or
                //  - a re-elaborated RVALUE select into a PACKED array
                //    (int'(a[0][0].min_v)).
                // A multi-dim UNPACKED select (a[0][0].x), a packed LHS with a
                // plain-ref RHS (int_port_signed), and the def view stay
                // unparented.
                bool basePacked = baseNv->symbol.getType().isPackedArray();
                bool doParent =
                    (inLhs && elabContAssignLhs &&
                     (comp.sels.size() == 1 || (basePacked && elabLhsReelab))) ||
                    (!inLhs && reemitting && basePacked);
                bool savedSCP = suppressConstParent;
                if (!doParent)
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
                // Trailing member of a base-select path: an RVALUE resolves to
                // the struct member's own fullname (work@top.min_v); an LVALUE
                // keeps the dotted path.
                if (!inLhs && lastMember)
                    r->VpiFullName(prefix + "." + comp.name);
                else
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

// A property-decl FORMAL reference: property-scoped ref bound to an implicit
// module wire minted at the first use (Surelog leaks formals as module nets).
UHDM::ref_obj* UhdmExporter::emitPropFormalRef(std::string_view nm, SourceRange nr,
                                               UHDM::BaseClass* parent,
                                               const std::string& prefix) {
    if (!propDeclScope)
        return nullptr;
    auto* fsym = propDeclScope->find(nm);
    if (!fsym || fsym->kind != SymbolKind::AssertionPort)
        return nullptr;
    auto* ref = s.MakeRef_obj();
    ref->VpiName(nm);
    ref->VpiFullName(joinRef(prefix, std::string(nm)));
    ref->VpiParent(parent);
    setLoc(ref, nr);
    auto& inet = implicitNetMap[fsym];
    if (!inet && implicitNetModule) {
        inet = s.MakeLogic_net();
        inet->VpiName(nm);
        inet->VpiFullName(implicitNetPrefix + "." + std::string(nm));
        inet->VpiParent(implicitNetModule);
        inet->VpiNetType(1);
        setLoc(inet, nr);
        auto* nets = implicitNetModule->Nets();
        if (!nets) {
            nets = s.MakeNetVec();
            implicitNetModule->Nets(nets);
        }
        nets->push_back(inet);
    }
    if (inet)
        ref->Actual_group(inet);
    return ref;
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
            // An EMBEDDED assignment expression (x = (y = ...) + 1) — one used
            // as an OPERAND or as another assignment's RHS — is an
            // operation(vpiAssignmentOp=82) with [lhs, rhs] operands
            // (paren-inclusive span); a STATEMENT-level assignment (parent is
            // a block/process) stays an assignment object (handled below).
            if (parent &&
                (parent->UhdmType() == UHDM::uhdmoperation ||
                 parent->UhdmType() == UHDM::uhdmassignment) &&
                !ae.isCompound()) {
                auto* op = s.MakeOperation();
                op->VpiOpType(kVpiAssignmentOp);
                op->VpiParent(parent);
                // The span reaches the enclosing parentheses.
                SourceRange sr = expr.sourceRange;
                if (expr.syntax &&
                    expr.syntax->kind == syntax::SyntaxKind::ParenthesizedExpression)
                    sr = expr.syntax->sourceRange();
                setLoc(op, sr);
                auto* operands = s.MakeAnyVec();
                // The LHS ref parents at the ENCLOSING assignment context,
                // not this op.
                UHDM::BaseClass* lhsParent = enclosingAssign ? enclosingAssign : op;
                inLhs = true;
                if (auto* l = emitExpr(ae.left(), lhsParent, prefix, netMap))
                    operands->push_back(l);
                inLhs = false;
                // A DIRECT leaf-constant RHS (z = 99) unparents; a nested op
                // RHS ((z=99)+1) self-parents and its operands parent
                // normally. This op is the enclosing context for the RHS.
                auto* savedEncl = enclosingAssign;
                enclosingAssign = op;
                bool savedS = suppressConstParent;
                if (isLiteralExpr(stripImplicitConv(ae.right())))
                    suppressConstParent = true;
                if (auto* r = emitExpr(ae.right(), op, prefix, netMap))
                    operands->push_back(r);
                suppressConstParent = savedS;
                enclosingAssign = savedEncl;
                op->Operands(operands);
                return op;
            }
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
            if (auto* lhs = emitExpr(ae.left(), asn, prefix, netMap)) {
                asn->Lhs((UHDM::expr*)lhs);
                // A class-handle assignment (bar = new()) re-parents its Lhs
                // ref through an artifact hier_path (weakly-tail only).
                if (stripImplicitConv(*rhsExpr).kind == ExpressionKind::NewClass &&
                    lhs->UhdmType() == UHDM::uhdmref_obj) {
                    auto* hp = s.MakeHier_path();
                    hp->VpiName(((UHDM::ref_obj*)lhs)->VpiName());
                    hp->VpiFullName(((UHDM::ref_obj*)lhs)->VpiName());
                    hp->VpiParent(asn);
                    auto* elems = s.MakeAnyVec();
                    elems->push_back(lhs);
                    hp->Path_elems(elems);
                    lhs->VpiParent(hp);
                    ((UHDM::ref_obj*)lhs)->Actual_group(nullptr);
                }
            }
            inLhs = false;
            // This assignment is the enclosing context for any embedded
            // assignment expressions in its RHS.
            auto* savedEncl0 = enclosingAssign;
            enclosingAssign = asn;
            auto* rhs = emitExpr(*rhsExpr, asn, prefix, netMap);
            enclosingAssign = savedEncl0;
            if (rhs) {
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
                // Function-call ARGS keep a pkg-scoped ref (named pkg::P,
                // anchored at the package-qualifier span) bound to the
                // package's def parameter object.
                if (parent && (parent->UhdmType() == UHDM::uhdmfunc_call ||
                               parent->UhdmType() == UHDM::uhdmtask_call)) {
                    std::string pn = std::string(scope->asSymbol().name) + "::" +
                                     std::string(nv.symbol.name);
                    ref->VpiName(pn);
                    ref->VpiFullName(pn);
                    ref->VpiParent(parent);
                    if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                ref->Actual_group(pp2);
                    setLoc(ref, SourceRange(expr.sourceRange.start(),
                                            expr.sourceRange.start() +
                                                scope->asSymbol().name.size() + 2));
                    return ref;
                }
                // Module-side references to package params are folded inline
                // to constants carrying the reference's location. STRUCT/UNION
                // typed pkg params stay refs bound to the pkg parameter
                // (Surelog keeps the ref_obj).
                auto& psym = nv.symbol.as<ParameterSymbol>();
                auto ckP = psym.getType().getCanonicalType().kind;
                if (ckP == SymbolKind::PackedStructType ||
                    ckP == SymbolKind::PackedUnionType) {
                    std::string pn = std::string(scope->asSymbol().name) + "::" +
                                     std::string(nv.symbol.name);
                    ref->VpiName(pn);
                    ref->VpiParent(parent);
                    if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                ref->Actual_group(pp2);
                    setLoc(ref, SourceRange(expr.sourceRange.start(),
                                            expr.sourceRange.start() +
                                                scope->asSymbol().name.size() + 2));
                    return ref;
                }
                // A PACKAGE param initialized by ANOTHER package's qualified
                // param keeps a doubled-scope ref_obj (pkg::otherpkg::P) bound
                // to that param — Surelog does not fold a cross-package
                // pkg-param ref inside a package init.
                if (paramInitPkg) {
                    std::string curPkg = prefix;
                    if (auto p2 = curPkg.find("::"); p2 != std::string::npos)
                        curPkg.resize(p2);
                    if (curPkg != std::string(scope->asSymbol().name)) {
                        std::string pn = std::string(scope->asSymbol().name) +
                                         "::" + std::string(nv.symbol.name);
                        ref->VpiName(pn);
                        ref->VpiParent(parent);
                        std::string full = prefix;
                        if (full.size() < 2 ||
                            full.compare(full.size() - 2, 2, "::") != 0)
                            full += "::";
                        ref->VpiFullName(full + pn);
                        if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                            pit2 != pkgDefMap.end() && pit2->second->Parameters())
                            for (auto* pp2 : *pit2->second->Parameters())
                                if (pp2->VpiName() == nv.symbol.name)
                                    ref->Actual_group(pp2);
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                }
                auto& cv = psym.getValue();
                if (cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    // TYPED pkg params fold at the type width; untyped at 64.
                    bool typedPkgParam = false;
                    if (auto d0 = psym.getDeclaredType())
                        if (auto t0 = d0->getTypeSyntax())
                            typedPkgParam =
                                t0->kind != syntax::SyntaxKind::ImplicitType;
                    c->VpiSize(typedPkgParam
                                   ? (int32_t)psym.getType().getBitWidth()
                                   : 64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    setLoc(c, expr.sourceRange);
                    if (parent && parent->UhdmType() == UHDM::uhdmoperation)
                        c->VpiParent(parent);
                    // A def-view cont-assign fold that READS an IMPORTED param
                    // carries a ref_typespec to the imported param's def
                    // typespec (module-named, instanced at the package) — the
                    // fold is a resolved copy of a typed param (Surelog).
                    if (parent && parent->UhdmType() == UHDM::uhdmcont_assign)
                        if (auto tit = importedParamDefTs.find(&nv.symbol);
                            tit != importedParamDefTs.end()) {
                            auto* rt = s.MakeRef_typespec();
                            rt->VpiFullName(prefix);
                            rt->VpiParent(c);
                            rt->Actual_typespec(tit->second);
                            c->Typespec(rt);
                        }
                    return c;
                }
                ref->VpiFullName(std::string(scope->asSymbol().name) + "::" +
                                 std::string(nv.symbol.name));
            }
            else {
                // A PACKAGE enum-const reference in a module expression folds
                // to a constant carrying the enum const's own encoding, at
                // the reference's span.
                if (nv.symbol.kind == SymbolKind::EnumValue) {
                    bool inPkg = false;
                    for (auto sc2 = nv.symbol.getParentScope(); sc2;
                         sc2 = sc2->asSymbol().getParentScope()) {
                        if (sc2->asSymbol().kind == SymbolKind::Package) {
                            inPkg = true;
                            break;
                        }
                        if (sc2->asSymbol().kind == SymbolKind::InstanceBody)
                            break;
                    }
                    // Only MODULE contexts fold; interfaces keep the ref.
                    if (inPkg) {
                        const UHDM::BaseClass* pw = parent;
                        while (pw && pw->UhdmType() != UHDM::uhdmmodule_inst &&
                               pw->UhdmType() != UHDM::uhdminterface_inst &&
                               pw->UhdmType() != UHDM::uhdmpackage)
                            pw = pw->VpiParent();
                        if (!pw || pw->UhdmType() != UHDM::uhdmmodule_inst)
                            inPkg = false;
                    }
                    if (inPkg) {
                        if (auto eit2 = enumConstMap.find(&nv.symbol);
                            eit2 != enumConstMap.end() &&
                            eit2->second->UhdmType() == UHDM::uhdmenum_const) {
                            auto* src = (UHDM::enum_const*)eit2->second;
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(src->VpiDecompile());
                            c->VpiSize(src->VpiSize());
                            std::string_view v = src->VpiValue();
                            c->VpiValue(std::string(v));
                            c->VpiConstType(v.rfind("BIN:", 0) == 0   ? vpiBinaryConst
                                            : v.rfind("HEX:", 0) == 0 ? vpiHexConst
                                            : v.rfind("OCT:", 0) == 0 ? vpiOctConst
                                            : v.rfind("DEC:", 0) == 0 ? vpiDecConst
                                                                      : vpiUIntConst);
                            setLoc(c, expr.sourceRange);
                            if (!suppressConstParent && parent &&
                                parent->UhdmType() == UHDM::uhdmoperation)
                                c->VpiParent(parent);
                            return c;
                        }
                    }
                }
                ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                if (suppressRefActual) {
                    // Gen-scope process ref: left unbound.
                }
                else if (auto it = netMap.find(&nv.symbol); it != netMap.end()) {
                    ref->Actual_group(it->second);
                    // Whole ref: may be re-pointed to a select object if this
                    // variable is written via a select elsewhere in the body.
                    if (selTrackActive)
                        selWholeRefs.push_back({ref, &nv.symbol});
                }
                else if (auto eit = enumConstMap.find(&nv.symbol); eit != enumConstMap.end())
                    ref->Actual_group(eit->second);
                else if (auto uit = unitParamMap.find(&nv.symbol);
                         uit != unitParamMap.end())
                    // $unit params bind the design-level parameter.
                    ref->Actual_group(uit->second);

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
            // Def-view param inits, cont-assigns AND process bodies leave a
            // DIRECT-literal unary operand unparented (~(15), -1, a = -4);
            // binary operands and nested expressions (~A[3]) keep the
            // normal rules.
            bool savedS = suppressConstParent, savedF = forceConstParent;
            if ((paramInitDef || inProcessEmit) && isLiteralExpr(ue.operand())) {
                suppressConstParent = true;
                forceConstParent = false;
            }
            if (auto* e = emitExpr(ue.operand(), op, prefix, netMap))
                operands->push_back(e);
            suppressConstParent = savedS;
            forceConstParent = savedF;
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
            setLocCompact(op, expr.sourceRange);
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
            // Spaced based literals (8'd 3) re-lex compactly; the span
            // shrinks by the removed whitespace.
            size_t spc = basedLiteralSpaceCount(raw);
            if (spc) {
                std::string comp;
                comp.reserve(raw.size());
                for (size_t i = 0; i < raw.size(); i++) {
                    comp += raw[i];
                    if (raw[i] != '\'')
                        continue;
                    size_t j = i + 1;
                    if (j < raw.size() && (raw[j] == 's' || raw[j] == 'S'))
                        comp += raw[j++];
                    if (j < raw.size()) {
                        char b = (char)tolower(raw[j]);
                        if (b == 'd' || b == 'h' || b == 'b' || b == 'o') {
                            comp += raw[j++];
                            while (j < raw.size() &&
                                   (raw[j] == ' ' || raw[j] == '\t'))
                                j++;
                        }
                    }
                    i = j - 1;
                }
                raw = comp;
            }
            // Digit-separator underscores (4'b001x, xxxx_xxxx) are removed in
            // both the decompile and the value (Surelog quirk).
            if (raw.find('\'') != std::string::npos)
                raw.erase(std::remove(raw.begin(), raw.end(), '_'), raw.end());
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)expr.type->getBitWidth());
            if (spc)
                setLoc(c, SourceRange(expr.sourceRange.start(),
                                      expr.sourceRange.end() - spc));
            else
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
                // Surelog quirk: a 1-bit 'x' value (1'bx) formats uppercase in
                // both the decompile and the value; 1-bit 'z' and multi-bit
                // x/z stay lowercase.
                if (expr.type->getBitWidth() == 1 && digits.size() == 1 &&
                    (digits[0] == 'x' || digits[0] == 'X')) {
                    digits = "X";
                    std::string dec = raw;
                    dec.back() = 'X';
                    c->VpiDecompile(dec);
                }
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
                // A signed based literal (1'sb1) carries a signed int_typespec
                // ref; the int_typespec lands in the weaklyReferenced tail.
                if (tick + 1 < raw.size() &&
                    (raw[tick + 1] == 's' || raw[tick + 1] == 'S')) {
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiParent(c);
                    auto* its = s.MakeInt_typespec();
                    its->VpiSigned(true);
                    rt->Actual_typespec(its);
                    c->Typespec(rt);
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
            // Nested casts (int'($clog2(X)'(X))) lose the INNER conversion's
            // syntax; the outer emission passes it down via castSynOverride.
            const syntax::SyntaxNode* effCastSyn = expr.syntax;
            if ((!effCastSyn ||
                 effCastSyn->kind != syntax::SyntaxKind::CastExpression) &&
                castSynOverride)
                effCastSyn = castSynOverride;
            castSynOverride = nullptr;
            // A COMPILER-INSERTED string conversion of a string literal (the
            // implicit string context of {NAME, "efgh"}) carries no cast
            // syntax — Surelog emits the bare string constant, no cast op.
            if (expr.type && expr.type->isString() &&
                stripImplicitConv(conv.operand()).kind == ExpressionKind::StringLiteral &&
                (!effCastSyn ||
                 effCastSyn->kind != syntax::SyntaxKind::CastExpression))
                return emitExpr(stripImplicitConv(conv.operand()), parent, prefix,
                                netMap);
            // A cast around a streaming concat is dropped (Surelog emits the
            // stream operation directly).
            if (stripImplicitConv(conv.operand()).kind == ExpressionKind::Streaming)
                return emitExpr(stripImplicitConv(conv.operand()), parent, prefix,
                                netMap);
            // Explicit cast: operation(vpiCastOp) with a typespec ref.
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCastOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            UHDM::typespec* cts = nullptr;
            // Size casts ("4'(x)") carry an integer_typespec at the size
            // literal; type casts use the target type's typespec.
            if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::SignedCastExpression) {
                noteUnsupported("signed cast form");
            }
            bool deferredCast = false;
            if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                auto& cesyn = effCastSyn->as<syntax::CastExpressionSyntax>();
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
                else if (expr.type && expr.type->kind == SymbolKind::TypeAlias &&
                         typedefTs.count(expr.type)) {
                    // A cast to a NAMED typedef (my_struct'(a)): the shared
                    // typedef typespec is the cast target. In a $UNIT
                    // function body, a VECTOR-typedef cast gets a FRESH
                    // clone with a Typedef_alias ref instead.
                    cts = typedefTs[expr.type];
                    if (currentSubSym && cts->UhdmType() == UHDM::uhdmlogic_typespec) {
                        auto ps0 = currentSubSym->getParentScope();
                        if (ps0 &&
                            ps0->asSymbol().kind == SymbolKind::CompilationUnit) {
                            auto& ta2 = expr.type->as<TypeAliasType>();
                            const syntax::SyntaxNode* tSyn2 = nullptr;
                            if (auto asyn2 = ta2.getSyntax())
                                if (asyn2->kind ==
                                    syntax::SyntaxKind::TypedefDeclaration)
                                    tSyn2 = asyn2->as<
                                                    syntax::TypedefDeclarationSyntax>()
                                                .type;
                            bypassTypedefShare = true;
                            bool savedTf2 = tfContext;
                            tfContext = true;
                            auto* cl2 = makeTypespec(ta2, tSyn2);
                            tfContext = savedTf2;
                            bypassTypedefShare = false;
                            cl2->VpiName(ta2.name);
                            auto* art2 = s.MakeRef_typespec();
                            art2->VpiFullName(std::string(ta2.name));
                            art2->VpiParent(cl2);
                            art2->Actual_typespec(cts);
                            ((UHDM::logic_typespec*)cl2)->Typedef_alias(art2);
                            cts = cl2;
                        }
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
                    // A BARE parameter width (P'(x)) mints a fresh NAMED
                    // int_typespec carrying the param's folded value, at a
                    // zero-width span on the param name token (per cast site).
                    auto& seCore = stripImplicitConv(sizeExpr);
                    if (seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        cesyn.left->kind == syntax::SyntaxKind::IdentifierName) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        auto* its = s.MakeInt_typespec();
                        its->VpiName(psym.name);
                        setLoc(its, SourceRange(psym.location, psym.location));
                        auto& pv = psym.as<ParameterSymbol>().getValue();
                        if (pv.isInteger() && !pv.integer().hasUnknown())
                            its->VpiValue(
                                "UINT:" +
                                pv.integer().toString(LiteralBase::Decimal, false));
                        cts = its;
                    }
                    // A PACKAGE-scoped parameter width (pkg::P'(x)) mints a
                    // BARE int_typespec: no name, no loc, just the folded
                    // UINT value.
                    if (!cts && seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        cesyn.left->kind == syntax::SyntaxKind::ScopedName) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        if (auto psc = psym.getParentScope();
                            psc && psc->asSymbol().kind == SymbolKind::Package) {
                            auto* its = s.MakeInt_typespec();
                            auto& pv = psym.as<ParameterSymbol>().getValue();
                            if (pv.isInteger() && !pv.integer().hasUnknown())
                                its->VpiValue(
                                    "UINT:" +
                                    pv.integer().toString(LiteralBase::Decimal, false));
                            cts = its;
                        }
                    }
                    // A PARENTHESIZED parameter width ((P)'(x)) reuses the
                    // param's own int_typespec as the cast target; that ts
                    // gains a loc-less vpiExpr ref_obj with a param-doubled
                    // fullname (work@top.P.P) bound to the def parameter.
                    // Only for a function DIRECTLY in the module: a function
                    // inside an elaborated GENERATE block builds a FRESH
                    // integer_typespec at the cast site instead (its params
                    // fold), so skip the param-reuse there.
                    bool inGenBlockFn = false;
                    if (currentSubSym)
                        for (auto gsc = currentSubSym->getParentScope(); gsc;
                             gsc = gsc->asSymbol().getParentScope()) {
                            auto gk = gsc->asSymbol().kind;
                            if (gk == SymbolKind::GenerateBlock ||
                                gk == SymbolKind::GenerateBlockArray) {
                                inGenBlockFn = true;
                                break;
                            }
                            if (gk == SymbolKind::InstanceBody)
                                break;
                        }
                    if (!cts && !inGenBlockFn &&
                        seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        if (auto psc = psym.getParentScope();
                            psc && psc->asSymbol().kind == SymbolKind::InstanceBody) {
                            auto dit = defMap.find(
                                &psc->asSymbol().as<InstanceBodySymbol>().getDefinition());
                            if (dit != defMap.end()) {
                                auto pit = dit->second.paramTs.find(&psym);
                                if (pit != dit->second.paramTs.end() &&
                                    pit->second->UhdmType() == UHDM::uhdmint_typespec) {
                                    auto* ipts = (UHDM::int_typespec*)pit->second;
                                    if (!ipts->Cast_to_expr()) {
                                        UHDM::parameter* pobj = nullptr;
                                        if (dit->second.mod && dit->second.mod->Parameters())
                                            for (auto* pp : *dit->second.mod->Parameters())
                                                if (pp->VpiName() == psym.name)
                                                    pobj = (UHDM::parameter*)pp;
                                        auto* r = s.MakeRef_obj();
                                        r->VpiName(psym.name);
                                        r->VpiParent(ipts);
                                        if (pobj) {
                                            r->VpiFullName(
                                                std::string(pobj->VpiFullName()) + "." +
                                                std::string(psym.name));
                                            r->Actual_group(pobj);
                                        }
                                        ipts->Cast_to_expr(r);
                                    }
                                    cts = ipts;
                                }
                            }
                        }
                    }
                    if (!cts) {
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
            }
            if (deferredCast) {
                auto* operandsD = s.MakeAnyVec();
                if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                    operandsD->push_back(e);
                op->Operands(operandsD);
                return op;
            }
            if (!cts && effCastSyn &&
                effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                auto it2 = castTsCache.find(
                    effCastSyn->as<syntax::CastExpressionSyntax>().left);
                if (it2 != castTsCache.end())
                    cts = it2->second;
            }
            // A NESTED-cast operand emits FIRST (its typespec precedes the
            // outer's in the arena), with the inner CastExpression syntax
            // recovered from the outer's parenthesized operand.
            UHDM::any* nestedOperand = nullptr;
            if (!cts && effCastSyn &&
                effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                const Expression* c1p = &conv.operand();
                while (c1p->kind == ExpressionKind::Conversion &&
                       c1p->as<ConversionExpression>().isImplicit())
                    c1p = &c1p->as<ConversionExpression>().operand();
                auto& c1 = *c1p;
                if (c1.kind == ExpressionKind::Conversion &&
                    !c1.as<ConversionExpression>().isImplicit() &&
                    (!c1.syntax ||
                     c1.syntax->kind != syntax::SyntaxKind::CastExpression)) {
                    const syntax::ExpressionSyntax* rsyn =
                        effCastSyn->as<syntax::CastExpressionSyntax>()
                            .right->expression;
                    while (rsyn &&
                           rsyn->kind == syntax::SyntaxKind::ParenthesizedExpression)
                        rsyn = rsyn->as<syntax::ParenthesizedExpressionSyntax>()
                                   .expression;
                    if (rsyn && rsyn->kind == syntax::SyntaxKind::CastExpression) {
                        castSynOverride = rsyn;
                        nestedOperand = emitExpr(c1, op, prefix, netMap);
                        castSynOverride = nullptr;
                    }
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
                if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::CastExpression)
                    setLoc(cts, effCastSyn->as<syntax::CastExpressionSyntax>().left->sourceRange());
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
            // $UNIT-function bodies leave DIRECT formal refs under a cast
            // unbound (Surelog quirk).
            bool unitFnCast = false;
            if (currentSubSym)
                if (auto ps0 = currentSubSym->getParentScope();
                    ps0 && ps0->asSymbol().kind == SymbolKind::CompilationUnit)
                    unitFnCast = stripImplicitConv(conv.operand()).kind ==
                                 ExpressionKind::NamedValue;
            bool savedSRA = suppressRefActual;
            if (unitFnCast)
                suppressRefActual = true;
            if (nestedOperand)
                operands->push_back(nestedOperand);
            else if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                operands->push_back(e);
            suppressRefActual = savedSRA;
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::Call: {
            auto& call = expr.as<CallExpression>();
            if (!call.isSystemCall()) {
                callStmtContext = false;
                auto& sub = *std::get<const SubroutineSymbol*>(call.subroutine);
                // Class METHOD calls (bar.set(4)): a method_func_call at the
                // method token, with an UNBOUND receiver ref as vpiPrefix.
                if (auto psc0 = sub.getParentScope();
                    psc0 && psc0->asSymbol().kind == SymbolKind::ClassType &&
                    call.thisClass()) {
                    auto* mfc = s.MakeMethod_func_call();
                    mfc->VpiName(sub.name);
                    mfc->VpiParent(parent);
                    auto& recv = *call.thisClass();
                    setLoc(mfc, nameSpan(recv.sourceRange.end() + 1, sub.name));
                    auto& rb = stripImplicitConv(recv);
                    if (rb.kind == ExpressionKind::NamedValue) {
                        auto* pr = s.MakeRef_obj();
                        pr->VpiName(rb.as<NamedValueExpression>().symbol.name);
                        pr->VpiFullName(joinRef(
                            prefix, rb.as<NamedValueExpression>().symbol.name));
                        pr->VpiParent(mfc);
                        setLoc(pr, recv.sourceRange);
                        mfc->Prefix(pr);
                    }
                    auto* margs = s.MakeAnyVec();
                    for (auto arg : call.arguments()) {
                        bool fs2 = forceConstParent;
                        if (isLiteralExpr(*arg))
                            forceConstParent = true;
                        if (auto* a2 = emitExpr(*arg, mfc, prefix, netMap))
                            margs->push_back(a2);
                        forceConstParent = fs2;
                    }
                    if (!margs->empty())
                        mfc->Tf_call_args(margs);
                    return mfc;
                }
                auto it = subMap.find(&sub);
                if (it == subMap.end()) {
                    // Calls seen before the def fill (param inits): create a
                    // shell now; emitTaskFuncs fills it later.
                    auto pscope = sub.getParentScope();
                    if (pscope && (pscope->asSymbol().kind == SymbolKind::InstanceBody ||
                                   pscope->asSymbol().kind == SymbolKind::Package)) {
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
                // Param-init calls and LHS bit-select INDEX calls
                // (intermediate[depth2Index(1)] = ...) anchor at the name.
                if (inParamInit || inLhs)
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
                    // An UNBASED-UNSIZED literal arg ('1): the def-view
                    // cont-assign copy stays bare (no formal-ts ref); the elab
                    // copy folds to the formal's width (repeated digit BIN).
                    bool unbasedArg =
                        stripImplicitConv(*arg).kind ==
                        ExpressionKind::UnbasedUnsizedIntegerLiteral;
                    if (unbasedArg && contAssignView == 2 && a &&
                        a->UhdmType() == UHDM::uhdmconstant && arg->type) {
                        logic_t ab = stripImplicitConv(*arg)
                                         .as<UnbasedUnsizedIntegerLiteral>()
                                         .getLiteralValue();
                        if (!ab.isUnknown()) {
                            int32_t w = (int32_t)arg->type->getBitWidth();
                            std::string digits((size_t)w, ab.value ? '1' : '0');
                            auto* ac = (UHDM::constant*)a;
                            ac->VpiDecompile(digits);
                            ac->VpiSize(w);
                            ac->VpiValue("BIN:" + digits);
                        }
                    }
                    if (a) {
                        // Function call arg refs carry a typespec ref to the
                        // formal's typespec (tasks don't; procedural-context
                        // calls don't either).
                        bool refArg = a->UhdmType() == UHDM::uhdmref_obj ||
                                      a->UhdmType() == UHDM::uhdmbit_select ||
                                      a->UhdmType() == UHDM::uhdmpart_select ||
                                      a->UhdmType() == UHDM::uhdmindexed_part_select;
                        bool otherArg = a->UhdmType() == UHDM::uhdmconstant ||
                                        a->UhdmType() == UHDM::uhdmfunc_call ||
                                        a->UhdmType() == UHDM::uhdmoperation;
                        // Only outermost-call CONSTANT/operation args carry
                        // formal-ts refs (REF args carry them at any nesting
                        // depth); def-view PACKAGE function bodies never do
                        // (top pkg copies re-attach them), while MODULE
                        // function bodies attach like any other context.
                        // Formals of a PREDEFINED integer type (int i) keep
                        // 64-bit constants and take no in-function ts ref;
                        // VECTOR formals ([3:0] inp) size their constant args
                        // and carry the ts ref even inside function bodies.
                        bool intFormal =
                            arg->type && arg->type->getCanonicalType().kind ==
                                             SymbolKind::PredefinedIntegerType;
                        // DEF-view cont-assign CONCAT args ({a,b}) carry no
                        // formal-ts ref (patterns '{0,1} keep theirs).
                        bool defOpArg = contAssignView == 1 &&
                                        a->UhdmType() == UHDM::uhdmoperation &&
                                        ((UHDM::operation*)a)->VpiOpType() ==
                                            vpiConcatOp;
                        bool argCtxOk =
                            currentTf ? (pkgTopEmit ||
                                         (!pkgScopeInst && callArgDepth == 1 &&
                                          a->UhdmType() == UHDM::uhdmconstant &&
                                          !intFormal))
                                      : (!inLhs && !defOpArg && !portInitCtx &&
                                         (refArg || callArgDepth == 1));
                        // Pkg-scoped param refs (pkg::P) carry no formal ts.
                        bool pkgScopedRef =
                            a->UhdmType() == UHDM::uhdmref_obj &&
                            std::string(((UHDM::ref_obj*)a)->VpiName()).find("::") !=
                                std::string::npos;
                        if (isFunc && !inProcessEmit && argCtxOk && !pkgScopedRef &&
                            !(unbasedArg && contAssignView == 1) &&
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
                            // A constant arg carrying a formal-ts ref sizes at
                            // the formal's width (loop(2) -> UINT:2 size 4) —
                            // VECTOR formals only (int formals keep 64).
                            if (a->UhdmType() == UHDM::uhdmconstant && arg->type &&
                                !intFormal &&
                                !stripImplicitConv(*arg).type->isString())
                                ((UHDM::constant*)a)
                                    ->VpiSize((int32_t)arg->type->getBitWidth());
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
                // Built-in METHOD call (e.first(), s.putc(...)): hier_path
                // [receiver ref (name-only), method_func_call named by the
                // method] — Surelog's folded shape.
                if (!call.arguments().empty()) {
                    auto* recv = call.arguments()[0];
                    std::string recvText = rawText(recv->sourceRange);
                    // STATEMENT context (b.putc(2,"x");): a flat
                    // method_func_call with an unbound receiver Prefix.
                    if (stmtCtx && !recvText.empty()) {
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(name);
                        mfc->VpiParent(parent);
                        auto mStart = recv->sourceRange.end() + 1;
                        setLoc(mfc, SourceRange(mStart, mStart + name.size()));
                        auto* pr = s.MakeRef_obj();
                        pr->VpiName(recvText);
                        pr->VpiFullName(joinRef(prefix, recvText));
                        pr->VpiParent(mfc);
                        setLoc(pr, recv->sourceRange);
                        mfc->Prefix(pr);
                        auto* margs = s.MakeAnyVec();
                        for (size_t ai = 1; ai < call.arguments().size(); ai++) {
                            bool fs2 = forceConstParent;
                            if (isLiteralExpr(*call.arguments()[ai]))
                                forceConstParent = true;
                            if (auto* a2 = emitExpr(*call.arguments()[ai], mfc,
                                                    prefix, netMap))
                                margs->push_back(a2);
                            forceConstParent = fs2;
                        }
                        if (!margs->empty())
                            mfc->Tf_call_args(margs);
                        return mfc;
                    }
                    if (!recvText.empty()) {
                        auto* hp = s.MakeHier_path();
                        std::string dotted = recvText + "." + name;
                        hp->VpiName(dotted);
                        hp->VpiFullName(dotted);
                        hp->VpiParent(parent);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        auto* r0 = s.MakeRef_obj();
                        r0->VpiName(recvText);
                        r0->VpiFullName(recvText); // name-only (dump omits)
                        r0->VpiParent(hp);
                        setLoc(r0, recv->sourceRange);
                        elems->push_back(r0);
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(name);
                        mfc->VpiParent(hp);
                        auto mStart = recv->sourceRange.end() + 1;
                        setLoc(mfc, SourceRange(mStart, mStart + name.size()));
                        // Extra method args (past the receiver); literal args
                        // parent at the method call.
                        auto* margs = s.MakeAnyVec();
                        for (size_t ai = 1; ai < call.arguments().size(); ai++) {
                            bool fs2 = forceConstParent;
                            if (isLiteralExpr(*call.arguments()[ai]))
                                forceConstParent = true;
                            if (auto* a2 =
                                    emitExpr(*call.arguments()[ai], mfc, prefix, netMap))
                                margs->push_back(a2);
                            forceConstParent = fs2;
                        }
                        if (!margs->empty())
                            mfc->Tf_call_args(margs);
                        elems->push_back(mfc);
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
                noteUnsupported("system method call: " + name);
                return nullptr;
            }
            // $bits folds to a constant for a type/var/member argument, but
            // Surelog keeps it a sys_func_call when the argument is an
            // expression ($bits(~x)) or a parameter ($bits(P), override-
            // dependent).
            bool bitsKeep = false;
            if (!call.arguments().empty()) {
                auto& a0 = *call.arguments()[0];
                bitsKeep = a0.kind == ExpressionKind::UnaryOp ||
                           a0.kind == ExpressionKind::BinaryOp ||
                           a0.kind == ExpressionKind::ConditionalOp ||
                           (a0.kind == ExpressionKind::NamedValue &&
                            a0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter &&
                            // A LOCALPARAM can't be overridden — its $bits
                            // folds in the ELAB re-emit (def keeps the call).
                            !(reemitting && a0.as<NamedValueExpression>()
                                                .symbol.as<ParameterSymbol>()
                                                .isLocalParam()));
            }
            if (name == "$bits" && !bitsKeep) {
                bool localParamArg =
                    !call.arguments().empty() &&
                    call.arguments()[0]->kind == ExpressionKind::NamedValue &&
                    call.arguments()[0]
                            ->as<NamedValueExpression>()
                            .symbol.kind == SymbolKind::Parameter;
                ASTContext qctx(comp.getRoot(), LookupLocation::max);
                if (auto cv = qctx.tryEval(expr); cv && cv.isInteger()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    // The elab localparam-$bits fold is loc-less.
                    if (!localParamArg)
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
            // expression contexts; other sys calls span the whole call. A
            // CLOCKING-EVENT argument also forces the name-only span.
            static const std::set<std::string> kNameOnlyFuncs = {"$signed", "$unsigned"};
            bool clockingArg = false;
            for (auto arg : call.arguments())
                if (arg->kind == ExpressionKind::ClockingEvent)
                    clockingArg = true;
            if (clockingArg)
                setLoc(sc, nameSpan(expr.sourceRange.start(), name));
            else if (stmtCtx || (!kNameOnlyFuncs.count(name) && !inCastSize))
                setLoc(sc, expr.sourceRange);
            else
                setLoc(sc, SourceRange(expr.sourceRange.start(),
                                       expr.sourceRange.start() + name.size()));
            auto* args = s.MakeAnyVec();
            callArgDepth++;
            for (auto arg : call.arguments()) {
                // An output arg ($readmemh(f, mem)) binds as an Assignment;
                // golden lists just the target ref (an assignment object would
                // poison the tf_call_args group).
                const Expression* argE = arg;
                if (argE->kind == ExpressionKind::Assignment)
                    argE = &argE->as<AssignmentExpression>().left();
                // System-call direct literal args parent to the call.
                bool forceSaved = forceConstParent;
                if (isLiteralExpr(*argE))
                    forceConstParent = true;
                if (auto* a = emitExpr(*argE, sc, prefix, netMap))
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
            // A CONTINUOUS-assign LVALUE concat ({a,b} = ...) is located at
            // its FIRST operand (Surelog quirk); procedural LHS concats and
            // rvalue concats span the whole braces.
            if (inLhs && parent && parent->UhdmType() == UHDM::uhdmcont_assign &&
                !ce.operands().empty())
                setLoc(op, ce.operands()[0]->sourceRange);
            else
                setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // Direct literal operands of a concat are unparented in
            // module-compile context, parented in re-elaborated (instance)
            // context. Nested expressions keep the normal rules.
            for (auto o : ce.operands()) {
                bool saved = suppressConstParent, savedF = forceConstParent;
                // A string-literal operand hidden behind a compiler cast
                // ({NAME,"efgh"}) counts as a direct literal too.
                const Expression* olit = o;
                while (olit->kind == ExpressionKind::Conversion)
                    olit = &olit->as<ConversionExpression>().operand();
                if (!reemitting && isLiteralExpr(*olit)) {
                    suppressConstParent = true;
                    // PARAM concat inits unparent literal operands (the force
                    // flag would re-parent them) — package and module alike.
                    if (inParamInit)
                        forceConstParent = false;
                }
                if (auto* e = emitExpr(*o, op, prefix, netMap))
                    operands->push_back(e);
                suppressConstParent = saved;
                forceConstParent = savedF;
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
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::ElementSelect: {
            auto& es = expr.as<ElementSelectExpression>();
            // Selects on member access become hier_paths whose last element
            // is the select object (lazily-frozen fullname).
            const Expression* esBottom = &es.value();
            while (esBottom->kind == ExpressionKind::MemberAccess)
                esBottom = &esBottom->as<MemberAccessExpression>().value();
            if (es.value().kind == ExpressionKind::MemberAccess &&
                esBottom->kind == ExpressionKind::NamedValue) {
                std::vector<const Expression*> chain;
                const Expression* base = &es.value();
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &base->as<MemberAccessExpression>().value();
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
            // Element select over a DOTTED interface-member path
            // (sub.req.arr[i]): hier_path with a final bit_select element.
            {
                const Expression* bb = &stripImplicitConv(es.value());
                while (bb->kind == ExpressionKind::MemberAccess ||
                       bb->kind == ExpressionKind::ElementSelect) {
                    if (bb->kind == ExpressionKind::MemberAccess)
                        bb = &bb->as<MemberAccessExpression>().value();
                    else
                        bb = &bb->as<ElementSelectExpression>().value();
                }
                if (bb->kind == ExpressionKind::ArbitrarySymbol ||
                    bb->kind == ExpressionKind::HierarchicalValue ||
                    (bb->kind == ExpressionKind::NamedValue &&
                     stripImplicitConv(es.value()).kind !=
                         ExpressionKind::NamedValue)) {
                    std::string baseDotted = rawText(es.value().sourceRange);
                    if (baseDotted.find('.') != std::string::npos) {
                        std::string selText = rawText(expr.sourceRange);
                        auto* hp = s.MakeHier_path();
                        hp->VpiName(selText);
                        hp->VpiFullName(selText);
                        hp->VpiParent(parent);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        auto exprStart = es.value().sourceRange.start();
                        std::vector<std::pair<std::string, size_t>> comps;
                        for (size_t st = 0; st <= baseDotted.size();) {
                            auto dot = baseDotted.find('.', st);
                            if (dot == std::string::npos)
                                dot = baseDotted.size();
                            comps.emplace_back(baseDotted.substr(st, dot - st), st);
                            if (dot == baseDotted.size())
                                break;
                            st = dot + 1;
                        }
                        for (size_t ci = 0; ci + 1 < comps.size(); ci++) {
                            auto& [cn, co] = comps[ci];
                            auto* r2 = s.MakeRef_obj();
                            r2->VpiName(cn);
                            r2->VpiFullName(cn); // name-only (dump omits)
                            r2->VpiParent(hp);
                            setLoc(r2, SourceRange(exprStart + co,
                                                   exprStart + co + cn.size()));
                            elems->push_back(r2);
                        }
                        std::string lastName =
                            comps.empty() ? std::string{} : comps.back().first;
                        size_t lastOff = comps.empty() ? 0 : comps.back().second;
                        auto* bs2 = s.MakeBit_select();
                        bs2->VpiName(lastName);
                        bs2->VpiFullName(selText);
                        bs2->VpiParent(hp);
                        setLoc(bs2, SourceRange(exprStart + lastOff,
                                                expr.sourceRange.end()));
                        if (auto* ix2 = emitExpr(es.selector(), bs2, prefix, netMap))
                            bs2->VpiIndex((UHDM::expr*)ix2);
                        elems->push_back(bs2);
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
            // A select of a PACKAGE parameter (pkg::A[0]) names itself
            // pkg::A (fullname==name, omitted by the dump) and parents at
            // the package's def parameter object.
            if (nv.symbol.kind == SymbolKind::Parameter) {
                if (auto psc2 = nv.symbol.getParentScope();
                    psc2 && psc2->asSymbol().kind == SymbolKind::Package) {
                    std::string pn2 = std::string(psc2->asSymbol().name) + "::" +
                                      std::string(nv.symbol.name);
                    bs->VpiName(pn2);
                    bs->VpiFullName(pn2);
                    if (auto pit2 = pkgDefMap.find(&psc2->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                bs->VpiParent(pp2);
                }
            }
            // A bit-select write only re-points whole refs when the base is a
            // function formal (io_decl); local vars/nets keep their own binding.
            if (auto nit = netMap.find(&nv.symbol);
                nit != netMap.end() && nit->second->UhdmType() == UHDM::uhdmio_decl)
                noteSelectObj(&nv.symbol, bs);
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
            const Expression* rsBottom = &stripImplicitConv(rs.value());
            while (rsBottom->kind == ExpressionKind::MemberAccess)
                rsBottom = &stripImplicitConv(
                    rsBottom->as<MemberAccessExpression>().value());
            if (stripImplicitConv(rs.value()).kind == ExpressionKind::MemberAccess &&
                rsBottom->kind == ExpressionKind::NamedValue) {
                std::vector<const Expression*> chain;
                const Expression* base = &stripImplicitConv(rs.value());
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &stripImplicitConv(base->as<MemberAccessExpression>().value());
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
                            // The indexed form carries the dotted select
                            // string as its fullname and stops BEFORE the ']'.
                            ips->VpiFullName(dotted);
                            setLoc(ips, SourceRange(elemLoc.start(),
                                                    rs.right().sourceRange.end()));
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
            // Range select over a DOTTED interface-member path
            // (sub.req.adr[A:B]): hier_path whose final element is the
            // (indexed_)part_select named by the last component.
            {
                const Expression* bb = &stripImplicitConv(rs.value());
                while (bb->kind == ExpressionKind::MemberAccess ||
                       bb->kind == ExpressionKind::ElementSelect) {
                    if (bb->kind == ExpressionKind::MemberAccess)
                        bb = &bb->as<MemberAccessExpression>().value();
                    else
                        bb = &bb->as<ElementSelectExpression>().value();
                }
                if (bb->kind == ExpressionKind::ArbitrarySymbol ||
                    bb->kind == ExpressionKind::HierarchicalValue ||
                    (bb->kind == ExpressionKind::NamedValue &&
                     stripImplicitConv(rs.value()).kind !=
                         ExpressionKind::NamedValue)) {
                    std::string baseDotted = rawText(rs.value().sourceRange);
                    if (baseDotted.find('.') != std::string::npos) {
                        std::string selText = rawText(expr.sourceRange);
                        auto* hp = s.MakeHier_path();
                        hp->VpiName(selText);
                        hp->VpiFullName(selText);
                        hp->VpiParent(parent);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        auto exprStart = rs.value().sourceRange.start();
                        std::vector<std::pair<std::string, size_t>> comps;
                        for (size_t st = 0; st <= baseDotted.size();) {
                            auto dot = baseDotted.find('.', st);
                            if (dot == std::string::npos)
                                dot = baseDotted.size();
                            comps.emplace_back(baseDotted.substr(st, dot - st), st);
                            if (dot == baseDotted.size())
                                break;
                            st = dot + 1;
                        }
                        for (size_t ci = 0; ci + 1 < comps.size(); ci++) {
                            auto& [cn, co] = comps[ci];
                            // An indexed component (a[0]) is a bit_select.
                            auto lb2 = cn.find('[');
                            auto rb2 = cn.find(']');
                            if (lb2 != std::string::npos && rb2 != std::string::npos &&
                                rb2 > lb2 + 1 &&
                                cn.find_first_not_of("0123456789", lb2 + 1) == rb2) {
                                std::string bn = cn.substr(0, lb2);
                                std::string ix = cn.substr(lb2 + 1, rb2 - lb2 - 1);
                                auto* bsm = s.MakeBit_select();
                                bsm->VpiName(bn);
                                bsm->VpiFullName(bn);
                                bsm->VpiParent(hp);
                                setLoc(bsm, SourceRange(exprStart + co,
                                                        exprStart + co + bn.size()));
                                auto* cix = s.MakeConstant();
                                cix->VpiDecompile(ix);
                                cix->VpiSize(64);
                                cix->VpiValue("UINT:" + ix);
                                cix->VpiConstType(vpiUIntConst);
                                size_t dOff = co + lb2 + 1;
                                setLoc(cix, SourceRange(exprStart + dOff,
                                                        exprStart + dOff + ix.size()));
                                bsm->VpiIndex(cix);
                                elems->push_back(bsm);
                                continue;
                            }
                            auto* r2 = s.MakeRef_obj();
                            r2->VpiName(cn);
                            r2->VpiFullName(cn); // name-only (dump omits)
                            r2->VpiParent(hp);
                            setLoc(r2, SourceRange(exprStart + co,
                                                   exprStart + co + cn.size()));
                            elems->push_back(r2);
                        }
                        std::string lastName =
                            comps.empty() ? std::string{} : comps.back().first;
                        size_t lastOff = comps.empty() ? 0 : comps.back().second;
                        SourceRange selLoc(exprStart + lastOff, expr.sourceRange.end());
                        bool constSel = false;
                        {
                            ASTContext cctx(comp.getRoot(), LookupLocation::max);
                            constSel =
                                (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                 cctx.tryEval(rs.left())) &&
                                (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                 cctx.tryEval(rs.right()));
                        }
                        bool sup = suppressConstParent;
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                            auto* ps2 = s.MakePart_select();
                            ps2->VpiName(lastName);
                            ps2->VpiFullName(selText);
                            ps2->VpiParent(hp);
                            setLoc(ps2, selLoc);
                            if (constSel)
                                ps2->VpiConstantSelect(true);
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* l = emitExpr(rs.left(), ps2, prefix, netMap))
                                ps2->Left_range((UHDM::expr*)l);
                            suppressConstParent = isLiteralExpr(rs.right());
                            if (auto* r3 = emitExpr(rs.right(), ps2, prefix, netMap))
                                ps2->Right_range((UHDM::expr*)r3);
                            elems->push_back(ps2);
                        }
                        else {
                            auto* ips2 = s.MakeIndexed_part_select();
                            ips2->VpiName(lastName);
                            ips2->VpiFullName(selText);
                            ips2->VpiParent(hp);
                            setLoc(ips2, selLoc);
                            ips2->VpiIndexedPartSelectType(
                                rs.getSelectionKind() == RangeSelectionKind::IndexedUp
                                    ? 1
                                    : 2);
                            if (constSel)
                                ips2->VpiConstantSelect(true);
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* b2 = emitExpr(rs.left(), ips2, prefix, netMap))
                                ips2->Base_expr((UHDM::expr*)b2);
                            suppressConstParent = isLiteralExpr(rs.right());
                            if (auto* w2 = emitExpr(rs.right(), ips2, prefix, netMap))
                                ips2->Width_expr((UHDM::expr*)w2);
                            elems->push_back(ips2);
                        }
                        suppressConstParent = sup;
                        hp->Path_elems(elems);
                        return hp;
                    }
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
                // An indexed part-select write re-points whole refs only when
                // the base is a net (module reg); local vars keep their binding.
                if (auto nit = netMap.find(&nv.symbol);
                    nit != netMap.end() && nit->second->UhdmType() == UHDM::uhdmlogic_net)
                    noteSelectObj(&nv.symbol, ips);
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
            // Simple (constant) part-select writes do NOT re-point whole refs.
            // Fullname is frozen from the parent chain (matches Surelog's
            // lazily-computed values, incl. the doubled name under a
            // bit_select index). A PARAM-init part-select of a param
            // (WidthRatio[DepthW:0]) scopes explicitly by the module prefix.
            if (inParamInit)
                psel->VpiFullName(joinRef(prefix, nv.symbol.name));
            else
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
                // Function/task bodies AND param inits scope EVERY bound ref
                // by the base name (Surelog's doubled part-select fullname).
                if (currentSubSym || inParamInit)
                    return basePfx;
                return stripImplicitConv(e).kind == ExpressionKind::NamedValue ? prefix
                                                                               : basePfx;
            };
            // Param-init bound constants are unparented.
            bool savedSup2 = suppressConstParent;
            if (inParamInit)
                suppressConstParent = true;
            bool savedF2 = forceConstParent;
            if (inParamInit)
                forceConstParent = false;
            if (auto* l = emitExpr(rs.left(), psel, boundPfx(rs.left()), netMap))
                psel->Left_range((UHDM::expr*)l);
            if (auto* r = emitExpr(rs.right(), psel, boundPfx(rs.right()), netMap))
                psel->Right_range((UHDM::expr*)r);
            suppressConstParent = savedSup2;
            forceConstParent = savedF2;
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
            // Struct-member access on an interface-port member (s.req.adr):
            // the base chain bottoms out at an ArbitrarySymbol — a dotted
            // hier_path over the whole expression.
            if (base->kind == ExpressionKind::ArbitrarySymbol ||
                base->kind == ExpressionKind::HierarchicalValue) {
                std::string dotted = rawText(expr.sourceRange);
                if (dotted.find('.') != std::string::npos)
                    return buildDottedHierPath(expr, dotted, parent, prefix);
            }
            // Member access threading an ELEMENT SELECT over an interface
            // array (s[0].req.wdt): dotted hier_path (a[i] components become
            // bit_selects in the builder... approximate with refs).
            if (base->kind == ExpressionKind::ElementSelect) {
                auto& esb = base->as<ElementSelectExpression>();
                auto& ebv = stripImplicitConv(esb.value());
                if (ebv.kind == ExpressionKind::ArbitrarySymbol ||
                    ebv.kind == ExpressionKind::HierarchicalValue) {
                    std::string dotted = rawText(expr.sourceRange);
                    if (dotted.find('.') != std::string::npos)
                        return buildDottedHierPath(expr, dotted, parent, prefix);
                }
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
            // this.member: the hier_path spans the `this` token only, and the
            // member ref is loc-less with a scope-prefixed fullname.
            bool thisPath = nv.symbol.name == "this";
            if (thisPath)
                setLoc(hp, base->sourceRange);
            else
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
                if (thisPath && *it2 == chain.front()) {
                    r->VpiFullName(joinRef(prefix, ma.member.name));
                }
                else {
                    auto end = (*it2)->sourceRange.end();
                    setLoc(r, SourceRange(end - ma.member.name.size(), end));
                }
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
                    // Re-emitted OUTERMOST patterns size their FIRST operand;
                    // NESTED patterns ('{'{0,..},..}) keep every element 64.
                    if (reemitting) {
                        if (operands->empty() && !wasInPattern)
                            ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                    }
                    // Outermost bare-decimal elements: a direct var initializer
                    // (suppressConstParent) resizes each to the element type; a
                    // func-arg / param-default pattern keeps 64 and leaves the
                    // element UNparented. Nested-pattern elements always keep 64.
                    else if (!wasInPattern && e->UhdmType() == UHDM::uhdmconstant) {
                        if (suppressConstParent) {
                            if (((UHDM::expr*)e)->VpiSize() == 64)
                                ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                        }
                        else {
                            ((UHDM::expr*)e)->VpiParent(nullptr);
                        }
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
            // In a PLAIN def cont-assign context the operands stay unparented
            // at 64 bits; init/re-emit contexts parent them (count at 32).
            bool plainCtx =
                !reemitting && !suppressConstParent && !forceConstParent;
            bool sup0 = suppressConstParent;
            if (plainCtx)
                suppressConstParent = true;
            auto* operands = s.MakeAnyVec();
            if (auto* c = emitExpr(rap.count(), op, prefix, netMap)) {
                // The replication count is a 32-bit constant in INIT
                // contexts only (plain/re-emitted CAs keep 64).
                if (sup0 && c->UhdmType() == UHDM::uhdmconstant &&
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
            if (plainCtx)
                suppressConstParent = sup0;
            return op;
        }
        case ExpressionKind::StructuredAssignmentPattern: {
            auto& ap = expr.as<StructuredAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            // A NESTED pattern (member setter of an outer pattern): no
            // first-operand VpiSize, and a BARE ts ref to the member's
            // typedef struct typespec (Surelog).
            bool nestedPat = parent && parent->UhdmType() == UHDM::uhdmoperation &&
                             ((UHDM::operation*)parent)->VpiOpType() ==
                                 vpiAssignmentPatternOp;
            if (nestedPat && reemitting && expr.type) {
                UHDM::typespec* mts = nullptr;
                if (auto tit = pkgTopTypedefTs.find(
                        (const Symbol*)&expr.type->getCanonicalType());
                    tit != pkgTopTypedefTs.end())
                    mts = tit->second;
                if (!mts && expr.type->kind == SymbolKind::TypeAlias) {
                    if (auto tit2 = pkgTopTypedefTs.find(
                            &expr.type->as<TypeAliasType>());
                        tit2 != pkgTopTypedefTs.end())
                        mts = tit2->second;
                    if (!mts)
                        if (auto tit3 = typedefTs.find(expr.type);
                            tit3 != typedefTs.end())
                            mts = tit3->second;
                }
                if (mts) {
                    auto* rt = s.MakeRef_typespec();
                    rt->Actual_typespec(mts);
                    op->Typespec(rt);
                }
            }
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
                        if (operands->empty() && !nestedPat)
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)setter.expr->type->getBitWidth());
                        operands->push_back(e);
                    }
                    continue;
                }
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                setLoc(tp, setter.expr->sourceRange);
                // The pattern value parents at the OPERATION — except a
                // literal value in a def CONT-ASSIGN, which stays unparented.
                bool savedS2 = suppressConstParent, savedF2 = forceConstParent;
                if (paramInitDef && isLiteralExpr(*setter.expr)) {
                    suppressConstParent = true;
                    forceConstParent = false;
                }
                if (auto* e = emitExpr(*setter.expr, op, prefix, netMap))
                    tp->Pattern((UHDM::expr*)e);
                suppressConstParent = savedS2;
                forceConstParent = savedF2;
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
        case ExpressionKind::Inside: {
            // a inside {A, B, ...}: an operation (vpiInsideOp) whose operands
            // are the LHS followed by the flattened set members.
            auto& ie = expr.as<InsideExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiInsideOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* l = emitExpr(ie.left(), op, prefix, netMap))
                operands->push_back(l);
            for (auto* rle : ie.rangeList())
                if (auto* e = emitExpr(*rle, op, prefix, netMap))
                    operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::ValueRange: {
            // A range set member ([4:7]): operation(vpiListOp) of the two
            // bounds (the enclosing inside-op comes from the item/expr level).
            auto& vr = expr.as<ValueRangeExpression>();
            auto* ol = s.MakeOperation();
            ol->VpiOpType(vpiListOp);
            ol->VpiParent(parent);
            setLoc(ol, expr.sourceRange);
            auto* bounds = s.MakeAnyVec();
            bool fcp2 = forceConstParent;
            // Case-inside members leave their bounds unparented (caller sets
            // suppressConstParent); a standalone `inside {[a:b]}` forces them.
            if (!suppressConstParent)
                forceConstParent = true;
            if (auto* l = emitExpr(vr.left(), ol, prefix, netMap))
                bounds->push_back(l);
            if (auto* r = emitExpr(vr.right(), ol, prefix, netMap))
                bounds->push_back(r);
            forceConstParent = fcp2;
            ol->Operands(bounds);
            return ol;
        }
        case ExpressionKind::EmptyArgument:
            // An omitted optional call argument ($readmemh(file, mem, ,)):
            // dropped (golden lists only the present args).
            return nullptr;
        case ExpressionKind::Streaming: {
            // Streaming concatenation: a SLICED stream ({ << 8 {x} }) folds to
            // a plain CONCAT over the operands (full span); an unsliced one
            // ({<<{x}}) keeps a stream operation (vpiStreamRLOp for <<),
            // anchored at the first operand's span.
            auto& sc2 = expr.as<StreamingConcatenationExpression>();
            bool sliced = sc2.getSliceSize() > 1;
            // The inner {..} concat: located at the FULL streaming span
            // (Surelog swaps the spans).
            auto* cc = s.MakeOperation();
            cc->VpiOpType(vpiConcatOp);
            setLoc(cc, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            for (auto& strm : sc2.streams())
                if (auto* e = emitExpr(*strm.operand, cc, prefix, netMap))
                    operands->push_back(e);
            cc->Operands(operands);
            // A stream operation (vpiStreamRLOp) wrapping the concat, located
            // at the {..} operand braces; a sliced stream ({ << 8 {x} }) adds
            // the slice-size constant as the FIRST operand.
            auto* op = s.MakeOperation();
            // << (right-to-left, sliceSize > 0) -> vpiStreamRLOp; >> -> LR.
            op->VpiOpType(sc2.getSliceSize() > 0 ? vpiStreamRLOp : vpiStreamLROp);
            op->VpiParent(parent);
            if (!sc2.streams().empty()) {
                auto fr = sc2.streams().front().operand->sourceRange;
                auto lr = sc2.streams().back().operand->sourceRange;
                setLoc(op, SourceRange(fr.start() - 1, lr.end() + 1));
            }
            else
                setLoc(op, expr.sourceRange);
            auto* outer = s.MakeAnyVec();
            // An explicit slice size (either direction) emits as a LOCATED,
            // UNPARENTED first operand (token parsed from the source text —
            // the streaming often reaches here with null syntax).
            {
                std::string raw = rawText(expr.sourceRange);
                auto p1 = raw.find("<<");
                if (p1 == std::string::npos)
                    p1 = raw.find(">>");
                if (p1 != std::string::npos) {
                    size_t q = p1 + 2;
                    while (q < raw.size() && isspace((unsigned char)raw[q]))
                        q++;
                    size_t st2 = q;
                    while (q < raw.size() && !isspace((unsigned char)raw[q]) &&
                           raw[q] != '{')
                        q++;
                    if (q > st2) {
                        std::string digits = raw.substr(st2, q - st2);
                        auto* c = s.MakeConstant();
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        // The elab re-emit parents the slice const at the op.
                        if (reemitting)
                            c->VpiParent(op);
                        setLoc(c, SourceRange(expr.sourceRange.start() + st2,
                                              expr.sourceRange.start() + q));
                        outer->push_back(c);
                    }
                }
            }
            cc->VpiParent(op);
            outer->push_back(cc);
            op->Operands(outer);
            return op;
        }
        case ExpressionKind::ArbitrarySymbol: {
            std::string dotted = rawText(expr.sourceRange);
            // A bare interface reference (no dot) is a plain ref_obj.
            if (dotted.find('.') == std::string::npos) {
                auto* r = s.MakeRef_obj();
                r->VpiName(dotted);
                r->VpiParent(parent);
                setLoc(r, expr.sourceRange);
                return r;
            }
            // Interface-port member access (sub.sig): a hier_path with one
            // ref_obj element per dotted component.
            return buildDottedHierPath(expr, dotted, parent, prefix);
        }
        case ExpressionKind::NewClass: {
            // bar = new(): a loc-less method_func_call named "new".
            auto* mfc = s.MakeMethod_func_call();
            mfc->VpiName("new");
            mfc->VpiParent(parent);
            return mfc;
        }
        case ExpressionKind::AssertionInstance: {
            // A named-property instantiation (down_n(8'd3)): property_inst
            // with constant args parented at an artifact func_call.
            auto& aie = expr.as<AssertionInstanceExpression>();
            auto* pi = s.MakeProperty_inst();
            pi->VpiName(aie.symbol.name);
            // Spans the whole instantiation, shrunk by any whitespace Surelog
            // compacts out of spaced based literals (8'd 3 -> 8'd3).
            SourceRange pir =
                expr.syntax ? expr.syntax->sourceRange() : expr.sourceRange;
            pir = SourceRange(pir.start(),
                              pir.end() - basedLiteralSpaceCount(rawText(pir)));
            setLoc(pi, pir);
            auto* fcArt = s.MakeFunc_call();
            fcArt->VpiName(aie.symbol.name);
            fcArt->VpiParent(parent);
            setLoc(fcArt, pir);
            auto* args = s.MakeAnyVec();
            for (auto& [port, actual] : aie.arguments) {
                (void)port;
                if (auto* pe = std::get_if<const Expression*>(&actual)) {
                    bool ss = suppressConstParent;
                    bool fs = forceConstParent;
                    suppressConstParent = true;
                    forceConstParent = false;
                    if (auto* a = emitExpr(**pe, fcArt, prefix, netMap)) {
                        a->VpiParent(fcArt);
                        args->push_back(a);
                    }
                    suppressConstParent = ss;
                    forceConstParent = fs;
                }
            }
            if (!args->empty()) {
                pi->VpiArguments(args);
                fcArt->Tf_call_args(args);
            }
            return pi;
        }
        case ExpressionKind::ClockingEvent: {
            // A clocking-event argument ($fell(a, @(posedge clk))): the edge
            // operation over the clock signal.
            auto& ce = expr.as<ClockingEventExpression>();
            return emitEventExpr(ce.timingControl, parent, prefix, netMap);
        }
        case ExpressionKind::Invalid: {
            // slang wraps some valid sub-expressions in Invalid nodes (e.g.
            // size-cast operand shells); unwrap when a child exists.
            auto& iv2 = expr.as<InvalidExpression>();
            // Property-decl FORMAL refs bind Invalid (untyped formals): a
            // property-scoped ref bound to an implicit module wire minted at
            // the first use.
            if (propDeclScope) {
                std::string nm;
                SourceRange nr = expr.sourceRange;
                if (nr.start() != SourceLocation::NoLocation)
                    nm = rawText(nr);
                if (nm.empty() && expr.syntax &&
                    expr.syntax->kind == syntax::SyntaxKind::IdentifierName) {
                    nm = std::string(expr.syntax->as<syntax::IdentifierNameSyntax>()
                                         .identifier.valueText());
                    nr = expr.syntax->sourceRange();
                }
                if (!nm.empty())
                    if (auto* ref = emitPropFormalRef(nm, nr, parent, prefix))
                        return ref;
            }
            if (iv2.child)
                return emitExpr(*iv2.child, parent, prefix, netMap);
            noteUnsupported("expression kind: Invalid");
            return nullptr;
        }
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
