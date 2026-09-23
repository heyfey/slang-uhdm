// r11u107 -- PATH FINDER (measurement only; uhdm-cmp is the judge).
// Restores a .uhdm and prints the listener call stack (kind name span) at the
// FIRST visit of every object whose UhdmId is listed (ids as uhdm-cmp prints
// them for that same file).
// build: g++ -O2 -std=c++17 path107.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o path107
// usage: path107 <file.uhdm> <id> [id...]
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
using namespace UHDM;
static std::string desc(const any* o) {
  char b[512];
  snprintf(b, sizeof b, "%s(%s) id:%u %u:%u-%u:%u", UhdmName(o->UhdmType()).data(),
           std::string(o->VpiName()).c_str(), o->UhdmId(), o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
  return b;
}
struct L : public UhdmListener {
  std::set<uint32_t> ids;
  void enterAny(const any* const o) override {
    if (!ids.count(o->UhdmId())) return;
    printf("== %s\n", desc(o).c_str());
    for (auto* c : getCallstack()) printf("   < %s\n", desc(c).c_str());
  }
};
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::string(argv[1]));
  L l;
  for (int i = 2; i < argc; i++) l.ids.insert(atoi(argv[i]));
  for (auto h : hs) l.listenAny((const any*)((uhdm_handle*)h)->object);
  return 0;
}
