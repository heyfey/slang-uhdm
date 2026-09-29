// fieldoff: byte offsets of UHDM BaseClass's span fields (the watchpoint targets of pinwriter.py).
// The standard headers come first, then the UHDM headers with protected/private opened (drivers/ccw.sh).
#include <algorithm>
#include <any>
#include <array>
#include <filesystem>
#include <functional>
#include <iomanip>
#include <map>
#include <memory>
#include <set>
#include <sstream>
#include <string>
#include <string_view>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <variant>
#include <vector>
#define protected public
#define private public
#include <uhdm/uhdm.h>
#undef protected
#undef private
#include <cstddef>
#include <iostream>
int main() {
  UHDM::Serializer s;
  UHDM::constant* c = s.MakeConstant();
  const char* b = reinterpret_cast<const char*>(static_cast<UHDM::BaseClass*>(c));
  std::cout << "base_off " << (reinterpret_cast<const char*>(static_cast<UHDM::BaseClass*>(c)) - reinterpret_cast<const char*>(c)) << '\n';
  std::cout << "vpiLineNo_ " << (reinterpret_cast<const char*>(&c->vpiLineNo_) - b) << '\n';
  std::cout << "vpiEndLineNo_ " << (reinterpret_cast<const char*>(&c->vpiEndLineNo_) - b) << '\n';
  std::cout << "vpiColumnNo_ " << (reinterpret_cast<const char*>(&c->vpiColumnNo_) - b) << '\n';
  std::cout << "vpiEndColumnNo_ " << (reinterpret_cast<const char*>(&c->vpiEndColumnNo_) - b) << '\n';
  std::cout << "vpiParent_ " << (reinterpret_cast<const char*>(&c->vpiParent_) - b) << '\n';
  std::cout << "constant_vpiSize_ " << (reinterpret_cast<const char*>(&c->vpiSize_) - b) << '\n';
}
