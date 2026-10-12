// r11u290 (pass 290, the two un-parked Surelog rows,
// tools/probe/r11u290repro/README.md): every law reads its own
// R11U290_<LAW>_OFF switch; R11U290_OFF drops all of them,
// restoring the base's bytes.
//   R11U290_PKGTDPACKED_OFF    § pkgTdPackedDimsDefNetShares290 (ModuleEmit.cpp, materializeDefNetTs)
//   R11U290_UNITENUMSHARE_OFF  § caUnitEnumUnresolvedShares290 (ModuleEmit.cpp, emitContAssigns)
//   R11U290_BASEIDXELEM_OFF    § elabCaBaseSelRefIdxAtElem290 (ExprEmit.cpp, the base-select site)
//   R11U290_MISEVALSHARE_OFF   § elabMisevalCompositeShares290 (ExprEmit.cpp, § elabMisevalRefSubst)
//   R11U290_OVCLONECHAIN_OFF   § elabOvMisevalCloneChain290 (ExprEmit.cpp + TypeEmit.cpp drain)
//   R11U290_OVFILE_OFF         § elabOvMisevalRestampFile290 (ParamEmit.cpp)
//   R11U290_SPLICEDECLTS_OFF   § elabMisevalSpliceDeclTs290 (TypeEmit.cpp, § elabVarRangeMisevalSubst)
//   R11U290_SPLICECHAIN_OFF    § elabMisevalSpliceRefChain290 (TypeEmit.cpp; drain called from ParamEmit.cpp)
//   R11U290_CONNBOUNDCHAIN_OFF § elabConnPsBoundRefChain290 (ExprEmit.cpp, the simple part-select; drain in TypeEmit.cpp)
//   R11U290_OVSPLICETOP_OFF    § elabOvSpliceTopCopy290 (TypeEmit.cpp, § elabOvMisevalNoFold's splice arm)
// R11U290_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.290`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>
#include <uhdm/uhdm_forward_decl.h>

namespace slang_uhdm {
inline bool r11u290On(const char* sw) {
    if (getenv("R11U290_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr290(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U290_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".290";
        FILE* fp = fopen(fn.c_str(), "a");
        if (!fp)
            return nullptr;
        std::string cl, prev, outp;
        if (FILE* c = fopen("/proc/self/cmdline", "r")) {
            int ch;
            while ((ch = fgetc(c)) != EOF) {
                if (ch == 0) {
                    if (prev == "-o")
                        outp = cl;
                    prev = cl;
                    cl.clear();
                }
                else
                    cl += (char)ch;
            }
            fclose(c);
        }
        fprintf(fp, "OUT %s\n", outp.c_str());
        return fp;
    }();
    if (tf) {
        fprintf(tf, "%s %s\n", law, detail.c_str());
        fflush(tf);
    }
}
// v11u290 (adversarial verification of r11u290): the verifier's
// refinements read r11v290On; R11V290_OFF drops them all (the law's bytes),
// R11U290_OFF still drops every law and refinement (pristine's bytes).
//   R11V290_SHAREOPND_OFF  § misevalShareOperandOnly290v (ExprEmit.cpp, § elabMisevalCompositeShares290)
//   R11V290_OVSIBOP_OFF    § ovCloneChainSiblingOperand290v (ParamEmit.cpp + ExprEmit.cpp + TypeEmit.cpp drain)
//   R11V290_WRITERKIND_OFF § pkgTdPackedWriterKindOrder290v (ModuleEmit.cpp, materializeDefNetTs)
//   R11V290_SPLICEOPND_OFF § ovSpliceTopOperandStaysHome290v (TypeEmit.cpp, § elabOvSpliceTopCopy290's branch)
//   R11V290_SPLICESW_OFF   § spliceChainSwitchOwnOnly290v (TypeEmit.cpp, drainMisevalSpliceChain290; switch semantics only)
inline bool r11v290On(const char* sw) {
    if (getenv("R11U290_OFF") != nullptr || getenv("R11V290_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// § ovCloneChainSiblingOperand290v — set beside misevalOvRhs290(): true when
// another parameter of the overridden parameter's own body reads it as an
// operand of an operator (through operators only).
inline bool& misevalOvSibOp290v() {
    static bool v = false;
    return v;
}
// § elabOvMisevalCloneChain290 — set while an ELABORATED parameter's Rhs
// is emitted on the § elabOvMisevalNoFold road (the override actual's
// tree, siblings substituted from the PARENT scope), read by
// § elabMisevalRefSubst.
inline bool& misevalOvRhs290() {
    static bool v = false;
    return v;
}
// § elabOvSpliceTopCopy290 — how deep the § elabVarRangeMisevalSubst
// splice is (0: the bound names the parameter itself).
inline int& misevalSpliceDepth290() {
    static int d = 0;
    return d;
}
// Defined in TypeEmit.cpp: register a spliced / cloned tree whose
// references are named design-final from their parent chain (force 0: an
// empty or bare stored name; 1: any stored name, and the ref_typespecs, for
// a clone that copied names; 2: any stored name, references only).
void noteMisevalSplice290(UHDM::any* e, int force = 0);
void noteMisevalCopyNames290(UHDM::any* c, const UHDM::any* src);
} // namespace slang_uhdm
