// r11u223: print the restored serializer's symbol table in id order.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
int main(int argc, char** argv) {
  UHDM::Serializer s;
  s.Restore(std::string(argv[1]));
  for (uint32_t i = 1; i < 20000000; i++) {
    auto v = s.GetSymbol(UHDM::SymbolId(i, ""));
    if (v == UHDM::SymbolFactory::getBadSymbol()) break;
    printf("%u %.*s\n", i, (int)v.size(), v.data());
  }
}
