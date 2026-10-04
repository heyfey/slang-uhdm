// (r11u232) ostats <db.uhdm>: the serializer's per-type object counts of one database (every object the file holds,
// reachable or not): the census of § cloneRetNoMintBindsHome232's minted return variables.  Build as cc_objid.sh does.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <iostream>
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  UHDM::Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  for (auto& [k, v] : s.ObjectStats()) if (v) std::cout << k << ' ' << v << '\n';
}
