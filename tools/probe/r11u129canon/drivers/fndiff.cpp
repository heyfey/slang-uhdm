// fndiff: every full-name difference mode 4 reads on a pair (golden first), with the USE-SITE evidence:
//   index type golden-raw ours-raw golden-canon ours-canon |golden names for ours's object| ours-in-set class
// class: TAIL (the in-copy tails differ, or one side is not in a copy) | STABLE (golden gives one name) |
//        FOREIGN (golden gives several, none is ours's). A summary line counts each class.
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
int main(int argc, char** argv) {
  UHDM::Serializer sa, sb;
  std::vector<vpiHandle> ha = sa.Restore(std::string(argv[1])), hb = sb.Restore(std::string(argv[2]));
  Lister la, lb;
  la.listenDesigns(ha);
  lb.listenDesigns(hb);
  PairCtx ctx(la.recs, lb.recs);
  size_t n = std::min(la.recs.size(), lb.recs.size()), c[3] = {0, 0, 0};
  bool verbose = argc > 4;
  for (size_t i = 0; i < n; ++i) {
    const Record &a = la.recs[i], &b = lb.recs[i];
    if (!fieldDiffers(a, b, 4, 4, &ctx)) continue;
    auto it = ctx.names.find(b.fields[1] + "|" + b.rawFull);
    size_t g = it == ctx.names.end() ? 0 : it->second.size();
    bool in = g && it->second.count(b.rawFull);
    int cls = a.fields[4] != b.fields[4] ? 0 : (g < 2 ? 1 : 2);
    ++c[cls];
    static const char* nm[] = {"TAIL", "STABLE", "FOREIGN"};
    if (verbose)
      std::cout << i << '\t' << b.fields[1] << '\t' << a.rawFull << '\t' << b.rawFull << '\t' << a.fields[4] << '\t'
                << b.fields[4] << '\t' << g << '\t' << in << '\t' << nm[cls] << '\n';
  }
  std::cout << argv[3] << "\tTAIL=" << c[0] << "\tSTABLE=" << c[1] << "\tFOREIGN=" << c[2] << '\n';
  return 0;
}
