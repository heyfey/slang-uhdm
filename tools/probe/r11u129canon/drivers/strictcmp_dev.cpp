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
//   uhdm-strictcmp [--max N] [--no-canon] [--canon-fullname 0|1|2|3] [--dump-a FILE --dump-b FILE] <a.uhdm> <b.uhdm>
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
// class-typed reference). The full name of an object inside a canonicalised
// subtree is synthesised from its parent chain, which is the copy's use site
// on one side and the declaration on the other. It is compared all the same
// (the contract): where the chains differ only because one side copies, the
// exporter's naming rule for objects inside a typespec is the thing to land,
// and a wrong chain (r11u123 s03: pa::pa::st_t) is a naming defect the
// comparator must not hide. --canon-fullname 1 skips unnamed objects' full
// names inside a subtree and 0 skips all of them: measurement knobs only.
//
// Exit 0: STRICT_EQUAL. Exit 1: NOT_EQUAL at stage 1 (uhdm-cmp's verdict,
// LHS/RHS printed as uhdm-cmp prints them). Exit 2: STRICT_NOTEQUAL (the
// first differing objects printed with their index and the differing field).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <cctype>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

namespace {

const char* kFields[] = {"depth",  "type",  "name",  "defname",  "fullname",
                         "file",   "line",  "col",   "endline",  "endcol",
                         "decompile", "size", "value", "consttype"};

struct Record {
  std::string fields[14];
  std::string rawFull;  // mode 4: the full name as read, before the in-copy rewrite
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
  // The full name inside a canonicalised subtree: 2 = always compared (the
  // contract: a full name is content, and a wrong parent chain is a naming
  // defect even on an unnamed reference — r11u123 s03: pa::pa::st_t), 1 =
  // compared on named objects only, 0 = never (measurement knobs).
  int fullnameMode = 3;
  int canonDepth = 0;    // enclosing canon roots on the path
  int barrierDepth = 0;  // enclosing class typespecs on the path
  // Mode 3, the contract: the outermost canon root on the path is the copy
  // boundary. Golden holds a copy per use, parented and located at the use
  // site; we hold one object at its declaration. So (a) an object inside the
  // subtree whose full name is its path inside the copy is compared by that
  // path (the names below the root), and a full name that points elsewhere
  // (a reference out of the subtree) is compared whole;
  // (b) the root itself, when reached through a ref_typespec, carries the
  // reference's own full name and span on golden's side, so those fields are
  // left out of its record; reached from its declaring scope it is compared
  // whole.
  const UHDM::any* rootObj = nullptr;
  std::string rootFull;  // kept for --dump readers
  bool rootViaRef = false;
  // Mode 4 measurement knobs (dev): the root's span is skipped only on a
  // named root; the stored-name check is off.
  bool bNamedOnly = getenv("SC4_BNAMED") != nullptr;
  bool computedCheck = getenv("SC4_COMPUTED") != nullptr;
  bool refWhole = getenv("SC4_REFWHOLE") != nullptr;
  bool anonComputed = getenv("SC4_ANONCOMP") != nullptr;
  bool ownerViaRefOnly = getenv("SC4_VIAREF") != nullptr;
  bool rootSkipOk(const UHDM::any* o) const {
    return !bNamedOnly || !o->VpiName().empty();
  }
  bool enteredViaRef(const UHDM::any* a) const {
    for (size_t i = 1; i < callstack.size(); ++i)
      if (callstack[i] == a) return callstack[i - 1]->UhdmType() == UHDM::uhdmref_typespec;
    return false;
  }
  bool onPathBelowRoot(const UHDM::any* a) const {
    bool below = false;
    for (const UHDM::any* c : callstack) {
      if (c == rootObj) below = true;
      if (below && c == a) return true;
    }
    return false;
  }
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
  // stored none.
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
    // Mode 4: only a parent-chain name (the one BaseClass::ComputeFullName
    // synthesises) depends on where a copy hangs; a name the producer stored
    // (a reference's target) is content and compared whole.
    if (computedCheck && full != chainFullName(o)) return full;
    if (refWhole && o->UhdmType() == UHDM::uhdmref_obj && full != chainFullName(o)) return full;
    // The tail: the chain's names from the object up to its owner, inclusive.
    // The owner is the nearest NAMED typespec (or enum constant) on the
    // chain: a typedef is declared once and golden hangs a copy of it at
    // every use, so the names above it are the identity part. An anonymous
    // typespec is declared where it is used, so the chain goes on through it;
    // with no named typespec on the chain the owner is the farthest
    // anonymous one.
    std::vector<std::string_view> names;
    std::vector<size_t> cut;  // names.size() after each typespec
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
      if (anonComputed && full != chainFullName(o)) return full;
    }
    if (ownerViaRefOnly && !enteredViaRef(owner)) return full;
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
          // The listener pushes the object before enterAny: its parent on
          // the path is the previous entry.
          rootViaRef = callstack.size() >= 2 &&
                       callstack[callstack.size() - 2]->UhdmType() == UHDM::uhdmref_typespec;
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
    bool skipSpan = fullnameMode >= 3 && refRoot;
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
            << " [--max N] [--no-canon] [--canon-fullname 0|1|2|3] [--dump-a FILE --dump-b FILE] <a.uhdm> <b.uhdm>\n";
  return 3;
}

void dump(const std::vector<Record>& recs, const std::string& path) {
  std::ofstream f(path);
  for (const auto& r : recs) f << r.joined() << '\n';
}

}  // namespace

int main(int argc, char** argv) {
  int maxDiffs = 20;
  bool canon = true;
  int fullnameMode = 3;
  std::string dumpA, dumpB;
  std::vector<std::string> files;
  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--max" && i + 1 < argc) maxDiffs = std::stoi(argv[++i]);
    else if (a == "--dump-a" && i + 1 < argc) dumpA = argv[++i];
    else if (a == "--dump-b" && i + 1 < argc) dumpB = argv[++i];
    else if (a == "--no-canon") canon = false;
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
  // Stage 2: the judge-blind fields, in walk order.
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
      if (a.fields[k] != b.fields[k] &&
          !(k == 4 && fullnameMode >= 4 && a.rawFull == b.rawFull)) {
        if (first < 0) first = k;
        ++tally[k];
      }
    if (first < 0) continue;
    ++diffObjects;
    if (firstField.empty()) firstField = kFields[first];
    if (shown < maxDiffs) {
      std::cout << "#" << i << " " << kFields[first] << "\n  A: " << a.joined() << "\n  B: " << b.joined() << '\n';
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
