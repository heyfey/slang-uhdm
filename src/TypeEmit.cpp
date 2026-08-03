//------------------------------------------------------------------------------
//! @file TypeEmit.cpp
//! @brief Typespecs, bound constants, variable object creation
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"
#include "slang/syntax/SyntaxTree.h"

namespace slang_uhdm {

// Defined below (near the array_var builders): the bare typespec CLASS a
// type maps to (int -> int_typespec, bit -> bit_typespec, ...), with no span
// and no flags. Forward-declared because makeTypeParamDefaultTs needs it.
static UHDM::typespec* bareElemTypespec(UHDM::Serializer& s,
                                        const slang::ast::Type& leaf);

// True when a signal's declared-type packed dimensions reference a PARAMETER
// (its width can be overridden per instance) — such widths keep $bits(sig)
// unfolded; a fixed width (int, logic [7:0]) folds.
static bool typeWidthUsesParam(const Symbol& sym) {
    auto dt = sym.getDeclaredType();
    if (!dt)
        return false;
    auto tsyn = dt->getTypeSyntax();
    if (!tsyn)
        return false;
    bool found = false;
    std::function<void(const syntax::SyntaxNode&)> scan =
        [&](const syntax::SyntaxNode& sn) {
            if (found)
                return;
            if (sn.kind == syntax::SyntaxKind::IdentifierName)
                found = true;
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scan(*cn);
        };
    if (syntax::IntegerTypeSyntax::isKind(tsyn->kind))
        for (auto d : tsyn->as<syntax::IntegerTypeSyntax>().dimensions)
            scan(*d);
    return found;
}

// `namedTypeDimBounds` / `srlgRedIntSyn` live in EmitHelpers.h — ParamEmit's
// packed-array param typespec builder needs the same two rules.



// A module/interface-local STRUCT typedef whose signal is an INITIALIZED
// UNPACKED ARRAY (tl_h2d_t a[1:0] = '{...}): Surelog re-stamps the shared
// typespec's END at that declarator's FIRST unpacked dimension. A BARE array
// declarator (mem_s memArray[8]) does NOT re-stamp (OneStruct). Returns
// NoLocation when no such signal exists. Last use wins.
SourceLocation UhdmExporter::structTypedefUseEnd(const InstanceBodySymbol& body,
                                                 const Type& ta) {
    SourceLocation out = SourceLocation::NoLocation;
    for (auto& mb : body.members()) {
        if (mb.kind != SymbolKind::Net && mb.kind != SymbolKind::Variable)
            continue;
        auto dt = mb.getDeclaredType();
        if (!dt || dt->getType().getCanonicalType().kind !=
                       SymbolKind::FixedSizeUnpackedArrayType)
            continue;
        const Type* el = &dt->getType().getCanonicalType();
        while (el->getCanonicalType().kind ==
               SymbolKind::FixedSizeUnpackedArrayType)
            el = &el->getCanonicalType()
                      .as<FixedSizeUnpackedArrayType>()
                      .elementType;
        if ((const Type*)el != (const Type*)&ta)
            continue;
        auto dsyn = mb.getSyntax();
        if (!dsyn || dsyn->kind != syntax::SyntaxKind::Declarator)
            continue;
        auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
        if (dd.dimensions.empty() || !dd.initializer)
            continue;
        out = dd.dimensions[0]->sourceRange().end();
    }
    return out;
}

const syntax::SyntaxNode* UhdmExporter::classScopeTypeRef(
    const syntax::SyntaxNode* typeSyn) {
    if (!typeSyn)
        return nullptr;
    auto* nt = typeSyn->as_if<syntax::NamedTypeSyntax>();
    if (!nt)
        return nullptr;
    auto* sn = nt->name->as_if<syntax::ScopedNameSyntax>();
    // Only a PARAMETERIZED class prefix (`C#(...)::`) is recognized: a bare
    // `X::T` is a package reference in every corpus test that reaches here,
    // and slang cannot resolve `C::T` for a generic class at all.
    if (!sn || !sn->left->as_if<syntax::ClassNameSyntax>())
        return nullptr;
    return sn;
}

const syntax::SyntaxNode* UhdmExporter::classScopeTypeRef(const Symbol& declSymbol) {
    auto* dt = declSymbol.getDeclaredType();
    return dt ? classScopeTypeRef(dt->getTypeSyntax()) : nullptr;
}

UHDM::typespec* UhdmExporter::makeClassScopeTs(const syntax::SyntaxNode& scopedName) {
    auto& sn = scopedName.as<syntax::ScopedNameSyntax>();
    auto* uts = s.MakeUnsupported_typespec();
    // Named by the class IDENTIFIER (the `#(...)` actuals are dropped) and
    // spanned from the class name through the `::` separator — Surelog's
    // class_scope node, the same span rule makeTypespec's scoped class-handle
    // arm uses.
    uts->VpiName(
        std::string(sn.left->as<syntax::ClassNameSyntax>().identifier.valueText()) +
        "::" + std::string(rawText(sn.right->sourceRange())));
    setLoc(uts, SourceRange(sn.left->sourceRange().start(),
                            sn.separator.range().end()));
    return uts;
}

UHDM::typespec* UhdmExporter::makeTypespec(const Symbol& declSymbol,
                                           const syntax::SyntaxNode* typeSynOverride,
                                           const PortSymbol* portCtx) {
    if (auto* csn = classScopeTypeRef(typeSynOverride ? typeSynOverride
                                                      : (declSymbol.getDeclaredType()
                                                             ? declSymbol.getDeclaredType()
                                                                   ->getTypeSyntax()
                                                             : nullptr)))
        return makeClassScopeTs(*csn);
    // A local var of a function inside an elaborated GEN block: fold its
    // param-ref type bounds (concrete instance). declSymbol's parent chain
    // reaches the function+gen-block even in the deferred typespec drain.
    const Scope* savedGbf = genBlockFnScope;
    {
        bool inFn = false, inGen = false;
        const Scope* fnScope = nullptr;
        for (auto sc = declSymbol.getParentScope(); sc;
             sc = sc->asSymbol().getParentScope()) {
            auto k = sc->asSymbol().kind;
            if (k == SymbolKind::Subroutine) {
                inFn = true;
                fnScope = sc;
            }
            if (k == SymbolKind::GenerateBlock ||
                k == SymbolKind::GenerateBlockArray)
                inGen = true;
            if (k == SymbolKind::InstanceBody)
                break;
        }
        // The function RETURN type keeps its param-ref bounds as refs (like a
        // normal function type); only genuine LOCAL VARS fold. So exclude the
        // subroutine's return-value var.
        if (inFn && inGen && fnScope) {
            auto& fnSym = fnScope->asSymbol();
            const Symbol* retVar =
                fnSym.kind == SymbolKind::Subroutine
                    ? fnSym.as<SubroutineSymbol>().returnValVar
                    : nullptr;
            if (&declSymbol != retVar)
                genBlockFnScope = fnScope;
        }
    }
    struct GbfGuard {
        const Scope*& slot;
        const Scope* prev;
        ~GbfGuard() { slot = prev; }
    } gbfGuard{genBlockFnScope, savedGbf};
    auto declared = declSymbol.getDeclaredType();
    // `CrossQueueType`/`CrossValType` are LRM-implicit types a cover cross
    // publishes inside its bins block; slang synthesizes them as TypeAliases
    // in the CoverCrossBody scope, Surelog has no such scope and its
    // CompileType falls through to the catch-all: an unsupported_typespec
    // NAMED as written, at the type-reference span (CrossFunc).
    if (declared && declared->getType().kind == SymbolKind::TypeAlias) {
        auto& xa0 = declared->getType().as<TypeAliasType>();
        if (auto xsc0 = xa0.getParentScope();
            xsc0 && xsc0->asSymbol().kind == SymbolKind::CoverCrossBody) {
            auto* uts0 = s.MakeUnsupported_typespec();
            uts0->VpiName(xa0.name);
            if (typeSynOverride)
                setLoc(uts0, typeSynOverride->sourceRange());
            else if (auto tsyn1 = declared->getTypeSyntax())
                setLoc(uts0, tsyn1->sourceRange());
            return uts0;
        }
    }
    // A CLASS-NESTED typedef referenced from a class that sorts EARLIER by
    // name (`uvm_resource_base` -> `uvm_resource_types::access_t`) has not
    // been compiled yet when this reference is emitted: Surelog compiles
    // every class's TYPES before binding any body, so build the owning
    // class's typedefs on demand and share them. Record that it happened —
    // Surelog's variable-class fallback for such a forward reference is a
    // class_var (probe-verified pair over one source: owner sorted BEFORE
    // -> struct_var, owner sorted AFTER -> class_var, both bound to the SAME
    // struct_typespec). IOClassStruct.
    if (declared && !bypassTypedefShare &&
        declared->getType().kind == SymbolKind::TypeAlias &&
        !typedefTs.count(&declared->getType())) {
        auto& ta9 = declared->getType().as<TypeAliasType>();
        if (auto* osc9 = ta9.getParentScope();
            osc9 && osc9->asSymbol().kind == SymbolKind::ClassType) {
            auto& ocl9 = osc9->asSymbol().as<ClassType>();
            auto* opsc9 = ocl9.getParentScope();
            // Only PACKAGE/class-nested classes: a $unit-level class displays
            // as `work@C`, a name this path cannot reconstruct.
            if (opsc9 && (opsc9->asSymbol().kind == SymbolKind::Package ||
                          opsc9->asSymbol().kind == SymbolKind::ClassType)) {
                buildClassTypedefTs(ocl9, std::string(ocl9.name));
                if (typedefTs.count(&declared->getType()))
                    onDemandClassTypedefs.insert((const void*)&declared->getType());
            }
        }
    }
    // Typedef'd declarations share the typedef's typespec object; anonymous
    // enums build an unnamed, unlocated enum_typespec per declaration.
    if (declared) {
        if (auto it = typedefTs.find(&declared->getType());
            it != typedefTs.end() && !bypassTypedefShare) {
            // A PACKAGE typedef has two objects: the def-view one (listed in
            // uhdmallPackages, keeping the typedef span) and the ELABORATED
            // one (uhdmtopPackages, re-parented/re-scoped/span-stretched by
            // its importer). Every real SIGNAL use binds the elaborated
            // object — in both the def and the instance view (Surelog shares
            // one mutated object across them). STRUCT typedefs included: what
            // used to break there (NSAP) was a nested inner-struct leaf left
            // without vpiInstance, not the def/elab choice.
            if (auto t9 = pkgTopTypedefTs.find((const void*)&declared->getType());
                t9 != pkgTopTypedefTs.end() &&
                t9->second->UhdmType() == it->second->UhdmType())
                return t9->second;
            return it->second;
        }
        // A COVERGROUP handle (`cg cg_inst = new(3);`) has no UHDM type of
        // its own: Surelog's CompileType falls through to the catch-all and
        // mints an unsupported_typespec carrying the WRITTEN type name, at
        // the whole declaration's span (CrossFunc). The def view's net
        // references it; the elab view's logic_var references nothing.
        if (auto& cg0 = declared->getType().getCanonicalType();
            cg0.kind == SymbolKind::CovergroupType) {
            auto* uts = s.MakeUnsupported_typespec();
            uts->VpiName(cg0.name);
            if (auto dsyn0 = declSymbol.getSyntax())
                setLoc(uts, dsyn0->parent ? dsyn0->parent->sourceRange()
                                          : dsyn0->sourceRange());
            else if (auto tsyn0 = declared->getTypeSyntax())
                setLoc(uts, tsyn0->sourceRange());
            return uts;
        }
        // Class handles: a fresh class_typespec per declaration, named by the
        // class and linked to its class_defn.  An ARRAY of class handles
        // (`C q[$]`, `C d[]`, `C a[4]`) types on its ELEMENT here: the dims
        // live on the array_typespec that wraps this one.
        if (auto& ct0 = arrayElemLeaf(declared->getType()).getCanonicalType();
            ct0.kind == SymbolKind::ClassType) {
            auto* cts = s.MakeClass_typespec();
            // A var declared INSIDE A PROCESS whose class is declared in the
            // SAME instance gets an UNNAMED class_typespec — Surelog's
            // statement-scope CompileType cannot name an instance-local class
            // (measured: `module m1; class C; ... initial begin C d = new();`
            // and the same in a program -> unnamed, while the module-scope
            // `C e;` and a $unit-scope class both stay named). vpiClassDefn is
            // linked either way. SimpleConstraint `frame_t frame = new();`.
            // A CLASS-METHOD body local is unnamed the same way, wherever its
            // class lives (measured: `package pk; class C; class D; function
            // void f(); C m2; begin C m3; end` -> both unnamed, while the
            // class PROPERTY `C m1` and a module function's `pk::C m5` keep
            // their names). Surelog compiles a class body with no enclosing
            // design scope to name the type from.
            bool inClassMethod0 = false;
            {
                bool sawSub0 = false;
                for (auto sc0 = declSymbol.getParentScope(); sc0;
                     sc0 = sc0->asSymbol().getParentScope()) {
                    auto k0 = sc0->asSymbol().kind;
                    if (k0 == SymbolKind::Subroutine)
                        sawSub0 = true;
                    // The class PROPERTY `C m1` (no subroutine between it and
                    // its class) keeps its name.
                    if (k0 == SymbolKind::ClassType) {
                        inClassMethod0 = sawSub0;
                        break;
                    }
                    if (k0 == SymbolKind::InstanceBody || k0 == SymbolKind::Package ||
                        k0 == SymbolKind::CompilationUnit)
                        break;
                }
            }
            // A class-method FORMAL is not a body local: Surelog compiles the
            // argument list from the prototype's own scope and keeps the name
            // (`extern function void add_testsuite(svunit_testsuite ts)` ->
            // class_typespec named svunit_testsuite on BOTH the prototype's
            // and the definition's io_decl).
            if (declSymbol.kind == SymbolKind::FormalArgument)
                inClassMethod0 = false;
            if (!inClassMethod0 &&
                !(declSymbol.getParentScope() &&
                  declSymbol.getParentScope()->asSymbol().kind ==
                      SymbolKind::StatementBlock &&
                  ct0.getParentScope() &&
                  ct0.getParentScope()->asSymbol().kind == SymbolKind::InstanceBody))
                cts->VpiName(ct0.name);
            if (auto* bcd0 = classDefnFor(ct0))
                cts->Class_defn(bcd0);
            else
                pendingClassTsLink.push_back({cts, &ct0});
            // `#(...)` on the declared type puts the specialization on the
            // typespec (ClassParamAsParam / ClassTypeParam).
            emitClassTsParams(cts, ct0.as<ClassType>(), std::string(ct0.name));
            if (auto tsyn0 = declared->getTypeSyntax()) {
                setLoc(cts, tsyn0->sourceRange());
                // A SCOPED class reference (pack::doorOpen) is named by the
                // WRITTEN text and located at the class_scope prefix Surelog
                // collects the node from (`pack::`).
                if (auto* nt0 = tsyn0->as_if<syntax::NamedTypeSyntax>())
                    if (auto* sn0 = nt0->name->as_if<syntax::ScopedNameSyntax>()) {
                        cts->VpiName(std::string(rawText(sn0->sourceRange())));
                        setLoc(cts, SourceRange(sn0->left->sourceRange().start(),
                                                sn0->separator.range().end()));
                    }
            }
            return cts;
        }
        if (!typeSynOverride) {
            auto& ct0 = declared->getType().getCanonicalType();
            if (ct0.kind == SymbolKind::EnumType)
                return buildEnumTs(ct0.as<EnumType>(), declared->getTypeSyntax(), "",
                                   /*implicitBaseRef=*/true);
        }
    }
    // Ports whose net is re-declared in the body ("input clock; wire clock;")
    // build their port typespec from the PORT declaration (its dims/type),
    // not the body re-declaration.
    bool mergedPort = portCtx && hasBodyDecl(declSymbol);
    const syntax::SyntaxNode* portDeclTypeSyn = nullptr;
    if (mergedPort) {
        auto scope0 = declSymbol.getParentScope();
        const syntax::SyntaxNode* msyn0 =
            scope0 ? scope0->asSymbol().getSyntax() : nullptr;
        if (msyn0 && msyn0->kind == syntax::SyntaxKind::ModuleDeclaration) {
            for (auto member : msyn0->as<syntax::ModuleDeclarationSyntax>().members) {
                if (member->kind != syntax::SyntaxKind::PortDeclaration)
                    continue;
                auto& pd = member->as<syntax::PortDeclarationSyntax>();
                bool found = false;
                for (auto dcl : pd.declarators) {
                    if (dcl->name.valueText() == portCtx->name)
                        found = true;
                }
                if (found) {
                    if (pd.header->kind == syntax::SyntaxKind::VariablePortHeader)
                        portDeclTypeSyn =
                            pd.header->as<syntax::VariablePortHeaderSyntax>().dataType;
                    else if (pd.header->kind == syntax::SyntaxKind::NetPortHeader)
                        portDeclTypeSyn =
                            pd.header->as<syntax::NetPortHeaderSyntax>().dataType;
                    break;
                }
            }
        }
        if (portDeclTypeSyn)
            typeSynOverride = portDeclTypeSyn;
    }
    auto typeSynFor = [&]() -> const syntax::SyntaxNode* {
        if (typeSynOverride)
            return typeSynOverride;
        return declared ? declared->getTypeSyntax() : nullptr;
    };
    // Merged ports anchor at the first declarator of the port declaration
    // group ("input clock,reset,..." -> clock); reach it through the port's
    // own declared-type syntax.
    SourceLocation implicitLoc;
    if (mergedPort) {
        implicitLoc = portCtx->location;
        auto scope = declSymbol.getParentScope();
        const syntax::SyntaxNode* msyn =
            scope ? scope->asSymbol().getSyntax() : nullptr;
        if (msyn && msyn->kind == syntax::SyntaxKind::ModuleDeclaration) {
            for (auto member : msyn->as<syntax::ModuleDeclarationSyntax>().members) {
                if (member->kind != syntax::SyntaxKind::PortDeclaration)
                    continue;
                auto& pd = member->as<syntax::PortDeclarationSyntax>();
                bool found = false;
                for (auto dcl : pd.declarators) {
                    if (dcl->name.valueText() == portCtx->name)
                        found = true;
                }
                if (found && !pd.declarators.empty()) {
                    implicitLoc = pd.declarators[0]->name.location();
                    break;
                }
            }
        }
    }
    else {
        implicitLoc = firstDeclaratorLoc(declSymbol);
    }
    SourceRange range(implicitLoc, implicitLoc);
    bool explicitType = false;
    if (declared && !(mergedPort && !portDeclTypeSyn)) {
        if (auto tsyn = typeSynFor()) {
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
    bool netKeywordAnchor = false;
    if (!explicitType && !mergedPort && declSymbol.kind == SymbolKind::Net) {
        if (auto nh = ansiNetHeader(declSymbol)) {
            range = nh->netType.range();
            netKeywordAnchor = true;
        }
        else {
            for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
                if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                    range = p->as<syntax::NetDeclarationSyntax>().netType.range();
                    netKeywordAnchor = true;
                    break;
                }
            }
        }
    }
    // Implicit types with a signing keyword ("input signed [3:0] x") anchor
    // at the signing token alone.
    bool implicitSigning = false;
    if (!explicitType && !netKeywordAnchor && declared) {
        if (auto tsyn = typeSynFor()) {
            if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                auto& its = tsyn->as<syntax::ImplicitTypeSyntax>();
                if (its.signing.valid()) {
                    range = its.signing.range();
                    implicitSigning = true;
                }
            }
        }
    }

    // Non-logic types get their own typespec classes. Unpacked arrays
    // resolve to their ELEMENT type (the dims become array_var ranges).
    if (declared) {
        const Type* et = &declared->getType().getCanonicalType();
        // A DYNAMIC array resolves to its element type the same way a fixed
        // unpacked array does; its single unsized dim becomes the declaring
        // object's [0:"unsized"] range (FileResolutionFunction's
        // `input real driver []` -> real_typespec + unsized io_decl range).
        // A QUEUE resolves the same way (its `[$]` dim becomes the wrapping
        // array_typespec's [0:$] range) — Surelog, probe-verified on
        // `C q[$]` / `int q[$]` class-method locals (ClassVar).  An
        // ASSOCIATIVE dim resolves the same way — its index type rides the
        // wrapping array_typespec's vpiIndexTypespec, so the declaration
        // still types on its ELEMENT (`int a [int]` -> int_typespec, not the
        // logic_typespec the integral fallback below would give; DynArrayKind).
        while (et->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType ||
               et->getCanonicalType().kind == SymbolKind::DynamicArrayType ||
               et->getCanonicalType().kind == SymbolKind::AssociativeArrayType ||
               et->getCanonicalType().kind == SymbolKind::QueueType) {
            auto& ect = et->getCanonicalType();
            et = ect.kind == SymbolKind::DynamicArrayType
                     ? &ect.as<DynamicArrayType>().elementType
                 : ect.kind == SymbolKind::QueueType
                     ? &ect.as<QueueType>().elementType
                 : ect.kind == SymbolKind::AssociativeArrayType
                     ? &ect.as<AssociativeArrayType>().elementType
                     : &ect.as<FixedSizeUnpackedArrayType>().elementType;
        }
        auto& ct = et->getCanonicalType();
        if (ct.kind == SymbolKind::FloatingType) {
            UHDM::typespec* t = ct.as<FloatingType>().floatKind == FloatingType::ShortReal
                                    ? (UHDM::typespec*)s.MakeShort_real_typespec()
                                    : (UHDM::typespec*)s.MakeReal_typespec();
            setLoc(t, range);
            return t;
        }
        if (ct.kind == SymbolKind::StringType) {
            auto* t = s.MakeString_typespec();
            setLoc(t, range);
            return t;
        }
        if (ct.kind == SymbolKind::CHandleType) {
            auto* t = s.MakeChandle_typespec();
            setLoc(t, range);
            return t;
        }
        if (ct.kind == SymbolKind::EventType) {
            auto* t = s.MakeEvent_typespec();
            setLoc(t, range);
            return t;
        }
        // Packed array whose leaf element is a shared struct/enum typedef ->
        // packed_array_typespec { dims + Elem_typespec ref -> the typedef }.
        if (declared->getType().isPackedArray() && !bypassTypedefShare) {
        int arrDims = 0;
        const Type* leaf = &declared->getType().getCanonicalType();
        while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
            arrDims++;
            leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
        }
        auto& lc = leaf->getCanonicalType();
        if (lc.kind == SymbolKind::PackedStructType || lc.kind == SymbolKind::EnumType) {
            UHDM::typespec* elemTs = nullptr;
            for (auto& [sym, tsp] : typedefTs)
                if (sym->kind == SymbolKind::TypeAlias &&
                    &sym->as<TypeAliasType>().getCanonicalType() == &lc) {
                    elemTs = tsp;
                    break;
                }
            if (elemTs) {
                auto* pat = s.MakePacked_array_typespec();
                // Semantic dims from the packed-type walk; source spans from
                // a bracket scan between type name and declarator (named
                // types carry the dims in neither syntax node).
                std::vector<ConstantRange> arrRanges;
                {
                    const Type* t2 = &declared->getType().getCanonicalType();
                    for (int i = 0; i < arrDims; i++) {
                        arrRanges.push_back(
                            t2->getCanonicalType().as<PackedArrayType>().range);
                        t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
                    }
                }
                std::vector<DimSpan> spans;
                {
                    // Prefer the type-syntax..declarator span; fall back to
                    // the typespec range (struct members expose no
                    // getTypeSyntax()).
                    SourceLocation tStart = range.start();
                    SourceLocation tEnd = declSymbol.location;
                    if (auto tsn2 = declared->getTypeSyntax())
                        tStart = tsn2->sourceRange().start();
                    if (!(tStart < tEnd))
                        tEnd = range.end();
                    if (tStart < tEnd)
                        spans = scanDimSpans(
                            std::string(rawText(SourceRange(tStart, tEnd))), tStart);
                }
                SourceRange patLoc = range;
                // A multi-dim packed array typespec span truncates to the end
                // of the FIRST dimension (Surelog), like the def-net path — but
                // NOT for a struct/union member, which keeps its full span.
                if (arrDims >= 2 && !spans.empty() && !structMemberTsCtx)
                    patLoc = SourceRange(range.start(), spans[0].range.end());
                auto* rvec = s.MakeRangeVec();
                for (int i = 0; i < arrDims; i++) {
                    auto* r = s.MakeRange();
                    r->VpiParent(pat);
                    auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                        // A packed-dim bound that is a bare ENUM-CONSTANT name
                        // (logic [s_e:n_e] arr, s_e an enum member) stays
                        // SYMBOLIC in the standalone typespec: Surelog emits a
                        // ref_obj -> the enum_const (the packed_array_VAR view
                        // still folds it to a constant). Resolve the source
                        // identifier in the declaration's own scope.
                        if (loc) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            if (ident) {
                                if (auto* psc = declSymbol.getParentScope())
                                    if (auto* bsym = psc->find(raw);
                                        bsym &&
                                        bsym->kind == SymbolKind::EnumValue)
                                        if (auto eit = enumConstMap.find(bsym);
                                            eit != enumConstMap.end() &&
                                            eit->second->UhdmType() ==
                                                UHDM::uhdmenum_const) {
                                            auto* ro = s.MakeRef_obj();
                                            ro->VpiName(raw);
                                            ro->VpiParent(r);
                                            setLoc(ro, *loc);
                                            ro->Actual_group(eit->second);
                                            return (UHDM::expr*)ro;
                                        }
                            }
                        }
                        // A bound naming a param of ANOTHER package (imported
                        // into the struct's package) is RESOLVED, not kept
                        // symbolic: Surelog folds it like any cross-package
                        // read (BitSelectOfParameterPassedToSubmodule's
                        // pad_type_e [NDioPads-1:0] with NDioPads owned by
                        // prim_pad_wrapper_pkg). Only a SAME-package param
                        // stays a member-scoped ref.
                        bool foreignPkgBound = false;
                        if (loc && structPkgScope) {
                            std::string rawF(rawText(*loc));
                            std::string idF;
                            for (char ch : rawF) {
                                if (isalnum((unsigned char)ch) || ch == '_')
                                    idF += ch;
                                else if (!idF.empty())
                                    break;
                            }
                            if (!idF.empty() &&
                                !isdigit((unsigned char)idF[0]))
                                if (auto* syF =
                                        Lookup::unqualified(*structPkgScope, idF);
                                    syF && syF->kind == SymbolKind::Parameter &&
                                    syF->getParentScope() &&
                                    syF->getParentScope()->asSymbol().kind ==
                                        SymbolKind::Package &&
                                    syF->getParentScope() != structPkgScope)
                                    foreignPkgBound = true;
                        }
                        // Typedef-member context: an IDENTIFIER bound
                        // ([MpRegions:0]) keeps a member-scoped ref_obj
                        // chained to the pkg param's def Rhs (Surelog).
                        if (loc && tfContext && structMemberTsCtx &&
                            !syntaxRefPrefix.empty()) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            // The member-scoped ref chains to the package
                            // param's DEF-view Rhs constant. pkgParamDefRhs is
                            // rewritten per view (the top pass overwrites it),
                            // and this ts is built in the TOP pass then
                            // cross-wired into the DEF struct — so prefer the
                            // def-only pkgParamConst record.
                            auto bindPkgParam = [&](UHDM::ref_obj* ro,
                                                    const std::string& nm) {
                                for (auto& [ps9, c9] : pkgParamConst)
                                    if (ps9->name == nm && ps9->getParentScope() &&
                                        ps9->getParentScope()->asSymbol().kind ==
                                            SymbolKind::Package) {
                                        ro->Actual_group(c9);
                                        return;
                                    }
                                for (auto& [ps9, rhs9] : pkgParamDefRhs)
                                    if (ps9->name == nm && ps9->getParentScope() &&
                                        ps9->getParentScope()->asSymbol().kind ==
                                            SymbolKind::Package) {
                                        ro->Actual_group(rhs9);
                                        return;
                                    }
                            };
                            if (ident && !foreignPkgBound) {
                                auto* ro = s.MakeRef_obj();
                                ro->VpiName(raw);
                                ro->VpiFullName(syntaxRefPrefix + syntaxRefSep +
                                                raw);
                                ro->VpiParent(r);
                                setLoc(ro, *loc);
                                bindPkgParam(ro, raw);
                                return (UHDM::expr*)ro;
                            }
                            // An IDENT-minus-LITERAL bound ([NDioPads-1:0])
                            // keeps its SUB op tree symbolic the same way:
                            // op11 { member-scoped ref_obj -> the param's def
                            // Rhs, UINT literal } at their token sub-spans
                            // (Surelog, BitSelectOfParameterPassedToSubmodule).
                            size_t dash8 = raw.find('-');
                            if (dash8 != std::string::npos && dash8 > 0) {
                                auto trim8 = [](const std::string& t,
                                                size_t& off) {
                                    size_t b = t.find_first_not_of(" \t");
                                    size_t e = t.find_last_not_of(" \t");
                                    if (b == std::string::npos) {
                                        off = 0;
                                        return std::string();
                                    }
                                    off = b;
                                    return t.substr(b, e - b + 1);
                                };
                                size_t lOff = 0, rOff = 0;
                                std::string lTxt =
                                    trim8(raw.substr(0, dash8), lOff);
                                std::string rTxt = trim8(
                                    raw.substr(dash8 + 1), rOff);
                                rOff += dash8 + 1;
                                bool lIdent =
                                    !lTxt.empty() &&
                                    (isalpha((unsigned char)lTxt[0]) ||
                                     lTxt[0] == '_');
                                for (char ch : lTxt)
                                    if (!(isalnum((unsigned char)ch) ||
                                          ch == '_')) {
                                        lIdent = false;
                                        break;
                                    }
                                bool rDigits = !rTxt.empty();
                                for (char ch : rTxt)
                                    if (!isdigit((unsigned char)ch)) {
                                        rDigits = false;
                                        break;
                                    }
                                if (lIdent && rDigits) {
                                    auto* op8 = s.MakeOperation();
                                    op8->VpiOpType(vpiSubOp);
                                    op8->VpiParent(r);
                                    setLoc(op8, *loc);
                                    auto* opnds8 = s.MakeAnyVec();
                                    // A FOREIGN-package bound resolves its
                                    // leaf: the op stays, but the identifier
                                    // becomes the param's VALUE (size 32, a
                                    // member-scoped ts ref -> a copy of the
                                    // param's own int typespec, instanced at
                                    // ITS package) — Surelog only leaves
                                    // SAME-package bounds symbolic.
                                    UHDM::expr* lf8 = nullptr;
                                    if (foreignPkgBound && structPkgScope)
                                        if (auto* fs8 = Lookup::unqualified(
                                                *structPkgScope, lTxt))
                                            if (fs8->kind ==
                                                SymbolKind::Parameter) {
                                                auto& fp8 =
                                                    fs8->as<ParameterSymbol>();
                                                auto& fv8 = fp8.getValue();
                                                if (fv8 && fv8.isInteger() &&
                                                    !fv8.integer()
                                                         .hasUnknown()) {
                                                    std::string fd8 =
                                                        fv8.integer().toString(
                                                            LiteralBase::Decimal,
                                                            false);
                                                    auto* fc8 = s.MakeConstant();
                                                    fc8->VpiDecompile(fd8);
                                                    fc8->VpiSize(32);
                                                    fc8->VpiValue("UINT:" + fd8);
                                                    fc8->VpiConstType(
                                                        vpiUIntConst);
                                                    auto* fts8 =
                                                        s.MakeInt_typespec();
                                                    if (auto fd0 =
                                                            fp8.getDeclaredType())
                                                        if (auto* ftsyn =
                                                                fd0->getTypeSyntax())
                                                            setLoc(fts8,
                                                                   ftsyn->sourceRange());
                                                    if (fp8.getType()
                                                            .getCanonicalType()
                                                            .isSigned())
                                                        fts8->VpiSigned(true);
                                                    if (auto fpsc =
                                                            fp8.getParentScope())
                                                        if (auto fpi = pkgDefMap.find(
                                                                &fpsc->asSymbol());
                                                            fpi != pkgDefMap.end())
                                                            fts8->Instance(
                                                                (UHDM::instance*)
                                                                    fpi->second);
                                                    auto* frt8 =
                                                        s.MakeRef_typespec();
                                                    frt8->VpiFullName(
                                                        syntaxRefPrefix);
                                                    frt8->VpiParent(fc8);
                                                    frt8->Actual_typespec(fts8);
                                                    fts8->VpiParent(frt8);
                                                    fc8->Typespec(frt8);
                                                    lf8 = fc8;
                                                }
                                            }
                                    auto* ro8 = lf8 ? nullptr : s.MakeRef_obj();
                                    if (ro8) {
                                        ro8->VpiName(lTxt);
                                        ro8->VpiFullName(syntaxRefPrefix +
                                                         syntaxRefSep + lTxt);
                                        bindPkgParam(ro8, lTxt);
                                        lf8 = ro8;
                                    }
                                    lf8->VpiParent(op8);
                                    setLoc(lf8, *loc);
                                    lf8->VpiColumnNo(op8->VpiColumnNo() +
                                                     (int32_t)lOff);
                                    lf8->VpiEndColumnNo(
                                        op8->VpiColumnNo() + (int32_t)lOff +
                                        (int32_t)lTxt.size());
                                    lf8->VpiEndLineNo(op8->VpiLineNo());
                                    auto* c8 = s.MakeConstant();
                                    c8->VpiDecompile(rTxt);
                                    c8->VpiSize(64);
                                    c8->VpiValue("UINT:" + rTxt);
                                    c8->VpiConstType(vpiUIntConst);
                                    c8->VpiParent(op8);
                                    setLoc(c8, *loc);
                                    c8->VpiColumnNo(op8->VpiColumnNo() +
                                                    (int32_t)rOff);
                                    c8->VpiEndColumnNo(
                                        op8->VpiColumnNo() + (int32_t)rOff +
                                        (int32_t)rTxt.size());
                                    c8->VpiEndLineNo(op8->VpiLineNo());
                                    opnds8->push_back(lf8);
                                    opnds8->push_back(c8);
                                    op8->Operands(opnds8);
                                    return (UHDM::expr*)op8;
                                }
                            }
                        }
                        // A literal-arithmetic bound (`1-1`, `66-1`) keeps
                        // its SUB op tree in the standalone typespec
                        // (MultirangesStartNotFromZero): op11 with UINT
                        // digit constants at their sub-spans.
                        if (loc) {
                            std::string raw9(rawText(*loc));
                            size_t dash9 = raw9.find('-');
                            bool litSub9 = dash9 != std::string::npos &&
                                           dash9 > 0 && dash9 + 1 < raw9.size();
                            if (litSub9)
                                for (size_t p9 = 0; p9 < raw9.size(); p9++)
                                    if (p9 != dash9 &&
                                        !isdigit((unsigned char)raw9[p9])) {
                                        litSub9 = false;
                                        break;
                                    }
                            if (litSub9) {
                                auto* op9 = s.MakeOperation();
                                op9->VpiOpType(vpiSubOp);
                                op9->VpiParent(r);
                                setLoc(op9, *loc);
                                auto* opnds9 = s.MakeAnyVec();
                                auto mkD9 = [&](const std::string& dg,
                                                int32_t colOff,
                                                int32_t len) -> UHDM::any* {
                                    auto* c9 = s.MakeConstant();
                                    c9->VpiDecompile(dg);
                                    c9->VpiSize(64);
                                    c9->VpiValue("UINT:" + dg);
                                    c9->VpiConstType(vpiUIntConst);
                                    c9->VpiParent(op9);
                                    setLoc(c9, *loc);
                                    c9->VpiColumnNo(op9->VpiColumnNo() +
                                                    colOff);
                                    c9->VpiEndColumnNo(op9->VpiColumnNo() +
                                                       colOff + len);
                                    return c9;
                                };
                                opnds9->push_back(mkD9(raw9.substr(0, dash9),
                                                       0, (int32_t)dash9));
                                opnds9->push_back(mkD9(
                                    raw9.substr(dash9 + 1), (int32_t)dash9 + 1,
                                    (int32_t)(raw9.size() - dash9 - 1)));
                                op9->Operands(opnds9);
                                return (UHDM::expr*)op9;
                            }
                        }
                        // A NET/PORT packed_array_typespec over a NAMED
                        // (struct/enum typedef) element obeys the SAME view
                        // rule the logic_typespec dims path already
                        // implements for plain vectors: an `<ident>-<digits>`
                        // bound stays the SYMBOLIC op tree in the DEF
                        // (module-compile) view and FOLDS in the elaborated
                        // one — and the folded form is an INT constant
                        // anchored at the IDENTIFIER token alone, not a UINT
                        // spanning the whole bound text (Surelog:
                        // PortPackage, StructArrayNet, PortComplex). Struct /
                        // union MEMBER bounds keep their own rules above.
                        if (loc && !structMemberTsCtx) {
                            std::string rawV(rawText(*loc));
                            size_t b0 = rawV.find_first_not_of(" \t");
                            size_t e0 = b0 == std::string::npos ? 0 : b0;
                            while (b0 != std::string::npos && e0 < rawV.size() &&
                                   (isalnum((unsigned char)rawV[e0]) ||
                                    rawV[e0] == '_' ||
                                    (rawV[e0] == ':' && e0 + 1 < rawV.size() &&
                                     rawV[e0 + 1] == ':')))
                                e0 += rawV[e0] == ':' ? 2 : 1;
                            std::string idV =
                                b0 == std::string::npos
                                    ? std::string()
                                    : rawV.substr(b0, e0 - b0);
                            bool identV =
                                !idV.empty() &&
                                (isalpha((unsigned char)idV[0]) || idV[0] == '_');
                            // The remainder must be exactly `- <digits>`.
                            std::string subV;
                            size_t subOff = 0;
                            if (identV) {
                                size_t p0 = rawV.find_first_not_of(" \t", e0);
                                identV = false;
                                if (p0 != std::string::npos && rawV[p0] == '-') {
                                    size_t d0 =
                                        rawV.find_first_not_of(" \t", p0 + 1);
                                    size_t d1 = d0;
                                    while (d1 != std::string::npos &&
                                           d1 < rawV.size() &&
                                           isdigit((unsigned char)rawV[d1]))
                                        d1++;
                                    if (d0 != std::string::npos && d1 > d0 &&
                                        rawV.find_first_not_of(" \t", d1) ==
                                            std::string::npos) {
                                        subV = rawV.substr(d0, d1 - d0);
                                        subOff = d0;
                                        identV = true;
                                    }
                                }
                            }
                            if (identV && tfContext) {
                                auto* opV = s.MakeOperation();
                                opV->VpiOpType(vpiSubOp);
                                opV->VpiParent(r);
                                setLoc(opV, *loc);
                                auto* opndsV = s.MakeAnyVec();
                                auto* roV = s.MakeRef_obj();
                                roV->VpiName(idV);
                                roV->VpiParent(opV);
                                setLoc(roV, *loc);
                                roV->VpiColumnNo(opV->VpiColumnNo() +
                                                 (int32_t)b0);
                                roV->VpiEndColumnNo(opV->VpiColumnNo() +
                                                    (int32_t)b0 +
                                                    (int32_t)idV.size());
                                roV->VpiEndLineNo(opV->VpiLineNo());
                                // A PACKAGE-qualified bound binds the package
                                // parameter object itself (Surelog resolves
                                // the qualified read); an unqualified module
                                // parameter stays a bare, unbound ref.
                                if (idV.find("::") != std::string::npos)
                                    for (auto& [ps5, po5] : pkgParamObj) {
                                        std::string qn5;
                                        if (auto sc5 = ps5->getParentScope();
                                            sc5 &&
                                            sc5->asSymbol().kind ==
                                                SymbolKind::Package)
                                            qn5 =
                                                std::string(sc5->asSymbol().name) +
                                                "::" + std::string(ps5->name);
                                        if (!qn5.empty() && qn5 == idV) {
                                            roV->Actual_group(po5);
                                            break;
                                        }
                                    }
                                opndsV->push_back(roV);
                                auto* cV = s.MakeConstant();
                                cV->VpiDecompile(subV);
                                cV->VpiSize(64);
                                cV->VpiValue("UINT:" + subV);
                                cV->VpiConstType(vpiUIntConst);
                                cV->VpiParent(opV);
                                setLoc(cV, *loc);
                                cV->VpiColumnNo(opV->VpiColumnNo() +
                                                (int32_t)subOff);
                                cV->VpiEndColumnNo(opV->VpiColumnNo() +
                                                   (int32_t)subOff +
                                                   (int32_t)subV.size());
                                cV->VpiEndLineNo(opV->VpiLineNo());
                                opndsV->push_back(cV);
                                opV->Operands(opndsV);
                                return (UHDM::expr*)opV;
                            }
                            if (identV) {
                                auto* cF = s.MakeConstant();
                                std::string dF = std::to_string(v);
                                cF->VpiDecompile(dF);
                                cF->VpiSize(64);
                                cF->VpiValue("INT:" + dF);
                                cF->VpiConstType(vpiIntConst);
                                cF->VpiParent(r);
                                setLoc(cF, *loc);
                                cF->VpiColumnNo(cF->VpiColumnNo() + (int32_t)b0);
                                cF->VpiEndColumnNo(cF->VpiColumnNo() +
                                                   (int32_t)idV.size());
                                cF->VpiEndLineNo(cF->VpiLineNo());
                                return (UHDM::expr*)cF;
                            }
                        }
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(r);
                        if (loc)
                            setLoc(c, *loc);
                        // A DEF-pass folded member bound derived from a package
                        // param IDENTIFIER ([K:0]) records that param — the
                        // post-swap TOP member pass gives it vpiSize:32 + a
                        // vpiTypespec (ref -> fresh int_typespec) like Surelog.
                        if (loc && structMemberTsCtx) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            if (ident)
                                for (auto& [ps9, rhs9] : pkgParamDefRhs)
                                    if (ps9->name == raw &&
                                        ps9->getParentScope() &&
                                        ps9->getParentScope()->asSymbol().kind ==
                                            SymbolKind::Package) {
                                        foldedMemberBoundParam[c] = ps9;
                                        break;
                                    }
                            // A folded ARITHMETIC bound over a package param
                            // ([NDioPads-1:0]) is a SIGNED int constant spanning
                            // the IDENTIFIER token alone (Surelog evaluates the
                            // op and keeps the left operand's span).
                            if (!ident) {
                                size_t dash7 = raw.find('-');
                                if (dash7 != std::string::npos && dash7 > 0) {
                                    size_t lb7 = raw.find_first_not_of(" \t");
                                    std::string lTxt7;
                                    if (lb7 != std::string::npos) {
                                        size_t le7 =
                                            raw.find_last_not_of(" \t", dash7 - 1);
                                        if (le7 != std::string::npos && le7 >= lb7)
                                            lTxt7 = raw.substr(lb7, le7 - lb7 + 1);
                                    }
                                    bool lIdent7 =
                                        !lTxt7.empty() &&
                                        (isalpha((unsigned char)lTxt7[0]) ||
                                         lTxt7[0] == '_');
                                    for (char ch : lTxt7)
                                        if (!(isalnum((unsigned char)ch) ||
                                              ch == '_')) {
                                            lIdent7 = false;
                                            break;
                                        }
                                    bool pkgParam7 = false;
                                    if (lIdent7)
                                        for (auto& [ps7, rhs7] : pkgParamDefRhs)
                                            if (ps7->name == lTxt7 &&
                                                ps7->getParentScope() &&
                                                ps7->getParentScope()
                                                        ->asSymbol()
                                                        .kind ==
                                                    SymbolKind::Package) {
                                                pkgParam7 = true;
                                                break;
                                            }
                                    if (pkgParam7) {
                                        c->VpiValue("INT:" + digits);
                                        c->VpiConstType(vpiIntConst);
                                        int32_t base7 = c->VpiColumnNo();
                                        c->VpiColumnNo(base7 + (int32_t)lb7);
                                        c->VpiEndColumnNo(base7 + (int32_t)lb7 +
                                                          (int32_t)lTxt7.size());
                                        c->VpiEndLineNo(c->VpiLineNo());
                                    }
                                }
                            }
                        }
                        return c;
                    };
                    const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
                    if (ds)
                        setLoc(r, ds->range);
                    r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
                    r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
                    rvec->push_back(r);
                }
                pat->Ranges(rvec);
                // A PACKAGE-struct leaf's packed_array_typespec is UNLOCATED
                // (its struct_typespec lives at the package); a module-local
                // one keeps the declaration span. A struct/union MEMBER (even
                // with a package leaf) spans its member type..dims (Surelog).
                bool pkgLeaf = false;
                for (auto sc0 = lc.getParentScope(); sc0;
                     sc0 = sc0->asSymbol().getParentScope())
                    if (sc0->asSymbol().kind == SymbolKind::Package) {
                        pkgLeaf = true;
                        break;
                    }
                if (!pkgLeaf || structMemberTsCtx)
                    setLoc(pat, patLoc);
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(pat);
                ert->Actual_typespec(elemTs);
                pat->Elem_typespec(ert);
                return pat;
            }
        }
        }
        // A packed array over a VECTOR TYPEDEF (logic4 [1:0] v) in module
        // context: an anonymous logic ts at the type span with an Elem ref
        // to the SHARED typedef ts and the ARRAY dim as its range (Surelog).
        // (A write-phase PORT recompile passes portCtx with tfContext set —
        // it still needs the full elem+range form, not a bare shell.)
        if ((!tfContext || portCtx) &&
            declared->getType().kind == SymbolKind::PackedArrayType) {
            auto& et9 = declared->getType().as<PackedArrayType>().elementType;
            if (et9.kind == SymbolKind::TypeAlias) {
                if (auto tit9 = typedefTs.find(&et9);
                    tit9 != typedefTs.end() &&
                    tit9->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* lts = s.MakeLogic_typespec();
                    setLoc(lts, range);
                    auto* ert9 = s.MakeRef_typespec();
                    ert9->VpiParent(lts);
                    // A FILE-LEVEL ($unit) element typedef mints a per-USE
                    // named clone (Typedef_alias -> the shared design ts);
                    // module-local element typedefs share directly (Surelog:
                    // arrays03 vs multidim_hier_path9). The write-phase port
                    // recompile (def-view object) carries the design Instance,
                    // the def-pass one (elab-view object) stays bare.
                    UHDM::typespec* elemAct9 = tit9->second;
                    if (auto sc9 = et9.as<TypeAliasType>().getParentScope();
                        sc9 &&
                        sc9->asSymbol().kind == SymbolKind::CompilationUnit) {
                        auto& eta9 = et9.as<TypeAliasType>();
                        const syntax::SyntaxNode* etSyn9 = nullptr;
                        if (auto easyn9 = eta9.getSyntax())
                            if (easyn9->kind ==
                                syntax::SyntaxKind::TypedefDeclaration)
                                etSyn9 =
                                    easyn9
                                        ->as<syntax::TypedefDeclarationSyntax>()
                                        .type;
                        bool sv9 = bypassTypedefShare;
                        bypassTypedefShare = true;
                        auto* ecl9 = makeTypespec(eta9, etSyn9);
                        bypassTypedefShare = sv9;
                        if (ecl9 &&
                            ecl9->UhdmType() == UHDM::uhdmlogic_typespec) {
                            ecl9->VpiName(eta9.name);
                            if (etSyn9)
                                setLoc(ecl9, etSyn9->sourceRange());
                            auto* eal9 = s.MakeRef_typespec();
                            eal9->VpiFullName(std::string(eta9.name));
                            eal9->VpiParent(ecl9);
                            eal9->Actual_typespec(tit9->second);
                            ((UHDM::logic_typespec*)ecl9)->Typedef_alias(eal9);
                            if (tfContext && portCtx && tit9->second->Instance())
                                ecl9->Instance(tit9->second->Instance());
                            elemAct9 = ecl9;
                        }
                    }
                    ert9->Actual_typespec(elemAct9);
                    lts->Elem_typespec(ert9);
                    auto pr9 =
                        declared->getType().as<PackedArrayType>().range;
                    std::vector<DimSpan> spans9;
                    {
                        SourceLocation tS9 = range.start();
                        if (auto tsy9 = declared->getTypeSyntax())
                            tS9 = tsy9->sourceRange().start();
                        if (tS9 < declSymbol.location)
                            spans9 = scanDimSpans(
                                std::string(rawText(
                                    SourceRange(tS9, declSymbol.location))),
                                tS9);
                    }
                    auto* rng9 = s.MakeRange();
                    rng9->VpiParent(lts);
                    const DimSpan* ds9 = spans9.empty() ? nullptr : &spans9[0];
                    if (ds9)
                        setLoc(rng9, ds9->range);
                    // The ARRAY dim of a vector-typedef packed array keeps an
                    // ARITHMETIC bound UNFOLDED in this (def) view — Surelog
                    // reduces `logic [W-1:0] x` but not the array dim of
                    // `my_vec_t [1:`SIZE-1] x`, which stays a vpiSubOp tree
                    // (purpose-built golden; scr1_pipe_mprf's `type_scr1_mprf_v
                    // [1:`SCR1_MPRF_SIZE-1] mprf_int`).  The dims of a named
                    // type live on the NAME (`IdentifierSelectName` selectors),
                    // not on the type syntax, so they are read from there.
                    auto dsyn9 = namedTypeDimBounds(declared->getTypeSyntax());
                    const syntax::ExpressionSyntax* dl9 =
                        dsyn9.empty() ? nullptr : dsyn9[0].first;
                    const syntax::ExpressionSyntax* dr9 =
                        dsyn9.empty() ? nullptr : dsyn9[0].second;
                    auto mk9 = [&](int64_t v, const SourceRange* loc,
                                   const syntax::ExpressionSyntax* bs9)
                        -> UHDM::expr* {
                        if (bs9 &&
                            syntax::BinaryExpressionSyntax::isKind(bs9->kind))
                            if (auto* e9 = emitSyntaxExpr(*bs9, rng9))
                                return (UHDM::expr*)e9;
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(rng9);
                        if (loc)
                            setLoc(c, *loc);
                        return c;
                    };
                    rng9->Left_expr(
                        mk9(pr9.left, ds9 ? &ds9->left : nullptr, dl9));
                    rng9->Right_expr(
                        mk9(pr9.right, ds9 ? &ds9->right : nullptr, dr9));
                    auto* rvec9 = s.MakeRangeVec();
                    rvec9->push_back(rng9);
                    lts->Ranges(rvec9);
                    return lts;
                }
            }
        }
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
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Time: {
                    its = s.MakeTime_typespec();
                    break;
                }
                default:
                    noteUnsupported("integer type kind");
                    break;
            }
            if (its) {
                setLoc(its, trimTypeSigning(typeSynFor(), range));
                return its;
            }
        }
    }

    // An ANONYMOUS packed union (union packed {..} u;) builds an unnamed
    // union_typespec. A TYPEDEF'd union (kind == TypeAlias) is excluded — it
    // shares the named typedef ts (or is cloned by the typedef paths).
    if (declared && (declared->getType().kind == SymbolKind::PackedUnionType ||
                     declared->getType().kind == SymbolKind::UnpackedUnionType)) {
        bool pk = declared->getType().kind == SymbolKind::PackedUnionType;
        auto& ctU = declared->getType().getCanonicalType();
        // The ELAB (net-bound) clone scopes its member refs through the
        // signal's own full name; the DEF object keeps bare member names.
        std::string uAlias = (!tfContext && !boundOwnerFullName.empty())
                                 ? boundOwnerFullName
                                 : std::string();
        auto* uts = pk ? buildUnionTs(ctU.as<PackedUnionType>(), true, uAlias)
                       : buildUnionTs(ctU.as<UnpackedUnionType>(), false, uAlias);
        if (auto tsyn = declared->getTypeSyntax()) {
            // A PACKED anonymous union ts spans only the `union packed` HEADER;
            // an UNPACKED one spans the whole syntax (Surelog).
            if (auto* su = tsyn->as_if<syntax::StructUnionTypeSyntax>(); su && pk) {
                // The DEF-view object spans the `union packed` header; the
                // ELAB (net-bound) one spans the `union` keyword alone.
                if (tfContext) {
                    SourceLocation e = su->keyword.range().end();
                    if (su->packed && su->packed.range().end() > e)
                        e = su->packed.range().end();
                    if (su->signing && su->signing.range().end() > e)
                        e = su->signing.range().end();
                    setLoc(uts, SourceRange(su->keyword.range().start(), e));
                }
                else
                    setLoc(uts, su->keyword.range());
            }
            else if (auto* su2 = tsyn->as_if<syntax::StructUnionTypeSyntax>()) {
                // An anonymous UNPACKED union: the ELAB clone spans the
                // `union` keyword; the DEF object stops at the end of the
                // FIRST member declaration (Surelog).
                if (!tfContext)
                    setLoc(uts, su2->keyword.range());
                else if (!su2->members.empty())
                    setLoc(uts,
                           SourceRange(su2->keyword.range().start(),
                                       su2->members[0]->sourceRange().end()));
                else
                    setLoc(uts, tsyn->sourceRange());
            }
            else
                setLoc(uts, tsyn->sourceRange());
        }
        return uts;
    }
    // An ANONYMOUS packed struct (struct packed {..} s;) builds an unnamed
    // struct_typespec — directly, or as the ELEMENT of an unpacked array
    // (struct packed {..} a [4]; the array emission wraps this in an
    // array_typespec). Typedef'd structs share their named ts above.
    if (declared) {
        const Type* st = &declared->getType();
        bool arrayElem = false;
        while (st->kind == SymbolKind::FixedSizeUnpackedArrayType) {
            st = &st->as<FixedSizeUnpackedArrayType>().elementType;
            arrayElem = true;
        }
        if (st->kind == SymbolKind::PackedStructType) {
            auto* sts = buildStructTs(st->as<PackedStructType>(), true, "");
            const syntax::SyntaxNode* ssyn =
                arrayElem ? st->getSyntax() : declared->getTypeSyntax();
            if (ssyn) {
                if (auto* su = ssyn->as_if<syntax::StructUnionTypeSyntax>()) {
                    // Surelog locates an ANONYMOUS inline struct_typespec at
                    // the bare `struct`/`union` keyword token (an unpacked-array
                    // ELEMENT struct: `struct packed {..} a[4]` spans just
                    // `struct`, NOT `struct packed`). A directly-declared
                    // (non-array-element) anonymous struct keeps the extended
                    // keyword+packed+signing span.
                    if (arrayElem) {
                        setLoc(sts, su->keyword.range());
                    }
                    else {
                        SourceLocation e = su->keyword.range().end();
                        if (su->packed && su->packed.range().end() > e)
                            e = su->packed.range().end();
                        if (su->signing && su->signing.range().end() > e)
                            e = su->signing.range().end();
                        setLoc(sts, SourceRange(su->keyword.range().start(), e));
                    }
                }
                else
                    setLoc(sts, ssyn->sourceRange());
            }
            return sts;
        }
        // An ANONYMOUS UNPACKED struct (`struct { .. } s;`) is the missing
        // sibling of the packed arm above and of the union arm before it:
        // the WRITTEN type decides the typespec class, so it too builds an
        // unnamed struct_typespec — not the integral fallback.  Surelog
        // anchors it at the bare `struct` keyword (PatternOrder's module-scope
        // `struct { .. } ABC = '{..}`, AssignRhsFlat's nested member struct
        // `struct { logic B; int C; } BC1, BC2;`); an initialized declaration
        // then stretches the def-view end through its init exactly as for a
        // vector (materializeDefNetTs).
        if (st->kind == SymbolKind::UnpackedStructType) {
            auto* sts = buildStructTs(st->as<UnpackedStructType>(), false, "");
            const syntax::SyntaxNode* ssyn =
                arrayElem ? st->getSyntax() : declared->getTypeSyntax();
            if (ssyn) {
                if (auto* su = ssyn->as_if<syntax::StructUnionTypeSyntax>())
                    setLoc(sts, su->keyword.range());
                else
                    setLoc(sts, ssyn->sourceRange());
            }
            return sts;
        }
    }
    // 2-state (bit) vectors take a bit_typespec; 4-state stay logic.
    // An UNPACKED array's element ts keys on its packed LEAF (bit [0:0][0:0]
    // b [0:0] still gets a bit_typespec element).
    // A DYNAMIC array's declaration keys on its element the same way (measured:
    // `bit [7:0] q [];` -> bit_typespec[7:0], `logic [3:0] r [];` ->
    // logic_typespec), matching the FileResolutionFunction rule above.
    auto unpackedLeaf0 = [](const Type* t) {
        while (t) {
            auto& c = t->getCanonicalType();
            if (c.kind == SymbolKind::FixedSizeUnpackedArrayType)
                t = &c.as<FixedSizeUnpackedArrayType>().elementType.getCanonicalType();
            else if (c.kind == SymbolKind::DynamicArrayType)
                t = &c.as<DynamicArrayType>().elementType.getCanonicalType();
            else if (c.kind == SymbolKind::QueueType)
                t = &c.as<QueueType>().elementType.getCanonicalType();
            // ...and an ASSOCIATIVE dim likewise (`bit a [int]` ->
            // bit_typespec).
            else if (c.kind == SymbolKind::AssociativeArrayType)
                t = &c.as<AssociativeArrayType>().elementType.getCanonicalType();
            else
                break;
        }
        return t;
    };
    UHDM::typespec* ts0;
    const Type* fsLeaf0 =
        unpackedLeaf0(declared ? &declared->getType().getCanonicalType() : nullptr);
    if (fsLeaf0 && fsLeaf0->isIntegral() && !fsLeaf0->isFourState())
        ts0 = s.MakeBit_typespec();
    else
        ts0 = s.MakeLogic_typespec();
    auto* ts = (UHDM::logic_typespec*)ts0;
    // Net-keyword-anchored typespecs omit the signed flag.
    if (declared && declared->getType().isSigned() && !netKeywordAnchor)
        ts->VpiSigned(true);
    setLoc(ts, range);

    // Packed dimensions: one uhdm range per dimension, bounds as evaluated
    // UINT constants (64-bit) that keep their source text as decompile.
    // Dims live on IntegerTypeSyntax ("logic [7:0]") or ImplicitTypeSyntax
    // ("input [7:0] a" / "wire [7:0] w").
    // The packed element sits under any unpacked array dims (an unpacked-array
    // net still carries its packed element ranges on the element typespec).
    const Type* packedLeaf =
        unpackedLeaf0(declared ? &declared->getType().getCanonicalType() : nullptr);
    if (packedLeaf && packedLeaf->isPackedArray()) {
        auto tsyn = typeSynFor();
        const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dimSyns = nullptr;
        if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind)) {
            dimSyns = &tsyn->as<syntax::IntegerTypeSyntax>().dimensions;
        }
        else if (tsyn && tsyn->kind == syntax::SyntaxKind::ImplicitType) {
            auto& its = tsyn->as<syntax::ImplicitTypeSyntax>();
            if (!its.dimensions.empty()) {
                dimSyns = &its.dimensions;
                // Location: net declarations span the net keyword through the
                // dims; port declarations use the dims range alone. A signing
                // keyword anchor wins over the dims range.
                if (!implicitSigning) {
                    SourceRange dr(its.dimensions[0]->sourceRange().start(),
                                   its.dimensions[its.dimensions.size() - 1]
                                       ->sourceRange()
                                       .end());
                    if (mergedPort) {
                        // Port-decl dims: the dims range alone.
                    }
                    else if (auto nh = ansiNetHeader(declSymbol)) {
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
        }
        if (dimSyns) {
            std::vector<ConstantRange> dims;
            // A net/var element typespec covers only the PACKED dims; descend
            // past any unpacked array dims (e.g. logic [7:0] memory [0:15],
            // bit [7:0] q []) to reach the packed element before collecting
            // its ranges.
            const Type* t =
                unpackedLeaf0(&declared->getType().getCanonicalType());
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
                    auto emitBound = [&](const syntax::ExpressionSyntax* bsyn,
                                         int64_t value) -> UHDM::expr* {
                        if (!bsyn || bsyn->kind == syntax::SyntaxKind::IntegerLiteralExpression)
                            return makeBoundConst(bsyn, value, r);
                        // A $bits(SIGNAL) bound stays UNFOLDED in module and
                        // param contexts alike ($bits(type) still folds): the
                        // sys call's arg ref scopes through the declaring
                        // symbol and binds the signal's net.
                        bool bitsOfSignal = false;
                        const Scope* declScope = declSymbol.getParentScope();
                        {
                            std::function<void(const syntax::SyntaxNode&)> scan =
                                [&](const syntax::SyntaxNode& sn) {
                                    if (bitsOfSignal)
                                        return;
                                    if (sn.kind ==
                                        syntax::SyntaxKind::InvocationExpression) {
                                        auto& inv2 =
                                            sn.as<syntax::InvocationExpressionSyntax>();
                                        if (inv2.left->kind ==
                                                syntax::SyntaxKind::SystemName &&
                                            inv2.arguments && declScope)
                                            for (auto a2 : inv2.arguments->parameters) {
                                                auto* sy2 = declScope->find(std::string(
                                                    rawText(a2->sourceRange())));
                                                if (sy2 &&
                                                    (sy2->kind == SymbolKind::Net ||
                                                     sy2->kind == SymbolKind::Variable))
                                                    bitsOfSignal = true;
                                            }
                                    }
                                    for (size_t ci = 0; ci < sn.getChildCount(); ci++)
                                        if (auto* cn = sn.childNode(ci))
                                            scan(*cn);
                                };
                            if (bsyn)
                                scan(*bsyn);
                        }
                        // A PARAMETER's own typespec keeps its range bounds
                        // SYMBOLIC — a bare param ref ([DepthW:0] on
                        // localparam FullDepth, issue326) as a scoped
                        // ref_obj, and ANY operation bound as the unfolded op
                        // tree, whether it references a param ([XLEN-1:0] on
                        // parameter IFU_RST) or is literal-only ([3-1:0] on
                        // localparam ADD) — rp32_r5p_mouse. A VAR/NET typespec
                        // folds all of these.
                        // ...and NOT for a COMPILATION-UNIT ($unit) parameter:
                        // Surelog reduces those bounds like a var/net's.
                        // `parameter bit [`XLEN-1:0] P` at file scope folds to
                        // INT:31 while the same declaration inside a module
                        // keeps the vpiSubOp tree (purpose-built golden: five
                        // $unit shapes — macro-arith, literal-only op, param
                        // op, bare param ref, logic vector — all fold; the
                        // module twin of the first does not).
                        // ...UNLESS the bound reads a $unit parameter declared
                        // in a DIFFERENT command-line source file.  Surelog
                        // compiles one file at a time and a guarded header's
                        // declarations land in whichever file included it
                        // first, so a bound reaching across that boundary
                        // never resolves: golden keeps the vpiSubOp with a
                        // DANGLING ref_obj (Scr1SvTests
                        // `parameter bit [SCR1_CSR_ADDR_WIDTH-1:0]
                        // SCR1_CSR_ADDR_TDU_TSELECT` — scr1_tdu.svh reaching
                        // scr1_arch_types.svh, which scr1_pipe_hdu.sv already
                        // claimed; the same file's SCR1_CSR_ADDR_TDU_OFFS_W
                        // bound one line up DOES fold).
                        bool unitParamTs =
                            declSymbol.kind == SymbolKind::Parameter &&
                            declSymbol.getParentScope() &&
                            declSymbol.getParentScope()->asSymbol().kind ==
                                SymbolKind::CompilationUnit;
                        std::string unitOwnRoot;
                        if (unitParamTs && bsyn) {
                            std::string ownRoot = rootFilePath(declSymbol.location);
                            std::function<void(const syntax::SyntaxNode&)> xf =
                                [&](const syntax::SyntaxNode& sn) {
                                    if (!unitParamTs)
                                        return;
                                    if (sn.kind ==
                                        syntax::SyntaxKind::IdentifierName) {
                                        auto* sy = declSymbol.getParentScope()
                                                       ->find(std::string(rawText(
                                                           sn.sourceRange())));
                                        if (sy &&
                                            sy->kind == SymbolKind::Parameter &&
                                            rootFilePath(sy->location) != ownRoot)
                                            unitParamTs = false;
                                    }
                                    for (size_t ci = 0; ci < sn.getChildCount();
                                         ci++)
                                        if (auto* cn = sn.childNode(ci))
                                            xf(*cn);
                                };
                            xf(*bsyn);
                            if (!unitParamTs)
                                unitOwnRoot = ownRoot;
                        }
                        // The SAME cross-file boundary keeps a VAR/NET typespec
                        // bound symbolic.  `logic [CHW-1:0] x` folds in the
                        // command-line file that FIRST included the guarded
                        // header declaring CHW and stays a vpiSubOp (with a
                        // BOUND ref_obj, unlike the parameter case above) in
                        // every later file — the two-file purpose-built golden
                        // is byte-for-byte the same declaration in both.  This
                        // is the long-standing "operation-vs-constant in a
                        // var/net typespec range" cluster (Scr1SvTests
                        // `logic [SCR1_DBG_DMI_CH_ID_WIDTH-1:0] tapc_dmi_ch_id`,
                        // `logic [SCR1_IRQ_LINES_NUM-1:0] irq_lines`): the
                        // same-file repro that "should" have reproduced it
                        // passes precisely because it is same-file.
                        bool unitXFileVarBound = false;
                        if (bsyn && !unitParamTs &&
                            (declSymbol.kind == SymbolKind::Variable ||
                             declSymbol.kind == SymbolKind::Net) &&
                            !unitParamMap.empty()) {
                            const Scope* xsc =
                                currentScope ? currentScope
                                             : declSymbol.getParentScope();
                            if (xsc) {
                                std::string ownRoot2 =
                                    rootFilePath(declSymbol.location);
                                ASTContext xctx(*xsc, LookupLocation::max);
                                auto& xbe = Expression::bind(*bsyn, xctx);
                                if (!xbe.bad())
                                    xbe.visit(makeVisitor(
                                        [&](auto& v,
                                            const NamedValueExpression& nv) {
                                            if (nv.symbol.kind ==
                                                    SymbolKind::Parameter &&
                                                unitParamMap.count(&nv.symbol) &&
                                                rootFilePath(nv.symbol.location) !=
                                                    ownRoot2)
                                                unitXFileVarBound = true;
                                            v.visitDefault(nv);
                                        }));
                            }
                        }
                        bool bareParamInParamTs = false;
                        if (declSymbol.kind == SymbolKind::Parameter && bsyn &&
                            !unitParamTs) {
                            if (syntax::BinaryExpressionSyntax::isKind(
                                    bsyn->kind))
                                bareParamInParamTs = true;
                            else if (bsyn->kind ==
                                         syntax::SyntaxKind::IdentifierName &&
                                     currentScope) {
                                ASTContext bctx(*currentScope,
                                                LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                if (!be.bad() &&
                                    stripImplicitConv(be).kind ==
                                        ExpressionKind::NamedValue &&
                                    stripImplicitConv(be)
                                            .as<NamedValueExpression>()
                                            .symbol.kind ==
                                        SymbolKind::Parameter)
                                    bareParamInParamTs = true;
                            }
                        }
                        // ...except inside a PACKAGE, where such a bound is
                        // VIEW-DEPENDENT. A package param's own typespec range
                        // that READS another parameter ([NAlerts-1:0] on
                        // alert_handler_reg_pkg::AsyncOn) keeps the symbolic op
                        // tree in the DEF package and FOLDS in the ELABORATED
                        // one — Surelog re-evaluates package ranges while
                        // elaborating the package (EarlgreyPackParam,
                        // LogicArrayParam, IntegerConcat). A literal-only op
                        // ([3-1:0]) stays symbolic in both views, so the rule
                        // keys off an actual parameter read.
                        // The DEF package view is the ONLY view that keeps it:
                        // the same package parameter read from a MODULE (a
                        // materialized wildcard-import copy, work@alert_handler
                        // .AsyncOn) folds its bound too, exactly like the elab
                        // package copy (LogicArrayParam).
                        bool pkgParamTsRef = false;
                        bool ownPkgDefView = false;
                        // Bind the bound in the parameter's HOME package, not
                        // in whatever scope is current: the module copies are
                        // minted with no currentScope (patchParamTypespecs) or
                        // with an elaborated body the bare name does not
                        // resolve in, and the bound is a package declaration in
                        // every view.
                        const Scope* pkgBindScope = declSymbol.getParentScope();
                        if (bareParamInParamTs && bsyn && pkgBindScope &&
                            declSymbol.getParentScope() &&
                            declSymbol.getParentScope()->asSymbol().kind ==
                                SymbolKind::Package) {
                            ownPkgDefView =
                                !pkgEmitTopView &&
                                curPkgEmitSym ==
                                    &declSymbol.getParentScope()->asSymbol();
                            ASTContext pctx(*pkgBindScope, LookupLocation::max);
                            auto& pbe = Expression::bind(*bsyn, pctx);
                            if (!pbe.bad())
                                pbe.visit(makeVisitor(
                                    [&](auto& v,
                                        const NamedValueExpression& nv) {
                                        if (nv.symbol.kind ==
                                            SymbolKind::Parameter)
                                            pkgParamTsRef = true;
                                        v.visitDefault(nv);
                                    }));
                        }
                        if (pkgParamTsRef && !ownPkgDefView)
                            bareParamInParamTs = false;
                        // A NON-TOP def port dim bound stays symbolic when
                        // the def is instantiated WITH a #(...) override
                        // (its module view compiles generically): every
                        // non-literal bound, literal ops ([2-1:0] tcb_siz)
                        // and overridable-param refs (X-1, POSOPPIS/
                        // ReplicationPassedToInstance) included. A def whose
                        // instances pass NO overrides folds those, keeping
                        // only LOCALPARAM refs symbolic (XLEN-1 on tcb_adr —
                        // rp32_r5p_mouse_soc_simple_top). Detected off the
                        // instantiation SYNTAX (overriddenTextDefs):
                        // isOverriddenParam misses cloned/canonical bodies.
                        bool defModuleParamDim = false;
                        if (defPortDim && bsyn && currentScope) {
                            bool defOvText9 = false;
                            for (auto sc9 = declSymbol.getParentScope(); sc9;
                                 sc9 = sc9->asSymbol().getParentScope())
                                if (sc9->asSymbol().kind ==
                                    SymbolKind::InstanceBody) {
                                    defOvText9 = overriddenTextDefs.count(
                                                     &sc9->asSymbol()
                                                          .as<InstanceBodySymbol>()
                                                          .getDefinition()) > 0;
                                    break;
                                }
                            if (defOvText9 &&
                                bsyn->kind !=
                                    syntax::SyntaxKind::IntegerLiteralExpression)
                                defModuleParamDim = true;
                            if (!defModuleParamDim) {
                                ASTContext bctx(*currentScope,
                                                LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                if (!be.bad())
                                    be.visit(makeVisitor(
                                        [&](auto& v,
                                            const NamedValueExpression& nv) {
                                            if (nv.symbol.kind ==
                                                    SymbolKind::Parameter &&
                                                nv.symbol.as<ParameterSymbol>()
                                                    .isLocalParam())
                                                defModuleParamDim = true;
                                            v.visitDefault(nv);
                                        }));
                            }
                        }
                        // A MODULE signal/net packed range bound that reaches
                        // an INTERFACE member THROUGH a modport/interface port
                        // (sub.OFF, s.CFG.BUS.DAT) stays a SYMBOLIC operation
                        // tree in Surelog's elab view — the port hop is not
                        // folded (unlike a bound referencing only local params
                        // or the interface's own params directly, which fold).
                        // Detected from the module PORT LIST (scope-independent:
                        // the elab-view bind of a modport-hop bound can fail):
                        // an identifier in the bound that names an interface/
                        // modport PORT of the declaring module means the bound
                        // reaches an interface member through the port hop.
                        bool ifacePortBound = false;
                        if (bsyn && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim) {
                            const InstanceBodySymbol* ib = nullptr;
                            for (auto sc = declSymbol.getParentScope(); sc;
                                 sc = sc->asSymbol().getParentScope())
                                if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
                                    ib = &sc->asSymbol().as<InstanceBodySymbol>();
                                    break;
                                }
                            if (ib) {
                                std::set<std::string> ifacePortNames;
                                for (auto pb : ib->getPortList())
                                    if (pb && pb->kind == SymbolKind::InterfacePort)
                                        ifacePortNames.insert(std::string(pb->name));
                                if (!ifacePortNames.empty()) {
                                    std::function<void(const syntax::SyntaxNode&)>
                                        scan = [&](const syntax::SyntaxNode& sn) {
                                            if (ifacePortBound)
                                                return;
                                            if (sn.kind ==
                                                syntax::SyntaxKind::IdentifierName) {
                                                auto txt = rawText(
                                                    sn.as<syntax::IdentifierNameSyntax>()
                                                        .identifier.range());
                                                if (ifacePortNames.count(
                                                        std::string(txt)))
                                                    ifacePortBound = true;
                                            }
                                            for (size_t ci = 0;
                                                 ci < sn.getChildCount(); ci++)
                                                if (auto* cn = sn.childNode(ci))
                                                    scan(*cn);
                                        };
                                    scan(*bsyn);
                                }
                            }
                        }
                        // ...but only in the DEF/generic view. An ELABORATED
                        // child-instance body folds the bound (Surelog).
                        // elabInstanceTs marks the elab-instance net/var
                        // typespec emission. The fold uses the interface's
                        // DEFAULT param value (the AllModules width), NOT the
                        // connected per-instance override. Re-evaluate the
                        // bound substituting each interface param reached
                        // through the port with its DEFAULT value: an external
                        // (through-port) parameter resolves to a default
                        // instance of its OWN interface definition (safe to
                        // instantiate — no port hop), while local params and
                        // literals fold normally.
                        if (ifacePortBound && elabInstanceTs) {
                            ifacePortBound = false;
                            const InstanceBodySymbol* ib2 = nullptr;
                            for (auto sc = declSymbol.getParentScope(); sc;
                                 sc = sc->asSymbol().getParentScope())
                                if (sc->asSymbol().kind ==
                                    SymbolKind::InstanceBody) {
                                    ib2 = &sc->asSymbol()
                                               .as<InstanceBodySymbol>();
                                    break;
                                }
                            if (ib2 && bsyn && currentScope) {
                                ASTContext bctx(*currentScope,
                                                LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                std::function<std::optional<ConstantValue>(
                                    const Expression&)>
                                    evalDef =
                                        [&](const Expression& e)
                                        -> std::optional<ConstantValue> {
                                    switch (e.kind) {
                                    case ExpressionKind::Conversion:
                                        return evalDef(
                                            e.as<ConversionExpression>()
                                                .operand());
                                    case ExpressionKind::UnaryOp: {
                                        auto& u = e.as<UnaryExpression>();
                                        auto ov = evalDef(u.operand());
                                        if (!ov)
                                            return std::nullopt;
                                        if (u.op == UnaryOperator::Minus)
                                            return ConstantValue(-ov->integer());
                                        if (u.op == UnaryOperator::Plus)
                                            return ov;
                                        return std::nullopt;
                                    }
                                    case ExpressionKind::BinaryOp: {
                                        auto& b = e.as<BinaryExpression>();
                                        auto l = evalDef(b.left());
                                        auto r = evalDef(b.right());
                                        if (!l || !r)
                                            return std::nullopt;
                                        auto cv = OpInfo::eval(b.op, *l, *r);
                                        if (cv.isInteger())
                                            return cv;
                                        return std::nullopt;
                                    }
                                    case ExpressionKind::NamedValue:
                                    case ExpressionKind::HierarchicalValue: {
                                        const Symbol& sym =
                                            e.kind == ExpressionKind::NamedValue
                                                ? e.as<NamedValueExpression>()
                                                      .symbol
                                                : e.as<HierarchicalValueExpression>()
                                                      .symbol;
                                        if (sym.kind == SymbolKind::Parameter) {
                                            const InstanceBodySymbol* pib =
                                                nullptr;
                                            for (auto sc = sym.getParentScope();
                                                 sc;
                                                 sc = sc->asSymbol()
                                                          .getParentScope())
                                                if (sc->asSymbol().kind ==
                                                    SymbolKind::InstanceBody) {
                                                    pib = &sc->asSymbol()
                                                               .as<InstanceBodySymbol>();
                                                    break;
                                                }
                                            // External (through-port) interface
                                            // param: substitute the interface
                                            // DEFAULT value.
                                            if (pib && pib != ib2 &&
                                                pib->getDefinition()
                                                        .definitionKind ==
                                                    DefinitionKind::Interface) {
                                                auto& pdef =
                                                    pib->getDefinition();
                                                auto dfIt =
                                                    moduleDefaultInst.find(
                                                        &pdef);
                                                if (dfIt ==
                                                    moduleDefaultInst.end())
                                                    dfIt =
                                                        moduleDefaultInst
                                                            .emplace(
                                                                &pdef,
                                                                &InstanceSymbol::
                                                                    createDefault(
                                                                        comp,
                                                                        pdef))
                                                            .first;
                                                if (auto* dsym =
                                                        dfIt->second->body.find(
                                                            std::string(
                                                                sym.name));
                                                    dsym &&
                                                    dsym->kind ==
                                                        SymbolKind::Parameter) {
                                                    auto dv =
                                                        dsym->as<ParameterSymbol>()
                                                            .getValue();
                                                    if (dv.isInteger())
                                                        return dv;
                                                }
                                            }
                                            auto pv =
                                                sym.as<ParameterSymbol>()
                                                    .getValue();
                                            if (pv.isInteger())
                                                return pv;
                                            return std::nullopt;
                                        }
                                        return std::nullopt;
                                    }
                                    default: {
                                        // Literals and param-free subtrees fold
                                        // via the normal instance context.
                                        ASTContext ec(*currentScope,
                                                      LookupLocation::max);
                                        if (auto cv = ec.tryEval(e);
                                            cv && cv.isInteger())
                                            return cv;
                                        return std::nullopt;
                                    }
                                    }
                                };
                                if (!be.bad())
                                    if (auto dcv = evalDef(be);
                                        dcv && dcv->isInteger() &&
                                        !dcv->integer().hasUnknown())
                                        value = *dcv->integer().as<int64_t>();
                            }
                        }
                        // A packed range bound referencing a LOCALPARAM whose
                        // init reads a MEMBER of a struct-typed parameter
                        // (localparam int N = Info.x) stays SYMBOLIC in Surelog:
                        // the localparam ref is SUBSTITUTED by a re-emission of
                        // its init hier_path (Info.x), kept unfolded. Applies in
                        // both def and elab module views (module signal dims).
                        // Follow a param's init chain: a param whose init reads
                        // a struct-param MEMBER (N = Info.x) IS the member-init
                        // param; a param whose init is a bare ref to another
                        // param (an OVERRIDE, Depth = N) recurses. Returns the
                        // member-init param whose init hier_path is re-emitted.
                        std::function<const ParameterSymbol*(
                            const ParameterSymbol*, int)>
                            resolveMemberInit =
                                [&](const ParameterSymbol* p,
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
                                return resolveMemberInit(
                                    &rs->as<ParameterSymbol>(), depth + 1);
                            return nullptr;
                        };
                        const ParameterSymbol* memberInitParam = nullptr;
                        if (bsyn && currentScope && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim &&
                            !ifacePortBound && !defPortDim) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad())
                                be.visit(makeVisitor(
                                    [&](auto& v, const NamedValueExpression& nv) {
                                        if (memberInitParam)
                                            return;
                                        if (nv.symbol.kind ==
                                            SymbolKind::Parameter)
                                            memberInitParam = resolveMemberInit(
                                                &nv.symbol
                                                     .as<ParameterSymbol>(),
                                                0);
                                        v.visitDefault(nv);
                                    }));
                        }
                        // An ELAB child whose module parameter is OVERRIDDEN at
                        // the instantiation by a HIERARCHICAL expression
                        // (#(.SYS_DAT(s.CFG.BUS.DAT))) keeps the bound
                        // SYMBOLIC, substituting that hier expression for the
                        // param reference — Surelog's reduce never crosses the
                        // interface-member hop, so the child's own widths stay
                        // unfolded (iface_param_2level). The hier_path is
                        // anchored at the BOUND's token span; its elements
                        // carry the override-site spans.
                        const ParameterSymbol* ovHierParam = nullptr;
                        if (!memberInitParam && bsyn && currentScope &&
                            elabInstanceTs && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim &&
                            !ifacePortBound) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad())
                                be.visit(makeVisitor(
                                    [&](auto& v, const NamedValueExpression& nv) {
                                        if (ovHierParam)
                                            return;
                                        if (nv.symbol.kind ==
                                                SymbolKind::Parameter &&
                                            isOverriddenParam(nv.symbol))
                                            if (auto* pin =
                                                    nv.symbol
                                                        .as<ParameterSymbol>()
                                                        .getInitializer()) {
                                                auto& top0 =
                                                    stripImplicitConv(*pin);
                                                const Expression* b0 = &top0;
                                                while (b0->kind ==
                                                       ExpressionKind::MemberAccess)
                                                    b0 = &stripImplicitConv(
                                                        b0->as<MemberAccessExpression>()
                                                            .value());
                                                if (b0 != &top0 &&
                                                    b0->kind ==
                                                        ExpressionKind::HierarchicalValue &&
                                                    b0->as<HierarchicalValueExpression>()
                                                            .symbol.kind ==
                                                        SymbolKind::Parameter)
                                                    ovHierParam =
                                                        &nv.symbol
                                                             .as<ParameterSymbol>();
                                            }
                                        v.visitDefault(nv);
                                    }));
                        }
                        if (ovHierParam) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            NetMap none;
                            std::string bpfx = boundOwnerFullName;
                            // Re-emit the OVERRIDE expression as a hier_path
                            // anchored at `anchor` (the param-ref token in the
                            // bound), with a ts ref scoped under the declaring
                            // signal whose actual is the param's own typespec.
                            auto emitOvHier =
                                [&](UHDM::BaseClass* par,
                                    const syntax::ExpressionSyntax* anchor)
                                -> UHDM::expr* {
                                auto* ovi = ovHierParam->getInitializer();
                                auto* he = (UHDM::expr*)emitExpr(*ovi, par, bpfx,
                                                                 none);
                                if (he &&
                                    he->UhdmType() == UHDM::uhdmhier_path) {
                                    auto* hp = (UHDM::hier_path*)he;
                                    if (anchor)
                                        setLoc(hp, anchor->sourceRange());
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(
                                        bpfx.empty()
                                            ? std::string(hp->VpiName())
                                            : bpfx + "." +
                                                  std::string(hp->VpiName()));
                                    rt->VpiParent(hp);
                                    auto* its = s.MakeInt_typespec();
                                    if (auto dt = ovHierParam->getDeclaredType())
                                        if (auto* tsyn = dt->getTypeSyntax())
                                            setLoc(its, tsyn->sourceRange());
                                    if (ovHierParam->getType().isSigned())
                                        its->VpiSigned(true);
                                    rt->Actual_typespec(its);
                                    hp->Typespec(rt);
                                    // An UNSCOPED (def-view) re-emit leaves the
                                    // tail element BARE — no ".DAT" fullname.
                                    if (bpfx.empty() && hp->Path_elems())
                                        for (auto* pe0 : *hp->Path_elems())
                                            if (pe0->UhdmType() ==
                                                UHDM::uhdmref_obj) {
                                                auto* r0 = (UHDM::ref_obj*)pe0;
                                                if (!r0->VpiFullName().empty() &&
                                                    r0->VpiFullName()[0] == '.')
                                                    r0->VpiFullName("");
                                            }
                                    // vpiExpr = the ENCLOSING instance's
                                    // interface-port LowConn ref (the very
                                    // object Surelog aliases here).
                                    std::string hn(hp->VpiName());
                                    if (auto d0 = hn.find('.');
                                        d0 != std::string::npos)
                                        hn.resize(d0);
                                    std::string up0 = bpfx;
                                    for (int k0 = 0; k0 < 2; k0++)
                                        if (auto d1 = up0.rfind('.');
                                            d1 != std::string::npos)
                                            up0.resize(d1);
                                        else
                                            up0.clear();
                                    UHDM::ref_obj* lcRef = nullptr;
                                    if (!up0.empty() && !hn.empty())
                                        if (auto lit = ifacePortLowConnByPath.find(
                                                up0 + "." + hn);
                                            lit != ifacePortLowConnByPath.end())
                                            lcRef = lit->second;
                                    // Def-view re-emit (no instance path): reach
                                    // the port SYMBOL through the AST instead.
                                    if (!lcRef && !hn.empty()) {
                                        const InstanceBodySymbol* ib9 = nullptr;
                                        for (auto sc9 =
                                                 ovHierParam->getParentScope();
                                             sc9;
                                             sc9 = sc9->asSymbol().getParentScope())
                                            if (sc9->asSymbol().kind ==
                                                SymbolKind::InstanceBody) {
                                                ib9 = &sc9->asSymbol()
                                                           .as<InstanceBodySymbol>();
                                                break;
                                            }
                                        if (ib9 && ib9->parentInstance)
                                            if (auto* psc9 =
                                                    ib9->parentInstance
                                                        ->getParentScope())
                                                if (auto* sy9 = psc9->find(hn);
                                                    sy9 &&
                                                    sy9->kind ==
                                                        SymbolKind::InterfacePort)
                                                    if (auto sit9 =
                                                            ifacePortLowConnBySym
                                                                .find(sy9);
                                                        sit9 !=
                                                        ifacePortLowConnBySym.end())
                                                        lcRef = sit9->second;
                                    }
                                    if (lcRef)
                                        hp->Root_value(lcRef);
                                }
                                return he;
                            };
                            if (!be.bad() &&
                                stripImplicitConv(be).kind ==
                                    ExpressionKind::BinaryOp &&
                                syntax::BinaryExpressionSyntax::isKind(
                                    bsyn->kind)) {
                                auto& bin =
                                    stripImplicitConv(be).as<BinaryExpression>();
                                auto& bsx =
                                    bsyn->as<syntax::BinaryExpressionSyntax>();
                                auto* op = s.MakeOperation();
                                op->VpiOpType(mapBinaryOp(bin.op));
                                op->VpiParent(r);
                                setLoc(op, bsyn->sourceRange());
                                auto* operands = s.MakeAnyVec();
                                if (auto* l = emitOvHier(op, bsx.left))
                                    operands->push_back(l);
                                int64_t rval = 1;
                                if (auto rcv = bctx.tryEval(bin.right());
                                    rcv && rcv.isInteger())
                                    rval = *rcv.integer().as<int64_t>();
                                operands->push_back(
                                    makeBoundConst(bsx.right, rval, op));
                                op->Operands(operands);
                                return op;
                            }
                            if (bsyn->kind == syntax::SyntaxKind::IdentifierName)
                                if (auto* he = emitOvHier(r, bsyn))
                                    return he;
                        }
                        if (memberInitParam) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            NetMap none;
                            std::string bpfx = boundOwnerFullName;
                            // Re-emit N's init (Info.x) as a hier_path, and
                            // attach a ref_typespec scoped under the declaring
                            // signal (work@top.data.Info.x) whose actual is N's
                            // own (int) typespec.
                            auto emitInitHier =
                                [&](UHDM::BaseClass* par) -> UHDM::expr* {
                                auto* init = memberInitParam->getInitializer();
                                auto* he = (UHDM::expr*)emitExpr(*init, par, bpfx,
                                                                 none);
                                if (he &&
                                    he->UhdmType() == UHDM::uhdmhier_path) {
                                    auto* hp = (UHDM::hier_path*)he;
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(
                                        bpfx.empty()
                                            ? std::string(hp->VpiName())
                                            : bpfx + "." +
                                                  std::string(hp->VpiName()));
                                    rt->VpiParent(hp);
                                    auto* its = s.MakeInt_typespec();
                                    if (auto dt =
                                            memberInitParam->getDeclaredType())
                                        if (auto* tsyn = dt->getTypeSyntax())
                                            setLoc(its, tsyn->sourceRange());
                                    if (memberInitParam->getType().isSigned())
                                        its->VpiSigned(true);
                                    rt->Actual_typespec(its);
                                    hp->Typespec(rt);
                                }
                                return he;
                            };
                            if (!be.bad() &&
                                stripImplicitConv(be).kind ==
                                    ExpressionKind::BinaryOp) {
                                auto& bin =
                                    stripImplicitConv(be).as<BinaryExpression>();
                                auto* op = s.MakeOperation();
                                op->VpiOpType(mapBinaryOp(bin.op));
                                op->VpiParent(r);
                                setLoc(op, bsyn->sourceRange());
                                auto* operands = s.MakeAnyVec();
                                if (auto* l = emitInitHier(op))
                                    operands->push_back(l);
                                const syntax::ExpressionSyntax* rsub = nullptr;
                                if (syntax::BinaryExpressionSyntax::isKind(
                                        bsyn->kind))
                                    rsub =
                                        bsyn->as<syntax::BinaryExpressionSyntax>()
                                            .right;
                                int64_t rval = 1;
                                if (auto rcv = bctx.tryEval(bin.right());
                                    rcv && rcv.isInteger())
                                    rval = *rcv.integer().as<int64_t>();
                                if (rsub)
                                    operands->push_back(
                                        makeBoundConst(rsub, rval, op));
                                op->Operands(operands);
                                return op;
                            }
                            if (auto* he = emitInitHier(r))
                                return he;
                        }
                        // A packed-range bound that READS a parameter whose own
                        // elab Rhs stayed a symbolic const call has no value to
                        // fold: Surelog substitutes the CALL for the reference
                        // (arguments already reduced) and leaves the enclosing
                        // arithmetic as an operation.  FuncInModule's
                        // `logic [NEXT_N-1:0][WIDTH-1:0] next_data` keeps
                        // `get_next_n(<64'b..>) - 1` while the second dim's
                        // `WIDTH-1` — a plain valued parameter — folds to 1 in
                        // the same typespec.
                        const ParameterSymbol* symCallParam = nullptr;
                        if (bsyn && currentScope && !memberInitParam &&
                            !ovHierParam && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim &&
                            !ifacePortBound && !defPortDim) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad())
                                be.visit(makeVisitor(
                                    [&](auto& v, const NamedValueExpression& nv) {
                                        if (!symCallParam &&
                                            nv.symbol.kind ==
                                                SymbolKind::Parameter &&
                                            elabParamCallSymbolic(
                                                nv.symbol.as<ParameterSymbol>()))
                                            symCallParam =
                                                &nv.symbol.as<ParameterSymbol>();
                                        v.visitDefault(nv);
                                    }));
                        }
                        if (symCallParam) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            NetMap none;
                            std::string bpfx = boundOwnerFullName;
                            // Re-emit the parameter's own call at the reference
                            // token's span, carrying a ts ref scoped under the
                            // declaring signal whose actual is the parameter's
                            // typespec (the same shape the ovHierParam and
                            // memberInitParam substitutions take).
                            auto emitSymCall =
                                [&](UHDM::BaseClass* par,
                                    const syntax::ExpressionSyntax* anchor)
                                -> UHDM::expr* {
                                bool sIP = inParamInit, sPD = paramInitDef;
                                bool sPP = paramInitPkg, sMD = elabMdimParamInit;
                                inParamInit = true;
                                paramInitDef = false;
                                paramInitPkg = false;
                                elabMdimParamInit = false;
                                auto* ce = (UHDM::expr*)emitExpr(
                                    *symCallParam->getInitializer(), par, bpfx,
                                    none);
                                inParamInit = sIP;
                                paramInitDef = sPD;
                                paramInitPkg = sPP;
                                elabMdimParamInit = sMD;
                                if (ce) {
                                    if (anchor)
                                        setLoc(ce, anchor->sourceRange());
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(bpfx);
                                    rt->VpiParent(ce);
                                    auto* its = s.MakeInt_typespec();
                                    if (auto dt = symCallParam->getDeclaredType())
                                        if (auto* tsyn = dt->getTypeSyntax())
                                            setLoc(its, tsyn->sourceRange());
                                    if (symCallParam->getType().isSigned())
                                        its->VpiSigned(true);
                                    rt->Actual_typespec(its);
                                    if (ce->UhdmType() == UHDM::uhdmfunc_call)
                                        ((UHDM::func_call*)ce)->Typespec(rt);
                                }
                                return ce;
                            };
                            if (!be.bad() &&
                                stripImplicitConv(be).kind ==
                                    ExpressionKind::BinaryOp &&
                                syntax::BinaryExpressionSyntax::isKind(
                                    bsyn->kind)) {
                                auto& bin =
                                    stripImplicitConv(be).as<BinaryExpression>();
                                auto& bsx =
                                    bsyn->as<syntax::BinaryExpressionSyntax>();
                                auto* op = s.MakeOperation();
                                op->VpiOpType(mapBinaryOp(bin.op));
                                op->VpiParent(r);
                                setLoc(op, bsyn->sourceRange());
                                auto* operands = s.MakeAnyVec();
                                if (auto* l = emitSymCall(op, bsx.left))
                                    operands->push_back(l);
                                int64_t rval = 1;
                                if (auto rcv = bctx.tryEval(bin.right());
                                    rcv && rcv.isInteger())
                                    rval = *rcv.integer().as<int64_t>();
                                operands->push_back(
                                    makeBoundConst(bsx.right, rval, op));
                                op->Operands(operands);
                                return op;
                            }
                            if (bsyn->kind == syntax::SyntaxKind::IdentifierName)
                                if (auto* he = emitSymCall(r, bsyn))
                                    return he;
                        }
                        if ((tfContext && !tfFormalTs) || bitsOfSignal ||
                            bareParamInParamTs || defModuleParamDim ||
                            ifacePortBound || structMemberSymBound ||
                            unitXFileVarBound) {
                            // Function/typedef context: unfolded expression.
                            bool savedBCN = boundCallNameSpan;
                            boundCallNameSpan = true;
                            // A DEF-view PACKAGE param bound keeps its param
                            // ref linked to the referenced package param's own
                            // def Rhs (Surelog value-ref chaining) — the same
                            // tf-type-scope resolver the package enum bases
                            // use. Without it the ref_obj dangles and Compare
                            // reports `failLhs=constant failRhs=<null>`.
                            const slang::ast::Scope* savedTfS7 = tfTypeScope;
                            bool setTf7 = false;
                            if (pkgParamTsRef && !tfTypeScope) {
                                tfTypeScope = declSymbol.getParentScope();
                                setTf7 = true;
                            }
                            std::string savedUXF7 = unitXFileRoot;
                            if (!unitOwnRoot.empty())
                                unitXFileRoot = unitOwnRoot;
                            auto* e0bcn = emitSyntaxExpr(*bsyn, r);
                            unitXFileRoot = savedUXF7;
                            if (setTf7)
                                tfTypeScope = savedTfS7;
                            boundCallNameSpan = savedBCN;
                            if (auto* e = e0bcn) {
                                // The sys-call arg refs bind their DEF
                                // nets — deferred until the nets exist.
                                if (bitsOfSignal) {
                                    std::function<void(UHDM::any*)> bindR =
                                        [&](UHDM::any* n0) {
                                            if (!n0)
                                                return;
                                            if (n0->UhdmType() == UHDM::uhdmref_obj) {
                                                auto* r2 = (UHDM::ref_obj*)n0;
                                                if (!r2->Actual_group() && declScope)
                                                    if (auto* sy3 = declScope->find(
                                                            std::string(r2->VpiName())))
                                                        pendingBitsBoundRefs.push_back(
                                                            {r2, sy3});
                                            }
                                            else if (n0->UhdmType() ==
                                                     UHDM::uhdmoperation) {
                                                if (auto* ops2 =
                                                        ((UHDM::operation*)n0)
                                                            ->Operands())
                                                    for (auto* o2 : *ops2)
                                                        bindR(o2);
                                            }
                                            else if (n0->UhdmType() ==
                                                     UHDM::uhdmsys_func_call) {
                                                if (auto* ar2 =
                                                        ((UHDM::sys_func_call*)n0)
                                                            ->Tf_call_args())
                                                    for (auto* o2 : *ar2)
                                                        bindR(o2);
                                            }
                                        };
                                    bindR(e);
                                }
                                return (UHDM::expr*)e;
                            }
                        }
                        // Elab IFACE views re-evaluate the bound at the
                        // DEFAULT param values (per-instance overrides are
                        // ignored — Surelog's AllModules width).
                        if (ifaceDefaultScope) {
                            ASTContext dctx(*ifaceDefaultScope, LookupLocation::max);
                            auto& dbe = Expression::bind(*bsyn, dctx);
                            if (!dbe.bad())
                                if (auto dcv = dctx.tryEval(dbe);
                                    dcv && dcv.isInteger() &&
                                    !dcv.integer().hasUnknown())
                                    value = *dcv.integer().as<int64_t>();
                        }
                        // Module context: a bare reference bound ([i:i]) folds
                        // to a UINT value-constant at its token; only an
                        // OPERATION bound (N-1) folds to an INT anchored at the
                        // operator's LEFT operand span.
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        std::string digits = std::to_string(value);
                        c->VpiDecompile(digits);
                        // A PARENTHESIZED arithmetic bound (`[(2*M-1):0]`, the
                        // shape a width macro expands to) is the same
                        // reduceExpr fold as a bare one — Surelog reduces the
                        // inner operation and never records the parens. So the
                        // INT/UINT pick and the left-operand anchor both key on
                        // the UNWRAPPED expression (YosysBigSimEllip's
                        // ``define WIDTH (2*`M-1)``: golden INT:193 at the `2`
                        // token, not UINT at the `(`).
                        const syntax::ExpressionSyntax* bop = bsyn;
                        while (bop->kind ==
                               syntax::SyntaxKind::ParenthesizedExpression)
                            bop = bop->as<syntax::ParenthesizedExpressionSyntax>()
                                      .expression;
                        if (syntax::BinaryExpressionSyntax::isKind(bop->kind)) {
                            // ExprEval::reduceExpr's per-operator value type:
                            // sub/mult/div ALWAYS yield INT; add yields UINT
                            // only when BOTH reduced operands are unsigned
                            // constants, so `24 * 8 - 1 + 4` (whose left
                            // operand already reduced to INT) is INT while
                            // `N + 1` stays UINT. Both anchor at the
                            // left-operand span — except in a typedef-signal
                            // CLONE, where the constant stays BARE (no loc, no
                            // parent).
                            std::function<bool(const syntax::SyntaxNode*)>
                                redInt = [&](const syntax::SyntaxNode* n)
                                -> bool {
                                if (!n)
                                    return false;
                                switch (n->kind) {
                                    case syntax::SyntaxKind::SubtractExpression:
                                    case syntax::SyntaxKind::MultiplyExpression:
                                    case syntax::SyntaxKind::DivideExpression:
                                        return true;
                                    case syntax::SyntaxKind::AddExpression: {
                                        auto& be9 =
                                            n->as<syntax::BinaryExpressionSyntax>();
                                        return redInt(be9.left) ||
                                               redInt(be9.right);
                                    }
                                    case syntax::SyntaxKind::
                                        ParenthesizedExpression:
                                        return redInt(
                                            n->as<syntax::
                                                      ParenthesizedExpressionSyntax>()
                                                .expression);
                                    default:
                                        return false;
                                }
                            };
                            if (redInt(bop)) {
                                c->VpiConstType(vpiIntConst);
                                c->VpiValue("INT:" + digits);
                            }
                            else {
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                            }
                            if (bareCloneComputedBounds)
                                c->VpiParent(nullptr);
                            else
                                setLoc(c, bop->as<syntax::BinaryExpressionSyntax>()
                                              .left->sourceRange());
                        }
                        else {
                            // A bound that references an int-encoded param
                            // (e.g. DINW = 2**SELW) folds to a signed INT
                            // const. A bare MODULE-param ref folds at the
                            // param's width with a ts ref (loc-less signed
                            // int clone, var-scoped fullname).
                            bool intEnc = false;
                            const ParameterSymbol* boundParam = nullptr;
                            // The MODULE (InstanceBody) param a bare bound
                            // resolves to, captured regardless of typed-ness for
                            // the elab-clone width fold below.
                            const ParameterSymbol* elabModPar = nullptr;
                            // A $unit param's typespec bound that is a BARE ref
                            // to another $unit param folds at THAT param's
                            // width (32 for `int unsigned`, not the bare 64)
                            // and carries a ref_typespec named after the
                            // DECLARING param whose actual is a located clone
                            // of the referenced param's own typespec — the
                            // $unit twin of the module rule below.  Bound in
                            // the parameter's OWN scope: the $unit typespecs
                            // are minted at the very end of the export, with
                            // no currentScope left.
                            const ParameterSymbol* unitBoundParam = nullptr;
                            if (unitParamTs &&
                                bsyn->kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                ASTContext uctx(*declSymbol.getParentScope(),
                                                LookupLocation::max);
                                auto& ube = Expression::bind(*bsyn, uctx);
                                if (!ube.bad()) {
                                    auto& ubee = stripImplicitConv(ube);
                                    if (ubee.kind ==
                                            ExpressionKind::NamedValue &&
                                        ubee.as<NamedValueExpression>()
                                                .symbol.kind ==
                                            SymbolKind::Parameter)
                                        unitBoundParam =
                                            &ubee.as<NamedValueExpression>()
                                                 .symbol.as<ParameterSymbol>();
                                }
                            }
                            if (currentScope) {
                                ASTContext bctx(*currentScope, LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                if (!be.bad()) {
                                    intEnc = isIntEncoded(be);
                                    auto& bee = stripImplicitConv(be);
                                    if (bee.kind == ExpressionKind::NamedValue &&
                                        bee.as<NamedValueExpression>().symbol.kind ==
                                            SymbolKind::Parameter) {
                                        auto& bp = bee.as<NamedValueExpression>()
                                                       .symbol.as<ParameterSymbol>();
                                        // TYPED params only (untyped keep
                                        // the bare 64-bit fold).
                                        bool typedP = false;
                                        if (auto bd0 = bp.getDeclaredType())
                                            if (auto bt0 = bd0->getTypeSyntax())
                                                typedP =
                                                    bt0->kind !=
                                                    syntax::SyntaxKind::ImplicitType;
                                        if (auto bsc = bp.getParentScope();
                                            typedP && bsc &&
                                            bsc->asSymbol().kind ==
                                                SymbolKind::InstanceBody)
                                            boundParam = &bp;
                                        // A GEN-SCOPE localparam bound folds
                                        // BARE at 32 (untyped resolves to
                                        // int) — Surelog.
                                        else if (auto bsc2 =
                                                     bp.getParentScope();
                                                 bsc2 && !bp.isFromGenvar() &&
                                                 bsc2->asSymbol().kind ==
                                                     SymbolKind::GenerateBlock)
                                            c->VpiSize(32);
                                        if (auto bsc3 = bp.getParentScope();
                                            bsc3 &&
                                            bsc3->asSymbol().kind ==
                                                SymbolKind::InstanceBody)
                                            elabModPar = &bp;
                                    }
                                }
                            }
                            // Is the module param a LITERAL-initialized param of
                            // the very body this declaration lives in? (see the
                            // elab-clone width fold below)
                            auto litBoundOwnPar9 = [&]() -> bool {
                                // An OVERRIDDEN untyped param has no narrow
                                // width to lend: Surelog's instance Value for
                                // it is the plain 64-bit UINT the override
                                // actual built (the same r9c9 rule that gives
                                // the param_assign Rhs its 64-bit LValue), so
                                // every range bound folding it stays at 64
                                // (YosysOldSimpleSpi: `fifo4 #(8)` -> golden
                                // `input [dw:1]` bound UINT:8 size 64, while
                                // the un-overridden instance of the same
                                // module keeps size 32).
                                // ...unless the override ACTUAL is itself a
                                // bare reference to a literal-initialized
                                // untyped parameter. Surelog then COPIES that
                                // parameter's already-evaluated Value (the
                                // same rule that gives such an override its
                                // UINT-at-the-referenced-width param_assign
                                // Rhs, see ParamEmit), so the narrow width
                                // survives the override and every bound
                                // folding it stays at 32 (BasicOh: `oh_dsync
                                // #(.SYNCPIPE(SYNCPIPE))` over `parameter
                                // SYNCPIPE = 2` -> `reg [SYNCPIPE:0]` bound
                                // UINT:2 size 32).
                                if (isOverriddenParam(*elabModPar)) {
                                    auto* ov9 = elabModPar->getInitializer();
                                    if (!ov9)
                                        return false;
                                    auto& so9 = stripImplicitConv(*ov9);
                                    if (so9.kind != ExpressionKind::NamedValue)
                                        return false;
                                    auto& asym9 =
                                        so9.as<NamedValueExpression>().symbol;
                                    if (asym9.kind != SymbolKind::Parameter)
                                        return false;
                                    auto& ap9 = asym9.as<ParameterSymbol>();
                                    bool untypedA9 = true;
                                    if (auto ad9 = ap9.getDeclaredType())
                                        if (auto at9 = ad9->getTypeSyntax())
                                            untypedA9 =
                                                at9->kind ==
                                                syntax::SyntaxKind::ImplicitType;
                                    auto* ai9 = ap9.getInitializer();
                                    if (!untypedA9 || !ai9 ||
                                        stripImplicitConv(*ai9).kind !=
                                            ExpressionKind::IntegerLiteral)
                                        return false;
                                    return true;
                                }
                                auto* in9 = elabModPar->getInitializer();
                                if (!in9 ||
                                    stripImplicitConv(*in9).kind !=
                                        ExpressionKind::IntegerLiteral)
                                    return false;
                                auto body9 = [](const Symbol& sy9) -> const Scope* {
                                    for (auto sc9 = sy9.getParentScope(); sc9;
                                         sc9 = sc9->asSymbol().getParentScope())
                                        if (sc9->asSymbol().kind ==
                                            SymbolKind::InstanceBody)
                                            return sc9;
                                    return nullptr;
                                };
                                return body9(*elabModPar) == body9(declSymbol);
                            };
                            if (unitBoundParam) {
                                c->VpiSize((int32_t)unitBoundParam->getType()
                                               .getBitWidth());
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                                auto* rtu = s.MakeRef_typespec();
                                rtu->VpiFullName(std::string(declSymbol.name));
                                rtu->VpiParent(c);
                                auto* itsu = s.MakeInt_typespec();
                                if (auto ud = unitBoundParam->getDeclaredType())
                                    if (auto ut = ud->getTypeSyntax())
                                        setLoc(itsu,
                                               trimTypeSigning(
                                                   ut, ut->sourceRange()));
                                if (unitBoundParam->getType().isSigned())
                                    itsu->VpiSigned(true);
                                rtu->Actual_typespec(itsu);
                                c->Typespec(rtu);
                            }
                            else if (boundParam && !boundOwnerFullName.empty() &&
                                !intEnc) {
                                c->VpiSize(
                                    (int32_t)boundParam->getType().getBitWidth());
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                                auto* rt0 = s.MakeRef_typespec();
                                rt0->VpiFullName(boundOwnerFullName);
                                rt0->VpiParent(c);
                                auto* its0 = s.MakeInt_typespec();
                                if (boundParam->getType().isSigned())
                                    its0->VpiSigned(true);
                                rt0->Actual_typespec(its0);
                                c->Typespec(rt0);
                            }
                            // An ELAB var-dim bound folding a MODULE-param ref
                            // that did NOT take the typed+var-scoped ts-ref path
                            // above (an untyped int-valued param, or a typed one
                            // minted without a var-scoped owner as in a gen-child
                            // typespec clone) takes the param's own width
                            // (int-valued -> 32) but NO ts ref — Surelog.
                            // A TYPED param always carries its width; an
                            // UNTYPED param only takes its (narrow) width when
                            // its initializer is a plain integer LITERAL — one
                            // computed from a $clog2/func CALL keeps the bare
                            // 64-bit fold (Surelog).
                            // ...and only when the literal-init param is one of
                            // THIS body's own params. When slang re-uses (value-
                            // dedups) an instance body under a second parent,
                            // currentScope here is the ENCLOSING module, so a
                            // same-named param of the parent resolves bogusly and
                            // would lend its (narrow) default width; Surelog,
                            // which never dedups, folds those at 64 (multiplier:
                            // RippleCarryAdder#(M+i) instantiated from two
                            // different top modules that both declare N).
                            else if (elabModPar && !intEnc &&
                                     (boundParam || litBoundOwnPar9())) {
                                c->VpiSize(
                                    (int32_t)elabModPar->getType().getBitWidth());
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                            }
                            else {
                                c->VpiConstType(intEnc ? vpiIntConst : vpiUIntConst);
                                c->VpiValue((intEnc ? "INT:" : "UINT:") + digits);
                            }
                            setLoc(c, bsyn->getFirstToken().range());
                        }
                        return c;
                    };
                    r->Left_expr(emitBound(lsyn, dims[i].left));
                    r->Right_expr(emitBound(rsyn, dims[i].right));
                    ranges->push_back(r);
                }
                ts->Ranges(ranges);
            }
            else {
                noteUnsupported("packed dimension shape");
            }
        }
        else {
            // NamedType + extra packed dims (reg8_t [0:3] x): golden emits the
            // net with NO typespec; emit a dim-less logic ts (callers require
            // non-null) — close enough to unblock (dump shows the bare ts).
        }
    }
    return ts;
}

UHDM::variables* UhdmExporter::makeVar(const Symbol& internal, bool portBacked) {
    auto declared = internal.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& ct = declared->getType().getCanonicalType();
    // A Verilog-mode module-scope `logic x;` Surelog never resolved stays a
    // NET through elaboration (vlogUnresolvedLogicNet).
    if (vlogUnresolvedLogicNet(internal))
        return nullptr;
    // Non-port `logic` variables become logic_vars in the elaborated view;
    // `reg` declarations stay logic_nets — and the `reg` keyword travels
    // through a typedef chain (`typedef reg [1:0] R; R y;` is a net with
    // vpiNetType 48, LogicTypedef), so read the WRITTEN keyword behind the
    // alias, not the resolved type.
    bool regDecl = false;
    if (auto tsyn = declared->getTypeSyntax())
        regDecl = tsyn->kind == syntax::SyntaxKind::RegType ||
                  aliasVectorKeyword(declared->getType()) ==
                      syntax::SyntaxKind::RegType;
    // A `parameter type T`-typed port elaborates as a variable of its resolved
    // type (Surelog), even though the def view keeps it a net.
    bool typeParamPort = portTypeParam(internal) != nullptr;
    // Enum variables — and PORTS typed by an enum typedef declared OUTSIDE the
    // module (a PACKAGE: `input custom::enum1 e`; or the COMPILATION UNIT:
    // AllBinding's `$unit`-scope `typedef enum ... type_scr1_mem_resp_e` used
    // by `input type_scr1_mem_resp_e p`), or by a `type` parameter resolving to
    // an enum — elaborate as enum_vars. A MODULE-local enum typedef port stays
    // a net.
    bool pkgEnumAlias = false;
    if (ct.kind == SymbolKind::EnumType) {
        auto& t0 = declared->getType();
        if (t0.kind == SymbolKind::TypeAlias)
            if (auto sc0 = t0.as<TypeAliasType>().getParentScope();
                sc0 && (sc0->asSymbol().kind == SymbolKind::Package ||
                        sc0->asSymbol().kind == SymbolKind::CompilationUnit))
                pkgEnumAlias = true;
    }
    if (ct.kind == SymbolKind::EnumType &&
        (internal.kind == SymbolKind::Variable || pkgEnumAlias || typeParamPort)) {
        auto* v = s.MakeEnum_var();
        v->VpiVisibility(1);
        return v;
    }
    // Class handles are class_vars in the elab view.
    if (ct.kind == SymbolKind::ClassType) {
        auto* v = s.MakeClass_var();
        v->VpiVisibility(1);
        return v;
    }
    // A TYPEDEF'd union variable elaborates as a union_var; an ANONYMOUS one
    // (declared type IS the union, not an alias) routes to the net path as a
    // struct_net (Surelog) — return null so the caller falls through.
    if (ct.kind == SymbolKind::PackedUnionType) {
        if (declared->getType().kind == SymbolKind::PackedUnionType)
            return nullptr;
        auto* v = s.MakeUnion_var();
        v->VpiVisibility(1);
        return v;
    }
    // A 2-STATE `bit` signal can never be a net — bit_var, even for ports
    // (Surelog). A packed VECTOR of bit (`output bit [6:0] a`, BitRanges) is
    // the same object: the packed dims live on the bit_typespec, so the leaf
    // element decides. `byte`/`int`/... are 2-state too but take their own
    // var classes below (PredefinedIntegerType), so only a ScalarType leaf
    // qualifies here.
    if (ct.kind == SymbolKind::ScalarType || ct.kind == SymbolKind::PackedArrayType) {
        const Type* bl = &ct;
        while (bl->getCanonicalType().kind == SymbolKind::PackedArrayType)
            bl = &bl->getCanonicalType().as<PackedArrayType>().elementType;
        auto& blc = bl->getCanonicalType();
        if (blc.kind == SymbolKind::ScalarType && blc.isIntegral() &&
            !blc.isFourState()) {
            auto* v = s.MakeBit_var();
            v->VpiVisibility(1);
            return v;
        }
    }
    // Real/shortreal signals are variables, never nets.
    if (ct.kind == SymbolKind::FloatingType) {
        auto* v = ct.as<FloatingType>().floatKind == FloatingType::ShortReal
                      ? (UHDM::variables*)s.MakeShort_real_var()
                      : (UHDM::variables*)s.MakeReal_var();
        v->VpiVisibility(1);
        return v;
    }
    // String signals are variables.
    if (ct.kind == SymbolKind::StringType) {
        auto* v = s.MakeString_var();
        v->VpiVisibility(1);
        return v;
    }
    // chandle signals are variables (never nets).
    if (ct.kind == SymbolKind::CHandleType) {
        auto* v = s.MakeChandle_var();
        v->VpiVisibility(1);
        return v;
    }
    // Packed structs become struct_nets (handled by the net branch) —
    // except 2-STATE structs (int members etc.), which cannot be nets and
    // elaborate as struct_vars.
    if (ct.kind == SymbolKind::PackedStructType) {
        if (!ct.isFourState()) {
            auto* v = s.MakeStruct_var();
            v->VpiVisibility(1);
            return v;
        }
        // An ANSI port typed by a `parameter type` the INSTANCE OVERRIDES is a
        // struct_var, not a struct_net (TypeParamElab: `output DATA_T
        // oup_data_o` is a logic_net in the def view where DATA_T is still
        // `logic`, and a struct_var in `i_arb`, whose DATA_T was overridden to
        // a packed struct). The override is what matters, not the resolved
        // type: PackageTypeParam's `input TYPE_PARAMETER input_struct` uses the
        // parameter's own `new_package::zzz` DEFAULT and stays a struct_net in
        // every view.
        if (auto* tpp9 = portTypeParam(internal); tpp9 && tpp9->isOverridden()) {
            auto* v = s.MakeStruct_var();
            v->VpiVisibility(1);
            return v;
        }
        // A 4-state struct whose TOP-LEVEL fields include an ATOM
        // (byte/int/integer), an ENUM, or any 2-state member is a struct_var
        // too (net_types decode) — but only for plain non-port, no-init,
        // non-portBacked declarations.
        if (!portBacked && internal.kind == SymbolKind::Variable &&
            !internal.getDeclaredType()->getInitializer()) {
            bool atomField = false;
            for (auto& fm :
                 ct.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                auto& fct = fm.getType().getCanonicalType();
                if (fct.kind == SymbolKind::PredefinedIntegerType ||
                    fct.kind == SymbolKind::EnumType ||
                    fct.kind == SymbolKind::PackedUnionType ||
                    !fct.isFourState()) {
                    atomField = true;
                    break;
                }
            }
            if (atomField) {
                auto* v = s.MakeStruct_var();
                v->VpiVisibility(1);
                return v;
            }
        }
        return nullptr;
    }
    // A packed array over a packed struct that reached here (its element is an
    // ANONYMOUS struct, so emitPackedStructArrayVar didn't fire) is a
    // struct_var carrying the shared packed_array_typespec.
    if (ct.kind == SymbolKind::PackedArrayType) {
        const Type* lf = &ct;
        while (lf->getCanonicalType().kind == SymbolKind::PackedArrayType)
            lf = &lf->getCanonicalType().as<PackedArrayType>().elementType;
        if (lf->getCanonicalType().kind == SymbolKind::PackedStructType) {
            auto* v = s.MakeStruct_var();
            v->VpiVisibility(1);
            return v;
        }
    }
    // A non-port logic variable, or a port with a separate `logic` body
    // redeclaration (input [3:0] a; logic [3:0] a;), is a logic_var; a plain
    // ANSI port stays a net. A port typed by a SCOPED package vector typedef
    // (output my_pkg::word o) is a logic_var too — but an IMPORTED
    // unqualified typedef port (import pkg::T; output T o) stays a net.
    bool pkgAliasPort = false;
    {
        auto& t = declared->getType();
        if (t.kind == SymbolKind::TypeAlias)
            if (auto sc = t.as<TypeAliasType>().getParentScope();
                sc && sc->asSymbol().kind == SymbolKind::Package) {
                pkgAliasPort = true;
                if (auto tsyn = declared->getTypeSyntax();
                    tsyn && tsyn->kind == syntax::SyntaxKind::NamedType &&
                    tsyn->as<syntax::NamedTypeSyntax>().name->kind ==
                        syntax::SyntaxKind::IdentifierName)
                    pkgAliasPort = false;
            }
    }
    // An ANSI port spelling `var` explicitly (input var logic i1) elaborates
    // as a logic_var; the same port without the keyword stays a net
    // (StandardNetVar is the calibration point: i1/o1 are vars, i2/i3/o2 nets).
    // A directionless TYPED ANSI port (`module m(logic a, b)`) is a variable
    // to Surelog even though slang models it as an inout NET (EmitHelpers
    // ansiDirectionlessVarPort).
    bool dirlessVarPort = portBacked && ansiDirectionlessVarPort(internal);
    if ((!portBacked || hasBodyDecl(internal) || pkgAliasPort || typeParamPort ||
         ansiVarKeywordPort(internal) || dirlessVarPort) &&
        !regDecl &&
        (internal.kind == SymbolKind::Variable || typeParamPort ||
         dirlessVarPort) &&
        ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() && ct.isFourState()) {
        auto* v = s.MakeLogic_var();
        v->VpiVisibility(1);
        // TYPEDEF'd vars carry signedness on the shared typespec only.
        if (ct.isSigned() && declared->getType().kind != SymbolKind::TypeAlias)
            v->VpiSigned(true);
        return v;
    }
    // A NET of a predefined-integer type (wire integer x) stays a NET in
    // the elab too (net_types decode: only Variables and ports become vars).
    if (ct.kind == SymbolKind::PredefinedIntegerType &&
        (internal.kind != SymbolKind::Net || portBacked ||
         !hasExplicitNetKeyword(internal))) {
        auto& pit = ct.as<PredefinedIntegerType>();
        // A var declared through a NAME (a typedef or a `parameter type`)
        // carries its signedness on the shared typespec only — the same rule
        // the logic_var arm above already applies. Surelog reads vpiSigned off
        // the DECLARATION's own signing syntax, and a name has none: measured
        // on `typedef int myint_t; myint_t td_i;` -> int_var with NO vpiSigned
        // while `int plain_i;` in the same module keeps it, and identically
        // for `parameter type T = int; T tv;` (r10c15 matrix c/d).
        bool namedTy9 = declared->getType().kind == SymbolKind::TypeAlias;
        switch (pit.integerKind) {
            case PredefinedIntegerType::Int: {
                auto* v = s.MakeInt_var();
                v->VpiSigned(pit.isSigned && !namedTy9);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Integer: {
                auto* v = s.MakeInteger_var();
                v->VpiSigned(pit.isSigned && !namedTy9);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::ShortInt: {
                auto* v = s.MakeShort_int_var();
                v->VpiSigned(pit.isSigned && !namedTy9);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::LongInt: {
                auto* v = s.MakeLong_int_var();
                v->VpiSigned(pit.isSigned && !namedTy9);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Byte: {
                auto* v = s.MakeByte_var();
                v->VpiSigned(pit.isSigned && !namedTy9);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Time: {
                // A `time` PORT stays a logic_net (time_typespec actual);
                // only non-port time variables become time_vars.
                if (portBacked)
                    return nullptr;
                auto* v = s.MakeTime_var();
                v->VpiVisibility(1);
                return v;
            }
            default:
                return nullptr;
        }
    }
    return nullptr;
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
        // rawText returns "" for MACRO-expanded ranges (call-site offsets do
        // not map into the buffer) — fall back to the numeric value.
        std::string raw = rawText(syn->sourceRange());
        c->VpiDecompile(raw.empty() ? std::to_string(value) : raw);
    }
    return c;
}

UHDM::typespec* UhdmExporter::makeTypeParamDefaultTs(
    const syntax::DataTypeSyntax& defSyn, const Scope& body) {
    ASTContext actx(body, LookupLocation::max);
    const Type& dt = comp.getType(defSyn, actx);
    const Type& ct = dt.getCanonicalType();
    // A default that NAMES a typedef/enum shares that typedef's own typespec
    // object.  Keyed on the ALIAS SYMBOL, not on the canonical type: an
    // anonymous default that happens to be structurally equal to some typedef
    // (`parameter type F = logic [7:0]` where a `typedef logic [7:0] vec_t`
    // also exists) builds its OWN typespec in Surelog and must not borrow the
    // typedef's named object (r10c15 matrix, m2.F).
    if (dt.kind == SymbolKind::TypeAlias) {
        if (auto it = typedefTs.find(&dt); it != typedefTs.end())
            return it->second;
        // Not yet emitted (or emitted under another alias in the chain):
        // fall back to the canonical match, which is what this did before.
        for (auto& [sym, tsp] : typedefTs)
            if (sym->kind == SymbolKind::TypeAlias &&
                &sym->as<TypeAliasType>().getCanonicalType() == &ct)
                return tsp;
    }
    // Surelog's CompileType mints the DEFAULT type's own typespec CLASS —
    // `int`/`byte`/`integer`/`shortint`/`longint`/`bit`/`real`/`string` each
    // get theirs, only `logic`/`reg` (and packed vectors of them) land on
    // logic_typespec (r10c15 15-case matrix).  vpiSigned follows the type.
    // Restricted to the SCALAR leaf kinds the matrix measured; an anonymous
    // aggregate default (a bare `enum`/`struct` written in the parameter) is
    // left on the logic_typespec fallback it has always had.
    const Type* leaf9 = &ct;
    while (leaf9->isPackedArray())
        leaf9 = &leaf9->as<PackedArrayType>().elementType.getCanonicalType();
    UHDM::typespec* ts = nullptr;
    if (leaf9->kind == SymbolKind::PredefinedIntegerType ||
        leaf9->kind == SymbolKind::ScalarType ||
        leaf9->kind == SymbolKind::FloatingType ||
        leaf9->kind == SymbolKind::StringType)
        ts = bareElemTypespec(s, ct);
    if (!ts)
        ts = s.MakeLogic_typespec();
    setLoc(ts, defSyn.sourceRange());
    if (dt.isSigned()) {
        switch (ts->UhdmType()) {
            case UHDM::uhdmlogic_typespec:
                ((UHDM::logic_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmbit_typespec:
                ((UHDM::bit_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmint_typespec:
                ((UHDM::int_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdminteger_typespec:
                ((UHDM::integer_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmshort_int_typespec:
                ((UHDM::short_int_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmlong_int_typespec:
                ((UHDM::long_int_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmbyte_typespec:
                ((UHDM::byte_typespec*)ts)->VpiSigned(true);
                break;
            case UHDM::uhdmtime_typespec:
                ((UHDM::time_typespec*)ts)->VpiSigned(true);
                break;
            default:
                break;
        }
    }
    // Packed vector dims -> ranges (bounds as UINT constants, source spans from
    // the default type-syntax dimensions).
    const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dimSyns = nullptr;
    if (syntax::IntegerTypeSyntax::isKind(defSyn.kind))
        dimSyns = &defSyn.as<syntax::IntegerTypeSyntax>().dimensions;
    if (dimSyns && ct.isPackedArray()) {
        std::vector<ConstantRange> dims;
        const Type* t = &ct;
        while (t->isPackedArray()) {
            dims.push_back(t->as<PackedArrayType>().range);
            t = &t->as<PackedArrayType>().elementType.getCanonicalType();
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
                    dimSyn->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& spec = dimSyn->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
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
            if (ts->UhdmType() == UHDM::uhdmbit_typespec)
                ((UHDM::bit_typespec*)ts)->Ranges(ranges);
            else
                ((UHDM::logic_typespec*)ts)->Ranges(ranges);
        }
    }
    return ts;
}

UHDM::typespec* UhdmExporter::sharedTypespec(const Symbol& declSymbol, TsCache& cache,
                                             const PortSymbol* portCtx) {
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
    auto* ts = makeTypespec(declSymbol, nullptr, portCtx);
    cache[key] = ts;
    return ts;
}

// Shared enum_typespec builder: base typespec (when the syntax declares
// one) + enum constants with Surelog value encodings.
UHDM::enum_typespec* UhdmExporter::buildEnumTs(const EnumType& et,
                                               const syntax::SyntaxNode* enumSyn,
                                               const std::string& refFullName,
                                               bool implicitBaseRef) {
    auto* ets = s.MakeEnum_typespec();
    const syntax::SyntaxNode* baseSyn = nullptr;
    if (enumSyn && enumSyn->kind == syntax::SyntaxKind::EnumType)
        baseSyn = enumSyn->as<syntax::EnumTypeSyntax>().baseType;
    if (baseSyn) {
        // An enum whose base is written as a TYPEDEF NAME
        // (`typedef enum uvm_field_flag_t {...} uvm_radix_enum;`) takes that
        // typedef's OWN shared typespec as its vpiBaseTypespec — Surelog
        // compiles the base through the datatype map, so the object is the
        // very one the typedef listed, name and all.  Minting a fresh
        // vector typespec from the base's canonical shape instead is a cmp
        // difference on the enum (BuildUVMPkg: `bit_typespec(uvm_field_flag_t)`
        // vs a bare `logic_typespec`).
        // ...but it is a SEPARATE object from the one the package lists: the
        // package listing renames its copy `<pkg>::<alias>` (UhdmWriter's
        // writeDataTypes) while the base keeps the BARE alias name, and both
        // are spanned at the typedef.  So this is a shallow clone of the
        // shared typespec — same kind, same ranges, bare name.
        if (baseSyn->kind == syntax::SyntaxKind::NamedType &&
            et.baseType.kind == SymbolKind::TypeAlias)
            if (auto* shb = sharedAliasTs(et.baseType)) {
                UHDM::typespec* cl0 = nullptr;
                if (shb->UhdmType() == UHDM::uhdmbit_typespec) {
                    auto* o0 = (UHDM::bit_typespec*)shb;
                    auto* n0 = s.MakeBit_typespec();
                    n0->VpiSigned(o0->VpiSigned());
                    n0->VpiVector(o0->VpiVector());
                    if (o0->Ranges())
                        n0->Ranges(o0->Ranges());
                    if (o0->Bit_typespec())
                        n0->Bit_typespec(o0->Bit_typespec());
                    if (o0->Typespec())
                        n0->Typespec(o0->Typespec());
                    if (o0->Left_expr())
                        n0->Left_expr(o0->Left_expr());
                    if (o0->Right_expr())
                        n0->Right_expr(o0->Right_expr());
                    cl0 = n0;
                }
                else if (shb->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* o0 = (UHDM::logic_typespec*)shb;
                    auto* n0 = s.MakeLogic_typespec();
                    n0->VpiSigned(o0->VpiSigned());
                    n0->VpiVector(o0->VpiVector());
                    if (o0->Ranges())
                        n0->Ranges(o0->Ranges());
                    if (o0->Elem_typespec())
                        n0->Elem_typespec(o0->Elem_typespec());
                    if (o0->Index_typespec())
                        n0->Index_typespec(o0->Index_typespec());
                    if (o0->Left_expr())
                        n0->Left_expr(o0->Left_expr());
                    if (o0->Right_expr())
                        n0->Right_expr(o0->Right_expr());
                    cl0 = n0;
                }
                if (cl0) {
                    cl0->VpiName(et.baseType.name);
                    cl0->VpiFile(shb->VpiFile());
                    cl0->VpiLineNo(shb->VpiLineNo());
                    cl0->VpiColumnNo(shb->VpiColumnNo());
                    cl0->VpiEndLineNo(shb->VpiEndLineNo());
                    cl0->VpiEndColumnNo(shb->VpiEndColumnNo());
                    auto* brt0 = s.MakeRef_typespec();
                    brt0->VpiFullName(refFullName);
                    brt0->VpiParent(ets);
                    brt0->Actual_typespec(cl0);
                    ets->Base_typespec(brt0);
                    baseSyn = nullptr;
                }
            }
    }
    if (baseSyn) {
        // An integer base (enum int/integer/... {..}) uses the matching integer
        // typespec; a logic/bit vector base uses logic_typespec (with a range).
        UHDM::typespec* bts = nullptr;
        auto& bct = et.baseType.getCanonicalType();
        if (bct.kind == SymbolKind::PredefinedIntegerType) {
            bool sgn = et.baseType.isSigned();
            switch (bct.as<PredefinedIntegerType>().integerKind) {
                case PredefinedIntegerType::Int: {
                    auto* t = s.MakeInt_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                default:
                    break;
            }
            if (bts)
                setLoc(bts, baseSyn->sourceRange());
        }
        if (bts) {
            auto* brt = s.MakeRef_typespec();
            brt->VpiFullName(refFullName);
            brt->VpiParent(ets);
            brt->Actual_typespec(bts);
            ets->Base_typespec(brt);
        }
        else {
        // A `bit`-based enum keeps a bit_typespec base (Surelog); logic and
        // implicit vectors use logic_typespec.
        bool bitBase9 = baseSyn->kind == syntax::SyntaxKind::BitType;
        UHDM::typespec* bts =
            bitBase9 ? (UHDM::typespec*)s.MakeBit_typespec()
                     : (UHDM::typespec*)s.MakeLogic_typespec();
        if (et.baseType.isSigned()) {
            if (bitBase9)
                ((UHDM::bit_typespec*)bts)->VpiSigned(true);
            else
                ((UHDM::logic_typespec*)bts)->VpiSigned(true);
        }
        setLoc(bts, baseSyn->sourceRange());
        if (et.baseType.isPackedArray()) {
            auto range = et.baseType.getFixedRange();
            const syntax::ExpressionSyntax* lsyn = nullptr;
            const syntax::ExpressionSyntax* rsyn = nullptr;
            if (syntax::IntegerTypeSyntax::isKind(baseSyn->kind)) {
                auto& dims = baseSyn->as<syntax::IntegerTypeSyntax>().dimensions;
                if (dims.size() == 1 && (*dims.begin())->specifier &&
                    (*dims.begin())->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& spec = (*dims.begin())
                                     ->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
                    if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                        auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                        lsyn = sel.left;
                        rsyn = sel.right;
                    }
                }
            }
            auto* r = s.MakeRange();
            r->VpiParent(bts);
            if (syntax::IntegerTypeSyntax::isKind(baseSyn->kind) &&
                !baseSyn->as<syntax::IntegerTypeSyntax>().dimensions.empty())
                setLoc(r, (*baseSyn->as<syntax::IntegerTypeSyntax>().dimensions.begin())
                              ->sourceRange());
            // Non-literal bounds (logic [W-1:0]) stay UNFOLDED in a
            // MODULE-local enum typedef's base; a PKG enum's base FOLDS to a
            // signed INT constant anchored at the bound's leading
            // identifier token (MUSI pkg::enum_t [Width-1:0] -> INT:3 at
            // the Width span). The fold applies in the ELABORATED (top)
            // package view and in module-context clones; the DEF-view PACKAGE
            // typedef LISTING keeps the bound SYMBOLIC (Surelog emits a
            // symbolic def base + a folded elab base). inPkgTypedefEmit
            // distinguishes the def-package listing from module context (both
            // have pkgTopEmit == false).
            bool pkgEnum9 =
                refFullName.find("::") != std::string::npos &&
                !(inPkgTypedefEmit && !pkgTopEmit);
            // A `$unit`-scope enum typedef folds its base bound like a
            // package one: the compilation unit is compiled before any module,
            // so `typedef enum logic [SCR1_IALU_OP_WIDTH_E-1:0]` lands as a
            // constant (Scr1SvTests scr1_riscv_isa_decoding.svh).
            if (!pkgEnum9)
                if (auto* esc0 = et.getParentScope();
                    esc0 &&
                    esc0->asSymbol().kind == SymbolKind::CompilationUnit)
                    pkgEnum9 = true;
            // A $bits(...)-based bound INVERTS the fold assignment: the DEF
            // package listing folds (INT anchored at the $bits span) while
            // the elaborated view keeps the sys call symbolic (jeras_union
            // fn3_alu_et/fn3_bru_et [$bits(fn3_t)-1:0]).
            auto hasSysCall9 = [](const syntax::ExpressionSyntax* b9) {
                if (!b9)
                    return false;
                bool found9 = false;
                std::function<void(const syntax::SyntaxNode&)> scan9 =
                    [&](const syntax::SyntaxNode& sn9) {
                        if (found9)
                            return;
                        if (sn9.kind == syntax::SyntaxKind::SystemName) {
                            found9 = true;
                            return;
                        }
                        for (size_t ci9 = 0; ci9 < sn9.getChildCount(); ci9++)
                            if (auto* cn9 = sn9.childNode(ci9))
                                scan9(*cn9);
                    };
                scan9(*b9);
                return found9;
            };
            auto enumBound = [&](const syntax::ExpressionSyntax* bsyn,
                                 int64_t val) -> UHDM::expr* {
                if (bsyn && bsyn->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
                    // The pkg fold: a bound REFERENCING a name folds in the
                    // elab/top view and module clones (MUSI Width-1 -> INT:3);
                    // a literal-only op ([2-1:0], riscv_priv_pkg) folds in
                    // the DEF listing but stays SYMBOLIC in the TOP view —
                    // Surelog's elab substitution never revisits a
                    // param-free expression. A sys-call bound ($clog2) folds
                    // in the def listing AND module clones; only the TOP-pkg
                    // view keeps it symbolic (jeras_union).
                    bool refBound9 = false;
                    {
                        std::function<void(const syntax::SyntaxNode&)> scanR9 =
                            [&](const syntax::SyntaxNode& sn9) {
                                if (refBound9)
                                    return;
                                if (sn9.kind ==
                                        syntax::SyntaxKind::IdentifierName ||
                                    sn9.kind == syntax::SyntaxKind::ScopedName)
                                    refBound9 = true;
                                for (size_t ci9 = 0;
                                     ci9 < sn9.getChildCount(); ci9++)
                                    if (auto* cn9 = sn9.childNode(ci9))
                                        scanR9(*cn9);
                            };
                        scanR9(*bsyn);
                    }
                    bool pkgNamed9 =
                        refFullName.find("::") != std::string::npos;
                    // A package's own DEF-LISTING enum object folds its
                    // bound IFF the enum is CONSUMED as a struct/union
                    // member type somewhere (Surelog's member compile forces
                    // the fold: jeras_union fn3_alu_et via ctl_alu_t.fn3,
                    // rp32 csr_perm_t via csr_adr_t.perm); an un-consumed
                    // enum keeps the written op ($bits or literal — rp32
                    // isa_base_et, isa_priv_typ_t).
                    bool memberUsed9 = false;
                    if (pkgListingEnumBuild || importCloneEmit) {
                        auto& etc9 = et.getCanonicalType();
                        for (auto* p9 : comp.getPackages()) {
                            for (auto& pm9 : p9->members()) {
                                if (pm9.kind != SymbolKind::TypeAlias)
                                    continue;
                                auto& pct9 = pm9.as<TypeAliasType>()
                                                 .getCanonicalType();
                                if (!pct9.isStruct() && !pct9.isUnion())
                                    continue;
                                for (auto& f9 :
                                     pct9.as<Scope>()
                                         .membersOfType<FieldSymbol>())
                                    if (&f9.getType().getCanonicalType() ==
                                        &etc9)
                                        memberUsed9 = true;
                            }
                            if (memberUsed9)
                                break;
                        }
                    }
                    bool sys9 = pkgNamed9 && hasSysCall9(bsyn);
                    // When the enum's HOME package is itself imported by
                    // ANOTHER package the fold moves to the importing
                    // package's CLONE: the home DEF listing keeps the written
                    // op and the clone carries the folded bound (rp32
                    // riscv_priv_pkg csr_perm_t [2-1:0], consumed through
                    // riscv_isa_i_pkg). curPkgEmitSym is the home package
                    // here; the clone is built under importCloneEmit, whose
                    // home is imported by construction.
                    bool homeImported9 =
                        curPkgEmitSym && pkgImportedByPkg.count(curPkgEmitSym);
                    bool fold9;
                    if (importCloneEmit && !sys9 && !refBound9)
                        fold9 = memberUsed9;
                    else if (pkgListingEnumBuild && sys9)
                        // A SYS-CALL bound is not a member-compile fold at
                        // all: it stays SYMBOLIC in the DEF listing whether or
                        // not the enum is consumed as a struct member, and
                        // folds only in the elaborated (top) listing
                        // (jeras_union fn3_alu_et/fn3_ldu_et/fn3_stu_et/
                        // fn3_bru_et [$bits(fn3_t)-1:0], all consumed as
                        // ctl_*_t.fn3).
                        fold9 = pkgTopEmit;
                    else if (pkgListingEnumBuild && !refBound9)
                        // The ELABORATED package listing always folds; the DEF
                        // listing folds only when a struct/union member compile
                        // forced it AND no import clone took the fold instead.
                        fold9 = pkgTopEmit || (memberUsed9 && !homeImported9);
                    else if (sys9)
                        fold9 = !pkgTopEmit;
                    else if (!pkgNamed9 && hasSysCall9(bsyn))
                        // A MODULE-scope enum whose bound calls a system
                        // function (`enum logic [$clog2(N)-1:0]`) folds in
                        // the ELABORATED view only: the def listing keeps the
                        // written operation, while elaboration reduces the
                        // call and the reduction consumes the whole binary
                        // expression, leaving one INT constant anchored at
                        // the CALL's span (InterfArrayBind).
                        // NOTE (r10iab): the r10c12 note that used to sit here
                        // — "we mint ONE base logic_typespec and share it
                        // between the def and elab enum_typespecs" — was
                        // WRONG.  We already mint one per view, exactly like
                        // Surelog (enum ts #1 parented at the enum_var,
                        // elaborated/folded; enum ts #2 bare, the def
                        // listing, written).  What was missing is that the
                        // DEF-view NET typespec is materialized LAZILY, after
                        // emitModuleDef has already popped its moduleDefEmit
                        // guard, so the def mint saw moduleDefEmit == false
                        // and folded too; materializeDefNetTs re-asserts the
                        // marker.  That one line converted InterfArrayBind in
                        // both modes.
                        //
                        // RANKED RESIDUE (measured, 0 corpus reach — do NOT
                        // land it blind).  The same view split is Surelog's
                        // rule for EVERY anonymous module-scope enum bound,
                        // not just a sys-call one: purpose-built golden
                        // r10iab/p3 shows `[NW-1:0]` (param) and `[4-1:0]`
                        // (literal arith) each minting TWO base typespecs,
                        // def written / elab folded, while a module-scope
                        // TYPEDEF enum (`typedef enum logic [NW-1:0] {..}
                        // q_t;`) mints ONE shared base and keeps it WRITTEN in
                        // both.  We fold NEITHER view for those (they fall to
                        // the refBound9 arm below), so the elab view is a
                        // known divergence.  Generalizing this arm to
                        // `hasSysCall9(bsyn) || refFullName.empty()` was built
                        // and swept: Surelog both-modes and u2r testflags came
                        // back with ZERO status changes and ZERO dump changes
                        // — it converts nothing — and golden r10iab/p5 proved
                        // it WRONG for a class-scope enum (`class C; enum
                        // logic [FW-1:0] {..} cvar; endclass` keeps the
                        // written op in both views), so it needs an
                        // InstanceBody-parent-scope guard.  Reverted: zero
                        // gain, real risk.
                        fold9 = !moduleDefEmit;
                    else if (refBound9)
                        // An import-listing CLONE of a package enum FOLDS a
                        // PARAM-referencing base bound: the clone is compiled
                        // out of the importing scope's ELABORATED table, where
                        // the parameter already has a value, while the home
                        // DEF listing keeps the written op (BlackBePipeInt
                        // bp_common_pkg::bp_params_e `bit [lg_max_cfgs-1:0]`
                        // — golden's bp_be_pkg-instanced clone carries a
                        // constant, its bp_common_pkg[DEF] listing an
                        // operation).  Same polarity as the homeImported9 arm
                        // above, which only covers literal-only bounds.
                        fold9 = pkgEnum9 || importCloneEmit;
                    else
                        // An import-listing CLONE keeps a literal-only op
                        // bound SYMBOLIC (Surelog's elab never revisits a
                        // param-free expression; rp32 csr_perm_t clone
                        // [2-1:0] stays 2-1 while the home def folds).
                        fold9 = pkgNamed9 && !pkgTopEmit && !importCloneEmit;
                    if (fold9) {
                        auto* c9 = s.MakeConstant();
                        std::string d9 = std::to_string(val);
                        c9->VpiDecompile(d9);
                        c9->VpiSize(64);
                        c9->VpiValue("INT:" + d9);
                        c9->VpiConstType(vpiIntConst);
                        c9->VpiParent(r);
                        const syntax::SyntaxNode* anchor9 = bsyn;
                        if (auto* be9 =
                                bsyn->as_if<syntax::BinaryExpressionSyntax>())
                            anchor9 = be9->left;
                        setLoc(c9, anchor9->sourceRange());
                        return c9;
                    }
                    // A DEF-view PACKAGE enum base bound (logic [Width-1:0])
                    // keeps its param ref linked to the referenced package
                    // param's def-init constant (Surelog value-ref chaining) —
                    // activate the tf-type-scope resolver over the enum's home
                    // package so the ref binds instead of dangling.
                    const slang::ast::Scope* savedTfScope9 = tfTypeScope;
                    bool setTf9 = false;
                    if (!tfTypeScope && inPkgTypedefEmit &&
                        refFullName.find("::") != std::string::npos)
                        if (auto* esc9 = et.getParentScope()) {
                            tfTypeScope = esc9;
                            setTf9 = true;
                        }
                    auto* e = emitSyntaxExpr(*bsyn, r);
                    if (setTf9)
                        tfTypeScope = savedTfScope9;
                    if (e)
                        return (UHDM::expr*)e;
                }
                return makeBoundConst(bsyn, val, r);
            };
            r->Left_expr(enumBound(lsyn, range.left));
            r->Right_expr(enumBound(rsyn, range.right));
            auto* rv = s.MakeRangeVec();
            rv->push_back(r);
            if (bitBase9)
                ((UHDM::bit_typespec*)bts)->Ranges(rv);
            else
                ((UHDM::logic_typespec*)bts)->Ranges(rv);
        }
        auto* brt = s.MakeRef_typespec();
        brt->VpiFullName(refFullName);
        brt->VpiParent(ets);
        brt->Actual_typespec(bts);
        ets->Base_typespec(brt);
        }
    }
    else if (implicitBaseRef) {
        // An inline anonymous enum (enum {..} v) carries a bare base
        // ref_typespec (fullname only, no actual); the caller patches its
        // fullname to the variable's. Typedef anon-base enums omit it.
        auto* brt = s.MakeRef_typespec();
        brt->VpiFullName(refFullName);
        brt->VpiParent(ets);
        ets->Base_typespec(brt);
    }
    auto* consts = s.MakeEnum_constVec();
    // § unitArith — a `$unit`-scope enum is elaborated like a TOP package
    // (the compilation unit is compiled before any module and has only ONE
    // view), so an enum const whose init is plain ARITHMETIC folds to digits
    // with the base's own signedness encoding at the 64-bit unsized-operand
    // width, instead of the def-view "BIN at base width + source text"
    // computed form.  Measured probe r10c9/c, one $unit enum, one const per
    // row: `P2+4` -> UINT:7 / "7" / 64, `3+40` -> UINT:43 / "43" / 64, while
    // `{2'b10,2'b01}` keeps BIN:1001 at the CONCAT's own width 4 and `P2`
    // keeps UINT:3 / "3" / 32 — so it is arithmetic only.
    // FileParam SCR1_SCU_DR_SYSCTRL_OP_BIT_L is the corpus distinguisher.
    bool unitEnum9 = false;
    if (auto* usc9 = et.getParentScope())
        unitEnum9 = usc9->asSymbol().kind == SymbolKind::CompilationUnit;
    for (auto& ev : et.values()) {
        auto* ec = s.MakeEnum_const();
        ec->VpiName(ev.name);
        ec->VpiParent(ets);
        if (auto syn = ev.getSyntax())
            setLoc(ec, syn->sourceRange());
        auto& cv = ev.getValue();
        std::string value;
        // § enumCastInitNotEvaluated — an enum constant whose initializer is
        // written as a CAST is not evaluated by Surelog at all: the const
        // lands as INT:0 at the 64-bit unsized width with NO decompile,
        // whatever the cast actually computes.  Size casts and type casts
        // alike, and every size spelling — golden /tmp/r10scr6_v10.sv
        // ((W+1)'('d0), 3'('d0), W'('d0), (W+1)'(0)) and
        // /tmp/r10scr6_v11.sv (logic'(1'b1), int'(3)) put all eight at
        // INT:0/64, while the plain based literal `3'd1` beside them still
        // reads 1.  Scr1SvTests type_scr1_abs_err_e / type_scr1_dhi_fsm_e:
        // the ABS_ERR_* pair was the design-echo head (47 of 96 vectors)
        // once the $unit enum-const refs bound.
        if (auto initC9 = ev.getInitializer()) {
            auto& c9 = stripImplicitConv(*initC9);
            bool castInit9 = false;
            if (auto* csyn9 = c9.syntax)
                castInit9 =
                    csyn9->kind == syntax::SyntaxKind::CastExpression ||
                    csyn9->kind == syntax::SyntaxKind::SignedCastExpression;
            if (castInit9) {
                ec->VpiValue("INT:0");
                ec->VpiSize(64);
                consts->push_back(ec);
                if (!enumConstMap.count(&ev))
                    enumConstMap[&ev] = ec;
                continue;
            }
        }
        if (auto init = ev.getInitializer()) {
            auto& lit = stripImplicitConv(*init);
            if (lit.kind == ExpressionKind::IntegerLiteral) {
                std::string raw = rawText(lit.sourceRange);
                auto tick = raw.find('\'');
                if (tick != std::string::npos) {
                    // Based literal: literal encoding at the literal size.
                    // Surelog strips whitespace between the base char and
                    // the digits (3'h 0 -> 3'h0), shrinking the end loc
                    // (rsp_gen_minimal).
                    {
                        size_t bp9 = tick + 1;
                        if (bp9 < raw.size() &&
                            (raw[bp9] == 's' || raw[bp9] == 'S'))
                            bp9++;
                        size_t ws9 = 0;
                        while (bp9 + 1 + ws9 < raw.size() &&
                               (raw[bp9 + 1 + ws9] == ' ' ||
                                raw[bp9 + 1 + ws9] == '\t'))
                            ws9++;
                        if (ws9) {
                            raw.erase(bp9 + 1, ws9);
                            if (ec->VpiEndColumnNo() >
                                (int32_t)ws9)
                                ec->VpiEndColumnNo(ec->VpiEndColumnNo() -
                                                   (int32_t)ws9);
                        }
                    }
                    // Surelog strips digit-group underscores (5'b00_000 ->
                    // 5'b00000) with NO end-loc shrink (jeras_union).
                    ec->VpiDecompile(stripSep(raw));
                    ec->VpiSize((int32_t)lit.type->getBitWidth());
                    // An UNSIZED based literal ('h0, 'b1011, 'd90 — nothing
                    // written before the tick) is width-INDETERMINATE, so
                    // Surelog records vpiSize -1, the same marker the
                    // unbased-unsized `'0` form takes, NOT the 32-bit
                    // self-determined width slang assigns. A WRITTEN size
                    // prefix (3'h0) keeps its own width. Measured probe
                    // r10c9/c ($unit) and r10c9/d (package) alike; FileParam
                    // SCR1_SCU_DR_SYSCTRL_OP_BIT_R = 'h0.
                    if (tick == 0)
                        ec->VpiSize(-1);
                    size_t basePos = tick + 1;
                    if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                        basePos++;
                    char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                    std::string digits = stripSep(raw.substr(basePos + 1));
                    switch (base) {
                        case 'b':
                            value = "BIN:" + digits;
                            break;
                        case 'h':
                            value = "HEX:" + digits;
                            break;
                        case 'o':
                            value = "OCT:" + digits;
                            break;
                        default:
                            // Based-decimal enum inits (3'd0) encode INT
                            // (MultirangesStartNotFromZero), not DEC.
                            value = "INT:" + digits;
                            break;
                    }
                }
                else {
                    // Bare decimal: 64-bit UINT.
                    ec->VpiDecompile(raw);
                    ec->VpiSize(64);
                    value = "UINT:" + raw;
                }
            }
        }
        // A COMPUTED (concat) init with X/Z bits ({2'b10, 2'b??}) keeps the
        // base width in BOTH views and the compacted source text as the DEF
        // decompile only (rp32 PRIV_ECALL) — value BIN with x/z bit chars.
        if (value.empty() && cv.isInteger() && cv.integer().hasUnknown() &&
            baseSyn) {
            auto* evInit9 = ev.getInitializer();
            if (evInit9 &&
                stripImplicitConv(*evInit9).kind !=
                    ExpressionKind::IntegerLiteral &&
                stripImplicitConv(*evInit9).kind !=
                    ExpressionKind::NamedValue) {
                int w9 = (int)et.baseType.getBitWidth();
                auto& iv9 = cv.integer();
                std::string initRaw9 =
                    rawText(stripImplicitConv(*evInit9).sourceRange);
                // Surelog's value string echoes the SOURCE spelling of a
                // high-impedance bit: `?` stays `?` ({2'b10,2'b??} -> BIN:10??,
                // rp32 PRIV_ECALL), and only a written z/Z prints as z.
                char zc9 = initRaw9.find('z') != std::string::npos ||
                                   initRaw9.find('Z') != std::string::npos
                               ? 'z'
                               : '?';
                std::string bits9((size_t)w9, '0');
                for (int bi9 = 0; bi9 < w9 && bi9 < (int)iv9.getBitWidth();
                     bi9++) {
                    auto b9 = iv9[bi9];
                    char c9 = b9.isUnknown()
                                  ? (b9.value == slang::logic_t::Z_VALUE ? zc9
                                                                         : 'x')
                                  : (b9.value ? '1' : '0');
                    bits9[(size_t)(w9 - 1 - bi9)] = c9;
                }
                ec->VpiValue("BIN:" + bits9);
                if (!pkgTopEmit) {
                    const std::string& raw9 = initRaw9;
                    std::string comp9;
                    comp9.reserve(raw9.size());
                    for (size_t i9 = 0; i9 < raw9.size(); i9++) {
                        if (std::isspace((unsigned char)raw9[i9])) {
                            size_t j9 = i9;
                            while (j9 < raw9.size() &&
                                   std::isspace((unsigned char)raw9[j9]))
                                j9++;
                            char pv9 = comp9.empty() ? '\0' : comp9.back();
                            char nx9 = j9 < raw9.size() ? raw9[j9] : '\0';
                            bool drop9 = pv9 == ',' || pv9 == '{' ||
                                         pv9 == '}' || nx9 == ',' ||
                                         nx9 == '{' || nx9 == '}';
                            if (!drop9)
                                comp9 += ' ';
                            i9 = j9 - 1;
                        }
                        else
                            comp9 += raw9[i9];
                    }
                    ec->VpiDecompile(comp9);
                }
                ec->VpiSize(w9);
                consts->push_back(ec);
                if (!enumConstMap.count(&ev))
                    enumConstMap[&ev] = ec;
                continue;
            }
        }
        if (value.empty() && cv.isInteger() && !cv.integer().hasUnknown()) {
            // A non-literal initializer (enum X = pkg::PARAM) keeps the SOURCE
            // reference as the decompile and follows the base signedness;
            // implicit/computed values decompile to the folded digits.
            std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
            auto* evInit = ev.getInitializer();
            // An UNBASED-UNSIZED init (`'0`) keeps Surelog's unsized encoding:
            // ONE binary digit and size -1, not the base width (Scr1SvTests
            // SCR1_IALU_CMD_NONE).
            if (evInit && stripImplicitConv(*evInit).kind ==
                              ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                std::string raw0 =
                    stripSep(std::string(
                        rawText(stripImplicitConv(*evInit).sourceRange)));
                ec->VpiDecompile(raw0);
                ec->VpiSize(-1);
                ec->VpiValue(std::string("BIN:") +
                             (cv.integer().reductionOr().value ? '1' : '0'));
                consts->push_back(ec);
                if (!enumConstMap.count(&ev))
                    enumConstMap[&ev] = ec;
                continue;
            }
            bool nonLitInit = evInit && stripImplicitConv(*evInit).kind !=
                                            ExpressionKind::IntegerLiteral;
            // A COMPUTED init (concat/operation, not a plain ref) encodes BIN
            // at the base width: def decompile = source text w/o spaces, top
            // view = <w>'b<bits>.
            bool refInit = evInit && stripImplicitConv(*evInit).kind ==
                                         ExpressionKind::NamedValue;
            // ...except in an IMPORT-LISTING CLONE, where a plain ref init
            // folds exactly like a computed one: golden's clone of
            // bp_common_pkg::bp_bedrock_fill_type_e (the object the module
            // listing shows) carries `4'b0100` / BIN:0100 for
            // `e_bedrock_fill_data = e_bedrock_cmd_data`, while the home
            // package's own DEF listing keeps `e_bedrock_cmd_data` / INT:4.
            // Same family as the concat clone rules importCloneEmit already
            // gates -- a clone re-elaborates the member through the datatype
            // map, which holds the resolved value, not the source reference.
            if (refInit && importCloneEmit)
                refInit = false;
            // § unitArith (see the note above the loop): a $unit enum's
            // ARITHMETIC init leaves the computed BIN form to the digits
            // branch below.
            bool unitArith9 =
                unitEnum9 && evInit &&
                (stripImplicitConv(*evInit).kind == ExpressionKind::BinaryOp ||
                 stripImplicitConv(*evInit).kind == ExpressionKind::UnaryOp);
            // § unitArithShape — the folded constant's WIDTH and SIGNEDNESS
            // come from the reduction, not from the enum base:
            //   * an operand that is a bare INTEGER LITERAL has no width in
            //     Surelog's evaluator, so the result lands at the unsized 64
            //     (`P2+4` -> 64, `3+40` -> 64); an expression whose every
            //     leaf is a WIDTH-CARRYING object keeps that width
            //     (`OP_WIDTH + ADDR_WIDTH` -> UINT:4 at 32).
            //   * a SUBTRACTION reduces signed, so the const encodes INT
            //     even under an `int unsigned` base (`OP_WIDTH-1` -> INT:1,
            //     `OP_WIDTH + ADDR_WIDTH - 1` -> INT:3), while a pure sum of
            //     unsigned operands stays UINT.
            // Measured on Scr1SvTests type_scr1_scu_sysctrl_dr_bits_e, whose
            // six consts span all four combinations, and consistent with the
            // r10c9/c probe rows quoted above.
            bool unitArithLit9 = false;
            bool unitArithSub9 = false;
            if (unitArith9)
                stripImplicitConv(*evInit).visit(makeVisitor(
                    [&](auto& v9, const IntegerLiteral& il9) {
                        unitArithLit9 = true;
                        v9.visitDefault(il9);
                    },
                    [&](auto& v9, const BinaryExpression& be9) {
                        if (be9.op == BinaryOperator::Subtract)
                            unitArithSub9 = true;
                        v9.visitDefault(be9);
                    }));
            // A $unit enum's PLAIN REFERENCE init decompiles to the folded
            // digits too — the compilation unit has only one view, so there
            // is no def-view "keep the source reference" form (r10c9/c: `P2`
            // -> UINT:3 / "3" / 32; Scr1SvTests
            // SCR1_SCU_DR_SYSCTRL_ADDR_BIT_R = SCR1_SCU_DR_SYSCTRL_OP_WIDTH
            // -> "2", not the parameter's name).  Width and signedness still
            // come from the base, unlike the arithmetic case.
            bool unitRefInit9 = unitEnum9 && refInit;
            if (nonLitInit && !refInit && baseSyn && !unitArith9) {
                int w = (int)et.baseType.getBitWidth();
                // Surelog's enum-const VALUE evaluation drops the RHS of a
                // bitwise-or: {RV_32E, RV_M | RV_C} encodes as
                // {RV_32E, RV_M} (riscv_isa_pkg isa_spec_et; the correctly
                // reduced number appears only in clone decompiles).
                // Reproduce with `a | b` -> `a` when the init contains one.
                SVInt quirkIv = cv.integer();
                {
                    auto& init9 = stripImplicitConv(*evInit);
                    bool hasOr9 = false;
                    init9.visit(makeVisitor(
                        [&](auto& v9, const BinaryExpression& b9) {
                            if (b9.op == BinaryOperator::BinaryOr)
                                hasOr9 = true;
                            v9.visitDefault(b9);
                        }));
                    std::function<std::optional<SVInt>(const Expression&)>
                        quirkVal = [&](const Expression& e9)
                        -> std::optional<SVInt> {
                        auto& s9 = stripImplicitConv(e9);
                        if (s9.kind == ExpressionKind::BinaryOp &&
                            s9.as<BinaryExpression>().op ==
                                BinaryOperator::BinaryOr)
                            return quirkVal(s9.as<BinaryExpression>().left());
                        if (s9.kind == ExpressionKind::Concatenation) {
                            SmallVector<SVInt> parts9;
                            for (auto* op9 :
                                 s9.as<ConcatenationExpression>().operands()) {
                                auto p9 = quirkVal(*op9);
                                if (!p9)
                                    return std::nullopt;
                                parts9.push_back(*p9);
                            }
                            return SVInt::concat(parts9);
                        }
                        ASTContext ectx9(et, LookupLocation::max);
                        auto lv9 = ectx9.tryEval(s9);
                        if (lv9.isInteger() && !lv9.integer().hasUnknown())
                            return lv9.integer();
                        return std::nullopt;
                    };
                    if (hasOr9)
                        if (auto qv9 = quirkVal(init9);
                            qv9 && (int)qv9->getBitWidth() == w)
                            quirkIv = *qv9;
                }
                auto& ivv = quirkIv;
                std::string bits((size_t)w, '0');
                for (int bi = 0; bi < w; bi++)
                    if (ivv[bi].value == 1)
                        bits[(size_t)(w - 1 - bi)] = '1';
                ec->VpiValue("BIN:" + bits);
                std::string raw = rawText(stripImplicitConv(*evInit).sourceRange);
                // Whitespace strips only ADJACENT to commas/braces; interior
                // operator spacing survives ({RV_32E , RV_M | RV_C} ->
                // {RV_32E,RV_M | RV_C}) — Surelog.
                {
                    std::string comp9;
                    comp9.reserve(raw.size());
                    for (size_t i9 = 0; i9 < raw.size(); i9++) {
                        if (std::isspace((unsigned char)raw[i9])) {
                            size_t j9 = i9;
                            while (j9 < raw.size() &&
                                   std::isspace((unsigned char)raw[j9]))
                                j9++;
                            char pv9 = comp9.empty() ? '\0' : comp9.back();
                            char nx9 = j9 < raw.size() ? raw[j9] : '\0';
                            bool drop9 = pv9 == ',' || pv9 == '{' ||
                                         pv9 == '}' || nx9 == ',' ||
                                         nx9 == '{' || nx9 == '}';
                            if (!drop9)
                                comp9 += ' ';
                            i9 = j9 - 1;
                        }
                        else
                            comp9 += raw[i9];
                    }
                    raw = comp9;
                }
                // The TOP-view package const leaves the decompile UNSET.
                // An IMPORT-LISTING clone follows Surelog's clone rules: a
                // concat of plain refs drops the decompile entirely; a concat
                // containing an OPERATION re-decompiles with each operand
                // FOLDED (enum ref -> <w>'b<bits>, operation -> decimal of
                // its full value — no or-drop quirk) — rp32 isa_spec_et
                // {RV_32E,RV_M | RV_C} -> {4'b1100,263168}.
                if (importCloneEmit) {
                    auto& init8 = stripImplicitConv(*evInit);
                    // A BARE ref init folds to the same `<w>'b<bits>` form the
                    // concat rule gives each ref operand, at the enum's own
                    // base width (BlackBePipeInt
                    // `e_bedrock_fill_data = e_bedrock_cmd_data` ->
                    // `4'b0100`, while the home package's def listing keeps
                    // the source reference).
                    if (init8.kind == ExpressionKind::NamedValue)
                        ec->VpiDecompile(std::to_string(w) + "'b" + bits);
                    else if (init8.kind == ExpressionKind::Concatenation) {
                        bool anyOp8 = false;
                        for (auto* op8 :
                             init8.as<ConcatenationExpression>().operands())
                            if (auto k8 = stripImplicitConv(*op8).kind;
                                k8 == ExpressionKind::BinaryOp ||
                                k8 == ExpressionKind::UnaryOp)
                                anyOp8 = true;
                        if (anyOp8) {
                            std::string txt8 = "{";
                            bool first8 = true;
                            for (auto* op8 : init8.as<ConcatenationExpression>()
                                                 .operands()) {
                                auto& so8 = stripImplicitConv(*op8);
                                if (!first8)
                                    txt8 += ",";
                                first8 = false;
                                ASTContext ectx8(et, LookupLocation::max);
                                auto v8 = ectx8.tryEval(so8);
                                if (v8.isInteger() &&
                                    !v8.integer().hasUnknown() &&
                                    so8.kind == ExpressionKind::NamedValue) {
                                    int ow8 =
                                        (int)v8.integer().getBitWidth();
                                    std::string ob8((size_t)ow8, '0');
                                    for (int bi8 = 0; bi8 < ow8; bi8++)
                                        if (v8.integer()[bi8].value == 1)
                                            ob8[(size_t)(ow8 - 1 - bi8)] =
                                                '1';
                                    txt8 += std::to_string(ow8) + "'b" + ob8;
                                }
                                else if (v8.isInteger() &&
                                         !v8.integer().hasUnknown())
                                    txt8 += v8.integer().toString(
                                        LiteralBase::Decimal, false);
                                else
                                    txt8 += rawText(so8.sourceRange);
                            }
                            txt8 += "}";
                            ec->VpiDecompile(txt8);
                        }
                    }
                    else if (!pkgTopEmit)
                        ec->VpiDecompile(raw);
                }
                else if (!pkgTopEmit)
                    ec->VpiDecompile(raw);
                ec->VpiSize(w);
                consts->push_back(ec);
                if (!enumConstMap.count(&ev))
                    enumConstMap[&ev] = ec;
                continue;
            }
            // Only an explicit UNSIGNED INTEGER base (enum int unsigned {..})
            // encodes UINT; implicit / logic-vector / signed bases use INT.
            bool unsignedIntBase =
                baseSyn &&
                et.baseType.getCanonicalType().kind == SymbolKind::PredefinedIntegerType &&
                !et.baseType.isSigned();
            value = (unsignedIntBase && !unitArithSub9 ? "UINT:" : "INT:") + digits;
            // Non-literal init keeps the SOURCE reference as the decompile in
            // the def view; the top/elab view folds to digits.
            if (nonLitInit && !pkgTopEmit && !unitArith9 && !unitRefInit9)
                ec->VpiDecompile(rawText(stripImplicitConv(*evInit).sourceRange));
            else
                ec->VpiDecompile(digits);
            ec->VpiSize((!unitArith9 || !unitArithLit9) && baseSyn
                            ? (int32_t)et.baseType.getBitWidth()
                            : 64);
        }
        if (!value.empty())
            ec->VpiValue(value);
        consts->push_back(ec);
        if (!enumConstMap.count(&ev))
            enumConstMap[&ev] = ec;
    }
    ets->Enum_consts(consts);
    return ets;
}

// A member packed dimension written with an IDENTIFIER bound
// (`pad_type_e [NDioPads-1:0] m`) leaves Surelog unable to type the struct's
// pattern params, so those never flatten in the package views.  The dims live
// in the member's TYPE syntax (between the type token and the declarator
// name), so scan that raw text for a bracketed identifier.
bool UhdmExporter::structHasSymbolicMemberDim(const Type& ty) {
    auto& ct = ty.getCanonicalType();
    if (ct.kind != SymbolKind::PackedStructType &&
        ct.kind != SymbolKind::UnpackedStructType)
        return false;
    for (auto& fm : ct.as<Scope>().members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        const syntax::SyntaxNode* mts = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent)
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                mts = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        if (!mts)
            continue;
        SourceLocation a = mts->sourceRange().start(), b = fm.location;
        if (!(a < b))
            continue;
        std::string txt = rawText(SourceRange(a, b));
        int depth = 0;
        for (char ch : txt) {
            if (ch == '[')
                depth++;
            else if (ch == ']')
                depth--;
            else if (depth > 0 &&
                     (isalpha((unsigned char)ch) || ch == '_'))
                return true;
        }
    }
    return false;
}

// Surelog reduces a PACKAGE parameter's elaborated param_assign RHS only when
// something resolves that parameter THROUGH the package scope: `pkg::NAME`.
// Reading the same parameter unqualified after a wildcard import, or never
// reading it at all, leaves the elaborated RHS in its declared shape (measured:
// same package + same pattern, only the reference form differing, flips the
// elaborated view between the flat op75 and the tagged_pattern tree).
// A reference written inside another PARAMETER DECLARATION does not count:
// Surelog compiles parameter defaults in its parameter pass, which resolves the
// package member without running the reduce (measured: the same `pkg::NAME`
// read moved from a cont-assign into a module/interface parameter default flips
// the elaborated package view back to the tagged tree — GenIfIfaceParamStructField
// `parameter p::cfg_t CFG = p::CFG_DEF`).
// One syntax walk over every tree collects the surviving `left::right` pairs.
bool UhdmExporter::hasScopedPkgRef(std::string_view pkgName,
                                   std::string_view name) {
    if (!scopedPkgRefsBuilt) {
        scopedPkgRefsBuilt = true;
        auto scan = [&](auto&& self, const syntax::SyntaxNode& node,
                        bool inParamDecl) -> void {
            if (node.kind == syntax::SyntaxKind::ParameterDeclaration ||
                node.kind == syntax::SyntaxKind::TypeParameterDeclaration)
                inParamDecl = true;
            if (!inParamDecl && node.kind == syntax::SyntaxKind::ScopedName) {
                auto& sn = node.as<syntax::ScopedNameSyntax>();
                if (sn.left && sn.right &&
                    sn.left->kind == syntax::SyntaxKind::IdentifierName &&
                    sn.right->kind == syntax::SyntaxKind::IdentifierName)
                    scopedPkgRefs.insert(
                        std::string(sn.left->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText()) +
                        "::" +
                        std::string(sn.right->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText()));
            }
            for (size_t i = 0, n = node.getChildCount(); i < n; i++)
                if (auto* ch = node.childNode(i))
                    self(self, *ch, inParamDecl);
        };
        for (auto& tree : comp.getSyntaxTrees())
            scan(scan, tree->root(), false);
    }
    return scopedPkgRefs.count(std::string(pkgName) + "::" +
                               std::string(name)) > 0;
}

// `(P)'(x)` — a PARENTHESIZED parameter size cast — reuses P's own
// declaration int_typespec as the cast target rather than minting one, and
// Surelog stamps vpiInstance = the package onto that shared object.  Doing the
// stamp at the CAST SITE only reaches the views that still emit a cast: the
// elaborated package listing folds `(dev_addr_width_gp)'('h0_0000)` to a plain
// constant, yet golden's elaborated copy of dev_addr_width_gp's own typespec
// carries the instance all the same.  So the stamp follows the PARAMETER.
// Measured on the r10c16c_r1 repro (w20 is a paren cast width: 16/16 golden
// copies instanced; w4, used only inside `w4+w20`, has 0/16) and on
// BlackBePipeInt bp_common_pkg dev_addr_width_gp.
// The cast has to be written INSIDE A PACKAGE: BlackBePipeInt's
// `dword_width_gp` is paren-cast only from a module's procedural code and
// golden leaves all 6 copies of its typespec Instance-less (r10c16c_r2 pins
// both halves), so the scan tracks package nesting.
bool UhdmExporter::isParenCastWidthParam(std::string_view name) {
    if (!parenCastWidthBuilt) {
        parenCastWidthBuilt = true;
        auto scan = [&](auto&& self, const syntax::SyntaxNode& node,
                        bool inPkg) -> void {
            if (node.kind == syntax::SyntaxKind::PackageDeclaration)
                inPkg = true;
            if (inPkg && node.kind == syntax::SyntaxKind::CastExpression) {
                const syntax::ExpressionSyntax* l9 =
                    node.as<syntax::CastExpressionSyntax>().left;
                bool paren9 = false;
                while (l9 &&
                       l9->kind == syntax::SyntaxKind::ParenthesizedExpression) {
                    paren9 = true;
                    l9 = l9->as<syntax::ParenthesizedExpressionSyntax>()
                             .expression;
                }
                if (paren9 && l9 &&
                    l9->kind == syntax::SyntaxKind::IdentifierName)
                    parenCastWidthNames.insert(std::string(
                        l9->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText()));
            }
            for (size_t i = 0, n = node.getChildCount(); i < n; i++)
                if (auto* ch = node.childNode(i))
                    self(self, *ch, inPkg);
        };
        for (auto& tree : comp.getSyntaxTrees())
            scan(scan, tree->root(), false);
    }
    return parenCastWidthNames.count(std::string(name)) > 0;
}

// The companion trigger to hasScopedPkgRef, and the one that decides a WIDE
// struct-pattern package parameter's ELABORATED shape: Surelog's
// substituteAssignedValue, called for every `P.member` select, reduces P's own
// elaborated value in place, and that reduce is what turns the tagged_pattern
// tree into the flat positional operand list.  A parameter nothing
// member-selects never gets reduced and keeps its tags.
// Measured on BlackBePipeInt's 14 config parameters, where the two shapes sort
// EXACTLY by the member-select count (`bp_custom_cfg_p` 0 selects -> tagged;
// `bp_default_cfg_p` / `bp_unicore_cfg_p` / `bp_multicore_*_override_p` /
// `bp_multicore_*_cfg_p` 72..936 selects -> flat), and on two purpose-built
// goldens that flip only which parameter is selected.
// Polarity is the MIRROR of hasScopedPkgRef: only a select written inside a
// PARAMETER DECLARATION counts.  A select in a cont-assign does NOT reduce the
// parameter (purpose-built 72-member golden: the module reads both `base_p.m0`
// and `copy_p.m0`, only `base_p` — the one a parameter also selects — goes
// flat), because a module-side read resolves the value without re-reducing the
// package's own param_assign.
// `a.b` is a ScopedName with a DOT separator in slang, not just a
// MemberAccessExpression — reading only the latter finds none of these.
bool UhdmExporter::hasMemberSelectOf(std::string_view name) {
    if (!memberSelectBasesBuilt) {
        memberSelectBasesBuilt = true;
        // `a.b` is a ScopedName whose SEPARATOR is a dot (slang parses `::`
        // and `.` into the same node); a postfix select off a non-name
        // expression is a MemberAccessExpression.  Both spell a member select,
        // and the base is the trailing identifier of the left side, so
        // `pa::base_p.m0` keys on `base_p`.
        auto baseName = [](const syntax::SyntaxNode* b) -> std::string {
            for (int g = 0; g < 8 && b && b->kind == syntax::SyntaxKind::ScopedName;
                 ++g)
                b = b->as<syntax::ScopedNameSyntax>().right;
            if (b && b->kind == syntax::SyntaxKind::IdentifierName)
                return std::string(b->as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText());
            return {};
        };
        auto scan = [&](auto&& self, const syntax::SyntaxNode& node,
                        bool inParamDecl) -> void {
            if (node.kind == syntax::SyntaxKind::ParameterDeclaration)
                inParamDecl = true;
            if (inParamDecl) {
                if (node.kind == syntax::SyntaxKind::MemberAccessExpression) {
                    if (auto n = baseName(
                            node.as<syntax::MemberAccessExpressionSyntax>()
                                .left);
                        !n.empty())
                        memberSelectBases.insert(n);
                }
                else if (node.kind == syntax::SyntaxKind::ScopedName) {
                    auto& sn = node.as<syntax::ScopedNameSyntax>();
                    if (sn.separator.kind == parsing::TokenKind::Dot)
                        if (auto n = baseName(sn.left); !n.empty())
                            memberSelectBases.insert(n);
                }
            }
            for (size_t i = 0, n = node.getChildCount(); i < n; i++)
                if (auto* ch = node.childNode(i))
                    self(self, *ch, inParamDecl);
        };
        for (auto& tree : comp.getSyntaxTrees())
            scan(scan, tree->root(), false);
    }
    return memberSelectBases.count(std::string(name)) > 0;
}

// Packed struct typespec: typespec_members with member-type Ref locations
// and alias-scoped ref fullnames.
// The element typespec of an aggregate member whose element type is ANONYMOUS
// (`logic [31:0] pair [2]`).  There is no shared typedef typespec to point the
// array_typespec's Elem ref at, but Surelog compiles the member's own type
// syntax all the same, so the array still carries a dim range and an Elem ref
// — only a member whose element names a typedef we never registered stays
// bare.  Returns null for element kinds this does not model (enums, structs,
// non-integral), which keeps the historic bare form for them.
// HierPathUnpacked's `keymgr_pkg::foo_t.pair`.
UHDM::typespec* UhdmExporter::anonAggregateElemTs(
    const Type& elemType, const syntax::SyntaxNode* memberTypeSyn) {
    if (!memberTypeSyn || elemType.kind == SymbolKind::TypeAlias)
        return nullptr;
    auto& elc = elemType.getCanonicalType();
    if (!elc.isIntegral() || elc.isEnum() || elc.isStruct())
        return nullptr;
    auto* lts = s.MakeLogic_typespec();
    setLoc(lts, memberTypeSyn->sourceRange());
    if (elemType.isSigned())
        lts->VpiSigned(true);
    const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dims = nullptr;
    if (syntax::IntegerTypeSyntax::isKind(memberTypeSyn->kind))
        dims = &memberTypeSyn->as<syntax::IntegerTypeSyntax>().dimensions;
    std::vector<ConstantRange> pd;
    for (const Type* pt = &elc; pt->isPackedArray();
         pt = &pt->as<PackedArrayType>().elementType.getCanonicalType())
        pd.push_back(pt->as<PackedArrayType>().range);
    if (dims && !pd.empty() && pd.size() == dims->size()) {
        auto* rv = s.MakeRangeVec();
        for (size_t di = 0; di < pd.size(); di++) {
            auto* dsy = (*dims)[di];
            auto* r = s.MakeRange();
            r->VpiParent(lts);
            setLoc(r, dsy->sourceRange());
            const syntax::ExpressionSyntax* pl = nullptr;
            const syntax::ExpressionSyntax* pr = nullptr;
            if (dsy->specifier &&
                dsy->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier)
                if (auto* rs =
                        dsy->specifier
                            ->as<syntax::RangeDimensionSpecifierSyntax>()
                            .selector->as_if<syntax::RangeSelectSyntax>()) {
                    pl = rs->left;
                    pr = rs->right;
                }
            r->Left_expr(makeBoundConst(pl, pd[di].left, r));
            r->Right_expr(makeBoundConst(pr, pd[di].right, r));
            rv->push_back(r);
        }
        lts->Ranges(rv);
    }
    return lts;
}

// Surelog does not SHARE a named vector typedef's typespec object across
// references — it copies it, and the copy is instance-free (the shared object
// carries the DEF-view module instance). uhdm-dump abbreviates an already
// visited typespec, so the difference is invisible in a dump diff while
// typespec::Compare, which recurses vpiInstance, fails hard on it: a def-view
// module_inst never equals the elaborated one (r9tdclone).
UHDM::typespec* UhdmExporter::copyNamedVecTs(const UHDM::typespec* src,
                                             UHDM::any* parent) {
    if (!src || src->UhdmType() != UHDM::uhdmlogic_typespec)
        return nullptr;
    auto* sl = (const UHDM::logic_typespec*)src;
    auto* cl = s.MakeLogic_typespec();
    cl->VpiName(std::string(sl->VpiName()));
    cl->VpiParent(parent);
    cl->VpiFile(sl->VpiFile());
    cl->VpiLineNo(sl->VpiLineNo());
    cl->VpiColumnNo(sl->VpiColumnNo());
    cl->VpiEndLineNo(sl->VpiEndLineNo());
    cl->VpiEndColumnNo(sl->VpiEndColumnNo());
    cl->VpiVector(sl->VpiVector());
    cl->VpiSigned(sl->VpiSigned());
    cl->Ranges(((UHDM::logic_typespec*)sl)->Ranges());
    cl->Elem_typespec(((UHDM::logic_typespec*)sl)->Elem_typespec());
    return cl;
}

// Fold a packed-vector typespec's still-symbolic bounds to the given literal
// range. Used where a SECOND copy of a typedef's base vector is re-emitted
// from syntax (so a param-dependent bound such as `[TxWidth-1:0]` comes back
// as an unfolded op tree) while golden gives BOTH copies the same folded
// [3:0]. The folded bound takes the "- / * / / fold signed" family's form —
// INT, size 64 — anchored at the operation's LEFT operand, the same anchor
// every other package-view fold uses. ImportBinding `typedef lc_tx_e lc_tx_t`.
void UhdmExporter::foldVecBounds(UHDM::typespec* dst, int64_t left,
                                 int64_t right) {
    if (!dst)
        return;
    UHDM::VectorOfrange* dr = nullptr;
    if (dst->UhdmType() == UHDM::uhdmlogic_typespec)
        dr = ((UHDM::logic_typespec*)dst)->Ranges();
    else if (dst->UhdmType() == UHDM::uhdmbit_typespec)
        dr = ((UHDM::bit_typespec*)dst)->Ranges();
    if (!dr || dr->size() != 1)
        return;
    auto* rng = (*dr)[0];
    if (!rng)
        return;
    auto mk = [&](UHDM::expr* old, int64_t v) -> UHDM::expr* {
        if (!old || old->UhdmType() != UHDM::uhdmoperation)
            return nullptr;
        const UHDM::any* anchor = old;
        if (auto* ops = ((UHDM::operation*)old)->Operands())
            if (!ops->empty() && (*ops)[0])
                anchor = (*ops)[0];
        auto* c = s.MakeConstant();
        std::string dg = std::to_string(v);
        c->VpiDecompile(dg);
        c->VpiValue("INT:" + dg);
        c->VpiSize(64);
        c->VpiConstType(vpiIntConst);
        c->VpiFile(anchor->VpiFile());
        c->VpiLineNo(anchor->VpiLineNo());
        c->VpiColumnNo(anchor->VpiColumnNo());
        c->VpiEndLineNo(anchor->VpiEndLineNo());
        c->VpiEndColumnNo(anchor->VpiEndColumnNo());
        c->VpiParent(rng);
        return c;
    };
    if (auto* nl = mk(rng->Left_expr(), left))
        rng->Left_expr(nl);
    if (auto* nr = mk(rng->Right_expr(), right))
        rng->Right_expr(nr);
}

UHDM::struct_typespec* UhdmExporter::buildStructTs(const Scope& structScope, bool packed,
                                                   const std::string& aliasName,
                                                   const std::string& memberSep) {
    auto* sts = s.MakeStruct_typespec();
    if (packed)
        sts->VpiPacked(true);
    // A MODULE-scope NAMED struct typedef keeps its members' packed-dim
    // OPERATION bounds symbolic in the elab view (Surelog); anonymous structs
    // (declared inline on a variable) and PACKAGE typedefs fold them. Named =
    // the struct's syntax sits inside a TypedefDeclaration; scope = no Package
    // ancestor.
    bool savedSymBound = structMemberSymBound;
    {
        bool namedTypedef = false;
        for (auto sn = structScope.asSymbol().getSyntax(); sn; sn = sn->parent)
            if (sn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                namedTypedef = true;
                break;
            }
        bool inPkg = false;
        // A `$unit`-scope struct typedef folds its member bounds like a
        // package one: Surelog compiles the compilation unit before any
        // module, so `logic [G_DW-1:0] data` in a file-level typedef lands as
        // a constant (Scr1SvTests type_scr1_scu_sysctrl_dr_s).
        bool inUnit = false;
        for (auto sc = structScope.asSymbol().getParentScope(); sc;
             sc = sc->asSymbol().getParentScope()) {
            if (sc->asSymbol().kind == SymbolKind::Package) {
                inPkg = true;
                structPkgScope = sc;
                break;
            }
            if (sc->asSymbol().kind == SymbolKind::CompilationUnit) {
                inUnit = true;
                break;
            }
            // Stop at the first real design scope: a MODULE-scope typedef
            // reaches the compilation unit too (every InstanceBody is nested
            // in one) and must NOT be read as file-level.
            if (sc->asSymbol().kind == SymbolKind::InstanceBody ||
                sc->asSymbol().kind == SymbolKind::GenerateBlock ||
                sc->asSymbol().kind == SymbolKind::GenerateBlockArray ||
                sc->asSymbol().kind == SymbolKind::Subroutine)
                break;
        }
        if (!inPkg)
            structPkgScope = nullptr;
        structMemberSymBound = (namedTypedef && !inPkg && !inUnit) ||
                               (namedTypedef && inPkg && pkgDefListingSymBound);
    }
    auto* members = s.MakeTypespec_memberVec();
    for (auto& fm : structScope.members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        auto* tm = s.MakeTypespec_member();
        tm->VpiName(fm.name);
        tm->VpiParent(sts);
        setLoc(tm, nameSpan(fm.location, fm.name));
        // An UNPACKED-array member (foo_t f [7]) spans name..last dim
        // (Surelog).
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            if (auto dsm9 = fm.getSyntax();
                dsm9 && dsm9->kind == syntax::SyntaxKind::Declarator) {
                auto& ddm9 = dsm9->as<syntax::DeclaratorSyntax>();
                if (!ddm9.dimensions.empty()) {
                    auto de9 = ddm9.dimensions[ddm9.dimensions.size() - 1]
                                   ->sourceRange()
                                   .end();
                    tm->VpiEndLineNo(sm->getLineNumber(de9));
                    tm->VpiEndColumnNo(sm->getColumnNumber(de9));
                }
            }
        // The canonical struct's fields may lose their type-syntax link;
        // recover it from the member declaration syntax.
        const syntax::SyntaxNode* memberTypeSyn = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                memberTypeSyn = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        }
        UHDM::typespec* fts = nullptr;
        // Unpacked-array member ats parent policy (see branch below):
        // MAIN (module-scoped) trees leave the ats/range/elem-ref/1-const
        // PARENT-FREE; BARE clone trees parent the ats at the member's ref.
        bool ats9MainFree = false;
        bool ats9CloneRefParent = false;
        // Set when a struct PARAM clone's NAMED-enum member gets its own fresh
        // scoped enum clone (parented at the member ref, below).
        bool memberEnumClone = false;
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            // Unpacked-array member (foo_t f [7]): a LOC-LESS array_typespec.
            // With a TYPEDEF'd element it carries the dim range ([0 : N-1 op]
            // at the size token) and an Elem ref to the shared element ts;
            // otherwise it stays bare (Surelog).
            // A CLASS-scope aggregate whose member is declared with ANOTHER
            // class typedef (`t_array m1;`) points straight at that typedef's
            // own array_typespec — Surelog resolves the name, it does not
            // re-derive the array (VirtualClass t_struct.m1).
            UHDM::typespec* sharedAlias9 = nullptr;
            if (unfoldedTypedefDims &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                if (auto ai9 = typedefTs.find(&fm.getDeclaredType()->getType());
                    ai9 != typedefTs.end())
                    sharedAlias9 = ai9->second;
            }
            if (sharedAlias9) {
                fts = sharedAlias9;
            }
            else {
            auto* ats9 = s.MakeArray_typespec();
            bool main9 = aliasName.find('.') != std::string::npos ||
                         aliasName.find(':') != std::string::npos;
            ats9MainFree = main9;
            ats9CloneRefParent = !main9;
            auto& ua9 = fm.getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>();
            UHDM::typespec* ets9 = nullptr;
            if (auto ei9 = typedefTs.find(&ua9.elementType);
                ei9 != typedefTs.end())
                ets9 = ei9->second;
            bool freshElem9 = false;
            if (!ets9) {
                ets9 = anonAggregateElemTs(ua9.elementType, memberTypeSyn);
                if (ets9) {
                    ets9->Instance(sts->Instance());
                    freshElem9 = true;
                }
            }
            if (ets9) {
                const syntax::VariableDimensionSyntax* dim9 = nullptr;
                if (auto ds9 = fm.getSyntax();
                    ds9 && ds9->kind == syntax::SyntaxKind::Declarator) {
                    auto& dd9 = ds9->as<syntax::DeclaratorSyntax>();
                    if (!dd9.dimensions.empty())
                        dim9 = dd9.dimensions[0];
                }
                const syntax::ExpressionSyntax* sz9 = nullptr;
                // [l:r] form — only a CLASS-scope member keeps it (the bounds
                // stay symbolic there); elsewhere both bounds fold below.
                const syntax::ExpressionSyntax* lo9 = nullptr;
                const syntax::ExpressionSyntax* hi9 = nullptr;
                if (dim9 && dim9->specifier &&
                    dim9->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel9 =
                        *dim9->specifier
                             ->as<syntax::RangeDimensionSpecifierSyntax>()
                             .selector;
                    if (auto* bs9 = sel9.as_if<syntax::BitSelectSyntax>())
                        sz9 = bs9->expr;
                    else if (auto* rs9 = sel9.as_if<syntax::RangeSelectSyntax>()) {
                        hi9 = rs9->left;
                        lo9 = rs9->right;
                    }
                }
                auto* r9 = s.MakeRange();
                if (!main9)
                    r9->VpiParent(ats9);
                if (sz9)
                    setLoc(r9, sz9->sourceRange());
                else if (unfoldedTypedefDims && hi9 && lo9 && dim9)
                    setLoc(r9, dim9->sourceRange());
                auto mk9 = [&](int64_t v,
                               const syntax::SyntaxNode* bs) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string d = std::to_string(v);
                    c->VpiDecompile(d);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + d);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r9);
                    if (bs)
                        setLoc(c, bs->sourceRange());
                    return c;
                };
                if (unfoldedTypedefDims && hi9 && lo9) {
                    // The dim's OWN refs stay bare (only the element clone's
                    // bounds scope through the member) — Surelog.
                    std::string savedPfxD = syntaxRefPrefix;
                    syntaxRefPrefix.clear();
                    r9->Left_expr((UHDM::expr*)emitSyntaxExpr(*hi9, r9));
                    r9->Right_expr((UHDM::expr*)emitSyntaxExpr(*lo9, r9));
                    syntaxRefPrefix = savedPfxD;
                }
                else {
                r9->Left_expr(mk9(0, nullptr));
                if (sz9) {
                    auto* op9 = s.MakeOperation();
                    op9->VpiOpType(vpiSubOp);
                    op9->VpiParent(r9);
                    setLoc(op9, sz9->sourceRange());
                    auto* ops9v = s.MakeAnyVec();
                    auto* n9c = mk9(ua9.range.width(), sz9);
                    n9c->VpiParent(op9);
                    ops9v->push_back(n9c);
                    auto* one9 = s.MakeConstant();
                    one9->VpiSize(64);
                    one9->VpiValue("INT:1");
                    one9->VpiConstType(vpiIntConst);
                    if (!main9)
                        one9->VpiParent(op9);
                    ops9v->push_back(one9);
                    op9->Operands(ops9v);
                    r9->Right_expr(op9);
                }
                else
                    r9->Right_expr(mk9(ua9.range.right, nullptr));
                }
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                ats9->Ranges(rv9);
                // The elem points at a fresh NAMED alias clone
                // (Typedef_alias -> the shared element ts) — Surelog.
                UHDM::typespec* tgt9 = ets9;
                if (ua9.elementType.kind == SymbolKind::TypeAlias &&
                    (ets9->UhdmType() == UHDM::uhdmbit_typespec ||
                     ets9->UhdmType() == UHDM::uhdmlogic_typespec)) {
                    auto* al9 = &ua9.elementType.as<TypeAliasType>();
                    const syntax::SyntaxNode* tsn9 = nullptr;
                    if (auto as9 = al9->getSyntax())
                        if (as9->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tsn9 = as9->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                    // The clone's own symbolic bounds scope through the member
                    // AND the element type name, like the alias ref below.
                    std::string savedPfx9 = syntaxRefPrefix;
                    if (unfoldedTypedefDims)
                        syntaxRefPrefix =
                            (aliasName.empty() ? std::string()
                                               : aliasName + memberSep) +
                            std::string(fm.name) + memberSep +
                            std::string(al9->name);
                    bypassTypedefShare = true;
                    auto* cl9e = makeTypespec(*al9, tsn9);
                    bypassTypedefShare = false;
                    syntaxRefPrefix = savedPfx9;
                    cl9e->VpiName(al9->name);
                    auto* art9e = s.MakeRef_typespec();
                    // Alias-clone ref scopes through the member AND the
                    // type name (work@top.bar_t.f.foo_t) — Surelog.
                    // ANON structs (empty alias) scope BARE: member.alias
                    // (ucsbece154b lru.way_index_t).
                    art9e->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name) + memberSep +
                        std::string(al9->name));
                    art9e->VpiParent(cl9e);
                    art9e->Actual_typespec(ets9);
                    if (cl9e->UhdmType() == UHDM::uhdmbit_typespec)
                        ((UHDM::bit_typespec*)cl9e)->Typedef_alias(art9e);
                    else if (cl9e->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)cl9e)->Typedef_alias(art9e);
                    if (main9)
                        cl9e->VpiParent(tm);
                    else {
                        // BARE clone tree: two-level chain — the alias ref
                        // points at a SECOND named clone with located
                        // ranges (Surelog); cloneA parents at the elem ref
                        // (set below, after ert9 exists).
                        bypassTypedefShare = true;
                        auto* cl9b = makeTypespec(*al9, tsn9);
                        bypassTypedefShare = false;
                        cl9b->VpiName(al9->name);
                        cl9b->VpiParent(art9e);
                        art9e->Actual_typespec(cl9b);
                    }
                    tgt9 = cl9e;
                }
                auto* ert9 = s.MakeRef_typespec();
                // The MODULE-scoped (main) member's elem ref is NAMELESS;
                // a BARE-scoped clone tree names it alias.member (Surelog).
                if (aliasName.find('.') == std::string::npos &&
                    aliasName.find(':') == std::string::npos)
                    ert9->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name));
                if (!main9)
                    ert9->VpiParent(ats9);
                ert9->Actual_typespec(tgt9);
                ats9->Elem_typespec(ert9);
                // A FRESHLY minted element ts is a member type like any
                // other: it parents at the typespec_member in a MAIN
                // (module-scoped) tree, at its own Elem ref in a clone.
                if (freshElem9)
                    ets9->VpiParent(main9 ? (UHDM::BaseClass*)tm
                                          : (UHDM::BaseClass*)ert9);
                if (!main9 && tgt9 != ets9)
                    tgt9->VpiParent(ert9);
            }
            fts = ats9;
            }
        }
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM). A module named typedef keeps its member
            // bounds symbolic in the elab view too, with the same member-scoped
            // ref name — so scope refs there as well.
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if ((tfContext || structMemberSymBound) && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            // A packed array over a VECTOR TYPEDEF member (logic4 [2:0] m)
            // needs makeTypespec's anonymous-logic-ts branch (Elem ref ->
            // typedef, array dim as range), which is tfContext-gated. A def-view
            // struct/union typespec is built with tfContext forced on; the dims
            // are literal, so clear it for this member.
            bool savedTf = tfContext;
            const TypeAliasType* vtaMem = nullptr;
            UHDM::typespec* vtaMemBase = nullptr;
            const TypeAliasType* btaMem = nullptr;
            UHDM::typespec* btaMemBase = nullptr;
            if (fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind ==
                    SymbolKind::PackedArrayType) {
                auto& etm = fm.getDeclaredType()
                                ->getType()
                                .as<PackedArrayType>()
                                .elementType;
                if (etm.kind == SymbolKind::TypeAlias) {
                    if (auto titm = typedefTs.find(&etm);
                        titm != typedefTs.end() &&
                        titm->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                        tfContext = false;
                        vtaMem = &etm.as<TypeAliasType>();
                        vtaMemBase = titm->second;
                    }
                    else if (titm != typedefTs.end() &&
                             titm->second->UhdmType() ==
                                 UHDM::uhdmbit_typespec) {
                        btaMem = &etm.as<TypeAliasType>();
                        btaMemBase = titm->second;
                    }
                }
            }
            // A packed array over a BIT TYPEDEF member (bit8_t [3:0] a):
            // packed_array_typespec with the array dim + Elem ref to a fresh
            // NAMED bit clone (Typedef_alias -> shared base) — Surelog.
            if (btaMem && btaMemBase) {
                auto* pat9 = s.MakePacked_array_typespec();
                if (memberTypeSyn)
                    setLoc(pat9, memberTypeSyn->sourceRange());
                auto& par9 =
                    fm.getDeclaredType()->getType().as<PackedArrayType>();
                std::vector<DimSpan> spans9;
                if (memberTypeSyn) {
                    auto full9 = memberTypeSyn->sourceRange();
                    spans9 = scanDimSpans(std::string(rawText(full9)),
                                          full9.start());
                }
                auto* r9 = s.MakeRange();
                r9->VpiParent(pat9);
                const DimSpan* ds9 =
                    spans9.empty() ? nullptr : &spans9[0];
                if (ds9)
                    setLoc(r9, ds9->range);
                auto mkB9 = [&](int64_t v9,
                                const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(r9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                r9->Left_expr(mkB9(par9.range.left, ds9 ? &ds9->left : nullptr));
                r9->Right_expr(
                    mkB9(par9.range.right, ds9 ? &ds9->right : nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                pat9->Ranges(rv9);
                const syntax::SyntaxNode* tgtSyn9 = nullptr;
                if (auto asyn9 = btaMem->getSyntax())
                    if (asyn9->kind ==
                        syntax::SyntaxKind::TypedefDeclaration)
                        tgtSyn9 =
                            asyn9->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl9 = makeTypespec(*btaMem, tgtSyn9);
                bypassTypedefShare = false;
                cl9->VpiName(btaMem->name);
                auto* art9 = s.MakeRef_typespec();
                art9->VpiFullName(std::string(btaMem->name));
                art9->VpiParent(cl9);
                art9->Actual_typespec(btaMemBase);
                if (cl9->UhdmType() == UHDM::uhdmbit_typespec)
                    ((UHDM::bit_typespec*)cl9)->Typedef_alias(art9);
                else if (cl9->UhdmType() == UHDM::uhdmlogic_typespec)
                    ((UHDM::logic_typespec*)cl9)->Typedef_alias(art9);
                if (savedTf)
                    cl9->Instance(btaMemBase->Instance());
                auto* ert9 = s.MakeRef_typespec();
                ert9->VpiFullName((aliasName.empty()
                                       ? std::string()
                                       : aliasName + memberSep) +
                                  std::string(fm.name));
                ert9->VpiParent(pat9);
                ert9->Actual_typespec(cl9);
                pat9->Elem_typespec(ert9);
                fts = pat9;
            }
            // A member typed by an ALIAS-OF-TYPEDEF (imm_l_t imm; where
            // typedef imm_i_t imm_l_t) SHARES the package's alias object
            // directly — no member clone (jeras_union ctl_ldu_t.imm).
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
                fm.getDeclaredType()
                        ->getType()
                        .as<TypeAliasType>()
                        .targetType.getType()
                        .kind == SymbolKind::TypeAlias) {
                if (auto titA = typedefTs.find(&fm.getDeclaredType()->getType());
                    titA != typedefTs.end() && !titA->second->VpiName().empty())
                    fts = titA->second;
            }
            // A DIRECT vector-typedef member (reg_addr_t rs1;): Surelog gives
            // the member its own NAMED alias clone (parent = the member,
            // Typedef_alias -> the shared typedef ts, own range copy) instead
            // of pointing at the shared ts.
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                auto& amt = fm.getDeclaredType()->getType();
                if (auto tita = typedefTs.find(&amt);
                    tita != typedefTs.end() &&
                    tita->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* dta = &amt.as<TypeAliasType>();
                    const syntax::SyntaxNode* tgtSynD = nullptr;
                    if (auto asynD = dta->getSyntax())
                        if (asynD->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSynD =
                                asynD->as<syntax::TypedefDeclarationSyntax>()
                                    .type;
                    bypassTypedefShare = true;
                    // A DEF-pkg member clone keeps SYMBOLIC bounds (12-1 op);
                    // the TOP/module-side clone folds (rewritten with its
                    // work@-scoped alias in emitImportArtifacts) — Surelog,
                    // jeras_union imm_*/fn3_t.
                    bool savedTfD9 = tfContext;
                    if (inPkgTypedefEmit && !pkgTopEmit)
                        tfContext = true;
                    auto* clD = makeTypespec(*dta, tgtSynD);
                    tfContext = savedTfD9;
                    bypassTypedefShare = false;
                    clD->VpiName(dta->name);
                    clD->VpiParent(tm);
                    auto* artD = s.MakeRef_typespec();
                    artD->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name) + memberSep +
                        std::string(dta->name));
                    artD->VpiParent(clD);
                    // The TOP-pkg build's and module-context clones FOLD
                    // (alias -> the folded pkg twin); the DEF-pkg build keeps
                    // the symbolic clone -> shared ts (jeras_union imm_*).
                    // The top-view fold reaches the clones nested inside an
                    // aggregate typedef too (rp32 op32_t.r4.funct3), which the
                    // listing-level cross-wire never sees.
                    bool foldD = !inPkgTypedefEmit || pkgTopEmit;
                    UHDM::typespec* twD = nullptr;
                    if (castAggCloneCtx) {
                        // A CAST clone tree's vector-typedef member binds a
                        // FRESH pkg-named FOLDED twin parented at this alias
                        // ref — one per clone, not the shared listing twin
                        // (Surelog; jeras_union op32_*'s fn3_t).
                        bypassTypedefShare = true;
                        bool sTfD = tfContext;
                        tfContext = false;
                        auto* ftw = makeTypespec(*dta, tgtSynD);
                        tfContext = sTfD;
                        bypassTypedefShare = false;
                        std::string tnm(dta->name);
                        for (auto sc9 = dta->getParentScope(); sc9;
                             sc9 = sc9->asSymbol().getParentScope())
                            if (sc9->asSymbol().kind == SymbolKind::Package) {
                                tnm = std::string(sc9->asSymbol().name) +
                                      "::" + tnm;
                                break;
                            }
                        ftw->VpiName(tnm);
                        ftw->Instance(tita->second->Instance());
                        foldVectorTsBounds(ftw, amt.getCanonicalType());
                        ftw->VpiParent(artD);
                        twD = ftw;
                    }
                    else if (foldD) {
                        // Inside the ELABORATED package listing the alias
                        // binds that listing's OWN folded typedef object
                        // rather than a fresh fold twin (rp32 dec_t.fn3 ->
                        // the top-view fn3_t, package-top instanced).
                        if (inPkgTypedefEmit && pkgTopEmit)
                            if (auto tt0 =
                                    pkgTopTypedefTs.find((const void*)&amt);
                                tt0 != pkgTopTypedefTs.end() && tt0->second)
                                twD = tt0->second;
                        if (!twD)
                            twD = pkgVectorFoldTwin(amt, tita->second);
                        // A MATERIALIZED-IMPORT parameter struct-clone's
                        // vector-typedef member binds its OWN UNQUALIFIED copy
                        // of that twin, parented at this alias ref — the
                        // pkg-NAMED twin belongs to the module typedef listing
                        // AND to a module's own parameter's clone (Surelog;
                        // StructUnsizedVal work@dut.InitDefault.pkg::init_t.
                        // key.key -> `key` while work@dut.pkg::init_t.key.key
                        // and work@top.d.Init.pkg::init_t.key.key -> `pkg::key`
                        // — § paramCloneImportedCopy).
                        if (twD && structCloneMemberRefParent &&
                            paramCloneImportedCopy && !paramOpCloneCtx)
                            if (auto* pcp0 = copyNamedVecTs(twD, artD)) {
                                pcp0->VpiName(std::string(dta->name));
                                pcp0->Instance(twD->Instance());
                                twD = pcp0;
                            }
                    }
                    // An ELAB *operation* clone (the flat op75's own ts) is
                    // INSTANCE-FREE all the way down: its vector-typedef
                    // member's alias binds a fresh instance-less COPY of the
                    // module's shared typedef object rather than the object
                    // itself (which carries the DEF-view module instance).
                    // The PARAMETER clone keeps pointing at the shared object
                    // — there the golden's per-reference copy carries the same
                    // instance, so the two compare equal.  typespec::Compare
                    // recurses vpiInstance and a def-view module_inst never
                    // equals the elaborated one (vpiTopModule differs, and gen
                    // constructs land in Gen_stmts vs Gen_scope_arrays), so
                    // this is a hard cmp failure that no dump shows
                    // (r9tdclone, ParamSubstituteComplex).  Copy the compared
                    // fields by hand: DeepClone recurses forever through the
                    // self-referential Typedef_alias.
                    UHDM::typespec* opCp0 = nullptr;
                    if (paramOpCloneCtx && !twD && tita->second->Instance())
                        opCp0 = copyNamedVecTs(tita->second, artD);
                    artD->Actual_typespec(opCp0 ? opCp0
                                                : (twD ? twD : tita->second));
                    if (twD)
                        foldVectorTsBounds(clD, amt.getCanonicalType());
                    if (clD->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)clD)->Typedef_alias(artD);
                    // A typedef-definition-build clone carries vpiInstance =
                    // the typedef's OWN home scope (Surelog), like the
                    // packed-array element clone below — for a PACKAGE typedef
                    // that is its defining package, not the shared ts's owner
                    // (which may be a re-exporting package).
                    if (savedTf) {
                        UHDM::instance* aliasInst = tita->second->Instance();
                        if (auto asc = dta->getParentScope();
                            asc && asc->asSymbol().kind == SymbolKind::Package) {
                            auto pit0 = pkgDefMap.find(&asc->asSymbol());
                            aliasInst = pit0 != pkgDefMap.end()
                                            ? (UHDM::instance*)pit0->second
                                            : nullptr;
                        }
                        clD->Instance(aliasInst);
                    }
                    fts = clD;
                }
            }
            // A struct/union PARAM clone (structCloneMemberRefParent) whose
            // member is a NAMED package-enum typedef carries its OWN fresh
            // scoped enum clone: parent = the member ref (below), instanced at
            // the CONTAINER's package, base ref scoped through the member
            // (…member.pkg::enum_e), base actual instanced at the ENUM's own
            // home package (Surelog emits one member-enum clone per struct-
            // param clone — the 5-level-hierarchy / passed-down families).
            // A CAST clone tree's STRUCT-typedef member gets its OWN fresh
            // threaded clone (member refs <alias>.<mem>.<pkg::S>.<sm>),
            // parented at the member ref, spans/Instance mirroring the shared
            // typedef object (Surelog; jeras_union op32_t'(ins)).
            if (!fts && castAggCloneCtx && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
                fm.getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType) {
                auto& mta =
                    fm.getDeclaredType()->getType().as<TypeAliasType>();
                std::string mnm(mta.name);
                for (auto sc9 = mta.getParentScope(); sc9;
                     sc9 = sc9->asSymbol().getParentScope())
                    if (sc9->asSymbol().kind == SymbolKind::Package) {
                        mnm = std::string(sc9->asSymbol().name) + "::" + mnm;
                        break;
                    }
                std::string subAlias =
                    (aliasName.empty()
                         ? std::string(fm.name)
                         : aliasName + memberSep + std::string(fm.name)) +
                    memberSep + mnm;
                auto* scl = buildStructTs(
                    mta.getCanonicalType().as<PackedStructType>(), true,
                    subAlias, memberSep);
                scl->VpiName(mnm);
                if (auto sit9 = typedefTs.find(
                        (const Symbol*)&fm.getDeclaredType()->getType());
                    sit9 != typedefTs.end()) {
                    auto* sh9 = sit9->second;
                    scl->VpiLineNo(sh9->VpiLineNo());
                    scl->VpiColumnNo(sh9->VpiColumnNo());
                    scl->VpiEndLineNo(sh9->VpiEndLineNo());
                    scl->VpiEndColumnNo(sh9->VpiEndColumnNo());
                    scl->Instance(sh9->Instance());
                }
                fts = scl;
                memberEnumClone = true; // ref-parent like the enum clones
            }
            if (!fts && structCloneMemberRefParent && fm.getDeclaredType()) {
                auto& mdt = fm.getDeclaredType()->getType();
                if (mdt.kind == SymbolKind::TypeAlias &&
                    mdt.getCanonicalType().kind == SymbolKind::EnumType) {
                    auto& etAlias = mdt.as<TypeAliasType>();
                    const Symbol* enumPkg = nullptr;
                    for (auto* sc = etAlias.getParentScope(); sc;
                         sc = sc->asSymbol().getParentScope())
                        if (sc->asSymbol().kind == SymbolKind::Package) {
                            enumPkg = &sc->asSymbol();
                            break;
                        }
                    const Symbol* containerPkg = nullptr;
                    for (auto* sc = fm.getParentScope(); sc;
                         sc = sc->asSymbol().getParentScope())
                        if (sc->asSymbol().kind == SymbolKind::Package) {
                            containerPkg = &sc->asSymbol();
                            break;
                        }
                    if (enumPkg) {
                        std::string enumNm = std::string(enumPkg->name) +
                                             "::" + std::string(etAlias.name);
                        std::string memRefFull =
                            aliasName.empty()
                                ? std::string(fm.name)
                                : aliasName + memberSep + std::string(fm.name);
                        const syntax::SyntaxNode* eSyn = nullptr;
                        if (auto dS = etAlias.getSyntax();
                            dS && dS->kind ==
                                      syntax::SyntaxKind::TypedefDeclaration)
                            eSyn = dS->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                        auto* ecl = buildEnumTs(
                            mdt.getCanonicalType().as<EnumType>(), eSyn,
                            memRefFull + "." + enumNm);
                        ecl->VpiName(enumNm);
                        if (auto dS = etAlias.getSyntax())
                            setLoc(ecl, dS->sourceRange());
                        if (containerPkg)
                            if (auto sit = pkgDefMap.find(containerPkg);
                                sit != pkgDefMap.end())
                                ecl->Instance(sit->second);
                        if (auto eit = pkgDefMap.find(enumPkg);
                            eit != pkgDefMap.end() && ecl->Base_typespec() &&
                            ecl->Base_typespec()->Actual_typespec()) {
                            ecl->Base_typespec()->Actual_typespec()->VpiParent(
                                ecl->Base_typespec());
                            ecl->Base_typespec()->Actual_typespec()->Instance(
                                eit->second);
                        }
                        fts = ecl;
                        memberEnumClone = true;
                    }
                }
            }
            if (!fts)
                fts = makeTypespec(fm, memberTypeSyn);
            // A nested ANONYMOUS struct member's struct_typespec is located at
            // the `struct` keyword span (Surelog); makeTypespec leaves it
            // loc-less for the anonymous form.
            if (fts && fts->UhdmType() == UHDM::uhdmstruct_typespec &&
                fts->VpiLineNo() == 0 && memberTypeSyn)
                setLoc(fts, memberTypeSyn->getFirstToken().range());
            tfContext = savedTf;
            // Surelog points the member's Elem ref at a fresh NAMED alias-clone
            // (Typedef_alias -> shared base, Instance = module) rather than the
            // bare base the anonymous-ts branch bound.
            if (vtaMem && vtaMemBase &&
                fts->UhdmType() == UHDM::uhdmlogic_typespec) {
                if (auto* et = ((UHDM::logic_typespec*)fts)->Elem_typespec()) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = vtaMem->getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>()
                                         .type;
                    bypassTypedefShare = true;
                    auto* cl = makeTypespec(*vtaMem, tgtSyn);
                    bypassTypedefShare = false;
                    cl->VpiName(vtaMem->name);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(std::string(vtaMem->name));
                    art->VpiParent(cl);
                    art->Actual_typespec(vtaMemBase);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    // Only the DEF-view clone (tfContext build) carries
                    // Instance; the elab-view clone leaves it null (Surelog).
                    if (savedTf)
                        cl->Instance(vtaMemBase->Instance());
                    et->Actual_typespec(cl);
                }
            }
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        // Fresh member typespecs parent at the member; shared typedef
        // typespecs (named) keep their own parent. Elab param CLONES parent
        // them at the member's REF instead (Surelog clone form).
        if (fts->VpiName().empty() && !ats9MainFree)
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        // ANONYMOUS structs (empty alias) name member refs bare, no
        // leading separator (struct_3d_packed_array).
        rt->VpiFullName(aliasName.empty()
                            ? std::string(fm.name)
                            : aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
        if (((structCloneMemberRefParent || ats9CloneRefParent) &&
             fts->VpiName().empty()) ||
            memberEnumClone)
            fts->VpiParent(rt);
        // Ref* fields point at the member's type syntax.
        if (memberTypeSyn) {
            auto sr = memberTypeSyn->sourceRange();
            if (sr.start() != SourceLocation::NoLocation) {
                tm->VpiRefFile(fullFilePath(sr.start()));
                tm->VpiRefLineNo(sm->getLineNumber(sr.start()));
                tm->VpiRefColumnNo(sm->getColumnNumber(sr.start()));
                tm->VpiRefEndLineNo(sm->getLineNumber(sr.end()));
                tm->VpiRefEndColumnNo(sm->getColumnNumber(sr.end()));
            }
        }
        members->push_back(tm);
    }
    structMemberSymBound = savedSymBound;
    structPkgScope = nullptr;
    sts->Members(members);
    return sts;
}


UHDM::union_typespec* UhdmExporter::buildUnionTs(const Scope& unionScope, bool packed,
                                                 const std::string& aliasName,
                                                 const std::string& memberSep) {
    auto* uts = s.MakeUnion_typespec();
    if (packed)
        uts->VpiPacked(true);
    auto* members = s.MakeTypespec_memberVec();
    for (auto& fm : unionScope.members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        auto* tm = s.MakeTypespec_member();
        tm->VpiName(fm.name);
        tm->VpiParent(uts);
        setLoc(tm, nameSpan(fm.location, fm.name));
        // An UNPACKED-array member (foo_t f [7]) spans name..last dim
        // (Surelog).
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            if (auto dsm9 = fm.getSyntax();
                dsm9 && dsm9->kind == syntax::SyntaxKind::Declarator) {
                auto& ddm9 = dsm9->as<syntax::DeclaratorSyntax>();
                if (!ddm9.dimensions.empty()) {
                    auto de9 = ddm9.dimensions[ddm9.dimensions.size() - 1]
                                   ->sourceRange()
                                   .end();
                    tm->VpiEndLineNo(sm->getLineNumber(de9));
                    tm->VpiEndColumnNo(sm->getColumnNumber(de9));
                }
            }
        const syntax::SyntaxNode* memberTypeSyn = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                memberTypeSyn = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        }
        UHDM::typespec* fts = nullptr;
        // Unpacked-array member ats parent policy (see branch below):
        // MAIN (module-scoped) trees leave the ats/range/elem-ref/1-const
        // PARENT-FREE; BARE clone trees parent the ats at the member's ref.
        bool ats9MainFree = false;
        bool ats9CloneRefParent = false;
        // Set when a struct PARAM clone's NAMED-enum member gets its own fresh
        // scoped enum clone (parented at the member ref, below).
        bool memberEnumClone = false;
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            // Unpacked-array member (foo_t f [7]): a LOC-LESS array_typespec.
            // With a TYPEDEF'd element it carries the dim range ([0 : N-1 op]
            // at the size token) and an Elem ref to the shared element ts;
            // otherwise it stays bare (Surelog).
            // A CLASS-scope aggregate whose member is declared with ANOTHER
            // class typedef (`t_array m1;`) points straight at that typedef's
            // own array_typespec — Surelog resolves the name, it does not
            // re-derive the array (VirtualClass t_struct.m1).
            UHDM::typespec* sharedAlias9 = nullptr;
            if (unfoldedTypedefDims &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                if (auto ai9 = typedefTs.find(&fm.getDeclaredType()->getType());
                    ai9 != typedefTs.end())
                    sharedAlias9 = ai9->second;
            }
            if (sharedAlias9) {
                fts = sharedAlias9;
            }
            else {
            auto* ats9 = s.MakeArray_typespec();
            bool main9 = aliasName.find('.') != std::string::npos ||
                         aliasName.find(':') != std::string::npos;
            ats9MainFree = main9;
            ats9CloneRefParent = !main9;
            auto& ua9 = fm.getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>();
            UHDM::typespec* ets9 = nullptr;
            if (auto ei9 = typedefTs.find(&ua9.elementType);
                ei9 != typedefTs.end())
                ets9 = ei9->second;
            bool freshElem9 = false;
            if (!ets9) {
                ets9 = anonAggregateElemTs(ua9.elementType, memberTypeSyn);
                if (ets9) {
                    ets9->Instance(uts->Instance());
                    freshElem9 = true;
                }
            }
            if (ets9) {
                const syntax::VariableDimensionSyntax* dim9 = nullptr;
                if (auto ds9 = fm.getSyntax();
                    ds9 && ds9->kind == syntax::SyntaxKind::Declarator) {
                    auto& dd9 = ds9->as<syntax::DeclaratorSyntax>();
                    if (!dd9.dimensions.empty())
                        dim9 = dd9.dimensions[0];
                }
                const syntax::ExpressionSyntax* sz9 = nullptr;
                // [l:r] form — only a CLASS-scope member keeps it (the bounds
                // stay symbolic there); elsewhere both bounds fold below.
                const syntax::ExpressionSyntax* lo9 = nullptr;
                const syntax::ExpressionSyntax* hi9 = nullptr;
                if (dim9 && dim9->specifier &&
                    dim9->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel9 =
                        *dim9->specifier
                             ->as<syntax::RangeDimensionSpecifierSyntax>()
                             .selector;
                    if (auto* bs9 = sel9.as_if<syntax::BitSelectSyntax>())
                        sz9 = bs9->expr;
                    else if (auto* rs9 = sel9.as_if<syntax::RangeSelectSyntax>()) {
                        hi9 = rs9->left;
                        lo9 = rs9->right;
                    }
                }
                auto* r9 = s.MakeRange();
                if (!main9)
                    r9->VpiParent(ats9);
                if (sz9)
                    setLoc(r9, sz9->sourceRange());
                else if (unfoldedTypedefDims && hi9 && lo9 && dim9)
                    setLoc(r9, dim9->sourceRange());
                auto mk9 = [&](int64_t v,
                               const syntax::SyntaxNode* bs) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string d = std::to_string(v);
                    c->VpiDecompile(d);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + d);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r9);
                    if (bs)
                        setLoc(c, bs->sourceRange());
                    return c;
                };
                if (unfoldedTypedefDims && hi9 && lo9) {
                    // The dim's OWN refs stay bare (only the element clone's
                    // bounds scope through the member) — Surelog.
                    std::string savedPfxD = syntaxRefPrefix;
                    syntaxRefPrefix.clear();
                    r9->Left_expr((UHDM::expr*)emitSyntaxExpr(*hi9, r9));
                    r9->Right_expr((UHDM::expr*)emitSyntaxExpr(*lo9, r9));
                    syntaxRefPrefix = savedPfxD;
                }
                else {
                r9->Left_expr(mk9(0, nullptr));
                if (sz9) {
                    auto* op9 = s.MakeOperation();
                    op9->VpiOpType(vpiSubOp);
                    op9->VpiParent(r9);
                    setLoc(op9, sz9->sourceRange());
                    auto* ops9v = s.MakeAnyVec();
                    auto* n9c = mk9(ua9.range.width(), sz9);
                    n9c->VpiParent(op9);
                    ops9v->push_back(n9c);
                    auto* one9 = s.MakeConstant();
                    one9->VpiSize(64);
                    one9->VpiValue("INT:1");
                    one9->VpiConstType(vpiIntConst);
                    if (!main9)
                        one9->VpiParent(op9);
                    ops9v->push_back(one9);
                    op9->Operands(ops9v);
                    r9->Right_expr(op9);
                }
                else
                    r9->Right_expr(mk9(ua9.range.right, nullptr));
                }
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                ats9->Ranges(rv9);
                // The elem points at a fresh NAMED alias clone
                // (Typedef_alias -> the shared element ts) — Surelog.
                UHDM::typespec* tgt9 = ets9;
                if (ua9.elementType.kind == SymbolKind::TypeAlias &&
                    (ets9->UhdmType() == UHDM::uhdmbit_typespec ||
                     ets9->UhdmType() == UHDM::uhdmlogic_typespec)) {
                    auto* al9 = &ua9.elementType.as<TypeAliasType>();
                    const syntax::SyntaxNode* tsn9 = nullptr;
                    if (auto as9 = al9->getSyntax())
                        if (as9->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tsn9 = as9->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                    // The clone's own symbolic bounds scope through the member
                    // AND the element type name, like the alias ref below.
                    std::string savedPfx9 = syntaxRefPrefix;
                    if (unfoldedTypedefDims)
                        syntaxRefPrefix =
                            (aliasName.empty() ? std::string()
                                               : aliasName + memberSep) +
                            std::string(fm.name) + memberSep +
                            std::string(al9->name);
                    bypassTypedefShare = true;
                    auto* cl9e = makeTypespec(*al9, tsn9);
                    bypassTypedefShare = false;
                    syntaxRefPrefix = savedPfx9;
                    cl9e->VpiName(al9->name);
                    auto* art9e = s.MakeRef_typespec();
                    // Alias-clone ref scopes through the member AND the
                    // type name (work@top.bar_t.f.foo_t) — Surelog.
                    // ANON structs (empty alias) scope BARE: member.alias
                    // (ucsbece154b lru.way_index_t).
                    art9e->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name) + memberSep +
                        std::string(al9->name));
                    art9e->VpiParent(cl9e);
                    art9e->Actual_typespec(ets9);
                    if (cl9e->UhdmType() == UHDM::uhdmbit_typespec)
                        ((UHDM::bit_typespec*)cl9e)->Typedef_alias(art9e);
                    else if (cl9e->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)cl9e)->Typedef_alias(art9e);
                    if (main9)
                        cl9e->VpiParent(tm);
                    else {
                        // BARE clone tree: two-level chain — the alias ref
                        // points at a SECOND named clone with located
                        // ranges (Surelog); cloneA parents at the elem ref
                        // (set below, after ert9 exists).
                        bypassTypedefShare = true;
                        auto* cl9b = makeTypespec(*al9, tsn9);
                        bypassTypedefShare = false;
                        cl9b->VpiName(al9->name);
                        cl9b->VpiParent(art9e);
                        art9e->Actual_typespec(cl9b);
                    }
                    tgt9 = cl9e;
                }
                auto* ert9 = s.MakeRef_typespec();
                // The MODULE-scoped (main) member's elem ref is NAMELESS;
                // a BARE-scoped clone tree names it alias.member (Surelog).
                if (aliasName.find('.') == std::string::npos &&
                    aliasName.find(':') == std::string::npos)
                    ert9->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name));
                if (!main9)
                    ert9->VpiParent(ats9);
                ert9->Actual_typespec(tgt9);
                ats9->Elem_typespec(ert9);
                // A FRESHLY minted element ts is a member type like any
                // other: it parents at the typespec_member in a MAIN
                // (module-scoped) tree, at its own Elem ref in a clone.
                if (freshElem9)
                    ets9->VpiParent(main9 ? (UHDM::BaseClass*)tm
                                          : (UHDM::BaseClass*)ert9);
                if (!main9 && tgt9 != ets9)
                    tgt9->VpiParent(ert9);
            }
            fts = ats9;
            }
        }
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM). A module named typedef keeps its member
            // bounds symbolic in the elab view too, with the same member-scoped
            // ref name — so scope refs there as well.
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if ((tfContext || structMemberSymBound) && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            // A packed array over a VECTOR TYPEDEF member (logic4 [2:0] m)
            // needs makeTypespec's anonymous-logic-ts branch (Elem ref ->
            // typedef, array dim as range), which is tfContext-gated. A def-view
            // struct/union typespec is built with tfContext forced on; the dims
            // are literal, so clear it for this member.
            bool savedTf = tfContext;
            const TypeAliasType* vtaMem = nullptr;
            UHDM::typespec* vtaMemBase = nullptr;
            const TypeAliasType* btaMem = nullptr;
            UHDM::typespec* btaMemBase = nullptr;
            if (fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind ==
                    SymbolKind::PackedArrayType) {
                auto& etm = fm.getDeclaredType()
                                ->getType()
                                .as<PackedArrayType>()
                                .elementType;
                if (etm.kind == SymbolKind::TypeAlias) {
                    if (auto titm = typedefTs.find(&etm);
                        titm != typedefTs.end() &&
                        titm->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                        tfContext = false;
                        vtaMem = &etm.as<TypeAliasType>();
                        vtaMemBase = titm->second;
                    }
                    else if (titm != typedefTs.end() &&
                             titm->second->UhdmType() ==
                                 UHDM::uhdmbit_typespec) {
                        btaMem = &etm.as<TypeAliasType>();
                        btaMemBase = titm->second;
                    }
                }
            }
            // A packed array over a BIT TYPEDEF member (bit8_t [3:0] a):
            // packed_array_typespec with the array dim + Elem ref to a fresh
            // NAMED bit clone (Typedef_alias -> shared base) — Surelog.
            if (btaMem && btaMemBase) {
                auto* pat9 = s.MakePacked_array_typespec();
                if (memberTypeSyn)
                    setLoc(pat9, memberTypeSyn->sourceRange());
                auto& par9 =
                    fm.getDeclaredType()->getType().as<PackedArrayType>();
                std::vector<DimSpan> spans9;
                if (memberTypeSyn) {
                    auto full9 = memberTypeSyn->sourceRange();
                    spans9 = scanDimSpans(std::string(rawText(full9)),
                                          full9.start());
                }
                auto* r9 = s.MakeRange();
                r9->VpiParent(pat9);
                const DimSpan* ds9 =
                    spans9.empty() ? nullptr : &spans9[0];
                if (ds9)
                    setLoc(r9, ds9->range);
                auto mkB9 = [&](int64_t v9,
                                const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(r9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                r9->Left_expr(mkB9(par9.range.left, ds9 ? &ds9->left : nullptr));
                r9->Right_expr(
                    mkB9(par9.range.right, ds9 ? &ds9->right : nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                pat9->Ranges(rv9);
                const syntax::SyntaxNode* tgtSyn9 = nullptr;
                if (auto asyn9 = btaMem->getSyntax())
                    if (asyn9->kind ==
                        syntax::SyntaxKind::TypedefDeclaration)
                        tgtSyn9 =
                            asyn9->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl9 = makeTypespec(*btaMem, tgtSyn9);
                bypassTypedefShare = false;
                cl9->VpiName(btaMem->name);
                auto* art9 = s.MakeRef_typespec();
                art9->VpiFullName(std::string(btaMem->name));
                art9->VpiParent(cl9);
                art9->Actual_typespec(btaMemBase);
                if (cl9->UhdmType() == UHDM::uhdmbit_typespec)
                    ((UHDM::bit_typespec*)cl9)->Typedef_alias(art9);
                else if (cl9->UhdmType() == UHDM::uhdmlogic_typespec)
                    ((UHDM::logic_typespec*)cl9)->Typedef_alias(art9);
                if (savedTf)
                    cl9->Instance(btaMemBase->Instance());
                auto* ert9 = s.MakeRef_typespec();
                ert9->VpiFullName((aliasName.empty()
                                       ? std::string()
                                       : aliasName + memberSep) +
                                  std::string(fm.name));
                ert9->VpiParent(pat9);
                ert9->Actual_typespec(cl9);
                pat9->Elem_typespec(ert9);
                fts = pat9;
            }
            // A member typed by an ALIAS-OF-TYPEDEF (imm_l_t imm; where
            // typedef imm_i_t imm_l_t) SHARES the package's alias object
            // directly — no member clone (jeras_union ctl_ldu_t.imm).
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
                fm.getDeclaredType()
                        ->getType()
                        .as<TypeAliasType>()
                        .targetType.getType()
                        .kind == SymbolKind::TypeAlias) {
                if (auto titA = typedefTs.find(&fm.getDeclaredType()->getType());
                    titA != typedefTs.end() && !titA->second->VpiName().empty())
                    fts = titA->second;
            }
            // A DIRECT vector-typedef member (reg_addr_t rs1;): Surelog gives
            // the member its own NAMED alias clone (parent = the member,
            // Typedef_alias -> the shared typedef ts, own range copy) instead
            // of pointing at the shared ts.
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                auto& amt = fm.getDeclaredType()->getType();
                if (auto tita = typedefTs.find(&amt);
                    tita != typedefTs.end() &&
                    tita->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* dta = &amt.as<TypeAliasType>();
                    const syntax::SyntaxNode* tgtSynD = nullptr;
                    if (auto asynD = dta->getSyntax())
                        if (asynD->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSynD =
                                asynD->as<syntax::TypedefDeclarationSyntax>()
                                    .type;
                    bypassTypedefShare = true;
                    // A DEF-pkg member clone keeps SYMBOLIC bounds (12-1 op);
                    // the TOP/module-side clone folds (rewritten with its
                    // work@-scoped alias in emitImportArtifacts) — Surelog,
                    // jeras_union imm_*/fn3_t.
                    bool savedTfD9 = tfContext;
                    if (inPkgTypedefEmit && !pkgTopEmit)
                        tfContext = true;
                    auto* clD = makeTypespec(*dta, tgtSynD);
                    tfContext = savedTfD9;
                    bypassTypedefShare = false;
                    clD->VpiName(dta->name);
                    clD->VpiParent(tm);
                    auto* artD = s.MakeRef_typespec();
                    artD->VpiFullName(
                        (aliasName.empty() ? std::string()
                                           : aliasName + memberSep) +
                        std::string(fm.name) + memberSep +
                        std::string(dta->name));
                    artD->VpiParent(clD);
                    // The TOP-pkg build's and module-context clones FOLD
                    // (alias -> the folded pkg twin); the DEF-pkg build keeps
                    // the symbolic clone -> shared ts (jeras_union imm_*).
                    // The top-view fold reaches the clones nested inside an
                    // aggregate typedef too (rp32 op32_t.r4.funct3), which the
                    // listing-level cross-wire never sees.
                    bool foldD = !inPkgTypedefEmit || pkgTopEmit;
                    UHDM::typespec* twD = nullptr;
                    if (castAggCloneCtx) {
                        // A CAST clone tree's vector-typedef member binds a
                        // FRESH pkg-named FOLDED twin parented at this alias
                        // ref — one per clone, not the shared listing twin
                        // (Surelog; jeras_union op32_*'s fn3_t).
                        bypassTypedefShare = true;
                        bool sTfD = tfContext;
                        tfContext = false;
                        auto* ftw = makeTypespec(*dta, tgtSynD);
                        tfContext = sTfD;
                        bypassTypedefShare = false;
                        std::string tnm(dta->name);
                        for (auto sc9 = dta->getParentScope(); sc9;
                             sc9 = sc9->asSymbol().getParentScope())
                            if (sc9->asSymbol().kind == SymbolKind::Package) {
                                tnm = std::string(sc9->asSymbol().name) +
                                      "::" + tnm;
                                break;
                            }
                        ftw->VpiName(tnm);
                        ftw->Instance(tita->second->Instance());
                        foldVectorTsBounds(ftw, amt.getCanonicalType());
                        ftw->VpiParent(artD);
                        twD = ftw;
                    }
                    else if (foldD) {
                        // Inside the ELABORATED package listing the alias
                        // binds that listing's OWN folded typedef object
                        // rather than a fresh fold twin (rp32 dec_t.fn3 ->
                        // the top-view fn3_t, package-top instanced).
                        if (inPkgTypedefEmit && pkgTopEmit)
                            if (auto tt0 =
                                    pkgTopTypedefTs.find((const void*)&amt);
                                tt0 != pkgTopTypedefTs.end() && tt0->second)
                                twD = tt0->second;
                        if (!twD)
                            twD = pkgVectorFoldTwin(amt, tita->second);
                        // A MATERIALIZED-IMPORT parameter struct-clone's
                        // vector-typedef member binds its OWN UNQUALIFIED copy
                        // of that twin, parented at this alias ref — the
                        // pkg-NAMED twin belongs to the module typedef listing
                        // AND to a module's own parameter's clone (Surelog;
                        // StructUnsizedVal work@dut.InitDefault.pkg::init_t.
                        // key.key -> `key` while work@dut.pkg::init_t.key.key
                        // and work@top.d.Init.pkg::init_t.key.key -> `pkg::key`
                        // — § paramCloneImportedCopy).
                        if (twD && structCloneMemberRefParent &&
                            paramCloneImportedCopy && !paramOpCloneCtx)
                            if (auto* pcp0 = copyNamedVecTs(twD, artD)) {
                                pcp0->VpiName(std::string(dta->name));
                                pcp0->Instance(twD->Instance());
                                twD = pcp0;
                            }
                    }
                    // An ELAB *operation* clone (the flat op75's own ts) is
                    // INSTANCE-FREE all the way down: its vector-typedef
                    // member's alias binds a fresh instance-less COPY of the
                    // module's shared typedef object rather than the object
                    // itself (which carries the DEF-view module instance).
                    // The PARAMETER clone keeps pointing at the shared object
                    // — there the golden's per-reference copy carries the same
                    // instance, so the two compare equal.  typespec::Compare
                    // recurses vpiInstance and a def-view module_inst never
                    // equals the elaborated one (vpiTopModule differs, and gen
                    // constructs land in Gen_stmts vs Gen_scope_arrays), so
                    // this is a hard cmp failure that no dump shows
                    // (r9tdclone, ParamSubstituteComplex).  Copy the compared
                    // fields by hand: DeepClone recurses forever through the
                    // self-referential Typedef_alias.
                    UHDM::typespec* opCp0 = nullptr;
                    if (paramOpCloneCtx && !twD && tita->second->Instance())
                        opCp0 = copyNamedVecTs(tita->second, artD);
                    artD->Actual_typespec(opCp0 ? opCp0
                                                : (twD ? twD : tita->second));
                    if (twD)
                        foldVectorTsBounds(clD, amt.getCanonicalType());
                    if (clD->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)clD)->Typedef_alias(artD);
                    // A typedef-definition-build clone carries vpiInstance =
                    // the typedef's OWN home scope (Surelog), like the
                    // packed-array element clone below — for a PACKAGE typedef
                    // that is its defining package, not the shared ts's owner
                    // (which may be a re-exporting package).
                    if (savedTf) {
                        UHDM::instance* aliasInst = tita->second->Instance();
                        if (auto asc = dta->getParentScope();
                            asc && asc->asSymbol().kind == SymbolKind::Package) {
                            auto pit0 = pkgDefMap.find(&asc->asSymbol());
                            aliasInst = pit0 != pkgDefMap.end()
                                            ? (UHDM::instance*)pit0->second
                                            : nullptr;
                        }
                        clD->Instance(aliasInst);
                    }
                    fts = clD;
                }
            }
            // A struct/union PARAM clone (structCloneMemberRefParent) whose
            // member is a NAMED package-enum typedef carries its OWN fresh
            // scoped enum clone: parent = the member ref (below), instanced at
            // the CONTAINER's package, base ref scoped through the member
            // (…member.pkg::enum_e), base actual instanced at the ENUM's own
            // home package (Surelog emits one member-enum clone per struct-
            // param clone — the 5-level-hierarchy / passed-down families).
            // A CAST clone tree's STRUCT-typedef member gets its OWN fresh
            // threaded clone (member refs <alias>.<mem>.<pkg::S>.<sm>),
            // parented at the member ref, spans/Instance mirroring the shared
            // typedef object (Surelog; jeras_union op32_t'(ins)).
            if (!fts && castAggCloneCtx && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
                fm.getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType) {
                auto& mta =
                    fm.getDeclaredType()->getType().as<TypeAliasType>();
                std::string mnm(mta.name);
                for (auto sc9 = mta.getParentScope(); sc9;
                     sc9 = sc9->asSymbol().getParentScope())
                    if (sc9->asSymbol().kind == SymbolKind::Package) {
                        mnm = std::string(sc9->asSymbol().name) + "::" + mnm;
                        break;
                    }
                std::string subAlias =
                    (aliasName.empty()
                         ? std::string(fm.name)
                         : aliasName + memberSep + std::string(fm.name)) +
                    memberSep + mnm;
                auto* scl = buildStructTs(
                    mta.getCanonicalType().as<PackedStructType>(), true,
                    subAlias, memberSep);
                scl->VpiName(mnm);
                if (auto sit9 = typedefTs.find(
                        (const Symbol*)&fm.getDeclaredType()->getType());
                    sit9 != typedefTs.end()) {
                    auto* sh9 = sit9->second;
                    scl->VpiLineNo(sh9->VpiLineNo());
                    scl->VpiColumnNo(sh9->VpiColumnNo());
                    scl->VpiEndLineNo(sh9->VpiEndLineNo());
                    scl->VpiEndColumnNo(sh9->VpiEndColumnNo());
                    scl->Instance(sh9->Instance());
                }
                fts = scl;
                memberEnumClone = true; // ref-parent like the enum clones
            }
            if (!fts && structCloneMemberRefParent && fm.getDeclaredType()) {
                auto& mdt = fm.getDeclaredType()->getType();
                if (mdt.kind == SymbolKind::TypeAlias &&
                    mdt.getCanonicalType().kind == SymbolKind::EnumType) {
                    auto& etAlias = mdt.as<TypeAliasType>();
                    const Symbol* enumPkg = nullptr;
                    for (auto* sc = etAlias.getParentScope(); sc;
                         sc = sc->asSymbol().getParentScope())
                        if (sc->asSymbol().kind == SymbolKind::Package) {
                            enumPkg = &sc->asSymbol();
                            break;
                        }
                    const Symbol* containerPkg = nullptr;
                    for (auto* sc = fm.getParentScope(); sc;
                         sc = sc->asSymbol().getParentScope())
                        if (sc->asSymbol().kind == SymbolKind::Package) {
                            containerPkg = &sc->asSymbol();
                            break;
                        }
                    if (enumPkg) {
                        std::string enumNm = std::string(enumPkg->name) +
                                             "::" + std::string(etAlias.name);
                        std::string memRefFull =
                            aliasName.empty()
                                ? std::string(fm.name)
                                : aliasName + memberSep + std::string(fm.name);
                        const syntax::SyntaxNode* eSyn = nullptr;
                        if (auto dS = etAlias.getSyntax();
                            dS && dS->kind ==
                                      syntax::SyntaxKind::TypedefDeclaration)
                            eSyn = dS->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                        auto* ecl = buildEnumTs(
                            mdt.getCanonicalType().as<EnumType>(), eSyn,
                            memRefFull + "." + enumNm);
                        ecl->VpiName(enumNm);
                        if (auto dS = etAlias.getSyntax())
                            setLoc(ecl, dS->sourceRange());
                        if (containerPkg)
                            if (auto sit = pkgDefMap.find(containerPkg);
                                sit != pkgDefMap.end())
                                ecl->Instance(sit->second);
                        if (auto eit = pkgDefMap.find(enumPkg);
                            eit != pkgDefMap.end() && ecl->Base_typespec() &&
                            ecl->Base_typespec()->Actual_typespec()) {
                            ecl->Base_typespec()->Actual_typespec()->VpiParent(
                                ecl->Base_typespec());
                            ecl->Base_typespec()->Actual_typespec()->Instance(
                                eit->second);
                        }
                        fts = ecl;
                        memberEnumClone = true;
                    }
                }
            }
            if (!fts)
                fts = makeTypespec(fm, memberTypeSyn);
            // A nested ANONYMOUS struct member's struct_typespec is located at
            // the `struct` keyword span (Surelog); makeTypespec leaves it
            // loc-less for the anonymous form.
            if (fts && fts->UhdmType() == UHDM::uhdmstruct_typespec &&
                fts->VpiLineNo() == 0 && memberTypeSyn)
                setLoc(fts, memberTypeSyn->getFirstToken().range());
            tfContext = savedTf;
            // Surelog points the member's Elem ref at a fresh NAMED alias-clone
            // (Typedef_alias -> shared base, Instance = module) rather than the
            // bare base the anonymous-ts branch bound.
            if (vtaMem && vtaMemBase &&
                fts->UhdmType() == UHDM::uhdmlogic_typespec) {
                if (auto* et = ((UHDM::logic_typespec*)fts)->Elem_typespec()) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = vtaMem->getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>()
                                         .type;
                    bypassTypedefShare = true;
                    auto* cl = makeTypespec(*vtaMem, tgtSyn);
                    bypassTypedefShare = false;
                    cl->VpiName(vtaMem->name);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(std::string(vtaMem->name));
                    art->VpiParent(cl);
                    art->Actual_typespec(vtaMemBase);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    // Only the DEF-view clone (tfContext build) carries
                    // Instance; the elab-view clone leaves it null (Surelog).
                    if (savedTf)
                        cl->Instance(vtaMemBase->Instance());
                    et->Actual_typespec(cl);
                }
            }
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        if (fts->VpiName().empty() && !ats9MainFree)
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        // ANONYMOUS structs (empty alias) name member refs bare, no
        // leading separator (struct_3d_packed_array).
        rt->VpiFullName(aliasName.empty()
                            ? std::string(fm.name)
                            : aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
        if (ats9CloneRefParent && fts->VpiName().empty())
            fts->VpiParent(rt);
        if (memberTypeSyn) {
            auto sr = memberTypeSyn->sourceRange();
            if (sr.start() != SourceLocation::NoLocation) {
                tm->VpiRefFile(fullFilePath(sr.start()));
                tm->VpiRefLineNo(sm->getLineNumber(sr.start()));
                tm->VpiRefColumnNo(sm->getColumnNumber(sr.start()));
                tm->VpiRefEndLineNo(sm->getLineNumber(sr.end()));
                tm->VpiRefEndColumnNo(sm->getColumnNumber(sr.end()));
            }
        }
        members->push_back(tm);
    }
    uts->Members(members);
    return uts;
}

// typedef of an unpacked array (typedef bar_t foobar_t [2]): a NAMED
// array_typespec spanning target-type..last-dim; a SIZE-form dim ([2]) folds
// to [0 : N-1 op] at the size token, a ranged dim keeps its bounds at their
// tokens (Surelog — mirrors the pkg-typedef form).  `qname` is the fullname
// this object's inner refs qualify with: the module-scoped name for the
// Typespecs LISTING, the bare typedef name for a return-value CLONE.
UHDM::array_typespec* UhdmExporter::buildUnpackedArrayTypedefTs(
    const TypeAliasType& ta, const std::string& qname, bool cloneForm) {
    const syntax::SyntaxNode* typeSyn = nullptr;
    if (auto syn = ta.getSyntax())
        if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
            typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
    auto& ct = ta.targetType.getType().getCanonicalType();
    auto& fua = ct.as<FixedSizeUnpackedArrayType>();
    auto* ats = s.MakeArray_typespec();
    SourceLocation aS = ta.location, aE = ta.location;
    if (typeSyn)
        aS = typeSyn->sourceRange().start();
    const syntax::VariableDimensionSyntax* dimSyn = nullptr;
    if (auto dsyn = ta.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
        auto& td = dsyn->as<syntax::TypedefDeclarationSyntax>();
        if (!td.dimensions.empty()) {
            dimSyn = td.dimensions[0];
            aE = td.dimensions[td.dimensions.size() - 1]->sourceRange().end();
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
        dimSyn->specifier->kind == syntax::SyntaxKind::RangeDimensionSpecifier) {
        auto& sel =
            *dimSyn->specifier->as<syntax::RangeDimensionSpecifierSyntax>().selector;
        if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
            lSyn = rss->left;
            rSyn = rss->right;
        }
        else if (auto* bss = sel.as_if<syntax::BitSelectSyntax>())
            szSyn = bss->expr;
    }
    auto mkB = [&](int64_t v, const syntax::SyntaxNode* bs) -> UHDM::expr* {
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
        // Size form: range at the size token, [0 : N-1 op] (the op located at
        // the size token; the 1 is a loc-less INT).
        setLoc(r, szSyn->sourceRange());
        r->Left_expr(mkB(0, nullptr));
        auto* op = s.MakeOperation();
        op->VpiOpType(vpiSubOp);
        op->VpiParent(r);
        setLoc(op, szSyn->sourceRange());
        auto* ops = s.MakeAnyVec();
        // A NAME-reference size ([CNT]) stays SYMBOLIC: a ref_obj scoped under
        // the typedef itself, and the synthetic 1 loses its parent (Surelog —
        // ArrayExprFuncArg/DefaultPattern*).  A literal size still folds —
        // and so does a size naming an IMPORTED (package) param, which
        // Surelog resolves through the import and reduces to the value at the
        // param's width with a ts ref to its home-package int typespec
        // (DefaultPatternInt).
        const ParameterSymbol* impP = nullptr;
        bool symSize = szSyn->kind == syntax::SyntaxKind::IdentifierName ||
                       szSyn->kind == syntax::SyntaxKind::ScopedName;
        if (symSize && szSyn->kind == syntax::SyntaxKind::IdentifierName)
            if (auto tsc = ta.getParentScope()) {
                std::string nm6(rawText(szSyn->sourceRange()));
                if (!tsc->find(nm6))
                    if (auto* f6 = tsc->lookupName(nm6);
                        f6 && f6->kind == SymbolKind::Parameter) {
                        impP = &f6->as<ParameterSymbol>();
                        symSize = false;
                    }
            }
        if (symSize) {
            auto* ro = s.MakeRef_obj();
            std::string idn(rawText(szSyn->sourceRange()));
            ro->VpiName(idn);
            ro->VpiFullName(qname + "." + idn);
            ro->VpiParent(op);
            setLoc(ro, szSyn->sourceRange());
            ops->push_back(ro);
        }
        else {
            auto* nC = mkB(fua.range.width(), szSyn);
            nC->VpiParent(op);
            if (impP) {
                ((UHDM::constant*)nC)
                    ->VpiSize((int32_t)impP->getType().getBitWidth());
                auto* rt6 = s.MakeRef_typespec();
                rt6->VpiFullName(qname);
                rt6->VpiParent(nC);
                auto* its6 = s.MakeInt_typespec();
                if (impP->getType().isSigned())
                    its6->VpiSigned(true);
                if (auto d6 = impP->getDeclaredType())
                    if (auto* t6 = d6->getTypeSyntax())
                        setLoc(its6, t6->sourceRange());
                its6->VpiParent(rt6);
                if (auto* hi6 = homePkgInstOf(*impP))
                    its6->Instance(hi6);
                rt6->Actual_typespec(its6);
                ((UHDM::constant*)nC)->Typespec(rt6);
            }
            ops->push_back(nC);
        }
        auto* one = s.MakeConstant();
        one->VpiSize(64);
        one->VpiValue("INT:1");
        one->VpiConstType(vpiIntConst);
        // Only the compile-time LISTING object leaves the synthetic 1
        // unparented; the elaborator-built clone parents it (Surelog).
        if (!symSize || cloneForm)
            one->VpiParent(op);
        ops->push_back(one);
        op->Operands(ops);
        r->Right_expr(op);
    }
    else {
        if (dimSyn)
            setLoc(r, dimSyn->sourceRange());
        // A CLASS-scope typedef keeps its bounds symbolic: the class body is
        // compiled once, so `[SIZE-1:0]` stays an operation over a ref to the
        // class's own formal (VirtualClass).
        if (unfoldedTypedefDims && lSyn && rSyn) {
            r->Left_expr((UHDM::expr*)emitSyntaxExpr(*lSyn, r));
            r->Right_expr((UHDM::expr*)emitSyntaxExpr(*rSyn, r));
        }
        else {
            r->Left_expr(mkB(fua.range.left, lSyn));
            r->Right_expr(mkB(fua.range.right, rSyn));
        }
    }
    rv->push_back(r);
    ats->Ranges(rv);
    // Elem ref -> the ELEMENT typedef's shared ts (typedef bar_t foobar_t [2]
    // points at bar_t's struct ts) — Surelog.
    {
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
        // A BUILT-IN element type (typedef int unsigned T[CNT]) has no typedef
        // ts to share: mint the element int_typespec at the target-type span.
        if (!ets0 && el0->getCanonicalType().kind ==
                         SymbolKind::PredefinedIntegerType && typeSyn) {
            auto* its0 = s.MakeInt_typespec();
            if (el0->isSigned())
                its0->VpiSigned(true);
            setLoc(its0, typeSyn->sourceRange());
            ets0 = its0;
        }
        // A PACKED element written INLINE (`typedef logic [1:0] T [7:0]`,
        // `typedef unit_t [0:4] U [7:8]`) has no typedef object to share
        // either, but Surelog compiles the written element type all the same:
        // a packed_array_typespec over the NAMED element typedef's shared
        // object when the packed dims sit on a typedef name, otherwise the
        // plain vector typespec of the built-in type. Both land parentless,
        // reachable only through the array's Elem ref (UnpackedTypespec).
        if (!ets0 && typeSyn) {
            auto& elc0 = el0->getCanonicalType();
            const Type* inner0 = elc0.kind == SymbolKind::PackedArrayType
                                     ? &elc0.as<PackedArrayType>().elementType
                                     : nullptr;
            UHDM::typespec* leaf0 = nullptr;
            if (inner0 && inner0->kind == SymbolKind::TypeAlias)
                if (auto li0 = typedefTs.find(
                        (const Symbol*)&inner0->as<TypeAliasType>());
                    li0 != typedefTs.end())
                    leaf0 = li0->second;
            if (leaf0) {
                auto* pts0 = s.MakePacked_array_typespec();
                setLoc(pts0, typeSyn->sourceRange());
                auto spans0 =
                    scanDimSpans(std::string(rawText(typeSyn->sourceRange())),
                                 typeSyn->sourceRange().start());
                auto* pr0 = s.MakeRange();
                pr0->VpiParent(pts0);
                if (!spans0.empty())
                    setLoc(pr0, spans0[0].range);
                auto mkP = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string dg = std::to_string(v);
                    c->VpiDecompile(dg);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + dg);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(pr0);
                    if (loc)
                        setLoc(c, *loc);
                    return c;
                };
                auto& pa0 = elc0.as<PackedArrayType>();
                pr0->Left_expr(
                    mkP(pa0.range.left, spans0.empty() ? nullptr : &spans0[0].left));
                pr0->Right_expr(
                    mkP(pa0.range.right, spans0.empty() ? nullptr : &spans0[0].right));
                auto* prv0 = s.MakeRangeVec();
                prv0->push_back(pr0);
                pts0->Ranges(prv0);
                auto* irt0 = s.MakeRef_typespec();
                irt0->VpiParent(pts0);
                irt0->Actual_typespec(leaf0);
                pts0->Elem_typespec(irt0);
                ets0 = pts0;
            }
            else
                ets0 = anonAggregateElemTs(*el0, typeSyn);
        }
        if (ets0) {
            // A STRUCT element points at a fresh NAMED clone with a
            // BARE-scoped member tree and a Typedef_alias ref to the
            // shared ts (Surelog); other elements share directly.
            UHDM::typespec* tgt0 = ets0;
            if (el0->kind == SymbolKind::TypeAlias &&
                el0->getCanonicalType().isStruct() &&
                ets0->UhdmType() == UHDM::uhdmstruct_typespec) {
                auto& ela = el0->as<TypeAliasType>();
                auto& elc = el0->getCanonicalType();
                UHDM::struct_typespec* cl0 =
                    elc.kind == SymbolKind::PackedStructType
                        ? buildStructTs(elc.as<PackedStructType>(), true,
                                        std::string(ela.name))
                        : buildStructTs(elc.as<UnpackedStructType>(), false,
                                        std::string(ela.name));
                cl0->VpiName(ela.name);
                cl0->VpiLineNo(ets0->VpiLineNo());
                cl0->VpiColumnNo(ets0->VpiColumnNo());
                cl0->VpiEndLineNo(ets0->VpiEndLineNo());
                cl0->VpiEndColumnNo(ets0->VpiEndColumnNo());
                auto* art0 = s.MakeRef_typespec();
                art0->VpiFullName(std::string(ela.name));
                art0->VpiParent(cl0);
                art0->Actual_typespec(ets0);
                cl0->Typedef_alias(art0);
                tgt0 = cl0;
            }
            auto* ert = s.MakeRef_typespec();
            ert->VpiFullName(qname);
            ert->VpiParent(ats);
            ert->Actual_typespec(tgt0);
            ats->Elem_typespec(ert);
            // A clone's freshly-minted element ts parents at its ref.
            if (cloneForm && !tgt0->VpiParent() && !tgt0->VpiName().length())
                tgt0->VpiParent(ert);
        }
    }
    return ats;
}

// Copy a range vector object-for-object (bounds that are not plain constants
// are shared — only their VALUES are compared).
static UHDM::VectorOfrange* copyRangeVec(UHDM::Serializer& s,
                                         const UHDM::VectorOfrange* src,
                                         UHDM::any* parent) {
    if (!src)
        return nullptr;
    auto* rv = s.MakeRangeVec();
    for (auto* r0 : *src) {
        auto* r = s.MakeRange();
        r->VpiParent(parent);
        r->VpiFile(r0->VpiFile());
        r->VpiLineNo(r0->VpiLineNo());
        r->VpiColumnNo(r0->VpiColumnNo());
        r->VpiEndLineNo(r0->VpiEndLineNo());
        r->VpiEndColumnNo(r0->VpiEndColumnNo());
        auto cpB = [&](const UHDM::expr* b) -> UHDM::expr* {
            if (!b || b->UhdmType() != UHDM::uhdmconstant)
                return (UHDM::expr*)b;
            auto* c0 = (const UHDM::constant*)b;
            auto* c = s.MakeConstant();
            c->VpiDecompile(c0->VpiDecompile());
            c->VpiSize(c0->VpiSize());
            c->VpiValue(c0->VpiValue());
            c->VpiConstType(c0->VpiConstType());
            c->VpiParent(r);
            c->VpiFile(c0->VpiFile());
            c->VpiLineNo(c0->VpiLineNo());
            c->VpiColumnNo(c0->VpiColumnNo());
            c->VpiEndLineNo(c0->VpiEndLineNo());
            c->VpiEndColumnNo(c0->VpiEndColumnNo());
            return c;
        };
        r->Left_expr(cpB(r0->Left_expr()));
        r->Right_expr(cpB(r0->Right_expr()));
        rv->push_back(r);
    }
    return rv;
}

// A leaf typespec Surelog re-mints inside a per-reference typedef copy: same
// class, span and signedness, no children beyond a vector's ranges.
// Aggregates (enum/struct/union) have no cheap copy — the caller shares those,
// which compares equal because uhdm-cmp never tests object identity.
static UHDM::typespec* freshLeafTsCopy(UHDM::Serializer& s,
                                       const UHDM::typespec* src) {
    if (!src || !src->VpiName().empty())
        return nullptr;
    UHDM::typespec* out = nullptr;
    switch (src->UhdmType()) {
        case UHDM::uhdmint_typespec:
            out = s.MakeInt_typespec();
            break;
        case UHDM::uhdminteger_typespec:
            out = s.MakeInteger_typespec();
            break;
        case UHDM::uhdmshort_int_typespec:
            out = s.MakeShort_int_typespec();
            break;
        case UHDM::uhdmlong_int_typespec:
            out = s.MakeLong_int_typespec();
            break;
        case UHDM::uhdmbyte_typespec:
            out = s.MakeByte_typespec();
            break;
        case UHDM::uhdmtime_typespec:
            out = s.MakeTime_typespec();
            break;
        case UHDM::uhdmreal_typespec:
            out = s.MakeReal_typespec();
            break;
        case UHDM::uhdmshort_real_typespec:
            out = s.MakeShort_real_typespec();
            break;
        case UHDM::uhdmstring_typespec:
            out = s.MakeString_typespec();
            break;
        case UHDM::uhdmlogic_typespec:
            out = s.MakeLogic_typespec();
            break;
        case UHDM::uhdmbit_typespec:
            out = s.MakeBit_typespec();
            break;
        default:
            return nullptr;
    }
    out->VpiFile(src->VpiFile());
    out->VpiLineNo(src->VpiLineNo());
    out->VpiColumnNo(src->VpiColumnNo());
    out->VpiEndLineNo(src->VpiEndLineNo());
    out->VpiEndColumnNo(src->VpiEndColumnNo());
    if (src->UhdmType() == UHDM::uhdmint_typespec)
        ((UHDM::int_typespec*)out)
            ->VpiSigned(((const UHDM::int_typespec*)src)->VpiSigned());
    if (auto* lt = out->Cast<UHDM::logic_typespec*>()) {
        auto* l0 = (const UHDM::logic_typespec*)src;
        lt->VpiSigned(l0->VpiSigned());
        lt->Ranges(copyRangeVec(
            s, ((UHDM::logic_typespec*)l0)->Ranges(), lt));
    }
    else if (auto* bt = out->Cast<UHDM::bit_typespec*>()) {
        auto* b0 = (const UHDM::bit_typespec*)src;
        bt->VpiSigned(b0->VpiSigned());
        bt->Ranges(copyRangeVec(s, ((UHDM::bit_typespec*)b0)->Ranges(), bt));
    }
    return out;
}

UHDM::array_typespec* UhdmExporter::copyArrayTypedefTs(
    const UHDM::array_typespec* src, const std::string& bareName,
    bool keepInstance, bool withAlias) {
    auto* cp = s.MakeArray_typespec();
    cp->VpiName(bareName);
    cp->VpiFile(src->VpiFile());
    cp->VpiLineNo(src->VpiLineNo());
    cp->VpiColumnNo(src->VpiColumnNo());
    cp->VpiEndLineNo(src->VpiEndLineNo());
    cp->VpiEndColumnNo(src->VpiEndColumnNo());
    cp->VpiArrayType(src->VpiArrayType());
    if (keepInstance)
        cp->Instance(((UHDM::array_typespec*)src)->Instance());
    if (withAlias) {
        auto* art = s.MakeRef_typespec();
        art->VpiFullName(bareName);
        art->VpiParent(cp);
        art->Actual_typespec((UHDM::typespec*)src);
        cp->Typedef_alias(art);
    }
    if (auto* rv = copyRangeVec(s, ((UHDM::array_typespec*)src)->Ranges(), cp))
        cp->Ranges(rv);
    if (auto* er = ((UHDM::array_typespec*)src)->Elem_typespec()) {
        auto* ert = s.MakeRef_typespec();
        ert->VpiFullName(bareName);
        ert->VpiParent(cp);
        auto* act = er->Actual_typespec();
        if (auto* fresh = freshLeafTsCopy(s, act)) {
            fresh->VpiParent(ert);
            ert->Actual_typespec(fresh);
        }
        else
            ert->Actual_typespec(act);
        cp->Elem_typespec(ert);
    }
    return cp;
}

// Typedefs (enums, packed structs): module Typespecs entries compiled at
// module compile, shared by both views and by all declarations.
void UhdmExporter::emitTypedefs(const InstanceBodySymbol& body, UHDM::instance* m,
                                const std::string& prefix, DefInfo& info) {
    auto* tds = s.MakeTypespecVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax()) {
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        }
        UHDM::typespec* ts = nullptr;
        if (ct.kind == SymbolKind::EnumType) {
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn,
                                    prefix + "." + std::string(ta.name));
            ets->VpiParent(m);
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            ts = ets;
        }
        else if (ct.kind == SymbolKind::PackedStructType) {
            // A struct whose variable is assigned WHOLE — cont-assigned
            // (assign c = ... / assign b = c) or declared with an initializer
            // (hw2reg_wrap_t w = {c, d}) — is netlist-recompiled: BARE member
            // refs, no module parent. Member-only or $bits-only uses keep the
            // module-prefixed refs + module parent (alert_rx_t / dmi_t /
            // EnumWidth's bar_t), regardless of nested typedef members.
            bool wholeAssigned = false;
            // The netlist recompile is scope-blind: a cont-assign inside a
            // GENERATE block counts exactly as a module-level one (FuncAlias
            // assigns `inst1` whole from `GEN1`), so walk the generate tree
            // as well as the body's own members.
            std::function<void(const Scope&)> scanCa2 = [&](const Scope& sc0) {
                for (auto& mb2 : sc0.members()) {
                    if (mb2.kind == SymbolKind::GenerateBlock ||
                        mb2.kind == SymbolKind::GenerateBlockArray) {
                        scanCa2(mb2.as<Scope>());
                        continue;
                    }
                    if (mb2.kind != SymbolKind::ContinuousAssign)
                        continue;
                    auto& as2 = mb2.as<ContinuousAssignSymbol>().getAssignment();
                    if (as2.kind != ExpressionKind::Assignment)
                        continue;
                    auto& ae2 = as2.as<AssignmentExpression>();
                    for (auto* side : {&ae2.left(), &ae2.right()}) {
                        auto& sc2 = stripImplicitConv(*side);
                        if (sc2.kind == ExpressionKind::NamedValue &&
                            &sc2.as<NamedValueExpression>()
                                    .symbol.getType()
                                    .getCanonicalType() == &ct)
                            wholeAssigned = true;
                    }
                }
            };
            scanCa2(body);
            bool bareRefs = wholeAssigned;
            // The def-net typespec drop applies only to structs with NO
            // nested UNION member (UnionInsideStruct's bar_t keeps its ts).
            bool hasUnionMember = false;
            for (auto& fm : ct.as<PackedStructType>().members()) {
                if (fm.kind != SymbolKind::Field)
                    continue;
                if (fm.as<FieldSymbol>().getType().getCanonicalType().kind ==
                    SymbolKind::PackedUnionType)
                    hasUnionMember = true;
            }
            if (!bareRefs && !hasUnionMember)
                modulePrefixedStructs.insert(&ct);
            std::string alias = bareRefs ? std::string(ta.name)
                                         : prefix + "." + std::string(ta.name);
            auto* sts = buildStructTs(ct.as<PackedStructType>(), true, alias);
            if (!bareRefs)
                sts->VpiParent(m);
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            // An UNPACKED-ARRAY signal of this typedef (tl_h2d_t a[1:0])
            // stretches the typespec end to that declarator's FIRST unpacked
            // dimension (Surelog re-stamps the shared object; last use wins).
            if (auto e9 = structTypedefUseEnd(body, ta);
                e9 != SourceLocation::NoLocation) {
                sts->VpiEndLineNo((uint32_t)sm->getLineNumber(e9));
                sts->VpiEndColumnNo((uint32_t)sm->getColumnNumber(e9));
            }
            ts = sts;
        }
        else if (ct.kind == SymbolKind::UnpackedStructType) {
            // Unpacked structs: module parent + module-scoped member refs.
            auto* sts = buildStructTs(ct.as<UnpackedStructType>(), false,
                                      prefix + "." + std::string(ta.name));
            sts->VpiParent(m);
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            ts = sts;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
            auto* ats = buildUnpackedArrayTypedefTs(
                ta, prefix + "." + std::string(ta.name));
            ats->VpiParent(m);
            ts = ats;
        }
        else if (ct.kind == SymbolKind::PackedUnionType) {
            // Packed unions mirror packed structs: WHOLE-assigned unions keep
            // BARE member refs; member-only uses take module-prefixed refs.
            bool uWhole = false;
            for (auto& mb2 : body.members()) {
                if (mb2.kind != SymbolKind::ContinuousAssign)
                    continue;
                auto& as2 = mb2.as<ContinuousAssignSymbol>().getAssignment();
                if (as2.kind != ExpressionKind::Assignment)
                    continue;
                auto& ae2 = as2.as<AssignmentExpression>();
                for (auto* side : {&ae2.left(), &ae2.right()}) {
                    auto& sc2 = stripImplicitConv(*side);
                    if (sc2.kind == ExpressionKind::NamedValue &&
                        &sc2.as<NamedValueExpression>()
                                .symbol.getType()
                                .getCanonicalType() == &ct)
                        uWhole = true;
                }
            }
            auto* uts = buildUnionTs(ct.as<PackedUnionType>(), true,
                                     uWhole ? std::string(ta.name)
                                            : prefix + "." + std::string(ta.name));
            uts->VpiParent(m);
            if (typeSyn)
                setLoc(uts, typeSyn->sourceRange());
            ts = uts;
        }
        else if (ct.kind == SymbolKind::PackedArrayType &&
                 [&] {
                     const Type* lf = &ct;
                     while (lf->getCanonicalType().kind == SymbolKind::PackedArrayType)
                         lf = &lf->getCanonicalType().as<PackedArrayType>().elementType;
                     return lf->getCanonicalType().kind == SymbolKind::PackedStructType ||
                            lf->getCanonicalType().kind == SymbolKind::EnumType;
                 }()) {
            // A packed array over a packed struct (struct packed {...} [31:0]
            // T) or an ENUM (typedef u[0:1] crash): a NAMED packed_array_typespec
            // whose Elem_typespec is a fresh struct_typespec / enum_typespec.
            std::string alias = prefix + "." + std::string(ta.name);
            const Type* leaf = &ct;
            int arrDims = 0;
            while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
                arrDims++;
                leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
                // A NAMED typedef element ENDS the dim walk: Surelog keeps the
                // written nesting rather than flattening through the alias, so
                // `typedef fmt_t [0:1] opgrp_t` is ONE range over the fmt_t
                // object, not two ranges over fmt_t's own enum leaf
                // (UnpackedTypespec).
                if (leaf->kind == SymbolKind::TypeAlias &&
                    typedefTs.count((const Symbol*)&leaf->as<TypeAliasType>()))
                    break;
            }
            bool enumLeaf =
                leaf->getCanonicalType().kind == SymbolKind::EnumType;
            // A shared PACKED-ARRAY leaf (alias-of-alias) names the array like
            // an enum leaf does.
            bool arrLeaf =
                leaf->getCanonicalType().kind == SymbolKind::PackedArrayType;
            std::string ename =
                leaf->kind == SymbolKind::TypeAlias ? std::string(leaf->name) : "";
            const syntax::SyntaxNode* esyn = leaf->getCanonicalType().getSyntax();
            // An enum leaf that IS a named typedef in this scope SHARES the
            // typedef's enum object (elem ref fullname = the outer alias's
            // BARE name) — Surelog.
            UHDM::typespec* sts = nullptr;
            bool sharedEnumLeaf = false;
            if (leaf->kind == SymbolKind::TypeAlias)
                if (auto sIt = typedefTs.find(
                        (const Symbol*)&leaf->as<TypeAliasType>());
                    sIt != typedefTs.end()) {
                    // A STRUCT leaf that is a named typedef shares its
                    // struct object too (Surelog).
                    sts = sIt->second;
                    sharedEnumLeaf = true;
                }
            if (!sts)
                sts = enumLeaf
                          ? (UHDM::typespec*)buildEnumTs(
                                leaf->getCanonicalType().as<EnumType>(), esyn,
                                ename)
                          : (UHDM::typespec*)buildStructTs(
                                leaf->getCanonicalType().as<PackedStructType>(),
                                true, alias);
            // A SHARED (named-typedef) struct leaf is NOT re-located or
            // re-parented by the array typedef — it keeps its own typedef
            // span and members (CastStructArray). Only a freshly built
            // (anonymous) leaf takes the array typedef's spans.
            bool sharedStructLeaf = sharedEnumLeaf && !enumLeaf;
            if (enumLeaf && !sharedEnumLeaf) {
                sts->VpiName(ename);
                if (esyn)
                    setLoc(sts, esyn->sourceRange());
            }
            // struct_typespec loc = the `struct` keyword token.
            else if (!enumLeaf && typeSyn && !sharedStructLeaf)
                setLoc(sts, typeSyn->getFirstToken().range());
            auto* pat = s.MakePacked_array_typespec();
            pat->VpiParent(m);
            if (enumLeaf || arrLeaf)
                pat->VpiName(ta.name);
            if (typeSyn)
                setLoc(pat, typeSyn->sourceRange());
            // One range per packed dim (bounds 64-bit UINT; loc from the dim
            // brackets scanned between the struct body and the declarator).
            std::vector<ConstantRange> arrRanges;
            {
                const Type* t2 = &ct;
                for (int i = 0; i < arrDims; i++) {
                    arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
                    t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
                }
            }
            std::vector<DimSpan> spans;
            if (typeSyn) {
                auto full = typeSyn->sourceRange();
                spans = scanDimSpans(std::string(rawText(full)), full.start());
            }
            auto* rvec = s.MakeRangeVec();
            for (int i = 0; i < arrDims; i++) {
                auto* r = s.MakeRange();
                r->VpiParent(pat);
                const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
                if (ds)
                    setLoc(r, ds->range);
                auto mkB = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string digits = std::to_string(v);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r);
                    if (loc)
                        setLoc(c, *loc);
                    return c;
                };
                r->Left_expr(mkB(arrRanges[i].left, ds ? &ds->left : nullptr));
                r->Right_expr(mkB(arrRanges[i].right, ds ? &ds->right : nullptr));
                rvec->push_back(r);
            }
            pat->Ranges(rvec);
            auto* ert = s.MakeRef_typespec();
            ert->VpiParent(pat);
            ert->VpiFullName(sharedEnumLeaf && !sharedStructLeaf
                                 ? std::string(ta.name)
                                 : alias);
            ert->Actual_typespec(sts);
            pat->Elem_typespec(ert);
            // Surelog re-parents the struct's members to the ARRAY typespec.
            if (!enumLeaf && !sharedStructLeaf &&
                ((UHDM::struct_typespec*)sts)->Members())
                for (auto* tm : *((UHDM::struct_typespec*)sts)->Members())
                    tm->VpiParent(pat);
            ts = pat;
        }
        else if ((ct.kind == SymbolKind::PackedArrayType ||
                  ct.kind == SymbolKind::ScalarType) &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias &&
                 typedefTs.count(&ta.targetType.getType()) &&
                 typedefTs[&ta.targetType.getType()]->UhdmType() ==
                     UHDM::uhdmlogic_typespec) {
            // A typedef ALIAS of another vector typedef (typedef int8_t
            // char_t): a NAMED clone at the TARGET typedef's type span with
            // its ranges and a Typedef_alias ref to the target's shared ts.
            auto& tgt = ta.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgtSyn = nullptr;
            if (auto asyn = tgt.getSyntax())
                if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                    tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
            bypassTypedefShare = true;
            auto* cl = makeTypespec(tgt, tgtSyn);
            bypassTypedefShare = false;
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(prefix + "." + std::string(ta.name));
            art->VpiParent(cl);
            art->Actual_typespec(typedefTs[&ta.targetType.getType()]);
            ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
            cl->VpiParent(m);
            ts = cl;
        }
        else if (ct.kind == SymbolKind::PackedArrayType ||
                 ct.kind == SymbolKind::ScalarType) {
            // Vector/scalar typedefs: a NAMED logic_typespec at the target
            // type syntax, module parent + Instance. Typedef ranges keep
            // param/$bits-dependent bounds UNFOLDED (typedef context).
            bypassTypedefShare = true;
            bool savedTf = tfContext;
            tfContext = true;
            typedefTsContext = true;
            auto* lts = makeTypespec(ta, typeSyn);
            typedefTsContext = false;
            tfContext = savedTf;
            bypassTypedefShare = false;
            // A module vector typedef used by a NET declaration (wire
            // typename x) carries only Instance, no VpiParent (net_types);
            // var/function-typed typedefs keep the module parent.
            bool netUse9 = false;
            for (auto& nm9 : body.members())
                if (nm9.kind == SymbolKind::Net)
                    if (auto* nd9 = nm9.getDeclaredType();
                        nd9 && &nd9->getType() == &ta) {
                        netUse9 = true;
                        break;
                    }
            if (!netUse9)
                lts->VpiParent(m);
            typedefClone[&ta] = nullptr;
            ts = lts;
        }
        else {
            noteUnsupported("typedef target: " + std::string(toString(ct.kind)));
            continue;
        }
        ts->VpiName(ta.name);
        ((UHDM::typespec*)ts)->Instance(m);
        typedefTs[&ta] = ts;
        info.typedefs.push_back(ts);
        tds->push_back(ts);
    }
    // A struct typedef referenced from another typedef's member gets
    // module parent and module-scoped member ref fullnames.
    for (auto* td : *tds) {
        if (td->UhdmType() != UHDM::uhdmstruct_typespec)
            continue;
        auto* sts = (UHDM::struct_typespec*)td;
        if (!sts->Members())
            continue;
        for (auto* tm : *sts->Members()) {
            if (!tm->Typespec() || !tm->Typespec()->Actual_typespec())
                continue;
            auto* target = tm->Typespec()->Actual_typespec();
            if (target->UhdmType() != UHDM::uhdmstruct_typespec || target->VpiParent())
                continue;
            auto* tsts = (UHDM::struct_typespec*)target;
            bool ours = false;
            for (auto* other : *tds)
                if (other == target)
                    ours = true;
            if (!ours)
                continue;
            tsts->VpiParent(m);
            if (tsts->Members()) {
                for (auto* mm : *tsts->Members()) {
                    if (mm->Typespec())
                        mm->Typespec()->VpiFullName(prefix + "." +
                                                    std::string(tsts->VpiName()) + "." +
                                                    std::string(mm->VpiName()));
                }
            }
        }
    }
    if (!tds->empty()) {
        // Surelog lists module typedefs NAME-SORTED (its typespec registry
        // is a name-keyed map), not in declaration order.
        std::stable_sort(tds->begin(), tds->end(),
                         [](const UHDM::typespec* a, const UHDM::typespec* b) {
                             return a->VpiName() < b->VpiName();
                         });
        m->Typespecs(tds);
    }
}

// Maps binary expression syntax kinds to vpi op codes (range-bound exprs).
static int32_t mapSyntaxUnaryOp(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::UnaryLogicalNotExpression:
            return vpiNotOp;
        case syntax::SyntaxKind::UnaryBitwiseNotExpression:
            return vpiBitNegOp;
        case syntax::SyntaxKind::UnaryMinusExpression:
            return vpiMinusOp;
        case syntax::SyntaxKind::UnaryPlusExpression:
            return vpiPlusOp;
        // Reduction operators (mriscv ALU: is_rd_nr & (&is_rd_reg)).
        case syntax::SyntaxKind::UnaryBitwiseAndExpression:
            return vpiUnaryAndOp;
        case syntax::SyntaxKind::UnaryBitwiseNandExpression:
            return vpiUnaryNandOp;
        case syntax::SyntaxKind::UnaryBitwiseOrExpression:
            return vpiUnaryOrOp;
        case syntax::SyntaxKind::UnaryBitwiseNorExpression:
            return vpiUnaryNorOp;
        case syntax::SyntaxKind::UnaryBitwiseXorExpression:
            return vpiUnaryXorOp;
        case syntax::SyntaxKind::UnaryBitwiseXnorExpression:
            return vpiUnaryXNorOp;
        default:
            return 0;
    }
}

static int32_t mapSyntaxBinOp(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::AddExpression:
            return vpiAddOp;
        case syntax::SyntaxKind::SubtractExpression:
            return vpiSubOp;
        case syntax::SyntaxKind::MultiplyExpression:
            return vpiMultOp;
        case syntax::SyntaxKind::DivideExpression:
            return vpiDivOp;
        case syntax::SyntaxKind::ModExpression:
            return vpiModOp;
        case syntax::SyntaxKind::LogicalShiftLeftExpression:
            return vpiLShiftOp;
        case syntax::SyntaxKind::LogicalShiftRightExpression:
            return vpiRShiftOp;
        // Arithmetic shifts (rp32_r5p_alu gen_shf `$signed(shf_ext) >>>
        // shf_amm` in a def-view gen-block cont_assign): without these the
        // whole RHS operand vanished from the def view.
        case syntax::SyntaxKind::ArithmeticShiftLeftExpression:
            return vpiArithLShiftOp;
        case syntax::SyntaxKind::ArithmeticShiftRightExpression:
            return vpiArithRShiftOp;
        case syntax::SyntaxKind::PowerExpression:
            return vpiPowerOp;
        case syntax::SyntaxKind::GreaterThanExpression:
            return vpiGtOp;
        case syntax::SyntaxKind::GreaterThanEqualExpression:
            return vpiGeOp;
        case syntax::SyntaxKind::LessThanExpression:
            return vpiLtOp;
        case syntax::SyntaxKind::LessThanEqualExpression:
            return vpiLeOp;
        case syntax::SyntaxKind::EqualityExpression:
            return vpiEqOp;
        case syntax::SyntaxKind::InequalityExpression:
            return vpiNeqOp;
        case syntax::SyntaxKind::WildcardEqualityExpression:
            return 69; // vpiWildEqOp
        case syntax::SyntaxKind::WildcardInequalityExpression:
            return 70; // vpiWildNeqOp
        case syntax::SyntaxKind::LogicalAndExpression:
            return vpiLogAndOp;
        case syntax::SyntaxKind::LogicalOrExpression:
            return vpiLogOrOp;
        case syntax::SyntaxKind::BinaryAndExpression:
            return vpiBitAndOp;
        case syntax::SyntaxKind::BinaryOrExpression:
            return vpiBitOrOp;
        case syntax::SyntaxKind::BinaryXorExpression:
            return vpiBitXorOp;
        default:
            return 0;
    }
}

UHDM::any* UhdmExporter::emitSyntaxExpr(const syntax::SyntaxNode& syn, UHDM::BaseClass* parent) {
    switch (syn.kind) {
        case syntax::SyntaxKind::IdentifierName: {
            auto name = syn.as<syntax::IdentifierNameSyntax>().identifier.valueText();
            // § unitRefSubst — inside an UNFOLDED $unit parameter init, a
            // reference to another $unit parameter of the SAME ROOT FILE is
            // not a reference in the golden at all: Surelog's reducer had
            // that parameter's value in hand and SPLICED it, keeping the
            // USE SITE's span and typing the spliced node with the
            // SUBSTITUTED parameter's typespec.  Measured on Scr1SvTests
            // scr1_tdu.svh (probe r10scr8pa, 5 of 957 design param_assign
            // tree rows):
            //   SCR1_TDU_ALLTRIG_NUM = SCR1_TDU_MTRIG_NUM + 1'b1
            //     -> ref_obj(SCR1_TDU_TRIG_NUM)@20:58, ts int_typespec@18:11
            //        (MTRIG_NUM is itself unfolded — its whole tree is
            //         spliced VERBATIM, with no second reduction pass, which
            //         is why TRIG_NUM survives as a name)
            //   SCR1_CSR_ADDR_TDU_TSELECT = ..._MBASE + ..._OFFS_TSELECT
            //     -> constant{HEX:0,sz=3,'h0}@36:101, ts bit_typespec@30:11
            // A reference reaching ANOTHER root file (`..._MBASE`, in
            // scr1_csr.svh) is one the reducer never resolved, so it stays a
            // dangling ref_obj — the same root-file test that decided the
            // init was unfoldable in the first place.
            if (unitSubstScope) {
                if (auto* usym9 = unitSubstScope->lookupName(name)) {
                    auto rit9 = unitParamRhs.find(usym9);
                    if (rit9 != unitParamRhs.end() && rit9->second &&
                        rootFilePath(usym9->location) == unitSubstRoot) {
                        if (auto* cl9 =
                                cloneUnitParamRhs(rit9->second, parent)) {
                            setLoc(cl9, syn.sourceRange());
                            auto pit9 = unitParamMap.find(usym9);
                            if (pit9 != unitParamMap.end() &&
                                pit9->second->Typespec()) {
                                auto* rt9 = s.MakeRef_typespec();
                                rt9->VpiParent(cl9);
                                cl9->Typespec(rt9);
                                pendingUnitSubstTs.push_back({rt9, usym9});
                            }
                            return cl9;
                        }
                    }
                }
            }
            // Inside a property DECLARATION, an identifier naming one of the
            // formals takes the formal-ref path — the ref binds the implicit
            // module wire Surelog leaks the formal into.  The assertion
            // walker only calls emitPropFormalRef for a BARE identifier, so a
            // formal reached through a compound syntax expression (a
            // repetition count `[*n-1]`) arrived here unbound (OneDivider).
            if (propDeclScope)
                if (auto* pfr = emitPropFormalRef(
                        name, syn.sourceRange(), parent,
                        syntaxRefPrefix.empty() ? propDeclRefPrefix
                                                : syntaxRefPrefix))
                    return pfr;
            // A module param identifier inside an elaborated GEN-BLOCK
            // function's type bound folds to its value (matching the ExprEmit
            // fold) — the gen block is a concrete instance. genBlockFnScope is
            // set off declSymbol in makeTypespec, so this works in the deferred
            // typespec drain where currentSubSym is null.
            if (genBlockFnScope) {
                {
                    ASTContext bctx(*genBlockFnScope, LookupLocation::max);
                    auto& be = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                                bctx);
                    if (!be.bad() && stripImplicitConv(be).kind ==
                                         ExpressionKind::NamedValue) {
                        auto& psy =
                            stripImplicitConv(be).as<NamedValueExpression>().symbol;
                        if (psy.kind == SymbolKind::Parameter) {
                            auto& cv = psy.as<ParameterSymbol>().getValue();
                            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                                auto* c = s.MakeConstant();
                                std::string digits = cv.integer().toString(
                                    LiteralBase::Decimal, false);
                                c->VpiDecompile(digits);
                                c->VpiSize((int32_t)psy.as<ParameterSymbol>()
                                               .getType()
                                               .getBitWidth());
                                c->VpiValue("UINT:" + digits);
                                c->VpiConstType(vpiUIntConst);
                                c->VpiParent(parent);
                                setLoc(c, syn.sourceRange());
                                // SL carries the folded param's type as a
                                // ref_typespec (no fullname in type context).
                                auto* its = s.MakeInt_typespec();
                                if (auto dt = psy.getDeclaredType())
                                    if (auto tsy = dt->getTypeSyntax())
                                        setLoc(its, tsy->sourceRange());
                                auto* rt = s.MakeRef_typespec();
                                rt->VpiParent(c);
                                rt->Actual_typespec(its);
                                c->Typespec(rt);
                                return c;
                            }
                        }
                    }
                }
            }
            // A DEF-view net/var range bound referencing an IMPORTED PACKAGE
            // parameter is already constant when the module def is compiled:
            // Surelog folds it to the value, carrying a bare ref to a clone of
            // the parameter's own typespec (cs_registers PMP_MAX_REGIONS-1).
            // MODULE params stay symbolic (they are overridable).
            if (defNetTsScope) {
                ASTContext dctx(*defNetTsScope, LookupLocation::max);
                auto& de = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                            dctx);
                if (!de.bad() && stripImplicitConv(de).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& dsy =
                        stripImplicitConv(de).as<NamedValueExpression>().symbol;
                    if (dsy.kind == SymbolKind::Parameter && dsy.getParentScope() &&
                        dsy.getParentScope()->asSymbol().kind ==
                            SymbolKind::Package) {
                        auto& dp = dsy.as<ParameterSymbol>();
                        auto& dcv = dp.getValue();
                        if (dcv.isInteger() && !dcv.integer().hasUnknown()) {
                            auto* c = s.MakeConstant();
                            std::string digits =
                                dcv.integer().toString(LiteralBase::Decimal, false);
                            c->VpiDecompile(digits);
                            c->VpiSize((int32_t)dp.getType().getBitWidth());
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(parent);
                            setLoc(c, syn.sourceRange());
                            // The ts ref binds the PACKAGE parameter's OWN
                            // typespec (it already carries vpiInstance = the
                            // package); only mint a clone when the package
                            // parameter object is not around.
                            UHDM::typespec* its = nullptr;
                            if (auto poit = pkgParamObj.find(&dsy);
                                poit != pkgParamObj.end() &&
                                poit->second->Typespec())
                                its = poit->second->Typespec()
                                          ->Actual_typespec();
                            if (!its) {
                                auto* its0 = s.MakeInt_typespec();
                                if (dp.getType().isSigned())
                                    its0->VpiSigned(true);
                                if (auto dt = dp.getDeclaredType())
                                    if (auto tsy = dt->getTypeSyntax())
                                        setLoc(its0, tsy->sourceRange());
                                its = its0;
                            }
                            auto* rt = s.MakeRef_typespec();
                            rt->VpiParent(c);
                            rt->Actual_typespec(its);
                            c->Typespec(rt);
                            return c;
                        }
                    }
                }
            }
            // A GENERATE CONDITION in the module DEF view reading a
            // MATERIALIZED IMPORT copy of a package parameter folds to that
            // copy's value: the module def compile already resolved the
            // import, so the reference never survives. The constant is sized
            // at the parameter's own type width and carries a ts ref
            // (fullname = the module) to the COPY's typespec, exactly like
            // the def-view net/var range bound above.
            // HierPathStructTypespec `!= MsgFifoDepthW+1`.
            if (genCondImportFold9 && currentScope && !defModImportParam.empty()) {
                ASTContext gctx(*currentScope, LookupLocation::max);
                auto& ge = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                            gctx);
                if (!ge.bad() && stripImplicitConv(ge).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& gsy = stripImplicitConv(ge)
                                    .as<NamedValueExpression>()
                                    .symbol;
                    auto git = defModImportParam.find(&gsy);
                    if (git != defModImportParam.end() &&
                        gsy.kind == SymbolKind::Parameter) {
                        auto& gp = gsy.as<ParameterSymbol>();
                        auto& gcv = gp.getValue();
                        if (gcv.isInteger() && !gcv.integer().hasUnknown()) {
                            auto* c = s.MakeConstant();
                            std::string digits = gcv.integer().toString(
                                LiteralBase::Decimal, false);
                            c->VpiDecompile(digits);
                            c->VpiSize((int32_t)gp.getType().getBitWidth());
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(parent);
                            setLoc(c, syn.sourceRange());
                            auto* rt = s.MakeRef_typespec();
                            rt->VpiFullName(syntaxRefPrefix);
                            rt->VpiParent(c);
                            if (git->second->Typespec())
                                rt->Actual_typespec(
                                    git->second->Typespec()->Actual_typespec());
                            c->Typespec(rt);
                            return c;
                        }
                    }
                }
            }
            auto* ref = s.MakeRef_obj();
            ref->VpiName(name);
            if (!syntaxRefPrefix.empty())
                ref->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(name));
            ref->VpiParent(parent);
            setLoc(ref, syn.sourceRange());
            // Inside a package function's return/arg TYPE range (logic
            // [PARAM-1:0]), a reference to a package parameter binds to that
            // param's def-init constant (Surelog value-ref chaining), not left
            // dangling.
            if (tfTypeScope && !ref->Actual_group()) {
                ASTContext tctx(*tfTypeScope, LookupLocation::max);
                auto& be = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                            tctx);
                if (!be.bad() && stripImplicitConv(be).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& psy =
                        stripImplicitConv(be).as<NamedValueExpression>().symbol;
                    if (psy.kind == SymbolKind::Parameter) {
                        if (auto pit = pkgParamConst.find(&psy);
                            pit != pkgParamConst.end())
                            ref->Actual_group(pit->second);
                        else if (auto pit2 = pkgParamDefRhs.find(&psy);
                                 pit2 != pkgParamDefRhs.end())
                            ref->Actual_group(pit2->second);
                    }
                }
            }
            // A `$unit`-scope parameter read from a SYNTAX-emitted expression
            // (a net/port/typedef typespec range bound, `logic
            // [SCR1_N-1:0]`) binds the DESIGN-level parameter object, exactly
            // like the AST path (ExprEmit's unitParamMap arm).  Surelog never
            // substitutes a compilation-unit parameter into a range, so the
            // bound stays an unfolded op tree whose ref_obj MUST carry the
            // actual; without it Compare reports `failLhs=parameter
            // failRhs=<null>` (Scr1SvTests, 88 first-fails).  Resolution goes
            // through a real scope so a same-named module-local declaration
            // shadows correctly.
            if (!ref->Actual_group() && !unitParamMap.empty() &&
                !suppressRefActual && !noUnitParamActual) {
                const Scope* bindScope = tfTypeScope ? tfTypeScope
                                         : defNetTsScope ? defNetTsScope
                                                         : currentScope;
                // ...but NOT for a DECLARATION inside the def view of a
                // generate region.  There the declaration is compiled detached
                // from any instance (the typespec is emitted PARENTLESS,
                // unlike a module-level net's, which hangs off its var), and
                // in that detached compile the `$unit` scope is not on the
                // lookup path -- the range ref stays dangling while its
                // module-level sibling binds.  A gen-if CONDITION in the same
                // region is NOT covered (it binds; see ConstCapital).
                // Purpose-built golden /tmp/r10scr5_h2/ua.sv holds both in ONE
                // file: `vmod` binds, `vgen` (identical range text, inside
                // `if (1) begin : gblk`) does not.  The ELAB view folds the
                // gen-block range to constants, so no ref survives there to
                // bind either way.
                // Worth one branch: this single ref_obj was the whole
                // Scr1SvTests design echo -- reachable from everything via
                // typespec->Instance(), it made all 44 design.Typespecs and 47
                // module vectors report `failLhs=<null> failRhs=parameter()`.
                if (inDefGenDeclTs)
                    bindScope = nullptr;
                if (bindScope) {
                    ASTContext uctx(*bindScope, LookupLocation::max);
                    auto& ube = Expression::bind(
                        syn.as<syntax::ExpressionSyntax>(), uctx);
                    if (!ube.bad() && stripImplicitConv(ube).kind ==
                                          ExpressionKind::NamedValue) {
                        auto& usy = stripImplicitConv(ube)
                                        .as<NamedValueExpression>()
                                        .symbol;
                        if (auto uit = unitParamMap.find(&usy);
                            uit != unitParamMap.end() &&
                            (unitXFileRoot.empty() ||
                             rootFilePath(usy.location) == unitXFileRoot))
                            ref->Actual_group(uit->second);
                    }
                }
            }
            // § unitEnumConstActual — the same law for a `$unit`-scope ENUM
            // CONSTANT.  `logic [SCR1_HDU_DCSR_CAUSE_BIT_L-
            // SCR1_HDU_DCSR_CAUSE_BIT_R:0] csr_dcsr_cause;` keeps its bound as
            // an unfolded operation, and golden's two ref_objs BIND the
            // enum_const objects of the file-level enum; ours left them
            // dangling, and that ONE pair was the whole Scr1SvTests design
            // echo after the memberActualLeak / block-array-pair fixes —
            // 47 of 98 vectors reported `failLhs=enum_const(...)
            // failRhs=<null>`, which is a ref_obj Actual mismatch, not a
            // vector-size one (probe r10scr5tb: golden bound=2 dangling=0,
            // ours dangling=2).  Scoped to compilation-unit enums, and off in
            // a def-view gen-block declaration exactly like the param arm.
            // ...and off in a def-view gen-block CONT-ASSIGN as well: a
            // generate scope binds no enum constant in either view
            // (Scr1SvTests scr1_mem_axi `assign core_resp = axi_reinit ?
            // SCR1_MEM_RESP_NOTRDY : rcvd_resp` inside `if
            // (SCR1_AXI_RESP_BP == 1) begin : axi_resp_bp`; golden has 0 of
            // its 621 enum-const bindings inside a generate scope).
            if (!ref->Actual_group() && !suppressRefActual &&
                !inDefGenDeclTs && !inDefGenCaExpr && !enumConstMap.empty()) {
                const Scope* bindScope9 = tfTypeScope ? tfTypeScope
                                          : defNetTsScope ? defNetTsScope
                                                          : currentScope;
                if (bindScope9) {
                    ASTContext ectx9(*bindScope9, LookupLocation::max);
                    auto& ebe9 = Expression::bind(
                        syn.as<syntax::ExpressionSyntax>(), ectx9);
                    if (!ebe9.bad() && stripImplicitConv(ebe9).kind ==
                                           ExpressionKind::NamedValue) {
                        auto& esy9 = stripImplicitConv(ebe9)
                                         .as<NamedValueExpression>()
                                         .symbol;
                        bool unitEnum9 = false;
                        if (esy9.kind == SymbolKind::EnumValue)
                            for (auto sc9 = esy9.getParentScope(); sc9;
                                 sc9 = sc9->asSymbol().getParentScope()) {
                                auto k9 = sc9->asSymbol().kind;
                                if (k9 == SymbolKind::CompilationUnit) {
                                    unitEnum9 = true;
                                    break;
                                }
                                if (k9 == SymbolKind::Package ||
                                    k9 == SymbolKind::InstanceBody ||
                                    k9 == SymbolKind::GenerateBlock ||
                                    k9 == SymbolKind::Subroutine)
                                    break;
                            }
                        if (unitEnum9)
                            if (auto eit9 = enumConstMap.find(&esy9);
                                eit9 != enumConstMap.end() && eit9->second &&
                                eit9->second->UhdmType() == UHDM::uhdmenum_const)
                                ref->Actual_group(eit9->second);
                    }
                }
            }
            return ref;
        }
        case syntax::SyntaxKind::IntegerLiteralExpression: {
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            // MACRO-expanded literals have call-site offsets rawText cannot
            // map — fall back to the token's numeric value.
            if (raw.empty())
                raw = syn.as<syntax::LiteralExpressionSyntax>()
                          .literal.intValue()
                          .toString(LiteralBase::Decimal, false);
            c->VpiDecompile(raw);
            c->VpiSize(64);
            c->VpiValue("UINT:" + raw);
            c->VpiConstType(vpiUIntConst);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::StringLiteralExpression: {
            // A string literal re-emitted from SYNTAX (gen-if / gen-case
            // condition, call argument): raw decompile WITH the quotes, size
            // = 8 bits per source character (Surelog).
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            c->VpiDecompile(raw);
            std::string inner = raw;
            if (inner.size() >= 2 && inner.front() == '"' && inner.back() == '"')
                inner = inner.substr(1, inner.size() - 2);
            c->VpiSize((int32_t)(inner.size() * 8));
            c->VpiValue("STRING:" + inner);
            c->VpiConstType(vpiStringConst);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::IntegerVectorExpression: {
            // Based literal (64'h123..): raw decompile, size from the prefix,
            // value in the written base.
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            c->VpiDecompile(stripSep(raw));
            auto tick = raw.find('\'');
            int32_t sz = 0;
            if (tick != std::string::npos && tick > 0)
                sz = (int32_t)atoi(raw.substr(0, tick).c_str());
            size_t basePos = tick == std::string::npos ? 0 : tick + 1;
            if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                basePos++;
            char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
            std::string digits = basePos + 1 <= raw.size() ? raw.substr(basePos + 1) : "";
            digits.erase(std::remove(digits.begin(), digits.end(), '_'), digits.end());
            switch (base) {
                case 'h':
                    c->VpiValue("HEX:" + digits);
                    c->VpiConstType(vpiHexConst);
                    break;
                case 'b':
                    c->VpiValue("BIN:" + digits);
                    c->VpiConstType(vpiBinaryConst);
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
            c->VpiSize(sz ? sz : 64);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::ParenthesizedExpression:
            return emitSyntaxExpr(*syn.as<syntax::ParenthesizedExpressionSyntax>().expression,
                                  parent);
        case syntax::SyntaxKind::ElementSelectExpression:
        case syntax::SyntaxKind::IdentifierSelectName: {
            // t[0] -> bit_select (prefix-scoped fullname, parented index).
            std::string_view bname;
            const syntax::SelectorSyntax* sel = nullptr;
            // Multi-selector chain (x[i][e:w]) -> var_select with one
            // vpiIndex per selector; a range selector becomes a nested
            // part_select with base-doubled naming
            // (MultirangesStartNotFromZero gen CA).
            std::vector<const syntax::SelectorSyntax*> selChain;
            std::string_view chainBase;
            if (syn.kind == syntax::SyntaxKind::ElementSelectExpression) {
                const syntax::SyntaxNode* walk = &syn;
                while (walk->kind ==
                       syntax::SyntaxKind::ElementSelectExpression) {
                    auto& eseW = walk->as<syntax::ElementSelectExpressionSyntax>();
                    if (!eseW.select || !eseW.select->selector)
                        return nullptr;
                    selChain.insert(selChain.begin(), eseW.select->selector);
                    walk = eseW.left;
                }
                if (walk->kind != syntax::SyntaxKind::IdentifierName)
                    return nullptr;
                chainBase =
                    walk->as<syntax::IdentifierNameSyntax>().identifier.valueText();
            }
            else {
                auto& isnW = syn.as<syntax::IdentifierSelectNameSyntax>();
                chainBase = isnW.identifier.valueText();
                for (auto* s2 : isnW.selectors) {
                    if (!s2->selector)
                        return nullptr;
                    selChain.push_back(s2->selector);
                }
            }
            if (selChain.empty())
                return nullptr;
            if (selChain.size() > 1) {
                auto* vs = s.MakeVar_select();
                vs->VpiName(chainBase);
                std::string vsFull;
                if (!syntaxRefPrefix.empty()) {
                    vsFull = syntaxRefPrefix + syntaxRefSep +
                             std::string(chainBase);
                    vs->VpiFullName(vsFull);
                }
                vs->VpiParent(parent);
                setLoc(vs, syn.sourceRange());
                auto* ixs = s.MakeExprVec();
                std::string savedPfxV = syntaxRefPrefix;
                if (!vsFull.empty())
                    syntaxRefPrefix = vsFull;
                for (auto* s3 : selChain) {
                    if (s3->kind == syntax::SyntaxKind::BitSelect) {
                        if (auto* ix = emitSyntaxExpr(
                                *s3->as<syntax::BitSelectSyntax>().expr, vs))
                            ixs->push_back((UHDM::expr*)ix);
                    }
                    else if (s3->kind ==
                             syntax::SyntaxKind::SimpleRangeSelect) {
                        auto& rsV = s3->as<syntax::RangeSelectSyntax>();
                        auto* psV = s.MakePart_select();
                        psV->VpiName(chainBase);
                        if (!vsFull.empty())
                            psV->VpiFullName(vsFull + syntaxRefSep +
                                             std::string(chainBase));
                        psV->VpiDefName(chainBase);
                        psV->VpiConstantSelect(true);
                        psV->VpiParent(vs);
                        setLoc(psV, s3->sourceRange());
                        std::string savedPfxP = syntaxRefPrefix;
                        if (!vsFull.empty())
                            syntaxRefPrefix =
                                vsFull + syntaxRefSep + std::string(chainBase);
                        if (auto* le = emitSyntaxExpr(*rsV.left, psV))
                            psV->Left_range((UHDM::expr*)le);
                        if (auto* re = emitSyntaxExpr(*rsV.right, psV))
                            psV->Right_range((UHDM::expr*)re);
                        syntaxRefPrefix = savedPfxP;
                        ixs->push_back(psV);
                    }
                    else {
                        syntaxRefPrefix = savedPfxV;
                        return nullptr;
                    }
                }
                syntaxRefPrefix = savedPfxV;
                vs->Exprs(ixs);
                return vs;
            }
            if (syn.kind == syntax::SyntaxKind::ElementSelectExpression) {
                auto& ese = syn.as<syntax::ElementSelectExpressionSyntax>();
                if (ese.left->kind != syntax::SyntaxKind::IdentifierName)
                    return nullptr;
                bname = ese.left->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText();
                sel = ese.select->selector;
            }
            else {
                auto& isn = syn.as<syntax::IdentifierSelectNameSyntax>();
                bname = isn.identifier.valueText();
                if (isn.selectors.size() != 1)
                    return nullptr;
                sel = isn.selectors[0]->selector;
            }
            // A RANGE select (x[63:W]) is a part_select (DefName = base,
            // ConstantSelect, Left/Right from the written bounds) — not a
            // bit_select.
            if (sel && sel->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                auto& rs = sel->as<syntax::RangeSelectSyntax>();
                auto* pssel = s.MakePart_select();
                pssel->VpiName(bname);
                if (!syntaxRefPrefix.empty())
                    pssel->VpiFullName(syntaxRefPrefix + syntaxRefSep +
                                       std::string(bname));
                pssel->VpiDefName(bname);
                pssel->VpiConstantSelect(true);
                pssel->VpiParent(parent);
                setLoc(pssel, syn.sourceRange());
                // Bound refs scope THROUGH the select base (prefix.base.P);
                // bound constants stay unparented (Surelog).
                std::string savedPfx2 = syntaxRefPrefix;
                if (!syntaxRefPrefix.empty())
                    syntaxRefPrefix += syntaxRefSep + std::string(bname);
                auto unparentConst = [](UHDM::any* e) {
                    if (e && e->UhdmType() == UHDM::uhdmconstant)
                        ((UHDM::expr*)e)->VpiParent(nullptr);
                };
                if (auto* le = emitSyntaxExpr(*rs.left, pssel)) {
                    unparentConst(le);
                    pssel->Left_range((UHDM::expr*)le);
                }
                if (auto* re = emitSyntaxExpr(*rs.right, pssel)) {
                    unparentConst(re);
                    pssel->Right_range((UHDM::expr*)re);
                }
                syntaxRefPrefix = savedPfx2;
                return pssel;
            }
            // An INDEXED range select (x[B +: W] / x[B -: W]) is an
            // indexed_part_select, and without this arm it fell through to the
            // bit_select default below.  Same head fields as the part_select
            // above, plus IndexedPartSelectType (1 = `+:`, 2 = `-:`), but the
            // bound expressions do NOT scope through the base: Surelog names
            // them prefix.LO / prefix.WD, not prefix.src.LO (purpose-built
            // golden /tmp/r10scr5_h3/ub.sv, byte-identical with this arm).
            // Constants stay unparented, as in the range arm.
            if (sel && (sel->kind == syntax::SyntaxKind::AscendingRangeSelect ||
                        sel->kind == syntax::SyntaxKind::DescendingRangeSelect)) {
                auto& rsI = sel->as<syntax::RangeSelectSyntax>();
                auto* ips = s.MakeIndexed_part_select();
                ips->VpiName(bname);
                if (!syntaxRefPrefix.empty())
                    ips->VpiFullName(syntaxRefPrefix + syntaxRefSep +
                                     std::string(bname));
                ips->VpiDefName(bname);
                ips->VpiConstantSelect(true);
                ips->VpiIndexedPartSelectType(
                    sel->kind == syntax::SyntaxKind::AscendingRangeSelect ? 1 : 2);
                ips->VpiParent(parent);
                setLoc(ips, sel->sourceRange());
                auto unparentConstI = [](UHDM::any* e) {
                    if (e && e->UhdmType() == UHDM::uhdmconstant)
                        ((UHDM::expr*)e)->VpiParent(nullptr);
                };
                if (auto* be = emitSyntaxExpr(*rsI.left, ips)) {
                    unparentConstI(be);
                    ips->Base_expr((UHDM::expr*)be);
                }
                if (auto* we = emitSyntaxExpr(*rsI.right, ips)) {
                    unparentConstI(we);
                    ips->Width_expr((UHDM::expr*)we);
                }
                return ips;
            }
            auto* bs = s.MakeBit_select();
            bs->VpiName(bname);
            if (!syntaxRefPrefix.empty())
                bs->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(bname));
            bs->VpiParent(parent);
            setLoc(bs, syn.sourceRange());
            if (sel && sel->kind == syntax::SyntaxKind::BitSelect) {
                // Every def gen-CA RHS bit_select anchors at its INDEX, not
                // just the top-level one (Surelog).
                if (selBaseScopeIdx)
                    setLoc(bs, sel->sourceRange());
                // Def gen-CA RHS: index subexpressions scope THROUGH the
                // select base (prefix.base.<name>) — Surelog. A BARE
                // identifier index is the bit_select's direct ref_obj child,
                // and UHDM's ComputeFullName skips a bit_select parent for a
                // ref_obj child, so it stays scope-level (prefix.<name>).
                std::string savedPfx3 = syntaxRefPrefix;
                if (selBaseScopeIdx && !syntaxRefPrefix.empty() &&
                    sel->as<syntax::BitSelectSyntax>().expr->kind !=
                        syntax::SyntaxKind::IdentifierName)
                    syntaxRefPrefix += syntaxRefSep + std::string(bname);
                if (auto* ix = emitSyntaxExpr(
                        *sel->as<syntax::BitSelectSyntax>().expr, bs))
                    bs->VpiIndex((UHDM::expr*)ix);
                syntaxRefPrefix = savedPfx3;
            }
            return bs;
        }
        case syntax::SyntaxKind::UnbasedUnsizedLiteralExpression: {
            // '0/'1/'x/'z: BIN digit, size -1, raw decompile ('x -> 'X).
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            if (raw.empty())
                raw = std::string(syn.as<syntax::LiteralExpressionSyntax>()
                                      .literal.rawText());
            for (auto& ch : raw)
                if (ch == 'x' || ch == 'z')
                    ch = (char)toupper(ch);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            std::string digit = raw.size() > 1 ? raw.substr(1) : "0";
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::ConcatenationExpression: {
            // {a, b, c} at module-DEF compile: a plain vpiConcatOp spanning the
            // braces, operands emitted from syntax like every other def-view
            // expression.  Reached from a gen-block's own declarations, where
            // the whole subtree is syntax-emitted (BitsInGenBlock).
            auto& cce = syn.as<syntax::ConcatenationExpressionSyntax>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConcatOp);
            op->VpiParent(parent);
            setLoc(op, syn.sourceRange());
            auto* operands = s.MakeAnyVec();
            for (auto* e0 : cce.expressions)
                if (auto* o0 = emitSyntaxExpr(*e0, op))
                    operands->push_back(o0);
            op->Operands(operands);
            return op;
        }
        case syntax::SyntaxKind::StreamingConcatenationExpression: {
            // {<< [N] {a,b}}: stream op at the INNER braces span wrapping a
            // concat that takes the WHOLE streaming span (Surelog span swap);
            // an explicit slice size is a located first operand.
            auto& sce = syn.as<syntax::StreamingConcatenationExpressionSyntax>();
            auto* op = s.MakeOperation();
            op->VpiOpType(sce.operatorToken.valueText() == ">>" ? vpiStreamLROp
                                                                : vpiStreamRLOp);
            op->VpiParent(parent);
            setLoc(op, SourceRange(sce.innerOpenBrace.location(),
                                   sce.innerCloseBrace.location() + 1));
            auto* outer = s.MakeAnyVec();
            if (sce.sliceSize)
                if (auto* c = emitSyntaxExpr(*sce.sliceSize, op))
                    outer->push_back(c);
            auto* cc = s.MakeOperation();
            cc->VpiOpType(vpiConcatOp);
            cc->VpiParent(op);
            setLoc(cc, syn.sourceRange());
            auto* inner = s.MakeAnyVec();
            for (auto* se : sce.expressions)
                if (auto* e = emitSyntaxExpr(*se->expression, cc))
                    inner->push_back(e);
            cc->Operands(inner);
            outer->push_back(cc);
            op->Operands(outer);
            return op;
        }
        case syntax::SyntaxKind::InvocationExpression: {
            auto& inv = syn.as<syntax::InvocationExpressionSyntax>();
            // System call ($bits(dmi_t)): a sys_func_call with the argument
            // emitted as a ref_obj (type/name-token) argument.
            if (inv.left->kind == syntax::SyntaxKind::SystemName) {
                auto sysName = inv.left->as<syntax::SystemNameSyntax>()
                                   .systemIdentifier.valueText();
                // Type-query calls ($bits(type)/$size(...)) fold to a constant
                // when the argument resolves in the current scope. $bits of a
                // SIGNAL folds too UNLESS the signal's width is param-dependent
                // ($bits(int o) -> 32; $bits([X-1:0] o) stays a sys_func_call).
                bool foldQuery = typedefTsContext;
                // Outside a typedef ts, $bits folds ONLY for a FIXED-width
                // SIGNAL arg ($bits(int o) -> 32); a $bits(TYPE) or a
                // param-dependent signal stays a sys_func_call.
                if (!foldQuery && currentScope && inv.arguments &&
                    (sysName == "$bits" || sysName == "$size")) {
                    for (auto a2 : inv.arguments->parameters)
                        if (auto* sy2 = currentScope->find(
                                std::string(rawText(a2->sourceRange()))))
                            if ((sy2->kind == SymbolKind::Net ||
                                 sy2->kind == SymbolKind::Variable) &&
                                !typeWidthUsesParam(*sy2))
                                foldQuery = true;
                }
                // A MEMBER/SELECT argument (`$bits(a.pair[0])`) can never
                // resolve through `currentScope->find`, which takes a bare
                // name — but Surelog's `compileBits` only ever needed the
                // argument's TYPESPEC, and that is exactly what
                // `srlgBitsFoldArg` certifies. Bind the call and ask it; the
                // width then comes from the type, because slang's own
                // evaluation refuses a select rooted at a PORT (there is no
                // instance to read). HierPathPackedStruct.
                const slang::ast::Expression* selBitsArg9 = nullptr;
                if (!foldQuery && currentScope && inv.arguments &&
                    sysName == "$bits") {
                    for (auto a2 : inv.arguments->parameters) {
                        std::string raw2(rawText(a2->sourceRange()));
                        if (raw2.find('.') == std::string::npos &&
                            raw2.find('[') == std::string::npos)
                            break;
                        ASTContext bc9(*currentScope, LookupLocation::max);
                        auto& bd9 =
                            Expression::bind(syn.as<syntax::ExpressionSyntax>(), bc9);
                        if (bd9.kind == ExpressionKind::Call &&
                            bd9.as<CallExpression>().isSystemCall() &&
                            !bd9.as<CallExpression>().arguments().empty()) {
                            auto& ba9 = stripImplicitConv(
                                *bd9.as<CallExpression>().arguments()[0]);
                            if ((ba9.kind == ExpressionKind::MemberAccess ||
                                 ba9.kind == ExpressionKind::ElementSelect ||
                                 ba9.kind == ExpressionKind::RangeSelect) &&
                                ba9.type && ba9.type->isIntegral() &&
                                ba9.type->getBitWidth() > 0 &&
                                srlgBitsFoldArg(ba9))
                                selBitsArg9 = &ba9;
                        }
                        break;
                    }
                }
                if (selBitsArg9) {
                    auto* c = s.MakeConstant();
                    std::string digits =
                        std::to_string(selBitsArg9->type->getBitWidth());
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(parent);
                    setLoc(c, syn.sourceRange());
                    return c;
                }
                if (foldQuery && currentScope &&
                    (sysName == "$bits" || sysName == "$size" || sysName == "$clog2")) {
                    ASTContext bctx(*currentScope, LookupLocation::max);
                    auto& bound = Expression::bind(syn.as<syntax::ExpressionSyntax>(), bctx);
                    if (auto cv = bctx.tryEval(bound); cv && cv.isInteger()) {
                        auto* c = s.MakeConstant();
                        std::string digits =
                            cv.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(parent);
                        setLoc(c, syn.sourceRange());
                        return c;
                    }
                }
                auto* sfc = s.MakeSys_func_call();
                sfc->VpiName(sysName);
                sfc->VpiParent(parent);
                // Inside a CAST SIZE the call keeps the NAME-token span
                // ($clog2, not $clog2(RomSize)) — the same rule the bound
                // emitter applies through inCastSize, measured on the two
                // $clog2 calls of ClogCast (line 55 plain gen-if condition ->
                // full span; line 63 the same call as a cast size -> name).
                if (inCastSize)
                    setLoc(sfc, SourceRange(syn.sourceRange().start(),
                                            syn.sourceRange().start() +
                                                sysName.size()));
                else
                    setLoc(sfc, syn.sourceRange());
                if (inv.arguments) {
                    auto* args = s.MakeAnyVec();
                    for (auto arg : inv.arguments->parameters) {
                        // DOTTED args (blk1.w) re-emit as hier_paths (bare
                        // base, prefix-scoped leaf).
                        std::string argRaw = rawText(arg->sourceRange());
                        const syntax::SyntaxNode* ae = nullptr;
                        if (arg->kind == syntax::SyntaxKind::OrderedArgument) {
                            ae = arg->as<syntax::OrderedArgumentSyntax>().expr;
                            if (ae->kind ==
                                syntax::SyntaxKind::SimplePropertyExpr)
                                ae = ae->as<syntax::SimplePropertyExprSyntax>()
                                         .expr;
                            if (ae->kind ==
                                syntax::SyntaxKind::SimpleSequenceExpr)
                                ae = ae->as<syntax::SimpleSequenceExprSyntax>()
                                         .expr;
                        }
                        // A CONCATENATION argument ($bits({a, b, c})) is a real
                        // expression, not a type name: Surelog compiles it
                        // through compileExpression and the query call keeps a
                        // vpiConcatOp operand whose operands are the member
                        // refs.  The raw-text ref_obj fallback below is only
                        // right for a NAME-shaped argument (BitsInGenBlock).
                        if (ae && (argRaw.find('.') != std::string::npos ||
                                   ae->kind == syntax::SyntaxKind::
                                                   ConcatenationExpression)) {
                            if (auto* e2 = emitSyntaxExpr(*ae, sfc)) {
                                args->push_back(e2);
                                continue;
                            }
                        }
                        // A PACKAGE DEF listing keeps the query call itself
                        // (THE LAW: that view reduces nothing), but Surelog
                        // still RESOLVES the argument, and the two package
                        // origins resolve differently:
                        //   * SAME package  -> ref_obj chained to that
                        //     parameter's own def Rhs constant, exactly like
                        //     a bare read of it elsewhere in the body;
                        //   * OTHER package -> the read is SUBSTITUTED by the
                        //     referenced parameter's VALUE, as a constant
                        //     sized by that parameter's own type (32 for
                        //     `int`) rather than the 64 bits every other
                        //     def-view fold carries.
                        // Measured on a 4-row package golden (probe p7:
                        // `(W==4)?..`, `(pb::Q==4)?..`, `$bits(pb::Q)`,
                        // `$bits(W)`): the two BARE reads bind the usual way
                        // and only the two $bits arguments split like this.
                        // AllPackageSignal's three static assertions are the
                        // same shape through a macro.
                        // The dim/bound emitter runs with no currentScope, so
                        // resolve in the package being listed (which is where
                        // Surelog resolves it too — both a same-package name
                        // and a `other::NAME` qualifier bind from there).
                        const Scope* argScope9 =
                            currentScope ? currentScope
                            : tfTypeScope ? tfTypeScope
                            : (curPkgEmitSym && curPkgEmitSym->kind ==
                                                    SymbolKind::Package)
                                ? &curPkgEmitSym->as<PackageSymbol>()
                                : nullptr;
                        if (ae && curPkgEmitSym && !pkgEmitTopView &&
                            argScope9 &&
                            syntax::ExpressionSyntax::isKind(ae->kind)) {
                            ASTContext pctx(*argScope9, LookupLocation::max);
                            auto& pb9 = Expression::bind(
                                ae->as<syntax::ExpressionSyntax>(), pctx);
                            const Symbol* psy9 = nullptr;
                            if (!pb9.bad() && stripImplicitConv(pb9).kind ==
                                                  ExpressionKind::NamedValue)
                                psy9 = &stripImplicitConv(pb9)
                                            .as<NamedValueExpression>()
                                            .symbol;
                            const Scope* home9 =
                                psy9 ? psy9->getParentScope() : nullptr;
                            if (psy9 && psy9->kind == SymbolKind::Parameter &&
                                home9 && home9->asSymbol().kind ==
                                             SymbolKind::Package) {
                                if (&home9->asSymbol() != curPkgEmitSym) {
                                    auto& dp9 = psy9->as<ParameterSymbol>();
                                    auto& dv9 = dp9.getValue();
                                    if (dv9.isInteger() &&
                                        !dv9.integer().hasUnknown()) {
                                        auto* c9 = s.MakeConstant();
                                        std::string dg9 =
                                            dv9.integer().toString(
                                                LiteralBase::Decimal, false);
                                        c9->VpiDecompile(dg9);
                                        c9->VpiSize((int32_t)dp9.getType()
                                                        .getBitWidth());
                                        c9->VpiValue("UINT:" + dg9);
                                        c9->VpiConstType(vpiUIntConst);
                                        c9->VpiParent(sfc);
                                        setLoc(c9, arg->sourceRange());
                                        args->push_back(c9);
                                        continue;
                                    }
                                }
                                else {
                                    auto* r9 = s.MakeRef_obj();
                                    r9->VpiName(argRaw);
                                    r9->VpiParent(sfc);
                                    setLoc(r9, arg->sourceRange());
                                    if (auto ci9 = pkgParamConst.find(psy9);
                                        ci9 != pkgParamConst.end())
                                        r9->Actual_group(ci9->second);
                                    else if (auto ri9 =
                                                 pkgParamDefRhs.find(psy9);
                                             ri9 != pkgParamDefRhs.end())
                                        r9->Actual_group(ri9->second);
                                    args->push_back(r9);
                                    continue;
                                }
                            }
                        }
                        auto* r = s.MakeRef_obj();
                        r->VpiName(argRaw);
                        r->VpiParent(sfc);
                        setLoc(r, arg->sourceRange());
                        args->push_back(r);
                    }
                    if (!args->empty())
                        sfc->Tf_call_args(args);
                }
                return sfc;
            }
            // Module-compile calls: NAME-token span, linked to the module
            // function when one matches by name (Surelog).
            auto* fc = s.MakeFunc_call();
            if (inv.left->kind == syntax::SyntaxKind::IdentifierName)
                fc->VpiName(
                    inv.left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            fc->VpiParent(parent);
            // TYPE-BOUND contexts anchor at the callee NAME token; expression
            // contexts keep the full call span (Surelog).
            if (boundCallNameSpan)
                setLoc(fc, inv.left->sourceRange());
            else
                setLoc(fc, syn.sourceRange());
            // Only TYPEDEF/PORT-context bounds (tfContext) link the
            // function; gen-conn call args stay unbound (Surelog).
            if (tfContext)
                for (auto& [subK, subI] : subMap)
                    if (subI.tf && subI.tf->VpiName() == fc->VpiName() &&
                        subI.tf->UhdmType() == UHDM::uhdmfunction) {
                        fc->Function((UHDM::function*)subI.tf);
                        break;
                    }
            // Arguments emit from syntax too (prefix_or(i[OFF-1:0])).
            if (inv.arguments && !inv.arguments->parameters.empty()) {
                auto* args = s.MakeAnyVec();
                for (auto a2 : inv.arguments->parameters)
                    if (a2->kind == syntax::SyntaxKind::OrderedArgument) {
                        // Unwrap the property/sequence wrappers around a
                        // plain expression argument.
                        const syntax::SyntaxNode* ae =
                            a2->as<syntax::OrderedArgumentSyntax>().expr;
                        if (ae->kind == syntax::SyntaxKind::SimplePropertyExpr)
                            ae = ae->as<syntax::SimplePropertyExprSyntax>()
                                     .expr;
                        if (ae->kind == syntax::SyntaxKind::SimpleSequenceExpr)
                            ae = ae->as<syntax::SimpleSequenceExprSyntax>()
                                     .expr;
                        if (auto* e2 = emitSyntaxExpr(*ae, fc))
                            args->push_back(e2);
                    }
                if (!args->empty())
                    fc->Tf_call_args(args);
            }
            return fc;
        }
        case syntax::SyntaxKind::CastExpression: {
            // int'(expr) at module compile: operation 67 with a scoped ts ref
            // (int_typespec at the cast-target token) + the operand.
            auto& ce = syn.as<syntax::CastExpressionSyntax>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCastOp);
            op->VpiParent(parent);
            setLoc(op, syn.sourceRange());
            UHDM::typespec* cts = nullptr;
            // The cast target's typespec CLASS follows the WRITTEN target, in
            // the def (syntax) view exactly as in the bound one: a type
            // keyword takes that keyword's typespec class, and anything else
            // is a SIZE expression, which Surelog compiles into an
            // integer_typespec (`Cast_to_size` -> `compileExpression` on the
            // size, hung on the typespec as vpiExpr, or a direct INT value
            // for a literal).  Measured def-view matrix (gen-if conditions,
            // purpose-built golden r10c5 t5.sv): `5'(N)` -> integer_typespec
            // at the literal with `INT:5`; `$clog2(N)'(N)` -> integer_typespec
            // spanning `$clog2(N)` with vpiExpr = the sys_func_call;
            // `(N+1)'(N)` -> integer_typespec spanning `N+1` (parens dropped)
            // with vpiExpr = the operation; `int'`/`byte'`/`shortint'`/
            // `integer'` -> int_/byte_/short_int_/integer_typespec.
            SourceRange ctsRange = ce.left->sourceRange();
            switch (ce.left->kind) {
                case syntax::SyntaxKind::IntType: {
                    auto* t = s.MakeInt_typespec();
                    t->VpiSigned(true);
                    cts = t;
                    break;
                }
                case syntax::SyntaxKind::IntegerType: {
                    auto* t = s.MakeInteger_typespec();
                    t->VpiSigned(true);
                    cts = t;
                    break;
                }
                case syntax::SyntaxKind::ByteType: {
                    auto* t = s.MakeByte_typespec();
                    t->VpiSigned(true);
                    cts = t;
                    break;
                }
                case syntax::SyntaxKind::ShortIntType: {
                    auto* t = s.MakeShort_int_typespec();
                    t->VpiSigned(true);
                    cts = t;
                    break;
                }
                case syntax::SyntaxKind::LongIntType: {
                    auto* t = s.MakeLong_int_typespec();
                    t->VpiSigned(true);
                    cts = t;
                    break;
                }
                case syntax::SyntaxKind::TimeType:
                    cts = s.MakeTime_typespec();
                    break;
                case syntax::SyntaxKind::BitType:
                    cts = s.MakeBit_typespec();
                    break;
                case syntax::SyntaxKind::LogicType:
                case syntax::SyntaxKind::RegType:
                    cts = s.MakeLogic_typespec();
                    break;
                // An IDENTIFIER cast target (a parameter width XLEN'(x) or a
                // typedef name) is UNRESOLVED in the def view — Surelog emits
                // an unsupported_typespec NAMED by the written token, exactly
                // as the def-view gen-block PROCEDURAL path does (see
                // defGenProcessEmit in ExprEmit). rp32_r5p_alu's gen_shf
                // `XLEN'($signed(shf_ext) >>> shf_amm)`; the elaborated view
                // still folds to int_typespec(XLEN).
                case syntax::SyntaxKind::IdentifierName: {
                    auto* t = s.MakeUnsupported_typespec();
                    t->VpiName(std::string(rawText(ce.left->sourceRange())));
                    cts = t;
                    break;
                }
                // A PACKAGE-SCOPED target (p::Q'(x), p::nib_t'(x)) is a TYPE
                // name to Surelog, not a size: it resolves through the
                // package (a param width -> that param's bare int_typespec
                // with the folded value; a typedef -> the shared named
                // typespec object).  Neither is reconstructible from syntax
                // alone here, so keep the historical unnamed logic_typespec
                // — RANKED residue, measured against golden in r10c5's t6.sv.
                case syntax::SyntaxKind::ScopedName:
                    cts = s.MakeLogic_typespec();
                    break;
                default:
                    break;
            }
            if (!cts) {
                // Size cast. Parens around the size expression are not part
                // of the typespec span.
                const syntax::SyntaxNode* sz = ce.left;
                while (sz->kind == syntax::SyntaxKind::ParenthesizedExpression)
                    sz = sz->as<syntax::ParenthesizedExpressionSyntax>()
                             .expression;
                ctsRange = sz->sourceRange();
                auto* its = s.MakeInteger_typespec();
                if (sz->kind == syntax::SyntaxKind::IntegerLiteralExpression)
                    its->VpiValue("INT:" + rawText(ctsRange));
                else {
                    // A SYSTEM CALL in a cast size is a TYPE-context bound
                    // like a typedef's: its sys_func_call keeps the NAME span
                    // ($clog2, not $clog2(RomSize)) — measured against the
                    // SAME call written as a plain gen-if condition in the
                    // same file, which keeps the full span (ClogCast lines
                    // 55 vs 63).
                    bool savedBCN9 = boundCallNameSpan, savedCS9 = inCastSize;
                    boundCallNameSpan = true;
                    inCastSize = true;
                    auto* se = emitSyntaxExpr(*sz, op);
                    boundCallNameSpan = savedBCN9;
                    inCastSize = savedCS9;
                    if (se)
                        its->Expr((UHDM::expr*)se);
                }
                cts = its;
            }
            setLoc((UHDM::BaseClass*)cts, ctsRange);
            auto* rt = s.MakeRef_typespec();
            if (!syntaxRefPrefix.empty())
                rt->VpiFullName(syntaxRefPrefix);
            rt->VpiParent(op);
            rt->Actual_typespec(cts);
            op->Typespec(rt);
            auto* operands = s.MakeAnyVec();
            const syntax::SyntaxNode* opnd = ce.right;
            if (opnd->kind == syntax::SyntaxKind::ParenthesizedExpression)
                opnd = opnd->as<syntax::ParenthesizedExpressionSyntax>().expression;
            if (auto* e = emitSyntaxExpr(*opnd, op))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case syntax::SyntaxKind::AssignmentPatternExpression: {
            // Structured pattern ('{f1: expr, ...}) in a DEF gen CA:
            // operation 75 of tagged_patterns; each carries the member expr
            // (parented at the operation) and a string_typespec ref named by
            // the FIELD, scoped at the gen prefix (Surelog).
            auto& ape = syn.as<syntax::AssignmentPatternExpressionSyntax>();
            if (ape.pattern->kind !=
                syntax::SyntaxKind::StructuredAssignmentPattern)
                return nullptr;
            auto& spn =
                ape.pattern->as<syntax::StructuredAssignmentPatternSyntax>();
            auto* op9 = s.MakeOperation();
            op9->VpiOpType(75);
            op9->VpiParent(parent);
            setLoc(op9, ape.pattern->sourceRange());
            auto* ops9 = s.MakeAnyVec();
            for (auto* item9 : spn.items) {
                if (item9->kind != syntax::SyntaxKind::AssignmentPatternItem)
                    continue;
                auto& api9 = item9->as<syntax::AssignmentPatternItemSyntax>();
                auto* tp9 = s.MakeTagged_pattern();
                tp9->VpiParent(op9);
                setLoc(tp9, api9.expr->sourceRange());
                if (auto* pe9 = emitSyntaxExpr(*api9.expr, op9))
                    tp9->Pattern((UHDM::expr*)pe9);
                auto* rt9 = s.MakeRef_typespec();
                if (!syntaxRefPrefix.empty())
                    rt9->VpiFullName(syntaxRefPrefix);
                rt9->VpiParent(tp9);
                auto* st9 = s.MakeString_typespec();
                st9->VpiName(rawText(api9.key->sourceRange()));
                st9->VpiParent(tp9);
                setLoc(st9, api9.key->sourceRange());
                rt9->Actual_typespec(st9);
                tp9->Typespec(rt9);
                ops9->push_back(tp9);
            }
            op9->Operands(ops9);
            return op9;
        }
        case syntax::SyntaxKind::ScopedName: {
            // A dotted HIERARCHICAL name (B.y, blk[0].sub.x) in a DEF-view
            // gen-block cont_assign: a hier_path built from the source text,
            // mirroring the ELAB HierarchicalValue handler (ExprEmit). A
            // package-scoped name (pkg::x) has no '.' -> <2 parts -> falls
            // through to null (unchanged). syntaxRefPrefix is the enclosing
            // gen-scope fullname (work@gen_test9.A); the leaf ref carries
            // prefix.<leaf> (Surelog flattens intermediate blocks: A.y not
            // A.B.y). Other (non-gen) callers have an empty/param prefix, so
            // the leaf simply gets no fullname.
            std::string raw = rawText(syn.sourceRange());
            // A SYMBOLIC base index (STAGE[i-1].C) re-lexes with spaces
            // around binary operators (Surelog) and needs the selector
            // SYNTAX for the bit_select index emission.
            const syntax::ExpressionSyntax* baseSelSyn = nullptr;
            {
                auto& scn0 = syn.as<syntax::ScopedNameSyntax>();
                if (scn0.left->kind ==
                    syntax::SyntaxKind::IdentifierSelectName) {
                    auto& isn0 =
                        scn0.left->as<syntax::IdentifierSelectNameSyntax>();
                    if (isn0.selectors.size() == 1 &&
                        isn0.selectors[0]->selector &&
                        isn0.selectors[0]->selector->kind ==
                            syntax::SyntaxKind::BitSelect)
                        baseSelSyn = isn0.selectors[0]
                                         ->selector
                                         ->as<syntax::BitSelectSyntax>()
                                         .expr;
                }
            }
            auto spaceOps = [](const std::string& t) {
                std::string o;
                for (size_t i2 = 0; i2 < t.size(); i2++) {
                    char ch = t[i2];
                    if ((ch == '+' || ch == '-' || ch == '*' || ch == '/') &&
                        i2 > 0 && t[i2 - 1] != ' ' && t[i2 - 1] != '[') {
                        o += ' ';
                        o += ch;
                        if (i2 + 1 < t.size() && t[i2 + 1] != ' ')
                            o += ' ';
                    }
                    else
                        o += ch;
                }
                return o;
            };
            std::string dispRaw = spaceOps(raw);
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
            // A PACKAGE-SCOPED reference (pkg::PARAM) in a symbolic TYPE range
            // keeps a ref_obj bound to the package parameter — Surelog leaves the
            // [pkg::WIDTH-1:0] bound UNFOLDED (fail_detect_width output port).
            if (parts.size() < 2 && raw.find("::") != std::string::npos) {
                // ...but a package ENUM MEMBER (pkg::ReadingLow) is already a
                // constant when the module def compiles (packages elaborate
                // first), so Surelog's reduce substitutes its VALUE.  The
                // enum_const's own value/width carry over verbatim; only the
                // decompile is re-rendered from them, which is why a member
                // whose initializer is an expression ({6'b001100, MuBi4False})
                // reads 10'b0011000101 and not its source text.  The constant
                // is anchored at the SCOPE qualifier (`pkg::`), not the whole
                // reference (EnumConstConcat).
                if (const Scope* esc =
                        currentScope ? currentScope : (const Scope*)nullptr) {
                    ASTContext ectx(*esc, LookupLocation::max);
                    auto& ee =
                        Expression::bind(syn.as<syntax::ExpressionSyntax>(), ectx);
                    if (!ee.bad() && stripImplicitConv(ee).kind ==
                                         ExpressionKind::NamedValue) {
                        auto& esy =
                            stripImplicitConv(ee).as<NamedValueExpression>().symbol;
                        if (esy.kind == SymbolKind::EnumValue) {
                            if (auto* ec = enumMemberSubstConst(esy)) {
                                std::string ev(ec->VpiValue());
                                auto cp = ev.find(':');
                                std::string tag = ev.substr(0, cp);
                                std::string dg = ev.substr(cp + 1);
                                std::string base = tag == "BIN"   ? "'b"
                                                   : tag == "HEX" ? "'h"
                                                   : tag == "OCT" ? "'o"
                                                                  : "";
                                ec->VpiDecompile(
                                    base.empty()
                                        ? dg
                                        : std::to_string(ec->VpiSize()) + base + dg);
                                ec->VpiParent(parent);
                                auto qEnd = syn.sourceRange().start() +
                                            raw.find("::") + 2;
                                setLoc(ec, SourceRange(syn.sourceRange().start(),
                                                       qEnd));
                                return ec;
                            }
                        }
                    }
                }
                auto* ref = s.MakeRef_obj();
                ref->VpiName(raw);
                ref->VpiFullName(raw);
                ref->VpiParent(parent);
                setLoc(ref, syn.sourceRange());
                const Scope& bscope =
                    currentScope ? *currentScope : (const Scope&)comp.getRoot();
                ASTContext bctx(bscope, LookupLocation::max);
                auto& be =
                    Expression::bind(syn.as<syntax::ExpressionSyntax>(), bctx);
                if (!be.bad() && stripImplicitConv(be).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& psy =
                        stripImplicitConv(be).as<NamedValueExpression>().symbol;
                    if (auto poit = pkgParamObj.find(&psy);
                        poit != pkgParamObj.end())
                        ref->Actual_group(poit->second);
                }
                return ref;
            }
            if (parts.size() < 2)
                return nullptr;
            auto* hp = s.MakeHier_path();
            hp->VpiName(dispRaw);
            hp->VpiFullName(dispRaw);
            hp->VpiParent(parent);
            setLoc(hp, syn.sourceRange());
            auto* elems = s.MakeAnyVec();
            auto exprStart = syn.sourceRange().start();
            std::string dottedSoFar;
            bool genVarBaseEmitted = false;
            for (size_t i = 0; i < parts.size(); i++) {
                auto& [pname, off] = parts[i];
                dottedSoFar += (i == 0 ? pname : "." + pname);
                auto lb = pname.find('[');
                auto rb = pname.find(']');
                if (lb != std::string::npos && rb != std::string::npos &&
                    rb > lb + 1 &&
                    pname.find_first_not_of("0123456789", lb + 1) == rb) {
                    std::string base = pname.substr(0, lb);
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(dottedSoFar);
                    setLoc(bs, SourceRange(exprStart + off,
                                           exprStart + off + base.size()));
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(idx);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + idx);
                    c->VpiConstType(vpiUIntConst);
                    size_t digitOff = off + lb + 1;
                    setLoc(c, SourceRange(exprStart + digitOff,
                                          exprStart + digitOff + idx.size()));
                    bs->VpiIndex(c);
                    elems->push_back(bs);
                    continue;
                }
                // A [L:R] literal RANGE on an element (f1[63:0]):
                // part_select named by the member, fullname = the dotted
                // path incl. the select, ConstantSelect, UINT64 bounds.
                {
                    auto cl9 = pname.find(':');
                    if (lb != std::string::npos && rb != std::string::npos &&
                        cl9 != std::string::npos && cl9 > lb && cl9 < rb &&
                        pname.find_first_not_of("0123456789",
                                                lb + 1) == cl9 &&
                        pname.find_first_not_of("0123456789",
                                                cl9 + 1) == rb) {
                        std::string base9 = pname.substr(0, lb);
                        auto* ps9 = s.MakePart_select();
                        ps9->VpiName(base9);
                        ps9->VpiFullName(dottedSoFar);
                        ps9->VpiParent(hp);
                        ps9->VpiConstantSelect(true);
                        setLoc(ps9, SourceRange(exprStart + off,
                                                exprStart + off + rb));
                        auto mkB9 = [&](size_t from, size_t to) {
                            auto* c9 = s.MakeConstant();
                            std::string dg9 =
                                pname.substr(from, to - from);
                            c9->VpiDecompile(dg9);
                            c9->VpiSize(64);
                            c9->VpiValue("UINT:" + dg9);
                            c9->VpiConstType(vpiUIntConst);
                            setLoc(c9,
                                   SourceRange(exprStart + off + from,
                                               exprStart + off + to));
                            return c9;
                        };
                        ps9->Left_range(mkB9(lb + 1, cl9));
                        ps9->Right_range(mkB9(cl9 + 1, rb));
                        elems->push_back(ps9);
                        continue;
                    }
                }
                // SYMBOLIC index on the base (STAGE[i-1]): bit_select named
                // by the base, fullname with SPACED index, index from the
                // selector syntax.
                if (i == 0 && baseSelSyn && lb != std::string::npos &&
                    rb != std::string::npos && rb > lb + 1) {
                    std::string base = pname.substr(0, lb);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(spaceOps(pname));
                    setLoc(bs, SourceRange(exprStart + off,
                                           exprStart + off + base.size()));
                    if (auto* ix = emitSyntaxExpr(*baseSelSyn, bs)) {
                        // A VARIABLE index ref parents at the HIER_PATH;
                        // operations/constants keep the bit_select (Surelog).
                        if (((UHDM::any*)ix)->UhdmType() == UHDM::uhdmref_obj)
                            ((UHDM::any*)ix)->VpiParent(hp);
                        bs->VpiIndex((UHDM::expr*)ix);
                    }
                    elems->push_back(bs);
                    continue;
                }
                // A GENVAR/variable-indexed BASE component (man[i].req.lck in a
                // genvar for): bit_select(base), raw component fullname, with a
                // ref_obj index child that PARENTS AT THE HIER_PATH and carries
                // the gen-scope-prefixed genvar fullname (Surelog). Distinct
                // from the constant-index and symbolic-doubled-index forms.
                if (i == 0 && lb != std::string::npos && rb != std::string::npos &&
                    rb > lb + 1) {
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto isIdentStart = [](char c) {
                        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                               c == '_';
                    };
                    bool simpleId = !idx.empty() && isIdentStart(idx[0]);
                    for (char ch : idx)
                        if (!(isIdentStart(ch) || (ch >= '0' && ch <= '9')))
                            simpleId = false;
                    if (simpleId) {
                        std::string base = pname.substr(0, lb);
                        auto* bs = s.MakeBit_select();
                        bs->VpiName(base);
                        bs->VpiParent(hp);
                        bs->VpiFullName(pname);
                        setLoc(bs, SourceRange(exprStart + off,
                                               exprStart + off + base.size()));
                        auto* ir = s.MakeRef_obj();
                        ir->VpiName(idx);
                        if (!syntaxRefPrefix.empty())
                            ir->VpiFullName(syntaxRefPrefix + "." + idx);
                        ir->VpiParent(hp);
                        size_t idOff = off + lb + 1;
                        setLoc(ir, SourceRange(exprStart + idOff,
                                               exprStart + idOff + idx.size()));
                        bs->VpiIndex(ir);
                        elems->push_back(bs);
                        genVarBaseEmitted = true;
                        continue;
                    }
                }
                auto* r = s.MakeRef_obj();
                r->VpiName(pname);
                if (genVarBaseEmitted && i + 1 == parts.size())
                    // A gen-scope modport-array member path gives the LEAF the
                    // RAW dotted fullname (Surelog).
                    r->VpiFullName(raw);
                else if (i + 1 == parts.size() && !syntaxRefPrefix.empty())
                    r->VpiFullName(syntaxRefPrefix + "." + pname);
                else
                    // Name-only cache blocks the dump-time lazy scoped
                    // fullname recompute (Surelog shows the bare name).
                    r->VpiFullName(pname);
                r->VpiParent(hp);
                setLoc(r, SourceRange(exprStart + off, exprStart + off + pname.size()));
                elems->push_back(r);
            }
            // A gen-scope modport-array member path anchors the hier_path at the
            // BASE-name token only (Surelog).
            if (genVarBaseEmitted && !elems->empty()) {
                auto* fe = (UHDM::expr*)elems->front();
                hp->VpiEndLineNo(fe->VpiEndLineNo());
                hp->VpiEndColumnNo(fe->VpiEndColumnNo());
            }
            hp->Path_elems(elems);
            return hp;
        }
        default: {
            // `x inside {a, b}` — op 95 with [x, a, b, ...] (Surelog).
            if (syn.kind == syntax::SyntaxKind::InsideExpression) {
                auto& ie = syn.as<syntax::InsideExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(95);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* l = emitSyntaxExpr(*ie.expr, op))
                    operands->push_back(l);
                if (ie.ranges)
                    for (auto* vr : ie.ranges->valueRanges)
                        if (auto* e = emitSyntaxExpr(*vr, op))
                            operands->push_back(e);
                op->Operands(operands);
                return op;
            }
            // Ternary (?:) — vpiConditionOp with [cond, true, false].
            if (syn.kind == syntax::SyntaxKind::ConditionalExpression) {
                auto& ce = syn.as<syntax::ConditionalExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(32);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (!ce.predicate->conditions.empty())
                    if (auto* c0 = emitSyntaxExpr(
                            *ce.predicate->conditions[0]->expr, op))
                        operands->push_back(c0);
                if (auto* l = emitSyntaxExpr(*ce.left, op))
                    operands->push_back(l);
                if (auto* r = emitSyntaxExpr(*ce.right, op))
                    operands->push_back(r);
                op->Operands(operands);
                return op;
            }
            if (int32_t opType = mapSyntaxUnaryOp(syn.kind)) {
                auto& ue = syn.as<syntax::PrefixUnaryExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(opType);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* e = emitSyntaxExpr(*ue.operand, op)) {
                    // A DIRECT literal operand of a UNARY op is built with
                    // compileConst and stays UNPARENTED (Surelog); binary
                    // operands and nested expressions keep the normal rules.
                    if (e->UhdmType() == UHDM::uhdmconstant &&
                        (ue.operand->kind ==
                             syntax::SyntaxKind::IntegerLiteralExpression ||
                         ue.operand->kind ==
                             syntax::SyntaxKind::IntegerVectorExpression))
                        ((UHDM::any*)e)->VpiParent(nullptr);
                    operands->push_back(e);
                }
                op->Operands(operands);
                return op;
            }
            if (int32_t opType = mapSyntaxBinOp(syn.kind)) {
                auto& be = syn.as<syntax::BinaryExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(opType);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* l = emitSyntaxExpr(*be.left, op))
                    operands->push_back(l);
                if (auto* r = emitSyntaxExpr(*be.right, op))
                    operands->push_back(r);
                op->Operands(operands);
                return op;
            }
            return nullptr;
        }
    }
}

UHDM::instance* UhdmExporter::homePkgInstOf(const Symbol& sym) {
    auto hs = sym.getParentScope();
    if (!hs || hs->asSymbol().kind != SymbolKind::Package)
        return nullptr;
    if (auto tt = pkgTopMap.find((const void*)&hs->asSymbol());
        tt != pkgTopMap.end())
        return (UHDM::instance*)tt->second;
    if (auto pd = pkgDefMap.find(&hs->asSymbol()); pd != pkgDefMap.end())
        return (UHDM::instance*)pd->second;
    return nullptr;
}

// Surelog's compileBound never matches the `$`-prefixed name it is handed from
// the system-task-name path, so $high/$low/$left/$right of an unpacked array
// fall through to a sys_func_call that the declaration-dimension reduce then
// evaluates as the operand's BIT COUNT.  Measured, three shapes, one source
// per row (`logic e[$high(a):0]` etc.):
//     logic [15:0] a[1:0] -> $high=$low=$left=$right = 32 = $bits(a)
//     logic  [7:0] a[3:0] -> 32                      = $bits(a)
//     logic  [2:0] a[1:0] ->  6                      = $bits(a)
// so `$high(a)-$low(a)+1` reduces to 1 and `logic d[$high(a)-$low(a)+1:0]` is
// a 2-element array, not the LRM's 3.  $size and $bits are unaffected (they go
// through compileBits, which does resolve).  SystemCallSize.
bool UhdmExporter::srlgBoundCallDim(const syntax::ExpressionSyntax* es,
                                    int64_t& out) {
    if (!es || !currentScope)
        return false;
    ASTContext bctx(*currentScope, LookupLocation::max);
    auto& be = Expression::bind(*const_cast<syntax::ExpressionSyntax*>(es), bctx);
    if (be.bad())
        return false;
    bool sawBoundCall = false;
    std::function<bool(const Expression&, int64_t&)> ev =
        [&](const Expression& e0, int64_t& v) -> bool {
        auto& e = stripImplicitConv(e0);
        if (e.kind == ExpressionKind::Call) {
            auto& ce = e.as<CallExpression>();
            if (ce.isSystemCall()) {
                auto nm = ce.getSubroutineName();
                if ((nm == "$high" || nm == "$low" || nm == "$left" ||
                     nm == "$right") &&
                    ce.arguments().size() == 1) {
                    const Type& at = *ce.arguments()[0]->type;
                    if (at.getCanonicalType().kind ==
                        SymbolKind::FixedSizeUnpackedArrayType) {
                        sawBoundCall = true;
                        v = (int64_t)at.getBitstreamWidth();
                        return true;
                    }
                }
            }
            return false;
        }
        if (e.kind == ExpressionKind::BinaryOp) {
            auto& bo = e.as<BinaryExpression>();
            int64_t l = 0, r = 0;
            if (!ev(bo.left(), l) || !ev(bo.right(), r))
                return false;
            switch (bo.op) {
                case BinaryOperator::Add: v = l + r; return true;
                case BinaryOperator::Subtract: v = l - r; return true;
                case BinaryOperator::Multiply: v = l * r; return true;
                case BinaryOperator::Divide:
                    if (!r)
                        return false;
                    v = l / r;
                    return true;
                default: return false;
            }
        }
        if (e.kind == ExpressionKind::UnaryOp) {
            auto& uo = e.as<UnaryExpression>();
            int64_t o = 0;
            if (!ev(uo.operand(), o))
                return false;
            if (uo.op == UnaryOperator::Minus) {
                v = -o;
                return true;
            }
            if (uo.op == UnaryOperator::Plus) {
                v = o;
                return true;
            }
            return false;
        }
        ASTContext lctx(comp.getRoot(), LookupLocation::max);
        auto cv = lctx.tryEval(e);
        if (!cv || !cv.isInteger() || cv.integer().hasUnknown())
            return false;
        auto iv = cv.integer().as<int64_t>();
        if (!iv)
            return false;
        v = *iv;
        return true;
    };
    int64_t val = 0;
    if (!ev(be, val) || !sawBoundCall)
        return false;
    out = val;
    return true;
}

// A purely DOTTED name bound (`CFG.HSK.DLY`): slang parses it as a chain of
// ScopedNameSyntax with Dot separators. `pkg::P` is the same node kind with a
// DoubleColon separator and is deliberately NOT matched.
static bool dottedNameBound(const slang::syntax::ExpressionSyntax* es) {
    namespace syntax = slang::syntax;
    if (!es || es->kind != syntax::SyntaxKind::ScopedName)
        return false;
    const syntax::SyntaxNode* cur = es;
    while (cur->kind == syntax::SyntaxKind::ScopedName) {
        auto& sn = cur->as<syntax::ScopedNameSyntax>();
        if (sn.separator.kind != slang::parsing::TokenKind::Dot ||
            sn.right->kind != syntax::SyntaxKind::IdentifierName)
            return false;
        cur = sn.left;
    }
    return cur->kind == syntax::SyntaxKind::IdentifierName;
}

UHDM::VectorOfrange* UhdmExporter::buildUnpackedRanges(
    const Symbol& sym, UHDM::BaseClass* parent,
    const std::string& defDimRefPrefix) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto* ranges = s.MakeRangeVec();
    const syntax::SyntaxNode* dsyn = sym.getSyntax();
    const Type* dt = &declared->getType().getCanonicalType();
    if (dsyn && dsyn->kind == syntax::SyntaxKind::Declarator) {
        auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
        for (auto dim : dd.dimensions) {
            if (dt->getCanonicalType().kind != SymbolKind::FixedSizeUnpackedArrayType)
                break;
            auto& ua = dt->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            auto* r = s.MakeRange();
            r->VpiParent(parent);
            setLoc(r, dim->sourceRange());
            const syntax::ExpressionSyntax* leftSyn = nullptr;
            const syntax::ExpressionSyntax* rightSyn = nullptr;
            const syntax::ExpressionSyntax* sizeSyn = nullptr;
            if (dim->specifier &&
                dim->specifier->kind == syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel = *dim->specifier->as<syntax::RangeDimensionSpecifierSyntax>().selector;
                if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                    leftSyn = rss->left;
                    rightSyn = rss->right;
                }
                else if (auto* bss = sel.as_if<syntax::BitSelectSyntax>()) {
                    sizeSyn = bss->expr;
                }
            }
            // Size-style dim [N] (== [0:N-1]): the range spans the whole [N],
            // left bound is a bare 0, and the right bound is an UNFOLDED N-1
            // operation anchored at the size-expression span.
            if (sizeSyn) {
                setLoc(r, sizeSyn->sourceRange());
                auto* lc = s.MakeConstant();
                lc->VpiParent(r);
                lc->VpiDecompile("0");
                lc->VpiSize(64);
                lc->VpiValue("UINT:0");
                lc->VpiConstType(vpiUIntConst);
                r->Left_expr(lc);
                auto* op = s.MakeOperation();
                op->VpiParent(r);
                op->VpiOpType(11);
                setLoc(op, sizeSyn->sourceRange());
                auto* ops = s.MakeAnyVec();
                // A PACKAGE FUNCTION's local unpacked array has ITS OWN
                // fold split, and it runs the OTHER WAY round from the
                // package parameters': the listing our emitPackage builds
                // with pkgEmitTopView keeps the size expression as a full
                // syntax tree -- one bare ref_obj per parameter read, no
                // fullname, BOUND to that parameter's own Rhs constant --
                // while the other listing folds it.  Measured on
                // `bit vb [(W==4)?1:-1]` + `bit vw [W]` in a package function
                // (probe p6, 75 changed lines -> 0 on this assignment,
                // inverted on the opposite one): the folding listing gives 1
                // (at the SELECTED branch's own token) and 4 (at the param's
                // type WIDTH, with a ts ref to a fresh copy of the param's
                // int_typespec).  AllPackageSignal.
                if (curPkgEmitSym && !pkgEmitTopView && defDimRefPrefix.empty() &&
                    dimFoldOwner.empty() &&
                    parent->UhdmType() == UHDM::uhdmarray_typespec &&
                    sizeSyn->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (auto* e9 = emitSyntaxExpr(*sizeSyn, op)) {
                        // emitSyntaxExpr leaves the reads unbound; Surelog
                        // resolves them in the package and points each at the
                        // parameter's Rhs constant.
                        std::function<void(UHDM::any*)> bind9 =
                            [&](UHDM::any* n9) {
                                if (!n9)
                                    return;
                                if (n9->UhdmType() == UHDM::uhdmref_obj) {
                                    auto* ro9 = (UHDM::ref_obj*)n9;
                                    if (ro9->Actual_group())
                                        return;
                                    auto sc9 = sym.getParentScope();
                                    if (!sc9)
                                        return;
                                    auto* tg9 = sc9->lookupName(
                                        std::string(ro9->VpiName()));
                                    if (!tg9)
                                        return;
                                    if (auto ai9 = paramRhsObj.find(tg9);
                                        ai9 != paramRhsObj.end() && ai9->second)
                                        ro9->Actual_group(ai9->second);
                                    return;
                                }
                                if (n9->UhdmType() == UHDM::uhdmoperation)
                                    if (auto* o9s =
                                            ((UHDM::operation*)n9)->Operands())
                                        for (auto* o9 : *o9s)
                                            bind9(o9);
                            };
                        bind9(e9);
                        ops->push_back(e9);
                        auto* one9 = s.MakeConstant();
                        one9->VpiSize(64);
                        one9->VpiValue("INT:1");
                        one9->VpiConstType(vpiIntConst);
                        ops->push_back(one9);
                        op->Operands(ops);
                        r->Right_expr(op);
                        ranges->push_back(r);
                        dt = &ua.elementType;
                        continue;
                    }
                }
                // DEF-view port array_typespec: a PARAM-sized dim ([N]) keeps
                // the size symbolic — a bare ref_obj <prefix>.N (no actual).
                if (!defDimRefPrefix.empty() &&
                    sizeSyn->kind == syntax::SyntaxKind::IdentifierName &&
                    (parent->UhdmType() == UHDM::uhdmarray_typespec ||
                     parent->UhdmType() == UHDM::uhdmio_decl ||
                     parent->UhdmType() == UHDM::uhdmparameter)) {
                    auto* ro = s.MakeRef_obj();
                    std::string nm(sizeSyn->as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText());
                    ro->VpiName(nm);
                    ro->VpiFullName(joinPath(defDimRefPrefix, nm));
                    ro->VpiParent(op);
                    setLoc(ro, sizeSyn->sourceRange());
                    // A PACKAGE def-view dim ref BINDS the sized param's own
                    // Rhs constant (Surelog resolves within the package) —
                    // DefaultPatternInt pack::V::CNT -> the CNT constant.  A
                    // MODULE dim ref stays unbound (ArrayExprFuncArg).
                    if (defDimRefPrefix.size() >= 2 &&
                        defDimRefPrefix.compare(defDimRefPrefix.size() - 2, 2,
                                                "::") == 0)
                    if (auto sc0 = sym.getParentScope())
                        if (auto* tgt0 = sc0->find(nm))
                            if (auto ai0 = paramRhsObj.find(tgt0);
                                ai0 != paramRhsObj.end() && ai0->second)
                                ro->Actual_group(ai0->second);
                    ops->push_back(ro);
                    auto* one = s.MakeConstant();
                    one->VpiSize(64);
                    one->VpiValue("INT:1");
                    one->VpiConstType(vpiIntConst);
                    // Same clone_tree shape as the folded size below: only an
                    // ELAB param dim parents its synthetic 1 (the def view and
                    // port/net dims leave it unparented).
                    if (elabParamDim)
                        one->VpiParent(op);
                    ops->push_back(one);
                    op->Operands(ops);
                    r->Right_expr(op);
                    ranges->push_back(r);
                    dt = &ua.elementType;
                    continue;
                }
                auto* sc = s.MakeConstant();
                sc->VpiParent(op);
                // A PARAM-sized dim ([DEPTH]) folds to the value at the
                // param's width, with a ts ref (loc-less signed int clone,
                // fullname = the var); literal sizes keep the raw text at 64.
                if (sizeSyn->kind != syntax::SyntaxKind::IntegerLiteralExpression &&
                    currentScope &&
                    (parent->UhdmType() == UHDM::uhdmarray_var ||
                     parent->UhdmType() == UHDM::uhdmarray_net)) {
                    std::string digits = std::to_string(ua.range.width());
                    sc->VpiDecompile(digits);
                    ASTContext bctx0(*currentScope, LookupLocation::max);
                    auto& be0 = Expression::bind(
                        *const_cast<syntax::ExpressionSyntax*>(sizeSyn), bctx0);
                    int32_t w0 = 32;
                    bool sgn0 = true;
                    if (!be0.bad() && be0.type) {
                        w0 = (int32_t)be0.type->getBitWidth();
                        sgn0 = be0.type->isSigned();
                    }
                    // § dimFoldReducedParam — but a size naming a parameter
                    // Surelog had to REDUCE (its own initializer is not a
                    // plain literal) takes the REDUCER's own output shape
                    // instead: vpiIntConst at 64 bits and NO typespec ref, the
                    // same shape that parameter's param_assign Rhs constant
                    // carries.  Scr1SvTests scr1_pipe_ifu `logic [..] q_data
                    // [SCR1_IFU_Q_SIZE_HALF]` with `localparam
                    // SCR1_IFU_Q_SIZE_HALF = SCR1_IFU_Q_SIZE_WORD * 2`:
                    // golden's dim bound is INT:4/64 bare, and the parameter's
                    // own Rhs is INT:4/64 too, while the literal-initialised
                    // `SCR1_IFU_Q_SIZE_WORD = 2` stays UINT:2 at its declared
                    // width.  A literal-initialised param keeps the width+ts
                    // shape (DefaultPatternModule `localparam int unsigned CNT
                    // = 2`).
                    bool reducedP0 = false;
                    if (!be0.bad()) {
                        auto& nv0 = stripImplicitConv(be0);
                        if (nv0.kind == ExpressionKind::NamedValue &&
                            nv0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter) {
                            auto& pp0 = nv0.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>();
                            if (auto* ie0 = pp0.getInitializer())
                                reducedP0 =
                                    stripImplicitConv(*ie0).kind !=
                                    ExpressionKind::IntegerLiteral;
                        }
                    }
                    if (reducedP0) {
                        sc->VpiSize(64);
                        sc->VpiValue("INT:" + digits);
                        sc->VpiConstType(vpiIntConst);
                        ops->push_back(sc);
                        auto* one0 = s.MakeConstant();
                        one0->VpiSize(64);
                        one0->VpiValue("INT:1");
                        one0->VpiConstType(vpiIntConst);
                        if (elabParamDim)
                            one0->VpiParent(op);
                        ops->push_back(one0);
                        op->Operands(ops);
                        r->Right_expr(op);
                        setLoc(sc, sizeSyn->sourceRange());
                        ranges->push_back(r);
                        dt = &ua.elementType;
                        continue;
                    }
                    sc->VpiSize(w0);
                    sc->VpiValue("UINT:" + digits);
                    auto* rt0 = s.MakeRef_typespec();
                    rt0->VpiFullName(std::string(
                        parent->UhdmType() == UHDM::uhdmarray_var
                            ? ((UHDM::array_var*)parent)->VpiFullName()
                            : ((UHDM::array_net*)parent)->VpiFullName()));
                    rt0->VpiParent(sc);
                    // A STRUCT-PARAM MEMBER dim (mem[pt.t]) anchors the fold
                    // at the param's DEFAULT literal (its raw decompile) and
                    // binds the SHARED struct typedef ts (Surelog).
                    UHDM::typespec* structTs0 = nullptr;
                    if (!be0.bad()) {
                        auto& ma0 = stripImplicitConv(be0);
                        if (ma0.kind == ExpressionKind::MemberAccess) {
                            auto& mb0 = stripImplicitConv(
                                ma0.as<MemberAccessExpression>().value());
                            if (mb0.kind == ExpressionKind::NamedValue &&
                                mb0.as<NamedValueExpression>().symbol.kind ==
                                    SymbolKind::Parameter) {
                                auto& psb0 = mb0.as<NamedValueExpression>()
                                                 .symbol.as<ParameterSymbol>();
                                auto d0b = psb0.getDeclaredType();
                                if (d0b &&
                                    d0b->getType().kind ==
                                        SymbolKind::TypeAlias) {
                                    auto& ta0b =
                                        d0b->getType().as<TypeAliasType>();
                                    auto& ctb0 = ta0b.getCanonicalType();
                                    if (auto tIt0 = typedefTs.find(
                                            (const Symbol*)&ta0b);
                                        tIt0 != typedefTs.end() &&
                                        ctb0.kind ==
                                            SymbolKind::PackedStructType) {
                                        // Surelog mints a PER-USE struct clone
                                        // at this folded bound (parent = the
                                        // constant's ref, member refs scoped at
                                        // the var, own logic ts at the member
                                        // ref) — NOT the shared $unit object.
                                        UHDM::typespec* sh0 = tIt0->second;
                                        std::string alias0 =
                                            std::string(rt0->VpiFullName()) +
                                            "." + std::string(ta0b.name);
                                        structCloneMemberRefParent = true;
                                        auto* scl0 = buildStructTs(
                                            ctb0.as<PackedStructType>(), true,
                                            alias0, ".");
                                        structCloneMemberRefParent = false;
                                        scl0->VpiName(ta0b.name);
                                        scl0->VpiParent(rt0);
                                        scl0->VpiFile(
                                            std::string(sh0->VpiFile()));
                                        scl0->VpiLineNo(sh0->VpiLineNo());
                                        scl0->VpiColumnNo(sh0->VpiColumnNo());
                                        scl0->VpiEndLineNo(sh0->VpiEndLineNo());
                                        scl0->VpiEndColumnNo(
                                            sh0->VpiEndColumnNo());
                                        structTs0 = scl0;
                                    }
                                }
                                if (auto* ini0 = psb0.getInitializer()) {
                                    auto& li0 = stripImplicitConv(*ini0);
                                    if (li0.kind ==
                                        ExpressionKind::IntegerLiteral) {
                                        setLoc(sc, li0.sourceRange);
                                        sc->VpiDecompile(
                                            rawText(li0.sourceRange));
                                    }
                                }
                            }
                        }
                    }
                    // Surelog attaches the folded dim constant's int_typespec
                    // ONLY when the sizing param is SIGNED (`int DEPTH` —
                    // issue326_packed_mem). An `int unsigned` sizing param
                    // (`int unsigned PMPNumChan` — hier_path) folds to a bare
                    // UINT constant with no typespec.
                    if (structTs0) {
                        rt0->Actual_typespec(structTs0);
                        sc->Typespec(rt0);
                    }
                    else if (sgn0) {
                        auto* its0 = s.MakeInt_typespec();
                        its0->VpiSigned(true);
                        rt0->Actual_typespec(its0);
                        sc->Typespec(rt0);
                    }
                    if (!be0.bad() &&
                        stripImplicitConv(be0).kind ==
                            ExpressionKind::MemberAccess &&
                        structTs0) {
                        // Skip the generic loc set below.
                        ops->push_back(sc);
                        auto* one0 = s.MakeConstant();
                        one0->VpiSize(64);
                        one0->VpiValue("INT:1");
                        one0->VpiConstType(vpiIntConst);
                        sc->VpiConstType(vpiUIntConst);
                        ops->push_back(one0);
                        op->Operands(ops);
                        r->Right_expr(op);
                        ranges->push_back(r);
                        dt = &ua.elementType;
                        continue;
                    }
                }
                // A PARAM-sized PARAMETER dim that FOLDS (package elab view,
                // and any imported copy) carries the VALUE as its decompile at
                // the sized param's own width, with a ts ref named after the
                // holder param and bound to a fresh copy of the sized param's
                // int typespec (Surelog; DefaultPatternInt).
                // ...and a PACKAGE FUNCTION's local takes the identical form
                // in the topPackages clone, only with an ANONYMOUS ts ref
                // (there is no holder parameter to name it after) -- probe p6
                // `bit vw [W]`.
                else if ((!dimFoldOwner.empty() ||
                          (curPkgEmitSym && pkgEmitTopView &&
                           defDimRefPrefix.empty() &&
                           parent->UhdmType() == UHDM::uhdmarray_typespec)) &&
                         sizeSyn->kind == syntax::SyntaxKind::IdentifierName) {
                    const ParameterSymbol* tp7 = nullptr;
                    if (auto sc7 = sym.getParentScope()) {
                        std::string nm7(
                            sizeSyn->as<syntax::IdentifierNameSyntax>()
                                .identifier.valueText());
                        auto* f7 = sc7->find(nm7);
                        // A WILDCARD-imported size param (import pack::*)
                        // is not a direct member: fall back to name lookup.
                        if (!f7)
                            f7 = sc7->lookupName(nm7);
                        if (f7 && f7->kind == SymbolKind::Parameter)
                            tp7 = &f7->as<ParameterSymbol>();
                    }
                    if (!tp7) {
                        sc->VpiDecompile(rawText(sizeSyn->sourceRange()));
                        sc->VpiSize(64);
                        sc->VpiValue("UINT:" + std::to_string(ua.range.width()));
                    }
                    else {
                        std::string d7 = std::to_string(ua.range.width());
                        sc->VpiDecompile(d7);
                        sc->VpiSize((int32_t)tp7->getType().getBitWidth());
                        sc->VpiValue("UINT:" + d7);
                        auto* rt7 = s.MakeRef_typespec();
                        rt7->VpiFullName(dimFoldOwner);
                        rt7->VpiParent(sc);
                        // A FRESH int_typespec per fold, parented at its ref
                        // and instanced at the sized param's home package
                        // (Surelog mints one per view — DefaultPatternInt).
                        auto* its7 = s.MakeInt_typespec();
                        if (tp7->getType().isSigned())
                            its7->VpiSigned(true);
                        if (auto d7t = tp7->getDeclaredType())
                            if (auto* t7s = d7t->getTypeSyntax())
                                setLoc(its7, t7s->sourceRange());
                        its7->VpiParent(rt7);
                        if (auto* hi7 = homePkgInstOf(*tp7))
                            its7->Instance(hi7);
                        rt7->Actual_typespec(its7);
                        sc->Typespec(rt7);
                    }
                }
                else {
                    sc->VpiDecompile(rawText(sizeSyn->sourceRange()));
                    sc->VpiSize(64);
                    sc->VpiValue("UINT:" + std::to_string(ua.range.width()));
                }
                sc->VpiConstType(vpiUIntConst);
                setLoc(sc, sizeSyn->sourceRange());
                // The elaborated (topPackages / import-clone) counterpart of
                // the def-listing tree above: Surelog's reduceExpr hands back
                // the SURVIVING literal, so a `?:` size collapses onto the
                // selected branch's own token -- span and decompile included
                // -- not onto the whole expression's text (probe p6,
                // AllPackageSignal's `((__prop) ? 1 : -1)`).
                if (curPkgEmitSym && pkgEmitTopView && defDimRefPrefix.empty() &&
                    dimFoldOwner.empty() &&
                    parent->UhdmType() == UHDM::uhdmarray_typespec) {
                    std::string want9 = std::to_string(ua.range.width());
                    std::function<const syntax::ExpressionSyntax*(
                        const syntax::ExpressionSyntax*)>
                        pick9 = [&](const syntax::ExpressionSyntax* e9)
                        -> const syntax::ExpressionSyntax* {
                        if (!e9)
                            return nullptr;
                        if (e9->kind == syntax::SyntaxKind::ParenthesizedExpression)
                            return pick9(
                                e9->as<syntax::ParenthesizedExpressionSyntax>()
                                    .expression);
                        if (e9->kind ==
                            syntax::SyntaxKind::ConditionalExpression) {
                            auto& ce9 =
                                e9->as<syntax::ConditionalExpressionSyntax>();
                            if (auto* l9 = pick9(ce9.left))
                                return l9;
                            return pick9(ce9.right);
                        }
                        if (e9->kind ==
                                syntax::SyntaxKind::IntegerLiteralExpression &&
                            std::string(rawText(e9->sourceRange())) == want9)
                            return e9;
                        return nullptr;
                    };
                    if (sizeSyn->kind == syntax::SyntaxKind::ConditionalExpression ||
                        sizeSyn->kind ==
                            syntax::SyntaxKind::ParenthesizedExpression)
                        if (auto* w9 = pick9(sizeSyn)) {
                            sc->VpiDecompile(rawText(w9->sourceRange()));
                            sc->VpiSize(64);
                            sc->VpiValue("UINT:" + want9);
                            setLoc(sc, w9->sourceRange());
                        }
                }
                ops->push_back(sc);
                auto* one = s.MakeConstant();
                one->VpiSize(64);
                one->VpiValue("INT:1");
                one->VpiConstType(vpiIntConst);
                if (elabParamDim)
                    one->VpiParent(op);
                ops->push_back(one);
                op->Operands(ops);
                r->Right_expr(op);
                ranges->push_back(r);
                dt = &ua.elementType;
                continue;
            }
            auto mkBound = [&](int64_t val, const syntax::ExpressionSyntax* es) -> UHDM::expr* {
                // An unpacked PARAM dim ([IFN-1:0]) referencing an OVERRIDDEN
                // param: the bound stays a SYMBOLIC op11 with a bare ref
                // <param>.<bound> — in the def view's parameter ranges and in
                // the elab array_typespec clone alike (param_array_wildcard).
                // A '::'-suffixed prefix is the DEF-PACKAGE spelling instead
                // (pkg::PARAM::N, ref BOUND to the sized param's Rhs) and is
                // built by the dedicated branch further down — this one would
                // otherwise swallow it and emit `pkg::PARAM::.N` unbound
                // (PackageEval).
                if (es && !defDimRefPrefix.empty() &&
                    !(defDimRefPrefix.size() >= 2 &&
                      defDimRefPrefix.compare(defDimRefPrefix.size() - 2, 2,
                                              "::") == 0) &&
                    (parent->UhdmType() == UHDM::uhdmparameter ||
                     parent->UhdmType() == UHDM::uhdmarray_typespec)) {
                    auto mkDimRef9 = [&](const syntax::ExpressionSyntax& is,
                                         UHDM::BaseClass* rp) {
                        auto* ro = s.MakeRef_obj();
                        std::string nm(is.as<syntax::IdentifierNameSyntax>()
                                           .identifier.valueText());
                        ro->VpiName(nm);
                        ro->VpiFullName(defDimRefPrefix + "." + nm);
                        ro->VpiParent(rp);
                        setLoc(ro, is.sourceRange());
                        return ro;
                    };
                    if (es->kind == syntax::SyntaxKind::IdentifierName)
                        return mkDimRef9(*es, r);
                    if (es->kind == syntax::SyntaxKind::SubtractExpression) {
                        auto& bs9 = es->as<syntax::BinaryExpressionSyntax>();
                        if (bs9.left->kind ==
                                syntax::SyntaxKind::IdentifierName &&
                            bs9.right->kind ==
                                syntax::SyntaxKind::IntegerLiteralExpression) {
                            auto* op9 = s.MakeOperation();
                            op9->VpiOpType(11);
                            op9->VpiParent(r);
                            setLoc(op9, es->sourceRange());
                            auto* ops9 = s.MakeAnyVec();
                            ops9->push_back(mkDimRef9(*bs9.left, op9));
                            auto* c9 = s.MakeConstant();
                            c9->VpiParent(op9);
                            c9->VpiDecompile(
                                rawText(bs9.right->sourceRange()));
                            c9->VpiSize(64);
                            c9->VpiValue(
                                "UINT:" +
                                std::string(
                                    rawText(bs9.right->sourceRange())));
                            c9->VpiConstType(vpiUIntConst);
                            setLoc(c9, bs9.right->sourceRange());
                            ops9->push_back(c9);
                            op9->Operands(ops9);
                            return (UHDM::expr*)op9;
                        }
                    }
                }
                // DEF-view array_net (interface/module def): a PARAM-based bound
                // ([0:DLY]) stays SYMBOLIC — a bare ref_obj <arraynet>.<param>
                // (no actual). The elab instance folds it to a constant.
                if (es && es->kind == syntax::SyntaxKind::IdentifierName &&
                    !defDimRefPrefix.empty() &&
                    parent->UhdmType() == UHDM::uhdmarray_net) {
                    auto* ro = s.MakeRef_obj();
                    std::string nm(es->as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText());
                    ro->VpiName(nm);
                    ro->VpiFullName(defDimRefPrefix + "." + nm);
                    ro->VpiParent(r);
                    setLoc(ro, es->sourceRange());
                    return ro;
                }
                // The DOTTED complement of the rule just above: a DEF-view
                // array_net bound that reads a STRUCT-parameter FIELD
                // (`logic dly [0:CFG.HSK.DLY]`) also stays symbolic, but as a
                // hier_path carrying one BARE ref_obj per component (no
                // fullnames, no actuals) — Surelog's `hier_path(CFG.HSK.DLY)`.
                if (dottedNameBound(es) && !defDimRefPrefix.empty() &&
                    parent->UhdmType() == UHDM::uhdmarray_net) {
                    std::vector<std::pair<std::string, slang::SourceRange>> comps;
                    const syntax::SyntaxNode* cur9 = es;
                    bool dotted9 = true;
                    while (cur9->kind == syntax::SyntaxKind::ScopedName) {
                        auto& sn9 = cur9->as<syntax::ScopedNameSyntax>();
                        if (sn9.separator.kind != parsing::TokenKind::Dot ||
                            sn9.right->kind !=
                                syntax::SyntaxKind::IdentifierName) {
                            dotted9 = false;
                            break;
                        }
                        auto& rid9 =
                            sn9.right->as<syntax::IdentifierNameSyntax>();
                        comps.emplace_back(
                            std::string(rid9.identifier.valueText()),
                            rid9.identifier.range());
                        cur9 = sn9.left;
                    }
                    if (dotted9 &&
                        cur9->kind == syntax::SyntaxKind::IdentifierName) {
                        auto& id9 = cur9->as<syntax::IdentifierNameSyntax>();
                        comps.emplace_back(
                            std::string(id9.identifier.valueText()),
                            id9.identifier.range());
                        std::reverse(comps.begin(), comps.end());
                        auto* hp9 = s.MakeHier_path();
                        std::string joined9;
                        for (size_t i9 = 0; i9 < comps.size(); i9++)
                            joined9 +=
                                (i9 ? "." : "") + comps[i9].first;
                        hp9->VpiName(joined9);
                        hp9->VpiParent(r);
                        setLoc(hp9, es->sourceRange());
                        auto* els9 = s.MakeAnyVec();
                        for (size_t i9 = 0; i9 < comps.size(); i9++) {
                            auto* ro9 = s.MakeRef_obj();
                            ro9->VpiName(comps[i9].first);
                            ro9->VpiParent(hp9);
                            // Surelog anchors the BASE component at the FIRST
                            // dotted member's token, not at its own (golden has
                            // CFG and HSK both at 13:20-13:23).
                            setLoc(ro9,
                                   comps[(i9 == 0 && comps.size() > 1) ? 1 : i9]
                                       .second);
                            els9->push_back(ro9);
                        }
                        hp9->Path_elems(els9);
                        return hp9;
                    }
                }
                // The RANGE form of the same DEF-PACKAGE rule: a package
                // parameter's own unpacked dim written [0:N-1] keeps the SUB
                // op symbolic in the DEF package listing (the elaborated
                // package copy and every import copy fold it, like the
                // [N] size form above). The ref is scoped THROUGH the owning
                // parameter (pkg::PARAM::N) and chained to the referenced
                // param's def Rhs — Surelog resolves within the package
                // (PackageEval).
                if (es && es->kind == syntax::SyntaxKind::SubtractExpression &&
                    defDimRefPrefix.size() >= 2 &&
                    defDimRefPrefix.compare(defDimRefPrefix.size() - 2, 2,
                                            "::") == 0 &&
                    parent->UhdmType() == UHDM::uhdmparameter) {
                    auto& be7 = es->as<syntax::BinaryExpressionSyntax>();
                    if (be7.left->kind == syntax::SyntaxKind::IdentifierName &&
                        be7.right->kind ==
                            syntax::SyntaxKind::IntegerLiteralExpression) {
                        std::string nm7(
                            be7.left->as<syntax::IdentifierNameSyntax>()
                                .identifier.valueText());
                        const Symbol* tgt7 = nullptr;
                        if (auto sc7 = sym.getParentScope())
                            tgt7 = sc7->find(nm7);
                        if (tgt7 && tgt7->kind == SymbolKind::Parameter) {
                            auto* op7 = s.MakeOperation();
                            op7->VpiOpType(vpiSubOp);
                            op7->VpiParent(r);
                            setLoc(op7, es->sourceRange());
                            auto* ops7 = s.MakeAnyVec();
                            auto* ro7 = s.MakeRef_obj();
                            ro7->VpiName(nm7);
                            ro7->VpiFullName(joinPath(defDimRefPrefix, nm7));
                            ro7->VpiParent(op7);
                            setLoc(ro7, be7.left->sourceRange());
                            if (auto ai7 = paramRhsObj.find(tgt7);
                                ai7 != paramRhsObj.end() && ai7->second)
                                ro7->Actual_group(ai7->second);
                            ops7->push_back(ro7);
                            auto* c7 = s.MakeConstant();
                            std::string d7(rawText(be7.right->sourceRange()));
                            c7->VpiDecompile(d7);
                            c7->VpiSize(64);
                            c7->VpiValue("UINT:" + d7);
                            c7->VpiConstType(vpiUIntConst);
                            c7->VpiParent(op7);
                            setLoc(c7, be7.right->sourceRange());
                            ops7->push_back(c7);
                            op7->Operands(ops7);
                            return op7;
                        }
                    }
                }
                // An ELAB array_net/array_var bound that is a bare PARAM
                // identifier ([0:DLY]) folds to a UINT constant (like a literal
                // bound), not the INT N-1 form — Surelog.
                bool arrParentIdBound =
                    es &&
                    (es->kind == syntax::SyntaxKind::IdentifierName ||
                     // A dotted STRUCT-PARAM field bound (CFG.HSK.DLY) folds
                     // the same way its bare-identifier sibling does.
                     dottedNameBound(es)) &&
                    (parent->UhdmType() == UHDM::uhdmarray_net ||
                     parent->UhdmType() == UHDM::uhdmarray_var) &&
                    // Only INTERFACE array bounds take the UINT form; module
                    // arrays keep the INT N-1 fold (blockrom).
                    parent->VpiParent() &&
                    parent->VpiParent()->UhdmType() ==
                        UHDM::uhdminterface_inst;
                // Literal / absent bounds: UINT at the token span. Non-literal
                // bounds (N-1) in module context fold to an INT constant
                // anchored at the top operator's LEFT operand span; in
                // function/typedef context they stay unfolded expressions.
                if (!arrParentIdBound && es &&
                    es->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (tfContext) {
                        if (auto* e = emitSyntaxExpr(*es, r))
                            return (UHDM::expr*)e;
                    }
                    else {
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        c->VpiConstType(vpiIntConst);
                        std::string digits = std::to_string(val);
                        c->VpiValue("INT:" + digits);
                        c->VpiDecompile(digits);
                        if (syntax::BinaryExpressionSyntax::isKind(es->kind))
                            setLoc(c, es->as<syntax::BinaryExpressionSyntax>().left->sourceRange());
                        else
                            setLoc(c, es->getFirstToken().range());
                        return c;
                    }
                }
                auto* c = s.MakeConstant();
                c->VpiParent(r);
                c->VpiDecompile(std::to_string(val));
                c->VpiSize(64);
                c->VpiValue("UINT:" + std::to_string(val));
                c->VpiConstType(vpiUIntConst);
                if (es)
                    setLoc(c, es->sourceRange());
                return c;
            };
            int64_t sl9 = ua.range.left, sr9 = ua.range.right;
            if (srlgBoundCallDim(leftSyn, sl9) ||
                srlgBoundCallDim(rightSyn, sr9)) {
                // Surelog's own bound values win over slang's LRM range.
            }
            r->Left_expr(mkBound((int32_t)sl9, leftSyn));
            r->Right_expr(mkBound((int32_t)sr9, rightSyn));
            ranges->push_back(r);
            dt = &ua.elementType;
        }
    }
    if (ranges->empty())
        return nullptr;
    return ranges;
}

UHDM::array_var* UhdmExporter::emitArrayVar(const Symbol& sym, const std::string& name,
                                            const std::string& fullName, UHDM::BaseClass* m,
                                            UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& ct = declared->getType().getCanonicalType();
    if (ct.kind != SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;

    // Leaf element type (for the inner reg's class and signedness).
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    bool leafSigned = leaf->isSigned();

    auto* av = s.MakeArray_var();
    av->VpiName(name);
    av->VpiFullName(fullName);
    av->VpiParent(m);
    setLoc(av, nameSpan(sym.location, sym.name));
    if (leafSigned)
        av->VpiSigned(true);
    av->VpiRandType(1);
    av->VpiVisibility(1);
    av->VpiArrayType(1);

    // Total element count = product of the unpacked dimension widths —
    // PARAM-sized ([DEPTH]) dims contribute 1 (Surelog quirk).
    int32_t total = 1;
    {
        std::vector<const syntax::VariableDimensionSyntax*> dimSyns;
        if (auto dsyn0 = sym.getSyntax();
            dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
            for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
                dimSyns.push_back(dim0);
        size_t di0 = 0;
        for (const Type* t = &declared->getType().getCanonicalType();
             t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType;) {
            auto& ua = t->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            bool paramSized = false;
            if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                dimSyns[di0]->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel0 = *dimSyns[di0]
                                  ->specifier
                                  ->as<syntax::RangeDimensionSpecifierSyntax>()
                                  .selector;
                if (auto* bss0 = sel0.as_if<syntax::BitSelectSyntax>())
                    paramSized = bss0->expr->kind !=
                                 syntax::SyntaxKind::IntegerLiteralExpression;
            }
            if (!paramSized) {
                // A $high/$low/$left/$right bound reduces to Surelog's own
                // value, so the element count follows it (SystemCallSize).
                int32_t w0 = (int32_t)ua.range.width();
                if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                    dimSyns[di0]->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel1 = *dimSyns[di0]
                                      ->specifier
                                      ->as<syntax::RangeDimensionSpecifierSyntax>()
                                      .selector;
                    if (auto* rss1 = sel1.as_if<syntax::RangeSelectSyntax>()) {
                        int64_t l1 = ua.range.left, r1 = ua.range.right;
                        if (srlgBoundCallDim(rss1->left, l1) ||
                            srlgBoundCallDim(rss1->right, r1))
                            w0 = (int32_t)((l1 > r1 ? l1 - r1 : r1 - l1) + 1);
                    }
                }
                total *= w0;
            }
            t = &ua.elementType;
            di0++;
        }
    }
    av->VpiSize(total);

    // Ranges: one per unpacked dim.
    UHDM::VectorOfrange* avRanges = buildUnpackedRanges(sym, av);
    if (avRanges)
        av->Ranges(avRanges);

    // An ENUM- or packed-STRUCT-typedef unpacked-array element: the reg is an
    // enum_var / struct_var carrying the SHARED per-use enum_typespec /
    // struct_typespec clone (parented at the module, NOT the reg — Surelog).
    // Resolve the element alias's top/def clone.
    UHDM::typespec* aggElemTs = nullptr;
    bool enumElem = false, structElem = false;
    {
        auto lck = leaf->getCanonicalType().kind;
        if (lck == SymbolKind::EnumType || lck == SymbolKind::PackedStructType) {
            const Type* leafDecl = &declared->getType();
            while (leafDecl->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leafDecl = &leafDecl->getCanonicalType()
                                .as<FixedSizeUnpackedArrayType>()
                                .elementType;
            if (leafDecl->kind == SymbolKind::TypeAlias) {
                auto& al = leafDecl->as<TypeAliasType>();
                auto want = lck == SymbolKind::EnumType
                                ? UHDM::uhdmenum_typespec
                                : UHDM::uhdmstruct_typespec;
                if (auto tit = pkgTopTypedefTs.find((const void*)&al);
                    tit != pkgTopTypedefTs.end() &&
                    tit->second->UhdmType() == want)
                    aggElemTs = tit->second;
                else if (auto tit2 = typedefTs.find(&al);
                         tit2 != typedefTs.end() &&
                         tit2->second->UhdmType() == want)
                    aggElemTs = tit2->second;
                if (aggElemTs) {
                    enumElem = lck == SymbolKind::EnumType;
                    structElem = !enumElem;
                }
            }
        }
    }

    // Inner reg: a var of the ELEMENT class (int/integer/logic) carrying the
    // element typespec (the shared net ts strips dims to the element span).
    UHDM::variables* reg;
    if (leaf->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
        auto& pit = leaf->getCanonicalType().as<PredefinedIntegerType>();
        if (pit.integerKind == PredefinedIntegerType::Integer)
            reg = s.MakeInteger_var();
        else
            reg = s.MakeInt_var();
    }
    else if (enumElem) {
        reg = s.MakeEnum_var();
    }
    else if (structElem) {
        reg = s.MakeStruct_var();
    }
    else if (leaf->getCanonicalType().isIntegral() &&
             !leaf->getCanonicalType().isFourState()) {
        // 2-STATE (bit) element: bit_var SHARING the array's dim range
        // objects (Surelog).
        reg = s.MakeBit_var();
        if (avRanges)
            ((UHDM::bit_var*)reg)->Ranges(avRanges);
    }
    else {
        reg = s.MakeLogic_var();
    }
    reg->VpiParent(av);
    setLoc(reg, nameSpan(sym.location, sym.name));
    auto* regRt = s.MakeRef_typespec();
    regRt->VpiFullName(fullName);
    regRt->VpiParent(reg);
    if (aggElemTs) {
        // The shared aggregate clone keeps its module parent; only the ref
        // links to it.
        regRt->Actual_typespec(aggElemTs);
    }
    else {
        regRt->Actual_typespec(elemTs);
        elemTs->VpiParent(reg);
    }
    reg->Typespec(regRt);
    auto* rvars = s.MakeVariablesVec();
    rvars->push_back(reg);
    av->Variables(rvars);

    // Array-pattern initializer: emitted as vpiExpr parented at the inner
    // reg, referenced by BOTH the array_var and the reg.
    if (auto init = declared->getInitializer()) {
        auto& ic = stripImplicitConv(*init);
        if (ic.kind == ExpressionKind::SimpleAssignmentPattern ||
            ic.kind == ExpressionKind::ReplicatedAssignmentPattern ||
            ic.kind == ExpressionKind::StructuredAssignmentPattern) {
            NetMap none;
            // Array-pattern leaf constants stay unparented (only the nested
            // pattern operations self-parent).
            bool savedSCP = suppressConstParent;
            suppressConstParent = true;
            if (auto* e = emitExpr(ic, reg, fullName, none)) {
                av->Expr((UHDM::expr*)e);
                reg->Expr((UHDM::expr*)e);
            }
            suppressConstParent = savedSCP;
        }
    }

    // array_typespec (unlocated, no children) — created AFTER any pattern
    // init so its arena id follows the init's typespecs.
    auto* ats = s.MakeArray_typespec();
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(fullName);
    art->VpiParent(av);
    art->Actual_typespec(ats);
    av->Typespec(art);
    arrayVarArrayTs[&sym] = ats;
    return av;
}

// The element typespec Surelog leaves on an UNELABORATED array_typespec: the
// element's own class, carrying NO span and NO signed flag (it is minted by
// CompileType from the type node alone, not from a declaration).
static UHDM::typespec* bareElemTypespec(UHDM::Serializer& s, const Type& leaf) {
    auto& c = leaf.getCanonicalType();
    if (c.kind == SymbolKind::PredefinedIntegerType) {
        switch (c.as<PredefinedIntegerType>().integerKind) {
            case PredefinedIntegerType::Int:
                return s.MakeInt_typespec();
            case PredefinedIntegerType::Integer:
                return s.MakeInteger_typespec();
            case PredefinedIntegerType::ShortInt:
                return s.MakeShort_int_typespec();
            case PredefinedIntegerType::LongInt:
                return s.MakeLong_int_typespec();
            case PredefinedIntegerType::Byte:
                return s.MakeByte_typespec();
            case PredefinedIntegerType::Time:
                return s.MakeTime_typespec();
            default:
                return nullptr;
        }
    }
    if (c.kind == SymbolKind::FloatingType)
        return c.as<FloatingType>().floatKind == FloatingType::ShortReal
                   ? (UHDM::typespec*)s.MakeShort_real_typespec()
                   : (UHDM::typespec*)s.MakeReal_typespec();
    if (c.kind == SymbolKind::StringType)
        return s.MakeString_typespec();
    if (c.isIntegral() && !c.isFourState())
        return s.MakeBit_typespec();
    if (c.isIntegral())
        return s.MakeLogic_typespec();
    return nullptr;
}

// A MODULE/INTERFACE-scope declaration carrying ANY unsized dimension
// (dynamic `[]`, associative `[idx]`, queue `[$]`) elaborates to an array_var
// — never a net or an array_net — while the DEF view keeps the plain
// logic_net (materializeDefNetTs).  Measured on a purpose-built 16-case
// golden (bit/int/logic/`logic [7:0]`/byte/integer/real/string elements x
// dyn/assoc/queue at module scope) plus DynArrayKind's four mixed-dim
// declarations:
//
//   int d [];        -> array_var{size 1, arrayType 2, reg int_var}
//   int d [][1:0];   -> ...+ one vpiRange [1:0], size 2   (outer dim erased)
//   int d [1:0][];   -> array_var{size 2, arrayType 2}    -- NO range, NO reg
//   int d [1:0][][2:0]; -> array_var{size 6, arrayType 2} -- ditto
//   int a [int];     -> arrayType 3 + array_typespec vpiIndexTypespec
//   int q [$];       -> arrayType 4
//
// So: the array KIND is the outermost UNSIZED dim's; when that dim is also
// the OUTERMOST dim of the declaration Surelog's ElaborationStep erases it
// and hands the array_var the remaining FIXED dims as vpiRange plus the
// element reg; when a FIXED dim comes first there is nothing to erase and the
// var keeps neither ranges nor reg (its dims stay on the array_typespec).
// vpiSize is the product of the fixed dims the var kept, or of ALL fixed dims
// in the leading-fixed shape.  vpiSigned rides the ARRAY (not the reg),
// vpiRandType 1 / vpiVisibility 1 always.
UHDM::array_var* UhdmExporter::emitDynArrayVar(const Symbol& sym,
                                               const std::string& name,
                                               const std::string& fullName,
                                               UHDM::BaseClass* m,
                                               UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto isUnsized = [](SymbolKind k) {
        return k == SymbolKind::DynamicArrayType ||
               k == SymbolKind::AssociativeArrayType ||
               k == SymbolKind::QueueType;
    };
    // Walk the unpacked dims outermost-first, recording each dim's kind and
    // (for fixed dims) its width.
    struct Dim {
        SymbolKind kind;
        int32_t width = 1;
        int64_t left = 0, right = 0;
        const Type* indexType = nullptr;
    };
    std::vector<Dim> dims;
    const Type* leaf = &declared->getType().getCanonicalType();
    for (;;) {
        auto& c = leaf->getCanonicalType();
        if (c.kind == SymbolKind::FixedSizeUnpackedArrayType) {
            auto& ua = c.as<FixedSizeUnpackedArrayType>();
            dims.push_back({c.kind, (int32_t)ua.range.width(), ua.range.left,
                            ua.range.right, nullptr});
            leaf = &ua.elementType;
        }
        else if (c.kind == SymbolKind::DynamicArrayType) {
            dims.push_back({c.kind, 1, 0, 0, nullptr});
            leaf = &c.as<DynamicArrayType>().elementType;
        }
        else if (c.kind == SymbolKind::QueueType) {
            dims.push_back({c.kind, 1, 0, 0, nullptr});
            leaf = &c.as<QueueType>().elementType;
        }
        else if (c.kind == SymbolKind::AssociativeArrayType) {
            auto& aa = c.as<AssociativeArrayType>();
            dims.push_back({c.kind, 1, 0, 0, aa.indexType});
            leaf = &aa.elementType;
        }
        else
            break;
    }
    size_t firstUnsized = dims.size();
    for (size_t i = 0; i < dims.size(); i++)
        if (isUnsized(dims[i].kind)) {
            firstUnsized = i;
            break;
        }
    if (firstUnsized == dims.size())
        return nullptr;  // no unsized dim: emitArrayVar's territory
    int32_t aKind = dims[firstUnsized].kind == SymbolKind::QueueType ? 4
                    : dims[firstUnsized].kind ==
                            SymbolKind::AssociativeArrayType
                        ? 3
                        : 2;
    bool leadingUnsized = firstUnsized == 0;

    auto* av = s.MakeArray_var();
    av->VpiName(name);
    av->VpiFullName(fullName);
    av->VpiParent(m);
    setLoc(av, nameSpan(sym.location, sym.name));
    if (leaf->isSigned())
        av->VpiSigned(true);
    av->VpiRandType(1);
    av->VpiVisibility(1);
    av->VpiArrayType(aKind);

    // The declarator's written dimensions, for the range spans.
    std::vector<const syntax::VariableDimensionSyntax*> dimSyns;
    if (auto dsyn = sym.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
        for (auto d : dsyn->as<syntax::DeclaratorSyntax>().dimensions)
            dimSyns.push_back(d);

    int32_t total = 1;
    UHDM::VectorOfrange* fixRanges = nullptr;
    for (size_t i = 0; i < dims.size(); i++) {
        if (dims[i].kind != SymbolKind::FixedSizeUnpackedArrayType)
            continue;
        total *= dims[i].width;
        auto* r = s.MakeRange();
        r->VpiParent(av);
        const syntax::ExpressionSyntax* lsyn = nullptr;
        const syntax::ExpressionSyntax* rsyn = nullptr;
        if (i < dimSyns.size()) {
            setLoc(r, dimSyns[i]->sourceRange());
            if (auto* spec = dimSyns[i]->specifier;
                spec && spec->kind == syntax::SyntaxKind::RangeDimensionSpecifier)
                if (auto* rss = spec->as<syntax::RangeDimensionSpecifierSyntax>()
                                    .selector->as_if<syntax::RangeSelectSyntax>()) {
                    lsyn = rss->left;
                    rsyn = rss->right;
                }
        }
        // Bounds as folded 64-bit UINT constants, spanning their own tokens.
        auto mk = [&](int64_t v, const syntax::ExpressionSyntax* bs) {
            auto* c = s.MakeConstant();
            c->VpiParent(r);
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            if (bs)
                setLoc(c, bs->sourceRange());
            return c;
        };
        r->Left_expr(mk(dims[i].left, lsyn));
        r->Right_expr(mk(dims[i].right, rsyn));
        if (!fixRanges)
            fixRanges = s.MakeRangeVec();
        fixRanges->push_back(r);
    }
    // The erased-first-dim shape hands the surviving fixed dims to the VAR;
    // the leading-fixed shape leaves them on the array_typespec (below).
    if (fixRanges && leadingUnsized)
        av->Ranges(fixRanges);
    av->VpiSize(total);

    // The element reg — only in the leading-unsized shape.
    if (leadingUnsized) {
        if (auto* reg = makeReturnVar(s, *leaf)) {
            reg->VpiParent(av);
            reg->VpiFullName(fullName);
            setLoc(reg, nameSpan(sym.location, sym.name));
            // Signedness rides the ARRAY here, not the element (measured).
            reg->VpiSigned(false);
            if (elemTs) {
                auto* rrt = s.MakeRef_typespec();
                rrt->VpiFullName(fullName);
                rrt->VpiParent(reg);
                rrt->Actual_typespec(elemTs);
                reg->Typespec(rrt);
                elemTs->VpiParent(reg);
            }
            auto* rvars = s.MakeVariablesVec();
            rvars->push_back(reg);
            av->Variables(rvars);
            // A CONCATENATION initializer (`byte b[] = {1, 1, 1}`) rides BOTH
            // the array_var and its element reg as vpiExpr — the SAME
            // operation object, parented at the REG (Surelog; UnsizedArray).
            if (auto* dtI9 = sym.getDeclaredType())
                if (auto* inI9 = dtI9->getInitializer()) {
                    auto& icI9 = stripImplicitConv(*inI9);
                    if (icI9.kind == ExpressionKind::Concatenation) {
                        NetMap none9;
                        bool savedSCP9 = suppressConstParent;
                        suppressConstParent = true;
                        if (auto* e9 = emitExpr(icI9, reg, fullName, none9)) {
                            // Bare-decimal elements size to the ELEMENT type
                            // (`byte` -> 8), not the default 64.
                            int32_t ew9 = (int32_t)leaf->getBitWidth();
                            if (ew9 > 0 && e9->UhdmType() == UHDM::uhdmoperation)
                                if (auto* os9 =
                                        ((UHDM::operation*)e9)->Operands())
                                    for (auto* o9 : *os9)
                                        if (o9->UhdmType() ==
                                                UHDM::uhdmconstant &&
                                            ((UHDM::expr*)o9)->VpiSize() == 64)
                                            ((UHDM::expr*)o9)->VpiSize(ew9);
                            av->Expr((UHDM::expr*)e9);
                            reg->Expr((UHDM::expr*)e9);
                        }
                        suppressConstParent = savedSCP9;
                    }
                }
        }
    }

    auto* ats = s.MakeArray_typespec();
    // Leading-fixed shape: the erasure pass never ran, so the declaration's
    // typespec keeps its written nesting — an OUTER array_typespec carrying
    // only the unsized dim's vpiArrayType, wrapping an inner one that holds
    // ALL the fixed ranges and the (unlocated, unsigned) element typespec.
    // uhdm-cmp walks Elem_typespec, so this is a compared difference, not
    // decoration (DynArrayKind dynamic3/dynamic4).
    if (!leadingUnsized) {
        auto* inner = s.MakeArray_typespec();
        if (fixRanges)
            inner->Ranges(fixRanges);
        if (auto* bare = bareElemTypespec(s, *leaf)) {
            auto* brt = s.MakeRef_typespec();
            brt->VpiParent(inner);
            brt->Actual_typespec(bare);
            inner->Elem_typespec(brt);
        }
        ats->VpiArrayType(aKind);
        auto* irt = s.MakeRef_typespec();
        irt->VpiParent(ats);
        irt->Actual_typespec(inner);
        ats->Elem_typespec(irt);
    }
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(fullName);
    art->VpiParent(av);
    art->Actual_typespec(ats);
    av->Typespec(art);
    // An ASSOCIATIVE array's index type lands on the array_typespec, spanning
    // the token INSIDE the brackets of its own dimension.
    if (leadingUnsized && dims[0].indexType) {
        UHDM::typespec* its = nullptr;
        auto& ick = dims[0].indexType->getCanonicalType();
        if (ick.kind == SymbolKind::StringType)
            its = s.MakeString_typespec();
        else if (ick.kind == SymbolKind::PredefinedIntegerType) {
            its = predefIntTypespec(ick, sym);
            // predefIntTypespec leaves the signed flag to its callers; an
            // `[int]` index carries it (typespec::Compare reads it).
            if (its && ick.isSigned())
                switch (its->UhdmType()) {
                    case UHDM::uhdmint_typespec:
                        ((UHDM::int_typespec*)its)->VpiSigned(true);
                        break;
                    case UHDM::uhdminteger_typespec:
                        ((UHDM::integer_typespec*)its)->VpiSigned(true);
                        break;
                    case UHDM::uhdmshort_int_typespec:
                        ((UHDM::short_int_typespec*)its)->VpiSigned(true);
                        break;
                    case UHDM::uhdmlong_int_typespec:
                        ((UHDM::long_int_typespec*)its)->VpiSigned(true);
                        break;
                    case UHDM::uhdmbyte_typespec:
                        ((UHDM::byte_typespec*)its)->VpiSigned(true);
                        break;
                    default:
                        break;
                }
        }
        else if (ick.isIntegral())
            its = s.MakeLogic_typespec();
        if (its) {
            if (!dimSyns.empty()) {
                auto dr = dimSyns[0]->sourceRange();
                setLoc(its, SourceRange(dr.start() + 1, dr.end() - 1));
            }
            auto* irt = s.MakeRef_typespec();
            irt->VpiParent(ats);
            irt->Actual_typespec(its);
            ats->Index_typespec(irt);
        }
    }
    arrayVarArrayTs[&sym] = ats;
    return av;
}

// Root ValueSymbol of an lvalue expression (unwrapping selects / member
// access / conversions down to the base named/hierarchical reference).
static const Symbol* uaLvalueRoot(const Expression& e) {
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

// Whether `target` (or a select/member-access rooted at it) is the LHS of a
// CONTINUOUS assignment in `scope`, recursing into generate blocks. Surelog
// promotes a CONTINUOUSLY-driven unpacked-array-of-packed-struct signal to an
// array_var (hier_path's `csr_pmp_cfg_i` driven by `assign x[i].m = ...`); a
// signal driven only PROCEDURALLY (ucsbece154b's `dll_d`/`dll_q` written in
// always_comb) or undriven (OneStruct's dead `memArray[8]`) stays an
// array_net.
static bool uaScopeDrives(const Scope& scope, const Symbol& target) {
    for (auto& mem : scope.members()) {
        if (mem.kind == SymbolKind::ContinuousAssign) {
            auto& asn = mem.as<ContinuousAssignSymbol>().getAssignment();
            if (asn.kind == ExpressionKind::Assignment) {
                auto& ae = asn.as<AssignmentExpression>();
                if (uaLvalueRoot(ae.left()) == &target)
                    return true;
            }
        }
        else if (mem.kind == SymbolKind::GenerateBlock) {
            if (uaScopeDrives(mem.as<GenerateBlockSymbol>(), target))
                return true;
        }
        else if (mem.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gb : mem.as<GenerateBlockArraySymbol>().entries)
                if (uaScopeDrives(*gb, target))
                    return true;
        }
    }
    return false;
}

bool UhdmExporter::unpackedArrayLeafIsNet(const Symbol& sym, bool portBacked,
                                          const UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return false;
    if (declared->getType().getCanonicalType().kind !=
        SymbolKind::FixedSizeUnpackedArrayType)
        return false;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    auto& lct = leaf->getCanonicalType();
    // Explicit variable-only leaves stay array_var.
    if (lct.kind == SymbolKind::EnumType || lct.kind == SymbolKind::FloatingType ||
        lct.kind == SymbolKind::StringType || lct.kind == SymbolKind::ClassType ||
        lct.kind == SymbolKind::PredefinedIntegerType ||
        lct.kind == SymbolKind::UnpackedStructType)
        return false;
    // A 4-state packed-struct unpacked array is a NET unless a continuous or
    // procedural assignment DRIVES it (a member/element select rooted at the
    // signal on some LHS), in which case Surelog promotes it to an array_var:
    //   - hier_path `csr_pmp_cfg_i[N]` driven by `assign x[i].m = ...` -> var
    //   - OneStruct dead `memArray[8]` (no driver) -> net
    // A declaration `= '{...}` initializer is a net-decl-assign, NOT a driver,
    // so `tl_h2d_t a[1:0] = '{...}` (IndexedPartSelectOfArrayElement) stays a
    // net.
    if (lct.kind == SymbolKind::PackedStructType) {
        // NOTE: no 2-state gate here. Surelog decides on the ONE-LEVEL member
        // typespec scan alone, so a struct whose members are all STRUCTS is a
        // net even when every leaf inside them is 2-state
        // (SelectHierPath's `IntegerRegisterWriteStageRegPath pipeReg [2]`,
        // one `BranchResult brResult` member holding one `int`). A struct
        // with a DIRECT bit/int member is already rejected by the scan below.
        // ...and only while EVERY member is logic/struct. Surelog runs the
        // struct member scan (structTsIsNetLike) BEFORE the unpacked-dimension
        // wrap, so one enum / packed-array / bit member makes the whole
        // unpacked array an array_VAR of struct_vars — tlul_pkg::tl_h2d_t's
        // `tl_d_op_e d_opcode` (PackStructVar), where the all-logic sibling
        // typedefs (OneStruct mem_s, IfGenTypeBinding pmp_cfg_t) stay nets.
        // The leaf's SHARED typedef object is what the element net/var binds
        // (emitArrayNet's lookup, repeated here); `elemTs` covers the
        // anonymous-struct leaf that has no named typedef.
        {
            const UHDM::typespec* leafTs = nullptr;
            if (elemTs && elemTs->UhdmType() == UHDM::uhdmstruct_typespec)
                leafTs = elemTs;
            else
                for (auto& [s2, tsp] : typedefTs)
                    if (s2->kind == SymbolKind::TypeAlias &&
                        &s2->as<TypeAliasType>().getCanonicalType() == &lct) {
                        leafTs = tsp;
                        break;
                    }
            if (leafTs && !structTsIsNetLike(leafTs))
                return false;
        }
        if (auto* sc = sym.getParentScope())
            if (uaScopeDrives(*sc, sym))
                return false;
        return true;
    }
    // Any other 2-STATE integral leaf (bit scalars/vectors) can never be a
    // net — array_var (Surelog).
    if (lct.isIntegral() && !lct.isFourState())
        return false;
    // A 4-state logic/reg leaf mirrors makeVar's scalar carve-out: a non-port
    // `logic` VARIABLE is a var (array_var); a `reg`, or a plain ANSI port,
    // stays a net (array_net).
    if (lct.isIntegral() && lct.isFourState()) {
        bool regDecl = false;
        if (auto tsyn = declared->getTypeSyntax())
            regDecl = tsyn->kind == syntax::SyntaxKind::RegType;
        bool isVar = (!portBacked || hasBodyDecl(sym)) && !regDecl &&
                     sym.kind == SymbolKind::Variable;
        return !isVar;
    }
    return true;
}

// The NET form of an unpacked array whose leaf is a net-type (reg memory):
// array_net { vpiSize, vpiRange x N, vpiNet = logic_net(elemTs, netType) }.
// No array_typespec / rand / visibility (unlike array_var).
UHDM::array_net* UhdmExporter::emitArrayNet(const Symbol& sym, const std::string& name,
                                            const std::string& fullName, UHDM::BaseClass* m,
                                            UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    if (declared->getType().getCanonicalType().kind !=
        SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;

    auto* an = s.MakeArray_net();
    an->VpiName(name);
    an->VpiFullName(fullName);
    an->VpiParent(m);
    setLoc(an, nameSpan(sym.location, sym.name));

    // Total element count = product of unpacked dim widths (param-sized dims
    // contribute 1, matching array_var).
    int32_t total = 1;
    {
        std::vector<const syntax::VariableDimensionSyntax*> dimSyns;
        if (auto dsyn0 = sym.getSyntax();
            dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
            for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
                dimSyns.push_back(dim0);
        size_t di0 = 0;
        for (const Type* t = &declared->getType().getCanonicalType();
             t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType;) {
            auto& ua = t->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            bool paramSized = false;
            if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                dimSyns[di0]->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel0 = *dimSyns[di0]
                                  ->specifier
                                  ->as<syntax::RangeDimensionSpecifierSyntax>()
                                  .selector;
                if (auto* bss0 = sel0.as_if<syntax::BitSelectSyntax>())
                    paramSized = bss0->expr->kind !=
                                 syntax::SyntaxKind::IntegerLiteralExpression;
            }
            if (!paramSized) {
                // A $high/$low/$left/$right bound reduces to Surelog's own
                // value, so the element count follows it (SystemCallSize).
                int32_t w0 = (int32_t)ua.range.width();
                if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                    dimSyns[di0]->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel1 = *dimSyns[di0]
                                      ->specifier
                                      ->as<syntax::RangeDimensionSpecifierSyntax>()
                                      .selector;
                    if (auto* rss1 = sel1.as_if<syntax::RangeSelectSyntax>()) {
                        int64_t l1 = ua.range.left, r1 = ua.range.right;
                        if (srlgBoundCallDim(rss1->left, l1) ||
                            srlgBoundCallDim(rss1->right, r1))
                            w0 = (int32_t)((l1 > r1 ? l1 - r1 : r1 - l1) + 1);
                    }
                }
                total *= w0;
            }
            t = &ua.elementType;
            di0++;
        }
    }
    an->VpiSize(total);

    if (auto* ranges = buildUnpackedRanges(sym, an))
        an->Ranges(ranges);

    // A struct-element array (mem_s mem[8]) carries a struct_net element whose
    // fullname DOUBLES the signal name, referencing the shared struct_typespec.
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    auto& lc = leaf->getCanonicalType();
    UHDM::typespec* structTs = nullptr;
    if (lc.kind == SymbolKind::PackedStructType) {
        for (auto& [s2, tsp] : typedefTs)
            if (s2->kind == SymbolKind::TypeAlias &&
                &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
                structTs = tsp;
                break;
            }
        // ANONYMOUS packed-struct leaf (ucsbece154b `struct packed {...}
        // dll_d[4]`): there is no named typedef ts to share, but the element
        // typespec is itself a struct_typespec — use it directly so the
        // element is still a DOUBLED-name struct_net (not a flat logic_net).
        if (!structTs && elemTs &&
            elemTs->UhdmType() == UHDM::uhdmstruct_typespec)
            structTs = elemTs;
    }
    auto* nvec = s.MakeNetVec();
    if (structTs) {
        std::string dbl = fullName + "." + name;
        auto* sn = s.MakeStruct_net();
        sn->VpiParent(an);
        sn->VpiName(name);
        sn->VpiFullName(dbl);
        // The struct_net element spans the name through the FIRST unpacked
        // dim (Surelog quirk: multi-dim arrays still stop at dim 0's end).
        SourceLocation snEnd = sym.location + sym.name.size();
        if (auto dsyn = sym.getSyntax();
            dsyn && dsyn->kind == syntax::SyntaxKind::Declarator) {
            auto& dims = dsyn->as<syntax::DeclaratorSyntax>().dimensions;
            if (!dims.empty())
                snEnd = dims[0]->sourceRange().end();
        }
        setLoc(sn, SourceRange(sym.location, snEnd));
        auto* srt = s.MakeRef_typespec();
        srt->VpiParent(sn);
        srt->VpiFullName(dbl);
        srt->Actual_typespec(structTs);
        sn->Typespec(srt);
        // The ANON shared struct ts parents at the (last) element struct_net
        // and its member refs scope through the doubled net name
        // (ucsbece154b dll_q.dll_q.tag) — last writer wins.
        if (structTs == elemTs &&
            structTs->UhdmType() == UHDM::uhdmstruct_typespec &&
            structTs->VpiName().empty()) {
            structTs->VpiParent(sn);
            if (auto* tms9 = ((UHDM::struct_typespec*)structTs)->Members())
                for (auto* tm9 : *tms9) {
                    if (!tm9->Typespec())
                        continue;
                    tm9->Typespec()->VpiFullName(
                        dbl + "." + std::string(tm9->VpiName()));
                    // Nested typedef-alias refs scope through the member
                    // (dll_q.dll_q.lru.way_index_t).
                    auto* ma9 = tm9->Typespec()->Actual_typespec();
                    if (ma9 &&
                        ma9->UhdmType() == UHDM::uhdmlogic_typespec) {
                        auto* al9 =
                            ((UHDM::logic_typespec*)ma9)->Typedef_alias();
                        if (al9 && al9->Actual_typespec())
                            al9->VpiFullName(
                                dbl + "." + std::string(tm9->VpiName()) +
                                "." +
                                std::string(
                                    al9->Actual_typespec()->VpiName()));
                    }
                }
        }
        nvec->push_back(sn);
    }
    else {
        auto* ln = s.MakeLogic_net();
        ln->VpiFullName(fullName);
        ln->VpiParent(an);
        setLoc(ln, nameSpan(sym.location, sym.name));
        if (leaf->isSigned())
            ln->VpiSigned(true);
        if (int32_t nt = netTypeFor(sym))
            ln->VpiNetType(nt);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->VpiParent(ln);
        rt->Actual_typespec(elemTs);
        ln->Typespec(rt);
        elemTs->VpiParent(ln);
        nvec->push_back(ln);
    }
    an->Nets(nvec);
    return an;
}

UHDM::packed_array_var* UhdmExporter::emitVectorTypedefArrayVar(
    const Symbol& sym, const std::string& name, const std::string& fullName,
    UHDM::instance* m) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& dt = declared->getType();
    if (dt.kind != SymbolKind::PackedArrayType)
        return nullptr;
    // Collect the ARRAY dims down to the typedef-alias element.
    std::vector<ConstantRange> arrRanges;
    const Type* t2 = &dt;
    while (t2->kind == SymbolKind::PackedArrayType) {
        arrRanges.push_back(t2->as<PackedArrayType>().range);
        t2 = &t2->as<PackedArrayType>().elementType;
    }
    if (t2->kind != SymbolKind::TypeAlias)
        return nullptr;
    auto tit = typedefTs.find(t2);
    if (tit == typedefTs.end() ||
        tit->second->UhdmType() != UHDM::uhdmlogic_typespec)
        return nullptr;
    auto* pav = s.MakePacked_array_var();
    pav->VpiName(name);
    pav->VpiFullName(fullName);
    pav->VpiParent(m);
    setLoc(pav, nameSpan(sym.location, sym.name));
    pav->VpiVisibility(1);
    // The var ts binds a PLAIN named clone (name + ranges, NO alias, NO
    // Instance — Surelog's per-var bare clone), created here. The elab pass
    // ALSO creates an enriched anonymous array ts and a NAMED alias clone
    // (Typedef_alias -> shared, module-instanced).
    UHDM::typespec* plainCl = nullptr;
    {
        auto& elAl0 = t2->as<TypeAliasType>();
        const syntax::SyntaxNode* tgtSyn0 = nullptr;
        if (auto asyn0 = elAl0.getSyntax())
            if (asyn0->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgtSyn0 = asyn0->as<syntax::TypedefDeclarationSyntax>().type;
        bypassTypedefShare = true;
        plainCl = makeTypespec(elAl0, tgtSyn0);
        bypassTypedefShare = false;
        plainCl->VpiName(elAl0.name);
        // ...except when the typedef lives in a PACKAGE: Surelog resolved the
        // type in the package's scope, so even the bare per-var clone keeps
        // vpiInstance = that package (LogicTypespec).  A module-local typedef
        // has nothing to inherit and its clone stays bare.
        if (auto* hs0 = elAl0.getParentScope();
            hs0 && hs0->asSymbol().kind == SymbolKind::Package)
            plainCl->Instance(tit->second->Instance());
    }
    (void)makeTypespec(sym);
    auto& elAl = t2->as<TypeAliasType>();
    const syntax::SyntaxNode* tgtSyn = nullptr;
    if (auto asyn = elAl.getSyntax())
        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
    bypassTypedefShare = true;
    auto* cl = makeTypespec(elAl, tgtSyn);
    bypassTypedefShare = false;
    cl->VpiName(elAl.name);
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(std::string(elAl.name));
    art->VpiParent(cl);
    art->Actual_typespec(tit->second);
    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
    cl->Instance((UHDM::instance*)m);
    auto* rt = s.MakeRef_typespec();
    rt->VpiFullName(fullName);
    rt->VpiParent(pav);
    rt->Actual_typespec(plainCl ? plainCl : tit->second);
    pav->Typespec(rt);
    // Dim spans scanned between the type-syntax start and the declarator.
    std::vector<DimSpan> spans;
    {
        SourceLocation tStart = sym.location;
        if (auto tsyn = declared->getTypeSyntax())
            tStart = tsyn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(
                std::string(rawText(SourceRange(tStart, sym.location))), tStart);
    }
    auto* rvec = s.MakeRangeVec();
    // The ELAB view folds the array dim (unlike the def-view typespec, which
    // keeps the op) but takes `reduceExpr`'s value type and anchor: a
    // sub/mult/div bound is a signed vpiIntConst spanning only its LEFTMOST
    // leaf (`[1:`SIZE-1]` -> INT:31 at the `32` token, not UINT:31 over the
    // whole `32-1`).
    auto dsynB = namedTypeDimBounds(declared->getTypeSyntax());
    for (size_t i = 0; i < arrRanges.size(); i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pav);
        const DimSpan* ds = i < spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        auto mkB = [&](int64_t v, const SourceRange* loc,
                       const syntax::ExpressionSyntax* bs) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            bool intEnc = srlgRedIntSyn(bs);
            c->VpiValue((intEnc ? "INT:" : "UINT:") + digits);
            c->VpiConstType(intEnc ? vpiIntConst : vpiUIntConst);
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            if (bs && syntax::BinaryExpressionSyntax::isKind(bs->kind)) {
                const syntax::ExpressionSyntax* lf = bs;
                while (syntax::BinaryExpressionSyntax::isKind(lf->kind))
                    lf = lf->as<syntax::BinaryExpressionSyntax>().left;
                setLoc(c, lf->getFirstToken().range());
            }
            return c;
        };
        const syntax::ExpressionSyntax* bl =
            i < dsynB.size() ? dsynB[i].first : nullptr;
        const syntax::ExpressionSyntax* br =
            i < dsynB.size() ? dsynB[i].second : nullptr;
        r->Left_expr(mkB(arrRanges[i].left, ds ? &ds->left : nullptr, bl));
        r->Right_expr(mkB(arrRanges[i].right, ds ? &ds->right : nullptr, br));
        rvec->push_back(r);
    }
    pav->Ranges(rvec);
    auto* ev = s.MakeLogic_var();
    ev->VpiParent(pav);
    ev->VpiFullName(fullName);
    auto* elems = s.MakeAnyVec();
    elems->push_back(ev);
    pav->Elements(elems);
    return pav;
}

UHDM::packed_array_var* UhdmExporter::emitPackedStructArrayVar(const Symbol& sym,
                                                               const std::string& name,
                                                               const std::string& fullName,
                                                               UHDM::instance* m) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
    // A signal declared straight from a PACKAGE packed-array typedef
    // (pkg::b c): bare packed_array_var referencing the SHARED named pkg
    // typespec — no inline ranges/elements (Surelog).
    if (declared->getType().kind == SymbolKind::TypeAlias) {
        auto& ta9 = declared->getType();
        if (auto ps9 = ta9.as<TypeAliasType>().getParentScope();
            ps9 && ps9->asSymbol().kind == SymbolKind::Package) {
            UHDM::typespec* sh9 = nullptr;
            if (auto i9 = pkgTopTypedefTs.find(&ta9);
                i9 != pkgTopTypedefTs.end() &&
                i9->second->UhdmType() == UHDM::uhdmpacked_array_typespec)
                sh9 = i9->second;
            else if (auto i8 = typedefTs.find(&ta9);
                     i8 != typedefTs.end() &&
                     i8->second->UhdmType() == UHDM::uhdmpacked_array_typespec)
                sh9 = i8->second;
            if (sh9) {
                auto* pav9 = s.MakePacked_array_var();
                pav9->VpiName(name);
                pav9->VpiFullName(fullName);
                pav9->VpiParent(m);
                setLoc(pav9, nameSpan(sym.location, sym.name));
                pav9->VpiVisibility(1);
                auto* rt9 = s.MakeRef_typespec();
                rt9->VpiFullName(fullName);
                rt9->VpiParent(pav9);
                rt9->Actual_typespec(sh9);
                pav9->Typespec(rt9);
                return pav9;
            }
        }
    }
    // Descend the packed dims to the leaf; it must be a shared struct or
    // enum typedef.
    int arrDims = 0;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
        arrDims++;
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    }
    auto& lc = leaf->getCanonicalType();
    if (lc.kind != SymbolKind::PackedStructType && lc.kind != SymbolKind::EnumType)
        return nullptr;
    UHDM::typespec* elemTs = nullptr;
    // Prefer the DECLARED alias (typedef lc_tx_e lc_tx_t used as elem type
    // resolves to lc_tx_t's clone, not the canonical enum's —
    // VarPassedTo2Submodules).
    {
        const Type* deE = &declared->getType();
        while (deE->kind != SymbolKind::TypeAlias &&
               deE->getCanonicalType().kind == SymbolKind::PackedArrayType)
            deE = &deE->getCanonicalType().as<PackedArrayType>().elementType;
        if (deE->kind == SymbolKind::TypeAlias &&
            &deE->getCanonicalType() != &lc) {
            auto& tgtE = deE->as<TypeAliasType>().targetType.getType();
            if (tgtE.getCanonicalType().kind == SymbolKind::PackedArrayType)
                deE = &tgtE.getCanonicalType()
                           .as<PackedArrayType>()
                           .elementType;
        }
        if (deE->kind == SymbolKind::TypeAlias &&
            &deE->getCanonicalType() == &lc)
            if (auto itE = typedefTs.find((const Symbol*)deE);
                itE != typedefTs.end())
                elemTs = itE->second;
    }
    if (!elemTs)
        for (auto& [s2, tsp] : typedefTs)
            if (s2->kind == SymbolKind::TypeAlias &&
                &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
                elemTs = tsp;
                break;
            }
    if (!elemTs)
        return nullptr;

    // The packed ARRAY dims (outermost-first), collected from the type walk.
    std::vector<ConstantRange> arrRanges;
    {
        const Type* t2 = &declared->getType().getCanonicalType();
        for (int i = 0; i < arrDims; i++) {
            arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
            t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
        }
    }

    auto* pav = s.MakePacked_array_var();
    pav->VpiName(name);
    pav->VpiFullName(fullName);
    pav->VpiParent(m);
    // Initialized vars span declarator..init; bare ones the name token.
    if (auto dsyn = sym.getSyntax(); dsyn && declared->getInitializer())
        setLoc(pav, dsyn->sourceRange());
    else
        setLoc(pav, nameSpan(sym.location, sym.name));
    pav->VpiVisibility(1);

    // One vpiRange per packed dim: UINT bounds located at the source dim
    // brackets (scanned between the type name and the declarator — named
    // types carry them in neither syntax node).
    std::vector<DimSpan> spans;
    if (auto tsn = declared->getTypeSyntax()) {
        auto tStart = tsn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(std::string(rawText(SourceRange(tStart, sym.location))),
                                 tStart);
    }
    auto* rvec = s.MakeRangeVec();
    for (int i = 0; i < arrDims; i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pav);
        auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            // An ENUM-CONST bound folds SIGNED at the enum width in the
            // signal view (MultirangesStartNotFromZero [s_e:n_e]).
            if (loc) {
                std::string rawB(rawText(*loc));
                bool identB = !rawB.empty() &&
                              (isalpha((unsigned char)rawB[0]) ||
                               rawB[0] == '_');
                for (char chB : rawB)
                    if (!(isalnum((unsigned char)chB) || chB == '_')) {
                        identB = false;
                        break;
                    }
                if (identB)
                    if (auto* pscB = sym.getParentScope())
                        if (auto* bsB = pscB->find(rawB);
                            bsB && bsB->kind == SymbolKind::EnumValue) {
                            c->VpiValue("INT:" + digits);
                            c->VpiConstType(vpiIntConst);
                            c->VpiSize((int32_t)bsB->as<EnumValueSymbol>()
                                           .getType()
                                           .getBitWidth());
                        }
            }
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            // An arithmetic bound (`1-1`, `NrHarts-1`, `pkg::N-1`) folds
            // with the HEAD token's span only, encoded INT (Surelog).
            if (loc) {
                if (size_t d2 = arithBoundHeadLen(std::string(rawText(*loc)))) {
                    c->VpiEndColumnNo(c->VpiColumnNo() + (int32_t)d2);
                    // Arith folds encode INT (Surelog), size stays 64.
                    c->VpiValue("INT:" + std::string(c->VpiDecompile()));
                    c->VpiConstType(vpiIntConst);
                }
            }
            return c;
        };
        const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
        r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
        rvec->push_back(r);
    }
    pav->Ranges(rvec);

    // vpiElement: a struct_var (or enum_var for enum leaves) referencing the
    // shared typedef typespec. When the element type is an ALIAS-OF-ALIAS
    // (typedef base_t; typedef base_t elem_t) Surelog emits a fresh element
    // CLONE whose fullname DOUBLES the signal name (work@m.sig.sig) and which
    // carries vpiName; a DIRECT enum/struct typedef keeps the single,
    // name-less element.
    bool aliasOfAlias = false;
    {
        const Type* de = &declared->getType();
        while (de->kind == SymbolKind::PackedArrayType)
            de = &de->as<PackedArrayType>().elementType;
        if (de->kind == SymbolKind::TypeAlias)
            aliasOfAlias = de->as<TypeAliasType>().targetType.getType().kind ==
                           SymbolKind::TypeAlias;
    }
    std::string elemFull = aliasOfAlias ? fullName + "." + name : fullName;
    UHDM::variables* sv = lc.kind == SymbolKind::EnumType
                              ? (UHDM::variables*)s.MakeEnum_var()
                              : (UHDM::variables*)s.MakeStruct_var();
    sv->VpiParent(pav);
    if (aliasOfAlias)
        sv->VpiName(name);
    sv->VpiFullName(elemFull);
    auto* srt = s.MakeRef_typespec();
    srt->VpiParent(sv);
    srt->VpiFullName(elemFull);
    srt->Actual_typespec(elemTs);
    sv->Typespec(srt);
    auto* elems = s.MakeAnyVec();
    elems->push_back(sv);
    pav->Elements(elems);

    // A pattern initializer becomes the var's vpiExpr: the operation is
    // parented at the ELEMENT struct_var (Surelog quirk), its literal
    // operands unparented.
    if (auto init = declared->getInitializer()) {
        bool savedS = suppressConstParent, savedF = forceConstParent;
        suppressConstParent = true;
        forceConstParent = false;
        NetMap noNets;
        if (auto* e = emitExpr(*init, sv, fullName, noNets)) {
            pav->Expr((UHDM::expr*)e);
            sv->Expr((UHDM::expr*)e);
            e->VpiParent(sv);
        }
        suppressConstParent = savedS;
        forceConstParent = savedF;
    }
    return pav;
}

// A packed array whose element is an enum (sp2v_e [1:0]) becomes a
// packed_array_var carrying one vpiRange per packed dim + a vpiElement
// enum_var. The typespec `ts` (already built by makeTypespec) supplies both
// the ranges (cloned with their source locs) and the shared enum_typespec.
UHDM::packed_array_var* UhdmExporter::makeEnumArrayVar(UHDM::typespec* ts,
                                                       const std::string& fullName,
                                                       UHDM::BaseClass* parent) {
    if (!ts || ts->UhdmType() != UHDM::uhdmpacked_array_typespec)
        return nullptr;
    auto* pat = (UHDM::packed_array_typespec*)ts;
    UHDM::typespec* elemTs = nullptr;
    if (auto* ert = pat->Elem_typespec())
        elemTs = ert->Actual_typespec();
    if (!elemTs || elemTs->UhdmType() != UHDM::uhdmenum_typespec)
        return nullptr;

    auto cloneLoc = [](UHDM::BaseClass* dst, const UHDM::BaseClass* src) {
        dst->VpiFile(src->VpiFile());
        dst->VpiLineNo(src->VpiLineNo());
        dst->VpiColumnNo(src->VpiColumnNo());
        dst->VpiEndLineNo(src->VpiEndLineNo());
        dst->VpiEndColumnNo(src->VpiEndColumnNo());
    };

    auto* pav = s.MakePacked_array_var();
    pav->VpiFullName(fullName);
    pav->VpiParent(parent);

    if (auto* prs = pat->Ranges()) {
        auto* rvec = s.MakeRangeVec();
        for (auto* pr : *prs) {
            auto* r = s.MakeRange();
            r->VpiParent(pav);
            cloneLoc(r, pr);
            auto cloneBound = [&](UHDM::expr* src) -> UHDM::expr* {
                auto* sc = (UHDM::constant*)src;
                auto* c = s.MakeConstant();
                c->VpiDecompile(sc->VpiDecompile());
                c->VpiSize(sc->VpiSize());
                c->VpiValue(sc->VpiValue());
                c->VpiConstType(sc->VpiConstType());
                c->VpiParent(r);
                cloneLoc(c, sc);
                return c;
            };
            if (pr->Left_expr())
                r->Left_expr(cloneBound(pr->Left_expr()));
            if (pr->Right_expr())
                r->Right_expr(cloneBound(pr->Right_expr()));
            rvec->push_back(r);
        }
        pav->Ranges(rvec);
    }

    auto* ev = s.MakeEnum_var();
    ev->VpiParent(pav);
    ev->VpiFullName(fullName);
    auto* ert = s.MakeRef_typespec();
    ert->VpiParent(ev);
    ert->VpiFullName(fullName);
    ert->Actual_typespec(elemTs);
    ev->Typespec(ert);
    auto* elems = s.MakeAnyVec();
    elems->push_back(ev);
    pav->Elements(elems);
    return pav;
}

// The NET form of a packed-array-of-struct (a child-instance PORT stays a
// net): packed_array_net (wire) + struct_net element whose fullname DOUBLES
// the signal name (work@m.d.sig.sig); the packed_array_typespec is shared
// unlocated.
// The shared struct typespec of a packed-array-of-struct-typedef signal (the
// element `emitPackedStructArrayNet` would wrap), or null when the signal has
// another shape.
UHDM::typespec* UhdmExporter::packedStructArrayElemTs(const Symbol& sym) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType)
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    auto& lc = leaf->getCanonicalType();
    if (lc.kind != SymbolKind::PackedStructType)
        return nullptr;
    for (auto& [s2, tsp] : typedefTs)
        if (s2->kind == SymbolKind::TypeAlias &&
            &s2->as<TypeAliasType>().getCanonicalType() == &lc)
            return tsp;
    return nullptr;
}

UHDM::packed_array_net* UhdmExporter::emitPackedStructArrayNet(const Symbol& sym,
                                                               const std::string& name,
                                                               const std::string& fullName,
                                                               UHDM::instance* m) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
    int arrDims = 0;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
        arrDims++;
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    }
    auto& lc = leaf->getCanonicalType();
    if (lc.kind != SymbolKind::PackedStructType)
        return nullptr;
    UHDM::typespec* elemTs = nullptr;
    for (auto& [s2, tsp] : typedefTs)
        if (s2->kind == SymbolKind::TypeAlias &&
            &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
            elemTs = tsp;
            break;
        }
    if (!elemTs)
        return nullptr;

    std::vector<ConstantRange> arrRanges;
    {
        const Type* t2 = &declared->getType().getCanonicalType();
        for (int i = 0; i < arrDims; i++) {
            arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
            t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
        }
    }

    auto* pan = s.MakePacked_array_net();
    pan->VpiName(name);
    pan->VpiFullName(fullName);
    pan->VpiParent(m);
    pan->VpiNetType(vpiWire);
    setLoc(pan, nameSpan(sym.location, sym.name));

    std::vector<DimSpan> spans;
    if (auto tsn = declared->getTypeSyntax()) {
        auto tStart = tsn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(std::string(rawText(SourceRange(tStart, sym.location))),
                                 tStart);
    }
    auto* rvec = s.MakeRangeVec();
    for (int i = 0; i < arrDims; i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pan);
        auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            // An ENUM-CONST bound folds SIGNED at the enum width in the
            // signal view (MultirangesStartNotFromZero [s_e:n_e]).
            if (loc) {
                std::string rawB(rawText(*loc));
                bool identB = !rawB.empty() &&
                              (isalpha((unsigned char)rawB[0]) ||
                               rawB[0] == '_');
                for (char chB : rawB)
                    if (!(isalnum((unsigned char)chB) || chB == '_')) {
                        identB = false;
                        break;
                    }
                if (identB)
                    if (auto* pscB = sym.getParentScope())
                        if (auto* bsB = pscB->find(rawB);
                            bsB && bsB->kind == SymbolKind::EnumValue) {
                            c->VpiValue("INT:" + digits);
                            c->VpiConstType(vpiIntConst);
                            c->VpiSize((int32_t)bsB->as<EnumValueSymbol>()
                                           .getType()
                                           .getBitWidth());
                        }
            }
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            // An arithmetic bound (`1-1`, `NrHarts-1`, `pkg::N-1`) folds
            // with the HEAD token's span only, encoded INT (Surelog).
            if (loc) {
                if (size_t d2 = arithBoundHeadLen(std::string(rawText(*loc)))) {
                    c->VpiEndColumnNo(c->VpiColumnNo() + (int32_t)d2);
                    // Arith folds encode INT (Surelog), size stays 64.
                    c->VpiValue("INT:" + std::string(c->VpiDecompile()));
                    c->VpiConstType(vpiIntConst);
                }
            }
            return c;
        };
        const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
        r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
        rvec->push_back(r);
    }
    pan->Ranges(rvec);

    // vpiElement: a struct_net whose fullname DOUBLES the signal name.
    std::string dbl = fullName + "." + name;
    auto* sn = s.MakeStruct_net();
    sn->VpiParent(pan);
    sn->VpiName(name);
    sn->VpiFullName(dbl);
    auto* srt = s.MakeRef_typespec();
    srt->VpiParent(sn);
    srt->VpiFullName(dbl);
    srt->Actual_typespec(elemTs);
    sn->Typespec(srt);
    auto* elems = s.MakeAnyVec();
    elems->push_back(sn);
    pan->Elements(elems);
    return pan;
}

} // namespace slang_uhdm
