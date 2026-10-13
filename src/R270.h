// r11u270 (pass 270, the expression/parameter ground,
// tools/probe/r11u270repro/README.md): every law reads its own
// R11U270_<LAW>_OFF switch; R11U270_OFF drops all of them,
// restoring the base's bytes.
// R11U270_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.270`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace UHDM {
class ref_typespec;
class BaseClass;
}
namespace slang::ast {
class Symbol;
class Expression;
}

namespace slang_uhdm {
// (r11u272: the r11v270On helper pre-written here for a verifier that wrote
// no fix was never called; removed, v11u270repro README's finding.)
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
}  // namespace slang_uhdm

namespace slang_uhdm {
// § insideSetParamFoldKeepsPa270 — the design-final half (defined in
// ExprEmit.cpp, called from ParamEmit's drainPaNameCopySrc38).
void insideSetParamPaDrain270();
// § insideSetParamFoldKeepsPa270 — the case-inside item record (StmtEmit).
void insidePaRecordCase270(const slang::ast::Expression& member, UHDM::BaseClass* e,
                           const UHDM::BaseClass* op);
// § enumAliasCastBindsImportCopy270 — the casts ExprEmit recorded (read by
// ParamEmit's drainPaNameCopySrc38).
size_t enumAliasCastN270();
void enumAliasCastRec270(size_t i, UHDM::ref_typespec*& rt,
                         const slang::ast::Symbol*& sym);

}  // namespace slang_uhdm
