// (r11u250) pcw <db.uhdm> <name>: for every int_typespec whose Cast_to_expr is a ref_obj named <name> (the
// paren-cast width mark), print the reference, its actual and the listing that holds the actual, then which
// parameter (or expression) uses each such typespec. Fail-closed on $FENCED: a path holding a fenced name is
// refused. Build: drivers/cc_x.sh's flags with this file (see README).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <string>
#include <iostream>
#include <map>
#include <cstdlib>
#include <cctype>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  const char* fe = getenv("FENCED");
  if (!fe || !*fe) { std::cerr << "pcw: FENCED unset\n"; return 2; }
  {
    std::string f(fe), path(argv[1]), w;
    int nw = 0;
    for (size_t i = 0; i <= f.size(); i++) {
      if (i == f.size() || f[i] == ' ') {
        if (!w.empty()) {
          nw++;
          for (size_t k = path.find(w); k != std::string::npos; k = path.find(w, k + 1)) {
            bool lb = k == 0 || !(isalnum((unsigned char)path[k - 1]) || path[k - 1] == '_');
            size_t e = k + w.size();
            bool rb = e >= path.size() || !(isalnum((unsigned char)path[e]) || path[e] == '_');
            if (lb && rb) { std::cerr << "pcw: fenced path refused\n"; return 2; }
          }
        }
        w.clear();
      } else w += f[i];
    }
    if (nw != 4) { std::cerr << "pcw: FENCED not 4 names\n"; return 2; }
  }
  Serializer s;
  std::vector<vpiHandle> hs = s.Restore(std::string(argv[1]));
  std::vector<const design*> designs;
  for (auto h : hs) designs.push_back((const design*)((const uhdm_handle*)h)->object);
  std::string nm = argv[2];
  std::map<const any*, std::string> listed;
  for (auto* d : designs) {
    auto scan = [&](const VectorOfpackage* v, const char* tag) {
      if (!v) return;
      for (auto* p : *v) if (p->Parameters()) for (auto* q : *p->Parameters())
        listed[q] += std::string(tag) + ":" + std::string(p->VpiName()) + " ";
    };
    scan(d->AllPackages(), "all");
    scan(d->TopPackages(), "top");
  }
  for (auto& kv : s.AllObjects()) {
    const any* o = (const any*)kv.first;
    if (!o || o->UhdmType() != uhdmint_typespec) continue;
    auto* it = (const int_typespec*)o;
    auto* ce = it->Cast_to_expr();
    if (!ce || ce->UhdmType() != uhdmref_obj) continue;
    auto* r = (const ref_obj*)ce;
    if (r->VpiName() != nm) continue;
    const any* a = r->Actual_group();
    std::cout << "ts#" << o->UhdmId() << " L" << o->VpiLineNo() << " ref#" << r->UhdmId() << " refFull='" << r->VpiName() << "' -> ";
    if (!a) { std::cout << "null\n"; continue; }
    std::cout << UhdmName(a->UhdmType()) << "#" << a->UhdmId() << " '" << a->VpiName() << "' parent=" << (a->VpiParent() ? std::string(a->VpiParent()->VpiName()) : "-") << " listed=[" << listed[a] << "]";
    // owner of the typespec: walk refs to it
    std::cout << "\n";
  }
  // which ref_typespecs point at each such int_typespec
  for (auto& kv : s.AllObjects()) {
    const any* o = (const any*)kv.first;
    if (!o || o->UhdmType() != uhdmref_typespec) continue;
    auto* rt = (const ref_typespec*)o;
    auto* at = rt->Actual_typespec();
    if (!at || at->UhdmType() != uhdmint_typespec) continue;
    auto* ce = ((const int_typespec*)at)->Cast_to_expr();
    if (!ce || ce->UhdmType() != uhdmref_obj || ((const ref_obj*)ce)->VpiName() != nm) continue;
    const any* p = rt->VpiParent();
    std::cout << "  user ts#" << at->UhdmId() << " <- " << (p ? UhdmName(p->UhdmType()) : "-") << " '" << (p ? std::string(p->VpiName()) : "") << "' #" << (p ? p->UhdmId() : 0) << " gp=" << (p && p->VpiParent() ? std::string(p->VpiParent()->VpiName()) : "-") << " listed=[" << listed[p] << "]\n";
  }
}
