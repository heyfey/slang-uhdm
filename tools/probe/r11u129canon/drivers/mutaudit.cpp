// mutaudit: adversarial soundness test of the in-copy full-name rule (r11u129 question 1), compiled WITH
// uhdm-strictcmp's own source so the rule tested is the rule shipped.
//
//   mutaudit <a.uhdm> <b.uhdm> <side A|B> <objects K> <label>
//
// The pair must be STRICT_EQUAL under mode 3. On the chosen side, up to K objects inside a canonicalised
// subtree (not a root reached through a ref_typespec) that carry a full name are sampled evenly; each gets
// every mutation below, applied to a FRESH restore of that side's database before any full name is read:
//   S-last / S-mid / S-top : the stored full name with its last / next-to-last / first name suffixed "Q"
//   P-par                  : VpiParent re-pointed to another object of the parent's type and name (a
//                            parenting defect; the full name then synthesised from the new chain)
// and is compared (all three modes 2, 3, 4) against the other side's records. Output, one line per mutation:
//   label base(m2m3m4 unmutated differs) side idx type kind class old new caught2 caught3 caught4
// class: tail = the mutated name lies on the chain from the object up to its nearest named typespec
// (content: every mode that claims soundness must catch it); above = the mutation lies wholly above that
// owner (identity by construction); untailed = the full name does not end with its chain (compared whole
// by mode 4); invisible = the full name did not change (P-par on a stored name; not counted).
#define main strictcmp_main
#include "../../../uhdm-strictcmp/uhdm-strictcmp.cpp"
#undef main
#include <map>
#include <regex>

namespace {
struct Rec : Lister {
  std::vector<const UHDM::any*> objs;
  std::vector<bool> cand;
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    size_t n = recs.size();
    Lister::enterAny(o, h);
    if (recs.size() == n) return;
    objs.push_back(o);
    bool inC = canon && canonDepth > 0;
    bool isRoot = o == rootObj;
    cand.push_back(inC && !isRoot && !recs.back().rawFull.empty());
  }
};
struct Raw : UHDM::VpiListener {
  std::vector<const UHDM::any*> objs;
  void enterAny(const UHDM::any* o, vpiHandle) override { objs.push_back(o); }
};
bool setFull(UHDM::any* o, const std::string& v) {
#define TRY(T) if (auto* x = dynamic_cast<UHDM::T*>(o)) { x->VpiFullName(v); return true; }
  TRY(ref_typespec) TRY(ref_obj) TRY(parameter) TRY(type_parameter) TRY(variables) TRY(nets)
  TRY(hier_path) TRY(scope) TRY(named_event) TRY(constraint) TRY(gen_var) TRY(property_decl)
  TRY(sequence_decl) TRY(primitive) TRY(concurrent_assertions) TRY(instance_array) TRY(gen_scope_array)
#undef TRY
  return false;
}
struct Listed { std::vector<Record> recs; };
Listed listRecs(std::vector<vpiHandle>& h, int mode) {
  Lister l;
  l.fullnameMode = mode;
  l.listenDesigns(h);
  return {std::move(l.recs)};
}
// golden first, as uhdm-strictcmp reads a pair
bool differs(const Listed& gold, const Listed& ours, int mode) {
  if (gold.recs.size() != ours.recs.size()) return true;
  PairCtx ctx(gold.recs, ours.recs);
  for (size_t i = 0; i < gold.recs.size(); ++i)
    for (int k = 0; k < 14; ++k)
      if (fieldDiffers(gold.recs[i], ours.recs[i], k, mode, &ctx)) return true;
  return false;
}
// token spans of a full name (names between '.' and '::' separators)
std::vector<std::pair<size_t, size_t>> tokens(const std::string& s) {
  std::vector<std::pair<size_t, size_t>> t;
  size_t b = 0;
  for (size_t i = 0; i <= s.size(); ++i) {
    bool sep = i == s.size() || s[i] == '.' || (s[i] == ':' && i + 1 < s.size() && s[i + 1] == ':');
    if (!sep) continue;
    if (i > b) t.push_back({b, i});
    if (i < s.size() && s[i] == ':') ++i;
    b = i + 1;
  }
  return t;
}
// the tail rule's suffix length inside full (0 = full does not end with the tail)
size_t tailLen(const UHDM::any* o, const std::string& full) {
  std::vector<std::string_view> names;
  const UHDM::any* child = nullptr;
  const UHDM::any* owner = nullptr;
  const UHDM::any* far = nullptr;
  size_t farCut = 0;
  for (const UHDM::any* a = o; a; child = a, a = a->VpiParent()) {
    if (a->UhdmType() == UHDM::uhdmdesign) break;
    std::string_view nm = Lister::chainName(a, child);
    if (!nm.empty()) names.push_back(nm);
    if (a != o && canonRoot(a)) {
      if (!a->VpiName().empty()) { owner = a; break; }
      far = a; farCut = names.size();
    }
  }
  if (!owner) { if (!far) return 0; names.resize(farCut); }
  std::string dot, col;
  for (auto it = names.rbegin(); it != names.rend(); ++it) {
    if (!dot.empty()) { dot += '.'; col += "::"; }
    dot += *it; col += *it;
  }
  if (Lister::endsAt(full, dot)) return dot.size();
  if (Lister::endsAt(full, col)) return col.size();
  return 0;
}
}  // namespace

int main(int argc, char** argv) {
  if (argc != 6) { std::cerr << "usage\n"; return 3; }
  std::string fa = argv[1], fb = argv[2], side = argv[3], label = argv[5];
  size_t K = std::stoul(argv[4]);
  std::string mine = side == "A" ? fa : fb, other = side == "A" ? fb : fa;
  UHDM::Serializer so;
  std::vector<vpiHandle> ho = so.Restore(other);
  Listed ref[5];
  for (int m : {2, 3, 4}) ref[m] = listRecs(ho, m);
  auto cmp = [&](const Listed& mut, int m) {  // the mutated side keeps its argument position
    return side == "A" ? differs(mut, ref[m], m) : differs(ref[m], mut, m);
  };
  // candidates on the mutated side (this restore is discarded)
  std::vector<std::pair<size_t, std::string>> cands;  // raw index, full
  std::vector<std::string> ctype;
  std::vector<size_t> ctail;
  {
    UHDM::Serializer s0;
    std::vector<vpiHandle> h0 = s0.Restore(mine);
    Raw raw; raw.listenDesigns(h0);
    std::map<const UHDM::any*, size_t> ix;
    for (size_t i = 0; i < raw.objs.size(); ++i) ix.emplace(raw.objs[i], i);
    Rec r; r.fullnameMode = 4; r.listenDesigns(h0);
    std::map<size_t, bool> seen;
    for (size_t i = 0; i < r.objs.size(); ++i) {
      if (!r.cand[i]) continue;
      auto it = ix.find(r.objs[i]);
      if (it == ix.end() || seen[it->second]) continue;
      seen[it->second] = true;
      cands.push_back({it->second, r.recs[i].rawFull});
      ctype.push_back(UHDM::UhdmName(r.objs[i]->UhdmType()));
      ctail.push_back(tailLen(r.objs[i], r.recs[i].rawFull));
    }
  }
  std::string base;
  {
    UHDM::Serializer sb;
    std::vector<vpiHandle> hb = sb.Restore(mine);
    for (int m : {2, 3, 4}) base += cmp(listRecs(hb, m), m) ? "1" : "0";
  }
  std::cerr << label << ": " << cands.size() << " candidates; unmutated differs (m2 m3 m4) = " << base << "\n";
  size_t step = cands.size() > K ? cands.size() / K : 1;
  for (size_t ci = 0, n = 0; ci < cands.size() && n < K; ci += step, ++n) {
    auto [idx, full] = cands[ci];
    auto tk = tokens(full);
    for (std::string kind : {"S-last", "S-mid", "S-top", "P-par"}) {
      std::string nw = full, cls;
      size_t tl = ctail[ci];
      if (kind[0] == 'S') {
        if (tk.empty()) continue;
        size_t t = kind == "S-last" ? tk.size() - 1 : kind == "S-mid" ? (tk.size() >= 2 ? tk.size() - 2 : SIZE_MAX) : 0;
        if (t == SIZE_MAX) continue;
        if (kind == "S-top" && tk.size() < 2) continue;
        nw = full.substr(0, tk[t].second) + "Q" + full.substr(tk[t].second);
        cls = tl == 0 ? "untailed" : (tk[t].first >= full.size() - tl ? "tail" : "above");
      }
      UHDM::Serializer s1;
      std::vector<vpiHandle> h1 = s1.Restore(mine);
      Raw raw; raw.listenDesigns(h1);
      auto* o = const_cast<UHDM::any*>(raw.objs[idx]);
      if (kind[0] == 'S') {
        if (!setFull(o, nw)) continue;
      } else {
        const UHDM::any* p = o->VpiParent();
        if (!p) continue;
        // a same-named parent elsewhere whose chain changes the synthesised name
        if (Lister::chainFullName(o) != full) continue;  // a stored name: re-parenting is invisible
        const UHDM::any* twin = nullptr;
        for (auto* c : raw.objs) {
          if (c == p || c->UhdmType() != p->UhdmType() || c->VpiName() != p->VpiName() ||
              c->VpiDefName() != p->VpiDefName())
            continue;
          o->VpiParent(const_cast<UHDM::any*>(c));
          if (Lister::chainFullName(o) != full) { twin = c; break; }
        }
        o->VpiParent(const_cast<UHDM::any*>(p));
        if (!twin) continue;
        o->VpiParent(const_cast<UHDM::any*>(twin));
        const char* f = nullptr;
        {
          vpiHandle oh = NewVpiHandle(o);
          f = vpi_get_str(vpiFullName, oh);
          vpi_release_handle(oh);
        }
        nw = f ? f : "";
        size_t tl2 = tailLen(o, nw);
        std::string oldTail = tl ? full.substr(full.size() - tl) : "", newTail = tl2 ? nw.substr(nw.size() - tl2) : "";
        cls = nw == full ? "invisible" : (tl && tl2 && oldTail == newTail ? "above" : (tl2 == 0 ? "untailed" : "tail"));
      }
      std::string c[5];
      for (int m : {2, 3, 4}) c[m] = cmp(listRecs(h1, m), m) ? "1" : "0";
      std::cout << label << '\t' << base << '\t' << side << '\t' << idx << '\t' << ctype[ci] << '\t' << kind << '\t' << cls << '\t'
                << full << '\t' << nw << '\t' << c[2] << '\t' << c[3] << '\t' << c[4] << '\n';
    }
  }
  return 0;
}
