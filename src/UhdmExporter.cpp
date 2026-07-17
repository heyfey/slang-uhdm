//------------------------------------------------------------------------------
//! @file UhdmExporter.cpp
//! @brief Exports a slang Compilation to a UHDM database (Surelog-compatible)
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <functional>

#include <uhdm/uhdm.h>

#include "slang/ast/ASTVisitor.h"
#include "slang/ast/Compilation.h"
#include "slang/ast/TimingControl.h"
#include "slang/ast/expressions/AssignmentExpressions.h"
#include "slang/ast/expressions/CallExpression.h"
#include "slang/ast/expressions/ConversionExpression.h"
#include "slang/ast/expressions/LiteralExpressions.h"
#include "slang/ast/expressions/MiscExpressions.h"
#include "slang/ast/expressions/OperatorExpressions.h"
#include "slang/ast/expressions/SelectExpressions.h"
#include "slang/ast/statements/ConditionalStatements.h"
#include "slang/ast/statements/LoopStatements.h"
#include "slang/ast/statements/MiscStatements.h"
#include "slang/ast/symbols/CompilationUnitSymbols.h"
#include "slang/ast/symbols/InstanceSymbols.h"
#include "slang/ast/symbols/MemberSymbols.h"
#include "slang/ast/symbols/ParameterSymbols.h"
#include "slang/ast/symbols/PortSymbols.h"
#include "slang/ast/symbols/VariableSymbols.h"
#include "slang/ast/types/AllTypes.h"
#include "slang/ast/types/Type.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/text/SourceManager.h"

using namespace slang;
using namespace slang::ast;

namespace slang_uhdm {

static constexpr int kVpiAssignmentOp = 82; // sv_vpi_user.h vpiAssignmentOp

// ANSI net-port headers ("input wire x") carry the net keyword token.
static const syntax::NetPortHeaderSyntax* ansiNetHeader(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            auto& ap = p->as<syntax::ImplicitAnsiPortSyntax>();
            if (ap.header->kind == syntax::SyntaxKind::NetPortHeader) {
                auto& nh = ap.header->as<syntax::NetPortHeaderSyntax>();
                if (nh.netType.valid())
                    return &nh;
            }
            return nullptr;
        }
    }
    return nullptr;
}

// Surelog derives vpiNetType from the declared type keyword: explicit
// `logic` -> vpiNet, `reg` -> vpiReg, implicit -> unset; explicit net
// keywords map to their vpi net types.
static int32_t netTypeFor(const Symbol& internal) {
    if (internal.kind == SymbolKind::Net) {
        // Explicit net declarations ("wire w;") and ANSI net-port headers
        // ("input wire x") carry the net kind; implicit port-backed nets do
        // not print a net type.
        auto& nt = internal.as<NetSymbol>().netType;
        bool explicitDecl = ansiNetHeader(internal) != nullptr;
        for (auto p = internal.getSyntax(); !explicitDecl && p; p = p->parent) {
            if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                explicitDecl = true;
                break;
            }
        }
        if (explicitDecl) {
            switch (nt.netKind) {
                case NetType::Wire:
                    return vpiWire;
                case NetType::WAnd:
                    return vpiWand;
                case NetType::WOr:
                    return vpiWor;
                case NetType::Tri:
                    return vpiTri;
                default:
                    break;
            }
        }
    }
    if (auto declared = internal.getDeclaredType()) {
        if (auto tsyn = declared->getTypeSyntax()) {
            if (tsyn->kind == syntax::SyntaxKind::LogicType)
                return vpiNet;
            if (tsyn->kind == syntax::SyntaxKind::RegType)
                return vpiReg;
        }
    }
    return 0;
}

static int32_t mapUnaryOp(UnaryOperator op) {
    switch (op) {
        case UnaryOperator::Plus:
            return vpiPlusOp;
        case UnaryOperator::Minus:
            return vpiMinusOp;
        case UnaryOperator::BitwiseNot:
            return vpiBitNegOp;
        case UnaryOperator::BitwiseAnd:
            return vpiUnaryAndOp;
        case UnaryOperator::BitwiseOr:
            return vpiUnaryOrOp;
        case UnaryOperator::BitwiseXor:
            return vpiUnaryXorOp;
        case UnaryOperator::BitwiseNand:
            return vpiUnaryNandOp;
        case UnaryOperator::BitwiseNor:
            return vpiUnaryNorOp;
        case UnaryOperator::BitwiseXnor:
            return vpiUnaryXNorOp;
        case UnaryOperator::LogicalNot:
            return vpiNotOp;
        case UnaryOperator::Preincrement:
            return vpiPreIncOp;
        case UnaryOperator::Postincrement:
            return vpiPostIncOp;
        case UnaryOperator::Predecrement:
            return vpiPreDecOp;
        case UnaryOperator::Postdecrement:
            return vpiPostDecOp;
        default:
            return 0;
    }
}

static int32_t mapBinaryOp(BinaryOperator op) {
    switch (op) {
        case BinaryOperator::Add:
            return vpiAddOp;
        case BinaryOperator::Subtract:
            return vpiSubOp;
        case BinaryOperator::Multiply:
            return vpiMultOp;
        case BinaryOperator::Divide:
            return vpiDivOp;
        case BinaryOperator::Mod:
            return vpiModOp;
        case BinaryOperator::BinaryAnd:
            return vpiBitAndOp;
        case BinaryOperator::BinaryOr:
            return vpiBitOrOp;
        case BinaryOperator::BinaryXor:
            return vpiBitXorOp;
        case BinaryOperator::BinaryXnor:
            return vpiBitXNorOp;
        case BinaryOperator::Equality:
            return vpiEqOp;
        case BinaryOperator::Inequality:
            return vpiNeqOp;
        case BinaryOperator::CaseEquality:
            return vpiCaseEqOp;
        case BinaryOperator::CaseInequality:
            return vpiCaseNeqOp;
        case BinaryOperator::GreaterThanEqual:
            return vpiGeOp;
        case BinaryOperator::GreaterThan:
            return vpiGtOp;
        case BinaryOperator::LessThanEqual:
            return vpiLeOp;
        case BinaryOperator::LessThan:
            return vpiLtOp;
        case BinaryOperator::WildcardEquality:
            return vpiWildEqOp;
        case BinaryOperator::WildcardInequality:
            return vpiWildNeqOp;
        case BinaryOperator::LogicalAnd:
            return vpiLogAndOp;
        case BinaryOperator::LogicalOr:
            return vpiLogOrOp;
        case BinaryOperator::LogicalImplication:
            return vpiImplyOp;
        case BinaryOperator::LogicalShiftLeft:
            return vpiLShiftOp;
        case BinaryOperator::LogicalShiftRight:
            return vpiRShiftOp;
        case BinaryOperator::ArithmeticShiftLeft:
            return vpiArithLShiftOp;
        case BinaryOperator::ArithmeticShiftRight:
            return vpiArithRShiftOp;
        case BinaryOperator::Power:
            return vpiPowerOp;
        default:
            return 0;
    }
}

UhdmExporter::UhdmExporter(Compilation& compilation, UHDM::Serializer& serializer) :
    comp(compilation), s(serializer), sm(compilation.getSourceManager()) {
}

void UhdmExporter::noteUnsupported(const std::string& what) {
    unsupportedKinds.insert(what);
}

void UhdmExporter::setLoc(UHDM::BaseClass* obj, SourceRange range) {
    if (range.start() == SourceLocation::NoLocation)
        return;
    obj->VpiLineNo(sm->getLineNumber(range.start()));
    obj->VpiColumnNo(sm->getColumnNumber(range.start()));
    if (range.end() != SourceLocation::NoLocation) {
        obj->VpiEndLineNo(sm->getLineNumber(range.end()));
        obj->VpiEndColumnNo(sm->getColumnNumber(range.end()));
    }
}

void UhdmExporter::setLocNamed(UHDM::BaseClass* obj, const Symbol& symbol) {
    auto loc = symbol.location;
    // Surelog anchors ports and port-backed nets at the port-list name, not
    // the declaration.
    if (symbol.kind == SymbolKind::Port)
        loc = symbol.as<PortSymbol>().externalLoc;
    if (loc == SourceLocation::NoLocation)
        return;
    setLoc(obj, SourceRange(loc, loc + symbol.name.size()));
}

std::string UhdmExporter::fullFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    return sm->getFullPath(loc.buffer()).string();
}

// Collects one representative instance per definition, recursively.
static void collectDefs(const InstanceBodySymbol& body,
                        std::map<std::string, const InstanceSymbol*>& defs) {
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            auto name = std::string(child.getDefinition().name);
            if (defs.emplace(name, &child).second)
                collectDefs(child.body, defs);
        }
    }
}

UHDM::design* UhdmExporter::exportDesign() {
    auto& root = comp.getRoot();

    d = s.MakeDesign();
    if (!root.topInstances.empty())
        d->VpiName("work@" + std::string(root.topInstances[0]->getDefinition().name));

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    for (auto inst : root.topInstances) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs);
    }

    // User packages (skip built-ins).
    std::vector<const PackageSymbol*> pkgs;
    for (auto pkg : comp.getPackages()) {
        if (pkg->name != "std" && pkg->name != "$unit")
            pkgs.push_back(pkg);
    }
    if (!pkgs.empty()) {
        auto* allP = s.MakePackageVec();
        for (auto pkg : pkgs)
            allP->push_back(emitPackage(*pkg, false));
        d->AllPackages(allP);
    }

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    // Pre-create the definition shells so ref_modules can point at them
    // regardless of emission order.
    for (auto& [name, inst] : defs) {
        defMap[&inst->getDefinition()].mod = s.MakeModule_inst();
        allMods->push_back(defMap[&inst->getDefinition()].mod);
    }
    d->AllModules(allMods);

    for (auto inst : root.topInstances) {
        std::string prefix = "work@" + std::string(inst->getDefinition().name);
        topMods->push_back(emitInstance(*inst, prefix, nullptr, nullptr, nullptr, /*isTop=*/true));
    }
    d->TopModules(topMods);

    if (!pkgs.empty()) {
        auto* topP = s.MakePackageVec();
        for (auto pkg : pkgs)
            topP->push_back(emitPackage(*pkg, true));
        d->TopPackages(topP);
    }

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    return d;
}

// Finds the named port connection syntax for a formal port name, so locations
// can anchor at the ".a(o)" text like Surelog.
static const syntax::NamedPortConnectionSyntax* findConnSyntax(const InstanceSymbol& inst,
                                                               std::string_view formal) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return nullptr;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections) {
        if (conn->kind == syntax::SyntaxKind::NamedPortConnection) {
            auto& npc = conn->as<syntax::NamedPortConnectionSyntax>();
            if (npc.name.valueText() == formal)
                return &npc;
        }
    }
    return nullptr;
}

// True when the expression tree contains anything Surelog's netlist
// elaboration would re-compile as an operation (which forces a fresh
// cont_assign object in the instance view instead of sharing the def's).
static bool containsOperation(const Expression& expr) {
    switch (expr.kind) {
        case ExpressionKind::UnaryOp:
        case ExpressionKind::BinaryOp:
        case ExpressionKind::ConditionalOp:
        case ExpressionKind::Concatenation:
        case ExpressionKind::Replication:
            return true;
        case ExpressionKind::Conversion: {
            auto& conv = expr.as<ConversionExpression>();
            if (!conv.isImplicit())
                return true;
            return containsOperation(conv.operand());
        }
        case ExpressionKind::Call:
            return true;
        default:
            return false;
    }
}

// Port connection expressions for output ports come wrapped in an assignment;
// the connected expression is its left side.
static const Expression* connectionExpr(const PortConnection& conn) {
    auto expr = conn.getExpression();
    if (expr && expr->kind == ExpressionKind::Assignment)
        expr = &expr->as<AssignmentExpression>().left();
    return expr;
}

static std::string joinPath(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    return prefix + "." + std::string(name);
}

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage) {
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        auto* up = s.MakeParameter();
        up->VpiName(ps.name);
        up->VpiFullName(joinPath(prefix, ps.name));
        up->VpiParent(m);
        setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));

        // Packages: follow the source keyword (slang marks package params
        // local per LRM; Surelog does not).
        bool isLocal = ps.isLocalParam();
        if (inPackage) {
            isLocal = false;
            for (auto q = ps.getSyntax(); q; q = q->parent) {
                if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                    isLocal = q->as<syntax::ParameterDeclarationSyntax>().keyword.valueText() ==
                              "localparam";
                    break;
                }
            }
        }
        bool wantTs = false;
        if (isLocal) {
            up->VpiLocalParam(true);
        }
        else {
            auto& cv = ps.getValue();
            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = iv.isSigned() && iv.isNegative();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                up->VpiValue((neg ? "INT:" : "UINT:") + digits);
            }
            wantTs = ps.getType().getCanonicalType().isIntegral();
        }
        if (auto declared0 = ps.getDeclaredType()) {
            if (auto tsyn0 = declared0->getTypeSyntax()) {
                if (tsyn0->kind != syntax::SyntaxKind::ImplicitType &&
                    ps.getType().getCanonicalType().isSigned())
                    up->VpiSigned(true);
            }
        }
        bool typedParam = false;
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax())
                typedParam = tsyn->kind != syntax::SyntaxKind::ImplicitType;
        }
        UHDM::ref_typespec* prt = nullptr;
        if (wantTs) {
            // The actual typespec object is created late (after the instance
            // ports) to match Surelog's arena order; the ref is patched then.
            prt = s.MakeRef_typespec();
            prt->VpiFullName(joinPath(prefix, ps.name));
            prt->VpiParent(up);
            up->Typespec(prt);
        }
        params->push_back(up);

        UHDM::ref_typespec* rhsRt = nullptr;
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(m);
        if (auto syn = ps.getSyntax())
            setLoc(pa, syn->sourceRange());
        pa->Lhs(up);
        if (auto init0 = ps.getInitializer()) {
            const Expression* init = init0;
            while (init->kind == ExpressionKind::Conversion &&
                   init->as<ConversionExpression>().isImplicit())
                init = &init->as<ConversionExpression>().operand();
            UHDM::any* rhs = nullptr;
            if (topView) {
                if (init->kind == ExpressionKind::IntegerLiteral) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    if (rhs)
                        ((UHDM::constant*)rhs)->VpiSize((int32_t)ps.getType().getBitWidth());
                }
                else if ((rhs = tryFoldConst(*init))) {
                    ((UHDM::constant*)rhs)->VpiParent(pa);
                    ((UHDM::constant*)rhs)->VpiSize(64);
                    setLoc((UHDM::constant*)rhs, init->sourceRange);
                }
            }
            if (!rhs) {
                forceConstParent = true;
                rhs = emitExpr(*init, pa, prefix, netMap);
                forceConstParent = false;
            }
            if (rhs) {
                pa->Rhs(rhs);
                if (inPackage && !topView && rhs->UhdmType() == UHDM::uhdmconstant)
                    pkgParamConst[&member] = (UHDM::constant*)rhs;
                // Literal inits of typed params carry the param typespec
                // (patched late together with the param ref).
                if (wantTs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    init->kind == ExpressionKind::IntegerLiteral) {
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
        passigns->push_back(pa);
        if (prt) {
            if (topView && !inPackage) {
                pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
            }
            else {
                auto* its = makeParamTs(ps, typedParam);
                if (rhsRt)
                    rhsRt->Actual_typespec(its);
                prt->Actual_typespec(its);
                if (typedParam)
                    its->VpiParent(up);
            }
        }
    }
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
}

UHDM::typespec* UhdmExporter::makeParamTs(const ParameterSymbol& ps, bool typedParam) {
    SourceRange tr(ps.location, ps.location + ps.name.size());
    if (typedParam) {
        if (auto declared = ps.getDeclaredType())
            if (auto tsyn = declared->getTypeSyntax())
                tr = tsyn->sourceRange();
    }
    else {
        for (auto q = ps.getSyntax(); q; q = q->parent) {
            if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                tr = q->sourceRange();
                break;
            }
        }
    }
    auto* its = s.MakeInt_typespec();
    // Untyped parameters carry no signedness flag.
    if (typedParam)
        its->VpiSigned(ps.getType().getCanonicalType().isSigned());
    setLoc(its, tr);
    return its;
}

void UhdmExporter::patchParamTypespecs() {
    for (auto& [ps, up, prt, rhsRt, typedParam] : pendingParamTs) {
        auto* its = makeParamTs(*ps, typedParam);
        if (rhsRt)
            rhsRt->Actual_typespec(its);
        prt->Actual_typespec(its);
        its->VpiParent(prt);
        (void)up;
        (void)typedParam;
    }
    pendingParamTs.clear();
}

void UhdmExporter::analyzeParamEnc(const InstanceBodySymbol& body) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        if (auto init = ps.getInitializer()) {
            if (init->kind != ExpressionKind::IntegerLiteral && isIntEncoded(*init))
                paramIntEnc[&member] = true;
        }
    }
}

UHDM::package* UhdmExporter::emitPackage(const PackageSymbol& pkg, bool topView) {
    std::string prefix = std::string(pkg.name) + "::";
    auto* up = s.MakePackage();
    up->VpiName(pkg.name);
    up->VpiFullName(prefix);
    up->VpiDefName(pkg.name);
    up->VpiParent(d);
    up->VpiFile(fullFilePath(pkg.location));
    if (topView)
        up->VpiTop(true);
    if (auto syn = pkg.getSyntax())
        setLoc(up, syn->sourceRange());
    NetMap none;
    emitParameters(pkg, up, prefix, none, topView, nullptr, true);
    return up;
}

UHDM::module_inst* UhdmExporter::emitModuleDef(const InstanceSymbol& inst) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = "work@" + std::string(def.name);

    DefInfo& info = defMap[&def];
    auto* m = info.mod;
    m->VpiDefName(prefix);
    m->VpiFullName(prefix);
    m->VpiParent(d);
    m->VpiFile(fullFilePath(def.location));
    if (auto syntax = body.getSyntax())
        setLoc(m, syntax->sourceRange());

    emitParameters(body, m, prefix, info.nets, /*topView=*/false, &info, false);

    // Nets: ANSI modules list port-backed nets before locals; non-ANSI
    // modules list locals first (Surelog's collection order).
    bool ansiPorts = true;
    std::set<const Symbol*> portInternals;
    for (auto portBase : body.getPortList()) {
        if (portBase->kind == SymbolKind::Port) {
            auto& ps = portBase->as<PortSymbol>();
            if (!ps.isAnsiPort)
                ansiPorts = false;
            if (ps.internalSymbol)
                portInternals.insert(ps.internalSymbol);
        }
    }
    auto* nets = s.MakeNetVec();
    TsCache defTs;
    auto emitDefPortNets = [&]() {
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::Port) {
                noteUnsupported("port kind: " + std::string(toString(portBase->kind)));
                continue;
            }
            auto& ps = portBase->as<PortSymbol>();
            auto* internal = ps.internalSymbol;
            if (!internal)
                continue;

            auto* n = s.MakeLogic_net();
            n->VpiName(ps.name);
            n->VpiFullName(prefix + "." + std::string(ps.name));
            n->VpiParent(m);
            setLocNamed(n, ps); // Surelog uses the port-list location
            if (int32_t nt = netTypeFor(*internal))
                n->VpiNetType(nt);
            info.nets[internal] = n;
            nets->push_back(n);
        }
    };
    if (ansiPorts)
        emitDefPortNets();
    // Local (non-port) declarations stay logic_nets in the def view, but
    // carry a typespec and explicit net type.
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
            continue;
        auto* n = s.MakeLogic_net();
        n->VpiName(member.name);
        n->VpiFullName(prefix + "." + std::string(member.name));
        n->VpiParent(m);
        setLocNamed(n, member);
        if (int32_t nt = netTypeFor(member))
            n->VpiNetType(nt);
        auto* ts = sharedTypespec(member, defTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(member.name));
        rt->VpiParent(n);
        rt->Actual_typespec(ts);
        n->Typespec(rt);
        info.nets[&member] = n;
        nets->push_back(n);
    }
    if (!ansiPorts)
        emitDefPortNets();
    if (!nets->empty())
        m->Nets(nets);

    // Def-view cont_assigns come before ports (their typespecs precede the
    // port typespecs in Surelog's arena).
    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false, nullptr);

    // Def-view ports share one typespec object per declaration (Surelog's
    // TypespecCache behavior), with no parent set.
    emitPorts(body, m, prefix, info.nets, /*topView=*/false, &defTs);

    // Child instance references (def view uses ref_module stubs).
    auto* refmods = s.MakeRef_moduleVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        auto& child = member.as<InstanceSymbol>();
        auto* rm = s.MakeRef_module();
        rm->VpiName(child.name);
        rm->VpiDefName("work@" + std::string(child.getDefinition().name));
        rm->VpiParent(m);
        setLoc(rm, SourceRange(child.location, child.location + child.name.size()));
        if (auto it = defMap.find(&child.getDefinition()); it != defMap.end())
            rm->Actual_group(it->second.mod);

        auto* rports = s.MakePortVec();
        for (auto conn : child.getPortConnections()) {
            auto* p = s.MakePort();
            p->VpiName(conn->port.name);
            p->VpiParent(rm);
            if (auto npc = findConnSyntax(child, conn->port.name))
                setLoc(p, npc->sourceRange());
            if (auto expr = connectionExpr(*conn)) {
                if (expr->kind == ExpressionKind::NamedValue) {
                    auto& nv = expr->as<NamedValueExpression>();
                    auto* r = s.MakeRef_obj();
                    r->VpiName(nv.symbol.name);
                    r->VpiFullName(prefix + "." + std::string(child.name) + "." +
                                   std::string(conn->port.name) + "." +
                                   std::string(nv.symbol.name));
                    r->VpiParent(p);
                    setLoc(r, expr->sourceRange);
                    if (auto nit = info.nets.find(&nv.symbol); nit != info.nets.end())
                        r->Actual_group(nit->second);
                    p->High_conn(r);
                }
                else if (auto* h = emitExpr(*expr, p, prefix, info.nets)) {
                    p->High_conn(h);
                }
            }
            rports->push_back(p);
        }
        if (!rports->empty())
            rm->Ports(rports);
        refmods->push_back(rm);
    }
    if (!refmods->empty())
        m->Ref_modules(refmods);

    // Processes (collect referenced signals: they drive typespec
    // reparenting in the instance view)
    auto* procs = s.MakeProcess_stmtVec();
    refCollector = &info.processRefs;
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock) {
            auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, info.nets);
            if (p) {
                procs->push_back(p);
                info.processes.push_back(p);
            }
        }
    }
    refCollector = nullptr;
    if (!procs->empty())
        m->Process(procs);

    return m;
}

UHDM::module_inst* UhdmExporter::emitInstance(const InstanceSymbol& inst, const std::string& path,
                                              UHDM::module_inst* parentM, NetMap* parentNets,
                                              std::set<const Symbol*>* parentRefs, bool isTop) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    // Surelog materializes a definition the first time the instance tree
    // reaches it; typespec creation order depends on this.
    if (!defMap[&def].filled) {
        defMap[&def].filled = true;
        emitModuleDef(inst);
    }
    std::string prefix = path;
    std::string defPrefix = "work@" + std::string(def.name);
    std::string parentPrefix;
    if (parentM && parentM->VpiFullName().length())
        parentPrefix = std::string(parentM->VpiFullName());

    auto* m = s.MakeModule_inst();
    m->VpiDefName(defPrefix);
    m->VpiFullName(prefix);
    m->VpiFile(fullFilePath(def.location));
    if (isTop) {
        m->VpiName(prefix);
        m->VpiParent(d);
        m->VpiTop(true);
        m->VpiTopModule(true);
        if (auto syntax = body.getSyntax())
            setLoc(m, syntax->sourceRange());
    }
    else {
        m->VpiName(inst.name);
        m->VpiParent(parentM);
        m->Instance(parentM);
        m->Module_inst(parentM);
        m->VpiDefFile(fullFilePath(def.location));
        m->VpiDefLineNo((int32_t)sm->getLineNumber(def.location));
        // The child instance spans the whole instantiation statement.
        if (auto syn = inst.getSyntax()) {
            const syntax::SyntaxNode* stmtSyn = syn;
            while (stmtSyn->parent &&
                   stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation) {
                stmtSyn = stmtSyn->parent;
            }
            setLoc(m, stmtSyn->sourceRange());
        }
    }

    // Top view gets its own net objects, each carrying a typespec. The
    // typespec object is shared per declaration (Surelog's TypespecCache),
    // and its parent is overwritten by each net using it, so it ends up
    // pointing at the last net of the declaration.
    NetMap topNets;
    TsCache netTs;
    std::set<const Symbol*> instRefs;
    analyzeParamEnc(body);
    {
        auto pit = defMap.find(&def);
        emitParameters(body, m, prefix, topNets, /*topView=*/true,
                       pit != defMap.end() ? &pit->second : nullptr, false);
    }
    std::vector<std::pair<const Symbol*, UHDM::any*>> sigOrder;
    bool ansiPorts = true;
    std::set<const Symbol*> portInternals;
    for (auto portBase : body.getPortList()) {
        if (portBase->kind == SymbolKind::Port) {
            auto& ps = portBase->as<PortSymbol>();
            if (!ps.isAnsiPort)
                ansiPorts = false;
            if (ps.internalSymbol)
                portInternals.insert(ps.internalSymbol);
        }
    }
    auto* nets = s.MakeNetVec();
    auto* vars = s.MakeVariablesVec();
    auto emitInstPortNets = [&]() {
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        std::string fullName = prefix + "." + std::string(ps.name);
        auto* ts = sharedTypespec(*internal, netTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->Actual_typespec(ts);

        if (auto* v = makeVar(*internal, /*portBacked=*/true)) {
            v->VpiName(ps.name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            setLocNamed(v, ps);
            rt->VpiParent(v);
            v->Typespec(rt);
            topNets[internal] = v;
            sigOrder.emplace_back(internal, v);
            vars->push_back(v);
        }
        else {
            auto* n = s.MakeLogic_net();
            n->VpiName(ps.name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            setLocNamed(n, ps);
            if (int32_t nt = netTypeFor(*internal))
                n->VpiNetType(nt);
            if (internal->getDeclaredType() &&
                internal->getDeclaredType()->getType().isSigned())
                n->VpiSigned(true);
            rt->VpiParent(n);
            n->Typespec(rt);
            topNets[internal] = n;
            sigOrder.emplace_back(internal, n);
            nets->push_back(n);
        }
    }
    };
    if (ansiPorts)
        emitInstPortNets();
    // Local (non-port) declarations: logic/reg variables become logic_vars,
    // explicit nets stay logic_nets.
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
            continue;
        std::string fullName = prefix + "." + std::string(member.name);
        auto* ts = sharedTypespec(member, netTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->Actual_typespec(ts);
        if (auto* v = makeVar(member, /*portBacked=*/false)) {
            v->VpiName(member.name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            setLocNamed(v, member);
            rt->VpiParent(v);
            v->Typespec(rt);
            topNets[&member] = v;
            sigOrder.emplace_back(&member, v);
            vars->push_back(v);
        }
        else {
            auto* n = s.MakeLogic_net();
            n->VpiName(member.name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            setLocNamed(n, member);
            if (int32_t nt = netTypeFor(member))
                n->VpiNetType(nt);
            rt->VpiParent(n);
            n->Typespec(rt);
            topNets[&member] = n;
            sigOrder.emplace_back(&member, n);
            nets->push_back(n);
        }
    }
    if (!ansiPorts)
        emitInstPortNets();
    if (!nets->empty())
        m->Nets(nets);
    if (!vars->empty())
        m->Variables(vars);

    // Children are elaborated before the instance's own ports (typespec
    // creation order follows Surelog).
    auto* children = s.MakeModule_instVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            children->push_back(emitInstance(child, prefix + "." + std::string(child.name), m,
                                             &topNets, &instRefs, /*isTop=*/false));
        }
    }
    if (!children->empty())
        m->Modules(children);

    // Instance-view ports each get a fresh typespec object (no sharing).
    auto* ports = s.MakePortVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* p = s.MakePort();
        p->VpiName(ps.name);
        p->VpiParent(m);
        setLocNamed(p, ps);
        switch (ps.direction) {
            case ArgumentDirection::In:
                p->VpiDirection(vpiInput);
                break;
            case ArgumentDirection::Out:
                p->VpiDirection(vpiOutput);
                break;
            case ArgumentDirection::InOut:
                p->VpiDirection(vpiInout);
                break;
            default:
                noteUnsupported("port direction");
                break;
        }

        const PortConnection* conn = nullptr;
        if (!isTop) {
            for (auto c : inst.getPortConnections()) {
                if (&c->port == portBase) {
                    conn = c;
                    break;
                }
            }
        }

        auto* lc = s.MakeRef_obj();
        lc->VpiName(ps.name);
        lc->VpiFullName(prefix + "." + std::string(ps.name));
        lc->VpiParent(p);
        if (!isTop) {
            // Child low conns anchor at the formal name in the connection.
            if (auto npc = findConnSyntax(inst, ps.name))
                setLoc(lc, SourceRange(npc->name.location(),
                                       npc->name.location() + ps.name.size()));
            else
                setLocNamed(lc, ps);
        }
        else {
            setLocNamed(lc, ps);
        }
        if (auto it = topNets.find(internal); it != topNets.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        if (conn && parentNets) {
            if (auto expr = connectionExpr(*conn)) {
                // Signals feeding child connections count as instance-view
                // references (drives typespec reparenting in the parent).
                refCollector = parentRefs;
                if (auto* h = emitExpr(*expr, p, parentPrefix, *parentNets))
                    p->High_conn(h);
                refCollector = nullptr;
            }
        }

        auto* pts = makeTypespec(*internal);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(pts);
        p->Typespec(rt);
        ports->push_back(p);
    }
    if (!ports->empty())
        m->Ports(ports);

    {
        auto it = defMap.find(&def);
        emitContAssigns(body, m, prefix, topNets, /*topView=*/true,
                        it != defMap.end() ? &it->second : nullptr, isTop, &instRefs);
    }

    // Deferred parameter typespecs (arena order: after instance ports).
    patchParamTypespecs();

    // Reparent typespecs of signals referenced in processes, re-emitted
    // cont_assigns, or child connections (Surelog's rebind behavior).
    {
        auto dit = defMap.find(&def);
        for (auto& [sym, obj] : sigOrder) {
            bool touched = instRefs.count(sym) ||
                           (dit != defMap.end() && dit->second.processRefs.count(sym));
            if (!touched)
                continue;
            auto* ex = (UHDM::expr*)obj;
            if (ex->Typespec() && ex->Typespec()->Actual_typespec())
                ex->Typespec()->Actual_typespec()->VpiParent(ex);
        }
    }

    // Top modules share the definition's process objects (their hierarchical
    // prefix is identical); child instances get their own copies with the
    // instance path baked into names.
    if (isTop) {
        auto it = defMap.find(&def);
        if (it != defMap.end() && !it->second.processes.empty()) {
            auto* procs = s.MakeProcess_stmtVec();
            for (auto* p : it->second.processes)
                procs->push_back(p);
            m->Process(procs);
        }
    }
    else {
        auto* procs = s.MakeProcess_stmtVec();
        for (auto& member : body.members()) {
            if (member.kind == SymbolKind::ProceduralBlock) {
                if (auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, topNets))
                    procs->push_back(p);
            }
        }
        if (!procs->empty())
            m->Process(procs);
    }

    return m;
}

void UhdmExporter::emitPorts(const InstanceBodySymbol& body, UHDM::module_inst* m,
                             const std::string& prefix,
                             NetMap& netMap, bool topView,
                             TsCache* sharedTs) {
    auto* ports = s.MakePortVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* p = s.MakePort();
        p->VpiName(ps.name);
        p->VpiParent(m);
        setLocNamed(p, ps);
        switch (ps.direction) {
            case ArgumentDirection::In:
                p->VpiDirection(vpiInput);
                break;
            case ArgumentDirection::Out:
                p->VpiDirection(vpiOutput);
                break;
            case ArgumentDirection::InOut:
                p->VpiDirection(vpiInout);
                break;
            default:
                noteUnsupported("port direction");
                break;
        }

        auto* lc = s.MakeRef_obj();
        lc->VpiName(ps.name);
        // Def view: work@mod.<n>.<n> (port-scoped); top view: work@mod.<n>.
        if (topView)
            lc->VpiFullName(prefix + "." + std::string(ps.name));
        else
            lc->VpiFullName(prefix + "." + std::string(ps.name) + "." + std::string(ps.name));
        lc->VpiParent(p);
        setLocNamed(lc, ps);
        if (auto it = netMap.find(internal); it != netMap.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        UHDM::typespec* ts = sharedTs ? sharedTypespec(*internal, *sharedTs)
                                            : makeTypespec(*internal);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(ts);
        p->Typespec(rt);

        ports->push_back(p);
    }
    if (!ports->empty())
        m->Ports(ports);
}

// The location Surelog gives a typespec: the declared type's syntax range for
// explicit types, or a zero-width range at the declaration's *first*
// declarator for implicit types (shared across all declarators).
static SourceLocation firstDeclaratorLoc(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        const syntax::SeparatedSyntaxList<syntax::DeclaratorSyntax>* decls = nullptr;
        if (p->kind == syntax::SyntaxKind::PortDeclaration)
            decls = &p->as<syntax::PortDeclarationSyntax>().declarators;
        else if (p->kind == syntax::SyntaxKind::NetDeclaration)
            decls = &p->as<syntax::NetDeclarationSyntax>().declarators;
        else if (p->kind == syntax::SyntaxKind::DataDeclaration)
            decls = &p->as<syntax::DataDeclarationSyntax>().declarators;
        if (decls && !decls->empty())
            return (*decls)[0]->name.location();

        // ANSI header groups ("input clk, clr"): anchor at the first port of
        // the group (the one that carries the direction token).
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort && p->parent) {
            auto& list = *p->parent;
            const syntax::ImplicitAnsiPortSyntax* groupStart = nullptr;
            for (size_t i = 0; i < list.getChildCount(); i++) {
                auto child = list.childNode(i);
                if (!child || child->kind != syntax::SyntaxKind::ImplicitAnsiPort)
                    continue;
                auto& ap = child->as<syntax::ImplicitAnsiPortSyntax>();
                bool hasHeaderTokens = false;
                if (ap.header->kind == syntax::SyntaxKind::VariablePortHeader) {
                    auto& vh = ap.header->as<syntax::VariablePortHeaderSyntax>();
                    hasHeaderTokens = vh.direction.valid() || vh.varKeyword.valid() ||
                                      vh.dataType->kind != syntax::SyntaxKind::ImplicitType;
                }
                else {
                    hasHeaderTokens = true;
                }
                if (hasHeaderTokens || !groupStart)
                    groupStart = &ap;
                if (child == p)
                    return groupStart->declarator->name.location();
            }
        }
    }
    return sym.location;
}

UHDM::typespec* UhdmExporter::makeTypespec(const Symbol& declSymbol) {
    auto declared = declSymbol.getDeclaredType();
    SourceLocation implicitLoc = firstDeclaratorLoc(declSymbol);
    SourceRange range(implicitLoc, implicitLoc);
    bool explicitType = false;
    if (declared) {
        if (auto tsyn = declared->getTypeSyntax()) {
            if (tsyn->kind != syntax::SyntaxKind::ImplicitType) {
                auto sr = tsyn->sourceRange();
                if (sr.start() != SourceLocation::NoLocation) {
                    range = sr;
                    explicitType = true;
                }
            }
        }
    }
    // Implicit-typed explicit net declarations anchor at the net keyword
    // ("wire w;" / "input wire x" -> the wire token).
    if (!explicitType && declSymbol.kind == SymbolKind::Net) {
        if (auto nh = ansiNetHeader(declSymbol)) {
            range = nh->netType.range();
        }
        else {
            for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
                if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                    range = p->as<syntax::NetDeclarationSyntax>().netType.range();
                    break;
                }
            }
        }
    }

    // Non-logic types get their own typespec classes.
    if (declared) {
        auto& ct = declared->getType().getCanonicalType();
        if (ct.kind == SymbolKind::PredefinedIntegerType) {
            auto& pit = ct.as<PredefinedIntegerType>();
            UHDM::typespec* its = nullptr;
            switch (pit.integerKind) {
                case PredefinedIntegerType::Int: {
                    auto* t = s.MakeInt_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                default:
                    noteUnsupported("integer type kind");
                    break;
            }
            if (its) {
                setLoc(its, range);
                return its;
            }
        }
    }

    auto* ts = s.MakeLogic_typespec();
    if (declared && declared->getType().isSigned())
        ts->VpiSigned(true);
    setLoc(ts, range);

    // Packed dimensions: one uhdm range per dimension, bounds as evaluated
    // UINT constants (64-bit) that keep their source text as decompile.
    // Dims live on IntegerTypeSyntax ("logic [7:0]") or ImplicitTypeSyntax
    // ("input [7:0] a" / "wire [7:0] w").
    if (declared && declared->getType().isPackedArray()) {
        auto tsyn = declared->getTypeSyntax();
        const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dimSyns = nullptr;
        if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind)) {
            dimSyns = &tsyn->as<syntax::IntegerTypeSyntax>().dimensions;
        }
        else if (tsyn && tsyn->kind == syntax::SyntaxKind::ImplicitType) {
            auto& its = tsyn->as<syntax::ImplicitTypeSyntax>();
            if (!its.dimensions.empty()) {
                dimSyns = &its.dimensions;
                // Location: net declarations span the net keyword through the
                // dims; port declarations use the dims range alone.
                SourceRange dr(its.dimensions[0]->sourceRange().start(),
                               its.dimensions[its.dimensions.size() - 1]->sourceRange().end());
                if (auto nh = ansiNetHeader(declSymbol)) {
                    dr = SourceRange(nh->netType.range().start(), dr.end());
                }
                else {
                    for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
                        if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                            dr = SourceRange(
                                p->as<syntax::NetDeclarationSyntax>().netType.range().start(),
                                dr.end());
                            break;
                        }
                    }
                }
                setLoc(ts, dr);
            }
        }
        if (dimSyns) {
            std::vector<ConstantRange> dims;
            const Type* t = &declared->getType().getCanonicalType();
            while (t->isPackedArray()) {
                auto& pat = t->as<PackedArrayType>();
                dims.push_back(pat.range);
                t = &pat.elementType.getCanonicalType();
            }
            if (dims.size() == dimSyns->size()) {
                auto* ranges = s.MakeRangeVec();
                for (size_t i = 0; i < dims.size(); i++) {
                    auto* dimSyn = (*dimSyns)[i];
                    auto* r = s.MakeRange();
                    r->VpiParent(ts);
                    setLoc(r, dimSyn->sourceRange());
                    const syntax::ExpressionSyntax* lsyn = nullptr;
                    const syntax::ExpressionSyntax* rsyn = nullptr;
                    if (dimSyn->specifier &&
                        dimSyn->specifier->kind == syntax::SyntaxKind::RangeDimensionSpecifier) {
                        auto& spec = dimSyn->specifier->as<syntax::RangeDimensionSpecifierSyntax>();
                        if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                            auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                            lsyn = sel.left;
                            rsyn = sel.right;
                        }
                    }
                    r->Left_expr(makeBoundConst(lsyn, dims[i].left, r));
                    r->Right_expr(makeBoundConst(rsyn, dims[i].right, r));
                    ranges->push_back(r);
                }
                ts->Ranges(ranges);
            }
            else {
                noteUnsupported("packed dimension shape");
            }
        }
        else {
            noteUnsupported("packed array without integer type syntax");
        }
    }
    return ts;
}

UHDM::variables* UhdmExporter::makeVar(const Symbol& internal, bool portBacked) {
    auto declared = internal.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& ct = declared->getType().getCanonicalType();
    // Non-port `logic` variables become logic_vars in the elaborated view;
    // `reg` declarations stay logic_nets.
    bool regDecl = false;
    if (auto tsyn = declared->getTypeSyntax())
        regDecl = tsyn->kind == syntax::SyntaxKind::RegType;
    if (!portBacked && !regDecl && internal.kind == SymbolKind::Variable &&
        ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() && ct.isFourState()) {
        auto* v = s.MakeLogic_var();
        v->VpiVisibility(1);
        if (ct.isSigned())
            v->VpiSigned(true);
        return v;
    }
    if (ct.kind == SymbolKind::PredefinedIntegerType) {
        auto& pit = ct.as<PredefinedIntegerType>();
        switch (pit.integerKind) {
            case PredefinedIntegerType::Int: {
                auto* v = s.MakeInt_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Integer: {
                auto* v = s.MakeInteger_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            default:
                return nullptr;
        }
    }
    return nullptr;
}

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr) {
    // Surelog's netlist elaboration re-compiles top-view cont_assign
    // expressions with constant reduction. Fold only genuine expressions,
    // not plain literals.
    if (expr.kind == ExpressionKind::IntegerLiteral)
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

void UhdmExporter::emitContAssigns(const InstanceBodySymbol& body, UHDM::module_inst* m,
                                   const std::string& prefix, NetMap& netMap, bool topView,
                                   DefInfo* defInfo, bool shareWithDef,
                                   std::set<const Symbol*>* instRefs) {
    auto* cas = s.MakeCont_assignVec();
    size_t idx = 0;
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::ContinuousAssign)
            continue;
        auto& casym = member.as<ContinuousAssignSymbol>();
        auto& assign = casym.getAssignment();
        size_t myIdx = idx++;
        if (assign.kind != ExpressionKind::Assignment) {
            noteUnsupported("continuous assign form");
            continue;
        }
        auto& ae = assign.as<AssignmentExpression>();
        // Top modules share the def's cont_assign object unless the RHS
        // contains operations (netlist elaboration re-compiles those, folded
        // or not).
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            !containsOperation(ae.right())) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        setLoc(ca, assign.sourceRange);
        UHDM::any* rhs = topView ? tryFoldConst(ae.right()) : nullptr;
        if (!rhs) {
            if (topView) {
                refCollector = instRefs;
                reemitting = true;
            }
            rhs = emitExpr(ae.right(), ca, prefix, netMap);
            refCollector = nullptr;
            reemitting = false;
        }
        if (rhs)
            ca->Rhs((UHDM::expr*)rhs);
        inLhs = true;
        if (auto* l = emitExpr(ae.left(), ca, prefix, netMap))
            ca->Lhs((UHDM::expr*)l);
        inLhs = false;
        cas->push_back(ca);
        if (defInfo)
            defInfo->contAssigns.push_back(ca);
    }
    if (!cas->empty())
        m->Cont_assigns(cas);
}

UHDM::constant* UhdmExporter::makeBoundConst(const syntax::SyntaxNode* syn, int64_t value,
                                             UHDM::BaseClass* parent) {
    auto* c = s.MakeConstant();
    c->VpiParent(parent);
    c->VpiSize(64);
    c->VpiConstType(vpiUIntConst);
    c->VpiValue("UINT:" + std::to_string(value));
    if (syn) {
        setLoc(c, syn->sourceRange());
        c->VpiDecompile(rawText(syn->sourceRange()));
    }
    return c;
}

UHDM::typespec* UhdmExporter::sharedTypespec(const Symbol& declSymbol, TsCache& cache) {
    // Key on the shared type syntax node so all declarators of one
    // declaration ("input A, B;") reuse the same typespec object.
    const void* key = &declSymbol;
    if (auto declared = declSymbol.getDeclaredType()) {
        if (auto tsyn = declared->getTypeSyntax())
            key = tsyn;
    }
    auto it = cache.find(key);
    if (it != cache.end())
        return it->second;
    auto* ts = makeTypespec(declSymbol);
    cache[key] = ts;
    return ts;
}

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
                        // Event list ranges include the closing paren; a bare
                        // signal event does not.
                        auto end = timing.sourceRange.end();
                        if (timing.kind == TimingControlKind::SignalEvent)
                            end = end + 1;
                        setLoc(ec, SourceRange(stmt.sourceRange.start(), end));
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
            return emitExpr(es.expr, parent, prefix, netMap);
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
                    if (auto* ue = emitExpr(*e, it, prefix, netMap))
                        exprs->push_back(ue);
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
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
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
            if (refCollector)
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
            }
            ref->VpiParent(parent);
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
                noteUnsupported("user function call");
                return nullptr;
            }
            auto* sc = s.MakeSys_func_call();
            std::string name = std::string(call.getSubroutineName());
            if (name.empty() || name[0] != '$')
                name = "$" + name;
            sc->VpiName(name);
            sc->VpiParent(parent);
            setLoc(sc, SourceRange(expr.sourceRange.start(),
                                   expr.sourceRange.start() + name.size()));
            auto* args = s.MakeAnyVec();
            // Call arguments don't count as instance-view references for
            // typespec reparenting.
            auto* savedCollector = refCollector;
            refCollector = nullptr;
            for (auto arg : call.arguments()) {
                if (auto* a = emitExpr(*arg, sc, prefix, netMap))
                    args->push_back(a);
            }
            refCollector = savedCollector;
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
            for (auto o : ce.operands()) {
                if (auto* e = emitExpr(*o, op, prefix, netMap))
                    operands->push_back(e);
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
            suppressConstParent = !reemitting;
            auto* cnt = emitExpr(re.count(), op, prefix, netMap);
            suppressConstParent = false;
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
            if (refCollector)
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
            if (refCollector)
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

std::string UhdmExporter::rawText(SourceRange range) {
    if (range.start() == SourceLocation::NoLocation || range.end() == SourceLocation::NoLocation)
        return "";
    auto text = sm->getSourceText(range.start().buffer());
    size_t start = range.start().offset();
    size_t end = range.end().offset();
    if (end > text.size() || start > end)
        return "";
    return std::string(text.substr(start, end - start));
}

} // namespace slang_uhdm
