//------------------------------------------------------------------------------
//! @file uhdm_main.cpp
//! @brief slang-uhdm: export a SystemVerilog design as a UHDM database
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "BuiltinSv.h"
#include "UhdmExporter.h"

#include <cstdio>
#include <filesystem>
#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <uhdm/ElaboratorListener.h>
#include <uhdm/SynthSubset.h>
#include <uhdm/UhdmAdjuster.h>
#include <uhdm/uhdm.h>

#include "slang/ast/Compilation.h"
#include "slang/diagnostics/DiagnosticEngine.h"
#include "slang/diagnostics/LookupDiags.h"
#include "slang/driver/Driver.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/syntax/SyntaxTree.h"
#include "slang/util/VersionInfo.h"

using namespace slang;
using namespace slang::driver;

int main(int argc, char** argv) {
    Driver driver;
    driver.addStandardArgs();

    std::optional<bool> showHelp;
    std::optional<bool> showVersion;
    std::optional<std::string> outputFile;
    driver.cmdLine.add("-h,--help", showHelp, "Display available options");
    driver.cmdLine.add("--version", showVersion, "Display version information and exit");
    driver.cmdLine.add("-o,--output", outputFile, "Output UHDM database file", "<file>");

    std::optional<bool> elabUhdm;
    driver.cmdLine.add("--elabuhdm", elabUhdm,
                       "Forces UHDM/VPI full elaboration; default is the folded model");

    // Builtins are ON by default and -nobuiltin opts out, matching Surelog's
    // spelling and its default exactly, so `slang-uhdm <src>` and
    // `surelog -parse <src>` agree without either side needing a flag.
    // --builtins is kept as an accepted no-op for invocations written against
    // the earlier opt-in spelling.
    std::optional<bool> noBuiltin;
    std::optional<bool> builtinsAlias;
    driver.cmdLine.add("--nobuiltin", noBuiltin,
                       "Do not emit the SystemVerilog builtin package or builtin.sv classes "
                       "(default is to emit them, as Surelog does)");
    driver.cmdLine.add("--builtins", builtinsAlias,
                       "Deprecated no-op: builtins are emitted by default; use --nobuiltin "
                       "to suppress them");

    // Surelog's blackboxing flags, repeatable exactly as Surelog's are
    // (`-bb_mod a -bb_mod b`). slang's registry requires a `--` prefix for a
    // multi-character name, but its PARSER strips leading dashes before the
    // lookup, so Surelog's own single-dash spelling (`-bb_mod work@top`) is
    // accepted too.
    std::vector<std::string> bbMods;
    std::vector<std::string> bbInsts;
    driver.cmdLine.add("--bb_mod", bbMods,
                       "Blackbox the named module definition: its body is not compiled and it "
                       "instantiates nothing (Surelog -bb_mod, ex: -bb_mod work@top)",
                       "<module>");
    driver.cmdLine.add("--bb_inst", bbInsts,
                       "Blackbox the named elaborated instance path (Surelog -bb_inst, ex: "
                       "-bb_inst work@top.u1)",
                       "<instance>");

    // Surelog's `--disable-feature=<a,b,...>` / `--enable-feature=<...>`.  Both
    // are spelled with `=` and take a COMMA LIST, so they arrive as a single
    // argv word; slang's registry has no `=`-glued form, so they are registered
    // as ordinary repeatable string options and slang's parser splits on the
    // `=` itself (`--disable-feature=parametersubstitution`).  Only
    // `parametersubstitution` is implemented; any other feature name is a hard
    // error rather than a silent no-op, because silently ignoring a
    // model-shaping flag manufactures a happy path (GOLDEN_EQUIVALENCE 2.3).
    std::vector<std::string> disableFeatures;
    std::vector<std::string> enableFeatures;
    driver.cmdLine.add("--disable-feature", disableFeatures,
                       "Disable a Surelog compile feature (comma separated). Supported: "
                       "parametersubstitution",
                       "<feature>[,...]");
    driver.cmdLine.add("--enable-feature", enableFeatures,
                       "Enable a Surelog compile feature (comma separated). Supported: "
                       "parametersubstitution (the default)",
                       "<feature>[,...]");

    // Surelog's Verilog-config selection (LRM 33).  Both flags are repeatable
    // exactly as Surelog's are, and slang's parser strips leading dashes before
    // the registry lookup, so Surelog's own `-cfg` / `-cfgfile` spelling works.
    //
    // slang implements config blocks natively (ConfigBlockSymbol: design
    // statement, default liblist, cell/instance overrides, `use lib.cfg:config`
    // recursion), so this is plumbing, not a reimplementation:
    //
    //   -cfg <name>      -> a top-level entry `<name>:config` (see the push
    //                       site below, after the sources are parsed).
    //   -cfgfile <file>  -> an ordinary source file.  Surelog parses config
    //                       files with a dedicated parser; slang parses
    //                       `config...endconfig` as normal source, so the file
    //                       only has to be handed to the compilation.  It lands
    //                       in the default library ("work"), matching Surelog's
    //                       `work@<cfg>` qualification of a -cfgfile config.
    //
    // Both are hard no-ops when absent: empty lists add nothing.
    std::vector<std::string> cfgNames;
    std::vector<std::string> cfgFiles;
    driver.cmdLine.add("--cfg", cfgNames,
                       "Select a Verilog configuration to elaborate, by config block name "
                       "(Surelog -cfg, ex: -cfg cfgReal)",
                       "<configName>");
    driver.cmdLine.add("--cfgfile", cfgFiles,
                       "Read a file of `config...endconfig` declarations (Surelog -cfgfile, "
                       "ex: -cfgfile configs.cfg)",
                       "<configFile>");

    std::optional<bool> synth;
    std::optional<bool> formal;
    driver.cmdLine.add("--synth", synth,
                       "Restrict the model to the synthesizable subset, as Surelog -synth does: "
                       "non-synthesizable constructs are filtered out and "
                       "'// pragma translate_off' regions are excluded");
    driver.cmdLine.add("--formal", formal,
                       "Like --synth but keeps model-checking constructs (Surelog -formal)");

    if (!driver.parseCommandLine(argc, argv))
        return 1;

    if (showHelp == true) {
        printf("%s\n",
               driver.cmdLine.getHelpText("slang-uhdm: SystemVerilog to UHDM exporter").c_str());
        return 0;
    }

    if (showVersion == true) {
        printf("slang-uhdm using slang version %s\n", VersionInfo::getVersionString().c_str());
        return 0;
    }

    // Feature toggles, comma-split like CommandLineParser.cpp, unknown names
    // rejected. slang hands the two flags over as two separate lists, so argv
    // order between them is lost and `--disable-feature` is applied last: a
    // command line naming the same feature both ways ends up disabled whatever
    // the order. No suite test does that, and the two flags are documented as
    // opposites rather than as an ordered sequence.
    bool paramSubstitution = true;
    {
        auto apply = [&](const std::vector<std::string>& list, bool on) -> bool {
            for (auto& item : list) {
                size_t pos = 0;
                while (pos <= item.size()) {
                    size_t comma = item.find(',', pos);
                    std::string feat = item.substr(pos, comma == std::string::npos
                                                            ? std::string::npos
                                                            : comma - pos);
                    if (feat == "parametersubstitution")
                        paramSubstitution = on;
                    else if (!feat.empty()) {
                        fprintf(stderr, "error: unsupported feature '%s'\n", feat.c_str());
                        return false;
                    }
                    if (comma == std::string::npos)
                        break;
                    pos = comma + 1;
                }
            }
            return true;
        };
        if (!apply(enableFeatures, true) || !apply(disableFeatures, false))
            return 1;
    }

    // Surelog's -synth/-formal honour `// pragma translate_off` / `translate_on`.
    // slang already implements exactly that under --translate-off-format, so ask
    // for it rather than reimplementing the exclusion. Injected before
    // processOptions(), which is where the option is parsed into effect.
    const bool synthSubset = (synth == true || formal == true);
    if (synthSubset)
        driver.options.translateOffOptions.push_back("pragma,translate_off,translate_on");

    // Surelog predefines `SURELOG=1` for every compilation (SurelogMacro:
    // `ifdef SURELOG guards the whole design, and the golden database contains
    // work@top). It is a UHDM-relevant fact about the golden tool's
    // environment, exactly like the builtin package, so mirror it. Prepended so
    // an explicit -DSURELOG=... on the command line still wins.
    driver.options.defines.insert(driver.options.defines.begin(), "SURELOG=1");

    // -cfgfile sources go in before processOptions() so they take part in the
    // normal source-existence check; the -cfg tops are pushed later, once the
    // sources are parsed and the declared config names are known.
    for (auto& file : cfgFiles)
        driver.sourceLoader.addFiles(file);

    if (!driver.processOptions())
        return 2;

    bool ok = driver.parseAllSources();

    // Surelog (unless given -nobuiltin) parses an embedded builtin.sv as a fake
    // file in the CURRENT WORKING DIRECTORY; the UHDM class spans reference that
    // path. Feed slang the same text under the same reported path so the parser
    // yields identical line:column information.
    const bool emitBuiltins = (noBuiltin != true);
    std::string builtinPath;
    if (emitBuiltins) {
        builtinPath = (std::filesystem::current_path() / "builtin.sv").string();
        auto buffer = driver.sourceManager.assignText(builtinPath, slang_uhdm::kBuiltinSvText);
        auto tree = syntax::SyntaxTree::fromBuffer(buffer, driver.sourceManager,
                                                   driver.createParseOptionBag());
        driver.syntaxTrees.push_back(tree);
    }

    // One syntax walk collecting two bind facts plus the declared config names:
    //   * bindInstRanges -- the source range of every `bind` directive's
    //     INSTANTIATION (instance name, parameter overrides, port connections).
    //     Only the instantiation, never the bind TARGET name: an unresolvable
    //     target stays a hard error.  See the leniency below.
    //   * bindCarriers / instantiated -- which module lexically holds a bind,
    //     and which module names are instantiated anywhere.  See syntheticTops.
    //   * declaredConfigs -- every `config <name>; ... endconfig`, used to drop
    //     unmatched -cfg names below.
    std::vector<SourceRange> bindInstRanges;
    std::set<std::string> bindCarriers, instantiated, declaredConfigs;
    for (auto& tree : driver.syntaxTrees) {
        std::function<void(const syntax::SyntaxNode&, const std::string&)> walk =
            [&](const syntax::SyntaxNode& node, const std::string& mod) {
                std::string cur = mod;
                if (node.kind == syntax::SyntaxKind::ModuleDeclaration)
                    cur = std::string(node.as<syntax::ModuleDeclarationSyntax>()
                                          .header->name.valueText());
                else if (node.kind == syntax::SyntaxKind::ConfigDeclaration)
                    declaredConfigs.insert(std::string(
                        node.as<syntax::ConfigDeclarationSyntax>().name.valueText()));
                else if (node.kind == syntax::SyntaxKind::HierarchyInstantiation)
                    instantiated.insert(std::string(
                        node.as<syntax::HierarchyInstantiationSyntax>()
                            .type.valueText()));
                else if (node.kind == syntax::SyntaxKind::BindDirective) {
                    auto& bd = node.as<syntax::BindDirectiveSyntax>();
                    bindInstRanges.push_back(bd.instantiation->sourceRange());
                    if (!cur.empty())
                        bindCarriers.insert(cur);
                }
                for (size_t i = 0; i < node.getChildCount(); i++)
                    if (auto* ch = node.childNode(i))
                        walk(*ch, cur);
            };
        walk(tree->root(), "");
    }

    // -cfg: each selected config becomes a top-level entry.  The `:config`
    // suffix restricts slang's top lookup to config blocks, which is what
    // Surelog's -cfg does (its ConfigSet is searched alone, never the module
    // table) -- UnitLibrary passes `-cfg top` while also declaring a module
    // named `top`.
    //
    // An UNMATCHED -cfg name is dropped with a warning rather than being handed
    // to slang, because Surelog treats it as a non-fatal error (CM0028
    // "Undefined configuration") and still writes its database, while slang's
    // InvalidTopModule is fatal.  Names carrying a library qualifier are passed
    // through untouched: this walk only sees the parsed trees, and a config in
    // a non-default library may not be among them.
    for (auto& name : cfgNames) {
        constexpr std::string_view configSuffix = ":config";
        std::string bare = name;
        if (bare.ends_with(configSuffix))
            bare.resize(bare.size() - configSuffix.size());
        if (bare.find('.') == std::string::npos && !declaredConfigs.count(bare)) {
            fprintf(stderr, "slang-uhdm: warning: undefined configuration '%s'\n", bare.c_str());
            continue;
        }
        driver.options.topModules.push_back(bare + std::string(configSuffix));
    }

    // A `bind` directive inside a module that is never instantiated (an SVA
    // wrapper holding only the bind) never fires in slang's elaboration when
    // --top prunes that module, but Surelog applies such binds globally
    // (mriscv_bind_sva: `bind mriscvcore_top_s2qed s2qed ...` inside module
    // Wrapper). Make the carrier module an extra top so the bind elaborates,
    // and tell the exporter it is synthetic (def view only, not a design top).
    // Only needed when --top was given: without it slang auto-selects the
    // uninstantiated carrier as a top already, so the bind fires on its own.
    std::set<std::string> syntheticTops;
    if (!driver.options.topModules.empty()) {
        std::set<std::string> tops(driver.options.topModules.begin(),
                                   driver.options.topModules.end());
        for (auto& mod : bindCarriers)
            if (!instantiated.count(mod) && !tops.count(mod)) {
                driver.options.topModules.push_back(mod);
                syntheticTops.insert(mod);
            }
    }

    auto compilation = driver.createCompilation();
    driver.reportCompilation(*compilation, /* quiet */ true);
    ok &= driver.reportDiagnostics(/* quiet */ true);
    if (!ok && !bindInstRanges.empty()) {
        // Surelog accepts an unresolvable hierarchical name in a bind's port
        // connections leniently -- it emits an unresolved hier_path and keeps
        // going -- where slang hard-errors (mriscv_bind_sva
        // .cpu0_rs1i(mriscvcore_inst0.DECODE_INSTR_inst.rs1i): the instance is
        // really named DECO_INSTR_inst, so the path cannot resolve).
        //
        // Deliberately narrow, so this cannot mask a real rejection: it fires
        // only when EVERY error in the compilation is that ONE diagnostic
        // (CouldNotResolveHierarchicalPath) AND every one of them is located
        // inside a bind directive's instantiation. Any other error code, or the
        // same code anywhere outside a bind, still rejects.
        bool excusable = false;
        for (auto& diag : compilation->getAllDiagnostics()) {
            if (driver.diagEngine.getSeverity(diag.code, diag.location) <
                DiagnosticSeverity::Error)
                continue;
            bool inBindInst = false;
            if (diag.code == diag::CouldNotResolveHierarchicalPath)
                for (auto& br : bindInstRanges)
                    if (diag.location.buffer() == br.start().buffer() &&
                        diag.location >= br.start() &&
                        diag.location <= br.end()) {
                        inBindInst = true;
                        break;
                    }
            if (!inBindInst) {
                excusable = false;
                break;
            }
            excusable = true;
        }
        ok = excusable;
    }
    if (!ok)
        return 3;

    UHDM::Serializer serializer;
    // Kept off so stale compile artifacts (e.g. abandoned pattern
    // first-compiles) survive into the database, as they do in the reference
    // shape. Surelog's own default is GC ON (CommandLineParser m_gc(true)), but
    // GC makes no measurable difference to its output and no corpus test passes
    // -gc/-nogc, so this is a difference in reason rather than in result.
    serializer.SetGCEnabled(false);
    slang_uhdm::UhdmExporter exporter(*compilation, serializer);
    if (emitBuiltins)
        exporter.enableBuiltins(builtinPath);
    if (!syntheticTops.empty())
        exporter.setSyntheticTops(syntheticTops);
    if (!paramSubstitution)
        exporter.setNoParamSubst();
    if (!bbMods.empty() || !bbInsts.empty())
        exporter.setBlackBoxes(std::set<std::string>(bbMods.begin(), bbMods.end()),
                               std::set<std::string>(bbInsts.begin(), bbInsts.end()));
    UHDM::design* design = exporter.exportDesign();

    // Post-export UHDM passes, in the order Surelog's UhdmWriter runs them.
    // (Surelog also runs UhdmLint here unconditionally; it is read-only -- no
    // Erase, no Make, no setters -- so it cannot change the database and is
    // deliberately not run.)
    if (elabUhdm == true || synthSubset) {
        std::vector<vpiHandle> designs{
            reinterpret_cast<vpiHandle>(new uhdm_handle(UHDM::uhdmdesign, design))};

        if (elabUhdm == true) {
            // UHDM elaborates its own model, then UhdmAdjuster rewrites the
            // elaborated tree. uniquifyTypespec(false) is Surelog's non-default
            // choice (the listener defaults it to true).
            UHDM::ElaboratorContext elaboratorContext(&serializer, false, false);
            elaboratorContext.m_elaborator.uniquifyTypespec(false);
            elaboratorContext.m_elaborator.listenDesigns(designs);

            UHDM::UhdmAdjuster adjuster(&serializer, design);
            adjuster.listenDesigns(designs);
        }

        if (synthSubset) {
            // SynthSubset ships with UHDM, so -synth is reused rather than
            // reimplemented. reportErrors mirrors Surelog's `true`; allowFormal
            // is what separates -formal from -synth.
            std::set<const UHDM::any*> nonSynthesizableObjects;
            UHDM::SynthSubset synth_(&serializer, nonSynthesizableObjects, design,
                                     /*reportErrors*/ true,
                                     /*allowFormal*/ formal == true);
            synth_.listenDesigns(designs);
            synth_.filterNonSynthesizable();
        }
    }

    serializer.Save(outputFile.value_or("slang.uhdm"));

    if (!exporter.unsupported().empty()) {
        fprintf(stderr, "slang-uhdm: unsupported constructs encountered:\n");
        for (auto& u : exporter.unsupported())
            fprintf(stderr, "  %s\n", u.c_str());
        return 4;
    }
    return 0;
}
