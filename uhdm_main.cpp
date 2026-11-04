//------------------------------------------------------------------------------
//! @file uhdm_main.cpp
//! @brief slang-uhdm: export a SystemVerilog design as a UHDM database
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "BuiltinSv.h"
#include "UhdmExporter.h"
#include "src/LawSwitch.h"
#include "src/LawState.h"

#include <cstdio>
#include <filesystem>
#include <functional>
#include <map>
#include <regex>
#include <set>
#include <string>
#include <vector>
#include <uhdm/ElaboratorListener.h>
#include <uhdm/SynthSubset.h>
#include <uhdm/chandle_var.h>
#include <uhdm/ExprEval.h>
#include <algorithm>
#include <uhdm/UhdmAdjuster.h>
#include <uhdm/uhdm.h>

#include "slang/ast/Compilation.h"
#include "slang/diagnostics/DiagnosticEngine.h"
#include "slang/diagnostics/LookupDiags.h"
#include "slang/driver/Driver.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/syntax/SyntaxTree.h"
#include "slang/util/VersionInfo.h"
#include "uhdm/uhdm-version.h"

namespace slang_uhdm {
extern bool g_svAllFiles188;  // § svModeAllFiles188 (UhdmExporter.cpp)
void defNetTpPatKeepActual275v();  // § defNetTpPatKeepsActual275v (UhdmExporter.cpp, v11u275)
}

using namespace slang;
using namespace slang::driver;

namespace slang_uhdm {
}

// § elabCloneFullNameUnstored137 (r11u137) — THE --elabuhdm CLONES READ THE
// INSTANCE PATH.  UHDM::ElaboratorListener::elabModule_inst DeepClones the
// definition's processes (defMod->Process()), the instance's task/function
// list (our instance lists share the definition's objects) and the other
// definition lists into every elaborated instance; each generated DeepClone
// starts with `*clone = *this`, so a full name STORED on the definition
// object is copied verbatim, while an unstored one is recomputed from the
// clone's own parent chain (BaseClass::ComputeFullName, the generated getter
// computes when nothing is stored).  Surelog leaves those names unstored, so
// golden's clones read the instance path (`work@top.u_dut.a`, `work@top.dut`,
// `work@top.get_a1`) where ours copied the definition's (`work@dut.a`,
// `work@dut`, `work@top.get_a1.a`): InterfInst, NoParamSubs, EmptyAssign,
// PortByName, ArrayVarName ... (the testflags-only fullname rows; map
// clusters N0124 N0280 N0282 N0652 N0695 N1124 N1286 N1837 N1849).  The law
// runs only when the listener runs, before listenDesigns: every object of a
// DEFINITION module/interface/program subtree whose stored full name EQUALS
// the name its own chain computes is left unstored (the definition view reads
// the same name either way; the clone now computes its own).  A name that
// differs from its chain is a modelled deviation and stays.  Grid
// tools/probe/r11u137repro/grid/eb.  Switch: R11U137_ELABCLONE_OFF.
namespace {
struct FullNameAcc137 {
    std::string_view (*get)(UHDM::BaseClass*);
    void (*set)(UHDM::BaseClass*, std::string_view);
};
template <class T>
FullNameAcc137 fnAcc137() {
    return {[](UHDM::BaseClass* o) { return ((T*)o)->VpiFullName(); },
            [](UHDM::BaseClass* o, std::string_view v) { ((T*)o)->VpiFullName(v); }};
}
bool fullNameAccess137(UHDM::BaseClass* o, FullNameAcc137& acc) {
#define ACC137(T)                                  \
    if (dynamic_cast<UHDM::T*>(o)) {               \
        acc = fnAcc137<UHDM::T>();                 \
        return true;                               \
    }
    ACC137(ref_obj)
    ACC137(ref_typespec)
    ACC137(scope)
    ACC137(nets)
    ACC137(variables)
    ACC137(hier_path)
    ACC137(parameter)
    ACC137(type_parameter)
    ACC137(concurrent_assertions)
    ACC137(property_decl)
    ACC137(sequence_decl)
    ACC137(named_event)
    ACC137(primitive)
    ACC137(instance_array)
    ACC137(gen_scope_array)
    ACC137(gen_var)
    ACC137(constraint)
#undef ACC137
    return false;
}
// BaseClass::ComputeFullName, reimplemented (it is protected).
std::string chainFullName137(const UHDM::BaseClass* self) {
    if (self->UhdmType() == UHDM::uhdmmodule_inst && self->VpiParent() &&
        self->VpiParent()->UhdmType() == UHDM::uhdmmodule_inst)
        return std::string(self->VpiDefName());
    std::vector<std::string_view> names;
    const UHDM::BaseClass* parent = self;
    const UHDM::BaseClass* child = nullptr;
    bool column = false;
    while (parent) {
        const UHDM::BaseClass* ap = parent->VpiParent();
        auto pt = parent->UhdmType();
        if (pt == UHDM::uhdmdesign)
            break;
        if (pt == UHDM::uhdmpackage || pt == UHDM::uhdmclass_defn)
            column = true;
        std::string_view name =
            parent->VpiName().empty() ? parent->VpiDefName() : parent->VpiName();
        bool skip = (ap && ap->UhdmType() == UHDM::uhdmref_obj) ||
                    pt == UHDM::uhdmmethod_func_call || pt == UHDM::uhdmmethod_task_call ||
                    pt == UHDM::uhdmfunc_call || pt == UHDM::uhdmtask_call ||
                    pt == UHDM::uhdmsys_func_call || pt == UHDM::uhdmsys_task_call;
        if (child) {
            auto ct = child->UhdmType();
            if (ct == UHDM::uhdmbit_select && pt == UHDM::uhdmport)
                skip = true;
            if (ct == UHDM::uhdmref_obj &&
                (pt == UHDM::uhdmbit_select || pt == UHDM::uhdmindexed_part_select ||
                 pt == UHDM::uhdmhier_path))
                skip = true;
        }
        if (!name.empty() && !skip)
            names.push_back(name);
        child = parent;
        parent = parent->VpiParent();
    }
    std::string out;
    for (auto it = names.rbegin(); it != names.rend(); ++it) {
        if (!out.empty())
            out += column ? "::" : ".";
        out += *it;
    }
    return out;
}
void elabCloneFullNameUnstored137(UHDM::design* d, UHDM::Serializer& s) {
    if (!d || !slang_uhdm::lawOn(137, "R11U137_ELABCLONE_OFF"))
        return;
    std::set<const UHDM::BaseClass*> defs;
    if (auto* v = d->AllModules())
        for (auto* m : *v)
            defs.insert(m);
    if (auto* v = d->AllInterfaces())
        for (auto* m : *v)
            defs.insert(m);
    if (auto* v = d->AllPrograms())
        for (auto* m : *v)
            defs.insert(m);
    // A package's subroutines are cloned into the calling instance by the
    // listener's scheduled task-function binding (golden
    // `work@t.simple_minus.value1` where ours kept the package's
    // `my_module_types::simple_minus::value1`: EvalFuncNamed, FileList,
    // FuncStruct).
    if (!slang_uhdm::envSet("R11U137_ELABCLONE_PKG_OFF")) {  // sub-switch of the law
        if (auto* v = d->AllPackages())
            for (auto* m : *v)
                defs.insert(m);
        if (auto* v = d->TopPackages())
            for (auto* m : *v)
                defs.insert(m);
    }
    // § elabCloneInstTreeUnstored144 (r11u144) — the listener clones out of
    // the ELABORATED instance trees too: it re-elaborates every generate
    // scope's contents (a hier_path over a generate array gets its fresh
    // `bit_select` element, and the index references beneath it read the
    // new chain: golden `…STAGE[i - 1].C.STAGE.i` where ours copied the
    // stored `…C.i`, CarryAdd; `…temp.inner.CHUNK`, GenScopeHierPath3), and it
    // clones an assertion's property/sequence instance, whose definition-view
    // copy is UNPARENTED (its chain ends at the instance: `p_triggers.a`),
    // into a parented clone (golden `work@m.a1.p_triggers.a`, SequenceInst).
    // The same equality test applies: a stored name equal to the object's own
    // chain is left unstored, which no un-cloned view can observe.  Switches:
    // R11U144_ELABINST_OFF (the instance trees), R11U144_ELABPROP_OFF (the
    // unparented property/sequence instance chains).
    const bool inst144 = slang_uhdm::lawOn(144, "R11U144_ELABINST_OFF");
    const bool prop144 = slang_uhdm::lawOn(144, "R11U144_ELABPROP_OFF");
    if (inst144)
        if (auto* v = d->TopModules())
            for (auto* m : *v)
                defs.insert(m);
    if (defs.empty())
        return;
    std::vector<UHDM::BaseClass*> all;
    for (auto& kv : s.AllObjects())
        all.push_back((UHDM::BaseClass*)kv.first);
    std::sort(all.begin(), all.end(),
              [](const UHDM::BaseClass* a, const UHDM::BaseClass* b) {
                  return a->UhdmId() < b->UhdmId();
              });
    std::vector<std::pair<UHDM::BaseClass*, FullNameAcc137>> clear;
    for (auto* o : all) {
        if (defs.count(o))
            continue;
        bool inDef = false;
        const UHDM::BaseClass* root144 = o;
        for (auto* a = o->VpiParent(); a; a = a->VpiParent()) {
            root144 = a;
            if (defs.count(a)) {
                inDef = true;
                break;
            }
            if (a->UhdmType() == UHDM::uhdmdesign)
                break;
        }
        if (!inDef && prop144 && root144 != o && !root144->VpiParent() &&
            (root144->UhdmType() == UHDM::uhdmproperty_inst ||
             root144->UhdmType() == UHDM::uhdmsequence_inst))
            inDef = true;
        if (!inDef)
            continue;
        // A PACKAGE subroutine keeps its stored `pkg::f` name in the clone
        // (golden `my_module_types::simple_minus` under work@t, EvalFuncNamed);
        // only its contents read the calling instance's path.
        if ((o->UhdmType() == UHDM::uhdmfunction || o->UhdmType() == UHDM::uhdmtask) &&
            o->VpiParent() && o->VpiParent()->UhdmType() == UHDM::uhdmpackage)
            continue;
        // § elabClassMethodKeepsName231 (r11u231) — a CLASS method of a
        // package is kept the same way: an importing module lists the class's
        // out-of-body method definitions (§ materializedPkgTfGroup, the
        // class_defn-parented objects), and golden's elaborated clone under
        // the instance keeps the stored `p::seqb::set_arbitration` where the
        // unstored name read the instance path `work@top.set_arbitration`
        // (grid tests/probe/r11u231repro/cases AL a02/a05/a07/a08, AO o05,
        // the -elabuhdm view).  Only a class a PACKAGE declares: a class
        // declared in a module is cloned with its instance and golden reads
        // the instance path there (`work@top::u::C::f`, grids r11u181repro
        // rt/g17, v11u223repro A/a30).  Switch R11U231_ELABCLSMETHOD_OFF.
        const bool clsMethod231 =
            (o->UhdmType() == UHDM::uhdmfunction || o->UhdmType() == UHDM::uhdmtask) &&
            o->VpiParent() && o->VpiParent()->UhdmType() == UHDM::uhdmclass_defn &&
            o->VpiParent()->VpiParent() &&
            o->VpiParent()->VpiParent()->UhdmType() == UHDM::uhdmpackage &&
            slang_uhdm::lawOn(231, "R11U231_ELABCLSMETHOD_OFF");
        FullNameAcc137 acc;
        if (!fullNameAccess137(o, acc))
            continue;
        std::string cur(acc.get(o));
        if (cur.empty() || cur != chainFullName137(o))
            continue;
        if (clsMethod231) {
            slang_uhdm::lawTrace(231, "elabClassMethodKeepsName231", cur);
            continue;
        }
        clear.push_back({o, acc});
    }
    for (auto& [o, acc] : clear)
        acc.set(o, std::string_view());
}
}  // namespace

static int realMain(int argc, char** argv) {
    Driver driver;
    // § fileMacroAbs15 — `__FILE__` must expand to the file's ABSOLUTE path.
    // slang's SourceManager::cacheBuffer stores each buffer's display name as
    // `fs::proximate(path)` (relative to the CWD) and `expandIntrinsic` builds
    // the `__FILE__` string literal from exactly that name, so a UVM compiled
    // from a test directory yielded "../../UVM/uvm-1.2/src/base/uvm_object.svh"
    // where the reference tool yields the absolute path.  The string is a
    // constant's vpiDecompile/vpiSize, both of which uhdm-cmp compares, so this
    // is a VALUE difference, not the location difference it looks like in a
    // dump diff (measured: 1596 of SeqDriver's 1626 differing constants, and
    // 3179 of the UVM-4's 3451).  Everything the emitter itself writes already
    // goes through SourceManager::getFullPath, so disabling proximate paths
    // moves only `__FILE__` and slang's own diagnostic text.
    driver.sourceManager.setDisableProximatePaths(true);
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
    // `parametersubstitution` and `letexprsubstitution` are implemented; any
    // other feature name is a hard error rather than a silent no-op, because
    // silently ignoring a model-shaping flag manufactures a happy path
    // (GOLDEN_EQUIVALENCE 2.3).
    std::vector<std::string> disableFeatures;
    std::vector<std::string> enableFeatures;
    driver.cmdLine.add("--disable-feature", disableFeatures,
                       "Disable a Surelog compile feature (comma separated). Supported: "
                       "parametersubstitution, letexprsubstitution",
                       "<feature>[,...]");
    driver.cmdLine.add("--enable-feature", enableFeatures,
                       "Enable a Surelog compile feature (comma separated). Supported: "
                       "parametersubstitution, letexprsubstitution (both the default)",
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
    // § filterProtected120 (r11u120) — Surelog's `-filterprotected`.
    std::optional<bool> filterProtected;
    driver.cmdLine.add("--filterprotected", filterProtected,
                       "Exclude '// synopsys|synthesis|pragma translate_off' .. 'translate_on' "
                       "regions and reproduce Surelog -filterprotected's line accounting");

    // § svModeAllFiles188 (r11u188) — Surelog's `-sverilog` (CommandLineParser
    // m_sverilog -> ParseFile's `fullSVMode()`) parses EVERY file as
    // SystemVerilog, whatever its extension; without it a `.v` root file is
    // lexed in Verilog mode (verilogLexMode).  The flag reaches the exporter
    // through g_svAllFiles188 (UhdmExporter.cpp).  Switch R11U188_SVMODE_OFF.
    std::optional<bool> svAllFiles;
    driver.cmdLine.add("--sverilog", svAllFiles,
                       "Parse every file as SystemVerilog for the database's Verilog-mode "
                       "lexing quirks, as Surelog -sverilog does (a .v file otherwise follows "
                       "Surelog's Verilog lexer)");

    if (!driver.parseCommandLine(argc, argv))
        return 1;
    if (svAllFiles == true && !slang_uhdm::envSet("R11U188_OFF") && !slang_uhdm::envSet("R11U188_SVMODE_OFF"))
        slang_uhdm::g_svAllFiles188 = true;

    if (showHelp == true) {
        printf("%s\n",
               driver.cmdLine.getHelpText("slang-uhdm: SystemVerilog to UHDM exporter").c_str());
        return 0;
    }

    if (showVersion == true) {
#define SLANG_UHDM_STR2(x) #x
#define SLANG_UHDM_STR(x) SLANG_UHDM_STR2(x)
        printf("slang-uhdm using slang version %s\n", VersionInfo::getVersionString().c_str());
        printf("slang-uhdm using UHDM version %d.%d (%s)\n", UHDM_VERSION_MAJOR,
               UHDM_VERSION_MINOR, SLANG_UHDM_STR(UHDM_VERSION_COMMIT_SHA));
        return 0;
    }

    // Feature toggles, comma-split like CommandLineParser.cpp, unknown names
    // rejected. slang hands the two flags over as two separate lists, so argv
    // order between them is lost and `--disable-feature` is applied last: a
    // command line naming the same feature both ways ends up disabled whatever
    // the order. No suite test does that, and the two flags are documented as
    // opposites rather than as an ordered sequence.
    bool paramSubstitution = true;
    bool letExprSubstitution = true;
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
                    else if (feat == "letexprsubstitution")
                        letExprSubstitution = on;
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
    // § filterProtected120 (r11u120) — THE REGIONS.  Surelog's `-filterprotected`
    // (uhdm2rtlil's downstream flow passes it) drops every one-line comment
    // region `// synopsys|pragma|synthesis translate_off` .. `translate_on`
    // from the preprocessed text (SV3_1aPpTreeShapeListener::enterComment, the
    // three regexes `//\s*<word>\s+translate_(off|on)\s*`, Surelog v1.87 and
    // uhdm2rtlil's v1.87-5 alike).  slang's `--translate-off-format` is the same
    // exclusion at the lexer, so ask for it once per prefix.  Measured:
    // gen_scope_numports, whose `// synthesis translate_off` region holds the
    // only `tc_sram` instance — without the exclusion the database elaborates
    // an instance golden does not have (uhdm-cmp 9824 lines under the
    // downstream flags).  Boundary: slang also honours BLOCK comments and
    // trailing words after the keyword, Surelog neither (no corpus file has
    // either form).  `R11U120_FP_OFF=1` makes the flag a no-op.
    const bool fpRegions120 = filterProtected == true && !slang_uhdm::envSet("R11U120_OFF") &&
                              !slang_uhdm::envSet("R11U120_FP_OFF");
    if (fpRegions120) {
        driver.options.translateOffOptions.push_back("synopsys,translate_off,translate_on");
        driver.options.translateOffOptions.push_back("synthesis,translate_off,translate_on");
        if (!synthSubset)
            driver.options.translateOffOptions.push_back("pragma,translate_off,translate_on");
    }

    // Surelog predefines `SURELOG=1` for every compilation (SurelogMacro:
    // `ifdef SURELOG guards the whole design, and the golden database contains
    // work@top). It is a UHDM-relevant fact about the golden tool's
    // environment, exactly like the builtin package, so mirror it. Prepended so
    // an explicit -DSURELOG=... on the command line still wins.
    driver.options.defines.insert(driver.options.defines.begin(), "SURELOG=1");

    // ...and the LRM coverage-control macros, from the very same builtin block
    // (Surelog src/DesignCompile/Builtin.cpp addBuiltinMacros, which defines
    // `SURELOG 1` alongside them). They are UHDM-relevant: a design that spells
    // `$coverage_control(`SV_COV_CHECK, ...)` gets those numbers as sys-call
    // ARGUMENT CONSTANTS in the database (CovMacro: UINT:3 / UINT:23 / UINT:11
    // against our UINT:0 for every undefined macro). Unlike `SURELOG`, this
    // block is gated the way Surelog gates it — `-nobuiltin` turns
    // parseBuiltIn() off and takes the macros with it. Prepended in reverse so
    // the list keeps source order and an explicit -D still wins.
    if (noBuiltin != true) {
        static const char* const kCovMacros[] = {
            "SV_COV_START=0",     "SV_COV_STOP=1",      "SV_COV_RESET=2",
            "SV_COV_CHECK=3",     "SV_COV_MODULE=10",   "SV_COV_HIER=11",
            "SV_COV_ASSERTION=20", "SV_COV_FSM_STATE=21",
            "SV_COV_STATEMENT=22", "SV_COV_TOGGLE=23",  "SV_COV_OVERFLOW=-2",
            "SV_COV_ERROR=-1",    "SV_COV_NOCOV=0",     "SV_COV_OK=1",
            "SV_COV_PARTIAL=2"};
        for (size_t i = sizeof(kCovMacros) / sizeof(kCovMacros[0]); i-- > 0;)
            driver.options.defines.insert(driver.options.defines.begin(),
                                          kCovMacros[i]);
    }

    // Surelog `-P<name>=<value>` (which the harness spells `-G` because that is
    // slang's option) stores the value as an unparsed STRING:
    // `m_paramList.emplace(id, StringUtils::unquoted(value))`, and later turns
    // it into a Value with `ExprBuilder::fromString`. slang instead parses the
    // value as an EXPRESSION and hard-errors when it is not one, which is how
    // `-PSRAMInitFile=/blah` (tests/ParamFile) becomes a rejection rather than a
    // string-valued override, and how `-PA="'d7_200"` (tests/DecValue) becomes a
    // 56-bit STRING instead of the number 7200 -- the quotes are argv characters
    // that Surelog strips and slang does not.
    //
    // So: unquote exactly as Surelog does, keep the raw string for the exporter
    // (which reproduces fromString's typing -- see UhdmExporter::cliOverrideConst),
    // and hand slang a spelling it can parse so the DERIVED values (localparams
    // computed from the override) still elaborate. A value that is not a number
    // becomes a string literal, which is what Surelog's fromString falls back to.
    std::map<std::string, std::string> cliParams;
    for (auto& opt : driver.options.paramOverrides) {
        auto eq = opt.find('=');
        if (eq == std::string::npos)
            continue;
        std::string name = opt.substr(0, eq);
        // A dotted left-hand side is slang's `defparam` form, which Surelog's
        // -P does not have; leave those to slang untouched.
        if (name.find('.') != std::string::npos)
            continue;
        std::string val = opt.substr(eq + 1);
        if (val.size() >= 2 && ((val.front() == '"' && val.back() == '"') ||
                                (val.front() == '\'' && val.back() == '\'')))
            val = val.substr(1, val.size() - 2);
        cliParams[name] = val;
        // Numeric (plain integer, real, or based literal) passes through; slang
        // parses all three, including the `_` separators.
        bool numeric = !val.empty();
        {
            size_t i = (val[0] == '-' || val[0] == '+') ? 1 : 0;
            bool sawDigit = false, sawTick = false;
            for (; i < val.size() && numeric; i++) {
                char c = val[i];
                if (c == '\'') {
                    if (sawTick)
                        numeric = false;
                    sawTick = true;
                }
                else if (isalnum((unsigned char)c) || c == '_' || c == '.') {
                    if (isdigit((unsigned char)c))
                        sawDigit = true;
                    else if (!sawTick && c != '.')
                        numeric = false;  // a bare identifier is not a number
                }
                else
                    numeric = false;
            }
            numeric = numeric && sawDigit;
        }
        if (!numeric) {
            std::string q = "\"";
            for (char c : val) {
                if (c == '"' || c == '\\')
                    q += '\\';
                q += c;
            }
            q += '"';
            opt = name + "=" + q;
        }
        else
            opt = name + "=" + val;
    }

    // -cfgfile sources go in before processOptions() so they take part in the
    // normal source-existence check; the -cfg tops are pushed later, once the
    // sources are parsed and the declared config names are known.
    for (auto& file : cfgFiles)
        driver.sourceLoader.addFiles(file);

    if (!driver.processOptions())
        return 2;

    bool ok = driver.parseAllSources();

    // § fpAbstainOnMatcherSplit120v (v11u120, the verifier) — L6 STANDS ONLY
    // WHERE slang's translate-off MATCHER AND SURELOG'S AGREE.
    //
    // slang's handler (Lexer::tryApplyCommentHandler / scanDisabledRegion)
    // opens a region on `//` OR `/*` followed by `<prefix> translate_off` with
    // ANY trailing text, and closes it only at the SAME prefix's
    // `translate_on` (again `//` or `/*`, any trailing text), scanning RAW text
    // straight through preprocessor directives.  Surelog's
    // (SV3_1aPpTreeShapeListener::enterComment) takes a ONE-LINE comment only,
    // `regex_match` of `//\s*<prefix>\s+translate_(off|on)\s*` (no trailing
    // text), closes at ANY prefix's translate_on, and keeps processing
    // `define/`include/`ifdef inside the region.  Where they split, L6 moved
    // legal designs AWAY from golden (verifier grid F, pristine -> L6):
    // trailing words on translate_off (x01, x03) EQUIVALENT -> STATUS_DIFF,
    // a block-comment pair (x02) IDENTICAL -> STATUS_DIFF, mixed prefixes
    // (x04) and a translate_off in an inactive branch closed after the
    // `endif (x05) EQUIVALENT -> SLANG_REJECT.  So: every translate-off region
    // slang made is checked against Surelog's reading (a one-line opener that
    // regex_matches, a one-line closer that regex_matches and ends the region,
    // no other prefix's translate_on inside, no `define/`undef/`include
    // inside, conditionals balanced inside); on ANY disagreement the sources
    // are re-parsed WITHOUT the three handlers and L7 stands down too, i.e.
    // the pristine reading (pristine bytes) for the whole run.  Grid
    // tests/probe/r11v120repro/grid/F: x01-x05 and x20 back at their pristine
    // verdicts, x06-x19 and x21 keep L6/L7's bytes.  `R11V120_FPSPLIT_OFF=1`
    // drops it.
    bool fpSplit120v = false;
    if (fpRegions120 && !slang_uhdm::envSet("R11V120_FPSPLIT_OFF")) {
        static const std::regex onReV(
            R"(//\s*(synopsys|pragma|synthesis)\s+translate_on\s*)");
        static const std::regex offReV(
            R"(//\s*(synopsys|pragma|synthesis)\s+translate_off\s*)");
        // A directive line inside a region: Surelog still EXECUTES it (only the
        // text is filtered), slang skips it raw.  Balanced conditionals agree
        // (both drop the text between them: pulp common_cells' `ifndef
        // VERILATOR .. `endif inside its regions); a define/undef/include or
        // a conditional that crosses the region boundary does not.
        static const std::regex dirReV(
            R"(\s*`\s*(define|undef|undefineall|include|ifdef|ifndef|elsif|else|endif)\b[\s\S]*)");
        // slang's opener rule, for the prefixes L6 registered.
        auto slangRegionV = [&](std::string_view t) -> bool {
            if (t.size() < 2 || t[0] != '/' || (t[1] != '/' && t[1] != '*'))
                return false;
            size_t i = 2;
            auto word = [&]() {
                while (i < t.size() && (t[i] == ' ' || t[i] == '\t'))
                    i++;
                size_t st = i;
                while (i < t.size() &&
                       (isalnum((unsigned char)t[i]) || t[i] == '_' || t[i] == '-'))
                    i++;
                return t.substr(st, i - st);
            };
            auto w1 = word();
            bool pfx = w1 == "synopsys" || w1 == "synthesis" ||
                       (w1 == "pragma" && !synthSubset);
            return pfx && word() == "translate_off";
        };
        int depthV = 0;
        auto lineSplitsV = [&](std::string_view line) -> bool {
            std::match_results<std::string_view::const_iterator> mV;
            if (std::regex_match(line.begin(), line.end(), mV, dirReV)) {
                auto kw = mV[1].str();
                if (kw == "ifdef" || kw == "ifndef")
                    depthV++;
                else if (kw == "endif") {
                    if (--depthV < 0)
                        return true;
                }
                else if (kw == "else" || kw == "elsif") {
                    if (depthV == 0)
                        return true;
                }
                else
                    return true;  // define / undef / undefineall / include
            }
            for (size_t c = line.find("//"); c != std::string_view::npos;
                 c = line.find("//", c + 2)) {
                auto sub = line.substr(c);
                if (std::regex_match(sub.begin(), sub.end(), onReV))
                    return true;
            }
            return false;
        };
        auto surelogAgreesV = [&](std::string_view t) -> bool {
            if (t[1] != '/')
                return false;  // a block-comment opener
            size_t nl = t.find('\n');
            size_t lastNl = t.rfind('\n');
            if (nl == std::string_view::npos)
                return false;  // unclosed on its own line
            std::string_view first = t.substr(0, nl);
            if (!std::regex_match(first.begin(), first.end(), offReV))
                return false;  // trailing text: Surelog opens nothing
            std::string_view tail = t.substr(lastNl + 1);
            size_t cs = tail.find("//");
            if (cs == std::string_view::npos)
                return false;  // a block-comment closer, or unclosed
            std::string_view closing = tail.substr(cs);
            if (!std::regex_match(closing.begin(), closing.end(), onReV))
                return false;  // trailing text: Surelog does not close here
            depthV = 0;
            for (size_t p = nl + 1; p < lastNl + 1;) {
                size_t e = t.find('\n', p);
                if (lineSplitsV(t.substr(p, e - p)))
                    return false;  // another prefix closes / a directive inside
                p = e + 1;
            }
            if (lineSplitsV(tail.substr(0, cs)))
                return false;
            return depthV == 0;  // a conditional left open crosses the boundary
        };
        std::function<void(const syntax::SyntaxNode&)> nodeV;
        std::function<void(parsing::Token)> tokV = [&](parsing::Token tk) {
            for (auto& v : tk.trivia()) {
                if (fpSplit120v)
                    return;
                if (v.kind == parsing::TriviaKind::Directive) {
                    if (auto* syn = v.syntax())
                        nodeV(*syn);
                    continue;
                }
                if (v.kind != parsing::TriviaKind::DisabledText)
                    continue;
                auto text = v.getRawText();
                if (slangRegionV(text) && !surelogAgreesV(text))
                    fpSplit120v = true;
            }
        };
        nodeV = [&](const syntax::SyntaxNode& n) {
            using syntax::SyntaxKind;
            if (fpSplit120v)
                return;
            if (n.kind == SyntaxKind::IfDefDirective || n.kind == SyntaxKind::IfNDefDirective ||
                n.kind == SyntaxKind::ElsIfDirective) {
                auto& c = n.as<syntax::ConditionalBranchDirectiveSyntax>();
                tokV(c.directive);
                nodeV(*c.expr);
                for (auto dt : c.disabledTokens)
                    tokV(dt);
                return;
            }
            if (n.kind == SyntaxKind::ElseDirective) {
                auto& c = n.as<syntax::UnconditionalBranchDirectiveSyntax>();
                tokV(c.directive);
                for (auto dt : c.disabledTokens)
                    tokV(dt);
                return;
            }
            for (size_t k = 0; k < n.getChildCount(); k++) {
                if (auto* cn = n.childNode(k))
                    nodeV(*cn);
                else if (auto ct = n.childToken(k))
                    tokV(ct);
            }
        };
        for (auto& tree : driver.syntaxTrees)
            nodeV(tree->root());
        if (fpSplit120v) {
            auto bagV = driver.createParseOptionBag();
            auto& loV = bagV.insertOrGet<parsing::LexerOptions>();
            loV.commentHandlers.erase("synopsys");
            loV.commentHandlers.erase("synthesis");
            if (!synthSubset)
                if (auto it = loV.commentHandlers.find("pragma");
                    it != loV.commentHandlers.end())
                    it->second.erase("translate_off");
            driver.syntaxTrees = driver.sourceLoader.loadAndParseSources(bagV, nullptr);
            if (slang_uhdm::envSet("R11U120_FPDBG"))
                fprintf(stderr, "R11V120 FPSPLIT: re-parsed without the translate-off handlers\n");
        }
    }

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

    // § fpLineFiller120 (r11u120) — THE LINE ACCOUNTING of `-filterprotected`.
    //
    // Producer (SV3_1aPpTreeShapeListener.cpp, enterComment/exitComment):
    // under the flag, a one-line comment matching `//\s*(synopsys|pragma|
    // synthesis)\s+translate_on\s*` ALWAYS calls `addLineFiller(ctx)`, which
    // appends the comment's newline to the preprocessed text.  That filler is
    // the only newline the comment contributes when it CLOSES a region in
    // active text (enterComment skipped the append because the region was
    // still on).  Anywhere else it is a SECOND newline: in an INACTIVE
    // `ifdef branch exitComment adds its own filler for the comment, and a
    // STRAY one in active text (no region open) was already appended whole.
    // Each such comment pushes every later preprocessed line down by one.
    // Positions are mapped back to the file through the IncludeFileInfo
    // records only a macro expansion (or include) writes: a WITH-ARGS macro
    // invocation (PUSH + POP, even for an empty body) re-anchors at its own
    // source line — the whole line, tokens before the backtick included — and
    // so does a no-arg macro whose body spans lines (its POP is recorded only
    // when the body holds a newline); a single-line no-arg macro records
    // nothing.  So per file: +1 for every line after each such comment, reset
    // to 0 from the line of the next re-anchoring expansion on.
    //
    // Measured with uhdm2rtlil's own Surelog, -DSYNTHESIS with vs without
    // -filterprotected (tests/probe/r11u120repro/grid/gF, fpspans.sh):
    // inactive `ifndef/`else translate_on +1 (f01, f07), twice +2 (f05), a
    // stray active translate_on +1 (f03), a closing one 0 (f04, f06), a
    // with-args macro re-anchors from its line (f02, f09, f12), a no-arg
    // single-line macro does not (f08), across module boundaries (f10).
    // ibex_controller.sv: the `ifndef SYNTHESIS region at 171-183 shifts
    // lines 183-207 until `ASSERT(...)` at 208 (34 RTLIL src lines).
    //
    // Here: one walk over every syntax tree classifying each translate_on
    // comment by where slang keeps it — an active LineComment trivia (a stray),
    // a branch's disabled tokens' trivia or a not-taken branch's terminator
    // trivia rewritten to DisabledText (inactive), or the tail of a
    // translate-off region's DisabledText (closing: counts only when the
    // region itself sits in an inactive branch).  The shift is applied as a
    // post-pass over every object's line fields right before the save, keyed
    // by the object's file.  `R11U120_FPLINE_OFF=1` drops it alone.
    struct FpEv120 {
        size_t off;
        bool resync;
    };
    std::map<std::string, std::vector<FpEv120>> fpEvents120;
    const bool fpLines120 = filterProtected == true && !slang_uhdm::envSet("R11U120_OFF") &&
                            !slang_uhdm::envSet("R11U120_FPLINE_OFF") && !fpSplit120v;
    if (fpLines120) {
        auto& sm120 = driver.sourceManager;
        struct Buf120 {
            const char* b;
            const char* e;
            std::string path;
        };
        std::vector<Buf120> bufs120;
        for (auto id : sm120.getAllBuffers()) {
            auto t = sm120.getSourceText(id);
            if (t.empty())
                continue;
            bufs120.push_back({t.data(), t.data() + t.size(), sm120.getFullPath(id).string()});
        }
        // (path, offset) of a pointer into some file buffer's text.
        auto where120 = [&](const char* p) -> std::pair<const Buf120*, size_t> {
            for (auto& b : bufs120)
                if (p >= b.b && p < b.e)
                    return {&b, (size_t)(p - b.b)};
            return {nullptr, 0};
        };
        static const std::regex onRe120(
            R"(//\s*(synopsys|pragma|synthesis)\s+translate_on\s*)");
        static const std::regex offRe120(
            R"(//\s*(synopsys|pragma|synthesis)\s+translate_off\s*)");
        auto addEv120 = [&](const char* p, bool resync) {
            auto [b, off] = where120(p);
            if (b)
                fpEvents120[b->path].push_back({off, resync});
        };
        std::map<std::string, bool> multiLineDef120;
        std::function<void(const syntax::SyntaxNode&, bool)> node120;
        std::function<void(parsing::Token, bool)> tok120;
        tok120 = [&](parsing::Token t, bool inactive) {
            auto tr = t.trivia();
            for (size_t i = 0; i < tr.size(); i++) {
                auto& v = tr[i];
                if (v.kind == parsing::TriviaKind::Directive) {
                    if (auto* syn = v.syntax())
                        node120(*syn, inactive);
                    continue;
                }
                auto text = v.getRawText();
                if (text.empty())
                    continue;
                if (v.kind == parsing::TriviaKind::LineComment) {
                    // Active: a stray; inactive: inside a skipped branch.
                    if (std::regex_match(text.begin(), text.end(), onRe120))
                        addEv120(text.data(), false);
                    continue;
                }
                if (v.kind != parsing::TriviaKind::DisabledText)
                    continue;
                // A not-taken branch's terminator comment, rewritten.
                if (std::regex_match(text.begin(), text.end(), onRe120)) {
                    addEv120(text.data(), false);
                    continue;
                }
                // A translate-off REGION: its first line is the opening
                // comment, its tail the closing one.
                size_t nl = text.find('\n');
                std::string_view first = text.substr(0, nl);
                if (!std::regex_match(first.begin(), first.end(), offRe120))
                    continue;
                size_t lastNl = text.rfind('\n');
                if (lastNl == std::string_view::npos)
                    continue;  // unclosed on its own line: no closing comment
                std::string_view tail = text.substr(lastNl + 1);
                size_t cs = tail.find("//");
                if (cs == std::string_view::npos)
                    continue;
                std::string_view closing = tail.substr(cs);
                if (!std::regex_match(closing.begin(), closing.end(), onRe120))
                    continue;
                bool regionInactive = inactive;
                if (!regionInactive)
                    for (size_t j = i + 1; j < tr.size(); j++) {
                        if (tr[j].kind == parsing::TriviaKind::EndOfLine)
                            break;
                        if (tr[j].kind == parsing::TriviaKind::DisabledText) {
                            regionInactive = true;
                            break;
                        }
                    }
                if (regionInactive)
                    addEv120(closing.data(), false);
            }
        };
        node120 = [&](const syntax::SyntaxNode& n, bool inactive) {
            using syntax::SyntaxKind;
            if (n.kind == SyntaxKind::IfDefDirective || n.kind == SyntaxKind::IfNDefDirective ||
                n.kind == SyntaxKind::ElsIfDirective) {
                auto& c = n.as<syntax::ConditionalBranchDirectiveSyntax>();
                tok120(c.directive, inactive);
                node120(*c.expr, inactive);
                for (auto dt : c.disabledTokens)
                    tok120(dt, true);
                return;
            }
            if (n.kind == SyntaxKind::ElseDirective) {
                auto& c = n.as<syntax::UnconditionalBranchDirectiveSyntax>();
                tok120(c.directive, inactive);
                for (auto dt : c.disabledTokens)
                    tok120(dt, true);
                return;
            }
            if (n.kind == SyntaxKind::DefineDirective && !inactive) {
                auto& d = n.as<syntax::DefineDirectiveSyntax>();
                bool ml = false;
                if (!d.body.empty()) {
                    auto s0 = d.body[0].rawText().data();
                    auto s1 = d.body[d.body.size() - 1].rawText().data();
                    auto [b0, o0] = where120(s0);
                    auto [b1, o1] = where120(s1);
                    if (b0 && b0 == b1)
                        for (size_t k = o0; k < o1; k++)
                            if (b0->b[k] == '\n') {
                                ml = true;
                                break;
                            }
                }
                multiLineDef120[std::string(d.name.valueText())] = ml;
            }
            if (n.kind == SyntaxKind::MacroUsage && !inactive) {
                auto& m = n.as<syntax::MacroUsageSyntax>();
                std::string nm(m.directive.valueText());
                if (!nm.empty() && nm[0] == '`')
                    nm.erase(0, 1);
                auto it = multiLineDef120.find(nm);
                if (m.args || (it != multiLineDef120.end() && it->second))
                    addEv120(m.directive.rawText().data(), true);
            }
            if (n.kind == SyntaxKind::IncludeDirective && !inactive) {
                auto& inc = n.as<syntax::IncludeDirectiveSyntax>();
                addEv120(inc.directive.rawText().data(), true);
            }
            for (size_t k = 0; k < n.getChildCount(); k++) {
                if (auto* cn = n.childNode(k))
                    node120(*cn, inactive);
                else if (auto ct = n.childToken(k))
                    tok120(ct, inactive);
            }
        };
        for (auto& tree : driver.syntaxTrees)
            node120(tree->root(), false);
        for (auto& [p, evs] : fpEvents120)
            std::stable_sort(evs.begin(), evs.end(),
                             [](const FpEv120& a, const FpEv120& b) { return a.off < b.off; });
        if (slang_uhdm::envSet("R11U120_FPDBG"))
            for (auto& [p, evs] : fpEvents120)
                for (auto& e : evs)
                    fprintf(stderr, "R11U120 FP %s off=%zu %s\n", p.c_str(), e.off,
                            e.resync ? "RESYNC" : "SHIFT");
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
    if (!letExprSubstitution)
        exporter.setNoLetSubst();
    if (!cliParams.empty())
        exporter.setCmdLineParams(cliParams);
    if (!bbMods.empty() || !bbInsts.empty())
        exporter.setBlackBoxes(std::set<std::string>(bbMods.begin(), bbMods.end()),
                               std::set<std::string>(bbInsts.begin(), bbInsts.end()));
    // § genCaPatKeepTagDefView121 (r10earl121) — the emitter has to know which
    // of the two views it is writing, because ONE of the flattens it models is
    // performed by `UHDM::ElaboratorListener` (`cont_assign::DeepClone`) and
    // not by Surelog's writer.  The test is the SAME `elabUhdm == true` that
    // gates the `ElaboratorContext` run below, so the flag can never disagree
    // with whether that listener actually runs.
    if (elabUhdm == true)
        exporter.setElabUhdmView121();
    UHDM::design* design = exporter.exportDesign();

    // § genCaCastFoldDefaultView119 (r10earl119) — the DEFAULT-view half of
    // § genCaCastFoldAdjustSize106.  Surelog folds and `adjustSize`s a
    // bound-Lhs gen-scope cast Rhs inside `UhdmWriter::writeCont_assign`, the
    // INSTANCE-tree writer, which is not conditioned on `-elabuhdm` at all --
    // measured on r10earl106's four arms built twice by the real Surelog:
    // golden's default and elaborated views hold the SAME constant on every
    // bound-Lhs cell and differ only where the bind FAILS.  Our own fold is
    // `UHDM::UhdmAdjuster`'s, which runs only below, so without this the
    // default view keeps the unfolded `vpiCastOp` operation (the
    // Earlgrey_0_1/default head at padctrl.sv:39:24).  Placed HERE, and
    // guarded so that it and `applyCaCastAdjust106` are MUTUALLY EXCLUSIVE:
    // one law, one application, whichever view is being written.
    if (elabUhdm != true)
        exporter.applyCaCastFoldDef119(design);

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
            // § elabCloneFullNameUnstored137 — before the listener clones
            // (law and decode at the function).
            elabCloneFullNameUnstored137(design, serializer);
            UHDM::ElaboratorContext elaboratorContext(&serializer, false, false);
            elaboratorContext.m_elaborator.uniquifyTypespec(false);
            elaboratorContext.m_elaborator.listenDesigns(designs);
            // § defNetTpPatKeepsActual275v (v11u275, law and decode at
            // UhdmExporter's defNetTpDimLastInstPat275).  Switch
            // R11V275_KEEPACTUAL_OFF.
            slang_uhdm::defNetTpPatKeepActual275v();

            // § unsizedInnerSizeDeclines223 (r11u223, pass 219's residue: the
            // elaborated view's rc 139 on `$size` of `int md [4][]` / `int
            // mq [4][$]`) — an array_var whose first unsized dimension is
            // dynamic or a queue behind a fixed one carries no vpiReg element
            // in golden (tools/probe/r11u223repro/cases/C c02, c03, c07), and
            // UHDM's ExprEval::size reads `array_var->Variables()->at(0)`
            // unguarded, so the adjuster's `$size`/`$bits` fold segfaulted
            // (Surelog itself fails on those cases).  For the adjuster's run
            // only, every array_var without an element holds a placeholder
            // element of a kind ExprEval::size does not size (a chandle_var,
            // its default arm: invalidValue), so the fold declines and the
            // call stays; the placeholder lives outside the serializer and is
            // removed right after, so no written byte can come from it.
            // Switch R11U223_SIZEDECLINE_OFF.
            std::vector<UHDM::array_var*> noElem223;
            static UHDM::chandle_var placeholder223;
            static std::vector<UHDM::variables*> phVec223{&placeholder223};
            // § sizeDeclineTsInvalid223v (v11u223, the adversarial verification
            // of r11u223) — ExprEval::size's array_var arm does not size the
            // element variable itself: it sizes `regv->Typespec()`'s actual,
            // so a placeholder with no typespec adds 0 bits WITHOUT setting
            // invalidValue; the `$size` generic handler then multiplies 0 by
            // the array's last range and the adjuster wrote the invented
            // constant `UINT:0` in place of the call (r11u223repro S/s02,
            // v11u219repro S/s01 and s01b: `$size` of `int md [4][]` came
            // out `UINT:0`, sized 8 and location-less by
            // § ndaAdjSizeFoldSized223, where the dimension's size is 4 and
            // Surelog writes no database).  The placeholder now carries a
            // chandle_typespec, a kind ExprEval::size does not size (its
            // default arm sets invalidValue), so
            // updateParentWithReducedExpression returns and the call stays,
            // as the law intends.  Both objects live outside the serializer
            // like the placeholder.  Switch R11V223_SIZEINVALID_OFF
            // (R11V223_OFF drops every v11u223 refinement).
            static UHDM::ref_typespec phRt223v;
            static UHDM::chandle_typespec phTs223v;
            if (slang_uhdm::lawFixOn(223, "R11V223_SIZEINVALID_OFF")) {
                phRt223v.Actual_typespec(&phTs223v);
                placeholder223.Typespec(&phRt223v);
            } else {
                placeholder223.Typespec(nullptr);
            }
            if (slang_uhdm::lawOn(223, "R11U223_SIZEDECLINE_OFF")) {
                for (auto& kv : serializer.AllObjects())
                    if (kv.first && kv.first->UhdmType() == UHDM::uhdmarray_var) {
                        auto* av223 = (UHDM::array_var*)kv.first;
                        if (!av223->Variables()) {
                            noElem223.push_back(av223);
                            av223->Variables(&phVec223);
                        }
                    }
            }
            // § ndaAdjSizeFoldSized223 (r11u223, pass 219's residue: golden's
            // generic-handler `$size` values, v11u219 cases S s04 s08) — a
            // net declaration's whole-initializer `$size` call that
            // § ndaSizeQueryFold216's reach declines is left to the adjuster,
            // whose ExprEval reduce writes golden's VALUE (the generic handler
            // included) but at the call's span with size 64; Surelog's
            // writeCont_assign folds it before writing, and adjustSize masks
            // and sizes it to the net, location-less, parented at the
            // assignment (golden s08 `UINT:2` size 8, no span).  The same
            // shape § ndaSizeQueryFold216 writes itself.  Recorded here after
            // the elaborator (the objects the adjuster sees), applied after
            // the adjuster to the constant that replaced the call.  Switch
            // R11U223_ADJSIZE_OFF.
            struct AdjSz223 {
                UHDM::cont_assign* ca;
                const UHDM::any* call;
                int64_t width;
            };
            std::vector<AdjSz223> adjSz223;
            if (slang_uhdm::lawOn(223, "R11U223_ADJSIZE_OFF")) {
                std::vector<UHDM::cont_assign*> cas223;
                for (auto& kv : serializer.AllObjects())
                    if (kv.first && kv.first->UhdmType() == UHDM::uhdmcont_assign)
                        cas223.push_back((UHDM::cont_assign*)kv.first);
                std::sort(cas223.begin(), cas223.end(),
                          [](const UHDM::cont_assign* a, const UHDM::cont_assign* b) {
                              return a->UhdmId() < b->UhdmId();
                          });
                for (auto* ca : cas223) {
                    if (!ca->VpiNetDeclAssign() || !ca->Rhs() || !ca->Lhs() ||
                        ca->Rhs()->UhdmType() != UHDM::uhdmsys_func_call ||
                        ((const UHDM::sys_func_call*)ca->Rhs())->VpiName() != "$size")
                        continue;
                    const UHDM::any* lhs = ca->Lhs();
                    const UHDM::ref_typespec* lrt = nullptr;
                    if (lhs->UhdmType() == UHDM::uhdmlogic_net)
                        lrt = ((const UHDM::logic_net*)lhs)->Typespec();
                    const UHDM::logic_typespec* lts =
                        lrt ? lrt->Actual_typespec<UHDM::logic_typespec>() : nullptr;
                    if (!lts)
                        continue;
                    int64_t w = 1;
                    bool ok = true;
                    if (auto* rs = lts->Ranges())
                        for (auto* r : *rs) {
                            auto* l = r ? r->Left_expr<UHDM::constant>() : nullptr;
                            auto* rr = r ? r->Right_expr<UHDM::constant>() : nullptr;
                            if (!l || !rr) {
                                ok = false;
                                break;
                            }
                            UHDM::ExprEval ev;
                            bool inv = false;
                            int64_t lv = ev.get_value(inv, l), rv = ev.get_value(inv, rr);
                            if (inv) {
                                ok = false;
                                break;
                            }
                            w *= (lv > rv ? lv - rv : rv - lv) + 1;
                        }
                    if (ok && w > 0)
                        adjSz223.push_back({ca, ca->Rhs(), w});
                }
            }
            UHDM::UhdmAdjuster adjuster(&serializer, design);
            adjuster.listenDesigns(designs);
            for (auto* av223 : noElem223)
                if (av223->Variables() == &phVec223)
                    av223->Variables(nullptr);
            for (auto& a223 : adjSz223) {
                auto* c = a223.ca->Rhs();
                if (!c || c == a223.call || c->UhdmType() != UHDM::uhdmconstant)
                    continue;
                auto* k = (UHDM::constant*)c;
                std::string_view v = k->VpiValue();
                if (v.rfind("UINT:", 0) != 0)
                    continue;
                uint64_t uv = strtoull(std::string(v.substr(5)).c_str(), nullptr, 10);
                if (a223.width < 64)
                    uv &= (((uint64_t)1 << a223.width) - 1);
                k->VpiValue("UINT:" + std::to_string(uv));
                k->VpiDecompile(std::to_string(uv));
                k->VpiSize((int32_t)a223.width);
                k->VpiFile("");
                k->VpiLineNo(0);
                k->VpiColumnNo(0);
                k->VpiEndLineNo(0);
                k->VpiEndColumnNo(0);
                k->VpiParent(a223.ca);
                slang_uhdm::lawTrace(223, "ndaAdjSizeFoldSized223", std::string(a223.ca->Lhs()->VpiName()));
            }

            // § genCaCastFoldAdjustSize106 (r10earl106) — the CONSUMER half of
            // Surelog's `UhdmWriter::writeCont_assign`.  It has to run HERE,
            // after the adjuster, because the adjuster is what folds a
            // gen-scope cast Rhs to a constant on our side at all; Surelog
            // replaced that Rhs with the ADJUSTED constant before the adjuster
            // ever saw it.  A no-op when the Rhs is still an operation.
            exporter.applyCaCastAdjust106(design);

            // § patGenCaHierPathElemNoBind115 (r10earl115) — the CONSUMER half
            // of the pattern-carried `hier_path` element law.  It has to run
            // HERE, after the elaborator, because the elaborator is what binds
            // those elements at all: `hier_path::DeepClone`'s pairwise
            // resolver reaches our pre-flattened operand list where Surelog's
            // tagged-pattern list keeps it out.  A no-op wherever nothing was
            // recorded (the whole uhdm2rtlil corpus, measured).
            exporter.applyPatCaElemUnbind115(design);
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

    // § parseViewSizeExprEval228 (r11u228, pass 223's residue 5 and v11u223's
    // residue 6: the parse view's `$size`, downstream-visible) — in the parse
    // view (no -elabuhdm) Surelog writes a module instance's net declaration
    // `wire [1:0] w = $size(bp);` with the call already reduced by UHDM
    // ExprEval (its `$size` dimension walker, else the generic `$bits`-style
    // handler: `$size(bp)` of `bit [3:0][1:0]` is 2, `$size(ea, 2)` of
    // `e_t ea [5]` is 15), then adjustSize masks and sizes it to the net,
    // location-less, parented at the assignment: the same constant the
    // -elabuhdm view gets from the adjuster and § ndaAdjSizeFoldSized223
    // (cases v11u223repro/cases/S s01-s05, v11u219repro/cases/S s04 s08,
    // whose -elabuhdm views are EQUAL and whose parse views were not).  Ours
    // kept the call wherever § ndaSizeQueryFold216's reach declines, and the
    // downstream plugin evaluated the call to the language's count (4), so
    // those designs synthesized differently (DIVERGENT).  Here ExprEval runs
    // on exactly those calls, as the adjuster runs it (inst = the enclosing
    // instance or generate scope, pexpr = the assignment), and its constant
    // replaces the call, sized as § ndaAdjSizeFoldSized223 sizes it.  Only a
    // net or variable operand (a parameter operand keeps the call in golden,
    // § ndaSizeQueryFold216's n15), only an elaborated listing's assignment
    // (the definition listing keeps it), never an array variable without its
    // element (ExprEval reads that element unguarded; Surelog writes no
    // database there).  Switch R11U228_PVSIZE_OFF.
    if (!(elabUhdm == true) && !synthSubset &&
        slang_uhdm::lawOn(228, "R11U228_PVSIZE_OFF")) {
        std::set<const UHDM::any*> defCas228;
        if (auto* am = design->AllModules())
            for (auto* m228 : *am)
                if (m228 && m228->Cont_assigns())
                    for (auto* c228 : *m228->Cont_assigns())
                        defCas228.insert(c228);
        std::vector<UHDM::cont_assign*> cas228;
        for (auto& kv : serializer.AllObjects())
            if (kv.first && kv.first->UhdmType() == UHDM::uhdmcont_assign)
                cas228.push_back((UHDM::cont_assign*)kv.first);
        std::sort(cas228.begin(), cas228.end(),
                  [](const UHDM::cont_assign* a, const UHDM::cont_assign* b) {
                      return a->UhdmId() < b->UhdmId();
                  });
        // § pvSizeNoElemDeclines228v (v11u228, the adversarial verification
        // of r11u228: the law binary exited rc 139 in the parse view on
        // v11u219repro/cases/S s01_dyn_inner and s01b_queue_inner and
        // v11u223repro/cases/S s09_genfor_dyn and s10_dyn_queue_decline,
        // `$size` of `int mq [3][$]`, `logic [1:0] md [2][]`, where pristine
        // wrote the call and Surelog writes no database) — ExprEval::size
        // reads `array_var->Variables()->at(0)` unguarded, and the law's own
        // guard looked only at the operand's actual, not at the element
        // array_var of a fixed-then-dynamic shape.  As the adjuster's run
        // does (§ unsizedInnerSizeDeclines223 with § sizeDeclineTsInvalid223v),
        // every array_var without an element holds, for these ExprEval runs
        // only, a placeholder chandle_var typed by a chandle_typespec, which
        // ExprEval::size does not size (invalidValue): the call stays, the
        // base's bytes.  The placeholders live outside the serializer and are
        // removed right after.  Switch R11V228_PVSIZEDYN_OFF.
        static UHDM::chandle_var ph228v;
        static UHDM::ref_typespec phRt228v;
        static UHDM::chandle_typespec phTs228v;
        static std::vector<UHDM::variables*> phVec228v{&ph228v};
        std::vector<UHDM::array_var*> noElem228v;
        if (slang_uhdm::fixOn(228, "R11V228_PVSIZEDYN_OFF")) {
            phRt228v.Actual_typespec(&phTs228v);
            ph228v.Typespec(&phRt228v);
            for (auto& kv : serializer.AllObjects())
                if (kv.first && kv.first->UhdmType() == UHDM::uhdmarray_var) {
                    auto* av = (UHDM::array_var*)kv.first;
                    if (!av->Variables()) {
                        noElem228v.push_back(av);
                        av->Variables(&phVec228v);
                    }
                }
        }
        // § pvSizeFwdPkgDimDeclines233v (r11u233, the second adversarial
        // verification of pass 228: case tools/probe/r11u233verify/cases/X
        // x03) — a package holding a reference `Q::n` to a package Q
        // declared LATER in the same file (the forward shape of
        // § fwdPkgRefClassScopeSpan227) leaves that reference unresolved in
        // golden, and every value computed from it with it: an operand
        // whose dimension reads such a package's parameter (`bit [3:0]
        // [p1::S.x:0] c` with `S = '{x: p2::E1}`) cannot be sized by
        // golden's ExprEval, which keeps `$size(c, 2)`; ours binds the
        // reference and sized it (11 records away: the call, its argument,
        // the net).  Such an operand keeps the call, the base's bytes.
        // Switch R11V233_PVSIZEFWD_OFF.
        std::set<std::string> fwdTainted233;
        const bool fwd233 = slang_uhdm::fixOn(233, "R11V233_PVSIZEFWD_OFF");
        bool fwdDone233 = false;
        auto fwdCompute233 = [&]() {
            if (fwdDone233)
                return;
            fwdDone233 = true;
            struct P233 { std::string file; int line = 0, col = 0; };
            std::map<std::string, P233> pk233;
            std::vector<const UHDM::ref_obj*> rf233;
            for (auto& kv : serializer.AllObjects()) {
                auto* o = (const UHDM::BaseClass*)kv.first;
                if (!o)
                    continue;
                if (o->UhdmType() == UHDM::uhdmpackage)
                    pk233.emplace(std::string(o->VpiName()),
                                  P233{std::string(o->VpiFile()), (int)o->VpiLineNo(),
                                       (int)o->VpiColumnNo()});
                else if (o->UhdmType() == UHDM::uhdmref_obj)
                    rf233.push_back((const UHDM::ref_obj*)o);
            }
            for (auto* r : rf233) {
                const std::string n(r->VpiName());
                const size_t k = n.find("::");
                if (k == std::string::npos || k == 0)
                    continue;
                const UHDM::BaseClass* p = r->VpiParent();
                for (int d = 0; p && d < 256 && p->UhdmType() != UHDM::uhdmpackage &&
                                p->UhdmType() != UHDM::uhdmdesign;
                     d++)
                    p = p->VpiParent();
                if (!p || p->UhdmType() != UHDM::uhdmpackage)
                    continue;
                auto qi = pk233.find(n.substr(0, k));
                auto pi = pk233.find(std::string(p->VpiName()));
                if (qi == pk233.end() || pi == pk233.end() || qi == pi ||
                    qi->second.file.empty() || qi->second.file != pi->second.file)
                    continue;
                if (std::make_pair(qi->second.line, qi->second.col) >
                    std::make_pair(pi->second.line, pi->second.col))
                    fwdTainted233.insert(std::string(p->VpiName()));
            }
        };
        // the package prefixes an operand's dimensions read
        std::function<bool(const UHDM::any*, int)> exprFwd233 =
            [&](const UHDM::any* e, int d) -> bool {
            if (!e || d > 32)
                return false;
            switch (e->UhdmType()) {
            case UHDM::uhdmref_obj: {
                const std::string n(((const UHDM::ref_obj*)e)->VpiName());
                const size_t k = n.find("::");
                return k != std::string::npos && fwdTainted233.count(n.substr(0, k));
            }
            case UHDM::uhdmhier_path:
                if (auto* pe = ((const UHDM::hier_path*)e)->Path_elems())
                    for (auto* x : *pe)
                        if (exprFwd233(x, d + 1))
                            return true;
                return false;
            case UHDM::uhdmoperation:
                if (auto* ops = ((const UHDM::operation*)e)->Operands())
                    for (auto* x : *ops)
                        if (exprFwd233(x, d + 1))
                            return true;
                return false;
            case UHDM::uhdmsys_func_call:
            case UHDM::uhdmfunc_call:
                if (auto* as = ((const UHDM::tf_call*)e)->Tf_call_args())
                    for (auto* x : *as)
                        if (exprFwd233(x, d + 1))
                            return true;
                return false;
            case UHDM::uhdmbit_select:
                return exprFwd233(((const UHDM::bit_select*)e)->VpiIndex(), d + 1);
            default:
                return false;
            }
        };
        std::function<bool(const UHDM::any*, int)> tsFwd233 =
            [&](const UHDM::any* ts, int d) -> bool {
            if (!ts || d > 16)
                return false;
            if (ts->UhdmType() == UHDM::uhdmref_typespec)
                ts = ((const UHDM::ref_typespec*)ts)->Actual_typespec();
            if (!ts)
                return false;
            const UHDM::VectorOfrange* rs = nullptr;
            const UHDM::ref_typespec* el = nullptr;
            switch (ts->UhdmType()) {
            case UHDM::uhdmlogic_typespec:
                rs = ((const UHDM::logic_typespec*)ts)->Ranges();
                el = ((const UHDM::logic_typespec*)ts)->Elem_typespec();
                break;
            case UHDM::uhdmbit_typespec:
                rs = ((const UHDM::bit_typespec*)ts)->Ranges();
                break;
            case UHDM::uhdmint_typespec:
                rs = ((const UHDM::int_typespec*)ts)->Ranges();
                break;
            case UHDM::uhdmpacked_array_typespec:
                rs = ((const UHDM::packed_array_typespec*)ts)->Ranges();
                el = ((const UHDM::packed_array_typespec*)ts)->Elem_typespec();
                break;
            case UHDM::uhdmarray_typespec:
                rs = ((const UHDM::array_typespec*)ts)->Ranges();
                el = ((const UHDM::array_typespec*)ts)->Elem_typespec();
                break;
            default:
                break;
            }
            if (rs)
                for (auto* r : *rs)
                    if (r && (exprFwd233(r->Left_expr(), 0) || exprFwd233(r->Right_expr(), 0)))
                        return true;
            return el && tsFwd233(el, d + 1);
        };
        auto operandFwd233 = [&](const UHDM::any* act) -> bool {
            if (!fwd233 || !act)
                return false;
            fwdCompute233();
            if (fwdTainted233.empty())
                return false;
            const UHDM::VectorOfrange* rs = nullptr;
            const UHDM::any* ets = nullptr;
            if (act->UhdmType() == UHDM::uhdmarray_var) {
                auto* av = (const UHDM::array_var*)act;
                rs = av->Ranges();
                if (av->Variables() && !av->Variables()->empty() && (*av->Variables())[0])
                    ets = (*av->Variables())[0]->Typespec();
            }
            else if (act->UhdmType() == UHDM::uhdmarray_net) {
                auto* an = (const UHDM::array_net*)act;
                rs = an->Ranges();
                if (an->Nets() && !an->Nets()->empty() && (*an->Nets())[0])
                    ets = (*an->Nets())[0]->Typespec();
            }
            else if (auto* v = dynamic_cast<const UHDM::variables*>(act))
                ets = v->Typespec();
            else if (auto* n = dynamic_cast<const UHDM::net*>(act))
                ets = n->Typespec();
            if (rs)
                for (auto* r : *rs)
                    if (r && (exprFwd233(r->Left_expr(), 0) || exprFwd233(r->Right_expr(), 0)))
                        return true;
            return tsFwd233(ets, 0);
        };
        auto isDefModule228 = [&](const UHDM::any* o) {
            if (auto* am = design->AllModules())
                for (auto* m228 : *am)
                    if (m228 == o)
                        return true;
            return false;
        };
        for (auto* ca : cas228) {
            if (!ca->VpiNetDeclAssign() || !ca->Rhs() || !ca->Lhs() ||
                defCas228.count(ca) ||
                ca->Rhs()->UhdmType() != UHDM::uhdmsys_func_call ||
                ((const UHDM::sys_func_call*)ca->Rhs())->VpiName() != "$size")
                continue;
            auto* call = (const UHDM::sys_func_call*)ca->Rhs();
            // The enclosing instance or generate scope, and the listing it
            // sits in: the top of its instance chain must be no definition.
            const UHDM::any* inst = ca->VpiParent();
            if (!inst ||
                (inst->UhdmType() != UHDM::uhdmmodule_inst &&
                 inst->UhdmType() != UHDM::uhdminterface_inst &&
                 inst->UhdmType() != UHDM::uhdmgen_scope))
                continue;
            const UHDM::any* topI = inst;
            for (const UHDM::any* q = inst; q && q->UhdmType() != UHDM::uhdmdesign;
                 q = q->VpiParent())
                topI = q;
            if (isDefModule228(topI) || isDefModule228(inst))
                continue;
            auto* args = call->Tf_call_args();
            if (!args || args->empty() || args->size() > 2 || !(*args)[0] ||
                (*args)[0]->UhdmType() != UHDM::uhdmref_obj)
                continue;
            const UHDM::any* act = ((const UHDM::ref_obj*)(*args)[0])->Actual_group();
            if (!act)
                continue;
            switch (act->UhdmType()) {
            case UHDM::uhdmparameter:
            case UHDM::uhdmparam_assign:
            case UHDM::uhdmtype_parameter:
                continue;
            case UHDM::uhdmarray_var:
                if (!((const UHDM::array_var*)act)->Variables() ||
                    ((const UHDM::array_var*)act)->Variables()->empty())
                    continue;
                break;
            default:
                break;
            }
            if (!(dynamic_cast<const UHDM::net*>(act) || dynamic_cast<const UHDM::variables*>(act) ||
                  act->UhdmType() == UHDM::uhdmarray_net))
                continue;
            if (operandFwd233(act)) {
                slang_uhdm::lawTrace(233, "pvSizeFwdPkgDimDeclines233v",
                                  std::string(ca->Lhs()->VpiName()));
                continue;
            }
            const UHDM::any* lhs = ca->Lhs();
            const UHDM::ref_typespec* lrt = nullptr;
            if (lhs->UhdmType() == UHDM::uhdmlogic_net)
                lrt = ((const UHDM::logic_net*)lhs)->Typespec();
            const UHDM::logic_typespec* lts =
                lrt ? lrt->Actual_typespec<UHDM::logic_typespec>() : nullptr;
            if (!lts)
                continue;
            int64_t w = 1;
            bool ok = true;
            if (auto* rs = lts->Ranges())
                for (auto* r : *rs) {
                    auto* l = r ? r->Left_expr<UHDM::constant>() : nullptr;
                    auto* rr = r ? r->Right_expr<UHDM::constant>() : nullptr;
                    if (!l || !rr) {
                        ok = false;
                        break;
                    }
                    UHDM::ExprEval ev;
                    bool inv = false;
                    int64_t lv = ev.get_value(inv, l), rv = ev.get_value(inv, rr);
                    if (inv) {
                        ok = false;
                        break;
                    }
                    w *= (lv > rv ? lv - rv : rv - lv) + 1;
                }
            if (!ok || w <= 0)
                continue;
            bool inv = false;
            UHDM::ExprEval eval(true);
            eval.reduceExceptions({vpiAssignmentPatternOp, vpiMultiAssignmentPatternOp,
                                   vpiConcatOp, vpiMultiConcatOp, vpiBitNegOp});
            if (!noElem228v.empty())
                slang_uhdm::trv228("pvSizeNoElemDeclines228v",
                                   std::string(ca->Lhs()->VpiName()) + " placeholders=" +
                                       std::to_string(noElem228v.size()));
            UHDM::expr* tmp = eval.reduceExpr(call, inv, inst, ca, true);
            if (inv || !tmp || tmp == call || tmp->UhdmType() != UHDM::uhdmconstant)
                continue;
            auto* k = (UHDM::constant*)tmp;
            std::string_view v = k->VpiValue();
            if (v.rfind("UINT:", 0) != 0)
                continue;
            uint64_t uv = strtoull(std::string(v.substr(5)).c_str(), nullptr, 10);
            if (w < 64)
                uv &= (((uint64_t)1 << w) - 1);
            k->VpiValue("UINT:" + std::to_string(uv));
            k->VpiDecompile(std::to_string(uv));
            k->VpiSize((int32_t)w);
            k->VpiConstType(vpiUIntConst);
            k->VpiFile("");
            k->VpiLineNo(0);
            k->VpiColumnNo(0);
            k->VpiEndLineNo(0);
            k->VpiEndColumnNo(0);
            k->VpiParent(ca);
            ca->Rhs(k);
            slang_uhdm::lawTrace(228, "parseViewSizeExprEval228",
                              std::string(ca->Lhs()->VpiName()) + " " +
                                  std::to_string(uv));
        }
        for (auto* av : noElem228v)
            av->Variables(nullptr);
    }

    // § fpLineFiller120 — the post-pass (decode at the event walk above).
    if (fpLines120 && !fpEvents120.empty()) {
        auto& sm120 = driver.sourceManager;
        // Per file: event lines, in offset order.
        std::map<std::string, std::vector<std::pair<uint32_t, bool>>> lines120;
        for (auto id : sm120.getAllBuffers()) {
            auto t = sm120.getSourceText(id);
            if (t.empty())
                continue;
            auto pth = sm120.getFullPath(id).string();
            auto it = fpEvents120.find(pth);
            if (it == fpEvents120.end() || lines120.count(pth))
                continue;
            auto& out = lines120[pth];
            for (auto& e : it->second)
                out.push_back({(uint32_t)sm120.getLineNumber(SourceLocation(id, e.off)),
                               e.resync});
        }
        auto shift120 = [&](const std::vector<std::pair<uint32_t, bool>>& evs,
                            int64_t q) -> int64_t {
            int64_t d = 0;
            for (auto& [ln, rs] : evs) {
                if ((int64_t)ln < q)
                    d = rs ? 0 : d + 1;
                else if ((int64_t)ln == q && rs)
                    d = 0;
                else if ((int64_t)ln > q)
                    break;
            }
            return d;
        };
        auto fileOf120 = [](const UHDM::BaseClass* o) -> std::string {
            for (int g = 0; o && g < 64; o = o->VpiParent(), g++)
                if (!o->VpiFile().empty())
                    return std::string(o->VpiFile());
            return {};
        };
        for (auto& [co, id] : serializer.AllObjects()) {
            (void)id;
            auto* o = const_cast<UHDM::BaseClass*>(co);
            if (!o)
                continue;
            if (o->VpiLineNo() > 0 || o->VpiEndLineNo() > 0) {
                auto it = lines120.find(fileOf120(o));
                if (it != lines120.end()) {
                    if (o->VpiLineNo() > 0)
                        o->VpiLineNo((uint32_t)(o->VpiLineNo() +
                                                shift120(it->second, o->VpiLineNo())));
                    if (o->VpiEndLineNo() > 0)
                        o->VpiEndLineNo((uint32_t)(o->VpiEndLineNo() +
                                                   shift120(it->second, o->VpiEndLineNo())));
                }
            }
            if (auto* in = dynamic_cast<UHDM::instance*>(o))
                if (in->VpiDefLineNo() > 0)
                    if (auto it = lines120.find(std::string(in->VpiDefFile()));
                        it != lines120.end())
                        in->VpiDefLineNo((int32_t)(in->VpiDefLineNo() +
                                                   shift120(it->second, in->VpiDefLineNo())));
            if (auto* tm = dynamic_cast<UHDM::typespec_member*>(o))
                if (auto it = lines120.find(std::string(tm->VpiRefFile()));
                    it != lines120.end()) {
                    if (tm->VpiRefLineNo() > 0)
                        tm->VpiRefLineNo((int32_t)(tm->VpiRefLineNo() +
                                                   shift120(it->second, tm->VpiRefLineNo())));
                    if (tm->VpiRefEndLineNo() > 0)
                        tm->VpiRefEndLineNo((int32_t)(
                            tm->VpiRefEndLineNo() + shift120(it->second, tm->VpiRefEndLineNo())));
                }
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

// § uncaughtExitsReject160 (r11u160, pass-154 sister face S7) — an exception
// that escapes the export (slang's Compilation::parseName throws
// std::runtime_error when Scope::lookupName is handed an escaped identifier
// holding a `#`, `\W#1 `, from ModuleEmit.cpp mintUnitEnumNets) used to abort
// the process (rc 134, SIGABRT, a core and a torn stderr).  Caught here it
// reads as every other rejection: a message and exit 3, no database written
// (the serializer saves last, so nothing partial exists), which the harness
// records as a clean SLANG_REJECT.  Surelog also fails that source (no golden).
// Case tools/probe/r11u160repro/cases/S7.  Switch R11U160_CATCH_OFF (and
// R11U160_OFF): the exception propagates as before.
int main(int argc, char** argv) {
    if (!slang_uhdm::lawOn(160, "R11U160_CATCH_OFF"))
        return realMain(argc, argv);
    try {
        return realMain(argc, argv);
    }
    catch (const std::exception& e) {
        fprintf(stderr, "slang-uhdm: error: %s\n", e.what());
        return 3;
    }
}
