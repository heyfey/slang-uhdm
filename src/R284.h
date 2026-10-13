// r11u284 (pass 284, the expression/parameter ground,
// tools/probe/r11u284repro/README.md): every law reads its own
// R11U284_<LAW>_OFF switch; R11U284_OFF drops all of them,
// restoring the base's bytes.
// R11U284_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.284`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <string_view>
#include <vector>
#include <set>
#include <uhdm/uhdm.h>

namespace slang_uhdm {
// The verifier's refinements (v11u284, tools/probe/v11u284repro/README.md):
// R11V284_<X>_OFF each, R11V284_OFF all; R11U284_OFF still drops everything.
}  // namespace slang_uhdm

// ExprEmit's design-final drain of the generate-scope fold names, called at
// the end of ParamEmit's drainShareDefParamTs (after pass 280's).
namespace UHDM { class Serializer; }
namespace slang_uhdm {
void foldTsNameFinalDrain282(UHDM::Serializer& s);
}  // namespace slang_uhdm

namespace slang_uhdm {
// § pkgAliasTdRefNameByParent284: the package alias-of-typedef listing
// objects' Typedef_alias references (ParamEmit emitPackage), with the alias
// symbol and the package name, named design-final in drainShareDefParamTs.
struct PkgAliasRec284 {
    UHDM::ref_typespec* ref = nullptr;
    const void* alias = nullptr; // const slang::ast::TypeAliasType*
    std::string pkg;
};
inline std::vector<PkgAliasRec284>& pkgAliasRecs284() {
    static std::vector<PkgAliasRec284> v;
    return v;
}
// § pkgTdNamedDimsElemByChain284: FACE 3's listing objects (L, built by
// buildTdOfNamedDims111), whose Elem reference is named by its final chain.
inline std::vector<UHDM::logic_typespec*>& namedDimsListings284() {
    static std::vector<UHDM::logic_typespec*> v;
    return v;
}
// § f3ParamCopyDeep284: every FACE 3 listing object L built (a set, read by
// makeParamTs's elaborated-parameter copy).
inline std::set<const UHDM::typespec*>& namedDimsSet284() {
    static std::set<const UHDM::typespec*> v;
    return v;
}
// § hpSelPortConnFoldChain284: the references of package-parameter folds
// named after a hier_path select (ExprEmit), named design-final when their
// chain runs through a port.
inline std::vector<const UHDM::ref_typespec*>& hpSelFoldRefs284() {
    static std::vector<const UHDM::ref_typespec*> v;
    return v;
}
// UHDM's BaseClass::ComputeFullName (protected there): the name the
// VpiFullName getter gives an object that stores none, from its parent chain.
inline std::string chainFullName284(const UHDM::BaseClass* self) {
    std::vector<std::string_view> names;
    const UHDM::BaseClass* parent = self;
    const UHDM::BaseClass* child = nullptr;
    bool column = false;
    while (parent) {
        const UHDM::BaseClass* ap = parent->VpiParent();
        auto pt = parent->UhdmType();
        auto apt = ap ? ap->UhdmType() : UHDM::uhdmunsupported_stmt;
        if (pt == UHDM::uhdmdesign)
            break;
        if (pt == UHDM::uhdmpackage || pt == UHDM::uhdmclass_defn)
            column = true;
        std::string_view name = parent->VpiName().empty() ? parent->VpiDefName() : parent->VpiName();
        bool skip = apt == UHDM::uhdmref_obj || pt == UHDM::uhdmmethod_func_call ||
                    pt == UHDM::uhdmmethod_task_call || pt == UHDM::uhdmfunc_call ||
                    pt == UHDM::uhdmtask_call || pt == UHDM::uhdmsys_func_call ||
                    pt == UHDM::uhdmsys_task_call;
        if (child) {
            auto ct = child->UhdmType();
            if ((ct == UHDM::uhdmbit_select && pt == UHDM::uhdmport) ||
                (ct == UHDM::uhdmref_obj &&
                 (pt == UHDM::uhdmbit_select || pt == UHDM::uhdmindexed_part_select ||
                  pt == UHDM::uhdmhier_path)))
                skip = true;
        }
        if (!name.empty() && !skip)
            names.push_back(name);
        child = parent;
        parent = parent->VpiParent();
    }
    std::string f;
    for (int i = (int)names.size() - 1; i >= 0; --i) {
        f += names[i];
        if (i)
            f += column ? "::" : ".";
    }
    return f;
}
} // namespace slang_uhdm
