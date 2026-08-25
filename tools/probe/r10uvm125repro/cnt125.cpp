// r10uvm125 — WHOLE-DATABASE object-kind counter.  A pass that REMOVES objects
// must score ONE-SIDED SETS, so this prints `KIND<TAB>count` for every UHDM kind
// in the serializer's AllObjects map.  MEASUREMENT ONLY.
//   usage: cnt125 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cnt125 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  std::map<std::string, long> m;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    m[std::string(UhdmName(a->UhdmType()))]++;
    if (a->UhdmType() == uhdmoperation)
      m["operation:op" + std::to_string(((const operation*)a)->VpiOpType())]++;
  }
  for (auto& kv : m) printf("%s\t%ld\n", kv.first.c_str(), kv.second);
  return 0;
}
