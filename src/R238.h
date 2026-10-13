// r11u238 (pass 238, the expression/parameter ground,
// tools/probe/r11u238repro/README.md): every law reads its own
// R11U238_<LAW>_OFF switch; R11U238_OFF drops all of them,
// restoring the base's bytes.
// R11U238_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.238`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>
#include <unistd.h>

namespace UHDM {
class ref_obj;
class ref_typespec;
class variables;
}  // namespace UHDM
namespace slang::ast {
class Symbol;
}  // namespace slang::ast

namespace slang_uhdm {
// v11u238 (the adversarial verification, tools/probe/v11u238repro/README.md):
// each refinement reads its own R11V238_<NAME>_OFF; R11V238_OFF drops all of
// them, and R11U238_OFF drops them with the laws they refine.
// § cloneForIncBindsHomeVar238 (StmtEmit ForLoop arm, drained in ParamEmit
// drainPaNameCopySrc38): a for-header loop variable -> the HOME listing's
// emitted object (the last and the first emission outside any import clone),
// and the import clones' loop-variable references waiting for it.
inline std::map<const slang::ast::Symbol*, UHDM::variables*>& homeForVar238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
inline std::map<const slang::ast::Symbol*, UHDM::variables*>&
homeForVarFirst238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
struct CloneForIncRef238 {
    UHDM::ref_obj* ref;
    const slang::ast::Symbol* sym;
    bool classClone;  // an out-of-body class method's clone: the FIRST home
                      // emission (the class listing), else the LAST
};
inline std::vector<CloneForIncRef238>& cloneForIncRefs238() {
    static std::vector<CloneForIncRef238> v;
    return v;
}
// § foreachClassPropStringTsShared238: loop-variable ref_typespecs left to
// pendingLoopVarTs9's mirror; ParamEmit drainShareDefParamTs gives any the
// mirror missed the old fresh string_typespec.
inline std::vector<UHDM::ref_typespec*>& deferredStrTs238() {
    static std::vector<UHDM::ref_typespec*> v;
    return v;
}
}  // namespace slang_uhdm
