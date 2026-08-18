// r10v64 — WHOLE-DESIGN constant census keyed on SPAN (file:line:col-end) with
// a COMPARE-VISIBLE payload, as a MULTISET.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr,"EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    const constant* c = any_cast<const constant*>(obj);
    if (!c) continue;
    std::string f(c->VpiFile());
    size_t sl = f.find_last_of('/');
    if (sl != std::string::npos) f = f.substr(sl + 1);
    const ref_typespec* rt = c->Typespec();
    int tsk = 0;
    if (rt) tsk = rt->Actual_typespec() ? (int)rt->Actual_typespec()->UhdmType() : -1;
    printf("%s:%u:%u-%u:%u|ct=%d|sz=%d|v=%s|d=%s|ts=%d\n", f.c_str(),
           c->VpiLineNo(), c->VpiColumnNo(), c->VpiEndLineNo(), c->VpiEndColumnNo(),
           c->VpiConstType(), c->VpiSize(), std::string(c->VpiValue()).c_str(),
           std::string(c->VpiDecompile()).c_str(), tsk);
  }
  return 0;
}
