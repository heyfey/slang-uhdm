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
//   uhdm-strictcmp [--max N] [--no-canon] [--dump-a FILE --dump-b FILE] <a.uhdm> <b.uhdm>
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
// on one side and the declaration on the other; it is left out of the record
// there (the object's own name is still compared, and the downstream consumer
// reads full names only on scopes, instances, parameters and references
// outside typespecs).
//
// Exit 0: STRICT_EQUAL. Exit 1: NOT_EQUAL at stage 1 (uhdm-cmp's verdict,
// LHS/RHS printed as uhdm-cmp prints them). Exit 2: STRICT_NOTEQUAL (the
// first differing objects printed with their index and the differing field).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>

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
  size_t cap = 20000000;
  bool overflow = false;
  int canonDepth = 0;    // enclosing canon roots on the path
  int barrierDepth = 0;  // enclosing class typespecs on the path
  void leaveAny(const UHDM::any* o, vpiHandle) override {
    if (!canon) return;
    bool isClass = o->UhdmType() == UHDM::uhdmclass_typespec;
    if (isClass) --barrierDepth;
    if (canonDepth > 0 && barrierDepth == 0 && !overflow) {
      // The listener leaves this object before popping it: elsewhere on the
      // path means an enclosing expansion of the same object.
      bool onPath = false;
      for (size_t i = 0; i + 1 < callstack.size(); ++i)
        if (callstack[i] == o) { onPath = true; break; }
      if (!onPath) visited.erase(o);
    }
    if (canonRoot(o)) --canonDepth;
  }
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    if (canon) {
      if (canonRoot(o)) ++canonDepth;
      if (o->UhdmType() == UHDM::uhdmclass_typespec) ++barrierDepth;
      if (recs.size() >= cap) overflow = true;
    }
    Record r;
    r.fields[0] = std::to_string(callstack.size());
    r.fields[1] = UHDM::UhdmName(o->UhdmType());
    r.fields[2] = std::string(o->VpiName());
    r.fields[3] = std::string(o->VpiDefName());
    if (!(canon && canonDepth > 0))
      if (const char* fn = vpi_get_str(vpiFullName, h)) r.fields[4] = fn;
    std::string f(o->VpiFile());
    auto pos = f.find_last_of("/\\");
    r.fields[5] = pos == std::string::npos ? f : f.substr(pos + 1);
    r.fields[6] = std::to_string(o->VpiLineNo());
    r.fields[7] = std::to_string(o->VpiColumnNo());
    r.fields[8] = std::to_string(o->VpiEndLineNo());
    r.fields[9] = std::to_string(o->VpiEndColumnNo());
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
            << " [--max N] [--no-canon] [--dump-a FILE --dump-b FILE] <a.uhdm> <b.uhdm>\n";
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
  std::string dumpA, dumpB;
  std::vector<std::string> files;
  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--max" && i + 1 < argc) maxDiffs = std::stoi(argv[++i]);
    else if (a == "--dump-a" && i + 1 < argc) dumpA = argv[++i];
    else if (a == "--dump-b" && i + 1 < argc) dumpB = argv[++i];
    else if (a == "--no-canon") canon = false;
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
  lA.listenDesigns(hA);
  lB.listenDesigns(hB);
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
      if (a.fields[k] != b.fields[k]) { if (first < 0) first = k; ++tally[k]; }
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
