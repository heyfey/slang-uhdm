// residue: question 3. On a pair (golden first) that mode 4 reads STRICT_NOTEQUAL, class every differing
// (position, field) and print one line: label total_diff_objects then class=count for each class seen.
//   FN-OUT       full name, object not inside a canonicalised subtree (compared whole): content
//   FN-TAIL      full name inside a copy, the tails (owner and below) differ: content (a truncated or
//                wrongly parented name) unless the tail itself is use-site dependent
//   FN-STABLE    tails agree, golden gives this object of ours one name at every listing: content
//   FN-FOREIGN   tails agree, golden gives it several names, none is ours's: identity + a naming defect
//   SP-ROOT-STABLE / SP-ROOT-FOREIGN   span of a named root reached through a ref_typespec, same test
//   SP-COPY-USESITE  span of an object inside a copy (not its root), golden gives this object of ours
//                (type, name, span) several spans and ours's is one of them: a copy located at its use
//   SP-COPY-STABLE   the same with one golden span, or ours's not among them: content
//   SP-ROOTDECL-USESITE / -STABLE   span of a named root NOT reached through a ref_typespec (a declaration
//                listing, or a root reached another way), with the (b) test: an extension candidate
//   SP-OUT       span outside any copy; OTHER name/defname/decompile/size/value/consttype; STRUCT walk shape
// With a 4th argument, prints every differing position: index class type golden ours.
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
#include <map>
int main(int argc, char** argv) {
  UHDM::Serializer sa, sb;
  std::vector<vpiHandle> ha = sa.Restore(std::string(argv[1])), hb = sb.Restore(std::string(argv[2]));
  Lister la, lb;
  la.listenDesigns(ha);
  lb.listenDesigns(hb);
  if (la.overflow || lb.overflow) { std::cout << argv[3] << "\toverflow\n"; return 0; }
  PairCtx ctx(la.recs, lb.recs);
  // spans of in-copy objects: golden spans per ours (type, name, span)
  std::map<std::string, std::set<std::string>> cs;
  size_t n = std::min(la.recs.size(), lb.recs.size());
  for (size_t i = 0; i < n; ++i)
    if (lb.recs[i].inCopy)
      cs[lb.recs[i].fields[1] + "|" + lb.recs[i].fields[2] + "|" + lb.recs[i].span()].insert(la.recs[i].span());
  std::map<std::string, size_t> cls;
  size_t objs = 0;
  bool verbose = argc > 4;
  for (size_t i = 0; i < n; ++i) {
    const Record &a = la.recs[i], &b = lb.recs[i];
    std::set<std::string> here;
    for (int k = 0; k < 14; ++k) {
      if (!fieldDiffers(a, b, k, 4, &ctx)) continue;
      std::string c;
      if (k <= 1) c = "STRUCT";
      else if (k == 4) {
        if (!b.inCopy) c = "FN-OUT";
        else if (a.fields[4] != b.fields[4]) c = "FN-TAIL";
        else {
          auto it = ctx.names.find(b.fields[1] + "|" + b.rawFull);
          c = (it == ctx.names.end() || it->second.size() < 2) ? "FN-STABLE" : "FN-FOREIGN";
        }
      } else if (k >= 5 && k <= 9) {
        if (a.refRoot && b.refRoot) {
          auto it = ctx.spans.find(b.fields[1] + "|" + b.fields[2] + "|" + b.span());
          c = (it == ctx.spans.end() || it->second.size() < 2) ? "SP-ROOT-STABLE" : "SP-ROOT-FOREIGN";
        } else if (b.inCopy) {
          auto it = cs.find(b.fields[1] + "|" + b.fields[2] + "|" + b.span());
          c = (it != cs.end() && it->second.size() >= 2 && it->second.count(b.span())) ? "SP-COPY-USESITE" : "SP-COPY-STABLE";
        } else if (b.root) {
          auto it = ctx.spans.find(b.fields[1] + "|" + b.fields[2] + "|" + b.span());
          c = (it != ctx.spans.end() && it->second.size() >= 2 && it->second.count(b.span())) ? "SP-ROOTDECL-USESITE"
                                                                                                  : "SP-ROOTDECL-STABLE";
        } else c = "SP-OUT";
      } else c = "OTHER";
      here.insert(c);
      if (verbose) std::cout << i << '\t' << c << '\t' << kFields[k] << '\t' << b.fields[1] << '\t'
                             << (k == 4 ? a.rawFull : a.fields[k]) << '\t' << (k == 4 ? b.rawFull : b.fields[k]) << '\n';
    }
    if (here.empty()) continue;
    ++objs;
    for (auto& c : here) ++cls[c];
    if (here.count("STRUCT")) break;
  }
  if (la.recs.size() != lb.recs.size()) ++cls["STRUCT"];
  std::cout << argv[3] << '\t' << objs;
  for (auto& [c, v] : cls) std::cout << '\t' << c << '=' << v;
  std::cout << '\n';
  return 0;
}
