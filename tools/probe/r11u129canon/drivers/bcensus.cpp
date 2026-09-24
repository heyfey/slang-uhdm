// bcensus: question 2 census. For one database, walk it as uhdm-strictcmp does (mode given) and count, per
// object, the listings whose span/file the record skips (a root reached through a ref_typespec) and the
// listings that compare it. An object with skipped listings and NO compared listing has its own span
// compared nowhere: the (b) rule hides any defect in it. Also counts roots first reached through a
// ref_typespec before any listing from a scope. Output one line:
//   label mode roots_via_ref_listings objects_skipped objects_never_compared(named) (anonymous) first_via_ref(named)
// plus, with a 4th argument, one line per never-compared object: type name file line.
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
#include <map>
namespace {
struct C : Lister {
  std::map<const UHDM::any*, std::pair<size_t, size_t>> seen;  // skipped, compared
  std::map<const UHDM::any*, int> first;                       // 1 = first listing skipped
  size_t skippedListings = 0;
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    size_t n = recs.size();
    Lister::enterAny(o, h);
    if (recs.size() == n || !canonRoot(o)) return;
    bool skipped = recs.back().fields[6] == "-" || recs.back().refRoot;
    auto& e = seen[o];
    if (skipped) { ++e.first; ++skippedListings; } else ++e.second;
    first.emplace(o, skipped ? 1 : 0);
    recs.back() = Record();  // keep memory flat: only the count matters here
  }
};
}  // namespace
int main(int argc, char** argv) {
  UHDM::Serializer s;
  std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
  C c;
  c.fullnameMode = std::stoi(argv[2]);
  c.listenDesigns(h);
  size_t objs = 0, nevN = 0, nevA = 0, firstN = 0;
  for (auto& [o, e] : c.seen) {
    if (!e.first) continue;
    ++objs;
    bool named = !o->VpiName().empty();
    if (!e.second) {
      (named ? nevN : nevA)++;
      if (argc > 4)
        std::cout << "NEVER\t" << UHDM::UhdmName(o->UhdmType()) << '\t' << o->VpiName() << '\t' << o->VpiFile()
                  << '\t' << o->VpiLineNo() << '\n';
    }
    if (named && c.first[o] == 1 && e.second) ++firstN;
  }
  std::cout << argv[3] << '\t' << argv[2] << '\t' << c.skippedListings << '\t' << objs << '\t' << nevN << '\t' << nevA
            << '\t' << firstN << '\n';
  return 0;
}
