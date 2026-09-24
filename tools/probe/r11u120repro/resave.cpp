// r11u120 resave: Restore a UHDM database and Save it again, unchanged.  The
// round trip keeps every object, field and per-type order, but re-registers the
// symbol table in the order the restored objects are visited — a probe of
// whether a downstream ORDER difference follows the objects or only the heap.
//   resave <in.uhdm> <out.uhdm>
#include <uhdm/uhdm.h>
#include <filesystem>
int main(int argc, char** argv) {
    UHDM::Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    s.Save(std::filesystem::path(argv[2]));
    return 0;
}
