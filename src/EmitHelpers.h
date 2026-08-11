//------------------------------------------------------------------------------
//! @file EmitHelpers.h
//! @brief File-local helpers shared by the UhdmExporter translation units
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <uhdm/uhdm.h>

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
inline std::string joinRef(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    if (prefix.find("::") != std::string::npos)
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

// Return-value variables take the class of the function's return type.
inline UHDM::variables* makeReturnVar(UHDM::Serializer& s, const Type& retType,
                                      bool signedImplicitRet = false) {
    auto& ct = retType.getCanonicalType();
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
    // A SIGNED implicit-base packed return (function signed [3:0] f) is an
    // int_var carrying vpiSigned (Surelog); other packed returns/vars stay
    // logic_vars (signedness rides on the typespec).
    if (signedImplicitRet && ct.kind == SymbolKind::PackedArrayType &&
        retType.isSigned()) {
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

inline bool isLiteralExpr(const Expression& e) {
    auto& c = stripImplicitConv(e);
    return c.kind == ExpressionKind::IntegerLiteral ||
           c.kind == ExpressionKind::StringLiteral ||
           c.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral;
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
