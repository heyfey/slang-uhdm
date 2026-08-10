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

void UhdmExporter::setLoc(UHDM::BaseClass* obj, SourceRange range) {
    if (range.start() == SourceLocation::NoLocation)
        return;
    // Macro-expanded tokens: SINGLE-LINE bodies lay out VIRTUALLY at the
    // INVOCATION site (usage line, usage col + body offset); later lines of
    // multi-line bodies keep their macro-DEFINITION-site span (Surelog).
    auto lineColOf = [&](SourceLocation lc, uint32_t& L, uint32_t& C) {
        uint32_t vl, vc;
        // Single-line macro bodies lay out at the invocation site; add the
        // intra-body argument-substitution shift Surelog applies.
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
    };
    uint32_t l = 0, c = 0;
    lineColOf(range.start(), l, c);
    obj->VpiLineNo(l);
    obj->VpiColumnNo(c);
    if (range.end() != SourceLocation::NoLocation) {
        lineColOf(range.end(), l, c);
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
// NOT modelled (measured, left for a later pass — see the pass-29 residue
// ranking): a BASED literal keeps its source spelling and base constType
// (`8'hff` -> `HEX:ff`, decompile `8'hff`) where the inline IntegerLiteral arm
// prints decimal, and its SIZE follows a rule t39b did NOT settle (`int
// k_wide = 8'hff` sizes 32 but `int k_bin = 4'b1010` sizes 4); a TIME literal
// (`9200s` -> UINT:9200000000000000, size 64, NO decompile) scales by a factor
// t39c did not settle either (`5ns` -> 5000000, `7ps` -> 7 under one
// `timescale 1ns/1ps`); and a SIMPLE assignment pattern's element constants
// size at the ELEMENT width where emitExpr gives them 64 (t39c a_dyn — no UVM
// property reaches it).
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
    if (ic.kind == ExpressionKind::Concatenation ||
        ic.kind == ExpressionKind::SimpleAssignmentPattern ||
        ic.kind == ExpressionKind::StructuredAssignmentPattern ||
        ic.kind == ExpressionKind::ReplicatedAssignmentPattern) {
        if (auto* e27 = emitExpr(ic, pi.var, pi.pfn, nm29))
            if (e27->UhdmType() == UHDM::uhdmoperation)
                pi.var->Expr((UHDM::expr*)e27);
        return;
    }
    if (ic.kind != ExpressionKind::Call || ic.as<CallExpression>().isSystemCall())
        return;
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
        if (auto* cds = syn->as_if<syntax::ClassDeclarationSyntax>())
            if (cds->classKeyword.range().start() != SourceLocation::NoLocation)
                r = SourceRange(cds->classKeyword.range().start(), r.end());
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
        // A DYNAMIC-array / QUEUE / ASSOC property is an array_var carrying a
        // bare array_typespec, with the ELEMENT variable under vpiReg.
        if (ct.kind == SymbolKind::DynamicArrayType ||
            ct.kind == SymbolKind::QueueType ||
            ct.kind == SymbolKind::AssociativeArrayType) {
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
            if (ct.kind == SymbolKind::DynamicArrayType)
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
            auto* reg = classAssocElemVar(cp, *et, cls);
            if (!reg) {
                noteUnsupported("class array property element");
                continue;
            }
            auto* av = s.MakeArray_var();
            av->VpiName(cp.name);
            av->VpiFullName(pfn);
            av->VpiParent(cd);
            setLoc(av, nameSpan(cp.location, cp.name));
            av->VpiSize(1);
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
            auto* ats = s.MakeArray_typespec();
            auto* art = s.MakeRef_typespec();
            art->VpiParent(av);
            art->Actual_typespec(ats);
            av->Typespec(art);
            emitAssocDims(cp, assocIdx, av, ats);
            reg->VpiParent(av);
            reg->VpiFullName(pfn);
            setLoc(reg, nameSpan(cp.location, cp.name));
            // A PREDEFINED-INTEGER element takes the matching integer
            // typespec here rather than the write-phase mint, which would
            // read the property's own declared type and produce the vector
            // form (int_typespec, not logic_typespec — BuildUVMPkg
            // uvm_seed_map `int unsigned seed_table[string]`).
            if (auto* rrt = reg->Typespec();
                rrt && !((UHDM::ref_typespec*)rrt)->Actual_typespec() &&
                et->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
                if (auto* pts = predefIntTypespec(et->getCanonicalType(), cp))
                    ((UHDM::ref_typespec*)rrt)->Actual_typespec(pts);
            }
            // An ELEMENT type with no shared alias (a bare `bit [7:0]`) still
            // gets its own typespec, minted in the write phase like any other
            // property's (SimpleConstraint `rand bit [7:0] payload []`: the
            // vpiReg bit_var's ref_typespec -> a ranged bit_typespec).
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
            if (cp.getInitializer())
                lateInit29.push_back({av, &cp, pfn});
            vars->push_back(av);
            continue;
        }
        // A predefined integer field (int/byte/...) is the matching typed
        // var (int_var + vpiSigned), not a bare bit_var; anonymous bit/logic
        // vectors keep bit/logic_var.
        UHDM::variables* v = nullptr;
        // An ENUM-typed property is an enum_var, not the bit/logic_var its
        // integral base would give (SimpleConstraint `rand pkt_type ptype`);
        // the array-element path (classElemVar) already had this rule.
        if (ct.kind == SymbolKind::EnumType)
            v = s.MakeEnum_var();
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
                    c0->VpiSize((int32_t)cp.getType().getBitWidth());
                    c0->VpiValue("UINT:" + d0);
                    c0->VpiConstType(vpiUIntConst);
                    c0->VpiParent(v);
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
                        c1->VpiSize((int32_t)cp.getType().getBitWidth());
                        c1->VpiValue("UINT:" + d1);
                        c1->VpiConstType(vpiUIntConst);
                        setLoc(c1, ub0.sourceRange);
                        auto* op1 = s.MakeOperation();
                        op1->VpiOpType(vpiMinusOp);
                        op1->VpiParent(v);
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
            // Everything else is a § classPropInit29 shape: deferred to just
            // after emitTaskFuncs so a call can bind the class's own methods.
            else
                lateInit29.push_back({v, &cp, pfn0});
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
    if (cls.isAbstract)
        cd->VpiVirtual(true);
    // Parameters BEFORE typedefs: Surelog compiles the class header first, so
    // a formal's typespec is the older object (arena order — VirtualClass's
    // type_parameter logic_typespec precedes the typedefs' own objects).
    emitClassParameters(cls, cd, fullName);
    emitClassTypedefs(cls, cd);
    currentClassDefn = cd;
    emitTaskFuncs(cls, cd, fullName + "::", nullptr, false);
    currentClassDefn = nullptr;
    // § classPropInit29 — the property initializers whose shape the inline
    // whitelist above does not build.  Drained HERE, not inline: the shapes
    // that matter are CALLS, and a call to a static method of the class's own
    // body (`static this_type me = get();`, uvm_component_registry) can only
    // bind vpiFunction once emitTaskFuncs has put that method in `subMap`.
    for (auto& pi29 : lateInit29)
        emitClassPropInit29(pi29);
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

UHDM::variables* UhdmExporter::classElemVar(const Type& elemType) {
    auto& ec = elemType.getCanonicalType();
    UHDM::variables* v = nullptr;
    UHDM::typespec* ts = nullptr;
    if (ec.kind == SymbolKind::ClassType) {
        v = s.MakeClass_var();
        auto* cts = s.MakeClass_typespec();
        cts->VpiName(ec.name);
        pendingClassTsLink.push_back({cts, &ec});
        ts = cts;
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
    else if (ec.kind == SymbolKind::PredefinedIntegerType)
        v = makeReturnVar(s, elemType);
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
    return classElemVar(elemType);
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
        // tdVecNamedClone42 is restricted to bit/logic bases.
        if (auto* cl = tdVecNamedClone42(idx, (const void*)&sym, sh))
            return cl;
        return sh;
    }
    if (ic.kind == SymbolKind::PredefinedIntegerType)
        return predefIntTypespec(ic, sym);
    if (ic.isIntegral())
        return s.MakeLogic_typespec();
    return nullptr;
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
    if (idx[0]) {
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
                cts->VpiName(dsyn ? std::string(rawText(dsyn->sourceRange()))
                                  : std::string(dct.name));
                cts->VpiParent(tp);
                if (dsyn)
                    setLoc(cts, dsyn->sourceRange());
                pendingClassTsLink.push_back({cts, &dct});
                its = cts;
            }
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
        {
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
    return nullptr;
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

UHDM::design* UhdmExporter::exportDesign() {
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

    // Surelog attaches the include records before any model content.
    emitIncludeFileInfos();

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    std::set<std::string> uninstGenDefNames;
    for (auto inst : orderedTops) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs, &uninstGenDefNames);
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
                    if (ea0->VpiName().empty() && ea0->Instance())
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
        auto emitOne = [&](const ClassType* c) {
            std::string cname = "work@" + std::string(c->name);
            made[c] = emitClassDefn(*c, cname, cname, d);
        };
        for (auto& e : ents)
            if (e.builtinFile)
                emitOne(e.cls);
        for (auto& e : ents)
            if (!e.builtinFile)
                emitOne(e.cls);
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
        if (ts)
            ts->VpiParent(pc.var);
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

    // Bind enum-value refs whose enum_const was only materialized in the
    // deferred typespec pass (anonymous enums).
    for (auto& [ref, sym] : pendingEnumRefs)
        if (auto eit = enumConstMap.find(sym); eit != enumConstMap.end())
            ref->Actual_group(eit->second);
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
    // Elab param_assign Rhs ts refs -> the def parameter's FINAL typespec.
    // Dead last: every deferred def-view typespec rebind is done by now.
    drainShareDefParamTs();
    // In-body func_call operation-arg stamps: reachability needs the whole
    // design's call set, so it is resolved here.
    drainBodyOpArgTs();
    // Deferred `Class::f()` -> out-of-body task_func links (§ ...26).
    drainScopedCallBind26();
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
    // § importPublishesPackageClasses24 — DESIGN-FINAL, and BEFORE the class
    // arm below: the package listings it rewrites (and the names it
    // requalifies) are what the class arm then inherits.
    importPublishesPackageClasses24();
    // § classInheritsContainerImports23 — DESIGN-FINAL: a class's inherited
    // listings are the very objects its container's imports already
    // materialized, so every package view has to be complete first.
    classInheritsContainerImports23();
    // § thisImplicitNetBoth38 — DEAD LAST: its predicate is which package
    // views list the routine, so every listing rewrite above (the two import
    // passes included) has to have run.  It only ever fills a null
    // Actual_group on a reference named `this` and appends one net.
    thisImplicitNetBoth38(d);
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
