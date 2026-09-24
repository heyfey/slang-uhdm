// fnaudit: per-record audit of the in-copy full-name rule of uhdm-strictcmp (compiled WITH the tool's own
// source, so the rule audited is the rule shipped). For every record inside a canonicalised subtree that
// carries a full name, prints: index depth type raw-full chain-full(ComputeFullName replica) record-field
// class, where class = stored (raw != chain: compared whole) | strip (rewritten to <in>tail) | whole-other.
//   fnaudit <db.uhdm> <mode> [filter-substring]
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
namespace {
struct Audit : Lister {
  std::string filt;
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    size_t before = recs.size();
    Lister::enterAny(o, h);
    if (recs.size() == before) return;
    const Record& r = recs.back();
    if (!(canon && canonDepth > 0) || o == rootObj || r.rawFull.empty()) return;
    std::string chain = chainFullName(o);
    const char* cls = r.rawFull != chain ? "stored" : (r.fields[4].rfind("<in>", 0) == 0 ? "strip" : "whole");
    std::string line = std::to_string(before) + "\t" + r.fields[0] + "\t" + r.fields[1] + "\t" + r.rawFull + "\t" +
                       chain + "\t" + r.fields[4] + "\t" + cls;
    if (filt.empty() || line.find(filt) != std::string::npos) std::cout << line << '\n';
  }
};
}  // namespace
int main(int argc, char** argv) {
  UHDM::Serializer s;
  std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
  Audit a;
  a.fullnameMode = std::stoi(argv[2]);
  if (argc > 3) a.filt = argv[3];
  a.listenDesigns(h);
  return 0;
}
