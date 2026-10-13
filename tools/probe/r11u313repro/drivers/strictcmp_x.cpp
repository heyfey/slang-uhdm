// (r11u311: copied from r11u309repro/drivers)
// (v11u311: copied from r11u311repro/drivers)
// (r11u295: copied from r11u293repro/drivers)
// (r11u293: copied from r11u291repro/drivers)
// (r11u291: copied from r11u289repro/drivers)
// (r11u283: copied from r11u281repro/drivers)
// (r11u271: copied from r11u269repro/drivers)
// (r11u275: copied from r11u273repro/drivers)
// (r11u263: copied from r11u261repro/drivers)
// (r11u267: copied from r11u265repro/drivers)
// (r11u261: copied from r11u259repro/drivers)
// (r11u250: copied from r11u249repro/drivers)
// (r11u259: copied from r11u252repro/drivers)
// (r11u249: copied from r11u247repro/drivers)
// (r11u244: copied from r11u242repro/drivers)
// (r11u247: copied from r11u244repro/drivers)
// (r11u238 (from r11u236repro): copied from tools/probe/r11u230map/drivers/strictcmp_x.cpp, with a fail-closed fence check on every path argument)
// r11u197map: tools/uhdm-strictcmp/uhdm-strictcmp.cpp at 4a65840e (with the r11u190 raw full-name print) + the maps 7-10 variant (escaped record dumps, --dump-ids); verdict and stdout = the tool's.
// (r11u242: copied from r11u240repro/drivers)
// uhdm-strictcmp: a comparator strictly stronger than uhdm-cmp.
//
// Stage 1 runs the library's own design::Compare, exactly as uhdm-cmp does,
// so nothing uhdm-cmp rejects can pass here. Stage 2, taken only when stage
// 1 is equal, walks both databases in the same (listener) order and compares,
// for every object visited, the fields uhdm-cmp never reads: name,
// definition name, full name, file basename, the four span fields, and for
// expressions decompile, size, value and constant type. Child order is part
// of the walk, so a reordering is a difference too.
//
//   uhdm-strictcmp [--max N] [--no-canon] [--canon-fullname 0|1|2|3|4] [--dump-a FILE --dump-b FILE] <golden.uhdm> <ours.uhdm>
//
// Identity canonicalisation (default on, --no-canon for the raw walk): the
// producer clones every typespec it reaches during elaboration, so golden
// holds a private copy of a typespec where we hold one shared object. The
// listener visits a shared object's children once; a copy's children at
// every copy. That is an identity difference, not a content difference, and
// it is outside the strict contract: the walk re-expands a typespec
// subtree (and an enum constant reached through a reference) at every
// reference, so a shared object and its copies list identically. Objects
// still on the walk's own path are never re-expanded (cycles), and the
// members, methods and constraints under a class typespec stay visited
// once (a class body is shared on both sides and reached from every
// class-typed reference). What a copy changes besides the listing is its
// full name (synthesised from the parent chain: the use site on golden's
// side, the declaration on ours) and, for a typedef's copy, the span of the
// copy's root (golden may locate it at the reference). The default
// (--canon-fullname 4, r11u129) excuses those two, and only in the shape a
// copy per use explains, by the r11u128map test made the rule (USE-SITE):
//  (a) a full name inside a subtree is read as its TAIL, the names on its
//      parent chain from the object up to the nearest NAMED typespec, that
//      name included (with none, the farthest anonymous one); a full name
//      that does not end with its tail (truncated, or naming something
//      elsewhere) is compared whole. Two identical full names are equal; two
//      different ones with equal tails are equal only when golden gives that
//      object of ours (keyed by type and full name) more than one name across
//      its listings and ours's name is one of them. A name golden gives at
//      every listing (STABLE) is content (r11u123 s03's pa::pa::st_t is not:
//      golden names that reference pa::pa::st_t at the declaration and
//      pa::st_t at its copies, case evidence/cases/s03_enum_two_pkgs_rerun).
//  (b) a named root reached through a ref_typespec: a different span is
//      equal only when golden gives that typedef of ours (type, name, span)
//      more than one span and ours's is one of them. An anonymous typespec is
//      declared where it is used; its span is always compared.
// The rule reads <golden.uhdm> first. --canon-fullname 3 is r11u128's
// reading (the last name on the walk's path; its (b) looked one entry too
// far up the path and never fired), 2 compares every full name whole, 1
// skips unnamed objects' full names inside a subtree and 0 all of them:
// measurement knobs.
//
// Exit 0: STRICT_EQUAL. Exit 1: NOT_EQUAL at stage 1 (uhdm-cmp's verdict,
// LHS/RHS printed as uhdm-cmp prints them). Exit 2: STRICT_NOTEQUAL (the
// first differing objects printed with their index and the differing field).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <cctype>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <vector>

namespace {

const char* kFields[] = {"depth",  "type",  "name",  "defname",  "fullname",
                         "file",   "line",  "col",   "endline",  "endcol",
                         "decompile", "size", "value", "consttype"};

struct Record {
  std::string fields[14];
  std::string rawFull;  // mode 4: the full name as read, before the in-copy rewrite
  bool refRoot = false;  // mode 4: a named root reached through a ref_typespec
  bool root = false;     // mode 4: a named typespec at a subtree root (any path)
  bool inCopy = false;   // mode 4: inside a canonicalised subtree, not its root
  uint32_t id = 0;       // r11u132map variant: UhdmId, dumped with --dump-ids
  std::string span() const {
    return fields[5] + ":" + fields[6] + "." + fields[7] + "-" + fields[8] + "." + fields[9];
  }
  std::string joined() const {
    std::string s;
    for (int i = 0; i < 14; ++i) {
      if (i) s += '\t';
      s += fields[i];
    }
    return s;
  }
};

bool canonRoot(const UHDM::any* o) {
  return dynamic_cast<const UHDM::typespec*>(o) != nullptr ||
         o->UhdmType() == UHDM::uhdmenum_const;
}

class Lister : public UHDM::VpiListener {
 public:
  std::vector<Record> recs;
  bool canon = true;
  // Per side. A record costs 0.5-0.8 KB, so 20M a side exhausted memory long
  // before the guard (r11u123 t07: bad_alloc under 8 GB); 4M is 1.8x the
  // largest corpus row (Earlgrey_0_1 default, 2.17M) and about 3 GB.
  size_t cap = 4000000;
  bool overflow = false;
  // The full name inside a canonicalised subtree: 4 = the default (the
  // header), 3 = r11u128's reading, 2 = always compared whole, 1 = compared
  // on named objects only, 0 = never (measurement knobs).
  int fullnameMode = 4;
  int canonDepth = 0;    // enclosing canon roots on the path
  int barrierDepth = 0;  // enclosing class typespecs on the path
  // Modes 3 and 4: the outermost canon root on the path is the copy
  // boundary; inCopyFull reads a full name inside it (a), and the root's
  // record is marked when it is reached through a ref_typespec (b). The
  // comparison (fieldDiffers, PairCtx) applies the header's rule.
  const UHDM::any* rootObj = nullptr;
  std::string rootFull;  // kept for --dump readers
  bool rootViaRef = false;
  // (b), mode 4: only a NAMED root is a typedef that golden copies to its
  // uses. An anonymous typespec is declared where it is used, so its own
  // span is compared at every listing (r11u129 cases b06, and the rows whose
  // cast typespec carries no file).
  bool rootSkipOk(const UHDM::any* o) const { return !o->VpiName().empty(); }
  // BaseClass::ComputeFullName's name for one link of the parent chain.
  static std::string_view chainName(const UHDM::any* a, const UHDM::any* child) {
    const UHDM::any* ap = a->VpiParent();
    auto t = a->UhdmType();
    bool skip = (ap && ap->UhdmType() == UHDM::uhdmref_obj) ||
                t == UHDM::uhdmmethod_func_call || t == UHDM::uhdmmethod_task_call ||
                t == UHDM::uhdmfunc_call || t == UHDM::uhdmtask_call ||
                t == UHDM::uhdmsys_func_call || t == UHDM::uhdmsys_task_call;
    if (child) {
      auto ct = child->UhdmType();
      if (ct == UHDM::uhdmbit_select && t == UHDM::uhdmport) skip = true;
      if (ct == UHDM::uhdmref_obj && (t == UHDM::uhdmbit_select || t == UHDM::uhdmindexed_part_select ||
                                      t == UHDM::uhdmhier_path))
        skip = true;
    }
    if (skip) return {};
    return a->VpiName().empty() ? a->VpiDefName() : a->VpiName();
  }
  // BaseClass::ComputeFullName (protected there), the same walk: the full
  // name the database synthesises from the parent chain when the producer
  // stored none. The rule does not need it; the r11u129 audit drivers
  // (tools/probe/r11u129canon/drivers) compile this file and use it.
  static std::string chainFullName(const UHDM::any* o) {
    if (o->UhdmType() == UHDM::uhdmmodule_inst && o->VpiParent() &&
        o->VpiParent()->UhdmType() == UHDM::uhdmmodule_inst)
      return std::string(o->VpiDefName());
    std::vector<std::string_view> names;
    bool column = false;
    const UHDM::any* child = nullptr;
    for (const UHDM::any* a = o; a; child = a, a = a->VpiParent()) {
      auto t = a->UhdmType();
      if (t == UHDM::uhdmdesign) break;
      if (t == UHDM::uhdmpackage || t == UHDM::uhdmclass_defn) column = true;
      std::string_view nm = chainName(a, child);
      if (!nm.empty()) names.push_back(nm);
    }
    std::string out;
    for (auto it = names.rbegin(); it != names.rend(); ++it) {
      if (!out.empty()) out += column ? "::" : ".";
      out += *it;
    }
    return out;
  }
  static bool endsAt(const std::string& full, const std::string& tail) {
    if (full == tail) return true;
    if (full.size() <= tail.size() ||
        full.compare(full.size() - tail.size(), tail.size(), tail) != 0)
      return false;
    char c = full[full.size() - tail.size() - 1];
    return c == '.' || c == ':';
  }
  std::string inCopyFull(const UHDM::any* o, const std::string& full) {
    if (fullnameMode == 3) {
      // The path inside the copy: the names on the walk's path below the
      // root, down to this object. A full name that is that path (it ends
      // with the path's last name) is compared as the path; one that
      // points elsewhere (a reference out of the subtree) is compared
      // whole, so a wrong target name still reads as a difference.
      std::string chain, last;
      bool below = false;
      for (const UHDM::any* a : callstack) {
        if (a == rootObj) { below = true; continue; }
        if (!below) continue;
        std::string nm(a->VpiName());
        if (nm.empty()) continue;
        chain += (chain.empty() ? "" : ".") + nm;
        last = nm;
      }
      if (!last.empty() && full.size() >= last.size() &&
          full.compare(full.size() - last.size(), last.size(), last) == 0 &&
          (full.size() == last.size() || !isalnum((unsigned char)full[full.size() - last.size() - 1])))
        return "<in>" + chain;
      return full;
    }
    if (fullnameMode < 4) return full;
    // Mode 4 (a): the tail, the chain's names (BaseClass::ComputeFullName's
    // naming) from the object up to its owner, inclusive. The owner is the
    // nearest NAMED typespec (or enum constant) on the parent chain: a typedef
    // is declared once and golden hangs a copy of it at every use, so only
    // the names above the owner are the identity part. An anonymous typespec
    // is declared where it is used, so the chain goes on through it; with no
    // named typespec on the chain the owner is the farthest anonymous one.
    // A full name that ends with the whole tail is compared as the tail, so
    // every name below the owner (and the owner's own) is still compared; any
    // other full name (a truncated one, a reference elsewhere) is compared
    // whole. r11u129: mode 3 compared only the last name on the walk's path.
    std::vector<std::string_view> names;
    const UHDM::any* child = nullptr;
    const UHDM::any* owner = nullptr;
    const UHDM::any* farthest = nullptr;
    size_t farCut = 0;
    for (const UHDM::any* a = o; a; child = a, a = a->VpiParent()) {
      if (a->UhdmType() == UHDM::uhdmdesign) break;
      std::string_view nm = chainName(a, child);
      if (!nm.empty()) names.push_back(nm);
      if (a != o && canonRoot(a)) {
        if (!a->VpiName().empty()) { owner = a; break; }
        farthest = a;
        farCut = names.size();
      }
    }
    if (!owner) {
      if (!farthest) return full;
      owner = farthest;
      names.resize(farCut);
    }
    std::string dot, col;
    for (auto it = names.rbegin(); it != names.rend(); ++it) {
      if (!dot.empty()) { dot += '.'; col += "::"; }
      dot += *it;
      col += *it;
    }
    if (dot.empty() || endsAt(full, dot) || endsAt(full, col)) return "<in>" + dot;
    return full;
  }
  void leaveAny(const UHDM::any* o, vpiHandle) override {
    if (!canon) return;
    bool isClass = o->UhdmType() == UHDM::uhdmclass_typespec;
    if (isClass) --barrierDepth;
    if (o == rootObj) { rootObj = nullptr; rootFull.clear(); rootViaRef = false; }
    if (canonDepth > 0 && barrierDepth == 0 && !overflow) {
      // The listener pops the object after leaveAny, so an object elsewhere
      // on the path is an enclosing expansion of itself (measured never to
      // happen: the listener's own visited set already blocks every cycle).
      bool onPath = false;
      for (size_t i = 0; i + 1 < callstack.size(); ++i)
        if (callstack[i] == o) { onPath = true; break; }
      if (!onPath) visited.erase(o);
    }
    if (canonRoot(o)) --canonDepth;
  }
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    if (canon) {
      if (canonRoot(o)) {
        ++canonDepth;
        if (canonDepth == 1) {
          rootObj = o;
          const char* rf = vpi_get_str(vpiFullName, h);
          rootFull = rf ? rf : "";
          // VpiListener::listenAny calls enterAny BEFORE the kind's listen
          // function pushes the object, so the object's parent on the path
          // is the LAST entry (r11u129 case b01: mode 3 read the entry before
          // it, the grandparent, and its (b) almost never fired; mode 3 keeps
          // that reading).
          size_t up = fullnameMode == 3 ? 2 : 1;
          rootViaRef = callstack.size() >= up &&
                       callstack[callstack.size() - up]->UhdmType() == UHDM::uhdmref_typespec;
        }
      }
      if (o->UhdmType() == UHDM::uhdmclass_typespec) ++barrierDepth;
      if (recs.size() >= cap) overflow = true;
    }
    if (overflow) return;  // the verdict is exit 3: keep no more records
    Record r;
    r.fields[0] = std::to_string(callstack.size());
    r.fields[1] = UHDM::UhdmName(o->UhdmType());
    r.fields[2] = std::string(o->VpiName());
    r.fields[3] = std::string(o->VpiDefName());
    bool inCanon = canon && canonDepth > 0;
    bool isRoot = inCanon && o == rootObj;
    bool refRoot = isRoot && rootViaRef && (fullnameMode == 3 || (fullnameMode >= 4 && rootSkipOk(o)));
    bool wantFull = !inCanon || fullnameMode == 2 ||
                    (fullnameMode == 1 && !o->VpiName().empty()) ||
                    (fullnameMode >= 3 && !refRoot);
    if (wantFull) {
      if (const char* fn = vpi_get_str(vpiFullName, h)) {
        std::string full = fn;
        r.rawFull = full;
        if (inCanon && !isRoot) full = inCopyFull(o, full);
        r.fields[4] = full;
      }
    }
    // Mode 3 blanks the root's span; mode 4 keeps it in the record and the
    // comparison excuses a different span only for a USE-SITE object
    // (PairCtx).
    bool skipSpan = fullnameMode == 3 && refRoot;
    r.refRoot = fullnameMode >= 4 && refRoot;
    r.root = fullnameMode >= 4 && isRoot && !o->VpiName().empty();
    r.inCopy = fullnameMode >= 4 && inCanon && !isRoot;
    std::string f(o->VpiFile());
    auto pos = f.find_last_of("/\\");
    r.fields[5] = skipSpan ? "-" : (pos == std::string::npos ? f : f.substr(pos + 1));
    r.fields[6] = skipSpan ? "-" : std::to_string(o->VpiLineNo());
    r.fields[7] = skipSpan ? "-" : std::to_string(o->VpiColumnNo());
    r.fields[8] = skipSpan ? "-" : std::to_string(o->VpiEndLineNo());
    r.fields[9] = skipSpan ? "-" : std::to_string(o->VpiEndColumnNo());
    if (const UHDM::expr* e = dynamic_cast<const UHDM::expr*>(o)) {
      r.fields[10] = std::string(e->VpiDecompile());
      r.fields[11] = std::to_string(e->VpiSize());
      r.fields[12] = std::string(e->VpiValue());
      if (const UHDM::constant* c = dynamic_cast<const UHDM::constant*>(o))
        r.fields[13] = std::to_string(c->VpiConstType());
    }
    r.id = o->UhdmId();
    recs.push_back(std::move(r));
  }
};

// The parent chain of an object, root first: type(name) > type(name) > ...
// (what tools/cmptool used to print for a stage-1 failure).
std::string parentChain(const UHDM::BaseClass* o) {
  std::vector<std::string> parts;
  for (const UHDM::BaseClass* p = o; p; p = p->VpiParent()) {
    std::string s = UHDM::UhdmName(p->UhdmType());
    if (!p->VpiName().empty()) s += "(" + std::string(p->VpiName()) + ")";
    parts.push_back(s);
    if (parts.size() > 64) break;
  }
  std::string out;
  for (auto it = parts.rbegin(); it != parts.rend(); ++it) {
    if (!out.empty()) out += " > ";
    out += *it;
  }
  return out;
}

int usage(const char* prog) {
  std::cerr << "Usage: " << prog
            << " [--max N] [--no-canon] [--canon-fullname 0|1|2|3|4] [--dump-a FILE --dump-b FILE] <a.uhdm> <b.uhdm>\n";
  return 3;
}

// Mode 4, the USE-SITE test (r11u128map's classification, made the rule):
// a difference that the in-copy reading or the root's span would excuse is
// identity only when golden gives the same source object MORE THAN ONE value
// across its listings (a copy per use) and ours's one value is among them
// (ours holds the object golden lists at one place, typically the
// declaration). A value golden gives at every listing (STABLE) is content:
// a naming or location law can match it (r11u123 s03's pa::pa::st_t); so is
// a value of ours golden never gives. Our side's source object is keyed by
// its type and full name (full names) or its type, name and span (spans), so
// clones of one declaration group together. <a> is the golden (the usage
// order).
struct PairCtx {
  std::map<std::string, std::set<std::string>> names, spans;
  PairCtx(const std::vector<Record>& A, const std::vector<Record>& B) {
    size_t n = std::min(A.size(), B.size());
    for (size_t i = 0; i < n; ++i) {
      const Record &a = A[i], &b = B[i];
      if (b.inCopy && !b.rawFull.empty()) names[b.fields[1] + "|" + b.rawFull].insert(a.rawFull);
      if (b.root) spans[b.fields[1] + "|" + b.fields[2] + "|" + b.span()].insert(a.span());
    }
  }
};

// One field of two aligned records. Modes 0-3 compare the record fields;
// mode 4 compares full names inside a copy by their tail and a named root's
// span loosely, each only for a USE-SITE object (PairCtx).
bool fieldDiffers(const Record& a, const Record& b, int k, int mode, const PairCtx* ctx) {
  if (mode >= 4 && k == 4) {
    if (a.rawFull == b.rawFull) return false;
    if (a.fields[4] != b.fields[4] || !ctx) return true;
    auto it = ctx->names.find(b.fields[1] + "|" + b.rawFull);
    return it == ctx->names.end() || it->second.size() < 2 || !it->second.count(b.rawFull);
  }
  if (a.fields[k] == b.fields[k]) return false;
  if (mode >= 4 && k >= 5 && k <= 9 && ctx && a.refRoot && b.refRoot) {
    auto it = ctx->spans.find(b.fields[1] + "|" + b.fields[2] + "|" + b.span());
    return it == ctx->spans.end() || it->second.size() < 2 || !it->second.count(b.span());
  }
  return true;
}

// r11u132map variant (measurement only): every field escaped (backslash,
// tab, newline) so a record is one line, plus a 15th column carrying what
// the mode-4 rule reads beyond the record: rawFull, refRoot, root, inCopy
// (0x1f-separated). The verdict and every other byte of stdout are the
// committed tool's.
std::string esc(const std::string& s) {
  std::string o;
  for (char c : s) {
    if (c == '\\') o += "\\\\";
    else if (c == '\t') o += "\\t";
    else if (c == '\n') o += "\\n";
    else if (c == '\r') o += "\\r";
    else o += c;
  }
  return o;
}
bool dumpIds = false;  // --dump-ids: a fifth 0x1f field, the object's UhdmId (site pinning)
void dump(const std::vector<Record>& recs, const std::string& path) {
  std::ofstream f(path);
  for (const auto& r : recs) {
    for (int i = 0; i < 14; ++i) f << esc(r.fields[i]) << '\t';
    f << esc(r.rawFull) << '\x1f' << r.refRoot << '\x1f' << r.root << '\x1f' << r.inCopy;
    if (dumpIds) f << '\x1f' << r.id;
    f << '\n';
  }
}

}  // namespace

#include <regex>
#include <sstream>
int main(int argc, char** argv) {
  { const char* f = std::getenv("FENCED");
    if (!f || !*f) { std::cerr << "strictcmp_x: FENCED unset, refusing\n"; return 4; }
    for (int i = 1; i < argc; ++i) { std::istringstream is(f); std::string w; std::string p(argv[i]);
      while (is >> w) if (std::regex_search(p, std::regex("\\b" + w + "\\b"))) { std::cerr << "strictcmp_x: fenced path, refusing\n"; return 5; } } }
  int maxDiffs = 20;
  bool canon = true;
  int fullnameMode = 4;
  std::string dumpA, dumpB;
  std::vector<std::string> files;
  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--max" && i + 1 < argc) maxDiffs = std::stoi(argv[++i]);
    else if (a == "--dump-a" && i + 1 < argc) dumpA = argv[++i];
    else if (a == "--dump-b" && i + 1 < argc) dumpB = argv[++i];
    else if (a == "--no-canon") canon = false;
    else if (a == "--dump-ids") dumpIds = true;
    else if (a == "--canon-fullname" && i + 1 < argc) fullnameMode = std::stoi(argv[++i]);
    else if (a.rfind("--", 0) == 0) return usage(argv[0]);
    else files.push_back(a);
  }
  if (files.size() != 2) return usage(argv[0]);
  for (const auto& f : files)
    if (!std::filesystem::exists(f)) {
      std::cerr << f << ": File does not exist!\n";
      return 3;
    }
  auto serA = std::make_unique<UHDM::Serializer>();
  auto serB = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> hA = serA->Restore(files[0]);
  std::vector<vpiHandle> hB = serB->Restore(files[1]);
  if (hA.empty() || hB.empty()) {
    std::cerr << (hA.empty() ? files[0] : files[1]) << ": Failed to load.\n";
    return 3;
  }
  if (hA.size() != hB.size()) {
    std::cout << "NOT_EQUAL stage1 designs " << hA.size() << " vs " << hB.size() << '\n';
    return 1;
  }
  // Stage 1: uhdm-cmp's own verdict.
  for (size_t i = 0; i < hA.size(); ++i) {
    const auto* dA = (const UHDM::design*)((const uhdm_handle*)hA[i])->object;
    const auto* dB = (const UHDM::design*)((const uhdm_handle*)hB[i])->object;
    UHDM::CompareContext ctx;
    if (dA->Compare(dB, &ctx) != 0) {
      std::cout << "LHS:\n";
      if (ctx.m_failedLhs) std::cout << UHDM::decompile(ctx.m_failedLhs); else std::cout << "<null>\n";
      std::cout << "RHS:\n";
      if (ctx.m_failedRhs) std::cout << UHDM::decompile(ctx.m_failedRhs); else std::cout << "<null>\n";
      if (ctx.m_failedLhs) std::cout << "lhsPath: " << parentChain(ctx.m_failedLhs) << '\n';
      if (ctx.m_failedRhs) std::cout << "rhsPath: " << parentChain(ctx.m_failedRhs) << '\n';
      std::cout << "NOT_EQUAL stage1\n";
      return 1;
    }
  }
  // Stage 2: the judge-blind fields, in walk order. <a> is the golden: mode
// 4's (b) excuses a copy located at a use on A's side only.
  Lister lA, lB;
  lA.canon = lB.canon = canon;
  lA.fullnameMode = lB.fullnameMode = fullnameMode;
  lA.listenDesigns(hA);
  if (!lA.overflow) lB.listenDesigns(hB);
  if (lA.overflow || lB.overflow) {
    std::cout << "canon overflow: the re-expanded walk passed " << lA.cap
              << " objects; the walk is not comparable\n";
    return 3;
  }
  if (!dumpA.empty()) dump(lA.recs, dumpA);
  if (!dumpB.empty()) dump(lB.recs, dumpB);
  size_t n = std::min(lA.recs.size(), lB.recs.size());
  std::unique_ptr<PairCtx> ctx;
  if (fullnameMode >= 4) ctx = std::make_unique<PairCtx>(lA.recs, lB.recs);
  int shown = 0;
  std::string firstField;
  size_t tally[14] = {0};
  size_t diffObjects = 0;
  bool structural = false;
  for (size_t i = 0; i < n; ++i) {
    const Record& a = lA.recs[i];
    const Record& b = lB.recs[i];
    int first = -1;
    for (int k = 0; k < 14; ++k)
      if (fieldDiffers(a, b, k, fullnameMode, ctx.get())) {
        if (first < 0) first = k;
        ++tally[k];
      }
    if (first < 0) continue;
    ++diffObjects;
    if (firstField.empty()) firstField = kFields[first];
    if (shown < maxDiffs) {
      std::cout << "#" << i << " " << kFields[first] << "\n  A: " << a.joined() << "\n  B: " << b.joined() << '\n';
      // r11u190: a full name that differs only in its raw form (mode 4 reads
      // the in-copy rewrite `<in>...` equal on both sides, the raw full names
      // differ, and the use-site test keeps it a difference) printed the same
      // text on both lines (tools/probe/r11u190verify/cases/E/e05 `#13
      // fullname  <in>p::e_t / <in>p::e_t`, golden `work@amod.p::e_t`, ours
      // `work@zlit.p::e_t`): the raw names follow, on a line of their own.
      // The verdict, the record lines and the --dump files are unchanged.
      if (fieldDiffers(a, b, 4, fullnameMode, ctx.get()) && a.fields[4] == b.fields[4] &&
          a.rawFull != b.rawFull)
        std::cout << "  raw fullname A: " << a.rawFull << " | B: " << b.rawFull << '\n';
      ++shown;
    }
    if (first <= 1) { structural = true; break; }  // the walks no longer align
  }
  if (lA.recs.size() != lB.recs.size()) {
    std::cout << "objects " << lA.recs.size() << " vs " << lB.recs.size() << '\n';
    if (firstField.empty()) firstField = "count";
  }
  if (firstField.empty()) {
    std::cout << "STRICT_EQUAL " << lA.recs.size() << " objects\n";
    return 0;
  }
  std::cout << "fields:";
  for (int k = 0; k < 14; ++k)
    if (tally[k]) std::cout << ' ' << kFields[k] << '=' << tally[k];
  std::cout << " objects_differing=" << diffObjects << (structural ? " (walk diverged)" : "") << '\n';
  std::cout << "STRICT_NOTEQUAL " << firstField << '\n';
  return 2;
}
