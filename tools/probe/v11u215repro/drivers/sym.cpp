#include <uhdm/Serializer.h>
#include <uhdm/SymbolId.h>
#include <cstdio>
int main(int argc, char** argv) {
  UHDM::Serializer s;
  s.Restore(std::string(argv[1]));
  int bad = 0;
  for (uint32_t i = 0; bad < 50; ++i) {
    auto v = s.GetSymbol(UHDM::SymbolId(i, ""));
    if (v == UHDM::SymbolFactory::getBadSymbol()) { bad++; continue; }
    bad = 0;
    printf("%u\t%.*s\n", i, (int)v.size(), v.data());
  }
}
