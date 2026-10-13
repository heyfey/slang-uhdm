// r11u286 (pass 286, the expression/parameter ground,
// tools/probe/r11u286repro/README.md): every law reads its own
// R11U286_<LAW>_OFF switch; R11U286_OFF drops all of them,
// restoring the base's bytes.
// R11U286_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.286`, its first line `OUT <-o path>`, then
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
#include <map>
#include <utility>
#include <uhdm/uhdm.h>

namespace slang_uhdm {
// The verifier's refinements (v11u286): R11V286_<X>_OFF each; R11U286_OFF
// drops them with the laws.
// § elabCastKeyBindsDefNet286: the definition listing's minted cast-pattern
// key wires, by (definition name, key name).
inline std::map<std::pair<std::string, std::string>, UHDM::logic_net*>& castKeyDefNets286() {
    static std::map<std::pair<std::string, std::string>, UHDM::logic_net*> m;
    return m;
}
// The wires an elaborated instance minted under the definition's name, not
// yet adopted by the definition listing.
inline std::set<UHDM::logic_net*>& castKeyAdopt286() {
    static std::set<UHDM::logic_net*> v;
    return v;
}
}  // namespace slang_uhdm
