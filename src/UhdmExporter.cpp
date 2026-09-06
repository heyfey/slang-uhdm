//------------------------------------------------------------------------------
//! @file UhdmExporter.cpp
//! @brief Exporter core: design assembly, locations, raw text
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"
#include "slang/syntax/SyntaxTree.h"

namespace slang_uhdm {

UhdmExporter::UhdmExporter(Compilation& compilation, UHDM::Serializer& serializer) :
    comp(compilation), s(serializer), sm(compilation.getSourceManager()) {
    // § macroLocOrder — publish the SourceManager for the free helpers that
    // must normalise macro locations before comparing them (EmitHelpers.h).
    helperSM = sm;
}

void UhdmExporter::noteUnsupported(const std::string& what) {
    unsupportedKinds.insert(what);
}

// Diagnostic only (env SLANG_UHDM_UNSUP_LOC=1): report WHERE an unsupported
// construct was hit.  The set-based summary names the kind; finding the site
// in a 25k-line UVM source otherwise means bisecting by hand.
void UhdmExporter::noteUnsupportedAt(const std::string& what,
                                     slang::SourceLocation loc) {
    unsupportedKinds.insert(what);
    static const bool on = getenv("SLANG_UHDM_UNSUP_LOC") != nullptr;
    if (on && sm)
        fprintf(stderr, "UNSUP %s @ %s:%u\n", what.c_str(),
                std::string(sm->getFileName(loc)).c_str(),
                (unsigned)sm->getLineNumber(loc));
}

bool UhdmExporter::isBuiltinUnit(const Scope& unit) {
    if (!builtins)
        return false;
    for (auto& mem : unit.members())
        return fullFilePath(mem.location) == builtinFilePath;
    return false;
}

// Surelog's Builtin::addBuiltinTypes() synthesizes a package named `builtin`
// holding five empty class_defns; UhdmWriter then inserts it at the FRONT of
// both package lists (the elaborated copy carries vpiTop + the class_defns,
// the un-elaborated one just the names). Nothing has a source position.
void UhdmExporter::emitBuiltinPackage(UHDM::VectorOfpackage*& allP,
                                      UHDM::VectorOfpackage*& topP) {
    static constexpr std::string_view kClasses[] = {"any_sverilog_class", "array",
                                                    "queue", "string", "system"};
    // TopPackages copy first (Surelog builds the elaborated views first).
    auto* pTop = s.MakePackage();
    pTop->VpiName("builtin");
    pTop->VpiFullName("builtin::");
    pTop->VpiDefName("builtin");
    pTop->VpiParent(d);
    pTop->VpiTop(true);
    auto* cds = s.MakeClass_defnVec();
    for (auto cn : kClasses) {
        auto* cd = s.MakeClass_defn();
        cd->VpiName(cn);
        cd->VpiFullName("builtin::" + std::string(cn));
        cd->VpiParent(pTop);
        cds->push_back(cd);
    }
    pTop->Class_defns(cds);
    auto* pAll = s.MakePackage();
    pAll->VpiName("builtin");
    pAll->VpiFullName("builtin::");
    pAll->VpiDefName("builtin");
    pAll->VpiParent(d);
    if (!allP)
        allP = s.MakePackageVec();
    if (!topP)
        topP = s.MakePackageVec();
    allP->insert(allP->begin(), pAll);
    topP->insert(topP->begin(), pTop);
}

// True when one of the body's own parameters is declared with a type alias
// that is ALSO declared in that body (parameter alert_tx_t P = ...).
static bool paramTypedByLocalTypedef(const Scope& body) {
    for (auto& mem : body.members()) {
        if (mem.kind != SymbolKind::Parameter)
            continue;
        auto dt = mem.as<ParameterSymbol>().getDeclaredType();
        if (!dt)
            continue;
        auto& ty = dt->getType();
        if (ty.kind != SymbolKind::TypeAlias)
            continue;
        if (ty.as<TypeAliasType>().getParentScope() == &body)
            return true;
    }
    return false;
}

// The line/column ONE UHDM object field gets for ONE SourceLocation.
//
// Extracted verbatim from `setLoc`'s former `lineColOf` lambda so that a
// consumer needing the span an object WOULD get — § connReplFoldNested54 keys a
// slang sub-expression against the span already written onto its emitted UHDM
// twin — reads the SAME arithmetic instead of a second copy of it.  A second
// copy is exactly how the "emitter nondeterminism" memory entry was earned:
// macro-buffer locations must be mapped through getFullyOriginalLoc and any
// path that forgets to flips per run.  Behaviour is unchanged; this is a move.
void UhdmExporter::locLineCol(SourceLocation lc, uint32_t& L, uint32_t& C) {
    uint32_t vl, vc;
    // Macro-expanded tokens: SINGLE-LINE bodies lay out VIRTUALLY at the
    // INVOCATION site (usage line, usage col + body offset); later lines of
    // multi-line bodies keep their macro-DEFINITION-site span (Surelog).
    if (sm->isMacroLoc(lc) && macroInvLineCol(lc, vl, vc)) {
        L = vl;
        C = (uint32_t)((int32_t)vc + macroArgShift(lc));
        return;
    }
    // Multi-line macro bodies keep their definition line; the column is the
    // definition column shifted right past earlier argument substitutions.
    if (sm->isMacroLoc(lc)) {
        SourceLocation d = sm->getFullyOriginalLoc(lc);
        L = (uint32_t)sm->getLineNumber(d);
        C = (uint32_t)((int32_t)sm->getColumnNumber(d) + macroArgShift(lc));
        return;
    }
    fileLineCol(lc, L, C);
}

void UhdmExporter::setLoc(UHDM::BaseClass* obj, SourceRange range) {
    if (range.start() == SourceLocation::NoLocation)
        return;
    uint32_t l = 0, c = 0;
    locLineCol(range.start(), l, c);
    obj->VpiLineNo(l);
    obj->VpiColumnNo(c);
    if (range.end() != SourceLocation::NoLocation) {
        locLineCol(range.end(), l, c);
        obj->VpiEndLineNo(l);
        obj->VpiEndColumnNo(c);
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
    setLoc(obj, nameSpan(loc, symbol.name));
}

SourceRange UhdmExporter::regNetSpan(const Symbol& sym) {
    // A reg variable emitted as a net, with an initializer, anchors over the
    // whole declarator ("b = 0") rather than just the name token.
    if (sym.kind == SymbolKind::Variable && sym.getDeclaredType() &&
        sym.getDeclaredType()->getInitializer()) {
        if (auto dsyn = sym.getSyntax()) {
            auto dr = dsyn->sourceRange();
            if (dr.start() != SourceLocation::NoLocation)
                return dr;
        }
    }
    return nameSpan(sym.location, sym.name);
}

SourceRange UhdmExporter::nameSpan(SourceLocation loc, std::string_view name) {
    // Escaped identifiers ("\foo* ") get Surelog's quirky name+6 width.
    if (rawText(SourceRange(loc, loc + 1)) == "\\")
        return SourceRange(loc, loc + name.size() + 6);
    return SourceRange(loc, loc + name.size());
}

SourceRange UhdmExporter::trimTypeSigning(const slang::syntax::SyntaxNode* tsyn,
                                          SourceRange r) {
    if (!tsyn || r.start() == SourceLocation::NoLocation)
        return r;
    // Only the integer ATOM types (signed by default) drop the keyword; a
    // logic/reg/bit vector keeps `signed` in its typespec span.
    switch (tsyn->kind) {
        case slang::syntax::SyntaxKind::ByteType:
        case slang::syntax::SyntaxKind::ShortIntType:
        case slang::syntax::SyntaxKind::IntType:
        case slang::syntax::SyntaxKind::LongIntType:
        case slang::syntax::SyntaxKind::IntegerType:
            break;
        default:
            return r;
    }
    auto* ity = tsyn->as_if<slang::syntax::IntegerTypeSyntax>();
    if (!ity || !ity->signing ||
        ity->signing.kind != slang::parsing::TokenKind::SignedKeyword)
        return r;
    auto ke = ity->keyword.range().end();
    if (ke == SourceLocation::NoLocation || !(ke < r.end()))
        return r;
    return SourceRange(r.start(), ke);
}

std::string UhdmExporter::fullFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    // Macro-expansion buffers have no path; report the definition file.
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    return sm->getFullPath(loc.buffer()).string();
}

std::string UhdmExporter::rootFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    auto buf = loc.buffer();
    for (int guard = 0; guard < 64; guard++) {
        auto up = sm->getIncludedFrom(buf);
        if (up == SourceLocation::NoLocation || !up.buffer().valid())
            break;
        buf = up.buffer();
    }
    return sm->getFullPath(buf).string();
}

// § unitRefSubst — deep-copy a $unit parameter's value tree so it can be
// SPLICED into another $unit parameter's unfolded init.  Only the three
// shapes an unfolded $unit init can hold are copied; anything else returns
// null, which leaves the reference in place (under-substituting is safe,
// inventing a shape is not).
UHDM::expr* UhdmExporter::cloneUnitParamRhs(const UHDM::expr* src,
                                            UHDM::BaseClass* parent) {
    if (!src)
        return nullptr;
    auto cloc = [](UHDM::BaseClass* dst, const UHDM::BaseClass* s0) {
        dst->VpiFile(s0->VpiFile());
        dst->VpiLineNo(s0->VpiLineNo());
        dst->VpiColumnNo(s0->VpiColumnNo());
        dst->VpiEndLineNo(s0->VpiEndLineNo());
        dst->VpiEndColumnNo(s0->VpiEndColumnNo());
    };
    switch (src->UhdmType()) {
        case UHDM::uhdmconstant: {
            auto* o = (const UHDM::constant*)src;
            auto* c = s.MakeConstant();
            c->VpiValue(o->VpiValue());
            c->VpiDecompile(o->VpiDecompile());
            c->VpiSize(o->VpiSize());
            c->VpiConstType(o->VpiConstType());
            c->VpiParent(parent);
            cloc(c, o);
            return c;
        }
        case UHDM::uhdmref_obj: {
            auto* o = (const UHDM::ref_obj*)src;
            auto* r = s.MakeRef_obj();
            r->VpiName(o->VpiName());
            if (!o->VpiFullName().empty())
                r->VpiFullName(o->VpiFullName());
            r->VpiParent(parent);
            cloc(r, o);
            return r;
        }
        case UHDM::uhdmoperation: {
            auto* o = (const UHDM::operation*)src;
            auto* op = s.MakeOperation();
            op->VpiOpType(o->VpiOpType());
            op->VpiParent(parent);
            cloc(op, o);
            // A CAST operation carries its target typespec, and the splice
            // keeps it: golden's `` `SCR1_DMEM_AWIDTH'(~MASK + 1'b1) `` reaches
            // scr1_dp_memory's SCR1_SIZE and ram_block's dimension still typed
            // by the SAME integer_typespec (scr1_top_axi.sv:367:22-24) it
            // carries at scr1_tcm's own param_assign.  Only the ref is fresh —
            // one ref_typespec per holder, the actual object shared.
            if (auto* srt = o->Typespec())
                if (auto* sact = srt->Actual_typespec()) {
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiParent(op);
                    if (!srt->VpiFullName().empty())
                        rt->VpiFullName(srt->VpiFullName());
                    rt->Actual_typespec(const_cast<UHDM::typespec*>(sact));
                    op->Typespec(rt);
                }
            if (auto* ops = o->Operands()) {
                auto* nv = s.MakeAnyVec();
                for (auto* e : *ops) {
                    auto* cl = cloneUnitParamRhs((const UHDM::expr*)e, op);
                    if (!cl)
                        return nullptr;
                    nv->push_back(cl);
                }
                op->Operands(nv);
            }
            return op;
        }
        default:
            return nullptr;
    }
}

std::vector<std::pair<const Symbol*, const Symbol*>>
UhdmExporter::fileScopeImportTypedefs(SourceLocation modLoc) {
    std::vector<std::pair<const Symbol*, const Symbol*>> out;
    std::string modFile = rootFilePath(modLoc);
    if (modFile.empty())
        return out;
    for (auto unit : comp.getCompilationUnits()) {
        for (auto& mem : unit->members()) {
            if (mem.kind != SymbolKind::WildcardImport &&
                mem.kind != SymbolKind::ExplicitImport)
                continue;
            if (rootFilePath(mem.location) != modFile)
                continue;
            if (mem.kind == SymbolKind::ExplicitImport) {
                auto* imported = mem.as<ExplicitImportSymbol>().importedSymbol();
                if (imported && imported->kind == SymbolKind::TypeAlias)
                    out.emplace_back(&mem, imported);
                continue;
            }
            auto* pkg = comp.getPackage(
                mem.as<WildcardImportSymbol>().packageName);
            if (!pkg)
                continue;
            std::vector<const Symbol*> tas;
            for (auto& pm : pkg->members())
                if (pm.kind == SymbolKind::TypeAlias)
                    tas.push_back(&pm);
            std::stable_sort(tas.begin(), tas.end(),
                             [](const Symbol* a, const Symbol* b) {
                                 return a->name < b->name;
                             });
            for (auto* ta : tas)
                out.emplace_back(&mem, ta);
        }
    }
    return out;
}

bool UhdmExporter::verilogLexMode(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return false;
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    // The lexer mode is set once per COMMAND-LINE file, so an `included
    // header inherits its includer's mode: walk to the root of the chain.
    auto buf = loc.buffer();
    for (int guard = 0; guard < 64; guard++) {
        auto up = sm->getIncludedFrom(buf);
        if (up == SourceLocation::NoLocation || !up.buffer().valid())
            break;
        buf = up.buffer();
    }
    return sm->getFullPath(buf).extension().string() != ".sv";
}

// ---------------------------------------------------------------------------
// Include file info
// ---------------------------------------------------------------------------
// Surelog hangs one include_file_info off the design for every ACTIVE
// `include directive it preprocessed -- the Context::INCLUDE + Action::PUSH
// records of each command-line file's root PreprocessFile, walked in
// preprocessing pre-order (CompileDesign.cpp "Compile Include file info" +
// UhdmWriter.cpp `d->Include_file_infos`).  Per record:
//
//   VpiFile         the ROOT source file of the include chain (the records all
//                   live on the root PreprocessFile, so a nested include still
//                   reports the command-line file)
//   VpiIncludedFile the resolved path of the included file
//   line/col        the filename token's span, EXCEPT that the line is
//                   Surelog's FLATTENED preprocessor-output line: the
//                   directive lines of the enclosing chain accumulate, and
//                   every earlier include in the same file shifts the line by
//                   the number of lines that include spliced in.
//
// slang gives us the same events from `SyntaxTree::getIncludeDirectives()`:
// recorded per directive, in pre-order, skipped inside a false `ifdef branch
// (parseBranchDirective consumes raw tokens), and with a FRESH buffer id per
// inclusion so the include tree is recoverable through the includer buffer.
// One asymmetry: when slang's header-guard detection suppresses a re-inclusion
// it records the directive with NO buffer.  Surelog still re-reads the file and
// records the event (its guarded body just appends nothing), so we keep those,
// resolving their path from the earlier inclusion that did open the file.
void UhdmExporter::emitIncludeFileInfos() {
    struct Ev {
        slang::BufferID inBuf;   // buffer holding the directive
        slang::BufferID incBuf;  // buffer of the included file, if opened
        uint32_t line = 0, col = 0, endLine = 0, endCol = 0;
        std::string path;    // resolved path of the included file
        uint32_t flat = 0;   // output lines this inclusion splices in
        int32_t parent = -1; // enclosing inclusion, -1 at a root file
    };
    std::vector<Ev> evs;
    std::map<uint32_t, size_t> evOfIncluded; // included buffer id -> event
    std::map<std::string, std::string> resolved; // as written -> full path
    for (auto tree : comp.getSyntaxTrees()) {
        for (auto& im : tree->getIncludeDirectives()) {
            if (!im.syntax)
                continue;
            auto r = im.syntax->fileName.range();
            if (r.start() == SourceLocation::NoLocation)
                continue;
            Ev e;
            e.inBuf = sm->getFullyExpandedLoc(r.start()).buffer();
            if (im.buffer.id) {
                e.incBuf = im.buffer.id;
                e.path = sm->getFullPath(im.buffer.id).string();
                resolved.emplace(std::string(im.path), e.path);
            }
            else {
                // Guard-suppressed (or unopenable) include: no buffer of its
                // own, so reuse the path this spelling resolved to before.
                auto it = resolved.find(std::string(im.path));
                if (it == resolved.end())
                    continue;
                e.path = it->second;
            }
            fileLineCol(r.start(), e.line, e.col);
            if (r.end() != SourceLocation::NoLocation)
                fileLineCol(r.end(), e.endLine, e.endCol);
            else {
                e.endLine = e.line;
                e.endCol = e.col;
            }
            if (e.incBuf)
                evOfIncluded.emplace(e.incBuf.getId(), evs.size());
            evs.push_back(std::move(e));
        }
    }
    if (evs.empty())
        return;
    // The enclosing inclusion is the event that opened the buffer this
    // directive sits in; pre-order guarantees it comes first, which also keeps
    // the parent walk below finite.
    for (size_t i = 0; i < evs.size(); i++) {
        auto it = evOfIncluded.find(evs[i].inBuf.getId());
        if (it != evOfIncluded.end() && it->second < i)
            evs[i].parent = (int32_t)it->second;
    }
    // How many output lines each inclusion splices into its includer: the
    // included file's own line count plus whatever ITS includes splice in.  An
    // inclusion slang suppressed (header guard already satisfied) splices
    // nothing -- Surelog re-reads the file but its guarded body appends
    // nothing.  Children always follow their parent in pre-order, so one
    // reverse pass accumulates.
    for (size_t i = evs.size(); i-- > 0;) {
        auto& e = evs[i];
        if (e.incBuf) {
            auto text = sm->getSourceText(e.incBuf);
            e.flat += (uint32_t)std::count(text.begin(), text.end(), '\n');
        }
        if (e.parent >= 0)
            evs[(size_t)e.parent].flat += e.flat;
    }
    // Line within the includer's own output = raw line plus the splices of the
    // earlier includes in that same buffer; the chain then adds each ancestor's
    // own such line minus one (the directive line the content replaces).
    std::map<uint32_t, uint32_t> shift; // includer buffer id -> lines spliced so far
    std::vector<uint32_t> rel(evs.size(), 0);
    for (size_t i = 0; i < evs.size(); i++) {
        auto& e = evs[i];
        rel[i] = e.line + shift[e.inBuf.getId()];
        shift[e.inBuf.getId()] += e.flat;
    }
    auto* infos = s.MakeInclude_file_infoVec();
    for (size_t i = 0; i < evs.size(); i++) {
        auto& e = evs[i];
        uint32_t line = rel[i];
        auto* rootBuf = &e.inBuf;
        for (int32_t p = e.parent; p >= 0; p = evs[(size_t)p].parent) {
            line += rel[(size_t)p] - 1;
            rootBuf = &evs[(size_t)p].inBuf;
        }
        auto* ifi = s.MakeInclude_file_info();
        ifi->VpiParent(d);
        ifi->VpiFile(sm->getFullPath(*rootBuf).string());
        ifi->VpiIncludedFile(e.path);
        ifi->VpiLineNo(line);
        ifi->VpiColumnNo(e.col);
        ifi->VpiEndLineNo(e.endLine > e.line ? line + (e.endLine - e.line) : line);
        ifi->VpiEndColumnNo(e.endCol);
        infos->push_back(ifi);
    }
    d->Include_file_infos(infos);
}

// § classPropScopedCallIsRefObj29 — the ScopedName a class-property
// initializer's CALL is written through, or null when it is written bare.
// `base39::mk()`, `cls39#(int)::sf()` and `q39b::kb39#(2)::sf(1,"s")` all
// answer their outermost ScopedName; `f()` and `this.f()` answer null (a DOT
// separator is a member select, not a scope).
const slang::syntax::SyntaxNode* UhdmExporter::scopedCallName29(
    const Expression& call) const {
    if (!call.syntax)
        return nullptr;
    const syntax::SyntaxNode* n = call.syntax;
    if (n->kind == syntax::SyntaxKind::InvocationExpression)
        n = &*n->as<syntax::InvocationExpressionSyntax>().left;
    if (!n || n->kind != syntax::SyntaxKind::ScopedName)
        return nullptr;
    auto& sn = n->as<syntax::ScopedNameSyntax>();
    if (sn.separator.kind != slang::parsing::TokenKind::DoubleColon)
        return nullptr;
    return n;
}

// § classPropInit29 — the class-property DECLARATION INITIALIZER shapes the
// inline whitelist in emitClassDefn does not build.  Surelog compiles a class
// body with Reduce::No, so nothing here folds; the four laws below were each
// pinned on the purpose-built pair tools/probe/r10uvm29repro/t39{a,b} (every
// cell read BOTH directions off the r10uvm29v census):
//
//   § classPropNewInit29 — `T p = new;` / `= new()` / `= new(args)` keeps the
//     constructor call as vpiExpr: the SAME loc-less `method_func_call 'new'`
//     emitExpr's NewClass arm already builds, arguments and all, and with NO
//     vpiArgument vector at all when the call is argument-less (bare `new`
//     and `new()` are identical).  11 uvm_pkg properties in Scoreboard
//     (uvm_status_container::scope, uvm_printer::knobs, uvm_transaction::
//     events, ...), the pass-28 ranked #1 head at 240+28+26 elements.
//
//   § classPropScopedCallIsRefObj29 — a call written through a CLASS `::`
//     scope is NOT a call in the model: it degrades to a bare `ref_obj`
//     naming `<leftmost segment>::<rightmost segment>` — every intermediate
//     segment and every `#(...)` parameterisation DROPPED, the ARGUMENTS
//     dropped with them — unbound (no vpiActual), fullname
//     `<property fullname>::<that name>`, spanned from the head of the scoped
//     name through the LAST `::` separator (Surelog's class_scope span, the
//     same one makeClassScopeTs uses).  t39a: `base39::mk()` -> `base39::mk`,
//     `cls39#(int)::sf()` -> `cls39::sf`; t39b: `q39b::kb39#(2)::sf(1,"s")`
//     -> `q39b::sf`.  This is the pass-28 ranked #2 residue
//     (`uvm_callbacks::m_register_pair` over the 9 `m_register_cb_*` bits the
//     `uvm_register_cb` macro plants, plus uvm_heartbeat_callback's
//     `uvm_coreservice_t::get`), 166 elements — and it is NOT a binding
//     question: golden leaves vpiActual null too, we simply had no vpiExpr.
//
//   § classPropCallInit29 — any OTHER call (bare `f()`, or one qualified by a
//     PACKAGE rather than a class) stays a `func_call` with vpiFunction bound
//     and its written arguments — which is exactly what emitExpr builds, once
//     the class's own methods exist (hence the deferred drain).  t39b's
//     `q39b::qf39(4)` keeps the QUALIFIER in vpiName (`q39b::qf39`), the
//     spelling ExprEmit's § staticScopedCall12 note says golden carries in
//     package-scope initializers and nowhere else.
//
//   § classPropUnbasedUnsizedInit29 — `'0`/`'1`/`'x`/`'z` fills the PROPERTY's
//     width and prints as one unsigned decimal (uvm_spell_chkr's
//     `static const int unsigned max = '1` -> 4294967295 at size 32).
//
//   § classPropPatternInit29 (t39c) — a CONCATENATION and an ASSIGNMENT
//     PATTERN ride the variable as the operation emitExpr already builds
//     (operation#33 over raw string constants; operation#75 over a
//     tagged_pattern for `'{default:0}`).  The assoc/queue/dynamic arm of
//     emitClassDefn `continue`s past the scalar initializer block, so it
//     enqueues its property here explicitly (uvm_sequence_library's
//     `int seqs_distrib[string] = '{default:0}`).
//
//   § classPropTimeLitInit2 (r10buvm2, and the arm that CLEARED BuildUVMPkg's
//     head) — a TIME LITERAL is a `vpiUIntConst` (constType 9, NOT the
//     vpiTimeConst 8 the shape's name suggests: Surelog's `paTime_literal`
//     arm literally writes `c->VpiConstType(vpiUIntConst)`), whose VALUE is
//     § srlgTimeLitVal's FIXED per-unit factor table (s 1e12, ms 1e9, ns 1e6,
//     us 1e3, ps 1, fs 1e-3) — a table that never consults the timescale and
//     is not even monotone.  Pass 29 left the factor "unsettled" from two
//     cells; it was settled the same session in `§ srlgTimeLitVal` for the
//     PARAMETER carrier, and arm a1's seven unit cells re-prove it here
//     (`9200s` -> 9200000000000000, `7ms` -> 7000000000, `7us` -> 7000,
//     `7ns` -> 7000000, `7ps` -> 7, `7fs` -> 0, `1.5ns` -> 1000000).
//     What pass 29 could NOT have known is the SECOND half: the SIZE and the
//     vpiDecompile are decided by `CompileHelper::adjustSize`, which
//     `makeVar_`'s tail runs over every constant initializer with the
//     property's TYPESPEC.  On a `time_typespec` `Bits()` reports
//     invalidValue, so adjustSize does NOTHING and the raw literal object
//     survives — size 64, no decompile.  On any other integral typespec it
//     masks the value to that width, resizes, and stamps a decimal decompile.
//
// NOT modelled (measured, left for a later pass — see the pass-29 residue
// ranking): a BASED literal keeps its source spelling and base constType
// (`8'hff` -> `HEX:ff`, decompile `8'hff`) where the inline IntegerLiteral arm
// prints decimal, and its SIZE follows a rule t39b did NOT settle (`int
// k_wide = 8'hff` sizes 32 but `int k_bin = 4'b1010` sizes 4); and a SIMPLE
// assignment pattern's element constants size at the ELEMENT width where
// emitExpr gives them 64 (t39c a_dyn — no UVM property reaches it).
void UhdmExporter::emitClassPropInit29(const PendingPropInit29& pi) {
    auto& cp = pi.cp->as<ClassPropertySymbol>();
    auto* pinit = cp.getInitializer();
    if (!pinit)
        return;
    auto& ic = stripImplicitConv(*pinit);
    NetMap nm29;
    struct Ctx29 {
        bool& f;
        explicit Ctx29(bool& b) : f(b) { f = true; }
        ~Ctx29() { f = false; }
    } ctx29(classPropInitCtx29);
    if (ic.kind == ExpressionKind::NewClass) {
        if (auto* e29 = emitExpr(ic, pi.var, pi.pfn, nm29))
            pi.var->Expr((UHDM::expr*)e29);
        return;
    }
    if (ic.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
        // The fill spans the PROPERTY's width; `'x`/`'z` has no decimal form
        // and is left off, as the IntegerLiteral arm leaves an unknown off.
        auto lv29 = ic.as<UnbasedUnsizedIntegerLiteral>().getLiteralValue();
        uint32_t w29 = (uint32_t)cp.getType().getBitWidth();
        if (w29 && !lv29.isUnknown()) {
            slang::SVInt u29 = lv29.value ? ~slang::SVInt(w29, 0, false)
                                          : slang::SVInt(w29, 0, false);
            u29.setSigned(false);
            std::string d29 = u29.toString(LiteralBase::Decimal, false);
            auto* c29 = s.MakeConstant();
            c29->VpiDecompile(d29);
            c29->VpiSize((int32_t)cp.getType().getBitWidth());
            c29->VpiValue("UINT:" + d29);
            c29->VpiConstType(vpiUIntConst);
            c29->VpiParent(pi.var);
            setLoc(c29, ic.sourceRange);
            pi.var->Expr(c29);
        }
        return;
    }
    // § classPropPatternInit29 — a CONCATENATION and an ASSIGNMENT PATTERN
    // ride the variable as the operation emitExpr already builds
    // (t39c: `{"ab","cd"}` -> operation#33 over raw string constants,
    // `'{default:0}` -> operation#75 over a tagged_pattern).  Only an
    // operation is accepted, so a shape that folds elsewhere stays off.
    //
    // § assocPropPatternInitRidesElem31 — THE UNSIZED-ARRAY CARRIER'S THREE
    // EXTRA CLAUSES.  When the property is a DYNAMIC / QUEUE / ASSOCIATIVE
    // array (`pi.elem` non-null; see the push site in emitClassDefn), golden's
    // object is not one `vpiExpr` on the array_var but ONE operation that
    //   (1) is PARENTED AT THE vpiReg ELEMENT variable, not at the array_var;
    //   (2) hangs off BOTH the array_var's and the ELEMENT's `vpiExpr` — the
    //       SAME object, exactly as § fixedClassPropIsArrayVar6 already does
    //       for a fixed array and as TypeEmit's `emitDynArrayVar` already does
    //       for a module/package-scope concatenation; and
    //   (3) has its DIRECT constant operands sized at the ELEMENT width where
    //       emitExpr leaves the bare-decimal default of 64.
    // Clause (2) is the COMPARED one: `variables::Compare` reads `Expr()` and
    // `array_var::Compare` walks `Variables()`, so the element's missing
    // `vpiExpr` first-fails the whole array_var.  THAT WAS THE HEAD — the
    // BuildUVMPkg and SeqDriver 47-line `uvm_sequence_library::seqs_distrib`
    // (`protected int seqs_distrib[string] = '{default:0}`) head at base
    // 265eea9 printed golden's `operation` 75 as LHS against `RHS: <null>`,
    // and its `vpiParent` in the head text is the `int_var`, not the
    // array_var, which is clause (1) written out.
    //
    // DECODED FROM THE PRODUCER, not guessed.  Surelog compiles the class-body
    // initializer in `ElaborationStep::exprFromAssign_`
    // (src/DesignCompile/ElaborationStep.cpp:1574) with `Reduce::No`, so
    // NOTHING folds; `makeVar_` then sets `var->Expr(assignExp)` on the
    // element (:2097) and `array_var->Expr(assignExp)` on the wrapper (:2289)
    // over the SAME object, whose `VpiParent` was last written by the element
    // arm.  The pattern tree itself is `CompileHelper::
    // compileAssignmentPattern` (CompileExpression.cpp:3671): op 75, one
    // `tagged_pattern` per keyed item, and a key with NO `Constant_primary`
    // child mints the `string_typespec` named `"default"` at the KEY span
    // (:3796) — which is the shape ExprEmit's default-setter arm already
    // builds byte for byte, so no new object kind is invented here.
    //
    // CLAUSE (3)'s WIDTH IS THE ELEMENT'S, MEASURED, and it is fenced to
    // DIRECT constant operands that emitExpr left at the BARE-DECIMAL default
    // (`bareDecimalDefault64_31`, EmitHelpers.h — read its measurement table):
    // a literal the source wrote 64 bits wide (`int d[] = '{64'd9}`) and a
    // real constant keep golden's 64, and only an unsized decimal takes the
    // element width.  Without that gate the resize shrank `64'd9` to 32 and
    // broke a field the base commit already had right (verifier r10vbuvm31,
    // arm gv31a7: four class-property cells golden==pristine,
    // patched!=golden).  Arm a2 reads golden `int cs_dyn[] =
    // '{1,2,3}` -> three size-32 constants, `byte cb_dyn[] = '{1,2}` -> size
    // 8, `int cc_dyn[] = {6,7,8}` (concat, op 33) -> size 32, and
    // `'{3{2}}` (op 76) -> the COUNT operand 32 with the nested concat's own
    // operand left at 64.  A TAGGED operand is not a constant, so
    // `'{default:0}` keeps golden's 64 for free — which is what the corpus
    // head needs.
    if (ic.kind == ExpressionKind::Concatenation ||
        ic.kind == ExpressionKind::SimpleAssignmentPattern ||
        ic.kind == ExpressionKind::StructuredAssignmentPattern ||
        ic.kind == ExpressionKind::ReplicatedAssignmentPattern) {
        UHDM::any* pat31 = pi.elem ? (UHDM::any*)pi.elem : (UHDM::any*)pi.var;
        if (auto* e27 = emitExpr(ic, pat31, pi.pfn, nm29))
            if (e27->UhdmType() == UHDM::uhdmoperation) {
                if (pi.elem) {
                    if (pi.elemW > 0)
                        if (auto* os31 = ((UHDM::operation*)e27)->Operands())
                            for (auto* o31 : *os31)
                                if (bareDecimalDefault64_31(o31))
                                    ((UHDM::expr*)o31)->VpiSize(pi.elemW);
                    pi.elem->Expr((UHDM::expr*)e27);
                }
                pi.var->Expr((UHDM::expr*)e27);
            }
        return;
    }
    // § typeParamScopedCallRef59 — CALL SITE 2 of 2.  A class-property
    // initializer written `<Tparam>::<method>(...)` is the SAME degraded ref_obj
    // § classPropScopedCallIsRefObj29 builds two blocks below, except that slang
    // never produced a CallExpression for it, so that arm's `ic.kind ==
    // ExpressionKind::Call` gate can never see it and this whole function used
    // to `return` one line down leaving the property with NO vpiExpr.
    // GATE (the code below IS the gate): the initializer is an `Invalid`
    // expression with NO child whose syntax roots in a `::`-scoped name.
    // Measured on arm a2 cell P12 (`Tregistry m_prop = Tregistry::get();`):
    // golden hangs `ref_obj Tregistry::get`@108:24-35 on the property's own
    // int_var with fullname `<property fullname>::Tregistry::get`, which is the
    // prefix this call passes.  It was the arm's LAST remaining head.
    if (auto* r59 = invalidScopedCallRef59(ic, pi.var, pi.pfn)) {
        pi.var->Expr((UHDM::expr*)r59);
        return;
    }
    if (ic.kind != ExpressionKind::Call)
        return;
    // § classPropSysCallInit2 — a SYSTEM function call initializer stays a
    // `sys_func_call` named `$<f>`, parented at the property, spanning the
    // WHOLE call, with its written arguments — which is exactly what emitExpr
    // already builds; this arm only stops throwing it away.  The kind test is
    // the gate: emitExpr FOLDS `$bits` (§ srlgBitsFoldArg / §
    // bitsOwnClassPropFold61) and returns a constant, and golden's own folded
    // `$bits` constant is sized by `adjustSize` at the property's width, which
    // this pass did NOT decode — so a folded result is left OFF rather than
    // emitted at the wrong size.  Arm a2 cells m04_urand ($urandom),
    // m05_urandr ($urandom_range with arguments), m06_random, m07_time,
    // m09_sqrt; the refused cell is m08_bits, residue R3.
    if (ic.as<CallExpression>().isSystemCall()) {
        if (auto* es2 = emitExpr(ic, pi.var, pi.pfn, nm29))
            if (es2->UhdmType() == UHDM::uhdmsys_func_call)
                pi.var->Expr((UHDM::expr*)es2);
        return;
    }
    if (auto* snn29 = scopedCallName29(ic)) {
        auto* sn29 = &snn29->as<syntax::ScopedNameSyntax>();
        // Only a CLASS scope degrades; a package qualifier keeps the call
        // (t39b `q39b::qf39(4)` vs `q39b::kb39#(2)::sf(1,"s")`).
        auto* sub29 = std::get<const SubroutineSymbol*>(
            ic.as<CallExpression>().subroutine);
        auto* psc29 = sub29 ? sub29->getParentScope() : nullptr;
        if (psc29 && psc29->asSymbol().kind == SymbolKind::ClassType) {
            // Leftmost identifier of the (left-associative) chain and the
            // rightmost segment's written text.
            const syntax::SyntaxNode* lhead29 = &*sn29->left;
            const slang::syntax::ScopedNameSyntax* deepest29 = sn29;
            while (lhead29->kind == syntax::SyntaxKind::ScopedName) {
                deepest29 = &lhead29->as<syntax::ScopedNameSyntax>();
                lhead29 = &*deepest29->left;
            }
            std::string head29;
            if (auto* cn29 = lhead29->as_if<syntax::ClassNameSyntax>())
                head29 = std::string(cn29->identifier.valueText());
            else if (auto* in29 = lhead29->as_if<syntax::IdentifierNameSyntax>())
                head29 = std::string(in29->identifier.valueText());
            else
                head29 = std::string(rawText(lhead29->sourceRange()));
            std::string tail29;
            if (auto* cn28 = sn29->right->as_if<syntax::ClassNameSyntax>())
                tail29 = std::string(cn28->identifier.valueText());
            else
                tail29 = std::string(rawText(sn29->right->sourceRange()));
            auto* ro29 = s.MakeRef_obj();
            ro29->VpiName(head29 + "::" + tail29);
            ro29->VpiFullName(pi.pfn + "::" + head29 + "::" + tail29);
            ro29->VpiParent(pi.var);
            setLoc(ro29, SourceRange(deepest29->left->sourceRange().start(),
                                     sn29->separator.range().end()));
            pi.var->Expr(ro29);
            return;
        }
    }
    if (auto* e28 = emitExpr(ic, pi.var, pi.pfn, nm29))
        if (e28->UhdmType() == UHDM::uhdmfunc_call)
            pi.var->Expr((UHDM::expr*)e28);
}

// § classDefnVirtualFromVirtualIfaceDecl6 (predicate) — does this class
// declaration's SYNTAX SUBTREE write a `virtual <iface>` data type anywhere?
// Surelog's rule is literally `fC->sl_collect(id, VObjectType::paVIRTUAL)`
// over the whole class subtree (CompileClass.cpp, grep `defn->VpiVirtual`),
// and `sl_collect` recurses (FileContent.cpp `NodeId FileContent::sl_collect`).
// The grammar emits a standalone `paVIRTUAL` node in exactly two places that
// can sit inside a class body: `VIRTUAL? CLASS` and
// `VIRTUAL INTERFACE? interface_identifier` — a `virtual function` qualifier
// does NOT (measured: arm cell k3_virtmethod reads vpiVirtual ABSENT on BOTH
// sides).
//
// STRUCK BY THE r10oth6 VERIFIER — this comment used to end "So a syntax walk
// for VirtualInterfaceType is the same predicate."  IT IS NOT, and the sentence
// above it names the counterexample it ignored: `VIRTUAL? CLASS` is the OTHER
// paVIRTUAL site that can sit in a class body.  A class whose only `virtual` is
// a NESTED `virtual class` gets vpiVirtual:1 from golden's `sl_collect` and
// ABSENT from this walk.  MEASURED, not reasoned — arm cell `v4_nestedvirt.sv`,
// `x1_outer`: golden 1 / ours ABSENT, with the control `x2_outer` (nested class
// NOT virtual) reading ABSENT on both sides.  This is an UNDER-fire and it is
// PRE-EXISTING (the pristine binary reads ABSENT too, since the outer class is
// not abstract), so it is not a regression of this pass — it is filed as
// residue R8 and deliberately NOT widened here, because widening it needs the
// `virtual class` half measured on its own and this pass did not do that.
static bool hasVirtualIfaceSyntax6(const slang::syntax::SyntaxNode* n) {
    if (!n)
        return false;
    if (n->kind == slang::syntax::SyntaxKind::VirtualInterfaceType)
        return true;
    for (size_t i = 0, e = n->getChildCount(); i < e; ++i)
        if (hasVirtualIfaceSyntax6(n->childNode(i)))
            return true;
    return false;
}

// A class definition (file-level or module-local): properties as ::-scoped
// automatic vars (typespecs deferred to the write phase), methods via
// emitTaskFuncs in class scope. File-level classes display their work@ name;
// module-local ones keep the bare name with a work@mod::name fullname.
UHDM::class_defn* UhdmExporter::emitClassDefn(const ClassType& cls,
                                              const std::string& dispName,
                                              const std::string& fullName,
                                              UHDM::BaseClass* parent) {
    auto* cd = s.MakeClass_defn();
    cd->VpiName(dispName);
    if (fullName != dispName)
        cd->VpiFullName(fullName);
    cd->VpiParent(parent);
    cd->VpiFile(fullFilePath(cls.location));
    if (auto syn = cls.getSyntax()) {
        // Surelog anchors a class_defn at the `class` KEYWORD (its
        // sl_collect(modId, paCLASS) start node), so a `virtual class` starts
        // past the `virtual`.
        auto r = syn->sourceRange();
        if (auto* cds = syn->as_if<syntax::ClassDeclarationSyntax>()) {
            if (cds->classKeyword.range().start() != SourceLocation::NoLocation)
                r = SourceRange(cds->classKeyword.range().start(), r.end());
            // § endBlockLabelAllOwners62 — `endclass : <name>` -> vpiEndLabel,
            // the WRITTEN TOKEN's text, bare (never the ::-qualified fullname).
            // class_defn::Compare reads vpiEndLabel as its LAST field, so a
            // labelled class whose every other field already matches
            // first-fails on nothing but this: that is exactly the
            // uvm_set_get_dap_base head this pass was given.
            if (auto* ebn = cds->endBlockName)
                cd->VpiEndLabel(ebn->name.valueText());
        }
        setLoc(cd, r);
    }
    auto* vars = s.MakeVariablesVec();
    auto* nevs = s.MakeNamed_eventVec();
    std::vector<PendingPropInit29> lateInit29;
    for (auto& pm : cls.members()) {
        if (pm.kind != SymbolKind::ClassProperty)
            continue;
        auto& cp = pm.as<ClassPropertySymbol>();
        auto& ct = cp.getType().getCanonicalType();
        std::string pfn = fullName + "::" + std::string(cp.name);
        // An `event` property is NOT a variable: it is a named_event in the
        // class's own vpiNamedEvent listing (scope::Compare reads that vector
        // BEFORE vpiVariables, so a missing one first-fails the class).  It
        // carries name/fullname/span only — no vpiAutomatic even on a
        // non-static property, and no visibility field exists on the object.
        if (ct.kind == SymbolKind::EventType) {
            auto* ne = s.MakeNamed_event();
            ne->VpiName(cp.name);
            ne->VpiFullName(pfn);
            ne->VpiParent(cd);
            setLoc(ne, nameSpan(cp.location, cp.name));
            nevs->push_back(ne);
            continue;
        }
        // `rand`/`randc` qualifier -> vpiIsRandomized + vpiRandType
        // (vpiNotRand 1 / vpiRand 2 / vpiRandC 3); an unqualified property
        // keeps whatever the shape below sets (SimpleConstraint).
        int32_t randTy = cp.randMode == RandMode::Rand    ? 2
                         : cp.randMode == RandMode::RandC ? 3
                                                          : 0;
        // A class PROPERTY carries the declared access qualifier, exactly as
        // emitTaskFuncs already stamps it on a method: vpiPublic 1 (the
        // default), vpiProtected 2, vpiLocal 3. variables::Compare reads
        // vpiVisibility, so a `protected`/`local` property emitted as public
        // is a cmp difference on its own (ApbSlave: svunit_base::name/success
        // are protected, svunit_testcase's counters local).
        int32_t vis = cp.visibility == Visibility::Protected ? 2
                      : cp.visibility == Visibility::Local   ? 3
                                                             : 1;
        // § classScopedTypedefPropIsBareLogicVar73 — a property whose DECLARED
        // TYPE NAME comes out of a CLASS scope the property's own class body
        // does not declare (`uvm_sequencer_base::seq_req_t request;`,
        // uvm_sequencer_base.svh:1771 — the head this pass was given, and
        // `rand uvm_mem_mam::alloc_mode_e mode` / `locality` with it) is a BARE
        // `logic_var` in golden with NO vpiTypespec at all: Surelog's Signal
        // never binds a typespec for it and `makeVar_` ends in the same
        // `// default type (fallback)` arm § virtualIfacePropIsBareLogicVar6
        // transcribes.  The predicate is in EmitHelpers.h with its three
        // measured clauses; it is read HERE, ahead of every emission arm,
        // because the degradation outranks the ARRAY arm too (a5 c_qual_qtd: a
        // class-scope QUEUE typedef is a logic_var, not an array_var).
        const bool foreignTd73 = classScopedTypedefProp73(cp, cls);
        // § fixedClassPropIsArrayVar6 — a FIXED-SIZE unpacked-array CLASS
        // PROPERTY (`Receiver rcvr[4];`) is an `array_var` in golden, built from
        // exactly the same parts as the dynamic/queue/assoc property one line
        // below — bare `array_typespec` behind a `ref_typespec`, ELEMENT var
        // under `vpiReg`, `vpiRandType`/`vpiVisibility`/`vpiAutomatic` from the
        // qualifiers — plus THREE fixed-only members: `vpiArrayType:1`,
        // `vpiSize` = the element COUNT (§ fixedUnpackedCount6), and one
        // `vpiRange` per written dimension.  We used to `continue` here
        // ("class property type: FixedSizeUnpackedArrayType"), which DELETED the
        // property from the class's `vpiVariables` listing — and `scope::Compare`
        // reads that vector, so the whole class first-failed.  SVSwitch's head at
        // base 80892a3 was exactly that: golden's `class_defn (work@Environment)`
        // lists `array_var (work@Environment::output_intf)` at 17 and
        // `array_var (work@Environment::rcvr)` at 20 and ours listed NEITHER.
        //
        // WITNESSES, both read in full from the pristine dumps before any code
        // was written (tools/probe/r10svs6repro/README.md §2):
        //   Environemnt.sv:17 `virtual output_interface.OP output_intf[4];`
        //     array_var @17:31-17:42 {size 4, arrayType 1, randType 1,
        //     visibility 1, automatic 1, range @17:43-17:44, reg = a BARE
        //     logic_var with NO typespec}
        //   Environemnt.sv:20 `Receiver rcvr[4];`
        //     ...same, reg = class_var -> ref_typespec -> class_typespec
        //     (Receiver) @20:3-20:11.
        //
        // WHY NOT ROUTE THROUGH TypeEmit.cpp's `emitArrayVar`, which already
        // builds this shape at MODULE scope — THE BRIEF'S OWN QUESTION, and the
        // answer is MEASURED, not stylistic.  `emitArrayVar`'s element decode is
        // wrong for 9 element kinds and the class arm would have INHERITED every
        // one: arm b2's MODULE twins read golden `byte_var`/`short_int_var`/
        // `long_int_var`/`real_var`/`short_real_var`/`string_var`/`struct_var`
        // (unpacked)/`class_var`/`byte_var`(typedef) against our `int_var` or
        // `logic_var` (cells m03, m04, m05, m06, m15, m16, m17, m21, m22, m24 —
        // 10 DIFFER readings, all PRE-EXISTING and all r10oth9's residue R5
        // widened).  The class-property element factory
        // (`classAssocElemVar`/`classElemVar`) is right for all of them, so the
        // shared parts reused here are the two that ARE right at both scopes:
        // § fixedUnpackedCount6 and `buildUnpackedRanges`.
        //
        // GATE — three clauses, each one measured:
        //   (1) the canonical type is a FixedSizeUnpackedArrayType, and
        //   (2) the property's OWN type is not itself a typedef NAME.  This is
        //       § arrayVarSignedWritten8's clause (a) reused as a SHAPE gate,
        //       because golden's object for `typedef byte barr_t[4]; barr_t x;`
        //       is a DIFFERENT and much smaller object: NO vpiSize, NO
        //       vpiArrayType, NO vpiRandType, NO vpiRange, NO vpiReg, and its
        //       actual typespec is a NAMED `array_typespec (barr_t)` (arm b2
        //       cells c25_wholetd / m25_wholetd — the module twin over-fires on
        //       all five today, which is r10oth8's own open residue).  Building
        //       the full shape there would be a MEASURED over-fire, so it is
        //       gated out and left as residue R1 rather than shipped and
        //       explained away, and
        //   (3) the INNERMOST element (after descending every fixed dim) is not
        //       itself dynamic/queue/assoc.  For `int x[4][]` golden's array_var
        //       carries `vpiArrayType:2` — the UNSIZED dim's kind wins wherever
        //       it sits — with NO range and NO element var (arm b3 cells
        //       c06_fixdyn / c08_fixq / c09_fixassoc, and c07_dynfix / c10_qfix
        //       from the other side).  That is a different law with a different
        //       shape; the hybrids stay exactly as they are today (no object at
        //       all: residue R2) instead of being swallowed by this arm.
        const Type* fixedElem6 = nullptr;
        if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType &&
            cp.getType().kind != SymbolKind::TypeAlias) {
            const Type* in6 = &ct;
            size_t nCanon6 = 0;
            while (in6->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType) {
                in6 = &in6->getCanonicalType()
                           .as<FixedSizeUnpackedArrayType>()
                           .elementType;
                ++nCanon6;
            }
            // GATE CLAUSE (2b), ADDED AT INTEGRATION (verifier F1): clause (2)
            // tests only the property's OWN type, so a whole-array typedef ONE
            // LEVEL DOWN (`typedef byte b4_t[4]; b4_t x[2];`) slipped past it
            // and this arm built a WRONG object — vpiSize 8 (the canonical
            // descent multiplied the typedef's hidden [4] in) with ONE range,
            // vpiSigned:1, and a flat byte_var element where golden nests an
            // array_var carrying the NAMED array_typespec (b4_t).  Verifier
            // cell v1_gaps.sv v01_tdarr, measured on both binaries; the module
            // twin m01_tdarr shows emitArrayVar inherits the same defect.
            // The refusal: every canonical fixed dim must have been WRITTEN on
            // the declarator — a typedef contributing hidden dims makes
            // nCanon6 exceed the written count, and that shape belongs to the
            // R1/R2 typedef family, not this law.  AST-shape test only.
            size_t nWritten6 = 0;
            if (auto* dsyn6 = cp.getSyntax();
                dsyn6 && dsyn6->kind == syntax::SyntaxKind::Declarator)
                nWritten6 =
                    dsyn6->as<syntax::DeclaratorSyntax>().dimensions.size();
            if (nCanon6 <= nWritten6)
                switch (in6->getCanonicalType().kind) {
                    case SymbolKind::DynamicArrayType:
                    case SymbolKind::QueueType:
                    case SymbolKind::AssociativeArrayType:
                        break;
                    default:
                        fixedElem6 = in6;
                        break;
                }
        }
        // A DYNAMIC-array / QUEUE / ASSOC property is an array_var carrying a
        // bare array_typespec, with the ELEMENT variable under vpiReg.
        // § classScopedTypedefPropIsBareLogicVar73 outranks this arm: the
        // FIXED gate above already refuses a typedef NAME (clause 2), but this
        // one does not, so a class-scope WHOLE-QUEUE / WHOLE-DYNAMIC typedef
        // (`holder::q_t x;`) would otherwise build an array_var where golden
        // has a bare logic_var — arm a5 cell c_qual_qtd, measured on both
        // binaries.  A DECLARATOR-formed array of the same qualified element
        // (`holder::e_t x[]`, `x[$]`) is NOT a typedef name, so it keeps this
        // arm and stays byte-identical to golden (a5 c_qual_dyn / c_qual_q).
        if (!foreignTd73 &&
            (fixedElem6 || ct.kind == SymbolKind::DynamicArrayType ||
             ct.kind == SymbolKind::QueueType ||
             ct.kind == SymbolKind::AssociativeArrayType)) {
            const Type* et = nullptr;
            int32_t akind = 2;
            // Every ASSOCIATIVE dimension of the declaration, outermost
            // first.  Surelog compiles ALL unpacked dims into `range`
            // objects whose Right_expr is a `STRING:associative` marker
            // constant carrying the index typespec
            // (CompileExpression.cpp:4103/4185), then ElaborationStep's
            // array_var pass (:2113) erases the FIRST such marker into the
            // array_typespec's vpiIndexTypespec and — because that marker
            // was dim 0 — hands the REMAINING markers to the array_var as
            // vpiRange.  So a multi-dimension assoc property
            // (`m_streams[string][string]`) is one array_var with one
            // Index_typespec and (ndims-1) marker ranges, and the vpiReg
            // element is the INNERMOST element type.
            std::vector<const Type*> assocIdx;
            // § fixedClassPropIsArrayVar6 — the element is the INNERMOST one
            // (a 2-D `int x[4][2]` has an int_var element, arm b3 c05_2d) and
            // the array kind is vpiArrayType 1.
            if (fixedElem6) {
                et = fixedElem6;
                akind = 1;
            }
            else if (ct.kind == SymbolKind::DynamicArrayType)
                et = &ct.as<DynamicArrayType>().elementType;
            else if (ct.kind == SymbolKind::QueueType) {
                et = &ct.as<QueueType>().elementType;
                akind = 4;
            }
            else {
                akind = 3;
                const Type* cur = &ct;
                while (cur->getCanonicalType().kind ==
                       SymbolKind::AssociativeArrayType) {
                    auto& ac = cur->getCanonicalType().as<AssociativeArrayType>();
                    assocIdx.push_back(ac.indexType);
                    et = &ac.elementType;
                    cur = et;
                }
            }
            auto* reg = fixedElem6 ? classFixedElemVar6(cp, *et, cls)
                                   : classAssocElemVar(cp, *et, cls);
            if (!reg) {
                noteUnsupported("class array property element");
                continue;
            }
            auto* av = s.MakeArray_var();
            av->VpiName(cp.name);
            av->VpiFullName(pfn);
            av->VpiParent(cd);
            setLoc(av, nameSpan(cp.location, cp.name));
            // § fixedClassPropIsArrayVar6 — vpiSize is the ELEMENT COUNT for a
            // fixed array (4 for `[4]`, 8 for `[4][2]`, and 1 for a PARAM-sized
            // `[N]` — arm b3 cells c01_size / c05_2d / c11_paramsz), against the
            // flat 1 a dynamic/queue/assoc property carries.
            av->VpiSize(fixedElem6 ? fixedUnpackedCount6(cp) : 1);
            // § constClassPropIsConstantVariable27 reaches the ARRAY property
            // too: `const int x[4] = '{...}` carries vpiConstantVariable:1 on the
            // array_var (arm b4 cell c06_const, read at own child depth).  The
            // scalar arm below already had this; the array arm did not, and no
            // dynamic-array cell had exercised it.
            if (cp.flags.has(VariableFlags::Const))
                av->VpiConstantVariable(true);
            // ...and the same static rule as the scalar arm below.
            if (cp.lifetime != VariableLifetime::Static)
                av->VpiAutomatic(true);
            if (randTy) {
                av->VpiIsRandomized(true);
                av->VpiRandType(randTy);
            }
            else
                av->VpiRandType(1);
            av->VpiVisibility(vis);
            av->VpiArrayType(akind);
            // NOTE § arrayVarSignedWritten8, the ADD half.  GATE: the shared
            // `arraySignedWritten8` predicate (declared above) — the element
            // type AS WRITTEN must be a signed integer atom or a signed
            // bit/logic/reg scalar/vector, and the property's own type must not
            // itself be a typedef name.  Golden puts this on the ARRAY_VAR;
            // ours used to put it only on the vpiReg element (see the SUPPRESS
            // half a few lines below), which is a MOVE, not an add.
            // WITNESS: SVSwitch Packet.sv:23 `rand byte data[];` — the head at
            // base 8d4d6ed was `array_var (work@packet::data)` with golden
            // carrying `|vpiSigned:1` and ours not.  `variables::Compare` reads
            // VpiSigned, so it gates.
            //
            // r10svs6 MADE THIS THE FOURTH CALL SITE, exactly as r10oth9's
            // residue R3 predicted it would need to be, and the predicate holds
            // AS WRITTEN for a FIXED array at class scope — 25 arm b2 cells,
            // golden `1` on `int`/`byte`/`shortint`/`longint`/`integer`/
            // `bit signed [7:0]`/`logic signed [7:0]` (c01, c03, c05, c06, c07,
            // c13, c14) and ABSENT on every unsigned atom, `time`, bare
            // `bit`/`logic`/`reg`, unsigned vector, `real`, `shortreal`,
            // `string`, enum (INCLUDING the SIGNED-enum typedef c19_senum),
            // packed and unpacked struct, class handle, `chandle` and the
            // typedef'd element c24_btd.  Clause (b)'s kind list and clause
            // (a)'s typedef rejection are therefore both live at this scope for
            // fixed arrays too, and NOTHING about the predicate had to change.
            if (arraySignedWritten8(cp.getType(), *et))
                av->VpiSigned(true);
            auto* ats = s.MakeArray_typespec();
            auto* art = s.MakeRef_typespec();
            art->VpiParent(av);
            art->Actual_typespec(ats);
            av->Typespec(art);
            emitAssocDims(cp, assocIdx, av, ats);
            // § fixedClassPropIsArrayVar6 — one `vpiRange` per WRITTEN dimension,
            // built by the SAME `buildUnpackedRanges` the module-scope arm uses.
            // Reusing it is a measurement, not an assumption: every module twin
            // of every dimension spelling is byte-identical to golden already
            // (arm b3 cells m01_size / m02_rng03 / m03_rng30 / m04_rng14 /
            // m05_2d / m11_paramsz all EQ), and golden's class-scope spans are
            // the same rule — the whole `[0:3]` for a range dim (b3 c02_rng03,
            // 9:16-9:21) and the SIZE TOKEN alone for a `[4]` dim (b3 c01_size,
            // 8:16-8:17; SVSwitch witness 1, 17:43-17:44).
            if (fixedElem6)
                if (auto* rngs6 = buildUnpackedRanges(cp, av))
                    av->Ranges(rngs6);
            // NOTE § bitElemSharesArrayRanges11 — the ELEMENT variable of a
            // CLASS-PROPERTY `array_var` carries `vpiRange` = THE ARRAY_VAR'S
            // OWN RANGE VECTOR, and it does so if and only if that element is a
            // `bit_var`.  `array_var::Compare` reads `Variables()` and
            // `variables`/`bit_var::Compare` reads `Ranges()`, so the missing
            // vector IS a compared difference, not decoration.
            //
            // WITNESS — the `uhdm-cmp` head of BuildUVMPkg in BOTH modes at
            // base e359f0a, `uvm_pkg.sv:21545`
            // `bit compare_map[uvm_object][uvm_object];`:
            //   LHS golden  bit_var (uvm_pkg::uvm_comparer::compare_map)
            //               |vpiRange -> range 21545:30-21545:42
            //                            (the INNER assoc marker, `UINT:0` ..
            //                             `STRING:associative` -> class_typespec
            //                             uvm_object)
            //   RHS <null>
            // The vector SafeCompare sets `m_failedLhs` to the OWNER of the
            // vector — so the head names the ELEMENT and the FIELD is the
            // element's `Ranges`, not anything on the array_var (whose own
            // `vpiRange` we already emit, byte for byte).
            //
            // DECODED FROM THE PRODUCER, not guessed.  Surelog
            // `ElaborationStep::makeVar_` (src/DesignCompile/ElaborationStep.cpp
            // ~1921) has exactly ONE arm in its `(found == false) && tps`
            // typespec switch that touches the element's ranges:
            //     } else if (tpstype == uhdmbit_typespec) {
            //         bit_var* stv = s.MakeBit_var();
            //         stv->Ranges(unpackedDimensions);   // <- the SAME vector
            // and `unpackedDimensions` is the very vector the array_var pass
            // (~2113) then ERASES the outermost unsized marker from and hands to
            // `array_var->Ranges(...)`.  The `logic_typespec` arm three lines
            // above has the same line COMMENTED OUT ("it is a repeat of the
            // typespec packed dimension"), which is why the law is bit-only.
            //
            // THE GATE IS THE ELEMENT KIND AND NOTHING ELSE, and every other
            // candidate gate was REFUTED on a purpose-built grid
            // (tools/probe/r10buvm11repro, golden vs ours, LHS golden):
            //   * NOT the dim shape — arm w1 gives golden's element the array's
            //     markers in ALL of `[int][int]`, `[int][string]`, `[k][k]`,
            //     `[][]`, `[$][$]`, `[int][$]`, `[$][int]`, `[][int]`,
            //     `[int][]`, `[int][int][int]`, `[int][2]`, `[][2]`, `[$][2]`,
            //     `[int][2][3]`, `[4]`, `[2][3]`, `[0:3]`; the 1-D unsized
            //     shapes (`[int]`, `[]`, `[$]`) leave the array_var rangeless
            //     and golden's element vector is then EMPTY, which serialization
            //     drops — so the `!avr->empty()` test below is the same fact.
            //   * NOT the home — arm w3 gives it at a class in a package, a
            //     class in a module, a class at $unit scope, in the DEF view and
            //     the ELAB view alike.  Subroutine- and block-LOCAL arrays are
            //     the fence: golden gives THEM no array_var ranges at all
            //     (`bit fl_aa[int][int]` reads `av-`/`ev-` on both sides), so
            //     TaskFuncEmit's sites are deliberately untouched.
            //   * NOT a typedef test — arm w2 and arm w6 give it to a
            //     package-scope `typedef bit`, a `typedef bit [7:0]`, a
            //     typedef-of-typedef, a QUALIFIED `pk::b_t`, and to typedefs
            //     declared INSIDE the class, identically to a written `bit`.
            //     (The MODULE-scope twin of that cell reads the OTHER way — arm
            //     w4 `f_btd`/`f_bvtd`/`n_btd` — which is exactly why this stamp
            //     is at the CLASS site only; see residue R1.)
            //   * NOT "any integral" — arm w2's 2-D assoc grid gives NOTHING to
            //     logic, `logic [7:0]`, a `typedef logic`, int, int unsigned,
            //     byte, shortint, longint, integer, time, real, shortreal,
            //     string, chandle, a class handle, an enum (even a `enum bit`
            //     one), a packed struct or an unpacked struct — 18 cells, all
            //     golden-empty and all already correct here.
            //   * A BASE-CLASS typedef element degrades to a `logic_var` before
            //     it reaches this line (§ classAssocElemVar's own law, arm w6
            //     `a_bbtd`/`f_bbtd`), so the kind gate fences it for free.
            // The three class-scope producers of `av->Ranges` — `emitAssocDims`'
            // inner-dimension markers, `buildUnpackedRanges`' fixed dims, and
            // § assocTypeParamDimIsStaticSize51's `[0 : KEY-1]` reshape (arm w5
            // `pool[KEY]` with `T = bit`) — all three answer the same way, which
            // is why the stamp sits AFTER all of them and reads the array_var
            // back rather than re-deriving anything.
            //
            // THE VECTOR IS SHARED, not copied, because Surelog shares it: the
            // range objects keep `vpiParent` -> the array_var in golden too.
            // uhdm-cmp does not compare object identity, so sharing is not the
            // measured fact — the CONTENT is — but copying would have to
            // reproduce every field of every bound expression, and re-parenting
            // would be a second, invented difference.
            if (reg->UhdmType() == UHDM::uhdmbit_var)
                if (auto* avr = av->Ranges(); avr && !avr->empty())
                    ((UHDM::bit_var*)reg)->Ranges(avr);
            reg->VpiParent(av);
            reg->VpiFullName(pfn);
            setLoc(reg, nameSpan(cp.location, cp.name));
            // NOTE § arrayVarSignedWritten8, the SUPPRESS half.  GATE: NONE —
            // it is UNCONDITIONAL, and that is a measurement, not a shortcut:
            // across the 118 CLASS-PROPERTY and MODULE/PACKAGE-VARIABLE cells
            // of tools/probe/r10oth8repro (every element kind, all four array
            // kinds) golden's vpiReg element var carries `vpiSigned` in ZERO of
            // them.  IT IS THE OPPOSITE AT SUBROUTINE/BLOCK-LOCAL SCOPE — arm
            // a9 cells n01/n02/n03 show golden putting `vpiSigned:1` on the
            // ELEMENT and nothing on the array_var there — which is why this
            // law is scope-bound and TaskFuncEmit.cpp's `reg0->VpiSigned(true)`
            // sites are deliberately left alone.  The value
            // arrives here from `makeReturnVar`, which stamps
            // `VpiSigned(pit.isSigned)` on an integer-atom var; for an UNSIGNED
            // atom that is already false, so clearing changes nothing there.
            // The module-scope twin does exactly this (TypeEmit.cpp, grep
            // `Signedness rides the ARRAY here`).
            reg->VpiSigned(false);
            // A PREDEFINED-INTEGER element takes the matching integer
            // typespec here rather than the write-phase mint, which would
            // read the property's own declared type and produce the vector
            // form (int_typespec, not logic_typespec — BuildUVMPkg
            // uvm_seed_map `int unsigned seed_table[string]`).
            if (auto* rrt = reg->Typespec();
                rrt && !((UHDM::ref_typespec*)rrt)->Actual_typespec() &&
                et->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
                if (auto* pts = predefIntTypespec(et->getCanonicalType(), cp)) {
                    ((UHDM::ref_typespec*)rrt)->Actual_typespec(pts);
                    // § arrayElemTsSignedParented9 — the ELEMENT TYPESPEC of a
                    // dynamic / queue / assoc CLASS PROPERTY carries BOTH
                    // `vpiParent` -> its own `vpiReg` element var AND
                    // `vpiSigned` = THE ELEMENT TYPE'S RESOLVED SIGNEDNESS.
                    // `predefIntTypespec` mints a bare object on purpose (its
                    // header comment: the io_decl / local copy Surelog hands
                    // back is the unsigned-looking one) and leaves both fields
                    // to its callers; this call site is the one that owes them.
                    //
                    // WITNESS: SVSwitch Packet.sv:23 `rand byte data[];` — the
                    // head at base 37ffbd2 was exactly
                    //   golden byte_typespec 23:6 { vpiParent -> byte_var
                    //          (work@packet::data), vpiSigned:1 }
                    //   ours   byte_typespec 23:6 { }
                    // while the PLAIN SCALAR `byte fcs;` one line below already
                    // got both from us (arm b1 cell c01_fcs), because a scalar
                    // property goes through the write-phase `makeTypespec`
                    // mint, whose PredefinedIntegerType arm stamps
                    // `VpiSigned(pit.isSigned)` and whose caller then stamps
                    // `ts->VpiParent(pc.var)`.  The MODULE-scope twin is
                    // already correct too (arm b1 m02_data): TypeEmit's
                    // `emitDynArrayVar` does `elemTs->VpiParent(reg)` (grep
                    // `Signedness rides the ARRAY here`) over a typespec that
                    // `sharedTypespec`/`makeTypespec` had already signed.  So
                    // this is the ONE arm of the three that owed the fields,
                    // and both stamps are TRANSCRIBED from a working sibling
                    // rather than invented.
                    //
                    // IT IS *NOT* § arrayVarSignedWritten8's PREDICATE, AND
                    // THAT IS A MEASUREMENT, NOT A SHORTCUT.  The two carriers
                    // DISAGREE on the typedef cell, which is the whole reason
                    // arm b3 exists:
                    //   `typedef byte b_t; rand b_t x[];` (b3 f01_btd/g01_btd)
                    //       array_var vpiSigned  -> ABSENT on both sides
                    //                               (§ arrayVarSignedWritten8
                    //                                clause (a)/(b): a typedef
                    //                                NAME gets nothing)
                    //       element typespec     -> golden vpiSigned:1
                    //   `typedef b_t b2_t; rand b2_t x[];` (b3 f05_chain) — same
                    //       split, golden typespec `1`, array_var absent.
                    // So the typespec keys on the RESOLVED type (`isSigned()`
                    // pierces the alias, which is exactly what r10oth8's F1 had
                    // to STOP the array_var doing), while the array_var keys on
                    // the type AS WRITTEN.  Reusing `arraySignedWritten8` here
                    // would leave f01/f05 wrong in the same direction they are
                    // wrong today.  DO NOT MERGE THE TWO PREDICATES.
                    //
                    // NEGATIVE CONTROLS THAT FIRE: `byte unsigned` /
                    // `int unsigned` / `shortint unsigned` / `longint unsigned`
                    // / `integer unsigned` and `time` (b2 d02/d05/d07/d09/d11/
                    // d12) are golden-ABSENT and stay absent, because the value
                    // stamped is `isSigned()` and not a constant 1 — and `time`
                    // additionally has no case below, matching `makeTypespec`.
                    //
                    // THE SHARED-OBJECT HAZARD DOES NOT REACH THIS SITE, and
                    // that is measured, not assumed: `predefIntTypespec` does
                    // `s.Make<X>_typespec()` unconditionally, so every object it
                    // returns is FRESH.  The R10OTH9_TRACE instrument (removed
                    // before shipping; the run is quoted in
                    // tools/probe/r10oth9repro/README.md §2) printed a DISTINCT
                    // pointer and `sharedAlias=0` for all 20 PATH_I objects
                    // across arms b1/b2/b3, `isSharedAliasTs` included.  A
                    // typedef'd element does NOT change that: the alias
                    // registries are never consulted on this path.
                    // ONE GATE, AND IT IS THE ONE CLAUSE THE TWO CARRIERS
                    // AGREE ON: § arrayVarSignedWritten8's clause (a), the
                    // WHOLE ARRAY reached through a typedef
                    // (`typedef byte barr_t[]; rand barr_t x;`).  Golden's
                    // object for that shape is not a `byte_typespec` at all —
                    // it is a bare `array_typespec` carrying NEITHER field
                    // (arm b3 cells f06_wholetd / g06_wholetd, both sides at
                    // own child depth).  Stamping there is a MEASURED over-fire
                    // on a cell golden leaves empty, so it is gated out rather
                    // than shipped and explained away.  The residue that our
                    // object is the wrong CLASS is ranked R4 and is NOT touched
                    // here.
                    // NOTE this is clause (a) ONLY.  Clauses (b)+(c) — the
                    // "as written" kind list — are what arms b3 f01/f05 REFUTE
                    // for this carrier; see the § comment above.
                    if (cp.getType().kind != SymbolKind::TypeAlias &&
                        et->isSigned())
                        switch (pts->UhdmType()) {
                            case UHDM::uhdmint_typespec:
                                ((UHDM::int_typespec*)pts)->VpiSigned(true);
                                break;
                            case UHDM::uhdminteger_typespec:
                                ((UHDM::integer_typespec*)pts)->VpiSigned(true);
                                break;
                            case UHDM::uhdmshort_int_typespec:
                                ((UHDM::short_int_typespec*)pts)
                                    ->VpiSigned(true);
                                break;
                            case UHDM::uhdmlong_int_typespec:
                                ((UHDM::long_int_typespec*)pts)
                                    ->VpiSigned(true);
                                break;
                            case UHDM::uhdmbyte_typespec:
                                ((UHDM::byte_typespec*)pts)->VpiSigned(true);
                                break;
                            default:
                                break;
                        }
                    if (cp.getType().kind != SymbolKind::TypeAlias)
                        pts->VpiParent(reg);
                }
            }
            // An ELEMENT type with no shared alias (a bare `bit [7:0]`) still
            // gets its own typespec, minted in the write phase like any other
            // property's (SimpleConstraint `rand bit [7:0] payload []`: the
            // vpiReg bit_var's ref_typespec -> a ranged bit_typespec).
            //
            // § arrayElemTsSignedParented9, THE HALF THIS PASS DELIBERATELY DID
            // NOT SHIP.  This branch already gets `vpiParent` (the write phase
            // stamps `ts->VpiParent(pc.var)` with `pc.var` = `reg`), but it does
            // NOT get `vpiSigned` for a SIGNED bit/logic/reg element: arm b2
            // cells d14_bits / d16_logics / d18_regs / d20_vecs / d21_lvecs read
            // golden `1` against our absent.  IT IS NOT A CLASS-SCOPE DEFECT —
            // the MODULE twins e14/e16/e20/e21 read exactly the same way, so it
            // is a shared law over a different producer (`makeTypespec`'s
            // scalar/packed arm, not its PredefinedIntegerType arm) with a much
            // wider blast radius than this pass measured.  Ranked R1 in
            // tools/probe/r10oth9repro/README.md; do not fix it here without
            // the module-scope arm table to go with it.
            if (auto* rrt = reg->Typespec();
                rrt && !((UHDM::ref_typespec*)rrt)->Actual_typespec())
                pendingClassPropTs.push_back(
                    {(UHDM::ref_typespec*)rrt, &cp, reg});
            auto* rvars = s.MakeVariablesVec();
            rvars->push_back(reg);
            av->Variables(rvars);
            // § classPropInit29 — a dynamic/queue/assoc property carries its
            // declaration initializer too (uvm_sequence_library's
            // `int seqs_distrib[string] = '{default:0}`).
            //
            // § fixedClassPropIsArrayVar6, THE INITIALIZER HALF — an ARRAY
            // PATTERN on a FIXED array is not a § classPropInit29 shape: golden
            // parents the operation at the ELEMENT var and hangs it off BOTH the
            // array_var's and the element's `vpiExpr` (arm b4 cells c06_const /
            // c11_initpat, where the `vpiExpr` operation's own `vpiParent` reads
            // `int_var (work@b4_cls::c11_initpat)` and the same object is printed
            // under the element too).  That is exactly what the MODULE-scope
            // sibling already does (TypeEmit.cpp emitArrayVar, grep
            // `Array-pattern initializer`), so the code is transcribed from it —
            // including `suppressConstParent`, which keeps the pattern's LEAF
            // constants unparented while the nested pattern operations
            // self-parent.
            if (auto* pin6 = fixedElem6 ? cp.getInitializer() : nullptr) {
                auto& ic6 = stripImplicitConv(*pin6);
                if (ic6.kind == ExpressionKind::SimpleAssignmentPattern ||
                    ic6.kind == ExpressionKind::ReplicatedAssignmentPattern ||
                    ic6.kind == ExpressionKind::StructuredAssignmentPattern) {
                    NetMap none6;
                    bool savedSCP6 = suppressConstParent;
                    suppressConstParent = true;
                    if (auto* e6 = emitExpr(ic6, reg, pfn, none6)) {
                        av->Expr((UHDM::expr*)e6);
                        reg->Expr((UHDM::expr*)e6);
                    }
                    suppressConstParent = savedSCP6;
                }
                else
                    lateInit29.push_back({av, &cp, pfn});
            }
            // § assocPropPatternInitRidesElem31 — a DYNAMIC / QUEUE /
            // ASSOCIATIVE property carries its declaration initializer on BOTH
            // carriers, so the deferred record names the vpiReg ELEMENT (and
            // its width) beside the array_var.  `fixedElem6` never reaches
            // here (its pattern arm is emitted inline above and its
            // non-pattern initializer takes the push one line up), which is
            // why the element fields are set at THIS push and nowhere else.
            else if (cp.getInitializer())
                lateInit29.push_back({av, &cp, pfn, reg,
                                      (int32_t)et->getBitWidth()});
            vars->push_back(av);
            continue;
        }
        // A predefined integer field (int/byte/...) is the matching typed
        // var (int_var + vpiSigned), not a bare bit_var; anonymous bit/logic
        // vectors keep bit/logic_var.
        UHDM::variables* v = nullptr;
        // § classScopedTypedefPropIsBareLogicVar73 — FIRST, ahead of every kind
        // decode, because the degradation is decided by the NAME's home scope
        // and not by what the name resolves to: arm a4 measures golden's
        // `logic_var` on the class-qualified enum, int, string, chandle,
        // packed struct, unpacked struct, whole-array, whole-queue and CLASS
        // HANDLE spellings alike (c_plain, c_randc, c_str, c_chand,
        // c_qual_pstruct, c_qual_ustruct, a5 c_qual_arrtd / c_qual_qtd,
        // a2 c_qual_handle), against our enum_var / int_var / string_var /
        // chandle_var / bit_var / struct_var / array_var / class_var.
        if (foreignTd73)
            v = s.MakeLogic_var();
        // An ENUM-typed property is an enum_var, not the bit/logic_var its
        // integral base would give (SimpleConstraint `rand pkt_type ptype`);
        // the array-element path (classElemVar) already had this rule.
        else if (ct.kind == SymbolKind::EnumType)
            v = s.MakeEnum_var();
        // § classPropPackedStructIsStructVar136 — a class property whose
        // canonical type is a PACKED struct / union is a `struct_var` /
        // `union_var`, NOT the `bit_var` / `logic_var` its INTEGRAL base gives.
        // A packed struct IS integral in slang, so without this arm the
        // `ct.isIntegral()` line below swallowed it and the 2-state /
        // 4-state split decided the class — which is how
        // `uvm_pkg::uvm_reg_map_info::mem_range` (uvm_reg_map.svh:29, typed by
        // the package typedef `uvm_reg_map_addr_range`, a 2-state packed
        // struct at uvm_reg_model.svh:408) came out a `bit_var` against
        // golden's `struct_var` in ALL NINE UVM databases.
        //
        // DECODED, not guessed: Surelog's variable class for a class property
        // FOLLOWS THE TYPESPEC KIND, in two mirror-image closed dispatches —
        //   * `CompileHelper::getSimpleVarFromTypespec`
        //     (src/DesignCompile/CompileType.cpp:78; its `uhdmstruct_typespec`
        //     arm at :201 mints `MakeStruct_var`, its `uhdmunion_typespec` arm
        //     at :182 `MakeUnion_var`), reached for a NAMED type through
        //     `compileVariable`'s `slStringConst` / `paClass_scope` arms
        //     (CompileType.cpp:345, :567, :599) and through
        //     `ElaborationStep::makeVar_`'s `SimpleType` arm (:1852);
        //   * `makeVar_`'s `DummyType` arm (ElaborationStep.cpp:1786-1791),
        //     which is the ANONYMOUS `struct packed {...} p;` route and reads
        //     the very same typespec kind.
        // Neither dispatch looks at 2-state vs 4-state, at the typedef's
        // declaration order, or at whether a typedef was written at all.
        //
        // THE TYPESPEC IS UNTOUCHED.  This arm decides the variable CLASS only;
        // the property's `ref_typespec` is still minted in the write phase by
        // `pendingClassPropTs` -> `makeTypespec`, and the census confirms the
        // bound `struct_typespec` / `union_typespec` (kind, name, member list
        // and `vpiInstance`) was ALREADY byte-for-byte golden's on every cell
        // this arm moves — so the typespec-linkage laws (uvm114, uvm123,
        // § classPropNoStampShared50) are not in play here.
        //
        // GATE = the CANONICAL kind, so the typedef chain (arm A `k12_chain`,
        // arm E `e07_chain3`), the cross-package spelling qualified and
        // wildcard-imported (arm B `b05_xpkgQual` / `b06_xpkgWild`), the
        // in-class typedef (`b07_inClass`) and the ANONYMOUS packed struct
        // (arm A `k14_anonps`) all land here — golden gives every one of them
        // a `struct_var`.  It sits AFTER § classScopedTypedefPropIsBareLogicVar73
        // on purpose: a CLASS-qualified packed-struct typedef stays that law's
        // bare `logic_var` (its arm a4 cell `c_qual_pstruct`).
        //
        // FENCED, deliberately: a PACKED ARRAY over a packed struct / union /
        // enum is a `packed_array_var` in golden and stays a `bit_var` here.
        // Arm F measures nine packed-array/control cells; the half's corpus
        // reach is ZERO (0 cells in 956 surelog + 1358 uhdm2rtlil databases),
        // and one of its FOUR moving cells (`f03_paunion`) also needs a
        // TYPESPEC fix we are not making in this pass, so the whole half is
        // left to R0 rather than half-moved.  `f05_pabit` / `f06_palogic` / `f07_patypedef` (a
        // bit / logic leaf) are `bit_var` / `logic_var` in golden and must
        // NEVER reach a packed-array arm.
        else if (ct.kind == SymbolKind::PackedStructType)
            v = s.MakeStruct_var();
        else if (ct.kind == SymbolKind::PackedUnionType)
            v = s.MakeUnion_var();
        else if (ct.isIntegral()) {
            if (ct.kind == SymbolKind::PredefinedIntegerType)
                v = makeVar(cp, /*portBacked=*/false);
            if (!v)
                v = ct.isFourState() ? (UHDM::variables*)s.MakeLogic_var()
                                     : (UHDM::variables*)s.MakeBit_var();
        }
        else
            v = makeVar(cp, /*portBacked=*/false);
        // An UNPACKED struct/union property is a struct_var / union_var
        // carrying the shared typedef typespec: makeVar's struct arms are
        // written for the module net-vs-var decode and only reach PACKED
        // ones, but a class property is never a net (BuildUVMPkg:
        // uvm_factory_override's `m_uvm_factory_type_pair_t orig/ovrd`).
        if (!v && ct.kind == SymbolKind::UnpackedStructType)
            v = s.MakeStruct_var();
        if (!v && ct.kind == SymbolKind::UnpackedUnionType)
            v = s.MakeUnion_var();
        // § virtualIfacePropIsBareLogicVar6 — a VIRTUAL INTERFACE class
        // PROPERTY is a BARE `logic_var` in golden, carrying nothing but
        // name / fullname / parent / span / vpiAutomatic / vpiVisibility, and
        // in particular NO vpiTypespec at all.  We used to `continue` here
        // ("class property type: VirtualInterfaceType"), which DELETED the
        // property from the class's vpiVariables listing — SVSwitch's head was
        // exactly that: golden's first Driver variable is the line-13
        // `virtual input_interface.IP input_intf`, ours was the line-14
        // `mailbox drvr2sb`.
        //
        // WHY a logic_var, transcribed from the producer rather than guessed:
        // Surelog never models a virtual interface at all.  `Signal`'s type is
        // the `slStringConst` of the interface name (CompileHelper.cpp
        // compileDataDeclaration steps PAST the `paVIRTUAL` node), no typespec
        // binds, and `ElaborationStep::makeVar_` falls off the end of its
        // subnettype switch into its `// default type (fallback)` arm, which
        // mints a bare `logic_var` with null packed ranges.  The tail of
        // makeVar_ then stamps vpiAutomatic (unless static) and vpiVisibility,
        // which is why the object still reads like a normal property.
        //
        // GATE: canonical-type kind only, so the TYPEDEF'd spelling
        // (`typedef virtual w_if.IP wif_t; wif_t vi;`) lands here too — arm
        // cell k6_typedef proves golden treats it identically.  All four
        // written spellings (`virtual <if>.<mp>`, `virtual <if>`,
        // `virtual interface <if>`, `virtual interface <if>.<mp>`) are ONE
        // cell in golden: v1 arm cells c1..c4.
        bool vifProp6 = false;
        if (!v && ct.kind == SymbolKind::VirtualInterfaceType) {
            v = s.MakeLogic_var();
            vifProp6 = true;
        }
        if (!v) {
            noteUnsupportedAt("class property type: " +
                              std::string(toString(ct.kind)), cp.location);
            continue;
        }
        v->VpiName(cp.name);
        v->VpiFullName(fullName + "::" + std::string(cp.name));
        v->VpiParent(cd);
        setLoc(v, nameSpan(cp.location, cp.name));
        // ...but a STATIC property is not automatic: it has one lifetime for
        // the whole class, and Surelog leaves vpiAutomatic unset on it
        // (`static protected int m_inst_count` vs the `local int m_inst_id`
        // one line above it, uvm_object).  variables::Compare reads the
        // field, so the two spellings are not interchangeable.
        if (cp.lifetime != VariableLifetime::Static)
            v->VpiAutomatic(true);
        // § constClassPropIsConstantVariable27 — a `const` class PROPERTY
        // carries vpiConstantVariable exactly as a package / module /
        // interface `const` variable does; we stamped it everywhere except
        // here.  Orthogonal to `static` and to the visibility qualifiers
        // (t37g: both qualifier orders, with and without an initializer,
        // local/protected, int and string all read 1).  Reach is one shared
        // object per macro expansion but a wide one: `const static string
        // type_name` (uvm_object_defines.svh:428) alone is 161 of the
        // Scoreboard package-listing localizer's failing elements, because
        // variables::Compare reads the field and every method whose body
        // mentions the class drags it in.
        if (cp.flags.has(VariableFlags::Const))
            v->VpiConstantVariable(true);
        if (randTy) {
            v->VpiIsRandomized(true);
            v->VpiRandType(randTy);
        }
        v->VpiVisibility(vis);
        // A property DECLARATION INITIALIZER rides the var as vpiExpr, and
        // variables::Compare recurses into it — a missing one is a cmp
        // difference on its own. Two measured shapes (ApbSlave's svunit
        // classes); anything else is left off rather than mis-shaped:
        //   `= <enum const>` -> an UNFOLDED ref_obj named after the constant,
        //      fullname <prop-fullname>::<const>, spanned at the reference;
        //   `= <integer literal>` -> a UINT constant sized at the PROPERTY's
        //      width (not the literal's), spanned at the literal.
        if (auto* pinit = cp.getInitializer()) {
            auto& ic0 = stripImplicitConv(*pinit);
            std::string pfn0 = fullName + "::" + std::string(cp.name);
            // ...and the same UNFOLDED ref_obj for a PARAMETER/localparam or
            // another property: Surelog compiles a class body with Reduce::No,
            // so no named initializer ever collapses to its value
            // (BuildUVMPkg: `int mcd = UVM_STDOUT;`).
            if (ic0.kind == ExpressionKind::NamedValue) {
                auto* ro = s.MakeRef_obj();
                ro->VpiName(ic0.as<NamedValueExpression>().symbol.name);
                ro->VpiFullName(pfn0 + "::" +
                                std::string(
                                    ic0.as<NamedValueExpression>().symbol.name));
                ro->VpiParent(v);
                setLoc(ro, ic0.sourceRange);
                v->Expr(ro);
            }
            else if (ic0.kind == ExpressionKind::IntegerLiteral) {
                auto iv0 = ic0.as<IntegerLiteral>().getValue();
                if (!iv0.hasUnknown()) {
                    slang::SVInt u0 = iv0;
                    u0.setSigned(false);
                    std::string d0 = u0.toString(LiteralBase::Decimal, false);
                    auto* c0 = s.MakeConstant();
                    c0->VpiDecompile(d0);
                    // § classScopedTypedefPropIsBareLogicVar73, the INITIALIZER
                    // half — and it is § classPropNullInitParentedByTypespec2's
                    // OWN law seen on a third population, exactly as that pass
                    // stated it ("having no typespec is the gate"): with no
                    // typespec the constant is parented by the CLASS_DEFN, not
                    // by the variable.  Arm a4 cells c_intinit and c_const
                    // against their controls k_intinit / k_const (the var).
                    //
                    // THE SIZE IS **NOT** A CONSTANT 64 — verifier arm v3
                    // (v3_size.sv, `§ 73` refinement) measured golden on the
                    // cells that make "property width" and "literal width"
                    // DISAGREE, and the carrier is the LITERAL AS WRITTEN:
                    //   c_uns   `holder::i_t = 7`     unsized -> 64
                    //   c_uns96 `holder::w_t = 7`     unsized -> 64  (NOT 96)
                    //   c_uns4  `holder::n_t = 7`     unsized -> 64  (NOT 4)
                    //   c_mix_w4`holder::w_t = 4'd7`  SIZED   ->  4  (NOT 64)
                    //   c_sz8   `holder::i_t = 8'd7`  SIZED   ->  8  (NOT 64)
                    //   c_sz32  `holder::i_t = 32'd7` SIZED   -> 32  (NOT 64)
                    // i.e. an UNSIZED literal falls back to Surelog's
                    // typespec-less default 64 (the a4 cells that produced the
                    // original "sized 64" reading are all unsized), while a
                    // SIZED literal keeps the width it was written with.  The
                    // NON-degraded branch is deliberately left EXACTLY as it
                    // was: its own sized-literal defect (v3 k_sz8 / k_mix_w4,
                    // identical on the pristine binary) is PRE-EXISTING and
                    // belongs to another head — widening the fix there would
                    // move corpus rows this pass has not measured.
                    c0->VpiSize(
                        foreignTd73
                            ? (ic0.as<IntegerLiteral>().isDeclaredUnsized
                                   ? 64
                                   : (int32_t)ic0.type->getBitWidth())
                            : (int32_t)cp.getType().getBitWidth());
                    c0->VpiValue("UINT:" + d0);
                    c0->VpiConstType(vpiUIntConst);
                    c0->VpiParent(foreignTd73 ? (UHDM::any*)cd : (UHDM::any*)v);
                    setLoc(c0, ic0.sourceRange);
                    v->Expr(c0);
                }
            }
            //   `= -<integer literal>` -> a bare vpiMinusOp operation (no
            //      decompile, no size, no typespec) over that same constant,
            //      spanned across the `-`.  BuildUVMPkg reaches this from
            //      almost every class (`int depth = -1` in uvm_printer_knobs
            //      alone is 1808 of the design's compare failures), because a
            //      missing vpiExpr first-fails variables::Compare.
            else if (ic0.kind == ExpressionKind::UnaryOp &&
                     ic0.as<UnaryExpression>().op == UnaryOperator::Minus) {
                auto& ub0 = stripImplicitConv(ic0.as<UnaryExpression>().operand());
                // § classPropRealInitRawValue29, the negated form: `real r =
                // -2.5` is the same bare vpiMinusOp over a source-text real
                // constant (t39c r_neg).
                if (ub0.kind == ExpressionKind::RealLiteral) {
                    std::string rtx4 = rawText(ub0.sourceRange);
                    auto* c4 = s.MakeConstant();
                    c4->VpiDecompile(rtx4);
                    c4->VpiSize(64);
                    c4->VpiValue(std::string("REAL:") + rtx4);
                    c4->VpiConstType(vpiRealConst);
                    setLoc(c4, ub0.sourceRange);
                    auto* op4 = s.MakeOperation();
                    op4->VpiOpType(vpiMinusOp);
                    op4->VpiParent(v);
                    setLoc(op4, ic0.sourceRange);
                    c4->VpiParent(op4);
                    auto* ops4 = s.MakeAnyVec();
                    ops4->push_back(c4);
                    op4->Operands(ops4);
                    v->Expr(op4);
                }
                else if (ub0.kind == ExpressionKind::IntegerLiteral) {
                    auto iv1 = ub0.as<IntegerLiteral>().getValue();
                    if (!iv1.hasUnknown()) {
                        slang::SVInt u1 = iv1;
                        u1.setSigned(false);
                        std::string d1 = u1.toString(LiteralBase::Decimal, false);
                        auto* c1 = s.MakeConstant();
                        c1->VpiDecompile(d1);
                        // § classScopedTypedefPropIsBareLogicVar73 — the SAME
                        // two facts one level down: the OPERATION takes the
                        // class_defn parent and the operand constant is sized
                        // by the LITERAL AS WRITTEN.  Arm a4 cell c_neg
                        // (`holder::i_t c_neg = -1`) against its control k_neg
                        // (the var).  `int depth = -1` is uvm-1.2's single
                        // commonest property initializer, so the shape is not
                        // hypothetical — only its class-qualified spelling is
                        // rare.
                        //
                        // The size is NOT a constant 64, for exactly the reason
                        // v3 gives one level up; verifier arm v4 (v4_neg.sv)
                        // measures the negated twin:
                        //   c_n_uns  `holder::i_t = -1`     unsized -> 64
                        //   c_n_uns4 `holder::n_t = -1`     unsized -> 64
                        //   c_n_sz8  `holder::i_t = -8'd1`  SIZED   ->  8
                        //   c_n_sz4  `holder::w_t = -4'd1`  SIZED   ->  4
                        // `ub0` is already stripped of the implicit conversion,
                        // so its type IS the literal's own.  The non-degraded
                        // branch is again left untouched (v4 k_n_sz8 / k_n_sz4
                        // are the same PRE-EXISTING defect, identical on the
                        // pristine binary).
                        c1->VpiSize(
                            foreignTd73
                                ? (ub0.as<IntegerLiteral>().isDeclaredUnsized
                                       ? 64
                                       : (int32_t)ub0.type->getBitWidth())
                                : (int32_t)cp.getType().getBitWidth());
                        c1->VpiValue("UINT:" + d1);
                        c1->VpiConstType(vpiUIntConst);
                        setLoc(c1, ub0.sourceRange);
                        auto* op1 = s.MakeOperation();
                        op1->VpiOpType(vpiMinusOp);
                        op1->VpiParent(foreignTd73 ? (UHDM::any*)cd
                                                   : (UHDM::any*)v);
                        setLoc(op1, ic0.sourceRange);
                        c1->VpiParent(op1);
                        auto* ops1 = s.MakeAnyVec();
                        ops1->push_back(c1);
                        op1->Operands(ops1);
                        v->Expr(op1);
                    }
                }
            }
            //   `= "<text>"` -> a vpiStringConst holding the RAW source
            //      characters (escapes unexpanded), sized 8 bits per raw
            //      character — the same rule ExprEmit's StringLiteral arm
            //      follows.  `= <real literal>` -> a vpiRealConst decompiling
            //      the source text at size 64.
            else if (ic0.kind == ExpressionKind::StringLiteral) {
                std::string raw2 = rawText(ic0.sourceRange);
                std::string in2 = raw2;
                if (in2.size() >= 2 && in2.front() == '"' && in2.back() == '"')
                    in2 = in2.substr(1, in2.size() - 2);
                else {
                    in2 = std::string(ic0.as<StringLiteral>().getRawValue());
                    if (in2.size() >= 2 && in2.front() == '"' && in2.back() == '"')
                        in2 = in2.substr(1, in2.size() - 2);
                    raw2 = "\"" + in2 + "\"";
                }
                auto* c2 = s.MakeConstant();
                c2->VpiDecompile(raw2);
                c2->VpiSize((int32_t)(in2.size() * 8));
                c2->VpiValue("STRING:" + in2);
                c2->VpiConstType(vpiStringConst);
                c2->VpiParent(v);
                setLoc(c2, ic0.sourceRange);
                v->Expr(c2);
            }
            else if (ic0.kind == ExpressionKind::RealLiteral) {
                // § classPropRealInitRawValue29 — a class-property REAL
                // initializer's vpiValue is the SOURCE TEXT, not a `%f`
                // rendering of the double.  Surelog compiles a class body
                // with Reduce::No, so the literal is never evaluated: t39c
                // reads REAL:1.5 / REAL:1.0e-12 / REAL:3.0 / REAL:1e6 for
                // the four spellings, all of them equal to the decompile.
                // `%f` had made uvm_tlm_time's `real Tp = 1.0e-12` print
                // REAL:0.000000 — a real pair, not a missing object.
                std::string rtx3 = rawText(ic0.sourceRange);
                auto* c3 = s.MakeConstant();
                c3->VpiDecompile(rtx3);
                c3->VpiSize(64);
                c3->VpiValue(std::string("REAL:") + rtx3);
                c3->VpiConstType(vpiRealConst);
                c3->VpiParent(v);
                setLoc(c3, ic0.sourceRange);
                v->Expr(c3);
            }
            // § classPropTimeLitInit2 — a TIME LITERAL class-property
            // initializer.  See the law block above emitClassPropInit29; the
            // ONE thing that decides the object's shape is whether Surelog's
            // `adjustSize` could size the property's TYPESPEC.
            else if (ic0.kind == ExpressionKind::TimeLiteral) {
                uint64_t tv2 = srlgTimeLitVal(rawText(ic0.sourceRange));
                const Type& pt2 = cp.getType().getCanonicalType();
                if (timeLikeType2(pt2)) {
                    // adjustSize is a NO-OP on a `time_typespec`, so the raw
                    // paTime_literal object survives: size 64, NO decompile.
                    auto* c5 = s.MakeConstant();
                    c5->VpiSize(64);
                    c5->VpiValue("UINT:" + std::to_string(tv2));
                    c5->VpiConstType(vpiUIntConst);
                    c5->VpiParent(v);
                    setLoc(c5, ic0.sourceRange);
                    v->Expr(c5);
                }
                else if (pt2.isIntegral() && pt2.getBitWidth()) {
                    // adjustSize FIRES: mask to the property's width, resize,
                    // and stamp the decimal decompile it never had before.
                    uint32_t w2 = pt2.getBitWidth();
                    uint64_t mv2 = w2 >= 64 ? tv2 : (tv2 & ((1ull << w2) - 1));
                    std::string d2 = std::to_string(mv2);
                    auto* c5 = s.MakeConstant();
                    c5->VpiDecompile(d2);
                    c5->VpiSize((int32_t)w2);
                    c5->VpiValue("UINT:" + d2);
                    c5->VpiConstType(vpiUIntConst);
                    c5->VpiParent(v);
                    setLoc(c5, ic0.sourceRange);
                    v->Expr(c5);
                }
                // A REAL / SHORTREAL property is left off: golden sizes it by
                // an `ExprEval::size(real_typespec)` answer this pass measured
                // (32) but did NOT decode, and a guessed width is worse than a
                // missing object.  Residue R2.
            }
            // § classPropNullInitParentedByTypespec2 — `= null` rides a
            // vpiNullConst (constType 11) sized 64, decompile `0`, value
            // UINT:0 on EVERY property that can hold it, and its vpiParent is
            // the CLASS_DEFN for some of them and the VARIABLE for others.
            // Surelog builds the initializer in
            // `TestbenchElaboration::bindProperties_` with
            // `exp->VpiParent(defn)` and then hands it to `makeVar_`, whose
            // TYPESPEC-DRIVEN arms all re-parent it to the variable and whose
            // trailing `subnettype` FALLBACK chain (reached only when the
            // property has NO typespec) ends in a bare `var->Expr(assignExp)`
            // that does not.
            //
            // THIS WIDENS § virtualIfaceNullInitIsClassParented6 AND REFUTES
            // ITS STATED GATE.  That law's comment ended "the gate is the
            // virtual-interface property, not `null`" — arm a2 cell m02_null
            // is the counterexample: a plain `chandle p = null;` is
            // CLASS_DEFN-parented too (golden's chandle_var carries no
            // typespec at all, `paChandle_type` being one of the fallback
            // chain's own branches).  The virtual interface was never the
            // gate; having no typespec is.
            else if (ic0.kind == ExpressionKind::NullLiteral) {
                auto* cn6 = s.MakeConstant();
                cn6->VpiDecompile("0");
                cn6->VpiSize(64);
                cn6->VpiValue("UINT:0");
                cn6->VpiConstType(vpiNullConst);
                // § classScopedTypedefPropIsBareLogicVar73 joins the FIRST
                // argument, not the helper: r10buvm2 owns this predicate and
                // its law is "NO TYPESPEC -> the null constant keeps Surelog's
                // class_defn parent".  A degraded property has no typespec, so
                // it is another instance of THAT law rather than a new one, and
                // the helper's body is left untouched.  Arm a4 cell c_null
                // (`holder::self_t c_null = null` — class_defn-parented in
                // golden) against control k_null (var-parented).
                cn6->VpiParent(nullInitDefnParented2(vifProp6 || foreignTd73, cp)
                                   ? (UHDM::any*)cd
                                   : (UHDM::any*)v);
                setLoc(cn6, ic0.sourceRange);
                v->Expr(cn6);
            }
            // Everything else is a § classPropInit29 shape: deferred to just
            // after emitTaskFuncs so a call can bind the class's own methods.
            else
                lateInit29.push_back({v, &cp, pfn0});
        }
        // § virtualIfacePropIsBareLogicVar6 (second half) — and it carries NO
        // ref_typespec.  Golden's object is five fields long; the ref_typespec
        // + write-phase mint below would add a `vpiTypespec` edge that
        // variables::Compare reads, so the property must skip it entirely.
        // Arm cells c1..c5, c7..c9, c12, k6, k8, k9 all read exactly
        // name/fullname/parent/span/automatic/visibility on BOTH sides.
        // § classScopedTypedefPropIsBareLogicVar73 (second half) — the SAME
        // skip, for the same reason: golden's degraded object has NO
        // vpiTypespec edge at all (the head's `logic_var
        // (uvm_pkg::uvm_sequence_request::request)` is six fields long and ours
        // was thirteen), so it must not reach the write-phase mint either.
        if (vifProp6 || foreignTd73) {
            vars->push_back(v);
            continue;
        }
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName + "::" + std::string(cp.name));
        rt->VpiParent(v);
        // The property ts is created in the write phase (arena order): the
        // ref is patched then.
        pendingClassPropTs.push_back({rt, &cp, v});
        v->Typespec(rt);
        vars->push_back(v);
    }
    if (!vars->empty())
        cd->Variables(vars);
    if (!nevs->empty())
        cd->Named_events(nevs);
    classDefnMap[&cls] = cd;
    if (cls.genericClass)
        genericDefnMap.emplace(cls.genericClass, cd);
    // `virtual class` / `pure virtual class`.
    // § classDefnVirtualFromVirtualIfaceDecl6 — ...and ALSO when the class
    // BODY writes a `virtual <iface>` data type anywhere, even though the
    // class itself is not abstract.  This is a Surelog artefact, not an LRM
    // rule: `sl_collect(classId, paVIRTUAL)` cannot tell the `virtual` of a
    // virtual-interface declaration from the `virtual` of `virtual class`.
    // class_defn::Compare reads vpiVirtual right after the scope base
    // (generated/src/class_defn.cpp `lhs->VpiVirtual() == rhs->VpiVirtual()`),
    // i.e. immediately after the vpiVariables listing this pass fixes — so
    // without this the SVSwitch head would simply move one field along.
    // Arm cells, BOTH sides: property k8/k9 = 1, method FORMAL k7 = 1, method
    // BODY LOCAL k5 = 1, in-class TYPEDEF k11 = 1; and the three controls
    // k1_plain / k3_virtmethod / k6_typedef (typedef written OUTSIDE the
    // class) all read ABSENT on both sides.
    if (cls.isAbstract || hasVirtualIfaceSyntax6(cls.getSyntax()))
        cd->VpiVirtual(true);
    // Parameters BEFORE typedefs: Surelog compiles the class header first, so
    // a formal's typespec is the older object (arena order — VirtualClass's
    // type_parameter logic_typespec precedes the typedefs' own objects).
    emitClassParameters(cls, cd, fullName);
    emitClassTypedefs(cls, cd);
    currentClassDefn = cd;
    // § externProtoInBodyCallBinds12 — THE MAP IS THE GATE (see
    // UhdmExporter.h).  Cleared here so it can only ever hold THIS class's own
    // prototypes: that is what fences a BASE class's prototype out (arm v2
    // `call_bef`, golden lnk0) without a single class-identity predicate at the
    // call site.  Saved and restored because a NESTED class's emission reuses
    // this same routine.
    auto savedProto12 = classProtoFn12;
    classProtoFn12.clear();
    emitTaskFuncs(cls, cd, fullName + "::", nullptr, false);
    currentClassDefn = nullptr;
    // § classPropInit29 — the property initializers whose shape the inline
    // whitelist above does not build.  Drained HERE, not inline: the shapes
    // that matter are CALLS, and a call to a static method of the class's own
    // body (`static this_type me = get();`, uvm_component_registry) can only
    // bind vpiFunction once emitTaskFuncs has put that method in `subMap`.
    for (auto& pi29 : lateInit29)
        emitClassPropInit29(pi29);
    // § externProtoInBodyCallBinds12 — the property initializers are drained
    // ABOVE, with the map still full, which is exactly why golden's
    // `uvm_reg_field::m_predefined = m_predefine_policies()` binds a prototype
    // declared BELOW the property (arm v1 `prop_esb`).  The map goes out of
    // scope only now.
    classProtoFn12 = savedProto12;
    // NESTED classes are their own class_defns parented at the enclosing one
    // and listed in its vpiInternalScope (Surelog's
    // CompileClass::compile_class_declaration_ pushes them onto Scopes()).
    // They are NOT re-listed in the owning package/module class list.
    {
        auto* scopes = s.MakeScopeVec();
        for (auto& nm : cls.members()) {
            const ClassType* nested = nullptr;
            if (nm.kind == SymbolKind::ClassType)
                nested = &nm.as<ClassType>();
            else if (nm.kind == SymbolKind::GenericClassDef) {
                if (auto* dsp = nm.as<GenericClassDefSymbol>().getDefaultSpecialization(cls);
                    dsp && dsp->kind == SymbolKind::ClassType)
                    nested = &dsp->as<ClassType>();
            }
            if (!nested)
                continue;
            scopes->push_back(emitClassDefn(*nested, std::string(nm.name),
                                            fullName + "::" + std::string(nm.name), cd));
        }
        if (!scopes->empty())
            cd->Scopes(scopes);
    }
    // `extends` needs every class_defn in the design to exist first.
    if (cls.getBaseClass())
        pendingExtends.push_back({cd, &cls});
    return cd;
}

UHDM::typespec* UhdmExporter::sharedAliasTs(const Type& t) {
    if (t.kind != SymbolKind::TypeAlias)
        return nullptr;
    if (auto it = pkgTopTypedefTs.find((const void*)&t); it != pkgTopTypedefTs.end())
        return it->second;
    if (auto it2 = typedefTs.find(&t); it2 != typedefTs.end())
        return it2->second;
    return nullptr;
}

bool UhdmExporter::isSharedAliasTs(const Type& t, const UHDM::typespec* ts) {
    if (!ts || t.kind != SymbolKind::TypeAlias)
        return false;
    // BOTH registries, not just the one sharedAliasTs prefers: a typedef has up
    // to two shared objects (the DEF-view one and the TOP-view one), the two
    // listings each hand back a different one, and NEITHER may be stamped by a
    // single use.  Testing only sharedAliasTs's winner would leave the other
    // object mutable — t58a measures both halves, `b8` (the bare twin) and
    // `pkb::b8` (the package listing's), and HEAD re-spans BOTH.
    if (auto it = pkgTopTypedefTs.find((const void*)&t);
        it != pkgTopTypedefTs.end() && it->second == ts)
        return true;
    if (auto it2 = typedefTs.find(&t); it2 != typedefTs.end() && it2->second == ts)
        return true;
    return false;
}

// § arrayVarSignedWritten8 — the ONE predicate behind every `array_var`
// `vpiSigned`, shared by the three sites that mint an array_var: this file's
// class-property dynamic/queue/assoc arm (`emitClassDefn`), and TypeEmit.cpp's
// `emitDynArrayVar` and `emitArrayVar`.
//
// GOLDEN'S RULE, transcribed from measurement and not guessed: signedness rides
// the ARRAY_VAR and NEVER the `vpiReg` element var, and it keys on the element
// type AS WRITTEN AT THE DECLARATION.  Surelog's compileVariable reaches a
// written keyword type through its own datatype path and computes signedness
// there; a type NAME resolves to a typespec instead and no signedness is ever
// computed, so `typedef byte b_t; b_t x[];` gets NO `vpiSigned` while
// `byte x[];` gets `vpiSigned:1`.  That is not an accident of $unit scope: a
// PACKAGE typedef behaves identically whether it is reached by wildcard import
// or written `pkg::name` (arm a8, cells k01/k02/k03 and m01/m02/m03/m06).
//
// THE KIND LIST IS NECESSARY, not decorative: an inline
// `struct packed signed { byte a; }` element IS signed and golden still gives
// the array_var nothing (arm a5 cells d09/e09), and an inline anonymous `enum`
// likewise (a5 d01/e01).  A predicate of "written and signed" without the kind
// list therefore over-fires on both.
//
// GATE (a) exists because `typedef byte barr_t[]; barr_t x;` — the whole ARRAY
// through a typedef — gets no `vpiSigned` either, and golden gives that shape
// no `vpiArrayType` at all (arm a5 cells d04/d05/e04/e05, an open residue of
// its own).
//
// DO NOT REUSE THIS PREDICATE FOR THE ELEMENT TYPESPEC.
// § arrayElemTsSignedParented9 (grep it in `emitClassDefn`) measured the OTHER
// carrier of signedness on the same declaration and the two DISAGREE on exactly
// the cell clause (a)/(b) exists for: `typedef byte b_t; b_t x[];` gives the
// array_var NOTHING and the ELEMENT TYPESPEC `vpiSigned:1` (arms b3 f01_btd /
// g01_btd / f05_chain).  The typespec keys on the RESOLVED type, this predicate
// on the type AS WRITTEN.  Two laws, two carriers, one declaration.
bool UhdmExporter::arraySignedWritten8(const Type& declaredWhole,
                                       const Type& writtenElem) {
    // (a) the array must be written at the declarator, not behind a typedef.
    if (declaredWhole.kind == SymbolKind::TypeAlias)
        return false;
    // (b) the element type must be written as a builtin integral keyword.  A
    // packed VECTOR qualifies only if the thing it packs is ALSO written as one,
    // so the alias rejection of clause (a) RECURSES through the packed wrapper.
    // Whitelisting PackedArrayType flatly would defeat clause (a): a written
    // `b_t [3:0]` is a PackedArrayType whose own `elementType` is the TypeAlias,
    // and `isSigned()` resolves STRAIGHT THROUGH it -- so the predicate would
    // pierce exactly the typedef this law exists to exclude.  Measured on the
    // v1_pkarrtd arm: `b_t [3:0] x[]` (v01/w01, `typedef byte b_t`) and
    // `se_t [1:0] x[]` (v03/w03, a signed-enum typedef) are golden `-`, while
    // `bit signed [7:0][3:0] x[]` (v02/w02) is golden `1` and is the POSITIVE
    // control that the descent must not break.  Do NOT canonicalise while
    // walking: canonicalising is what loses the alias.
    const Type* wk = &writtenElem;
    while (wk->kind == SymbolKind::PackedArrayType)
        wk = &wk->as<PackedArrayType>().elementType;
    switch (wk->kind) {
        case SymbolKind::PredefinedIntegerType:  // byte/shortint/int/longint/integer/time
        case SymbolKind::ScalarType:             // bit / logic / reg
            break;
        default:
            return false;
    }
    // (c) and it must be SIGNED — by default for the integer atoms (LRM 6.11,
    // which is why a census grepping for the literal `signed` keyword returns
    // ~zero and proves nothing), by the keyword for the vectors.
    return writtenElem.isSigned();
}

UHDM::variables* UhdmExporter::classElemVar(const Type& elemType,
                                            const Symbol* declKey9) {
    auto& ec = elemType.getCanonicalType();
    UHDM::variables* v = nullptr;
    UHDM::typespec* ts = nullptr;
    // NOTE § classPropElemTsFollowsScalarTd9, THE ON-DEMAND HALF, and it is a
    // TRANSCRIPTION of makeTypespec's own arm (grep "has not been compiled yet
    // when this reference is emitted"), not a new mechanism.  `emitClassDefn`
    // walks VARIABLES BEFORE it calls `emitClassTypedefs`, so at this point the
    // owning class's OWN nested typedefs are not in `typedefTs` yet and
    // `sharedAliasTs` below would miss every one of them — which is why a
    // class-NESTED typedef element (`typedef uvm_port_base #(IF) this_type;
    // this_type m_imp_list [string];`) resolved to the underlying class while
    // the PACKAGE-level spelling one line up did not.  The scalar path already
    // forces this build for exactly the same reason; the array element is
    // catching up with its own scalar here too.
    // GATE: only a PACKAGE-nested or class-nested owning class, because a
    // $unit-level class displays as `work@C` and this path cannot reconstruct
    // that name — the identical gate makeTypespec carries.  `buildClassTypedefTs`
    // is idempotent (`buildingClassTypedefs` re-entrancy set + a per-member
    // `typedefTs.count` early exit), so a class whose typedefs are already
    // built is a no-op.
    if (elemType.kind == SymbolKind::TypeAlias && !typedefTs.count(&elemType)) {
        if (auto* osc9 = elemType.getParentScope();
            osc9 && osc9->asSymbol().kind == SymbolKind::ClassType) {
            auto& ocl9 = osc9->asSymbol().as<ClassType>();
            if (auto* opsc9 = ocl9.getParentScope();
                opsc9 && (opsc9->asSymbol().kind == SymbolKind::Package ||
                          opsc9->asSymbol().kind == SymbolKind::ClassType))
                buildClassTypedefTs(ocl9, std::string(ocl9.name));
        }
    }
    if (ec.kind == SymbolKind::ClassType) {
        v = s.MakeClass_var();
        // NOTE § classPropElemTsFollowsScalarTd9, THE CLASS-HANDLE HALF.  The
        // three arms below this one already ask `sharedAliasTs` — the element
        // of a struct / union / enum TYPEDEF binds the TYPEDEF'S OWN LISTING
        // OBJECT — and this arm did not, so a CLASS-handle typedef element
        // resolved through the alias to the underlying class and minted a
        // FRESH, UNLOCATED object named for it:
        //   `uvm_id_actions_array severity_id_actions [uvm_severity];`
        //     golden class_typespec (uvm_pkg::uvm_id_actions_array)
        //            @29:9-29:17  inst=ALL:adpcm_pkg
        //     ours   class_typespec (uvm_pool) @0:0-0:0  inst=<null>
        // The SCALAR spelling of the same declaration was already right —
        // § classTdTopOnlyShare50 gives `uvm_id_verbosities_array
        // id_verbosities;` the listing object — so this is the array element
        // catching up with its own scalar, not a new policy.
        // GATE: `sharedAliasTs` returns a registry entry, so `isSharedAliasTs`
        // is TRUE for it and § sharedAliasNoStamp41's guards apply; and the
        // KIND is checked, so a typedef whose listing object is not a
        // `class_typespec` (a `typedef` chain that resolved elsewhere) keeps
        // the fresh mint.
        UHDM::typespec* sh9 = sharedAliasTs(elemType);
        if (sh9 && sh9->UhdmType() == UHDM::uhdmclass_typespec)
            ts = sh9;
        else {
            auto* cts = s.MakeClass_typespec();
            cts->VpiName(ec.name);
            // § classTpTsResolvedNameEverySite87 — the ARRAY-ELEMENT site, and
            // it is THE HEAD of this pass: `REQ m_last_req_buffer[$];` in
            // `uvm_sequencer_param_base`.  golden's element typespec is the
            // class-scope type-parameter GROUP object (named `rsp_type`), ours
            // was this fresh, unlocated mint named for the RESOLVED class
            // (`uvm_sequence_item`).  Same rename as the scalar property one
            // spelling up in makeTypespec; the object stays per-declaration.
            if (declKey9)
                if (auto* dt87 = declKey9->getDeclaredType())
                    if (auto gn87 = classTpGroupDeclName87(*declKey9,
                                                           dt87->getTypeSyntax());
                        !gn87.empty()) {
                        cts->VpiName(gn87);
                        tpGroupTs87.insert(cts);
                    }
            pendingClassTsLink.push_back({cts, &ec});
            ts = cts;
        }
    }
    else if (ec.isStruct()) {
        v = s.MakeStruct_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.isUnpackedUnion() || ec.isPackedUnion()) {
        v = s.MakeUnion_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.kind == SymbolKind::EnumType) {
        v = s.MakeEnum_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.kind == SymbolKind::StringType)
        v = s.MakeString_var();
    // A PREDEFINED-INTEGER element takes its own var class, exactly as
    // makeReturnVar does for a subroutine-local container — an `int unsigned
    // seed_table[string]` element is an int_var, not the bit_var its 2-state
    // integral base would give (BuildUVMPkg uvm_seed_map).
    // § typeParamRetIsRefVar58's ONE EXCLUSION, and it is a MEASURED over-fire
    // this pass caught with mv58.sh before landing: this factory builds the
    // element variable of a CLASS PROPERTY container, and a class property is
    // the one declaration Surelog compiles through ElaborationStep's explicit
    // `Parameter` branch (ElaborationStep.cpp:1885-1900), which RESOLVES the
    // type parameter to its concrete var class instead of falling through to
    // compileVariable's ref_var.  So `protected T queue[$];` in
    // `uvm_queue #(type T=int)` is an int_var in golden — 3 objects on each of
    // the four UVM rows — while the `T`-returning method right below it is a
    // ref_var.  Passing the CANONICAL type keeps the gate off: it is the
    // predefined-integer arm this branch wants and nothing else changes,
    // because every arm reachable from here reads only the canonical type.
    else if (ec.kind == SymbolKind::PredefinedIntegerType) {
        v = makeReturnVar(s, ec);
        // NOTE § classPropElemTsFollowsScalarTd9, THE INTEGER-ATOM HALF, and
        // the object it binds is NOT the listing object the aggregates take:
        // § tdVecNamedClone42's KIND GATE says every ATOM gets a
        // PER-DECLARATION NAMED CLONE that ALIASES the listing object, and
        // golden does exactly that here too —
        //   `uvm_action severity_actions [uvm_severity];`
        //     golden int_typespec (uvm_action) @272:9-272:12 inst=TOP:uvm_pkg
        //     ours   int_typespec ()           @67:3-67:13   inst=<null>
        // where @272:9 is the `int` token of `typedef int uvm_action;`.  Left
        // to itself this arm returns a var with a NULL actual and the caller's
        // `predefIntTypespec` mint (grep § arrayElemTsSignedParented9) makes a
        // bare, UNNAMED object at the property's own span.  The clone carries
        // the alias's name, the typedef's span, the listing object's
        // vpiInstance and vpiTypedefAlias, and — like every other element
        // typespec on this path — `vpiParent` -> its own vpiReg element var.
        // GATE: `declKey9` (the property symbol) must be present, because
        // `tdVecNamedClone42` keys its cache on the declaration; a caller with
        // no key keeps the old mint.  The clone is per (declaration, position)
        // so posKey 0 is the ELEMENT slot and never collides with
        // `assocIndexTs`'s posKey 1 on the same property.
        if (declKey9)
            if (auto* sh9 = sharedAliasTs(elemType))
                if (auto* cl9 = tdVecNamedClone42(elemType, (const void*)declKey9,
                                                  sh9, /*posKey=*/0)) {
                    cl9->VpiParent(v);
                    ts = cl9;
                }
    }
    else if (ec.kind == SymbolKind::ScalarType ||
             ec.kind == SymbolKind::PackedArrayType)
        v = ec.isFourState() ? (UHDM::variables*)s.MakeLogic_var()
                             : (UHDM::variables*)s.MakeBit_var();
    if (!v)
        return nullptr;
    auto* rt = s.MakeRef_typespec();
    rt->VpiParent(v);
    if (ts)
        rt->Actual_typespec(ts);
    v->Typespec(rt);
    return v;
}

// Surelog resolves a class-scope type NAME against the declaring class's own
// datatype map only: it never walks the base chain and never resolves a
// `base_class::T` qualification.  So a property typed by a typedef that lives
// in a BASE class compiles as if the name were unknown, and the element of an
// associative array declared that way lands as a bare `logic_var` with NO
// typespec (BuildUVMPkg: uvm_copier's `recursion_state_e m_recur_states[...]`
// and uvm_printer's `uvm_policy::recursion_state_e m_recur_states[...]`, both
// inherited from uvm_policy — while uvm_comparer's `state_info_t`, declared in
// uvm_comparer itself, resolves and stays a struct_var).  slang resolves all
// three, so the un-seeable ones are degraded here on purpose.
UHDM::variables* UhdmExporter::classAssocElemVar(const Symbol& cp,
                                                 const Type& elemType,
                                                 const ClassType& owner) {
    const Type* named = &elemType;
    if (named->kind == SymbolKind::TypeAlias || named->kind == SymbolKind::EnumType) {
        auto sc = named->getParentScope();
        if (sc && sc->asSymbol().kind == SymbolKind::ClassType &&
            &sc->asSymbol() != (const Symbol*)&owner) {
            (void)cp;
            return s.MakeLogic_var();
        }
    }
    return classElemVar(elemType, &cp);
}

// § fixedClassPropIsArrayVar6, THE ELEMENT FACTORY.  A FIXED-size unpacked
// array reaches four element kinds that no dynamic/queue/assoc class property in
// either corpus ever exercised, so `classElemVar` has no arm for them and would
// hand back null — which in this arm means `noteUnsupported` and the property
// DELETED from the class listing again.  All four are measured, in both the
// class arm (b2/b5 `c`-cells) and its module twin:
//
//   VIRTUAL INTERFACE  -> a BARE `logic_var` with NO `vpiTypespec` AT ALL.  This
//     is § virtualIfacePropIsBareLogicVar6's law one level down: Surelog never
//     models a virtual interface, so `ElaborationStep::makeVar_` falls into its
//     `// default type (fallback)` arm and mints a bare logic_var.  ALL FIVE
//     written spellings are one cell — `virtual w_if.IP`, `virtual w_if`,
//     `virtual interface w_if`, `virtual interface w_if.IP` and a
//     `typedef virtual w_if.IP` name (arm b5 c01..c05) — and so is the 2-D case
//     (c06_vif2d).  THE WITNESS IS SVSwitch Environemnt.sv:17.
//   chandle   -> `chandle_var`, also with NO typespec (b2 c23_chandle).
//   shortreal -> `short_real_var`, also with NO typespec (b2 c16_sreal).  `real`
//     is NOT in this group: golden gives it a `real_typespec` spanned at the
//     `real` keyword (b2 c15_real), which is what the write-phase mint produces,
//     so it goes through the typespec path like every other kind.
//
// HOW THE THREE NO-TYPESPEC KINDS ACTUALLY SUPPRESS THE TYPESPEC, since there is
// no flag for it: they are returned with NO `ref_typespec` attached at all, and
// the caller's shared line is `if (auto* rrt = reg->Typespec(); rrt && !...)`, so
// a null `vpiTypespec` skips both the `predefIntTypespec` arm and the write-phase
// `pendingClassPropTs` mint on its own.  A flag would have been a second way to
// say the same thing and could have drifted from it.
UHDM::variables* UhdmExporter::classFixedElemVar6(const Symbol& cp,
                                                  const Type& elemType,
                                                  const ClassType& owner) {
    auto& ec = elemType.getCanonicalType();
    if (ec.kind == SymbolKind::VirtualInterfaceType)
        return s.MakeLogic_var();
    if (ec.kind == SymbolKind::CHandleType)
        return s.MakeChandle_var();
    if (ec.kind == SymbolKind::FloatingType) {
        auto fk = ec.as<FloatingType>().floatKind;
        if (fk == FloatingType::ShortReal)
            return s.MakeShort_real_var();
        // `real` (and `realtime`, which slang canonicalises to it) keeps the
        // typespec path; the ref_typespec is added by the caller's shared code.
        auto* rv = s.MakeReal_var();
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(rv);
        rv->Typespec(rt);
        return rv;
    }
    return classAssocElemVar(cp, elemType, owner);
}

UHDM::typespec* UhdmExporter::assocIndexTs(const Type& idx, const Symbol& sym) {
    auto& ic = idx.getCanonicalType();
    if (ic.kind == SymbolKind::StringType)
        return s.MakeString_typespec();
    if (ic.kind == SymbolKind::ClassType) {
        auto* cts = s.MakeClass_typespec();
        cts->VpiName(ic.name);
        pendingClassTsLink.push_back({cts, &ic});
        return cts;
    }
    if (auto* sh = sharedAliasTs(idx)) {
        // § arrayElemTdClone42, the INDEX half — pass 41's open residue, and
        // its answer was never "the other registry".  Golden's index object
        // for a PACKED-VECTOR typedef index is a bare-named PER-DECLARATION
        // CLONE (`uvm_reg_addr_t`), not either listing object: preferring
        // `typedefTs` over `pkgTopTypedefTs` here was implemented and measured
        // to change NOTHING (pass 41), because both registries hold the SAME
        // package-qualified object.  The bare twin that golden's 3 rows bind
        // is a clone of exactly the kind the ELEMENT position needs — one law,
        // both halves.  Enum and struct typedef indices keep the listing
        // object: golden spells those `<pkg>::<alias>` too, which is why
        // tdVecNamedClone42's kind gate excludes them (§ tdAtomKindGate43
        // measures that gate per KIND: every ATOM clones, the aggregates and a
        // CHAINED typedef bind the listing object).
        if (auto* cl = tdVecNamedClone42(idx, (const void*)&sym, sh,
                                        /*posKey=*/1))
            return cl;
        return sh;
    }
    if (ic.kind == SymbolKind::PredefinedIntegerType)
        return assocIndexSignedAtom63(ic, predefIntTypespec(ic, sym));
    if (ic.isIntegral())
        return s.MakeLogic_typespec();
    return nullptr;
}

// § assocIndexTsSigned63 — the INDEX TYPESPEC of an ASSOCIATIVE array carries
// `vpiSigned` = THE INDEX TYPE'S RESOLVED SIGNEDNESS, and carries NOTHING ELSE.
//
// GATE: `ic.isSigned()` on the CANONICAL index type, and the kind switch.  That
// is the WHOLE gate — no scope test, no view test, no typedef test, no
// declarator test — and each of those was measured rather than assumed
// (tools/probe/r10uvm63repro, arms b1..b4, 4 scopes x 21 index kinds):
//
//   CLASS property (b1) / MODULE variable (b2) / PACKAGE variable (b4) —
//     golden's grid is CELL-FOR-CELL IDENTICAL in all three.  `integer` `int`
//     `byte` `shortint` `longint` and their explicit `signed` spellings read
//     `vpiSigned:1`; `time`, every `unsigned` spelling, `bit`, `logic`, `reg`,
//     unsigned packed vectors and `string` read ABSENT.  There is no scope this
//     law is bound to, which is why the gate has no scope term.
//   OUTER slot (`vpiIndexTypespec`) and INNER slot (the `STRING:associative`
//     marker constant's own typespec, dimensions 2..N of `[string][integer]`)
//     read THE SAME (b3 f10..f13 / g10..g13).  The law is a property of the
//     INDEX POSITION, not of the vpiIndexTypespec SLOT, so it belongs in this
//     shared factory and not at one call site.
//
// **THE `vpiParent` HALF OF § arrayElemTsSignedParented9 DOES NOT CARRY OVER,
// AND THAT IS THE PASS'S SHARPEST MEASUREMENT.**  The ELEMENT typespec of a
// dynamic/queue/assoc class property takes BOTH `vpiParent` -> its element var
// AND `vpiSigned`; the INDEX typespec takes `vpiSigned` ALONE.  Golden's index
// object is UNPARENTED in every cell of b1, b2 and b3's declaration-spanned
// rows — 21 + 21 + 8 cells, zero exceptions.  The only index cells where golden
// prints `vpiParent` are the ones whose object is a TYPEDEF's own listing
// object (b3 `?line17`..`?line23`, b4 `t01`..`t05`), where the parent is the
// typedef declaration and has nothing to do with the index position.  Stamping
// `VpiParent` here would have been a MEASURED over-fire on every cell this pass
// clears, transcribed from a sibling law that does not apply.
//
// NOR IS THERE A TYPEDEF GATE, and that too is a measured difference from § 9.
// § arrayElemTsSignedParented9 gates on `cp.getType().kind != TypeAlias`
// (clause (a) of § arrayVarSignedWritten8) because golden's object for a
// whole-array typedef is a bare `array_typespec` carrying neither field.  The
// index position has no such cell: for `typedef int T[integer]; T q;` golden's
// index object is the TYPEDEF's `integer_typespec`, and it carries
// `vpiSigned:1` (arm b4 `?line32`).  A typedef gate here would suppress a flag
// golden emits.  A typedef'd INDEX (`T q[my_int_t]`) never reaches this arm at
// all — `sharedAliasTs` / § arrayElemTdClone42 returns above it.
//
// WHERE THE CLAUSE CAME FROM: it is TRANSCRIBED, not invented.  The
// module/interface instance-level writer (`src/TypeEmit.cpp`, grep
// `assocIndexTs and assocIndexTs does not`) has carried exactly this switch
// since pass 43, and its own comment records that `assocIndexTs` lacked it —
// that note is what this pass measured and acted on.  `src/ParamEmit.cpp`'s
// § assocIdxSiteFive44 gets the same call, so all THREE producers of the index
// rule now agree; `grep -rn 'assocIndexSignedAtom63' src/ include/` names them.
//
// DIRECTION: ADD ONLY.  The helper mints nothing, deletes nothing, re-parents
// nothing and moves no span; the only dump-line shape it can produce is
// `|vpiSigned:1`.  A null typespec is passed through untouched so the caller's
// `if (its)` guards keep their meaning.
//
// `time` IS DOUBLY EXCLUDED, on purpose: `isSigned()` is false for it AND the
// switch has no `time_typespec` case, matching `makeTypespec`.  Golden reads
// ABSENT for `[time]` in all four arms (b1 c06 / b2 m06 / b4 p06).
UHDM::typespec* UhdmExporter::assocIndexSignedAtom63(const Type& ic,
                                                     UHDM::typespec* ts) {
    if (!ts || !ic.isSigned())
        return ts;
    switch (ts->UhdmType()) {
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
        default:
            break;
    }
    return ts;
}

// The associative dimensions of one class property.  The OUTERMOST index type
// becomes the array_typespec's vpiIndexTypespec; every INNER one stays in the
// raw marker form Surelog's range compiler produced — a range whose Left_expr
// is a `UINT:0` constant and whose Right_expr is a `STRING:associative`
// constant carrying that dimension's index typespec — listed on the array_var
// itself.  The marker constants are spanned only when the index type was
// written as a NAME (Surelog's ref_obj arm populates core members; its
// keyword-type arm does not), so `[uvm_object]` carries a span and `[string]`
// does not; the enclosing range is spanned either way.
void UhdmExporter::emitAssocDims(const Symbol& cp,
                                 const std::vector<const Type*>& idx,
                                 UHDM::array_var* av, UHDM::array_typespec* ats) {
    if (idx.empty())
        return;
    // The declarator's written dimensions, so each index typespec/range can be
    // spanned at the `[...]` it came from.
    std::vector<const syntax::VariableDimensionSyntax*> dims;
    if (auto dsyn = cp.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
        for (auto d : dsyn->as<syntax::DeclaratorSyntax>().dimensions)
            dims.push_back(d);
    auto dimAt = [&](size_t i) -> const syntax::VariableDimensionSyntax* {
        return i < dims.size() ? dims[i] : nullptr;
    };
    // Whether dimension i was written as a type NAME rather than a keyword.
    auto namedIdx = [&](size_t i) {
        auto* d = dimAt(i);
        if (!d || !d->specifier ||
            d->specifier->kind != syntax::SyntaxKind::RangeDimensionSpecifier)
            return false;
        auto& sel = *d->specifier->as<syntax::RangeDimensionSpecifierSyntax>().selector;
        if (sel.kind != syntax::SyntaxKind::BitSelect)
            return false;
        auto* e = sel.as<syntax::BitSelectSyntax>().expr.get();
        return e && (e->kind == syntax::SyntaxKind::IdentifierName ||
                     e->kind == syntax::SyntaxKind::ScopedName);
    };
    // The `[0 : <name>-1]` SIZE range Surelog compiles for a dimension whose
    // bracket names a PARAMETER — § assocTypeParamDimIsStaticSize51 below.  The
    // shape is § assocIoRange9's (src/TaskFuncEmit.cpp, `grep -n assocIoRange9`)
    // with one addition golden requires here and not there: the ref_obj carries
    // a vpiFullName of `<array fullname>::<name>`.
    auto tpSizeRange51 = [&](size_t i) -> UHDM::range* {
        const syntax::ExpressionSyntax* sx = nullptr;
        if (auto* d = dimAt(i); d && d->specifier)
            if (auto* rd =
                    d->specifier->as_if<syntax::RangeDimensionSpecifierSyntax>())
                if (rd->selector->kind == syntax::SyntaxKind::BitSelect)
                    sx = rd->selector->as<syntax::BitSelectSyntax>().expr.get();
        auto* r = s.MakeRange();
        r->VpiParent(av);
        if (sx)
            setLoc(r, sx->sourceRange());
        auto* lc = s.MakeConstant();
        lc->VpiParent(r);
        lc->VpiDecompile("0");
        lc->VpiSize(64);
        lc->VpiValue("UINT:0");
        lc->VpiConstType(vpiUIntConst);
        r->Left_expr(lc);
        auto* op = s.MakeOperation();
        op->VpiParent(r);
        op->VpiOpType(vpiSubOp);
        auto* ops = s.MakeAnyVec();
        auto* ro = s.MakeRef_obj();
        ro->VpiParent(op);
        std::string nm;
        if (sx) {
            setLoc(op, sx->sourceRange());
            setLoc(ro, sx->sourceRange());
            if (sx->kind == syntax::SyntaxKind::IdentifierName)
                nm = std::string(
                    sx->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            else {
                nm = sx->toString();
                while (!nm.empty() && std::isspace((unsigned char)nm.front()))
                    nm.erase(nm.begin());
                while (!nm.empty() && std::isspace((unsigned char)nm.back()))
                    nm.pop_back();
            }
        }
        ro->VpiName(nm);
        if (!nm.empty() && !av->VpiFullName().empty())
            ro->VpiFullName(std::string(av->VpiFullName()) + "::" + nm);
        ops->push_back(ro);
        auto* one = s.MakeConstant();
        one->VpiValue("INT:1");
        one->VpiConstType(vpiIntConst);
        one->VpiSize(64);
        ops->push_back(one);
        op->Operands(ops);
        r->Right_expr(op);
        return r;
    };
    // NOTE § assocTypeParamDimIsStaticSize51 — LAW 2, and the law that actually
    // CONVERTS the four UVM tests.  Direction: RESHAPE (assoc -> static).
    //
    // Gate: the declaration has EXACTLY ONE written associative dimension and
    // its index type is a type parameter (assocIdxIsTypeParam51).  Then golden's
    // array_var is a vpiStaticArray (1) carrying ONE vpiRange `[0 : <name>-1]`
    // and a BARE array_typespec — Surelog never saw an associative array at all,
    // because its dimension compiler resolved the bracket name in the PARAMETER
    // map and compiled `[KEY]` as a SIZE EXPRESSION.
    //
    // WHY THE ONE-DIMENSION HALF OF THE GATE IS NECESSARY, measured (arm a2,
    // LHS golden / RHS ours): a MIXED multi-dimension declaration is a THIRD
    // shape, not this one.  `T ii_pool[string][KEY]` -> golden array_var
    // vpiArrayType 3 (from dim 0) with the `[0:KEY-1]` range beside it;
    // `T oo_pool[KEY][string]` -> golden array_var vpiArrayType 3 with NO range
    // and a NESTED array_typespec pair (outer arrayType 3 + vpiElemTypespec ->
    // inner holding the range).  Widening this law to those would be wider than
    // the evidence; they stay residue R2.  The corpus witness
    // (uvm_pool.svh:42 `protected T pool[KEY];`) is single-dimension.
    //
    // WITNESS, SimpleUVM `default`, uvm_pkg::uvm_pool::pool — the uhdm-cmp head
    // of all seven comparable UVM rows once LAW 1 removed the index typespec:
    //   field          LHS golden            RHS ours before      RHS ours after
    //   vpiArrayType   1 (static)            3 (assoc)            1
    //   vpiRange       range 42:20-42:23     ABSENT               present, equal
    //                  [0 : KEY-1]
    // Both fields are read by `array_var::Compare`
    // (UHDM generated/src/array_var.cpp, `VpiArrayType()` then `Ranges()`),
    // which is exactly why LAW 1 alone moved the head here instead of clearing
    // it.
    if (idx[0] && assocIdxIsTypeParam51(*idx[0]) && idx.size() == 1) {
        av->VpiArrayType(vpiStaticArray);
        auto* rs51 = s.MakeRangeVec();
        rs51->push_back(tpSizeRange51(0));
        av->Ranges(rs51);
        return;
    }
    // NOTE § assocIdxTypeParamNoIndexTs51 — SITE 1 of 3 (the CLASS-PROPERTY
    // site, and the one the corpus head lives on).  Direction: SUPPRESS.  Gate:
    // assocIdxIsTypeParam51(*idx[0]) — the OUTERMOST index type was written as
    // a TYPE PARAMETER.  Predicate and its refutations: src/EmitHelpers.h,
    // `grep -n assocIdxIsTypeParam51`.
    //
    // Witness (uvm-1.2 base/uvm_pool.svh:42 `protected T pool[KEY];` in
    // `class uvm_pool #(type KEY=int, T=uvm_void)`; LHS golden(Surelog) /
    // RHS ours, SimpleUVM default):
    //   golden `array_typespec` for uvm_pkg::uvm_pool::pool is BARE
    //   ours had `vpiIndexTypespec -> ref_typespec -> int_typespec 42:20-42:23`
    //     (the `KEY` TOKEN — KEY resolved to its `int` default)
    // That extra ref_typespec WAS the single uhdm-cmp head of all seven
    // comparable UVM rows.  The typespec is not merely unlinked here, it is
    // never MINTED: an orphan would still join the design's typespec arena and
    // `design::Compare` walks `Typespecs()` as a size-checked vector.
    //
    // The INNER dimensions below are deliberately NOT gated: golden does not
    // suppress a typespec there, it emits a WHOLE DIFFERENT SHAPE (a static
    // `[0:<name>-1]` range instead of an associative marker constant — arm a2
    // `T ii_pool[string][KEY]`), so a suppression there would be wider than the
    // evidence.  Residue R2.
    if (idx[0] && !assocIdxIsTypeParam51(*idx[0])) {
        if (auto* its = assocIndexTs(*idx[0], cp)) {
            // § sharedAliasNoStamp41 — the pass-40 hazard is INHERITED from
            // here: a TYPEDEF-NAME index (`uvm_reg_addr_t`, t58a's `[b8]`)
            // resolves to the ONE shared typespec object every user of that
            // typedef points at, and re-spanning it at THIS property's index
            // bracket drags every unrelated declaration of the typedef's type
            // along.  Golden uses the shared object as it stands: t58a
            // `pkb::oobb::pmapb`'s vpiIndexTypespec is `bit_typespec (b8)
            // @31:11`, the typedef's own span.  MEASURED, not inferred — LAW A
            // alone left 10 `b8` + 13 `pkb::b8` + 6 `myint` occurrences
            // re-spanned to 41:14 / 42:15 by this very site.
            // ...and § arrayElemTdClone42's clone is skipped for the same
            // reason one predicate wider: it is not registry-shared, but golden
            // keeps it at the TYPEDEF's span and it is shared with the
            // array_var's element `reg`.
            if (auto* d = dimAt(0); d && !isSharedAliasTs(*idx[0], its) &&
                                    !isTdVecClone42(its)) {
                auto dr = d->sourceRange();
                if (auto* rd = d->specifier
                                   ? d->specifier
                                         ->as_if<syntax::RangeDimensionSpecifierSyntax>()
                                   : nullptr)
                    setLoc(its, rd->selector->sourceRange());
                else
                    setLoc(its, SourceRange(dr.start() + 1, dr.end() - 1));
            }
            auto* irt = s.MakeRef_typespec();
            irt->VpiParent(ats);
            irt->Actual_typespec(its);
            ats->Index_typespec(irt);
        }
    }
    if (idx.size() < 2)
        return;
    auto* rs = s.MakeRangeVec();
    for (size_t i = 1; i < idx.size(); i++) {
        auto* r = s.MakeRange();
        r->VpiParent(av);
        auto* lc = s.MakeConstant();
        lc->VpiConstType(vpiUIntConst);
        lc->VpiSize(64);
        lc->VpiValue("UINT:0");
        lc->VpiDecompile("0");
        lc->VpiParent(r);
        r->Left_expr(lc);
        auto* rc = s.MakeConstant();
        rc->VpiConstType(vpiStringConst);
        rc->VpiSize(0);
        rc->VpiValue("STRING:associative");
        rc->VpiDecompile("associative");
        rc->VpiParent(r);
        r->Right_expr(rc);
        if (idx[i]) {
            if (auto* its = assocIndexTs(*idx[i], cp)) {
                // § sharedAliasNoStamp41 — same invariant, INNER dimension.
                if (auto* d = dimAt(i); d && !isSharedAliasTs(*idx[i], its) &&
                                        !isTdVecClone42(its))
                    if (auto* rd = d->specifier
                                       ? d->specifier->as_if<
                                             syntax::RangeDimensionSpecifierSyntax>()
                                       : nullptr)
                        setLoc(its, rd->selector->sourceRange());
                auto* rrt = s.MakeRef_typespec();
                rrt->VpiParent(rc);
                rrt->Actual_typespec(its);
                rc->Typespec(rrt);
            }
        }
        if (auto* d = dimAt(i)) {
            setLoc(r, d->sourceRange());
            if (namedIdx(i)) {
                auto st = d->sourceRange().start();
                setLoc(lc, SourceRange(st, st + 1));
                setLoc(rc, SourceRange(st, st + 1));
            }
        }
        rs->push_back(r);
    }
    av->Ranges(rs);
}

// Class-scope parameters. Surelog compiles them with Reduce::No, so only a
// LITERAL initializer becomes a value: such a parameter carries the folded
// value plus a synthesized int_typespec spanning its whole DECLARATION, shared
// by every declarator of that declaration and by their RHS constants. A
// parameter whose RHS is an expression (5 * p1) keeps neither. The param_assign
// RHS is built from SYNTAX (unfolded), matching Surelog's un-reduced model.
void UhdmExporter::emitClassParameters(const ClassType& cls, UHDM::class_defn* cd,
                                       const std::string& fullName) {
    auto* params = s.MakeAnyVec();
    auto* pas = s.MakeParam_assignVec();
    // The `parameter <...>` declaration node a declarator belongs to (its span
    // excludes the trailing `;`, which the class-property wrapper would add).
    auto declNodeOf = [](const Symbol& sym) -> const syntax::SyntaxNode* {
        for (auto p = sym.getSyntax(); p; p = p->parent)
            if (p->kind == syntax::SyntaxKind::ParameterDeclaration ||
                p->kind == syntax::SyntaxKind::TypeParameterDeclaration)
                return p;
        return nullptr;
    };
    for (auto& mem : cls.members()) {
        if (mem.kind == SymbolKind::TypeParameter) {
            auto& tps = mem.as<TypeParameterSymbol>();
            auto* tp = s.MakeType_parameter();
            tp->VpiName(tps.name);
            tp->VpiFullName(fullName + "::" + std::string(tps.name));
            tp->VpiParent(cd);
            setLoc(tp, nameSpan(tps.location, tps.name));
            auto* rt = s.MakeRef_typespec();
            rt->VpiParent(tp);
            auto& dt = tps.targetType.getType();
            auto* dsyn = tps.targetType.getTypeSyntax();
            UHDM::typespec* its = nullptr;
            if (auto& dct = dt.getCanonicalType(); dct.kind == SymbolKind::ClassType) {
                auto* cts = s.MakeClass_typespec();
                // § classTpTsResolvedNameEverySite87 — this line used to be
                // `rawText(dsyn->sourceRange())`, i.e. the WRITTEN TEXT
                // verbatim, and golden never writes it verbatim: it strips the
                // `#(...)`, it resolves a spelling that is itself a type
                // parameter, and a group with a typedef wins over both.  Arm a3
                // reads the four spellings; the SeqDriver census reads the same
                // four in UVM (`uvm_visitor_adapter`, `uvm_in_order_comparator`,
                // `uvm_sequencer`'s `type RSP = REQ`, and the `#(RSP)`
                // specialization of `uvm_sequencer_analysis_fifo`).
                cts->VpiName(classTpTsName87(cls, dsyn, dct));
                cts->VpiParent(tp);
                if (dsyn)
                    setLoc(cts, dsyn->sourceRange());
                pendingClassTsLink.push_back({cts, &dct});
                its = cts;
            }
            // § classTpTdGroupNonClsRootShared91, site A.  A type parameter
            // in a default-chain group that HAS a winning typedef binds the
            // group's ONE object — the object built from the CHAIN ROOT's own
            // class-header default, named for the winner.  This is 18 of the
            // 24 cells the corpus census names (the six `uvm_*_imp` classes'
            // `IMP` / `REQ_IMP` / `RSP_IMP`, golden `this_rsp_type` where ours
            // read ANONYMOUS).  It does NOT re-parent: golden's object hangs
            // off the class_defn (it is the vpiTypedef LISTING entry), which
            // `emitClassTypedefs` sets.
            else if (auto* g91 = classTpGroupNcTs91(cls, mem))
                its = g91;
            else {
                its = makeTypespec(mem, dsyn);
                if (its)
                    its->VpiParent(tp);
            }
            rt->Actual_typespec(its);
            tp->Typespec(rt);
            params->push_back(tp);
            continue;
        }
        if (mem.kind != SymbolKind::Parameter)
            continue;
        auto& ps = mem.as<ParameterSymbol>();
        auto* pv = s.MakeParameter();
        pv->VpiName(ps.name);
        pv->VpiFullName(fullName + "::" + std::string(ps.name));
        pv->VpiParent(cd);
        setLoc(pv, nameSpan(ps.location, ps.name));
        // Class parameters are localparams by LRM, but Surelog reports
        // vpiLocalParam off the WRITTEN keyword (paLocal_parameter_declaration).
        if (auto* dn0 = declNodeOf(ps))
            if (auto* pd0 = dn0->as_if<syntax::ParameterDeclarationBaseSyntax>();
                pd0 && pd0->keyword.kind == parsing::TokenKind::LocalParamKeyword)
                pv->VpiLocalParam(true);
        params->push_back(pv);
        // RHS from syntax (Surelog does not reduce class parameters).
        const syntax::ExpressionSyntax* rhsSyn = nullptr;
        if (auto dsyn = ps.getSyntax())
            if (auto* dcl = dsyn->as_if<syntax::DeclaratorSyntax>();
                dcl && dcl->initializer)
                rhsSyn = dcl->initializer->expr;
        if (!rhsSyn)
            continue;
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(cd);
        setLoc(pa, SourceRange(ps.location, rhsSyn->sourceRange().end()));
        auto* rhs = emitSyntaxExpr(*rhsSyn, pa);
        if (!rhs) {
            pas->push_back(pa);
            pa->Lhs(pv);
            continue;
        }
        pa->Rhs((UHDM::expr*)rhs);
        pa->Lhs(pv);
        pas->push_back(pa);
        // A literal RHS folds: the parameter takes its value, and both the
        // parameter and the constant share the declaration's int_typespec.
        if (rhs->UhdmType() != UHDM::uhdmconstant)
            continue;
        auto* rc = (UHDM::constant*)rhs;
        pv->VpiValue(rc->VpiValue());
        // ONE int_typespec per DECLARATOR (three declarators on one
        // `parameter` line give three objects), spanning the whole declaration
        // and shared with that declarator's own fold constant. A SIZED literal
        // RHS also gives it the literal's packed range.
        auto* dn = declNodeOf(ps);
        UHDM::typespec* dts = nullptr;
        // NOTE § classParamWrittenTypeTypespec54 — a class value parameter with
        // an EXPLICITLY WRITTEN data type takes THAT type's typespec, spanning
        // the DATA TYPE SYNTAX; only an IMPLICIT (untyped) parameter takes the
        // int_typespec spanning the WHOLE DECLARATION that this site used to
        // build unconditionally.  DIRECTION: RESHAPE (kind + span).
        // WITNESS — this was the cmp HEAD of all seven comparable UVM rows once
        // § classNestedClassTdGroupNoAnchor54 landed:
        //   LHS golden(BuildUVMPkg): string_typespec, line:13652:48-13652:54
        //     |vpiParent parameter (uvm_pkg::uvm_object_registry::Tname)
        //   RHS ours: int_typespec, line:13652:48-13652:72
        // (uvm-1.2 spells the same class at uvm_registry.svh:189, and both the
        // parameter and its fold CONSTANT share the one object on both sides.)
        // GATE, proved necessary three ways in tools/probe/r10uvm54repro:
        //   * the IMPLICIT arm is UNTOUCHED — `#(P = 3)` keeps the
        //     whole-declaration int_typespec, which is what the live
        //     `ClassParamAsParam` / `ClassTypeParam` canaries carry;
        //   * only `string` and a PredefinedIntegerType `int` are converted;
        //     every other written type falls through to the old shape rather
        //     than guessing a kind this pass has not measured (a `byte`/`bit
        //     [7:0]` class parameter is recorded as residue, not fixed);
        //   * the SIZED-literal packed range below stays on the implicit arm
        //     only, since golden's written-type span has no literal range.
        // BuildUVMPkg census (clsparam.py kinds): golden 5 string_typespec +
        // 2 int_typespec of 7 class parameters; ours before this law 7
        // int_typespec, and every one of the 7 spans was the whole declaration.
        {
            const syntax::DataTypeSyntax* wtSyn54 = nullptr;
            if (const DeclaredType* dt54 = ps.getDeclaredType())
                wtSyn54 = dt54->getTypeSyntax();
            if (wtSyn54 &&
                wtSyn54->kind != syntax::SyntaxKind::ImplicitType) {
                auto& pct54 = ps.getType().getCanonicalType();
                UHDM::typespec* wts54 = nullptr;
                if (pct54.kind == SymbolKind::StringType)
                    wts54 = s.MakeString_typespec();
                else if (pct54.kind == SymbolKind::PredefinedIntegerType &&
                         pct54.as<PredefinedIntegerType>().integerKind ==
                             PredefinedIntegerType::Int)
                    wts54 = s.MakeInt_typespec();
                if (wts54) {
                    setLoc(wts54, wtSyn54->sourceRange());
                    dts = wts54;
                }
            }
        }
        if (!dts) {
            auto* its = s.MakeInt_typespec();
            if (dn)
                setLoc(its, dn->sourceRange());
            if (rhsSyn->kind == syntax::SyntaxKind::IntegerVectorExpression) {
                std::string raw0(rawText(rhsSyn->sourceRange()));
                auto tick0 = raw0.find('\'');
                int32_t sz0 = tick0 != std::string::npos && tick0 > 0
                                  ? atoi(raw0.substr(0, tick0).c_str())
                                  : 0;
                if (sz0 > 0) {
                    auto mk0 = [&](int64_t v) {
                        auto* c0 = s.MakeConstant();
                        c0->VpiValue("INT:" + std::to_string(v));
                        return c0;
                    };
                    auto* rg0 = s.MakeRange();
                    rg0->VpiParent(its);
                    rg0->Left_expr(mk0(sz0 - 1));
                    rg0->Right_expr(mk0(0));
                    auto* rgv0 = s.MakeRangeVec();
                    rgv0->push_back(rg0);
                    its->Ranges(rgv0);
                }
            }
            dts = its;
        }
        auto* prt = s.MakeRef_typespec();
        prt->VpiParent(pv);
        prt->Actual_typespec(dts);
        pv->Typespec(prt);
        auto* crt = s.MakeRef_typespec();
        crt->VpiParent(rc);
        crt->Actual_typespec(dts);
        rc->Typespec(crt);
    }
    if (!params->empty())
        cd->Parameters(params);
    if (!pas->empty())
        cd->Param_assigns(pas);
}

// PACKAGE-scope class definitions: emitted onto the ELABORATED package view
// only, name-sorted (Surelog's multimap<name, ClassDefinition*>).
void UhdmExporter::emitPackageClasses(const PackageSymbol& pkg, UHDM::package* up,
                                      const std::string& prefix) {
    std::vector<std::pair<std::string, const ClassType*>> pcls;
    for (auto& mem : pkg.members()) {
        if (mem.kind == SymbolKind::ClassType)
            pcls.emplace_back(std::string(mem.name), &mem.as<ClassType>());
        else if (mem.kind == SymbolKind::GenericClassDef) {
            if (auto* dsp = mem.as<GenericClassDefSymbol>().getDefaultSpecialization(pkg);
                dsp && dsp->kind == SymbolKind::ClassType)
                pcls.emplace_back(std::string(mem.name), &dsp->as<ClassType>());
        }
    }
    if (pcls.empty())
        return;
    std::stable_sort(pcls.begin(), pcls.end(),
                     [](auto& a, auto& b) { return a.first < b.first; });
    auto* cds = s.MakeClass_defnVec();
    for (auto& [nm, c] : pcls)
        cds->push_back(emitClassDefn(*c, nm, prefix + nm, up));
    up->Class_defns(cds);
}

// The deferred `extends` pass. Surelog binds base classes by walking the
// design-wide name-sorted class map (TestbenchElaboration::bindBaseClasses_),
// so vpiDerivedClasses lists derived classes in NAME order. Two shapes:
//   extends <class>      -> extends parented at the derived class_defn, the
//                           class_typespec named/located at the written base
//                           name, and the base gains a vpiDerivedClasses entry.
//   extends <typeparam>  -> extends has NO vpiParent, the class_typespec is
//                           loc-less and named after the parameter, its
//                           vpiClassDefn copied from the type_parameter's own
//                           class_typespec, and the base gains NO derived entry.
void UhdmExporter::drainPendingExtends() {
    for (auto& [cts, ty] : pendingClassTsLink) {
        if (cts->Class_defn())
            continue;
        if (auto* cd9 = classDefnFor(*ty))
            cts->Class_defn(cd9);
    }
    pendingClassTsLink.clear();
    for (auto& pp : pendingClassTsPa) {
        if (pp.pa->Lhs())
            continue;
        if (auto* cd9 = classDefnFor(*pp.cls); cd9 && cd9->Parameters())
            for (auto* p9 : *cd9->Parameters())
                if (p9->VpiName() == pp.paramName) {
                    pp.pa->Lhs(p9);
                    break;
                }
    }
    pendingClassTsPa.clear();
    auto pend = pendingExtends;
    pendingExtends.clear();
    std::stable_sort(pend.begin(), pend.end(), [](const PendingExtends& a,
                                                  const PendingExtends& b) {
        return a.cls->name < b.cls->name;
    });
    for (auto& pe : pend) {
        auto* base = pe.cls->getBaseClass();
        if (!base)
            continue;
        // The base name AS WRITTEN (Surelog names the class_typespec after the
        // extends-clause token, not after the resolved class).
        std::string written;
        const syntax::SyntaxNode* nameSyn = nullptr;
        SourceRange nameRange;
        if (auto syn = pe.cls->getSyntax();
            syn && syn->kind == syntax::SyntaxKind::ClassDeclaration)
            if (auto* ec = syn->as<syntax::ClassDeclarationSyntax>().extendsClause) {
                nameSyn = ec->baseName;
                // A PARAMETERIZED base (`extends resource_db#(T)`) names and
                // spans only the class IDENTIFIER — Surelog drops the
                // parameter assignment from both (ClassParamAsParam).
                if (auto* cn = nameSyn->as_if<syntax::ClassNameSyntax>()) {
                    written = std::string(cn->identifier.valueText());
                    nameRange = cn->identifier.range();
                }
                else {
                    written = std::string(rawText(nameSyn->sourceRange()));
                    nameRange = nameSyn->sourceRange();
                }
            }
        // `extends IF` where IF is one of this class's own type parameters.
        const Symbol* tpSym = nullptr;
        if (!written.empty())
            for (auto& mem : pe.cls->members())
                if (mem.kind == SymbolKind::TypeParameter && mem.name == written) {
                    tpSym = &mem;
                    break;
                }
        auto* ext = s.MakeExtends();
        auto* rt = s.MakeRef_typespec();
        auto* cts = s.MakeClass_typespec();
        rt->VpiParent(ext);
        rt->Actual_typespec(cts);
        ext->Class_typespec(rt);
        cts->VpiName(written.empty() ? std::string(base->name) : written);
        auto& bct = base->getCanonicalType();
        // A SPECIALIZED base (`extends uvm_port_base #(IF)`) resolves to a
        // slang specialization symbol, but Surelog compiles a parameterized
        // class ONCE and every derived class registers on that single generic
        // class_defn — so route through classDefnFor, which falls back to the
        // generic, rather than the exact-symbol map (BuildUVMPkg:
        // uvm_port_base collects 86 derived classes, all through `#(...)`).
        if (auto* bcd = classDefnFor(bct))
            cts->Class_defn(bcd);
        if (nameSyn)
            setLoc(ext, nameRange);
        if (!tpSym) {
            // The class-bound branch: the extends is parented, the typespec
            // located, and the base collects the derived class.
            ext->VpiParent(pe.cd);
            if (nameSyn)
                setLoc(cts, nameRange);
            if (auto* baseCd = (UHDM::class_defn*)cts->Class_defn()) {
                auto* der = baseCd->Deriveds();
                if (!der) {
                    baseCd->Deriveds(s.MakeClass_defnVec());
                    der = baseCd->Deriveds();
                }
                der->push_back(pe.cd);
            }
            // A base class named through the enclosing package's WILDCARD
            // import also lists that typedef's shared import clone in the
            // DERIVING class's own Typespecs — the package import-listing
            // rule applied to the scope that actually resolved the name
            // (ClassExtends: `class c2 extends c3` inside p2 lists p1::c3).
            if (!written.empty())
                if (auto* sc9 = pe.cls->getParentScope();
                    sc9 && sc9->asSymbol().kind == SymbolKind::Package)
                    for (auto& im9 : sc9->members()) {
                        if (im9.kind != SymbolKind::WildcardImport)
                            continue;
                        auto* ip9 = im9.as<WildcardImportSymbol>().getPackage();
                        if (!ip9)
                            continue;
                        for (auto& tm9 : ip9->members()) {
                            if (tm9.kind != SymbolKind::TypeAlias ||
                                tm9.name != written)
                                continue;
                            auto ic9 = pkgImportCloneTs.find(&tm9);
                            if (ic9 == pkgImportCloneTs.end())
                                continue;
                            auto* tv9 = pe.cd->Typespecs();
                            if (!tv9) {
                                pe.cd->Typespecs(s.MakeTypespecVec());
                                tv9 = pe.cd->Typespecs();
                            }
                            if (std::find(tv9->begin(), tv9->end(),
                                          ic9->second) == tv9->end())
                                tv9->push_back(ic9->second);
                        }
                    }
        }
        pe.cd->Extends(ext);
    }
}

// A specialization's class_defn: Surelog compiles a parameterized class ONCE
// (from its default specialization), so every slang specialization symbol of
// the same generic maps onto that one object.
UHDM::class_defn* UhdmExporter::classDefnFor(const Type& ct) {
    if (auto it = classDefnMap.find(&ct); it != classDefnMap.end())
        return it->second;
    if (ct.kind == SymbolKind::ClassType)
        if (auto* gc = ct.as<ClassType>().genericClass)
            if (auto git = genericDefnMap.find(gc); git != genericDefnMap.end())
                return git->second;
    // NOTE § builtinClassTsLinksBuiltinFileDefn7 — DIRECTION: ADD an EDGE.
    // GATE: `mailbox` / `semaphore` / `process` resolve, in slang, to a
    // specialization of a generic class slang synthesizes in its OWN built-in
    // `std` package, which lives in no compilation unit; the class_defn we emit
    // for the same name comes from the injected <cwd>/builtin.sv text.  The two
    // symbols are unrelated, so the SHORT NAME is the only bridge there is.
    // NECESSARY, not cosmetic: `class_typespec::Compare` reads vpiClassDefn, and
    // this missing scalar POINTER was SVSwitch's cmp head -- `BaseClass.h`'s
    // scalar SafeCompare prints a missing POINTER as `RHS: <null>` on the
    // POINTEE, i.e. as if the whole class_defn OBJECT were absent (it is not; we
    // emit all ten of SVSwitch's).
    // MEASURED both sides: arm c1_builtins cells a1_mb / a2_sem / a3_proc
    // (properties), a9_mb (formal), a15_mb (module var) and arm c3_bounds cell
    // d13 -- golden carries the edge in EVERY one, we carried it in NONE.
    // GATE (byte verifier + arm): only isBuiltinStdClass, so nothing that
    // already resolves is touched, and the map is EMPTY under --nobuiltin.
    if (!builtinFileDefnByName.empty() && isBuiltinStdClass(ct)) {
        if (auto bit = builtinFileDefnByName.find(ct.name);
            bit != builtinFileDefnByName.end())
            return bit->second;
    }
    return nullptr;
}

// § builtinClassTsLinksBuiltinFileDefn7's gate.  slang's `std` package is
// compiler-synthesized (Compilation::getStdPackage), so its classes have no
// syntax and no compilation unit; a USER class of the same short name always
// has a CompilationUnit / InstanceBody / user Package home and is rejected
// here.  Stopping at the FIRST enclosing Package / CompilationUnit /
// InstanceBody is what makes that distinction, rather than the class's name.
bool UhdmExporter::isBuiltinStdClass(const Type& ct) {
    if (ct.kind != SymbolKind::ClassType)
        return false;
    auto scopeOf = [](const Symbol& sym) { return sym.getParentScope(); };
    const Scope* sc = scopeOf(ct);
    if (!sc)
        if (auto* gc = ct.as<ClassType>().genericClass)
            sc = scopeOf(*gc);
    for (; sc; sc = sc->asSymbol().getParentScope()) {
        auto& sym = sc->asSymbol();
        if (sym.kind == SymbolKind::Package)
            return sym.name == "std";
        if (sym.kind == SymbolKind::CompilationUnit ||
            sym.kind == SymbolKind::InstanceBody)
            return false;
    }
    return false;
}

// § builtinClassLocalUnsupportedBeforeClassPhase115 — the predicate; the law,
// its Surelog citations and the three conjuncts are in UhdmExporter.h.
std::string_view UhdmExporter::builtinStdClassToken115(const DeclaredType* dt) {
    if (!dt)
        return {};
    // Conjunct 1 — slang's `std` builtin class, and NOTHING else.  The kind
    // test inside isBuiltinStdClass is also conjunct 3: an array declaration's
    // type is an array type, so it never reaches the ClassType arm.
    if (!isBuiltinStdClass(dt->getType()))
        return {};
    // Conjunct 2 — the BARE spelling.  golden's `std::process` cell keeps
    // class_var, so the scoped name is not this law's.
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return {};
    auto& nt = tsyn->as<syntax::NamedTypeSyntax>();
    if (!nt.name || nt.name->kind != syntax::SyntaxKind::IdentifierName)
        return {};
    auto tok = nt.name->as<syntax::IdentifierNameSyntax>().identifier;
    if (!tok.valid())
        return {};
    return tok.valueText();
}

// § builtinClassLocalUnsupportedBeforeClassPhase115, the view conjunct; the
// law and its grid are in UhdmExporter.h.
bool UhdmExporter::inGenScopeChain115(const UHDM::any* o) {
    for (int d = 0; o && d < 300; ++d, o = o->VpiParent())
        if (o->UhdmType() == UHDM::uhdmgen_scope)
            return true;
    return false;
}

// The specialization carried by a class_typespec (see the header note).
void UhdmExporter::emitClassTsParams(UHDM::class_typespec* cts, const ClassType& cls,
                                     const std::string& prefix) {
    auto* params = s.MakeAnyVec();
    auto* pas = s.MakeParam_assignVec();
    for (auto& mem : cls.members()) {
        // Value parameters of a specialization have no observed Surelog form
        // here yet; only `type` formals are reproduced.
        if (mem.kind != SymbolKind::TypeParameter)
            continue;
        auto& tps = mem.as<TypeParameterSymbol>();
        std::string fn = prefix + "." + std::string(tps.name);
        auto* tp = s.MakeType_parameter();
        tp->VpiName(tps.name);
        tp->VpiFullName(fn);
        tp->VpiParent(cts);
        setLoc(tp, nameSpan(tps.location, tps.name));
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(tp);
        rt->VpiFullName(fn);
        auto& dct = tps.targetType.getType().getCanonicalType();
        auto* dsyn = tps.targetType.getTypeSyntax();
        UHDM::typespec* its = nullptr;
        if (dct.kind == SymbolKind::ClassType) {
            auto* nts = s.MakeClass_typespec();
            nts->VpiName(dct.name);
            nts->VpiParent(tp);
            if (auto* bcd = classDefnFor(dct))
                nts->Class_defn(bcd);
            else
                pendingClassTsLink.push_back({nts, &dct});
            if (dsyn)
                setLoc(nts, dsyn->sourceRange());
            emitClassTsParams(nts, dct.as<ClassType>(),
                              fn + "." + std::string(dct.name));
            its = nts;
        }
        else {
            its = makeTypespec(mem, dsyn);
            if (its)
                its->VpiParent(tp);
        }
        rt->Actual_typespec(its);
        tp->Typespec(rt);
        params->push_back(tp);
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(cts);
        setLoc(pa, nameSpan(tps.location, tps.name));
        pa->Rhs(tp);
        pas->push_back(pa);
        // Lhs is the class_defn's own formal of the same name.
        bool bound = false;
        if (auto* bcd = classDefnFor(cls); bcd && bcd->Parameters())
            for (auto* p9 : *bcd->Parameters())
                if (p9->VpiName() == tps.name) {
                    pa->Lhs(p9);
                    bound = true;
                    break;
                }
        if (!bound)
            pendingClassTsPa.push_back({pa, &cls, std::string(tps.name)});
    }
    if (params->empty())
        return;
    cts->Parameters(params);
    cts->Param_assigns(pas);
}

// NOTE § classPropSpecForeignPkgHome163 — the LISTING half.  The predicate that
// decides WHETHER a class property's class_typespec carries a specialization
// listing lives at the mint (src/TypeEmit.cpp, `grep -n foreignPkgHome163`);
// this is WHAT the listing contains, transcribed line by line from Surelog's
// only writer of `Parameters`/`Param_assigns`,
// `CompileHelper::compileDatastructureTypespec`'s `datatype_cast<const
// ClassDefinition*>` arm (src/DesignCompile/CompileType.cpp:902-1000):
//
//   * the loop walks the WRITTEN `Ordered_parameter_assignment` list and stops
//     at `index < formal.size()`, so a formal with NO written argument gets
//     NOTHING — arm C `c4_one_arg_of_two` (`genEp163#(int)` of a TWO-formal
//     class) is ONE entry in golden, not two.  This is why the site cannot
//     reuse `emitClassTsParams`, which lists every formal of the
//     SPECIALIZATION and would give that cell two;
//   * `index` counts ALL formals, VALUE ones included, and a value formal's
//     argument pushes nothing — arm C `c10_value_then_type`
//     (`valEp163#(4, cfgUn163)` on `#(int NN, type TA)`) is ONE entry in
//     golden, bound to TA, and the `4` only advances the index;
//   * the loop is guarded on `paOrdered_parameter_assignment`, so a NAMED
//     argument spelling produces no entries at all — arm C `c7_named_arg`;
//   * `pass->Lhs(fparam)` is the TARGET class_defn's own formal, and
//     `pass->VpiLineNo(fparam->VpiLineNo())` gives the param_assign the
//     FORMAL's span;
//   * the two ARMS.  When the written argument parses as a `paData_type`
//     (`int`, `bit [3:0]`, …) Surelog compiles the argument's own type node and
//     calls `populateCoreMembers(p->getNodeId(), …)` on the type_parameter,
//     i.e. it stamps THE FORMAL'S OWN DECLARATION SPAN on it; when the argument
//     parses as an EXPRESSION (a bare identifier naming a class or a typedef)
//     it takes the `compileExpression`/`ref_obj` branch, which stamps NO span
//     on the type_parameter and NO span on the param_assign, and locates the
//     actual typespec at the WHOLE `#(...)` text.  Both faces are in the
//     Scoreboard head itself: `type_parameter T` at `110:31-110:32` (the
//     formal's own span, `int` argument) beside `type_parameter IMP` with no
//     span at all (`my_scoreboard` argument), and their actuals at `9:22-9:25`
//     and `9:20-9:41`.
//
// A SCOPED spelling is refused here for the same reason r10sd1 refuses it: it
// takes Surelog's paPackage_scope/paClass_scope arm and never reaches this
// mint.  NO VpiFullName is written on the type_parameter or its ref_typespec —
// UHDM's `ComputeFullName()` yields golden's
// `work@my_scoreboard::m_imp::uvm_analysis_imp::T` from the final parent chain,
// which is not known here.
void UhdmExporter::emitClassPropSpecParams163(
        UHDM::class_typespec* cts, const ClassType& target,
        const syntax::SyntaxNode* typeSyn, const Scope* declScope) {
    if (!cts || cts->Parameters())
        return;
    // (1) The written spelling must be an UNQUALIFIED `C #(...)`.
    auto* nt163 = typeSyn ? typeSyn->as_if<syntax::NamedTypeSyntax>() : nullptr;
    auto* cn163 = nt163 ? nt163->name->as_if<syntax::ClassNameSyntax>() : nullptr;
    if (!cn163 || !cn163->parameters)
        return;
    // (2) ORDERED arguments only.
    std::vector<const syntax::ExpressionSyntax*> ord163;
    for (auto* pa163 : cn163->parameters->parameters) {
        if (!pa163 || pa163->kind != syntax::SyntaxKind::OrderedParamAssignment)
            return;
        ord163.push_back(&*pa163->as<syntax::OrderedParamAssignmentSyntax>().expr);
    }
    if (ord163.empty())
        return;
    // § ownTypeFormalArgPushesNothing163v — the argument names a TYPE FORMAL of
    // the DECLARING class itself.  Measured, not reasoned: arm P `p03`/`p11`
    // (every argument a own formal) carry NO listing in golden, `p05`/`p06`
    // carry exactly ONE entry with the index advanced past the skipped
    // argument, and arm Q `q04`/`q05` repeat it beside a class-scope typedef
    // argument, which is NOT skipped (`q03` keeps its entry).  A direct `find`
    // in the declaring scope and no walk: an OUTER class's formal (`q01`) and a
    // module type parameter (`q10`) ARE listed by golden.
    auto ownTypeFormal163v = [&](const syntax::ExpressionSyntax* a163v) {
        if (!declScope || !a163v ||
            a163v->kind != syntax::SyntaxKind::IdentifierName)
            return false;
        std::string_view nm163v =
            a163v->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (nm163v.empty())
            return false;
        const Symbol* f163v = declScope->find(nm163v);
        return f163v && f163v->kind == SymbolKind::TypeParameter;
    };
    auto* params163 = s.MakeAnyVec();
    auto* pas163 = s.MakeParam_assignVec();
    size_t idx163 = 0;
    for (auto& m163 : target.members()) {
        if (m163.kind != SymbolKind::TypeParameter &&
            m163.kind != SymbolKind::Parameter)
            continue;
        if (idx163 >= ord163.size())
            break;
        const syntax::ExpressionSyntax* a163 = ord163[idx163++];
        if (m163.kind != SymbolKind::TypeParameter)
            continue;  // a VALUE formal consumes its argument and pushes nothing
        if (ownTypeFormal163v(a163))
            continue;  // and so does the declaring class's OWN type formal
        auto& tps163 = m163.as<TypeParameterSymbol>();
        // Surelog's `paData_type` test: a bare identifier (a class name, a
        // typedef name) parses as an EXPRESSION and takes the other arm.
        const bool exprArm163 =
            a163 && (a163->kind == syntax::SyntaxKind::IdentifierName ||
                     a163->kind == syntax::SyntaxKind::ScopedName ||
                     a163->kind == syntax::SyntaxKind::ClassName);
        auto* tp163 = s.MakeType_parameter();
        tp163->VpiName(tps163.name);
        tp163->VpiParent(cts);
        if (!exprArm163)
            setLoc(tp163, nameSpan(tps163.location, tps163.name));
        auto* rt163 = s.MakeRef_typespec();
        rt163->VpiParent(tp163);
        auto& dct163 = tps163.targetType.getType().getCanonicalType();
        UHDM::typespec* its163 = nullptr;
        if (dct163.kind == SymbolKind::ClassType) {
            auto* nts163 = s.MakeClass_typespec();
            nts163->VpiName(dct163.name);
            nts163->VpiParent(tp163);
            if (auto* bcd163 = classDefnFor(dct163))
                nts163->Class_defn(bcd163);
            else
                pendingClassTsLink.push_back({nts163, &dct163});
            setLoc(nts163, cn163->parameters->sourceRange());
            its163 = nts163;
        }
        else {
            its163 = makeTypespec(m163, tps163.targetType.getTypeSyntax());
            if (its163) {
                its163->VpiParent(tp163);
                if (!exprArm163)
                    setLoc(its163, a163->sourceRange());
                else if (its163->VpiName().empty() &&
                         a163->kind == syntax::SyntaxKind::IdentifierName) {
                    // The expression arm re-enters `compileDatastructureTypespec`
                    // with the ref_obj's NAME, which is what golden's
                    // `logic_typespec (nib163_t)` wears (arm C `c6_typedef_arg`).
                    its163->VpiName(std::string(
                        a163->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText()));
                    setLoc(its163, cn163->parameters->sourceRange());
                }
            }
        }
        rt163->Actual_typespec(its163);
        tp163->Typespec(rt163);
        params163->push_back(tp163);
        auto* pa163 = s.MakeParam_assign();
        pa163->VpiParent(cts);
        pa163->Rhs(tp163);
        if (!exprArm163)
            setLoc(pa163, nameSpan(tps163.location, tps163.name));
        bool bound163 = false;
        if (auto* bcd163 = classDefnFor(target); bcd163 && bcd163->Parameters())
            for (auto* p163 : *bcd163->Parameters())
                if (p163->VpiName() == tps163.name) {
                    pa163->Lhs(p163);
                    bound163 = true;
                    break;
                }
        if (!bound163)
            pendingClassTsPa.push_back({pa163, &target, std::string(tps163.name)});
        pas163->push_back(pa163);
    }
    if (params163->empty())
        return;
    cts->Parameters(params163);
    cts->Param_assigns(pas163);
}

// NOTE § classTdSpecParamsForeignHome1 — the SPECIALIZATION carried by a
// CLASS-SCOPE class-handle typedef, and the ONE predicate that decides it.
//
// WHAT WAS MISSING.  SeqDriver's shared 85-line cmp head, both modes, is
//   LHS  class_typespec (adpcm_pkg::type_id) @440:12-440:31, with vpiParameter
//        type_parameter T -> class_typespec (adpcm_seq_item) and a vpiParamAssign
//        whose Lhs is uvm_pkg::uvm_object_registry::T
//   RHS  <null>
// and `RHS: <null>` here is NOT a missing object: we emit that class_typespec,
// with the right name, span, vpiInstance and vpiClassDefn, at the SAME index of
// the SAME 125-entry `work@top_tb` Typespecs vector golden uses (censused
// span-keyed on both sides: 125 == 125, object present).  It is the
// `rhs == nullptr` arm of UHDM's VECTOR `SafeCompare` (BaseClass.h:216-220),
// which sets `m_failedLhs` to the CONTAINER and leaves `m_failedRhs` unset --
// byte-for-byte the same cmp.log text a missing singular object produces.  The
// brief's r10uvm52-era reading ("head-is-an-object means every recursive vector
// before it passed") is therefore FALSE for a NULL vector, and following it
// would have sent this pass hunting a typespec-minting owner that already exists.
// The deficit is `Parameters` (and `Param_assigns`) on an object we already emit.
//
// THE LAW, transcribed from Surelog rather than guessed.  A class_typespec's
// Parameters/Param_assigns have exactly ONE writer in Surelog:
// `CompileHelper::compileDatastructureTypespec`'s ClassDefinition arm
// (CompileType.cpp:904-1000), which walks the WRITTEN `Parameter_value_assignment`
// and pushes one type_parameter + one param_assign per ORDERED argument.  That
// arm is reached only as the LAST resort of `compileTypespec`'s slStringConst
// case: three probes run first (CompileType.cpp:1896-1918)
//     design->getClassDefinition(typeName)
//     design->getClassDefinition(<component>::typeName)
//     design->getClassDefinition(<component's parent scope>::typeName)
// and a HIT there mints a bare class_typespec with Name + Class_defn and NO
// parameters.  So the predicate is "all three probes miss", i.e. the target
// generic class is NOT nested in the referencing class and NOT a sibling of it
// in the referencing class's immediate parent scope.  Surelog keys a package
// class `pkg::C` and a compilation-unit class `work@C`, so the parent-scope
// probe can only ever hit for a PACKAGE parent -- which is why a $unit class
// referencing a $unit generic DOES carry the specialization (cell b13).
//
// GRID (tools/probe/r10sd1repro/grid/, one cell PER FILE -- see ct1grid.sh for
// why a1_registry.sv's single-file version was worthless).  LHS always golden:
//   b1  class td, target in OWN pkg                              golden --  (probe 3 hits)
//   b2  same, arg is another class                               golden --
//   b12 same, typedef produced by a MACRO                        golden --  (macro IRRELEVANT)
//   b3  PACKAGE td, target in OWN pkg                            golden --  (probe 2 hits)
//   b18 class td, target named QUALIFIED `rp::regb#(..)`         golden --  (paClass_scope arm)
//   b21 class td, foreign target, NO `#(...)`                    golden --
//   b20 class td, foreign target, NAMED args `#(.T(x))`          golden --  (ordered-only loop)
//   b19 class td in a generic, foreign target, arg = OWN type param  golden --  (the
//       `datatype_cast<const Parameter*>` arm returns nullptr, "Prevent
//       circular definition")
//   b5  same with an own-package target                          golden --
//   b11 class td, target in a WILDCARD-imported pkg              golden PA  <- SeqDriver
//   b17 same via an EXPLICIT `import rp::regb;`                  golden PA
//   b14 same plus a macro                                        golden PA
//   b23 same with ONE ordered arg (value formal defaulted)       golden PA
//   b13 class td in a $unit class, $unit target                  golden PA  (see above)
//   b22 TWO class tds of one foreign generic                     golden PA on BOTH
//   b4/b15/b16 MODULE- and PACKAGE-scope tds of a foreign generic golden PA -- a
//       DIFFERENT emission site, DISCLOSED AS A RESIDUE and deliberately not
//       touched here: the whole-design cell grid shows zero corpus reach for
//       them (every differing key is a class-scope one).
//   b9/b24/b25/b26/b27 INLINE declarations -- not this site; b9 already agrees.
bool UhdmExporter::emitClassTdSpecParams1(
        UHDM::class_typespec* cts, const ClassType& target,
        const ClassType& declCls, const syntax::SyntaxNode* typeSyn) {
    if (!cts || cts->Parameters())
        return false;
    // (1) The written spelling must be an UNQUALIFIED `C #(...)`.  A ScopedName
    // (`rp::regb #(..)`) takes Surelog's paPackage_scope/paClass_scope arm
    // (CompileType.cpp:1522-1545), which mints a bare class_typespec -- cell b18.
    auto* nt1 = typeSyn ? typeSyn->as_if<syntax::NamedTypeSyntax>() : nullptr;
    auto* cn1 = nt1 ? nt1->name->as_if<syntax::ClassNameSyntax>() : nullptr;
    if (!cn1)
        return false;
    // (2) ORDERED arguments only: the loop Surelog walks is guarded on
    // `paOrdered_parameter_assignment`, so a named-arg spelling produces the
    // (empty, hence dump- and cmp-invisible) vectors and nothing else -- b20.
    std::vector<const syntax::ExpressionSyntax*> ord1;
    for (auto* pa1 : cn1->parameters->parameters) {
        if (!pa1 || pa1->kind != syntax::SyntaxKind::OrderedParamAssignment)
            return false;
        ord1.push_back(&*pa1->as<syntax::OrderedParamAssignmentSyntax>().expr);
    }
    if (ord1.empty())
        return false;
    // (3) THE HOME TEST — Surelog's three getClassDefinition probes.
    const Symbol* gsym1 = target.genericClass
                              ? static_cast<const Symbol*>(target.genericClass)
                              : static_cast<const Symbol*>(&target);
    const Scope* gsc1 = gsym1->getParentScope();
    const Symbol* home1 = gsc1 ? &gsc1->asSymbol() : nullptr;
    if (home1) {
        if (home1 == static_cast<const Symbol*>(&declCls))
            return false; // nested in the referencing class (probe 2)
        const Scope* dp1 = declCls.getParentScope();
        // Probe 3 spells `<parentScopeName>::<typeName>`.  It hits whenever the
        // target is a SIBLING of the referencing class in that class's IMMEDIATE
        // parent scope -- and that scope is a Package (`pb::regb`) OR an
        // enclosing CLASS (`pb::outerb::regb`), because Surelog keys a nested
        // class under its outer class exactly as it keys a package class under
        // its package.  What probe 3 can NEVER spell is a compilation-unit
        // class, which Surelog keys `work@C` (cell b13, which must keep firing).
        // So the test is "the parent scope is a NAMED declaration scope", i.e.
        // Package or ClassType -- NOT Package alone.
        //
        // VERIFIER FINDING F1 (r10sd1 verifier pass): with `Package` alone this
        // predicate MISSED the enclosing-class case and the emitter OVER-FIRED.
        // Witness cell `grid/b28_nestedouter.sv`: golden carries NO
        // specialization (probe 3 spells `pb::outerb::regb` and HITS), the
        // pristine binary agreed, and the Package-only gate emitted one anyway
        // -- a SAME -> DIFF regression, dump content vs golden 94 -> 143.
        if (dp1 && home1 == &dp1->asSymbol() &&
            (home1->kind == SymbolKind::Package ||
             home1->kind == SymbolKind::ClassType))
            return false;
    }
    // (4) Which formals are backed by a CONCRETE written argument.  An argument
    // that names a parameter of the referencing class (or of a class enclosing
    // it) resolves, in Surelog, through `compileDatastructureTypespec`'s
    // `datatype_cast<const Parameter*>` arm, which returns nullptr and pushes
    // NOTHING -- cells b19 and b5.  Ordered index i counts ALL formals (value
    // ones included), exactly as Surelog's `getOrderedParameters()` does.
    auto namesAParamOf1 = [&](std::string_view id1) {
        for (const Scope* sc1 = &declCls; sc1;) {
            for (auto& m1 : sc1->members())
                if ((m1.kind == SymbolKind::TypeParameter ||
                     m1.kind == SymbolKind::Parameter) &&
                    m1.name == id1)
                    return true;
            auto& ss1 = sc1->asSymbol();
            if (ss1.kind != SymbolKind::ClassType)
                break;
            sc1 = ss1.getParentScope();
            if (sc1 && sc1->asSymbol().kind != SymbolKind::ClassType)
                break;
        }
        return false;
    };
    std::set<std::string> ok1;
    size_t idx1 = 0;
    for (auto& m1 : target.members()) {
        if (m1.kind != SymbolKind::TypeParameter &&
            m1.kind != SymbolKind::Parameter)
            continue;
        if (idx1 >= ord1.size())
            break;
        const syntax::ExpressionSyntax* a1 = ord1[idx1++];
        if (m1.kind != SymbolKind::TypeParameter)
            continue;
        std::string_view id1;
        if (a1 && a1->kind == syntax::SyntaxKind::IdentifierName)
            id1 = a1->as<syntax::IdentifierNameSyntax>().identifier.valueText();
        if (!id1.empty() && namesAParamOf1(id1))
            continue;
        ok1.insert(std::string(m1.name));
    }
    if (ok1.empty())
        return false;
    // (5) BUILD.  Deliberate differences from emitClassTsParams, each measured
    // on cell b11's golden:
    //   * NO VpiFullName is written on the type_parameter or its ref_typespec.
    //     Golden's `work@topb.pb::tidb.T` (and SeqDriver's
    //     `work@top_tb.adpcm_pkg::type_id.T`) is EXACTLY what UHDM's
    //     `ComputeFullName()` yields from the FINAL parent chain, and that chain
    //     is not known here -- the object is renamed `<pkg>::<td>` and
    //     re-parented to the module_inst by the package/module listing passes
    //     that run LATER.  Leaving it unset lets the reader compute it, which is
    //     also what Surelog does; the same rule gives every one of the 60 group
    //     clones its own `<owner>::<td>::T` spelling for free.
    //   * NO span on the type_parameter and NO span on the param_assign
    //     (golden prints neither).
    //   * the ACTUAL's span is the whole `#(...)` text, not the argument's own.
    auto* params1 = s.MakeAnyVec();
    auto* pas1 = s.MakeParam_assignVec();
    for (auto& m1 : target.members()) {
        if (m1.kind != SymbolKind::TypeParameter)
            continue;
        auto& tps1 = m1.as<TypeParameterSymbol>();
        if (!ok1.count(std::string(tps1.name)))
            continue;
        auto* tp1 = s.MakeType_parameter();
        tp1->VpiName(tps1.name);
        tp1->VpiParent(cts);
        auto* rt1 = s.MakeRef_typespec();
        rt1->VpiParent(tp1);
        auto& dct1 = tps1.targetType.getType().getCanonicalType();
        UHDM::typespec* its1 = nullptr;
        if (dct1.kind == SymbolKind::ClassType) {
            auto* nts1 = s.MakeClass_typespec();
            nts1->VpiName(dct1.name);
            nts1->VpiParent(tp1);
            if (auto* bcd1 = classDefnFor(dct1))
                nts1->Class_defn(bcd1);
            else
                pendingClassTsLink.push_back({nts1, &dct1});
            setLoc(nts1, cn1->parameters->sourceRange());
            its1 = nts1;
        }
        else {
            its1 = makeTypespec(m1, tps1.targetType.getTypeSyntax());
            if (its1)
                its1->VpiParent(tp1);
        }
        rt1->Actual_typespec(its1);
        tp1->Typespec(rt1);
        params1->push_back(tp1);
        auto* pa1 = s.MakeParam_assign();
        pa1->VpiParent(cts);
        pa1->Rhs(tp1);
        pas1->push_back(pa1);
        // Lhs is the TARGET class_defn's own formal of the same name; golden's
        // clones carry a clone of it, which compares equal to the shared object
        // (type_parameter::Compare reads VpiName + Typespec, never identity).
        bool bound1 = false;
        if (auto* bcd1 = classDefnFor(target); bcd1 && bcd1->Parameters())
            for (auto* p1 : *bcd1->Parameters())
                if (p1->VpiName() == tps1.name) {
                    pa1->Lhs(p1);
                    bound1 = true;
                    break;
                }
        if (!bound1)
            pendingClassTsPa.push_back({pa1, &target, std::string(tps1.name)});
    }
    if (params1->empty())
        return false;
    cts->Parameters(params1);
    cts->Param_assigns(pas1);
    return true;
}

// § classTdSpecParamsForeignHome1, the CLONE half.  Surelog's later typedefs of
// one target take the `clone_tree` path (ElaborationStep.cpp:193-200), so a
// clone carries the BASE's specialization and NOT the one its own `#(...)` text
// would produce: cell b22's `pb::wb::tidb` binds T to `ub`, and all 60 UVM
// `type_id` / `this_type` clones bind T to `adpcm_seq_item` / `adpcm_driver`.
// Fresh objects per clone (never a shared vector): the type_parameter's parent
// is what ComputeFullName reads, and golden gives every clone its own
// `<owner>::<td>::T` spelling.
void UhdmExporter::copyClassTdSpecParams1(UHDM::class_typespec* dst,
                                          UHDM::class_typespec* base,
                                          bool overwrite1) {
    if (!dst || !base || dst == base || !base->Parameters())
        return;
    // NOTE § classTdCloneSpecOverridesOwnArgs112 — THE CLONE HALF IS TOTAL.
    // Surelog's `ElaborationStep::bindTypedefs_` gives a group's later typedefs
    // `clone_tree` of the BASE's typespec (ElaborationStep.cpp:194-201): the
    // clone's OWN `#(...)` text never reaches the database.  The 2026-08 cut of
    // this law refused a destination that already had Parameters, on the
    // reading that such a member is "the b22 base/base case where both members'
    // own text agrees anyway".  That reading is FALSE whenever the group's
    // members specialize the SAME foreign generic with DIFFERENT arguments,
    // which is exactly what the two `uvm_*_registry` groups do: SeqDriver's
    // `adpcm_pkg::adpcm_sequencer::type_id`, `::adpcm_test::type_id` (group
    // `uvm_component_registry`, base `adpcm_pkg::adpcm_driver`) and
    // `::adpcm_tx_seq::type_id` (group `uvm_object_registry`, base
    // `adpcm_pkg::adpcm_seq_item`) each fired their OWN foreign-home gate and
    // so kept T bound to their own class, where golden binds the BASE's.
    // The corpus reach is 13 cells, predicted a priori from PRISTINE databases
    // by tools/probe/r10uvm112repro/pred112.py: those three plus MiniAmiq's ten
    // `svaunit_*::type_id` clones (base `svaunit_base` / `svaunit_base_sequence`).
    // SimpleUVM, Scoreboard and BuildUVMPkg have none, and the whole
    // uhdm2rtlil corpus (1358 rows, every database dumped and screened) has none.
    if (dst->Parameters() && !overwrite1)
        return;
    auto* params1 = s.MakeAnyVec();
    auto* pas1 = s.MakeParam_assignVec();
    auto* bpas1 = base->Param_assigns();
    size_t i1 = 0;
    for (auto* bp1 : *base->Parameters()) {
        if (!bp1 || bp1->UhdmType() != UHDM::uhdmtype_parameter) {
            i1++;
            continue;
        }
        auto* btp1 = (UHDM::type_parameter*)bp1;
        auto* tp1 = s.MakeType_parameter();
        tp1->VpiName(btp1->VpiName());
        tp1->VpiParent(dst);
        if (auto* brt1 = btp1->Typespec()) {
            auto* rt1 = s.MakeRef_typespec();
            rt1->VpiParent(tp1);
            rt1->Actual_typespec(brt1->Actual_typespec());
            tp1->Typespec(rt1);
        }
        params1->push_back(tp1);
        auto* pa1 = s.MakeParam_assign();
        pa1->VpiParent(dst);
        pa1->Rhs(tp1);
        if (bpas1 && i1 < bpas1->size() && bpas1->at(i1))
            pa1->Lhs(bpas1->at(i1)->Lhs());
        pas1->push_back(pa1);
        i1++;
    }
    if (params1->empty())
        return;
    dst->Parameters(params1);
    dst->Param_assigns(pas1);
}

// Class-scope typedefs (class_defn vpiTypedef), NAME-ordered: Surelog writes
// the class's DataTypeMap, a std::map keyed by the typedef name, and gives a
// class_defn's typespecs no vpiInstance (UhdmWriter::writeDataTypes).
//
// Two alias shapes are reproduced:
//   * ENUM aliases — the builtin `process::state` shape, behind --builtins.
//   * CLASS-handle aliases (`typedef resource #(T) rsrc_t;`) — a class_typespec
//     NAMED AFTER THE ALIAS but pointing at the TARGET class's class_defn, and
//     located at the target's own name text. The property declared with the
//     alias (`rsrc_t rsrc;`) shares this very object rather than minting a
//     fresh class_typespec named after the class (ClassParamAsParam,
//     ClassTypeParam) — makeTypespec's typedefTs lookup does that for free.
//
//   * ORDINARY data types (`typedef logic [SIZE-1:0] t_vector;`, an unpacked
//     array, a struct) — built exactly like a module's own typedefs, EXCEPT
//     that every dimension bound stays UNFOLDED. A class_defn is emitted once
//     per generic (classDefnFor), so the formals of the specialization slang
//     hands us (SIZE=1) must not leak in: golden holds `operation(SIZE-1)`
//     over a bare ref_obj SIZE. The refs' fullnames chain off the CLASS with
//     `::` (work@C::t_vector::SIZE), the separator Surelog uses inside a class.
//     No vpiInstance on any of them (writeDataTypes skips it for class_defn).
// § typedefAliasSharesTypespec25 — the root of a class type parameter's
// DEFAULT chain, or null when `written` is not one of this class's type
// parameters.  `type RSP = REQ` and `type RSP_IMP = IMP` are the two shapes
// this walks; the chain is read off the DECLARATOR (`TypeAssignmentSyntax`),
// not off the resolved targetType, so a specialization's overrides cannot
// change it — Surelog compiles a parameterized class once, generically.
const Symbol* UhdmExporter::tpAliasRootOf25(const ClassType& cls,
                                            std::string_view written) const {
    auto find25 = [&](std::string_view n) -> const Symbol* {
        for (auto& m : cls.members())
            if (m.kind == SymbolKind::TypeParameter && m.name == n)
                return &m;
        return nullptr;
    };
    if (!find25(written))
        return nullptr;
    // The chain has to come off the class DECLARATION: a specialization's
    // TypeParameterSymbols carry no syntax of their own (getSyntax() is null),
    // and their resolved targetType is the OVERRIDE, which would hide the
    // default that does the sharing.
    std::map<std::string, std::string, std::less<>> dflt25;
    if (auto* csyn = cls.getSyntax())
        if (csyn->kind == syntax::SyntaxKind::ClassDeclaration)
            if (auto* pl = csyn->as<syntax::ClassDeclarationSyntax>().parameters)
                for (auto* decl : pl->declarations) {
                    auto* td =
                        decl->as_if<syntax::TypeParameterDeclarationSyntax>();
                    if (!td)
                        continue;
                    for (auto* da : td->declarators) {
                        if (!da || !da->assignment || !da->assignment->type)
                            continue;
                        auto* nt =
                            da->assignment->type->as_if<syntax::NamedTypeSyntax>();
                        if (!nt ||
                            nt->name->kind != syntax::SyntaxKind::IdentifierName)
                            continue;
                        dflt25.emplace(
                            std::string(da->name.valueText()),
                            std::string(nt->name
                                            ->as<syntax::IdentifierNameSyntax>()
                                            .identifier.valueText()));
                    }
                }
    std::string cur(written);
    for (int guard = 0; guard < 32; ++guard) {
        auto it = dflt25.find(cur);
        // A default that does NOT name another type parameter (`type REQ =
        // uvm_sequence_item`) ends the chain: that parameter is the root.
        if (it == dflt25.end() || it->second == cur || !find25(it->second))
            break;
        cur = it->second;
    }
    return find25(cur);
}

void UhdmExporter::emitClassTypedefs(const ClassType& cls, UHDM::class_defn* cd) {
    buildClassTypedefTs(cls, std::string(cd->VpiName()));
    std::vector<std::pair<std::string, UHDM::typespec*>> ents;
    // § typedefAliasSharesTypespec25 — type-parameter aliases reaching the same
    // root parameter are ONE object in Surelog: written once, at the
    // alphabetically first of their names, under the SOURCE-LAST one's name.
    // Reproduced by keeping the last-declared member's typespec at the first
    // name's slot and dropping the rest (uvm_sequencer_param_base's
    // `typedef REQ req_type; typedef RSP rsp_type;` -> golden's single
    // `class_typespec 'rsp_type'` at ts[0]).
    std::map<const void*, std::pair<std::string, UHDM::typespec*>> grp25;
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto itR = tpAliasRoot25.find((const void*)&member.as<TypeAliasType>());
        if (itR == tpAliasRoot25.end())
            continue;
        auto itT = typedefTs.find((const Symbol*)&member.as<TypeAliasType>());
        if (itT == typedefTs.end())
            continue;
        auto& slot = grp25[itR->second];
        // First name wins the key; last declarator wins the object.
        if (slot.first.empty() || std::string(member.name) < slot.first)
            slot.first = std::string(member.name);
        slot.second = itT->second;
    }
    // Every grouped member leaves the listing; one synthetic entry per group
    // takes their place.  A one-member group is a no-op (same name, same
    // object), so no shape without the alias pair can move.
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        if (tpAliasRoot25.count((const void*)&ta))
            continue;
        auto itT = typedefTs.find((const Symbol*)&ta);
        if (itT == typedefTs.end())
            continue;
        itT->second->VpiParent(cd);
        ents.emplace_back(std::string(ta.name), itT->second);
    }
    for (auto& [root25, slot25] : grp25) {
        (void)root25;
        slot25.second->VpiParent(cd);
        ents.emplace_back(slot25.first, slot25.second);
    }
    if (ents.empty())
        return;
    std::stable_sort(ents.begin(), ents.end(),
                     [](const auto& a, const auto& b) { return a.first < b.first; });
    auto* tds = s.MakeTypespecVec();
    for (auto& e : ents)
        tds->push_back(e.second);
    cd->Typespecs(tds);
}

// The typespec half of emitClassTypedefs, split out so a reference from a
// class that sorts EARLIER by name can force it (see makeTypespec). Builds
// and REGISTERS each nested typedef's typespec once; the owning class's own
// emitClassTypedefs then reuses the objects, parents them and lists them.
// NOTE § classNestedClassTdGroupNoAnchor54 — the SORT KEY of the base pick,
// TRANSCRIBED from Surelog rather than guessed.
// `ElaborationStep::bindTypedefs_` builds ONE `defs` vector — FileContents,
// then PACKAGES, then MODULES, then PROGRAMS, then
// `design->getClassDefinitions()` — and walks it once.  The first typedef of a
// given target class to be walked mints a bare `class_typespec`
// (`compileTypespec` + `populateCoreMembers` = the NAME-TOKEN span, no alias)
// and stores it on the shared target DataType (`dt->setTypespec(ts)`); every
// LATER typedef of the same target then takes the `def->getTypespec() != null`
// path, `clone_tree`s that object and hangs a `Typedef_alias` ref on the clone.
// So "the base" is simply "walked first", and among CLASS-nested typedefs that
// order is `Design::m_classDefinitions`, a
// `std::multimap<std::string, ClassDefinition*>` whose KEY is the FULLY
// QUALIFIED name that `ResolveSymbols` registered: `<pkg>::<cls>` for a class
// declared in a package, `<lib>@<cls>` (= `work@<cls>`) for a compilation-unit
// one.  Within one class the order is `DesignComponent::TypeDefMap`, a
// `std::map<std::string, TypeDef*>` keyed by the TYPEDEF's name.
// That also explains why a PACKAGE-level typedef always wins (pass-50 law 4):
// packages are walked before classes.
std::string UhdmExporter::surelogClassKey54(const ClassType& cls) const {
    if (const Scope* sc = cls.getParentScope()) {
        const Symbol& ss = sc->asSymbol();
        if (ss.kind == SymbolKind::Package)
            return std::string(ss.name) + "::" + std::string(cls.name);
    }
    // UNMEASURED HALF, recorded rather than guessed: Surelog registers a class
    // nested in a MODULE or in another CLASS under other keys; no arm here
    // reaches those, and every corpus owner is a package class or a
    // compilation-unit class.
    return "work@" + std::string(cls.name);
}

// NOTE § classNestedClassTdGroupNoAnchor54 — the drain.  DIRECTION: RESHAPE
// (span) + ADD (the alias).  Runs DESIGN-FINAL because the group is
// design-wide: it needs every class's typedefs built AND `classTdGroupBase50`
// fully published by both `emitPackage` views, since "has a package anchor" is
// the gate that keeps this law off pass-50 law 4's territory.
// GATE, and how it was proved necessary (arm a1, tools/probe/r10uvm54repro):
//   * a group that HAS a `classTdGroupBase50` entry is skipped entirely — a1's
//     `k54` group (package anchor `s54::k_anchor54`) must keep aliasing to the
//     PACKAGE object, and it does, untouched;
//   * a group with exactly ONE member gets NOTHING — a1's `h54` group, where
//     golden gives `r54::a_owner54::h_only54` no vpiTypedefAlias at all;
//   * the base is never itself reshaped and an existing alias is never
//     replaced (the object can be SHARED across package views —
//     § pkgImportCloneLastWriter32 — so a second ref_typespec child would be a
//     duplicate on a shared object).
void UhdmExporter::drainClassNestedTdGroups54() {
    std::map<const void*, std::vector<size_t>> grp54;
    for (size_t i = 0; i < classNestedTd54.size(); i++) {
        auto& e = classNestedTd54[i];
        if (!e.ts || !e.key)
            continue;
        // The PACKAGE anchor wins: that is pass-50 law 4, already applied at
        // build time, and this law is exactly its no-anchor complement.
        if (classTdGroupBase50.count(e.key))
            continue;
        grp54[e.key].push_back(i);
    }
    for (auto& [k54, idx54] : grp54) {
        (void)k54;
        if (idx54.size() < 2)
            continue;
        std::stable_sort(idx54.begin(), idx54.end(),
                         [&](size_t a, size_t b) {
                             auto& x = classNestedTd54[a];
                             auto& y = classNestedTd54[b];
                             if (x.owner != y.owner)
                                 return x.owner < y.owner;
                             return x.name < y.name;
                         });
        // NOTE § classNestedTdOneObjectPerSurelogTypedef97 — ONE GROUP MEMBER
        // PER SOURCE DECLARATION.  Surelog compiles a parameterized class ONCE,
        // generically: a `ClassDefinition`'s `TypeDefMap` is a
        // `std::map<std::string, TypeDef*>`, so `typedef port #(IF) this_type;`
        // written inside `class port #(type IF)` is exactly ONE `TypeDef` and
        // `ElaborationStep::bindTypedefs_` gives it exactly ONE typespec —
        // whatever the number of specializations the design instantiates.
        // slang, which elaborates a parameterized class ONCE PER
        // SPECIALIZATION, hands us one `TypeAliasType` per specialization, so
        // the collector above pushes the SAME source declaration N times and
        // the group then aliased copies 2..N to copy 1.  Golden has nothing to
        // alias them to, so `typespec::Compare`'s `Typedef_alias` walk names
        // ours with `LHS: <null>` — the cmp head of all seven UVM row-modes at
        // 65468af (`uvm-1.2 base/uvm_port_base.svh:199`).
        //
        // GATE: the identity is the DECLARING class's GENERIC class (the
        // ClassType itself when it is not a specialization) plus the typedef's
        // own name — never the `surelogClassKey54` STRING.  Arm
        // `g97_a5_samename.sv` REFUTES the string key: two classes both named
        // `dup97e`, one per module, both spell `work@dup97e`, and golden gives
        // their same-named typedefs a REAL group (a base plus an aliased
        // clone) that a string-keyed dedup would silently drop.
        //
        // GATE, second half — § classNestedTdDupCopiesFollowTheirDeclaration97v
        // (the VERIFIER's re-cut).  The duplicate identity decides ONLY (a) how
        // many members the group really has and (b) whether a member is a copy
        // of the BASE's own declaration.  It must NOT drop copies of a
        // NON-base declaration from the alias loop: golden has ONE object for
        // that declaration and it IS aliased, while we have N copies and
        // NOTHING says which of them the class's vpiTypedef listing and its use
        // sites will read.  Dropping all but one un-aliased the LISTED copy and
        // turned a PASSING database into a failing one on purpose-built golden
        // — arms `v97_c1_mixedgroup.sv` / `v97_c4_specparams.sv`, official
        // uhdm-cmp PASS -> 1 head / 17 lines, BOTH views, before this half
        // existed.  So: count DISTINCT declarations for the size test, skip
        // only the copies of the BASE's declaration, and alias every copy of
        // every other one exactly as pass 54 did.
        std::set<std::pair<const void*, std::string>> decl97;
        for (size_t i54 : idx54) {
            auto& e54 = classNestedTd54[i54];
            decl97.insert({e54.declKey, e54.name});
        }
        // A group that is ONE declaration wearing N specializations is not a
        // group at all: golden gives its single object no alias (arm a1, and
        // one cell in each of the census's nine disagreeing databases).
        if (decl97.size() < 2)
            continue;
        auto* bts54 = classNestedTd54[idx54[0]].ts;
        const void* bDecl97 = classNestedTd54[idx54[0]].declKey;
        const std::string bName97 = classNestedTd54[idx54[0]].name;
        for (size_t j = 1; j < idx54.size(); j++) {
            auto& m54 = classNestedTd54[idx54[j]];
            // A SECOND COPY of the BASE's own written declaration — the head's
            // shape.  Golden has one object there and it carries no alias.
            if (m54.declKey == bDecl97 && m54.name == bName97)
                continue;
            if (m54.ts == bts54 || m54.ts->Typedef_alias())
                continue;
            m54.ts->VpiLineNo(bts54->VpiLineNo());
            m54.ts->VpiColumnNo(bts54->VpiColumnNo());
            m54.ts->VpiEndLineNo(bts54->VpiEndLineNo());
            m54.ts->VpiEndColumnNo(bts54->VpiEndColumnNo());
            m54.ts->VpiFile(bts54->VpiFile());
            // The alias ref's fullname is `<declaring class key>::<typedef>`,
            // measured on BOTH corpora: golden BuildUVMPkg says
            // `uvm_pkg::uvm_agent::type_id`, golden a1 says
            // `work@mm54::n_u54` and `zbb54::aa54::n_z54`.
            auto* ar54 = s.MakeRef_typespec();
            ar54->VpiParent(m54.ts);
            ar54->VpiFullName(m54.owner + "::" + m54.name);
            ar54->Actual_typespec(bts54);
            m54.ts->Typedef_alias(ar54);
            // § classTdSpecParamsForeignHome1, the CLONE half.  A clone carries
            // the BASE's specialization, not its own `#(...)`: grid cell b22's
            // `pb::wb::tidb` binds T to `ub`, and SeqDriver's 60 `type_id` /
            // `this_type` clones all bind T to `adpcm_seq_item` (@440) or
            // `adpcm_driver` (@468).
            //
            // ~~A clone whose own gate already fired (its written args ARE
            // foreign-concrete) keeps what it has -- copyClassTdSpecParams1
            // refuses a non-empty destination -- which is the b22 base/base
            // case where both members' own text agrees anyway.~~  **STRUCK BY
            // r10uvm112.**  b22's two members share an argument, so the
            // refusal was invisible there; it is NOT the general case.  When a
            // group's members specialize the same foreign generic with
            // DIFFERENT arguments the refusal leaves the clone wearing its own
            // `#(...)`, which `clone_tree` never produces -- SeqDriver's
            // 32-line head, and ten more cells in MiniAmiq.
            // § classTdCloneSpecOverridesOwnArgs112 — OVERWRITE.  A clone in
            // this group is `clone_tree` of the base, so the base's
            // specialization REPLACES whatever the clone's own `#(...)` text
            // produced.  Only a member that reached here is touched: the base
            // itself and every copy of the base's own declaration are skipped
            // above, and a member that already carried an alias never enters
            // the loop.
            copyClassTdSpecParams1(m54.ts, bts54, /*overwrite1=*/true);
        }
    }
}

void UhdmExporter::buildClassTypedefTs(const ClassType& cls,
                                       const std::string& clsName) {
    if (!buildingClassTypedefs.insert(&cls).second)
        return;
    struct BctGuard {
        std::set<const void*>& set;
        const void* key;
        ~BctGuard() { set.erase(key); }
    } bctGuard{buildingClassTypedefs, (const void*)&cls};
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        // § typedefAliasSharesTypespec25 — the type-parameter root is recorded
        // for EVERY class typedef, before the already-built early exit: the
        // typespec may have been minted on demand by an earlier-sorted class,
        // and the grouping still has to see this member.
        if (typeSyn)
            if (auto* nt25 = typeSyn->as_if<syntax::NamedTypeSyntax>())
                if (nt25->name->kind == syntax::SyntaxKind::IdentifierName)
                    if (auto* root25 = tpAliasRootOf25(
                            cls, nt25->name->as<syntax::IdentifierNameSyntax>()
                                     .identifier.valueText()))
                        tpAliasRoot25.emplace((const void*)&ta,
                                              (const void*)root25);
        // § classTpTdGroupNonClsRootShared91, site B.  The FIRST candidate
        // typedef of a group member does not mint anything: it BINDS the
        // group's one object, which is therefore also what the class's
        // vpiTypedef LISTING and every property/local/formal written as this
        // typedef will read.  The remaining 6 of the corpus census's 24 cells
        // are here — `local this_req_type m_req_imp;` in the six `uvm_*_imp`
        // classes, the cmp HEAD of all seven UVM row-modes, golden
        // `this_rsp_type` where ours read `this_req_type`.
        // The `VpiName(ta.name)` at the tail of this loop is exactly why the
        // arm has to skip the whole body rather than fall through: renaming the
        // shared object to the non-winning typedef's name is the bug being
        // fixed.
        if (!typedefTs.count((const Symbol*)&ta))
            if (auto* sh91 = classTpGroupNcTdTs91(cls, ta)) {
                typedefTs[(const Symbol*)&ta] = sh91;
                continue;
            }
        if (typedefTs.count((const Symbol*)&ta))
            continue;
        UHDM::typespec* ts = nullptr;
        if (ct.kind == SymbolKind::EnumType && builtins) {
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn, std::string(ta.name));
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            ts = ets;
        }
        else if (ct.kind == SymbolKind::ClassType) {
            auto* cts = s.MakeClass_typespec();
            if (auto* bcd = classDefnFor(ct))
                cts->Class_defn(bcd);
            else
                pendingClassTsLink.push_back({cts, &ct});
            // The span is the target class NAME as written — a parameterized
            // target (`resource #(T)`) contributes only its identifier, the
            // same rule drainPendingExtends applies to an extends clause.
            if (typeSyn) {
                auto r = typeSyn->sourceRange();
                if (auto* nt = typeSyn->as_if<syntax::NamedTypeSyntax>())
                    if (auto* cn = nt->name->as_if<syntax::ClassNameSyntax>())
                        r = cn->identifier.range();
                setLoc(cts, r);
            }
            // § classTdSpecParamsForeignHome1 — the SPECIALIZATION.  Runs BEFORE
            // the two group arms below on purpose: a group's BASE is whichever
            // member is walked first, and the clone arms copy from whatever the
            // base already carries.
            emitClassTdSpecParams1(cts, ct.as<ClassType>(), cls, typeSyn);
            // NOTE § classNestedClassTdJoinsPkgGroup50 — a class-NESTED
            // class-handle typedef whose GENERIC CLASS already has a
            // package-level class-handle typedef group joins that group as a
            // CLONE, exactly as a second package-level typedef of the same
            // generic class does (§ pkgClassTd9): the base's span and vpiFile,
            // the base's vpiInstance, and a vpiTypedefAlias ref -> the base.
            // WITNESS — the SINGLE remaining cmp head of ALL SEVEN comparable
            // UVM rows before this arm, `uvm_pool::this_type`:
            //   LHS golden(BuildUVMPkg): class_typespec (this_type), id:186335,
            //     line:30449:9, endln:30449:17, |vpiTypedefAlias: ref_typespec
            //     (uvm_pkg::uvm_pool::this_type) -> vpiActual class_typespec
            //     (uvm_pkg::uvm_id_actions_array) id:186106, |vpiInstance
            //     package uvm_pkg
            //   RHS ours: class_typespec (this_type), line:14277:11-19, NO
            //     vpiTypedefAlias (cmp prints `RHS: <null>` for the ref), no
            //     vpiInstance
            // GATE: the group key is the GENERIC CLASS, never the specialisation
            // (pass-49 arm a4 groups gc49#(string,int) and gc49#(int,string)
            // under one base), and the base is the one the PACKAGE pass already
            // resolved — NOT a re-sort over the merged set, which would pick
            // `this_type` ('t' < 'u') and is REFUTED by golden.
            if (auto* gcN50 = ct.as<ClassType>().genericClass)
                if (auto bit50 = classTdGroupBase50.find((const void*)gcN50);
                    bit50 != classTdGroupBase50.end() && bit50->second &&
                    bit50->second != cts) {
                    auto* bts50 = bit50->second;
                    cts->VpiLineNo(bts50->VpiLineNo());
                    cts->VpiColumnNo(bts50->VpiColumnNo());
                    cts->VpiEndLineNo(bts50->VpiEndLineNo());
                    cts->VpiEndColumnNo(bts50->VpiEndColumnNo());
                    cts->VpiFile(bts50->VpiFile());
                    if (bts50->Instance() && !cts->Instance())
                        cts->Instance(bts50->Instance());
                    // The BASE is a registered/shared listing object
                    // (§ sharedAliasNoStamp41): read only, never stamped.
                    auto* ar50 = s.MakeRef_typespec();
                    ar50->VpiParent(cts);
                    ar50->VpiFullName(clsName + "::" + std::string(ta.name));
                    ar50->Actual_typespec(bts50);
                    cts->Typedef_alias(ar50);
                    // § classTdSpecParamsForeignHome1, clone half: a
                    // package-anchored clone carries the ANCHOR's
                    // specialization.  UNMEASURED CELL, recorded as such: no
                    // grid cell and no corpus row reaches a package-anchored
                    // group whose base is a FOREIGN generic (every UVM group
                    // that moves here is the no-anchor kind, drained below), so
                    // this call is a no-op today -- `copyClassTdSpecParams1`
                    // returns immediately when the base has no Parameters.
                    copyClassTdSpecParams1(cts, bts50);
                }
            // NOTE § classNestedClassTdGroupNoAnchor54 — COLLECT every
            // class-nested class-handle typedef, whether or not law 4 above
            // found a package anchor: the drain needs the WHOLE group to know
            // that a group HAS no anchor, and `classTdGroupBase50` may not be
            // populated yet at this point anyway (pass-50 residue R2b — the
            // on-demand call from makeTypespec can run before emitPackage).
            // GATE: keyed on the target's GENERIC class when it is a
            // specialization and on the target ClassType itself otherwise —
            // golden groups NON-generic targets too, measured on BuildUVMPkg's
            // `uvm_pkg::uvm_callbacks_base` group (2 members, base
            // `uvm_callbacks_base::this_type` @26619:11-29, clone
            // `uvm_typed_callbacks::super_type` aliased to it), so a
            // genericClass-only key would MISS it.
            // GATE, second half — a typedef whose WRITTEN target is a TYPE
            // PARAMETER (`typedef REQ req_type;`) never joins a group.  Golden
            // hands such a typedef the PARAMETER's own typespec object
            // (§ typedefAliasSharesTypespec25), so it has no clone and no
            // alias.  MEASURED OVER-FIRE, which is why this half exists: with
            // the gate absent, `uvm_pkg::uvm_sequencer_param_base::rsp_type`
            // (REQ and RSP both resolving to uvm_sequence_item in the default
            // specialization) acquired an alias -> `req_type` that golden does
            // NOT have, on BOTH BuildUVMPkg and SimpleUVM.
            if (!tpAliasRoot25.count((const void*)&ta) &&
                classNestedTd54Seen.insert(cts).second) {
                auto* gcN54 = ct.as<ClassType>().genericClass;
                classNestedTd54.push_back(
                    {surelogClassKey54(cls), std::string(ta.name), cts,
                     gcN54 ? (const void*)gcN54 : (const void*)&ct,
                     // § classNestedTdOneObjectPerSurelogTypedef97 — the
                     // DECLARING side's identity: one Surelog TypeDef per
                     // (generic class, typedef name), however many
                     // specializations slang elaborates.
                     cls.genericClass ? (const void*)cls.genericClass
                                      : (const void*)&cls});
            }
            // § classRepresentativeSkipsTypeParamAlias25 — see the header.
            // `typedef REQ req_type;` resolves, in the specialization slang
            // hands us, to a ClassType, so the object is built exactly like a
            // class-handle alias; what it must NOT do is become that class's
            // DataTypeMap representative.
            if (tpAliasRoot25.count((const void*)&ta))
                tpAliasClassTs25.insert(cts);
            ts = cts;
        }
        else if (ct.kind == SymbolKind::UnpackedStructType ||
                 ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::FixedSizeUnpackedArrayType ||
                 ct.kind == SymbolKind::PackedArrayType ||
                 ct.kind == SymbolKind::ScalarType ||
                 // § classTypedefOfPredefIntIsListed25 — `typedef int f_int;`
                 // in a class was the ONE simple shape that produced no
                 // typespec, so the class listed nothing where golden lists an
                 // int_typespec (t35b: golden's `P` has all five of f_bit,
                 // f_en, f_int, f_st, f_vec; we had four).  It is also what
                 // § typedefAliasSharesTypespec25's `type IMP = int` arm needs:
                 // UVM's six `uvm_*_imp` classes list exactly one
                 // int_typespec 'this_rsp_type'.
                 ct.kind == SymbolKind::PredefinedIntegerType) {
            const std::string aliasFull = clsName + "::" + std::string(ta.name);
            bool savedTf = tfContext, savedTd = typedefTsContext;
            bool savedBy = bypassTypedefShare, savedUf = unfoldedTypedefDims;
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            tfContext = true;
            typedefTsContext = true;
            bypassTypedefShare = true;
            unfoldedTypedefDims = true;
            syntaxRefPrefix = aliasFull;
            syntaxRefSep = "::";
            if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                ts = buildUnpackedArrayTypedefTs(ta, aliasFull);
            }
            else if (ct.kind == SymbolKind::UnpackedStructType ||
                     ct.kind == SymbolKind::PackedStructType) {
                auto* sts =
                    ct.kind == SymbolKind::PackedStructType
                        ? buildStructTs(ct.as<PackedStructType>(), true,
                                        aliasFull, "::")
                        : buildStructTs(ct.as<UnpackedStructType>(), false,
                                        aliasFull, "::");
                if (typeSyn)
                    setLoc(sts, typeSyn->sourceRange());
                ts = sts;
            }
            else {
                ts = makeTypespec(ta, typeSyn);
            }
            syntaxRefSep = savedSep;
            syntaxRefPrefix = savedPfx;
            unfoldedTypedefDims = savedUf;
            bypassTypedefShare = savedBy;
            typedefTsContext = savedTd;
            tfContext = savedTf;
        }
        else if (ct.kind == SymbolKind::QueueType ||
                 ct.kind == SymbolKind::DynamicArrayType ||
                 ct.kind == SymbolKind::AssociativeArrayType)
            ts = buildDynContainerTypedefTs(ta, typeSyn);
        if (!ts)
            continue;
        ts->VpiName(ta.name);
        // Registering it lets a method's return type / a property share it.
        typedefTs[&ta] = ts;
    }
}

// A typedef of a DYNAMIC CONTAINER (`typedef T tab_t[string];`,
// `typedef elem q_t[$];`).  Surelog's typedef path stops at compileTypespec,
// so the array_typespec keeps the RAW form compileRanges produced and never
// reaches the ElaborationStep pass that turns a marker range into
// vpiIndexTypespec: no vpiArrayType, no vpiElemTypespec, no vpiIndexTypespec,
// and one marker vpiRange per written dimension — `UINT:0 .. STRING:associative`
// (the index typespec riding the right constant), `UINT:0 .. STRING:$` for a
// queue, `UINT:0 .. STRING:unsized` for an unsized dynamic array.  The
// typespec spans from the TYPE token through the last dimension's `]`.
UHDM::typespec* UhdmExporter::buildDynContainerTypedefTs(
    const TypeAliasType& ta, const syntax::SyntaxNode* typeSyn) {
    std::vector<const syntax::VariableDimensionSyntax*> dims;
    if (auto syn = ta.getSyntax())
        if (auto* td = syn->as_if<syntax::TypedefDeclarationSyntax>())
            for (auto d : td->dimensions)
                dims.push_back(d);
    struct DynDim {
        int kind = 0;  // 0 assoc, 1 queue, 2 dynamic
        const Type* idx = nullptr;
    };
    std::vector<DynDim> ds;
    for (const Type* cur = &ta.targetType.getType();;) {
        auto& cc = cur->getCanonicalType();
        if (cc.kind == SymbolKind::AssociativeArrayType) {
            ds.push_back({0, cc.as<AssociativeArrayType>().indexType});
            cur = &cc.as<AssociativeArrayType>().elementType;
        }
        else if (cc.kind == SymbolKind::QueueType) {
            ds.push_back({1, nullptr});
            cur = &cc.as<QueueType>().elementType;
        }
        else if (cc.kind == SymbolKind::DynamicArrayType) {
            ds.push_back({2, nullptr});
            cur = &cc.as<DynamicArrayType>().elementType;
        }
        else
            break;
    }
    if (ds.empty())
        return nullptr;
    auto* ats = s.MakeArray_typespec();
    auto* rs = s.MakeRangeVec();
    for (size_t i = 0; i < ds.size(); i++) {
        auto* r = s.MakeRange();
        r->VpiParent(ats);
        auto* lc = s.MakeConstant();
        lc->VpiParent(r);
        lc->VpiConstType(vpiUIntConst);
        lc->VpiSize(64);
        lc->VpiValue("UINT:0");
        lc->VpiDecompile("0");
        r->Left_expr(lc);
        auto* rc = s.MakeConstant();
        rc->VpiParent(r);
        if (ds[i].kind == 1) {
            rc->VpiConstType(vpiUnboundedConst);
            rc->VpiSize(1);
            rc->VpiValue("STRING:$");
            rc->VpiDecompile("$");
        }
        else if (ds[i].kind == 2) {
            rc->VpiConstType(vpiStringConst);
            rc->VpiSize(0);
            rc->VpiValue("STRING:unsized");
            rc->VpiDecompile("unsized");
        }
        else {
            rc->VpiConstType(vpiStringConst);
            rc->VpiSize(0);
            rc->VpiValue("STRING:associative");
            rc->VpiDecompile("associative");
            if (ds[i].idx)
                if (auto* its = assocIndexTs(*ds[i].idx, ta)) {
                    auto* irt = s.MakeRef_typespec();
                    irt->VpiParent(rc);
                    irt->Actual_typespec(its);
                    rc->Typespec(irt);
                }
        }
        r->Right_expr(rc);
        if (i < dims.size()) {
            auto dr = dims[i]->sourceRange();
            if (ds[i].kind == 1) {
                // The queue marker is the `$` token, not the brackets.
                setLoc(r, SourceRange(dr.start() + 1, dr.end() - 1));
                setLoc(rc, SourceRange(dr.start() + 1, dr.end() - 1));
            }
            else
                setLoc(r, dr);
        }
        rs->push_back(r);
    }
    ats->Ranges(rs);
    if (typeSyn && !dims.empty())
        setLoc(ats, SourceRange(typeSyn->sourceRange().start(),
                                dims.back()->sourceRange().end()));
    else if (typeSyn)
        setLoc(ats, typeSyn->sourceRange());
    return ats;
}

// Builds a canonical string of an instance's parameterization (value +
// type-parameter tuple) so distinct overrides can be counted per definition.
static std::string paramTuple(const InstanceSymbol& inst) {
    std::string key;
    for (auto& mem : inst.body.members()) {
        if (mem.kind == SymbolKind::Parameter) {
            auto& ps = mem.as<ParameterSymbol>();
            key += ps.name;
            key += '=';
            auto& v = ps.getValue();
            key += v.bad() ? std::string("?") : v.toString();
            key += ';';
        }
        else if (mem.kind == SymbolKind::TypeParameter) {
            auto& tp = mem.as<TypeParameterSymbol>();
            key += tp.name;
            key += '#';
            key += tp.targetType.getType().toString();
            key += ';';
        }
    }
    return key;
}

void UhdmExporter::computeParamMultiplicity() {
    std::map<const DefinitionSymbol*, std::set<std::string>> perDef;
    // TEXTUAL override multiplicity: distinct #(...) raw texts across
    // instances (Surelog uniquifies pre-elab, so #(1.0) vs #(1) differ even
    // when the folded values coincide — realexpr).
    std::map<const DefinitionSymbol*, std::set<std::string>> perDefText;
    std::function<void(const Symbol&)> visit = [&](const Symbol& member) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            perDef[&child.getDefinition()].insert(paramTuple(child));
            defInstTotal[&child.getDefinition()]++;
            defAllInstCount[&child.getDefinition()]++;
            {
                std::string ptxt9;
                for (auto p9 = child.getSyntax(); p9; p9 = p9->parent)
                    if (p9->kind ==
                        syntax::SyntaxKind::HierarchyInstantiation) {
                        if (auto* pva9 =
                                p9->as<syntax::HierarchyInstantiationSyntax>()
                                    .parameters)
                            ptxt9 = std::string(
                                rawText(pva9->sourceRange()));
                        break;
                    }
                if (!ptxt9.empty())
                    overriddenTextDefs.insert(&child.getDefinition());
                perDefText[&child.getDefinition()].insert(ptxt9);
            }
            for (auto& gm : child.body.members())
                visit(gm);
        }
        else if (member.kind == SymbolKind::InstanceArray) {
            for (auto* e : member.as<InstanceArraySymbol>().elements)
                visit(*e);
        }
        else if (member.kind == SymbolKind::GenerateBlock) {
            if (!member.as<GenerateBlockSymbol>().isUninstantiated)
                for (auto& gm : member.as<Scope>().members())
                    visit(gm);
        }
        else if (member.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gb : member.as<GenerateBlockArraySymbol>().entries)
                for (auto& gm : gb->members())
                    visit(gm);
        }
    };
    for (auto inst : comp.getRoot().topInstances) {
        defAllInstCount[&inst->getDefinition()]++;
        for (auto& m : inst->body.members())
            visit(m);
    }
    for (auto& [def, tuples] : perDef)
        if (tuples.size() > 1)
            multiParamDefs.insert(def);
    for (auto& [def, texts] : perDefText)
        if (texts.size() > 1)
            textMultiParamDefs.insert(def);
}

bool UhdmExporter::isMultiParamDef(const Scope& body) const {
    auto& sym = body.asSymbol();
    if (sym.kind != SymbolKind::InstanceBody)
        return false;
    return multiParamDefs.count(&sym.as<InstanceBodySymbol>().getDefinition()) > 0;
}

bool UhdmExporter::srcOrderLess(SourceLocation a, SourceLocation b) const {
    if (bufRank.empty()) {
        // Rank buffers by SYNTAX order, not semantic-unit membership: modules
        // are definitions, not compilation-unit members, so a module-only file
        // never appears in unit->members() and would fall to the BufferID
        // fallback — and BufferIDs follow parallel-load completion order,
        // which flips run to run (mriscv_bind_sva design name work@Wrapper vs
        // work@mriscvcore_top_s2qed). Syntax-tree member order is the parsed
        // command-line order and covers every declaration kind.
        size_t seq = 0;
        for (auto& tree : comp.getSyntaxTrees()) {
            if (!tree)
                continue;
            auto& rootNode = tree->root();
            if (rootNode.kind == syntax::SyntaxKind::CompilationUnit) {
                for (auto mem :
                     rootNode.as<syntax::CompilationUnitSyntax>().members) {
                    auto loc = mem->sourceRange().start();
                    if (loc != SourceLocation::NoLocation)
                        bufRank.emplace(loc.buffer(), seq++);
                }
            }
            else {
                auto loc = rootNode.sourceRange().start();
                if (loc != SourceLocation::NoLocation)
                    bufRank.emplace(loc.buffer(), seq++);
            }
        }
        // Semantic units still rank anything syntax missed (e.g. buffers
        // whose only content expanded from directives).
        for (auto unit : comp.getCompilationUnits())
            for (auto& mem : unit->members())
                if (mem.location)
                    bufRank.emplace(mem.location.buffer(), seq++);
    }
    auto rank = [&](SourceLocation l) -> size_t {
        auto it = bufRank.find(l.buffer());
        // Unranked buffers (no top-level member) keep bufferID order after
        // every ranked one.
        return it != bufRank.end() ? it->second
                                   : (size_t)l.buffer().getId() + (1u << 20);
    };
    size_t ra = rank(a), rb = rank(b);
    if (ra != rb)
        return ra < rb;
    if (a.buffer() != b.buffer())
        return a.buffer() < b.buffer();
    return a.offset() < b.offset();
}


// ===========================================================================
// § unitImportHoistsPkgParams146 — A `$unit`-SCOPE PACKAGE IMPORT MATERIALIZES
// THE IMPORTED PACKAGE'S PARAMETERS **ON THE DESIGN**, AND EVERY LATE-BOUND
// REFERENCE THAT CAN SEE THE DESIGN READS THAT COPY INSTEAD OF THE PACKAGE'S
// OWN FOLDED VALUE.
//
// SURELOG, cited:
//   * `CompileHelper::importPackage` (CompileHelper.cpp:199-241) walks the
//     imported package's `getParameterMap()` — a `std::map` KEYED BY NAME, so
//     the listing comes out in ASCII NAME ORDER, not declaration order —
//     clones each `parameter`, stamps `the_p->VpiImported(pack_name)` (:221 for
//     a `type_parameter`, :229 for a plain `parameter`) and pushes the clone
//     onto `scope->getParameters()`.
//   * The SECOND block (:242-277, "Regular parameter") clones the package's
//     `param_assign`s in the package's OWN listing order onto
//     `scope->getParam_assigns()` and stamps that clone's `Lhs` the same way
//     (:274).  Those are two DISJOINT object sets: the `vpiParameter` entries
//     are never the `vpiParamAssign` Lhs entries (measured below).
//   * `UhdmWriter` then hoists the FileContent's two vectors onto the design
//     and REPARENTS every entry (`tf->VpiParent(d)`, UhdmWriter.cpp:4886-4910).
//   * `UhdmWriter::lateBinding` walks `ref->VpiParent()` UPWARD and, on
//     reaching the design, binds by name out of `design->Parameters()`
//     (:3361-3370) — and that walk runs BEFORE the package rule that binds a
//     reference to its `param_assign`'s **Rhs** (:3814-3822).  So inside a
//     `$unit`-imported package every such reference names the DESIGN's stamped
//     copy, and the package's folded constant is only reached when the walk
//     never gets to the design.
//
// MEASURED (goldens; `tools/probe/r10uvm146repro/ct146cen`, `ct146fld`):
//   * SimpleUVM/default+testflags and Scoreboard/default each list **45**
//     `vpiParameter` + **45** `vpiParamAssign` on `design (work@top)`, all
//     `vpiImported=uvm_pkg`; ours listed **0/0**.
//   * The design copy agrees with BOTH package views on EVERY field
//     `parameter::Compare` reads (VpiDecompile/VpiSize/VpiConstType/VpiSigned/
//     Expr/Ranges/Left_range/Right_range/VpiLocalParam/VpiName/Typespec) and
//     differs ONLY in `vpiImported` — the LAST field that Compare reads.  A
//     copy that SHARES every child pointer therefore cannot move any earlier
//     field.  The `vpiParamAssign` half is the ELABORATED package view's:
//     `UVM_MACRO_EXTRAS`'s Rhs is an `operation` in the def listing and a
//     folded `constant` in both the elab listing and the design listing.
//   * 53 references per row-mode bind that copy in golden; ours bound the
//     package's folded `constant` (43) or `operation` (10).
//   * The 31 golden databases in the two corpora that carry such a listing at
//     all are these three row-modes plus 28 SLANG_REJECT/NO_DATABASE rows.
// ===========================================================================
static UHDM::parameter* designImportParamCopy146(UHDM::Serializer& s,
                                                 UHDM::any* src,
                                                 UHDM::BaseClass* parent,
                                                 const std::string& pkgName) {
    if (!src || src->UhdmType() != UHDM::uhdmparameter || pkgName.empty())
        return nullptr;
    auto* sp = (UHDM::parameter*)src;
    auto* cp = s.MakeParameter();
    const std::string nm(sp->VpiName());
    cp->VpiName(nm);
    cp->VpiValue(std::string(sp->VpiValue()));
    cp->VpiDecompile(std::string(sp->VpiDecompile()));
    cp->VpiSize(sp->VpiSize());
    cp->VpiConstType(sp->VpiConstType());
    cp->VpiSigned(sp->VpiSigned());
    cp->VpiLocalParam(sp->VpiLocalParam());
    cp->Typespec(sp->Typespec());
    cp->Expr(sp->Expr());
    cp->Ranges(sp->Ranges());
    cp->Left_range(sp->Left_range());
    cp->Right_range(sp->Right_range());
    cp->VpiUses(sp->VpiUses());
    cp->VpiFile(std::string(sp->VpiFile()));
    cp->VpiLineNo(sp->VpiLineNo());
    cp->VpiColumnNo(sp->VpiColumnNo());
    cp->VpiEndLineNo(sp->VpiEndLineNo());
    cp->VpiEndColumnNo(sp->VpiEndColumnNo());
    // Golden's design entry dumps its BARE name (`vpiFullName:UVM_STDOUT`),
    // never the package-qualified one.  VpiFullName is dump-only (never
    // compared) — matched so the whole-dump diff reads clean.
    cp->VpiFullName(nm);
    cp->VpiParent(parent);
    cp->VpiImported(pkgName);
    return cp;
}

// The TYPE-PARAMETER half.  `type_parameter::Compare` reads VpiType/VpiName/
// VpiDefName, VpiLocalParam, Typespec, Expr and — last — VpiImported, so the
// same share-every-child copy is enough.  Golden lists it in the SAME sorted
// `vpiParameter` vector as the value parameters and gives it NO `vpiParamAssign`
// (grid arm B: `parameter type K_type = logic [3:0]` in a `$unit`-imported
// package lands between `K_str` and `K_typed` and the design's param_assign
// listing stays at eight).
static UHDM::type_parameter* designImportTypeParamCopy146(
    UHDM::Serializer& s, UHDM::any* src, UHDM::BaseClass* parent,
    const std::string& pkgName) {
    if (!src || src->UhdmType() != UHDM::uhdmtype_parameter || pkgName.empty())
        return nullptr;
    auto* sp = (UHDM::type_parameter*)src;
    auto* cp = s.MakeType_parameter();
    const std::string nm(sp->VpiName());
    cp->VpiName(nm);
    cp->VpiLocalParam(sp->VpiLocalParam());
    cp->Typespec(sp->Typespec());
    cp->Expr(sp->Expr());
    cp->VpiFile(std::string(sp->VpiFile()));
    cp->VpiLineNo(sp->VpiLineNo());
    cp->VpiColumnNo(sp->VpiColumnNo());
    cp->VpiEndLineNo(sp->VpiEndLineNo());
    cp->VpiEndColumnNo(sp->VpiEndColumnNo());
    cp->VpiFullName(nm);
    cp->VpiParent(parent);
    cp->VpiImported(pkgName);
    return cp;
}

static UHDM::param_assign* designImportPaCopy146(UHDM::Serializer& s,
                                                 UHDM::param_assign* src,
                                                 UHDM::design* dsn,
                                                 const std::string& pkgName) {
    if (!src || !src->Lhs() || src->Lhs()->UhdmType() != UHDM::uhdmparameter)
        return nullptr;
    auto* cp = s.MakeParam_assign();
    cp->VpiConnByName(src->VpiConnByName());
    cp->VpiOverriden(src->VpiOverriden());
    // The Rhs (and any attributes) stay the package's objects: Surelog's
    // `clone_tree` deep-copies them, but every field `param_assign::Compare`
    // reaches through them is already equal to golden's — the package listing
    // this pass copies from is byte-equal to golden's own.
    cp->Rhs(src->Rhs());
    cp->Attributes(src->Attributes());
    cp->VpiFile(std::string(src->VpiFile()));
    cp->VpiLineNo(src->VpiLineNo());
    cp->VpiColumnNo(src->VpiColumnNo());
    cp->VpiEndLineNo(src->VpiEndLineNo());
    cp->VpiEndColumnNo(src->VpiEndColumnNo());
    cp->VpiParent(dsn);
    cp->Lhs(designImportParamCopy146(s, (UHDM::any*)src->Lhs(), cp, pkgName));
    return cp;
}

UHDM::design* UhdmExporter::exportDesign() {
    // § compoundLitWriteBackSat2 — decide the constant-evaluated function
    // bodies' literal values BEFORE anything is emitted, so the def view and
    // every elab copy agree on the one value golden's shared object carries.
    computeCompoundWriteBack();
    auto& root = comp.getRoot();
    computeParamMultiplicity();

    // Surelog applies a -P override under `instance->getParent() == nullptr`,
    // i.e. only to the DEFINITIONS of top-level instances -- and it mutates the
    // definition's own Parameter object, so both the def view and every
    // instance view of that definition see the effect.
    if (!cliParams.empty())
        for (auto* t : root.topInstances)
            cliTopDefs.insert(&t->getDefinition());

    d = s.MakeDesign();
    // Multi-top designs: Surelog names the design after (and lists tops in)
    // SOURCE order; slang's topInstances may differ.
    std::vector<const InstanceSymbol*> orderedTops(root.topInstances.begin(),
                                                   root.topInstances.end());
    // Driver-added SYNTHETIC tops (bind carriers) are not design tops: pull
    // them out; they are re-added below as uninstantiated def views only.
    std::vector<const InstanceSymbol*> synthTops;
    if (!syntheticTops.empty()) {
        auto mid = std::stable_partition(
            orderedTops.begin(), orderedTops.end(),
            [this](const InstanceSymbol* t) {
                return syntheticTops.count(
                           std::string(t->getDefinition().name)) == 0;
            });
        synthTops.assign(mid, orderedTops.end());
        orderedTops.erase(mid, orderedTops.end());
    }
    // A file-scope `program` is NOT a design top for Surelog. Measured on a
    // purpose-built golden pair (bare `program p1;` vs `program p1;` +
    // `module m1;`): in BOTH the program appears only in design->AllPrograms
    // as a DEF view (VpiName empty, VpiDefName work@p1) and never in
    // AllModules/TopModules; with no module top besides it the design is
    // `unnamed` with AllModules/TopModules NULL, and with a module top the
    // design is named after the MODULE. slang, by contrast, elaborates an
    // uninstantiated program as a root top instance. So pull program tops out
    // of orderedTops (they still get their AllPrograms def view below) —
    // instantiated programs (OneNetInterf/OneNetModPort/OneNetRange) are not
    // root tops in slang either, so they are untouched by this rule.
    std::vector<const InstanceSymbol*> progTops;
    {
        auto mid = std::stable_partition(
            orderedTops.begin(), orderedTops.end(),
            [](const InstanceSymbol* t) { return !isProgramDef(*t); });
        progTops.assign(mid, orderedTops.end());
        orderedTops.erase(mid, orderedTops.end());
    }
    std::stable_sort(orderedTops.begin(), orderedTops.end(),
                     [this](const InstanceSymbol* a, const InstanceSymbol* b) {
                         return srcOrderLess(a->getDefinition().location,
                                             b->getDefinition().location);
                     });
    if (!orderedTops.empty())
        d->VpiName("work@" + std::string(orderedTops[0]->getDefinition().name));
    else
        d->VpiName("unnamed"); // no top module: Surelog's unnamed design
    // NOTE (design-root family, TopParam): a module whose parameter has NO
    // default (`module top #(parameter param);`) is a design top for Surelog
    // (design `work@top`, TopModules = [top], the child getting an overriding
    // param_assign whose Rhs ref_obj resolves to top's own unset parameter),
    // but slang refuses it both automatically and under an explicit --top
    // ("'top' is not a valid top-level module"), so orderedTops comes back
    // empty and the design falls to `unnamed` with a null TopModules. Not
    // reachable without a slang change; the AllModules def views already match.

    // § dottedTopNameBareElab — measured on a 10-arm purpose-built grid
    // (tools/probe/r10yos1repro/grid.sh): a DESIGN TOP whose module name
    // contains a `.` (only reachable through an escaped identifier,
    // `module \a.b.C ... endmodule`) is NOT elaborated by Surelog.  Its
    // uhdmtopModules entry is a BARE module_inst — vpiParent(design),
    // vpiName/vpiDefName = work@<name>, vpiTop, vpiTopModule, the module's
    // source range — and carries NO nets, ports, cont_assigns, parameters,
    // processes or child instances at all ("Nb instances: 1 / Max instance
    // depth: 1" in Surelog's own log, even when the module instantiates
    // children).  The DEF view (uhdmallModules) is untouched and complete.
    // The grid pins every boundary:
    //   * the dot must be in the TOP's own name — `\a[0]`, `\a$b` and plain
    //     `\foo` tops all elaborate normally, so it is the DOT and not the
    //     escaping;
    //   * a dotted name on a CHILD module elaborates normally (h_dotchild);
    //   * the rule is PER TOP, not per design: in a two-top design the
    //     dotted top is bare while the plain top beside it is fully
    //     elaborated (i_multitop_onedot / j_plainfirst_dotsecond), and the
    //     design name / top ORDER are unaffected (source order, as always).
    // Surelog builds elaborated instance paths by concatenating with '.', so
    // a dotted top name makes its own hierarchical path unresolvable and the
    // instance tree comes back empty; only the top shell survives.
    std::set<const InstanceSymbol*> bareTops;
    for (auto* t : orderedTops)
        if (t->getDefinition().name.find('.') != std::string_view::npos)
            bareTops.insert(t);

    // Surelog attaches the include records before any model content.
    emitIncludeFileInfos();

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    std::set<std::string> uninstGenDefNames;
    // § dottedTopNameBareElab — BARE tops are collected LAST, so a def that an
    // ELABORATED top also instantiates takes its def-view representative from
    // the elaborated subtree.  MEASURED (a dotted top FIRST in source order
    // beside a plain top sharing one child, both instantiating `child`):
    // collectDefs keeps ONE representative instance per definition and
    // emitModuleDef fills that representative's DefInfo::nets keyed by ITS
    // body's symbols, while the port phase runs from whichever instance the
    // instance walk reaches FIRST (emitInstance's `!filled` fill).  A bare top
    // runs no walk, so the walk arrives from the OTHER top with a DIFFERENT
    // InstanceBodySymbol, every `netMap.find(internal)` in emitPorts misses,
    // and the def-view ports lose their LowConn actual: golden's
    // `port(a) |vpiLowConn ref_obj(work@child.a.a) |vpiActual logic_net
    // (work@child.a)` came back with a null actual (one uhdm-cmp head,
    // `LHS: logic_net(work@child.a)` / `RHS: <null>`), which the PRISTINE
    // binary got right.  Collecting bare tops last keeps the representative
    // and the filling instance the same object.  When no top is bare the two
    // passes are exactly the original single loop (byte-identical output).
    for (int barePass = 0; barePass < 2; ++barePass) {
        for (auto inst : orderedTops) {
            if ((bareTops.count(inst) != 0) != (barePass == 1))
                continue;
            auto name = std::string(inst->getDefinition().name);
            if (defs.emplace(name, inst).second)
                collectDefs(inst->body, defs, &uninstGenDefNames);
        }
    }
    // Parsed-but-unreferenced module definitions (an explicit --top prunes
    // them from the root) still get def views — Surelog compiles every parsed
    // module (load_and_derive testflags: ref_mod under -top dut). Only
    // safely-instantiable ones: modules with all params defaulted and no
    // interface ports.
    std::set<const DefinitionSymbol*> unrefDefs;
    auto addDefOnlyModule = [&](const DefinitionSymbol& udef) {
        if (udef.definitionKind != DefinitionKind::Module)
            return;
        if (defs.count(std::string(udef.name)))
            return;
        // Library-unit (-y/-v) modules compile on demand only — an unused
        // one gets NO def view (Surelog).
        if (!udef.sourceLibrary.isDefault ||
            (udef.syntaxTree && udef.syntaxTree->isLibraryUnit))
            return;
        bool allDefaulted = true;
        for (auto& up : udef.parameters)
            if (!up.hasDefault()) {
                allDefaulted = false;
                break;
            }
        if (!allDefaulted)
            return;
        // § uninstDefPortedAdmit — a def harvested from a NON-TAKEN GENERATE
        // BRANCH used to be admitted only when PORTLESS, because resolving the
        // port connections of a createDefault instance segfaults: slang leaves
        // such an instance out of every scope, so getParentScope() is null and
        // resolvePortConnections()'s SLANG_ASSERT(scope) is compiled out in
        // Release.  The crash is fixed at the one asker (ParamEmit's
        // collectImportedParams, § detachedInstNoConns), so PORTED defs are
        // admitted too — Surelog lists every parsed module DEFINITION in
        // uhdmallModules, and Earlgrey_0_1 has 13 of them (aes_sbox_canright*,
        // ibex_dummy_instr/icache/multdiv_slow, prim_secded_*, prim_xilinx_*).
        // INTERFACE-ported defs stay out (below): their connection resolution
        // is a different path that is still unmeasured.
        auto& uinst = InstanceSymbol::createDefault(comp, udef);
        bool ifacePorted = false;
        for (auto pb : uinst.body.getPortList())
            if (pb->kind == SymbolKind::InterfacePort) {
                ifacePorted = true;
                break;
            }
        if (ifacePorted)
            return;
        if (defs.emplace(std::string(udef.name), &uinst).second) {
            unrefDefs.insert(&udef);
            // § defOnlyNoArgTs — this listing is never elaborated.
            defOnlyDefs.insert(&udef);
            collectDefs(uinst.body, defs, &uninstGenDefNames);
        }
    };
    for (auto* udefSym : comp.getUnreferencedDefinitions())
        addDefOnlyModule(*udefSym);
    // § dottedTopNameBareElab — a BARE top runs no instance walk, so NOTHING
    // under it (the top's own def included) is ever reached by one: those defs
    // fill their port phase in the write-phase fallback below, name-sorted,
    // exactly like a def whose only "instance" never happened.  Defs an
    // ELABORATED top also reaches are protected by that fallback's `!filled`
    // guard, so listing them here is safe in a mixed multi-top design.
    // INTERFACE defs are EXCLUDED: the write-phase fallback calls
    // emitModuleDefPorts, which reads DefInfo::mod, and an interface def has no
    // DefInfo::mod at all (its shell lives in ifaceDefMap, see the def-shell
    // pre-pass) — every other unrefDefs producer is module/program-only for
    // exactly this reason.  MEASURED: without this guard
    // `module \a.b.C (input x, output y); plainif bus(); ... endmodule`
    // SEGFAULTS the exporter (null DefInfo::mod dereference) where the
    // pristine binary writes a database; probe arm
    // tools/probe/r10yos1repro/grid/k_dottopiface.sv.
    for (auto* bt : bareTops) {
        std::map<std::string, const InstanceSymbol*> sub;
        sub.emplace(std::string(bt->getDefinition().name), bt);
        collectDefs(bt->body, sub, &uninstGenDefNames);
        for (auto& [n9, i9] : sub) {
            if (useInterfacePath(*i9))
                continue;
            unrefDefs.insert(&i9->getDefinition());
        }
    }
    // Modules instantiated ONLY inside a non-taken generate branch: slang never
    // reports them as unreferenced, but Surelog still compiled them, so they
    // carry the same def-view-only entry in AllModules. A def added here can
    // itself hide further non-taken branches, so run to a fixpoint over a
    // snapshot (collectDefs keeps appending to uninstGenDefs).
    //
    // NOTE (design-root family): this closes the design ROOT of HierPathEval
    // and UnsignedParam, both of which then diverge on CONSTANT EVALUATION,
    // not on containers:
    //   * HierPathEval — `.PadType(TargetCfg.dio_pad_type)` where TargetCfg is
    //     a 2-bit packed struct {logic a; pad_type_e dio_pad_type} = 'b10.
    //     slang folds the member select to 0 (first member is the MSB, per
    //     LRM); Surelog folds it to 1. Matching golden means reproducing
    //     Surelog's LSB-first member offset for this fold — do not do it
    //     globally, it would break every converged packed-struct fold.
    //   * UnsignedParam — `localparam signed [63:0] n` gives golden an
    //     int_typespec with vpiSigned:1 that we do not set (a real, separate
    //     gap), and beyond it `n4 == 10376293541461622783` is TRUE for Surelog
    //     (64-bit unsigned) and FALSE for slang (the unsized decimal needs 65
    //     bits as a SIGNED value), so the `GOOD good();` generate branch is
    //     taken in golden's topModules and not in ours. Not reachable without
    //     a slang change.
    std::set<std::string> genDefsDone;
    for (bool changed = true; changed;) {
        changed = false;
        std::vector<std::string> pending(uninstGenDefNames.begin(),
                                         uninstGenDefNames.end());
        for (auto& gname : pending) {
            if (!genDefsDone.insert(gname).second)
                continue;
            changed = true;
            for (auto* sym : comp.getDefinitions())
                if (sym->kind == SymbolKind::Definition && sym->name == gname) {
                    addDefOnlyModule(sym->as<DefinitionSymbol>());
                    break;
                }
        }
    }
    // Uninstantiated file-scope `program`s: def views only (AllPrograms),
    // filled like an unreferenced def in the write phase; never design tops.
    for (auto* pt : progTops)
        if (defs.emplace(std::string(pt->getDefinition().name), pt).second) {
            unrefDefs.insert(&pt->getDefinition());
            uninstProgDefs.insert(&pt->getDefinition());
            collectDefs(pt->body, defs, &uninstGenDefNames);
        }
    // Synthetic (bind-carrier) tops: def views only, filled like an
    // unreferenced def in the write phase; never emitted as tops.
    for (auto* st : synthTops)
        if (defs.emplace(std::string(st->getDefinition().name), st).second) {
            unrefDefs.insert(&st->getDefinition());
            collectDefs(st->body, defs);
        }
    // Bound-child display paths (see bindDefDisplay).
    for (auto* ti : orderedTops)
        for (auto& member : ti->body.members()) {
            if (member.kind != SymbolKind::Instance)
                continue;
            auto& child = member.as<InstanceSymbol>();
            bool fromBind9 = false;
            for (auto p2 = child.getSyntax(); p2; p2 = p2->parent)
                if (p2->kind == syntax::SyntaxKind::BindDirective) {
                    fromBind9 = true;
                    break;
                }
            if (fromBind9)
                bindDefDisplay.emplace(
                    &child.getDefinition(),
                    "work@" + std::string(ti->getDefinition().name) + "." +
                        std::string(child.name));
        }
    // A design with NO top (recursive_map: every module is instantiated,
    // recursively) still carries every module definition in allModules —
    // Surelog compiles defs regardless of elaboration. Build uninstantiated
    // def views; their child instantiations become UninstantiatedDefSymbols
    // (ref_module stubs), so recursion cannot loop.
    if (orderedTops.empty()) {
        for (auto sym : comp.getDefinitions()) {
            if (sym->kind != SymbolKind::Definition)
                continue;
            auto& defSym = sym->as<DefinitionSymbol>();
            if (defSym.definitionKind != DefinitionKind::Module)
                continue;
            auto& inv = InstanceSymbol::createInvalid(comp, defSym);
            defs.emplace(std::string(defSym.name), &inv);
        }
    }
    // Surelog also lists UN-INSTANTIATED interface definitions in
    // AllInterfaces (iface_method_call intf2) — emit them from a default
    // parameterization. Modules stay instance-driven.
    for (auto defSym : comp.getDefinitions()) {
        if (defSym->kind != SymbolKind::Definition)
            continue;
        auto& d9 = defSym->as<DefinitionSymbol>();
        if (d9.definitionKind != DefinitionKind::Interface)
            continue;
        if (defs.count(std::string(d9.name)))
            continue;
        auto& di9 = InstanceSymbol::createDefault(comp, d9);
        defs.emplace(std::string(d9.name), &di9);
    }

    // User packages (skip built-ins).
    std::vector<const PackageSymbol*> pkgs;
    for (auto pkg : comp.getPackages()) {
        if (pkg->name != "std" && pkg->name != "$unit")
            pkgs.push_back(pkg);
    }
    // Surelog keeps source (compile) order; slang name-sorts.
    std::stable_sort(pkgs.begin(), pkgs.end(), [this](auto* a, auto* b) {
        return srcOrderLess(a->location, b->location);
    });
    // Which packages are wildcard-imported by a module body (their
    // nested-container struct typedefs take a special TOP form).
    for (auto& [name, inst] : defs)
        for (auto& mem : inst->body.members())
            if (mem.kind == SymbolKind::WildcardImport)
                if (auto* p0 = comp.getPackage(
                        mem.as<WildcardImportSymbol>().packageName))
                    wildcardImportedPkgs.insert(p0);
    for (auto pkg : pkgs)
        for (auto& mem : pkg->members()) {
            std::string_view pn9;
            if (mem.kind == SymbolKind::WildcardImport)
                pn9 = mem.as<WildcardImportSymbol>().packageName;
            else if (mem.kind == SymbolKind::ExplicitImport)
                pn9 = mem.as<ExplicitImportSymbol>().packageName;
            else
                continue;
            if (auto* tp9 = comp.getPackage(pn9))
                pkgImportedByPkg.insert(tp9);
        }
    if (!pkgs.empty()) {
        auto* allP = s.MakePackageVec();
        for (auto pkg : pkgs)
            allP->push_back(emitPackage(*pkg, false));
        d->AllPackages(allP);
        // Surelog builds both package views before any module.
        auto* topP = s.MakePackageVec();
        for (auto pkg : pkgs)
            topP->push_back(emitPackage(*pkg, true));
        d->TopPackages(topP);
        // A call BETWEEN package functions (prim_util_pkg::vbits calling
        // prim_util_pkg::_clog2) binds the callee in the ELABORATED (top)
        // package view in BOTH copies — Surelog resolves package calls after
        // it has built the top views, so the def copy's own function object is
        // never the callee. Module-level calls already bind the top view (they
        // are emitted after this point), so the sweep only reaches calls made
        // inside a package. EvalFunc.
        for (auto& pr : s.AllObjects()) {
            if (!pr.first ||
                pr.first->UhdmType() != UHDM::uhdmfunc_call)
                continue;
            auto* fc = (UHDM::func_call*)pr.first;
            auto* callee = fc->Function();
            if (!callee)
                continue;
            const UHDM::instance* home = callee->Instance();
            if (!home)
                continue;
            size_t pi = allP->size();
            for (size_t i = 0; i < allP->size(); i++)
                if ((*allP)[i] == home)
                    pi = i;
            if (pi == allP->size())
                continue;
            // § pkgDefCallBindsOwnListing173 — THE GATE ON THE REBIND ABOVE.
            //
            //   A CALL EMITTED INSIDE A PACKAGE'S **DEF** LISTING
            //   (`design->AllPackages`) BINDS *THAT LISTING'S OWN TWIN* OF A
            //   FUNCTION OF THE SAME PACKAGE.  ONLY AN EXPLICITLY
            //   PACKAGE-QUALIFIED WRITTEN SPELLING — `<home package>::<name>`
            //   — IS RE-POINTED AT THE ELABORATED TWIN.
            //
            // The rule above ("a call BETWEEN package functions binds the top
            // view in BOTH copies") was read off EvalFunc, whose one cell is
            // `return (value == 1) ? 1 : prim_util_pkg::_clog2(value);` — a
            // call written WITH the package qualifier.  It was generalised to
            // every package-internal call, and on a package the size of
            // uvm_pkg that over-fires by three orders of magnitude.  Measured
            // on SimpleUVM (`tools/probe/r10uvm173repro/ct173bind.cpp`, one
            // row per bound call, keyed by the listing the CALL lives in ->
            // the listing the CALLEE lives in; LHS always golden):
            //
            //   golden  PKGDEF->PKGDEF  1014   PKGDEF->PKGELAB  3
            //   ours    PKGDEF->PKGDEF     1   PKGDEF->PKGELAB  1016
            //
            // and golden's THREE exceptions are, by name, the three
            // `uvm_pkg::m_uvm_string_queue_join` calls the
            // `UVM_STRING_QUEUE_STREAMING_PACK` macro writes
            // (uvm_macros.svh:37) — the package-qualified spelling, exactly
            // EvalFunc's shape.  The 1014 golden keeps on the def twin are
            // unqualified (`uvm_report_enabled`, `uvm_is_match`, ...), and so
            // are the two CLASS-qualified ones (`uvm_root::get`,
            // `uvm_reg_field::get_max_size`): the qualifier that moves a call
            // is the HOME PACKAGE's name, not any `::`.
            //
            // WHY THE JUDGE SEES IT.  `func_call::Compare` walks
            // `vpiFunction`, so a def-listing call bound to our elaborated
            // twin pairs GOLDEN's def-listing body against OURS elaborated
            // body — two listings that legitimately differ.  The SimpleUVM
            // head was exactly that: golden's def-view `uvm_is_match` leaves
            // the `uvm_re_match(s, str)` actual bare while every ELABORATED
            // listing (golden's and ours alike) stamps the formal's
            // `string_typespec` on it, so the crossing printed as
            // `LHS: <null>` against our `ref_typespec` at
            // uvm_globals.svh:403:24 — a typespec-shaped head with no
            // typespec defect under it (the argument cells agree edge for
            // edge in both views; CENSUS.r10uvm173.txt).
            //
            // WHAT COUNTS AS "PACKAGE-QUALIFIED" — read off the CROSS-PACKAGE
            // arm (`g173_b_cross.sv`), which is the only place the two candidate
            // spellings of the test come apart.  `tinderPkg`'s def listing calls
            // `flintPkg::emberCount` (qualified, ANOTHER package) and, through a
            // wildcard import, `emberCount` (unqualified, the same function):
            // golden binds the ELABORATED twin for the first and the def twin
            // for the second.  Our own emitter reaches the second through a
            // wildcard-import CLONE whose home package is the CALLER's, so
            // testing the qualifier against the CALLEE'S home package name got
            // `flintPkg::emberCount` wrong (it moved the cell AWAY from golden,
            // caught by this arm before delivery).  The test that carries every
            // measured cell is the WRITTEN one: does the name begin with
            // `<some package of this design>::`?  That admits `quill_pkg::tally`,
            // `flintPkg::emberCount`, `prim_util_pkg::_clog2` and
            // `uvm_pkg::m_uvm_string_queue_join`, and correctly REFUSES the
            // CLASS-qualified statics `uvm_root::get`,
            // `uvm_reg{,_field}::get_max_size` and `uvm_mem::get_max_size`,
            // which golden keeps on the def twin.
            bool defListingCall173 = false;
            {
                const UHDM::BaseClass* r173 = fc;
                for (int g173 = 0;
                     r173 && r173->VpiParent() &&
                     r173->VpiParent()->UhdmType() != UHDM::uhdmdesign &&
                     g173 < 4096;
                     ++g173)
                    r173 = r173->VpiParent();
                for (auto* dp173 : *allP)
                    if ((const UHDM::BaseClass*)dp173 == r173) {
                        defListingCall173 = true;
                        break;
                    }
            }
            if (defListingCall173) {
                const std::string cn173(fc->VpiName());
                const size_t sep173 = cn173.find("::");
                bool pkgQualified173 = false;
                if (sep173 != std::string::npos) {
                    const std::string qual173 = cn173.substr(0, sep173);
                    for (auto* dp173 : *allP)
                        if (dp173->VpiName() == qual173) {
                            pkgQualified173 = true;
                            break;
                        }
                }
                if (!pkgQualified173)
                    continue;
            }
            auto* tf = (*topP)[pi]->Task_funcs();
            if (!tf)
                continue;
            for (auto* t : *tf)
                if (t->UhdmType() == UHDM::uhdmfunction &&
                    t->VpiName() == callee->VpiName()) {
                    fc->Function((UHDM::function*)t);
                    break;
                }
        }
        // ...and a wildcard-import clone's vpiReturn is the ELABORATED home
        // function's return variable (§ pkgCloneRetFixups9).
        for (auto& [cl9, hp9] : pkgCloneRetFixups9) {
            auto tit9 = pkgTopMap.find(hp9);
            if (tit9 == pkgTopMap.end() || !tit9->second->Task_funcs())
                continue;
            std::string want9 = std::string(hp9->name) +
                                "::" + std::string(cl9->VpiName());
            for (auto* t9 : *tit9->second->Task_funcs())
                if (t9->UhdmType() == UHDM::uhdmfunction &&
                    t9->VpiFullName() == want9) {
                    cl9->Return(((UHDM::function*)t9)->Return());
                    break;
                }
        }
        // Import-clone typespecs point vpiInstance at the ELABORATED (top)
        // home package, which only exists now that the top views are built.
        for (auto& [cts, pn] : importCopyTsFixups)
            for (auto* tp : *topP)
                if (tp->VpiName() == pn) {
                    cts->Instance(tp);
                    break;
                }
        // Cross-package def-init param refs re-point at the ELAB home-package
        // parameter (Surelog's def-view init ref reaches the folded elab param).
        for (auto& [ref, homeSym, pname] : pkgCrossRefTopFixups) {
            auto tit = pkgTopMap.find(homeSym);
            if (tit != pkgTopMap.end() && tit->second->Parameters())
                for (auto* pp : *tit->second->Parameters())
                    if (pp->VpiName() == pname) {
                        ref->Actual_group(pp);
                        break;
                    }
        }
        pkgCrossRefTopFixups.clear();
        // Materialized-import param typespecs created in the DEF package pass
        // reach the ELABORATED home package too (same rule as the import
        // clones above) — BitSelectOfParameterPassedToSubmodule.
        for (auto& [ts9, home9] : pkgImportTsTopFixups)
            if (auto tit9 = pkgTopMap.find(home9); tit9 != pkgTopMap.end())
                ts9->Instance(tit9->second);
        pkgImportTsTopFixups.clear();
        // A package subroutine that names ANOTHER package's typedef binds the
        // ELABORATED listing object in both views (Surelog) — the def pass
        // could only reach the def object, so re-point now (PackFunc).
        for (auto& [rt9, aliasT9] : pkgForeignTsTopFixups)
            if (auto t9 = pkgTopTypedefTs.find((const void*)aliasT9);
                t9 != pkgTopTypedefTs.end() && t9->second)
                rt9->Actual_typespec(t9->second);
        pkgForeignTsTopFixups.clear();
        // A DEF-view package TYPEDEF listing whose symbolic member bound names
        // ANOTHER package's parameter ([top_pkg::TL_SZW-1:0] inside
        // tlul_pkg::tl_h2d_t) binds the ELABORATED (folded) home parameter —
        // the same rule pkgCrossRefTopFixups applies to def-view cross-package
        // param INITS, here for type ranges. Done structurally because the
        // bound ref is minted by several range-builder arms; the def→top param
        // swap is keyed on the def param object, so only refs that actually
        // reached a FOREIGN package's def listing move (Surelog,
        // PackStructVar). A SAME-package bound is untouched: its def param is
        // not in the foreign map.
        {
            // def parameter object -> (owning def package, elab twin)
            std::map<const UHDM::any*, std::pair<UHDM::package*, UHDM::any*>>
                defParamTwin;
            for (auto* dp0 : *allP) {
                UHDM::package* tp0 = nullptr;
                for (auto* t0 : *topP)
                    if (t0->VpiName() == dp0->VpiName()) {
                        tp0 = t0;
                        break;
                    }
                if (!tp0 || !dp0->Parameters() || !tp0->Parameters())
                    continue;
                for (auto* p0 : *dp0->Parameters())
                    for (auto* p1 : *tp0->Parameters())
                        if (p0->VpiName() == p1->VpiName()) {
                            defParamTwin[p0] = {dp0, p1};
                            break;
                        }
            }
            std::function<void(UHDM::any*, UHDM::package*)> fixExpr =
                [&](UHDM::any* e, UHDM::package* home) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r0 = (UHDM::ref_obj*)e;
                        if (auto* act = r0->Actual_group())
                            if (auto it0 = defParamTwin.find(act);
                                it0 != defParamTwin.end() &&
                                it0->second.first != home)
                                r0->Actual_group(it0->second.second);
                        return;
                    }
                    if (e->UhdmType() == UHDM::uhdmoperation)
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* o0 : *ops)
                                fixExpr(o0, home);
                };
            auto fixRanges = [&](UHDM::VectorOfrange* rs, UHDM::package* home) {
                if (!rs)
                    return;
                for (auto* r0 : *rs) {
                    fixExpr((UHDM::any*)r0->Left_expr(), home);
                    fixExpr((UHDM::any*)r0->Right_expr(), home);
                }
            };
            std::function<void(UHDM::typespec*, UHDM::package*, int)> fixTs =
                [&](UHDM::typespec* t0, UHDM::package* home, int depth) {
                    if (!t0 || depth > 8)
                        return;
                    switch (t0->UhdmType()) {
                        case UHDM::uhdmlogic_typespec:
                            fixRanges(((UHDM::logic_typespec*)t0)->Ranges(),
                                      home);
                            break;
                        case UHDM::uhdmbit_typespec:
                            fixRanges(((UHDM::bit_typespec*)t0)->Ranges(), home);
                            break;
                        case UHDM::uhdmpacked_array_typespec: {
                            auto* pt0 = (UHDM::packed_array_typespec*)t0;
                            fixRanges(pt0->Ranges(), home);
                            if (pt0->Elem_typespec())
                                fixTs(pt0->Elem_typespec()->Actual_typespec(),
                                      home, depth + 1);
                            break;
                        }
                        case UHDM::uhdmarray_typespec: {
                            auto* at0 = (UHDM::array_typespec*)t0;
                            fixRanges(at0->Ranges(), home);
                            if (at0->Elem_typespec())
                                fixTs(at0->Elem_typespec()->Actual_typespec(),
                                      home, depth + 1);
                            break;
                        }
                        case UHDM::uhdmstruct_typespec:
                            if (auto* ms =
                                    ((UHDM::struct_typespec*)t0)->Members())
                                for (auto* m0 : *ms)
                                    if (m0->Typespec())
                                        fixTs(m0->Typespec()->Actual_typespec(),
                                              home, depth + 1);
                            break;
                        case UHDM::uhdmunion_typespec:
                            if (auto* ms =
                                    ((UHDM::union_typespec*)t0)->Members())
                                for (auto* m0 : *ms)
                                    if (m0->Typespec())
                                        fixTs(m0->Typespec()->Actual_typespec(),
                                              home, depth + 1);
                            break;
                        default:
                            break;
                    }
                };
            for (auto* dp0 : *allP)
                if (dp0->Typespecs())
                    for (auto* t0 : *dp0->Typespecs())
                        fixTs(t0, dp0, 0);
            // An UNPACKED-array member's WRAPPER array_typespec carries no
            // vpiInstance: Surelog instances the ELEMENT typespec it compiled
            // in the package scope and synthesizes the wrapper around it.
            // Several passes stamp member actuals with the package, so the
            // wrapper is cleared once here, after all of them have run.
            // Instance() is cmp-relevant (typespec::Compare recurses it), so
            // leaving it set is a hard blocker (HierPathUnpacked
            // keymgr_pkg::foo_t.pair).
            auto bareWrapInst = [](UHDM::VectorOftypespec_member* mems) {
                if (!mems)
                    return;
                for (auto* tm0 : *mems) {
                    if (!tm0->Typespec())
                        continue;
                    auto* at0 = tm0->Typespec()->Actual_typespec();
                    if (!at0 || at0->UhdmType() != UHDM::uhdmarray_typespec ||
                        !at0->Instance())
                        continue;
                    auto* er0 = ((UHDM::array_typespec*)at0)->Elem_typespec();
                    if (!er0 || !er0->Actual_typespec())
                        continue;
                    auto* ea0 = er0->Actual_typespec();
                    if (ea0->VpiName().empty() && ea0->Instance()) {
                        at0->Instance(nullptr);
                        continue;
                    }
                    // § structMemberWrittenQueueArrayTs149 — the QUEUE marker
                    // wrapper carries no vpiInstance EITHER, whatever its
                    // element is.  Surelog instances the typespec it compiled
                    // for the member's data type and then synthesizes the
                    // marker wrapper around it (CompileType.cpp:1745-1760);
                    // ours stamps the member's OUTERMOST typespec, so the
                    // stamp lands on the wrapper and the element loses it.
                    // Hand it down (only to an element that has none) and
                    // clear the wrapper.  GATE: a NAMELESS array_typespec
                    // whose SINGLE range carries the `$` marker — the queue
                    // signature and nothing else, so the fixed-dimension
                    // wrapper family above is untouched.  Measured on arm
                    // `elems` cells clsQ / enumQ / nestQ / tdefQ, where
                    // golden's wrapper is instance-less and its element
                    // carries the package.
                    auto* aq0 = (UHDM::array_typespec*)at0;
                    if (!aq0->VpiName().empty() || !aq0->Ranges() ||
                        aq0->Ranges()->size() != 1)
                        continue;
                    auto* rq0 = (*aq0->Ranges())[0];
                    auto unb0 = [](const UHDM::any* e) {
                        return e && e->UhdmType() == UHDM::uhdmconstant &&
                               ((const UHDM::constant*)e)->VpiConstType() ==
                                   vpiUnboundedConst;
                    };
                    if (!unb0(rq0->Left_expr()) && !unb0(rq0->Right_expr()))
                        continue;
                    if (!ea0->Instance())
                        ea0->Instance(at0->Instance());
                    at0->Instance(nullptr);
                }
            };
            for (auto* pv0 : {allP, topP})
                if (pv0)
                    for (auto* dp0 : *pv0)
                        if (dp0->Typespecs())
                            for (auto* t0 : *dp0->Typespecs()) {
                                if (t0->UhdmType() == UHDM::uhdmstruct_typespec)
                                    bareWrapInst(((UHDM::struct_typespec*)t0)
                                                     ->Members());
                                else if (t0->UhdmType() ==
                                         UHDM::uhdmunion_typespec)
                                    bareWrapInst(((UHDM::union_typespec*)t0)
                                                     ->Members());
                            }
        }
        // NOTE: a pkg consumed by ANOTHER package keeps its DEF listing bound
        // to its OWN typedef objects (rp32 riscv_priv_pkg csr_adr_t.perm ->
        // the home csr_perm_t, riscv_isa_pkg isa_t.spec -> the home
        // isa_spec_t). The importer's clone carries the clone bindings, wired
        // where the clone is built (emitPackage). An earlier revision
        // repointed the DEF listing here instead, which exchanged the two
        // views' member actuals.
    }
    // --builtins: the synthesized `builtin` package heads both lists.
    if (builtins) {
        auto* allP = d->AllPackages();
        auto* topP = d->TopPackages();
        emitBuiltinPackage(allP, topP);
        d->AllPackages(allP);
        d->TopPackages(topP);
    }

    // File-level ($unit) parameters -> DESIGN-level Parameters/Param_assigns
    // (name-only, typespecs materialized at the very end).
    {
        auto* uparams = s.MakeAnyVec();
        auto* upassigns = s.MakeParam_assignVec();
        // A $unit parameter's folded value carries Surelog's ExprEval
        // ENCODING, not slang's: `5'd7` stays `DEC:7` at size 5 with
        // vpiDecompile `5'd7`, `7'h4` stays `HEX:4`, and a computed bound
        // takes the sign UHDM's `ExprEval::reduceExpr` would give it —
        // vpiSubOp/vpiMultOp always produce `INT:`/vpiIntConst while
        // vpiAddOp is unsigned only when NEITHER operand reduced to an
        // int/dec/string/real constant (ExprEval.cpp vpiAddOp's
        // `unsignedOperation`).  A bare reference to another $unit parameter
        // inherits that parameter's whole encoding (Surelog reuses the
        // reduced constant).  constant::Compare reads VpiConstType /
        // VpiDecompile / VpiSize, so all three are load-bearing.
        struct UnitEnc {
            std::string value;      // "DEC:7"
            std::string decompile;  // "5'd7"
            int32_t size = 0;
            int32_t constType = vpiUIntConst;
            bool wantTs = true;
            bool ok = false;
        };
        std::map<const Symbol*, UnitEnc> unitEnc;
        // Decompose an integer literal's source text into (base, digits,
        // declared size).  base is 0 when the literal is unbased.
        auto litParts = [&](const Expression& e, char& base,
                            std::string& digits, int32_t& size) -> bool {
            if (e.kind != ExpressionKind::IntegerLiteral)
                return false;
            // A MACRO-SIZED based literal (`\`SCR1_XLEN'd8`) spans two
            // buffers, so plain `rawText` reads the expansion buffer and the
            // base/size decode falls through to a bare 64-bit decimal.
            // `rawTextLit` rebuilds it from the token stream, which is what
            // Surelog reduces (golden keeps DEC:8 / `32'd8`).
            std::string raw = rawTextLit(e);
            if (raw.empty())
                return false;
            auto tick = raw.find('\'');
            if (tick == std::string::npos) {
                base = 0;
                digits = stripSep(raw);
                size = -1;
                return true;
            }
            size_t bp = tick + 1;
            if (bp < raw.size() && (raw[bp] == 's' || raw[bp] == 'S'))
                bp++;
            base = bp < raw.size() ? (char)tolower(raw[bp]) : 'd';
            digits = stripSep(raw.substr(bp + 1));
            std::string szTxt = stripSep(raw.substr(0, tick));
            size = szTxt.empty() ? -1 : (int32_t)strtol(szTxt.c_str(), nullptr, 10);
            return true;
        };
        auto baseConstType = [](char base) -> int32_t {
            switch (base) {
                case 'b': return vpiBinaryConst;
                case 'o': return vpiOctConst;
                case 'h': return vpiHexConst;
                default: return vpiDecConst;
            }
        };
        auto baseTag = [](char base) -> const char* {
            switch (base) {
                case 'b': return "BIN:";
                case 'o': return "OCT:";
                case 'h': return "HEX:";
                default: return "DEC:";
            }
        };
        // The vpiConstType `reduceExpr` would hand back for a sub-expression —
        // only its INT/DEC-ness matters to vpiAddOp's unsigned test.
        std::function<int32_t(const Expression&)> reducedType =
            [&](const Expression& e0) -> int32_t {
            const Expression& e = stripImplicitConv(e0);
            char b = 0;
            std::string dg;
            int32_t sz = 0;
            if (litParts(e, b, dg, sz))
                return b ? baseConstType(b) : vpiUIntConst;
            if (e.kind == ExpressionKind::NamedValue) {
                auto& sym = e.as<NamedValueExpression>().symbol;
                if (auto it = unitEnc.find(&sym); it != unitEnc.end())
                    return it->second.constType;
                if (sym.kind == SymbolKind::Parameter)
                    if (auto* i2 = sym.as<ParameterSymbol>().getInitializer())
                        return reducedType(*i2);
                return vpiUIntConst;
            }
            if (e.kind == ExpressionKind::Call)
                return vpiUIntConst;
            // An EXPLICIT size cast (`W'(x)`) reduces UNSIGNED: reduceExpr
            // masks the operand to the cast width and hands back a UINT,
            // whatever the operand reduced to (Scr1SvTests
            // SCR1_IRQ_VOID_VECT_NUM `SCR1_IRQ_VECT_WIDTH'(...)`,
            // SCR1_HDU_DBGCSR_OFFS_* `WIDTH'('d0)`).  The knock-on matters as
            // much as the cast itself: vpiAddOp's `unsignedOperation` test
            // reads this, so a cast feeding an add (SCR1_HDU_DBGCSR_ADDR_*)
            // keeps the SUM unsigned too.
            if (e.kind == ExpressionKind::Conversion)
                return vpiUIntConst;
            if (e.kind == ExpressionKind::UnaryOp)
                return vpiIntConst;
            if (e.kind == ExpressionKind::BinaryOp) {
                auto& be = e.as<BinaryExpression>();
                // Bitwise and shift reductions are unsigned in ExprEval, the
                // same as a cast (Scr1SvTests SCR1_CSR_MISA
                // `(MXL << (`SCR1_XLEN-2)) | `SCR1_RVI_ENC | ...`).
                switch (be.op) {
                    case BinaryOperator::BinaryAnd:
                    case BinaryOperator::BinaryOr:
                    case BinaryOperator::BinaryXor:
                    case BinaryOperator::BinaryXnor:
                    case BinaryOperator::LogicalShiftLeft:
                    case BinaryOperator::LogicalShiftRight:
                    case BinaryOperator::ArithmeticShiftLeft:
                    case BinaryOperator::ArithmeticShiftRight:
                        return vpiUIntConst;
                    default:
                        break;
                }
                if (be.op == BinaryOperator::Add) {
                    auto sgn = [&](const Expression& o) {
                        int32_t t = reducedType(o);
                        return t == vpiIntConst || t == vpiDecConst ||
                               t == vpiStringConst || t == vpiRealConst;
                    };
                    return (sgn(be.left()) || sgn(be.right())) ? vpiIntConst
                                                               : vpiUIntConst;
                }
                return vpiIntConst;
            }
            return vpiIntConst;
        };
        for (auto unit : comp.getCompilationUnits()) {
            for (auto& mem : unit->members()) {
                if (mem.kind != SymbolKind::Parameter)
                    continue;
                auto& ps = mem.as<ParameterSymbol>();
                auto* up = s.MakeParameter();
                up->VpiName(ps.name);
                up->VpiParent(d);
                setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));
                auto& cv = ps.getValue();
                // Only an EXPLICITLY typed $unit parameter carries
                // signedness (`parameter int X` yes, `parameter X = 16` no) —
                // parameter::Compare reads VpiSigned, and slang types an
                // untyped param `int`, i.e. signed.
                bool typedDecl9 = false;
                if (auto declared9 = ps.getDeclaredType())
                    if (auto tsyn9 = declared9->getTypeSyntax())
                        typedDecl9 =
                            tsyn9->kind != syntax::SyntaxKind::ImplicitType;
                if (typedDecl9 && ps.getType().getCanonicalType().isSigned())
                    up->VpiSigned(true);
                // parameter::Compare reads VpiLocalParam — a $unit
                // `localparam` carries it exactly like a module one.
                for (auto q9 = ps.getSyntax(); q9; q9 = q9->parent)
                    if (q9->kind == syntax::SyntaxKind::ParameterDeclaration) {
                        if (q9->as<syntax::ParameterDeclarationSyntax>()
                                .keyword.valueText() == "localparam")
                            up->VpiLocalParam(true);
                        break;
                    }
                UnitEnc enc;
                const Expression* initE = ps.getInitializer();
                // Surelog compiles each command-line file's FileContent on its
                // own, and a guarded header is textually included by exactly
                // ONE of them — so a $unit parameter declared in a header owned
                // by file A is NOT in scope for the reducer when it folds a
                // $unit parameter declared in a header owned by file B.  The
                // init then stays an UNFOLDED expression: the parameter carries
                // no value (its typespec survives) and the param_assign keeps
                // a bare ref_obj / operation whose refs are DANGLING.
                // The property is transitive — an init reading a $unit
                // parameter that itself never folded cannot fold either
                // (`SCR1_TDU_ALLTRIG_NUM = SCR1_TDU_MTRIG_NUM + 1'b1`, both in
                // scr1_tdu.svh, unfolded because MTRIG_NUM reads
                // scr1_arch_description.svh's SCR1_TDU_TRIG_NUM).
                const syntax::ExpressionSyntax* initSyn9 = nullptr;
                if (auto dsyn9 = ps.getSyntax();
                    dsyn9 && dsyn9->kind == syntax::SyntaxKind::Declarator)
                    if (auto* iv9 = dsyn9->as<syntax::DeclaratorSyntax>().initializer)
                        initSyn9 = iv9->expr;
                std::string psRoot9 = rootFilePath(ps.location);
                std::function<bool(const syntax::SyntaxNode&)> readsUnres9 =
                    [&](const syntax::SyntaxNode& n9) -> bool {
                    if (n9.kind == syntax::SyntaxKind::IdentifierName) {
                        auto nm9 = n9.as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText();
                        auto* scope9 = ps.getParentScope();
                        if (!scope9)
                            return false;
                        auto* sym9 = scope9->lookupName(nm9);
                        if (!sym9 || !unitParamMap.count(sym9))
                            return false;
                        if (rootFilePath(sym9->location) != psRoot9)
                            return true;
                        auto it9 = unitEnc.find(sym9);
                        return it9 != unitEnc.end() && !it9->second.ok;
                    }
                    for (size_t i9 = 0; i9 < n9.getChildCount(); i9++)
                        if (auto* c9 = n9.childNode(i9))
                            if (readsUnres9(*c9))
                                return true;
                    return false;
                };
                bool unresolvedInit9 = initSyn9 && readsUnres9(*initSyn9);
                // Surelog's `reduceExpr` folds arithmetic but NOT a
                // concatenation/replication: `{2'b01, 2'b10}` stays an
                // operation and its parameter carries neither a value nor a
                // typespec.  Emitting a folded constant there would be worse
                // than emitting nothing.
                bool unfoldableInit9 = false;
                if (initE) {
                    auto k9 = stripImplicitConv(*initE).kind;
                    unfoldableInit9 = k9 == ExpressionKind::Concatenation ||
                                      k9 == ExpressionKind::Replication;
                }
                if (unresolvedInit9)
                    unfoldableInit9 = true;
                if (initE && !unfoldableInit9 &&
                    stripImplicitConv(*initE).kind ==
                        ExpressionKind::StringLiteral) {
                    auto& sl9 = stripImplicitConv(*initE);
                    std::string txt(sl9.as<StringLiteral>().getValue());
                    enc.value = "STRING:" + txt;
                    enc.decompile = std::string(rawText(sl9.sourceRange));
                    enc.size = (int32_t)(txt.size() * 8);
                    enc.constType = vpiStringConst;
                    enc.ok = true;
                    up->VpiValue(enc.value);
                }
                else if (initE && !unfoldableInit9 &&
                         stripImplicitConv(*initE).kind ==
                             ExpressionKind::RealLiteral) {
                    auto& rl9 = stripImplicitConv(*initE);
                    char rb9[64];
                    snprintf(rb9, sizeof(rb9), "%f",
                             rl9.as<RealLiteral>().getValue());
                    enc.value = std::string("REAL:") + rb9;
                    enc.decompile = std::string(rawText(rl9.sourceRange));
                    enc.size = 32;
                    enc.constType = vpiRealConst;
                    enc.ok = true;
                    up->VpiValue(enc.value);
                }
                else if (initE && !unfoldableInit9 && cv.isInteger() &&
                         !cv.integer().hasUnknown()) {
                    const Expression& ic = stripImplicitConv(*initE);
                    char base = 0;
                    std::string digits;
                    int32_t litSize = 0;
                    const UnitEnc* inherit = nullptr;
                    if (ic.kind == ExpressionKind::NamedValue)
                        if (auto it = unitEnc.find(
                                &ic.as<NamedValueExpression>().symbol);
                            it != unitEnc.end() && it->second.ok)
                            inherit = &it->second;
                    if (inherit) {
                        enc = *inherit;
                        // A bare ref inherits the referenced parameter's
                        // encoding, but a TYPED declaration still re-widths it
                        // to its OWN declared width — `localparam int unsigned
                        // SPAN = SCR1_CSR_ADDR_HDU_MSPAN` keeps HEX:004 and
                        // takes VpiSize 32, not the 12 the source literal had.
                        if (typedDecl9)
                            enc.size = (int32_t)ps.getType().getBitWidth();
                    }
                    else if (litParts(ic, base, digits, litSize)) {
                        if (base) {
                            enc.value = std::string(baseTag(base)) + digits;
                            // rawTextLit, not rawText: a macro-sized literal's
                            // decompile is the EXPANDED text (`32'd8`).
                            enc.decompile = stripSep(rawTextLit(ic));
                            enc.size = litSize;
                            enc.constType = baseConstType(base);
                            // A DECIMAL-based literal, and any literal whose
                            // width Surelog could not determine, leave an
                            // UNTYPED parameter with NO typespec at all.  An
                            // explicitly TYPED declaration ALWAYS keeps one,
                            // whatever the literal looks like -- `parameter
                            // bit [`SCR1_XLEN-1:0] SCR1_ARCH_RST_VECTOR =
                            // 'h200` and `parameter bit
                            // [SCR1_EXC_CODE_WIDTH_E-1:0] X = 4'd11` both
                            // carry one (and SCR1_RST_VECTOR, whose init is a
                            // bare ref to the first, inherits its enc).
                            // The typed constant then takes the DECLARED
                            // width, not the literal's: `4'd11` under `bit
                            // [7:0]` is VpiSize 8, and an unsized `'h200`
                            // under `bit [31:0]` is 32 (purpose-built golden
                            // battery: same-width/wider/unsized/plain-decimal
                            // /int/logic typed shapes plus the untyped twin,
                            // which alone keeps the literal's own width and no
                            // typespec).
                            enc.wantTs =
                                typedDecl9 || (base != 'd' && litSize >= 0);
                            if (typedDecl9)
                                enc.size = (int32_t)ps.getType().getBitWidth();
                        }
                        else {
                            enc.value = "UINT:" + digits;
                            enc.decompile = digits;
                            enc.size = (int32_t)ps.getType().getBitWidth();
                            enc.constType = vpiUIntConst;
                        }
                        enc.ok = true;
                    }
                    else {
                        int32_t ct = reducedType(ic);
                        bool sgn = ct == vpiIntConst;
                        std::string dg = cv.integer().toString(
                            LiteralBase::Decimal, /*includeBase=*/false);
                        enc.value = (sgn ? "INT:" : "UINT:") + dg;
                        enc.decompile = dg;
                        // Surelog reduces with 64-bit arithmetic and then
                        // clamps to the parameter's own width — `int` for an
                        // untyped $unit parameter, whatever was written for a
                        // typed one.  It is NOT the initializer's width (a
                        // `7'h4 + 7'h5` bound still lands at 32).
                        enc.size = typedDecl9
                                       ? (int32_t)ps.getType().getBitWidth()
                                       : 32;
                        enc.constType = sgn ? vpiIntConst : vpiUIntConst;
                        enc.ok = true;
                    }
                    enc.ok = true;
                    up->VpiValue(enc.value);
                }
                else if (unfoldableInit9 && !unresolvedInit9)
                    enc.wantTs = false;
                unitEnc[&mem] = enc;
                if (!enc.ok)
                    unitParamNoValue.insert(&mem);
                UHDM::ref_typespec* prt = nullptr;
                if (enc.wantTs) {
                    prt = s.MakeRef_typespec();
                    prt->VpiFullName(ps.name);
                    prt->VpiParent(up);
                    up->Typespec(prt);
                }
                auto* pa = s.MakeParam_assign();
                pa->VpiParent(d);
                if (auto syn = ps.getSyntax())
                    setLoc(pa, syn->sourceRange());
                pa->Lhs(up);
                UHDM::ref_typespec* rhsRt = nullptr;
                if (initE && enc.ok) {
                    auto& ic = stripImplicitConv(*initE);
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(enc.decompile);
                    c->VpiSize(enc.size);
                    c->VpiValue(enc.value);
                    c->VpiConstType(enc.constType);
                    c->VpiParent(pa);
                    // A reduced BINARY bound keeps the span of its LEFTMOST
                    // leaf — `reduceExpr` builds the result constant off the
                    // left operand it folded first, so `32 - 6` lands on the
                    // `32`, not on the whole expression.
                    const Expression* spanE = &ic;
                    while (spanE->kind == ExpressionKind::BinaryOp)
                        spanE = &stripImplicitConv(
                            spanE->as<BinaryExpression>().left());
                    setLoc(c, spanE->sourceRange);
                    rhsRt = s.MakeRef_typespec();
                    rhsRt->VpiParent(c);
                    c->Typespec(rhsRt);
                    pa->Rhs(c);
                }
                else if (unresolvedInit9 && initSyn9) {
                    // The unfolded form, emitted from SYNTAX: the refs are
                    // deliberately left unbound (Surelog never resolved them).
                    // § unitRefSubst — but the ones Surelog COULD resolve are
                    // not left as references at all: they are SPLICED with
                    // the referenced parameter's own value tree.  See the
                    // emitSyntaxExpr IdentifierName arm.
                    unitSubstScope = ps.getParentScope();
                    unitSubstRoot = psRoot9;
                    if (auto* e9 = emitSyntaxExpr(*initSyn9, pa))
                        pa->Rhs((UHDM::expr*)e9);
                    unitSubstScope = nullptr;
                    unitSubstRoot.clear();
                }
                if (pa->Rhs())
                    unitParamRhs[&mem] = (UHDM::expr*)pa->Rhs();
                unitParamMap[&mem] = up;
                if (prt)
                    pendingUnitParamTs.push_back({up, prt, rhsRt, &ps});
                uparams->push_back(up);
                upassigns->push_back(pa);
            }
        }
        // § unitImportHoistsPkgParams146 (see the header above this
        // function): the `$unit` import's own materialization, appended AFTER
        // the compilation unit's own parameters — Surelog compiles the file's
        // parameter DECLARATIONS in the decl-only FileContent pass
        // (`FunctorCompileFileContentDecl`, CompileFileContent.cpp:39) and the
        // `paPackage_import_item`s only in the second, non-decl pass (:81-88),
        // so the imported clones are always the later push.
        // The import list is read off the compilation unit's SYNTAX, not off
        // its elaborated members: slang COLLAPSES two identical
        // `import p::*;` statements in one scope into a single
        // `WildcardImportSymbol`, and Surelog does not — `importPackage` runs
        // once per `paPackage_import_item`, so a package imported twice is
        // listed twice (grid arm D, and the three-fold micro-arm: golden 3
        // entries, the symbol-driven enumeration gave 1).
        for (auto& tree146 : comp.getSyntaxTrees()) {
            auto& root146 = tree146->root();
            if (root146.kind != syntax::SyntaxKind::CompilationUnit)
                continue;
            for (auto* m146 :
                 root146.as<syntax::CompilationUnitSyntax>().members) {
                if (!m146 ||
                    m146->kind != syntax::SyntaxKind::PackageImportDeclaration)
                    continue;
                for (auto* i146 :
                     m146->as<syntax::PackageImportDeclarationSyntax>().items) {
                    if (!i146)
                        continue;
                    const PackageSymbol* ipk =
                        comp.getPackage(i146->package.valueText());
                    if (!ipk)
                        continue;
                    // `importPackage`'s `object_name` filter (CompileHelper.cpp
                    // :204/:245): an EXPLICIT import materializes ONLY the
                    // named item; a wildcard's item token is `*`.
                    std::string only146(i146->item.valueText());
                    if (only146 == "*")
                        only146.clear();
                    auto tit146 = pkgTopMap.find(ipk);
                    if (tit146 == pkgTopMap.end() || !tit146->second)
                        continue;
                    auto* tpk146 = tit146->second;
                    const std::string pkgName146(ipk->name);
                    // (a) `vpiParameter` — ASCII NAME ORDER
                    // (`getParameterMap()` is a std::map), value parameters and
                    // TYPE parameters in the SAME sorted vector.
                    std::vector<UHDM::any*> srcs146;
                    if (tpk146->Parameters())
                        for (auto* p146 : *tpk146->Parameters())
                            if (p146 &&
                                (p146->UhdmType() == UHDM::uhdmparameter ||
                                 p146->UhdmType() == UHDM::uhdmtype_parameter) &&
                                (only146.empty() || p146->VpiName() == only146))
                                srcs146.push_back(p146);
                    // § unitImportHoistsPkgParams146v — THE MAP DEDUPES, THE
                    // VECTOR DOES NOT.  `importPackage` reads
                    // `def->getParameterMap()`, and that map is filled by
                    // `DesignComponent::insertParameter`
                    // (DesignComponent.cpp:209) with
                    // `m_parameterMap.emplace(p->getName(), p)` — an EMPLACE,
                    // so a name inserted twice keeps the FIRST entry, while
                    // `m_orderedParameters` (our `Parameters()` vector's
                    // counterpart) keeps BOTH.  A package that IMPORTS and then
                    // RE-EXPORTS another package borrows the same parameter
                    // twice: golden's package listing carries it twice and
                    // golden's DESIGN listing carries it ONCE.  Measured on the
                    // verifier arm `v08_export.sv` — `package pv8b` does
                    // `import pv8a::*; export pv8a::*;`, golden lists
                    // `vpiParameter` AA,BB (2) and `vpiParamAssign` AA,AA,BB
                    // (3); without this dedupe we listed AA,AA,BB (3) against
                    // golden's 2.  The param_assign half is NOT deduped —
                    // golden's is the ordered `getParamAssignVec()` and it
                    // really does carry the name twice.
                    {
                        std::set<std::string> seen146;
                        std::vector<UHDM::any*> uniq146;
                        uniq146.reserve(srcs146.size());
                        for (auto* p146 : srcs146)
                            if (seen146.insert(std::string(p146->VpiName()))
                                    .second)
                                uniq146.push_back(p146);
                        srcs146.swap(uniq146);
                    }
                    std::sort(srcs146.begin(), srcs146.end(),
                              [](const UHDM::any* a, const UHDM::any* b) {
                                  return a->VpiName() < b->VpiName();
                              });
                    for (auto* p146 : srcs146) {
                        UHDM::any* cp146 =
                            p146->UhdmType() == UHDM::uhdmtype_parameter
                                ? (UHDM::any*)designImportTypeParamCopy146(
                                      s, p146, d, pkgName146)
                                : (UHDM::any*)designImportParamCopy146(
                                      s, p146, d, pkgName146);
                        if (!cp146)
                            continue;
                        uparams->push_back(cp146);
                        // lateBinding scans `design->Parameters()` in order and
                        // takes the FIRST name match, so a name listed twice
                        // (the same package imported twice) binds through its
                        // first entry.  Only a VALUE parameter is a binding
                        // target for a `ref_obj`.
                        if (cp146->UhdmType() == UHDM::uhdmparameter)
                            designImportParam146.emplace(
                                std::string(p146->VpiName()),
                                (UHDM::parameter*)cp146);
                    }
                    // (b) `vpiParamAssign` — the ELABORATED package listing, in
                    // ITS OWN order (the package's declaration order), each Lhs
                    // a second stamped copy.  A type parameter has no
                    // param_assign on either side.
                    if (tpk146->Param_assigns())
                        for (auto* pa146 : *tpk146->Param_assigns()) {
                            if (!pa146 || !pa146->Lhs())
                                continue;
                            if (!only146.empty() &&
                                pa146->Lhs()->VpiName() != only146)
                                continue;
                            if (auto* cpa146 = designImportPaCopy146(
                                    s, pa146, d, pkgName146))
                                upassigns->push_back(cpa146);
                        }
                }
            }
        }
        if (!uparams->empty()) {
            d->Parameters(uparams);
            d->Param_assigns(upassigns);
        }
    }


    // True when some module signal (net/port/variable) has the given struct
    // type (so its file-level typedef is elaborated with a design parent).
    auto structUsedByModuleSignal = [&](const Type& structType) -> bool {
        const Type* target = &structType.getCanonicalType();
        // A $unit function returning the struct elaborates first (before any
        // module) and leaves its typedef unparented.
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members())
                if (member.kind == SymbolKind::Subroutine &&
                    &member.as<SubroutineSymbol>().getReturnType().getCanonicalType() == target)
                    return false;
        bool directUse = false;
        for (auto& [name, inst] : defs) {
            for (auto& member : inst->body.members()) {
                const DeclaredType* dt = nullptr;
                if (member.kind == SymbolKind::Net || member.kind == SymbolKind::Variable ||
                    member.kind == SymbolKind::Port ||
                    member.kind == SymbolKind::Parameter)
                    dt = member.getDeclaredType();
                if (!dt)
                    continue;
                auto& mct = dt->getType().getCanonicalType();
                if (&mct == target)
                    directUse = true;
                // A signal whose type is a PACKED ARRAY of the struct reaches
                // it through the packed_array_typespec's Elem_typespec, which
                // still counts as a module-signal use.
                else if (mct.isPackedArray()) {
                    const Type* el = &mct;
                    while (el->getCanonicalType().kind == SymbolKind::PackedArrayType)
                        el = &el->getCanonicalType().as<PackedArrayType>().elementType;
                    if (&el->getCanonicalType() == target)
                        directUse = true;
                }
            }
        }
        return directUse;
    };

    // Surelog's UhdmWriter::writeCont_assign ends by CLEARING the vpiParent of
    // the typespec it resolved for the assign's LHS (UhdmWriter.cpp:2295) —
    // so a file-level struct typedef that types ANY continuous-assign target
    // signal ends up unparented at the design, whatever the typedef pass set
    // (DotMultirange status_t, gen_struct_access td2). Only a WHOLE-signal
    // LHS resolves the signal's typespec; member/index selects do not.
    auto structTypesContAssignLhs = [&](const Type& structType) -> bool {
        const Type* target = &structType.getCanonicalType();
        bool found = false;
        std::function<void(const Scope&)> scan = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (found)
                    return;
                if (mem.kind == SymbolKind::ContinuousAssign) {
                    auto& asn =
                        mem.as<ContinuousAssignSymbol>().getAssignment();
                    if (asn.kind != ExpressionKind::Assignment)
                        continue;
                    auto& lc = stripImplicitConv(
                        asn.as<AssignmentExpression>().left());
                    if (lc.kind != ExpressionKind::NamedValue)
                        continue;
                    if (auto dt2 =
                            lc.as<NamedValueExpression>().symbol.getDeclaredType();
                        dt2 && &dt2->getType().getCanonicalType() == target)
                        found = true;
                }
                else if (mem.kind == SymbolKind::GenerateBlock)
                    scan(mem.as<GenerateBlockSymbol>());
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan(*ge);
            }
        };
        for (auto& [name, inst] : defs)
            scan(inst->body);
        return found;
    };

    // File-level (compilation-unit) typedefs: the typespec OBJECTS are built
    // in SOURCE order (so their member typespecs land in source order in the
    // arena), but the design Typespecs LIST is name-sorted like Surelog's.
    {
        std::vector<const Symbol*> srcAliases;
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members())
                if (member.kind == SymbolKind::TypeAlias)
                    srcAliases.push_back(&member);
        std::stable_sort(srcAliases.begin(), srcAliases.end(),
                         [this](auto* a, auto* b) {
                             return srcOrderLess(a->location, b->location);
                         });
        std::map<std::string, UHDM::typespec*> byName;
        // Where each $unit typespec was DECLARED — the design's Typespecs
        // vector is grouped by the command-line file that first included the
        // declaring header (§ the sort below), so the map's own alphabetical
        // order is only the WITHIN-group order.
        std::map<std::string, SourceLocation> declLoc9;
        {
            for (auto* memberPtr : srcAliases) {
                auto& member = *memberPtr;
                auto& ta = member.as<TypeAliasType>();
                auto& ct = ta.targetType.getType().getCanonicalType();
                const syntax::SyntaxNode* typeSyn = nullptr;
                if (auto syn = ta.getSyntax()) {
                    if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
                }
                UHDM::typespec* ts = nullptr;
                if (ct.kind == SymbolKind::EnumType) {
                    ts = buildEnumTs(ct.as<EnumType>(), typeSyn, std::string(ta.name));
                    ts->VpiParent(d);
                    if (auto syn = ta.getSyntax())
                        setLoc(ts, syn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedStructType) {
                    ts = buildStructTs(ct.as<PackedStructType>(), true,
                                       std::string(ta.name));
                    // A file-level packed struct used by a MODULE signal
                    // (net/port/var) parents at the design; one used only in
                    // function returns etc. stays unparented. One used by a
                    // $UNIT function FORMAL parents at the design and anchors
                    // at that first formal's type token.
                    const syntax::SyntaxNode* formalSyn = nullptr;
                    for (auto unit2 : comp.getCompilationUnits()) {
                        for (auto& m2 : unit2->members()) {
                            if (m2.kind != SymbolKind::Subroutine)
                                continue;
                            for (auto arg2 :
                                 m2.as<SubroutineSymbol>().getArguments()) {
                                if (&arg2->getType().getCanonicalType() != &ct)
                                    continue;
                                if (auto dt2 = arg2->getDeclaredType())
                                    if (auto tsy2 = dt2->getTypeSyntax())
                                        formalSyn = tsy2;
                                break;
                            }
                            if (formalSyn)
                                break;
                        }
                        if (formalSyn)
                            break;
                    }
                    if (structUsedByModuleSignal(ct) &&
                        !structTypesContAssignLhs(ct))
                        ts->VpiParent(d);
                    else if (formalSyn)
                        ts->VpiParent(d);
                    if (formalSyn && !structUsedByModuleSignal(ct))
                        setLoc(ts, formalSyn->sourceRange());
                    else if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::UnpackedStructType) {
                    ts = buildStructTs(ct.as<UnpackedStructType>(), false,
                                       std::string(ta.name));
                    ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedUnionType) {
                    ts = buildUnionTs(ct.as<PackedUnionType>(), true,
                                      std::string(ta.name));
                    if (structUsedByModuleSignal(ct))
                        ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedArrayType ||
                         ct.kind == SymbolKind::ScalarType) {
                    // Vector/scalar typedef: a NAMED logic_typespec with its
                    // ranges at the target type syntax (like module-scope
                    // vector typedefs).  Unlike a module-scope one its bounds
                    // FOLD: the compilation unit is compiled before any
                    // module, so `typedef logic [G_DW-1:0] g_v;` lands as a
                    // constant range (same rule as the file-level struct
                    // members, buildStructTs).
                    bypassTypedefShare = true;
                    bool savedTf = tfContext;
                    tfContext = false;
                    typedefTsContext = true;
                    ts = makeTypespec(ta, typeSyn);
                    typedefTsContext = false;
                    tfContext = savedTf;
                    bypassTypedefShare = false;
                    ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                    // A typedef aliasing a NAMED vector typedef with ADDED
                    // packed dims (typedef reg8_t [0:3] t2): Surelog's
                    // multi-clone graph — the design ts spans the first USE,
                    // Elem-refs an unnamed clone chain over the target span,
                    // and SHARES a packed_array ts's range.
                    auto& tgtT = ta.targetType.getType();
                    if (ct.kind == SymbolKind::PackedArrayType && typeSyn &&
                        tgtT.kind == SymbolKind::PackedArrayType &&
                        tgtT.as<PackedArrayType>().elementType.kind ==
                            SymbolKind::TypeAlias &&
                        typedefTs.count(
                            &tgtT.as<PackedArrayType>().elementType)) {
                        auto& elT = tgtT.as<PackedArrayType>().elementType;
                        auto* baseTs = typedefTs[&elT];
                        // Dedicated ELEM clones (named reg8_t, ranges) — one
                        // per array-clone level. Surelog mints a FRESH element
                        // clone for BOTH the outer clone (clA.elem) and the
                        // inner alias clone (clB.elem), and gives the outer
                        // one a Typedef_alias to a BARE sibling clone (R1),
                        // while the inner one aliases the shared design ts.
                        auto& eta = elT.as<TypeAliasType>();
                        const syntax::SyntaxNode* etSyn = nullptr;
                        if (auto easyn = eta.getSyntax())
                            if (easyn->kind ==
                                syntax::SyntaxKind::TypedefDeclaration)
                                etSyn = easyn
                                            ->as<syntax::
                                                     TypedefDeclarationSyntax>()
                                            .type;
                        // Mint a fresh named element clone; if aliasTgt is set,
                        // give it a Typedef_alias ref to it (parented at the
                        // clone). Returns null on a non-logic result.
                        auto mintElem =
                            [&](UHDM::typespec* aliasTgt) -> UHDM::typespec* {
                            bypassTypedefShare = true;
                            auto* c = makeTypespec(eta, etSyn);
                            bypassTypedefShare = false;
                            if (!c)
                                return nullptr;
                            c->VpiName(eta.name);
                            if (etSyn)
                                setLoc(c, etSyn->sourceRange());
                            if (aliasTgt &&
                                c->UhdmType() == UHDM::uhdmlogic_typespec) {
                                auto* ar = s.MakeRef_typespec();
                                ar->VpiFullName(eta.name);
                                ar->VpiParent(c);
                                ar->Actual_typespec(aliasTgt);
                                ((UHDM::logic_typespec*)c)->Typedef_alias(ar);
                            }
                            return c;
                        };
                        auto tspan = typeSyn->sourceRange();
                        std::string raw = rawText(tspan);
                        auto lb = raw.find('[');
                        auto cl = raw.find(':');
                        auto rb = raw.find(']');
                        auto mkDimRange =
                            [&](UHDM::BaseClass* pts) -> UHDM::range* {
                            if (lb == std::string::npos ||
                                cl == std::string::npos ||
                                rb == std::string::npos)
                                return nullptr;
                            auto* r = s.MakeRange();
                            r->VpiParent(pts);
                            setLoc(r, SourceRange(tspan.start() + lb,
                                                  tspan.start() + rb + 1));
                            auto mkC = [&](size_t from, size_t to) {
                                std::string dg = raw.substr(from, to - from);
                                while (!dg.empty() && dg.front() == ' ') {
                                    dg.erase(dg.begin());
                                    from++;
                                }
                                while (!dg.empty() && dg.back() == ' ') {
                                    dg.pop_back();
                                    to--;
                                }
                                auto* c = s.MakeConstant();
                                c->VpiDecompile(dg);
                                c->VpiSize(64);
                                c->VpiValue("UINT:" + dg);
                                c->VpiConstType(vpiUIntConst);
                                c->VpiParent(r);
                                setLoc(c, SourceRange(tspan.start() + from,
                                                      tspan.start() + to));
                                return c;
                            };
                            r->Left_expr(mkC(lb + 1, cl));
                            r->Right_expr(mkC(cl + 1, rb));
                            return r;
                        };
                        auto* pat2 = s.MakePacked_array_typespec();
                        setLoc(pat2, tspan);
                        auto* shr = mkDimRange(pat2);
                        if (shr) {
                            auto* v0 = s.MakeRangeVec();
                            v0->push_back(shr);
                            pat2->Ranges(v0);
                        }
                        auto* clA = s.MakeLogic_typespec();
                        setLoc(clA, tspan);
                        auto* clB = s.MakeLogic_typespec();
                        setLoc(clB, tspan);
                        // Mint the three reg8_t element clones in Surelog's
                        // creation order: elemCl_B (clB.elem, alias -> shared
                        // base), then elemCl (clA.elem), then its BARE alias
                        // sibling R1.
                        UHDM::typespec* elemClB = mintElem(baseTs);
                        UHDM::typespec* elemCl = mintElem(nullptr);
                        if (elemCl &&
                            elemCl->UhdmType() == UHDM::uhdmlogic_typespec) {
                            auto* r1 = mintElem(nullptr);
                            auto* eal = s.MakeRef_typespec();
                            eal->VpiFullName(eta.name);
                            eal->VpiParent(elemCl);
                            eal->Actual_typespec(r1 ? r1 : baseTs);
                            if (r1)
                                r1->VpiParent(eal);
                            ((UHDM::logic_typespec*)elemCl)->Typedef_alias(eal);
                        }
                        auto* tar = s.MakeRef_typespec();
                        tar->VpiParent(clA);
                        tar->Actual_typespec(clB);
                        clA->Typedef_alias(tar);
                        auto* ear = s.MakeRef_typespec();
                        ear->VpiParent(clA);
                        ear->Actual_typespec(elemCl ? elemCl : baseTs);
                        if (elemCl)
                            elemCl->VpiParent(ear);
                        clA->Elem_typespec(ear);
                        if (auto* rA = mkDimRange(clA)) {
                            auto* vA = s.MakeRangeVec();
                            vA->push_back(rA);
                            clA->Ranges(vA);
                        }
                        auto* ebr = s.MakeRef_typespec();
                        ebr->VpiParent(clB);
                        ebr->Actual_typespec(elemClB ? elemClB : baseTs);
                        clB->Elem_typespec(ebr);
                        if (auto* rB = mkDimRange(clB)) {
                            auto* vB = s.MakeRangeVec();
                            vB->push_back(rB);
                            clB->Ranges(vB);
                        }
                        auto* der = s.MakeRef_typespec();
                        der->VpiFullName(ta.name);
                        der->VpiParent(ts);
                        der->Actual_typespec(clA);
                        ((UHDM::logic_typespec*)ts)->Elem_typespec(der);
                        if (shr) {
                            auto* vT = s.MakeRangeVec();
                            vT->push_back(shr); // SHARED — parent stays pat2
                            ((UHDM::logic_typespec*)ts)->Ranges(vT);
                        }
                        // Span the design ts at the FIRST module-signal USE.
                        bool spanned = false;
                        for (auto& [nm2, inst2] : defs) {
                            for (auto& member : inst2->body.members()) {
                                const DeclaredType* dtu = nullptr;
                                if (member.kind == SymbolKind::Net ||
                                    member.kind == SymbolKind::Variable ||
                                    member.kind == SymbolKind::Port)
                                    dtu = member.getDeclaredType();
                                if (!dtu || &dtu->getType() != (const Type*)&ta)
                                    continue;
                                if (auto tsy = dtu->getTypeSyntax()) {
                                    setLoc(ts, tsy->sourceRange());
                                    spanned = true;
                                }
                                break;
                            }
                            if (spanned)
                                break;
                        }
                    }
                }
                // `typedef uvm_config_db#(uvm_object, string) alias;` — the
                // same rule as a class-SCOPE class alias: one class_typespec
                // named after the ALIAS, carrying the specialization, which
                // every declaration of the alias then shares (ClassTypeParam).
                else if (ct.kind == SymbolKind::ClassType) {
                    auto* cts = s.MakeClass_typespec();
                    if (auto* bcd = classDefnFor(ct))
                        cts->Class_defn(bcd);
                    else
                        pendingClassTsLink.push_back({cts, &ct});
                    emitClassTsParams(cts, ct.as<ClassType>(), std::string(ta.name));
                    cts->VpiParent(d);
                    if (typeSyn) {
                        auto r = typeSyn->sourceRange();
                        if (auto* nt = typeSyn->as_if<syntax::NamedTypeSyntax>())
                            if (auto* cn = nt->name->as_if<syntax::ClassNameSyntax>())
                                r = SourceRange(cn->identifier.range().start(), r.end());
                        setLoc(cts, r);
                    }
                    ts = cts;
                }
                else {
                    noteUnsupported("typedef target: " + std::string(toString(ct.kind)));
                    continue;
                }
                ts->VpiName(ta.name);
                ts->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                // MULTI-TOP designs parent $unit typedefs at the DESIGN
                // (arrays03); single-top ones leave them for net re-parenting
                // (DotMultirange).
                if (comp.getRoot().topInstances.size() > 1)
                    ts->VpiParent((UHDM::BaseClass*)d);
                typedefTs[&ta] = ts;
                byName[std::string(ta.name)] = ts;
                declLoc9[std::string(ta.name)] = ta.location;
            }
        }
        // A user-defined NETTYPE (`nettype real my_real with my_function2`) is
        // a design-level typespec too: Surelog emits the resolved DATA type
        // under the nettype's name, with vpiInstance = the design and
        // vpiFunction = the resolution function. The function object only
        // exists after the $unit task_func pass below, so the binding is
        // deferred (FileResolutionFunction).
        std::vector<std::pair<UHDM::typespec*, std::string>> nettypeResolvers;
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members()) {
                if (member.kind != SymbolKind::NetType)
                    continue;
                auto& nt = member.as<NetType>();
                if (nt.isBuiltIn())
                    continue;
                const syntax::SyntaxNode* dtSyn = nullptr;
                if (auto syn = nt.getSyntax())
                    if (syn->kind == syntax::SyntaxKind::NetTypeDeclaration)
                        dtSyn = syn->as<syntax::NetTypeDeclarationSyntax>().type;
                auto* ts = makeTypespec(nt, dtSyn);
                if (!ts)
                    continue;
                ts->VpiName(nt.name);
                ts->VpiParent(d);
                ts->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                if (dtSyn)
                    setLoc(ts, dtSyn->sourceRange());
                byName[std::string(nt.name)] = ts;
                declLoc9[std::string(nt.name)] = nt.location;
                if (auto* rf = nt.getResolutionFunction())
                    nettypeResolvers.push_back({ts, std::string(rf->name)});
            }
        // A FILE-SCOPE `import pkg::*` puts the package's typedefs into that
        // FileContent's DataTypeMap (CompileHelper::importPackage), and the
        // design's Typespecs are the union of every FileContent's map
        // (UhdmWriter, "Non-Elaborated Model") -- so the SHARED package
        // typespec is listed at the design too, under its unqualified name.
        for (auto unit : comp.getCompilationUnits())
            for (auto& mem : unit->members()) {
                const Symbol* only = nullptr;
                const PackageSymbol* ipkg = nullptr;
                if (mem.kind == SymbolKind::WildcardImport)
                    ipkg = comp.getPackage(
                        mem.as<WildcardImportSymbol>().packageName);
                else if (mem.kind == SymbolKind::ExplicitImport) {
                    only = mem.as<ExplicitImportSymbol>().importedSymbol();
                    if (!only || only->kind != SymbolKind::TypeAlias)
                        continue;
                    ipkg = comp.getPackage(
                        mem.as<ExplicitImportSymbol>().packageName);
                }
                if (!ipkg)
                    continue;
                for (auto& pm : ipkg->members()) {
                    if (pm.kind != SymbolKind::TypeAlias)
                        continue;
                    if (only && &pm != only)
                        continue;
                    auto tit = pkgTopTypedefTs.find((const void*)&pm);
                    if (tit == pkgTopTypedefTs.end() || !tit->second)
                        continue;
                    if (byName.emplace(std::string(pm.name), tit->second).second)
                        declLoc9[std::string(pm.name)] = mem.location;
                }
            }
        if (!byName.empty()) {
            // Surelog builds the design's Typespecs by walking the
            // FileContents in COMMAND-LINE order and appending each one's
            // (name-sorted) DataTypeMap, so the vector is a sequence of
            // per-root-file GROUPS, alphabetical inside each group — NOT one
            // global alphabetical list.  A guarded header is textually
            // included exactly once, so its typedefs belong to the FIRST
            // command-line file that pulled it in (Scr1SvTests: 28 types from
            // scr1_pipe_hdu.sv, then tdu.svh's 2 from scr1_pipe_tdu.sv,
            // memif's 3 from scr1_pipe_exu.sv, search_ms1's 2 from
            // scr1_pipe_ialu.sv, tapc's 2 from scr1_tapc.sv, scu's 7 from
            // scr1_scu.sv — purpose-built 3-file golden r10scr4_f agrees).
            // constant-time note: byName is already alphabetical, so a STABLE
            // sort on the group rank alone yields (group, name).
            auto rootLoc9 = [&](SourceLocation loc) {
                if (loc == SourceLocation::NoLocation)
                    return loc;
                if (sm->isMacroLoc(loc))
                    loc = sm->getFullyOriginalLoc(loc);
                for (int g9 = 0; g9 < 64; g9++) {
                    auto up = sm->getIncludedFrom(loc.buffer());
                    if (up == SourceLocation::NoLocation || !up.buffer().valid())
                        break;
                    loc = up;
                }
                return loc;
            };
            std::vector<std::pair<std::string, UHDM::typespec*>> ordered9(
                byName.begin(), byName.end());
            std::stable_sort(ordered9.begin(), ordered9.end(),
                             [&](auto& a, auto& b) {
                                 auto la = declLoc9.count(a.first)
                                               ? rootLoc9(declLoc9[a.first])
                                               : SourceLocation::NoLocation;
                                 auto lb = declLoc9.count(b.first)
                                               ? rootLoc9(declLoc9[b.first])
                                               : SourceLocation::NoLocation;
                                 if (la == SourceLocation::NoLocation ||
                                     lb == SourceLocation::NoLocation ||
                                     la.buffer() == lb.buffer())
                                     return false;
                                 return srcOrderLess(la, lb);
                             });
            auto* tds = s.MakeTypespecVec();
            for (auto& [nm, ts] : ordered9)
                tds->push_back(ts);
            d->Typespecs(tds);
        }

        // $unit (compilation-unit) functions live on the design object.
        for (auto unit : comp.getCompilationUnits())
            emitTaskFuncs(*unit, d, "", nullptr);

        for (auto& [ts, fname] : nettypeResolvers) {
            if (ts->UhdmType() != UHDM::uhdmreal_typespec || !d->Task_funcs())
                continue;
            for (auto* tf : *d->Task_funcs())
                if (tf->UhdmType() == UHDM::uhdmfunction && tf->VpiName() == fname) {
                    ((UHDM::real_typespec*)ts)->Resolution_func((UHDM::function*)tf);
                    break;
                }
        }
    }

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    // Pre-create the definition shells so ref_modules can point at them
    // regardless of emission order. Interface defs get interface_inst shells
    // in AllInterfaces, `program` defs get program shells in AllPrograms, and
    // everything else module_inst shells in AllModules.
    auto* allIfaces = s.MakeInterface_instVec();
    auto* allProgs = s.MakeProgramVec();
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst)) {
            auto* iface = s.MakeInterface_inst();
            ifaceDefMap[&inst->getDefinition()] = iface;
            allIfaces->push_back(iface);
        }
        // EVERY `program` def gets the program shell — a file-scope program is
        // never a design top (see the progTops partition in exportDesign), so
        // there is no module_inst fallback left.
        else if (isProgramDef(*inst)) {
            auto* prog = s.MakeProgram();
            defMap[&inst->getDefinition()].mod = prog;
            allProgs->push_back(prog);
        }
        else {
            defMap[&inst->getDefinition()].mod = s.MakeModule_inst();
            allMods->push_back((UHDM::module_inst*)defMap[&inst->getDefinition()].mod);
        }
    }
    // A design with no module definition at all (a lone `program` file, an
    // interface-only file) leaves AllModules NULL in golden, not an empty
    // vector — Surelog's writer only creates the vector when it has a member.
    if (!allMods->empty())
        d->AllModules(allMods);
    if (!allIfaces->empty())
        d->AllInterfaces(allIfaces);
    if (!allProgs->empty())
        d->AllPrograms(allProgs);
    // `primitive ... endprimitive` -> design->AllUdps, name-sorted like
    // Surelog's module map (a UDP is a ModuleDefinition there, routed to
    // AllUdps instead of AllModules by its declaration type).
    emitUdpDefns();

    // Surelog compiles every module's parameters at module-compile time, so
    // all def-view parameter typespecs precede any elaboration typespecs.
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst))
            continue; // simple-interface params handled in emitInterfaceDef
        // -bb_mod/-bb_inst: Surelog returns from CompileModule BEFORE any
        // collectModuleObjects_ pass, so a blackboxed definition never gets
        // parameters either -- the AllModules entry is a bare shell.
        if (blackboxedDef("work@" + name))
            continue;
        DefInfo& info = defMap[&inst->getDefinition()];
        // A param TYPED BY one of the module's own typedefs forces that
        // typedef's compile first (Surelog compiles the typedef declaration
        // before the parameter that names it), so the typedef's member
        // typespecs precede the param initializer's own objects.
        if (!info.typedefsDone && paramTypedByLocalTypedef(inst->body)) {
            info.typedefsDone = true;
            const Scope* savedCS = currentScope;
            currentScope = &inst->body;
            emitTypedefs(inst->body, info.mod, "work@" + name, info);
            currentScope = savedCS;
        }
        emitParameters(inst->body, info.mod, "work@" + name, info.nets, /*topView=*/false,
                       &info, false);
    }
    // Every def's CONTENT (typedefs, nets, task_funcs, cont_assigns,
    // processes, generate placeholders) compiles before any instance; only
    // the port/net-ts phase is encounter-ordered.
    for (auto& [name, inst] : defs) {
        // A blackboxed def emits its HEADER only (the emitModuleDef /
        // emitInterfaceDef early return); mark the port phase done so neither
        // the instance walk nor the write-phase fallback fills it in later.
        if (blackboxedDef("work@" + name))
            defMap[&inst->getDefinition()].filled = true;
        if (useInterfacePath(*inst))
            emitInterfaceDef(*inst);
        else
            emitModuleDef(*inst, false);
    }
    // Deferred def-view aggregate-typedef param ts (typedefTs is now full).
    drainDefParamTs();
    // Pkg struct typedef ts spans stretch to the first module-signal USE
    // declarator (Surelog).
    for (auto& [tsP, aliasT] : pendingPkgTsStretch) {
        // LAST use wins (Surelog last-writer semantics).
        for (auto& [nm9, inst9] : defs) {
            for (auto& member : inst9->body.members()) {
                const DeclaredType* dt9 = nullptr;
                if (member.kind == SymbolKind::Net ||
                    member.kind == SymbolKind::Variable ||
                    member.kind == SymbolKind::Port)
                    dt9 = member.getDeclaredType();
                if (!dt9)
                    continue;
                const Type* t9 = &dt9->getType();
                while (t9->getCanonicalType().kind ==
                       SymbolKind::FixedSizeUnpackedArrayType)
                    t9 = &t9->getCanonicalType()
                              .as<FixedSizeUnpackedArrayType>()
                              .elementType;
                if ((const Type*)t9 != aliasT)
                    continue;
                if (auto dsyn9 = member.getSyntax()) {
                    // Only declarators extending past the name (an
                    // initializer or unpacked dims) stretch the span.
                    if (dsyn9->kind == syntax::SyntaxKind::Declarator) {
                        auto& dd9 = dsyn9->as<syntax::DeclaratorSyntax>();
                        if (!dd9.initializer && dd9.dimensions.empty())
                            continue;
                        // A STRUCT typedef only relocates for an unpacked-dim
                        // declarator or an assignment-PATTERN init; a bare
                        // literal fill (hw_key_req_t k = '1) leaves the shared
                        // typespec at its typedef span (PartSelectInFor).
                        // Enum/alias typedefs stretch on any init
                        // (typedef_package).
                        if (tsP->UhdmType() == UHDM::uhdmstruct_typespec &&
                            dd9.dimensions.empty() && dd9.initializer &&
                            dd9.initializer->expr->kind !=
                                syntax::SyntaxKind::AssignmentPatternExpression)
                            continue;
                    }
                    // ANSI PORT uses don't stretch (Surelog).
                    {
                        bool ansiPort9 = false;
                        for (auto q9 = dsyn9; q9; q9 = q9->parent)
                            if (q9->kind ==
                                syntax::SyntaxKind::ImplicitAnsiPort) {
                                ansiPort9 = true;
                                break;
                            }
                        if (ansiPort9)
                            continue;
                    }
                    auto e9 = dsyn9->sourceRange().end();
                    if (e9 != SourceLocation::NoLocation) {
                        tsP->VpiEndLineNo((uint32_t)sm->getLineNumber(e9));
                        tsP->VpiEndColumnNo(
                            (uint32_t)sm->getColumnNumber(e9));
                    }
                }
            }
        }
    }
    pendingPkgTsStretch.clear();

    // File-level class definitions -> design->AllClasses: properties as
    // ::-scoped automatic vars, methods via emitTaskFuncs (class scope).
    {
        auto* classes = s.MakeClass_defnVec();
        struct ClassEnt {
            const ClassType* cls;
            bool builtinFile;
        };
        std::vector<ClassEnt> ents;
        for (auto unit : comp.getCompilationUnits()) {
            bool bi = isBuiltinUnit(*unit);
            for (auto& mem : unit->members()) {
                if (mem.kind == SymbolKind::ClassType)
                    ents.push_back({&mem.as<ClassType>(), bi});
                // A PARAMETERIZED class declaration (`class resource #(type
                // T=int)`) is a GenericClassDefSymbol in slang, not a
                // ClassType, so it never reached AllClasses. Surelog compiles
                // it once, from its DEFAULT specialization, exactly like the
                // nested-class path above (ClassParamAsParam, ClassTypeParam,
                // VirtualClass).
                // ClassParamAsParam and ClassTypeParam are CMP_EQUAL as of the
                // design-root-class block: this list, plus class-SCOPE class
                // aliases (emitClassTypedefs), the specialization carried on a
                // class_typespec (emitClassTsParams), a $unit class alias as a
                // design typedef, and the `= new` var vpiExpr.
                // VirtualClass still diverges, on THREE independent rules:
                //   (a) class-scope aliases of ordinary data types
                //       (t_vector/t_array/t_struct) must be listed with their
                //       SIZE-dependent ranges kept UNFOLDED (golden holds
                //       operation(SIZE-1); the default specialization folds
                //       SIZE=1 to [0:0]), which emitClassTypedefs skips;
                //   (b) a class-SCOPED type reference (`C#(t_t0,3)::t_vector`)
                //       is an unsupported_typespec named `C::t_vector` in
                //       golden — Surelog does not resolve it;
                //   (c) the vars it types are bare logic_vars with NO typespec
                //       in the top view, and def-view logic_nets pointing at
                //       the unsupported_typespec.
                else if (mem.kind == SymbolKind::GenericClassDef) {
                    auto& gc = mem.as<GenericClassDefSymbol>();
                    if (auto* dsp = gc.getDefaultSpecialization(*unit);
                        dsp && dsp->kind == SymbolKind::ClassType)
                        ents.push_back({&dsp->as<ClassType>(), bi});
                }
            }
        }
        // Surelog compiles builtin.sv before the user sources, so its
        // class_defn objects lead the arena; the design's class LIST is then
        // ordered by SHORT class name (Surelog's multimap<name, ClassDefn*>).
        std::map<const ClassType*, UHDM::class_defn*> made;
        auto emitOne = [&](const ClassType* c, bool fromBuiltinFile) {
            std::string cname = "work@" + std::string(c->name);
            made[c] = emitClassDefn(*c, cname, cname, d);
            // NOTE § builtinClassTsLinksBuiltinFileDefn7 — the SHORT-NAME index
            // classDefnFor falls back to.  Only the injected builtin.sv unit
            // feeds it, so it stays empty under --nobuiltin and can never shadow
            // a user class.  See the header comment for why the bridge exists.
            if (fromBuiltinFile && made[c])
                builtinFileDefnByName.emplace(std::string(c->name), made[c]);
        };
        for (auto& e : ents)
            if (e.builtinFile)
                emitOne(e.cls, /*fromBuiltinFile=*/true);
        for (auto& e : ents)
            if (!e.builtinFile)
                emitOne(e.cls, /*fromBuiltinFile=*/false);
        std::stable_sort(ents.begin(), ents.end(),
                         [](const ClassEnt& a, const ClassEnt& b) {
                             return a.cls->name < b.cls->name;
                         });
        for (auto& e : ents)
            classes->push_back(made[e.cls]);
        if (!classes->empty())
            d->AllClasses(classes);
    }


    for (auto inst : orderedTops) {
        std::string prefix = "work@" + std::string(inst->getDefinition().name);
        // § dottedTopNameBareElab — a top whose NAME carries a `.` elaborates
        // to a BARE SHELL in Surelog (see emitBareTopShell for the grid).
        if (bareTops.count(inst)) {
            topMods->push_back(emitBareTopShell(*inst, prefix));
            continue;
        }
        // isTop always yields a module_inst (see emitInstance): design->
        // TopModules has no program variant.
        topMods->push_back((UHDM::module_inst*)emitInstance(*inst, prefix, nullptr, nullptr,
                                                            nullptr, /*isTop=*/true));
    }
    // Bind pkg alias-of-vector-typedef chains to the TARGET's top/module
    // listing object now that the top walk built it (jeras_union imm_l_t);
    // fall back to the def listing when the package never top-emitted.
    for (auto& [rt9, tgtSym9] : pendingAliasChainTgt) {
        UHDM::typespec* t9 = nullptr;
        if (auto it9 = pkgTopTypedefTs.find((const void*)tgtSym9);
            it9 != pkgTopTypedefTs.end())
            t9 = it9->second;
        else if (auto it8 = typedefTs.find(tgtSym9); it8 != typedefTs.end())
            t9 = it8->second;
        if (t9)
            rt9->Actual_typespec(t9);
    }
    pendingAliasChainTgt.clear();
    // Class property typespecs materialize post-elab (write phase).
    for (auto& pc : pendingClassPropTs) {
        auto* ts = makeTypespec(*pc.sym);
        pc.rt->Actual_typespec(ts);
        // NOTE § classPropNoStampShared50 — this stamp is unconditional today,
        // which is § sharedAliasNoStamp41's forbidden move the moment
        // makeTypespec hands back a REGISTERED typedef object.  Measured, not
        // predicted: with § classTdTopOnlyShare50 in and this guard OUT, the
        // SeqDriver module listing entry `class_typespec
        // (uvm_pkg::uvm_id_verbosities_array)` lost its `vpiParent: module_inst
        // work@top_tb` (golden's, and ours at 8c14dc7) and became `vpiParent:
        // class_var (uvm_pkg::uvm_report_handler::id_verbosities)` — one
        // property re-parenting the whole design's listing object.
        // GATE: pointer identity through isSharedAliasTs, never a canonical
        // kind (a `typedef int myint` walks any kind guard).
        if (ts) {
            auto* dt50 = pc.sym->getDeclaredType();
            if (!dt50 || !isSharedAliasTs(dt50->getType(), ts))
                ts->VpiParent(pc.var);
        }
    }
    pendingClassPropTs.clear();
    // Write phase: walk defs NAME-SORTED; top defs write their ports +
    // deferred typespecs, other defs materialize their local-net typespecs
    // (Surelog write-phase arena order).
    for (auto& [name, inst] : defs) {
        // Simple interfaces have no top ports but do materialize their def-view
        // net typespecs (below), so they are NOT skipped here.
        auto* di = &defMap[&inst->getDefinition()];
        // A def never reached by the instance walk (its only "instance" was
        // a DROPPED bind under an implicit top, an unreferenced definition
        // under an explicit --top, or the design has NO top at all —
        // recursive_map) fills its port phase here.
        if (!di->filled && (droppedBindDefs.count(&inst->getDefinition()) ||
                            unrefDefs.count(&inst->getDefinition()) ||
                            orderedTops.empty())) {
            di->filled = true;
            emitModuleDefPorts(*inst);
        }
        // The def's LAST elaborated instance deferred its port typespecs to
        // this slot (ports precede nets, as in the top-def phase).
        drainElabPortTs(&inst->getDefinition());
        bool isTopDef = false;
        for (auto& tp : topPendings) {
            if (&tp.inst->getDefinition() == &inst->getDefinition()) {
                isTopDef = true;
                emitTopPorts(tp);
            }
        }
        if (!isTopDef) {
            // A (non-top) interface def unfolds its param-dependent net ranges
            // (W-1 -> operation); its def typespec is not shared with an elab
            // one, so this is safe.
            bool savedTf = tfContext;
            if (useInterfacePath(*inst))
                tfContext = true;
            // NOTE § dottedTopNameBareElab — a BARE top pushes no TopPending, so
            // it never reaches emitTopPorts and its def-view net typespecs drain
            // HERE, on the non-top rule.  I shipped a `tfContext = true` for
            // them first (the TOP-def rule, on the argument that Surelog
            // compiled the module the same way whether or not the instance tree
            // came back empty) and then MEASURED it: built the predicate behind
            // a switch and ran YosysVerx both ways — the two databases are
            // BYTE-IDENTICAL, so the predicate is inert on the only witness
            // that exists and is NOT shipped.  It would only bite for a dotted
            // top with PARAM-DEPENDENT net ranges, and no such test exists in
            // either corpus (census.sh: one dotted name, corpus-wide).
            // VERIFIER CORRECTION (vyos1) — "inert" holds for YosysVerx ONLY.
            // Re-measured on purpose-built dotted tops that DO carry
            // param-dependent net ranges (vgrid/w3_paramnet.v,
            // vgrid/w13_pkg.sv): the predicate is NOT inert there — it moves the
            // output and moves it TOWARD golden (w3 span-stripped dump delta
            // 93 -> 40 lines, w13 88 -> 73) — but it does NOT close the gap
            // (uhdm-cmp still reports one head either way, golden keeping
            // `W-1` as an operation where we fold a constant).  So NOT SHIPPING
            // it is still the right call, for a stronger reason than "inert":
            // it is an incomplete fix for a residue no corpus row witnesses.
            for (auto& pn : pendingNetTs) {
                if (pn.di == di && !pn.rt->Actual_typespec())
                    materializeDefNetTs(pn);
            }
            tfContext = savedTf;
        }
    }
    // Re-point deferred def-view bare-package-typedef aggregate param refs at
    // the ELAB clone Surelog shares between both views (all elab param clones
    // now exist — they are minted in the emitTopPorts write phase above).
    shareDefAggParamTs();
    // Package param concat/pattern operand order (Surelog's isDecreasingRange
    // rule) — needs the drained param typespecs to read its ranges from.
    applyPkgParamPatternReorder();
    // A deferred instance whose def never appeared in the walk still needs its
    // typespec (safety net; normally everything drained above).
    for (auto& pe : pendingElabPortTs)
        if (!pe.rt->Actual_typespec())
            drainElabPortTs(pe.def);
    pendingElabPortTs.clear();
    topPendings.clear();
    pendingParamTs.clear();
    pendingParamTsRebind.clear(); // indices into the queue just cleared
    pendingNetTs.clear();
    for (auto& [dst, src] : netTsAlias)
        if (dst && src && !dst->Actual_typespec())
            dst->Actual_typespec(src->Actual_typespec());
    netTsAlias.clear();

    // § ifaceDupSharesHomePorts — the col-0 tail dup SHARES the home view's
    // fully-connected port objects (see makeIfaceRefDup for the measurement
    // and for why the dump made them look bare). Replayed here because the
    // home's ports come from the deferred emitTopPorts drain.
    for (auto& [dup9, home9] : pendingIfaceDupPorts) {
        if (!dup9 || !home9 || dup9->Ports() || !home9->Ports())
            continue;
        auto* dports9 = s.MakePortVec();
        for (auto* hp9 : *home9->Ports())
            dports9->push_back(hp9);
        if (!dports9->empty())
            dup9->Ports(dports9);
    }
    pendingIfaceDupPorts.clear();

    // Bind enum-value refs whose enum_const was only materialized in the
    // deferred typespec pass (anonymous enums).
    for (auto& [ref, sym] : pendingEnumRefs) {
        if (auto eit = enumConstMap.find(sym); eit != enumConstMap.end()) {
            ref->Actual_group(eit->second);
            continue;
        }
        // § defBodyTypedefSiteShare62 — the reference reads a MODULE-LOCAL
        // enum constant from an instance whose specialization is not the one
        // that produced the def listing, so the symbol-keyed map cannot see
        // it.  Surelog compiles the module's `typedef enum` ONCE per
        // DEFINITION and hands EVERY instance that one `enum_const` object, so
        // the declaration SITE is the right key.  This is the same recovery
        // `pendingEnumIdxRefs` already makes below by (name, location); it is
        // done here on the shared declarator SYNTAX NODE, which is exact.
        //   Earlgrey `tlul_adapter_sram`: `OpRead` / `OpWrite` in the module's
        //   own cont_assigns bind `enum_const` in all nine of golden's
        //   elaborated instances and bound in exactly one of ours (40 cells
        //   over 5 keys), while the imported `tlul_pkg::AccessAck` beside them
        //   — ONE package symbol for every specialization — always bound.
        // FENCE: `enumConstSite62` is written only by `emitTypedefs`, i.e.
        // only for a MODULE/INTERFACE definition's own `typedef enum`; a
        // package, class or gen-scope enum never enters it, and an ANONYMOUS
        // enum (no typedef) is out of reach too.  Refs that golden leaves bare
        // never arrive here: the § enumNoBind13 / § genCaEnumConstNoBind21 /
        // LAW-C arms return earlier in the chain.
        if (auto* esyn62 = sym->getSyntax()) {
            if (auto sit62 = enumConstSite62.find(esyn62);
                sit62 != enumConstSite62.end() && sit62->second)
                ref->Actual_group(sit62->second);
        }
    }
    pendingEnumRefs.clear();

    // A foreach_stmt's iterated-array ref binds the array's OWN array_typespec.
    // Surelog resolves the name against the module in declaration-object order,
    // so an instance-view array_var's typespec wins over the port's — and only
    // an array whose leaf is a NET (no array_var) falls back to the port's.
    // Both are minted after the statement, hence the deferred bind.
    for (auto& pf : pendingForeachArrayTs) {
        if (pf.rt->Actual_typespec())
            continue;
        UHDM::typespec* act = nullptr;
        if (auto ait = arrayVarArrayTs.find(pf.sym); ait != arrayVarArrayTs.end())
            act = ait->second;
        if (!act && pf.mod && instGetPorts(pf.mod))
            for (auto* pt : *instGetPorts(pf.mod))
                if (pt->VpiName() == pf.sym->name && pt->Typespec() &&
                    pt->Typespec()->Actual_typespec() &&
                    pt->Typespec()->Actual_typespec()->UhdmType() ==
                        UHDM::uhdmarray_typespec)
                    act = pt->Typespec()->Actual_typespec();
        pf.rt->Actual_typespec(act ? act : s.MakeArray_typespec());
    }
    pendingForeachArrayTs.clear();

    // A shadowing foreach loop variable mirrors the declaration's typespec.
    for (auto& [dst9, src9] : pendingLoopVarTs9)
        if (!dst9->Actual_typespec() && src9->Actual_typespec())
            dst9->Actual_typespec(src9->Actual_typespec());
    pendingLoopVarTs9.clear();

    // $signed/$unsigned result typespecs: share the LHS port's actual typespec
    // (no tail duplicate); fall back to a fresh one for non-port LHSs.
    for (auto& p : pendingSysFuncTs) {
        UHDM::typespec* act = nullptr;
        if (p.mod && instGetPorts(p.mod))
            for (auto* pt : *instGetPorts(p.mod))
                if (pt->VpiName() == p.sym->name && pt->Typespec())
                    act = pt->Typespec()->Actual_typespec();
        // Non-port LHS: share the def NET's typespec.
        if (!act && p.mod && p.mod->Nets())
            for (auto* nt : *p.mod->Nets())
                if (nt->VpiName() == p.sym->name && nt->Typespec())
                    act = nt->Typespec()->Actual_typespec();
        if (!act && p.nullIfNoTs)
            continue;
        p.rt->Actual_typespec(act ? act : makeTypespec(*p.sym));
    }
    pendingSysFuncTs.clear();

    // Package-function return-value locals are normally drained from
    // emitTopPorts; a design with NO module never reaches that call and the
    // `f = ...` body refs would stay unbound (PackFunc is packages only).
    // Already-processed entries carry no refs, so this is a no-op otherwise.
    drainFuncRet(/*pkgOnly=*/true);

    // $unit param typespecs are the very last arena objects.
    std::map<const Symbol*, UHDM::typespec*> unitSubstTsObj;
    for (auto& pu : pendingUnitParamTs) {
        // A compilation-unit parameter is typed by exactly the same rules as
        // a module one: `typedParam` is "the declaration names a type".
        // Forcing it true made every UNTYPED $unit param (`parameter
        // SCR1_N = 16;`) carry vpiSigned on its int_typespec, which
        // int_typespec::Compare reads — Surelog leaves it unsigned and only
        // an explicitly-typed one (`parameter int`) is signed.  The declared
        // span is the whole declaration either way, so nothing else moves.
        bool typedUnitParam = false;
        if (auto declared = pu.ps->getDeclaredType())
            if (auto tsyn = declared->getTypeSyntax())
                typedUnitParam = tsyn->kind != syntax::SyntaxKind::ImplicitType;
        auto* its = makeParamTs(*pu.ps, typedUnitParam);
        pu.prt->Actual_typespec(its);
        if (pu.rhsRt)
            pu.rhsRt->Actual_typespec(its);
        // A PLAIN untyped $unit param's int_typespec is left UNPARENTED by
        // Surelog (a ranged/signed untyped one, and every typed one, is
        // parented).
        bool plainUntyped9 = false;
        if (!typedUnitParam)
            if (auto d9 = pu.ps->getDeclaredType())
                if (auto t9 = d9->getTypeSyntax();
                    t9 && t9->kind == syntax::SyntaxKind::ImplicitType)
                    plainUntyped9 =
                        t9->as<syntax::ImplicitTypeSyntax>().dimensions.empty() &&
                        !t9->as<syntax::ImplicitTypeSyntax>().signing.valid();
        if (!plainUntyped9)
            its->VpiParent(pu.up);
        unitSubstTsObj[(const Symbol*)pu.ps] = its;
    }
    // § unitRefSubst — a spliced value carries the SUBSTITUTED parameter's
    // typespec, not the one the splice landed under: `SCR1_TDU_ALLTRIG_NUM =
    // SCR1_TDU_MTRIG_NUM + 1'b1` splices MTRIG_NUM's `ref_obj(TRIG_NUM)` and
    // types it with MTRIG_NUM's own `int unsigned` (Scr1SvTests scr1_tdu.svh).
    for (auto& [rt9, sym9] : pendingUnitSubstTs)
        if (auto it9 = unitSubstTsObj.find(sym9); it9 != unitSubstTsObj.end())
            rt9->Actual_typespec(it9->second);
    pendingUnitSubstTs.clear();
    pendingUnitParamTs.clear();

    d->TopModules(topMods);

    // The DESIGN's own subroutine listing is fed by COMPILATION-UNIT-scope
    // wildcard imports ALONE — the materialized group of each, concatenated
    // in import order (§ unitScopeWildcardImports / materializedPkgTfGroup).
    // A module-scope import contributes NOTHING here.  Runs after every
    // module so the groups are the same objects the modules list.
    if (auto uw9 = unitScopeWildcardImports(); !uw9.empty()) {
        std::vector<UHDM::task_func*> dtf9;
        for (auto* p9 : uw9)
            for (auto* tf9 : materializedPkgTfGroup(*p9))
                if (std::find(dtf9.begin(), dtf9.end(), tf9) == dtf9.end())
                    dtf9.push_back(tf9);
        if (!dtf9.empty()) {
            // `$unit`-scope subroutines of the sources themselves already own
            // this vector; the import group is appended, never substituted.
            auto* dv9 = d->Task_funcs();
            if (!dv9) {
                dv9 = s.MakeTask_funcVec();
                d->Task_funcs(dv9);
            }
            for (auto* tf9 : dtf9)
                if (std::find(dv9->begin(), dv9->end(), tf9) == dv9->end())
                    dv9->push_back(tf9);
        }
    }

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    // $bits(SIGNAL) typespec-bound arg refs bind their DEF nets (deferred:
    // the def param pre-pass ran before the nets existed).
    for (auto& [r0, sym0] : pendingBitsBoundRefs) {
        for (auto sc0 = sym0->getParentScope(); sc0;
             sc0 = sc0->asSymbol().getParentScope()) {
            if (sc0->asSymbol().kind != SymbolKind::InstanceBody)
                continue;
            auto dit0 =
                defMap.find(&sc0->asSymbol().as<InstanceBodySymbol>().getDefinition());
            if (dit0 != defMap.end()) {
                if (auto nit0 = dit0->second.nets.find(sym0);
                    nit0 != dit0->second.nets.end())
                    r0->Actual_group(nit0->second);
                else {
                    // Elaborated-instance param typespecs re-emit the $bits arg
                    // ref against the instance's own net symbol, but the def
                    // NetMap is keyed by the def-view body's symbols — bind by
                    // name to the DEF net (Surelog reuses work@<def>.<sig>).
                    for (auto& [ks, vn] : dit0->second.nets)
                        if (ks->name == sym0->name) {
                            r0->Actual_group(vn);
                            break;
                        }
                }
            }
            break;
        }
    }
    pendingBitsBoundRefs.clear();
    // Enum-constant array-index refs: the enum_const only exists once the
    // referencing scope's enum typespec has been minted (InterfArrayBind).
    for (auto& [r9, sym9] : pendingEnumIdxRefs) {
        if (auto eit9 = enumConstMap.find(sym9); eit9 != enumConstMap.end()) {
            r9->Actual_group(eit9->second);
            continue;
        }
        // The referencing scope (def body) and the scope whose enum typespec
        // was minted (elab body) hold DISTINCT symbols for the same
        // declaration; match on the shared declaration site.
        for (auto& [ks9, ec9] : enumConstMap)
            if (ks9->name == sym9->name && ks9->location == sym9->location) {
                r9->Actual_group(ec9);
                break;
            }
    }
    pendingEnumIdxRefs.clear();
    // Part-select fold constants' own logic_typespecs (bare-bound range),
    // materialized last (weak tail).
    for (auto& p : pendingPartSelFoldTs) {
        auto* lts = s.MakeLogic_typespec();
        auto* rg = s.MakeRange();
        rg->VpiParent(lts);
        auto mkb = [&](int64_t val) {
            auto* bc = s.MakeConstant();
            bc->VpiValue("UINT:" + std::to_string(val));
            return bc;
        };
        rg->Left_expr(mkb(p.left));
        rg->Right_expr(mkb(p.right));
        auto* rgv = s.MakeRangeVec();
        rgv->push_back(rg);
        lts->Ranges(rgv);
        p.rt->Actual_typespec(lts);
    }
    pendingPartSelFoldTs.clear();
    // --disable-feature=parametersubstitution: a substituted ref_obj borrows
    // the hopped parameter's typespec, which the deferred param-typespec pass
    // may only have filled in after the ref was built.
    for (auto& [dst, src] : noSubstRefTs)
        if (!dst->Actual_typespec() && src->Actual_typespec())
            dst->Actual_typespec(src->Actual_typespec());
    noSubstRefTs.clear();
    // § r10fsv2 — a struct-pattern member fold that read a same-package param
    // whose OWN typespec is built by the deferred pass above.
    for (auto& [rt, sym, owner, topView] : pkgPatValTsFix) {
        if (rt->Actual_typespec())
            continue;
        if (auto dit = pkgParamObj.find(sym);
            dit != pkgParamObj.end() && dit->second->Typespec() &&
            dit->second->Typespec()->Actual_typespec()) {
            rt->Actual_typespec(dit->second->Typespec()->Actual_typespec());
            continue;
        }
        // § r10fsv3 S6.  The ELAB-listing fallback is ELAB-ONLY.  A parameter
        // whose init is itself a param REFERENCE has a typespec in the elab
        // listing and none in the def one, and golden's DEF-view pattern
        // element then carries NO vpiTypespec AT ALL — not an empty ref
        // (FuncStructVal AxiUserWidth/FetchUserWidth vs the literal-init
        // XLEN sibling, which does have a def typespec and does keep the ref).
        if (!topView) {
            if (owner && owner->Typespec() == rt)
                owner->Typespec(nullptr);
            continue;
        }
        if (auto tit = pkgParamObjTop.find(sym);
            tit != pkgParamObjTop.end() && tit->second->Typespec())
            rt->Actual_typespec(tit->second->Typespec()->Actual_typespec());
    }
    pkgPatValTsFix.clear();
    // Base-class wiring last: every class_defn (package, module-local,
    // file-level, nested) now exists, so a base in any scope resolves.
    drainPendingExtends();
    // § r10fsv3 S1 FOREIGN-TYPEDEF PARAM SHARING.  The rule
    // pkgForeignTsTopFixups applies to package SUBROUTINES holds for package
    // PARAMETERS too: a parameter declared with ANOTHER package's typedef
    // (`localparam config_pkg::cva6_user_cfg_t cva6_cfg = ...`) binds the
    // declaring package's ELABORATED listing object in BOTH views — Surelog
    // creates that typespec once and shares it, so the def view never holds a
    // def-instanced copy of a foreign type.  A SAME-package type is untouched:
    // config_pkg's own `cva6_cfg_empty` keeps the def object in the def view
    // and the elab object in the elab view.
    //   This is cmp-load-bearing, not cosmetic: typespec::Compare chases
    // Instance(), so the def param's typespec decides WHICH package view the
    // whole-design walk descends into next.  Pointing at the def listing takes
    // the walk through the CLEAN typedef copy (no EvalFunc leftovers stamped,
    // ranges unfolded) where golden's walk goes through the elaborated,
    // stamped one — reported as `failRhs = <null>` on the struct's first
    // member (FuncStructVal, § r10fsv2 S1).
    //   Keyed structurally on the typespec's OWN vpiInstance: the def→elab
    // swap fires only for an object instanced at a DIFFERENT def package,
    // which is exactly "this named type was declared elsewhere".  It runs
    // HERE, not where the two views are built, because a package parameter's
    // ref_typespec is still empty then — the actual is filled by the deferred
    // typespec drain a few lines above.
    if (d->AllPackages() && d->TopPackages()) {
        std::map<const UHDM::BaseClass*, UHDM::package*> defToTop;
        for (auto* dp0 : *d->AllPackages())
            for (auto* tp0 : *d->TopPackages())
                if (tp0->VpiName() == dp0->VpiName()) {
                    defToTop[dp0] = tp0;
                    break;
                }
        for (auto* dp0 : *d->AllPackages()) {
            if (!dp0->Parameters())
                continue;
            for (auto* p0 : *dp0->Parameters()) {
                if (p0->UhdmType() != UHDM::uhdmparameter)
                    continue;
                auto* rt0 = ((UHDM::parameter*)p0)->Typespec();
                auto* at0 = rt0 ? rt0->Actual_typespec() : nullptr;
                if (!at0 || at0->VpiName().empty() || !at0->Instance())
                    continue;
                auto hit = defToTop.find(at0->Instance());
                // Instanced at its own def package, or at something that is
                // not a def package at all — nothing to share.
                if (hit == defToTop.end() ||
                    (const UHDM::BaseClass*)at0->Instance() ==
                        (const UHDM::BaseClass*)dp0 ||
                    !hit->second->Typespecs())
                    continue;
                for (auto* t0 : *hit->second->Typespecs())
                    if (t0->VpiName() == at0->VpiName() &&
                        t0->UhdmType() == at0->UhdmType()) {
                        rt0->Actual_typespec(t0);
                        break;
                    }
            }
        }
    }
    // EvalFunc member-assignment leftovers: stamp AFTER every typespec is
    // materialized (the struct ts a parameter points at is filled by the
    // deferred drain above) and only on the ELABORATED views.
    stampEvalFuncLeftovers(d);
    // § impCopyCastFold — the folded size-cast constant names the SAME
    // declared-type typespec its parameter does; that link is only final now.
    for (auto& [rt9, up9] : castFoldTsFix9)
        if (rt9 && up9 && !rt9->Actual_typespec() && up9->Typespec())
            rt9->Actual_typespec(up9->Typespec()->Actual_typespec());
    // § dimBoundInheritsParamEnc74 — A FOLDED SIZE-FORM DIMENSION BOUND
    // CARRIES THE `vpiConstType` AND VALUE TAG OF THE `param_assign` OF THE
    // PARAMETER IT SUBSTITUTED, READ OUT OF THE NEAREST ENCLOSING SCOPE.
    //
    // This is Surelog's own loop.  `CompileHelper::compileRanges`
    // (~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:4038-4155)
    // rewrites `[N]` to `range(UINT:0/64, vpiSubOp(<N>, INT:1/64))` and builds
    // `<N>` with `compileExpression(... Reduce::Yes, instance ...)`.  For a
    // parameter name that lands in `CompileHelper::getValue` (same file,
    // :871-1120), which mints the operand from `instance->getValue(name)`
    // (:966-981) — the SAME `Value` object `NetlistElaboration::elab_parameters_`
    // (src/DesignCompile/NetlistElaboration.cpp:429-432) stamps into that
    // parameter's `param_assign` Rhs — and, failing that, WALKS THE INSTANCE
    // CHAIN OUTWARD looking in `netlist->param_assigns()` for a `param_assign`
    // whose `Lhs()->VpiName()` is the name and CLONES its Rhs (:986-1024).
    // Either way the bound's encoding IS the param_assign's.
    //
    // ONLY the encoding.  The param_assign copy has
    // `CompileHelper::adjustSize` run over it afterwards
    // (NetlistElaboration.cpp:448) and the bound copy does not, which is why
    // the bound's SIZE is often not the param_assign's (measured: golden's
    // `s_sz [D]` bound is size 64 where its `param_assign` is size 32) and why
    // every size arm in `buildUnpackedRanges` — § dimFoldOverriddenParam23,
    // § dimFoldOverrideChainWidth26, § dimFoldReducedTypedWidth26 — stands
    // untouched.
    //
    // Deferred to design-final because an array declaration is emitted before
    // its own instance body's `param_assigns` exist, and because the ELAB
    // instance and gen-scope producers live in ModuleEmit, not ParamEmit, so
    // `paramRhsObj` never sees them (`R10E74_ENCDBG` reports `elab=0 def=0`
    // for every instance parameter and every gen-scope localparam).  Reading
    // the EMITTED param_assign instead of a symbol map is also what makes the
    // rule per-INSTANCE by construction.
    static const bool dimEncDbg74 = getenv("R10E74_ENCDBG");
    for (auto& [bc74, pn74] : dimBoundEncFix74) {
        if (!bc74 || pn74.empty())
            continue;
        // The bound must be one of the two DECIMAL encodings; a based/binary
        // bound keeps whatever its own law gave it.
        int32_t bct74 = bc74->VpiConstType();
        if (bct74 != vpiIntConst && bct74 != vpiUIntConst)
            continue;
        std::string bv74(bc74->VpiValue());
        auto bcl74 = bv74.find(':');
        if (bcl74 == std::string::npos)
            continue;
        const UHDM::constant* src74 = nullptr;
        // r10vearl74 FIX — THE OUTWARD WALK MUST NOT CROSS AN INSTANCE
        // BOUNDARY.  The walk resolves BY NAME, so once it leaves the
        // declaration's own instance body it can land on an unrelated
        // same-named `param_assign` in the PARENT instance and overwrite an
        // encoding that was already right.  Measured (verifier grid A,
        // `va1_v74.sv`): `module vq74; logic [3:0] q_pm [vpk74::PM];` with
        // `vpk74::PM = 4 * 2` is `INT:8` on golden in EVERY instance of
        // `vq74` — but under a parent that carries its own
        // `localparam int PM = 4 + 4` (`UINT:8`, same value, other tag) the
        // unbounded walk stamped `UINT:8`, 6 range cells per view,
        // pristine-RIGHT -> patched-WRONG.  Golden cannot do this: SystemVerilog
        // name resolution stops at the module body, and a package parameter is
        // not on the instance chain at all (Surelog's own outward walk,
        // CompileExpression.cpp:986-1024, is only the FALLBACK after
        // `instance->getValue(name)` has already answered with the package's
        // value).  So check each enclosing scope and STOP at the first
        // `instance` — module_inst / interface_inst / program / package /
        // udp_defn.  `gen_scope` and `gen_scope_array` are LEXICAL, sit below
        // that boundary and are still walked, which is exactly what the
        // gen-scope and multi-instance families this law was written for need.
        // When the walk finds nothing the emit-time value stands, and for a
        // package parameter that value is the package's own.
        for (const UHDM::any* up74 = bc74->VpiParent();
             up74 && !src74; up74 = up74->VpiParent()) {
            auto* sc74 = any_cast<const UHDM::scope*>(up74);
            if (!sc74)
                continue;
            if (auto* pas74 = sc74->Param_assigns())
                for (auto* pa74 : *pas74) {
                    if (!pa74 || !pa74->Lhs() ||
                        pa74->Lhs()->VpiName() != pn74)
                        continue;
                    if (auto* rh74 = pa74->Rhs();
                        rh74 && rh74->UhdmType() == UHDM::uhdmconstant)
                        src74 = (const UHDM::constant*)rh74;
                    break;
                }
            if (any_cast<const UHDM::instance*>(up74))
                break;
        }
        if (dimEncDbg74)
            fprintf(stderr, "ENC74 par=%s bound=%s src=%s\n", pn74.c_str(),
                    bv74.c_str(),
                    src74 ? std::string(src74->VpiValue()).c_str() : "-");
        if (!src74)
            continue;
        int32_t pct74 = src74->VpiConstType();
        if (pct74 != vpiIntConst && pct74 != vpiUIntConst)
            continue;
        std::string pv74(src74->VpiValue());
        auto pcl74 = pv74.find(':');
        if (pcl74 == std::string::npos)
            continue;
        bc74->VpiConstType(pct74);
        bc74->VpiValue(pv74.substr(0, pcl74 + 1) + bv74.substr(bcl74 + 1));
    }
    // § enumBaseTdCloneElabRanges114 (r10uvm114, decoded in the header) — an
    // enum's NAMED VECTOR-TYPEDEF base is a per-use `clone_tree` of the
    // typedef object OF THE VIEW being compiled, so outside the DEF-package
    // typedef listing it carries the ELABORATED (folded) bounds.  Design-final
    // because `buildEnumTs` runs before the TOP-view package listing exists
    // whenever another package wildcard-imports the enum's home package.
    //
    // The clone is re-pointed at the TOP-view listing object's OWN ranges — it
    // is NOT re-folded here — so a bound our elaborated listing deliberately
    // left symbolic stays symbolic, and the two objects cannot disagree.
    // FOUR fences, each one a refusal to move a cell this pass did not
    // measure: the top object must be the SAME typespec kind, the two range
    // vectors must have the SAME length, the swap happens only when the
    // clone's bounds hold an `operation` that the top object's do not, and the
    // top-level bound operator must not be `%` or `**` (see below).
    static const bool ebDbg114 = getenv("R10U114_ENUMBASEDBG");
    if (ebDbg114)
        fprintf(stderr, "ENUMBASE114 recorded=%zu topReg=%zu\n",
                enumBaseTdClone114.size(), pkgTopTypedefTs.size());
    for (auto& [cl114, td114] : enumBaseTdClone114) {
        if (!cl114 || !td114)
            continue;
        auto tit114 = pkgTopTypedefTs.find(td114);
        if (tit114 == pkgTopTypedefTs.end() || !tit114->second ||
            tit114->second == cl114)
            continue;
        UHDM::typespec* top114 = tit114->second;
        if (top114->UhdmType() != cl114->UhdmType())
            continue;
        auto rangesOf114 = [](UHDM::typespec* t) -> UHDM::VectorOfrange* {
            if (t->UhdmType() == UHDM::uhdmbit_typespec)
                return ((UHDM::bit_typespec*)t)->Ranges();
            if (t->UhdmType() == UHDM::uhdmlogic_typespec)
                return ((UHDM::logic_typespec*)t)->Ranges();
            return nullptr;
        };
        auto* curR114 = rangesOf114(cl114);
        auto* topR114 = rangesOf114(top114);
        if (!curR114 || !topR114 || curR114 == topR114 ||
            curR114->size() != topR114->size() || curR114->empty())
            continue;
        auto hasOp114 = [](UHDM::VectorOfrange* rv) {
            for (auto* r : *rv)
                for (auto* b : {r->Left_expr(), r->Right_expr()})
                    if (b && b->UhdmType() == UHDM::uhdmoperation)
                        return true;
            return false;
        };
        if (!hasOp114(curR114) || hasOp114(topR114))
            continue;
        // FOURTH FENCE (residue R1) — the two TOP-LEVEL bound operators where
        // our own ELABORATED listing object's encoder already disagrees with
        // golden: `%` (vpiModOp) and `**` (vpiPowerOp) fold to `INT:` /
        // vpiIntConst on golden and to `UINT:` / vpiUIntConst here
        // (`g114_h_ops.sv`, the thirteen-operator table; the other eleven
        // agree).  Repairing that encoder is a different law; this pass
        // REFUSES to spread it, so no cell it moves can end up wrong in a new
        // way.  Only the TOP-LEVEL operator is read — a `%` or `**` NESTED
        // under a `-` folds through vpiSubOp's arm and is not fenced.
        bool badEnc114 = false;
        for (auto* r : *curR114)
            for (auto* b : {r->Left_expr(), r->Right_expr()})
                if (b && b->UhdmType() == UHDM::uhdmoperation) {
                    int32_t ot114 = ((UHDM::operation*)b)->VpiOpType();
                    if (ot114 == vpiModOp || ot114 == vpiPowerOp)
                        badEnc114 = true;
                }
        if (badEnc114)
            continue;
        if (ebDbg114)
            fprintf(stderr, "ENUMBASE114 clone=%s top=%s dims=%zu\n",
                    std::string(cl114->VpiName()).c_str(),
                    std::string(top114->VpiName()).c_str(), curR114->size());
        if (cl114->UhdmType() == UHDM::uhdmbit_typespec)
            ((UHDM::bit_typespec*)cl114)->Ranges(topR114);
        else
            ((UHDM::logic_typespec*)cl114)->Ranges(topR114);
    }
    // Elab param_assign Rhs ts refs -> the def parameter's FINAL typespec.
    // Dead last: every deferred def-view typespec rebind is done by now.
    drainShareDefParamTs();
    // In-body func_call operation-arg stamps: reachability needs the whole
    // design's call set, so it is resolved here.
    drainBodyOpArgTs();
    // Deferred `Class::f()` -> out-of-body task_func links (§ ...26).
    drainScopedCallBind26();
    // § recvNamesSubroutineCollapsesStmtCall172 — the LATE half of the link:
    // a collapsed call whose callee had not been emitted when the caller's
    // body was walked.  Same shape (and same kind guard) as §26's drain.
    drainCollapseLink172();
    // § pkgVarInitCmViewClone111 — IMMEDIATELY AFTER that drain: a package
    // variable initializer's `C::m()` binds the `C::m` listing entry of the
    // package VIEW it lives in, where that view has one.  The drain above is
    // what puts the class_defn's method there in the first place, so this pass
    // cannot run before it (measured: three of the four golden cells are
    // deferred calls and only the fourth is bound at emission).
    for (auto* pv111 : {d->AllPackages(), d->TopPackages()})
        if (pv111)
            for (auto* p111 : *pv111)
                bindPkgVarInitClassMethodClones111(p111);
    // LAW S: a package SCALAR typedef is BARE at every variable-like binding.
    // Dead last — after every deferred typespec rebind above, so no later pass
    // can put a qualified object back.
    // § modPkgTypedefTopTs15 — a module listing's package-typedef bindings name
    // the ELABORATED package's typespecs.  Immediately BEFORE LAW S, so LAW S
    // then makes its bare/re-qualified copies out of the top objects (their
    // Typedef_alias targets follow automatically).
    modPkgTypedefTopTs15();
    // § pkgParamTsTopInstance16 — the same question for a SUBSTITUTED package
    // parameter's constant typespec.  After the typedef pass so a typedef
    // object it also moved is not moved twice.
    pkgParamTsTopInstance16(d);
    bareScalarTypedefVarTs();
    // § castPkgVecTdBareViewClone123 — the CAST flavour of LAW S's
    // per-use clone, at the one binding LAW S's own walk cannot classify (an
    // operation's target typespec carries no view of its own).  Immediately
    // after LAW S, so the two alias passes below see its copies; the copies
    // themselves come from this pass's OWN memo (see TypeEmit.cpp).
    castPkgTdCloneViewTs123();
    // § importCloneBareTdAlias16: inside a wildcard-import CLONE body the
    // alias target of that bare copy is bare too.  Right after LAW S, whose
    // memo it re-points.
    importCloneBareTdAlias16();
    // § cloneAliasTopTarget19 — the def->top question for the ALIAS TARGET of
    // a clone no parent walk can classify (the clone is unparented, so
    // ownership has to be read off the BINDING ref).  After both alias passes
    // above, whose deliberate targets it must not disturb.
    cloneAliasTopTarget19();
    // § modTdClonePkgTopInstance16 — LAW S and its alias fix-ups are the last
    // writers of a module listing's typespec clones, so the clone-instance
    // stamp runs after them.
    modTdClonePkgTopInstance16(d);
    // § pkgBoundMintTsTopInstance17 — the MISSING-INSTANCE mirror: a per-site
    // typespec the folded-bound path MINTED has no vpiInstance at all.  Runs
    // beside the pass-16 stamps and never overwrites one they set.
    pkgBoundMintTsTopInstance17(d);
    // § pkgImportAggCloneLastWriter32 — a shared package-typedef IMPORT CLONE
    // is owned by the LAST package that listed it.  Dead last among the
    // instance passes: the wildcard subroutine-clone stamp and the two
    // top-instance passes above all write the same field (incl. pass 17's
    // mint stamp immediately above).
    pkgImportCloneLastWriter32();
    // § lawSCopyHomeInstance36 — the same question for the LAW-S bare COPIES
    // those clones are made into.  Strictly after pass 32 and after all three
    // def->top stamps above: it is the last writer of a COPY's vpiInstance,
    // and it never touches a listing object (pass 32's own objects included).
    lawSCopyHomeInstance36(d);
    // ...and an anonymous class_typespec never carries vpiInstance.
    clearAnonClassTsInstance();
    // § pkgCloneHierBind9 — bind the BASE of every dotted reference inside a
    // wildcard-import package CLONE body (see TaskFuncEmit): the first
    // Path_elems entry of a hier_path and a method_func_call's Prefix, when
    // the name is one of that body's own formals/locals.  Only the clone
    // view: the home package's copy of the same body leaves them null in
    // golden too, and so do we.  Runs over the arena so all ~15 hier_path
    // shapes ExprEmit builds are covered from one place.
    if (!pkgCloneBodyLocals9.empty()) {
        auto ownerTf9 = [](const UHDM::BaseClass* o) -> const UHDM::task_func* {
            for (int g9 = 0; o && g9 < 40; g9++, o = o->VpiParent())
                if (o->UhdmType() == UHDM::uhdmfunction ||
                    o->UhdmType() == UHDM::uhdmtask)
                    return (const UHDM::task_func*)o;
            return nullptr;
        };
        // A body's BLOCK-local declarations (`foreach (...) begin string acc
        // = ...; end`) never reach funcMap — emitStmt registers them in the
        // nested copy it hands the block — so the lookup climbs the emitted
        // parent chain first and consults each enclosing block's own
        // Variables.  That is also the correct SHADOWING order: uvm_reg::
        // do_check declares `acc` twice, once per foreach block, and each
        // reference must reach its own.
        auto blockVar9 = [](const UHDM::BaseClass* b9,
                            std::string_view nm9) -> UHDM::any* {
            const UHDM::VectorOfvariables* vs9 = nullptr;
            if (b9->UhdmType() == UHDM::uhdmbegin)
                vs9 = ((const UHDM::begin*)b9)->Variables();
            else if (b9->UhdmType() == UHDM::uhdmnamed_begin)
                vs9 = ((const UHDM::named_begin*)b9)->Variables();
            else if (b9->UhdmType() == UHDM::uhdmfork_stmt)
                vs9 = ((const UHDM::fork_stmt*)b9)->Variables();
            else if (b9->UhdmType() == UHDM::uhdmnamed_fork)
                vs9 = ((const UHDM::named_fork*)b9)->Variables();
            if (!vs9)
                return nullptr;
            for (auto* v9 : *vs9)
                if (v9 && v9->VpiName() == nm9)
                    return (UHDM::any*)v9;
            return nullptr;
        };
        // § pkgCloneLoopVarBind37 — a foreach LOOP VARIABLE is the one clone
        // body binding target that is NOT a declared variable: the loop lists
        // an unresolved ref_var (§ StmtEmit's classMethodNoBind arm) and both
        // the listing entry and every body reference to the name bind the
        // shared § cloneLoopVarShared37 object hanging off it.  Consulted in
        // the SAME innermost-out climb as blockVar9, which is what makes
        // shadowing come out right when a body reuses `i` in two loops.
        auto loopVar37 = [](const UHDM::BaseClass* b37,
                            std::string_view nm37) -> UHDM::any* {
            if (b37->UhdmType() != UHDM::uhdmforeach_stmt)
                return nullptr;
            auto* lvs37 = ((const UHDM::foreach_stmt*)b37)->VpiLoopVars();
            if (!lvs37)
                return nullptr;
            for (auto* v37 : *lvs37)
                if (v37 && v37->UhdmType() == UHDM::uhdmref_var &&
                    v37->VpiName() == nm37)
                    return (UHDM::any*)((const UHDM::ref_var*)v37)
                        ->Actual_group();
            return nullptr;
        };
        // Reading and writing vpiActual across the three reference kinds
        // golden binds in a clone body.  Pass 9 wrote only the ref_obj half
        // because it only ever looked at hier_path elements and method-call
        // prefixes; § pkgCloneLocalRefBind37 widens the SWEEP, and a widened
        // sweep necessarily reaches a foreach's own `ref_var` (its array
        // reference and its loop variable) and an array `bit_select`'s base.
        auto actOf37 = [](const UHDM::any* e37) -> const UHDM::any* {
            switch (e37->UhdmType()) {
                case UHDM::uhdmref_obj:
                    return ((const UHDM::ref_obj*)e37)->Actual_group();
                case UHDM::uhdmref_var:
                    return ((const UHDM::ref_var*)e37)->Actual_group();
                case UHDM::uhdmbit_select:
                    return ((const UHDM::bit_select*)e37)->Actual_group();
                default:
                    return nullptr;
            }
        };
        auto setAct37 = [](UHDM::any* e37, UHDM::any* a37) {
            switch (e37->UhdmType()) {
                case UHDM::uhdmref_obj:
                    ((UHDM::ref_obj*)e37)->Actual_group(a37);
                    break;
                case UHDM::uhdmref_var:
                    ((UHDM::ref_var*)e37)->Actual_group(a37);
                    break;
                case UHDM::uhdmbit_select:
                    ((UHDM::bit_select*)e37)->Actual_group(a37);
                    break;
                default:
                    break;
            }
        };
        auto bindable37 = [](const UHDM::any* e37) {
            auto t37 = e37->UhdmType();
            return t37 == UHDM::uhdmref_obj || t37 == UHDM::uhdmref_var ||
                   t37 == UHDM::uhdmbit_select;
        };
        auto bind9 = [&](UHDM::any* e9, const UHDM::BaseClass* anchor9) {
            if (!e9 || !bindable37(e9))
                return;
            if (actOf37(e9) || e9->VpiName().empty())
                return;
            auto* tf9 = ownerTf9(anchor9);
            if (!tf9)
                return;
            auto bit9 = pkgCloneBodyLocals9.find(tf9);
            if (bit9 == pkgCloneBodyLocals9.end())
                return;
            std::string nm9(e9->VpiName());
            for (const UHDM::BaseClass* a9 = anchor9;
                 a9 && (const UHDM::BaseClass*)a9 != (const UHDM::BaseClass*)tf9;
                 a9 = a9->VpiParent()) {
                if (auto* lv37 = loopVar37(a9, nm9)) {
                    if (lv37 != e9)
                        setAct37(e9, lv37);
                    return;
                }
                if (auto* bv9 = blockVar9(a9, nm9)) {
                    setAct37(e9, bv9);
                    return;
                }
            }
            auto nit9 = bit9->second.find(nm9);
            if (nit9 != bit9->second.end())
                setAct37(e9, nit9->second);
        };
        // § pkgCloneMember10 — a NON-BASE element resolves against the
        // preceding element's TYPE first, and a struct member wins over a
        // same-named local.  uvm_printer::print_array_header writes
        // `row_info.name = ...` with a formal ALSO called `name`: golden's
        // clone binds the ts member (uvm_printer_row_info.name), never the
        // io_decl, and binds `row_info.level` / `.type_name` / `.val` the
        // same way even though no local of that name exists at all.  Where
        // the base is a CLASS the members are not typespec_members and
        // nothing resolves, so `knobs.indent` stays null and
        // `__m_uvm_status_container.printer` falls back to the formal (the
        // LAW PCB witness).  Census r10uvm9e on SeqDriver: golden binds 184
        // typespec_members, all at a non-base index, all in adpcm_pkg.
        auto actualTs10 = [](const UHDM::any* a10) -> const UHDM::typespec* {
            if (!a10)
                return nullptr;
            const UHDM::ref_typespec* rt10 = nullptr;
            if (a10->UhdmType() == UHDM::uhdmio_decl)
                rt10 = ((const UHDM::io_decl*)a10)->Typespec();
            else if (a10->UhdmType() == UHDM::uhdmtypespec_member)
                rt10 = ((const UHDM::typespec_member*)a10)->Typespec();
            else if (auto* e10 = any_cast<const UHDM::expr*>(a10))
                rt10 = e10->Typespec();
            return rt10 ? rt10->Actual_typespec() : nullptr;
        };
        // The written element carries no index, so an array/queue of structs
        // reaches its ELEMENT type the same way a plain struct variable does
        // (`m_rows[j].name` after the select is folded into the base).
        auto structTs10 =
            [](const UHDM::typespec* t10) -> const UHDM::typespec* {
            for (int g10 = 0; t10 && g10 < 8; g10++) {
                switch (t10->UhdmType()) {
                    case UHDM::uhdmstruct_typespec:
                    case UHDM::uhdmunion_typespec:
                        return t10;
                    case UHDM::uhdmarray_typespec: {
                        auto* er10 =
                            ((const UHDM::array_typespec*)t10)->Elem_typespec();
                        t10 = er10 ? er10->Actual_typespec() : nullptr;
                        break;
                    }
                    case UHDM::uhdmpacked_array_typespec: {
                        auto* er10 = ((const UHDM::packed_array_typespec*)t10)
                                         ->Elem_typespec();
                        t10 = er10 ? er10->Actual_typespec() : nullptr;
                        break;
                    }
                    default:
                        return nullptr;
                }
            }
            return nullptr;
        };
        auto bindMember10 = [&](UHDM::any* e10, const UHDM::any* prev10,
                                const UHDM::BaseClass* anchor10) -> bool {
            if (!e10 || !prev10 || e10->UhdmType() != UHDM::uhdmref_obj)
                return false;
            auto* r10 = (UHDM::ref_obj*)e10;
            if (r10->Actual_group() || r10->VpiName().empty())
                return false;
            // Clone bodies only — the same rule outside them would bind
            // hier_paths in module scopes that golden leaves null.
            auto* tf10 = ownerTf9(anchor10);
            if (!tf10 || !pkgCloneBodyLocals9.count(tf10))
                return false;
            const UHDM::any* pact10 = nullptr;
            if (prev10->UhdmType() == UHDM::uhdmref_obj)
                pact10 = ((const UHDM::ref_obj*)prev10)->Actual_group();
            else if (prev10->UhdmType() == UHDM::uhdmref_var)
                pact10 = ((const UHDM::ref_var*)prev10)->Actual_group();
            else if (prev10->UhdmType() == UHDM::uhdmtypespec_member)
                pact10 = prev10;
            if (!pact10)
                return false;
            auto* sts10 = structTs10(actualTs10(pact10));
            // ...and only a PACKAGE-scope struct type resolves.  A type
            // declared INSIDE a class is invisible from the clone's symbol
            // table exactly as LAW C's class-scope enum constant is: golden
            // gives `m_verbosity_setting setting;` (typedef'd inside class
            // uvm_component) an unresolved ref_var and leaves EVERY
            // `setting.<member>` null, while `uvm_printer_row_info row_info;`
            // (package scope) resolves and binds all five members.  Same
            // witness pair for uvm_cmdline_parsed_arg_t (`t.arg`, `t.args`).
            if (!sts10 || (sts10->VpiParent() &&
                           sts10->VpiParent()->UhdmType() ==
                               UHDM::uhdmclass_defn))
                return false;
            const UHDM::VectorOftypespec_member* mems10 =
                sts10->UhdmType() == UHDM::uhdmstruct_typespec
                    ? ((const UHDM::struct_typespec*)sts10)->Members()
                    : ((const UHDM::union_typespec*)sts10)->Members();
            if (!mems10)
                return false;
            for (auto* m10 : *mems10)
                if (m10 && m10->VpiName() == r10->VpiName()) {
                    r10->Actual_group((UHDM::any*)m10);
                    return true;
                }
            return false;
        };
        for (auto& kv9 : s.AllObjects()) {
            auto* o9 = (UHDM::BaseClass*)kv9.first;
            if (!o9)
                continue;
            if (o9->UhdmType() == UHDM::uhdmhier_path) {
                // EVERY element, not just the base: Surelog's clone lookup is
                // purely by NAME against the local scope, so
                // `__m_uvm_status_container.printer = printer` binds its
                // SECOND element to the formal `printer` even though that
                // element is the container's member (uvm_object::sprint:896).
                // A non-base element tries the preceding element's TYPE first
                // (pkgCloneMember10 above) and only then that name lookup.
                if (auto* es9 = ((UHDM::hier_path*)o9)->Path_elems()) {
                    const UHDM::any* prev10 = nullptr;
                    for (auto* e0 : *es9) {
                        if (!prev10 || !bindMember10(e0, prev10, o9))
                            bind9(e0, o9);
                        prev10 = e0;
                    }
                }
            }
            else if (o9->UhdmType() == UHDM::uhdmmethod_func_call)
                bind9((UHDM::any*)((UHDM::method_func_call*)o9)->Prefix(), o9);
        }
        // § pkgCloneLocalRefBind37 — and then the SAME name lookup for every
        // OTHER reference in a clone body.  Pass 9 read the law off hier_path
        // bases alone and wrote it that narrowly; the r10uvm28g census says
        // golden applies it to ordinary refs too, and that is where 88% of
        // SeqDriver's 3171 binding misses live (t51a/t51b):
        //
        //   DEFPKG imp51::f51 | bit_select 'arr2' -> array_var:arr2  (base of
        //       a body-local array)
        //   DEFPKG imp52::c52::count | ref_var 'loc' -> array_var:loc  (a
        //       foreach's ARRAY reference, when the array is a body local)
        //   DEFPKG imp52::c52::count | ref_obj 'i'  -> ref_var:i       (a
        //       foreach LOOP VARIABLE, § pkgCloneLoopVarBind37)
        //
        // with the NEGATIVES in the same goldens and satisfied by the
        // "body's own locals" restriction alone: a CLASS PROPERTY reached
        // bare (`bit_select 'm_kids'`, `ref_var 'm_kids'` as the foreach
        // array) and `this` stay null in golden's clone, and so do they here
        // because neither is in pkgCloneBodyLocals9.  This runs SECOND so the
        // § pkgCloneMember10 rule still owns the non-base hier_path elements;
        // bind9 only ever fills a null, so nothing above can be overwritten.
        for (auto& kv37 : s.AllObjects()) {
            auto* o37 = (UHDM::any*)kv37.first;
            if (o37 && bindable37(o37))
                bind9(o37, o37);
        }
    }
    pkgCloneBodyLocals9.clear();
    // § cloneStmtHomeVarRef17 — a clone body's STATEMENT reference to a body
    // LOCAL binds the ELABORATED HOME body's variable, not the clone's own
    // listing entry (its FORMAL references keep the clone's io_decls).  AFTER
    // pkgCloneHierBind9, which is the other half of the same question: that
    // pass fills a hier_path BASE (and a method-call prefix) that golden binds
    // only inside a clone, and it necessarily binds the clone's own object —
    // so this rewrite has to see those bindings, not race them.
    cloneStmtHomeVarRef17();
    // § hierCallArgTakesBase39 — a CLASS-METHOD call written `recv.m(args)` in
    // EXPRESSION position, whose receiver is ONE bare name, hands EVERY DIRECT
    // reference ARGUMENT the RECEIVER's own vpiActual — not the argument's
    // declaration, and not null:
    //
    //   DEFPKG adpcm_pkg::uvm_component::create_component
    //     ref_obj 'factory'             -> class_var:factory   (the base)
    //     ref_obj 'requested_type_name'  -> class_var:factory   (golden)
    //     ref_obj 'name'                 -> class_var:factory   (golden)
    //     ref_obj 'this'                 -> class_var:factory   (golden)
    //
    // where we bound each argument to its own io_decl (a WRONG target, which
    // only BINDWRONG can see) or left it null.  Surelog's `compileTfCall`
    // reaches the argument list through the dotted-name path and resolves it
    // against the object it has just bound the ROOT name to; nothing else in
    // the emitted tree records that, so this reads as a per-reference law.
    //
    // THE GATE IS THE WHOLE LAW (r10uvm39h over the UVM-4: 4761 rows in this
    // position, every cell read off ONE golden in tools/probe/r10uvm39repro):
    //   * the BASE must be BOUND — and the ONLY place golden binds it is a
    //     wildcard-import CLONE body (§ pkgCloneHierBind9).  All 272 corpus
    //     rows are `adpcm_pkg` clones; the home package's own listing (uvm_pkg,
    //     1922 rows) and a MODULE body (t55a's `mq = mh.take55(mf, ms)`) leave
    //     base AND arguments alone, in golden and in ours.  So no extra
    //     view/scope test is needed: "base bound" IS the clone test.
    //   * the path must be EXACTLY TWO elements.  t55b cell C
    //     (`m3.deep.take56(f3, s3)`, base BOUND) keeps SELF, and so do all 32
    //     corpus rows at length 3 — the length gate is measured, not assumed.
    //   * the base must be a plain ref_obj: an INDEXED receiver
    //     (`parr[i4].one56(f4)`, t55b cell D) keeps SELF.
    //   * only the DIRECT arguments: t55b cell H (`recv8.take56(f8 + 1, s8)`)
    //     binds `s8` to the base and leaves `f8`, one level down inside the
    //     operation, on its own io_decl.
    //   * STATEMENT position never has a hier_path at all (cell F), so it is
    //     out of reach by construction.
    // and classRecvCallHp39 carries the one condition the tree cannot express:
    // a BUILT-IN associative-array method with a bound base
    // (`visited.exists(succ)`, t55b cell E) has the identical two-element shape
    // and keeps SELF.  Testing the base's target kind would work on golden
    // (array_var) and FAIL on ours, which emits that same declaration as a
    // logic_var — so the arm that built the hier_path is the predicate.
    //
    // Runs AFTER § cloneStmtHomeVarRef17 deliberately: that pass re-points a
    // clone's body-local bindings, so the base's FINAL actual is only knowable
    // here, and reading it earlier would propagate a stale target.  It is the
    // only writer of these argument actuals and it OVERWRITES (the 180 rows we
    // bound to the wrong object are the bigger half; 82 were null).
    if (!classRecvCallHp39.empty()) {
        auto actOf39 = [](const UHDM::any* e) -> UHDM::any* {
            if (!e)
                return nullptr;
            switch (e->UhdmType()) {
                case UHDM::uhdmref_obj:
                    return (UHDM::any*)((const UHDM::ref_obj*)e)->Actual_group();
                case UHDM::uhdmref_var:
                    return (UHDM::any*)((const UHDM::ref_var*)e)->Actual_group();
                case UHDM::uhdmbit_select:
                    return (UHDM::any*)((const UHDM::bit_select*)e)
                        ->Actual_group();
                default:
                    return nullptr;
            }
        };
        auto setAct39 = [](UHDM::any* e, UHDM::any* a) {
            switch (e->UhdmType()) {
                case UHDM::uhdmref_obj:
                    ((UHDM::ref_obj*)e)->Actual_group(a);
                    break;
                case UHDM::uhdmref_var:
                    ((UHDM::ref_var*)e)->Actual_group(a);
                    break;
                case UHDM::uhdmbit_select:
                    ((UHDM::bit_select*)e)->Actual_group(a);
                    break;
                default:
                    break;
            }
        };
        for (auto* hp39 : classRecvCallHp39) {
            auto* es39 = hp39 ? ((UHDM::hier_path*)hp39)->Path_elems() : nullptr;
            if (!es39 || es39->size() != 2)
                continue;
            auto* b39 = (*es39)[0];
            if (!b39 || b39->UhdmType() != UHDM::uhdmref_obj)
                continue;
            UHDM::any* bact39 = actOf39(b39);
            if (!bact39)
                continue;
            auto* mfc39 = (*es39)[1];
            if (!mfc39 || mfc39->UhdmType() != UHDM::uhdmmethod_func_call)
                continue;
            auto* as39 = ((UHDM::method_func_call*)mfc39)->Tf_call_args();
            if (!as39)
                continue;
            for (auto* a39 : *as39) {
                if (!a39 || a39 == b39)
                    continue;
                auto t39 = a39->UhdmType();
                if (t39 != UHDM::uhdmref_obj && t39 != UHDM::uhdmref_var &&
                    t39 != UHDM::uhdmbit_select)
                    continue;
                setAct39(a39, bact39);
            }
        }
    }
    classRecvCallHp39.clear();
    // § classRetNameDefViewNoBind37 — the EXTRA-side mirror of
    // § pkgCloneLocalRefBind37: a class method's own-name (implicit return
    // variable) reference binds only in the ELABORATED listing of its class.
    // After the two clone-binding passes above, which never touch a
    // return-name ref (drainFuncRet owns those), and design-final because the
    // predicate is which package VIEW lists the class_defn.
    classRetNameDefViewNoBind37(d);
    // § classMethodRetNameNoBind56 + § retNameNewLhsNoBind56 — DESIGN-FINAL,
    // immediately after pass 37 because they are the same field on the same
    // references and the two laws are disjoint from its view law: 56/A drops
    // the binding on an IN-BODY class method's return name in EVERY view
    // (`vpiMethod` = 1; golden binds 0 of 241 such refs over the four UVM
    // tests), 56/B drops it on the `= new(...)` artefact-hier_path Lhs that
    // § invalidNewCallFromSyntax55 had already nulled and this drain
    // re-bound.  Nothing after this point reads these refs' `Actual_group`:
    // § thisImplicitNetBoth38 requires `VpiName() == "this"` and
    // § castSizeParamRefBindFinal only walks a listing's `Parameters()`.
    retNameNoBind56(d);
    // § castSizeParamRefBindFinal — a `P'(x)` size cast whose target P is a
    // module-BODY localparam leaves its int_typespec's Cast_to_expr ref_obj
    // UNBOUND: § stampCastSizeParamTs binds `up` only on the call that first
    // mints the ref, and for a body localparam that call runs before the
    // listing's parameter object exists (the same cast on a PORT-LIST
    // localparam — `localparam int unsigned DepthW = $clog2(Depth+1)` in the
    // parameter port list — IS bound on both sides, which is the
    // distinguisher).  int_typespec::Compare chases Cast_to_expr and
    // ref_obj::Compare chases Actual_group, so a null there reports as
    // `parameter 'PTRV_W' vs <null>` with the module_inst as the parent —
    // ve.sv isolates it to this one field with both Parameters() and
    // Param_assigns() otherwise identical.  Surelog binds the LISTING'S OWN
    // parameter of that name, so the repair is by name within the listing;
    // it only ever fills a null and never rewrites an existing binding.
    // Corpus: prim_fifo_async PTRV_W (4 heads: dmi_cdc, dmi_jtag,
    // prim_fifo_async, tlul_fifo_async) + prim_filter_ctr CTR_WIDTH.
    {
        auto fixList9 = [&](UHDM::instance* in9) {
            auto* ps9 = in9 ? in9->Parameters() : nullptr;
            if (!ps9)
                return;
            for (auto* p9 : *ps9) {
                auto* rt9 = ((UHDM::expr*)p9)->Typespec();
                if (!rt9)
                    continue;
                auto* a9 = rt9->Actual_typespec();
                if (!a9 || a9->UhdmType() != UHDM::uhdmint_typespec)
                    continue;
                auto* ce9 = ((UHDM::int_typespec*)a9)->Cast_to_expr();
                if (!ce9 || ce9->UhdmType() != UHDM::uhdmref_obj)
                    continue;
                auto* r9 = (UHDM::ref_obj*)ce9;
                if (r9->Actual_group())
                    continue;
                for (auto* q9 : *ps9)
                    if (q9->VpiName() == r9->VpiName()) {
                        r9->Actual_group(q9);
                        break;
                    }
            }
        };
        if (auto* am9 = d->AllModules())
            for (auto* m9 : *am9)
                fixList9(m9);
        if (auto* tm9 = d->TopModules())
            for (auto* m9 : *tm9)
                fixList9(m9);
    }
    // § cbEventRefFirstInstance15 — DESIGN-FINAL, and placed AHEAD of the pinned
    // tail below because it is independent of every pass there: it only fills a
    // NULL vpiActual on a clocking-block EVENT ref_obj, and none of the four
    // tail passes reads or writes one (§ 54 writes class_typespec spans, § 24 /
    // § 23 / § 45 rewrite package and class LISTINGS, § 38 touches only refs
    // NAMED `this`).  Every interface view has been emitted by this point, which
    // is the only ordering this drain actually requires.
    drainCbElabRefs15();
    // NOTE § classNestedClassTdGroupNoAnchor54 — DESIGN-FINAL, and BEFORE the
    // three listing passes below so they publish finished objects.  It is
    // placed here and not later because it must not disturb the pinned tail
    // ordering (§ classInheritsContainerImports23 -> § 45 -> § 38 DEAD LAST);
    // it only writes a span and one vpiTypedefAlias child on class-nested
    // class_typespecs, which none of those passes reads.
    drainClassNestedTdGroups54();
    // § importPublishesPackageClasses24 — DESIGN-FINAL, and BEFORE the class
    // arm below: the package listings it rewrites (and the names it
    // requalifies) are what the class arm then inherits.
    importPublishesPackageClasses24();
    // § classInheritsContainerImports23 — DESIGN-FINAL: a class's inherited
    // listings are the very objects its container's imports already
    // materialized, so every package view has to be complete first.
    classInheritsContainerImports23();
    // § modulePublishesPackageClasses45 — the MODULE arm of § 24, AFTER both of
    // the passes above.  After § 24 because it inherits the names § 24
    // requalifies (SeqDriver's module reads `adpcm_pkg::this_type`), and after
    // the class arm so it cannot influence it: the class arm reads package
    // listings and a class's own, never a module's, and running last makes that
    // independence structural instead of argued.
    modulePublishesPackageClasses45();
    // § thisImplicitNetBoth38 — DEAD LAST: its predicate is which package
    // views list the routine, so every listing rewrite above (the two import
    // passes included) has to have run.  It only ever fills a null
    // Actual_group on a reference named `this` and appends one net.
    thisImplicitNetBoth38(d);
    // § unsizedBasedParamRhsSize106 — AFTER the pinned tail, and it cannot
    // disturb it: it writes only VpiSize and the vpiTypespec REFERENCE of
    // param_assign Rhs CONSTANTS, and none of the four tail passes above reads
    // either (§ 54 writes class_typespec spans, § 24 / § 23 / § 45 rewrite
    // package and class LISTINGS, § 38 fills a null Actual_group on refs named
    // `this` and appends one net).  Running last is what makes the width and
    // typespec final: the many per-view paths that re-size a copied constant
    // have all run by now.
    drainUnsizedBasedRhs106();
    // § unitImportHoistsPkgParams146, THE BINDING ARM — DEAD LAST, and it can
    // only ever REPLACE a folded package-parameter value on a reference whose
    // name the design listing carries.  It never fills a null Actual_group (so
    // it cannot race § thisImplicitNetBoth38 or § pkgCloneHierBind9) and never
    // touches a listing, a typespec or a span.
    //
    // Surelog's `UhdmWriter::lateBinding` walks `ref->VpiParent()` UPWARD and
    // binds out of `design->Parameters()` the moment the walk reaches the
    // design (UhdmWriter.cpp:3359-3370) — BEFORE the package rule that hands a
    // reference its `param_assign`'s Rhs (:3814-3822).  Two things therefore
    // gate the rewrite, and BOTH are measured, not argued:
    //
    //  (1) THE CHAIN MUST REACH THE DESIGN.  Four golden UVM_LARGE_STRING
    //      references sit under a `range > logic_typespec` whose chain ends
    //      before any scope; golden leaves all four on the package's folded
    //      value, and so do we.
    //  (2) THE CHAIN MUST NOT PASS THROUGH A `ref_typespec`.  That is the
    //      difference between the two typespec-range shapes golden splits:
    //      `range > logic_typespec > package > design` (the PACKAGE typedef
    //      `uvm_bitstream_t`'s `[UVM_STREAMBITS-1:0]`) binds the design copy,
    //      while `range > logic_typespec > ref_typespec > logic_var > ...`
    //      (uvm_string_to_bits's own `logic [UVM_LARGE_STRING-1:0]` local)
    //      does not — a DECLARATION's own typespec was resolved when the
    //      declaration compiled and never went on the component's late-binding
    //      pool at all.
    //
    // CENSUS (r10uvm146repro/ct146cen, three row-modes, identical in each):
    // 59 references carry one of the 45 listed names; golden binds 53 of them
    // to the design copy and 6 to the package's folded constant/operation;
    // ours bound 55 to the folded value and 4 (chain-does-not-reach) the same
    // way golden does.  The gate splits exactly 53 / 6.
    // § unitImportHoistsPkgParams146v — THE FIRST LISTED ENTRY WINS, AND IT CAN
    // BE THE COMPILATION UNIT'S OWN PARAMETER.  `lateBinding` does not look up
    // a name in the import's materialized set: it scans `design->Parameters()`
    // IN ORDER and takes the FIRST entry whose `VpiName` matches
    // (UhdmWriter.cpp:3361-3369, `break` out of the for on the first hit).  The
    // unit's OWN parameters are listed BEFORE the imported copies, so when a
    // `$unit` parameter and an imported one share a name, golden binds the OWN
    // one.  Measured on the verifier arm `v33_own_vs_imported.sv`: golden lists
    // `CLASH`(own, 33), `CLASH`(imported pv33, 133), `OTHER`(imported, 134) and
    // binds `pv33::fp`'s `CLASH` to the value **33**; binding straight out of
    // the import map gave 133.  This map is rebuilt from the final listing with
    // `emplace` (first wins) and is restricted to names the import
    // materialized, so the gate — "a `$unit` import of a package that has
    // parameters" — is unchanged.
    std::map<std::string, UHDM::parameter*> bind146;
    if (!designImportParam146.empty() && d->Parameters())
        for (auto* q146 : *d->Parameters()) {
            if (!q146 || q146->UhdmType() != UHDM::uhdmparameter)
                continue;
            std::string qn146(q146->VpiName());
            if (designImportParam146.count(qn146))
                bind146.emplace(qn146, (UHDM::parameter*)q146);
        }
    if (!bind146.empty())
        for (auto& kv146 : s.AllObjects()) {
            auto* o146 = (UHDM::BaseClass*)kv146.first;
            if (!o146 || o146->UhdmType() != UHDM::uhdmref_obj)
                continue;
            auto* r146 = (UHDM::ref_obj*)o146;
            const UHDM::any* act146 = r146->Actual_group();
            if (!act146)
                continue;
            const auto at146 = act146->UhdmType();
            if (at146 != UHDM::uhdmconstant && at146 != UHDM::uhdmoperation)
                continue;
            if (r146->VpiName().empty())
                continue;
            auto it146 = bind146.find(std::string(r146->VpiName()));
            if (it146 == bind146.end())
                continue;
            bool reaches146 = false;
            const UHDM::BaseClass* up146 = o146->VpiParent();
            for (int g146 = 0; up146 && g146 < 400;
                 g146++, up146 = up146->VpiParent()) {
                if (up146->UhdmType() == UHDM::uhdmref_typespec)
                    break;
                if (up146->UhdmType() == UHDM::uhdmdesign) {
                    reaches146 = true;
                    break;
                }
            }
            if (!reaches146)
                continue;
            r146->Actual_group(it146->second);
        }
    return d;
}

// A function body's nested-call OPERATION argument carries the formal's
// typespec only when Surelog's constant evaluator RUNS that call: the stamp is
// what binding an actual to a formal leaves behind (see the bodyOpArg9 note in
// ExprEmit).  So the test is on the CALLEE, and the closure over the live entry
// points follows the evaluator's own prefix walk (§ evalReachedCallees), not
// every call edge the body happens to contain:
//   FuncArgs      `assign out1 = pow_a(inp, 3)` survives reduction -> pow_a is
//                 live, so its own recursive `pow_a(base, exp - 1)` — inside
//                 `if (exp > 0)`, which the evaluator cannot fold — IS stamped
//                 (the CALLEE is reached, through the top-level call);
//                 `assign out2 = pow_b(2, 2)` folds away, so pow_b is not live
//                 and the identical body statement is bare.
//   FuncIoTypespec/arm a9 x6  the only call to the callee sits inside an
//                 unfoldable `if`, so the evaluator never runs it and the
//                 operation actual stays bare — while the same call written as
//                 a plain body statement (x2..x5) is stamped.
// § classScopeCallOfOutOfBodyMethodIsFuncCall26 — bind the deferred
// `Class::f()` calls now that every task_func exists.  Surelog reaches the
// object through getTaskFunc at COMPILE time (the out-of-body definition is
// registered on the enclosing package/file before any variable elaborates);
// our package-variable initializers run before the package's task_funcs are
// emitted, so the same link is made here instead.
void UhdmExporter::drainCollapseLink172() {
    for (auto& [c172, sym172] : pendingCollapseLink172) {
        auto it172 = subMap.find(sym172);
        if (it172 == subMap.end() || !it172->second.tf)
            continue;
        if (c172->UhdmType() == UHDM::uhdmfunc_call) {
            if (it172->second.tf->UhdmType() == UHDM::uhdmfunction)
                ((UHDM::func_call*)c172)->Function(
                    (UHDM::function*)it172->second.tf);
        } else if (c172->UhdmType() == UHDM::uhdmtask_call) {
            if (it172->second.tf->UhdmType() == UHDM::uhdmtask)
                ((UHDM::task_call*)c172)->Task((UHDM::task*)it172->second.tf);
        }
    }
    pendingCollapseLink172.clear();
}

void UhdmExporter::drainScopedCallBind26() {
    for (auto& [c26, sym26] : pendingScopedCallBind26) {
        auto it26 = subMap.find(sym26);
        if (it26 == subMap.end() || !it26->second.tf)
            continue;
        if (c26->UhdmType() == UHDM::uhdmfunc_call) {
            if (it26->second.tf->UhdmType() == UHDM::uhdmfunction)
                ((UHDM::func_call*)c26)->Function(
                    (UHDM::function*)it26->second.tf);
        }
        else if (c26->UhdmType() == UHDM::uhdmtask_call) {
            if (it26->second.tf->UhdmType() == UHDM::uhdmtask)
                ((UHDM::task_call*)c26)->Task((UHDM::task*)it26->second.tf);
        }
    }
    pendingScopedCallBind26.clear();
}

void UhdmExporter::drainBodyOpArgTs() {
    if (pendingBodyOpArgTs.empty()) {
        liveCalledSubs.clear();
        return;
    }
    std::set<const slang::ast::SubroutineSymbol*> reached = liveCalledSubs;
    std::vector<const slang::ast::SubroutineSymbol*> work(reached.begin(),
                                                          reached.end());
    while (!work.empty()) {
        auto* cur = work.back();
        work.pop_back();
        std::vector<const slang::ast::SubroutineSymbol*> callees;
        evalReachedCallees(*cur, callees);
        for (auto* nx : callees)
            if (reached.insert(nx).second)
                work.push_back(nx);
    }
    for (auto& p : pendingBodyOpArgTs)
        if (p.callee && reached.count(p.callee))
            p.owner->Typespec(p.rt);
    pendingBodyOpArgTs.clear();
    liveCalledSubs.clear();
}

// Surelog reports source positions in the FULLY MACRO-EXPANDED text: every
// macro call is replaced in place by its expanded body, recursively (nested
// calls expanded, formals replaced by the actual argument text). This builder
// measures every expansion once so both layers can be reproduced:
//   * lineShifts   - a FILE position past a top-level macro call on its line
//                    moves right by (expandedLen - callLen).
//   * macroRepls   - a position INSIDE a macro body moves right by the deltas
//                    of the replacements (argument substitutions AND nested
//                    macro calls) that precede it on that body line.
// slang models each expansion as its own buffer whose getExpansionRange()
// names the text it replaces, so the buffers form the expansion tree directly.
void UhdmExporter::buildMacroExpansions() {
    macroExpBuilt = true;

    // Pasted-argument text per MacroArg buffer: slang gives EVERY token of a
    // macro argument its own buffer, so record both the token extent and the
    // whitespace that preceded it (the gap the next token pastes over).
    std::map<uint32_t, uint32_t> argLen, argLead;
    std::function<void(const slang::syntax::SyntaxNode&)> walk =
        [&](const slang::syntax::SyntaxNode& node) {
            for (size_t i = 0, n = node.getChildCount(); i < n; i++) {
                if (auto* child = node.childNode(i)) {
                    walk(*child);
                    continue;
                }
                auto tok = node.childToken(i);
                if (!tok)
                    continue;
                auto loc = tok.location();
                if (loc == SourceLocation::NoLocation || !sm->isMacroArgLoc(loc))
                    continue;
                uint32_t end = (uint32_t)(loc.offset() + tok.rawText().size());
                auto it = argLen.find(loc.buffer().getId());
                if (it == argLen.end() || end > it->second)
                    argLen[loc.buffer().getId()] = end;
                if (it == argLen.end()) {
                    size_t tl = 0;
                    for (auto& tv : tok.trivia())
                        tl += tv.getRawText().size();
                    argLead[loc.buffer().getId()] = (uint32_t)tl;
                }
            }
        };
    for (auto& tree : comp.getSyntaxTrees())
        walk(tree->root());

    // Every expansion buffer: what it replaces, and its unexpanded length.
    struct BufInfo {
        slang::SourceRange usage;
        int32_t rawLen = 0;
        bool multiLine = false;
    };
    std::map<uint32_t, BufInfo> info;
    std::vector<uint32_t> order;
    for (auto buf : sm->getAllBuffers()) {
        SourceLocation b0(buf, 0);
        if (!sm->isMacroLoc(b0))
            continue;
        BufInfo bi;
        bi.usage = sm->getExpansionRange(b0);
        if (bi.usage.start() == SourceLocation::NoLocation ||
            bi.usage.end() == SourceLocation::NoLocation ||
            bi.usage.start().buffer() != bi.usage.end().buffer())
            continue;
        if (sm->isMacroArgLoc(b0)) {
            // An argument buffer with no surviving token is an intermediate
            // hop (an actual that is itself a formal); it carries no text.
            auto it = argLen.find(buf.getId());
            if (it == argLen.end())
                continue;
            bi.rawLen = (int32_t)it->second;
        }
        else {
            SourceLocation bodyStart = sm->getFullyOriginalLoc(b0);
            if (bodyStart == SourceLocation::NoLocation ||
                sm->isMacroLoc(bodyStart))
                continue;
            auto text = sm->getSourceText(bodyStart.buffer());
            size_t p = bodyStart.offset();
            if (p >= text.size())
                continue;
            size_t e = p;
            while (e < text.size() && text[e] != '\n')
                e++;
            // Multi-line bodies (line-continuation backslash) keep definition
            // spans; no single-line length applies.
            size_t e2 = e;
            while (e2 > p && (text[e2 - 1] == ' ' || text[e2 - 1] == '\t' ||
                              text[e2 - 1] == '\r'))
                e2--;
            bi.multiLine = (e2 > p && text[e2 - 1] == '\\');
            bi.rawLen = (int32_t)(e2 - p);
        }
        info[buf.getId()] = bi;
        order.push_back(buf.getId());
    }

    // Attach each nested expansion to the body buffer it sits in.
    for (auto id : order) {
        auto& bi = info[id];
        auto us = bi.usage.start();
        if (!sm->isMacroLoc(us))
            continue;
        SourceLocation d = sm->getFullyOriginalLoc(us);
        uint32_t dl = (d == SourceLocation::NoLocation || sm->isMacroLoc(d))
                          ? 0
                          : (uint32_t)sm->getLineNumber(d);
        macroRepls[us.buffer().getId()].push_back(
            {(uint32_t)us.offset(), (uint32_t)bi.usage.end().offset(), 0, dl,
             {id}});
    }
    // Merge the parts that replace the SAME text (the tokens of one multi-token
    // argument) and keep only the outermost replacements: a formal that lives
    // inside a nested macro call is already covered by that call's expansion.
    for (auto& [k, v] : macroRepls) {
        std::sort(v.begin(), v.end(),
                  [](const MacroRepl& a, const MacroRepl& b) {
                      if (a.start != b.start)
                          return a.start < b.start;
                      if (a.end != b.end)
                          return a.end > b.end;
                      return a.parts.front() < b.parts.front();
                  });
        std::vector<MacroRepl> keep;
        uint32_t covered = 0;
        for (auto& r : v) {
            if (!keep.empty() && r.start == keep.back().start &&
                r.end == keep.back().end) {
                keep.back().parts.push_back(r.parts.front());
                continue;
            }
            if (!keep.empty() && r.start < covered)
                continue;
            keep.push_back(r);
            covered = r.end;
        }
        v.swap(keep);
    }

    // Expanded length of a buffer's text, recursively.
    std::map<uint32_t, int32_t> expLenMemo;
    std::function<int32_t(uint32_t)> expLen = [&](uint32_t id) -> int32_t {
        auto m = expLenMemo.find(id);
        if (m != expLenMemo.end())
            return m->second;
        auto bi = info.find(id);
        if (bi == info.end())
            return 0;
        expLenMemo[id] = bi->second.rawLen; // cycle guard
        int32_t len = bi->second.rawLen;
        auto ri = macroRepls.find(id);
        if (ri != macroRepls.end()) {
            for (auto& r : ri->second) {
                int32_t sum = 0;
                bool ok = true;
                for (size_t pi = 0; pi < r.parts.size(); pi++) {
                    auto ci = info.find(r.parts[pi]);
                    if (ci == info.end() || ci->second.multiLine) {
                        ok = false;
                        break;
                    }
                    // The gap before each continuation token is pasted too.
                    if (pi) {
                        auto li = argLead.find(r.parts[pi]);
                        if (li != argLead.end())
                            sum += (int32_t)li->second;
                    }
                    sum += expLen(r.parts[pi]);
                }
                if (!ok)
                    continue;
                r.delta = sum - (int32_t)(r.end - r.start);
                len += r.delta;
            }
        }
        expLenMemo[id] = len;
        return len;
    };

    // Resolve every replacement's delta (a multi-line body contributes no
    // line shift of its own, but its arguments still shift its body columns).
    for (auto id : order)
        expLen(id);

    // Where each continuation part lands inside its replacement.
    for (auto& [k, v] : macroRepls) {
        for (auto& r : v) {
            uint32_t off = 0;
            for (size_t pi = 0; pi < r.parts.size(); pi++) {
                if (pi) {
                    auto li = argLead.find(r.parts[pi]);
                    off += (li == argLead.end() ? 0 : li->second);
                    macroPartOffset[r.parts[pi]] = off;
                }
                auto ei = expLenMemo.find(r.parts[pi]);
                off += (ei == expLenMemo.end() ? 0 : (uint32_t)ei->second);
            }
        }
    }

    // Top-level calls (the ones whose replaced text is in a real file) drive
    // the per-line column shifts.
    for (auto id : order) {
        auto& bi = info[id];
        if (bi.multiLine)
            continue;
        auto us = bi.usage.start();
        if (sm->isMacroLoc(us))
            continue;
        int32_t delta =
            expLen(id) - (int32_t)(bi.usage.end().offset() - us.offset());
        if (delta == 0)
            continue;
        auto key = std::make_pair(us.buffer().getId(),
                                  (uint32_t)sm->getLineNumber(us));
        lineShifts[key].push_back({(uint32_t)sm->getColumnNumber(us), delta});
    }
    for (auto& [k, v] : lineShifts)
        std::sort(v.begin(), v.end());
}

// Column delta a macro-expanded token acquires from the replacements that
// precede it within its macro body line. Body tokens anchor at their own body
// offset; argument tokens anchor at the formal parameter they replaced (so the
// substitution itself is excluded, but earlier ones on the line still count).
int32_t UhdmExporter::macroArgShift(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation || !sm->isMacroLoc(loc))
        return 0;
    if (!macroExpBuilt)
        buildMacroExpansions();
    SourceLocation bodyLoc = loc;
    if (sm->isMacroArgLoc(loc)) {
        bodyLoc = sm->getExpansionRange(loc).start();
        if (bodyLoc == SourceLocation::NoLocation || !sm->isMacroLoc(bodyLoc))
            return 0;
    }
    SourceLocation fdef = sm->getFullyOriginalLoc(bodyLoc);
    if (fdef == SourceLocation::NoLocation || sm->isMacroLoc(fdef))
        return 0;
    uint32_t defLine = (uint32_t)sm->getLineNumber(fdef);
    auto it = macroRepls.find(bodyLoc.buffer().getId());
    if (it == macroRepls.end())
        return 0;
    int32_t shift = 0;
    for (auto& r : it->second)
        if (r.end <= bodyLoc.offset() && r.defLine == defLine)
            shift += r.delta;
    return shift;
}

// Whitespace runs that TRAIL a based number literal on `line` (Surelog's
// lexer folds each into a single column). Memoized per (buffer, line).
const std::vector<std::pair<uint32_t, int32_t>>& UhdmExporter::numLitWsShift(
    SourceLocation lc, uint32_t line, uint32_t col) {
    auto key = std::make_pair(lc.buffer().getId(), line);
    auto [it, fresh] = numLitWsShifts.try_emplace(key);
    if (!fresh)
        return it->second;
    auto text = sm->getSourceText(lc.buffer());
    if (col == 0 || lc.offset() + 1 < col)
        return it->second;
    size_t ls = lc.offset() - (size_t)(col - 1);
    size_t le = text.find('\n', ls);
    if (ls >= text.size())
        return it->second;
    std::string_view ln =
        text.substr(ls, (le == std::string_view::npos ? text.size() : le) - ls);
    // A based literal's VALUE characters (the base letter is one of them).
    auto isVal = [](char ch) {
        return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') ||
               (ch >= 'A' && ch <= 'F') || ch == 'x' || ch == 'X' ||
               ch == 'z' || ch == 'Z' || ch == '?' || ch == '_';
    };
    for (size_t p = 0; p < ln.size();) {
        if (ln[p] != ' ') {
            p++;
            continue;
        }
        size_t q = p;
        while (q < ln.size() && ln[q] == ' ')
            q++;
        size_t runLen = q - p;
        if (runLen >= 2 && p > 0) {
            size_t j = p;
            while (j > 0 && isVal(ln[j - 1]))
                j--;
            // ...'<value>  or  ...'s<value>
            bool based = j < p && j > 0 &&
                         (ln[j - 1] == '\'' ||
                          ((ln[j - 1] == 's' || ln[j - 1] == 'S') && j > 1 &&
                           ln[j - 2] == '\''));
            // A PLAIN DECIMAL literal's trailing run collapses too
            // ("[12  -1:0]" pp-prints as "[12 -1:0]"; jeras_union imm_*) —
            // but ONLY in files Surelog actively preprocesses (any `
            // directive present); directive-free files pass through the pp
            // verbatim (fsm's "#1  IDLE" keeps its spacing).
            bool plain = false;
            if (!based && j < p &&
                text.find('`') != std::string_view::npos) {
                bool digitsOnly = ln[j] >= '0' && ln[j] <= '9';
                for (size_t k = j; digitsOnly && k < p; k++)
                    if (!((ln[k] >= '0' && ln[k] <= '9') || ln[k] == '_'))
                        digitsOnly = false;
                char pc = j > 0 ? ln[j - 1] : ' ';
                plain = digitsOnly &&
                        !((pc >= 'a' && pc <= 'z') || (pc >= 'A' && pc <= 'Z') ||
                          (pc >= '0' && pc <= '9') || pc == '_' || pc == '$' ||
                          pc == '\'' || pc == '.');
            }
            if (based || plain)
                it->second.push_back({(uint32_t)q, -(int32_t)(runLen - 1)});
        }
        p = q;
    }
    return it->second;
}

// A FILE position's Surelog-layout line/col (col shifted right past any
// single-line macro expansions earlier on the line, and LEFT past any
// whitespace run folded into a preceding based number literal).
void UhdmExporter::fileLineCol(SourceLocation lc, uint32_t& line,
                               uint32_t& col) {
    line = (uint32_t)sm->getLineNumber(lc);
    col = (uint32_t)sm->getColumnNumber(lc);
    if (!macroExpBuilt)
        buildMacroExpansions();
    uint32_t c0 = col;
    for (auto& [ucol, d] : numLitWsShift(lc, line, c0))
        if (ucol < c0)
            col = (uint32_t)((int32_t)col + d);
    auto it = lineShifts.find(std::make_pair(lc.buffer().getId(), line));
    if (it == lineShifts.end())
        return;
    for (auto& [ucol, d] : it->second)
        if (ucol < c0)
            col = (uint32_t)((int32_t)col + d);
}

// For a token from a SINGLE-LINE macro body: the Surelog-style virtual
// position (invocation line, invocation col + offset within the body).
// Returns false for multi-line-body tokens (they keep definition spans).
bool UhdmExporter::macroInvLineCol(SourceLocation loc, uint32_t& line,
                                   uint32_t& col) {
    if (!sm->isMacroLoc(loc))
        return false;
    SourceLocation orig = sm->getFullyOriginalLoc(loc);
    SourceLocation bodyStart =
        sm->getFullyOriginalLoc(SourceLocation(loc.buffer(), 0));
    if (orig.buffer() != bodyStart.buffer() ||
        orig.offset() < bodyStart.offset())
        return false;
    auto text = sm->getSourceText(orig.buffer());
    for (size_t i = bodyStart.offset(); i < orig.offset() && i < text.size();
         i++)
        if (text[i] == '\n')
            return false;
    SourceLocation u = sm->getExpansionRange(loc).start();
    uint32_t ul, uc;
    if (sm->isMacroLoc(u)) {
        if (!macroInvLineCol(u, ul, uc)) {
            u = sm->getFullyOriginalLoc(u);
            fileLineCol(u, ul, uc);
        }
        else if (!sm->isMacroArgLoc(loc)) {
            // A nested call sits at its own shifted position inside the parent
            // body. (For an argument paste the caller's macroArgShift already
            // supplies that shift, anchored at the formal it replaced.)
            uc = (uint32_t)((int32_t)uc + macroArgShift(u));
        }
    }
    else if (u == SourceLocation::NoLocation) {
        return false;
    }
    else {
        fileLineCol(u, ul, uc);
    }
    line = ul;
    col = uc + (uint32_t)loc.offset();
    // A continuation token of a multi-token argument starts where the earlier
    // parts of that argument end, not at the substitution point.
    if (!macroExpBuilt)
        buildMacroExpansions();
    if (auto pi = macroPartOffset.find(loc.buffer().getId());
        pi != macroPartOffset.end())
        col += pi->second;
    return true;
}

std::string UhdmExporter::rawText(SourceRange range) {
    if (range.start() == SourceLocation::NoLocation || range.end() == SourceLocation::NoLocation)
        return "";
    // Macro-expansion buffers have no stored text; read the definition site.
    if (sm->isMacroLoc(range.start()) && sm->isMacroLoc(range.end()))
        range = sm->getFullyOriginalRange(range);
    auto text = sm->getSourceText(range.start().buffer());
    size_t start = range.start().offset();
    size_t end = range.end().offset();
    if (end > text.size() || start > end)
        return "";
    return std::string(text.substr(start, end - start));
}

// § macroExpandedText — the node's text as the PREPROCESSED stream reads it.
//
// `rawText` on a macro-expanded range reads the macro BODY (getFullyOriginalRange
// walks back to the definition site), so a name written with a macro FORMAL
// comes back unsubstituted: rggen's
//   `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
//      assign FIF.valid = RIF.valid; ...
// invoked as `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)`
// yields `FIF.valid` / `RIF.read_mask[LSB+:WIDTH]`, while Surelog — which
// compiles the expanded token stream — names the hier_path
// `bit_field_sub_if.valid` / `bit_field_if.read_mask[0+:4]`.
//
// The node's own TOKENS are the expanded ones (macro-argument substitution
// replaces the formal's token with the argument's), so concatenating their raw
// text reproduces the expanded spelling exactly.  Trivia is dropped, which is
// what the substituted form looks like anyway (`[0+:4]`, no interior spaces).
// Outside a macro this is plain `rawText` so every existing caller's spelling —
// including interior comments and spacing — is unchanged.
std::string UhdmExporter::rawTextExp(const syntax::SyntaxNode& syn) {
    auto r9 = syn.sourceRange();
    if (r9.start() == SourceLocation::NoLocation || !sm->isMacroLoc(r9.start()))
        return rawText(r9);
    std::string out;
    std::function<void(const syntax::SyntaxNode&)> walk =
        [&](const syntax::SyntaxNode& n) {
            for (size_t i = 0; i < n.getChildCount(); i++) {
                if (auto* c = n.childNode(i))
                    walk(*c);
                else if (auto t = n.childToken(i))
                    out += t.rawText();
            }
        };
    walk(syn);
    return out.empty() ? rawText(r9) : out;
}

// § rawTextExpr — the expression-level face of § macroExpandedText.  The
// dotted-hier_path arms of emitExpr decide whether an expression IS a dotted
// path by looking for a '.' in its raw text; inside a macro body that text is
// often EMPTY (the span maps back to a multi-line `define whose start/end land
// in different buffers), so the arm silently returns null and the whole
// cont_assign side comes out unset.  Rebuilding from the node's tokens both
// restores the '.' test and gives the SUBSTITUTED spelling Surelog names the
// path with (`bit_field_if.read_data[__i]`, not `RIF.read_data[__i]`).
std::string UhdmExporter::rawTextExpr(const Expression& e) {
    std::string t = rawText(e.sourceRange);
    if (!t.empty() || !e.syntax)
        return t;
    return rawTextExp(*e.syntax);
}

// A based literal whose SIZE comes from a macro (`\`SCR1_XLEN'hFFFF_FFFE`)
// spans two buffers: the size token lives in the macro's expansion buffer, the
// base and digits in the source file. No single buffer holds the text, so
// `rawText` reads garbage from the expansion buffer and every base/size test
// downstream falls through to a plain 64-bit decimal. Surelog works on the
// EXPANDED token stream, so rebuild the literal from its three tokens —
// `32'hFFFF_FFFE`, exactly what golden decompiles.
// Only for that case: the token rebuild drops interior whitespace, and a
// SPACED literal (`8'd 3`) needs its true source text — `basedLiteralSpaceCount`
// reads it to shrink the emitted span (u2r sva_counter).
std::string UhdmExporter::rawTextLit(const Expression& expr) {
    auto r9 = expr.sourceRange;
    bool crossBuf9 = r9.start() != SourceLocation::NoLocation &&
                     r9.end() != SourceLocation::NoLocation &&
                     (r9.start().buffer() != r9.end().buffer() ||
                      sm->isMacroLoc(r9.start()) != sm->isMacroLoc(r9.end()));
    if (auto* sy = expr.syntax; crossBuf9 && sy &&
                                sy->kind ==
                                    syntax::SyntaxKind::IntegerVectorExpression) {
        auto& iv = sy->as<syntax::IntegerVectorExpressionSyntax>();
        std::string out;
        if (iv.size)
            out += std::string(iv.size.rawText());
        if (iv.base)
            out += std::string(iv.base.rawText());
        if (iv.value)
            out += std::string(iv.value.rawText());
        if (out.find('\'') != std::string::npos)
            return out;
    }
    // A PLAIN (unbased) literal that came out of a MACRO EXPANSION
    // (`\`SV_COV_CHECK` -> 3) has no readable text at its own range: the
    // expansion buffer stores none and getFullyOriginalRange lands in the
    // `define body, whose offsets do not describe this token. rawText then
    // returns "" and every digit test downstream reads the literal as 0 —
    // CovMacro's $coverage_control arguments came out UINT:0 with no
    // decompile against golden's UINT:3 / UINT:23 / UINT:11. Surelog works on
    // the EXPANDED token stream, so read the token itself.
    if (auto* sy = expr.syntax;
        sy && sy->kind == syntax::SyntaxKind::IntegerLiteralExpression &&
        expr.sourceRange.start() != SourceLocation::NoLocation &&
        sm->isMacroLoc(expr.sourceRange.start())) {
        auto tok = sy->as<syntax::LiteralExpressionSyntax>().literal;
        if (!tok.rawText().empty())
            return std::string(tok.rawText());
    }
    return rawText(expr.sourceRange);
}

// ---------------------------------------------------------------- UDP defns
//
// Surelog compiles a `primitive ... endprimitive` into a ModuleDefinition
// whose declaration type is paUdp_declaration; UhdmWriter routes those to
// design->AllUdps instead of AllModules (CompileModule::collectUdpObjects_
// builds the udp_defn itself).  The compare surface is narrow: udp_defn
// compares DefName/VpiSize/VpiProtected/VpiPrimType/Attributes/Io_decls/
// Table_entrys/Initial; table_entry compares only VpiSize (its "? 1 : 1"
// string is NOT compared); io_decl compares Direction/Name/Expr; attribute
// compares only VpiName.  `initial::Compare` does not even recurse into its
// statement — the body is emitted for dump fidelity only.
//
// Shapes taken from the Udp golden:
//   * udp_defn VpiDefName is the QUALIFIED name ("work@udp_body"), spanning
//     the `primitive` keyword through `endprimitive` (NOT the leading
//     attribute group, which slang folds into the declaration's range).
//   * one io_decl per HEADER port, in header order, anchored at the header
//     name token, with vpiExpr = a logic_net anchored at the body
//     declaration (`output a;` / `input b,c;` — both input nets carry the
//     whole declaration's span and share its attribute objects).
//   * VpiSize on a table_entry is the number of INPUT fields, where a
//     parenthesised edge `(01)` counts as one and every other character
//     counts as one (so it always equals ports-1).
void UhdmExporter::emitUdpDefns() {
    std::vector<const PrimitiveSymbol*> prims;
    // getDefinitions() is already name-sorted, matching Surelog's module map.
    for (auto* sym : comp.getDefinitions()) {
        if (sym->kind != SymbolKind::Primitive)
            continue;
        auto& ps = sym->as<PrimitiveSymbol>();
        // Built-in gate types live in slang's gateMap, never in the definition
        // map, so only source-declared UDPs reach here; the guard documents
        // the invariant (Surelog skips definitions with no file contents).
        if (ps.primitiveKind != PrimitiveSymbol::UserDefined || !ps.getSyntax())
            continue;
        prims.push_back(&ps);
    }
    if (prims.empty())
        return;
    auto* udps = s.MakeUdp_defnVec();
    for (auto* ps : prims)
        udps->push_back(buildUdpDefn(*ps));
    d->AllUdps(udps);
}

UHDM::udp_defn* UhdmExporter::buildUdpDefn(const PrimitiveSymbol& prim) {
    auto* defn = s.MakeUdp_defn();
    udpDefnMap[&prim] = defn;
    std::string qname = "work@" + std::string(prim.name);
    defn->VpiParent(d);
    defn->VpiDefName(qname);

    const syntax::UdpDeclarationSyntax* us = nullptr;
    if (auto* syn = prim.getSyntax();
        syn && syn->kind == syntax::SyntaxKind::UdpDeclaration)
        us = &syn->as<syntax::UdpDeclarationSyntax>();
    if (us)
        setLoc(defn, SourceRange(us->primitive.location(),
                                 us->endprimitive.range().end()));

    // Attribute objects are shared between the declaration group's members
    // (Surelog compiles the group once and hands the same vector out), so a
    // net-level `(* clk = "foo" *) input clk, d;` gives clk and d the same
    // attribute object — exactly as the golden prints it.
    auto buildAttrs = [&](std::span<const AttributeSymbol* const> attrs,
                          UHDM::BaseClass* parent) -> UHDM::VectorOfattribute* {
        if (attrs.empty())
            return nullptr;
        auto* av = s.MakeAttributeVec();
        for (auto* a : attrs) {
            auto* asyn = a->getSyntax();
            UHDM::attribute* ua = nullptr;
            if (auto sit = sharedAttrObjs.find((const void*)asyn);
                asyn && sit != sharedAttrObjs.end()) {
                ua = sit->second;
            }
            else {
                ua = s.MakeAttribute();
                if (asyn) {
                    sharedAttrObjs[(const void*)asyn] = ua;
                    setLoc(ua, asyn->sourceRange());
                }
                ua->VpiName(a->name);
                // Only a direct STRING clause is spelled out; the value is not
                // part of attribute::Compare, so anything else is left unset.
                if (asyn && asyn->kind == syntax::SyntaxKind::AttributeSpec)
                    if (auto* vc = asyn->as<syntax::AttributeSpecSyntax>().value;
                        vc && vc->expr->kind ==
                                  syntax::SyntaxKind::StringLiteralExpression) {
                        std::string raw = rawText(vc->expr->sourceRange());
                        if (raw.size() >= 2 && raw.front() == '"' &&
                            raw.back() == '"')
                            raw = raw.substr(1, raw.size() - 2);
                        ua->VpiValue("STRING:" + raw);
                    }
            }
            ua->VpiParent(parent); // last writer, like Surelog's shared vectors
            av->push_back(ua);
        }
        return av;
    };

    if (auto* av = buildAttrs(comp.getAttributes(prim), defn))
        defn->Attributes(av);

    // Header port-name spans (non-ANSI): slang moves PrimitivePortSymbol
    // ::location onto the BODY declaration, so the header token has to come
    // from the syntax.
    std::map<std::string_view, SourceRange> hdrLoc;
    if (us && us->portList->kind == syntax::SyntaxKind::NonAnsiUdpPortList)
        for (auto* p : us->portList->as<syntax::NonAnsiUdpPortListSyntax>().ports)
            hdrLoc.emplace(p->identifier.valueText(), p->identifier.range());

    if (!prim.ports.empty()) {
        auto* ios = s.MakeIo_declVec();
        for (auto* port : prim.ports) {
            auto* io = s.MakeIo_decl();
            io->VpiParent(defn);
            io->VpiName(port->name);
            io->VpiDirection(port->direction == PrimitivePortDirection::In
                                 ? vpiInput
                                 : vpiOutput);
            if (auto hit = hdrLoc.find(port->name); hit != hdrLoc.end())
                setLoc(io, hit->second);
            else
                setLocNamed(io, *port);
            auto* net = s.MakeLogic_net();
            net->VpiParent(defn);
            net->VpiName(port->name);
            net->VpiFullName(qname + "." + std::string(port->name));
            // The net is born at the BODY declaration; an input name syntax
            // is one entry of `input b,c;`, so walk up to the declaration.
            if (auto* psyn = port->getSyntax()) {
                const syntax::SyntaxNode* dsyn = psyn;
                for (auto* p = psyn; p; p = p->parent)
                    if (p->kind == syntax::SyntaxKind::UdpInputPortDecl ||
                        p->kind == syntax::SyntaxKind::UdpOutputPortDecl) {
                        dsyn = p;
                        break;
                    }
                setLoc(net, dsyn->sourceRange());
            }
            if (auto* av = buildAttrs(comp.getAttributes(*port), net))
                net->Attributes(av);
            io->Expr(net);
            ios->push_back(io);
        }
        defn->Io_decls(ios);
    }

    if (!prim.table.empty()) {
        auto* tes = s.MakeTable_entryVec();
        // Row spans come from the syntax; slang drops a row it diagnosed, so
        // only a 1:1 count lets the two lists be zipped.
        const syntax::UdpEntrySyntax* const* esyn = nullptr;
        if (us && us->body->entries.size() == prim.table.size())
            esyn = us->body->entries.begin();
        size_t ri = 0;
        for (auto& row : prim.table) {
            auto* te = s.MakeTable_entry();
            te->VpiParent(defn);
            int32_t nfields = 0;
            std::string val = "STRING:";
            for (size_t i = 0; i < row.inputs.size(); i++) {
                if (row.inputs[i] == '(') {
                    // `(01)` — Surelog writes the two edge chars unseparated.
                    for (i++; i < row.inputs.size() && row.inputs[i] != ')'; i++)
                        val += row.inputs[i];
                    val += ' ';
                }
                else {
                    val += row.inputs[i];
                    val += ' ';
                }
                nfields++;
            }
            val += ": ";
            if (row.state) {
                val += row.state;
                val += " : ";
            }
            // A sequential row's output keeps a trailing space; a `-` (no
            // change) and every combinational output do not.
            if (row.state && row.output != '-') {
                val += row.output;
                val += ' ';
            }
            else
                val += row.output;
            te->VpiValue(val);
            te->VpiSize(nfields);
            if (esyn && !esyn[ri]->inputs.empty())
                setLoc(te, esyn[ri]->inputs.sourceRange());
            tes->push_back(te);
            ri++;
        }
        defn->Table_entrys(tes);
    }

    // `initial q = 0;` inside the primitive. Only the object's existence is
    // compared, but the body is written out the way Surelog writes it.
    if (prim.initVal && us && us->body->initialStmt) {
        auto& is = *us->body->initialStmt;
        auto* init = s.MakeInitial();
        init->VpiParent(defn);
        setLoc(init, is.sourceRange());
        auto* asg = s.MakeAssignment();
        asg->VpiParent(init);
        setLoc(asg, is.sourceRange());
        init->Stmt(asg);
        auto* ref = s.MakeRef_obj();
        ref->VpiParent(asg);
        ref->VpiName(is.name.valueText());
        ref->VpiFullName(qname + "." + std::string(is.name.valueText()));
        setLoc(ref, is.name.range());
        asg->Lhs(ref);
        auto* c = s.MakeConstant();
        c->VpiParent(asg);
        std::string dec = rawText(is.value->sourceRange());
        c->VpiValue("UINT:" + dec);
        c->VpiDecompile(dec);
        c->VpiSize(64);
        c->VpiConstType(vpiUIntConst);
        setLoc(c, is.value->sourceRange());
        asg->Rhs(c);
        defn->Initial(init);
    }
    return defn;
}

SourceRange UhdmExporter::ifaceElemIndexRange(SourceRange range) {
    std::string t = rawText(range);
    auto lb = t.find('[');
    if (lb == std::string::npos || t.empty() || t.back() != ']')
        return range;
    size_t b = lb + 1, e = t.size() - 1;
    while (b < e && isspace((unsigned char)t[b]))
        ++b;
    while (e > b && isspace((unsigned char)t[e - 1]))
        --e;
    if (b >= e)
        return range;
    return SourceRange(range.start() + b, range.start() + e);
}

} // namespace slang_uhdm
