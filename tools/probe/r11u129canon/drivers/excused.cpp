// excused: what mode 4 excuses on a pair (golden first): the positions where the raw full names differ
// but fieldDiffers excuses them (the USE-SITE in-copy reading), and the named-root spans it excuses.
// Output: label names_excused spans_excused, and with a 4th argument one line per excused position.
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
  size_t n = std::min(la.recs.size(), lb.recs.size()), en = 0, es = 0;
  for (size_t i = 0; i < n; ++i) {
    const Record &a = la.recs[i], &b = lb.recs[i];
    if (a.rawFull != b.rawFull && !fieldDiffers(a, b, 4, 4, &ctx)) {
      ++en;
      if (argc > 4) std::cout << "NAME\t" << i << '\t' << b.fields[1] << '\t' << a.rawFull << '\t' << b.rawFull << '\t' << b.fields[4] << '\n';
    }
    bool sd = false, sx = true;
    for (int k = 5; k <= 9; ++k)
      if (a.fields[k] != b.fields[k]) { sd = true; if (fieldDiffers(a, b, k, 4, &ctx)) sx = false; }
    if (sd && sx) {
      ++es;
      if (argc > 4) std::cout << "SPAN\t" << i << '\t' << b.fields[1] << '\t' << b.fields[2] << '\t' << a.span() << '\t' << b.span() << '\n';
    }
  }
  std::cout << argv[3] << '\t' << en << '\t' << es << '\n';
  return 0;
}
