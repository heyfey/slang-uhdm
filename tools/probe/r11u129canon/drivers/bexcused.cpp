// bexcused: how often the mode-4 (b) rule fires on a pair (golden first). Counts the aligned positions
// where both records are a named root reached through a ref_typespec, their spans differ, and whether
// spanExcused excuses the difference. Output: label refroot_positions span_differs excused not_excused
// plus, with a 4th argument, every excused / unexcused pair of spans.
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
int main(int argc, char** argv) {
  UHDM::Serializer sa, sb;
  std::vector<vpiHandle> ha = sa.Restore(std::string(argv[1])), hb = sb.Restore(std::string(argv[2]));
  Lister la, lb;
  la.listenDesigns(ha);
  lb.listenDesigns(hb);
  size_t n = std::min(la.recs.size(), lb.recs.size()), rr = 0, dif = 0, exc = 0;
  PairCtx ctx(la.recs, lb.recs);
  for (size_t i = 0; i < n; ++i) {
    const Record &a = la.recs[i], &b = lb.recs[i];
    if (!(a.refRoot && b.refRoot)) continue;
    ++rr;
    if (a.span() == b.span()) continue;
    ++dif;
    bool e = true;
    for (int k = 5; k <= 9; ++k) if (fieldDiffers(a, b, k, 4, &ctx)) e = false;
    exc += e;
    if (argc > 4)
      std::cout << (e ? "EXCUSED\t" : "KEPT\t") << i << '\t' << a.fields[1] << '\t' << a.fields[2] << '\t' << a.span()
                << '\t' << b.span() << '\n';
  }
  std::cout << argv[3] << '\t' << rr << '\t' << dif << '\t' << exc << '\t' << dif - exc << '\n';
  return 0;
}
