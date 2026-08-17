// r10uvm82 VERIFIER census — INDEPENDENT of ct82imp: uses UHDM's own
// UhdmListener auto-walk (not a hand-rolled BFS) and keys each parameter /
// type_parameter by the KIND of the scope whose listing holds it, taken from
// the LISTENER CALLSTACK, not from vpiParent (which this very pass rewrites).
// MEASUREMENT-ONLY.
// build: g++ -O2 -std=c++17 v82cen.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o v82cen
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;

class Cen : public UhdmListener {
public:
  std::map<std::string,int> tally;   // "<scopekind>|<imported>" -> n
  std::map<std::string,int> tallyTp; // same, for type_parameter
  // nearest enclosing scope kind on the callstack
  std::string scopeKind() const {
    for (auto it = callstack.crbegin(); it != callstack.crend(); ++it) {
      switch ((*it)->UhdmType()) {
        case uhdmclass_defn:   return "class_defn";
        case uhdmpackage:      return "package";
        case uhdmmodule_inst:  return "module_inst";
        case uhdminterface_inst:return "interface_inst";
        case uhdmprogram:      return "program";
        default: break;
      }
    }
    return "<none>";
  }
  void enterParameter(const parameter* const o) override {
    std::string i(o->VpiImported());
    tally[scopeKind() + "|" + (i.empty() ? std::string("<EMPTY>") : i)]++;
  }
  void enterType_parameter(const type_parameter* const o) override {
    std::string i(o->VpiImported());
    tallyTp[scopeKind() + "|" + (i.empty() ? std::string("<EMPTY>") : i)]++;
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: v82cen <file.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 2; }
  const design* d = nullptr;
  for (auto h : restored) {
    const uhdm_handle* uh = (const uhdm_handle*)h;
    const BaseClass* o = (const BaseClass*)uh->object;
    if (o->UhdmType() == uhdmdesign) d = (const design*)o;
  }
  if (!d) { fprintf(stderr, "NO_DESIGN\n"); return 2; }
  Cen c;
  c.listenAny(d);
  for (auto& [k,v] : c.tally)   printf("PAR\t%s\t%d\n", k.c_str(), v);
  for (auto& [k,v] : c.tallyTp) printf("TPAR\t%s\t%d\n", k.c_str(), v);
  return 0;
}
