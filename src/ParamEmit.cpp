//------------------------------------------------------------------------------
//! @file ParamEmit.cpp
//! @brief Parameters, param_assigns, deferred param typespecs, packages
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include <functional>

#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include "slang/ast/EvalContext.h"

namespace slang_uhdm {

static bool containsUserCall(const Expression& e) {
    bool found = false;
    e.visit(makeVisitor([&](auto& v, const CallExpression& c) {
        if (!c.isSystemCall())
            found = true;
        v.visitDefault(c);
    }));
    return found;
}

// Surelog's constant-function evaluator BAILS on a function whose body declares
// a LOCALPARAM at any block level: the elab param_assign then keeps a symbolic
// Rhs instead of the folded value (const_func_block_var). Plain block variables,
// named blocks and loops fold fine — the lifetime (static vs automatic) does
// NOT matter (asym_ram_sdp_*_wider's static `log2` folds).
static bool subroutineDeclaresParam(const Scope& sc) {
    for (auto& m : sc.members()) {
        if (m.kind == SymbolKind::Parameter || m.kind == SymbolKind::TypeParameter)
            return true;
        if (m.kind == SymbolKind::StatementBlock &&
            subroutineDeclaresParam(m.as<StatementBlockSymbol>()))
            return true;
    }
    return false;
}

// ---------------------------------------------------------------------------
// Surelog's ExprEval::evalStmt reduces an ASSIGNMENT's Rhs with pexpr = the
// ASSIGNMENT itself; in that context a bit/part SELECT of a FUNCTION-SCOPE
// object (formal arg or body variable) does NOT resolve to the value evalFunc
// stored for it, so the select stays symbolic. Operators that consume their
// operands through the SHARED invalidValue flag (&&, ||, &, |, ^, ~, !, ==, *,
// -, <<, ?:, and a select whose INDEX is such a select) then mark the whole
// evaluation invalid and the call stays a func_call. vpiAddOp and concat use
// LOCAL flags, so `x[i] + y[i]` / `{x[i],y[i]}` still fold, and a BARE select
// Rhs (`F = D[0]`) folds because setValueInInstance re-reduces with pexpr=null.
// The refusal is EXECUTION-dependent: the same statement inside a loop that
// never runs does not defeat the fold (func_upto: `for (i=LO; i+SPAN<HI; ...)`
// only has a live body for HI=2/LO=0/SPAN=1, which is exactly the 512 of 2144
// instances where Surelog keeps the func_call).
static const ValueSymbol* selectRootSym(const Expression& e) {
    const Expression* p = &e;
    for (int guard = 0; guard < 16; guard++) {
        switch (p->kind) {
            case ExpressionKind::ElementSelect:
                p = &p->as<ElementSelectExpression>().value();
                break;
            case ExpressionKind::RangeSelect:
                p = &p->as<RangeSelectExpression>().value();
                break;
            case ExpressionKind::MemberAccess:
                p = &p->as<MemberAccessExpression>().value();
                break;
            case ExpressionKind::Conversion:
                p = &p->as<ConversionExpression>().operand();
                break;
            case ExpressionKind::NamedValue:
                return &p->as<NamedValueExpression>().symbol;
            default:
                return nullptr;
        }
    }
    return nullptr;
}

static bool isFuncScopeValue(const ValueSymbol& sym, const SubroutineSymbol& sub) {
    if (sym.kind != SymbolKind::Variable && sym.kind != SymbolKind::FormalArgument)
        return false;
    const Scope* sc = sym.getParentScope();
    for (int guard = 0; sc && guard < 8; guard++) {
        auto& ss = sc->asSymbol();
        if (&ss == (const Symbol*)&sub)
            return true;
        if (ss.kind != SymbolKind::StatementBlock)
            return false;
        sc = ss.getParentScope();
    }
    return false;
}

static bool poisonsEvalFunc(const Expression& e, const SubroutineSymbol& sub) {
    bool found = false;
    std::function<void(const Expression&, bool)> walk = [&](const Expression& x,
                                                            bool poisonCtx) {
        if (found)
            return;
        switch (x.kind) {
            case ExpressionKind::ElementSelect: {
                auto& es = x.as<ElementSelectExpression>();
                if (poisonCtx) {
                    if (auto* rs = selectRootSym(es.value()))
                        if (isFuncScopeValue(*rs, sub)) {
                            found = true;
                            return;
                        }
                }
                walk(es.value(), poisonCtx);
                walk(es.selector(), true);
                return;
            }
            case ExpressionKind::RangeSelect: {
                auto& rs2 = x.as<RangeSelectExpression>();
                if (poisonCtx) {
                    if (auto* rs = selectRootSym(rs2.value()))
                        if (isFuncScopeValue(*rs, sub)) {
                            found = true;
                            return;
                        }
                }
                walk(rs2.value(), poisonCtx);
                walk(rs2.left(), true);
                walk(rs2.right(), true);
                return;
            }
            case ExpressionKind::BinaryOp: {
                auto& b = x.as<BinaryExpression>();
                bool p = poisonCtx || b.op != BinaryOperator::Add;
                walk(b.left(), p);
                walk(b.right(), p);
                return;
            }
            case ExpressionKind::UnaryOp: {
                auto& u = x.as<UnaryExpression>();
                bool p = poisonCtx || u.op != UnaryOperator::Plus;
                walk(u.operand(), p);
                return;
            }
            case ExpressionKind::ConditionalOp: {
                auto& c = x.as<ConditionalExpression>();
                for (auto& cond : c.conditions)
                    walk(*cond.expr, true);
                walk(c.left(), true);
                walk(c.right(), true);
                return;
            }
            case ExpressionKind::Concatenation: {
                for (auto* op : x.as<ConcatenationExpression>().operands())
                    walk(*op, poisonCtx);
                return;
            }
            case ExpressionKind::Replication: {
                auto& r = x.as<ReplicationExpression>();
                walk(r.count(), poisonCtx);
                walk(r.concat(), poisonCtx);
                return;
            }
            case ExpressionKind::Conversion:
                walk(x.as<ConversionExpression>().operand(), poisonCtx);
                return;
            case ExpressionKind::Assignment: {
                auto& a = x.as<AssignmentExpression>();
                walk(a.left(), poisonCtx);
                walk(a.right(), poisonCtx);
                return;
            }
            default:
                return;
        }
    };
    walk(e, false);
    return found;
}

// A for loop whose stop condition is FALSE on entry (evaluated with the
// initializers applied) never runs, so nothing in its body can defeat the fold.
static bool forLoopCanRun(const ForLoopStatement& fl, Compilation& comp) {
    if (!fl.stopExpr)
        return true;
    ASTContext actx(comp.getRoot(), LookupLocation::max);
    EvalContext ec(actx, EvalFlags::IsScript);
    ec.pushEmptyFrame();
    for (auto* lv : fl.loopVars) {
        ConstantValue iv = lv->getInitializer() ? lv->getInitializer()->eval(ec)
                                                : ConstantValue();
        if (!iv)
            return true;
        ec.createLocal(lv, std::move(iv));
    }
    for (auto* init : fl.initializers) {
        if (init->kind == ExpressionKind::Assignment) {
            auto& lhs = init->as<AssignmentExpression>().left();
            if (lhs.kind == ExpressionKind::NamedValue) {
                auto& vs = lhs.as<NamedValueExpression>().symbol;
                if (!ec.findLocal(&vs))
                    ec.createLocal(&vs, vs.getType().getDefaultValue());
            }
        }
        if (!init->eval(ec))
            return true;
    }
    ConstantValue cv = fl.stopExpr->eval(ec);
    if (!cv || !cv.isInteger() || cv.integer().hasUnknown())
        return true;
    return cv.isTrue();
}

static bool stmtPoisonsEvalFunc(const Statement& st, const SubroutineSymbol& sub,
                                Compilation& comp) {
    switch (st.kind) {
        case StatementKind::List:
            for (auto* s : st.as<StatementList>().list)
                if (stmtPoisonsEvalFunc(*s, sub, comp))
                    return true;
            return false;
        case StatementKind::Block:
            return stmtPoisonsEvalFunc(st.as<BlockStatement>().body, sub, comp);
        case StatementKind::ExpressionStatement: {
            auto& e = st.as<ExpressionStatement>().expr;
            if (e.kind == ExpressionKind::Assignment)
                return poisonsEvalFunc(e, sub);
            return false;
        }
        case StatementKind::Conditional: {
            auto& cs = st.as<ConditionalStatement>();
            // The CONDITION is reduced with pexpr=null (selects resolve there),
            // so only the TAKEN branch matters when the condition folds.
            int taken = -1;
            if (cs.conditions.size() == 1 && !cs.conditions[0].pattern) {
                ASTContext actx(comp.getRoot(), LookupLocation::max);
                EvalContext ec(actx, EvalFlags::IsScript);
                ec.pushEmptyFrame();
                ConstantValue cv = cs.conditions[0].expr->eval(ec);
                if (cv && cv.isInteger() && !cv.integer().hasUnknown())
                    taken = cv.isTrue() ? 0 : 1;
            }
            if (taken != 1 && stmtPoisonsEvalFunc(cs.ifTrue, sub, comp))
                return true;
            if (taken != 0 && cs.ifFalse &&
                stmtPoisonsEvalFunc(*cs.ifFalse, sub, comp))
                return true;
            return false;
        }
        case StatementKind::ForLoop: {
            auto& fl = st.as<ForLoopStatement>();
            if (!forLoopCanRun(fl, comp))
                return false;
            return stmtPoisonsEvalFunc(fl.body, sub, comp);
        }
        case StatementKind::WhileLoop:
            return stmtPoisonsEvalFunc(st.as<WhileLoopStatement>().body, sub, comp);
        case StatementKind::DoWhileLoop:
            return stmtPoisonsEvalFunc(st.as<DoWhileLoopStatement>().body, sub, comp);
        case StatementKind::RepeatLoop:
            return stmtPoisonsEvalFunc(st.as<RepeatLoopStatement>().body, sub, comp);
        case StatementKind::ForeverLoop:
            return stmtPoisonsEvalFunc(st.as<ForeverLoopStatement>().body, sub, comp);
        case StatementKind::ForeachLoop:
            return stmtPoisonsEvalFunc(st.as<ForeachLoopStatement>().body, sub, comp);
        case StatementKind::Case: {
            auto& cst = st.as<CaseStatement>();
            for (auto& item : cst.items)
                if (stmtPoisonsEvalFunc(*item.stmt, sub, comp))
                    return true;
            if (cst.defaultCase)
                return stmtPoisonsEvalFunc(*cst.defaultCase, sub, comp);
            return false;
        }
        default:
            return false;
    }
}

static bool subroutinePoisonsEvalFunc(const SubroutineSymbol& sub, Compilation& comp) {
    return stmtPoisonsEvalFunc(sub.getBody(), sub, comp);
}

// Surelog INLINES a foldable const function's body, so the folded constant is
// encoded by the same rules a plain expression fold uses — driven by the RETURN
// assignment's expression kind: a CONCAT body ({..}) folds full-width BIN, a
// comparison/logical body folds BIN with DECIMAL digits, everything else UINT.
enum class ConstCallEnc { Uint, BoolBin, ConcatBin };

static ConstCallEnc constCallEncoding(const SubroutineSymbol& sub) {
    ConstCallEnc enc = ConstCallEnc::Uint;
    auto classify = [&](const Expression& rhs) {
        auto& se = stripImplicitConv(rhs);
        if (se.kind == ExpressionKind::Concatenation)
            enc = ConstCallEnc::ConcatBin;
        else if (se.kind == ExpressionKind::BinaryOp) {
            auto bop = se.as<BinaryExpression>().op;
            enc = (OpInfo::isComparison(bop) || bop == BinaryOperator::LogicalAnd ||
                   bop == BinaryOperator::LogicalOr ||
                   bop == BinaryOperator::LogicalImplication ||
                   bop == BinaryOperator::LogicalEquivalence)
                      ? ConstCallEnc::BoolBin
                      : ConstCallEnc::Uint;
        }
        else
            enc = ConstCallEnc::Uint;
    };
    sub.getBody().visit(makeVisitor([&](auto& v, const AssignmentExpression& a) {
        auto& lhs = a.left();
        if (sub.returnValVar && lhs.kind == ExpressionKind::NamedValue &&
            &lhs.as<NamedValueExpression>().symbol ==
                (const Symbol*)sub.returnValVar)
            classify(a.right());
        v.visitDefault(a);
    }));
    return enc;
}

// ---------------------------------------------------------------------------
// Surelog's constant-function evaluator (UHDM ExprEval) does NOT model LRM
// expression widths: every intermediate value is a 64-bit word, and `>>`/`>>>`
// are BOTH ((uint64_t)val0 >> val1) on that word (ExprEval reduceExpr,
// vpiRShiftOp), while a ternary reduces to `INT:<selected branch>` — a SIGNED
// 64-bit constant. So a signed-negative operand that the LRM would have
// coerced to a NARROWER UNSIGNED type is SIGN-EXTENDED to 64 bits before the
// shift, making the shift read as arithmetic:
//     func = {(inp == 0 ? -1 : func(inp - 1)) >> 2};   // func_tern_hint
// LRM: the ternary is 32-bit UNSIGNED (one arm is func's unsigned 31-bit
// return), so -1 >> 2 = 0x3FFFFFFF. Surelog: (uint64_t)-1 >> 2 = 0x3FFF..FF,
// masked to the 31-bit return width (evalFunc masks the func value to the
// return logic_typespec's size) = 0x7FFFFFFF — and every recursion level
// re-masks, so the whole A/B/C/D chain sits one bit off.
// srlgFoldCall replays that 64-bit model over the narrow statement subset
// where it can matter; it returns nullopt for anything it does not model, so
// slang's LRM value stays authoritative for every other fold.

// int64 view of a slang constant under Surelog's get_value(): a SIGNED value
// keeps its sign (INT:), an unsigned one is zero-extended (UINT:).
static std::optional<int64_t> srlgWord(const ConstantValue& cv) {
    if (!cv.isInteger())
        return std::nullopt;
    const SVInt& iv = cv.integer();
    if (iv.hasUnknown() || iv.getBitWidth() > 64)
        return std::nullopt;
    if (iv.isSigned()) {
        if (auto v = iv.as<int64_t>())
            return *v;
        return std::nullopt;
    }
    if (auto v = iv.as<uint64_t>())
        return (int64_t)*v;
    return std::nullopt;
}

// Does Surelog give this type a logic_typespec whose width MASKS the value on
// function return / formal-arg binding? A predefined integer (integer/int/...)
// gets an int_typespec and is NOT masked (evalFunc only masks logic_typespec).
static bool srlgMaskWidth(const Type& t, uint64_t& w) {
    if (!t.isIntegral() || t.isPredefinedInteger() || t.isEnum())
        return false;
    auto& ct = t.getCanonicalType();
    if (ct.kind != SymbolKind::ScalarType && ct.kind != SymbolKind::PackedArrayType)
        return false;
    w = t.getBitWidth();
    return w > 0 && w < 64;
}

class SrlgFold {
public:
    // Replays Surelog's 64-bit fold of a user function call; nullopt when the
    // body (or any operand) falls outside the modelled subset.
    std::optional<int64_t> call(const SubroutineSymbol& sub,
                                std::span<const Expression* const> args) {
        std::vector<int64_t> argv;
        for (auto* a : args) {
            auto v = evalExpr(*a);
            if (!v)
                return std::nullopt;
            argv.push_back(*v);
        }
        return invoke(sub, argv);
    }

private:
    std::map<const Symbol*, int64_t> env;
    const Symbol* retVar = nullptr;
    int depth = 0;
    bool bad = false;

    static int64_t maskTo(int64_t v, uint64_t w, bool sgn) {
        uint64_t mask = (1ull << w) - 1;
        uint64_t t = (uint64_t)v & mask;
        if (sgn && ((t >> (w - 1)) & 1))
            t |= ~mask;
        return (int64_t)t;
    }

    std::optional<int64_t> invoke(const SubroutineSymbol& sub,
                                  const std::vector<int64_t>& argv) {
        auto formals = sub.getArguments();
        if (bad || ++depth > 64 || !sub.returnValVar ||
            formals.size() != argv.size()) {
            bad = true;
            depth--;
            return std::nullopt;
        }
        auto savedEnv = env;
        auto* savedRet = retVar;
        env.clear();
        retVar = (const Symbol*)sub.returnValVar;
        for (size_t i = 0; i < formals.size(); i++) {
            if (formals[i]->direction != ArgumentDirection::In) {
                bad = true;
                break;
            }
            int64_t v = argv[i];
            uint64_t fw = 0;
            if (srlgMaskWidth(formals[i]->getType(), fw))
                v = maskTo(v, fw, formals[i]->getType().isSigned());
            env[formals[i]] = v;
        }
        std::optional<int64_t> out;
        if (!bad) {
            bool returned = false;
            evalStmt(sub.getBody(), returned);
            auto it = env.find(retVar);
            if (!bad && it != env.end()) {
                int64_t v = it->second;
                uint64_t rw = 0;
                if (srlgMaskWidth(sub.getReturnType(), rw))
                    v = (int64_t)((uint64_t)v & ((1ull << rw) - 1));
                out = v;
            }
            else
                bad = true;
        }
        env = savedEnv;
        retVar = savedRet;
        depth--;
        return bad ? std::nullopt : out;
    }

    void evalStmt(const Statement& st, bool& returned) {
        if (bad || returned)
            return;
        switch (st.kind) {
            case StatementKind::Empty:
                return;
            case StatementKind::List:
                for (auto* s2 : st.as<StatementList>().list) {
                    evalStmt(*s2, returned);
                    if (bad || returned)
                        return;
                }
                return;
            case StatementKind::Block:
                evalStmt(st.as<BlockStatement>().body, returned);
                return;
            case StatementKind::VariableDeclaration: {
                auto& vs = st.as<VariableDeclStatement>().symbol;
                if (auto* init = vs.getInitializer()) {
                    if (auto v = evalExpr(*init))
                        env[&vs] = *v;
                    else
                        bad = true;
                }
                return;
            }
            case StatementKind::ExpressionStatement: {
                auto& e = st.as<ExpressionStatement>().expr;
                if (e.kind != ExpressionKind::Assignment) {
                    bad = true;
                    return;
                }
                auto& asn = e.as<AssignmentExpression>();
                auto& lhs = stripImplicitConv(asn.left());
                if (asn.isCompound() || lhs.kind != ExpressionKind::NamedValue) {
                    bad = true;
                    return;
                }
                if (auto v = evalExpr(asn.right()))
                    env[&lhs.as<NamedValueExpression>().symbol] = *v;
                else
                    bad = true;
                return;
            }
            case StatementKind::Return: {
                auto* re = st.as<ReturnStatement>().expr;
                if (!re) {
                    bad = true;
                    return;
                }
                if (auto v = evalExpr(*re)) {
                    env[retVar] = *v;
                    returned = true;
                }
                else
                    bad = true;
                return;
            }
            case StatementKind::Conditional: {
                auto& cs = st.as<ConditionalStatement>();
                if (cs.conditions.size() != 1 || cs.conditions[0].pattern) {
                    bad = true;
                    return;
                }
                auto c = evalExpr(*cs.conditions[0].expr);
                if (!c) {
                    bad = true;
                    return;
                }
                if (*c != 0)
                    evalStmt(cs.ifTrue, returned);
                else if (cs.ifFalse)
                    evalStmt(*cs.ifFalse, returned);
                return;
            }
            default:
                bad = true;
                return;
        }
    }

    std::optional<int64_t> evalExpr(const Expression& e) {
        if (bad)
            return std::nullopt;
        switch (e.kind) {
            case ExpressionKind::Conversion: {
                auto& cv = e.as<ConversionExpression>();
                if (!cv.isImplicit()) // vpiCastOp: not modelled
                    break;
                return evalExpr(cv.operand());
            }
            case ExpressionKind::IntegerLiteral:
                return srlgWord(ConstantValue(e.as<IntegerLiteral>().getValue()));
            case ExpressionKind::NamedValue: {
                auto& sym = e.as<NamedValueExpression>().symbol;
                auto it = env.find(&sym);
                if (it != env.end())
                    return it->second;
                if (sym.kind == SymbolKind::Parameter)
                    return srlgWord(sym.as<ParameterSymbol>().getValue());
                break;
            }
            case ExpressionKind::UnaryOp: {
                auto& uo = e.as<UnaryExpression>();
                auto v = evalExpr(uo.operand());
                if (!v)
                    break;
                switch (uo.op) {
                    case UnaryOperator::Plus:
                        return *v;
                    case UnaryOperator::Minus:
                        return -*v;
                    case UnaryOperator::LogicalNot:
                        return *v == 0 ? 1 : 0;
                    default:
                        break;
                }
                break;
            }
            case ExpressionKind::ConditionalOp: {
                auto& co = e.as<ConditionalExpression>();
                if (co.conditions.size() != 1 || co.conditions[0].pattern)
                    break;
                auto c = evalExpr(*co.conditions[0].expr);
                if (!c)
                    break;
                // Surelog reduces the ternary to INT:<selected branch>, keeping
                // that branch's SIGNEDNESS (no LRM common type).
                return evalExpr(*c != 0 ? co.left() : co.right());
            }
            case ExpressionKind::Concatenation: {
                // A 1-element concat passes the value through; a wider one
                // needs Surelog's per-operand VpiSize model (not replayed).
                auto ops = e.as<ConcatenationExpression>().operands();
                if (ops.size() == 1)
                    return evalExpr(*ops[0]);
                break;
            }
            case ExpressionKind::Call: {
                auto& ce = e.as<CallExpression>();
                if (ce.isSystemCall())
                    break;
                if (auto sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
                    return call(**sp, ce.arguments());
                break;
            }
            case ExpressionKind::BinaryOp: {
                auto& bo = e.as<BinaryExpression>();
                auto l = evalExpr(bo.left());
                if (!l)
                    break;
                auto r = evalExpr(bo.right());
                if (!r)
                    break;
                uint64_t ul = (uint64_t)*l, ur = (uint64_t)*r;
                switch (bo.op) {
                    case BinaryOperator::Add:
                        return (int64_t)(ul + ur);
                    case BinaryOperator::Subtract:
                        return (int64_t)(ul - ur);
                    case BinaryOperator::Multiply:
                        return (int64_t)(ul * ur);
                    case BinaryOperator::Divide:
                        if (*r == 0 || *l < 0 || *r < 0)
                            break;
                        return *l / *r;
                    case BinaryOperator::Mod:
                        if (*r == 0 || *l < 0 || *r < 0)
                            break;
                        return *l % *r;
                    case BinaryOperator::BinaryAnd:
                        return (int64_t)(ul & ur);
                    case BinaryOperator::BinaryOr:
                        return (int64_t)(ul | ur);
                    case BinaryOperator::BinaryXor:
                        return (int64_t)(ul ^ ur);
                    case BinaryOperator::LogicalAnd:
                        return (*l != 0 && *r != 0) ? 1 : 0;
                    case BinaryOperator::LogicalOr:
                        return (*l != 0 || *r != 0) ? 1 : 0;
                    case BinaryOperator::Equality:
                        return *l == *r ? 1 : 0;
                    case BinaryOperator::Inequality:
                        return *l != *r ? 1 : 0;
                    case BinaryOperator::GreaterThan:
                        return *l > *r ? 1 : 0;
                    case BinaryOperator::GreaterThanEqual:
                        return *l >= *r ? 1 : 0;
                    case BinaryOperator::LessThan:
                        return *l < *r ? 1 : 0;
                    case BinaryOperator::LessThanEqual:
                        return *l <= *r ? 1 : 0;
                    // vpiRShiftOp and vpiArithRShiftOp share ExprEval's
                    // ((uint64_t)val0 >> val1) — the 64-bit word is what
                    // decides whether the sign bit propagates.
                    case BinaryOperator::LogicalShiftRight:
                    case BinaryOperator::ArithmeticShiftRight:
                        if (ur >= 64)
                            break;
                        return (int64_t)(ul >> ur);
                    case BinaryOperator::LogicalShiftLeft:
                    case BinaryOperator::ArithmeticShiftLeft:
                        if (ur >= 64)
                            break;
                        return (int64_t)(ul << ur);
                    default:
                        break;
                }
                break;
            }
            default:
                break;
        }
        bad = true;
        return std::nullopt;
    }
};

// Surelog's 64-bit fold can only DIVERGE from the LRM fold where a `>>`/`>>>`
// left operand is NARROWER than 64 bits (so the LRM shifts within that width)
// yet holds a SIGNED subexpression, whose negative value Surelog sign-extends
// to 64 bits before shifting. Its own LRM signedness is irrelevant: a signed
// `-1 >> 2` zero-fills at 32 bits per the LRM but propagates the sign bit
// through Surelog's 64-bit word just the same. Gate the replay on that shape.
static bool hasSignExtendedShift(const SubroutineSymbol& sub) {
    bool found = false;
    sub.getBody().visit(makeVisitor([&](auto& v, const BinaryExpression& b) {
        if (b.op == BinaryOperator::LogicalShiftRight ||
            b.op == BinaryOperator::ArithmeticShiftRight) {
            auto& lhs = stripImplicitConv(b.left());
            if (lhs.type->isIntegral() && lhs.type->getBitWidth() < 64) {
                lhs.visit(makeVisitor(
                    [&](auto& v2, std::derived_from<Expression> auto& sub2) {
                        if (sub2.type->isIntegral() && sub2.type->isSigned())
                            found = true;
                        v2.visitDefault(sub2);
                    }));
            }
        }
        v.visitDefault(b);
    }));
    return found;
}

// A module that IMPORTS (via wildcard or explicit import) and REFERENCES a
// package parameter materializes it as a module-local parameter (Surelog sets
// vpiImported = the package name). A QUALIFIED reference (pkg::P) with no
// import does NOT materialize it (ParameterColonReference, PkgParamAsFunctionArg).
static void collectImportedParams(
    const Scope& body, std::vector<const ParameterSymbol*>& out,
    std::map<const ParameterSymbol*, std::string>& srcOut,
    const std::function<bool(SourceLocation, SourceLocation)>& locLess) {
    std::set<const Symbol*> wildcardPkgs; // packages wildcard-imported
    std::set<const Symbol*> explicitSyms; // explicitly imported symbols
    for (auto& m : body.members()) {
        if (m.kind == SymbolKind::WildcardImport) {
            if (auto* p = m.as<WildcardImportSymbol>().getPackage())
                wildcardPkgs.insert(p);
        }
        else if (m.kind == SymbolKind::ExplicitImport) {
            if (auto* imp = m.as<ExplicitImportSymbol>().importedSymbol())
                explicitSyms.insert(imp);
        }
    }
    if (wildcardPkgs.empty() && explicitSyms.empty())
        return;
    std::set<const Symbol*> seen;
    std::vector<const ParameterSymbol*> found;
    auto v = makeVisitor([&](auto& vis, const NamedValueExpression& nv) {
        if (nv.symbol.kind == SymbolKind::Parameter) {
            auto sc = nv.symbol.getParentScope();
            bool imported = explicitSyms.count(&nv.symbol) ||
                            (sc && wildcardPkgs.count(&sc->asSymbol()));
            if (imported && seen.insert(&nv.symbol).second)
                found.push_back(&nv.symbol.as<ParameterSymbol>());
        }
        vis.visitDefault(nv);
    });
    for (auto& m : body.members()) {
        if (m.kind == SymbolKind::ContinuousAssign)
            m.as<ContinuousAssignSymbol>().getAssignment().visit(v);
        else if (m.kind == SymbolKind::ProceduralBlock)
            m.as<ProceduralBlockSymbol>().getBody().visit(v);
        // A module parameter whose DEFAULT references an imported package
        // param (parameter x = PkgParam) materializes it too. For an
        // OVERRIDDEN param the bound initializer is the override expression,
        // so re-bind the declaration default to keep the pkg ref visible.
        else if (m.kind == SymbolKind::Parameter) {
            auto& ps9 = m.as<ParameterSymbol>();
            const Expression* init = ps9.getInitializer();
            if (isOverriddenParam(ps9)) {
                if (auto* dsyn = paramDefaultSyn(ps9)) {
                    ASTContext actx(body, LookupLocation::max);
                    auto* di9 = &Expression::bind(*dsyn, actx);
                    if (!di9->bad())
                        init = di9;
                }
            }
            if (init)
                init->visit(v);
        }
        // A child INSTANCE param override referencing an imported param
        // (#(.P(AddrSpace + ...))) materializes it too (Surelog).
        else if (m.kind == SymbolKind::Instance) {
            auto& ci = m.as<InstanceSymbol>();
            for (auto& cm : ci.body.members())
                if (cm.kind == SymbolKind::Parameter)
                    if (auto* init2 = cm.as<ParameterSymbol>().getInitializer())
                        init2->visit(v);
            // A PORT CONNECTION whose actual references an imported param
            // (.region_attrs_i(HwDataAttr)) materializes it in THIS module too.
            for (auto* pc : ci.getPortConnections())
                if (pc)
                    if (auto* pe = pc->getExpression())
                        pe->visit(v);
        }
    }
    // Surelog's allModules def is the ELABORATED unique instance: a module
    // whose OWN port is driven (by its instantiator) with an imported package
    // param materializes that param into the def too (the connected value flows
    // into the child's elaborated instance). Scan this body's parent-instance
    // port connections for imported params (the visitor gates on this body's
    // own wildcard/explicit imports, so only params the child imports match).
    if (body.asSymbol().kind == SymbolKind::InstanceBody)
        if (auto* pi = body.asSymbol()
                           .as<InstanceBodySymbol>()
                           .parentInstance)
            for (auto* pc : pi->getPortConnections())
                if (pc)
                    if (auto* pe = pc->getExpression())
                        pe->visit(v);
    // A NET/VARIABLE declaration whose TYPE RANGE references an imported param
    // (logic [$bits(P)-1:0] x, or logic [P-1:0] y) materializes it too — the
    // range keeps a symbolic ref even when the width folds to a constant.
    // Resolve identifiers against the MODULE scope (body).
    std::function<void(const syntax::SyntaxNode&)> scanDeclRange =
        [&](const syntax::SyntaxNode& sn) {
            if (sn.kind == syntax::SyntaxKind::IdentifierName) {
                auto nm = std::string(
                    sn.as<syntax::IdentifierNameSyntax>().identifier.valueText());
                // Explicit imports first, then each wildcard-imported package.
                const Symbol* hit = nullptr;
                for (auto* es : explicitSyms)
                    if (es->name == nm && es->kind == SymbolKind::Parameter) {
                        hit = es;
                        break;
                    }
                if (!hit)
                    for (auto* pkgSym : wildcardPkgs)
                        if (auto* sym = pkgSym->as<PackageSymbol>().find(nm))
                            if (sym->kind == SymbolKind::Parameter) {
                                hit = sym;
                                break;
                            }
                if (hit && seen.insert(hit).second)
                    found.push_back(&hit->as<ParameterSymbol>());
            }
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scanDeclRange(*cn);
        };
    std::set<const syntax::SyntaxNode*> scannedDecls;
    for (auto& m : body.members()) {
        if (m.kind != SymbolKind::Variable && m.kind != SymbolKind::Net)
            continue;
        // The member's syntax is the DECLARATOR; the TYPE (with its range
        // dimensions) lives on the enclosing DataDeclaration/NetDeclaration.
        const syntax::SyntaxNode* dsyn = m.getSyntax();
        if (dsyn && dsyn->parent)
            dsyn = dsyn->parent;
        if (dsyn && scannedDecls.insert(dsyn).second)
            scanDeclRange(*dsyn);
    }
    // A wildcard-imported TYPEDEF whose range references an imported param
    // (typedef logic [SramAw-1:0] t;) materializes that param too — the
    // module lists the typedef and its range keeps a symbolic ref to the
    // param, even when the only use ($bits(t)) folds to a constant.
    std::function<void(const syntax::SyntaxNode&, const Scope&)> scanTd =
        [&](const syntax::SyntaxNode& sn, const Scope& psc) {
            if (sn.kind == syntax::SyntaxKind::IdentifierName) {
                auto nm = sn.as<syntax::IdentifierNameSyntax>().identifier.valueText();
                if (auto* sym = psc.find(std::string(nm)))
                    if (sym->kind == SymbolKind::Parameter && sym->getParentScope() &&
                        wildcardPkgs.count(&sym->getParentScope()->asSymbol()) &&
                        seen.insert(sym).second)
                        found.push_back(&sym->as<ParameterSymbol>());
            }
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scanTd(*cn, psc);
        };
    for (auto* pkgSym : wildcardPkgs) {
        auto& psc = pkgSym->as<PackageSymbol>();
        for (auto& pm : psc.members())
            if (pm.kind == SymbolKind::TypeAlias)
                if (auto* tsyn = pm.getSyntax();
                    tsyn && tsyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                    scanTd(*tsyn->as<syntax::TypedefDeclarationSyntax>().type, psc);
    }
    // STRUCTURAL materialization: a wildcard import `import P::*` materializes
    // ALL of P's transitively-EXPORTED parameters — P's own declared params
    // PLUS the params P itself wildcard-imported (re-export) — regardless of
    // whether any is referenced here. Surelog tags each with vpiImported = P
    // (the immediately-imported package). BitSelectOfParameterPassedToSubmodule
    // re-exports NDioPads through pinmux_pkg into work@top with
    // vpiImported=pinmux_pkg. The srcOut map carries P's name so the emitter
    // can override the param's home-scope name for the re-export case.
    std::function<void(const Symbol*, std::set<const Symbol*>&,
                       std::vector<const ParameterSymbol*>&)>
        collectPkgParams = [&](const Symbol* pkgSym,
                               std::set<const Symbol*>& vis,
                               std::vector<const ParameterSymbol*>& acc) {
            if (!vis.insert(pkgSym).second)
                return;
            auto& psc = pkgSym->as<PackageSymbol>();
            for (auto& pm : psc.members()) {
                if (pm.kind == SymbolKind::Parameter)
                    acc.push_back(&pm.as<ParameterSymbol>());
                else if (pm.kind == SymbolKind::WildcardImport)
                    if (auto* q = pm.as<WildcardImportSymbol>().getPackage())
                        collectPkgParams(q, vis, acc);
            }
        };
    for (auto* pkgSym : wildcardPkgs) {
        std::set<const Symbol*> vis;
        std::vector<const ParameterSymbol*> acc;
        collectPkgParams(pkgSym, vis, acc);
        for (auto* pp : acc)
            if (seen.insert(pp).second) {
                found.push_back(pp);
                // vpiImported = the immediately-imported package P (the home
                // scope may be a deeper package for re-exported params).
                if (pp->getParentScope() &&
                    &pp->getParentScope()->asSymbol() != pkgSym)
                    srcOut[pp] = std::string(pkgSym->name);
            }
    }
    // Surelog orders materialized imported params by their DECLARATION order
    // in the package, not by reference-discovery order.
    std::stable_sort(found.begin(), found.end(),
                     [&](const ParameterSymbol* a, const ParameterSymbol* b) {
                         return locLess(a->location, b->location);
                     });
    out.insert(out.end(), found.begin(), found.end());
}

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                                  bool topShareTs, bool funcScope) {
    // Elaborated module/interface params are clone_tree copies in Surelog, so
    // their unpacked-dim "N-1" op parents its synthetic 1 (see elabParamDim).
    bool savedEpd = elabParamDim;
    elabParamDim = topView && !inPackage && !funcScope;
    struct EpdRestore {
        bool& f;
        bool v;
        ~EpdRestore() { f = v; }
    } epdRestore{elabParamDim, savedEpd};
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    std::vector<const ParameterSymbol*> paramSyms;
    for (auto& member0 : body.members())
        if (member0.kind == SymbolKind::Parameter)
            paramSyms.push_back(&member0.as<ParameterSymbol>());
    // PACKAGES materialize imported params too (pinmux_pkg lists NDioPads
    // with vpiImported — BitSelectOfParameterPassedToSubmodule).
    // srcImp maps a re-exported materialized param to the immediately-imported
    // package name (its vpiImported), overriding its home-scope name.
    std::map<const ParameterSymbol*, std::string> srcImp;
    if (!funcScope) {
        collectImportedParams(body, paramSyms, srcImp,
                              [this](SourceLocation a, SourceLocation b) {
                                  return srcOrderLess(a, b);
                              });
        // The list is SOURCE-LOCATION ordered: materialized imported
        // params (pkg locs, usually earlier) list before declared ones.
        std::stable_sort(paramSyms.begin(), paramSyms.end(),
                         [this](const ParameterSymbol* a,
                                const ParameterSymbol* b) {
                             return srcOrderLess(a->location, b->location);
                         });
    }
    // A materialized package parameter's emitted {param_assign, Rhs constant},
    // keyed by its symbol: a LATER module param whose default is a bare ref to
    // it (parameter logic[..] P = X) clones this constant in the ELAB view
    // (ParameterFromPkg* family).
    std::map<const Symbol*, std::pair<UHDM::param_assign*, UHDM::constant*>>
        pkgRefSrc;
    // param_assigns of PARAMETER-PORT-LIST params (for the elab reorder).
    std::set<const UHDM::any*> portPa9;
    // Tag every param_assign pushed while emitting a PARAMETER-PORT-LIST
    // param (the pushes happen at several sites, so mark by loop iteration).
    size_t paMark9 = 0;
    bool paMarkPort9 = false;
    auto flushPaTag9 = [&]() {
        for (size_t i9 = paMark9; i9 < passigns->size(); i9++)
            if (paMarkPort9)
                portPa9.insert((const UHDM::any*)(*passigns)[i9]);
        paMark9 = passigns->size();
    };
    for (auto* psPtr : paramSyms) {
        const Symbol& member = *psPtr;
        auto& ps = *psPtr;
        // Imported = the param belongs to ANOTHER scope (a package), not the
        // body being emitted (a package emitting its own params is NOT that).
        bool isImported = ps.getParentScope() != &body;
        flushPaTag9();
        paMarkPort9 = !isImported && ps.isPortParam();
        // The package instance a materialized param's typespec is INSTANCED at.
        // For a package view (inPackage), a param DECLARED here instances at
        // this package (m); a re-exported IMPORTED param (pinmux_pkg's
        // materialized NDioPads) instances at its HOME package
        // (prim_pad_wrapper_pkg), not the re-exporting one — Surelog
        // (BitSelectOfParameterPassedToSubmodule).
        auto pkgTsInstance = [&]() -> UHDM::instance* {
            if (inPackage && isImported && ps.getParentScope()) {
                if (auto pit = pkgDefMap.find(&ps.getParentScope()->asSymbol());
                    pit != pkgDefMap.end())
                    return (UHDM::instance*)pit->second;
            }
            return (UHDM::instance*)m;
        };
        // ...and the home package it reaches is the ELABORATED (top) one in
        // BOTH views — Surelog's cross-package instance links land on the
        // elaborated package. The def-package pass runs before top packages
        // exist, so record those for the post-build re-point.
        auto stampPkgTsInst = [&](UHDM::typespec* ts9) {
            if (inPackage && isImported && ps.getParentScope()) {
                const void* home9 = &ps.getParentScope()->asSymbol();
                if (auto tit9 = pkgTopMap.find(home9); tit9 != pkgTopMap.end()) {
                    ts9->Instance(tit9->second);
                    return;
                }
                if (auto pit9 = pkgDefMap.find(home9); pit9 != pkgDefMap.end()) {
                    ts9->Instance(pit9->second);
                    pkgImportTsTopFixups.emplace_back(ts9, home9);
                    return;
                }
            }
            ts9->Instance(pkgTsInstance());
        };
        // Instance overrides: the bound initializer's syntax is the
        // override expression at the instantiation, not the declaration
        // default. Both views keep DEFAULT-derived values; the instance
        // param_assign carries the folded override.
        const syntax::ExpressionSyntax* defaultSyn = paramDefaultSyn(ps);
        const Expression* boundInit = ps.getInitializer();
        bool overridden = isOverriddenParam(ps);
        // A required (override-only) param has NO declaration default; Surelog
        // leaves it valueless/typespec-less in the def view.
        bool hasDefault = defaultSyn != nullptr;
        // The default, bound in this scope (used for values in both views).
        const Expression* defaultInit = hasDefault ? boundInit : nullptr;
        if (overridden) {
            ASTContext actx(body, LookupLocation::max);
            defaultInit = &Expression::bind(*defaultSyn, actx);
            // A bare assignment PATTERN ('{...}) cannot bind without a target
            // type — re-bind with the param's own type so pattern defaults
            // keep their Rhs (tagged-pattern op) instead of silently dropping.
            if (defaultInit->bad())
                defaultInit = &Expression::bindRValue(
                    ps.getType(), *defaultSyn, defaultSyn->sourceRange(), actx);
            if (defaultInit->bad())
                defaultInit = nullptr;
        }
        auto* up = s.MakeParameter();
        up->VpiName(ps.name);
        up->VpiFullName(joinPath(prefix, ps.name));
        up->VpiParent(m);
        setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));
        if (isImported) {
            // Re-exported materialized params carry the IMMEDIATELY-imported
            // package name (srcImp), not their deeper home scope.
            auto siIt = srcImp.find(&ps);
            up->VpiImported(siIt != srcImp.end()
                                ? siIt->second
                                : std::string(ps.getParentScope()->asSymbol().name));
        }

        // Surelog reports vpiLocalParam by the WRITTEN keyword, not slang's
        // LRM-derived local flag: a module-BODY `parameter` (local per LRM
        // when the module has an ANSI header) is a real parameter to Surelog.
        // Packages and function scopes follow the keyword the same way.
        bool isLocal = ps.isLocalParam();
        for (auto q = ps.getSyntax(); q; q = q->parent) {
            if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                isLocal = q->as<syntax::ParameterDeclarationSyntax>().keyword.valueText() ==
                          "localparam";
                break;
            }
        }
        bool typedParam = false;
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax())
                typedParam = tsyn->kind != syntax::SyntaxKind::ImplicitType;
        }
        // An imported param's type syntax may not resolve from the importing
        // module; fall back to a definite integral kind (int/scalar/vector).
        // An IMPLICITLY-typed imported param (parameter W = 48) is NOT promoted:
        // it follows the untyped rules (default int_typespec) exactly as it
        // does in its home package — otherwise a bare vector-canonical value
        // would emit a spurious logic[31:0] typespec (fail_detect_width).
        bool implicitImportDecl = false;
        if (auto d0i = ps.getDeclaredType())
            if (auto ts0i = d0i->getTypeSyntax())
                implicitImportDecl =
                    ts0i->kind == syntax::SyntaxKind::ImplicitType;
        if (isImported && !typedParam && !implicitImportDecl) {
            auto& ct0 = ps.getType().getCanonicalType();
            typedParam = ct0.kind == SymbolKind::PredefinedIntegerType ||
                         ct0.kind == SymbolKind::ScalarType ||
                         (ct0.kind == SymbolKind::PackedArrayType && ct0.isIntegral());
        }
        bool wantTs = false;
        if (isLocal)
            up->VpiLocalParam(true);
        // Function-scope, explicitly-TYPED, and ranged (localparam [7:0] X)
        // localparams are valued and typed like module non-local params.
        // All parameters — including plain local untyped ones (localparam
        // IDLE = 2'b00) — carry a value/typespec (Surelog); the inner
        // literalInit/wantTs gates decide the exact encoding.
        // An ELAB-pkg param with a COMPUTED init (Y+1, g(4)) still carries
        // its evaluated value and an int ts (Surelog folds package elabs).
        bool pkgElabComputed = false;
        if (true) {
            // Params with non-literal initializers carry no value string.
            // Values derive from the DEFAULT initializer even when
            // overridden.
            bool literalInit = false;
            if (defaultInit)
                literalInit = isLiteralExpr(*defaultInit);
            ConstantValue dcv;
            if (overridden && defaultInit) {
                ASTContext actx(body, LookupLocation::max);
                dcv = actx.tryEval(*defaultInit);
            }
            const ConstantValue& cv = overridden ? dcv : ps.getValue();
            bool unknownDefault = cv.isInteger() && cv.integer().hasUnknown();
            if (literalInit && unknownDefault && defaultInit) {
                // 'x/'z defaults: BIN value with UPPERCASE digits.
                std::string raw = rawText(stripImplicitConv(*defaultInit).sourceRange);
                auto tick = raw.find('\'');
                if (tick != std::string::npos) {
                    std::string digits = stripSep(raw.substr(tick + 1));
                    for (auto& ch : digits)
                        ch = (char)toupper(ch);
                    up->VpiValue("BIN:" + digits);
                }
            }
            // An unbased-unsized default ('0/'1/'x/'z) carries a BIN:<bit>
            // parameter value, not a decimal UINT. (Coercion to int can clear
            // the value's unknown flag, so this handles X/Z here rather than
            // relying on the unknownDefault path above.)
            bool unbasedInit =
                defaultInit && stripImplicitConv(*defaultInit).kind ==
                                   ExpressionKind::UnbasedUnsizedIntegerLiteral;
            if (unbasedInit) {
                logic_t bit = stripImplicitConv(*defaultInit)
                                  .as<UnbasedUnsizedIntegerLiteral>()
                                  .getLiteralValue();
                std::string d = bit.isUnknown()
                                    ? (bit.value == logic_t::X_VALUE ? "X" : "Z")
                                    : (bit.value ? "1" : "0");
                up->VpiValue("BIN:" + d);
            }
            pkgElabComputed = inPackage && topView && !literalInit &&
                              !unbasedInit && defaultInit && cv.isInteger() &&
                              !cv.integer().hasUnknown() && [&] {
                                  // Only inits that FOLD in the elab view:
                                  // binary ops and const-function calls.
                                  // Concats/patterns keep their operation
                                  // and carry no param value (Surelog).
                                  const Expression* d9 =
                                      &stripImplicitConv(*defaultInit);
                                  while (d9->kind == ExpressionKind::Conversion)
                                      d9 = &d9->as<ConversionExpression>()
                                                .operand();
                                  if (d9->kind == ExpressionKind::BinaryOp ||
                                      containsUserCall(*defaultInit))
                                      return true;
                                  // A QUALIFIED pkg-param ref init
                                  // (ctrl_pkg::Banks) also folds (value
                                  // carried; loc = the qualifier span).
                                  if (d9->kind == ExpressionKind::NamedValue &&
                                      d9->as<NamedValueExpression>()
                                              .symbol.kind ==
                                          SymbolKind::Parameter &&
                                      (rawText(d9->sourceRange).find("::") !=
                                           std::string::npos ||
                                       // ...and a WILDCARD-imported one, which
                                       // is written bare.
                                       [&] {
                                           auto sc9 =
                                               d9->as<NamedValueExpression>()
                                                   .symbol.getParentScope();
                                           return sc9 &&
                                                  sc9->asSymbol().kind ==
                                                      SymbolKind::Package;
                                       }()))
                                      return true;
                                  return false;
                              }();
            // A MODULE param whose default is a bare/qualified reference to a
            // PACKAGE param carries the folded value too (Surelog) — but an
            // AGGREGATE value never inlines on the parameter object (it lives
            // only in the param_assign Rhs op; BSOPPS work@top.TargetCfg).
            bool modPkgRefFold9 =
                !inPackage && !literalInit && !unbasedInit && defaultInit &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::PackedStructType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::PackedUnionType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::UnpackedStructType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::UnpackedUnionType &&
                cv.isInteger() && !cv.integer().hasUnknown() && [&] {
                    const Expression* d8 = &stripImplicitConv(*defaultInit);
                    while (d8->kind == ExpressionKind::Conversion)
                        d8 = &d8->as<ConversionExpression>().operand();
                    if (d8->kind != ExpressionKind::NamedValue)
                        return false;
                    auto& sy8 = d8->as<NamedValueExpression>().symbol;
                    if (sy8.kind != SymbolKind::Parameter)
                        return false;
                    auto sc8 = sy8.getParentScope();
                    return sc8 && sc8->asSymbol().kind == SymbolKind::Package;
                }();
            if (!unbasedInit && (literalInit || pkgElabComputed ||
                                 modPkgRefFold9) &&
                cv.isInteger() && !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = (iv.isSigned() && iv.isNegative()) ||
                           (pkgElabComputed && iv.isSigned() && defaultInit &&
                            containsUserCall(*defaultInit));
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                std::string value = (neg ? "INT:" : "UINT:") + digits;
                // Based-literal initializers keep their base encoding — a
                // pkg-param REFERENCE inherits the referenced param's.
                const Expression* encSrc9 = defaultInit;
                if (defaultInit) {
                    auto& r9 = stripImplicitConv(*defaultInit);
                    if (r9.kind == ExpressionKind::NamedValue &&
                        r9.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter)
                        if (auto* pi9 = r9.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>()
                                            .getInitializer())
                            encSrc9 = pi9;
                }
                if (auto init0 = encSrc9) {
                    auto& lit = stripImplicitConv(*init0);
                    if (lit.kind == ExpressionKind::IntegerLiteral) {
                        std::string raw = rawText(lit.sourceRange);
                        auto tick = raw.find('\'');
                        if (tick != std::string::npos) {
                            size_t basePos = tick + 1;
                            if (basePos < raw.size() &&
                                (raw[basePos] == 's' || raw[basePos] == 'S'))
                                basePos++;
                            char base = basePos < raw.size() ? (char)tolower(raw[basePos])
                                                             : 'd';
                            std::string litDigits = stripSep(raw.substr(basePos + 1));
                            switch (base) {
                                case 'b':
                                    value = "BIN:" + litDigits;
                                    break;
                                case 'h':
                                    value = "HEX:" + litDigits;
                                    break;
                                case 'o':
                                    value = "OCT:" + litDigits;
                                    break;
                                default:
                                    value = "DEC:" + litDigits;
                                    break;
                            }
                        }
                    }
                }
                up->VpiValue(value);
            }
            // Real params carry a REAL:<%f> value.
            if (defaultInit && cv.isReal()) {
                char buf[64];
                snprintf(buf, sizeof(buf), "%f", (double)cv.real());
                up->VpiValue(std::string("REAL:") + buf);
            }
            // String params carry a STRING:<text> value.
            if (defaultInit && literalInit && cv.isString())
                up->VpiValue("STRING:" + cv.str());
            // The value mirrors the INIT LITERAL's kind, not the param type:
            // a REAL literal keeps REAL:%f even on an integral param (p1);
            // an INT literal keeps UINT even on a real param (p3) — realexpr.
            if (defaultInit) {
                auto& il9 = stripImplicitConv(*defaultInit);
                if (il9.kind == ExpressionKind::RealLiteral && !cv.isReal()) {
                    char buf9[64];
                    snprintf(buf9, sizeof(buf9), "%f",
                             il9.as<RealLiteral>().getValue());
                    up->VpiValue(std::string("REAL:") + buf9);
                }
                else if (il9.kind == ExpressionKind::IntegerLiteral &&
                         cv.isReal())
                    up->VpiValue("UINT:" +
                                 std::string(rawText(il9.sourceRange)));
                // A STRING-literal init on an (implicitly) integral param
                // keeps STRING:<text> (const_func: parameter OUTPUT = "FOO").
                else if (il9.kind == ExpressionKind::StringLiteral &&
                         !cv.isString())
                    up->VpiValue(
                        "STRING:" +
                        std::string(il9.as<StringLiteral>().getValue()));
            }
            // Untyped params carry a typespec only for LITERAL initializers;
            // computed values ($clog2(W), 2**S) get none. Typed and ranged
            // params always do.
            auto& ctw = ps.getType().getCanonicalType();
            // Typed/ranged params always carry a typespec (its range/type is
            // independent of the value); only an untyped literal is gated on a
            // known value.
            bool realLit =
                defaultInit && stripImplicitConv(*defaultInit).kind ==
                                   ExpressionKind::RealLiteral;
            // An implicitly-typed param carrying an explicit SIGNING keyword
            // (localparam signed Y = $floor(W / X)) always gets its
            // int_typespec — located at the signing keyword — even when the
            // init is COMPUTED (Surelog; const_func Y/Z).
            bool signedImplicitTs = false;
            if (auto ds9 = ps.getDeclaredType())
                if (auto ts9 = ds9->getTypeSyntax())
                    if (ts9->kind == syntax::SyntaxKind::ImplicitType)
                        signedImplicitTs =
                            ts9->as<syntax::ImplicitTypeSyntax>()
                                .signing.valid() &&
                            ts9->as<syntax::ImplicitTypeSyntax>()
                                .dimensions.empty();
            wantTs = (ctw.isIntegral() || ctw.isFloating() || ctw.isStruct() ||
                      (ctw.isString() && (typedParam || literalInit))) &&
                     (typedParam || isRangedUntypedParam(ps) ||
                      signedImplicitTs || pkgElabComputed ||
                      ((literalInit || realLit) && !unknownDefault));
        }
        if (auto declared0 = ps.getDeclaredType()) {
            if (auto tsyn0 = declared0->getTypeSyntax()) {
                // Surelog flags vpiSigned only when the declaration carries an
                // explicit `parameter`/`localparam` keyword (parameter int P,
                // or #(parameter int W)). The bare ANSI form #(int x = 0) omits
                // the keyword and gets no vpiSigned (its signedness lives on the
                // int_typespec actual instead).
                bool hasKeyword = false;
                for (auto q = ps.getSyntax(); q; q = q->parent) {
                    if (syntax::ParameterDeclarationBaseSyntax::isKind(q->kind)) {
                        hasKeyword = q->as<syntax::ParameterDeclarationBaseSyntax>()
                                         .keyword.kind != parsing::TokenKind::Unknown;
                        break;
                    }
                }
                if (tsyn0->kind != syntax::SyntaxKind::ImplicitType &&
                    ps.getType().getCanonicalType().isSigned() && hasKeyword &&
                    // ENUM-typed params carry no vpiSigned (Surelog).
                    ps.getType().getCanonicalType().kind != SymbolKind::EnumType &&
                    // TYPEDEF-typed params (localparam int4_t P) carry no
                    // vpiSigned either — Surelog never resolves an alias's
                    // signedness onto the parameter object (typedef_param).
                    declared0->getType().kind != SymbolKind::TypeAlias)
                    up->VpiSigned(true);
            }
        }
        UHDM::ref_typespec* prt = nullptr;
        // The unpacked-array param's own array_typespec, captured so the
        // elab-view folded pattern op can SHARE it (Surelog points the op's ts
        // ref at the SAME array_typespec object).
        UHDM::array_typespec* paramArrayTs = nullptr;
        // In the ELAB view Surelog builds the param_assign RHS's typespec
        // clone BEFORE the parameter's own, so the parameter's clone is
        // created behind this closure (forced at the end of the param).
        std::function<UHDM::array_typespec*()> paramArrTs =
            [&paramArrayTs]() { return paramArrayTs; };
        bool hasParamArrTs = false;
        if (wantTs) {
            // The actual typespec object is created late (after the instance
            // ports) to match Surelog's arena order; the ref is patched then.
            prt = s.MakeRef_typespec();
            prt->VpiFullName(joinPath(prefix, ps.name));
            prt->VpiParent(up);
            up->Typespec(prt);
        }
        // An UNPACKED-ARRAY param (int X [1:0]) is not isIntegral, so the
        // wantTs path skips it. Surelog gives it an array_typespec (unpacked
        // range + Elem_typespec) plus the element's signedness/size and the
        // unpacked-dim range ON the parameter (shared range object).
        else if (ps.getType().getCanonicalType().kind ==
                 SymbolKind::FixedSizeUnpackedArrayType) {
            const Type* leaf = &ps.getType().getCanonicalType();
            while (leaf->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leaf = &leaf->getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>()
                            .elementType;
            std::string afull = joinPath(prefix, ps.name);
            // Unpacked-dim range, parented to the param and SHARED with the
            // array_typespec (Surelog uses one range object for both).
            // BOTH views: dims referencing an OVERRIDDEN param keep SYMBOLIC
            // bounds, bare refs scoped through the param
            // (param_array_wildcard — elab uses op11 with the elab-scoped
            // ref name too).
            std::string dimPrefix9;
            {
                bool ovr9 = false;
                if (auto dsyn9 = ps.getSyntax();
                    dsyn9 && dsyn9->kind == syntax::SyntaxKind::Declarator) {
                    for (auto dim9 :
                         dsyn9->as<syntax::DeclaratorSyntax>().dimensions) {
                        std::function<void(const syntax::SyntaxNode&)> scan9 =
                            [&](const syntax::SyntaxNode& sn9) {
                                if (sn9.kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                    auto nm9 =
                                        sn9.as<syntax::IdentifierNameSyntax>()
                                            .identifier.valueText();
                                    if (auto* hit9 =
                                            body.find(std::string(nm9));
                                        hit9 &&
                                        hit9->kind ==
                                            SymbolKind::Parameter &&
                                        isOverriddenParam(*hit9))
                                        ovr9 = true;
                                }
                                for (size_t i9 = 0;
                                     i9 < sn9.getChildCount(); i9++)
                                    if (auto* cn9 = sn9.childNode(i9))
                                        scan9(*cn9);
                            };
                        scan9(*dim9);
                    }
                }
                if (ovr9)
                    dimPrefix9 = afull;
            }
            auto* prng = buildUnpackedRanges(ps, up, dimPrefix9);
            if (prng)
                up->Ranges(prng);
            up->VpiSize(1);
            up->VpiSigned(leaf->isSigned());
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(afull);
            art->VpiParent(up);
            up->Typespec(art);
            hasParamArrTs = true;
            if (topView && !inPackage &&
                m->UhdmType() == UHDM::uhdmmodule_inst) {
                // ELAB clone: OWN range objects, parented at the ref_typespec
                // that holds it (the def view keeps the compile-time shape:
                // parent = the parameter, ranges shared with it). Minted after
                // the instance's net/port typespecs unless the folded-pattern
                // path needs it sooner.
                auto mk = [this, psp = &ps, afull, art,
                           dimPrefix9]() -> UHDM::array_typespec* {
                    if (auto* ex = art->Actual_typespec())
                        return (UHDM::array_typespec*)ex;
                    // The clone's own "N-1" dim op parents its synthetic 1
                    // (elab shape) even when minted in the write phase, and
                    // its bounds stay symbolic when the def's did.
                    bool saved = elabParamDim;
                    elabParamDim = true;
                    auto* ats = makeUnpackedArrayParamTs(*psp, afull, art,
                                                         nullptr, true, dimPrefix9);
                    elabParamDim = saved;
                    art->Actual_typespec(ats);
                    return ats;
                };
                paramArrTs = mk;
                pendingElabArrayTs.push_back([mk]() { mk(); });
            }
            else {
                paramArrayTs = makeUnpackedArrayParamTs(ps, afull, up, prng);
                art->Actual_typespec(paramArrayTs);
            }
        }
        params->push_back(up);
        if (funcScope)
            netMap[&member] = up;

        UHDM::ref_typespec* rhsRt = nullptr;
        // The Rhs constant captured for pkgRefSrc, and a flag suppressing the
        // deferred ts patch when a pkg-ref clone binds its own (pkg-located) ts.
        UHDM::constant* rhsConstForMap = nullptr;
        bool pkgRefFold = false;
        auto* pa = s.MakeParam_assign();
        if (topView)
            elabParamPa[&member] = pa;
        pa->VpiParent(m);
        if (auto syn = ps.getSyntax())
            setLoc(pa, syn->sourceRange());
        pa->Lhs(up);
        // DEF-view materialized IMPORTED vector-typedef param: the param_assign
        // Lhs is a SEPARATE parameter clone with its own ts clone chain
        // (Surelog).
        UHDM::parameter* upLhs9 = nullptr;
        UHDM::ref_typespec* prtLhs9 = nullptr;
        if (!topView && !inPackage && isImported && prt) {
            bool wantLhsClone9 = false;
            if (auto dLhs = ps.getDeclaredType()) {
                // Vector-typedef materialized imports (its home typedef) and
                // plain TYPED materialized imports both clone.
                if (dLhs->getType().kind == SymbolKind::TypeAlias &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    ps.getType().getCanonicalType().isIntegral() &&
                    dLhs->getType().getParentScope() == ps.getParentScope())
                    wantLhsClone9 = true;
                else if (auto tsy9 = dLhs->getTypeSyntax();
                         tsy9 &&
                         tsy9->kind != syntax::SyntaxKind::ImplicitType)
                    wantLhsClone9 = true;
                // A plain UNTYPED integral import (parameter W = 48) ALSO gets a
                // separate def-view Lhs clone (Surelog; fail_detect_width). The
                // implicit type canonicalizes to a packed logic vector, so no
                // packed-array exclusion here (the TypeAlias vector case is
                // handled by the first branch above).
                else if (auto tsy9b = dLhs->getTypeSyntax();
                         tsy9b &&
                         tsy9b->kind == syntax::SyntaxKind::ImplicitType &&
                         ps.getType().getCanonicalType().isIntegral())
                    wantLhsClone9 = true;
            }
            if (wantLhsClone9) {
                upLhs9 = s.MakeParameter();
                upLhs9->VpiName(up->VpiName());
                upLhs9->VpiFullName(up->VpiFullName());
                upLhs9->VpiLineNo(up->VpiLineNo());
                upLhs9->VpiColumnNo(up->VpiColumnNo());
                upLhs9->VpiEndLineNo(up->VpiEndLineNo());
                upLhs9->VpiEndColumnNo(up->VpiEndColumnNo());
                upLhs9->VpiImported(std::string(up->VpiImported()));
                upLhs9->VpiValue(std::string(up->VpiValue()));
                if (up->VpiSigned())
                    upLhs9->VpiSigned(true);
                if (up->VpiLocalParam())
                    upLhs9->VpiLocalParam(true);
                upLhs9->VpiParent(pa);
                prtLhs9 = s.MakeRef_typespec();
                prtLhs9->VpiFullName(std::string(prt->VpiFullName()));
                prtLhs9->VpiParent(upLhs9);
                upLhs9->Typespec(prtLhs9);
                pa->Lhs(upLhs9);
            }
        }
        // Function-scope params parent at their param_assign.
        if (funcScope)
            up->VpiParent(pa);
        // A UNIQUIFIED (multi-param-def) instance also marks params whose
        // VALUE differs from the default-eval as overriden — a DERIVED
        // param ('1 sized by an overridden typedef width) counts
        // (ParameterOfParametrizedTypeInSubmodule Y). Single-instance
        // defparam targets stay unmarked (hierdefparam).
        bool derivedOv9 = false;
        if (topView && !overridden && hasDefault && defaultInit &&
            !inPackage && isMultiParamDef(body)) {
            // Derived = the declared type resolves through a TYPEDEF whose
            // target references an OVERRIDDEN param of this body.
            if (auto od9 = ps.getDeclaredType()) {
                auto& dt9o = od9->getType();
                if (dt9o.kind == SymbolKind::TypeAlias) {
                    std::string tgt9;
                    if (auto asyn9 = dt9o.as<TypeAliasType>().getSyntax())
                        tgt9 = std::string(rawText(asyn9->sourceRange()));
                    if (!tgt9.empty())
                        for (auto& om9 : body.members()) {
                            if (om9.kind != SymbolKind::Parameter ||
                                !isOverriddenParam(om9))
                                continue;
                            auto p9 = tgt9.find(om9.name);
                            while (p9 != std::string::npos) {
                                bool lb9 =
                                    p9 == 0 ||
                                    (!isalnum((unsigned char)tgt9[p9 - 1]) &&
                                     tgt9[p9 - 1] != '_');
                                size_t e9 = p9 + om9.name.size();
                                bool rb9 =
                                    e9 >= tgt9.size() ||
                                    (!isalnum((unsigned char)tgt9[e9]) &&
                                     tgt9[e9] != '_');
                                if (lb9 && rb9) {
                                    derivedOv9 = true;
                                    break;
                                }
                                p9 = tgt9.find(om9.name, p9 + 1);
                            }
                            if (derivedOv9)
                                break;
                        }
                }
            }
        }
        if (topView &&
            (overridden || derivedOv9 || (!hasDefault && boundInit)))
            pa->VpiOverriden(true);
        // A module-scope typed localparam whose init element-selects an
        // UNPACKED-ARRAY param (localparam int C = Arr[Idx]) CLAIMS the
        // selected operand of the array's ELAB pattern op: that operand
        // constant gets a ts ref (module-scoped fullname) to a fresh
        // int_typespec at the claiming param's declared-type span (Surelog;
        // ModuleInstantiationAndIndirectParams — module-level twin of the
        // gen-scope adopter in ModuleEmit).
        if (topView && !inPackage && !overridden && defaultInit &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PredefinedIntegerType) {
            auto& se0 = stripImplicitConv(*defaultInit);
            if (se0.kind == ExpressionKind::ElementSelect) {
                auto& es0 = se0.as<ElementSelectExpression>();
                auto& bv = stripImplicitConv(es0.value());
                if (bv.kind == ExpressionKind::NamedValue &&
                    bv.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter) {
                    auto& rp =
                        bv.as<NamedValueExpression>().symbol.as<ParameterSymbol>();
                    auto oit = elabArrayPatternOp.find(&rp);
                    auto& rpt = rp.getType().getCanonicalType();
                    ASTContext ec0(comp.getRoot(), LookupLocation::max);
                    ConstantValue iv = ec0.tryEval(es0.selector());
                    if (oit != elabArrayPatternOp.end() && iv && iv.isInteger() &&
                        rpt.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                        auto* op0 = oit->second;
                        int64_t ix = iv.integer().as<int64_t>().value_or(-1);
                        auto rng = rpt.as<FixedSizeUnpackedArrayType>().range;
                        int32_t lo = std::min(rng.left, rng.right);
                        int64_t pos = ix - lo;
                        if (op0->VpiReordered() != 1 && op0->Operands() &&
                            ix >= 0 && pos >= 0 &&
                            pos < (int64_t)op0->Operands()->size()) {
                            auto* opnd = (*op0->Operands())[pos];
                            if (opnd->UhdmType() == UHDM::uhdmconstant &&
                                !((UHDM::constant*)opnd)->Typespec()) {
                                auto* ort = s.MakeRef_typespec();
                                std::string tsPfx = prefix;
                                if (tsPfx.size() >= 2 &&
                                    tsPfx.compare(tsPfx.size() - 2, 2, "::") == 0)
                                    tsPfx.resize(tsPfx.size() - 2);
                                ort->VpiFullName(tsPfx);
                                ort->VpiParent(opnd);
                                auto* oits = s.MakeInt_typespec();
                                oits->VpiSigned(true);
                                SourceRange otr(ps.location, ps.location);
                                if (auto od = ps.getDeclaredType())
                                    if (auto otsyn = od->getTypeSyntax())
                                        otr = otsyn->getFirstToken().range();
                                setLoc(oits, otr);
                                oits->VpiParent(ort);
                                ort->Actual_typespec(oits);
                                ((UHDM::constant*)opnd)->Typespec(ort);
                            }
                        }
                    }
                }
            }
        }
        // Instance view of an override: folded constant, base-encoded and
        // override-site-anchored for literal overrides; expression overrides
        // anchor at the DEFAULT initializer.
        // A NO-DEFAULT param bound to an EXPRESSION (.Width(A+B)) also folds
        // directly here — the cont-assign backpatch (noDefOvPa) only shares
        // LITERAL overrides, so an expression bind would otherwise get NO Rhs.
        bool noDefExprOv =
            !hasDefault && topView && boundInit &&
            stripImplicitConv(*boundInit).kind != ExpressionKind::IntegerLiteral;
        // A NO-DEFAULT param positionally/named overridden by an integer
        // LITERAL in a MULTIPARAM def: Surelog's uniquified elab param_assign
        // carries a LOC-LESS folded UINT constant directly (an untyped one at
        // width 64, no typespec; a typed one at its type width with typespec).
        bool noDefLitMP =
            !hasDefault && topView && boundInit && isMultiParamDef(body) &&
            stripImplicitConv(*boundInit).kind == ExpressionKind::IntegerLiteral;
        // ELAB view of a PACKED-STRUCT param OVERRIDDEN by a bare REFERENCE to
        // a (local)param whose own init is an assignment PATTERN
        // (`bus_if #(C) bus()`, `localparam p::cfg_t C = '{...}`): Surelog does
        // NOT fold the aggregate to one packed constant — it re-emits the
        // REFERENCED param's pattern as the flat op75 (per-member operands at
        // their own source spans/encodings, nested member patterns kept as
        // nested op75s), anchored at the OVERRIDE-SITE span and tagged with the
        // instance-scoped struct typespec. Keeping the operation form also
        // makes the modport port-view retain the param_assign (an aggregate
        // value cannot inline on the parameter object).
        // iface_wholestruct_param / iface_cfg_param_def_pass.
        const Expression* structOvPat = nullptr;
        SourceRange structOvLoc;
        if (topView && overridden && boundInit &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PackedStructType) {
            auto& bi8 = stripImplicitConv(*boundInit);
            const Symbol* rs8 = nullptr;
            if (bi8.kind == ExpressionKind::NamedValue)
                rs8 = &bi8.as<NamedValueExpression>().symbol;
            else if (bi8.kind == ExpressionKind::HierarchicalValue)
                rs8 = &bi8.as<HierarchicalValueExpression>().symbol;
            if (rs8 && rs8->kind == SymbolKind::Parameter)
                if (auto* rin8 = rs8->as<ParameterSymbol>().getInitializer()) {
                    auto& si8 = stripImplicitConv(*rin8);
                    if (si8.kind ==
                            ExpressionKind::StructuredAssignmentPattern ||
                        si8.kind == ExpressionKind::SimpleAssignmentPattern) {
                        structOvPat = &si8;
                        structOvLoc = bi8.sourceRange;
                    }
                }
        }
        // A module struct param DEFAULTED from a bare reference to a
        // PACKAGE struct param (`parameter target_cfg_t TargetCfg =
        // DefaultTargetCfg`) substitutes that param's pattern the same way in
        // the ELAB view — as the FLAT op75 over the reference's own span (the
        // DEF view keeps the plain ref_obj). BSOPPS*.
        if (!structOvPat && topView && !inPackage && !overridden &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PackedStructType &&
            ps.getParentScope() == &body && ps.getInitializer()) {
            auto& bi7 = stripImplicitConv(*ps.getInitializer());
            if (bi7.kind == ExpressionKind::NamedValue) {
                auto& rs7 = bi7.as<NamedValueExpression>().symbol;
                if (rs7.kind == SymbolKind::Parameter && rs7.getParentScope() &&
                    rs7.getParentScope()->asSymbol().kind == SymbolKind::Package)
                    if (auto* rin7 = rs7.as<ParameterSymbol>().getInitializer()) {
                        auto& si7 = stripImplicitConv(*rin7);
                        if (si7.kind ==
                                ExpressionKind::StructuredAssignmentPattern ||
                            si7.kind == ExpressionKind::SimpleAssignmentPattern) {
                            structOvPat = &si7;
                            structOvLoc = bi7.sourceRange;
                        }
                    }
            }
        }
        // An instance param OVERRIDE whose actual is a LOCALPARAM initialized
        // from a struct-param MEMBER (.Depth(N), N = Info.x) keeps a SYMBOLIC
        // hier_path Rhs (re-emit of N's init) at the override-site span, rather
        // than folding to the connected value (Surelog).
        const ParameterSymbol* ovMemberInitParam = nullptr;
        if (topView && overridden && boundInit) {
            auto& bi = stripImplicitConv(*boundInit);
            const Symbol* refSym = nullptr;
            if (bi.kind == ExpressionKind::NamedValue)
                refSym = &bi.as<NamedValueExpression>().symbol;
            else if (bi.kind == ExpressionKind::HierarchicalValue)
                refSym = &bi.as<HierarchicalValueExpression>().symbol;
            // Only a NON-overridden localparam holds a genuine member-init in
            // its declared init; an OVERRIDDEN param's getInitializer() returns
            // the override expression (e.g. PadType=TargetCfg.dio_pad_type),
            // which Surelog folds at the connection instead of re-emitting.
            if (refSym && refSym->kind == SymbolKind::Parameter &&
                !isOverriddenParam(refSym->as<ParameterSymbol>()))
                if (auto* pin =
                        refSym->as<ParameterSymbol>().getInitializer()) {
                    auto& si = stripImplicitConv(*pin);
                    if (si.kind == ExpressionKind::MemberAccess) {
                        auto& mb = stripImplicitConv(
                            si.as<MemberAccessExpression>().value());
                        if (mb.kind == ExpressionKind::NamedValue &&
                            mb.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter &&
                            mb.as<NamedValueExpression>()
                                    .symbol.getType()
                                    .getCanonicalType()
                                    .kind == SymbolKind::PackedStructType)
                            ovMemberInitParam =
                                &refSym->as<ParameterSymbol>();
                    }
                }
        }
        if (topView && (overridden || noDefExprOv || noDefLitMP) &&
            !structOvPat) {
            auto& cvo = ps.getValue();
            // UNBASED-UNSIZED override actuals (#(.VALUE('0)) etc.,
            // unbased_unsized_param sp13..sp16): the pa Rhs constant keeps
            // the unbased encoding with a LOCATED declared-type ts; the
            // child's reading cont_assign later CLAIMS the same object
            // ('0/'x/'z) or copies it ('1).
            if (boundInit) {
                auto& ub9 = stripImplicitConv(*boundInit);
                if (ub9.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    logic_t bit9 = ub9.as<UnbasedUnsizedIntegerLiteral>()
                                       .getLiteralValue();
                    auto* c9 = s.MakeConstant();
                    if (bit9.isUnknown()) {
                        std::string d9 =
                            bit9.value == logic_t::X_VALUE ? "X" : "Z";
                        c9->VpiDecompile("'b" + d9);
                        c9->VpiSize(-1);
                        c9->VpiValue("BIN:" + d9);
                        c9->VpiConstType(vpiBinaryConst);
                    }
                    else if (bit9.value == 0) {
                        c9->VpiDecompile("'b0");
                        c9->VpiSize(64);
                        c9->VpiValue("BIN:0");
                        c9->VpiConstType(vpiBinaryConst);
                    }
                    else {
                        slang::SVInt ones9(
                            (slang::bitwidth_t)ps.getType().getBitWidth(), 0,
                            false);
                        ones9 = ~ones9;
                        std::string d9 =
                            ones9.toString(LiteralBase::Decimal, false);
                        c9->VpiDecompile(d9);
                        c9->VpiSize((int32_t)ps.getType().getBitWidth());
                        c9->VpiValue("UINT:" + d9);
                        c9->VpiConstType(vpiUIntConst);
                    }
                    c9->VpiParent(pa);
                    auto* rt9 = s.MakeRef_typespec();
                    std::string tsPfx9 = prefix;
                    if (tsPfx9.size() >= 2 &&
                        tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                        tsPfx9.resize(tsPfx9.size() - 2);
                    rt9->VpiFullName(tsPfx9);
                    rt9->VpiParent(c9);
                    if (prt) {
                        // Bound below (patchParamTypespecs) to the param's own
                        // elab ts object; copies of this constant clone it.
                        unbasedOvTsRef[&ps] = rt9;
                    }
                    else {
                        auto* lts9 = s.MakeLogic_typespec();
                        if (auto dt9 = ps.getDeclaredType())
                            if (auto tsy9 = dt9->getTypeSyntax())
                                setLoc(lts9, tsy9->sourceRange());
                        rt9->Actual_typespec(lts9);
                    }
                    c9->Typespec(rt9);
                    pa->Rhs(c9);
                    elabParamConst[&ps] = c9;
                    unbasedOvConst[&ps] = c9;
                    passigns->push_back(pa);
                    if (prt)
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    continue;
                }
            }
            // An override ACTUAL that reads a parameter through a HIERARCHICAL
            // member path (#(.SYS_DAT(s.CFG.BUS.DAT))) keeps the SYMBOLIC
            // hier_path Rhs at the override-site span: Surelog's reduce never
            // crosses the interface-member hop (iface_param_2level). vpiExpr
            // aliases the ENCLOSING instance's interface-port LowConn ref.
            const Expression* ovHierInit = nullptr;
            if (boundInit) {
                auto& bi7 = stripImplicitConv(*boundInit);
                const Expression* b7 = &bi7;
                while (b7->kind == ExpressionKind::MemberAccess)
                    b7 = &stripImplicitConv(
                        b7->as<MemberAccessExpression>().value());
                if (b7 != &bi7 &&
                    b7->kind == ExpressionKind::HierarchicalValue &&
                    b7->as<HierarchicalValueExpression>().symbol.kind ==
                        SymbolKind::Parameter)
                    ovHierInit = &bi7;
            }
            if (ovHierInit) {
                auto* he = (UHDM::expr*)emitExpr(*ovHierInit, pa, prefix, netMap);
                if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                    auto* hp = (UHDM::hier_path*)he;
                    std::string hn(hp->VpiName());
                    if (auto d0 = hn.find('.'); d0 != std::string::npos)
                        hn.resize(d0);
                    std::string up0 = prefix;
                    if (auto d1 = up0.rfind('.'); d1 != std::string::npos)
                        up0.resize(d1);
                    else
                        up0.clear();
                    if (!up0.empty() && !hn.empty())
                        if (auto lit =
                                ifacePortLowConnByPath.find(up0 + "." + hn);
                            lit != ifacePortLowConnByPath.end())
                            hp->Root_value(lit->second);
                }
                pa->Rhs(he);
                passigns->push_back(pa);
                if (prt)
                    pendingParamTs.push_back(
                        {&ps, up, prt, nullptr, typedParam});
                continue;
            }
            if (ovMemberInitParam) {
                auto* init = ovMemberInitParam->getInitializer();
                // Re-emitting the referenced localparam's member-init path
                // (Info.x): flag the param-init context so the hier_path uses
                // the lvalue-style base span + bare leaf (Surelog).
                inParamInit = true;
                auto* he = (UHDM::expr*)emitExpr(*init, pa, prefix, netMap);
                inParamInit = false;
                if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                    auto* hp = (UHDM::hier_path*)he;
                    if (boundInit)
                        setLoc(hp, boundInit->sourceRange);
                    // ref_typespec scoped to N's owning module (work@top.Info.x),
                    // actual = N's own (int) typespec.
                    std::string npfx = prefix;
                    if (auto dp = npfx.rfind('.'); dp != std::string::npos)
                        npfx.resize(dp);
                    else
                        npfx.clear();
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(npfx.empty()
                                        ? std::string(hp->VpiName())
                                        : npfx + "." + std::string(hp->VpiName()));
                    rt->VpiParent(hp);
                    auto* its = s.MakeInt_typespec();
                    if (auto dt = ovMemberInitParam->getDeclaredType())
                        if (auto* tsyn = dt->getTypeSyntax())
                            setLoc(its, tsyn->sourceRange());
                    if (ovMemberInitParam->getType().isSigned())
                        its->VpiSigned(true);
                    rt->Actual_typespec(its);
                    hp->Typespec(rt);
                }
                pa->Rhs(he);
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
            if (cvo.isInteger()) {
                auto& iv = cvo.integer();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                // A GENERATE-containing child is uniquified by Surelog's
                // elaboration: its overrides encode UINT at the value width
                // even for untyped params. INTERFACE instances do the same.
                bool genChild = m->UhdmType() == UHDM::uhdminterface_inst;
                for (auto& mb0 : body.members())
                    if (mb0.kind == SymbolKind::GenerateBlock ||
                        mb0.kind == SymbolKind::GenerateBlockArray) {
                        genChild = true;
                        break;
                    }
                // A definition instantiated with MULTIPLE DISTINCT parameter
                // values is uniquified by Surelog: its untyped overrides encode
                // UINT at the value width (like the gen/interface case) rather
                // than INT/size-1.
                if (isMultiParamDef(body))
                    genChild = true;
                // Children INSTANTIATED INSIDE a gen scope are uniquified
                // too (generate_test adder_inst) — UINT at the width.
                if (!genChild &&
                    body.asSymbol().kind == SymbolKind::InstanceBody &&
                    body.asSymbol().as<InstanceBodySymbol>().parentInstance)
                    if (auto psc9 = body.asSymbol()
                                        .as<InstanceBodySymbol>()
                                        .parentInstance->getParentScope();
                        psc9 &&
                        (psc9->asSymbol().kind == SymbolKind::GenerateBlock ||
                         psc9->asSymbol().kind ==
                             SymbolKind::GenerateBlockArray))
                        genChild = true;
                // A VECTOR-TYPEDEF param's literal override keeps its SOURCE
                // base form (384'b1 -> BIN:1, binary const) — Surelog.
                bool vecAliasOv8 = false;
                if (typedParam && boundInit && ps.getDeclaredType() &&
                    (ps.getDeclaredType()->getType().kind ==
                         SymbolKind::TypeAlias ||
                     // WIDE (>64-bit) direct-vector params too: the int64
                     // fold would overflow — keep the source base form.
                     ps.getType().getBitWidth() > 64) &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    stripImplicitConv(*boundInit).kind ==
                        ExpressionKind::IntegerLiteral) {
                    std::string raw8(
                        rawText(stripImplicitConv(*boundInit).sourceRange));
                    auto tick8 = raw8.find('\'');
                    if (tick8 != std::string::npos && tick8 + 1 < raw8.size()) {
                        size_t bp8 = tick8 + 1;
                        if (raw8[bp8] == 's' || raw8[bp8] == 'S')
                            bp8++;
                        char base8 = (char)tolower((unsigned char)raw8[bp8]);
                        std::string dg8 = stripSep(raw8.substr(bp8 + 1));
                        if (base8 == 'b' || base8 == 'h' || base8 == 'o') {
                            c->VpiValue((base8 == 'b'   ? "BIN:"
                                         : base8 == 'h' ? "HEX:"
                                                        : "OCT:") +
                                        dg8);
                            c->VpiConstType(base8 == 'b'   ? vpiBinaryConst
                                            : base8 == 'h' ? vpiHexConst
                                                           : vpiOctConst);
                            c->VpiSize((int32_t)iv.getBitWidth());
                            c->VpiDecompile(stripSep(raw8));
                            vecAliasOv8 = true;
                        }
                    }
                }
                // A STRING-literal override keeps STRING:<text> with the bare
                // text decompile at the value width (const_func #("BAR")).
                bool strOv8 = false;
                if (boundInit && stripImplicitConv(*boundInit).kind ==
                                     ExpressionKind::StringLiteral) {
                    std::string txt8(stripImplicitConv(*boundInit)
                                         .as<StringLiteral>()
                                         .getValue());
                    c->VpiValue("STRING:" + txt8);
                    c->VpiConstType(vpiStringConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                    c->VpiDecompile(txt8);
                    strOv8 = true;
                }
                // An override whose value ORIGINATES in a bit-pattern
                // expression (a concat/replication, however many param hops
                // and struct-member selects away) keeps that BINARY encoding:
                // BIN at the value width with a sized-binary decompile. A
                // value that traces back to a plain integer stays UINT
                // (Surelog: BSOPPS* .PadType(TargetCfg.dio_pad_type[k]) with
                // '{dio_pad_type: {N{B}}} vs ParameterPassedToSubmodule* with
                // TargetCfg = 1).
                std::function<bool(const Expression&, int)> bitPatOrigin =
                    [&](const Expression& e0, int d0) -> bool {
                    if (d0 > 8)
                        return false;
                    auto& e8 = stripImplicitConv(e0);
                    switch (e8.kind) {
                        case ExpressionKind::Replication:
                        case ExpressionKind::Concatenation:
                            return true;
                        case ExpressionKind::MemberAccess:
                            return bitPatOrigin(
                                e8.as<MemberAccessExpression>().value(), d0 + 1);
                        case ExpressionKind::ElementSelect:
                            return bitPatOrigin(
                                e8.as<ElementSelectExpression>().value(), d0 + 1);
                        case ExpressionKind::RangeSelect:
                            return bitPatOrigin(
                                e8.as<RangeSelectExpression>().value(), d0 + 1);
                        case ExpressionKind::StructuredAssignmentPattern: {
                            auto& ap8 =
                                e8.as<StructuredAssignmentPatternExpression>();
                            for (auto& ms8 : ap8.memberSetters)
                                if (ms8.expr && bitPatOrigin(*ms8.expr, d0 + 1))
                                    return true;
                            return ap8.defaultSetter &&
                                   bitPatOrigin(*ap8.defaultSetter, d0 + 1);
                        }
                        case ExpressionKind::SimpleAssignmentPattern: {
                            for (auto* el8 :
                                 e8.as<SimpleAssignmentPatternExpression>()
                                     .elements())
                                if (el8 && bitPatOrigin(*el8, d0 + 1))
                                    return true;
                            return false;
                        }
                        case ExpressionKind::NamedValue: {
                            auto& sy8 = e8.as<NamedValueExpression>().symbol;
                            if (sy8.kind != SymbolKind::Parameter)
                                return false;
                            if (auto* in8 =
                                    sy8.as<ParameterSymbol>().getInitializer())
                                return bitPatOrigin(*in8, d0 + 1);
                            return false;
                        }
                        default:
                            return false;
                    }
                };
                bool enumOv8 = false;
                if (typedParam && !vecAliasOv8 && !strOv8 &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::EnumType &&
                    boundInit && bitPatOrigin(*boundInit, 0) &&
                    iv.getBitWidth() <= 64) {
                    int32_t w6 = (int32_t)iv.getBitWidth();
                    std::string bits6;
                    for (int32_t i6 = w6 - 1; i6 >= 0; i6--)
                        bits6 += (iv[i6] == slang::logic_t(1)) ? '1' : '0';
                    c->VpiValue("BIN:" + bits6);
                    c->VpiConstType(vpiBinaryConst);
                    c->VpiSize(w6);
                    c->VpiDecompile(std::to_string(w6) + "'b" + bits6);
                    enumOv8 = true;
                }
                // A typed VECTOR param override whose value ORIGINATES in a
                // BASED hex/bin/oct literal — directly (#(.Q(8'hcd))) or
                // through parameter refs (#(.P(PP)) with PP = 8'hab) — keeps
                // that base encoding at the param width with the origin's
                // sized decompile (Surelog; rp32_r5p_mouse_soc_simple_top
                // cpu.IFU_RST <- soc IFU_RST = 32'h8000_0000).
                bool srcBaseOv8 = false;
                if (typedParam && !vecAliasOv8 && !strOv8 && !enumOv8 &&
                    boundInit &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    iv.getBitWidth() <= 64) {
                    const Expression* org8 = &stripImplicitConv(*boundInit);
                    for (int h8 = 0;
                         h8 < 8 && org8->kind == ExpressionKind::NamedValue;
                         h8++) {
                        auto& sy9 = org8->as<NamedValueExpression>().symbol;
                        if (sy9.kind != SymbolKind::Parameter)
                            break;
                        auto* in9 = sy9.as<ParameterSymbol>().getInitializer();
                        if (!in9)
                            break;
                        org8 = &stripImplicitConv(*in9);
                    }
                    if (org8->kind == ExpressionKind::IntegerLiteral) {
                        std::string raw9(rawText(org8->sourceRange));
                        auto tick9 = raw9.find('\'');
                        if (tick9 != std::string::npos) {
                            size_t bp9 = tick9 + 1;
                            if (bp9 < raw9.size() &&
                                (raw9[bp9] == 's' || raw9[bp9] == 'S'))
                                bp9++;
                            char base9 = bp9 < raw9.size()
                                             ? (char)tolower(raw9[bp9])
                                             : 'd';
                            if (base9 == 'h' || base9 == 'b' || base9 == 'o') {
                                std::string dg9 =
                                    stripSep(raw9.substr(bp9 + 1));
                                c->VpiValue((base9 == 'h'   ? "HEX:"
                                             : base9 == 'b' ? "BIN:"
                                                            : "OCT:") +
                                            dg9);
                                c->VpiConstType(base9 == 'h' ? vpiHexConst
                                                : base9 == 'b'
                                                    ? vpiBinaryConst
                                                    : vpiOctConst);
                                c->VpiSize((int32_t)iv.getBitWidth());
                                c->VpiDecompile(stripSep(raw9));
                                srcBaseOv8 = true;
                            }
                        }
                    }
                }
                // Typed params fold UINT at the type width; untyped INT at
                // size -1.
                if (vecAliasOv8 || strOv8 || enumOv8 || srcBaseOv8) {
                }
                else if (typedParam && iv.getBitWidth() > 64) {
                    // WIDE values overflow the decimal fold — encode HEX at
                    // the value width with a sized-hex decompile (Surelog).
                    std::string hx8 = iv.toString(LiteralBase::Hex, false);
                    c->VpiValue("HEX:" + hx8);
                    c->VpiConstType(vpiHexConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                    c->VpiDecompile(std::to_string(iv.getBitWidth()) + "'h" +
                                    hx8);
                }
                else if (typedParam || genChild) {
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    // An untyped NO-DEFAULT param has no width source; Surelog's
                    // uniquified override folds it at the 64-bit default width.
                    c->VpiSize((noDefLitMP && !typedParam)
                                   ? 64
                                   : (int32_t)iv.getBitWidth());
                }
                else {
                    c->VpiValue("INT:" + digits);
                    c->VpiConstType(vpiIntConst);
                    c->VpiSize(-1);
                }
                c->VpiParent(pa);
                if (defaultInit)
                    setLoc(c, stripImplicitConv(*defaultInit).sourceRange);
                if (wantTs) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    // Vector-typedef override Rhs ts refs are NAMELESS
                    // (Surelog).
                    if (!vecAliasOv8)
                        rt->VpiFullName(tsPrefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    rhsRt = rt;
                }
                pa->Rhs(c);
                if (topView)
                    elabParamConst[&ps] = c;
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        // Surelog instances the ts at the package only for
                        // TYPED params; untyped ones stay Instance-less.
                        if (typedParam)
                            stampPkgTsInst(its);
                        if (rhsRt)
                            rhsRt->Actual_typespec(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
            // A REAL param OVERRIDE folds to the TRUNCATED integer value
            // (Surelog: real p = 0 with #(1.0) -> UINT:1 size 32) at the
            // default's site, carrying a ts ref to the param's real_typespec.
            else if (cvo.isReal()) {
                int64_t rv = (int64_t)cvo.real();
                std::string digits = std::to_string(rv);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                c->VpiSize(32);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(pa);
                if (defaultInit)
                    setLoc(c, stripImplicitConv(*defaultInit).sourceRange);
                if (wantTs) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    rt->VpiFullName(tsPrefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    rhsRt = rt;
                }
                pa->Rhs(c);
                if (topView)
                    elabParamConst[&ps] = c;
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, rhsRt, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its);
                        if (rhsRt)
                            rhsRt->Actual_typespec(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
        }
        // A NO-DEFAULT param carries no direct Rhs (the bound initializer is
        // the override expression); the ELAB param_assign later SHARES the
        // cont-assign fold constant (noDefOvPa backpatch).
        if (!hasDefault && topView && boundInit)
            noDefOvPa[&member].push_back(pa);
        if (auto init0 = (overridden      ? defaultInit
                          : (!hasDefault) ? nullptr
                                          : ps.getInitializer())) {
            const Expression* init = init0;
            while (init->kind == ExpressionKind::Conversion &&
                   init->as<ConversionExpression>().isImplicit())
                init = &init->as<ConversionExpression>().operand();
            UHDM::any* rhs = nullptr;
            // A localparam whose init is a single-argument SYSTEM function call
            // ($clog2(Depth)) of an OVERRIDDEN param that resolves (through the
            // override chain) to a member-init localparam (N = Info.x) keeps a
            // SYMBOLIC sys_func_call in the elab view, with the arg substituted
            // by the member-init hier_path (Surelog does not fold it).
            std::function<const ParameterSymbol*(const ParameterSymbol*, int)>
                resolveMemberInit = [&](const ParameterSymbol* p,
                                        int depth) -> const ParameterSymbol* {
                if (depth > 8)
                    return nullptr;
                auto* pin = p->getInitializer();
                if (!pin)
                    return nullptr;
                auto& si = stripImplicitConv(*pin);
                if (si.kind == ExpressionKind::MemberAccess) {
                    auto& mb = stripImplicitConv(
                        si.as<MemberAccessExpression>().value());
                    if (mb.kind == ExpressionKind::NamedValue &&
                        mb.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        mb.as<NamedValueExpression>()
                                .symbol.getType()
                                .getCanonicalType()
                                .kind == SymbolKind::PackedStructType)
                        return p;
                    return nullptr;
                }
                const Symbol* rs = nullptr;
                if (si.kind == ExpressionKind::NamedValue)
                    rs = &si.as<NamedValueExpression>().symbol;
                else if (si.kind == ExpressionKind::HierarchicalValue)
                    rs = &si.as<HierarchicalValueExpression>().symbol;
                if (rs && rs->kind == SymbolKind::Parameter)
                    return resolveMemberInit(&rs->as<ParameterSymbol>(),
                                             depth + 1);
                return nullptr;
            };
            const ParameterSymbol* clogMemberInit = nullptr;
            const CallExpression* clogCall = nullptr;
            if (topView && init->kind == ExpressionKind::Call &&
                init->as<CallExpression>().isSystemCall() &&
                init->as<CallExpression>().arguments().size() == 1) {
                auto& a0 = stripImplicitConv(
                    *init->as<CallExpression>().arguments()[0]);
                const Symbol* rs = nullptr;
                if (a0.kind == ExpressionKind::NamedValue)
                    rs = &a0.as<NamedValueExpression>().symbol;
                else if (a0.kind == ExpressionKind::HierarchicalValue)
                    rs = &a0.as<HierarchicalValueExpression>().symbol;
                if (rs && rs->kind == SymbolKind::Parameter)
                    if ((clogMemberInit = resolveMemberInit(
                             &rs->as<ParameterSymbol>(), 0)))
                        clogCall = &init->as<CallExpression>();
            }
            if (topView) {
                if (init->kind == ExpressionKind::IntegerLiteral) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    // A REAL param initialized with an INTEGER literal keeps
                    // the literal's natural width (localparam real p3 = 123 ->
                    // UINT:123 size 32), NOT the real's 64-bit width (Surelog).
                    if (rhs) {
                        if (ps.getType().getCanonicalType().isFloating())
                            ((UHDM::constant*)rhs)
                                ->VpiSize(
                                    (int32_t)init->type->getBitWidth());
                        else
                            ((UHDM::constant*)rhs)
                                ->VpiSize(
                                    (int32_t)ps.getType().getBitWidth());
                    }
                }
                // Symbolic sys_func_call ($clog2(Info.x)) of a member-init
                // param: re-emit the call with the argument substituted by the
                // member-init hier_path (Surelog keeps it unfolded).
                else if (clogMemberInit && clogCall) {
                    auto* sc = s.MakeSys_func_call();
                    sc->VpiName(std::string(clogCall->getSubroutineName()));
                    sc->VpiParent(pa);
                    setLoc(sc, init->sourceRange);
                    // The substituted member-init path (Info.x) uses the
                    // param-init lvalue-style base span + bare leaf (Surelog).
                    inParamInit = true;
                    auto* he = (UHDM::expr*)emitExpr(
                        *clogMemberInit->getInitializer(), sc, prefix, netMap);
                    inParamInit = false;
                    if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                        auto* hp = (UHDM::hier_path*)he;
                        setLoc(hp, clogCall->arguments()[0]->sourceRange);
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(prefix.empty()
                                            ? std::string(hp->VpiName())
                                            : prefix + "." +
                                                  std::string(hp->VpiName()));
                        rt->VpiParent(hp);
                        auto* its = s.MakeInt_typespec();
                        if (auto dt = clogMemberInit->getDeclaredType())
                            if (auto* tsyn = dt->getTypeSyntax())
                                setLoc(its, tsyn->sourceRange());
                        if (clogMemberInit->getType().isSigned())
                            its->VpiSigned(true);
                        rt->Actual_typespec(its);
                        hp->Typespec(rt);
                    }
                    if (he) {
                        auto* args = s.MakeAnyVec();
                        args->push_back(he);
                        sc->Tf_call_args(args);
                    }
                    rhs = sc;
                }
                // A TYPED STRING param whose init is NON-literal (a concat)
                // folds to a STRING constant in the ELAB view (the DEF view
                // keeps the operation); a plain string literal re-emits
                // (StringAssignment).
                else if (ps.getType().getCanonicalType().isString() &&
                         stripImplicitConv(*init).kind !=
                             ExpressionKind::StringLiteral &&
                         !containsUserCall(*init)) {
                    ASTContext sctx(comp.getRoot(), LookupLocation::max);
                    ConstantValue scv = sctx.tryEval(*init0);
                    if (scv && scv.isString()) {
                        std::string sv = scv.str();
                        auto* c = s.MakeConstant();
                        c->VpiSize((int32_t)(sv.size() * 8));
                        c->VpiValue("STRING:" + sv);
                        c->VpiConstType(vpiStringConst);
                        c->VpiDecompile(sv);
                        c->VpiParent(pa);
                        setLoc(c, init->sourceRange);
                        if (wantTs) {
                            auto* rt = s.MakeRef_typespec();
                            std::string tsPrefix = prefix;
                            if (tsPrefix.size() >= 2 &&
                                tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                                tsPrefix.resize(tsPrefix.size() - 2);
                            rt->VpiFullName(tsPrefix);
                            rt->VpiParent(c);
                            c->Typespec(rt);
                            rhsRt = rt;
                        }
                        moduleStringParamConst[&member] = c;
                        rhs = c;
                    }
                }
                // ELAB-pkg CONST-FUNCTION-CALL init (Z = g(4)) folds to the
                // evaluated value: size 32, INT/UINT by the value's sign,
                // whole-init span, ts ref patched to the param ts (Surelog).
                else if (pkgElabComputed && containsUserCall(*init) &&
                         ps.getValue().isInteger() &&
                         !ps.getValue().integer().hasUnknown()) {
                    auto& iv2 = ps.getValue().integer();
                    std::string digits =
                        iv2.toString(LiteralBase::Decimal, false);
                    bool sgn2 = iv2.isSigned();
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(digits);
                    c->VpiSize(32);
                    c->VpiValue((sgn2 ? "INT:" : "UINT:") + digits);
                    c->VpiConstType(sgn2 ? vpiIntConst : vpiUIntConst);
                    c->VpiParent(pa);
                    setLoc(c, init->sourceRange);
                    if (wantTs) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent(c);
                        c->Typespec(rt);
                        rhsRt = rt;
                    }
                    rhs = c;
                }
                // A STRING-literal init on an (implicitly) INTEGRAL param
                // re-emits the string constant in the elab view, decompiled
                // WITHOUT quotes (const_func e1) — not the UINT fold.
                else if (stripImplicitConv(*init).kind ==
                             ExpressionKind::StringLiteral &&
                         !ps.getType().getCanonicalType().isString()) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    if (rhs && rhs->UhdmType() == UHDM::uhdmconstant) {
                        auto* rc = (UHDM::constant*)rhs;
                        std::string_view v0 = rc->VpiValue();
                        if (v0.rfind("STRING:", 0) == 0)
                            rc->VpiDecompile(std::string(v0.substr(7)));
                    }
                }
                // A TYPED string param never folds (the elab Rhs re-emits the
                // string constant, decompiled without quotes). Pkg CONCAT
                // inits keep the operation in both views.
                else if (!ps.getType().getCanonicalType().isString() &&
                         !(inPackage && [&] {
                             // A pkg param whose init is a concatenation — or
                             // an explicit size/type cast wrapping one, e.g.
                             // 3'({3'({3'h1})}) — keeps the operation in the
                             // elab view (Surelog leaves the cast/concat tree
                             // unfolded rather than reducing it to a constant).
                             const Expression* e = &stripImplicitConv(*init);
                             while (e->kind == ExpressionKind::Conversion &&
                                    !e->as<ConversionExpression>().isImplicit())
                                 e = &stripImplicitConv(
                                     e->as<ConversionExpression>().operand());
                             return e->kind == ExpressionKind::Concatenation;
                         }()) &&
                         // A materialized IMPORTED param's concat init keeps
                         // the operation in the elab view too (Surelog).
                         !(isImported && stripImplicitConv(*init).kind ==
                                             ExpressionKind::Concatenation) &&
                         // A NESTED assignment pattern ('{'{1,0,0,0}}) keeps
                         // its operation in the elab view (not folded).
                         !([&] {
                             auto& si = stripImplicitConv(*init);
                             if (si.kind != ExpressionKind::SimpleAssignmentPattern)
                                 return false;
                             for (auto* el : si.as<SimpleAssignmentPatternExpression>()
                                                 .elements())
                                 if (stripImplicitConv(*el).kind ==
                                     ExpressionKind::SimpleAssignmentPattern)
                                     return true;
                             return false;
                         }()) &&
                         // A MODULE struct-typed param never folds its RHS
                         // (patterns keep the op forms; casts keep the cast
                         // op). A PACKAGE struct param keeps only PATTERN ops
                         // (other pkg inits still fold — Surelog).
                         !([&] {
                             auto ck9 = ps.getType().getCanonicalType().kind;
                             if (ck9 != SymbolKind::PackedStructType &&
                                 ck9 != SymbolKind::PackedUnionType)
                                 return false;
                             if (!inPackage)
                                 return true;
                             auto k = stripImplicitConv(*init).kind;
                             return k == ExpressionKind::StructuredAssignmentPattern ||
                                    k == ExpressionKind::SimpleAssignmentPattern;
                         }()) &&
                         // An init reading a struct-param MEMBER keeps the
                         // hier_path (Info.x) in BOTH views (Surelog).
                         !([&] {
                             auto& si = stripImplicitConv(*init);
                             if (si.kind != ExpressionKind::MemberAccess)
                                 return false;
                             auto& base = stripImplicitConv(
                                 si.as<MemberAccessExpression>().value());
                             return base.kind == ExpressionKind::NamedValue &&
                                    base.as<NamedValueExpression>().symbol.kind ==
                                        SymbolKind::Parameter &&
                                    base.as<NamedValueExpression>()
                                            .symbol.getType()
                                            .getCanonicalType()
                                            .kind == SymbolKind::PackedStructType;
                         }()) &&
                         !containsUserCall(*init) &&
                         (rhs = tryFoldConst(*init,
                                             typedParam ? init0 : nullptr))) {
                    bool partSelectFold = false;
                    ((UHDM::constant*)rhs)->VpiParent(pa);
                    // A materialized IMPORTED param whose default folds from a
                    // NON-literal operation (cast/concat) yields a BARE folded
                    // constant in the module view: no loc, no typespec ref
                    // (Surelog). A simple-literal import (int W = 4) keeps
                    // them, but that init takes the IntegerLiteral branch
                    // above, not this fold path.
                    bool importedFold = isImported && topView && !inPackage;
                    // Typed params fold at the type width; a size-cast value
                    // (32'(ONE)) at the cast width; other untyped values at 64.
                    auto& scv = stripImplicitConv(*init);
                    bool sizeCastVal =
                        scv.kind == ExpressionKind::Conversion &&
                        !scv.as<ConversionExpression>().isImplicit() && scv.type &&
                        scv.syntax &&
                        scv.syntax->kind == syntax::SyntaxKind::CastExpression &&
                        !isTypeSyntaxKind(
                            scv.syntax->as<syntax::CastExpressionSyntax>().left->kind);
                    // A DEF-view materialized UNTYPED integral import folds at
                    // the param's TYPE width (Surelog: 32 for a plain int
                    // import), matching its elab view — not the 64-bit default.
                    bool defUntypedImport =
                        !topView && !inPackage && isImported && !typedParam &&
                        ps.getType().getCanonicalType().isIntegral() &&
                        ps.getDeclaredType() &&
                        ps.getDeclaredType()->getTypeSyntax() &&
                        ps.getDeclaredType()->getTypeSyntax()->kind ==
                            syntax::SyntaxKind::ImplicitType;
                    // A RANGED-UNTYPED localparam ([HI:LO] A_CONST = A_VAL)
                    // whose default FOLDS in the elab view carries its value at
                    // the (per-instance) RANGE width, with a ts ref to a fresh
                    // int_typespec located at the range span — exactly like the
                    // OVERRIDDEN ranged case (A_VAL above). The DEF view keeps
                    // the unfolded ref_obj, so this only fires under topView.
                    bool rangedFold =
                        topView && !inPackage && isRangedUntypedParam(ps);
                    // An UNTYPED param whose default is a CONCAT
                    // ({(A) > (B) ? (A) : (B)}, the classic `max()` macro)
                    // folds at the concat's OWN self-determined width — not
                    // the 64-bit untyped default — and, unlike a concat fold
                    // in a cont-assign/statement (bare, no decompile), the
                    // param_assign Rhs form carries a based-binary decompile
                    // (Surelog).
                    bool concatFold = !typedParam && !defUntypedImport &&
                                      !rangedFold && !sizeCastVal &&
                                      scv.kind == ExpressionKind::Concatenation;
                    if (!concatFold)
                        ((UHDM::constant*)rhs)
                            ->VpiSize(typedParam || defUntypedImport || rangedFold
                                          ? (int32_t)ps.getType().getBitWidth()
                                      : sizeCastVal ? (int32_t)scv.type->getBitWidth()
                                                    : 64);
                    else {
                        auto* cc9 = (UHDM::constant*)rhs;
                        std::string_view cv9 = cc9->VpiValue();
                        if (cv9.rfind("BIN:", 0) == 0 && !cc9->VpiDecompile().size())
                            cc9->VpiDecompile(std::to_string(cc9->VpiSize()) + "'b" +
                                              std::string(cv9.substr(4)));
                    }
                    // ELAB-pkg computed BinaryOp init folds at the LEFT
                    // operand's span, sized 32, with a ts ref patched to the
                    // param's int ts (Surelog).
                    if (pkgElabComputed && !typedParam && wantTs) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent((UHDM::constant*)rhs);
                        ((UHDM::constant*)rhs)->Typespec(rt);
                        rhsRt = rt;
                    }
                    // A PARENTHESIZED default (localparam W = (X-1)) folds to a
                    // constant spanning the parens, not the inner expression.
                    SourceRange rhsLoc = init->sourceRange;
                    if (!overridden)
                        if (auto* dsyn = paramDefaultSyn(ps))
                            if (dsyn->kind ==
                                syntax::SyntaxKind::ParenthesizedExpression)
                                rhsLoc = dsyn->sourceRange();
                    if (!importedFold)
                        setLoc((UHDM::constant*)rhs, rhsLoc);
                    // ELAB-pkg computed BinaryOp init folds at the LEFT
                    // operand's span, sized 32 (Surelog).
                    {
                        const Expression* se9 = &scv;
                        while (se9->kind == ExpressionKind::Conversion)
                            se9 = &se9->as<ConversionExpression>().operand();
                        if (pkgElabComputed &&
                            se9->kind == ExpressionKind::BinaryOp) {
                            setLoc((UHDM::constant*)rhs,
                                   se9->as<BinaryExpression>().left().sourceRange);
                            if (!typedParam)
                                ((UHDM::constant*)rhs)->VpiSize(32);
                        }
                        // A QUALIFIED pkg-param ref init folds at the
                        // QUALIFIER span (pkg:: incl. colons) — Surelog.
                        else if (pkgElabComputed &&
                                 se9->kind == ExpressionKind::NamedValue) {
                            std::string rq9(rawText(se9->sourceRange));
                            auto qp9 = rq9.rfind("::");
                            if (qp9 != std::string::npos) {
                                auto st9 = se9->sourceRange.start();
                                setLoc((UHDM::constant*)rhs,
                                       SourceRange(st9, st9 + qp9 + 2));
                            }
                        }
                    }
                    // A SUBTRACT init (W - 19) folds signed (INT).
                    if (scv.kind == ExpressionKind::BinaryOp &&
                        scv.as<BinaryExpression>().op == BinaryOperator::Subtract) {
                        auto* rc1 = (UHDM::constant*)rhs;
                        std::string_view v1 = rc1->VpiValue();
                        if (v1.rfind("UINT:", 0) == 0) {
                            rc1->VpiValue("INT:" + std::string(v1.substr(5)));
                            rc1->VpiConstType(vpiIntConst);
                        }
                    }
                    // An assignment-pattern default ('{0,1}) folds to a
                    // based-decimal (2'd1) constant with NO typespec ref.
                    auto& sinit = stripImplicitConv(*init);
                    bool isPattern =
                        sinit.kind == ExpressionKind::SimpleAssignmentPattern ||
                        sinit.kind == ExpressionKind::StructuredAssignmentPattern ||
                        sinit.kind == ExpressionKind::ReplicatedAssignmentPattern;
                    if (isPattern && typedParam) {
                        auto* c = (UHDM::constant*)rhs;
                        std::string v(c->VpiValue());
                        std::string digits =
                            v.find(':') != std::string::npos ? v.substr(v.find(':') + 1) : v;
                        c->VpiDecompile(std::to_string((int32_t)ps.getType().getBitWidth()) +
                                        "'d" + digits);
                        c->VpiConstType(0);
                    }
                    // A typed-param unbased-unsized default folds at the type
                    // width (Surelog quirk): '0 -> BIN:0/<width>'b0, '1 ->
                    // UINT:<all-ones>/decimal, 'x/'z -> BIN:X/Z.
                    if (sinit.kind ==
                            ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                        typedParam) {
                        logic_t bit = sinit.as<UnbasedUnsizedIntegerLiteral>()
                                          .getLiteralValue();
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = (int32_t)ps.getType().getBitWidth();
                        if (bit.isUnknown()) {
                            std::string d = bit.value == logic_t::X_VALUE ? "X" : "Z";
                            c->VpiValue("BIN:" + d);
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(std::to_string(w) + "'b" + d);
                        }
                        else if (bit.value == 0) {
                            c->VpiValue("BIN:0");
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(std::to_string(w) + "'b0");
                        }
                        else {
                            slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                            ones = ~ones;
                            std::string digits = ones.toString(LiteralBase::Decimal, false);
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiDecompile(digits);
                        }
                        // The DEGENERATE fills ('0/'x/'z, ConstType BIN) are the
                        // SAME constant object Surelog shares into the reading
                        // cont-assign (bare stub, parent = that CA). '1 (UINT)
                        // instead gets a FRESH fold at the read, so it is not
                        // recorded here.
                        if (topView && (bit.isUnknown() || bit.value == 0))
                            unbasedSharedPaConst[&ps] = c;
                    }
                    // A typed-param PART-SELECT init (WidthRatio[5:0]) folds
                    // to BINARY at the type width (Surelog quirk) and is
                    // SHARED into a reading cont-assign (o = FullDepth).
                    if (sinit.kind == ExpressionKind::RangeSelect && typedParam &&
                        topView) {
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = (int32_t)ps.getType().getBitWidth();
                        std::string v(c->VpiValue());
                        std::string digits = v.find(':') != std::string::npos
                                                 ? v.substr(v.find(':') + 1)
                                                 : v;
                        slang::SVInt sv2 =
                            slang::SVInt::fromString(std::string_view(digits));
                        slang::SVInt wv(
                            (slang::bitwidth_t)(w > 0 ? w : 1), 0, false);
                        wv = sv2.resize((slang::bitwidth_t)(w > 0 ? w : 1));
                        std::string bits;
                        for (int32_t bi = w - 1; bi >= 0; bi--)
                            bits += (wv[bi] == slang::logic_t(1)) ? '1' : '0';
                        c->VpiValue("BIN:" + bits);
                        c->VpiConstType(vpiBinaryConst);
                        c->VpiDecompile(std::to_string(w) + "'b" + bits);
                        moduleParamFoldConst[&member] = c;
                        // Its own FRESH unlocated logic_typespec (range =
                        // the param's fixed range, BARE UINT bounds) — NOT
                        // the param's bit_typespec — created in the write-
                        // phase tail (deferred).
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(prefix);
                        rt->VpiParent(c);
                        c->Typespec(rt);
                        auto fr = ps.getType().getCanonicalType().getFixedRange();
                        pendingPartSelFoldTs.push_back({rt, fr.left, fr.right});
                        partSelectFold = true;
                    }
                    // Typed-param (non-pattern) folds carry a ts ref to the
                    // param; a RANGED-UNTYPED elab fold carries the SAME ts ref
                    // shape (fullname = instance prefix, actual = range
                    // int_typespec) so its folded value is width-typed.
                    if ((typedParam || rangedFold) && wantTs && !isPattern &&
                        !partSelectFold && !importedFold) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent((UHDM::constant*)rhs);
                        ((UHDM::constant*)rhs)->Typespec(rt);
                        rhsRt = rt;
                    }
                }
            }
            if (!rhs) {
                // A DEF-view NESTED pattern leaves leaf constants UNPARENTED
                // (only the nested pattern operations self-parent), so it does
                // NOT force the const parent.
                bool nestedPat = false;
                {
                    auto& si = stripImplicitConv(*init);
                    if (si.kind == ExpressionKind::SimpleAssignmentPattern)
                        for (auto* el : si.as<SimpleAssignmentPatternExpression>()
                                            .elements())
                            if (stripImplicitConv(*el).kind ==
                                ExpressionKind::SimpleAssignmentPattern)
                                nestedPat = true;
                }
                // Struct-typed param pattern RHS (Surelog 3-object model):
                // ELAB view: a FLAT op-75 (per-member folded constants) whose
                // ts ref (rhsRt) binds the elab param clone in
                // patchParamTypespecs. DEF view: emitExpr's tagged_pattern op
                // plus a ts ref to a FRESH def clone (deferred to
                // drainDefParamTs, scoped work@<mod>.<ty>.<member>).
                bool structPat = false;
                // WIDTH RULE: a PACKAGE struct-pattern param whose struct bit
                // width EXCEEDS 64 keeps the tagged_pattern tree in the ELAB
                // view too (Surelog's package def and elab views are byte-
                // identical: kmac_pkg::A 96b ImportedDoubleCastedParameter,
                // pinmux_pkg::DefaultTargetCfg ~72b BSOPPS). A <=64b package
                // struct param still flat-folds to the packed op75 constant
                // (PatternAssignmentOfStructParam 4b,
                // StructParameterInitializedWithPatternAndReferenced 4b). Our
                // wide fold otherwise mints a BOGUS UINT:0 constant (int64
                // overflow of a >64b decimal) — the gate removes it.
                bool structWidePkg = false;
                {
                    auto& pctS = ps.getType().getCanonicalType();
                    auto k0 = structOvPat ? structOvPat->kind
                                          : stripImplicitConv(*init).kind;
                    structPat = pctS.kind == SymbolKind::PackedStructType &&
                                (k0 == ExpressionKind::StructuredAssignmentPattern ||
                                 k0 == ExpressionKind::SimpleAssignmentPattern);
                    // The rule follows the PACKAGE ORIGIN of the struct param:
                    // it applies in its home package (inPackage) AND when the
                    // param is MATERIALIZED into an importing module/package
                    // (isImported) — kmac_pkg::A viewed in work@top keeps the
                    // tagged tree too. A module-LOCAL struct param still flat-
                    // folds.
                    if (structPat && (inPackage || isImported) &&
                        ps.getType().getBitWidth() > 64)
                        structWidePkg = true;
                    // SYMBOLIC-DIM RULE: a struct whose member carries a
                    // PARAMETER-DEPENDENT packed dimension
                    // (pad_type_e [NDioPads-1:0] m) never flattens in either
                    // HOME-PACKAGE view — Surelog leaves that pattern op
                    // untyped (no struct ts ref) and therefore never runs its
                    // flatten pass on it, so the elaborated package view is
                    // byte-identical to the def view (BSOPPS*, TSPWRIS). A
                    // fixed-dim member struct (logic [3:0] addr) still folds
                    // flat in the elab package view. The importing MODULE
                    // views are unaffected — they flatten either way.
                    if (structPat && inPackage &&
                        structHasSymbolicMemberDim(pctS))
                        structWidePkg = true;
                }
                // The DEF view of an INTERFACE struct param keeps the TAGGED
                // form (emitExpr tagged_pattern op: constant size 64 + a ts ref
                // to the member's string_typespec) — same as a module localparam
                // pattern default; it does NOT fold to the flat op75. Only the
                // ELAB (topView) view flattens. (Previously this DEF case took
                // the flat op75 branch below, emitting a bare member constant +
                // an op-level struct ts ref — which mismatched Surelog. Falling
                // through to emitExpr with paramInitDef restores the tags.)
                // NOTE follow-on (iface_cfg_param_def_pass, still DIFF): the ELAB
                // override RHS (work@top.bus.CFG) should re-emit as an op75 at
                // the override-connection site (constant at the value source),
                // the reader's `32'(s.CFG.DAT)` must stay a hier_path cast op
                // (Surelog does NOT fold interface-port struct-param reads), and
                // the modport port-view needs its own override param_assign.
                // ...EXCEPT when the interface is instantiated as an ARRAY
                // (bus_if #(C) arr[1:0] ()). Surelog's array-instance path
                // re-reduces the DEFINITION's parameter defaults, so the def
                // view flat-folds too — with a BARE op ts ref (no parent, no
                // fullname) instead of the elab clone's scoped one.
                // (iface_array_elem_cfg_param.)
                bool ifaceArrayDefFold = false;
                if (structPat && !topView && !structWidePkg) {
                    const InstanceBodySymbol* ob0 = nullptr;
                    for (auto* sc0 = ps.getParentScope(); sc0;) {
                        auto& ss0 = sc0->asSymbol();
                        if (ss0.kind == SymbolKind::InstanceBody) {
                            ob0 = &ss0.as<InstanceBodySymbol>();
                            break;
                        }
                        sc0 = ss0.getParentScope();
                    }
                    if (ob0 && ob0->getDefinition().definitionKind ==
                                   DefinitionKind::Interface &&
                        defInstantiatedAsArray(ob0->getDefinition()))
                        ifaceArrayDefFold = true;
                }
                if (structPat && (topView || ifaceArrayDefFold) &&
                    !structWidePkg) {
                    auto& pctS = ps.getType().getCanonicalType();
                    // An OVERRIDE by a param REFERENCE substitutes the
                    // REFERENCED param's pattern, anchored at the override site.
                    auto& sinitK =
                        structOvPat ? *structOvPat : stripImplicitConv(*init);
                    auto* op2 = s.MakeOperation();
                    op2->VpiOpType(75);
                    op2->VpiParent(pa);
                    setLoc(op2, structOvPat ? structOvLoc : init->sourceRange);
                    auto* rt = s.MakeRef_typespec();
                    if (!ifaceArrayDefFold)
                        rt->VpiParent(op2);
                    op2->Typespec(rt);
                    rhsRt = rt; // -> elab param clone (patchParamTypespecs)
                    auto* opnds = s.MakeAnyVec();
                    ASTContext ectx(comp.getRoot(), LookupLocation::max);
                    for (auto& fld :
                         pctS.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                        const Expression* se = nullptr;
                        if (sinitK.kind ==
                            ExpressionKind::StructuredAssignmentPattern) {
                            auto& ap =
                                sinitK.as<StructuredAssignmentPatternExpression>();
                            for (auto& ms : ap.memberSetters)
                                if (ms.member == &fld) {
                                    se = ms.expr;
                                    break;
                                }
                            if (!se)
                                se = ap.defaultSetter;
                        }
                        if (!se)
                            continue;
                        // A NESTED struct-pattern member is KEPT as a nested
                        // op75 in the ELAB view — Surelog does NOT fold the
                        // inner pattern. Recurse via the reemitting path, which
                        // builds the op with a BARE ts ref to the member's
                        // typedef struct typespec and leaf constants at their
                        // source encoding (based literals keep width; an
                        // unbased int leaf keeps its 64-bit default size).
                        {
                            auto& seN = stripImplicitConv(*se);
                            const Type& fct = fld.getType().getCanonicalType();
                            if ((seN.kind ==
                                     ExpressionKind::StructuredAssignmentPattern ||
                                 seN.kind ==
                                     ExpressionKind::SimpleAssignmentPattern) &&
                                fct.kind == SymbolKind::PackedStructType) {
                                bool savedRe = reemitting;
                                reemitting = true;
                                auto* ne = emitExpr(seN, op2, prefix, netMap);
                                reemitting = savedRe;
                                if (ne) {
                                    ((UHDM::any*)ne)->VpiParent(op2);
                                    // An OVERRIDE-SUBSTITUTED pattern's nested
                                    // member op is SIZED at the member width
                                    // and its struct ts ref carries the
                                    // instance-scoped fullname (Surelog,
                                    // iface_wholestruct_param). A plain DEFAULT
                                    // fold leaves both bare (iface_cfg_mem).
                                    if (structOvPat &&
                                        ne->UhdmType() == UHDM::uhdmoperation) {
                                        auto* nop = (UHDM::operation*)ne;
                                        nop->VpiSize((int32_t)fld.getType()
                                                         .getBitWidth());
                                        if (auto* nrt = nop->Typespec()) {
                                            std::string tsP = prefix;
                                            if (tsP.size() >= 2 &&
                                                tsP.compare(tsP.size() - 2, 2,
                                                            "::") == 0)
                                                tsP.resize(tsP.size() - 2);
                                            nrt->VpiFullName(tsP);
                                            nrt->VpiParent(nop);
                                        }
                                    }
                                    opnds->push_back(ne);
                                }
                                continue;
                            }
                        }
                        // A LITERAL setter keeps its source encoding (1'b1 ->
                        // BIN, parented at the op via emitExpr); non-literal
                        // setters fold to UINT at the member width.
                        if (stripImplicitConv(*se).kind ==
                                ExpressionKind::IntegerLiteral) {
                            if (auto* e2 = emitExpr(*se, op2, prefix, netMap)) {
                                ((UHDM::expr*)e2)->VpiParent(op2);
                                // An UNSIZED decimal setter ('{DAT: 24}) is
                                // sized at the MEMBER width in the elab fold —
                                // like the non-literal path below — not left at
                                // slang's 64-bit int default. A SIZED/BASED
                                // literal (4'h5, 1'b1) already carries its own
                                // width and keeps it (its raw text has a base
                                // tick).
                                if (e2->UhdmType() == UHDM::uhdmconstant &&
                                    ((UHDM::constant*)e2)->VpiSize() == 64 &&
                                    rawText(stripImplicitConv(*se).sourceRange)
                                            .find('\'') == std::string::npos)
                                    ((UHDM::constant*)e2)
                                        ->VpiSize((int32_t)fld.getType()
                                                      .getBitWidth());
                                opnds->push_back(e2);
                            }
                            continue;
                        }
                        ConstantValue cvm = ectx.tryEval(*se);
                        if (cvm && cvm.isInteger() && !cvm.integer().hasUnknown()) {
                            auto* c2 = s.MakeConstant();
                            slang::SVInt uvm = cvm.integer();
                            uvm.setSigned(false);
                            // A REPLICATION setter ({NDioPads{B}}) folds to the
                            // repeated bit pattern in the elab view too — the
                            // SAME BIN constant the def view builds (decompile
                            // = the bits), plus an INSTANCE-scoped ts ref to a
                            // bare int_typespec (Surelog, BSOPPS*InGenFor).
                            if (stripImplicitConv(*se).kind ==
                                ExpressionKind::Replication) {
                                int32_t w7 =
                                    (int32_t)fld.getType().getBitWidth();
                                std::string bits7;
                                for (int32_t i7 = w7 - 1; i7 >= 0; i7--)
                                    bits7 += (uvm[i7] == slang::logic_t(1))
                                                 ? '1'
                                                 : '0';
                                c2->VpiDecompile(bits7);
                                c2->VpiSize(w7);
                                c2->VpiValue("BIN:" + bits7);
                                c2->VpiConstType(vpiBinaryConst);
                                std::string tsP7 = prefix;
                                if (tsP7.size() >= 2 &&
                                    tsP7.compare(tsP7.size() - 2, 2, "::") == 0)
                                    tsP7.resize(tsP7.size() - 2);
                                auto* rrt7 = s.MakeRef_typespec();
                                rrt7->VpiParent(c2);
                                rrt7->VpiFullName(tsP7);
                                rrt7->Actual_typespec(s.MakeInt_typespec());
                                c2->Typespec(rrt7);
                            }
                            // A CONCAT setter re-encodes BINARY at the member
                            // width with a BARE ts ref (Surelog).
                            else if (stripImplicitConv(*se).kind ==
                                     ExpressionKind::Concatenation) {
                                int32_t w8 =
                                    (int32_t)fld.getType().getBitWidth();
                                std::string bits8;
                                for (int32_t i8 = w8 - 1; i8 >= 0; i8--)
                                    bits8 += (uvm[i8] == slang::logic_t(1))
                                                 ? '1'
                                                 : '0';
                                c2->VpiSize(w8);
                                c2->VpiValue("BIN:" + bits8);
                                c2->VpiConstType(vpiBinaryConst);
                            }
                            else {
                                std::string dg = uvm.toString(
                                    LiteralBase::Decimal, false);
                                c2->VpiDecompile(dg);
                                c2->VpiSize(
                                    (int32_t)fld.getType().getBitWidth());
                                c2->VpiValue("UINT:" + dg);
                                c2->VpiConstType(vpiUIntConst);
                            }
                            c2->VpiParent(op2);
                            setLoc(c2, se->sourceRange);
                            opnds->push_back(c2);
                        }
                    }
                    op2->Operands(opnds);
                    rhs = op2;
                }
                // A >64b struct param MATERIALIZED into an importing MODULE
                // keeps the TAGGED tree in the module DEF view (and in both
                // home-package views), but its ELAB view STRIPS the
                // tagged_pattern wrappers: the op75's direct operands are the
                // member VALUE expressions themselves, re-emitted as-is (a
                // size cast stays an op67 over the source constant) and sized
                // to the member width (ImportedDoubleCastedParameter
                // kmac_pkg::A). Only member ops are re-sized; a plain
                // constant member keeps its own literal size.
                if (!rhs && structPat && topView && structWidePkg &&
                    isImported && !inPackage) {
                    auto& pctW = ps.getType().getCanonicalType();
                    auto& sinitW = stripImplicitConv(*init);
                    if (sinitW.kind ==
                        ExpressionKind::StructuredAssignmentPattern) {
                        auto& apW =
                            sinitW.as<StructuredAssignmentPatternExpression>();
                        auto* opW = s.MakeOperation();
                        opW->VpiOpType(75);
                        opW->VpiParent(pa);
                        setLoc(opW, init->sourceRange);
                        auto* opndW = s.MakeAnyVec();
                        bool okW = true;
                        for (auto& fld : pctW.as<PackedStructType>()
                                             .membersOfType<FieldSymbol>()) {
                            const Expression* se = nullptr;
                            for (auto& ms : apW.memberSetters)
                                if (ms.member == &fld) {
                                    se = ms.expr;
                                    break;
                                }
                            if (!se)
                                se = apW.defaultSetter;
                            if (!se) {
                                okW = false;
                                break;
                            }
                            // A REPLICATION member value keeps the SAME folded
                            // BIN constant the def view built (Surelog reuses
                            // the resolved value; only casts stay unfolded) —
                            // with an instance-scoped ts ref to a bare
                            // int_typespec. BSOPPS (72b pinmux_pkg).
                            if (stripImplicitConv(*se).kind ==
                                    ExpressionKind::Replication &&
                                se->type) {
                                ASTContext rctxW(comp.getRoot(),
                                                 LookupLocation::max);
                                if (auto rcvW = rctxW.tryEval(*se);
                                    rcvW && rcvW.isInteger() &&
                                    !rcvW.integer().hasUnknown()) {
                                    auto rivW = rcvW.integer();
                                    int32_t rwW =
                                        (int32_t)se->type->getBitWidth();
                                    std::string rbW;
                                    for (int32_t bW = rwW - 1; bW >= 0; bW--)
                                        rbW += (rivW[bW] == slang::logic_t(1))
                                                   ? '1'
                                                   : '0';
                                    auto* rcW = s.MakeConstant();
                                    rcW->VpiDecompile(rbW);
                                    rcW->VpiSize(rwW);
                                    rcW->VpiValue("BIN:" + rbW);
                                    rcW->VpiConstType(vpiBinaryConst);
                                    rcW->VpiParent(opW);
                                    setLoc(rcW, se->sourceRange);
                                    std::string tsPW = prefix;
                                    if (tsPW.size() >= 2 &&
                                        tsPW.compare(tsPW.size() - 2, 2,
                                                     "::") == 0)
                                        tsPW.resize(tsPW.size() - 2);
                                    auto* rrtW = s.MakeRef_typespec();
                                    rrtW->VpiParent(rcW);
                                    rrtW->VpiFullName(tsPW);
                                    rrtW->Actual_typespec(s.MakeInt_typespec());
                                    rcW->Typespec(rrtW);
                                    opndW->push_back(rcW);
                                    continue;
                                }
                            }
                            // An UNBASED-UNSIZED member value ('0) is the one
                            // payload Surelog RESOLVES in the elab view: a
                            // decimal UINT constant at the member width (the
                            // def view keeps the '0 form). Casts and folded
                            // bit patterns are re-emitted as they stand.
                            // TypedefStructParamWithRangeInSubmodule.
                            if (stripImplicitConv(*se).kind ==
                                ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                                ASTContext uctx(comp.getRoot(),
                                                LookupLocation::max);
                                if (auto ucv = uctx.tryEval(*se);
                                    ucv && ucv.isInteger() &&
                                    !ucv.integer().hasUnknown()) {
                                    auto uiv = ucv.integer();
                                    uiv.setSigned(false);
                                    std::string ud = uiv.toString(
                                        LiteralBase::Decimal, false);
                                    auto* uc = s.MakeConstant();
                                    uc->VpiDecompile(ud);
                                    uc->VpiSize(
                                        (int32_t)fld.getType().getBitWidth());
                                    uc->VpiValue("UINT:" + ud);
                                    uc->VpiConstType(vpiUIntConst);
                                    uc->VpiParent(opW);
                                    setLoc(uc, se->sourceRange);
                                    opndW->push_back(uc);
                                    continue;
                                }
                            }
                            bool savedRe = reemitting;
                            reemitting = true;
                            // The re-emitted size-cast typespecs belong to the
                            // HOME package (vpiInstance), like every other
                            // module-view copy of an imported param's init.
                            auto* savedImpW = importedInitPkgInst;
                            if (ps.getParentScope())
                                if (auto pitW = pkgDefMap.find(
                                        &ps.getParentScope()->asSymbol());
                                    pitW != pkgDefMap.end())
                                    importedInitPkgInst =
                                        (UHDM::instance*)pitW->second;
                            auto* me = emitExpr(*se, opW, prefix, netMap);
                            importedInitPkgInst = savedImpW;
                            reemitting = savedRe;
                            if (!me) {
                                okW = false;
                                break;
                            }
                            me->VpiParent(opW);
                            if (me->UhdmType() == UHDM::uhdmoperation)
                                ((UHDM::operation*)me)->VpiSize(
                                    (int32_t)fld.getType().getBitWidth());
                            opndW->push_back(me);
                        }
                        if (okW && !opndW->empty()) {
                            opW->Operands(opndW);
                            rhs = opW;
                        }
                    }
                }
                // ELAB (topView) view of a materialized UNPACKED-ARRAY-of-packed-
                // struct param: Surelog FOLDS the '{'{...}} pattern. The outer op
                // carries the param's array_typespec; the array element struct is
                // ABSORBED (its members become the op's direct operands); each
                // member value folds recursively — a struct whose fields are all
                // scalar collapses to a constant, a struct with a sub-struct field
                // stays an op75 tagged with that struct's typespec. (Refuses any
                // shape it cannot fold exactly, leaving the baseline pattern.)
                bool structArrShape9 = false;
                if (auto& pctA9 = ps.getType().getCanonicalType();
                    pctA9.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                    const Type* lf9a = &pctA9;
                    while (lf9a->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        lf9a = &lf9a->getCanonicalType()
                                    .as<FixedSizeUnpackedArrayType>()
                                    .elementType;
                    structArrShape9 =
                        lf9a->getCanonicalType().kind ==
                            SymbolKind::PackedStructType &&
                        init &&
                        stripImplicitConv(*init).kind ==
                            ExpressionKind::SimpleAssignmentPattern;
                }
                if (!rhs && topView && !inPackage && hasParamArrTs &&
                    structArrShape9) {
                    std::string pfxA = prefix;
                    if (pfxA.size() >= 2 &&
                        pfxA.compare(pfxA.size() - 2, 2, "::") == 0)
                        pfxA.resize(pfxA.size() - 2);
                    if (auto* aop = foldUnpackedStructArrayPattern(
                            *init, ps.getType(), paramArrTs(), pfxA, pa, prefix,
                            netMap)) {
                        rhs = aop;
                    }
                }
                // ELAB OVERRIDDEN unpacked VECTOR-array param: the Rhs folds
                // to ONE wide BIN constant of the OVERRIDE bits at the
                // DEFAULT span, nameless ts ref -> the array_typespec.
                // Surelog ZERO-extends sized 'b literals (17'bx -> 16 zeros
                // + x), so fold TEXTUALLY from the override syntax and bail
                // on any non-'b leaf (param_array_wildcard).
                if (!rhs && topView && !inPackage && overridden &&
                    hasParamArrTs && boundInit && boundInit->syntax &&
                    defaultSyn) {
                    const Type* lf9 = &ps.getType().getCanonicalType();
                    bool isArr9 =
                        lf9->kind == SymbolKind::FixedSizeUnpackedArrayType;
                    while (lf9->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        lf9 = &lf9->getCanonicalType()
                                   .as<FixedSizeUnpackedArrayType>()
                                   .elementType;
                    if (isArr9 && lf9->getCanonicalType().isPackedArray()) {
                        std::string bits9;
                        std::function<bool(const syntax::SyntaxNode&)> fold9 =
                            [&](const syntax::SyntaxNode& sn9) -> bool {
                            if (sn9.kind == syntax::SyntaxKind::
                                                ConcatenationExpression) {
                                for (auto* el9 :
                                     sn9.as<syntax::ConcatenationExpressionSyntax>()
                                         .expressions)
                                    if (!fold9(*el9))
                                        return false;
                                return true;
                            }
                            if (sn9.kind == syntax::SyntaxKind::
                                                IntegerVectorExpression) {
                                std::string t9(rawText(sn9.sourceRange()));
                                auto q9 = t9.find('\'');
                                if (q9 == std::string::npos || q9 == 0)
                                    return false;
                                size_t sz9 =
                                    (size_t)atoi(t9.substr(0, q9).c_str());
                                if (!sz9 || q9 + 1 >= t9.size() ||
                                    (char)tolower(t9[q9 + 1]) != 'b')
                                    return false;
                                std::string dg9;
                                for (char ch9 : t9.substr(q9 + 2))
                                    if (ch9 != '_' && ch9 != ' ')
                                        dg9 += (char)tolower(ch9);
                                if (dg9.empty() || dg9.size() > sz9)
                                    return false;
                                bits9 +=
                                    std::string(sz9 - dg9.size(), '0') + dg9;
                                return true;
                            }
                            return false;
                        };
                        if (fold9(*boundInit->syntax) && !bits9.empty()) {
                            auto* c9 = s.MakeConstant();
                            c9->VpiDecompile(std::to_string(bits9.size()) +
                                             "'b" + bits9);
                            c9->VpiSize((int32_t)bits9.size());
                            c9->VpiValue("BIN:" + bits9);
                            c9->VpiConstType(vpiBinaryConst);
                            setLoc(c9, defaultSyn->sourceRange());
                            auto* rt9 = s.MakeRef_typespec();
                            rt9->VpiParent(c9);
                            rt9->Actual_typespec(paramArrTs());
                            c9->Typespec(rt9);
                            rhs = c9;
                        }
                    }
                }
                // DEF-view TYPEDEF-typed param whose default is an UNQUALIFIED
                // ref to an imported pkg param (materialized in this module)
                // keeps an UNBOUND ref_obj Rhs (Surelog), not a fold. A param
                // typed by a DIRECT vector (logic [7:0][3:0] P = X) still
                // folds (ParameterFromPkg* distinguisher).
                if (!rhs && !topView && !inPackage && ps.getDeclaredType() &&
                    ps.getDeclaredType()->getType().kind ==
                        SymbolKind::TypeAlias) {
                    auto& sref9 = stripImplicitConv(*init);
                    if (sref9.kind == ExpressionKind::NamedValue &&
                        sref9.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        sref9.syntax &&
                        sref9.syntax->kind ==
                            syntax::SyntaxKind::IdentifierName) {
                        auto& rsym9 = sref9.as<NamedValueExpression>().symbol;
                        if (auto rsc9 = rsym9.getParentScope();
                            rsc9 && rsc9->asSymbol().kind ==
                                        SymbolKind::Package &&
                            std::find(paramSyms.begin(), paramSyms.end(),
                                      (const ParameterSymbol*)&rsym9) !=
                                paramSyms.end()) {
                            auto* ro9 = s.MakeRef_obj();
                            ro9->VpiName(rsym9.name);
                            ro9->VpiFullName(
                                joinPath(prefix, std::string(rsym9.name)));
                            ro9->VpiParent(pa);
                            setLoc(ro9, init->sourceRange);
                            rhs = ro9;
                        }
                    }
                }
                // A MODULE localparam initialized by a DIRECT const-call
                // (localparam A = func(0)) folds in the ELAB view; the def view
                // keeps the func_call (Surelog).
                if (!rhs && topView && !inPackage && isLocal) {
                    auto& icc9 = stripImplicitConv(*init);
                    const SubroutineSymbol* csub9 = nullptr;
                    if (icc9.kind == ExpressionKind::Call &&
                        !icc9.as<CallExpression>().isSystemCall())
                        if (auto sp9 = std::get_if<const SubroutineSymbol*>(
                                &icc9.as<CallExpression>().subroutine))
                            csub9 = *sp9;
                    // An ARGUMENT Surelog cannot itself reduce to a constant
                    // (a system call outside ExprEval's repertoire — $floor,
                    // $ceil, ... as opposed to $bits/$clog2/$size/$signed)
                    // makes EvalFunc report an invalid value, so the call
                    // stays a func_call in the elab view too (const_func:
                    // localparam signed Z = negate($floor(W / X))).
                    bool unevalArg9 = false;
                    if (csub9)
                        for (auto* a9 : icc9.as<CallExpression>().arguments())
                            a9->visit(makeVisitor(
                                [&](auto& vis9, const CallExpression& ce9) {
                                    static const std::set<std::string>
                                        kEvalSys = {"$bits",  "$size",
                                                    "$high",  "$low",
                                                    "$left",  "$right",
                                                    "$clog2", "$signed",
                                                    "$unsigned"};
                                    if (ce9.isSystemCall() &&
                                        !kEvalSys.count(std::string(
                                            ce9.getSubroutineName())))
                                        unevalArg9 = true;
                                    vis9.visitDefault(ce9);
                                }));
                    // A function whose body declares a LOCALPARAM defeats
                    // Surelog's const evaluator — the call stays symbolic
                    // (const_func_block_var). Lifetime is irrelevant.
                    if (csub9 && !unevalArg9 && !subroutineDeclaresParam(*csub9) &&
                        !subroutinePoisonsEvalFunc(*csub9, comp)) {
                        auto& pv9 = ps.getValue();
                        if (pv9.isInteger() &&
                            !pv9.integer().hasUnknown()) {
                            auto iv9 = pv9.integer();
                            // Surelog's 64-bit fold model (srlgFold) beats the
                            // LRM value where a sign-extended `>>` is in play.
                            if (hasSignExtendedShift(*csub9)) {
                                SrlgFold sf9;
                                if (auto wv9 = sf9.call(
                                        *csub9,
                                        icc9.as<CallExpression>().arguments()))
                                    iv9 = SVInt(64, (uint64_t)*wv9, false);
                            }
                            // A RANGED-UNTYPED localparam const-call fold
                            // ([HI:LO] C_CONST = F(..)) folds like A_CONST: UINT
                            // at the (per-instance) RANGE width with a ts ref to
                            // the range int_typespec — NOT the BIN value form a
                            // plain untyped localparam takes.
                            if (isRangedUntypedParam(ps)) {
                                std::string digits9 =
                                    iv9.toString(LiteralBase::Decimal, false);
                                auto* c9 = s.MakeConstant();
                                c9->VpiDecompile(digits9);
                                c9->VpiSize(
                                    (int32_t)ps.getType().getBitWidth());
                                c9->VpiValue("UINT:" + digits9);
                                c9->VpiConstType(vpiUIntConst);
                                c9->VpiParent(pa);
                                setLoc(c9, icc9.sourceRange);
                                if (wantTs) {
                                    auto* rt = s.MakeRef_typespec();
                                    std::string tsPfx9 = prefix;
                                    if (tsPfx9.size() >= 2 &&
                                        tsPfx9.compare(tsPfx9.size() - 2, 2,
                                                       "::") == 0)
                                        tsPfx9.resize(tsPfx9.size() - 2);
                                    rt->VpiFullName(tsPfx9);
                                    rt->VpiParent(c9);
                                    c9->Typespec(rt);
                                    rhsRt = rt;
                                }
                                rhs = c9;
                            }
                            else {
                            // Surelog sizes the inlined fold at the FUNCTION
                            // RETURN type's width; a PREDEFINED-integer return
                            // (`function integer log2`) carries no explicit
                            // width, so it takes the untyped 64-bit default
                            // ([30:0]/[7:0] returns keep 31/8).
                            auto& rty9 = csub9->getReturnType();
                            int32_t w9 = rty9.isPredefinedInteger()
                                             ? 64
                                             : (int32_t)rty9.getBitWidth();
                            if (w9 <= 0)
                                w9 = (int32_t)iv9.getBitWidth();
                            auto enc9 = constCallEncoding(*csub9);
                            std::string digits9 =
                                iv9.toString(LiteralBase::Decimal, false);
                            auto* c9 = s.MakeConstant();
                            if (enc9 == ConstCallEnc::ConcatBin) {
                                auto wv9 = iv9.resize((slang::bitwidth_t)w9);
                                std::string bits9;
                                for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                                    bits9 += wv9[i9] == slang::logic_t(1)
                                                 ? '1'
                                                 : '0';
                                c9->VpiDecompile(std::to_string(w9) + "'b" +
                                                 bits9);
                                c9->VpiValue("BIN:" + bits9);
                                c9->VpiConstType(vpiBinaryConst);
                            }
                            else if (enc9 == ConstCallEnc::BoolBin) {
                                c9->VpiDecompile(std::to_string(w9) + "'b" +
                                                 digits9);
                                c9->VpiValue("BIN:" + digits9);
                                c9->VpiConstType(vpiBinaryConst);
                            }
                            else {
                                c9->VpiDecompile(digits9);
                                c9->VpiValue("UINT:" + digits9);
                                c9->VpiConstType(vpiUIntConst);
                            }
                            c9->VpiSize(w9);
                            c9->VpiParent(pa);
                            setLoc(c9, icc9.sourceRange);
                            rhs = c9;
                            }
                        }
                    }
                }
                forceConstParent = !nestedPat;
                inParamInit = true;
                // A wide (>64b) PACKAGE struct-pattern param's ELAB view is
                // byte-identical to its DEF view (tagged_pattern tree); drive
                // emitExpr down the def path for it (WIDTH RULE).
                paramInitDef = !topView || structWidePkg;
                paramInitPkg = inPackage;
                importedParamClone = isImported && !inPackage;
                bool savedSuppP = suppressConstParent;
                if (!topView && nestedPat)
                    suppressConstParent = true;
                // ELAB (topView) view of an UNPACKED-struct typed param: Surelog
                // FOLDS the elab default to the flat op form (each struct level
                // is an op75 tagged with its struct_typespec; the leaf scalar is
                // a bare constant), rather than the DEF tagged_pattern shape.
                // Re-emit in `reemitting` mode to drop the tags; the outer op's
                // struct ts ref is attached below (structOp -> rhsRt). The DEF
                // view keeps the tagged form (paramInitDef).
                // The elab default may reach us as a struct assignment pattern
                // OR as a NamedValue reference to a struct-valued (local)param
                // that emitExpr folds into the pattern op — both fold flat.
                bool elabUnpStructPat = false;
                if (topView && !inPackage && typedParam && !rhs) {
                    auto& sk0 = stripImplicitConv(*init);
                    elabUnpStructPat =
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        (sk0.kind == ExpressionKind::StructuredAssignmentPattern ||
                         sk0.kind == ExpressionKind::SimpleAssignmentPattern ||
                         sk0.kind == ExpressionKind::NamedValue);
                }
                bool savedReemit0 = reemitting;
                if (elabUnpStructPat)
                    reemitting = true;
                auto* savedImpInst0 = importedInitPkgInst;
                if (!inPackage && isImported && ps.getParentScope())
                    if (auto pit0 =
                            pkgDefMap.find(&ps.getParentScope()->asSymbol());
                        pit0 != pkgDefMap.end())
                        importedInitPkgInst = (UHDM::instance*)pit0->second;
                if (!rhs)
                    rhs = emitExpr(*init, pa, prefix, netMap);
                importedInitPkgInst = savedImpInst0;
                reemitting = savedReemit0;
                // A DEF-view materialized UNTYPED integral import's Rhs constant
                // is sized at the param's type width (Surelog: 32 for a plain
                // int import) — matching its elab view, not the 64-bit default.
                if (!topView && !inPackage && isImported && !typedParam && rhs &&
                    rhs->UhdmType() == UHDM::uhdmconstant &&
                    ps.getType().getCanonicalType().isIntegral() &&
                    ps.getDeclaredType() &&
                    ps.getDeclaredType()->getTypeSyntax() &&
                    ps.getDeclaredType()->getTypeSyntax()->kind ==
                        syntax::SyntaxKind::ImplicitType)
                    ((UHDM::constant*)rhs)
                        ->VpiSize((int32_t)ps.getType().getBitWidth());
                suppressConstParent = savedSuppP;
                paramInitPkg = false;
                paramInitDef = false;
                importedParamClone = false;
                inParamInit = false;
                forceConstParent = false;
                // Elab typed-param op init with UNKNOWN param-ref operands:
                // the refs fold to their BIN:X/Z constants and the op gains a
                // ts ref (patched to the param's typespec).
                if (topView && typedParam && rhs &&
                    rhs->UhdmType() == UHDM::uhdmoperation) {
                    auto* opr = (UHDM::operation*)rhs;
                    bool anyUnknown = false;
                    if (opr->Operands())
                        for (auto*& o2 : *opr->Operands()) {
                            if (o2->UhdmType() != UHDM::uhdmref_obj)
                                continue;
                            auto* r2 = (UHDM::ref_obj*)o2;
                            for (auto* pp : *params) {
                                if (pp->VpiName() != r2->VpiName())
                                    continue;
                                std::string_view pv =
                                    ((UHDM::parameter*)pp)->VpiValue();
                                if (pv.rfind("BIN:", 0) == 0 &&
                                    pv.find_first_of("XZxz") !=
                                        std::string_view::npos) {
                                    auto* c2 = s.MakeConstant();
                                    std::string digs(pv.substr(4));
                                    c2->VpiDecompile("'b" + digs);
                                    c2->VpiSize(-1);
                                    c2->VpiValue(std::string(pv));
                                    c2->VpiConstType(vpiBinaryConst);
                                    c2->VpiParent(opr);
                                    c2->VpiLineNo(r2->VpiLineNo());
                                    c2->VpiColumnNo(r2->VpiColumnNo());
                                    c2->VpiEndLineNo(r2->VpiEndLineNo());
                                    c2->VpiEndColumnNo(r2->VpiEndColumnNo());
                                    o2 = c2;
                                    anyUnknown = true;
                                }
                                break;
                            }
                        }
                    // A PACKED-ARRAY typed param's ASSIGNMENT-PATTERN op ('{..})
                    // also carries a ts ref to the param's typespec (Surelog),
                    // even when all its operands are known literals. A
                    // CONCATENATION init ({a,b}) does NOT (PkgParamAsFunctionArg).
                    bool packedArrayOp =
                        ps.getType().getCanonicalType().isPackedArray() &&
                        opr->VpiOpType() == vpiAssignmentPatternOp;
                    // An UNPACKED-array param's elab-view pattern op also gets a
                    // ts ref, but its actual is a FRESH array_typespec (not the
                    // deferred/patched param typespec) — built inline here.
                    // ONLY when the array's leaf element is a simple integral
                    // (int X[1:0]='{0,1}): a STRUCT/UNION-element array
                    // ('{'{phase:1'b1}}) keeps its nested tagged-pattern ops and
                    // Surelog attaches NO typespec to the outer op.
                    bool unpackedArrayOp = false;
                    if (ps.getType().getCanonicalType().kind ==
                            SymbolKind::FixedSizeUnpackedArrayType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp) {
                        const Type* uleaf = &ps.getType().getCanonicalType();
                        while (uleaf->getCanonicalType().kind ==
                               SymbolKind::FixedSizeUnpackedArrayType)
                            uleaf = &uleaf->getCanonicalType()
                                         .as<FixedSizeUnpackedArrayType>()
                                         .elementType;
                        auto lk = uleaf->getCanonicalType().kind;
                        unpackedArrayOp =
                            lk != SymbolKind::PackedStructType &&
                            lk != SymbolKind::UnpackedStructType &&
                            lk != SymbolKind::PackedUnionType &&
                            lk != SymbolKind::UnpackedUnionType;
                    }
                    // A materialized IMPORTED vector-typedef param's elab
                    // CONCAT op also carries a ts ref (own clone pair).
                    bool importedConcatOp =
                        isImported && typedParam &&
                        ps.getType().getCanonicalType().isPackedArray() &&
                        opr->VpiOpType() == vpiConcatOp;
                    // An UNPACKED-struct typed param's elab assignment-pattern
                    // op carries a ts ref to the param's struct typespec
                    // (Surelog folds the elab default, tagging the outer op with
                    // the struct_typespec at the instance-scoped fullname). The
                    // PACKED-struct case is handled by the flat op75 branch
                    // above; here the op keeps its (reemitted) folded operands.
                    //
                    // ...but only when the value comes from the param's OWN
                    // DEFAULT. An unpacked-struct param OVERRIDDEN by a bare
                    // REFERENCE to another (package local)param — tif
                    // #(p::CFG_PER) — instead takes Surelog's VERBATIM copy of
                    // the referenced param's own Rhs tree: the outer pattern op
                    // carries NO typespec at all (only the nested member ops
                    // keep theirs), and it spans the REFERENCED param's
                    // initializer. Distinguisher: iface_struct_field_param_width
                    // (overridden by p::CFG_PER -> no outer ts, op@pkg-init
                    // span) vs iface_nested_param_field (plain `tif s()`,
                    // default p::CFG_DEF -> outer ts at the default span).
                    bool structRefOv = false;
                    if (overridden) {
                        auto& ov0 = stripImplicitConv(*init);
                        structRefOv =
                            ov0.kind == ExpressionKind::NamedValue &&
                            ov0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter;
                    }
                    bool structOp =
                        !inPackage && !structRefOv &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp;
                    // Same rule for the SPAN: the copied tree keeps the
                    // referenced param's initializer source range.
                    if (structRefOv &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp) {
                        auto& ov1 = stripImplicitConv(*init);
                        if (auto* rin = ov1.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>()
                                            .getInitializer())
                            setLoc(opr, rin->sourceRange);
                    }
                    if ((anyUnknown || packedArrayOp || unpackedArrayOp ||
                         importedConcatOp || structOp) &&
                        !(opr->Typespec() &&
                          opr->Typespec()->Actual_typespec())) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent(opr);
                        opr->Typespec(rt);
                        if (unpackedArrayOp)
                            // The OP's clone names its element ref by the
                            // holding ref_typespec's own fullname (the
                            // instance prefix), not the parameter's.
                            rt->Actual_typespec(makeUnpackedArrayParamTs(
                                ps, tsPrefix, rt, nullptr, true));
                        else
                            rhsRt = rt;
                    }
                    // Record the elab pattern op so a gen-scope localparam that
                    // element-selects this array param can adopt its operand.
                    if (unpackedArrayOp)
                        elabArrayPatternOp[&ps] = opr;
                }
            }
            if (rhs) {
                pa->Rhs(rhs);
                // A DEF-view param_assign is a DEEP-CLONED object at
                // elaboration, so Surelog re-parents its Rhs at the
                // param_assign. Our fold/emit fallback leaves a bare constant
                // for a MODULE param whose default is a pkg-param ref
                // (P = X, P_INSTANCE = P_PKG). Package-param Rhs constants
                // (which are SHARED into reading cont_assigns and re-parented
                // there) and constants some later arm still parents are left
                // alone: only claim a still-bare DEF-view MODULE Rhs here.
                if (!topView && !inPackage &&
                    rhs->UhdmType() == UHDM::uhdmconstant && !rhs->VpiParent())
                    rhs->VpiParent(pa);
                // An IMPORTED param's def-view copy is a materialized (already
                // resolved) param: its bare-decimal RHS folds to the type width
                // (int -> 32), exactly like the elab view — NOT the package
                // def's raw 64-bit bare decimal (Surelog sizes the copy, not
                // the source literal).
                if (isImported && !topView && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    ((UHDM::constant*)rhs)
                        ->VpiSize((int32_t)ps.getType().getBitWidth());
                // The ELAB (top-view) MODULE copy of a TYPED param re-emits
                // the param's RESOLVED VALUE, so a BASED-DECIMAL default
                // loses its base form: 2'd1 becomes a plain int constant
                // (INT:1, decompile "1"). Other bases keep their source
                // encoding; the DEF view AND the package views keep DEC
                // (Surelog; cs_registers CSR_MISA_MXL / ibex_pkg,
                // rp32_r5p_mouse ST0-ST3).
                if (topView && typedParam && !inPackage &&
                    rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto* rc9 = (UHDM::constant*)rhs;
                    std::string_view v9 = rc9->VpiValue();
                    if (v9.rfind("DEC:", 0) == 0) {
                        std::string dg9(v9.substr(4));
                        rc9->VpiValue("INT:" + dg9);
                        rc9->VpiConstType(vpiIntConst);
                        rc9->VpiDecompile(dg9);
                    }
                }
                if (inPackage && !topView && rhs->UhdmType() == UHDM::uhdmconstant)
                    pkgParamConst[&member] = (UHDM::constant*)rhs;
                if (inPackage && !topView)
                    pkgParamObj[&member] = up;
                // Registered per VIEW: the top-view pass overwrites with its
                // elab Rhs so view-local refs chain within their own view.
                if (inPackage)
                    pkgParamDefRhs[&member] = rhs;
                // ELAB pkg typed-param whose init chain (through same-pkg
                // param refs) lands on an ENUM VALUE folds in the enum
                // literal's source HEX form (8'hCC / HEX:CC) — Surelog.
                if (topView && inPackage && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    enumOriginHexRecode((UHDM::constant*)rhs, init);
                // Literal inits of typed params carry the param typespec
                // (patched late together with the param ref).
                // Unknown ('x/'z) defaults: uppercase digits and a BARE
                // (never-patched) ts ref on the Rhs constant.
                if (rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto* rc = (UHDM::constant*)rhs;
                    std::string_view v0 = rc->VpiValue();
                    if (v0.rfind("BIN:", 0) == 0 &&
                        (v0.find_first_of("xXzZ") != std::string_view::npos)) {
                        // (emitExpr already uppercased the value/decompile.)
                        // Elab-view unbased-unsized 'x/'z decompiles with an
                        // explicit 'b base ('x -> 'bX); the def view keeps the
                        // bare 'X (Surelog quirk).
                        if (topView &&
                            stripImplicitConv(*init).kind ==
                                ExpressionKind::UnbasedUnsizedIntegerLiteral)
                            rc->VpiDecompile("'b" + std::string(v0.substr(4)));
                        if (!topView && !wantTs && !rc->Typespec()) {
                            auto* brt = s.MakeRef_typespec();
                            std::string tsPrefix = prefix;
                            if (tsPrefix.size() >= 2 &&
                                tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                                tsPrefix.resize(tsPrefix.size() - 2);
                            brt->VpiFullName(tsPrefix);
                            brt->VpiParent(rc);
                            rc->Typespec(brt);
                        }
                    }
                }
                // Elab-view string constants decompile WITHOUT quotes (the
                // def view keeps them).
                if (topView && rhs->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::constant*)rhs)->VpiConstType() == vpiStringConst) {
                    auto* rc = (UHDM::constant*)rhs;
                    std::string d(rc->VpiDecompile());
                    if (d.size() >= 2 && d.front() == '"' && d.back() == '"')
                        rc->VpiDecompile(d.substr(1, d.size() - 2));
                }
                if (auto& sik = stripImplicitConv(*init);
                    // An ELAB MATERIALIZED MULTIDIM-vector import's literal
                    // Rhs carries NO ts ref (Surelog); scalar/1-D imports
                    // keep it.
                    !(topView && isImported &&
                      ps.getType().getCanonicalType().kind ==
                          SymbolKind::PackedArrayType &&
                      ps.getType()
                              .getCanonicalType()
                              .as<PackedArrayType>()
                              .elementType.getCanonicalType()
                              .kind == SymbolKind::PackedArrayType) &&
                    wantTs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    (sik.kind == ExpressionKind::IntegerLiteral ||
                     sik.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral ||
                     sik.kind == ExpressionKind::RealLiteral ||
                     sik.kind == ExpressionKind::StringLiteral ||
                     // A TYPED param folded from a PKG-param ref carries the
                     // ts too (Surelog).
                     (typedParam && sik.kind == ExpressionKind::NamedValue &&
                      sik.as<NamedValueExpression>().symbol.getParentScope() &&
                      sik.as<NamedValueExpression>()
                              .symbol.getParentScope()
                              ->asSymbol()
                              .kind == SymbolKind::Package))) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    // An OVERRIDDEN vector-typedef param's elab Rhs ts ref is
                    // NAMELESS (Surelog).
                    bool vecAliasOv9 =
                        overridden && ps.getDeclaredType() &&
                        ps.getDeclaredType()->getType().kind ==
                            SymbolKind::TypeAlias &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::PackedArrayType;
                    if (!vecAliasOv9)
                        rt->VpiFullName(tsPrefix);
                    rt->VpiParent((UHDM::constant*)rhs);
                    ((UHDM::constant*)rhs)->Typespec(rt);
                    rhsRt = rt;
                }
                // A TYPED module param whose default is a BARE reference to a
                // materialized package parameter Y (parameter logic[..] P = X):
                // in the ELAB view Surelog does NOT re-fold — it CLONES Y's
                // folded constant (Y's value/encoding/size), parents it at Y's
                // param_assign, and gives its ts ref Y's package-located
                // typespec (NOT a fresh bare recompute). ParameterFromPkg*.
                if (topView && !inPackage && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto& sref = stripImplicitConv(*init);
                    if (sref.kind == ExpressionKind::NamedValue) {
                        auto& ysym =
                            sref.as<NamedValueExpression>().symbol;
                        if (ysym.kind == SymbolKind::Parameter &&
                            ysym.getParentScope() &&
                            ysym.getParentScope()->asSymbol().kind ==
                                SymbolKind::Package) {
                            UHDM::param_assign* ypa = nullptr;
                            UHDM::constant* yc = nullptr;
                            for (auto& [msym, rec] : pkgRefSrc)
                                if (msym->location == ysym.location &&
                                    msym->name == ysym.name) {
                                    ypa = rec.first;
                                    yc = rec.second;
                                    break;
                                }
                            if (ypa && yc && rhsRt) {
                                auto* rc = (UHDM::constant*)rhs;
                                rc->VpiValue(std::string(yc->VpiValue()));
                                rc->VpiConstType(yc->VpiConstType());
                                rc->VpiSize(yc->VpiSize());
                                rc->VpiDecompile(
                                    std::string(yc->VpiDecompile()));
                                rc->VpiParent(ypa);
                                auto* yts = makeParamTs(
                                    ysym.as<ParameterSymbol>(), true);
                                if (ysym.getParentScope())
                                    if (auto pit = pkgDefMap.find(
                                            &ysym.getParentScope()
                                                 ->asSymbol());
                                        pit != pkgDefMap.end())
                                        yts->Instance(
                                            (UHDM::instance*)pit->second);
                                rhsRt->Actual_typespec(yts);
                                pkgRefFold = true;
                            }
                        }
                    }
                }
            }
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant)
                rhsConstForMap = (UHDM::constant*)rhs;
            // DEFPARAM'd param (value differs from the declared-default
            // eval, but the initializer is still the default): Surelog keeps
            // the DEFAULT value on the parameter and puts the DEFPARAM value
            // in the param_assign Rhs (hierdefparam: UINT:44 / Rhs 42).
            if (!inPackage && !overridden && hasDefault && defaultInit &&
                rhs && rhs->UhdmType() == UHDM::uhdmconstant) {
                auto& cvd9 = ps.getValue();
                if (cvd9.isInteger() && !cvd9.integer().hasUnknown() &&
                    ps.getType().getCanonicalType().isIntegral()) {
                ASTContext dctx9(body, LookupLocation::max);
                auto dv9 = dctx9.tryEval(*defaultInit);
                if (dv9 && dv9.isInteger() &&
                    !dv9.integer().hasUnknown() &&
                    dv9.integer() != cvd9.integer()) {
                    std::string cd9 = cvd9.integer().toString(
                        LiteralBase::Decimal, false);
                    std::string dd9 = dv9.integer().toString(
                        LiteralBase::Decimal, false);
                    if (topView) {
                        auto* rc9 = (UHDM::constant*)rhs;
                        rc9->VpiDecompile(cd9);
                        rc9->VpiValue("UINT:" + cd9);
                    }
                    up->VpiValue("UINT:" + dd9);
                }
                }
            }
        }
        passigns->push_back(pa);
        // DEF-view aggregate-typedef params (typedef struct/union/enum T; then
        // parameter T P) defer their ts binding past emitTypedefs so they can
        // SHARE the named typedef typespec (drainDefParamTs).
        bool deferAggTs = false;
        if (auto dAgg = ps.getDeclaredType()) {
            auto& dtAgg = dAgg->getType();
            auto ckAgg = dtAgg.getCanonicalType().kind;
            deferAggTs = dtAgg.kind == SymbolKind::TypeAlias &&
                         (ckAgg == SymbolKind::PackedStructType ||
                          ckAgg == SymbolKind::PackedUnionType ||
                          ckAgg == SymbolKind::EnumType ||
                          // A local VECTOR typedef param defers too so its DEF
                          // ts SHARES the typedef's logic_typespec (drained
                          // past emitTypedefs) instead of the int_typespec
                          // fallback; the ELAB view keeps its aliased clone.
                          (ckAgg == SymbolKind::PackedArrayType &&
                           dtAgg.getCanonicalType().isIntegral()));
        }
        if (prt) {
            if (topView && !inPackage) {
                // A pkg-ref clone already bound its Rhs ts to the pkg-located
                // typespec; keep the deferred patch off that ref.
                pendingParamTs.push_back(
                    {&ps, up, prt, pkgRefFold ? nullptr : rhsRt, typedParam});
            }
            else if (deferAggTs) {
                pendingDefParamTs.push_back({&ps, up, prt, rhsRt, typedParam, m,
                                             &member, di, inPackage,
                                             joinPath(prefix, ps.name)});
                // The def-Lhs parameter clone drains its OWN ts clone chain.
                if (upLhs9 && prtLhs9)
                    pendingDefParamTs.push_back(
                        {&ps, upLhs9, prtLhs9, nullptr, typedParam, m, &member,
                         nullptr, inPackage, joinPath(prefix, ps.name)});
            }
            else {
                // $bits(SIGNAL) bounds scope their refs through the param
                // and bind this view's nets; currentScope lets a FIXED-width
                // $bits fold even in the def pre-pass.
                std::string savedPfx2 = syntaxRefPrefix;
                const Scope* savedCS = currentScope;
                syntaxRefPrefix = joinPath(prefix, ps.name);
                if (!currentScope)
                    currentScope = ps.getParentScope();
                auto* its = makeParamTs(ps, typedParam);
                currentScope = savedCS;
                syntaxRefPrefix = savedPfx2;
                bool untypedImport = !inPackage && isImported && !typedParam;
                if (inPackage && typedParam)
                    stampPkgTsInst(its);
                else if (!inPackage && isImported && ps.getParentScope()) {
                    // An imported param's typespec is INSTANCED at its package —
                    // but ONLY for TYPED imports. An UNTYPED import (parameter
                    // W = 48) keeps its int_typespec Instance-less, exactly as
                    // it is in its home package (Surelog; fail_detect_width).
                    // ...and the package it reaches is the ELABORATED (top)
                    // one — Surelog's cross-view instance links land on the
                    // elab package, and UHDM's Compare follows
                    // typespec->vpiInstance, so binding the DEF view drags the
                    // UNELABORATED param constants into the comparison
                    // (cs_registers: 64-bit def vs 32-bit elab pkg params).
                    if (typedParam) {
                        const void* home3 = &ps.getParentScope()->asSymbol();
                        if (auto tit = pkgTopMap.find(home3);
                            tit != pkgTopMap.end())
                            its->Instance((UHDM::instance*)tit->second);
                        else if (auto pit = pkgDefMap.find(home3);
                                 pit != pkgDefMap.end()) {
                            its->Instance((UHDM::instance*)pit->second);
                            pkgImportTsTopFixups.emplace_back(its, home3);
                        }
                    }
                    // Remember it so a def-view fold that READS this imported
                    // param can carry a ref_typespec to it.
                    importedParamDefTs[&ps] = its;
                }
                if (di)
                    di->paramTs[&member] = its;
                // Remember the DEF param's own ts ref: a cont-assign function
                // call taking this param as a direct actual REBINDS it to the
                // formal's typespec (Surelog).
                if (di && !inPackage)
                    defParamTsRef[&member] = prt;
                if (rhsRt) {
                    // An untyped import's Rhs constant ref binds its OWN fresh
                    // int_typespec (Surelog builds a distinct typespec per ref,
                    // not the shared param ts).
                    if (!inPackage && isImported) {
                        std::string savedPfxR = syntaxRefPrefix;
                        syntaxRefPrefix = joinPath(prefix, ps.name);
                        auto* itsR = makeParamTs(ps, typedParam);
                        syntaxRefPrefix = savedPfxR;
                        itsR->Instance(its->Instance());
                        itsR->VpiParent(rhsRt);
                        rhsRt->Actual_typespec(itsR);
                    }
                    else
                        rhsRt->Actual_typespec(its);
                }
                prt->Actual_typespec(its);
                // An untyped import's param-ref int_typespec is parented at its
                // ref_typespec (Surelog); typed/ranged params handle this via the
                // VpiParent(up) rule below.
                if (untypedImport && !its->VpiParent())
                    its->VpiParent(prt);
                if (prtLhs9 && !prtLhs9->Actual_typespec()) {
                    // The Lhs clone gets its OWN fresh ts (pkg-Instanced,
                    // parented at the clone's ref) — Surelog.
                    std::string savedPfxL = syntaxRefPrefix;
                    syntaxRefPrefix = joinPath(prefix, ps.name);
                    auto* itsL = makeParamTs(ps, typedParam);
                    syntaxRefPrefix = savedPfxL;
                    if (!inPackage && isImported && typedParam && ps.getParentScope())
                        if (auto pitL =
                                pkgDefMap.find(&ps.getParentScope()->asSymbol());
                            pitL != pkgDefMap.end())
                            itsL->Instance((UHDM::instance*)pitL->second);
                    itsL->VpiParent(prtLhs9);
                    prtLhs9->Actual_typespec(itsL);
                }
                bool signedImplicit = false;
                if (auto d0 = ps.getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        if (t0->kind == syntax::SyntaxKind::ImplicitType)
                            signedImplicit =
                                t0->as<syntax::ImplicitTypeSyntax>().signing.valid() &&
                                t0->as<syntax::ImplicitTypeSyntax>().dimensions.empty();
                // A MATERIALIZED IMPORT's typespec parents at its
                // ref_typespec, not the parameter (that form is for the
                // param's HOME scope) — Surelog.
                if (isImported && !inPackage) {
                    if (!its->VpiParent())
                        its->VpiParent(prt);
                }
                else if (typedParam || isRangedUntypedParam(ps) ||
                         signedImplicit)
                    its->VpiParent(up);
            }
        }
        // Record this param's {param_assign, Rhs constant} so a later module
        // param whose default is a bare ref to it can clone the fold.
        if (rhsConstForMap)
            pkgRefSrc[&member] = {pa, rhsConstForMap};
        // A DEGENERATE unbased fill ('x/'z) reaches its BIN Rhs constant via the
        // fallback emitExpr path (not the fold arm above), so it is recorded
        // here: Surelog shares this SAME object into the reading cont-assign.
        // ('0 was already recorded in the fold arm; '1/UINT is excluded.)
        if (topView && rhsConstForMap && !unbasedSharedPaConst.count(&ps)) {
            if (auto* pinU = ps.getInitializer()) {
                auto& siU = stripImplicitConv(*pinU);
                if (siU.kind ==
                    ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    slang::logic_t bU =
                        siU.as<UnbasedUnsizedIntegerLiteral>()
                            .getLiteralValue();
                    if (bU.isUnknown() || bU.value == 0)
                        unbasedSharedPaConst[&ps] = rhsConstForMap;
                }
            }
        }
    }
    flushPaTag9();
    // Type parameters (parameter type T = ...) emit as UHDM type_parameter
    // objects under vpiParameter. Surelog locates the DEF-view type_parameter
    // at its name token and leaves the ELAB-view one unlocated (instance type
    // params fold to id-only). The typespec Actual is the resolved default
    // (def) or override (elab) type, built from the param's own targetType.
    for (auto& member0 : body.members()) {
        if (member0.kind != SymbolKind::TypeParameter)
            continue;
        auto& tps = member0.as<TypeParameterSymbol>();
        auto* tp = s.MakeType_parameter();
        tp->VpiName(tps.name);
        tp->VpiFullName(joinPath(prefix, tps.name));
        tp->VpiParent(m);
        if (!topView)
            setLoc(tp, SourceRange(tps.location, tps.location + tps.name.size()));
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(tp);
        rt->VpiFullName(joinPath(prefix, tps.name));
        std::string savedPfx = syntaxRefPrefix;
        const Scope* savedCS = currentScope;
        syntaxRefPrefix = joinPath(prefix, tps.name);
        if (!currentScope)
            currentScope = tps.getParentScope();
        UHDM::typespec* its = nullptr;
        // The def view shows the DECLARATION default; the elab view shows this
        // instance's resolved (possibly overridden) type. The borrowed def-view
        // instance body may carry an override AND its cloned type-param symbol
        // can lose its declarator syntax, so read the default straight from the
        // module's parameter-port-list syntax.
        const syntax::DataTypeSyntax* defTypeSyn = nullptr;
        if (!topView) {
            const syntax::SyntaxNode* msyn =
                tps.getParentScope() ? tps.getParentScope()->asSymbol().getSyntax()
                                     : nullptr;
            if (auto* mds = msyn ? msyn->as_if<syntax::ModuleDeclarationSyntax>()
                                 : nullptr) {
                if (auto* ppl = mds->header->parameters)
                    for (auto* decl : ppl->declarations)
                        if (auto* tpd = decl->as_if<
                                syntax::TypeParameterDeclarationSyntax>())
                            for (auto* d : tpd->declarators)
                                if (d->name.valueText() == tps.name && d->assignment)
                                    defTypeSyn = d->assignment->type;
            }
        }
        if (defTypeSyn) {
            its = makeTypeParamDefaultTs(*defTypeSyn, body);
            // Surelog parents the def-view default typespec at the type param
            // (it is shared with the port typedefs via ref_typespec).
            if (its)
                its->VpiParent(tp);
        }
        else if (topView &&
                 tps.targetType.getType().kind == SymbolKind::TypeAlias) {
            // An elab type_parameter resolved to a TYPEDEF carries its OWN
            // bare-named CLONE of the typedef ts (parented at the type
            // param), not the shared module typedef object (Surelog).
            auto& ta9 = tps.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgt9 = nullptr;
            if (auto asyn9 = ta9.getSyntax();
                asyn9 && asyn9->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgt9 = asyn9->as<syntax::TypedefDeclarationSyntax>().type;
            if (ta9.getCanonicalType().kind == SymbolKind::EnumType)
                its = (UHDM::typespec*)buildEnumTs(
                    ta9.getCanonicalType().as<EnumType>(), tgt9,
                    std::string(ta9.name));
            else {
                bypassTypedefShare = true;
                its = makeTypespec(ta9, tgt9);
                bypassTypedefShare = false;
            }
            if (its) {
                its->VpiName(ta9.name);
                its->VpiParent(tp);
            }
            else
                its = makeTypespec(tps);
        }
        else
            its = makeTypespec(tps);
        currentScope = savedCS;
        syntaxRefPrefix = savedPfx;
        if (its)
            rt->Actual_typespec(its);
        tp->Typespec(rt);
        // Remember the elab-view resolved typespec so the port variable typed
        // by this type param can SHARE it (Surelog uses one object).
        if (topView && its)
            typeParamElabTs[&tps] = its;
        // Remember the def-view DEFAULT typespec so every type-param-typed
        // port's vpiTypedef (all views) can SHARE this one object (Surelog).
        if (!topView && its && defTypeSyn &&
            body.asSymbol().kind == SymbolKind::InstanceBody)
            typeParamDefaultTs[{(const void*)&body.asSymbol()
                                    .as<InstanceBodySymbol>()
                                    .getDefinition(),
                                std::string(tps.name)}] = its;
        params->push_back(tp);
    }
    // Surelog lists MATERIALIZED imported params NAME-SORTED in the module
    // Parameters vec (name-keyed registry); param_assigns keep location
    // order (simple_package: ADDR_WIDTH before DATA_WIDTH).
    {
        std::set<std::string_view> matNames9;
        for (auto* ps9 : paramSyms)
            if (ps9->getParentScope() != &body)
                matNames9.insert(ps9->name);
        if (!matNames9.empty()) {
            std::vector<size_t> idx9;
            std::vector<UHDM::any*> mats9;
            for (size_t i9 = 0; i9 < params->size(); i9++)
                if ((*params)[i9]->UhdmType() == UHDM::uhdmparameter &&
                    matNames9.count(
                        ((UHDM::parameter*)(*params)[i9])->VpiName())) {
                    idx9.push_back(i9);
                    mats9.push_back((*params)[i9]);
                }
            std::stable_sort(
                mats9.begin(), mats9.end(), [](UHDM::any* a, UHDM::any* b) {
                    return ((UHDM::parameter*)a)->VpiName() <
                           ((UHDM::parameter*)b)->VpiName();
                });
            for (size_t k9 = 0; k9 < idx9.size(); k9++)
                (*params)[idx9[k9]] = mats9[k9];
        }
    }
    // The ELABORATED instance assigns its PARAMETER-PORT-LIST params first
    // (they are resolved from the instantiation) and the rest — materialized
    // imported params included — after, in source-location order. BODY params
    // stay in plain location order in both views, so an imported param
    // declared earlier still leads (ParameterFromPkgInNestedModule) — Surelog
    // (ParameterFromPkgOnParameterPortList).
    if (topView && !inPackage && !portPa9.empty() &&
        portPa9.size() < passigns->size()) {
        // Rank 0: port-list pa's (resolved at instantiation, first). Rank 1:
        // body pa's. Rank 2: NO-OP-overridden module port-list pa's (value ==
        // declaration default) — the override application re-creates them
        // last (jeras_tcb_gpio: DLY localparam before GW(32)==32). A value-
        // CHANGING override keeps the port-first slot
        // (ParameterOfSizeOfParametrizedPortInSubmodule X(5)!=15).
        // Interfaces keep the plain port-first order.
        auto noopOv9 = [&](UHDM::param_assign* pa9) -> bool {
            if (!pa9->VpiOverriden() ||
                m->UhdmType() != UHDM::uhdmmodule_inst || !pa9->Lhs())
                return false;
            for (auto& mb9 : body.members()) {
                if (mb9.kind != SymbolKind::Parameter ||
                    mb9.name != std::string_view(pa9->Lhs()->VpiName()))
                    continue;
                auto& ps9 = mb9.as<ParameterSymbol>();
                if (auto* ds9 = paramDefaultSyn(ps9)) {
                    ASTContext dctx9(body, LookupLocation::max);
                    auto& de9 = Expression::bind(*ds9, dctx9);
                    auto dv9 = dctx9.tryEval(de9);
                    auto& cv9 = ps9.getValue();
                    if (dv9 && dv9.isInteger() && cv9.isInteger() &&
                        dv9.integer() == cv9.integer())
                        return true;
                }
                return false;
            }
            return false;
        };
        auto rank9 = [&](UHDM::param_assign* pa9) -> int {
            if (!portPa9.count(pa9))
                return 1;
            if (noopOv9(pa9))
                return 2;
            return 0;
        };
        std::stable_sort(passigns->begin(), passigns->end(),
                         [&](UHDM::param_assign* a9, UHDM::param_assign* b9) {
                             return rank9(a9) < rank9(b9);
                         });
    }
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
}

UHDM::array_typespec* UhdmExporter::makeUnpackedArrayParamTs(
    const ParameterSymbol& ps, const std::string& elemFull,
    UHDM::BaseClass* parent, UHDM::VectorOfrange* sharedRanges,
    bool elabClone, const std::string& dimRefPrefix) {
    const Type* leaf = &ps.getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    // Element typespec (int_typespec for int/..., logic_typespec else) at the
    // declared-type keyword span.
    SourceRange typeR(ps.location, ps.location);
    if (auto declared = ps.getDeclaredType())
        if (auto tsyn = declared->getTypeSyntax())
            typeR = tsyn->getFirstToken().range();
    UHDM::typespec* elemTs = nullptr;
    // A struct/union/enum element type references the SHARED typedef typespec
    // (Surelog), not a fresh logic_typespec — when it has been materialized.
    if (auto lit = typedefTs.find(leaf);
        lit != typedefTs.end() &&
        (lit->second->UhdmType() == UHDM::uhdmstruct_typespec ||
         lit->second->UhdmType() == UHDM::uhdmunion_typespec ||
         lit->second->UhdmType() == UHDM::uhdmenum_typespec))
        elemTs = lit->second;
    if (elemTs) {
        // shared typedef keeps its own parent/loc
    }
    else if (leaf->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
        auto* its = s.MakeInt_typespec();
        its->VpiSigned(leaf->isSigned());
        setLoc(its, typeR);
        elemTs = its;
    }
    else {
        auto* lts = s.MakeLogic_typespec();
        setLoc(lts, typeR);
        // A packed-VECTOR element (logic [31:0]) spans the full type syntax
        // and carries its packed range with literal-folded bounds
        // (param_array_wildcard).
        if (auto declared9 = ps.getDeclaredType()) {
            if (auto tsyn9 = declared9->getTypeSyntax()) {
                if (auto* its9 = tsyn9->as_if<syntax::IntegerTypeSyntax>();
                    its9 && !its9->dimensions.empty() &&
                    leaf->getCanonicalType().isPackedArray()) {
                    setLoc(lts, tsyn9->sourceRange());
                    auto cr9 =
                        leaf->getCanonicalType().as<PackedArrayType>().range;
                    auto* dim9 = its9->dimensions[0];
                    auto* rng9 = s.MakeRange();
                    rng9->VpiParent(lts);
                    setLoc(rng9, dim9->sourceRange());
                    const syntax::ExpressionSyntax* ls9 = nullptr;
                    const syntax::ExpressionSyntax* rs9 = nullptr;
                    if (dim9->specifier &&
                        dim9->specifier->kind ==
                            syntax::SyntaxKind::RangeDimensionSpecifier)
                        if (auto* rsel9 =
                                dim9->specifier
                                    ->as<syntax::RangeDimensionSpecifierSyntax>()
                                    .selector
                                    ->as_if<syntax::RangeSelectSyntax>()) {
                            ls9 = rsel9->left;
                            rs9 = rsel9->right;
                        }
                    auto mkc9 = [&](int64_t v9,
                                    const syntax::ExpressionSyntax* es9) {
                        auto* c9 = s.MakeConstant();
                        c9->VpiParent(rng9);
                        std::string d9 = std::to_string(v9);
                        c9->VpiDecompile(d9);
                        c9->VpiSize(64);
                        c9->VpiValue("UINT:" + d9);
                        c9->VpiConstType(vpiUIntConst);
                        if (es9)
                            setLoc(c9, es9->sourceRange());
                        return c9;
                    };
                    rng9->Left_expr(mkc9(cr9.left, ls9));
                    rng9->Right_expr(mkc9(cr9.right, rs9));
                    auto* rv9 = s.MakeRangeVec();
                    rv9->push_back(rng9);
                    lts->Ranges(rv9);
                }
            }
        }
        elemTs = lts;
    }
    auto* ats = s.MakeArray_typespec();
    ats->VpiParent(parent);
    // loc: type-start .. FIRST unpacked-dim end (Surelog; the flat ts holds
    // every dim as a range but its span stops at the first).
    SourceLocation aEnd = ps.location + ps.name.size();
    if (auto dsyn = ps.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
        if (auto& dims = dsyn->as<syntax::DeclaratorSyntax>().dimensions; !dims.empty())
            aEnd = dims[0]->sourceRange().end();
    setLoc(ats, SourceRange(typeR.start(), aEnd));
    // Ranges: reuse the shared range objects if given, else build fresh.
    UHDM::VectorOfrange* rsrc =
        sharedRanges ? sharedRanges : buildUnpackedRanges(ps, ats, dimRefPrefix);
    if (rsrc) {
        auto* atsR = s.MakeRangeVec();
        for (auto* r0 : *rsrc)
            atsR->push_back(r0);
        ats->Ranges(atsR);
    }
    auto* ert = s.MakeRef_typespec();
    ert->VpiFullName(elemFull);
    ert->VpiParent(ats);
    ert->Actual_typespec(elemTs);
    ats->Elem_typespec(ert);
    // An elaboration clone owns its element typespec, so that clone points
    // back at the ref holding it; a SHARED typedef ts keeps its own parent.
    if (elabClone && elemTs && !elemTs->VpiParent())
        elemTs->VpiParent(ert);
    return ats;
}

UHDM::operation* UhdmExporter::foldUnpackedStructArrayPattern(
    const Expression& init, const Type& arrType, UHDM::typespec* arrTs,
    const std::string& tsFullName, UHDM::any* parent, const std::string& prefix,
    NetMap& netMap, bool connFold) {
    auto& pctA = arrType.getCanonicalType();
    if (pctA.kind != SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;
    const Type* leafA = &pctA;
    while (leafA->getCanonicalType().kind ==
           SymbolKind::FixedSizeUnpackedArrayType)
        leafA = &leafA->getCanonicalType()
                     .as<FixedSizeUnpackedArrayType>()
                     .elementType;
    if (leafA->getCanonicalType().kind != SymbolKind::PackedStructType)
        return nullptr;
    auto& sinitA = stripImplicitConv(init);
    if (sinitA.kind != ExpressionKind::SimpleAssignmentPattern)
        return nullptr;
    // struct_typespec lookup for a (possibly typedef'd) type.
    auto lookupStructTs = [&](const Type& t) -> UHDM::typespec* {
        if (t.kind == SymbolKind::TypeAlias) {
            if (auto it = typedefTs.find(&t.as<TypeAliasType>());
                it != typedefTs.end())
                return it->second;
            if (auto it =
                    pkgTopTypedefTs.find((const void*)&t.as<TypeAliasType>());
                it != pkgTopTypedefTs.end())
                return it->second;
        }
        const Symbol* canon = (const Symbol*)&t.getCanonicalType();
        if (auto it = pkgTopTypedefTs.find((const void*)canon);
            it != pkgTopTypedefTs.end())
            return it->second;
        if (auto it = typedefTs.find(canon); it != typedefTs.end())
            return it->second;
        return nullptr;
    };
    // Recursive value fold. Returns nullptr on any unfoldable shape.
    std::function<UHDM::any*(const Expression&, const Type&, UHDM::any*)>
        foldField = [&](const Expression& e, const Type& ft,
                        UHDM::any* par) -> UHDM::any* {
        auto& ce = stripImplicitConv(e);
        auto& ctf = ft.getCanonicalType();
        if (ctf.kind == SymbolKind::PackedStructType &&
            ce.kind == ExpressionKind::StructuredAssignmentPattern) {
            bool hasStructMember = false;
            for (auto& f2 : ctf.as<PackedStructType>().membersOfType<FieldSymbol>())
                if (f2.getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType) {
                    hasStructMember = true;
                    break;
                }
            if (!hasStructMember)
                return nullptr; // all-scalar multi/complex struct: bail
            auto& ap2 = ce.as<StructuredAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(75);
            op->VpiParent(par);
            setLoc(op, e.sourceRange);
            // In the instance-CONNECTION flavour every nested member op is
            // sized to its own struct width (the param_assign flavour, which
            // re-uses the definition-view objects, leaves them sizeless).
            if (connFold)
                op->VpiSize((int32_t)ctf.getBitWidth());
            if (auto* sts = lookupStructTs(ft)) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiParent(op);
                rt->Actual_typespec(sts);
                op->Typespec(rt);
            }
            auto* opn = s.MakeAnyVec();
            for (auto& f2 :
                 ctf.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                const Expression* se2 = nullptr;
                for (auto& ms : ap2.memberSetters)
                    if (ms.member == &f2) {
                        se2 = ms.expr;
                        break;
                    }
                if (!se2)
                    se2 = ap2.defaultSetter;
                if (!se2)
                    return nullptr;
                auto* fv = foldField(*se2, f2.getType(), op);
                if (!fv)
                    return nullptr;
                opn->push_back(fv);
            }
            op->Operands(opn);
            return op;
        }
        // scalar / literal leaf: re-emit the source constant.
        return emitExpr(e, par, prefix, netMap);
    };
    auto& apA = sinitA.as<SimpleAssignmentPatternExpression>();
    auto& elemA = pctA.as<FixedSizeUnpackedArrayType>().elementType;
    auto* aop = s.MakeOperation();
    aop->VpiOpType(75);
    aop->VpiParent(parent);
    setLoc(aop, init.sourceRange);
    if (arrTs) {
        auto* rtA = s.MakeRef_typespec();
        rtA->VpiParent(aop);
        rtA->VpiFullName(tsFullName);
        rtA->Actual_typespec(arrTs);
        aop->Typespec(rtA);
    }
    auto* aopn = s.MakeAnyVec();
    bool ok = true;
    for (auto* el : apA.elements()) {
        auto& ee = stripImplicitConv(*el);
        auto& ect = elemA.getCanonicalType();
        if (ee.kind != ExpressionKind::StructuredAssignmentPattern ||
            ect.kind != SymbolKind::PackedStructType) {
            ok = false;
            break;
        }
        auto& eap = ee.as<StructuredAssignmentPatternExpression>();
        for (auto& f2 : ect.as<PackedStructType>().membersOfType<FieldSymbol>()) {
            const Expression* se2 = nullptr;
            for (auto& ms : eap.memberSetters)
                if (ms.member == &f2) {
                    se2 = ms.expr;
                    break;
                }
            if (!se2)
                se2 = eap.defaultSetter;
            if (!se2) {
                ok = false;
                break;
            }
            auto* fv = foldField(*se2, f2.getType(), aop);
            if (!fv) {
                ok = false;
                break;
            }
            aopn->push_back(fv);
        }
        if (!ok)
            break;
    }
    if (!ok || aopn->empty())
        return nullptr;
    aop->Operands(aopn);
    return aop;
}

bool UhdmExporter::isRangedUntypedParam(const ParameterSymbol& ps) {
    if (auto declared = ps.getDeclaredType())
        if (auto tsyn = declared->getTypeSyntax())
            if (tsyn->kind == syntax::SyntaxKind::ImplicitType)
                return !tsyn->as<syntax::ImplicitTypeSyntax>().dimensions.empty() &&
                       ps.getType().getCanonicalType().isPackedArray();
    return false;
}

// Peel selects / member-access / conversions of an initializer down to its
// root value symbol (the named/hierarchical reference the value flows from).
static const Symbol* paramInitRootSym(const Expression& e) {
    const Expression* cur = &e;
    while (cur) {
        switch (cur->kind) {
            case ExpressionKind::NamedValue:
                return &cur->as<NamedValueExpression>().symbol;
            case ExpressionKind::HierarchicalValue:
                return &cur->as<HierarchicalValueExpression>().symbol;
            case ExpressionKind::ElementSelect:
                cur = &cur->as<ElementSelectExpression>().value();
                break;
            case ExpressionKind::RangeSelect:
                cur = &cur->as<RangeSelectExpression>().value();
                break;
            case ExpressionKind::MemberAccess:
                cur = &cur->as<MemberAccessExpression>().value();
                break;
            case ExpressionKind::Conversion:
                cur = &cur->as<ConversionExpression>().operand();
                break;
            default:
                return nullptr;
        }
    }
    return nullptr;
}

// An enum-typed parameter whose value ORIGINATES (through param hops / member
// selects) in a package DIFFERENT from the enum's home instances its clone at
// the value-origin package (Surelog: the pinmux TargetCfg.dio_pad_type family).
// Follows the override initializer to its root value symbol; recurses through
// an overridden PARAMETER root; otherwise returns the package that homes the
// root symbol's declared (aggregate/enum) typedef. Returns null for the common
// case (literal override, or same-package value), leaving the home instance.
static const Symbol* enumParamValueOriginPkg(const ParameterSymbol& ps,
                                             int depth) {
    if (depth > 8)
        return nullptr;
    if (!isOverriddenParam(ps))
        return nullptr;
    const Expression* init = ps.getInitializer();
    if (!init)
        return nullptr;
    const Symbol* root = paramInitRootSym(*init);
    if (!root)
        return nullptr;
    // The value flows from another overridden parameter: recurse to ITS origin.
    if (root->kind == SymbolKind::Parameter &&
        isOverriddenParam(root->as<ParameterSymbol>()))
        if (auto* r =
                enumParamValueOriginPkg(root->as<ParameterSymbol>(), depth + 1))
            return r;
    // Otherwise the origin is the package that homes the root symbol's declared
    // named typedef (a struct/enum whose home differs from the enum's own).
    if (auto* dt = root->getDeclaredType())
        if (dt->getType().kind == SymbolKind::TypeAlias)
            for (auto* sc = dt->getType().getParentScope(); sc;
                 sc = sc->asSymbol().getParentScope())
                if (sc->asSymbol().kind == SymbolKind::Package)
                    return &sc->asSymbol();
    return nullptr;
}

UHDM::typespec* UhdmExporter::makeParamTs(const ParameterSymbol& ps, bool typedParam,
                                          bool parentBounds) {
    SourceRange tr(ps.location, ps.location + ps.name.size());
    if (typedParam) {
        if (auto declared = ps.getDeclaredType())
            if (auto tsyn = declared->getTypeSyntax()) {
                // An UNTYPED param forced to typedParam (the imported-integral
                // fallback) still locates its typespec at the DECLARATION span,
                // like a normal untyped param — not the empty implicit-type span.
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    for (auto q = ps.getSyntax(); q; q = q->parent)
                        if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                            tr = q->sourceRange();
                            break;
                        }
                }
                else
                    tr = trimTypeSigning(tsyn, tsyn->sourceRange());
            }
    }
    else {
        for (auto q = ps.getSyntax(); q; q = q->parent) {
            if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                tr = q->sourceRange();
                break;
            }
        }
        // A ranged untyped param (parameter [0:0] X) locates its int_typespec
        // at the packed-range span, not the whole declaration; a SIGNED
        // implicit param (localparam unsigned P) at the signing keyword.
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax()) {
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    auto& imp = tsyn->as<syntax::ImplicitTypeSyntax>();
                    if (!imp.dimensions.empty())
                        tr = SourceRange(imp.dimensions[0]->sourceRange().start(),
                                         imp.dimensions.back()->sourceRange().end());
                    else if (imp.signing.valid())
                        tr = imp.signing.range();
                }
            }
        }
    }
    // The typespec class follows the declared integer kind (integer -> an
    // integer_typespec, etc.); untyped params default to int_typespec.
    UHDM::typespec* its = nullptr;
    bool sharedAggTs = false;
    bool sgn = ps.getType().getCanonicalType().isSigned();
    if (typedParam) {
        auto& ct = ps.getType().getCanonicalType();
        if (ct.kind == SymbolKind::PredefinedIntegerType) {
            switch (ct.as<PredefinedIntegerType>().integerKind) {
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Time:
                    its = s.MakeTime_typespec();
                    break;
                default:
                    break;
            }
        }
    }
    // A real (real/shortreal) param is a real_typespec — typed OR an untyped
    // param inferred real from its literal (localparam p = 123.45).
    if (!its && ps.getType().getCanonicalType().isFloating())
        its = s.MakeReal_typespec();
    // A TYPED string param (parameter string N) is a LOCATED string_typespec.
    if (typedParam && !its && ps.getType().getCanonicalType().isString())
        its = s.MakeString_typespec();
    // A typed logic/bit scalar param is a logic/bit_typespec, not an
    // int_typespec.
    if (typedParam && !its) {
        auto& ct = ps.getType().getCanonicalType();
        if (ct.kind == SymbolKind::ScalarType && ct.isFourState()) {
            auto* t = s.MakeLogic_typespec();
            if (sgn)
                t->VpiSigned(true);
            its = t;
        }
        else if (ct.kind == SymbolKind::ScalarType) {
            auto* t = s.MakeBit_typespec();
            if (sgn)
                t->VpiSigned(true);
            its = t;
        }
        // A typed packed logic/bit VECTOR written directly (parameter logic
        // [31:0] X) builds a logic_typespec with its range via makeTypespec. A
        // typedef'd type (NamedType syntax) would make makeTypespec bail, so
        // it stays on the int_typespec default.
        else if (ct.kind == SymbolKind::PackedArrayType && ct.isIntegral()) {
            auto* tsyn = ps.getDeclaredType() ? ps.getDeclaredType()->getTypeSyntax() : nullptr;
            if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind))
                its = makeTypespec(ps);
            // A param typed by a VECTOR TYPEDEF (parameter my_type_t Y) uses a
            // NAMED clone of the typedef's logic_typespec with a Typedef_alias
            // ref to the shared typedef ts (Surelog), not a bare int_typespec.
            // (Only once emitTypedefs has populated typedefTs — the def
            // pre-pass falls back and is patched later.)
            else if (auto d0 = ps.getDeclaredType();
                     d0 && d0->getType().kind == SymbolKind::TypeAlias) {
                auto& taSym = d0->getType().as<TypeAliasType>();
                // A UNIQUIFIED instance body owns its OWN TypeAlias symbols,
                // which are NOT the ones typedefTs holds (it holds the DEF
                // body's, seen once at emitTypedefs). The elab child SHARES
                // the def typedef object (see the isTop-removed listing), so
                // fall back to it BY NAME when the per-instance symbol misses
                // (ParameterOfParametrizedTypeInSubmodule u_sub_5/u_sub_10 Y).
                UHDM::typespec* sharedTd = nullptr;
                if (auto tit = typedefTs.find(&taSym); tit != typedefTs.end())
                    sharedTd = tit->second;
                else if (auto* psc = ps.getParentScope();
                         psc &&
                         psc->asSymbol().kind == SymbolKind::InstanceBody) {
                    auto& defsym = psc->asSymbol()
                                       .as<InstanceBodySymbol>()
                                       .getDefinition();
                    if (auto dit = defMap.find(&defsym); dit != defMap.end())
                        for (auto* td : dit->second.typedefs)
                            if (td->VpiName() == taSym.name) {
                                sharedTd = td;
                                break;
                            }
                }
                if (sharedTd &&
                    sharedTd->UhdmType() == UHDM::uhdmlogic_typespec) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = taSym.getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn =
                                asyn->as<syntax::TypedefDeclarationSyntax>().type;
                    bypassTypedefShare = true;
                    // Keep the typedef clone's parametrized range SYMBOLIC
                    // ([X-1:0], not folded to [19:0]) — Surelog keeps the X-1
                    // operation on the alias clone in both views.
                    bool savedTf2 = tfContext;
                    tfContext = true;
                    auto* cl = makeTypespec(taSym, tgtSyn);
                    tfContext = savedTf2;
                    bypassTypedefShare = false;
                    auto* art = s.MakeRef_typespec();
                    // Package-scoped alias refs join with '::'; module-scoped
                    // with '.' (Surelog). Context comes from the REF PREFIX,
                    // not the symbol's home scope — a materialized imported
                    // param lives in the pkg but is emitted module-side.
                    bool psPkg = ps.getParentScope() &&
                                 ps.getParentScope()->asSymbol().kind ==
                                     SymbolKind::Package &&
                                 syntaxRefPrefix.rfind(
                                     std::string(
                                         ps.getParentScope()->asSymbol().name),
                                     0) == 0;
                    art->VpiFullName(syntaxRefPrefix.empty()
                                         ? std::string(taSym.name)
                                         : syntaxRefPrefix +
                                               (psPkg ? "::" : ".") +
                                               std::string(taSym.name));
                    art->VpiParent(cl);
                    // An IMPORTED vector typedef in MODULE context aliases to
                    // a SECOND bare clone (pkg-Instanced, no alias) — not the
                    // pkg's qualified ts; both clones Instance at the def pkg
                    // (Surelog).
                    // Only the MATERIALIZED IMPORTED param itself (ps lives in
                    // the typedef's home pkg) gets the second clone; a module
                    // param merely TYPED by the imported typedef aliases the
                    // qualified pkg ts directly (Surelog).
                    const Symbol* tdHome9 = nullptr;
                    if (auto hs9 = taSym.getParentScope();
                        hs9 && hs9->asSymbol().kind == SymbolKind::Package &&
                        !psPkg && ps.getParentScope() == hs9)
                        tdHome9 = &hs9->asSymbol();
                    if (tdHome9 && pkgDefMap.count(tdHome9)) {
                        bypassTypedefShare = true;
                        tfContext = true;
                        auto* clB = makeTypespec(taSym, tgtSyn);
                        tfContext = savedTf2;
                        bypassTypedefShare = false;
                        clB->VpiName(taSym.name);
                        clB->VpiParent(art);
                        clB->Instance((UHDM::instance*)pkgDefMap[tdHome9]);
                        art->Actual_typespec(clB);
                    }
                    else
                        art->Actual_typespec(sharedTd);
                    // ANY module-context clone of a pkg typedef Instances at
                    // the def pkg (Surelog).
                    if (auto hsI9 = taSym.getParentScope();
                        hsI9 && !psPkg &&
                        hsI9->asSymbol().kind == SymbolKind::Package &&
                        pkgDefMap.count(&hsI9->asSymbol()))
                        cl->Instance(
                            (UHDM::instance*)pkgDefMap[&hsI9->asSymbol()]);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    cl->VpiName(taSym.name);
                    its = cl;
                    if (tgtSyn)
                        tr = tgtSyn->sourceRange();
                }
            }
        }
        // An ENUM-typedef-typed param (parameter pad_type_e P) binds the
        // SHARED enum typespec (def view: the def object; elab: the top
        // object) — not a fresh int_typespec (Surelog).
        else if (ct.kind == SymbolKind::EnumType) {
            if (auto d0 = ps.getDeclaredType();
                d0 && d0->getType().kind == SymbolKind::TypeAlias) {
                auto& taSym = d0->getType().as<TypeAliasType>();
                if (defViewParamTs) {
                    if (auto tit = typedefTs.find(&taSym);
                        tit != typedefTs.end()) {
                        its = tit->second;
                        sharedAggTs = true;
                    }
                }
                else {
                    // ELAB: a FRESH enum clone — base ref MODULE-scoped
                    // (work@top.my_pkg::get_e), pkg-Instanced, spanning the
                    // whole typedef; parent = the prt ref (caller).
                    std::string aliasNm(taSym.name);
                    const Symbol* homePkg9 = nullptr;
                    if (auto sc9 = taSym.getParentScope();
                        sc9 && sc9->asSymbol().kind == SymbolKind::Package) {
                        homePkg9 = &sc9->asSymbol();
                        aliasNm = std::string(homePkg9->name) + "::" + aliasNm;
                    }
                    // Base ref scopes through the PARAM's full name
                    // (work@top.GetWhat.my_pkg::get_e — Surelog).
                    const syntax::SyntaxNode* eSyn9 = nullptr;
                    if (auto dS9 = taSym.getSyntax();
                        dS9 &&
                        dS9->kind == syntax::SyntaxKind::TypedefDeclaration)
                        eSyn9 =
                            dS9->as<syntax::TypedefDeclarationSyntax>().type;
                    auto* ecl = buildEnumTs(ct.as<EnumType>(), eSyn9,
                                            syntaxRefPrefix.empty()
                                                ? aliasNm
                                                : syntaxRefPrefix + "." +
                                                      aliasNm);
                    ecl->VpiName(aliasNm);
                    if (auto dS9 = taSym.getSyntax())
                        setLoc(ecl, dS9->sourceRange());
                    if (homePkg9)
                        if (auto pit9 = pkgDefMap.find(homePkg9);
                            pit9 != pkgDefMap.end()) {
                            // The enum clone's OWN Instance is the VALUE-ORIGIN
                            // package when the override value flows in from a
                            // different package (Surelog: pinmux
                            // TargetCfg.dio_pad_type -> PadType clone instanced
                            // at pinmux, not prim_pad_wrapper); the base actual
                            // keeps the enum's HOME package in both cases.
                            UHDM::instance* enumInst = pit9->second;
                            if (auto* origin =
                                    enumParamValueOriginPkg(ps, 0);
                                origin && origin != homePkg9)
                                if (auto oit = pkgDefMap.find(origin);
                                    oit != pkgDefMap.end())
                                    enumInst = oit->second;
                            ecl->Instance(enumInst);
                            // The base actual is REF-parented and
                            // pkg-Instanced (Surelog).
                            if (ecl->Base_typespec() &&
                                ecl->Base_typespec()->Actual_typespec()) {
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->VpiParent(ecl->Base_typespec());
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->Instance(pit9->second);
                            }
                        }
                    its = ecl;
                    sharedAggTs = true; // caller skips setLoc; parent set below
                }
            }
        }
        // A struct/union-typed param carries a FRESH aggregate typespec clone
        // (named by the typedef, located at the struct/union body), not an
        // int_typespec. Member refs scope through the calling context
        // (syntaxRefPrefix: the elab param clone uses work@top.P.<ty>.<m>).
        else if (ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::PackedUnionType ||
                 ct.kind == SymbolKind::UnpackedStructType) {
            std::string alias;
            const Symbol* aliasPkg = nullptr;
            if (auto d0 = ps.getDeclaredType())
                if (d0->getType().kind == SymbolKind::TypeAlias) {
                    alias = std::string(d0->getType().name);
                    // A PACKAGE-scoped typedef names the clone p::cfg_t and
                    // instances it at the package (Surelog).
                    for (auto sc2 = d0->getType().getParentScope(); sc2;
                         sc2 = sc2->asSymbol().getParentScope())
                        if (sc2->asSymbol().kind == SymbolKind::Package) {
                            aliasPkg = &sc2->asSymbol();
                            alias = std::string(aliasPkg->name) + "::" + alias;
                            break;
                        }
                }
            std::string memberScope = alias;
            if (!syntaxRefPrefix.empty() && !alias.empty())
                memberScope = syntaxRefPrefix + "." + alias;
            its = ct.kind == SymbolKind::PackedStructType
                      ? (UHDM::typespec*)buildStructTs(ct.as<PackedStructType>(), true,
                                                       memberScope)
                      : ct.kind == SymbolKind::UnpackedStructType
                      ? (UHDM::typespec*)buildStructTs(
                            ct.as<UnpackedStructType>(), false, memberScope)
                      : (UHDM::typespec*)buildUnionTs(ct.as<PackedUnionType>(), true,
                                                      memberScope);
            its->VpiName(alias);
            if (aliasPkg) {
                // A param-ts CLONE reaches the ELABORATED (top) home package
                // when one exists — Surelog's cross-scope instance links land
                // on the elaborated package (whose typedefs carry the FOLDED
                // member bounds), not the def-view one. Package-owned
                // typespecs keep their own view's package (set by the caller).
                UHDM::package* homePkg0 = nullptr;
                if (auto tit0 = pkgTopMap.find(aliasPkg); tit0 != pkgTopMap.end())
                    homePkg0 = tit0->second;
                else if (auto dit0 = pkgDefMap.find(aliasPkg);
                         dit0 != pkgDefMap.end())
                    homePkg0 = dit0->second;
                if (homePkg0) {
                    its->Instance(homePkg0);
                    // Fresh member-actual clones carry the package Instance
                    // too (shared package typespecs already have it).
                    if (auto* mems = ((UHDM::struct_typespec*)its)->Members())
                        for (auto* tm : *mems)
                            if (tm->Typespec() &&
                                tm->Typespec()->Actual_typespec() &&
                                !tm->Typespec()->Actual_typespec()->Instance())
                                tm->Typespec()->Actual_typespec()->Instance(
                                    homePkg0);
                }
            }
            if (auto* csyn = ct.getSyntax())
                tr = csyn->sourceRange();
        }
    }
    // An untyped param initialized with a string literal (parameter X = "FOO")
    // is a bare (unlocated) string_typespec, not an int_typespec.
    bool stringParam = false;
    if (!its && !typedParam) {
        if (auto init = ps.getInitializer();
            init && stripImplicitConv(*init).kind == ExpressionKind::StringLiteral) {
            its = s.MakeString_typespec();
            stringParam = true;
        }
    }
    UHDM::int_typespec* intTs = nullptr;
    if (!its) {
        intTs = s.MakeInt_typespec();
        // Untyped parameters carry no signedness flag — EXCEPT one written
        // with an explicit signing keyword (localparam signed Y), whose
        // int_typespec spans that keyword and does carry it (const_func).
        bool signKw9 = false;
        if (auto d9 = ps.getDeclaredType())
            if (auto t9 = d9->getTypeSyntax())
                if (t9->kind == syntax::SyntaxKind::ImplicitType)
                    signKw9 = t9->as<syntax::ImplicitTypeSyntax>()
                                  .signing.valid() &&
                              t9->as<syntax::ImplicitTypeSyntax>()
                                  .dimensions.empty();
        if (typedParam || signKw9)
            intTs->VpiSigned(sgn);
        its = intTs;
    }
    // An UNTYPED param inferred REAL keeps its real_typespec LOC-LESS
    // (realexpr p4); typed real params locate at the type token.
    bool untypedReal9 =
        !typedParam && ps.getType().getCanonicalType().isFloating();
    if (!stringParam && !sharedAggTs && !untypedReal9)
        setLoc(its, tr);
    // A ranged untyped param (parameter [0:0] X) carries the packed range on
    // its int_typespec, with located UINT bounds.
    bool explicitRange = false;
    if (!typedParam && intTs) {
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax()) {
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    auto& imp = tsyn->as<syntax::ImplicitTypeSyntax>();
                    if (!imp.dimensions.empty() &&
                        ps.getType().getCanonicalType().isPackedArray()) {
                        auto* dim = imp.dimensions[0];
                        auto crange = ps.getType().getCanonicalType().getFixedRange();
                        const syntax::ExpressionSyntax* lsyn = nullptr;
                        const syntax::ExpressionSyntax* rsyn = nullptr;
                        if (dim->specifier &&
                            dim->specifier->kind ==
                                syntax::SyntaxKind::RangeDimensionSpecifier) {
                            auto& sel = *dim->specifier
                                             ->as<syntax::RangeDimensionSpecifierSyntax>()
                                             .selector;
                            if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                                lsyn = rss->left;
                                rsyn = rss->right;
                            }
                        }
                        auto* r = s.MakeRange();
                        r->VpiParent(its);
                        setLoc(r, dim->sourceRange());
                        auto mkB = [&](int64_t v,
                                       const syntax::ExpressionSyntax* es)
                            -> UHDM::expr* {
                            // A NAMED bound ([HI:LO]) stays a symbolic ref
                            // scoped through the param (work@evil.A_VAL.HI) —
                            // Surelog keeps it in both views. Literal bounds
                            // fold to UINT constants.
                            if (es &&
                                es->kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                auto* r0 = s.MakeRef_obj();
                                std::string bn(
                                    es->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText());
                                r0->VpiName(bn);
                                if (!syntaxRefPrefix.empty())
                                    r0->VpiFullName(syntaxRefPrefix + "." + bn);
                                r0->VpiParent(r);
                                setLoc(r0, es->sourceRange());
                                return (UHDM::expr*)r0;
                            }
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(std::to_string(v));
                            c->VpiSize(64);
                            c->VpiValue("UINT:" + std::to_string(v));
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(r);
                            if (es)
                                setLoc(c, es->sourceRange());
                            return (UHDM::expr*)c;
                        };
                        r->Left_expr(mkB(crange.left, lsyn));
                        r->Right_expr(mkB(crange.right, rsyn));
                        auto* rv = s.MakeRangeVec();
                        rv->push_back(r);
                        intTs->Ranges(rv);
                        explicitRange = true;
                    }
                }
            }
        }
    }
    // Untyped params with based-literal inits gain a bare [w-1:0] range
    // (loc-less, value-only INT constants).
    if (!typedParam && !explicitRange) {
        if (auto init = ps.getInitializer()) {
            auto& lit = stripImplicitConv(*init);
            if (lit.kind == ExpressionKind::IntegerLiteral &&
                rawText(lit.sourceRange).find('\'') != std::string::npos) {
                auto* r = s.MakeRange();
                r->VpiParent(its);
                auto mkBound = [&](int64_t v) {
                    auto* c = s.MakeConstant();
                    c->VpiValue("INT:" + std::to_string(v));
                    // Write-phase (instance) param ts bounds are parented.
                    if (parentBounds)
                        c->VpiParent(r);
                    return c;
                };
                r->Left_expr(mkBound((int64_t)lit.type->getBitWidth() - 1));
                r->Right_expr(mkBound(0));
                auto* rv = s.MakeRangeVec();
                rv->push_back(r);
                if (intTs)
                    intTs->Ranges(rv);
            }
        }
    }
    return its;
}

// A LOC-LESS bare logic_typespec clone of a vector param's packed range;
// bound constants carry ONLY the UINT value (parented at the range when
// parentBounds).
UHDM::typespec* UhdmExporter::makeBareVecParamTs(const ParameterSymbol& ps,
                                                 bool parentBounds) {
    auto& ct = ps.getType().getCanonicalType();
    if (!ct.isPackedArray())
        return nullptr;
    auto& pat = ct.as<PackedArrayType>();
    auto* lts = s.MakeLogic_typespec();
    auto* r = s.MakeRange();
    r->VpiParent(lts);
    auto mk = [&](int64_t v) {
        auto* c = s.MakeConstant();
        c->VpiValue("UINT:" + std::to_string(v));
        if (parentBounds)
            c->VpiParent(r);
        return c;
    };
    r->Left_expr(mk(pat.range.left));
    r->Right_expr(mk(pat.range.right));
    auto* rv = s.MakeRangeVec();
    rv->push_back(r);
    lts->Ranges(rv);
    return lts;
}

// The instance body a symbol is declared in (nullptr for package/$unit
// params); generate blocks resolve to their enclosing instance.
static const InstanceBodySymbol* paramOwnerBody(const Symbol& sym) {
    for (auto* sc = sym.getParentScope(); sc;) {
        auto& ss = sc->asSymbol();
        if (ss.kind == SymbolKind::InstanceBody)
            return &ss.as<InstanceBodySymbol>();
        sc = ss.getParentScope();
    }
    return nullptr;
}

// Surelog builds an aggregate param's ELAB pattern-op typespec clone while it
// ELABORATES the param assign — before the instance's own net/port typespecs
// are written. Minting it here (right after the instance's params are emitted)
// puts it in that arena slot; patchParamTypespecs then reuses the clone.
void UhdmExporter::mintParamOpClones(size_t lo, size_t hi) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        auto& pct = ps->getType().getCanonicalType();
        if (pct.kind != SymbolKind::PackedStructType &&
            pct.kind != SymbolKind::PackedUnionType)
            continue;
        if (!rhsRt || !rhsRt->VpiParent() ||
            rhsRt->VpiParent()->UhdmType() != UHDM::uhdmoperation)
            continue;
        if (paramOpClones.count(rhsRt))
            continue;
        std::string savedPfx = syntaxRefPrefix;
        std::string full(prt->VpiFullName());
        auto dot = full.rfind('.');
        syntaxRefPrefix = dot == std::string::npos ? full : full.substr(0, dot);
        structCloneMemberRefParent = true;
        auto* opClone = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
        structCloneMemberRefParent = false;
        rhsRt->Actual_typespec(opClone);
        opClone->VpiParent(rhsRt);
        if (rhsRt->VpiFullName().empty())
            rhsRt->VpiFullName(syntaxRefPrefix);
        syntaxRefPrefix = savedPfx;
        paramOpClones[rhsRt] = opClone;
    }
}

void UhdmExporter::patchParamTypespecs(size_t lo, size_t hi,
                                       const InstanceBodySymbol* ownBody,
                                       bool descendants) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        if (ownBody) {
            // Package/$unit params ride with the instance that pulled them in.
            auto* ob = paramOwnerBody(*ps);
            bool own = !ob || ob == ownBody;
            if (own == descendants)
                continue;
        }
        // The ELAB param ts is a FRESH clone (Surelog: parented at the elab
        // ref below; struct/union clones also carry vpiInstance -> the module).
        // A struct-pattern param's ELAB OP ts (rhsRt on an operation) binds its
        // OWN module-scoped clone (created FIRST — Surelog tail order), with
        // member leaf ts parented at the member refs.
        std::string savedPfx2 = syntaxRefPrefix;
        bool aggParam = ps->getType().getCanonicalType().kind ==
                            SymbolKind::PackedStructType ||
                        ps->getType().getCanonicalType().kind ==
                            SymbolKind::PackedUnionType;
        UHDM::typespec* opClone = nullptr;
        if (auto oit = paramOpClones.find(rhsRt);
            rhsRt && oit != paramOpClones.end())
            opClone = oit->second; // minted at elaboration (mintParamOpClones)
        else if (aggParam && rhsRt && rhsRt->VpiParent() &&
                 rhsRt->VpiParent()->UhdmType() == UHDM::uhdmoperation) {
            std::string full(prt->VpiFullName());
            auto dot = full.rfind('.');
            syntaxRefPrefix = dot == std::string::npos ? full : full.substr(0, dot);
            structCloneMemberRefParent = true;
            opClone = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
            structCloneMemberRefParent = false;
            rhsRt->Actual_typespec(opClone);
            opClone->VpiParent(rhsRt);
            if (rhsRt->VpiFullName().empty())
                rhsRt->VpiFullName(syntaxRefPrefix);
        }
        // A param typed by a PACKAGE typedef shares the pkg's TOP typespec
        // (no clone); module-local aggregate typedefs get the fresh clone C.
        UHDM::typespec* its = nullptr;
        bool sharedPkgTs = false;
        // An ALIAS-OF-ALIAS vector typedef param (typedef int8_t char_t)
        // binds the SHARED module typedef ts in the elab view too; Surelog's
        // param-scoped clones stay orphaned (typedef_param ch).
        if (ps->getDeclaredType()) {
            auto& dtA = ps->getDeclaredType()->getType();
            if (dtA.kind == SymbolKind::TypeAlias &&
                dtA.getCanonicalType().kind == SymbolKind::PackedArrayType &&
                dtA.getCanonicalType().isIntegral() &&
                dtA.as<TypeAliasType>().targetType.getType().kind ==
                    SymbolKind::TypeAlias)
                if (auto titA = typedefTs.find(&dtA); titA != typedefTs.end()) {
                    its = titA->second;
                    sharedPkgTs = true; // shared: keeps its own parent
                }
        }
        if (aggParam) {
            if (auto d0 = ps->getDeclaredType()) {
                auto& dt0 = d0->getType();
                if (dt0.kind == SymbolKind::TypeAlias) {
                    auto& taSym = dt0.as<TypeAliasType>();
                    // Only QUALIFIED (pkg::T) params share; a wildcard-
                    // imported BARE name gets the fresh clone (Surelog).
                    bool qualified0 = false;
                    if (auto* tsyn0 = d0->getTypeSyntax();
                        tsyn0 && tsyn0->kind == syntax::SyntaxKind::NamedType)
                        qualified0 =
                            tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                            syntax::SyntaxKind::ScopedName;
                    // An INTERFACE instance's aggregate parameter never shares
                    // the package typespec: Surelog clones the whole struct
                    // family per interface VIEW (iface_cfg_mem).
                    bool ifaceOwner0 = false;
                    if (auto* ob0 = paramOwnerBody(*ps))
                        ifaceOwner0 = ob0->getDefinition().definitionKind ==
                                      DefinitionKind::Interface;
                    if (auto sc = taSym.getParentScope();
                        qualified0 && !ifaceOwner0 && sc &&
                        sc->asSymbol().kind == SymbolKind::Package) {
                        if (auto tit = pkgTopTypedefTs.find(&taSym);
                            tit != pkgTopTypedefTs.end()) {
                            its = tit->second;
                            sharedPkgTs = true;
                        }
                    }
                }
            }
        }
        if (!its) {
            syntaxRefPrefix = std::string(prt->VpiFullName());
            if (aggParam)
                structCloneMemberRefParent = true;
            its = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
            structCloneMemberRefParent = false;
            if (aggParam)
                attachFoldedBoundMeta(its, (UHDM::instance*)its->Instance());
            if (its->UhdmType() == UHDM::uhdmstruct_typespec ||
                its->UhdmType() == UHDM::uhdmunion_typespec) {
                // A $UNIT-level struct typedef clone is Instanced at the
                // DESIGN (struct_param_dim test_struct_t), not the module.
                bool unitTd9 = false;
                // A PACKAGE-scoped struct/union typedef clone stays Instanced
                // at its home PACKAGE (makeParamTs' aliasPkg link), even when
                // used as a module param's type — Surelog keeps the pkg
                // instance in both views (5-level-hierarchy family). Only
                // MODULE-LOCAL typedef clones (no package/unit home) take the
                // instantiating module instance. unitTd9 keys on the
                // IMMEDIATE typedef scope; pkgTd9 on ANY package ancestor.
                bool pkgTd9 = false;
                if (ps->getDeclaredType()) {
                    auto& dtT9 = ps->getDeclaredType()->getType();
                    if (dtT9.kind == SymbolKind::TypeAlias) {
                        auto& taT9 = dtT9.as<TypeAliasType>();
                        if (auto* isc9 = taT9.getParentScope())
                            unitTd9 = isc9->asSymbol().kind ==
                                      SymbolKind::CompilationUnit;
                        for (auto* scT9 = taT9.getParentScope(); scT9;
                             scT9 = scT9->asSymbol().getParentScope())
                            if (scT9->asSymbol().kind == SymbolKind::Package) {
                                pkgTd9 = true;
                                break;
                            }
                    }
                }
                if (unitTd9)
                    its->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                else if (!pkgTd9 || !its->Instance())
                    if (auto* par = up->VpiParent())
                        its->Instance((UHDM::instance*)par);
            }
            // A fresh ELAB enum clone of a MODULE-scoped named enum typedef
            // (localparam enum_e P) carries vpiInstance = this module instance,
            // like the struct/union clones above (Surelog). Package-scoped
            // params are Instanced at their package below.
            if (its->UhdmType() == UHDM::uhdmenum_typespec && !its->Instance() &&
                ps->getParentScope() &&
                ps->getParentScope()->asSymbol().kind != SymbolKind::Package)
                if (auto* par = up->VpiParent())
                    its->Instance((UHDM::instance*)par);
            // An imported param's typespec is INSTANCED at its package — but
            // NOT a plain UNTYPED (implicit) integral import, whose int_typespec
            // stays Instance-less in both views (Surelog; fail_detect_width).
            bool implicitImport9 =
                !typedParam && ps->getDeclaredType() &&
                ps->getDeclaredType()->getTypeSyntax() &&
                ps->getDeclaredType()->getTypeSyntax()->kind ==
                    syntax::SyntaxKind::ImplicitType;
            if (!implicitImport9 && ps->getParentScope() &&
                ps->getParentScope()->asSymbol().kind == SymbolKind::Package)
                if (auto pit = pkgDefMap.find(&ps->getParentScope()->asSymbol());
                    pit != pkgDefMap.end())
                    its->Instance((UHDM::instance*)pit->second);
        }
        syntaxRefPrefix = savedPfx2;
        if (rhsRt && !opClone) {
            // The ELAB UINT-recomputed fold ('1 -> all-ones) of a VECTOR
            // param binds a fresh LOC-LESS bare clone (unparented bounds,
            // no clone parent); BIN-valued folds keep the located ts.
            auto* rc0 = rhsRt->VpiParent();
            bool uintFold = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                            ((UHDM::constant*)rc0)->VpiValue().rfind("UINT:", 0) == 0;
            // A DEGENERATE unbased fill's BIN constant only takes the LOC-LESS
            // bare ts when it was actually SHARED into a reading cont-assign
            // (its parent got re-stamped to that CA). An unshared '0 (used only
            // in an override expr) keeps its LOCATED param ts.
            bool unbasedSharedActive =
                unbasedSharedPaConst.count(ps) && rc0 &&
                rc0->VpiParent() &&
                rc0->VpiParent()->UhdmType() == UHDM::uhdmcont_assign;
            // A RANGED UNTYPED param folded from a REAL literal binds a
            // fresh LOC-LESS bare logic_typespec (realexpr p1).
            bool realFold9 = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                             ((UHDM::constant*)rc0)
                                     ->VpiValue()
                                     .rfind("REAL:", 0) == 0;
            if (realFold9 && !typedParam &&
                ps->getType().getCanonicalType().isIntegral()) {
                auto* lts9 = s.MakeLogic_typespec();
                // Surelog's bare logic_typespec carries a LOC-LESS range
                // mirroring the param's packed [7:0] — loc-less bounds that
                // print only their UINT value (no size/decompile/parent).
                auto& ct9 = ps->getType().getCanonicalType();
                if (ct9.isPackedArray()) {
                    auto fr9 = ct9.getFixedRange();
                    auto* rg9 = s.MakeRange();
                    rg9->VpiParent(lts9);
                    auto mkB9 = [&](int64_t v) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        c->VpiValue("UINT:" + std::to_string(v));
                        return c;
                    };
                    rg9->Left_expr(mkB9(fr9.left));
                    rg9->Right_expr(mkB9(fr9.right));
                    auto* rv9 = s.MakeRangeVec();
                    rv9->push_back(rg9);
                    lts9->Ranges(rv9);
                }
                rhsRt->Actual_typespec(lts9);
            }
            else if ((uintFold || unbasedSharedActive) && typedParam &&
                !isOverriddenParam(*ps) &&
                ps->getType().getCanonicalType().isPackedArray()) {
                // A DEGENERATE unbased fill ('0/'x/'z, BIN) binds the SAME
                // loc-less bare vec ts as the '1 (UINT) recompute (Surelog).
                if (auto* bare = makeBareVecParamTs(*ps, /*parentBounds=*/false))
                    rhsRt->Actual_typespec(bare);
            }
            // An IMPORTED vector-typedef param's elab OPERATION Rhs ts ref
            // binds its OWN clone pair (module-prefix scoped), not the param's
            // (Surelog).
            else if ([&] {
                         if (!rc0 || rc0->UhdmType() != UHDM::uhdmoperation)
                             return false;
                         auto d0 = ps->getDeclaredType();
                         if (!d0 ||
                             d0->getType().kind != SymbolKind::TypeAlias)
                             return false;
                         auto& ct9 = ps->getType().getCanonicalType();
                         if (ct9.kind != SymbolKind::PackedArrayType ||
                             !ct9.isIntegral())
                             return false;
                         auto hs9 = d0->getType()
                                        .as<TypeAliasType>()
                                        .getParentScope();
                         return hs9 && hs9->asSymbol().kind ==
                                           SymbolKind::Package &&
                                ps->getParentScope() == hs9;
                     }()) {
                std::string full9(prt->VpiFullName());
                auto dot9 = full9.rfind('.');
                syntaxRefPrefix =
                    dot9 == std::string::npos ? full9 : full9.substr(0, dot9);
                auto* opTs9 = makeParamTs(*ps, typedParam);
                syntaxRefPrefix = savedPfx2;
                rhsRt->Actual_typespec(opTs9);
                opTs9->VpiParent(rhsRt);
            }
            // A TYPEDEF'd vector param INITIALIZED BY a module-local PARAM
            // REF (localparam int8_t int8 = int4): the elab fold's constant
            // binds a FRESH bare int_typespec (signed per the param type),
            // not the param's own typedef clone (typedef_param).
            else if ([&] {
                         if (!typedParam || !rc0 ||
                             rc0->UhdmType() != UHDM::uhdmconstant)
                             return false;
                         auto d0 = ps->getDeclaredType();
                         if (!d0 ||
                             d0->getType().kind != SymbolKind::TypeAlias)
                             return false;
                         if (!ps->getType().getCanonicalType().isPackedArray())
                             return false;
                         auto init9 = ps->getInitializer();
                         if (!init9)
                             return false;
                         auto& si9 = stripImplicitConv(*init9);
                         if (si9.kind != ExpressionKind::NamedValue)
                             return false;
                         auto& sym9 = si9.as<NamedValueExpression>().symbol;
                         return sym9.kind == SymbolKind::Parameter &&
                                sym9.getParentScope() &&
                                sym9.getParentScope()->asSymbol().kind !=
                                    SymbolKind::Package;
                     }()) {
                auto* bi9 = s.MakeInt_typespec();
                if (ps->getType().getCanonicalType().isSigned())
                    bi9->VpiSigned(true);
                rhsRt->Actual_typespec(bi9);
            }
            else
                rhsRt->Actual_typespec(its);
        }
        prt->Actual_typespec(its);
        if (!sharedPkgTs)
            its->VpiParent(prt);
        // Record this ELAB struct/union param clone so a bare-package-typedef
        // aggregate param's DEF view can SHARE it (shareDefAggParamTs), rather
        // than mint its own def-scoped clone (Surelog: one clone per param).
        if (its->UhdmType() == UHDM::uhdmstruct_typespec ||
            its->UhdmType() == UHDM::uhdmunion_typespec)
            if (auto* ob9 = paramOwnerBody(*ps))
                elabAggParamClone[{&ob9->getDefinition(),
                                   std::string(ps->name)}] = its;
        // Unbased-unsized override pa constant ts (see unbasedOvTsRef).
        if (auto uit = unbasedOvTsRef.find(ps); uit != unbasedOvTsRef.end()) {
            uit->second->Actual_typespec(its);
            unbasedOvTsRef.erase(uit);
        }
        if (auto cit = unbasedOvCloneTsRef.find(ps);
            cit != unbasedOvCloneTsRef.end()) {
            for (auto* ubRt : cit->second) {
                std::string savedPfx3 = syntaxRefPrefix;
                syntaxRefPrefix = std::string(ubRt->VpiFullName());
                auto* ubTs = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
                syntaxRefPrefix = savedPfx3;
                ubRt->Actual_typespec(ubTs);
                ubTs->VpiParent(ubRt);
            }
            unbasedOvCloneTsRef.erase(cit);
        }
        // No-default override fold-constant ts refs share this elab ts.
        if (auto nit = noDefOvTsRef.find(ps); nit != noDefOvTsRef.end()) {
            for (auto* r0 : nit->second)
                r0->Actual_typespec(its);
            noDefOvTsRef.erase(nit);
        }
        // A param used as a cast width hangs a vpiExpr ref on its def-view
        // ts; the elab ts SHARES that ref_obj.
        if (its->UhdmType() == UHDM::uhdmint_typespec) {
            if (auto psc = ps->getParentScope();
                psc && psc->asSymbol().kind == SymbolKind::InstanceBody) {
                auto dit = defMap.find(
                    &psc->asSymbol().as<InstanceBodySymbol>().getDefinition());
                if (dit != defMap.end())
                    if (auto pit = dit->second.paramTs.find(ps);
                        pit != dit->second.paramTs.end() &&
                        pit->second->UhdmType() == UHDM::uhdmint_typespec)
                        if (auto* ce =
                                ((UHDM::int_typespec*)pit->second)->Cast_to_expr())
                            ((UHDM::int_typespec*)its)->Cast_to_expr(ce);
            }
        }
        (void)up;
    }
}

// Deferred DEF-view aggregate-typedef param ts: bind the SHARED named typedef
// typespec now that emitTypedefs has populated typedefTs. The shared object
// keeps its own parent/instance. Falls back to a fresh makeParamTs when the
// typedef wasn't materialized (mirrors the non-deferred path).
void UhdmExporter::drainDefParamTs() {
    for (auto& pd : pendingDefParamTs) {
        UHDM::typespec* its = nullptr;
        bool sharedTs = false;
        bool bareAggPkgTd = false;
        if (auto d0 = pd.ps->getDeclaredType()) {
            auto& dt0 = d0->getType();
            // A VECTOR typedef (typedef logic[X-1:0] my_type_t) is CLONED with a
            // Typedef_alias in both views (like struct/union/enum params take the
            // share shortcut) — fall through to makeParamTs for the clone.
            bool vectorAlias =
                dt0.kind == SymbolKind::TypeAlias &&
                dt0.getCanonicalType().kind == SymbolKind::PackedArrayType &&
                dt0.getCanonicalType().isIntegral() &&
                // An ALIAS-OF-ALIAS (typedef int8_t char_t) SHARES the
                // typedef ts instead — Surelog builds no usable param clone
                // for it (typedef_param ch).
                dt0.as<TypeAliasType>().targetType.getType().kind !=
                    SymbolKind::TypeAlias;
            // An aggregate param typed by a PACKAGE typedef named BARE (a
            // wildcard-imported target_cfg_t / flash_req_t) gets a FRESH clone
            // in the DEF view too — exactly the qualification rule the ELAB
            // view applies (patchParamTypespecs). Only a QUALIFIED pkg::T use
            // shares the package's typespec object.
            if (!pd.inPackage && dt0.kind == SymbolKind::TypeAlias) {
                auto ck0 = dt0.getCanonicalType().kind;
                if (ck0 == SymbolKind::PackedStructType ||
                    ck0 == SymbolKind::PackedUnionType ||
                    ck0 == SymbolKind::UnpackedStructType) {
                    bool qualified0 = false;
                    if (auto* tsyn0 = d0->getTypeSyntax();
                        tsyn0 && tsyn0->kind == syntax::SyntaxKind::NamedType)
                        qualified0 =
                            tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                            syntax::SyntaxKind::ScopedName;
                    if (!qualified0)
                        if (auto* sc0 =
                                dt0.as<TypeAliasType>().getParentScope();
                            sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                            bareAggPkgTd = true;
                }
            }
            // A TOP-view package param shares its OWN view's typedef object
            // (the module-scoped clone with folded member bounds), not the
            // def-view one — Surelog's top package param_assign Lhs typespec
            // is the top typedef (TypedefStructParamWithRangeInSubmodule).
            bool topPkgView = pd.inPackage && pd.m &&
                              pd.m->UhdmType() == UHDM::uhdmpackage &&
                              ((UHDM::package*)pd.m)->VpiTop();
            if (topPkgView && !vectorAlias)
                if (auto tit0 = pkgTopTypedefTs.find((const void*)&dt0);
                    tit0 != pkgTopTypedefTs.end()) {
                    its = tit0->second;
                    sharedTs = true;
                }
            if (!its)
                if (auto tit = typedefTs.find(&dt0);
                    tit != typedefTs.end() && !vectorAlias && !bareAggPkgTd) {
                    its = tit->second;
                    sharedTs = true;
                }
        }
        if (!its) {
            std::string savedPfx2 = syntaxRefPrefix;
            const Scope* savedCS = currentScope;
            syntaxRefPrefix = pd.refFullName;
            defViewParamTs = true;
            if (!currentScope)
                currentScope = pd.ps->getParentScope();
            // A DEF-view aggregate CLONE is shaped like the elab one: member
            // leaf typespecs parent at their ref_typespec, and folded
            // package-param member bounds carry Surelog's size/typespec meta.
            auto pck0 = pd.ps->getType().getCanonicalType().kind;
            bool aggClone0 = pck0 == SymbolKind::PackedStructType ||
                             pck0 == SymbolKind::PackedUnionType ||
                             pck0 == SymbolKind::UnpackedStructType;
            if (aggClone0)
                structCloneMemberRefParent = true;
            its = makeParamTs(*pd.ps, pd.typedParam);
            structCloneMemberRefParent = false;
            if (aggClone0)
                attachFoldedBoundMeta(its, (UHDM::instance*)its->Instance());
            defViewParamTs = false;
            currentScope = savedCS;
            syntaxRefPrefix = savedPfx2;
        }
        if (pd.inPackage && !sharedTs && pd.typedParam)
            its->Instance((UHDM::instance*)pd.m);
        if (pd.di)
            pd.di->paramTs[pd.member] = its;
        if (pd.rhsRt)
            pd.rhsRt->Actual_typespec(its);
        pd.prt->Actual_typespec(its);
        if (!sharedTs && pd.typedParam)
            its->VpiParent(pd.up);
        // A bare-package-typedef aggregate param defers to SHARE its ELAB
        // clone: Surelog emits ONE struct/union clone per param (parented at
        // the elab ref, pkg-instanced) that BOTH the def and elab views use.
        // The fresh def clone minted above is a fallback for an uninstantiated
        // def; shareDefAggParamTs re-points these refs once the elab clone
        // exists (5-level-hierarchy / parameter-passed-down families).
        if (bareAggPkgTd)
            if (auto* ob = paramOwnerBody(*pd.ps))
                pendingDefAggShare.push_back({pd.prt, pd.rhsRt, pd.di,
                                              pd.member, &ob->getDefinition(),
                                              std::string(pd.ps->name)});
    }
    pendingDefParamTs.clear();
}

// Re-point deferred def-view bare-package-typedef aggregate param refs at the
// single ELAB clone Surelog shares across both views. Leaves the fresh def
// clone (now unreferenced) out of the dump; keeps it only when the def was
// never elaborated (no matching elab clone).
void UhdmExporter::shareDefAggParamTs() {
    for (auto& e : pendingDefAggShare) {
        auto it = elabAggParamClone.find({e.def, e.name});
        if (it == elabAggParamClone.end())
            continue;
        auto* elab = it->second;
        if (e.prt)
            e.prt->Actual_typespec(elab);
        if (e.rhsRt)
            e.rhsRt->Actual_typespec(elab);
        if (e.di && e.member)
            e.di->paramTs[e.member] = elab;
    }
    pendingDefAggShare.clear();
}

// A fold whose init chain (through param refs) lands on an ENUM VALUE takes
// the enum literal's source HEX form (8'hCC / HEX:CC / constType 5) — Surelog.
// Returns true when the recode applied.
bool UhdmExporter::enumOriginHexRecode(UHDM::constant* c,
                                       const Expression* init) {
    if (!init)
        return false;
    const Expression* ce = &stripImplicitConv(*init);
    const Expression* evInit = nullptr;
    for (int g = 0; ce && g < 8; g++) {
        if (ce->kind != ExpressionKind::NamedValue)
            break;
        auto& sym2 = ce->as<NamedValueExpression>().symbol;
        if (sym2.kind == SymbolKind::EnumValue) {
            evInit = sym2.as<EnumValueSymbol>().getInitializer();
            break;
        }
        if (sym2.kind != SymbolKind::Parameter)
            break;
        auto* ini2 = sym2.as<ParameterSymbol>().getInitializer();
        ce = ini2 ? &stripImplicitConv(*ini2) : nullptr;
    }
    if (!evInit)
        return false;
    std::string lit = rawText(stripImplicitConv(*evInit).sourceRange);
    while (!lit.empty() && (unsigned char)lit.back() <= ' ')
        lit.pop_back();
    while (!lit.empty() && (unsigned char)lit.front() <= ' ')
        lit.erase(lit.begin());
    auto hp = lit.find("'h");
    if (hp == std::string::npos)
        hp = lit.find("'H");
    if (hp == std::string::npos)
        return false;
    std::string digits = lit.substr(hp + 2);
    for (auto& ch : digits)
        ch = (char)toupper((unsigned char)ch);
    c->VpiValue("HEX:" + digits);
    c->VpiConstType(vpiHexConst);
    c->VpiDecompile(lit);
    return true;
}

void UhdmExporter::analyzeParamEnc(const InstanceBodySymbol& body) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        if (auto init = ps.getInitializer()) {
            if (init->kind != ExpressionKind::IntegerLiteral && isIntEncoded(*init))
                paramIntEnc[&member] = true;
            // A subtract init (localparam W = X-1) is signed arithmetic, so a
            // bare reference to W as a range bound folds to a signed INT
            // constant — mirroring the direct-subtract-bound rule.
            else if (auto& si = stripImplicitConv(*init);
                     si.kind == ExpressionKind::BinaryOp &&
                     si.as<BinaryExpression>().op == BinaryOperator::Subtract)
                paramIntEnc[&member] = true;
        }
    }
}

// After the def/top member cross-wire swap, each swapped-in FOLDED member
// packed_array_typespec bound that came from a package-param identifier
// ([K:0]) gets Surelog's metadata: vpiSize:32 + a vpiTypespec ref to a
// FRESH int_typespec (the source param's type, instance-less). The ref
// fullname copies the member's typespec fullname (rewritten to work@<mod>
// form later, in the module typedef-listing pass).
void UhdmExporter::attachFoldedBoundMeta(UHDM::typespec* container,
                                         UHDM::instance* pkgInst) {
    UHDM::VectorOftypespec_member* mems = nullptr;
    if (container->UhdmType() == UHDM::uhdmstruct_typespec)
        mems = ((UHDM::struct_typespec*)container)->Members();
    else if (container->UhdmType() == UHDM::uhdmunion_typespec)
        mems = ((UHDM::union_typespec*)container)->Members();
    if (!mems)
        return;
    for (auto* tmM : *mems) {
        if (!tmM->Typespec())
            continue;
        auto* mAct = tmM->Typespec()->Actual_typespec();
        if (!mAct || mAct->UhdmType() != UHDM::uhdmpacked_array_typespec)
            continue;
        auto* pats = (UHDM::packed_array_typespec*)mAct;
        if (!pats->Ranges())
            continue;
        std::string memFN(tmM->Typespec()->VpiFullName());
        for (auto* rg : *pats->Ranges())
            for (UHDM::expr* be : {rg->Left_expr(), rg->Right_expr()}) {
                if (!be || be->UhdmType() != UHDM::uhdmconstant)
                    continue;
                auto* c = (UHDM::constant*)be;
                auto fit = foldedMemberBoundParam.find(c);
                if (fit == foldedMemberBoundParam.end())
                    continue;
                const Symbol* psym = fit->second;
                c->VpiSize(32);
                auto* its2 = s.MakeInt_typespec();
                if (psym->kind == SymbolKind::Parameter) {
                    auto& psp = psym->as<ParameterSymbol>();
                    bool implicitSrc = false;
                    if (auto dt0 = psp.getDeclaredType())
                        if (auto* ts0 = dt0->getTypeSyntax())
                            implicitSrc =
                                ts0->kind == syntax::SyntaxKind::ImplicitType;
                    // An UNTYPED source param leaves this synthesized ts
                    // UNSIGNED (Surelog), even though its value type is int.
                    if (!implicitSrc && psp.getType().getCanonicalType().isSigned())
                        its2->VpiSigned(true);
                    if (auto dt = psp.getDeclaredType())
                        if (auto* tsyn = dt->getTypeSyntax()) {
                            // An UNTYPED source param (parameter K = 8)
                            // spans its whole DECLARATION, like every
                            // other untyped param int_typespec (Surelog).
                            if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                                for (auto q = psp.getSyntax(); q; q = q->parent)
                                    if (q->kind ==
                                        syntax::SyntaxKind::ParameterDeclaration) {
                                        setLoc(its2, q->sourceRange());
                                        break;
                                    }
                            }
                            else
                                setLoc(its2, tsyn->sourceRange());
                        }
                    // vpiInstance follows the source param's TYPING: a TYPED
                    // one (parameter int K) carries the package; an UNTYPED
                    // one stays instance-less — the same typed/untyped split
                    // the param's own int_typespec follows (Surelog).
                    if (!implicitSrc)
                        its2->Instance(pkgInst);
                }
                auto* rt2 = s.MakeRef_typespec();
                rt2->VpiParent(c);
                rt2->VpiFullName(memFN);
                rt2->Actual_typespec(its2);
                its2->VpiParent(rt2);
                c->Typespec(rt2);
            }
    }
}

UHDM::package* UhdmExporter::emitPackage(const PackageSymbol& pkg, bool topView) {
    std::string prefix = std::string(pkg.name) + "::";
    auto* up = s.MakePackage();
    if (!topView)
        pkgDefMap[&pkg] = up;
    else
        pkgTopMap[&pkg] = up;
    up->VpiName(pkg.name);
    up->VpiFullName(prefix);
    up->VpiDefName(pkg.name);
    up->VpiParent(d);
    up->VpiFile(fullFilePath(pkg.location));
    if (topView)
        up->VpiTop(true);
    if (auto syn = pkg.getSyntax()) {
        setLoc(up, syn->sourceRange());
        // endpackage : name -> vpiEndLabel.
        if (syntax::ModuleDeclarationSyntax::isKind(syn->kind))
            if (auto* bn = syn->as<syntax::ModuleDeclarationSyntax>().blockName)
                up->VpiEndLabel(bn->name.valueText());
    }
    NetMap none;
    // Package-scope cast typespecs (size-literal integer_typespecs) carry
    // vpiInstance = the package (Surelog); expose it during param emission.
    auto* savedPkgInst0 = pkgScopeInst;
    pkgScopeInst = (UHDM::instance*)up;
    emitParameters(pkg, up, prefix, none, topView, nullptr, true);
    pkgScopeInst = savedPkgInst0;
    // Package typedefs: struct/enum/vector typespecs named pkg::T, parented and
    // instanced at the package, populating typedefTs so package-typedef'd
    // signals/params resolve.
    auto* tds = s.MakeTypespecVec();
    pkgTopEmit = topView; // enum-const decompile is view-dependent (buildEnumTs)
    inPkgTypedefEmit = true;
    // Package typedefs are CREATED in source order (so intra-package
    // references resolve via typedefTs) but LISTED name-sorted (Surelog).
    std::vector<const Symbol*> pkgAliases;
    for (auto& member : pkg.members())
        if (member.kind == SymbolKind::TypeAlias)
            pkgAliases.push_back(&member);
    std::vector<std::pair<std::string, UHDM::typespec*>> pkgTdByName;
    // A package IMPORTING another package lists the imported ENUM typedefs
    // as ONE shared clone per typedef (created on first sight; module import
    // listings share it) plus an import_typespec per import item (after the
    // sorted typedefs).
    std::vector<UHDM::typespec*> importTss;
    if (true) {
        for (auto& mem : pkg.members()) {
            std::string_view pn;
            if (mem.kind == SymbolKind::WildcardImport)
                pn = mem.as<WildcardImportSymbol>().packageName;
            else if (mem.kind == SymbolKind::ExplicitImport)
                pn = mem.as<ExplicitImportSymbol>().packageName;
            else
                continue;
            if (auto* spkg = comp.getPackage(pn)) {
                for (auto& pm : spkg->members()) {
                    if (pm.kind != SymbolKind::TypeAlias)
                        continue;
                    auto& ta2 = pm.as<TypeAliasType>();
                    auto& ct2 = ta2.getCanonicalType();
                    if (ct2.kind != SymbolKind::EnumType &&
                        ct2.kind != SymbolKind::PackedStructType)
                        continue;
                    // ONE clone per imported typedef, shared by every module
                    // import listing (direct and transitive) — created here
                    // (the home pkg emitted earlier in source order).
                    UHDM::enum_typespec* cl2 = nullptr;
                    if (auto cit2 = pkgImportCloneTs.find(&pm);
                        cit2 != pkgImportCloneTs.end())
                        cl2 = (UHDM::enum_typespec*)cit2->second;
                    else {
                        const syntax::SyntaxNode* dSyn2 = ta2.getSyntax();
                        const syntax::SyntaxNode* tSyn2 = nullptr;
                        if (dSyn2 && dSyn2->kind ==
                                         syntax::SyntaxKind::TypedefDeclaration)
                            tSyn2 = dSyn2->as<syntax::TypedefDeclarationSyntax>()
                                        .type;
                        std::string nm2 =
                            std::string(pn) + "::" + std::string(ta2.name);
                        if (ct2.kind == SymbolKind::PackedStructType) {
                            auto* scl = buildStructTs(
                                ct2.as<PackedStructType>(), true, nm2, "::");
                            scl->VpiName(nm2);
                            if (tSyn2)
                                setLoc(scl, tSyn2->sourceRange());
                            scl->Instance((UHDM::instance*)up);
                            // The clone's MEMBER typespecs stay instanced at
                            // the struct's HOME package (Surelog) — only the
                            // clone itself moves to the importing package.
                            if (auto hip3 = pkgDefMap.find(&spkg->asSymbol());
                                hip3 != pkgDefMap.end()) {
                                std::function<void(UHDM::typespec*)> stampHome =
                                    [&](UHDM::typespec* t3) {
                                        if (!t3 ||
                                            t3->UhdmType() !=
                                                UHDM::uhdmstruct_typespec)
                                            return;
                                        auto* ms3 =
                                            ((UHDM::struct_typespec*)t3)
                                                ->Members();
                                        if (!ms3)
                                            return;
                                        for (auto* tm3 : *ms3) {
                                            if (!tm3->Typespec())
                                                continue;
                                            auto* at3 =
                                                tm3->Typespec()
                                                    ->Actual_typespec();
                                            if (!at3)
                                                continue;
                                            if (at3->Instance())
                                                at3->Instance(hip3->second);
                                            stampHome(at3);
                                        }
                                    };
                                stampHome(scl);
                            }
                            pkgImportCloneTs[&pm] = scl;
                            pkgTdByName.emplace_back(std::string(ta2.name),
                                                     (UHDM::typespec*)scl);
                            continue;
                        }
                        auto* ecl = buildEnumTs(ct2.as<EnumType>(), tSyn2, nm2);
                        ecl->VpiName(nm2);
                        if (dSyn2)
                            setLoc(ecl, dSyn2->sourceRange());
                        ecl->Instance((UHDM::instance*)up);
                        if (ecl->Base_typespec() &&
                            ecl->Base_typespec()->Actual_typespec())
                            if (auto hip2 = pkgDefMap.find(&spkg->asSymbol());
                                hip2 != pkgDefMap.end())
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->Instance(hip2->second);
                        pkgImportCloneTs[&pm] = ecl;
                        cl2 = ecl;
                    }
                    pkgTdByName.emplace_back(std::string(ta2.name),
                                             (UHDM::typespec*)cl2);
                }
            }
            auto* its2 = s.MakeImport_typespec();
            its2->VpiName(std::string(pn));
            its2->Instance((UHDM::instance*)up);
            if (auto msyn = mem.getSyntax())
                setLoc(its2, msyn->sourceRange());
            // Hidden item constant: "*" (loc-less) or the imported name (at
            // its token). Dump-invisible but uhdm-cmp checked.
            {
                std::string itemName = "*";
                auto* c = s.MakeConstant();
                if (mem.kind == SymbolKind::ExplicitImport) {
                    itemName =
                        std::string(mem.as<ExplicitImportSymbol>().importName);
                    setLoc(c, SourceRange(mem.location,
                                          mem.location + itemName.size()));
                }
                c->VpiDecompile(itemName);
                c->VpiSize((int32_t)itemName.size() * 8);
                c->VpiValue("STRING:" + itemName);
                c->VpiConstType(8); // Surelog's string-const encoding here
                its2->Item(c);
            }
            importTss.push_back(its2);
            // An EXPLICITLY imported SUBROUTINE (import pkg::f) re-emits in
            // this package's scope (prefix-renamed) sharing the HOME
            // function's Return var; calls keep binding the home object.
            if (mem.kind == SymbolKind::ExplicitImport)
                if (auto* is9 = mem.as<ExplicitImportSymbol>().importedSymbol();
                    is9 && is9->kind == SymbolKind::Subroutine &&
                    comp.getPackage(pn)) {
                    UHDM::task_func* homeTf = nullptr;
                    SubInfo homeSi;
                    bool hadHome = false;
                    if (auto sit9 = subMap.find(is9); sit9 != subMap.end()) {
                        homeSi = sit9->second;
                        homeTf = homeSi.tf;
                        hadHome = true;
                    }
                    // The clone's typespecs keep vpiInstance = the HOME
                    // package (where the function is defined), not this
                    // importing package.
                    UHDM::instance* homeInst = nullptr;
                    if (homeTf && homeTf->Instance())
                        homeInst = (UHDM::instance*)homeTf->Instance();
                    else if (auto hip9 =
                                 pkgDefMap.find(&comp.getPackage(pn)->asSymbol());
                             hip9 != pkgDefMap.end())
                        homeInst = (UHDM::instance*)hip9->second;
                    importCopyTsInst = homeInst;
                    std::vector<UHDM::typespec*> copyTss;
                    importCopyTsCollect = &copyTss;
                    emitTaskFuncs(*comp.getPackage(pn), up, prefix, nullptr,
                                  /*sharedScope=*/false, is9);
                    importCopyTsCollect = nullptr;
                    importCopyTsInst = nullptr;
                    // The clone's own typespecs keep vpiInstance = the
                    // ELABORATED (top) home package, resolved after both
                    // package views are built.
                    for (auto* cts : copyTss)
                        importCopyTsFixups.emplace_back(cts, std::string(pn));
                    if (homeTf && up->Task_funcs() &&
                        !up->Task_funcs()->empty()) {
                        auto* cp9 = up->Task_funcs()->back();
                        if (cp9->UhdmType() == UHDM::uhdmfunction &&
                            homeTf->UhdmType() == UHDM::uhdmfunction) {
                            ((UHDM::function*)cp9)
                                ->Return(((UHDM::function*)homeTf)->Return());
                            // A P::f() call through this importing package binds
                            // the ELABORATED clone (top view).
                            if (topView)
                                importCopyFunc[{&pkg, is9}] =
                                    (UHDM::function*)cp9;
                        }
                    }
                    if (hadHome)
                        subMap[is9] = homeSi; // calls bind the home object
                }
        }
    }
    for (auto* memberP : pkgAliases) {
        auto& member = *memberP;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        UHDM::typespec* ts = nullptr;
        // A packed-array-of-AGGREGATE typedef (typedef a[1:0] b, a = struct):
        // a packed_array_typespec with a Typedef_alias (bare clone), the [1:0]
        // Range (UINT bounds), and an Elem ref -> the SHARED element typedef
        // ts — all refs doubled-scoped pkg::pkg::b (Surelog).
        bool aggArray = false;
        if (ct.kind == SymbolKind::PackedArrayType) {
            const Type* el0 = &ct;
            while (el0->getCanonicalType().kind == SymbolKind::PackedArrayType)
                el0 = &el0->getCanonicalType().as<PackedArrayType>().elementType;
            auto& elc = el0->getCanonicalType();
            aggArray = elc.isStruct() || elc.isUnion();
        }
        if (aggArray) {
            // Listed in the TOP package view only (Surelog).
            if (!topView)
                continue;
            auto& pat = ct.as<PackedArrayType>();
            std::string dblName = prefix + prefix + std::string(ta.name);
            auto* outer = s.MakePacked_array_typespec();
            outer->VpiParent(up);
            if (typeSyn)
                setLoc(outer, typeSyn->sourceRange());
            auto* cl = s.MakePacked_array_typespec();
            // The alias-actual clone is LOCATED at the typedef type span,
            // pkg-Instanced, and carries the dim range with token-anchored
            // bounds (Surelog).
            if (typeSyn) {
                setLoc(cl, typeSyn->sourceRange());
                cl->Instance((UHDM::instance*)up);
                std::vector<DimSpan> clSp9;
                {
                    auto full9 = typeSyn->sourceRange();
                    clSp9 = scanDimSpans(std::string(rawText(full9)),
                                         full9.start());
                }
                auto* clr9 = s.MakeRange();
                clr9->VpiParent(cl);
                const DimSpan* cds9 = clSp9.empty() ? nullptr : &clSp9[0];
                if (cds9)
                    setLoc(clr9, cds9->range);
                auto mkB9c = [&](int64_t v9,
                                 const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(clr9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                clr9->Left_expr(
                    mkB9c(pat.range.left, cds9 ? &cds9->left : nullptr));
                clr9->Right_expr(
                    mkB9c(pat.range.right, cds9 ? &cds9->right : nullptr));
                auto* clrv9 = s.MakeRangeVec();
                clrv9->push_back(clr9);
                cl->Ranges(clrv9);
            }
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(dblName);
            art->VpiParent(outer);
            art->Actual_typespec(cl);
            outer->Typedef_alias(art);
            auto* rvec = s.MakeRangeVec();
            auto* r = s.MakeRange();
            r->VpiParent(outer);
            auto mkB2 = [&](int64_t v) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string d = std::to_string(v);
                c->VpiDecompile(d);
                c->VpiSize(64);
                c->VpiValue("UINT:" + d);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                return c;
            };
            r->Left_expr(mkB2(pat.range.left));
            r->Right_expr(mkB2(pat.range.right));
            rvec->push_back(r);
            outer->Ranges(rvec);
            // Element ref -> the shared element typedef ts (by alias Type, or
            // canonical match).
            const Type* elAl = &pat.elementType;
            UHDM::typespec* ets2 = nullptr;
            if (auto tit = typedefTs.find(elAl); tit != typedefTs.end())
                ets2 = tit->second;
            else
                for (auto& [sym0, tsp0] : typedefTs)
                    if (sym0->kind == SymbolKind::TypeAlias &&
                        &((const Type*)sym0)->getCanonicalType() ==
                            &elAl->getCanonicalType()) {
                        ets2 = tsp0;
                        break;
                    }
            if (ets2) {
                // The alias-actual TWIN also carries a NAMELESS Elem ref to
                // the same shared element ts (Surelog).
                auto* certn = s.MakeRef_typespec();
                certn->VpiParent(cl);
                certn->Actual_typespec(ets2);
                cl->Elem_typespec(certn);
                auto* ert = s.MakeRef_typespec();
                ert->VpiFullName(dblName);
                ert->VpiParent(outer);
                ert->Actual_typespec(ets2);
                outer->Elem_typespec(ert);
            }
            ts = outer;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType &&
                 (ct.as<FixedSizeUnpackedArrayType>()
                          .elementType.getCanonicalType()
                          .isStruct() ||
                  ct.as<FixedSizeUnpackedArrayType>()
                          .elementType.getCanonicalType()
                          .isUnion())) {
            // typedef of an UNPACKED array of a struct/union typedef
            // (typedef a b[1:0]): a NAMED array_typespec (pkg::b, pkg-parented
            // and -Instanced, listed in the TOP package view only). Its Elem
            // ref (doubled name pkg::pkg::b) binds a fresh NAMED struct clone
            // of the element typedef (pkg::a) with a Typedef_alias -> the
            // shared element ts — mirrors the module emitTypedefs arm.
            if (!topView)
                continue;
            auto& fua = ct.as<FixedSizeUnpackedArrayType>();
            auto* ats = s.MakeArray_typespec();
            ats->VpiParent(up);
            ats->Instance((UHDM::instance*)up);
            SourceLocation aS = ta.location, aE = ta.location;
            if (typeSyn)
                aS = typeSyn->sourceRange().start();
            const syntax::VariableDimensionSyntax* dimSyn = nullptr;
            if (auto dsyn = ta.getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                auto& td = dsyn->as<syntax::TypedefDeclarationSyntax>();
                if (!td.dimensions.empty()) {
                    dimSyn = td.dimensions[0];
                    aE = td.dimensions[td.dimensions.size() - 1]
                             ->sourceRange()
                             .end();
                }
            }
            setLoc(ats, SourceRange(aS, aE));
            auto* rv = s.MakeRangeVec();
            auto* r = s.MakeRange();
            r->VpiParent(ats);
            const syntax::ExpressionSyntax* lSyn = nullptr;
            const syntax::ExpressionSyntax* rSyn = nullptr;
            const syntax::ExpressionSyntax* szSyn = nullptr;
            if (dimSyn && dimSyn->specifier &&
                dimSyn->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel = *dimSyn->specifier
                                 ->as<syntax::RangeDimensionSpecifierSyntax>()
                                 .selector;
                if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                    lSyn = rss->left;
                    rSyn = rss->right;
                }
                else if (auto* bss = sel.as_if<syntax::BitSelectSyntax>())
                    szSyn = bss->expr;
            }
            auto mkB = [&](int64_t v,
                           const syntax::SyntaxNode* bs) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string digits = std::to_string(v);
                c->VpiDecompile(digits);
                c->VpiSize(64);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                if (bs)
                    setLoc(c, bs->sourceRange());
                return c;
            };
            if (szSyn) {
                setLoc(r, szSyn->sourceRange());
                r->Left_expr(mkB(0, nullptr));
                auto* op = s.MakeOperation();
                op->VpiOpType(vpiSubOp);
                op->VpiParent(r);
                setLoc(op, szSyn->sourceRange());
                auto* ops = s.MakeAnyVec();
                auto* nC = mkB(fua.range.width(), szSyn);
                nC->VpiParent(op);
                ops->push_back(nC);
                auto* one = s.MakeConstant();
                one->VpiSize(64);
                one->VpiValue("INT:1");
                one->VpiConstType(vpiIntConst);
                one->VpiParent(op);
                ops->push_back(one);
                op->Operands(ops);
                r->Right_expr(op);
            }
            else {
                if (dimSyn)
                    setLoc(r, dimSyn->sourceRange());
                r->Left_expr(mkB(fua.range.left, lSyn));
                r->Right_expr(mkB(fua.range.right, rSyn));
            }
            rv->push_back(r);
            ats->Ranges(rv);
            const Type* el0 = &fua.elementType;
            UHDM::typespec* ets0 = nullptr;
            if (auto ei = typedefTs.find(el0); ei != typedefTs.end())
                ets0 = ei->second;
            else
                for (auto& [sym0, tsp0] : typedefTs)
                    if (sym0->kind == SymbolKind::TypeAlias &&
                        &((const Type*)sym0)->getCanonicalType() ==
                            &el0->getCanonicalType()) {
                        ets0 = tsp0;
                        break;
                    }
            if (ets0) {
                UHDM::typespec* tgt0 = ets0;
                if (el0->kind == SymbolKind::TypeAlias &&
                    ets0->UhdmType() == UHDM::uhdmstruct_typespec) {
                    auto& ela = el0->as<TypeAliasType>();
                    auto& elc = el0->getCanonicalType();
                    std::string clName = prefix + std::string(ela.name);
                    UHDM::struct_typespec* cl0 =
                        elc.kind == SymbolKind::PackedStructType
                            ? buildStructTs(elc.as<PackedStructType>(), true,
                                            clName)
                            : buildStructTs(elc.as<UnpackedStructType>(), false,
                                            clName);
                    cl0->VpiName(clName);
                    cl0->VpiLineNo(ets0->VpiLineNo());
                    cl0->VpiColumnNo(ets0->VpiColumnNo());
                    cl0->VpiEndLineNo(ets0->VpiEndLineNo());
                    cl0->VpiEndColumnNo(ets0->VpiEndColumnNo());
                    cl0->Instance((UHDM::instance*)up);
                    if (auto* mems = cl0->Members())
                        for (auto* tm : *mems)
                            if (tm->Typespec() &&
                                tm->Typespec()->Actual_typespec())
                                tm->Typespec()->Actual_typespec()->Instance(
                                    (UHDM::instance*)up);
                    auto* art0 = s.MakeRef_typespec();
                    art0->VpiFullName(clName);
                    art0->VpiParent(cl0);
                    art0->Actual_typespec(ets0);
                    cl0->Typedef_alias(art0);
                    tgt0 = cl0;
                }
                auto* ert = s.MakeRef_typespec();
                ert->VpiFullName(prefix + prefix + std::string(ta.name));
                ert->VpiParent(ats);
                ert->Actual_typespec(tgt0);
                ats->Elem_typespec(ert);
            }
            ts = ats;
        }
        else if ((ct.kind == SymbolKind::PackedArrayType ||
                  ct.kind == SymbolKind::ScalarType) &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias) {
            // A packed ALIAS-of-typedef (typedef imm_i_t imm_l_t): ONE shared
            // object cloned from the TARGET's declaration form — target type
            // span, signed, range FOLDED to constants — carrying a
            // Typedef_alias ref (module-scoped fullname) to a bare-named clone
            // of the target's ts. It is OMITTED from both pkg listings; module
            // listings and all member uses share it (jeras_union imm_l_t).
            if (topView) {
                // The TOP listing DOES carry the shared alias object (the def
                // listing omitted it) — jeras_union imm_l_t.
                if (auto tit9 = typedefTs.find(&ta); tit9 != typedefTs.end()) {
                    pkgTopTypedefTs[&ta] = tit9->second;
                    pkgTdByName.emplace_back(std::string(ta.name),
                                             tit9->second);
                }
                continue;
            }
            auto& tgt9 = ta.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgtTypeSyn9 = nullptr;
            if (auto asyn9 = tgt9.getSyntax();
                asyn9 && asyn9->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgtTypeSyn9 = asyn9->as<syntax::TypedefDeclarationSyntax>().type;
            // Left bound folds INT when written as a binary op (12-1), UINT
            // for a literal — decided from the TARGET's dim syntax.
            bool leftBin9 = false;
            if (tgtTypeSyn9 &&
                syntax::IntegerTypeSyntax::isKind(tgtTypeSyn9->kind)) {
                auto& dims9 =
                    tgtTypeSyn9->as<syntax::IntegerTypeSyntax>().dimensions;
                if (!dims9.empty() && (*dims9.begin())->specifier &&
                    (*dims9.begin())->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel9 = (*dims9.begin())
                                     ->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
                    if (sel9.selector->kind ==
                        syntax::SyntaxKind::SimpleRangeSelect)
                        leftBin9 =
                            sel9.selector->as<syntax::RangeSelectSyntax>()
                                .left->kind !=
                            syntax::SyntaxKind::IntegerLiteralExpression;
                }
            }
            auto foldBounds9 = [&](UHDM::typespec* t9) {
                if (!t9 || t9->UhdmType() != UHDM::uhdmlogic_typespec)
                    return;
                auto* rs9 = ((UHDM::logic_typespec*)t9)->Ranges();
                if (!rs9 || rs9->empty())
                    return;
                auto cr9 = ct.kind == SymbolKind::PackedArrayType
                               ? ct.as<PackedArrayType>().range
                               : ConstantRange{0, 0};
                auto mkC9 = [&](int32_t v9, bool int9,
                                UHDM::expr* old9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue((int9 ? "INT:" : "UINT:") + d9);
                    c9->VpiConstType(int9 ? vpiIntConst : vpiUIntConst);
                    c9->VpiParent((*rs9)[0]);
                    if (old9) {
                        // Anchor at the OLD bound's leading span (the left
                        // operand of a folded N-1 op).
                        UHDM::expr* anchor9 = old9;
                        if (old9->UhdmType() == UHDM::uhdmoperation) {
                            auto* ops9 = ((UHDM::operation*)old9)->Operands();
                            if (ops9 && !ops9->empty())
                                anchor9 = (UHDM::expr*)(*ops9)[0];
                        }
                        c9->VpiLineNo(anchor9->VpiLineNo());
                        c9->VpiColumnNo(anchor9->VpiColumnNo());
                        c9->VpiEndLineNo(anchor9->VpiEndLineNo());
                        c9->VpiEndColumnNo(anchor9->VpiEndColumnNo());
                    }
                    return c9;
                };
                auto* r9 = (*rs9)[0];
                bool leftOp9 = leftBin9 ||
                               (r9->Left_expr() &&
                                r9->Left_expr()->UhdmType() ==
                                    UHDM::uhdmoperation);
                r9->Left_expr(mkC9(cr9.left, leftOp9, r9->Left_expr()));
                r9->Right_expr(mkC9(cr9.right, false, r9->Right_expr()));
            };
            bypassTypedefShare = true;
            auto* lts9 = makeTypespec(ta, tgtTypeSyn9 ? tgtTypeSyn9 : typeSyn);
            bypassTypedefShare = false;
            foldBounds9(lts9);
            if (tgtTypeSyn9)
                setLoc(lts9, tgtTypeSyn9->sourceRange());
            lts9->VpiName(prefix + std::string(ta.name));
            lts9->Instance((UHDM::instance*)up);
            // Typedef_alias -> a bare-named clone of the target's form, which
            // itself carries a Typedef_alias ref (bare fullname) to the
            // TARGET's shared listing object, instanced at the package.
            bypassTypedefShare = true;
            auto* bare9 = makeTypespec(ta, tgtTypeSyn9 ? tgtTypeSyn9 : typeSyn);
            bypassTypedefShare = false;
            foldBounds9(bare9);
            if (tgtTypeSyn9)
                setLoc(bare9, tgtTypeSyn9->sourceRange());
            bare9->VpiName(tgt9.name);
            bare9->Instance((UHDM::instance*)up);
            if (bare9->UhdmType() == UHDM::uhdmlogic_typespec) {
                // ...whose Actual is a SEPARATE pkg-named SYMBOLIC clone of
                // the target (Surelog's alias-chain twin keeps the unfolded
                // bounds; only the outer two levels fold).
                bypassTypedefShare = true;
                bool savedTfA9 = tfContext;
                tfContext = true;
                auto* tgtCl9 =
                    makeTypespec(ta, tgtTypeSyn9 ? tgtTypeSyn9 : typeSyn);
                tfContext = savedTfA9;
                bypassTypedefShare = false;
                if (tgtTypeSyn9)
                    setLoc(tgtCl9, tgtTypeSyn9->sourceRange());
                tgtCl9->VpiName(prefix + std::string(tgt9.name));
                tgtCl9->Instance((UHDM::instance*)up);
                auto* tart9 = s.MakeRef_typespec();
                tart9->VpiFullName(std::string(tgt9.name));
                tart9->VpiParent(bare9);
                tart9->Actual_typespec(tgtCl9);
                ((UHDM::logic_typespec*)bare9)->Typedef_alias(tart9);
            }
            auto* art9 = s.MakeRef_typespec();
            art9->VpiFullName(std::string(d->VpiName()) + "." + prefix +
                              std::string(ta.name));
            art9->VpiParent(lts9);
            art9->Actual_typespec(bare9);
            lts9->Typedef_alias(art9);
            typedefTs[&ta] = lts9;
            typedefClone[&ta] = nullptr;
            continue; // no def-listing entry
        }
        else if (ct.kind == SymbolKind::PackedArrayType || ct.kind == SymbolKind::ScalarType) {
            // A param-bounded range (logic [X-1:0]) stays UNFOLDED in the DEF
            // view with a pkg::pkg::T::-scoped ref (tfContext + :: separator);
            // the elaborated view folds it.
            bypassTypedefShare = true;
            bool savedTf = tfContext;
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if (!topView) {
                tfContext = true;
                syntaxRefPrefix = prefix + prefix + std::string(ta.name);
                syntaxRefSep = "::";
            }
            auto* lts = makeTypespec(ta, typeSyn);
            tfContext = savedTf;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
            bypassTypedefShare = false;
            lts->VpiParent(up);
            // Def-view unfolded bound refs to package params bind vpiActual
            // to the param's def-view init constant.
            if (!topView && lts->UhdmType() == UHDM::uhdmlogic_typespec) {
                std::function<void(UHDM::any*)> bindRefs = [&](UHDM::any* e) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r = (UHDM::ref_obj*)e;
                        if (!r->Actual_group())
                            if (auto* sym = pkg.find(r->VpiName()))
                                if (auto pit = pkgParamConst.find(sym);
                                    pit != pkgParamConst.end())
                                    r->Actual_group(pit->second);
                    }
                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* op : *ops)
                                bindRefs(op);
                    }
                };
                if (auto* rs = ((UHDM::logic_typespec*)lts)->Ranges())
                    for (auto* r : *rs) {
                        bindRefs(r->Left_expr());
                        bindRefs(r->Right_expr());
                    }
            }
            typedefClone[&ta] = nullptr;
            ts = lts;
        }
        else if (ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::UnpackedStructType) {
            // Package struct member refs use pkg::pkg::T::m (doubled prefix);
            // each field typespec carries vpiInstance = package.
            // DEF-view member bounds stay UNFOLDED (member-scoped refs bound
            // to the params' def init constants); the elab view folds them.
            // A NESTED-struct-containing typedef's TOP view instead scopes
            // members pkg::T.m (single prefix, dot) and stays UNPARENTED.
            bool pkStr = ct.kind == SymbolKind::PackedStructType;
            const Scope& structScope =
                pkStr ? (const Scope&)ct.as<PackedStructType>()
                      : (const Scope&)ct.as<UnpackedStructType>();
            bool nestedStruct = false;
            for (auto& fm : structScope.membersOfType<FieldSymbol>())
                if (auto mk = fm.getType().getCanonicalType().kind;
                    mk == SymbolKind::PackedStructType ||
                    mk == SymbolKind::UnpackedStructType)
                    nestedStruct = true;
            bool topNested = topView && nestedStruct &&
                             wildcardImportedPkgs.count(&pkg);
            // A pkg struct consumed ONLY inside other package typedefs
            // (never by a module signal, directly or via packed array)
            // SHARES its def-view object into the elab pkg view instead of
            // materializing a top copy (nested_struct base_struct_t).
            if (topView && pkgDefStructTs.count(&ta)) {
                bool modUse9 = false;
                std::function<void(const InstanceBodySymbol&)> scan9 =
                    [&](const InstanceBodySymbol& b9) {
                        for (auto& mb9 : b9.members()) {
                            const DeclaredType* dt9 = nullptr;
                            if (mb9.kind == SymbolKind::Net ||
                                mb9.kind == SymbolKind::Variable ||
                                mb9.kind == SymbolKind::Port ||
                                mb9.kind == SymbolKind::Parameter)
                                dt9 = mb9.getDeclaredType();
                            if (dt9) {
                                const Type* t9 =
                                    &dt9->getType().getCanonicalType();
                                while (t9->getCanonicalType().kind ==
                                           SymbolKind::PackedArrayType ||
                                       t9->getCanonicalType().kind ==
                                           SymbolKind::
                                               FixedSizeUnpackedArrayType) {
                                    auto& c9 = t9->getCanonicalType();
                                    t9 = c9.kind == SymbolKind::PackedArrayType
                                             ? &c9.as<PackedArrayType>()
                                                    .elementType
                                             : &c9.as<
                                                     FixedSizeUnpackedArrayType>()
                                                    .elementType;
                                }
                                if (&t9->getCanonicalType() ==
                                    &ct.getCanonicalType())
                                    modUse9 = true;
                            }
                            if (mb9.kind == SymbolKind::Instance)
                                scan9(mb9.as<InstanceSymbol>().body);
                        }
                    };
                for (auto* ti9 : comp.getRoot().topInstances)
                    scan9(ti9->body);
                // Share only when the struct is nested inside ANOTHER
                // package's struct typedef (cross-pkg consumption).
                bool crossPkgNest9 = false;
                for (auto* opkg9 : comp.getPackages()) {
                    if (opkg9 == &pkg)
                        continue;
                    for (auto& om9 : opkg9->members())
                        if (om9.kind == SymbolKind::TypeAlias) {
                            auto& oct9 = om9.as<TypeAliasType>()
                                             .targetType.getType()
                                             .getCanonicalType();
                            if (oct9.isStruct())
                                for (auto& of9 : oct9.as<Scope>().members())
                                    if (of9.kind == SymbolKind::Field &&
                                        &of9.as<FieldSymbol>()
                                                .getType()
                                                .getCanonicalType() ==
                                            &ct.getCanonicalType())
                                        crossPkgNest9 = true;
                        }
                }
                if (!crossPkgNest9)
                    modUse9 = true;
                if (!modUse9) {
                    auto* shared9 = pkgDefStructTs[&ta];
                    pkgTopTypedefTs[&ta] = shared9;
                    pkgTdByName.emplace_back(std::string(ta.name), shared9);
                    continue;
                }
            }
            std::string alias = topNested
                                    ? prefix + std::string(ta.name)
                                    : prefix + prefix + std::string(ta.name);
            bool savedTf = tfContext;
            if (topView)
                tfContext = true;
            inPkgTopStructBuild = topView;
            auto* sts = buildStructTs(structScope, pkStr, alias,
                                      topNested ? "." : "::");
            inPkgTopStructBuild = false;
            tfContext = savedTf;
            if (!topNested)
                sts->VpiParent(up);
            if (sts->Members())
                for (auto* tm : *sts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec()) {
                        auto* mts = tm->Typespec()->Actual_typespec();
                        // A member whose actual is ANOTHER package's shared
                        // STRUCT typedef re-points at the import clone (never
                        // mutate the home object's Instance).
                        if (mts->UhdmType() == UHDM::uhdmstruct_typespec &&
                            mts->Instance() &&
                            mts->Instance() != (UHDM::instance*)up &&
                            mts->Instance()->UhdmType() == UHDM::uhdmpackage) {
                            const Symbol* homeSym9 = nullptr;
                            for (auto& [sym9, tsp9] : typedefTs)
                                if (tsp9 == mts) {
                                    homeSym9 = sym9;
                                    break;
                                }
                            if (homeSym9)
                                if (auto cit9 = pkgImportCloneTs.find(homeSym9);
                                    cit9 != pkgImportCloneTs.end()) {
                                    tm->Typespec()->Actual_typespec(
                                        cit9->second);
                                    mts = cit9->second;
                                }
                        }
                        // A member whose actual is ANOTHER package's shared
                        // enum typedef gets a FRESH per-use clone (Instance ->
                        // THIS package) — never mutate the shared object
                        // (Surelog keeps home Instance on the home copy).
                        if (mts->UhdmType() == UHDM::uhdmenum_typespec &&
                            mts->Instance() &&
                            mts->Instance() != (UHDM::instance*)up &&
                            mts->Instance()->UhdmType() == UHDM::uhdmpackage &&
                            // An ENUM-ALIAS ts (typedef op32_op62_et opc_t)
                            // stays the ONE shared object across views —
                            // never per-use cloned (jeras_union ctl_t.opc).
                            !((UHDM::enum_typespec*)mts)->Typedef_alias()) {
                            const EnumType* et9 = nullptr;
                            for (auto& [sym9, tsp9] : typedefTs)
                                if (tsp9 == mts &&
                                    sym9->kind == SymbolKind::TypeAlias) {
                                    auto& c9 = sym9->as<TypeAliasType>()
                                                   .getCanonicalType();
                                    if (c9.kind == SymbolKind::EnumType)
                                        et9 = &c9.as<EnumType>();
                                    break;
                                }
                            if (et9) {
                                auto* cl9 = buildEnumTs(
                                    *et9, nullptr,
                                    std::string(mts->VpiName()));
                                cl9->VpiName(mts->VpiName());
                                cl9->VpiLineNo(mts->VpiLineNo());
                                cl9->VpiColumnNo(mts->VpiColumnNo());
                                cl9->VpiEndLineNo(mts->VpiEndLineNo());
                                cl9->VpiEndColumnNo(mts->VpiEndColumnNo());
                                tm->Typespec()->Actual_typespec(cl9);
                                mts = cl9;
                            }
                        }
                        mts->Instance((UHDM::instance*)up);
                        if (topView && mts->UhdmType() == UHDM::uhdmlogic_typespec) {
                            std::function<void(UHDM::any*)> bindRefs2 =
                                [&](UHDM::any* e) {
                                    if (!e)
                                        return;
                                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                                        auto* r = (UHDM::ref_obj*)e;
                                        if (!r->Actual_group())
                                            if (auto* sym = pkg.find(r->VpiName()))
                                                if (auto pit = pkgParamConst.find(sym);
                                                    pit != pkgParamConst.end())
                                                    r->Actual_group(pit->second);
                                    }
                                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                                        if (auto* ops =
                                                ((UHDM::operation*)e)->Operands())
                                            for (auto* op : *ops)
                                                bindRefs2(op);
                                    }
                                };
                            if (auto* rs = ((UHDM::logic_typespec*)mts)->Ranges())
                                for (auto* r : *rs) {
                                    bindRefs2(r->Left_expr());
                                    bindRefs2(r->Right_expr());
                                }
                        }
                    }
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            // NESTED inner-struct member clones carry the pkg Instance on
            // their leaf member typespecs in BOTH views (nested_struct): the
            // def-view object is what the TOP struct ends up owning after the
            // member cross-wire below, and a leaf left without vpiInstance
            // breaks any Compare that reaches the top struct (NSAP).
            if (sts->Members())
                for (auto* tmN : *sts->Members())
                    if (tmN->Typespec() && tmN->Typespec()->Actual_typespec() &&
                        tmN->Typespec()->Actual_typespec()->UhdmType() ==
                            UHDM::uhdmstruct_typespec) {
                        auto* ists =
                            (UHDM::struct_typespec*)tmN->Typespec()
                                ->Actual_typespec();
                        if (ists->Members())
                            for (auto* itm : *ists->Members())
                                if (itm->Typespec() &&
                                    itm->Typespec()->Actual_typespec() &&
                                    !itm->Typespec()
                                         ->Actual_typespec()
                                         ->Instance())
                                    itm->Typespec()
                                        ->Actual_typespec()
                                        ->Instance((UHDM::instance*)up);
                    }
            // The TOP view's span stretches to the first module-signal USE
            // declarator (patched once defs exist); the def view keeps the
            // typedef span.
            if (topView)
                pendingPkgTsStretch.push_back(
                    {(UHDM::typespec*)sts, (const Type*)&ta});
            // Surelog CROSS-WIRES the two views' member typespecs: the
            // first-created (folded) member ts belongs to the TOP struct, the
            // second-created (unfolded) one to the DEF struct — while each
            // view's struct container keeps its own creation slot. Swap the
            // member actuals (and their parents/instances) after the top
            // build.
            if (!topView)
                pkgDefStructTs[&ta] = sts;
            else if (auto dit0 = pkgDefStructTs.find(&ta);
                     dit0 != pkgDefStructTs.end() && dit0->second->Members() &&
                     sts->Members() &&
                     dit0->second->Members()->size() == sts->Members()->size()) {
                auto* dsts = dit0->second;
                auto* dup2 = (UHDM::instance*)dsts->Instance();
                for (size_t mi = 0; mi < sts->Members()->size(); mi++) {
                    auto* dm = (*dsts->Members())[mi];
                    auto* tmM = (*sts->Members())[mi];
                    if (!dm->Typespec() || !tmM->Typespec())
                        continue;
                    auto* da = dm->Typespec()->Actual_typespec();
                    auto* taA = tmM->Typespec()->Actual_typespec();
                    if (!da || !taA || da->UhdmType() != taA->UhdmType())
                        continue;
                    // A NESTED struct/union member is NOT cross-wired: each
                    // view already built its own-view inner typedef (def ->
                    // symbolic def object, top -> folded elab object), so a
                    // swap would give each container the wrong-view inner
                    // aggregate (rsp_gen_minimal tl_d2h_t.d_user). Only the
                    // scalar (folded-vs-unfolded) leaves swap.
                    if (da->UhdmType() == UHDM::uhdmstruct_typespec ||
                        da->UhdmType() == UHDM::uhdmunion_typespec)
                        continue;
                    dm->Typespec()->Actual_typespec(taA);
                    tmM->Typespec()->Actual_typespec(da);
                    if (!taA->VpiName().length())
                        taA->VpiParent(dm);
                    if (!da->VpiName().length())
                        da->VpiParent(tmM);
                    if (dup2)
                        taA->Instance(dup2);
                    da->Instance((UHDM::instance*)up);
                }
                attachFoldedBoundMeta(sts, (UHDM::instance*)up);
            }
            ts = sts;
        }
        else if (ct.kind == SymbolKind::EnumType &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias) {
            // A pkg ENUM-typedef ALIAS (typedef lc_tx_e lc_tx_t): CREATED in
            // the DEF pass (arena: before the top-pkg clones) but LISTED only
            // in the TOP view. The clone is built from the TARGET's enum
            // syntax (own consts + fresh base at the target's base span) with
            // a Typedef_alias ref (doubled pkg scoping) to the target's
            // shared TOP ts (bound later, in the top pass). Its span runs
            // from the TARGET typedef's start to the first USE declarator's
            // end.
            if (!topView) {
                auto& tgt = ta.targetType.getType().as<TypeAliasType>();
                const syntax::SyntaxNode* tgtSyn = nullptr;
                SourceLocation tgtStart = tgt.location;
                SourceRange tgtDecl;
                if (auto asyn = tgt.getSyntax();
                    asyn && asyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                    tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                    tgtStart = asyn->sourceRange().start();
                    tgtDecl = asyn->sourceRange();
                }
                // A module VARIABLE of the alias type extends the span to its
                // declarator end, DOUBLES the ref scoping and parents at the
                // package; port-only uses keep the TARGET's decl span, single
                // scoping and no parent.
                SourceLocation useEnd = SourceLocation::NoLocation;
                bool arrayAliasUse0 = false;
                for (auto inst : comp.getRoot().topInstances) {
                    for (auto& mb : inst->body.members()) {
                        if (mb.kind != SymbolKind::Variable)
                            continue;
                        auto dt0 = mb.getDeclaredType();
                        if (!dt0)
                            continue;
                        // Direct alias type OR a PACKED ARRAY of it
                        // (VarPassedTo2Submodules lc_tx_t [0:0] var). An
                        // ARRAY use doubles/parents but does NOT stretch
                        // the span (useEnd stays unset).
                        bool aliasDirect0 = &dt0->getType() == (const Type*)&ta;
                        bool aliasUse0 = aliasDirect0;
                        if (!aliasUse0)
                            for (const Type* t0 = &dt0->getType();;) {
                                if (t0 == (const Type*)&ta) {
                                    aliasUse0 = true;
                                    break;
                                }
                                auto& c0 = t0->getCanonicalType();
                                if (c0.kind != SymbolKind::PackedArrayType)
                                    break;
                                t0 = &c0.as<PackedArrayType>().elementType;
                            }
                        if (!aliasUse0)
                            continue;
                        if (!aliasDirect0) {
                            arrayAliasUse0 = true;
                            break;
                        }
                        // PORT-backed variables (output pkg::b o) don't count.
                        bool portBacked = false;
                        for (auto pb : inst->body.getPortList())
                            if (pb->kind == SymbolKind::Port &&
                                pb->as<PortSymbol>().internalSymbol == &mb)
                                portBacked = true;
                        if (portBacked)
                            continue;
                        if (auto dsyn0 = mb.getSyntax())
                            useEnd = dsyn0->sourceRange().end();
                        break;
                    }
                    if (useEnd != SourceLocation::NoLocation)
                        break;
                }
                bool varUse =
                    useEnd != SourceLocation::NoLocation || arrayAliasUse0;
                std::string refName = varUse
                                          ? prefix + prefix + std::string(ta.name)
                                          : prefix + std::string(ta.name);
                auto* ets = buildEnumTs(ct.as<EnumType>(), tgtSyn, refName);
                if (varUse)
                    ets->VpiParent(up);
                if (ets->Base_typespec() && ets->Base_typespec()->Actual_typespec()) {
                    auto* bts = ets->Base_typespec()->Actual_typespec();
                    bts->Instance((UHDM::instance*)up);
                    bts->VpiParent(ets->Base_typespec());
                }
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(refName);
                art->VpiParent(ets);
                ets->Typedef_alias(art);
                if (varUse && useEnd != SourceLocation::NoLocation)
                    setLoc(ets, SourceRange(tgtStart, useEnd));
                else if (tgtDecl.start() != SourceLocation::NoLocation)
                    setLoc(ets, tgtDecl);
                else if (auto syn = ta.getSyntax())
                    setLoc(ets, syn->sourceRange());
                ets->VpiName(prefix + std::string(ta.name));
                ets->Instance((UHDM::instance*)up);
                // Module signals of the alias type (BOTH views) bind this
                // clone; the def LISTING omits it.
                typedefTs[&ta] = ets;
                continue;
            }
            // TOP pass: bind the alias target (now emitted) and list.
            auto tit0 = typedefTs.find(&ta);
            if (tit0 == typedefTs.end())
                continue;
            auto* ets = (UHDM::enum_typespec*)tit0->second;
            if (ets->Typedef_alias())
                if (auto tgtIt = pkgTopTypedefTs.find(&ta.targetType.getType());
                    tgtIt != pkgTopTypedefTs.end())
                    ets->Typedef_alias()->Actual_typespec(tgtIt->second);
            pkgTopTypedefTs[&ta] = ets;
            pkgTdByName.emplace_back(std::string(ta.name), ets);
            continue;
        }
        else if (ct.kind == SymbolKind::EnumType) {
            // The base ref fullname doubles the package scope
            // (pkg::pkg::name — Surelog scopes the already-prefixed typedef
            // name by the package again).
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn,
                                    prefix + prefix + std::string(ta.name));
            ets->VpiParent(up);
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            // The base typespec is package-instanced too.
            if (ets->Base_typespec() && ets->Base_typespec()->Actual_typespec())
                ets->Base_typespec()->Actual_typespec()->Instance((UHDM::instance*)up);
            // The TOP clone's span stretches to the first module-signal USE
            // declarator (a `pkg::e arr [N]` unpacked-array element extends the
            // endln to the array_var decl end — Surelog). The def view keeps
            // the typedef span.
            if (topView)
                pendingPkgTsStretch.push_back(
                    {(UHDM::typespec*)ets, (const Type*)&ta});
            ts = ets;
        }
        else if (ct.kind == SymbolKind::PackedUnionType ||
                 ct.kind == SymbolKind::UnpackedUnionType) {
            // Package UNION typedef -> union_typespec, members doubled-scoped
            // p::p::T::m ("::"), parented at the package (sibling of the
            // PackedStructType branch).
            std::string alias = prefix + prefix + std::string(ta.name);
            bool pk = ct.kind == SymbolKind::PackedUnionType;
            // Member bounds ([K:0]) stay SYMBOLIC in the top view (mirror the
            // PackedStructType branch's tfContext handling).
            bool savedTfU = tfContext;
            if (topView)
                tfContext = true;
            inPkgTopStructBuild = topView;
            auto* uts = pk
                            ? buildUnionTs(ct.as<PackedUnionType>(), true, alias,
                                           "::")
                            : buildUnionTs(ct.as<UnpackedUnionType>(), false,
                                           alias, "::");
            inPkgTopStructBuild = false;
            tfContext = savedTfU;
            uts->VpiParent(up);
            if (uts->Members())
                for (auto* tm : *uts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec())
                        tm->Typespec()->Actual_typespec()->Instance(
                            (UHDM::instance*)up);
            // Mirror the struct arm: Surelog CROSS-WIRES the two views' member
            // typespecs. The DEF pass folds member bounds ([K:0] -> constant);
            // the TOP pass (tfContext) keeps them SYMBOLIC (ref_obj). Surelog
            // wires the symbolic (top-built) member ts into the DEF union and
            // the folded (def-built) one into the TOP union. Swap after top.
            if (!topView)
                pkgDefUnionTs[&ta] = uts;
            else if (auto duit = pkgDefUnionTs.find(&ta);
                     duit != pkgDefUnionTs.end() && duit->second->Members() &&
                     uts->Members() &&
                     duit->second->Members()->size() == uts->Members()->size()) {
                auto* duts = duit->second;
                auto* dup2 = (UHDM::instance*)duts->Instance();
                for (size_t mi = 0; mi < uts->Members()->size(); mi++) {
                    auto* dm = (*duts->Members())[mi];
                    auto* tmM = (*uts->Members())[mi];
                    if (!dm->Typespec() || !tmM->Typespec())
                        continue;
                    auto* da = dm->Typespec()->Actual_typespec();
                    auto* taA = tmM->Typespec()->Actual_typespec();
                    if (!da || !taA || da->UhdmType() != taA->UhdmType())
                        continue;
                    // A NESTED struct/union member is NOT cross-wired: each
                    // view already built its own-view inner typedef (def ->
                    // symbolic def object, top -> folded elab object), so a
                    // swap would give each container the wrong-view inner
                    // aggregate (rsp_gen_minimal tl_d2h_t.d_user). Only the
                    // scalar (folded-vs-unfolded) leaves swap.
                    if (da->UhdmType() == UHDM::uhdmstruct_typespec ||
                        da->UhdmType() == UHDM::uhdmunion_typespec)
                        continue;
                    dm->Typespec()->Actual_typespec(taA);
                    tmM->Typespec()->Actual_typespec(da);
                    if (!taA->VpiName().length())
                        taA->VpiParent(dm);
                    if (!da->VpiName().length())
                        da->VpiParent(tmM);
                    if (dup2)
                        taA->Instance(dup2);
                    da->Instance((UHDM::instance*)up);
                }
                attachFoldedBoundMeta(uts, (UHDM::instance*)up);
            }
            if (typeSyn)
                setLoc(uts, typeSyn->sourceRange());
            ts = uts;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType && topView) {
            // typedef a b[1:0] (TOP view only): an array_typespec spanning
            // target-type .. dims, Range at the dim tokens, Elem ref
            // (doubled pkg::pkg::b) -> the element typedef's ts (Surelog).
            auto& ua = ct.as<FixedSizeUnpackedArrayType>();
            auto* ats = s.MakeArray_typespec();
            SourceLocation aS = ta.location, aE = ta.location;
            if (typeSyn)
                aS = typeSyn->sourceRange().start();
            const syntax::SyntaxNode* dimSyn = nullptr;
            if (auto dsyn = ta.getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                auto& td = dsyn->as<syntax::TypedefDeclarationSyntax>();
                if (!td.dimensions.empty()) {
                    dimSyn = td.dimensions[0];
                    aE = td.dimensions[td.dimensions.size() - 1]
                             ->sourceRange()
                             .end();
                }
            }
            setLoc(ats, SourceRange(aS, aE));
            auto* r = s.MakeRange();
            r->VpiParent(ats);
            const syntax::ExpressionSyntax* lSyn = nullptr;
            const syntax::ExpressionSyntax* rSyn = nullptr;
            if (dimSyn) {
                setLoc(r, dimSyn->sourceRange());
                auto& vd = dimSyn->as<syntax::VariableDimensionSyntax>();
                if (vd.specifier &&
                    vd.specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel = *vd.specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>()
                                     .selector;
                    if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                        lSyn = rss->left;
                        rSyn = rss->right;
                    }
                }
            }
            auto mkAB = [&](int64_t v,
                            const syntax::ExpressionSyntax* bs) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string digits = std::to_string(v);
                c->VpiDecompile(digits);
                c->VpiSize(64);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                if (bs)
                    setLoc(c, bs->sourceRange());
                return c;
            };
            r->Left_expr(mkAB(ua.range.left, lSyn));
            r->Right_expr(mkAB(ua.range.right, rSyn));
            auto* rvec = s.MakeRangeVec();
            rvec->push_back(r);
            ats->Ranges(rvec);
            // Elem ref -> the element typedef's ts in THIS view.
            UHDM::typespec* elemTs2 = nullptr;
            const Type* et = &ua.elementType;
            const Symbol* etSym =
                et->kind == SymbolKind::TypeAlias
                    ? (const Symbol*)&et->as<TypeAliasType>()
                    : nullptr;
            if (topView) {
                if (auto eit = pkgTopTypedefTs.find(etSym);
                    etSym && eit != pkgTopTypedefTs.end())
                    elemTs2 = eit->second;
            }
            else if (auto eit = typedefTs.find(etSym);
                     etSym && eit != typedefTs.end())
                elemTs2 = eit->second;
            if (!elemTs2 && !topView)
                for (auto& [sym2, tsp2] : typedefTs)
                    if (sym2->kind == SymbolKind::TypeAlias &&
                        &sym2->as<TypeAliasType>().getCanonicalType() ==
                            &et->getCanonicalType()) {
                        elemTs2 = tsp2;
                        break;
                    }
            if (elemTs2) {
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(ats);
                ert->VpiFullName(prefix + prefix + std::string(ta.name));
                ert->Actual_typespec(elemTs2);
                ats->Elem_typespec(ert);
            }
            ts = ats;
        }
        if (!ts)
            continue;
        ts->VpiName(prefix + std::string(ta.name));
        ts->Instance((UHDM::instance*)up);
        // A member typed by ANOTHER package's struct typedef keeps that
        // package's vpiInstance on the member's OWN sub-typespecs (Surelog);
        // only this typedef's own objects move to the importing package.
        if (ts->UhdmType() == UHDM::uhdmstruct_typespec) {
            std::function<void(UHDM::typespec*, UHDM::instance*)> stampSub =
                [&](UHDM::typespec* t4, UHDM::instance* inst4) {
                    if (!t4 || t4->UhdmType() != UHDM::uhdmstruct_typespec)
                        return;
                    auto* ms4 = ((UHDM::struct_typespec*)t4)->Members();
                    if (!ms4)
                        return;
                    for (auto* tm4 : *ms4) {
                        if (!tm4->Typespec())
                            continue;
                        auto* at4 = tm4->Typespec()->Actual_typespec();
                        if (!at4)
                            continue;
                        if (at4->Instance())
                            at4->Instance(inst4);
                        stampSub(at4, inst4);
                    }
                };
            if (ct.kind == SymbolKind::PackedStructType) {
                auto& pst4 = ct.as<PackedStructType>();
                auto* ms5 = ((UHDM::struct_typespec*)ts)->Members();
                for (auto& fld4 : pst4.membersOfType<FieldSymbol>()) {
                    auto dt4 = fld4.getDeclaredType();
                    if (!dt4 || dt4->getType().kind != SymbolKind::TypeAlias)
                        continue;
                    const Scope* hs4 = dt4->getType()
                                           .as<TypeAliasType>()
                                           .getParentScope();
                    if (!hs4 || hs4->asSymbol().kind != SymbolKind::Package ||
                        &hs4->asSymbol() == &pkg.asSymbol())
                        continue;
                    auto hip4 = pkgDefMap.find(&hs4->asSymbol());
                    if (hip4 == pkgDefMap.end() || !ms5)
                        continue;
                    for (auto* tm5 : *ms5)
                        if (tm5->VpiName() == fld4.name && tm5->Typespec())
                            stampSub(tm5->Typespec()->Actual_typespec(),
                                     (UHDM::instance*)hip4->second);
                }
            }
        }
        if (!topView)
            typedefTs[&ta] = ts;
        else
            pkgTopTypedefTs[&ta] = ts;
        UHDM::typespec* listTs = ts;
        // A pkg imported by ANOTHER pkg lists its DEF enum object in the
        // TOP view too (the top object appears only via module listings).
        if (topView && ct.kind == SymbolKind::EnumType &&
            pkgImportedByPkg.count(&pkg))
            if (auto dIt = typedefTs.find(&ta); dIt != typedefTs.end())
                listTs = dIt->second;
        pkgTdByName.emplace_back(std::string(ta.name), listTs);
    }
    // The Typespecs LIST is name-sorted (creation stayed source-ordered).
    std::stable_sort(pkgTdByName.begin(), pkgTdByName.end(),
                     [](auto& a, auto& b) { return a.first < b.first; });
    for (auto& [nm0, ts0] : pkgTdByName)
        tds->push_back(ts0);
    for (auto* it9 : importTss)
        tds->push_back(it9);
    if (!tds->empty())
        up->Typespecs(tds);
    // A package STRUCT typedef named as a package SUBROUTINE ARGUMENT's type
    // has its shared typespec RE-LOCATED to that argument's type reference —
    // Surelog's last-writer stamp. A RETURN type does NOT relocate
    // (rsp_gen_minimal: tl_d2h_t moves to the arg, tl_d2h_rsp_intg_t stays).
    for (auto& mem9 : pkg.members()) {
        if (mem9.kind != SymbolKind::Subroutine)
            continue;
        for (auto* arg9 : mem9.as<SubroutineSymbol>().getArguments()) {
            auto dt9 = arg9->getDeclaredType();
            if (!dt9 || dt9->getType().kind != SymbolKind::TypeAlias ||
                !dt9->getType().getCanonicalType().isStruct())
                continue;
            UHDM::typespec* sh9 = nullptr;
            if (topView) {
                if (auto i9 = pkgTopTypedefTs.find((const void*)&dt9->getType());
                    i9 != pkgTopTypedefTs.end())
                    sh9 = i9->second;
            }
            else if (auto i8 = typedefTs.find(&dt9->getType());
                     i8 != typedefTs.end())
                sh9 = i8->second;
            if (!sh9 || sh9->UhdmType() != UHDM::uhdmstruct_typespec)
                continue;
            if (auto tsy9 = dt9->getTypeSyntax())
                setLoc(sh9, tsy9->sourceRange());
        }
    }
    // A struct/union-typed package parameter references the SHARED package
    // typedef object (Surelog), not the fresh clone built during emitParameters
    // (which ran before this typedef loop, so nested-struct members had no
    // registered inner typedef and fell back to logic_typespec). Re-point each
    // such param's typespec actual to the now-materialized typedef.
    if (up->Parameters())
        for (auto& member : pkg.members()) {
            if (member.kind != SymbolKind::Parameter)
                continue;
            auto& ps2 = member.as<ParameterSymbol>();
            auto d0 = ps2.getDeclaredType();
            if (!d0 || d0->getType().kind != SymbolKind::TypeAlias)
                continue;
            auto ck2 = d0->getType().getCanonicalType().kind;
            if (ck2 != SymbolKind::PackedStructType &&
                ck2 != SymbolKind::UnpackedStructType &&
                ck2 != SymbolKind::PackedUnionType &&
                ck2 != SymbolKind::UnpackedUnionType)
                continue;
            auto& taSym2 = d0->getType().as<TypeAliasType>();
            UHDM::typespec* shared = nullptr;
            if (topView) {
                if (auto tit = pkgTopTypedefTs.find(&taSym2);
                    tit != pkgTopTypedefTs.end())
                    shared = tit->second;
            }
            else if (auto tit = typedefTs.find(&d0->getType());
                     tit != typedefTs.end())
                shared = tit->second;
            if (!shared)
                continue;
            for (auto* pv0 : *up->Parameters()) {
                if (pv0->UhdmType() != UHDM::uhdmparameter)
                    continue;
                auto* pv = (UHDM::parameter*)pv0;
                if (pv->VpiName() == ps2.name && pv->Typespec() &&
                    pv->Typespec()->Actual_typespec() &&
                    pv->Typespec()->Actual_typespec()->UhdmType() ==
                        shared->UhdmType())
                    pv->Typespec()->Actual_typespec(shared);
            }
        }
    // An UNPACKED-ARRAY-of-struct/union/enum package parameter's array_typespec
    // element also references the SHARED typedef; re-point its Elem actual
    // (built as a logic_typespec before the typedef loop ran).
    if (up->Parameters())
        for (auto& member : pkg.members()) {
            if (member.kind != SymbolKind::Parameter)
                continue;
            auto& ps2 = member.as<ParameterSymbol>();
            const Type* leaf = &ps2.getType().getCanonicalType();
            if (leaf->kind != SymbolKind::FixedSizeUnpackedArrayType)
                continue;
            while (leaf->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leaf = &leaf->getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>()
                            .elementType;
            if (leaf->kind != SymbolKind::TypeAlias)
                continue;
            UHDM::typespec* shared = nullptr;
            if (topView) {
                if (auto tit = pkgTopTypedefTs.find(&leaf->as<TypeAliasType>());
                    tit != pkgTopTypedefTs.end())
                    shared = tit->second;
            }
            else if (auto tit = typedefTs.find(leaf);
                     tit != typedefTs.end())
                shared = tit->second;
            if (!shared || (shared->UhdmType() != UHDM::uhdmstruct_typespec &&
                            shared->UhdmType() != UHDM::uhdmunion_typespec &&
                            shared->UhdmType() != UHDM::uhdmenum_typespec))
                continue;
            for (auto* pv0 : *up->Parameters()) {
                if (pv0->UhdmType() != UHDM::uhdmparameter)
                    continue;
                auto* pv = (UHDM::parameter*)pv0;
                if (pv->VpiName() != ps2.name || !pv->Typespec())
                    continue;
                auto* ats0 = pv->Typespec()->Actual_typespec();
                if (ats0 && ats0->UhdmType() == UHDM::uhdmarray_typespec)
                    if (auto* er = ((UHDM::array_typespec*)ats0)->Elem_typespec();
                        er && er->Actual_typespec() &&
                        er->Actual_typespec()->UhdmType() !=
                            UHDM::uhdmstruct_typespec)
                        er->Actual_typespec(shared);
            }
        }
    inPkgTypedefEmit = false;
    pkgTopEmit = topView;
    emitTaskFuncs(pkg, up, prefix, nullptr, /*sharedScope=*/false);
    pkgTopEmit = false;
    return up;
}

// After ALL def-view packages exist: insert the home def objects into the
// importing packages' Typespecs slots, stamp Instance = the importing pkg,
// and expose them for module import listings.

} // namespace slang_uhdm
