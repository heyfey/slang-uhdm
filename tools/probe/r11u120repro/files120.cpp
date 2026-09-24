// r11u120 files: the distinct VpiFile paths a database's objects carry.
//   files <file.uhdm>
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
#include <string>
int main(int argc, char** argv) {
    UHDM::Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::set<std::string> f;
    for (auto& [o, id] : s.AllObjects())
        if (o && !o->VpiFile().empty()) f.insert(std::string(o->VpiFile()));
    for (auto& x : f) std::cout << x << "\n";
}
