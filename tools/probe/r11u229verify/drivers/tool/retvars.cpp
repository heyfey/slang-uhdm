// r11u229: retvars <db>: the return variables of a UHDM database.  Counts every function's Return() object, and every
// VARIABLE object parented at a function and named like it that no function's Return() points to (an unreferenced
// return variable: pass 224 section 7's "minted clone return variables", which neither the strict walk nor uhdm-dump
// reaches), and every variable parented at a function that is neither a Return() nor in any vpiVariables listing.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <set>
#include <string>
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  UHDM::Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  std::set<const UHDM::BaseClass*> rets; size_t nf = 0;
  for (auto& kv : s.AllObjects()) {
    auto* o = kv.first; if (!o || o->UhdmType() != UHDM::uhdmfunction) continue;
    nf++; if (auto* r = ((const UHDM::function*)o)->Return()) rets.insert(r);
  }
  std::set<const UHDM::BaseClass*> listed;
  for (auto& kv : s.AllObjects()) {
    auto* o = kv.first; if (!o) continue;
    if (auto* vv = std::get<2>(o->GetByVpiType(vpiVariables))) for (auto* e : *vv) listed.insert(e);
  }
  size_t unref = 0, orphan = 0;
  for (auto& kv : s.AllObjects()) {
    auto* o = kv.first; if (!o) continue;
    auto* p = o->VpiParent();
    if (!p || p->UhdmType() != UHDM::uhdmfunction) continue;
    std::string t = UHDM::UhdmName(o->UhdmType());
    if (t.size() < 4 || t.compare(t.size() - 4, 4, "_var") != 0) continue;
    if (!rets.count(o) && !listed.count(o)) orphan++;
  }
  for (auto& kv : s.AllObjects()) {
    auto* o = kv.first; if (!o) continue;
    auto* p = o->VpiParent();
    if (!p || p->UhdmType() != UHDM::uhdmfunction || o->VpiName() != p->VpiName()) continue;
    std::string t = UHDM::UhdmName(o->UhdmType());
    if (t.size() < 4 || t.compare(t.size() - 4, 4, "_var") != 0) continue;
    if (!rets.count(o)) unref++;
  }
  printf("functions=%zu returns=%zu unreferenced_return_like_vars=%zu function_parented_vars_neither_return_nor_listed=%zu\n", nf, rets.size(), unref, orphan);
}
