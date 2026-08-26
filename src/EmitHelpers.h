//------------------------------------------------------------------------------
//! @file EmitHelpers.h
//! @brief File-local helpers shared by the UhdmExporter translation units
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <uhdm/uhdm.h>

#include <algorithm>
#include <cctype>
#include <charconv>
#include <functional>

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
#include "slang/ast/symbols/SubroutineSymbols.h"
#include "slang/ast/symbols/VariableSymbols.h"
#include "slang/ast/types/AllTypes.h"
#include "slang/ast/types/Type.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/text/SourceManager.h"

namespace slang_uhdm {

using namespace slang;
using namespace slang::ast;

inline constexpr int kVpiAssignmentOp = 82; // sv_vpi_user.h vpiAssignmentOp

// ---------------------------------------------------------------------------
// Surelog's `CompileHelper::adjustSize` (CompileHelper.cpp:3949), the
// vpiBinaryConst arm, ported verbatim.
//
// adjustSize is the ONE function that decides how a literal is re-encoded once
// its target width is known (it runs on cont_assign RHSs from UhdmWriter, on
// param_assign RHSs from NetlistElaboration, and on typespec bounds from
// ElaborationStep).  For a BINARY constant it takes the constant's OWN
// int_typespec as the governing type when the literal is signed, and then:
//
//   * sign bit set  -> re-encode at the target width: two's-complement INT
//     when the target is SIGNED; otherwise pad with ones up to the target
//     width and emit the decimal INT (or, above 63 bits where `strtoll`
//     saturates, keep the padded BIN string);
//   * unsized ('sb1 / 'b1 / '1) worth 1 -> the target-width all-ones mask,
//     UINT up to 64 bits and BIN beyond;
//   * anything else -> value untouched (only VpiSize is clamped, in place).
//
// Only the first two shapes CLONE the constant, so only they produce an
// elab-view object distinct from the def view; everything else keeps sharing.
// `slAdjustBinConst` reports exactly the cloning cases.
// ---------------------------------------------------------------------------

inline uint64_t slBinToU64(std::string_view b) {
    uint64_t v = 0;
    for (char c : b)
        v = (v << 1) | (uint64_t)(c == '1');
    return v;
}

inline std::string slTwosComplement(std::string_view bin) {
    int32_t n = (int32_t)bin.length();
    std::string ones;
    for (int32_t i = 0; i < n; i++)
        ones += bin[i] == '0' ? '1' : '0';
    std::string twos = ones;
    int32_t i = n - 1;
    for (; i >= 0; i--) {
        if (ones[i] == '1')
            twos[i] = '0';
        else {
            twos[i] = '1';
            break;
        }
    }
    if (i == -1)
        twos = '1' + twos;
    return twos;
}

struct SLAdjustedConst {
    std::string digits;  // decompile text == the value payload
    std::string prefix;  // "INT:" / "UINT:" / "BIN:"
    int32_t constType = 0;
    int32_t size = 0;
};

// `digits` is the constant's BIN: payload (no prefix), `origSize` its VpiSize
// (-1 for an unsized literal), `size` the target width, `signedLhs` the target
// typespec's vpiSigned.  Returns true when Surelog would clone-and-rewrite.
inline bool slAdjustBinConst(std::string_view digits, int32_t origSize,
                             bool constantIsSigned, int32_t size,
                             bool signedLhs, SLAdjustedConst& out) {
    if (digits.empty() || digits.find_first_not_of("01") != std::string_view::npos)
        return false;  // x/z: get_value fails, adjustSize does nothing
    if (size <= 0)
        return false;
    uint64_t val = slBinToU64(digits);
    if (origSize == -1) {
        // '1 / 'sb1 / 'b1: the all-ones mask at the target width.
        if (val != 1)
            return false;
        if (size <= 64) {
            uint64_t mask = size == 64 ? ~(uint64_t)0
                                       : (((uint64_t)1 << size) - 1);
            out.digits = std::to_string(mask);
            out.prefix = "UINT:";
            out.constType = vpiUIntConst;
        } else {
            out.digits = std::string((size_t)size, '1');
            out.prefix = "BIN:";
            out.constType = vpiBinaryConst;
        }
        out.size = size;
        return true;
    }
    if (!constantIsSigned || origSize <= 0)
        return false;
    // msb = val & (1 << (origSize - 1)) on the ORIGINAL width.
    bool msb = origSize <= 64 &&
               (val & ((uint64_t)1 << (uint32_t)(origSize - 1))) != 0;
    if (!msb)
        return false;
    std::string v(digits);
    int32_t orig = origSize;
    if (signedLhs) {
        const std::string res = slTwosComplement(v);
        int64_t sval = (int64_t)strtoll(res.c_str(), nullptr, 2);
        out.digits = std::to_string(-sval);
        out.prefix = "INT:";
        out.constType = vpiIntConst;
    } else {
        if (size > orig) {
            v.append((size_t)(size - orig), '1');
            orig = size;
        }
        if (size > 63) {
            out.digits = v;
            out.prefix = "BIN:";
            out.constType = vpiBinaryConst;
        } else {
            int64_t sval = (int64_t)strtoll(v.c_str(), nullptr, 2);
            out.digits = std::to_string(sval);
            out.prefix = "INT:";
            out.constType = vpiIntConst;
        }
    }
    out.size = orig < size ? orig : size;
    return true;
}

// The ELEMENT type an UNPACKED array declaration types on: fixed, dynamic and
// queue dims all live on the wrapping array_typespec, so `C q[$]` /`C d[]` /
// `C a[4]` all key on `C` (Surelog's CompileType, probe-verified in a class
// method: array_typespec { Elem_typespec -> class_typespec(C) }).
inline const Type& arrayElemLeaf(const Type& t0) {
    const Type* t = &t0;
    while (true) {
        auto& c = t->getCanonicalType();
        if (c.kind == SymbolKind::FixedSizeUnpackedArrayType)
            t = &c.as<FixedSizeUnpackedArrayType>().elementType;
        else if (c.kind == SymbolKind::DynamicArrayType)
            t = &c.as<DynamicArrayType>().elementType;
        else if (c.kind == SymbolKind::QueueType)
            t = &c.as<QueueType>().elementType;
        // An ASSOCIATIVE dim is the same shape: the index type rides the
        // wrapping array_typespec's Index_typespec and the ELEMENT is what
        // the declaration types on (BuildUVMPkg `uvm_seed_map
        // uvm_random_seed_table_lookup [string]` -> class_typespec
        // uvm_seed_map, not the logic_typespec the integral fallback gave).
        else if (c.kind == SymbolKind::AssociativeArrayType)
            t = &c.as<AssociativeArrayType>().elementType;
        else
            return *t;
    }
}

// Surelog's struct net-vs-var rule, verbatim (NetlistElaboration.cpp, the
// `ttmp == uhdmstruct_typespec` arm of elab_signal_): a struct-typed signal is
// a NET only while EVERY member's typespec is a logic_typespec or another
// struct_typespec. One enum / packed-array / bit / int / real member and the
// whole signal becomes a struct_VAR. Members carrying no actual typespec are
// skipped, exactly as Surelog's `if (const typespec* mtps = ...)` skips them.
//
// The rule reads the EMITTED typespec rather than the slang type so the two
// stay consistent by construction: whatever we decided to spell as a
// packed_array_typespec is what Surelog's writer would have seen.
//
// It governs the UNPACKED-ARRAY leaf too: the same `isNet` flag decides
// array_net vs array_var (unpackedArrayLeafIsNet).
inline bool structTsIsNetLike(const UHDM::typespec* ts) {
    if (!ts || ts->UhdmType() != UHDM::uhdmstruct_typespec)
        return true;
    auto* sts = (const UHDM::struct_typespec*)ts;
    if (!sts->Members())
        return true;
    for (auto* mem : *sts->Members()) {
        auto* mrt = mem->Typespec();
        if (!mrt)
            continue;
        auto* mts = mrt->Actual_typespec();
        if (!mts)
            continue;
        auto k = mts->UhdmType();
        if (k != UHDM::uhdmlogic_typespec && k != UHDM::uhdmstruct_typespec)
            return false;
    }
    return true;
}

// § pkgScopedPaStructStrictNetVar88 — the OTHER struct member scan Surelog
// runs, `SURELOG::Struct::isNet()` (Design/Struct.cpp:44), verbatim: the
// struct is net-like only while EVERY member's typespec is a plain
// logic_typespec.  A NESTED STRUCT member fails it, which is exactly where it
// parts company with `structTsIsNetLike` above (the elab_signal_ scan, which
// accepts logic OR struct).  A member with no typespec / no actual typespec is
// a FAILURE here, not a skip — Surelog `return false`s on both.  A non-struct
// typespec is not net-like at all (Surelog: `if (m_typespec->UhdmType() !=
// uhdmstruct_typespec) return false`), which is also what makes a typedef that
// already carries its own packed dims (a packed_array_typespec) a variable.
//
// WHICH SCAN GOVERNS IS A FUNCTION OF THE WRITTEN PACKED DIMENSIONS.  For a
// signal written `pkg::T` with NO packed dims, `elab_signal_`'s typespec
// dispatch reaches the struct_typespec arm and runs the LOOSE scan.  With
// packed dims the typespec is a packed_array_typespec, that arm is SKIPPED,
// and the only thing that ever set `isNet` is `bindStructInPackage`
// (ElaborationStep.cpp:1233), which consults THIS scan.  Hence: dims ⇒ STRICT,
// no dims ⇒ LOOSE.
inline bool structTsIsNetStrict(const UHDM::typespec* ts) {
    if (!ts || ts->UhdmType() != UHDM::uhdmstruct_typespec)
        return false;
    auto* sts = (const UHDM::struct_typespec*)ts;
    if (!sts->Members())
        return true;
    for (auto* mem : *sts->Members()) {
        auto* mrt = mem->Typespec();
        if (!mrt)
            return false;
        auto* mts = mrt->Actual_typespec();
        if (!mts)
            return false;
        if (mts->UhdmType() != UHDM::uhdmlogic_typespec)
            return false;
    }
    return true;
}

// Surelog re-lexes based literals compactly ("8'd 3" -> "8'd3"); spans that
// contain them shrink by the whitespace between the base char and the digits.
inline size_t basedLiteralSpaceCount(std::string_view text) {
    size_t n = 0;
    for (size_t i = 0; i + 1 < text.size(); i++) {
        if (text[i] != '\'')
            continue;
        size_t j = i + 1;
        if (j < text.size() && (text[j] == 's' || text[j] == 'S'))
            j++;
        if (j >= text.size())
            break;
        char b = (char)tolower(text[j]);
        if (b != 'd' && b != 'h' && b != 'b' && b != 'o')
            continue;
        for (j++; j < text.size() && (text[j] == ' ' || text[j] == '\t'); j++)
            n++;
    }
    return n;
}

// ANSI net-port headers ("input wire x") and non-ANSI net-port
// declarations ("input wire signed inp;") carry the net keyword token.
// True when a body net was declared with an explicit net-type keyword
// ("wire x", "tri y") rather than an implicit type ("logic z").
inline bool hasExplicitNetKeyword(const Symbol& sym) {
    if (sym.kind != SymbolKind::Net)
        return false;
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration)
            return p->as<syntax::NetDeclarationSyntax>().netType.valid();
        if (p->kind == syntax::SyntaxKind::DataDeclaration)
            return false;
    }
    return false;
}

// True when a BODY data declaration spells the `var` keyword
// ("var pkg::S [3:0] c;"). Surelog's elaborated signal takes the VAR shape
// then, while the same declaration written bare takes the net shape.
inline bool hasVarKeywordDecl(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind != syntax::SyntaxKind::DataDeclaration)
            continue;
        for (auto mod : p->as<syntax::DataDeclarationSyntax>().modifiers)
            if (mod.kind == parsing::TokenKind::VarKeyword)
                return true;
        return false;
    }
    return false;
}

// True when a declaration's type is written with a `::` SCOPE qualifier
// (`pkg::Struct x;`). Surelog's elaborated signal shape keys on the written
// spelling, not on where the typedef actually lives: probe-verified that
// `pkg::P1 [1:0]` elaborates as a packed_array_NET while the same typedef
// reached through `import pkg::*` (bare `P1 [1:0]`), a $unit typedef and a
// module-local typedef all elaborate as packed_array_VARs.
inline bool scopedWrittenType(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    auto* tsyn = dt ? dt->getTypeSyntax() : nullptr;
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return false;
    return tsyn->as<syntax::NamedTypeSyntax>().name->kind ==
           syntax::SyntaxKind::ScopedName;
}

// True when an ANSI port spells the `var` keyword explicitly
// ("input var logic i1"). Surelog elaborates such a port as a VARIABLE even
// though the def view keeps the generic logic_net (StandardNetVar).
inline bool ansiVarKeywordPort(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            auto& ap = p->as<syntax::ImplicitAnsiPortSyntax>();
            if (ap.header->kind == syntax::SyntaxKind::VariablePortHeader)
                return ap.header->as<syntax::VariablePortHeaderSyntax>()
                    .varKeyword.valid();
            return false;
        }
        if (p->kind == syntax::SyntaxKind::ModuleDeclaration)
            break;
    }
    return false;
}

// ---- directionless TYPED ANSI ports --------------------------------------
//
// `module m(logic a, b, c);` — an ANSI port header that gives a VARIABLE data
// type but spells NO direction keyword.  The LRM defaults the direction to
// `inout` (and an inout port must be a net), but Surelog models the signal as
// a VARIABLE, and three things follow, all measured on single-source pairs
// against `input logic a, b, c` / `wire a, b` / `input a, b`:
//
//   * the ELABORATED view lists it under vpiVariables as a logic_var (with
//     `input logic a` it stays a logic_net);
//   * the PORT carries no vpiTypedef at all (a port with an explicit
//     direction carries one even when it has no data type: `input a`);
//   * the port that syntactically CARRIES the data type is appended to the
//     definition's net list AFTER the body declarations —
//     `module m(logic a, b, logic c, d); logic rst;` gives b, d, rst, a, c.
//     Continuation ports (b, d), which inherit the header, keep their place.
//
// slang resolves the inheritance internally (AnsiPortListBuilder::addInherited
// hands a continuation port a copy of the previous header's type), so the
// syntax walk has to redo it: a header with no direction, no `var` and an
// EMPTY implicit type is a continuation of the nearest preceding port.
inline bool ansiHeaderIsInherited(const syntax::VariablePortHeaderSyntax& h) {
    if (h.direction.valid() || h.varKeyword.valid())
        return false;
    if (!h.dataType || h.dataType->kind != syntax::SyntaxKind::ImplicitType)
        return false;
    auto& it = h.dataType->as<syntax::ImplicitTypeSyntax>();
    return !it.signing.valid() && it.dimensions.empty();
}

// The header itself (already known not to be a continuation) is a
// directionless VARIABLE header.
//
// A NAMED type (`dm::hartinfo_t [N-1:0] hartinfo_i`, PortPackage) is EXCLUDED:
// Surelog keeps such a port a net (struct_net in the elab view) and keeps its
// vpiTypedef, exactly like a directed port.  Only a BUILTIN data-type keyword
// flips the port to a variable.  `var` is left to ansiVarKeywordPort, which
// already covers it and does not carry the ordering/typedef consequences.
inline bool ansiHeaderIsDirectionlessVar(const syntax::VariablePortHeaderSyntax& h) {
    if (h.direction.valid() || h.varKeyword.valid())
        return false;
    if (!h.dataType || h.dataType->kind == syntax::SyntaxKind::ImplicitType)
        return false;
    return h.dataType->kind != syntax::SyntaxKind::NamedType &&
           h.dataType->kind != syntax::SyntaxKind::TypeReference;
}

// The ImplicitAnsiPort this port's internal symbol was declared in, or null.
inline const syntax::ImplicitAnsiPortSyntax* ansiPortSyntaxOf(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            return &p->as<syntax::ImplicitAnsiPortSyntax>();
        if (p->kind == syntax::SyntaxKind::ModuleDeclaration)
            break;
    }
    return nullptr;
}

// This port syntactically CARRIES a directionless variable data type (the
// deferral key for the def-view net order).
inline bool ansiTypedVarPortHead(const Symbol& internal) {
    auto* ap = ansiPortSyntaxOf(internal);
    if (!ap || ap->header->kind != syntax::SyntaxKind::VariablePortHeader)
        return false;
    auto& h = ap->header->as<syntax::VariablePortHeaderSyntax>();
    return !ansiHeaderIsInherited(h) && ansiHeaderIsDirectionlessVar(h);
}

// This port's EFFECTIVE header (its own, or the one it continues) is a
// directionless variable header.
inline bool ansiDirectionlessVarPort(const Symbol& internal) {
    auto* ap = ansiPortSyntaxOf(internal);
    if (!ap)
        return false;
    if (ap->header->kind != syntax::SyntaxKind::VariablePortHeader)
        return false;
    auto& h = ap->header->as<syntax::VariablePortHeaderSyntax>();
    if (!ansiHeaderIsInherited(h))
        return ansiHeaderIsDirectionlessVar(h);
    // Continuation: walk back to the nearest preceding port that owns a
    // header and answer for that one.
    const syntax::SyntaxNode* list = ap->parent;
    if (!list)
        return false;
    const syntax::ImplicitAnsiPortSyntax* owner = nullptr;
    for (size_t ci = 0; ci < list->getChildCount(); ci++) {
        const syntax::SyntaxNode* cn = list->childNode(ci);
        if (!cn)
            continue;
        if (cn == (const syntax::SyntaxNode*)ap)
            break;
        if (cn->kind != syntax::SyntaxKind::ImplicitAnsiPort)
            continue;
        auto& cp = cn->as<syntax::ImplicitAnsiPortSyntax>();
        if (cp.header->kind != syntax::SyntaxKind::VariablePortHeader) {
            owner = nullptr; // a net/interface header owns the run
            continue;
        }
        if (!ansiHeaderIsInherited(
                cp.header->as<syntax::VariablePortHeaderSyntax>()))
            owner = &cp;
    }
    if (!owner)
        return false;
    return ansiHeaderIsDirectionlessVar(
        owner->header->as<syntax::VariablePortHeaderSyntax>());
}

inline const syntax::NetPortHeaderSyntax* ansiNetHeader(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            auto& ap = p->as<syntax::ImplicitAnsiPortSyntax>();
            if (ap.header->kind == syntax::SyntaxKind::NetPortHeader) {
                auto& nh = ap.header->as<syntax::NetPortHeaderSyntax>();
                if (nh.netType.valid())
                    return &nh;
                return nullptr;
            }
            // A CONTINUATION declarator (output wire [3:0] a, b, c: slang
            // gives b/c a bare VariablePortHeader with no direction) of a NET
            // port inherits the nearest PRECEDING port's explicit net header.
            if (internal.kind == SymbolKind::Net &&
                ap.header->kind == syntax::SyntaxKind::VariablePortHeader &&
                !ap.header->as<syntax::VariablePortHeaderSyntax>()
                     .direction.valid() &&
                p->parent) {
                const syntax::SyntaxNode* list = p->parent;
                const syntax::NetPortHeaderSyntax* found = nullptr;
                for (size_t ci = 0; ci < list->getChildCount(); ci++) {
                    const syntax::SyntaxNode* cn = list->childNode(ci);
                    if (!cn)
                        continue;
                    if (cn == p)
                        return found;
                    if (cn->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
                        auto& ap2 = cn->as<syntax::ImplicitAnsiPortSyntax>();
                        if (ap2.header->kind == syntax::SyntaxKind::NetPortHeader) {
                            auto& nh2 =
                                ap2.header->as<syntax::NetPortHeaderSyntax>();
                            found = nh2.netType.valid() ? &nh2 : nullptr;
                        }
                        else if (ap2.header->kind ==
                                     syntax::SyntaxKind::VariablePortHeader &&
                                 !ap2.header
                                      ->as<syntax::VariablePortHeaderSyntax>()
                                      .direction.valid()) {
                            // Another continuation: chain unchanged.
                        }
                        else {
                            found = nullptr;
                        }
                    }
                }
            }
            return nullptr;
        }
        if (p->kind == syntax::SyntaxKind::PortDeclaration) {
            auto& pd = p->as<syntax::PortDeclarationSyntax>();
            if (pd.header->kind == syntax::SyntaxKind::NetPortHeader) {
                auto& nh = pd.header->as<syntax::NetPortHeaderSyntax>();
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
// A signal whose declared type is written as a bare identifier that resolves
// to a `parameter type T` — Surelog models these ports specially (def-view net
// with no net type + type-param default typespec; elab-view logic_var).
inline const TypeParameterSymbol* portTypeParam(const Symbol& internal) {
    auto* dt = internal.getDeclaredType();
    if (!dt)
        return nullptr;
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return nullptr;
    auto& nt = tsyn->as<syntax::NamedTypeSyntax>();
    if (nt.name->kind != syntax::SyntaxKind::IdentifierName)
        return nullptr;
    auto name = nt.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
    auto* scope = internal.getParentScope();
    if (!scope)
        return nullptr;
    auto* sym = scope->find(std::string(name));
    if (sym && sym->kind == SymbolKind::TypeParameter)
        return &sym->as<TypeParameterSymbol>();
    return nullptr;
}

// The `parameter type T` a TypeAliasType IS, or null for a real typedef.
// slang models every type parameter as a same-named TypeAliasType in the
// parameter's own scope (TypeParameterSymbol's ctor), whose syntax node is the
// declarator (`TypeAssignment`), never a `TypedefDeclaration` — so a type
// parameter overridden with ANOTHER type parameter arrives at the emitter
// looking exactly like a typedef override. r10c15.
inline const TypeParameterSymbol* typeParamOfAlias(const TypeAliasType& ta) {
    auto* syn = ta.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::TypeAssignment)
        return nullptr;
    auto* sc = ta.getParentScope();
    if (!sc)
        return nullptr;
    for (auto& mem : sc->members())
        if (mem.kind == SymbolKind::TypeParameter &&
            &mem.as<TypeParameterSymbol>().getTypeAlias() == (const Type*)&ta)
            return &mem.as<TypeParameterSymbol>();
    return nullptr;
}

// § typeParamRetIsRefVar58 — THE PREDICATE.  A declaration whose written type
// is a TYPE PARAMETER is a bare `ref_var` in golden, WHATEVER the parameter is
// bound to, with the ONE exception of a CLASS binding (then `class_var`).  See
// include/UhdmExporter.h for the law, the decoded Surelog mechanism and every
// measured cell; the gate lives at the top of makeReturnVar below, which is the
// single factory our return vars, our subroutine-body locals, our block locals
// and our non-integral for-loop variables all come out of.
//
// GATE, and it is exactly Surelog's: TypeAlias + `TypeAssignment` syntax (the
// only syntax kind that spells a type-parameter assignment, and never a
// `typedef` — see typeParamOfAlias above) + the canonical type is NOT a
// ClassType.  Deliberately NOT a scope walk: typeParamOfAlias's members() loop
// answers the same question but costs a scope scan per declaration, and the
// syntax kind alone is what § assocIdxTypeParamNoIndexTs51 already gates on.
inline bool typeParamVarIsRefVar58(const Type& declType) {
    if (declType.kind != SymbolKind::TypeAlias)
        return false;
    auto* syn = declType.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::TypeAssignment)
        return false;
    // A CLASS binding keeps its class_var: Surelog reaches it through
    // compileTypespec's class_typespec arm (CompileType.cpp:386-400), the one
    // branch of compileVariable that fires BEFORE the ref_var fallthrough.
    return declType.getCanonicalType().kind != SymbolKind::ClassType;
}

// NOTE § assocIdxTypeParamNoIndexTs51 — the PREDICATE of the pass-51 law.
// An ASSOCIATIVE dimension whose index type was written as a TYPE PARAMETER
// gets NO `vpiIndexTypespec` in golden, at ANY site and in EITHER view.
//
// Direction: SUPPRESS.  Gate: the index type is a `TypeAlias` whose syntax node
// is a `TypeAssignment` — i.e. it is a type PARAMETER's alias, never a
// `typedef` (see typeParamOfAlias above; `TypeAssignment` is the discriminator
// and the only syntax kind that spells a type-parameter assignment).
//
// WHY THE GATE IS THIS AND NOT "written as a NAME" (proved, arm a1/a2/a3, LHS
// golden / RHS ours): a TYPEDEF-name index is associative in golden and DOES
// carry an index typespec — a1 `int pt_pool[myint51]` -> golden
// `int_typespec (myint51) @13:11`.  Only a type PARAMETER is suppressed.
// Surelog's dimension compiler resolves the bracket name in the parameter map
// first, so a type parameter comes out as the SIZE expression `<name>-1` on a
// vpiStaticArray and never as an index type (the same shape
// § assocIoRange9 already models at the subroutine site).
//
// NOT VIEW-SCOPED — arm a3 is the decider: `sub51 #(.MK(string))` gives MK a
// REAL type in the ELABORATED view and golden STILL emits no index typespec
// there (golden's only two index typespecs in a3 are the `[string]` control,
// one per view).  So the suppression is unconditional on the view and on
// whether the parameter was overridden.
inline bool assocIdxIsTypeParam51(const Type& idx) {
    if (idx.kind != SymbolKind::TypeAlias)
        return false;
    auto* syn = idx.getSyntax();
    return syn && syn->kind == syntax::SyntaxKind::TypeAssignment;
}

// NOTE § assocIdxNameHoistNet135 — WHICH bracket name Surelog fails to resolve,
// and therefore compiles as an EXPRESSION that joins the late-binding pool and
// mints the importing module's implicit wire.
//
// `CompileHelper::compileRanges`'s `paConstant_expression` arm
// (Surelog src/DesignCompile/CompileExpression.cpp:4166-4196) hands the bracket
// text to `compileExpression`, whose first stop is `getObject`
// (`CompileExpression.cpp:237-260`):
//     const DataType *dtype = component->getDataType(name);
//     if ((result == nullptr) && dtype) { ... result = dtype->getTypespec(); }
// A `typedef` — of anything: an int, a vector, an enum, even a CLASS HANDLE —
// is in that map, so the name comes back AS A TYPESPEC and no `ref_obj` is ever
// minted.  A CLASS NAME is not (classes live in the class-definition map), and
// neither is a TYPE PARAMETER's name, so both fall through to the identifier
// arm at `:5769-5788`, take `needLateBinding` and hoist.  A SCOPED name
// (`pkg::T`) is resolved by the class-scope arm (`:4463-4519`,
// `p->getDataType(typeName)`) and never reaches the identifier arm either.
//
// MEASURED, grid arm `g135_a1.sv` (ONE home, ONE position, twelve spellings),
// golden `work@topKindBeta135`:
//   [baseGammaCls135]                        a CLASS name           -> WIRE
//   [fwdRhoCls135]                           a FORWARD-typedef'd class -> WIRE
//   [KEYBRAVO135] (arm a4)                   a TYPE PARAMETER       -> WIRE
//   [tdEtaHandle135]  typedef of a class handle                     -> none
//   [tdLambdaInt135]  typedef of `int`                              -> none
//   [tdNuVec135]      typedef of a vector                           -> none
//   [enumIotaKind135] an enum typedef                               -> none
//   [pkgScopedSigma135::scopedTauCls135]  a SCOPED class name       -> none
//   [pkgScopedSigma135::scopedUpsEnum135] a SCOPED enum typedef     -> none
//   [string] [int] [*] [paramMuCls135#(int)]  never a name at all   -> none
// so the gate is NOT "written as a NAME" (which is § assocIoRange9's RANGE-SHAPE
// question, and stays exactly as it was): it is "written as a BARE IDENTIFIER
// THAT IS NOT A TYPEDEF".  A first cut that used the shape test minted six
// wires golden does not have.
inline bool assocIdxNameHoistable135(const Type& idx,
                                     const syntax::ExpressionSyntax* sx) {
    if (!sx || sx->kind != syntax::SyntaxKind::IdentifierName)
        return false;
    if (idx.kind != SymbolKind::TypeAlias)
        return true;
    return assocIdxIsTypeParam51(idx);
}

// § assocPropPatternInitRidesElem31, CLAUSE (3)'s GATE — the predicate that
// decides WHICH direct constant operand of an unsized array's declaration
// initializer takes the ELEMENT width.  Clause (3) says "wherever emitExpr
// left the bare-decimal DEFAULT of 64", and this is that condition written
// out, because `VpiSize() == 64` alone is NOT it: a literal the source WROTE
// 64 bits wide (`64'd9`) and a REAL constant (`shortreal r[] = '{1.0}`) also
// arrive at 64, and golden keeps BOTH at 64 — Surelog's
// `compileAssignmentPattern` sizes only the constants that had no written
// width.  Measured against Surelog on the verifier's arms
// tools/probe/r10vbuvm31repro/{gv31a1,gv31a7,gv31a8}.sv:
//   int  d[]  = '{64'd9, 64'd8}   golden 64 / 64      (WRITTEN width kept)
//   int  q[$] = '{9, 64'd4}       golden 32 / 64      (mixed, per operand)
//   byte b[]  = '{64'd9}          golden 64           (NOT the element width)
//   int  c[]  = {1, 64'd9}        golden 32 / 64      (concatenation, same)
//   shortreal s[] = '{1.0, 2.0}   golden 64 / 64      (real, NOT 32)
//   int  d[]  = '{1, 2, 3}        golden 32 32 32     (bare decimal -> element)
//   bit [2:0] j[] = '{1, 2, 3}    golden  3  3  3
// so the gate is: an UNSIGNED-INTEGER constant (`vpiUIntConst`, which is what
// emitExpr stamps on a bare decimal and never on a based literal or a real)
// still carrying the default 64, whose decompile has no base tick.  Without
// it the resize walks onto `64'd9` and shrinks a field golden had right.
inline bool bareDecimalDefault64_31(const UHDM::any* o) {
    if (!o || o->UhdmType() != UHDM::uhdmconstant)
        return false;
    const auto* c = (const UHDM::constant*)o;
    if (c->VpiSize() != 64 || c->VpiConstType() != vpiUIntConst)
        return false;
    return std::string_view(c->VpiDecompile()).find('\'') ==
           std::string_view::npos;
}

// A declaration whose type is named through an explicit `other_pkg::T`
// qualification: the shared typespec belongs to THAT package and every
// vpiInstance / span stamp made while emitting the USING package must leave it
// alone (Surelog creates the object once, in its declaring package —
// PackFunc). `home` is the package currently being emitted; null outside one.
inline bool foreignPkgTypedef(const Symbol& declSym, const Symbol* home) {
    auto* dt = declSym.getDeclaredType();
    if (!home || !dt || dt->getType().kind != SymbolKind::TypeAlias)
        return false;
    auto* sc = dt->getType().getParentScope();
    return sc && sc->asSymbol().kind == SymbolKind::Package &&
           &sc->asSymbol() != home;
}

// § r10fsv3 S5.  Surelog cannot size an enum declared with NO base type
// (`typedef enum { A, B } e;`) — the same blind spot § r10fsv2 R-c measured on
// pattern substitution — so such a member contributes ZERO bits to the packed
// width of a struct that contains it.  This returns the width Surelog computes
// for `t`: slang's, minus every base-less enum member, recursively.
// FuncStructVal's `cva6_cfg_t` is the measurement: slang says 10131 bits and
// golden's elaborated `cva6_cfg_empty = '0` is BIN:0 at 10099 — exactly the
// 32-bit `noc_type_e NOCType` member removed.
inline uint64_t slPackedWidth(const Type& t0) {
    const Type* t = &t0.getCanonicalType();
    if (t->kind == SymbolKind::EnumType) {
        auto* syn = t->getSyntax();
        if (syn && syn->kind == syntax::SyntaxKind::EnumType &&
            syn->as<syntax::EnumTypeSyntax>().baseType == nullptr)
            return 0;
        return t->getBitWidth();
    }
    if (t->kind == SymbolKind::PackedStructType) {
        uint64_t w = 0;
        for (auto& f : t->as<PackedStructType>().membersOfType<FieldSymbol>())
            w += slPackedWidth(f.getType());
        return w;
    }
    if (t->kind == SymbolKind::PackedUnionType) {
        uint64_t w = 0;
        for (auto& f : t->as<PackedUnionType>().membersOfType<FieldSymbol>())
            w = std::max(w, slPackedWidth(f.getType()));
        return w;
    }
    if (t->kind == SymbolKind::PackedArrayType) {
        auto& pa = t->as<PackedArrayType>();
        return slPackedWidth(pa.elementType) * pa.range.width();
    }
    return t->getBitWidth();
}

// The set of local types passed as `type` parameter arguments to child
// instances of `body` — a module-local net of such a type omits its def-view
// typespec (Surelog leaves it a bare logic_net; the elab view re-types it).
inline void collectTypeParamArgTypes(const InstanceBodySymbol& body,
                                     std::set<const Type*>& out) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        for (auto& cm : member.as<InstanceSymbol>().body.members()) {
            if (cm.kind != SymbolKind::TypeParameter)
                continue;
            auto& tp = cm.as<TypeParameterSymbol>();
            if (!tp.isOverridden())
                continue;
            out.insert(&tp.targetType.getType());
        }
    }
}

// The integer-vector KEYWORD a (possibly chained) typedef was written with --
// `reg`/`logic`/`bit`, or Unknown for anything else.  Surelog carries the
// written keyword through the alias chain: `typedef reg [1:0] R; R y;` is a
// vpiReg(48) net exactly like `reg [1:0] y;`, while the same typedef spelled
// `logic` gives vpiNet(36) and a logic_var (LogicTypedef, plus a 4-case
// typedef/typedef-of-typedef probe).
inline syntax::SyntaxKind aliasVectorKeyword(const Type& t) {
    const Type* cur = &t;
    for (int guard = 0; guard < 32; guard++) {
        while (cur->kind == SymbolKind::PackedArrayType)
            cur = &cur->as<PackedArrayType>().elementType;
        if (cur->kind != SymbolKind::TypeAlias)
            return syntax::SyntaxKind::Unknown;
        auto& ta = cur->as<TypeAliasType>();
        if (auto* tsyn = ta.targetType.getTypeSyntax())
            if (tsyn->kind == syntax::SyntaxKind::RegType ||
                tsyn->kind == syntax::SyntaxKind::LogicType ||
                tsyn->kind == syntax::SyntaxKind::BitType)
                return tsyn->kind;
        cur = &ta.targetType.getType();
    }
    return syntax::SyntaxKind::Unknown;
}

inline int32_t netTypeFor(const Symbol& internal, bool defView = false) {
    // A `parameter type T`-typed port carries no net type (Surelog).
    if (portTypeParam(internal))
        return 0;
    if (internal.kind == SymbolKind::Net) {
        // Implicitly-declared nets (created by an undeclared name in an assign
        // or port connection) print as a bare wire.
        if (internal.as<NetSymbol>().isImplicit)
            return vpiWire;
        // DEF view only (net_types; the ELAB/top view keeps real kinds):
        // a PREDEFINED-INTEGER net (wire integer x) prints NO net type; a
        // net declared via a MODULE-LOCAL vector typedef prints 36
        // regardless of wire/wand/wor.
        if (auto* dt0 = internal.getDeclaredType(); dt0 && defView) {
            if (dt0->getType().getCanonicalType().kind ==
                SymbolKind::PredefinedIntegerType)
                return 0;
            if (dt0->getType().kind == SymbolKind::TypeAlias) {
                auto& ta1 = dt0->getType().as<TypeAliasType>();
                auto ck1 = ta1.targetType.getType().getCanonicalType().kind;
                if (auto ps1 = ta1.getParentScope();
                    ps1 &&
                    ps1->asSymbol().kind != SymbolKind::Package &&
                    (ck1 == SymbolKind::PackedArrayType ||
                     ck1 == SymbolKind::ScalarType))
                    return 36;
            }
        }
        // A PREDEFINED-INTEGER ANSI net-port (input wire integer x) prints
        // NO net type in every view; a BODY declaration keeps its kind in
        // the elab view (Surelog).
        if (auto* dt0 = internal.getDeclaredType())
            if (dt0->getType().getCanonicalType().kind ==
                    SymbolKind::PredefinedIntegerType &&
                ansiNetHeader(internal) != nullptr)
                return 0;
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
        // An ANSI net-PORT header whose net keyword is followed by an explicit
        // integer-vector data type ("input wire logic [2:0] sw") is a *typed*
        // port declaration: Surelog's port Signal keeps the DATA type in
        // m_type and demotes the net keyword to m_subNetType, and UhdmWriter
        // derives vpiNetType from m_type alone -- so `logic` wins and the net
        // prints vpiLogicNet(36), not vpiWire(1).  Fall through to the
        // declared-type arm below, which already maps LogicType -> vpiNet.
        // A BODY net declaration ("wire logic w;", "wand logic x;") is built
        // by a different Signal path and keeps its NET keyword (u2r net_types
        // measures wire/wand/wor logic at 1/2/3).  WireLogicSize.
        bool typedNetDecl = false;
        if (ansiNetHeader(internal) != nullptr)
            if (auto* dt1 = internal.getDeclaredType())
                if (auto* ts1 = dt1->getTypeSyntax())
                    typedNetDecl = ts1->kind == syntax::SyntaxKind::LogicType ||
                                   ts1->kind == syntax::SyntaxKind::RegType;
        if (explicitDecl && !typedNetDecl) {
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
            // Typedefs of plain logic vectors keep the logic net type —
            // except PACKAGE typedefs, which print none (their ports become
            // logic_vars in the elab view).
            if (tsyn->kind == syntax::SyntaxKind::NamedType) {
                auto& t = declared->getType();
                auto& ct = t.getCanonicalType();
                // A packed array whose LEAF is a struct (filter_ctl_t [1:0])
                // carries no net type.
                const Type* leaf0 = &ct;
                while (leaf0->getCanonicalType().kind == SymbolKind::PackedArrayType)
                    leaf0 = &leaf0->getCanonicalType()
                                 .as<PackedArrayType>()
                                 .elementType;
                if (leaf0->getCanonicalType().isStruct())
                    return 0;
                if ((ct.kind == SymbolKind::PackedArrayType ||
                     ct.kind == SymbolKind::ScalarType) &&
                    ct.isFourState()) {
                    // SCOPED pkg-typedef references (pkg::T x, pkg::T [1:0] x)
                    // print none; an IMPORTED unqualified name (import
                    // pkg::T; output T o) behaves like a local typedef and
                    // keeps vpiNet. Descend packed dims to the leaf alias.
                    //
                    // § unqualDimNet9 — an unqualified name CARRYING PACKED
                    // DIMS (`pad_pok_t [3:0] pad_pok`) parses as an
                    // IdentifierSelectName, not an IdentifierName: slang hangs
                    // a named type's packed dims off the NAME, not off the
                    // type syntax (see the same note in TypeEmit's array
                    // branch).  Reading only IdentifierName made every such
                    // declaration look SCOPED and dropped its vpiNetType.
                    // Purpose-built golden (PackedArrayHighConn v4 repro):
                    // `import pkg::*; pad_pok_t [3:0] pad_pok;` -> 36, while
                    // `pkg::pad_pok_t [3:0] pad_pok;` -> none.
                    const Type* la = &t;
                    while (la->kind == SymbolKind::PackedArrayType)
                        la = &la->as<PackedArrayType>().elementType;
                    if (la->kind == SymbolKind::TypeAlias &&
                        tsyn->as<syntax::NamedTypeSyntax>().name->kind !=
                            syntax::SyntaxKind::IdentifierName &&
                        tsyn->as<syntax::NamedTypeSyntax>().name->kind !=
                            syntax::SyntaxKind::IdentifierSelectName)
                        if (auto sc = la->as<TypeAliasType>().getParentScope();
                            sc && sc->asSymbol().kind == SymbolKind::Package)
                            return 0;
                    // A `reg`-written typedef nets as vpiReg, not vpiNet.
                    if (aliasVectorKeyword(t) == syntax::SyntaxKind::RegType)
                        return vpiReg;
                    return vpiNet;
                }
            }
        }
    }
    return 0;
}

// § genConnOperatorActual (r10earl6) — the same two maps keyed on the SYNTAX
// node instead of the bound AST operator, for the def-view gen-block
// instantiation loop, which has no AST to read (it emits from the syntax tree
// alone).  TypeEmit keeps private copies for range bounds; these are the
// subset the port-connection arm needs, in one place both can reach.
inline int32_t mapSynUnaryOp9(slang::syntax::SyntaxKind k) {
    using slang::syntax::SyntaxKind;
    switch (k) {
        case SyntaxKind::UnaryLogicalNotExpression:
            return vpiNotOp;
        case SyntaxKind::UnaryBitwiseNotExpression:
            return vpiBitNegOp;
        case SyntaxKind::UnaryMinusExpression:
            return vpiMinusOp;
        case SyntaxKind::UnaryPlusExpression:
            return vpiPlusOp;
        case SyntaxKind::UnaryBitwiseAndExpression:
            return vpiUnaryAndOp;
        case SyntaxKind::UnaryBitwiseNandExpression:
            return vpiUnaryNandOp;
        case SyntaxKind::UnaryBitwiseOrExpression:
            return vpiUnaryOrOp;
        case SyntaxKind::UnaryBitwiseNorExpression:
            return vpiUnaryNorOp;
        case SyntaxKind::UnaryBitwiseXorExpression:
            return vpiUnaryXorOp;
        case SyntaxKind::UnaryBitwiseXnorExpression:
            return vpiUnaryXNorOp;
        default:
            return 0;
    }
}

inline int32_t mapSynBinaryOp9(slang::syntax::SyntaxKind k) {
    using slang::syntax::SyntaxKind;
    switch (k) {
        case SyntaxKind::AddExpression:
            return vpiAddOp;
        case SyntaxKind::SubtractExpression:
            return vpiSubOp;
        case SyntaxKind::MultiplyExpression:
            return vpiMultOp;
        case SyntaxKind::DivideExpression:
            return vpiDivOp;
        case SyntaxKind::ModExpression:
            return vpiModOp;
        case SyntaxKind::LogicalShiftLeftExpression:
            return vpiLShiftOp;
        case SyntaxKind::LogicalShiftRightExpression:
            return vpiRShiftOp;
        case SyntaxKind::ArithmeticShiftLeftExpression:
            return vpiArithLShiftOp;
        case SyntaxKind::ArithmeticShiftRightExpression:
            return vpiArithRShiftOp;
        case SyntaxKind::GreaterThanExpression:
            return vpiGtOp;
        case SyntaxKind::GreaterThanEqualExpression:
            return vpiGeOp;
        case SyntaxKind::LessThanExpression:
            return vpiLtOp;
        case SyntaxKind::LessThanEqualExpression:
            return vpiLeOp;
        case SyntaxKind::EqualityExpression:
            return vpiEqOp;
        case SyntaxKind::InequalityExpression:
            return vpiNeqOp;
        case SyntaxKind::LogicalAndExpression:
            return vpiLogAndOp;
        case SyntaxKind::LogicalOrExpression:
            return vpiLogOrOp;
        case SyntaxKind::BinaryAndExpression:
            return vpiBitAndOp;
        case SyntaxKind::BinaryOrExpression:
            return vpiBitOrOp;
        case SyntaxKind::BinaryXorExpression:
            return vpiBitXorOp;
        default:
            return 0;
    }
}

inline int32_t mapUnaryOp(UnaryOperator op) {
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

inline int32_t mapBinaryOp(BinaryOperator op) {
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

// Collects one representative instance per definition, recursively.
// `uninstDefNames`, when given, additionally collects the DEFINITION NAMES
// reached only through a NON-TAKEN generate branch: Surelog compiles every
// parsed module, so such a module still carries a def view in
// design->AllModules (HierPathEval: work@GOOD, referenced only from
// gen_inner_if_true, which is false). slang marks those definitions referenced,
// so getUnreferencedDefinitions() never reports them, and inside an
// uninstantiated scope the instantiation is an UninstantiatedDefSymbol that
// carries only the NAME -- hence names, resolved by the caller.
inline void collectDefs(const InstanceBodySymbol& body,
                        std::map<std::string, const InstanceSymbol*>& defs,
                        std::set<std::string>* uninstDefNames = nullptr) {
    // An INSTANCE ARRAY (myif arr[N], producer p[N]) is an InstanceArraySymbol
    // whose elements are the per-index InstanceSymbols (or nested arrays) — its
    // definition must be collected too, else the interface/module def is
    // dropped from AllInterfaces/AllModules entirely.
    // Definition harvest inside a non-taken generate branch: def views only,
    // never instance bodies (the bodies are uninstantiated).
    std::function<void(const Symbol&)> visitUninst = [&](const Symbol& m) {
        if (m.kind == SymbolKind::Instance)
            uninstDefNames->insert(std::string(m.as<InstanceSymbol>().getDefinition().name));
        else if (m.kind == SymbolKind::UninstantiatedDef)
            uninstDefNames->insert(
                std::string(m.as<UninstantiatedDefSymbol>().definitionName));
        else if (m.kind == SymbolKind::InstanceArray) {
            for (auto* e : m.as<InstanceArraySymbol>().elements)
                visitUninst(*e);
        }
        else if (m.kind == SymbolKind::GenerateBlock ||
                 m.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gm : m.as<Scope>().members())
                visitUninst(gm);
        }
    };
    std::function<void(const Symbol&)> visit = [&](const Symbol& member) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            auto name = std::string(child.getDefinition().name);
            if (defs.emplace(name, &child).second)
                collectDefs(child.body, defs, uninstDefNames);
        }
        else if (member.kind == SymbolKind::InstanceArray) {
            for (auto* e : member.as<InstanceArraySymbol>().elements)
                visit(*e);
        }
        // Instances INSIDE generate blocks (begin:foo mod_a a(...); end) —
        // their defs must reach AllModules too. Non-taken branches don't.
        else if (member.kind == SymbolKind::GenerateBlock) {
            if (!member.as<GenerateBlockSymbol>().isUninstantiated) {
                for (auto& gm : member.as<Scope>().members())
                    visit(gm);
            }
            else if (uninstDefNames) {
                for (auto& gm : member.as<Scope>().members())
                    visitUninst(gm);
            }
        }
        else if (member.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gm : member.as<Scope>().members())
                visit(gm);
        }
    };
    for (auto& member : body.members())
        visit(member);
}

// Finds the named port connection syntax for a formal port name, so locations
// can anchor at the ".a(o)" text like Surelog.
inline const syntax::NamedPortConnectionSyntax* findConnSyntax(const InstanceSymbol& inst,
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

// The `.*` wildcard port connection of an instantiation, if it has one.
// Surelog does NOT expand `.*`: CompileHelper::compileHighConn sees a
// paDOTSTAR formal name and emits ONE nameless port whose High_conn is a
// constant carrying VpiValue "STRING:.*" / VpiDecompile ".*" (no VpiSize, no
// VpiConstType), spanning the Port_connection node — CompileHelper.cpp:2946.
// slang, by contrast, materialises a PortConnection per implicitly-connected
// port, so the wildcard has to be recognised from the syntax.
inline const syntax::WildcardPortConnectionSyntax* findWildcardConn(
    const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return nullptr;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections)
        if (conn->kind == syntax::SyntaxKind::WildcardPortConnection)
            return &conn->as<syntax::WildcardPortConnectionSyntax>();
    return nullptr;
}

// § macroLocOrder — the compilation's SourceManager, published for the free
// helpers below.  Set once by the UhdmExporter constructor.
//
// Why a helper needs it: comparing two SourceLocations with `<`/`>=` orders
// them by BUFFER ID first, and slang assigns buffer ids as buffers are
// created — including MACRO EXPANSION buffers, created when expansion is
// reached during a PARALLEL parse.  So the ordering between two locations
// from different buffers is not reproducible across runs of the same binary
// on the same sources.  Any helper that must reason about "is this location
// inside that range" therefore has to map macro locations back to their
// fully-original file location first, and only then compare.
inline const slang::SourceManager* helperSM = nullptr;

// The originating FILE location of `loc`: a macro-expansion location maps back
// to the macro USE site's original file location, which is stable across runs.
inline slang::SourceLocation origLoc(slang::SourceLocation loc) {
    if (!helperSM || loc == slang::SourceLocation::NoLocation)
        return loc;
    if (helperSM->isMacroLoc(loc))
        return helperSM->getFullyOriginalLoc(loc);
    return loc;
}

// True when a parameter's bound initializer is an instance override (its
// syntax differs from the declaration-default initializer syntax).
inline const syntax::ExpressionSyntax* paramDefaultSyn(const ParameterSymbol& ps) {
    if (auto dsyn = ps.getSyntax()) {
        if (dsyn->kind == syntax::SyntaxKind::Declarator) {
            auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
            if (dd.initializer)
                return dd.initializer->expr;
        }
    }
    return nullptr;
}
// True for a parameter-port-list entry written WITHOUT the `parameter` /
// `localparam` keyword — the grammar's `data_type list_of_param_assignments`
// form (`module m #( int unsigned XLEN = 32 )`), an IMPLICIT parameter. slang
// leaves ParameterDeclarationSyntax::keyword invalid for it, so the test is
// exact. Surelog re-creates these AFTER the body params in the elaborated
// instance (see the rank comment in emitParameters).
inline bool isImplicitPortParam(const ParameterSymbol& ps) {
    if (!ps.isPortParam())
        return false;
    auto* n = ps.getSyntax();
    // Declarator -> SeparatedSyntaxList -> ParameterDeclaration.
    for (int i = 0; n && i < 4; i++, n = n->parent) {
        if (n->kind != syntax::SyntaxKind::ParameterDeclaration)
            continue;
        return !n->as<syntax::ParameterDeclarationSyntax>().keyword;
    }
    return false;
}
inline bool isOverriddenParam(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto& ps = sym.as<ParameterSymbol>();
    auto* defaultSyn = paramDefaultSyn(ps);
    auto* bi = ps.getInitializer();
    if (!bi || !defaultSyn)
        return false;
    auto dr = defaultSyn->sourceRange();
    // The bound initializer's source span: its syntax node if present (a
    // PARENTHESIZED default binds to the inner expr, so the node differs from
    // the default's paren node), else the folded expression's range.
    SourceRange br = bi->syntax ? bi->syntax->sourceRange() : bi->sourceRange;
    if (br.start() == SourceLocation::NoLocation ||
        dr.start() == SourceLocation::NoLocation)
        return bi->syntax && bi->syntax != defaultSyn;
    // § macroLocOrder — compare ORIGINAL file locations.  Both spans here can
    // begin inside a MACRO EXPANSION buffer, and expansion-buffer ids are
    // assigned during a parallel parse, so the raw `>=`/`<=` ordering between
    // two such locations is not reproducible run to run.  Scr1SvTests
    // `parameter SCR1_TCM_SIZE = `SCR1_IMEM_AWIDTH'h00010000`, overridden at
    // scr1_top_axi.sv:367 with ``SCR1_DMEM_AWIDTH'(~SCR1_TCM_ADDR_MASK +
    // 1'b1)``, has a macro location at BOTH ends: roughly one run in six
    // called that override a DEFAULT, which put the override expression in
    // scr1_tcm's DEF view and dropped the parameter's value AND typespec —
    // the whole design's first uhdm-cmp failure, appearing and disappearing
    // between identical runs of the same binary.  Mapping each endpoint back
    // to its macro USE site makes the comparison stable AND correct: the use
    // sites are in the two real files, which the parse orders deterministically.
    SourceLocation bs = origLoc(br.start()), be = origLoc(br.end());
    SourceLocation ds = origLoc(dr.start()), de = origLoc(dr.end());
    // Different buffers cannot nest, and asking `>=` across them would just
    // reintroduce an id comparison — a span from another file is an override.
    if (bs.buffer() != ds.buffer() || be.buffer() != de.buffer())
        return true;
    // A default (even parenthesized) has its tokens WITHIN the declaration
    // default's range; a real override binds syntax from the instantiation,
    // OUTSIDE that range.
    if (bs >= ds && be <= de)
        return false;
    return true;
}

// True when a LOCALPARAM's initializer is a COMPUTED (non-literal) expression:
// e.g. `localparam W = $clog2(DATA_WIDTH)`. Surelog keeps a def-view packed
// range that references such a localparam UNFOLDED (op(ref W - 1)), just like
// it does for overridden params, because the folded bound is not a plain
// source literal. Restricted to LOCALPARAMs: an overridable module parameter
// with a computed default (`parameter W = $clog2(N)`) still FOLDS in Surelog's
// range (for_loop_nonconst_bound, multiple_blocking) — only the immutable
// localparam form is kept symbolic. Literal-init (`localparam W = 32`) folds.
inline bool paramInitIsComputed(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto& ps = sym.as<ParameterSymbol>();
    if (!ps.isLocalParam())
        return false;
    const Expression* bi = ps.getInitializer();
    if (!bi)
        return false;
    // Unwrap implicit/explicit conversions (int cast around $clog2, etc.).
    const Expression* e = bi;
    while (e->kind == ExpressionKind::Conversion)
        e = &e->as<ConversionExpression>().operand();
    switch (e->kind) {
        case ExpressionKind::IntegerLiteral:
        case ExpressionKind::UnbasedUnsizedIntegerLiteral:
        case ExpressionKind::RealLiteral:
            return false;
        default:
            return true;
    }
}

// Data-type syntax kinds that can appear as a cast target.
inline bool isTypeSyntaxKind(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::LogicType:
        case syntax::SyntaxKind::BitType:
        case syntax::SyntaxKind::RegType:
        case syntax::SyntaxKind::ByteType:
        case syntax::SyntaxKind::ShortIntType:
        case syntax::SyntaxKind::IntType:
        case syntax::SyntaxKind::LongIntType:
        case syntax::SyntaxKind::IntegerType:
        case syntax::SyntaxKind::TimeType:
        case syntax::SyntaxKind::ShortRealType:
        case syntax::SyntaxKind::RealType:
        case syntax::SyntaxKind::RealTimeType:
        case syntax::SyntaxKind::StructType:
        case syntax::SyntaxKind::UnionType:
        case syntax::SyntaxKind::EnumType:
            return true;
        default:
            return false;
    }
}

// § castTargetKeywordTypespecKind96 (r10uvm96) — AN EXPLICIT CAST'S TARGET
// TYPESPEC KIND IS A PURE FUNCTION OF THE KEYWORD WRITTEN LEFT OF THE `'`.
//
// Surelog's cast arm (CompileExpression.cpp:2636, `paCast`/`paConstant_cast`)
// hands the casting-type node straight to `CompileHelper::compileTypespec`,
// whose keyword cases (CompileType.cpp:1480) funnel into
// `compileBuiltinTypespec` (CompileType.cpp:1126) — a switch on the PARSE NODE,
// never on any computed type.  Measured cell-by-cell on purpose-built golden
// (`g96_a1_keywords.sv`, one `$display(<kw>'(q))` per keyword):
//
//   real       -> real_typespec          shortreal -> short_real_typespec
//   realtime   -> time_typespec          time      -> time_typespec
//   integer    -> integer_typespec       longint   -> long_int_typespec
//   shortint   -> short_int_typespec     int       -> int_typespec
//   byte       -> byte_typespec          bit       -> bit_typespec
//   logic/reg  -> logic_typespec         string    -> string_typespec
//   N'         -> integer_typespec (the size-cast road, INT:<N>)
//
// `compileBuiltinTypespec` opens with `bool isSigned = true` and only an
// explicit `unsigned` clears it, so the five INTEGER ATOMS carry vpiSigned:1
// while real / shortreal / time / realtime / bit / logic carry NO signedness at
// all — measured in the golden's own top-level typespec listing.
//
// Our two cast-typespec mint sites (ExprEmit's fallback and ModuleEmit's
// deferred `pendingCastTs` drain) keyed on the SLANG TYPE instead, which
// collapses every `PredefinedIntegerType` onto `int_typespec` and every
// non-integral keyword onto the catch-all `logic_typespec`.  This helper
// restores the WRITTEN-KEYWORD dispatch for exactly the kinds that collapse;
// it returns nullptr for every other syntax kind so the callers' existing arms
// (int / byte / bit / logic / reg / string / size / typedef / struct / enum,
// all already equal to golden across both corpora) are reached UNCHANGED.
inline UHDM::typespec* castKeywordTypespec96(UHDM::Serializer& s,
                                             syntax::SyntaxKind k,
                                             bool srcSigned) {
    switch (k) {
        case syntax::SyntaxKind::RealType:
            return s.MakeReal_typespec();
        case syntax::SyntaxKind::ShortRealType:
            return s.MakeShort_real_typespec();
        // `realtime` and `time` are ONE typespec kind in Surelog: the
        // `paNonIntType_RealTime` case (CompileType.cpp:2041) and the
        // `paIntegerAtomType_Time` case both mint `time_typespec`, neither
        // stamping signedness.
        case syntax::SyntaxKind::RealTimeType:
        case syntax::SyntaxKind::TimeType:
            return s.MakeTime_typespec();
        case syntax::SyntaxKind::IntegerType: {
            auto* t = s.MakeInteger_typespec();
            t->VpiSigned(srcSigned);
            return t;
        }
        case syntax::SyntaxKind::LongIntType: {
            auto* t = s.MakeLong_int_typespec();
            t->VpiSigned(srcSigned);
            return t;
        }
        case syntax::SyntaxKind::ShortIntType: {
            auto* t = s.MakeShort_int_typespec();
            t->VpiSigned(srcSigned);
            return t;
        }
        default:
            return nullptr;
    }
}

// True when the instance's connection list is positional (ordered).
inline bool hasOrderedConns(const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return false;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections)
        if (conn->kind == syntax::SyntaxKind::OrderedPortConnection)
            return true;
    return false;
}

// A `net_lvalue` in the 1800 grammar: a (possibly hierarchical, possibly
// selected) identifier, or a concatenation of those.  Nothing else --
// literals, operations, calls and replications are all excluded.
inline bool isNetLvalueSyntax(const syntax::ExpressionSyntax& e) {
    switch (e.kind) {
        case syntax::SyntaxKind::IdentifierName:
        case syntax::SyntaxKind::IdentifierSelectName:
        case syntax::SyntaxKind::ScopedName:
        case syntax::SyntaxKind::MemberAccessExpression:
        case syntax::SyntaxKind::ElementSelectExpression:
        case syntax::SyntaxKind::ConcatenationExpression:
            return true;
        default:
            return false;
    }
}

// Surelog's parser resolves `foo f(a, b);` as a **udp_instantiation**, not a
// module_instantiation: with an ordered connection list of two or more
// terminals whose first parses as a `net_lvalue` (the UDP output), the
// udp_instantiation alternative matches and ANTLR takes it -- whether or not
// a UDP named `foo` exists.  CompileModule then routes the item to
// compileUdpInstantiation, which builds NO `ref_module`, so the definition
// view of the parent carries no child reference at all.  Measured on a
// ten-shape probe: `i(x,y)`, `i(x,y,z)`, `i(x, y&z)` and `i({x,y}, z)` are
// UDPs; `.a(x)` named lists, a non-net_lvalue FIRST terminal (`i(x&y, z)`,
// `i(1'b0, z)`), an empty terminal (`i(x, , z)`) and single-terminal lists
// all stay module_instantiations and keep their ref_module.
//
// A `#(...)` override does NOT by itself break the shape: `delay2 ::= # (
// mintypmax_expression [, mintypmax_expression] )` swallows an ORDERED list
// of one or two values, so `sub #(1) i(x,y)`, `sub #(1,2) i(x,y)` and
// `Example #("FOO") e2(a,b,c,d)` are all UDPs.  Three or more values, or any
// NAMED override, exceed delay2 and leave a module_instantiation (measured).
inline bool udpShapedInstantiation(const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return false;
    auto& hi = syn->as<syntax::HierarchicalInstanceSyntax>();
    if (hi.connections.size() < 2)
        return false;
    const syntax::ExpressionSyntax* firstExpr = nullptr;
    for (auto conn : hi.connections) {
        if (conn->kind != syntax::SyntaxKind::OrderedPortConnection)
            return false;
        // A port connection's expression is wrapped in the property/sequence
        // shells the assertion grammar shares with it.
        const syntax::PropertyExprSyntax* pe =
            conn->as<syntax::OrderedPortConnectionSyntax>().expr;
        if (!pe || pe->kind != syntax::SyntaxKind::SimplePropertyExpr)
            return false;
        const syntax::SequenceExprSyntax* se =
            pe->as<syntax::SimplePropertyExprSyntax>().expr;
        if (!se || se->kind != syntax::SyntaxKind::SimpleSequenceExpr)
            return false;
        const syntax::ExpressionSyntax* e =
            se->as<syntax::SimpleSequenceExprSyntax>().expr;
        // An empty terminal (`i(x, , z)`) is not a UDP instance.
        if (!e || e->getFirstToken().isMissing())
            return false;
        if (!firstExpr)
            firstExpr = e;
    }
    // A `#(...)` override survives only while it still reads as delay2.
    for (auto p = syn->parent; p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::HierarchyInstantiation) {
            auto* pva = p->as<syntax::HierarchyInstantiationSyntax>().parameters;
            if (pva) {
                if (pva->parameters.size() > 2)
                    return false;
                for (auto pa : pva->parameters)
                    if (pa->kind != syntax::SyntaxKind::OrderedParamAssignment)
                        return false;
            }
            break;
        }
        if (p->kind == syntax::SyntaxKind::ModuleDeclaration)
            break;
    }
    return firstExpr && isNetLvalueSyntax(*firstExpr);
}

// True when the expression tree contains anything Surelog's netlist
// elaboration would re-compile as an operation (which forces a fresh
// cont_assign object in the instance view instead of sharing the def's).
inline bool containsOperation(const Expression& expr) {
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
        case ExpressionKind::Call: {
            // User function calls are reused as-is; sys calls inside
            // recompiled expressions force a fresh cont_assign - except the
            // transparent signedness casts $signed/$unsigned, which are shared.
            auto& call = expr.as<CallExpression>();
            if (!call.isSystemCall())
                return false;
            auto n = call.getSubroutineName();
            // Built-in METHOD calls (a.getc(i): no leading $) are shared,
            // as are the transparent casts and sampled-value functions.
            if (n.empty() || n[0] != '$')
                return false;
            return n != "$signed" && n != "$unsigned" && n != "$fell" &&
                   n != "$rose" && n != "$stable" && n != "$past";
        }
        case ExpressionKind::SimpleAssignmentPattern:
        case ExpressionKind::StructuredAssignmentPattern:
        case ExpressionKind::ReplicatedAssignmentPattern:
            return true;
        default:
            return false;
    }
}

// Port connection expressions for output ports come wrapped in an assignment;
// the connected expression is its left side.
inline const Expression* connectionExpr(const PortConnection& conn) {
    auto expr = conn.getExpression();
    if (expr && expr->kind == ExpressionKind::Assignment)
        expr = &expr->as<AssignmentExpression>().left();
    return expr;
}

// Refs inside package scopes keep :: separators all the way down.
//
// § scopeRootedPathKeepsColons41 — "inside a package scope" is a property of
// the path's ROOT, not of any `::` anywhere in it.  The rule is therefore:
// keep `::` only when the FIRST `::` comes BEFORE the first `.`, i.e. when the
// path is ROOTED in a scoped name; once a `.` has been taken first, the path is
// a HIERARCHY and a `::` appearing later is just a qualified NAME inside one
// segment.  FOUR golden cells fix it, and only this rule satisfies all four:
//
//   A  aes_pkg::aes_circ_byte_shift.in   + s      `::` first  -> `::`
//        golden aes_pkg::aes_circ_byte_shift::in::s
//   B  work@foo::set                     + body   `::` only   -> `::`
//        golden work@foo::set::body        (uhdm2rtlil test `OneThis`)
//   C  work@Receiver::start.bytes         + size  `::` first  -> `::`
//        golden work@Receiver::start::bytes::size (surelog test `SVSwitch`)
//   D  work@prim_prince.gen_fwd_pass[1].
//      prim_cipher_pkg::PRINCE_ROUND_CONST + k    `.`  first  -> `.`
//        golden ...prim_cipher_pkg::PRINCE_ROUND_CONST.k
//
// Cell D is the one § pkgWrittenQualSelBase41 creates: before it, no prefix
// with a `.` BEFORE its first `::` ever reached this function, so the old
// blanket "any `::` anywhere" rule was never exercised on that shape and every
// index ref under a qualified select came out `...pkg::X::k`.  TWO wrong
// repairs were measured and discarded before this one — "test `work@`" broke
// cell B and was caught by the ROW GATE (`OneThis` dump match->differ), and
// "`work@` AND dotted" broke cell C and was caught by the BYTE VERIFIER
// (`SVSwitch`, both modes, -5 bytes).  All four cells are kept here so the
// next edit cannot break one silently.
inline std::string joinRef(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    const size_t c41 = prefix.find("::");
    const size_t d41 = prefix.find('.');
    if (c41 != std::string::npos && (d41 == std::string::npos || c41 < d41))
        return prefix + "::" + std::string(name);
    return prefix + "." + std::string(name);
}

inline std::string joinPath(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    return prefix + "." + std::string(name);
}

// The location Surelog gives a typespec: the declared type's syntax range for
// explicit types, or a zero-width range at the declaration's *first*
// declarator for implicit types (shared across all declarators).
inline SourceLocation firstDeclaratorLoc(const Symbol& sym) {
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

// Surelog's net collection order: nets from body net/data declarations and
// ANSI headers sort by declaration location; nets declared only through
// non-ANSI port declarations append afterwards in port-list order.
inline bool hasBodyDecl(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration ||
            p->kind == syntax::SyntaxKind::DataDeclaration)
            return true;
        if (p->kind == syntax::SyntaxKind::PortDeclaration ||
            p->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            return false;
    }
    return false;
}

inline bool hasExplicitDeclLoc(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration ||
            p->kind == syntax::SyntaxKind::DataDeclaration ||
            p->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            return true;
        if (p->kind == syntax::SyntaxKind::PortDeclaration)
            return false;
    }
    return false;
}

// A non-ANSI header port written `.X1(internal)`: the port names itself and
// the expression names what it connects to. Surelog keeps the two apart — the
// PORT mints a net of its own name at the port-name location, while the
// expression's symbol keeps the net (and gains the port) of its declaration.
// A plain `(a)` header port shares one identity and is NOT explicit.
inline bool isExplicitNonAnsiPort(const PortSymbol& ps) {
    auto syn = ps.getSyntax();
    return !ps.isAnsiPort && !ps.isNullPort && syn && syn->parent &&
           syn->parent->kind == syntax::SyntaxKind::ExplicitNonAnsiPort;
}

// ...and the same port written over a CONCATENATION rather than one symbol
// (`module top(.op({\op[79] ,\op[78] }))`, `module c(.a({b, c}))`), which
// slang gives back as a MultiPortSymbol over one sub-PortSymbol per operand.
// Surelog splits it exactly as it splits `.X1(y)` — the port mints a net of
// its own name, and every operand keeps its declared net and earns a port of
// its own — so the operands' symbols ARE this port's internals. Returned in
// source order, empty when the port is not that shape. An UNNAMED port
// (`module f({a, b})`) is deliberately excluded: Surelog compiles that one
// through its signal-list path and lands a different (and self-inconsistent)
// net/port set.
inline std::vector<const Symbol*> portExprSymbols(const Symbol& pb) {
    std::vector<const Symbol*> out;
    if (pb.kind != SymbolKind::MultiPort || pb.name.empty())
        return out;
    auto& mp = pb.as<MultiPortSymbol>();
    if (mp.isNullPort)
        return out;
    for (auto* sp : mp.ports) {
        if (!sp || !sp->internalSymbol)
            return {};
        out.push_back(sp->internalSymbol);
    }
    return out;
}

// `module f({a, b}); input a, b;` — an UNNAMED concatenation header port of
// exactly TWO simple identifiers. Surelog's non-ANSI port parser does not read
// this as a concatenation at all: it reads `a b` as an INTERFACE PORT
// declaration, signal `b` of interface type `a`. Everything odd about the
// golden follows from that one reading and nothing else does — the header
// contributes only signal `b` (anchored at the SECOND identifier, 46:14, not
// at its `input a, b;` declaration), the def-view port `b` binds `module a` as
// its LowConn actual, the elab view carries an `interface_inst work@a` named
// `b`, and `a` earns its port from the declaration alone, AFTER `b`. Returns
// {typeName-symbol, port-symbol} = {a, b}, or {nullptr, nullptr}.
// Deliberately narrow: two operands, both plain identifiers, and the first
// must name a design unit (that is what makes Surelog bind an instance).
inline std::pair<const Symbol*, const Symbol*> unnamedConcatIfacePort(
    const Symbol& pb) {
    if (pb.kind != SymbolKind::MultiPort || !pb.name.empty())
        return {nullptr, nullptr};
    auto& mp = pb.as<MultiPortSymbol>();
    if (mp.isNullPort || mp.ports.size() != 2)
        return {nullptr, nullptr};
    if (!mp.ports[0] || !mp.ports[1] || !mp.ports[0]->internalSymbol ||
        !mp.ports[1]->internalSymbol)
        return {nullptr, nullptr};
    return {mp.ports[0]->internalSymbol, mp.ports[1]->internalSymbol};
}

// slang has no PortConnection for a concatenation header port: it SPLITS the
// actual across the operand sub-ports, so `.a({x,y})` becomes one sliced
// connection per sub-port and the written actual is gone from the AST. This
// maps each of those sub-ports back to the MultiPortSymbol they belong to, so
// a connection list can be collapsed to the header ports Surelog writes.
inline std::map<const Symbol*, const Symbol*> multiPortOwners(
    const InstanceSymbol& inst) {
    std::map<const Symbol*, const Symbol*> out;
    for (auto pb : inst.body.getPortList()) {
        if (pb->kind != SymbolKind::MultiPort ||
            (portExprSymbols(*pb).empty() && !unnamedConcatIfacePort(*pb).first))
            continue;
        for (auto* sp : pb->as<MultiPortSymbol>().ports)
            if (sp)
                out[sp] = pb;
    }
    return out;
}

// The connection actual AS WRITTEN, unwrapped from the property/sequence
// shells the port-connection grammar puts around it.
inline const syntax::ExpressionSyntax* connActualSyntax(
    const syntax::PropertyExprSyntax* pe) {
    const syntax::SyntaxNode* sn = pe;
    if (sn && sn->kind == syntax::SyntaxKind::SimplePropertyExpr)
        sn = sn->as<syntax::SimplePropertyExprSyntax>().expr;
    if (sn && sn->kind == syntax::SyntaxKind::SimpleSequenceExpr)
        sn = sn->as<syntax::SimpleSequenceExprSyntax>().expr;
    if (sn && syntax::ExpressionSyntax::isKind(sn->kind))
        return &sn->as<syntax::ExpressionSyntax>();
    return nullptr;
}

// ...the same, over a whole body: the header's single unnamed concat port.
inline std::pair<const Symbol*, const Symbol*> unnamedConcatIfacePort(
    const InstanceBodySymbol& body) {
    for (auto pb : body.getPortList())
        if (auto pr = unnamedConcatIfacePort(*pb); pr.first)
            return pr;
    return {nullptr, nullptr};
}

// The distinct symbols named by a body's EXPLICIT ports, in port order.
inline std::vector<const Symbol*> explicitPortInternals(
    const InstanceBodySymbol& body) {
    std::vector<const Symbol*> out;
    for (auto pb : body.getPortList()) {
        if (pb->kind == SymbolKind::MultiPort) {
            // The unnamed-concat reading above puts the SECOND identifier
            // (the port) first and the first (the interface type) after it,
            // matching Surelog's header-then-declaration signal order.
            if (auto pr = unnamedConcatIfacePort(*pb); pr.first) {
                for (auto* esym : {pr.second, pr.first})
                    if (std::find(out.begin(), out.end(), esym) == out.end())
                        out.push_back(esym);
                continue;
            }
            for (auto* esym : portExprSymbols(*pb))
                if (std::find(out.begin(), out.end(), esym) == out.end())
                    out.push_back(esym);
            continue;
        }
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (!ps.internalSymbol || !isExplicitNonAnsiPort(ps))
            continue;
        if (std::find(out.begin(), out.end(), ps.internalSymbol) == out.end())
            out.push_back(ps.internalSymbol);
    }
    return out;
}

// ...of those, the ones no header port is already named after: each is a port
// declaration in its own right, so it earns its own port object.
inline std::vector<const Symbol*> explicitPortOwnPorts(
    const InstanceBodySymbol& body) {
    std::vector<const Symbol*> out;
    for (auto* isym : explicitPortInternals(body)) {
        bool named = false;
        for (auto pb : body.getPortList())
            if (pb->name == isym->name)
                named = true;
        if (!named)
            out.push_back(isym);
    }
    return out;
}

// The direction of the port declaration an explicit port's symbol came from,
// read off the header ports that name it.
inline int32_t explicitPortDirection(const InstanceBodySymbol& body,
                                     const Symbol& isym) {
    for (auto pb : body.getPortList()) {
        // A concat port's operands all take the header port's own direction
        // (`module c(.a({b, c})); input b; input c;` -> three vpiInput ports).
        if (pb->kind == SymbolKind::MultiPort) {
            auto pes = portExprSymbols(*pb);
            if (auto pr = unnamedConcatIfacePort(*pb); pr.first)
                pes = {pr.second, pr.first};
            if (std::find(pes.begin(), pes.end(), &isym) == pes.end())
                continue;
            switch (pb->as<MultiPortSymbol>().direction) {
                case ArgumentDirection::In:
                    return vpiInput;
                case ArgumentDirection::Out:
                    return vpiOutput;
                default:
                    return vpiInout;
            }
        }
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (ps.internalSymbol != &isym)
            continue;
        switch (ps.direction) {
            case ArgumentDirection::In:
                return vpiInput;
            case ArgumentDirection::Out:
                return vpiOutput;
            default:
                return vpiInout;
        }
    }
    return vpiInout;
}

struct NetOrderItem {
    const Symbol* sym;
    const PortSymbol* port;
    bool bodyDecl;
    // The net an EXPLICIT non-ANSI port mints under its OWN name; `sym` is
    // the expression's symbol (the lowConn actual), NOT this net's identity.
    bool portExprNet = false;
    // ...and the header symbol that DOES name it — the port itself, or the
    // MultiPortSymbol when the header port is written over a concatenation
    // (whose `port` is only the first operand's sub-port).
    const Symbol* netNameSym = nullptr;
};

// An interface handled by the interface_inst path: variables/nets/parameters/
// ports/cont-assigns/processes are supported; child instances, generate, and
// modports still fall through to the (incomplete) module_inst path.
inline bool isSimpleInterfaceBody(const InstanceBodySymbol& body) {
    for (auto& m : body.members()) {
        switch (m.kind) {
            // Child instances (interface/module instantiated INSIDE the
            // interface) still fall through to the module_inst path. Generate
            // blocks are now handled by the interface path (def-view gen_stmts +
            // elab gen_scope_arrays).
            case SymbolKind::Instance:
                return false;
            default:
                break;
        }
    }
    return true;
}

inline bool useInterfacePath(const InstanceSymbol& inst) {
    return inst.isInterface() && isSimpleInterfaceBody(inst.body);
}

// Cont_assigns/Process/Ports/Gen_scope_arrays are declared separately (same
// signature) on module_inst and interface_inst, not on the common `instance`
// base. These dispatch the setter on the runtime type so emission code can be
// written against instance*.
// The module_inst view of an instance object, or null when it is a program /
// interface_inst (relations that exist only on module_inst).
inline UHDM::module_inst* asModuleInst(UHDM::instance* m) {
    return (m && m->UhdmType() == UHDM::uhdmmodule_inst) ? (UHDM::module_inst*)m
                                                         : nullptr;
}

inline void instSetContAssigns(UHDM::instance* m, UHDM::VectorOfcont_assign* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Cont_assigns(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Cont_assigns(v);
    else
        ((UHDM::module_inst*)m)->Cont_assigns(v);
}
inline void instSetProcess(UHDM::instance* m, UHDM::VectorOfprocess_stmt* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Process(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Process(v);
    else
        ((UHDM::module_inst*)m)->Process(v);
}
inline void instSetPorts(UHDM::instance* m, UHDM::VectorOfport* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Ports(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Ports(v);
    else
        ((UHDM::module_inst*)m)->Ports(v);
}
inline UHDM::VectorOfport* instGetPorts(const UHDM::instance* m) {
    if (!m)
        return nullptr;
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        return ((const UHDM::interface_inst*)m)->Ports();
    if (m->UhdmType() == UHDM::uhdmprogram)
        return ((const UHDM::program*)m)->Ports();
    if (m->UhdmType() == UHDM::uhdmmodule_inst)
        return ((const UHDM::module_inst*)m)->Ports();
    return nullptr;
}
inline void instSetGenScopeArrays(UHDM::instance* m, UHDM::VectorOfgen_scope_array* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Gen_scope_arrays(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Gen_scope_arrays(v);
    else
        ((UHDM::module_inst*)m)->Gen_scope_arrays(v);
}
inline void instSetInterfaces(UHDM::instance* m, UHDM::VectorOfinterface_inst* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Interfaces(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Interfaces(v);
    else
        ((UHDM::module_inst*)m)->Interfaces(v);
}
inline UHDM::VectorOfinterface_array* instGetInterfaceArrays(const UHDM::instance* m) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        return ((const UHDM::interface_inst*)m)->Interface_arrays();
    if (m->UhdmType() == UHDM::uhdmprogram)
        return ((const UHDM::program*)m)->Interface_arrays();
    return ((const UHDM::module_inst*)m)->Interface_arrays();
}
inline void instSetInterfaceArrays(UHDM::instance* m, UHDM::VectorOfinterface_array* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Interface_arrays(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Interface_arrays(v);
    else
        ((UHDM::module_inst*)m)->Interface_arrays(v);
}
inline void instSetEndLabel(UHDM::instance* m, std::string_view lbl) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->VpiEndLabel(lbl);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->VpiEndLabel(lbl);
    else
        ((UHDM::module_inst*)m)->VpiEndLabel(lbl);
}
inline void instSetGenStmts(UHDM::instance* m, UHDM::VectorOfgen_stmt* v) {
    // UHDM's `program` carries no gen_stmts relation, so a program def drops
    // its generate placeholders (no corpus case yet).
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Gen_stmts(v);
    else if (auto* mm = asModuleInst(m))
        mm->Gen_stmts(v);
}

// A `program` block is written into design->AllPrograms / instance->Programs,
// never AllModules. Surelog's program writer is a separate path from its
// module writer, and the two differ in the def view (see emitModuleDef).
inline bool isProgramDef(const InstanceSymbol& inst) {
    return inst.getDefinition().definitionKind == DefinitionKind::Program;
}
// The GENERIC interface port form (`module m (interface intf);`) — the port
// names no interface type. Surelog never recognises it as an interface port:
// it compiles an ordinary net-backed port whose typespec is an
// unsupported_typespec named after the PORT. Ports that do name a type
// (`ConnectTB.tb intf`, `sim_sram_if ss_if`) take the interface path.
inline bool isGenericIfacePort(const InterfacePortSymbol& ip) {
    for (auto sy = ip.getSyntax(); sy; sy = sy->parent) {
        const syntax::InterfacePortHeaderSyntax* iph = nullptr;
        if (sy->kind == syntax::SyntaxKind::InterfacePortHeader)
            iph = &sy->as<syntax::InterfacePortHeaderSyntax>();
        else if (sy->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            const syntax::PortHeaderSyntax* h =
                sy->as<syntax::ImplicitAnsiPortSyntax>().header;
            if (h && h->kind == syntax::SyntaxKind::InterfacePortHeader)
                iph = &h->as<syntax::InterfacePortHeaderSyntax>();
        }
        if (iph)
            return !iph->modport &&
                   iph->nameOrKeyword.kind == parsing::TokenKind::InterfaceKeyword;
        if (sy->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            break;
    }
    return false;
}

// True when some instantiation in this interface instance's OWN scope hands
// it to a PLAIN (non-modport-qualified) GENERIC interface port.  Surelog
// lists such an interface's Variables TWICE -- on the home view and on the
// port view alike -- and only for the plain form: measured on a two-instance
// repro where `ca`, passed to `GEN1(interface intf)` as `.intf(ca)`, reads
// four vpiVariables while the sibling `cb` behind a typed port reads two, and
// on OneNetModPortGeneric itself, where work@TOP.conntb (plain `.intf(conntb)`
// into OBSERVER) doubles while work@TOP.dut1.conntb (modport-qualified
// `.intf(conntb.dut)` into middle) does not.  Two generic ports on one
// instance still double only once.
// § genericIfacePortNameMatch narrows this: only a generic port Surelog could
// NOT resolve (its name matches no interface definition) doubles — a matched
// one is an ordinary plain interface port and lists its variables once
// (r10imex_repro/t5).  `unbound` answers "is this port the unresolved form?".
inline bool boundToPlainGenericIfacePort(
    const InstanceSymbol& ifaceInst,
    const std::function<bool(const InterfacePortSymbol&)>& unbound) {
    const Scope* home = ifaceInst.getParentScope();
    if (!home)
        return false;
    for (auto& mem : home->members()) {
        if (mem.kind != SymbolKind::Instance)
            continue;
        auto& child = mem.as<InstanceSymbol>();
        for (auto pb : child.body.getPortList()) {
            if (pb->kind != SymbolKind::InterfacePort)
                continue;
            auto& ip = pb->as<InterfacePortSymbol>();
            if (!unbound(ip))
                continue;
            auto conn = ip.getConnection();
            if (conn.first == &ifaceInst && !conn.second)
                return true;
        }
    }
    return false;
}

inline const Expression& stripImplicitConv(const Expression& e);

// The def-view source span of an implicit net that slang minted at the FIRST
// terminal of an UNNAMED gate. Surelog's def-view gate compile never lands
// that terminal (see emitGates), so the net is not born there — it appears at
// the first terminal Surelog does compile. Only such nets get an entry; every
// other net keeps its own declaration span.
inline std::map<const Symbol*, SourceRange> defImplicitNetLocs(
    const InstanceBodySymbol& body) {
    auto primOf = [](const Symbol& mb) -> const PrimitiveInstanceSymbol* {
        if (mb.kind == SymbolKind::PrimitiveInstance)
            return &mb.as<PrimitiveInstanceSymbol>();
        if (mb.kind == SymbolKind::InstanceArray) {
            auto& arr = mb.as<InstanceArraySymbol>();
            if (!arr.elements.empty() && arr.elements[0] &&
                arr.elements[0]->kind == SymbolKind::PrimitiveInstance)
                return &arr.elements[0]->as<PrimitiveInstanceSymbol>();
        }
        return nullptr;
    };
    auto termSym = [](const Expression* ce) -> const Symbol* {
        if (!ce)
            return nullptr;
        const Expression* te = &stripImplicitConv(*ce);
        if (te->kind == ExpressionKind::Assignment)
            te = &stripImplicitConv(te->as<AssignmentExpression>().left());
        if (te->kind != ExpressionKind::NamedValue)
            return nullptr;
        auto& sym = te->as<NamedValueExpression>().symbol;
        if (sym.kind != SymbolKind::Net || !sym.as<NetSymbol>().isImplicit)
            return nullptr;
        return &sym;
    };
    // Nets born on a terminal the def view drops.
    std::set<const Symbol*> orphaned;
    for (auto& mb : body.members()) {
        auto* pi = primOf(mb);
        if (!pi || !mb.name.empty())
            continue;
        auto conns = pi->getPortConnections();
        if (conns.empty())
            continue;
        if (auto* sym = termSym(conns[0]);
            sym && sym->location == conns[0]->sourceRange.start())
            orphaned.insert(sym);
    }
    std::map<const Symbol*, SourceRange> locs;
    if (orphaned.empty())
        return locs;
    for (auto& mb : body.members()) {
        auto* pi = primOf(mb);
        if (!pi)
            continue;
        auto conns = pi->getPortConnections();
        for (size_t ci = mb.name.empty() ? 1u : 0u; ci < conns.size(); ci++) {
            auto* sym = termSym(conns[ci]);
            if (sym && orphaned.count(sym) && !locs.count(sym))
                locs[sym] = conns[ci]->sourceRange;
        }
    }
    return locs;
}

inline std::vector<NetOrderItem> collectNetOrder(const InstanceBodySymbol& body) {
    std::vector<NetOrderItem> sorted, implicitPorts, mintedNets, typedVarPorts;
    std::set<const Symbol*> portInternals;
    for (auto pb : body.getPortList()) {
        // A CONCAT port mints its net the same way; the first operand's
        // sub-port stands in as `port`, which is what types that net.
        if (pb->kind == SymbolKind::MultiPort) {
            auto pes = portExprSymbols(*pb);
            if (!pes.empty())
                implicitPorts.push_back({pes.front(),
                                         pb->as<MultiPortSymbol>().ports.front(),
                                         false, true, pb});
            continue;
        }
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (!ps.internalSymbol)
            continue;
        // An EXPLICIT port keeps its own net in the port group; the
        // expression's symbol falls through to the member loop and sorts by
        // its declaration, so BOTH nets exist (Surelog).
        if (isExplicitNonAnsiPort(ps)) {
            implicitPorts.push_back({ps.internalSymbol, &ps, false, true, &ps});
            continue;
        }
        portInternals.insert(ps.internalSymbol);
        NetOrderItem it{ps.internalSymbol, &ps, hasBodyDecl(*ps.internalSymbol)};
        // The port that CARRIES a directionless variable data type is
        // appended after every body declaration (see ansiTypedVarPortHead).
        if (!it.bodyDecl && ansiTypedVarPortHead(*ps.internalSymbol))
            typedVarPorts.push_back(it);
        else if (it.bodyDecl || hasExplicitDeclLoc(*ps.internalSymbol))
            sorted.push_back(it);
        else
            implicitPorts.push_back(it);
    }
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
            continue;
        // A connection-MINTED implicit net (no declaration anywhere) sorts
        // AFTER the non-ANSI port nets (mriscv top: clk/rstn before the
        // implicit .trap(trap) nets); declared nets stay before them.
        if (member.kind == SymbolKind::Net &&
            member.as<NetSymbol>().isImplicit)
            mintedNets.push_back({&member, nullptr, true});
        else
            sorted.push_back({&member, nullptr, true});
    }
    auto locLess = [](const NetOrderItem& a, const NetOrderItem& b) {
        return a.sym->location < b.sym->location;
    };
    std::stable_sort(sorted.begin(), sorted.end(), locLess);
    std::stable_sort(mintedNets.begin(), mintedNets.end(), locLess);
    sorted.insert(sorted.end(), implicitPorts.begin(), implicitPorts.end());
    sorted.insert(sorted.end(), mintedNets.begin(), mintedNets.end());
    sorted.insert(sorted.end(), typedVarPorts.begin(), typedVarPorts.end());
    return sorted;
}

// The packages a module body MATERIALIZES, each with the MULTIPLICITY
// Surelog copies its contents at, in first-seen order.
//
// Measured on a purpose-built Surelog golden triple (r10apb2): a MODULE-scope
// `import p::*` copies the package's whole variable list into the module
// ONCE, a COMPILATION-UNIT-scope (file-level) one copies it TWICE, and the
// two spellings ADD (both together -> three copies). A file-level import only
// reaches modules written in the SAME FILE — a module in a third file gets
// nothing — so the buffer must match even when `--single-unit` merges every
// file into one compilation unit (Surelog's default IS one unit, so the
// scope alone cannot separate them).
inline std::vector<std::pair<const PackageSymbol*, int>> collectMaterializedPkgs(
    const InstanceBodySymbol& body) {
    std::vector<std::pair<const PackageSymbol*, int>> out;
    auto add = [&](const PackageSymbol* p, int copies) {
        if (!p)
            return;
        for (auto& e : out)
            if (e.first == p) {
                e.second += copies;
                return;
            }
        out.push_back({p, copies});
    };
    SourceLocation modLoc = body.getDefinition().location;
    if (auto* ps = body.getDefinition().getParentScope();
        ps && ps->asSymbol().kind == SymbolKind::CompilationUnit)
        for (auto& m : ps->members())
            if (m.kind == SymbolKind::WildcardImport &&
                m.location.buffer() == modLoc.buffer())
                add(m.as<WildcardImportSymbol>().getPackage(), 2);
    for (auto& m : body.members())
        if (m.kind == SymbolKind::WildcardImport)
            add(m.as<WildcardImportSymbol>().getPackage(), 1);
    return out;
}

// PACKAGE-SCOPE DATA declarations an import MATERIALIZES into this module.
// Surelog copies them exactly as it copies imported parameters (see
// collectImportedParams): the def view lists a wire logic_net named
// work@<mod>.<v>, the elab view the package variable's own kind
// (string_var/class_var/logic_var...).
//
// The whole package list rides, in PACKAGE DECLARATION order and whether or
// not the module reads any of them (Surelog-measured, r10apb2 repro 1: an
// unread `const string`/`int` pair both materialize) — repeated once per
// copy (see collectMaterializedPkgs). An EXPLICIT import names one symbol and
// materializes only that one. The shapes emitPackageVar declines to model
// (unpacked aggregates, dynamic containers) are dropped here too.
inline std::vector<const slang::ast::VariableSymbol*> collectImportedPkgVars(
    const InstanceBodySymbol& body) {
    std::vector<const slang::ast::VariableSymbol*> out;
    auto modelled = [](const Symbol& v) {
        const slang::ast::DeclaredType* dt = v.getDeclaredType();
        if (!dt)
            return false;
        switch (dt->getType().getCanonicalType().kind) {
            case SymbolKind::FixedSizeUnpackedArrayType:
            case SymbolKind::DynamicArrayType:
            case SymbolKind::AssociativeArrayType:
            case SymbolKind::QueueType:
            case SymbolKind::UnpackedStructType:
            case SymbolKind::UnpackedUnionType:
                return false;
            default:
                return true;
        }
    };
    for (auto& [pkg, copies] : collectMaterializedPkgs(body))
        for (int i = 0; i < copies; i++)
            for (auto& pm : pkg->members())
                if (pm.kind == SymbolKind::Variable && modelled(pm))
                    out.push_back(&pm.as<slang::ast::VariableSymbol>());
    for (auto& m : body.members()) {
        if (m.kind != SymbolKind::ExplicitImport)
            continue;
        auto* imp = m.as<ExplicitImportSymbol>().importedSymbol();
        if (imp && imp->kind == SymbolKind::Variable && modelled(*imp))
            out.push_back(&imp->as<slang::ast::VariableSymbol>());
    }
    return out;
}

// The declared return-type syntax of a function ("function [3:0] f;"), used
// to anchor the return variable's typespec.
inline const syntax::SyntaxNode* returnTypeSyntax(const SubroutineSymbol& sub) {
    auto syn = sub.getSyntax();
    if (syn && syn->kind == syntax::SyntaxKind::FunctionDeclaration)
        return sub.getSyntax()->as<syntax::FunctionDeclarationSyntax>().prototype->returnType;
    if (syn && syn->kind == syntax::SyntaxKind::DPIImport)
        return syn->as<syntax::DPIImportSyntax>().method->returnType;
    return nullptr;
}

// § implicitRetSigningIsIntVar70 — THE PREDICATE.  Was the return type written
// as an IMPLICIT base type (no type keyword at all) carrying a SIGNING KEYWORD?
//
//     function unsigned      f;      -> TRUE     <- the UVM head
//     function signed        f;      -> TRUE
//     function unsigned[3:0] f;      -> TRUE
//     function signed  [3:0] f;      -> TRUE
//     function               f;      -> false    (implicit, NO signing)
//     function         [3:0] f;      -> false    (implicit, NO signing)
//     function logic unsigned f;     -> false    (the base type is WRITTEN)
//     function int  unsigned  f;     -> false    (ditto)
//
// THIS IS A SYNTAX QUESTION AND NEVER A TYPE QUESTION, and that is the whole
// correction this pass makes.  The predecessor arm asked `retType.isSigned()`,
// which answers "is the resulting TYPE signed" — and golden does not care:
// `function unsigned get_recorders(...)` produces an `int_var` carrying
// `vpiSigned:1` in golden even though the keyword says UNSIGNED (measured,
// tools/probe/r10uvm70repro/README.md §2, arm a1 cells 8/11/16/19).  The flag
// records that a SIGNING KEYWORD WAS WRITTEN on a type that had no base, not
// the keyword's direction.
inline bool implicitRetWrittenSigning70(const syntax::SyntaxNode* rs) {
    if (!rs || rs->kind != syntax::SyntaxKind::ImplicitType)
        return false;
    return rs->as<syntax::ImplicitTypeSyntax>().signing.valid();
}

// Does a declaration naming this unpacked-array typedef get a per-reference
// COPY of the typedef's array_typespec, or does it bind the shared object?
// Measured over a 6-shape golden pair (int / size-form int / anonymous
// `logic [1:0]` / named-vector / enum-typedef / struct-typedef elements, in
// both module and package scope): the ELEMENT decides. A NAMED-typedef element
// resolves to an object already in the scope's typespec map and the array is
// shared; a built-in or anonymous element is re-compiled from the type node,
// which mints a fresh array_typespec + a fresh element typespec per reference
// (r10unpk).
inline bool unpackedArrayTypedefCopies(const TypeAliasType& ta) {
    auto& ct = ta.targetType.getType().getCanonicalType();
    if (ct.kind != SymbolKind::FixedSizeUnpackedArrayType)
        return false;
    return ct.as<FixedSizeUnpackedArrayType>().elementType.kind !=
           SymbolKind::TypeAlias;
}

// ---------------------------------------------------------------------------
// § declArrayElemTsIsWrittenKeyword126
//
// THE LAW.  The ELEMENT TYPESPEC of a FIXED-SIZE unpacked-array BLOCK-ITEM
// subroutine local is the typespec class Surelog's `compileTypespec` mints for
// the declaration's WRITTEN BASE-TYPE KEYWORD — `string` -> string_typespec,
// `real` -> real_typespec, `byte` -> byte_typespec, and so on for all twelve
// keyword forms.  It is NOT derived from the element's integral shape.
//
// WHY, read off Surelog.  `CompileHelper::compileTypespec` (CompileType.cpp)
// dispatches on the PARSE NODE of the data type, and its builtin arm
// `compileBuiltinTypespec` (CompileType.cpp:1126-1231) is a closed switch:
//
//     paIntVec_TypeLogic / paIntVec_TypeReg -> logic_typespec (+Ranges, signed
//                                              only when `signed` is written)
//     paIntegerAtomType_Int      -> int_typespec        VpiSigned unless `unsigned`
//     paIntegerAtomType_Integer  -> integer_typespec    "
//     paIntegerAtomType_Byte     -> byte_typespec       "
//     paIntegerAtomType_LongInt  -> long_int_typespec   "
//     paIntegerAtomType_Shortint -> short_int_typespec  "
//     paIntegerAtomType_Time     -> time_typespec       (no VpiSigned at all)
//     paIntVec_TypeBit           -> bit_typespec (+Ranges, signed if written)
//     paNonIntType_ShortReal     -> short_real_typespec
//     paNonIntType_Real          -> real_typespec
//     paString_type              -> string_typespec     (CompileType.cpp:1220)
//     default                    -> logic_typespec      <- OUR OLD ANSWER
//
// with `paChandle_type` (CompileType.cpp:2019) and `paEvent_type` (:2035)
// handled by the same dispatch one level up.  The unpacked dimensions are then
// wrapped around THAT object as an `array_typespec`, so the keyword decides the
// element typespec and the brackets decide nothing.
//
// OURS ASKED THE ELEMENT'S SHAPE INSTEAD.  The tf BLOCK-ITEM fixed-size arm in
// TaskFuncEmit was a three-way fallback — PredefinedIntegerType -> int_typespec,
// 2-state integral -> bit_typespec, everything else -> logic_typespec — i.e. it
// only ever reproduced Surelog's `int`, `bit` and `default` rows.  `string`,
// `real`, `shortreal`, `chandle`, `event`, `byte`, `shortint`, `longint`,
// `integer` and `time` all landed on the wrong class.  Grid A (22 element kinds
// in one class task body) measures every row of the table above against golden.
//
// SCOPE, stated so the gate written is the gate coded.  The dispatch is on the
// WRITTEN SYNTAX NODE, never on the canonical type, because a declaration that
// NAMES A TYPEDEF (`label126_t caption126[2]`, `paint126_e hue126[4]`,
// `psplit126_t split126[2]`, a class handle) binds golden's SHARED, NAMED
// typespec object — a different mechanism (a name, a typedef span and a
// vpiInstance), which this law leaves exactly where it stands rather than
// swapping one wrong object for another.  Returning null for those nodes is
// what keeps this pass's movers TO-GOLDEN-only.
//
// The element VARIABLE is untouched: `makeReturnVar` already gives it golden's
// class in every one of the 22 grid-A cells (golden itself gives an `event`
// element a logic_var next to an event_typespec), which is why this is a
// typespec-only law.
inline UHDM::typespec* writtenKeywordElemTs126(UHDM::Serializer& s,
                                               const syntax::SyntaxNode* tsyn,
                                               bool isSigned) {
    if (!tsyn)
        return nullptr;
    switch (tsyn->kind) {
        case syntax::SyntaxKind::StringType:
            return s.MakeString_typespec();
        case syntax::SyntaxKind::RealType:
            return s.MakeReal_typespec();
        case syntax::SyntaxKind::ShortRealType:
            return s.MakeShort_real_typespec();
        case syntax::SyntaxKind::CHandleType:
            return s.MakeChandle_typespec();
        case syntax::SyntaxKind::EventType:
            return s.MakeEvent_typespec();
        case syntax::SyntaxKind::IntType: {
            auto* t = s.MakeInt_typespec();
            t->VpiSigned(isSigned);
            return t;
        }
        case syntax::SyntaxKind::IntegerType: {
            auto* t = s.MakeInteger_typespec();
            t->VpiSigned(isSigned);
            return t;
        }
        case syntax::SyntaxKind::ByteType: {
            auto* t = s.MakeByte_typespec();
            t->VpiSigned(isSigned);
            return t;
        }
        case syntax::SyntaxKind::ShortIntType: {
            auto* t = s.MakeShort_int_typespec();
            t->VpiSigned(isSigned);
            return t;
        }
        case syntax::SyntaxKind::LongIntType: {
            auto* t = s.MakeLong_int_typespec();
            t->VpiSigned(isSigned);
            return t;
        }
        case syntax::SyntaxKind::TimeType:
            // § declArrayElemTsIsWrittenKeyword126v — the `time` row is the
            // ONE arm of Surelog's switch that never touches VpiSigned
            // (CompileType.cpp:1188-1192 has no `var->VpiSigned(...)` call at
            // all, unlike every other integer-atom row), so a written
            // `time signed x[N]` is golden's time_typespec with VpiSigned
            // FALSE.  `time_typespec::Compare` READS VpiSigned, so setting it
            // from slang's `isSigned()` moved the cell to the right class and
            // the wrong field.  Verifier arm v126_a_sign, cell `t_sgn126v`.
            return s.MakeTime_typespec();
        default:
            return nullptr;
    }
}

// Return-value variables take the class of the function's return type.
inline UHDM::variables* makeReturnVar(UHDM::Serializer& s, const Type& retType,
                                      bool implicitWrittenSigning70 = false) {
    auto& ct = retType.getCanonicalType();
    // § typeParamRetIsRefVar58 — THE GATE, and it must run BEFORE every arm
    // below because the arms key on the CANONICAL type, which for a type
    // parameter is the BINDING and therefore resolves the very thing golden
    // refuses to resolve.  Emitting no vpiSigned is part of the law, not an
    // omission: golden's ref_var carries none, and `variables::Compare` DOES
    // compare vpiSigned (UHDM build/generated/src/variables.cpp), so the flag
    // and the object class stand or fall together.  Law + cells:
    // include/UhdmExporter.h and tools/probe/r10uvm58repro/README.md.
    if (typeParamVarIsRefVar58(retType))
        return s.MakeRef_var();
    // An UNPACKED-array return (typedef int T[N]; function T f) is a bare
    // array_var carrying only the ref to the array_typespec — Surelog
    // (ArrayExprFuncArg/DefaultPattern*).  Unlike a function-LOCAL unpacked
    // array it has no element reg and no vpiArrayType.
    if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType)
        return s.MakeArray_var();
    if (ct.kind == SymbolKind::PackedStructType ||
        ct.kind == SymbolKind::UnpackedStructType)
        return s.MakeStruct_var();
    // A union-typed return is a union_var (Surelog, rp32 enc32/dec32).
    if (ct.kind == SymbolKind::PackedUnionType ||
        ct.kind == SymbolKind::UnpackedUnionType)
        return s.MakeUnion_var();
    if (ct.kind == SymbolKind::EnumType)
        return s.MakeEnum_var();
    if (ct.kind == SymbolKind::StringType)
        return s.MakeString_var();
    // A chandle return/formal is a chandle_var (Surelog, DpiChandle).
    if (ct.kind == SymbolKind::CHandleType)
        return s.MakeChandle_var();
    // § aliasClassRefVar10 — a class handle declared through a TYPEDEF ALIAS
    // is a `ref_var`, not a class_var, at SUBROUTINE/STATEMENT scope (the
    // return value, a body local, a begin-block local); writing the class
    // NAME directly still gives a class_var, and a class PROPERTY / package
    // variable / module variable is a class_var either way (that is why this
    // lives in makeReturnVar and not in makeVar).  Read off Surelog
    // CompileType.cpp `compileVariable` (:340-435), the function that
    // compiles exactly those declarations: for a named type it tries
    // getDataType -> getSimpleVarFromTypespec (a class typespec yields no
    // simple var), then design->getClassDefinition(name) — which finds the
    // CLASS's own name and never an alias — then a class_typespec test that
    // the alias fails because its typespec is still an unsupported_typespec
    // at that point (`needLateTypedefBinding` patches the real one in
    // afterwards, which is why golden's ref_var ends up carrying a
    // class_typespec).  Everything else falls through to `MakeRef_var`.
    // Verified on purpose-built pairs t3/t4: with `typedef Inner alias_t`,
    // both a class-scope and a package-scope alias give ref_var for a
    // function return, a function local, an `initial` block local and an
    // `always_comb` local, while the same alias as a class property, a
    // package variable and a module variable stays class_var and a formal
    // stays an io_decl.  Reach: `Return | ref_var vs class_var` 108/87/89 and
    // `Variables | ref_var vs class_var` 103/139 across the UVM four
    // (uvm's `type_id` and `this_type` are 102 of BuildUVMPkg's 108).
    // A `parameter type T` is NOT an alias for this rule even though slang
    // models it as a TypeAliasType: golden gives `function T gf(); T l;` a
    // class_var in BOTH views while the `typedef G#(T) this_type` next to it
    // in the same class gets a ref_var (repro t5).  Surelog reaches the
    // specialization's real class through the parameter binding, so its
    // getClassDefinition lookup succeeds where an alias NAME never does.
    if (ct.kind == SymbolKind::ClassType) {
        if (retType.kind == SymbolKind::TypeAlias &&
            !typeParamOfAlias(retType.as<TypeAliasType>()))
            return s.MakeRef_var();
        return s.MakeClass_var();
    }
    if (ct.kind == SymbolKind::PredefinedIntegerType) {
        auto& pit = ct.as<PredefinedIntegerType>();
        if (pit.integerKind == PredefinedIntegerType::Int) {
            auto* v = s.MakeInt_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::Integer) {
            auto* v = s.MakeInteger_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::ShortInt) {
            auto* v = s.MakeShort_int_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::LongInt) {
            auto* v = s.MakeLong_int_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::Byte) {
            auto* v = s.MakeByte_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        // § timeRetVar10 — a `time` return / subroutine local is a time_var,
        // the same object kind makeVar already gives a module-scope `time`;
        // this factory had no Time arm at all so it fell through to the
        // logic_var default.  The TYPESPEC was already a time_typespec on
        // both sides, so only the variable object kind differed (repro t1:
        // `time t1;` in a class is a time_var on both sides while the
        // identical `time l1;` inside a method and `function time get_t()`
        // were logic_vars).  Unsigned: Surelog leaves vpiSigned off a
        // time_var.  Reach in the UVM four: 73 rows on SeqDriver alone
        // (32 Return + 21 Stmt + 20 Variables), and the same three slots on
        // BuildUVMPkg / SimpleUVM / Scoreboard.
        if (pit.integerKind == PredefinedIntegerType::Time)
            return s.MakeTime_var();
    }
    if (ct.kind == SymbolKind::FloatingType) {
        if (ct.as<FloatingType>().floatKind == FloatingType::ShortReal)
            return s.MakeShort_real_var();
        return s.MakeReal_var();
    }
    // A packed array whose ELEMENT is a NAMED TYPEDEF (word[1:0]) is a
    // packed_array_var; plain vectors (logic [1:0]) stay logic_vars.
    if (ct.kind == SymbolKind::PackedArrayType &&
        ct.as<PackedArrayType>().elementType.kind == SymbolKind::TypeAlias)
        return s.MakePacked_array_var();
    // § implicitRetSigningIsIntVar70 — an IMPLICIT-base return type carrying a
    // WRITTEN SIGNING KEYWORD is an int_var stamped `vpiSigned:1`, in BOTH
    // directions and with or WITHOUT a packed range (Surelog).  The typespec
    // stays a logic_typespec and is already correct on our side — golden's own
    // object disagrees with itself here (int_var + logic_typespec), which is
    // why the kind cannot be inferred from the typespec.
    //
    // THIS ARM REPLACES A NARROWER ONE and the widening is the pass.  The old
    // text read `signedImplicitRet && ct.kind == PackedArrayType &&
    // retType.isSigned()`, i.e. "function signed [3:0] f" ONLY, and it missed
    // three of the four cells its own family contains:
    //     function unsigned      f;   golden int_var+vpiSigned  <- the UVM head
    //     function signed        f;   golden int_var+vpiSigned
    //     function unsigned [3:0]f;   golden int_var+vpiSigned
    //     function signed   [3:0]f;   golden int_var+vpiSigned  (already right)
    // `retType.isSigned()` is FALSE for the two `unsigned` spellings, and
    // `ct.kind == PackedArrayType` is FALSE for the two range-less ones, so the
    // old gate could only ever pass the fourth.  The predicate now lives in
    // `implicitRetWrittenSigning70` and asks the SYNTAX, which is the only
    // thing golden keys on.
    //
    // NARROWNESS, stated so the code gate matches the written gate: the caller
    // passes TRUE only for an `ImplicitTypeSyntax` whose `signing` token is
    // valid.  A bare `function f;` and a bare `function [3:0] f;` pass FALSE
    // and keep their old objects; an EXPLICIT base with a signing keyword
    // (`logic signed`, `reg signed`, `bit unsigned`, `int unsigned`) is not an
    // ImplicitType at all and never reaches here.
    if (implicitWrittenSigning70) {
        auto* v = s.MakeInt_var();
        v->VpiSigned(true);
        return v;
    }
    // A `bit`-based return (bit f, bit [1:0] f) is a bit_var; four-state
    // logic/reg returns stay logic_vars.
    {
        // MULTI-dim packed vectors (bit [N-1:0][15:0]) unwrap every level:
        // the `bit`-ness lives on the innermost scalar (FuncInModule).
        const Type* base9 = &ct;
        while (base9->kind == SymbolKind::PackedArrayType)
            base9 = &base9->as<PackedArrayType>()
                         .elementType.getCanonicalType();
        if (base9->kind == SymbolKind::ScalarType &&
            base9->as<ScalarType>().scalarKind == ScalarType::Bit) {
            // Signedness rides on the typespec only (Surelog leaves the
            // bit_var itself unsigned even for `function bit signed f`).
            return s.MakeBit_var();
        }
    }
    return s.MakeLogic_var();
}

// § atomVarSignedWritten68 — the ONE predicate behind `vpiSigned` on a SCALAR
// INTEGER-ATOM variable at SUBROUTINE / STATEMENT scope, applied POST-FACTORY at
// every site that declares one.
//
// GOLDEN'S RULE, transcribed from measurement (tools/probe/r10uvm68repro,
// 108 cells over 5 arms + a span census of the SimpleUVM golden): the flag keys
// on the atom being WRITTEN AT THE DECLARATION, exactly as
// § arrayVarSignedWritten8's clause (a) does for an `array_var` and as
// makeVar's `namedTy9` (r10c15) already does for a MODULE-scope variable.  A
// type NAME carries no signing syntax, so Surelog's compileVariable computes no
// signedness and the variable gets nothing:
//
//     int      x;        -> int_var  vpiSigned:1
//     typedef int t_t;
//     t_t      y;        -> int_var  NO vpiSigned          <- this law
//
// and identically for `integer` / `shortint` / `longint` / `byte` (arm a2, all
// five atoms), at ANY typedef chain depth, whether the name is written
// package-qualified or reached by wildcard import (arm a3), and at every
// declaration site a subroutine has: the return variable (including an
// out-of-body `extern` body, a DPI-import prototype and a PURE VIRTUAL
// prototype), a body local, a begin / named-begin / fork block local, an
// always_comb local and a for-header loop variable (arms a1/a5).
// In the SimpleUVM golden this holds for 34/34 named `int_var`, 193/193 named
// `bit_var` and 15/15 named `logic_var`, with ZERO counterexamples.
//
// THE OTHER CARRIER GOES THE OTHER WAY, and that is the pass's refutation: the
// int_typespec the variable points at DOES carry `vpiSigned:1` when it is named
// (64/64 in the same golden, `int_typespec (UVM_FILE)@313:9` among them).  The
// TYPESPEC keys on the RESOLVED type, the VARIABLE on the type AS WRITTEN —
// the scalar sibling of § arrayElemTsSignedParented9's two-carrier finding.  So
// there is nothing to "also fix" on the typespec: it is already right.
//
// WHY POST-FACTORY AND NOT INSIDE makeReturnVar: makeReturnVar is ALSO the
// ELEMENT-REG factory (TypeEmit's `emitArrayVar`, TaskFuncEmit's queue/dyn
// block-item arms, ParamEmit's package array), and those sites hand it an
// ARRAY ELEMENT type which can itself be a typedef alias.  Element-var
// signedness is § arrayVarSignedWritten8 / § arrayElemTsSignedParented9
// territory, measured there and deliberately NOT touched here; gating inside
// the factory would silently change it.  Call this ONLY where the type is the
// DECLARATION's own type.
//
// Setting the field FALSE is how the flag is cleared everywhere in this emitter
// (makeVar does `VpiSigned(pit.isSigned && !namedTy9)`); `vpiSigned` is a plain
// bool with no unset state and the dump prints it only when true.
inline void clearNamedAtomSigned68(UHDM::variables* v, const Type& declared) {
    if (!v)
        return;
    // A NAME, at any chain depth: slang models `typedef t_t u_t;` as a
    // TypeAlias whose target is another TypeAlias, so one test covers the chain
    // (arm a3 x_td1/x_td3).  A `parameter type` / class TYPE PARAMETER is also
    // a TypeAliasType here, and golden agrees it gets nothing — but it has
    // already become a `ref_var` via § typeParamVarIsRefVar58, which carries no
    // vpiSigned either way, so this is a no-op on it (arm a4, 11/11 EQ).
    if (declared.kind != SymbolKind::TypeAlias)
        return;
    // ONLY the predefined integer atoms.  `bit`/`logic`/`reg` and packed
    // vectors never get the flag on the VARIABLE at this scope on either side,
    // and a named `time` gets nothing on either side (arm a2 t_time/r_time), so
    // narrowing to PredefinedIntegerType keeps the edit to the population it
    // was measured on.
    if (declared.getCanonicalType().kind != SymbolKind::PredefinedIntegerType)
        return;
    v->VpiSigned(false);
}

// Packed dims written after a NAMED type (filter_ctl_t [1:0] a) live neither
// in the type syntax nor in getResolvedDimensions; scan the source between
// the type name and the declarator for bracket groups. Returns
// (range-span, left-bound-span, right-bound-span) per dim.
struct DimSpan {
    SourceRange range, left, right;
};
inline std::vector<DimSpan> scanDimSpans(const std::string& raw, SourceLocation base) {
    std::vector<DimSpan> out;
    for (size_t i = 0; i < raw.size(); i++) {
        if (raw[i] != '[')
            continue;
        auto close = raw.find(']', i);
        if (close == std::string::npos)
            continue;
        // The range separator is a LONE colon: a scoped bound (`[pkg::N-1:0]`)
        // must not be split at the `::` of its qualifier.
        size_t colon = std::string::npos;
        for (size_t j = i + 1; j < close; j++) {
            if (raw[j] != ':')
                continue;
            if (raw[j + 1] == ':') {
                j++;  // skip the `::` pair whole
                continue;
            }
            colon = j;
            break;
        }
        if (colon == std::string::npos)
            continue;
        auto trim = [&](size_t a, size_t b) {
            while (a < b && isspace((unsigned char)raw[a]))
                a++;
            while (b > a && isspace((unsigned char)raw[b - 1]))
                b--;
            return SourceRange(base + a, base + b);
        };
        out.push_back({SourceRange(base + i, base + close + 1), trim(i + 1, colon),
                       trim(colon + 1, close)});
        i = close;
    }
    return out;
}

// A packed-dim bound written `<head>-<digits>`, where <head> is either a digit
// run (`1-1`) or an identifier, possibly package-qualified (`NrHarts-1`,
// `pkg::N-1`). Surelog's fold of such a bound keeps the HEAD's span alone and
// encodes INT; every other shape keeps the whole bound text and UINT. Returns
// the head length, or 0 when the bound has another shape.
inline size_t arithBoundHeadLen(const std::string& raw) {
    size_t d = raw.find('-');
    if (d == std::string::npos || d == 0 || d + 1 >= raw.size())
        return 0;
    for (size_t p = d + 1; p < raw.size(); p++)
        if (!isdigit((unsigned char)raw[p]))
            return 0;
    bool allDigits = true, ident = isalpha((unsigned char)raw[0]) || raw[0] == '_';
    for (size_t p = 0; p < d; p++) {
        char c = raw[p];
        if (!isdigit((unsigned char)c))
            allDigits = false;
        bool scopeColon = c == ':' && ((p + 1 < d && raw[p + 1] == ':') ||
                                       (p > 0 && raw[p - 1] == ':'));
        if (!(isalnum((unsigned char)c) || c == '_' || scopeColon))
            ident = false;
    }
    return (allDigits || ident) ? d : 0;
}

// The packed dimensions written after a NAMED type (`my_vec_t [1:`N-1] x`)
// are parsed by slang onto the type's NAME — an `IdentifierSelectName` whose
// selectors carry them — not onto the `DataTypeSyntax`, which is a bare
// `NamedTypeSyntax`.  Returns the (left, right) bound expressions per dim.
inline std::vector<
    std::pair<const syntax::ExpressionSyntax*, const syntax::ExpressionSyntax*>>
namedTypeDimBounds(const syntax::SyntaxNode* tsyn) {
    std::vector<std::pair<const syntax::ExpressionSyntax*,
                          const syntax::ExpressionSyntax*>>
        out;
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return out;
    const syntax::NameSyntax* nm = tsyn->as<syntax::NamedTypeSyntax>().name;
    if (!nm || nm->kind != syntax::SyntaxKind::IdentifierSelectName)
        return out;
    for (const syntax::ElementSelectSyntax* sel :
         nm->as<syntax::IdentifierSelectNameSyntax>().selectors) {
        const syntax::SelectorSyntax* sl = sel ? sel->selector : nullptr;
        if (sl && sl->kind == syntax::SyntaxKind::SimpleRangeSelect) {
            auto& rs = sl->as<syntax::RangeSelectSyntax>();
            out.push_back(std::make_pair(
                (const syntax::ExpressionSyntax*)rs.left,
                (const syntax::ExpressionSyntax*)rs.right));
        }
        else
            out.push_back(std::make_pair(
                (const syntax::ExpressionSyntax*)nullptr,
                (const syntax::ExpressionSyntax*)nullptr));
    }
    return out;
}

// `ExprEval::reduceExpr`'s value type for a folded arithmetic bound:
// sub/mult/div always yield a signed vpiIntConst; add yields one only when a
// sub-operand already reduced to one.  (Mirrors the `redInt` lambda in
// `makeTypespec`'s bound emitter — same rule, reusable shape.)
inline bool srlgRedIntSyn(const syntax::SyntaxNode* n) {
    if (!n)
        return false;
    switch (n->kind) {
        case syntax::SyntaxKind::SubtractExpression:
        case syntax::SyntaxKind::MultiplyExpression:
        case syntax::SyntaxKind::DivideExpression:
            return true;
        case syntax::SyntaxKind::AddExpression: {
            auto& be = n->as<syntax::BinaryExpressionSyntax>();
            return srlgRedIntSyn(be.left) || srlgRedIntSyn(be.right);
        }
        case syntax::SyntaxKind::ParenthesizedExpression:
            return srlgRedIntSyn(
                n->as<syntax::ParenthesizedExpressionSyntax>().expression);
        default:
            return false;
    }
}

// Strips slang's implicit conversion wrappers (Surelog has no equivalent).
inline const Expression& stripImplicitConv(const Expression& e) {
    const Expression* p = &e;
    while (p->kind == ExpressionKind::Conversion &&
           p->as<ConversionExpression>().isImplicit())
        p = &p->as<ConversionExpression>().operand();
    return *p;
}

// § elabHierSelWidthFold — an indexed part-select whose WIDTH expression is a
// bare PARAMETER read is substituted by that parameter's VALUE before the
// select is decompiled, so the rendered select text carries the DIGITS rather
// than the identifier, and the vpiWidthExpr is a constant sized by THAT
// parameter's own type (an untyped localparam is `int` -> 32).  Measured on
// BlackBePipeInt: golden's four net-decl-assign hier_paths read
// `reservation.pc[0+:39]` / `reservation.rs1[0+:64]` where the source writes
// `[0+:vaddr_width_p]` / `[0+:dword_width_gp]`, and the symbolic spelling
// occurs ZERO times in the whole dump.  A literal keeps its written spelling
// (a based one must not be re-rendered in decimal) and a computed width keeps
// its text — only the bare-parameter read substitutes.
struct SelWidthFold {
    bool ok = false;
    std::string text;
    int32_t size = 64;
    const Symbol* sym = nullptr;
};

inline SelWidthFold selWidthParamFold(const Expression& w) {
    SelWidthFold r;
    auto& sw = stripImplicitConv(w);
    if (sw.kind != ExpressionKind::NamedValue)
        return r;
    auto& sym = sw.as<NamedValueExpression>().symbol;
    if (sym.kind != SymbolKind::Parameter)
        return r;
    auto& ps = sym.as<ParameterSymbol>();
    // § hierSelWidthOvParamNoFold — an OVERRIDABLE module parameter does not
    // substitute.  The distinguisher is § crossPkgRangeBoundFold's, one level
    // down in an expression: at DEFINITION-compile time a `parameter` in the
    // module's own port list has no settled value, so Surelog's decompile
    // keeps the identifier, while a package parameter (compiled first) and a
    // module `localparam` (not overridable) both have one.  Measured both
    // ways: BlackBePipeInt folds `reservation.pc[0+:vaddr_width_p]` to
    // `[0+:39]` — and `vaddr_width_p` is a LOCALPARAM in bp_be_pipe_int's own
    // parameter port list, not a package parameter, which is why the plain
    // "declared in a package" test regressed it — while spi_device.sv:159's
    // `reg2hw.rxf_addr.base.q[SDW+:SramAw]` keeps BOTH the rendered name and
    // the vpiWidthExpr symbolic (golden: a ref_obj), `SramAw` being
    // `parameter int SramAw = 9` in the port list.  vo.sv row G is the
    // purpose-built twin of the spi_device shape.
    if (!ps.isLocalParam())
        if (auto* psc9 = sym.getParentScope();
            !psc9 || psc9->asSymbol().kind != SymbolKind::Package)
            return r;
    auto& cv = ps.getValue();
    if (!cv.isInteger() || cv.integer().hasUnknown())
        return r;
    r.ok = true;
    r.text = cv.integer().toString(LiteralBase::Decimal, false);
    r.size = (int32_t)ps.getType().getBitWidth();
    r.sym = &sym;
    return r;
}

// § dollarBoundIsConst6 — `$` (slang's UnboundedLiteral, which lives in
// LiteralExpressions.h beside the other three) counts here because golden's
// parenting of a `$` bound is INDISTINGUISHABLE from its parenting of an
// integer literal in the same position: arm v3_parentpolicy pairs the two in
// seven positions and golden's answer is identical in all seven.  The site this
// reaches is the var_select builder's `forceConstParent = isLiteralExpr(idx)`
// (`qq[1][$]`), which the constant-parenting predicate alone would leave
// unparented while golden parents it.
inline bool isLiteralExpr(const Expression& e) {
    auto& c = stripImplicitConv(e);
    return c.kind == ExpressionKind::IntegerLiteral ||
           c.kind == ExpressionKind::StringLiteral ||
           c.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral ||
           c.kind == ExpressionKind::UnboundedLiteral;
}

// § negLitPkgRetFoldNested30 / VERIFIER FIX (r10vbuvm30) — Surelog does not
// negate the literal's VALUE: `ExprEval::reduceExpr`'s `vpiMinusOp` arm
// negates `get_value()` OF THE CONSTANT Surelog built, and REFUSES the fold
// entirely when that call sets `invalidValue`.  `get_value` (UHDM
// templates/ExprEval.cpp:1946) parses the constant's `VpiValue` DIGIT STRING
// — never the width-truncated value — and carries two refusals that decide
// whether golden folds AT ALL:
//   * `vpiDecConst` (a based `'d`, and a bare decimal too long for uint64):
//     the digits go through the STRICT int64 `NumUtils::parseInt64`, so
//     `-64'd9223372036854775808` does NOT fold; there is NO size check, so
//     `-128'd5` DOES (to -5, at size 128).
//   * `vpiBinaryConst` / `vpiOctConst` / `vpiHexConst`: `VpiSize() > 64`
//     refuses outright — `-70'b1`, `-68'h1`, `-128'hFFFFFFFFFFFFFFFFFFFF` all
//     stay unary-minus OPERATIONS in golden — and otherwise the digits are
//     parsed LENIENTLY (int64 first, then uint64 cast down), so
//     `-64'hFFFFFFFFFFFFFFFF` reads as -1 and golden's fold is `INT:1`.
// Because the digits are read UNTRUNCATED, `-4'd20` folds to -20 (not -4),
// `-4'hFF` to -255, `-2'b1111` to -15 and `-3'o77` to -63.  All measured on
// golden: tools/probe/r10vbuvm30repro/vg30_i_digits.sv and vg30_c_values.sv.
//
// `raw` is the literal's source text (`rawTextLit`), `bitWidth` its slang
// type width (what the constant's `VpiSize` is built from) and `dec` the
// literal's own value rendered as an UNSIGNED decimal — the bare-decimal
// arm's digits, where Surelog's own constant is a `vpiUIntConst` read with
// the lenient parser.  Returns false ⇒ `get_value` would be invalid ⇒ NO FOLD.
inline bool srlgNegLitGetValue30(std::string raw, int32_t bitWidth,
                                 const std::string& dec, int64_t& out) {
    // NumUtils::internal::strToInt — signed first, then unsigned, cast down.
    auto lenient = [](std::string_view s, int32_t base, int64_t& r) {
        while (!s.empty() && (s.front() == ' ' || s.front() == '\t'))
            s.remove_prefix(1);
        if (!s.empty() && s.front() == '+')
            s.remove_prefix(1);
        if (s.empty())
            return false;
        int64_t sn = 0;
        auto pr = std::from_chars(s.data(), s.data() + s.size(), sn, base);
        if (pr.ec == std::errc()) {
            r = sn;
            return true;
        }
        if (s.front() != '-' && pr.ec == std::errc::result_out_of_range) {
            uint64_t un = 0;
            auto pu = std::from_chars(s.data(), s.data() + s.size(), un, base);
            if (pu.ec == std::errc()) {
                r = (int64_t)un;
                return true;
            }
        }
        return false;
    };
    // NumUtils::parseInt64 — strToNum, strictly int64.
    auto strict = [](std::string_view s, int64_t& r) {
        while (!s.empty() && (s.front() == ' ' || s.front() == '\t'))
            s.remove_prefix(1);
        if (!s.empty() && s.front() == '+')
            s.remove_prefix(1);
        if (s.empty())
            return false;
        auto pr = std::from_chars(s.data(), s.data() + s.size(), r, 10);
        return pr.ec == std::errc();
    };
    raw.erase(std::remove_if(raw.begin(), raw.end(),
                             [](unsigned char c) { return std::isspace(c); }),
              raw.end());
    size_t tick = raw.find('\'');
    if (tick == std::string::npos) {
        // Bare decimal.  The IntegerLiteral arm encodes it `UINT:<digits>`
        // unless the digits do not fit uint64 (`largeInt`), where it becomes
        // a `vpiDecConst` whose 21+ digits the strict parser always rejects.
        // The lenient uint64 read of the value is exactly what `dec` carries.
        return lenient(dec, 10, out);
    }
    if (tick == 0)
        bitWidth = -1;  // unsized based: VpiSize is -1 (or 0 for 'b0/'b1)
    raw.erase(std::remove(raw.begin(), raw.end(), '_'), raw.end());
    tick = raw.find('\'');
    size_t basePos = tick + 1;
    if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
        basePos++;
    char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
    std::string_view digits =
        basePos + 1 <= raw.size() ? std::string_view(raw).substr(basePos + 1)
                                  : std::string_view{};
    switch (base) {
        case 'b':
            return bitWidth <= 64 && lenient(digits, 2, out);
        case 'o':
            return bitWidth <= 64 && lenient(digits, 8, out);
        case 'h':
            return bitWidth <= 64 && lenient(digits, 16, out);
        default:
            return strict(digits, out);
    }
}

// § negLitPkgRetFoldNested30 (r10buvm30) — the WRITTEN SHAPE that the fold
// replaces with ONE constant: a unary MINUS whose operand is an integer
// literal with no unknown bits.  Callers that treat a DIRECT LITERAL operand
// specially (the concatenation arm unparents one) must treat the folded
// constant the same way, because golden's folded constant sits in exactly the
// slot a plain literal would.  The predicate says nothing about the WINDOW —
// the caller still gates on `pkgRetFoldExpr30`.
inline bool isNegLitFoldShape30(const Expression& e) {
    auto& u = stripImplicitConv(e);
    if (u.kind != ExpressionKind::UnaryOp)
        return false;
    auto& ue = u.as<UnaryExpression>();
    if (ue.op != UnaryOperator::Minus)
        return false;
    auto& ib = stripImplicitConv(ue.operand());
    return ib.kind == ExpressionKind::IntegerLiteral &&
           !ib.as<IntegerLiteral>().getValue().hasUnknown();
}

// § srlgTimeLitVal — Surelog's TIME-literal reduction, transcribed field for
// field from CompileExpression.cpp:699 (`case VObjectType::paTime_literal`).
//
// It is NOT a physical unit conversion and it does NOT consult the timescale:
// Surelog parses the numeric prefix with NumUtils::parseUint64 (std::from_chars
// on an integer, so `1.5ns` yields 1 — the fraction is dropped, not rounded)
// and multiplies by a FIXED per-unit factor:
//     s 1e12   ms 1e9   us 1e3   ns 1e6   ps 1   fs 1e-3
// The table is not monotone (`us` < `ns`) and `fs` truncates toward zero
// (7fs -> 0), because the factors are doubles assigned back into a uint64_t.
// Measured against Surelog on a 7-row purpose-built golden (probe p2/t2.v,
// one parameter per unit plus `1.5ns`): 7fs->0, 7ps->7, 7ns->7000000,
// 7us->7000, 7ms->7000000000, 7s->7000000000000, 1.5ns->1000000 — exactly
// what this transcription computes.  An unrecognised unit is Picosecond
// (TimeInfo::unitFromString's fallthrough).
inline uint64_t srlgTimeLitVal(std::string_view raw) {
    uint64_t v = 0;
    size_t i = 0;
    for (; i < raw.size() && raw[i] >= '0' && raw[i] <= '9'; i++)
        v = v * 10 + (uint64_t)(raw[i] - '0');
    // The unit is the trailing run of letters (`5ns` -> "ns", `1.5ns` -> "ns").
    size_t u = raw.size();
    while (u > 0 && isalpha((unsigned char)raw[u - 1]))
        u--;
    std::string_view unit = raw.substr(u);
    double f = 1.0; // Picosecond, and the unrecognised-unit fallthrough
    if (unit == "s")
        f = 1e12;
    else if (unit == "ms")
        f = 1e9;
    else if (unit == "us")
        f = 1e3;
    else if (unit == "ns")
        f = 1e6;
    else if (unit == "ps")
        f = 1.0;
    else if (unit == "fs")
        f = 1e-3;
    // Surelog does this multiply in double and assigns back to uint64_t; keep
    // the double so the (harmless in practice) mantissa rounding matches, but
    // never invoke UB on an out-of-range conversion.
    double d = f * (double)v;
    if (!(d >= 0.0) || d >= 18446744073709551616.0)
        return 0;
    return (uint64_t)d;
}

// § classPropTimeLitInit2 (predicate 1 of 2) — does this type land on a
// Surelog `time_typespec`?
//
// It is the ONE question that decides a time-literal class-property
// initializer's SIZE and whether it carries a vpiDecompile at all, because
// `CompileHelper::adjustSize` is a no-op exactly when `Bits()` returns
// `invalidValue` for the property's typespec, and a `time_typespec` is such a
// typespec.  TWO written types reach it, and they are NOT the same slang kind:
// `time` (a PredefinedIntegerType) and `realtime` (a FloatingType) —
// `compileTypespec`'s `paNonIntType_RealTime` arm builds a `time_typespec`
// exactly as `paIntegerAtomType_Time` does.  Measured on arm a1, cells
// k01..k07 / k09 / k11..k13 (size 64, NO decompile) against k08 / k10 / k17..
// k20 / k22 / k23 / k24 (resized + decompiled).  `longint k17_li = 5ns` is the
// cell that proves the gate is the TYPESPEC KIND and not "the width is already
// 64": it is 64 bits wide and golden decompiles it.
inline bool timeLikeType2(const slang::ast::Type& ct) {
    using namespace slang::ast;
    if (ct.kind == SymbolKind::PredefinedIntegerType)
        return ct.as<PredefinedIntegerType>().integerKind ==
               PredefinedIntegerType::Time;
    if (ct.kind == SymbolKind::FloatingType)
        return ct.as<FloatingType>().floatKind == FloatingType::RealTime;
    return false;
}

// § classPropNullInitParentedByTypespec2 (predicate 2 of 2) — is this
// property's `= null` initializer parented at the CLASS_DEFN rather than at
// the variable?
//
// YES exactly when the property has NO typespec in golden, i.e. when Surelog's
// `makeVar_` reaches it only in the trailing `subnettype` fallback chain,
// whose tail does a bare `var->Expr(assignExp)` and never re-parents.  Two
// written types can hold `null` and land there: a `virtual <iface>` property
// (the pre-existing `vifProp6` half, arm a2 cell m11_vnull) and a `chandle`
// (`paChandle_type`, arm a2 cell m02_null).  A CLASS HANDLE does NOT — it is
// built by makeVar_'s `datatype_cast<ClassDefinition>` arm, which re-parents
// (arm a2 cell m01_null, and BuildUVMPkg's
// `uvm_component::m_unsupported_resource_base`).
inline bool nullInitDefnParented2(bool vifProp,
                                  const slang::ast::ClassPropertySymbol& cp) {
    return vifProp ||
           cp.getType().getCanonicalType().kind == slang::ast::SymbolKind::CHandleType;
}

// § classScopedTypedefPropIsBareLogicVar73 — does this class PROPERTY's
// DECLARED TYPE NAME live in a CLASS scope that the property's own class body
// does not itself declare?
//
// Surelog compiles a class property from a `Signal` whose type is the WRITTEN
// NAME, and resolves that name against the class's OWN typedef table and the
// enclosing package / compilation unit — never against another class's.  A name
// that has to come out of a class scope (`C::t`, or a typedef INHERITED from a
// base class, or the class's own typedef written `C::t`) is not found, no
// typespec binds, and `ElaborationStep::makeVar_` falls off the end of its
// `subnettype` switch into the same `// default type (fallback)` arm that
// § virtualIfacePropIsBareLogicVar6 already transcribes: a BARE `logic_var`
// with NO vpiTypespec, keeping only name / fullname / parent / span and the
// qualifier fields (`vpiAutomatic`, `vpiVisibility`, `vpiConstantVariable`,
// `vpiIsRandomized` + `vpiRandType`).  This is the THIRD trigger of that one
// fallback, not a new object.
//
// THE GATE, read off the grid (tools/probe/r10uvm73repro/README.md §2) and
// nothing else:
//   (1) the property's OWN declared type is a TYPEDEF NAME (a TypeAlias).  A
//       bare `holder h;` class handle, a `logic [7:0] x;`, and every
//       declarator-formed array (`holder::e_t x[3]`, `x[]`, `x[$]`) are NOT
//       typedef names and do NOT degrade — arm a1 cells c_class_handle,
//       c_qual_enum_arr, c_qual_enum_aa and arm a5 cells c_qual_dyn / c_qual_q
//       read AGREE on both sides today.  A typedef of a WHOLE array or queue
//       DOES degrade (a5 c_qual_arrtd / c_qual_qtd), which is why the test is
//       on the WRITTEN type and not on the canonical kind.
//   (2) that typedef's HOME SCOPE is a ClassType.  A package / $unit typedef
//       does not degrade however it is written — a1 c_pkg_enum, c_pkg_struct,
//       c_pkgqual_enum (`p1::pkg_e_t`, package-QUALIFIED, still fine).
//   (3) and either the home class is NOT the property's own class (INHERITED —
//       a1 c_inh_enum, a2 c_grand_inh, two levels up), or the name was WRITTEN
//       with a `::` scope qualifier (a1 c_self_qual_enum: the class's OWN
//       typedef, self-qualified, degrades — so the qualifier alone is
//       sufficient and "can Surelog see the type" is REFUTED as the axis).
//
// The population is a class property only: the same type on a FUNCTION LOCAL
// (a1 l_qual_enum), on a FORMAL ARGUMENT (a1 a_qual_enum) and on a class-scope
// ALIAS of the same qualified name (a2 c_locloc) all keep their full typespec
// in golden.  A PACKAGE variable degrades too (a5 p_pkgvar) but that is a
// different emission site with its own canary surface — README residue R1.
inline bool classScopedTypedefProp73(const slang::ast::ClassPropertySymbol& cp,
                                     const slang::ast::Symbol& ownerCls) {
    const slang::ast::Type& dt = cp.getType();
    if (dt.kind != slang::ast::SymbolKind::TypeAlias)
        return false;
    const slang::ast::Scope* home = dt.getParentScope();
    if (!home || home->asSymbol().kind != slang::ast::SymbolKind::ClassType)
        return false;
    if (&home->asSymbol() != &ownerCls)
        return true;
    // The class's OWN typedef: only the ::-qualified SPELLING degrades.
    if (auto* tsyn = cp.getDeclaredType()->getTypeSyntax())
        if (auto* nts = tsyn->as_if<syntax::NamedTypeSyntax>())
            return nts->name &&
                   nts->name->kind == syntax::SyntaxKind::ScopedName;
    return false;
}

// ---------------------------------------------------------------------------
// § classTdLocalVarKindFollowsCompileOrder10
//
// THE LAW.  A SUBROUTINE-scope declaration — a body local, a block-item local
// or the RETURN VARIABLE — whose declared type names a typedef that lives
// inside a CLASS takes the object class that typedef's typespec implies ONLY
// IF Surelog had already compiled the owning class when it compiled this
// declaration.  Otherwise the declaration falls back, and WHICH fallback
// depends on how the type was WRITTEN:
//
//   * written `Owner::td` (a ScopedName)  ->  a bare `class_var`
//   * written `td`        (a bare name)   ->  a bare `ref_var`
//
// In BOTH fallbacks the variable's name, full name, span, parent and
// ref_typespec — and that ref's `vpiActual`, the real struct/enum/int/class
// typespec, patched in afterwards by `needLateTypedefBinding` — are IDENTICAL
// to the resolved arm.  ONLY THE OBJECT CLASS CHANGES.  That is exactly the
// SeqDriver head: `class_var` vs `struct_var` on
// `uvm_resource_types::access_t access_record` at uvm_resource.svh:483:34,
// with every other line of the object byte-equal between the two sides.
//
// WHY, read off Surelog and then measured cell by cell (tools/probe/
// r10sd10repro/grid10):
//   `CompileHelper::compileVariable`'s `paClass_scope` arm (CompileType.cpp
//   ~553) resolves the owner with THREE lookups and no more —
//   `getClassDefinition(<written scope name>)`,
//   `<declaring component's own full name>::<scope name>`, and
//   `<declaring component's PARENT scope's name>::<scope name>` — then asks the
//   owner's DataType for a typespec, and ends `if (var == nullptr) var =
//   s.MakeClass_var();`.  The BARE-name arm (CompileType.cpp ~340) runs the
//   same question through `component->getDataType` and ends its own fallback
//   chain at `MakeRef_var`.  A class's typedefs have a typespec only once that
//   class's `CompileClass` has run, and `CompileDesign::compile` runs its
//   passes in this order:
//        packages (strict order) -> FILE CONTENTS -> modules -> programs
//        -> CLASSES, LAST,
//   iterating `ClassNameClassDefinitionMultiMap` — a `std::map<std::string, …,
//   StringViewCompare>` whose comparator is literally `a < b`.  So class bodies
//   are compiled in LEXICOGRAPHIC ORDER OF THEIR FULLY-QUALIFIED NAMES, and
//   SOURCE ORDER IS IRRELEVANT.
//
// SOURCE ORDER IS IRRELEVANT is not an inference, it is grid cell
// `g8_sortorder_refutation`: with the owner written FIRST in the file and named
// `zholder`, a user named `auser` gets `class_var`; with the owner written LAST
// and named `ahold`, a user named `zuser` gets `struct_var`.
//
// THE PREDICATE, in the four questions it actually asks:
//   (1) OWNER — is the declared type a TypeAlias whose home scope is a
//       ClassType?  A package / `$unit` typedef never reaches this law: its
//       typespec is built in the package pass, which runs before every class,
//       and `pkg::t` takes `compileVariable`'s `getPackage()` arm instead
//       (grid `g3` `c_pkg_scope`, `struct_var` on both sides).
//   (2) BODY FORM — is the declaration inside an OUT-OF-BODY (`extern`) method
//       definition?  That body is written at file scope and is compiled by the
//       FileContent pass, BEFORE ANY CLASS AT ALL, so NOTHING is resolved
//       there — not even the class's OWN typedef (grid `g6`: `v_ext_bare`
//       `ref_var`, `v_ext_scoped` and `v_ext_sibling` `class_var`, against
//       `struct_var` for all three inline).  This is what makes
//       `uvm_component::m_set_cl_action`'s `uvm_cmdline_parsed_arg_t t` a
//       `ref_var` in golden even though the typedef is `uvm_component`'s own.
//   (3) REACH (scoped spelling only) — the lookup rebuilds exactly ONE key,
//       `<the declaring class's OUTERMOST CONTAINER>::<the ONE written
//       segment>`, so the owner must be a DIRECT CHILD of that container and
//       the written scope must be a single segment.  An owner imported from
//       ANOTHER package is a `class_var` however the names sort (grid `g4`
//       `v_imported`); so is a two-segment spelling of a sibling in the
//       declaring class's OWN package (`px12::a12::a_t`, cell v12).
//       [V-FIX vsd10 — the shipped form of this question asked "self or a
//       class sharing the declaring class's PARENT SCOPE", which is the same
//       question only while the declaring class is NOT itself nested; see the
//       measured table at the `scopedReach` term below.]
//   (4) ORDER — was the owner's class compiled before the declaring class?
//       Its own typedef always is: `CompileClass` compiles a class's TYPES
//       before it binds any body (grid `g4` `v_self`, `g6` inline arm).  A
//       SIBLING is decided by comparing the leaf names, because the two map
//       keys differ only there.  A class NESTED in the declaring class carries
//       the declaring class's whole key as a PREFIX and therefore always sorts
//       AFTER it (grid `g4` `v_inner`).  A declaration compiled outside any
//       class — a module or `initial`-block local — is compiled before EVERY
//       class (grid `g3` `init_late` / `init_early`).
//
// WHAT THIS LAW DOES NOT DO, so the gate stated is the gate coded: it never
// changes the RESOLVED arm.  Grid `g7`'s `r_early_cls` — a SCOPED class-handle
// typedef whose owner IS compiled — is golden `class_var` and ours `ref_var`,
// because § aliasClassRefVar10 answers the bare-name question at a site that
// also sees the scoped spelling.  That is a real defect, it is left alone
// here, and it is filed as this pass's residue R1 with `g7` as its cell.
enum class TdLocalVarKind10 { Resolved, ClassVar, RefVar };

// The declaration CONTEXT Surelog compiles this symbol in: the nearest
// enclosing ClassType (null when the package / module / `$unit` pass compiles
// it instead), and whether an OUT-OF-BODY method definition was crossed on the
// way — `outOfBlockIndex` is non-zero exactly for an `extern` body, the same
// test src/ExprEmit.cpp already uses to refuse folding in one.
struct TdDeclCtx10 {
    const slang::ast::ClassType* cls = nullptr;
    bool outOfBody = false;
};

inline TdDeclCtx10 tdDeclCtx10(const slang::ast::Symbol& sym) {
    TdDeclCtx10 r;
    auto note = [&](const slang::ast::Symbol& ss) {
        if (ss.kind == slang::ast::SymbolKind::Subroutine &&
            ss.as<slang::ast::SubroutineSymbol>().outOfBlockIndex !=
                slang::ast::SymbolIndex(0))
            r.outOfBody = true;
    };
    note(sym);
    for (const slang::ast::Scope* sc = sym.getParentScope(); sc;
         sc = sc->asSymbol().getParentScope()) {
        const slang::ast::Symbol& ss = sc->asSymbol();
        note(ss);
        if (ss.kind == slang::ast::SymbolKind::ClassType) {
            r.cls = &ss.as<slang::ast::ClassType>();
            return r;
        }
        if (ss.kind == slang::ast::SymbolKind::Package ||
            ss.kind == slang::ast::SymbolKind::CompilationUnit ||
            ss.kind == slang::ast::SymbolKind::InstanceBody)
            return r;
    }
    return r;
}

// `tyOverride`, added by r10sd12 and used by NOTHING ELSE than
// § declArrayElemKindIsDeclKind12: the DECLARATOR-ARRAY element variable asks
// this same predicate about the declaration's WRITTEN BASE TYPE, which is the
// declared type with the declarator's own dimensions peeled off.  Every existing
// caller passes nothing and reads `dt->getType()` exactly as before.
inline TdLocalVarKind10 classTdLocalVarKind10(
    const slang::ast::Symbol& declSym,
    const slang::ast::Type* tyOverride = nullptr) {
    const slang::ast::DeclaredType* dt = declSym.getDeclaredType();
    if (!dt)
        return TdLocalVarKind10::Resolved;
    const slang::ast::Type& ty = tyOverride ? *tyOverride : dt->getType();
    // (1) OWNER
    if (ty.kind != slang::ast::SymbolKind::TypeAlias)
        return TdLocalVarKind10::Resolved;
    const slang::ast::Scope* osc = ty.getParentScope();
    if (!osc || osc->asSymbol().kind != slang::ast::SymbolKind::ClassType)
        return TdLocalVarKind10::Resolved;
    const slang::ast::ClassType& owner =
        osc->asSymbol().as<slang::ast::ClassType>();
    // V-FIX vsd10 — `oneSeg` is the SCOPED arm's own question and is measured,
    // not assumed: a written scope of TWO OR MORE segments (`pkg::cls::td`,
    // `otherpkg::cls::td`) NEVER resolves, because the lookup below rebuilds
    // exactly ONE key, `<container>::<the one written segment>`.  Cells
    // `v12_segment_probe` `s_sib2` (`px12::a12::a_t`, an EARLY-sorting sibling
    // of the declaring class's own package — golden `class_var`, and we emitted
    // `struct_var` before this term), `v4` `v_imported` and `v6` `v_inh_scoped`.
    bool scoped = false;
    bool oneSeg = false;
    if (auto* tsyn = dt->getTypeSyntax())
        if (auto* nts = tsyn->as_if<syntax::NamedTypeSyntax>())
            if (nts->name &&
                nts->name->kind == syntax::SyntaxKind::ScopedName) {
                scoped = true;
                auto& sn = nts->name->as<syntax::ScopedNameSyntax>();
                // ONE segment means ONE class name, parameterisation included:
                // a PARAMETERIZED owner is written `aparm#(int)::td` and slang
                // gives that segment a `ClassName` node, not an
                // `IdentifierName`.  Measured both ways — cell `v6`
                // `v_early_parm` (`aparm6#(int)::prec_t`, EARLY-sorting owner)
                // is golden `struct_var` and must RESOLVE, while `v2`'s
                // `zparm2#(int)::prec_t` and `zother2#(int)::orec_t`
                // (LATE-sorting owners) stay golden `class_var` and are held
                // back by the ORDER term, not by this one.  Reading only
                // `IdentifierName` here regressed `v_early_parm` and the cell
                // caught it before this fix landed.
                auto lk = (&*sn.left)->kind;
                oneSeg = lk == syntax::SyntaxKind::IdentifierName ||
                         lk == syntax::SyntaxKind::ClassName;
            }
    const TdDeclCtx10 ctx = tdDeclCtx10(declSym);
    const slang::ast::Scope* op = owner.getParentScope();
    const slang::ast::Scope* dp = ctx.cls ? ctx.cls->getParentScope() : nullptr;
    const bool self = ctx.cls == &owner;
    const bool sibling = ctx.cls && op && dp && op == dp;
    // (4) ORDER.  Only a SIBLING is compared, and then by LEAF NAME, because
    // two siblings' map keys differ only there.  Every other owner is treated
    // as NOT YET COMPILED, which is the fallback direction: the scoped arm's
    // question (3) already forces the fallback for one, and the only way a bare
    // name can reach a non-sibling owner at all is INHERITANCE ACROSS SCOPES,
    // where this predicate does not reconstruct the two full keys.  Named as a
    // limit rather than hidden: on this corpus that case is `adpcm_pkg::…`
    // inheriting from `uvm_pkg::…`, where the full-key relation agrees with the
    // fallback anyway.
    const bool ownerCompiled =
        !ctx.outOfBody && ctx.cls &&
        (self || (sibling && owner.name < ctx.cls->name));
    // (3) REACH — the SCOPED spelling's own question, and NOT redundant with
    // (4): the three lookups rebuild the owner's key as `<scope>::<name>` from
    // the DECLARING component's name, and a `$unit`-level class is registered
    // as `work@<name>`, which none of the three ever spells.  So a `$unit`
    // sibling — and a `$unit` class's OWN typedef, written with its own scope —
    // is a `class_var` even though the owner IS compiled.  MEASURED, both ways:
    // grid `g9`, `v_unit_sibling` / `v_unit_self_scoped` `class_var` against
    // `v_mod_sibling` `struct_var` for the same shape inside a MODULE (whose
    // name, `work@top`, the lookup does spell).
    //
    // V-FIX vsd10 — THE SCOPED ARM RESOLVES AGAINST THE DECLARING CLASS'S
    // OUTERMOST CONTAINER, AND AGAINST NOTHING ELSE.
    //
    // The shipped form asked `self || sibling` with `sibling` meaning "the two
    // classes share a PARENT SCOPE", and read `nameableScope` off that parent.
    // For a class declared at package / module / `$unit` level the two readings
    // agree exactly (the parent scope IS the container), which is why every
    // corpus row and every grid10 cell is unmoved by this term.  They come
    // apart the moment the DECLARING class is itself NESTED in another class,
    // and there the shipped form is wrong in BOTH directions:
    //
    //   MEASURED, golden vs the shipped binary (cells v9/v11/v12/v13/v14):
    //     `outer::o_t` from a class nested in `outer`      golden struct_var,
    //         shipped class_var   <- PRISTINE-RIGHT -> PATCHED-WRONG
    //     `o12::o_t` from a class nested TWO deep          golden struct_var,
    //         shipped class_var   <- same regression, module scope too
    //         (`mo11::o_t` from `mo11::mi11`, cell v11)
    //     `a13::a_t`, a TOP-LEVEL early sibling, named from inside a nested
    //         class                                        golden struct_var,
    //         shipped class_var   <- same regression
    //     `m13::m_t`, a NESTED class's OWN typedef, self-qualified
    //                                                      golden class_var,
    //         shipped struct_var  <- the other direction
    //     `n13::n_t`, a SIBLING NESTED class                golden class_var,
    //         shipped answers it by ORDER, so it is right only while the names
    //         happen to sort that way (cell v14 renames it and the answer flips
    //         while golden does not)
    //
    // The rule that answers all fourteen measured cells at once: Surelog
    // rebuilds ONE key, `<the declaring class's outermost container>::<the one
    // written segment>`, and resolves only if that key names the owner.  So the
    // owner must be a DIRECT CHILD of the container the declaring class's
    // outermost enclosing class sits in — `px13::a13` is, `px13::o13::n13` is
    // not — and the container must be NAMEABLE, which `$unit` is not (that is
    // the shipped law's `g9`, preserved here: the walk stops at a
    // CompilationUnit and `rootNameable` is false).
    //
    // ORDER then compares that same key against the DECLARING class's key.
    // When the owner IS the outermost enclosing class, its key is a strict
    // PREFIX of the declaring class's, so it always sorts first and is always
    // compiled — that is why `outer::o_t` resolves from an inner class while
    // `o12::m12::m_t` does not.  Otherwise the two keys share the container
    // prefix and differ at the next segment, so the LEAF comparison is against
    // the OUTERMOST class's name, not the declaring class's.
    const slang::ast::ClassType* topCls = ctx.cls;
    while (topCls) {
        const slang::ast::Scope* tp = topCls->getParentScope();
        if (tp && tp->asSymbol().kind == slang::ast::SymbolKind::ClassType)
            topCls = &tp->asSymbol().as<slang::ast::ClassType>();
        else
            break;
    }
    const slang::ast::Scope* rootScope =
        topCls ? topCls->getParentScope() : nullptr;
    bool rootNameable = false;
    if (rootScope) {
        auto k = rootScope->asSymbol().kind;
        rootNameable = k == slang::ast::SymbolKind::Package ||
                       k == slang::ast::SymbolKind::InstanceBody;
    }
    const bool scopedReach = !ctx.outOfBody && ctx.cls && oneSeg &&
                             rootNameable && op && op == rootScope;
    const bool scopedOrder =
        topCls && (&owner == topCls || owner.name < topCls->name);
    if (scoped)
        return (scopedReach && scopedOrder) ? TdLocalVarKind10::Resolved
                                            : TdLocalVarKind10::ClassVar;
    // BARE spelling.  Surelog reaches the typedef LEXICALLY here
    // (`component->getDataType`), so question (3) does not apply and a `$unit`
    // class's own bare typedef resolves (grid `g9` `v_unit_self_bare`).  A bare
    // name reaching a class-nested typedef from OUTSIDE any class is not
    // expressible, so that arm is carried UNEXERCISED and deliberately changes
    // nothing rather than guessing a fallback never measured.
    if (!ctx.cls)
        return TdLocalVarKind10::Resolved;
    return ownerCompiled ? TdLocalVarKind10::Resolved
                         : TdLocalVarKind10::RefVar;
}

// ---------------------------------------------------------------------------
// § blockLocalTdDeclIsRefVarUnsupported155
//
// THE LAW.  A declaration whose written type is a BARE NAME that denotes a
// TYPEDEF DECLARED INSIDE A STATEMENT SCOPE — a `begin` / `fork` arm / loop
// body / `case` item, a subroutine BODY, an `initial` / `always` body — binds
// NOT that typedef's real typespec but an `unsupported_typespec` NAMED with
// the WRITTEN TYPE NAME and SPANNED over it, and the declaration itself is a
// `ref_var`, whatever the typedef's target type is.  UNLESS the same NAME also
// denotes a type OUTSIDE every statement scope (a class / package / module /
// `$unit` typedef, a type parameter, or a CLASS), in which case Surelog binds
// THAT one and nothing about the declaration moves.
//
// WHY, read off Surelog.  `CompileHelper::compileStmt`'s `paType_declaration`
// arm (`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:1284-1290`) is
//
//     case VObjectType::paType_declaration: {
//       if (pstmt) {
//         // Keep type declaration local to the current stmt
//         component = nullptr;
//       }
//       compileTypeDef(component, fC, fC->Parent(nodeId), …, pstmt);
//
// and every `insertTypeDef` / `insertDataType` inside `compileTypeDef`
// (`CompileHelper.cpp:558-636, 742-895`) is guarded `if (scope)`.  A typedef
// compiled as a STATEMENT therefore lands in NO `DesignComponent`'s data-type
// map — and a subroutine BODY takes that same arm, because
// `compileTask`/`compileFunction` pass the synthesised `begin` as `pstmt`
// (`CompileStmt.cpp:2046-2075`).  So when the declaration is compiled:
//   * `compileVariable` (`CompileType.cpp:340-435`) finds no
//     `component->getDataType(typeName)` and no `design->getClassDefinition`,
//     and falls to its FINAL arm — `ref_var` (`CompileType.cpp:421-431`);
//   * the `ts` it binds came from `compileTypespec`'s `slStringConst` arm,
//     which ends in `compileDatastructureTypespec`'s catch-all
//     (`CompileType.cpp:1051-1055`): an `unsupported_typespec` carrying
//     `VpiName(typeName)` and `populateCoreMembers(type, type, …)`, i.e. the
//     WRITTEN NAME and the WRITTEN NAME'S SPAN;
//   * `needLateTypedefBinding` can NEVER repair it, because
//     `ElaborationStep::bindTypedefs_`'s `defs` vector
//     (`ElaborationStep.cpp:110-148`) is built from file contents, packages,
//     modules, programs and classes ONLY — a statement-scope typedef is in
//     none of them, so its name never enters the `specs` map.
// The placeholder's `vpiInstance` is `component->getUhdmInstance()`
// (`CompileType.cpp:2135-2136`) — the same pointer every other typespec of the
// declaration takes, which is why the sites stamp it from their own `tsInst` /
// `pkgScopeInst` rather than re-deriving it.
//
// MEASURED, arm by arm (grid155, five arms, both views, golden vs ours):
//   * `g155_a_home`  — ELEVEN homes all degrade IDENTICALLY: a `begin` in an
//     in-body class method, an in-body method's body top level, a class TASK,
//     an OUT-OF-BODY method's body level AND its nested `begin`, a package
//     free function, a module `initial`, a module function, a module task, an
//     `always_comb` named block, a `fork` arm, a `for` body, a `case` item and
//     an `initial` inside a GENERATE block.  The vpiInstance is the home
//     PACKAGE for the package free function and the out-of-body method
//     (`Hive155`) and NOTHING for every other home — exactly `tsInst`.
//     The same file's `hivePkgWidth` / `RoostMember` controls RESOLVE.
//   * `g155_b_form`  — ELEVEN declared-type forms off a statement-scope
//     typedef (vector, `logic`, `int`, `string`, inline enum, packed struct,
//     typedef-of-local-typedef, alias of a CLASS, alias of a TYPE PARAMETER,
//     alias of a PACKAGE typedef, and one in a module function) ALL degrade,
//     against package enum / package struct / package typedef-of-typedef /
//     class typedef / class name / parameterised class name / `$unit` typedef
//     controls that all RESOLVE.
//   * `g155_c_shape` — 1, 2 and 3 declarators, with and without an
//     INITIALISER, a PACKED dimension written at the use, and a use from a
//     NESTED `begin` all degrade; the four DECLARATOR-ARRAY forms put the
//     placeholder on the ELEMENT variable and leave the `array_var` /
//     `array_typespec` untouched.
//   * `g155_d_gate`  — the SHADOW gate from every home: a local typedef whose
//     name is also a PACKAGE / MODULE / `$unit` / CLASS typedef RESOLVES to
//     the OUTER one (`shadowPkgName`, `modCarryShadow`, `modUnitShadow`,
//     `ibBeadShadow`); a typedef declared DIRECTLY in a GENERATE block
//     RESOLVES (`mintVal`) because a generate block is not a statement scope;
//     and a use three `begin`s deep still degrades (`vaultVal`).
//   * `g155_e_edge`  — a local typedef whose name is also a CLASS in the same
//     package makes the declaration a `class_var` (`clashClassName`,
//     `compileVariable`'s `getClassDefinition` arm), while a local typedef
//     named after a MODULE still degrades (`clashModuleName`); `const`,
//     `automatic` and `static` locals degrade exactly like a plain one.
//
// THE ANSWER: the WRITTEN TYPE NAME when the law fires, empty otherwise.
inline bool isStmtScopeSym155(const slang::ast::Symbol& s) {
    return s.kind == slang::ast::SymbolKind::StatementBlock ||
           s.kind == slang::ast::SymbolKind::Subroutine;
}

// § blockLocalTdDeclIsRefVarUnsupported155, THE SHADOW GATE'S TYPE TEST.
// Anything that could answer `component->getDataType` /
// `design->getClassDefinition` / the `getParameters()` type-parameter arm for
// this name.  A plain VALUE of the same name is none of those and is
// deliberately NOT a decline.
inline bool typeLike155(const slang::ast::Symbol& h) {
    return h.isType() ||
           h.kind == slang::ast::SymbolKind::TypeParameter ||
           h.kind == slang::ast::SymbolKind::GenericClassDef ||
           h.kind == slang::ast::SymbolKind::ForwardingTypedef;
}

// § blockLocalTdDeclIsRefVarUnsupported155, THE IMPORT HALF OF THE SHADOW GATE
// (added by the adversarial verifier r10v155; see tools/probe/r10v155repro).
//
// `Scope::find` is DIRECT MEMBERS ONLY.  It returns nullptr for an
// `ExplicitImport` (slang `source/ast/Scope.cpp:582-584`, "Don't return
// imported symbols; this function is for querying direct members only"), and a
// WILDCARD import is not in the name map at all (`include/slang/ast/symbols/
// MemberSymbols.h:88-91`, "won't even be in the name map of a symbol at all…
// there is a sideband list").  Surelog's `getDataType` /
// `getClassDefinition` DO resolve an imported name, so without this probe the
// law fires on a declaration golden never degrades.
//
// MEASURED (`tools/probe/r10v155repro/v155_e_import.sv`, both views, golden vs
// ours): a statement-scope `typedef int` shadowing an EXPLICITLY imported class
// (`import pq::KExpl155v;`) and a WILDCARD-imported class (`import pq::*;`) —
// golden reads `class_var` + `class_typespec` on BOTH, i.e. it binds the CLASS
// and the local typedef is invisible.  Without this probe the law minted
// `ref_var` + `unsupported_typespec` on all FOUR cells (2 declarations x 2
// views).  A class that is a DIRECT member of an enclosing scope was already
// declined by `Scope::find` (v155_e_import `KLoc155v`), and a class in a
// package that is NOT imported is correctly degraded by golden too
// (`KNone155v` — golden `ref_var` + `unsupported_typespec`), which is why the
// probe asks about IMPORTS ONLY and never about the design at large.
inline bool importedTypeLike155(const slang::ast::Scope& sc,
                                std::string_view nm) {
    for (const auto& m : sc.members()) {
        if (m.kind == slang::ast::SymbolKind::ExplicitImport && m.name == nm) {
            if (const slang::ast::Symbol* is =
                    m.as<slang::ast::ExplicitImportSymbol>().importedSymbol())
                if (typeLike155(*is))
                    return true;
        }
    }
    if (auto* wd = sc.getWildcardImportData()) {
        for (const slang::ast::WildcardImportSymbol* wi : wd->wildcardImports) {
            if (const slang::ast::PackageSymbol* pkg = wi->getPackage())
                if (const slang::ast::Symbol* hit = pkg->find(nm))
                    if (typeLike155(*hit))
                        return true;
        }
    }
    return false;
}

// § blockLocalTdDeclIsRefVarUnsupported155, THE PROGRAM CARVE-OUT (added by
// the adversarial verifier r10v155; see tools/probe/r10v155repro).
//
// A MODULE's and an INTERFACE's collect walk STOPS at a procedural block:
// `CompileModule.cpp:529-538` lists
//   paPar_block, paSeq_block, paFunction_body_declaration,
//   paTask_body_declaration
// among its `stopPoints`, so a `paData_declaration` — and therefore the
// `paType_declaration` inside it — is NEVER reached by
// `CompileHelper::compileDataDeclaration` (`CompileHelper.cpp:2260-2277`,
// which calls `compileTypeDef(component, …, /*pstmt*/ nullptr)` and DOES
// register).  Only `compileStmt`'s `paType_declaration` arm sees it, with
// `component = nullptr` — and the declaration degrades.
//
// A PROGRAM's collect walk has stopPoints = `{ paClass_declaration }` and
// NOTHING ELSE (`CompileProgram.cpp:97-99`).  It therefore DESCENDS into an
// `initial` / `final` block's `paSeq_block`, reaches the `paData_declaration`,
// and registers the typedef in the Program component — so `compileVariable`
// resolves it and NOTHING degrades.
//
// MEASURED (`tools/probe/r10v155repro/v155_g_program.sv`, both views, golden vs
// ours), every typedef name unique in the design:
//   module   initial / always_comb / final / task body  -> golden DEGRADES (4)
//   interface initial / task body                       -> golden DEGRADES (2)
//   package  function body                              -> golden DEGRADES (1)
//   PROGRAM  initial / final                            -> golden RESOLVES  (2)
//   PROGRAM  task body                                  -> golden DEGRADES (1)
// The discriminator is therefore: a statement scope that reaches a PROGRAM's
// body WITHOUT passing through a SUBROUTINE is registered and must not degrade.
// Without this carve-out the law fired on the two program cells and drove them
// AWAY from golden — `byte_var` + `byte_typespec` (2 of 4 payload fields
// already right) became `ref_var` + `unsupported_typespec` (1 of 4).
inline bool stmtScopeIsProgramProcedural155(const slang::ast::Scope& home) {
    for (const slang::ast::Scope* sc = &home; sc;
         sc = sc->asSymbol().getParentScope()) {
        const slang::ast::Symbol& ss = sc->asSymbol();
        // A subroutine body is a stop point in EVERY container, a program
        // included, so the law still fires below one.
        if (ss.kind == slang::ast::SymbolKind::Subroutine)
            return false;
        if (ss.kind == slang::ast::SymbolKind::InstanceBody) {
            return ss.as<slang::ast::InstanceBodySymbol>()
                       .getDefinition()
                       .definitionKind == slang::ast::DefinitionKind::Program;
        }
    }
    return false;
}

inline std::string_view stmtScopeTdName155(const slang::ast::Symbol& declSym) {
    const slang::ast::DeclaredType* dt = declSym.getDeclaredType();
    if (!dt)
        return {};
    // (1) SPELLING — ONE BARE IDENTIFIER.  A `Scope::td` spelling is
    // § classScopedTdDeclTsUnsupported11's and can never name a
    // statement-scope typedef; a built-in keyword type is not a NamedType.
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return {};
    auto& nt155 = tsyn->as<syntax::NamedTypeSyntax>();
    if (!nt155.name)
        return {};
    // ...and the SAME spelling with PACKED DIMENSIONS written at the USE
    // (`weftKind [1:0] warpPacked;`), which slang parses as ONE
    // `IdentifierSelectName` rather than a name plus dimensions.  Golden
    // degrades it exactly like the bare form and SPANS the placeholder from
    // the type through the LAST packed dimension — `compileTypespec`'s
    // `if (ranges && result)` tail re-runs `populateCoreMembers(type,
    // last_Packed_dimension, result)` (CompileType.cpp:1958-1967) after
    // `compileDatastructureTypespec` has already spanned it over the name
    // alone.  `tsyn->sourceRange()` is that wider span, so the factory needs
    // no special case (grid155 `warpPacked`, golden
    // `unsupported_typespec (weftKind) @25:7-25:21`).
    std::string_view nm155;
    if (nt155.name->kind == syntax::SyntaxKind::IdentifierName)
        nm155 = nt155.name->as<syntax::IdentifierNameSyntax>()
                    .identifier.valueText();
    else if (nt155.name->kind == syntax::SyntaxKind::IdentifierSelectName)
        nm155 = nt155.name->as<syntax::IdentifierSelectNameSyntax>()
                    .identifier.valueText();
    if (nm155.empty())
        return {};
    // (2a) THE CHEAP GATE, asked BEFORE any name lookup.  The declared type
    // must ALREADY be — or contain as its element — a `TypeAliasType` of that
    // very name whose HOME is a statement scope.  This is read straight off
    // the DeclaredType every other law at these sites already resolves, and it
    // costs nothing.
    //
    // WHY IT IS ASKED FIRST, and not merged into the walk below: a
    // `Scope::find` FORCES that scope's members to be elaborated, and RESUME
    // §9's Heisenbug warning ("do not force AST binding during the DEF phase")
    // is exactly this hazard.  A first cut ran the walk for EVERY declaration
    // and the wide boundary gate caught the consequence in one arm —
    // r10buvm22repro/g22.sv, which slang REJECTS on both binaries (rc=4/4) and
    // whose declaration census moved 0 cells, but whose partial database moved
    // three folded constants inside an associative-dimension range.  With this
    // gate the lookup below runs only for a declaration that genuinely names a
    // statement-scope typedef.
    const slang::ast::TypeAliasType* al155 = nullptr;
    {
        const slang::ast::Type* t155 = &dt->getType();
        for (int g155 = 0; t155 && g155 < 16; g155++) {
            if (t155->kind == slang::ast::SymbolKind::TypeAlias) {
                al155 = &t155->as<slang::ast::TypeAliasType>();
                break;
            }
            const slang::ast::Type& ct155 = t155->getCanonicalType();
            using slang::ast::SymbolKind;
            if (ct155.kind == SymbolKind::PackedArrayType)
                t155 = &ct155.as<slang::ast::PackedArrayType>().elementType;
            else if (ct155.kind == SymbolKind::FixedSizeUnpackedArrayType)
                t155 = &ct155.as<slang::ast::FixedSizeUnpackedArrayType>()
                            .elementType;
            else if (ct155.kind == SymbolKind::QueueType)
                t155 = &ct155.as<slang::ast::QueueType>().elementType;
            else if (ct155.kind == SymbolKind::DynamicArrayType)
                t155 = &ct155.as<slang::ast::DynamicArrayType>().elementType;
            else if (ct155.kind == SymbolKind::AssociativeArrayType)
                t155 = &ct155.as<slang::ast::AssociativeArrayType>()
                            .elementType;
            else
                break;
        }
    }
    if (!al155 || al155->name != nm155)
        return {};
    const slang::ast::Scope* home155 = al155->getParentScope();
    if (!home155 || !isStmtScopeSym155(home155->asSymbol()))
        return {};
    // …and it must not be a PROGRAM's procedural block, whose collect walk has
    // no `paSeq_block` stop point and therefore REGISTERS the typedef.  See
    // `stmtScopeIsProgramProcedural155` above for the Surelog citations and the
    // ten measured cells.
    if (stmtScopeIsProgramProcedural155(*home155))
        return {};
    const std::string key155(nm155);
    bool found155 = false;
    for (const slang::ast::Scope* sc = declSym.getParentScope(); sc;
         sc = sc->asSymbol().getParentScope()) {
        const slang::ast::Symbol& ss = sc->asSymbol();
        const slang::ast::Symbol* hit = sc->find(key155);
        if (!found155) {
            if (!hit)
                continue;
            // (2) THE NAME MUST FIRST BE FOUND IN A STATEMENT SCOPE, AS A
            // TYPEDEF.  Found anywhere else first (a generate block, a class,
            // a package, `$unit`) means Surelog resolved it too.
            if (!isStmtScopeSym155(ss) ||
                hit->kind != slang::ast::SymbolKind::TypeAlias)
                return {};
            found155 = true;
            continue;
        }
        // (3) THE SHADOW GATE.  Statement scopes above are just as invisible
        // to Surelog, so they are skipped; anything type-like OUTSIDE them
        // means `getDataType` / `getClassDefinition` answers and the
        // declaration keeps its resolved shape (`g155_d_gate`, `g155_e_edge`).
        if (isStmtScopeSym155(ss))
            continue;
        if (hit && typeLike155(*hit))
            return {};
        // …and the same question asked of this scope's IMPORTS, which
        // `Scope::find` cannot answer.  See `importedTypeLike155` above for the
        // slang citations and the four measured cells.
        if (!hit && importedTypeLike155(*sc, key155))
            return {};
    }
    return found155 ? nm155 : std::string_view{};
}

// ---------------------------------------------------------------------------
// § namedBaseUnpackedTdRetVar22
//
// THE LAW.  The FUNCTION RETURN VARIABLE of a function whose RETURN TYPE names
// a TYPEDEF THAT CARRIES UNPACKED DIMENSIONS (`typedef <base> t[$] / [] /
// [idx] / [N];`) is
//
//   * a `ref_var`  when the typedef's WRITTEN BASE is a NAMED TYPE and
//     Surelog's typedef pass never attaches a typespec to that typedef, and
//   * an `array_var` otherwise,
//
// and it is NEVER the `logic_var` our factory's fall-through gives a queue /
// dynamic / associative return today.
//
// DECODED FROM SURELOG, not inferred.  `compileTaskFunc` builds the return
// object with `compileVariable(component, fC, Return_data_type, …)`
// (CompileStmt.cpp:2400-2416), and for a return type written as a NAME that
// lands in `CompileType.cpp`'s `slStringConst` arm (:337-431), whose FIRST
// question is
//
//     if (const DataType* dt = component->getDataType(typeName))
//       if (typespec* tps = dt->getActual()->getTypespec())
//         if (variables* var = getSimpleVarFromTypespec(tps, ranges, …))
//
// `getSimpleVarFromTypespec` (CompileType.cpp:78-233) turns an
// `array_typespec` with no `Index_typespec` into an `array_var` — so WHEN the
// typedef has a typespec, an unpacked-array return is an `array_var`, whatever
// the container flavour.  WHEN IT DOES NOT, the arm is skipped,
// `design->getClassDefinition(<the alias name>)` cannot find a class of that
// name, the `class_typespec` test fails (the alias's own typespec is the
// ARRAY, not a class), and control reaches the arm's tail — a bare
// `s.MakeRef_var()` carrying the declaration's typespec (:421-431).  That
// `ref_var` is never redeemed: `swapForSpecifiedVar` /
// `lateTypedefBinding` only run for typespecs `getSimpleVarFromTypespec`
// knows, and `UhdmWriter.cpp:1066`'s class-body `lateTypedefBinding` is
// commented out (buvm17/19).
//
// WHICH TYPEDEFS HAVE NO TYPESPEC is `compileTypedef`'s own split
// (CompileHelper.cpp:600-1100):
//
//   * an INLINE `struct` / `union` base (:657-1035) sets `st->setTypespec(...)`
//     UNCONDITIONALLY, and so does the INLINE `enum` base;
//   * a BUILT-IN base (`int`, `logic [7:0]`, `string`, …) takes the
//     `SimpleType` arm (:1053-1098) and ends `simple->setTypespec(ts)`,
//     UNCONDITIONALLY;
//   * a NAMED base (`slStringConst` / `paClass_scope`, :890-1052) builds a
//     `DummyType` and sets a typespec ONLY inside
//       `if ((reduce == Reduce::Yes) && (Package || FileContent))`
//     and then only when the base does NOT compile to a `class_typespec` or an
//     `unsupported_typespec` (:906-907).
//
// So a NAMED-base unpacked typedef is un-typespec'd — hence `ref_var` —
// in a CLASS, in a MODULE and in a `$unit` CLASS always; in a PACKAGE it is
// `ref_var` when the base is a CLASS (the `class_typespec` exclusion) and,
// when the base is a named NON-class, `ref_var` in the DEF listing (the
// `Reduce::No` pass) against `array_var` in every elaborated listing.
//
// MEASURED, GOLDEN, 190 grid cells over `g22.sv` + `g22b.sv` in BOTH views:
//
//   written base        typedef scope   golden return var
//   ------------------  --------------  ---------------------------------
//   int / logic[7:0] /  any             array_var        (all 5 listings)
//   string / inline
//   struct / inline enum
//   named CLASS         class/module    ref_var          (all listings)
//   named CLASS         package         ref_var          (all listings)
//   named non-class     class/module    ref_var          (all listings)
//   named non-class     package         ref_var in DEFPKG, array_var else
//   type parameter      class           ref_var          (all listings)
//
// and the container flavour is IRRELEVANT — `[$]`, `[]`, `[string]`, `[int]`
// and `[4]` answer identically in every row of that table (cells
// `pc_q_*`/`pc_d_*`/`pc_a_*`/`pc_f_*` and `pf_*`).
//
// THE FENCE, enumerated before the code was written: across BOTH corpora only
// NINE databases contain a function whose return typespec is an
// `array_typespec` at all.  Four of them — `ArrayExprFuncArg`,
// `DefaultPatternInt`, `DefaultPatternModule`, `FuncRetArray`, all CMP_EQUAL —
// carry `typedef int unsigned ASSIGN_VADDR_RET_T[2];`, whose written base is
// the KEYWORD `int unsigned`, so this predicate answers `ArrayVar` and leaves
// the object they already have.  The `uhdm2rtlil` corpus has NONE (0 of 1358).
enum class UnpackedTdRetKind22 { Unchanged, RefVar, ArrayVar };

inline UnpackedTdRetKind22 unpackedTdRetVarKind22(
    const slang::ast::Symbol& sub, const slang::ast::Type& retType,
    bool defPkgListing) {
    // (0) THE OUT-OF-BODY EXCLUSION.  An `extern` definition's return object is
    // NOT this law's: golden answers it with a `class_var` in five of the six
    // listings a package class has (cells `po_q_cls`, `po_f_cls`, `po_tdcls`,
    // `po_tdstruct`, `po_pq_cls` — only the ELABPKG/DEF listing shows the
    // redeemed kind), which is § classTdLocalVarKindFollowsCompileOrder10's
    // out-of-body arm, already emitted for every class-scoped spelling.  A
    // PACKAGE-scoped typedef named from an out-of-body body reaches that law's
    // early `Resolved` and would otherwise fall through to here.
    if (tdDeclCtx10(sub).outOfBody)
        return UnpackedTdRetKind22::Unchanged;
    if (retType.kind != slang::ast::SymbolKind::TypeAlias)
        return UnpackedTdRetKind22::Unchanged;
    const auto& ta = retType.as<slang::ast::TypeAliasType>();
    // The DIMENSIONS must be WRITTEN ON THE TYPEDEF.  A function returning a
    // typedef whose TARGET is itself an array typedef (`typedef q_t alias_t;`)
    // is a different declaration for Surelog and is deliberately not this
    // law's (the no-dimension arm is residue R1, measured in `g22b.sv`).
    const slang::syntax::SyntaxNode* syn = ta.getSyntax();
    if (!syn || syn->kind != slang::syntax::SyntaxKind::TypedefDeclaration)
        return UnpackedTdRetKind22::Unchanged;
    const auto& tds = syn->as<slang::syntax::TypedefDeclarationSyntax>();
    if (tds.dimensions.empty())
        return UnpackedTdRetKind22::Unchanged;
    // …and they must really be UNPACKED (a PACKED dimension written after the
    // name is not expressible, but a typedef whose canonical type is not a
    // container means the peel below has nothing to walk — refuse rather than
    // guess).
    switch (retType.getCanonicalType().kind) {
        case slang::ast::SymbolKind::QueueType:
        case slang::ast::SymbolKind::DynamicArrayType:
        case slang::ast::SymbolKind::AssociativeArrayType:
        case slang::ast::SymbolKind::FixedSizeUnpackedArrayType:
            break;
        default:
            return UnpackedTdRetKind22::Unchanged;
    }
    // (1) THE WRITTEN BASE.  Only a NAMED type reaches `compileTypedef`'s
    // DummyType arm; every keyword / inline-aggregate base is typespec'd
    // unconditionally and is therefore redeemed to an `array_var`.
    if (tds.type->kind != slang::syntax::SyntaxKind::NamedType)
        return UnpackedTdRetKind22::ArrayVar;
    // (2) THE TYPEDEF'S OWN SCOPE — the `Package || FileContent` gate.  Note
    // this asks where the TYPEDEF lives, not where the FUNCTION lives: cells
    // `pc_pq_cls` / `pc_pq_int` are a package typedef named by a class method
    // and answer with the PACKAGE row of the table.
    const slang::ast::Scope* tsc = ta.getParentScope();
    const bool eager =
        tsc && (tsc->asSymbol().kind == slang::ast::SymbolKind::Package ||
                tsc->asSymbol().kind ==
                    slang::ast::SymbolKind::CompilationUnit);
    if (!eager)
        return UnpackedTdRetKind22::RefVar;
    // (3) THE BASE'S KIND — the `class_typespec` exclusion.  Peel exactly the
    // dimensions WRITTEN on the typedef (never "peel every array level": a
    // typedef of an array typedef must keep its own level), the same discipline
    // § declArrayElemKindIsDeclKind12 uses.
    const slang::ast::Type* bt = &ta.targetType.getType();
    for (size_t i = 0; i < tds.dimensions.size() && bt; i++) {
        const slang::ast::Type& c = bt->getCanonicalType();
        if (c.kind == slang::ast::SymbolKind::QueueType)
            bt = &c.as<slang::ast::QueueType>().elementType;
        else if (c.kind == slang::ast::SymbolKind::DynamicArrayType)
            bt = &c.as<slang::ast::DynamicArrayType>().elementType;
        else if (c.kind == slang::ast::SymbolKind::AssociativeArrayType)
            bt = &c.as<slang::ast::AssociativeArrayType>().elementType;
        else if (c.kind == slang::ast::SymbolKind::FixedSizeUnpackedArrayType)
            bt = &c.as<slang::ast::FixedSizeUnpackedArrayType>().elementType;
        else
            break;
    }
    if (bt && bt->getCanonicalType().kind == slang::ast::SymbolKind::ClassType)
        return UnpackedTdRetKind22::RefVar;
    // (4) The named NON-class base in a package: the DEF listing keeps the
    // unredeemed `ref_var` the `Reduce::No` pass built, every elaborated
    // listing gets the redeemed `array_var` (cells `bf_q_tdint` /
    // `bf_q_tdenum` / `bf_q_tdstruct`, five listings each).
    return defPkgListing ? UnpackedTdRetKind22::RefVar
                         : UnpackedTdRetKind22::ArrayVar;
}

// ---------------------------------------------------------------------------
// § declArrayElemKindIsDeclKind12
//
// THE LAW.  The ELEMENT variable of a DECLARATOR-ARRAY declaration at
// SUBROUTINE / STATEMENT scope — `T name[int]`, `T name[$]`, `T name[]`,
// `T name[4]` — takes THE SAME OBJECT CLASS the SCALAR declaration `T name;`
// would take at that same site.  The array brackets decide the ARRAY_VAR's
// shape and NOTHING about the element's class.
//
// WHY, read off Surelog and then measured.  `CompileHelper::compileStmt`'s
// paVariable_declaration arm (src/DesignCompile/CompileStmt.cpp ~1173) compiles
// the declarator's dimensions and the DATA TYPE separately, and it builds the
// element by calling the ordinary scalar factory on the DATA-TYPE NODE ALONE:
//
//     variables* var = compileVariable(component, fC, Data_type, …);
//     …
//     if (unpackedDimensions) {
//       array_var* arr = s.MakeArray_var();
//       …
//       arr->VpiName(fC->SymName(Var));
//       var->VpiName("");        // <- the SAME object, renamed
//       var->VpiParent(arr);
//       vars->push_back(var);    // <- and re-parented under vpiReg
//     }
//
// So the element variable IS the scalar variable.  Every arm of
// `compileVariable` therefore reaches it unchanged, and in particular the two
// laws this emitter already carries for a class-nested typedef at subroutine
// scope do:
//
//   * § classTdLocalVarKindFollowsCompileOrder10 — a `Owner::td` spelling ends
//     at `compileVariable`'s paClass_scope arm, whose BOTH halves yield a
//     `class_var` (the resolved half runs `getSimpleVarFromTypespec` on a
//     class_typespec, CompileType.cpp ~134; the tail is literally
//     `if (var == nullptr) var = s.MakeClass_var()`, ~616), and a BARE `td`
//     in an OUT-OF-BODY method body ends at the bare arm's `MakeRef_var`
//     tail (~421).
//   * § aliasClassRefVar10 — the bare class-handle alias's `ref_var`.
//
// OURS ASKED NEITHER.  The four declarator-array element sites call
// `makeReturnVar(s, <ELEMENT TYPE>)`, i.e. they hand the factory the type with
// the brackets ALREADY PEELED and never look at how the declaration was
// WRITTEN.  A `Owner::td` element then falls to § aliasClassRefVar10's
// `ref_var` (golden: `class_var`) and a bare class-nested STRUCT typedef in an
// out-of-body body falls to `struct_var` (golden: `ref_var`).  Both are on the
// corpus and BOTH are converted by this one predicate:
//
//   uvm_resource.svh:955  `uvm_resource_types::rsrc_q_t all[int];`
//       golden class_var / ours ref_var    <- THE SeqDriver HEAD (r10sd11 R0)
//   uvm_factory.svh:2036  `m_inst_typename_alias_t type_alias_inst[$];`
//       golden ref_var   / ours struct_var <- BuildUVMPkg, the same law's
//                                             OTHER arm, in the other direction
//
// THE PREDICATE IS NOT A NEW ONE.  It is r10sd10's, asked about the
// declaration's WRITTEN BASE TYPE instead of its full declared type — the
// SPELLING half (`scoped` / `oneSeg`) already reads `getTypeSyntax()`, which
// for a declarator is the base `Owner::td` node and carries no brackets at all,
// so only the TYPE had to be peeled.  Peeling is by the number of dimensions
// WRITTEN ON THE DECLARATOR, never "peel every array level", because a typedef
// that is ITSELF an array (`typedef int arr_t[4]; arr_t a[2];`) must keep its
// own level: Surelog compiles `arr_t` as the Data_type and the declarator's
// `[2]` as the unpacked dimension, and nothing else.
//
// WHAT THIS DOES NOT TOUCH, stated so the gate written is the gate coded:
// the `Resolved` arm is byte-unchanged — it still calls `makeReturnVar` on the
// element type, so every int / bit / logic / enum / struct / string / class
// element the corpus has today keeps the object it has today.  The law can only
// fire where r10sd10's predicate fires, i.e. where the declared type NAMES A
// TYPEDEF THAT LIVES IN A CLASS.
inline const slang::ast::Type* declArrayElemDeclType12(
    const slang::ast::Symbol& sym) {
    const slang::ast::DeclaredType* dt = sym.getDeclaredType();
    if (!dt)
        return nullptr;
    size_t ndim = 0;
    if (auto* dsyn = sym.getSyntax())
        if (dsyn->kind == syntax::SyntaxKind::Declarator)
            ndim = dsyn->as<syntax::DeclaratorSyntax>().dimensions.size();
    if (!ndim)
        return nullptr;
    const slang::ast::Type* t = &dt->getType();
    for (size_t i = 0; i < ndim; i++) {
        const slang::ast::Type& c = t->getCanonicalType();
        // `elementType` is the DECLARED element, so a typedef survives the peel
        // (that is the whole point: the predicate below asks about the alias).
        if (c.kind == slang::ast::SymbolKind::QueueType)
            t = &c.as<slang::ast::QueueType>().elementType;
        else if (c.kind == slang::ast::SymbolKind::DynamicArrayType)
            t = &c.as<slang::ast::DynamicArrayType>().elementType;
        else if (c.kind == slang::ast::SymbolKind::AssociativeArrayType)
            t = &c.as<slang::ast::AssociativeArrayType>().elementType;
        else if (c.kind ==
                 slang::ast::SymbolKind::FixedSizeUnpackedArrayType)
            t = &c.as<slang::ast::FixedSizeUnpackedArrayType>().elementType;
        else
            // Fewer array levels than written dimensions (a PACKED dimension
            // written on the declarator, which is not an unpacked container).
            // Stop rather than guess; the caller's `Resolved` arm is the safe
            // direction.
            return t;
    }
    return t;
}

// r10sd10's question, asked about a DECLARATOR ARRAY's element.  `Resolved`
// whenever the declaration is not a declarator array at all, so a caller can
// apply it unconditionally.
inline TdLocalVarKind10 declArrayElemVarKind12(
    const slang::ast::Symbol& declSym, bool stmtScopeTd155 = false) {
    const slang::ast::Type* et = declArrayElemDeclType12(declSym);
    if (!et)
        return TdLocalVarKind10::Resolved;
    // § blockLocalTdDeclIsRefVarUnsupported155, the KIND half for the FOUR
    // DECLARATOR-ARRAY forms.  golden puts the placeholder and the `ref_var`
    // on the ELEMENT variable and leaves the `array_var` / `array_typespec`
    // alone (grid155 `g155_c_shape` warpFixed/warpQueue/warpDyn/warpAssoc and
    // `g155_e_edge` tongsFixed/tongsQueue/tongsDyn/tongsAssoc, both views).
    // The ANSWER is passed IN, not recomputed: question (4) — the
    // `bindTypedefs_` repair gate — needs the whole design's typedef-name
    // count, which lives on the exporter.  Asked FIRST because the two
    // predicates are mutually exclusive (this one needs a typedef declared in
    // a STATEMENT scope, r10sd10's needs one declared in a CLASS), so the
    // order is documentation, not precedence.
    if (stmtScopeTd155)
        return TdLocalVarKind10::RefVar;
    return classTdLocalVarKind10(declSym, et);
}

// ---------------------------------------------------------------------------
// § declArrayElemVarSignedIsAtomKeyword129
//
// THE LAW.  The ELEMENT VARIABLE of a DECLARATOR ARRAY carries `vpiSigned`
// only when the declaration's WRITTEN BASE TYPE is one of the five INTEGER
// ATOM KEYWORDS — `int`, `integer`, `byte`, `shortint`, `longint` — and then
// its value is "no `unsigned` keyword was written", never the element type's
// computed signedness.  A `logic` / `reg` / `bit` / `time` / `string` / `real`
// / `shortreal` / `chandle` / `event` element, an INLINE enum or struct, and
// EVERY NAMED TYPE (a typedef of an integer atom included) carry NO
// `vpiSigned` at all — not even when the type they name is signed.
//
// WHY, read off Surelog.  `CompileHelper::compileVariable`
// (~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:250-760) is a CLOSED
// switch on the PARSE NODE of the written data type, with eighteen case labels
// and a `default`.  `var->VpiSigned(isSigned)` appears in exactly SEVEN of
// them:
//
//     paIntegerAtomType_Int      (:452)   int_var        VpiSigned(isSigned)
//     paIntegerAtomType_Integer  (:462)   integer_var    "
//     paSigning_Unsigned         (:472)   int_var        "
//     paSigning_Signed           (:482)   int_var        "
//     paIntegerAtomType_Byte     (:492)   byte_var       "
//     paIntegerAtomType_LongInt  (:502)   long_int_var   "
//     paIntegerAtomType_Shortint (:512)   short_int_var  "
//
// and NOWHERE ELSE: `paIntVec_TypeLogic`/`_TypeReg` (:437), `paIntVec_TypeBit`
// (:527), `paIntegerAtomType_Time` (:518), `paNonIntType_Real`/`_ShortReal`,
// `paString_type`, `paChandle_type`, `paClass_scope` and the `default`
// "implicit type" arm (:753, a bare `logic_var`) all leave the flag unset.
// The NAMED-TYPE arm (`slStringConst`, :338) mints its variable through
// `getSimpleVarFromTypespec` (CompileType.cpp:78-235), a second closed
// dispatch — on the TYPESPEC kind this time — that sets `Actual_typespec` and
// NOTHING ELSE; it never touches `VpiSigned` on any of its twelve rows.
//
// `isSigned` itself is a SYNTAX question too (CompileType.cpp:456-460):
//     bool isSigned = true;
//     const NodeId signId = fC->Sibling(variable);
//     if (signId && fC->Type(signId) == paSigning_Unsigned) isSigned = false;
// i.e. "signed unless the word `unsigned` follows the keyword" — the same
// reading § implicitRetWrittenSigning70 already made for the RETURN variable.
//
// The array wrapper changes none of it: `CompileStmt.cpp:1189-1255` compiles
// the element with this very `compileVariable` call and only then wraps it in
// an `array_var`, blanking its name.  So the ELEMENT variable of `t a[2]`,
// `t a[]`, `t a[$]`, `t a[k]` and `t a[2][3]` alike answers the table above.
//
// OURS ASKED THE ELEMENT TYPE'S SIGNEDNESS INSTEAD (`elem->isSigned()`), which
// is true for an `int`-based enum, for a typedef of `int`/`byte`/`shortint`,
// for a `signed` packed struct and for `logic signed [3:0]` — none of which
// golden stamps.  Grids A/B/C/D/E measure every row of the table above against
// a Surelog golden.
//
// THE FLAG IS ASSIGNED, NOT OR-ED IN.  `makeReturnVar` (this file) stamps
// `VpiSigned` a SECOND time, off the CANONICAL `PredefinedIntegerType`, so a
// declaration that NAMES a typedef of an integer atom (`typedef int t; t a[2]`)
// arrived at the call site already flagged and an `if (...) VpiSigned(true)`
// could not clear it.  All four call sites therefore WRITE the law's answer
// (`reg->VpiSigned(<predicate>)`), which is a no-op wherever the factory left
// the flag alone (an enum_var, a class_var, a ref_var, a logic_var) and clears
// it on exactly the named-atom-typedef cells golden leaves unsigned — grid A
// `auditTick129` / `pixelRow129` / `skewPair129`, grid E `scopedInt129` /
// `chainInt129` / `innerTally129`.
//
// SCOPE, stated so the gate written is the gate coded.  `ImplicitType` is
// EXCLUDED from the law and keeps the pre-pass answer: Surelog emits no
// variable at all for the `var`-keyword locals that produce it in the grid
// (`var signed [3:0] x[2]`, `var int y[3]`), so the arm has no golden to be
// measured against and must not be moved on a guess.  Everything else is a
// keyword this table names.
inline bool declArrayElemVarSigned129(const slang::ast::Symbol& declSym,
                                      const Type& elemType) {
    const slang::ast::DeclaredType* dt = declSym.getDeclaredType();
    const syntax::SyntaxNode* tsyn = dt ? dt->getTypeSyntax() : nullptr;
    if (!tsyn)
        return elemType.isSigned();
    switch (tsyn->kind) {
        case syntax::SyntaxKind::IntType:
        case syntax::SyntaxKind::IntegerType:
        case syntax::SyntaxKind::ByteType:
        case syntax::SyntaxKind::ShortIntType:
        case syntax::SyntaxKind::LongIntType:
            // "signed unless `unsigned` is written" — CompileType.cpp:456-460.
            return tsyn->as<syntax::IntegerTypeSyntax>().signing.kind !=
                   parsing::TokenKind::UnsignedKeyword;
        case syntax::SyntaxKind::ImplicitType:
            // UNMEASURED (see SCOPE above) — unchanged by this pass.
            return elemType.isSigned();
        default:
            return false;
    }
}

// The element variable itself: r10sd10's answer when it has one, and the
// UNCHANGED `makeReturnVar` factory otherwise.
inline UHDM::variables* makeDeclArrayElemVar12(UHDM::Serializer& s,
                                               const slang::ast::Symbol& declSym,
                                               const Type& elemType,
                                               bool stmtScopeTd155 = false) {
    switch (declArrayElemVarKind12(declSym, stmtScopeTd155)) {
        case TdLocalVarKind10::ClassVar:
            return s.MakeClass_var();
        case TdLocalVarKind10::RefVar:
            return s.MakeRef_var();
        case TdLocalVarKind10::Resolved:
            break;
    }
    return makeReturnVar(s, elemType);
}

// ---------------------------------------------------------------------------
// § classScopedTdDeclTsUnsupported11
//
// THE LAW.  A declaration whose type is WRITTEN `Owner::td`, with `Owner` a
// CLASS, does NOT bind `td`'s real typespec.  It binds an
// `unsupported_typespec` NAMED with the WRITTEN SCOPED TEXT and SPANNED over
// the CLASS-SCOPE PREFIX (`Owner::`, start of the type to the start of the last
// segment) — UNLESS `td` is the typedef that CLAIMED its target's typespec
// slot, in which case the real typespec binds and nothing changes.
//
// WHY, read off Surelog and then measured cell by cell (grid11):
//   `CompileHelper::compileTypespec`'s `paPackage_scope / paClass_scope` arm
//   (CompileType.cpp ~1518) resolves the scope with EXACTLY ONE lookup,
//   `design->getPackage(<written scope name>)`.  There is no class lookup at
//   all, so `Owner::td` with a CLASS owner ALWAYS ends at the arm's tail
//   `unsupported_typespec` named `Owner::td` and spanned by
//   `populateCoreMembers(type, type, ref)` over the paClass_scope NODE — which
//   covers `Owner::` and not the leaf.  THAT IS THE OBJECT GOLDEN KEEPS.
//   `compileVariable`'s own paClass_scope arm (~554) then overwrites the
//   variable's typespec with that same object and calls
//   `component->needLateTypedefBinding(var)`.
//
//   The placeholder is repaired later, in `ElaborationStep::bindTypedefs_`,
//   and ONLY through a `std::map<std::string, typespec*> specs` whose
//   class-scoped key `Owner::td` is added at exactly ONE place: the
//   `noTypespec == true` branch, i.e. the branch a typedef takes only when its
//   TARGET DataType's typespec slot was still EMPTY when the typedef was
//   processed.  A typedef whose target already carries a typespec takes the
//   `else` at the top of the loop, which keys `specs` off the ALREADY-CLAIMED
//   typespec's OWN name (`Owner::<that name>`) — so `Owner::td` is never a key,
//   the swap never fires, and the placeholder survives into the database.
//
//   `bindTypedefs_` walks its typedefs in ONE order and fills each target's
//   slot on first touch:
//        $unit/file typedefs -> PACKAGE typedefs -> module -> program
//        -> CLASS typedefs, LAST,
//   iterating name-ordered maps at both levels (`ClassNameClassDefinition-
//   MultiMap` by fully-qualified class name, `TypeDefMap` = `std::map<
//   std::string, TypeDef*, StringViewCompare>` by typedef name).  So the
//   CLAIMER of a target is the typedef with the smallest
//   (group, container-name, typedef-name) key, and every other typedef naming
//   the same target degrades.
//
// THE FOUR QUESTIONS, and the grid11 cell behind each:
//   (1) SPELLING — the type is written `Owner::td`, a ScopedName whose ROOT
//       resolves to a CLASS.  A PACKAGE root takes `compileTypespec`'s
//       `getPackage` arm and resolves (`g4` `p_scoped`); a BARE name never
//       reaches this arm at all (`g4` `b_inh` / `b_own`).
//   (2) TARGET IS A NAME — `td`'s target must be another DataType: a class, a
//       class specialisation, or another typedef, with any number of
//       DECLARATOR dimensions on top.  A target declared IN PLACE has no
//       shared slot and always resolves: `g1` proves it for int / enum /
//       struct / packed struct / logic vector / string / `int m_t[string]` /
//       `int n_t[4]`, all NINE unmoved.
//   (3) CLAIM — `td` is not the smallest key naming that target.  `g1`
//       `c_t` (first by NAME in its class) resolves while `ca_t` and `cq_t`
//       degrade; `g7` `n7::a_t` (first by CONTAINER) resolves while `x7::b_t`
//       degrades; `g7` `pk_t`, a PACKAGE typedef, claims ahead of BOTH
//       `n7::c_t` and `x7::d_t`; `g7` `n7::u_t`, the only typedef naming its
//       target, resolves.
//   (4) GENERIC GROUPING — two DIFFERENT SPECIALISATIONS of one generic class
//       share ONE claim.  `g7` `n7::p_a` (`zg7#(int)`) resolves and `x7::p_b`
//       (`zg7#(byte)`) degrades, so the target key is the GENERIC, not the
//       specialisation.  This is what puts UVM's `uvm_queue#(T)::this_type`
//       ahead of `uvm_resource_types::rsrc_q_t` (`uvm_pkg::uvm_queue` <
//       `uvm_pkg::uvm_resource_types`) and is the whole SeqDriver head.
//
// SITE IS IRRELEVANT: `g3` reads the same typedef as a body local, a
// block-item local, a task local, an array-declarator local, a RETURN type and
// three FORMALS, and golden binds the SAME real typespec to all eight when the
// typedef claims its slot.  This pass therefore changes ONLY the three
// SUBROUTINE-scope sites § classTdLocalVarKindFollowsCompileOrder10 already
// owns; the FORMAL site keeps § classScopedTdFormalUnsupported34's older,
// claim-blind predicate and its over-fire is filed as this pass's residue R1
// with `g3` as its cell.

// The WRITTEN segments of a `A::b` (or `A::b::c`) type, left to right.
// IDENTIFIER segments only: a PARAMETERISED owner (`aparm#(int)::td`) is a
// `ClassName` node, is outside every measured cell, and is refused rather than
// guessed at.
inline bool scopedTdSegs11(const slang::ast::DeclaredType* dt,
                           std::vector<std::string_view>& segs) {
    if (!dt)
        return false;
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return false;
    auto& nt = tsyn->as<syntax::NamedTypeSyntax>();
    if (!nt.name || nt.name->kind != syntax::SyntaxKind::ScopedName)
        return false;
    std::function<bool(const syntax::NameSyntax*)> walk =
        [&](const syntax::NameSyntax* n) -> bool {
        if (!n)
            return false;
        if (n->kind == syntax::SyntaxKind::ScopedName) {
            auto& sn = n->as<syntax::ScopedNameSyntax>();
            return walk(sn.left) && walk(sn.right);
        }
        if (n->kind == syntax::SyntaxKind::IdentifierName) {
            segs.push_back(
                n->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            return true;
        }
        return false;
    };
    return walk(nt.name) && segs.size() >= 2;
}

// The TypeAlias a `A::b(::c)` spelling names, or null — with the ROOT required
// to be a CLASS, which is the whole difference between this law and the
// package-scoped control (`g4` `p_scoped`, unmoved).
inline const slang::ast::TypeAliasType* scopedTdLeaf11(
    const slang::ast::Scope& from, const std::vector<std::string_view>& segs) {
    const slang::ast::Symbol* root = nullptr;
    for (const slang::ast::Scope* sc = &from; sc && !root;
         sc = sc->asSymbol().getParentScope())
        root = sc->find(segs.front());
    if (!root)
        return nullptr;
    const slang::ast::Scope* cur = nullptr;
    if (root->kind == slang::ast::SymbolKind::ClassType)
        cur = &root->as<slang::ast::ClassType>();
    else if (root->kind == slang::ast::SymbolKind::GenericClassDef) {
        if (auto* ds = root->as<slang::ast::GenericClassDefSymbol>()
                           .getDefaultSpecialization(from);
            ds && ds->kind == slang::ast::SymbolKind::ClassType)
            cur = &ds->as<slang::ast::ClassType>();
    }
    if (!cur)
        return nullptr;
    const slang::ast::Symbol* leaf = nullptr;
    for (size_t i = 1; i < segs.size(); i++) {
        leaf = cur->find(segs[i]);
        if (!leaf)
            return nullptr;
        if (i + 1 < segs.size()) {
            if (leaf->kind != slang::ast::SymbolKind::ClassType)
                return nullptr;
            cur = &leaf->as<slang::ast::ClassType>();
        }
    }
    if (!leaf || leaf->kind != slang::ast::SymbolKind::TypeAlias)
        return nullptr;
    return &leaf->as<slang::ast::TypeAliasType>();
}

// The DataType whose typespec SLOT this typedef competes for — Surelog's
// `typd->getDefinition()->getActual()`, i.e. the END of the definition chain.
//
// Declarator containers are peeled (`typedef zelem cq_t[$]` competes for
// `zelem`, grid11 `g1` `cq_t`), a chain of typedef NAMES is chased to its end
// (`g1` `ss_t` -> `s_t`, `g6` `t_self` -> `t_cls` -> `zelem6`), a
// SPECIALISATION reports its GENERIC (question (4), `g7` `p_a` / `p_b`), and a
// typedef whose chain ends at a type declared IN PLACE owns its own DataType
// and therefore reports ITSELF — which is what makes `g1`'s `s_t` the claimant
// that pushes `ss_t` out.  Never null: every typedef contests exactly one slot.
inline const slang::ast::Symbol* tdSlot11(const slang::ast::TypeAliasType& al) {
    const slang::ast::TypeAliasType* cur = &al;
    // 16 is far past any corpus chain and keeps a cyclic alias (which slang
    // rejects, but a malformed tree could still present) from looping.
    for (int hop = 0; hop < 16; hop++) {
        const slang::ast::Type* t = &cur->targetType.getType();
        for (int guard = 0; guard < 8; guard++) {
            if (t->kind == slang::ast::SymbolKind::QueueType)
                t = &t->as<slang::ast::QueueType>().elementType;
            else if (t->kind == slang::ast::SymbolKind::DynamicArrayType)
                t = &t->as<slang::ast::DynamicArrayType>().elementType;
            else if (t->kind == slang::ast::SymbolKind::AssociativeArrayType)
                t = &t->as<slang::ast::AssociativeArrayType>().elementType;
            else if (t->kind ==
                     slang::ast::SymbolKind::FixedSizeUnpackedArrayType)
                t = &t->as<slang::ast::FixedSizeUnpackedArrayType>()
                         .elementType;
            else
                break;
        }
        if (t->kind == slang::ast::SymbolKind::ClassType) {
            auto& ct = t->as<slang::ast::ClassType>();
            return ct.genericClass ? (const slang::ast::Symbol*)ct.genericClass
                                   : (const slang::ast::Symbol*)&ct;
        }
        if (t->kind != slang::ast::SymbolKind::TypeAlias)
            return cur;
        cur = &t->as<slang::ast::TypeAliasType>();
    }
    return cur;
}

// Surelog's REGISTERED name for a class / generic class — the key
// `ClassNameClassDefinitionMultiMap` sorts on, and therefore the container half
// of a class typedef's claim key.  Three forms, the ones r10sd10 filed as its
// residue R6: `pkg::c`, `work@mod::c`, `work@c`.
// V-FIX vsd11 — A CLASS NESTED IN ANOTHER CLASS IS REGISTERED UNDER ITS SHORT
// NAME ALONE, and it is therefore ordered against the `pkg::c` / `work@mod::c`
// / `work@c` forms by that bare name.
//
// The shipped form prepended every enclosing class, spelling a nested class
// `pkg::Outer::Inner`.  For a class declared at package / module / `$unit`
// level the two readings are identical, which is why no grid11 cell and no
// corpus row separates them; they come apart the instant the DECLARING class is
// itself nested, and there the shipped form decides the claim race backwards.
//
//   MEASURED, golden vs the shipped binary, and BRACKETED on both sides:
//     vgrid11 `v3`  `binner3` nested in `pv3::aouter3`, both naming `zel3`:
//         golden RESOLVES `binner3::s_in` and DEGRADES `aouter3::t_out`, so the
//         NESTED typedef claims.  Shipped key `pv3::aouter3::binner3` sorts
//         AFTER `pv3::aouter3` and degrades `binner3::s_in` instead —
//         PRISTINE-RIGHT (`class_typespec (s_in)`) -> PATCHED-WRONG
//         (`unsupported_typespec (binner3::s_in)`).
//     vgrid11 `va`  the same shape with the nested class RENAMED `zzinna`, so
//         its SHORT name sorts AFTER the outer's package key: golden DEGRADES
//         `zzinna::z_in` and RESOLVES `aouta::a_out` — the claim goes the other
//         way, which is what rules out both `Outer::Inner` and any rule that
//         simply reaches nested classes first.
//   `binner3` < `pv3::aouter3` and `pva::aouta` < `zzinna` is exactly the bare
//   short name and nothing else.
inline std::string surelogClassKey11(const slang::ast::Symbol& cls) {
    const slang::ast::Scope* sc = cls.getParentScope();
    if (sc) {
        const slang::ast::Symbol& ss = sc->asSymbol();
        if (ss.kind == slang::ast::SymbolKind::ClassType ||
            ss.kind == slang::ast::SymbolKind::GenericClassDef)
            return std::string(cls.name);
        if (ss.kind == slang::ast::SymbolKind::Package)
            return std::string(ss.name) + "::" + std::string(cls.name);
        if (ss.kind == slang::ast::SymbolKind::InstanceBody)
            return "work@" + std::string(ss.name) + "::" + std::string(cls.name);
    }
    return "work@" + std::string(cls.name);
}

// V-FIX vsd11 — an INTERFACE CLASS is not in the list `bindTypedefs_` walks.
// Its typedefs neither CLAIM a target's typespec slot nor register an
// `Owner::td` repair key, so `IfaceCls::td` ALWAYS degrades and never pushes
// another typedef out.
//
//   MEASURED: vgrid11 `vb` — `aifb::only_t` is the SOLE typedef naming
//   `zonlyb`, so every claim model resolves it, and golden DEGRADES it anyway;
//   `aifb::shr_t` racing `zclsb::shr2_t` for one target sorts FIRST
//   (`pvb::aifb` < `pvb::zclsb`) and golden still lets `shr2_t` RESOLVE.
//   vgrid11 `v5` is the same fact on the corpus-shaped case: the shipped binary
//   let `pv5::ai5::i_t` claim `zel5` and so degraded `zbase5::base_t` —
//   PRISTINE-RIGHT -> PATCHED-WRONG.
inline bool isIfaceClass11(const slang::ast::Symbol& s) {
    if (s.kind == slang::ast::SymbolKind::ClassType)
        return s.as<slang::ast::ClassType>().isInterface;
    if (s.kind == slang::ast::SymbolKind::GenericClassDef)
        return s.as<slang::ast::GenericClassDefSymbol>().isInterface;
    return false;
}

// Is this parameter's own DECLARED default a TIME literal (parameter P = 5ns)?
// Read from the declarator syntax, not getInitializer(), so an instance
// override cannot flip the answer (same reasoning as
// declaredStringLiteralParam).
inline bool declaredTimeLiteralParam(const slang::ast::ParameterSymbol& ps) {
    if (auto* dsyn = ps.getSyntax())
        if (auto* decl = dsyn->as_if<syntax::DeclaratorSyntax>())
            return decl->initializer && decl->initializer->expr &&
                   decl->initializer->expr->kind ==
                       syntax::SyntaxKind::TimeLiteralExpression;
    return false;
}

// § writtenCallArgs16 — how many arguments a call actually WROTE.
//
// slang materialises a DEFAULTED formal as a full argument expression, located
// at the declaration's default; Surelog lists only the actuals written at the
// call site.  The func_call / task_call path has carried this rule since the
// ApbSlave probe (`write(addr, data)` is two arguments, not five); the
// METHOD-call paths did not, and that omission is the whole
// `method_func_call vs method_func_call | Args/SIZE n vs n+1` block at the
// head of the UVM-4 residue — `uvm_printer::print_object`'s
// `byte scope_separator="."`, `print_time`, `print_generic`,
// `uvm_component::set_domain`'s `int hier=1`, and so on: 1070 of SeqDriver's
// 1511 unexplained `deeper` mfc pairs.
//
// Reads the INVOCATION SYNTAX, which is the only place the distinction
// survives; a call with no invocation syntax (an implicit or rewritten one)
// falls back to the bound count so the helper can never trim a real argument.
// Only valid where `arguments()` excludes the receiver — user subroutine
// calls.  A BUILT-IN method passes its receiver as `arguments()[0]`, so those
// sites must keep counting the bound list.
inline size_t writtenCallArgs16(const CallExpression& call) {
    if (auto* isy = call.syntax
                        ? call.syntax->as_if<syntax::InvocationExpressionSyntax>()
                        : nullptr)
        return isy->arguments ? isy->arguments->parameters.size() : 0;
    return call.arguments().size();
}

// The written prefix of a user subroutine call's argument list.
inline std::span<const Expression* const> writtenArgs16(
    const CallExpression& call) {
    auto all = call.arguments();
    return all.subspan(0, std::min(writtenCallArgs16(call), all.size()));
}

// ------------------------------------------------- § emptyArgSlotIntZero24
//
// A WRITTEN-BUT-EMPTY positional argument slot (`f(a,,b)`, `f(a,b,)`) is NOT
// the formal's default.  Surelog's by-position arm
// (`CompileHelper::compileTfCallArguments`, `CompileHelper.cpp:4404`) mints a
// FRESH constant for the empty node and never looks at the io_decl at all:
//
//     } else {                                   // Expression is InvalidNodeId
//       constant* c = s.MakeConstant();
//       c->VpiValue("INT:0");
//       c->VpiDecompile("0");
//       c->VpiSize(64);
//       c->VpiConstType(vpiIntConst);
//       fC->populateCoreMembers(argumentNode, argumentNode, c);
//       arguments->push_back(c);
//     }
//
// — no `VpiParent(call)` (the by-position arm sets that only on a compiled
// expression), so the object is UNPARENTED and located at the EMPTY SLOT.
// slang instead binds `formal->getDefaultValue()` for the same slot
// (`CallExpression::bindArgs`), which is the DECLARATION's own expression, so
// we cloned a `32'h0` / `""` / `E1` / `PAR24+1` / `help24(2)` where golden
// holds `INT:0`.
//
// `callArgList24` is the written actual list; `emptyArgSlots24` returns, per
// WRITTEN slot, the `EmptyArgumentSyntax` node that slot was left as (nullptr
// for a written one).  It is deliberately ALL-OR-NOTHING and POSITIONAL-ONLY:
// with ANY named association the written index is no longer the bound index,
// and § namedTfArgsFormalSlots4 (which mints the SAME object without a span)
// already owns that shape.  It returns false — leaving every caller's existing
// behaviour untouched — when there is no invocation syntax, no argument list,
// a named argument anywhere, or no empty slot at all.
inline const syntax::ArgumentListSyntax* callArgList24(
    const CallExpression& call) {
    auto* isy = call.syntax
                    ? call.syntax->as_if<syntax::InvocationExpressionSyntax>()
                    : nullptr;
    return isy ? isy->arguments : nullptr;
}

inline bool emptyArgSlots24(
    const syntax::ArgumentListSyntax* al,
    std::vector<const syntax::ArgumentSyntax*>& slots) {
    slots.clear();
    if (!al)
        return false;
    bool any = false;
    for (auto* p : al->parameters) {
        if (p->kind == syntax::SyntaxKind::NamedArgument) {
            slots.clear();
            return false;
        }
        bool e = p->kind == syntax::SyntaxKind::EmptyArgument;
        any = any || e;
        slots.push_back(e ? p : nullptr);
    }
    if (!any)
        slots.clear();
    return any;
}

// ---------------------------------------------------------------- named args
//
// § writtenCallArgs16's PREFIX is only correct while WRITTEN ORDER equals
// FORMAL ORDER — i.e. for a POSITIONAL call.  A call written with NAMED
// association (`f(.b(x), .a(y))`) breaks that identity twice over: a skipped
// formal may sit ANYWHERE in the list, not just at the tail, and the written
// order need not be the formal order at all.  slang always hands back
// `arguments()` in FORMAL order with every unwritten formal materialised as its
// declared default, so a prefix of that list is, for a named call, a list of
// the WRONG expressions in the WRONG order — the empty STRING constant at the
// head of BuildUVMPkg's cmp was `uvm_factory_override::new`'s formal #1
// default `""`, standing where golden holds the FIRST WRITTEN actual.
//
// `writtenFormalIdx4` is the ONE decoder both laws share: it maps each WRITTEN
// actual to its FORMAL INDEX, in WRITTEN order.
//
// It is deliberately ALL-OR-NOTHING.  Anything it cannot account for exactly —
// an EMPTY association (`.f()`, or the trailing `f(a,b,)` slot uvm-1.2's
// `create`/`print_field_int`/`read`/`write` calls are full of), a name that
// matches no formal, a duplicate, a position past the bound list — returns
// false, and every caller then keeps its EXISTING behaviour unchanged.  A
// decoder that guessed would silently rewrite argument lists it had not
// understood; this one only ever speaks when the mapping is total.
inline bool writtenFormalIdx4(
    const syntax::SeparatedSyntaxList<syntax::ArgumentSyntax>* params,
    std::span<const slang::ast::FormalArgumentSymbol* const> formals,
    size_t nbound, std::vector<size_t>& idx, bool& anyNamed) {
    idx.clear();
    anyNamed = false;
    if (!params || formals.empty())
        return false;
    std::vector<bool> used(formals.size(), false);
    size_t pos = 0;
    for (auto* p : *params) {
        size_t f;
        if (p->kind == syntax::SyntaxKind::NamedArgument) {
            auto& na = p->as<syntax::NamedArgumentSyntax>();
            if (!na.expr)
                return false;
            anyNamed = true;
            auto nm = na.name.valueText();
            size_t k = formals.size();
            for (size_t i = 0; i < formals.size(); ++i)
                if (formals[i]->name == nm) {
                    k = i;
                    break;
                }
            if (k == formals.size())
                return false;
            f = k;
        }
        else if (p->kind == syntax::SyntaxKind::OrderedArgument)
            f = pos++;
        else
            return false; // EmptyArgument, and anything the grammar adds later
        if (f >= formals.size() || f >= nbound || used[f])
            return false;
        used[f] = true;
        idx.push_back(f);
    }
    return true;
}

// § namedMethodArgsWritten4 (decoder half) — a METHOD_FUNC_CALL's vpiArgument
// list is the WRITTEN actual list in WRITTEN order: a formal that was not
// written contributes NOTHING, and a named actual contributes the expression
// the CALL SITE wrote, at the position the CALL SITE wrote it.
//
// MEASURED on arm a1 (`ct4arm.sh a1_namedargs.sv`), one golden, ten cells:
// the ctor `new(.d(2), .b("bb"), .f(1), .c(1), .e(3))` against a six-formal
// `new` lists `2 | "bb" | 1 | 1 | 3` — WRITTEN order, the skipped formal
// absent — and `hh.mf6(.d(2), .c(1), .b("bb"))` lists `2 | 1 | "bb"` on a
// plain method, `hh.mt6(...)` the same on a TASK, and arm a2's
// `super.new(.c(k), .b(2))` the same on a base-constructor chain-up.
//
// Returns the WRITTEN-order actuals, or the § writtenCallArgs16 prefix
// unchanged when the call is positional or the mapping is not total (the
// prefix and the remap are the SAME list for a positional call, so this is a
// no-op wherever named association was not used).
inline std::span<const Expression* const> writtenArgsInOrder4(
    const CallExpression& call, const slang::ast::SubroutineSymbol& sub,
    std::vector<const Expression*>& buf) {
    auto* isy = call.syntax
                    ? call.syntax->as_if<syntax::InvocationExpressionSyntax>()
                    : nullptr;
    if (!isy || !isy->arguments)
        return writtenArgs16(call);
    auto all = call.arguments();
    std::vector<size_t> idx;
    bool named = false;
    if (!writtenFormalIdx4(&isy->arguments->parameters, sub.getArguments(),
                           all.size(), idx, named) ||
        !named)
        return writtenArgs16(call);
    buf.clear();
    for (size_t i : idx)
        buf.push_back(all[i]);
    return std::span<const Expression* const>(buf);
}

// § namedTfArgsFormalSlots4 (decoder half) — a FUNC_CALL / TASK_CALL written
// with NAMED association is the OTHER half of the same fact, and it does NOT
// follow the method rule: Surelog's plain tf-call path lists ONE vpiArgument
// PER FORMAL, in FORMAL order, and fills an UNWRITTEN formal's slot with a
// LOC-LESS, PARENT-LESS placeholder `constant` — `INT:0`, `vpiSize:64`,
// `vpiDecompile:0`, `vpiConstType:7` — which is NOT the formal's declared
// default.
//
// MEASURED on the same two arms, and the two shapes are decided by the UHDM
// OBJECT KIND, not by the receiver:
//   a1 C6  `pf6(.d(2), .b("bb"), .c(1))`  6 formals -> `0[NOLOC] "bb" 1 2 0[NOLOC] 0[NOLOC]`
//   a1 C7  `pf6(.d(9))`                   6 formals -> `0 0 0 9 0 0`, five placeholders
//   a2 E1  `im(.c(1), .b(2))`  an in-class BARE call, golden emits func_call
//          -> `0[NOLOC] 2 1 0[NOLOC]`, so a receiver-less METHOD takes the
//          TF-CALL rule, which is why this cannot be gated on "is a method"
//   a2 E4  `gt(.c(1), .b(2))`  a TASK -> the same four slots
//   a2 E7  `im(.b(2), .c(1))`  REORDERED -> `0 2 1 0`: FORMAL order, always
//   a1 C12 `pf6("aa","bb",1,2)` PURELY POSITIONAL -> FOUR arguments and NO
//          placeholders: the slot filling is gated on NAMED association, and
//          this cell is why.
//
// `written` comes back sized to the formal list; false marks a placeholder
// slot.  Returns false — leaving the caller's existing behaviour untouched —
// for a positional call or a mapping § writtenFormalIdx4 could not total.
inline bool namedTfSlots4(const CallExpression& call,
                          const slang::ast::SubroutineSymbol& sub,
                          std::vector<bool>& written) {
    written.clear();
    auto* isy = call.syntax
                    ? call.syntax->as_if<syntax::InvocationExpressionSyntax>()
                    : nullptr;
    if (!isy || !isy->arguments)
        return false;
    auto formals = sub.getArguments();
    std::vector<size_t> idx;
    bool named = false;
    if (!writtenFormalIdx4(&isy->arguments->parameters, formals,
                           call.arguments().size(), idx, named) ||
        !named)
        return false;
    written.assign(formals.size(), false);
    for (size_t i : idx)
        written[i] = true;
    return true;
}

// Collects the value symbols referenced on a cont_assign LHS (their top-view
// net typespecs lose the creation-time parent when Surelog re-elaborates the
// assignment).
inline void collectLhsSyms(const Expression& e, std::set<const Symbol*>& out) {
    switch (e.kind) {
        case ExpressionKind::NamedValue:
            out.insert(&e.as<NamedValueExpression>().symbol);
            break;
        case ExpressionKind::ElementSelect:
            collectLhsSyms(e.as<ElementSelectExpression>().value(), out);
            break;
        case ExpressionKind::RangeSelect:
            collectLhsSyms(e.as<RangeSelectExpression>().value(), out);
            break;
        case ExpressionKind::Concatenation:
            for (auto op : e.as<ConcatenationExpression>().operands())
                collectLhsSyms(*op, out);
            break;
        case ExpressionKind::Conversion:
            collectLhsSyms(e.as<ConversionExpression>().operand(), out);
            break;
        default:
            break;
    }
}

// Surelog's "source order" is the order of the FLATTENED text — an `include`d
// file's contents sit at the include DIRECTIVE's offset in the including
// file, not after everything that file contains. `SourceLocation`'s own `<`
// orders by (BufferID, offset), which groups a whole included buffer either
// before or after its includer wholesale and so cannot express that.
//
// The include-expanded key of a location is therefore the chain of
// (buffer, offset) pairs from the ROOT buffer down: comparing two keys
// lexicographically reproduces the flattened order, and a location that IS an
// include directive sorts ahead of everything the include brought in.
//
// Measured on uvm-1.2 (r10uvm3): `base/uvm_component.svh` declares class
// uvm_component, `\`include "base/uvm_root.svh"` at line 1712, and only THEN
// its own out-of-body method definitions (line 1822+). Surelog's uvm_pkg
// listing puts uvm_root's 23 methods between uvm_phase's and uvm_component's,
// exactly where the flattened text puts them; a (buffer, offset) sort puts
// them 113 entries later.
inline std::vector<std::pair<uint32_t, uint64_t>> includeExpandedKey(
    const slang::SourceManager& sm, slang::SourceLocation loc) {
    std::vector<std::pair<uint32_t, uint64_t>> path;
    slang::SourceLocation l = loc;
    for (int guard = 0; l && guard < 64; guard++) {
        path.push_back({l.buffer().getId(), (uint64_t)l.offset()});
        slang::SourceLocation inc = sm.getIncludedFrom(l.buffer());
        if (!inc)
            break;
        l = inc;
    }
    std::reverse(path.begin(), path.end());
    return path;
}

inline bool includeExpandedLess(const std::vector<std::pair<uint32_t, uint64_t>>& a,
                                const std::vector<std::pair<uint32_t, uint64_t>>& b) {
    for (size_t i = 0; i < a.size() && i < b.size(); i++) {
        if (a[i].first != b[i].first)
            return a[i].first < b[i].first;
        if (a[i].second != b[i].second)
            return a[i].second < b[i].second;
    }
    return a.size() < b.size();
}

// One entry of a PACKAGE's `vpiTaskFunc` listing: the subroutine SYMBOL and
// whether this package OWNS it or merely materializes a CLONE of it.
struct PkgTfEntry {
    const SubroutineSymbol* sub;
    // Non-null for an OUT-OF-BODY CLASS-METHOD definition: the class whose
    // `C::m` clone the package's DEF-view listing carries
    // (§ emitPackageClassMethodClones).  Null for a package-level subroutine.
    const ClassType* cls;
    SourceLocation at;  // the slot the entry occupies in THIS package's source
    bool imported;      // true: a clone an `import q::*` materializes here
    int ctorKey;        // 1 for a constructor: Surelog binds those LAST
};

// The out-of-body method DEFINITIONS of one class, i.e. exactly the
// subroutines `members()` never yields (slang keeps them out of every scope's
// member list; they are reachable only through the prototype).  Mirrors the
// `oobDefs` walk in emitTaskFuncs — the two must agree, because this listing
// decides WHICH clones an importing package materializes and emitTaskFuncs
// decides which ones it will emit.
inline std::vector<const SubroutineSymbol*> classOobDefs(const ClassType& c) {
    std::vector<const Symbol*> memberList;
    for (auto& m : c.members())
        memberList.push_back(&m);
    std::vector<const SubroutineSymbol*> out;
    for (auto& m : c.members()) {
        if (m.kind != SymbolKind::MethodPrototype)
            continue;
        auto& mp = m.as<MethodPrototypeSymbol>();
        if (mp.flags.has(MethodFlags::Pure))
            continue;
        auto* impl = mp.getSubroutine();
        if (!impl || !impl->getSyntax())
            continue;
        if (std::find(memberList.begin(), memberList.end(),
                      (const Symbol*)impl) != memberList.end())
            continue;
        out.push_back(impl);
    }
    return out;
}

// A PACKAGE that wildcard-imports another package materializes a CLONE of
// every subroutine that import makes visible — named by the IMPORTING package
// (`p2::f`), listed in its `vpiTaskFunc` whether or not anything calls it, and
// TRANSITIVELY: a package importing an importer inherits the whole chain.
//
// The listing is ONE source-ordered pass over the importing package: its own
// subroutines sit at their declaration locations and each import's whole group
// sits at the IMPORT STATEMENT's location, the group itself keeping the
// imported package's own listing order.  Measured on a purpose-built Surelog
// golden (r10evfn probe 2): `package p2` declaring g0@15, `import p1::*`@20
// (p1 declares f@2, f2@7) and g@21 lists g0, f, f2, g — and `package p3`,
// which only does `import p2::*`, lists p2's four in exactly that order.
//
// The group is the home package's DEF-VIEW listing, so it carries that
// listing's CLASS machinery too: one entry per out-of-body class-method
// definition (`C::f`), interleaved with the package's own subroutines at its
// source slot, constructors last (§ emitPackageClassMethodClones).  Measured
// on r10uvm3 repro 1 (`p1` with an oob method @9 and a free function @10,
// `p2` importing it and declaring `k`@15): golden p2 lists [C::f, h, k] in
// BOTH views, sharedPtrs=0 against p1's — and on SeqDriver, whose adpcm_pkg
// lists uvm_pkg's whole 894-entry def listing.
//
// The ordering key is the one the package listing itself uses (§ pkgTfOrder9):
// (constructor-last, include-expanded source order).  An IMPORT group's whole
// contents take the import statement's slot with key 0, so the group keeps the
// home listing's order verbatim — constructors included.
inline std::vector<PkgTfEntry> collectPkgTfListing(
    const slang::SourceManager& sm, const PackageSymbol& pkg,
    std::set<const PackageSymbol*>& seen) {
    std::vector<PkgTfEntry> out;
    if (!seen.insert(&pkg).second)
        return out;
    std::vector<PkgTfEntry> ents;
    for (auto& m : pkg.members()) {
        if (m.kind == SymbolKind::Subroutine) {
            if (!m.getSyntax())
                continue;
            ents.push_back({&m.as<SubroutineSymbol>(), nullptr, m.location,
                            false, m.name == "new" ? 1 : 0});
        }
        else if (m.kind == SymbolKind::ClassType ||
                 m.kind == SymbolKind::GenericClassDef) {
            const ClassType* ct = nullptr;
            if (m.kind == SymbolKind::ClassType)
                ct = &m.as<ClassType>();
            else if (auto* dsp = m.as<GenericClassDefSymbol>()
                                     .getDefaultSpecialization(pkg);
                     dsp && dsp->kind == SymbolKind::ClassType)
                ct = &dsp->as<ClassType>();
            if (!ct)
                continue;
            for (auto* d : classOobDefs(*ct))
                ents.push_back(
                    {d, ct, d->location, false, d->name == "new" ? 1 : 0});
        }
        else if (m.kind == SymbolKind::WildcardImport) {
            auto* q = m.as<WildcardImportSymbol>().getPackage();
            if (!q)
                continue;
            // The import STATEMENT's slot. A WildcardImportSymbol's own
            // `location` is not the written one, so read the syntax.
            SourceLocation at = m.location;
            if (auto* isyn = m.getSyntax())
                at = isyn->sourceRange().start();
            for (auto& e : collectPkgTfListing(sm, *q, seen))
                ents.push_back({e.sub, e.cls, at, true, 0});
        }
    }
    seen.erase(&pkg);
    std::stable_sort(ents.begin(), ents.end(),
                     [&](const PkgTfEntry& a, const PkgTfEntry& b) {
                         if (a.ctorKey != b.ctorKey)
                             return a.ctorKey < b.ctorKey;
                         return includeExpandedLess(includeExpandedKey(sm, a.at),
                                                    includeExpandedKey(sm, b.at));
                     });
    for (auto& e : ents) {
        bool dup = false;
        for (auto& o : out)
            if (o.sub == e.sub)
                dup = true;
        if (!dup)
            out.push_back(e);
    }
    return out;
}

} // namespace slang_uhdm
