// fanames <db>...: § fixArrLocalNamedAggElemTs480's prediction scan.  For every array_var under a
// function or task whose element variable's typespec is a logic_typespec or bit_typespec, read the
// source token at the typespec's start; a token that is not a keyword (logic, reg, bit, wire) is the
// written NAME the law reads.  Prints one line per hit and a count per database.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <vector>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> cache;
static std::string tokenAt(const std::string& f, int l, int c) {
  auto it = cache.find(f);
  if (it == cache.end()) {
    std::vector<std::string> lines; std::ifstream in(f); std::string s;
    while (std::getline(in, s)) lines.push_back(s);
    it = cache.emplace(f, lines).first;
  }
  if (l < 1 || l > (int)it->second.size()) return "?";
  const std::string& s = it->second[l - 1];
  if (c < 1 || c > (int)s.size()) return "?";
  size_t b = c - 1, e = b;
  while (e < s.size() && (isalnum((unsigned char)s[e]) || s[e] == '_' || s[e] == ':' || s[e] == '$')) ++e;
  return s.substr(b, e - b);
}
int main(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    Serializer s; s.Restore(std::filesystem::path(argv[i]));
    long hits = 0;
    for (auto& kv : s.AllObjects()) {
      auto* o = (const any*)kv.first;
      if (o->UhdmType() != uhdmarray_var) continue;
      auto* av = (const array_var*)o;
      if (av->VpiArrayType() != vpiStaticArray || !av->Variables() || av->Variables()->empty()) continue;
      bool tf = false;
      for (auto* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) { tf = true; break; }
      if (!tf) continue;
      auto* v = (*av->Variables())[0];
      const ref_typespec* rt = nullptr;
      if (auto* vv = dynamic_cast<const variables*>(v)) rt = vv->Typespec();
      if (!rt || !rt->Actual_typespec()) continue;
      auto* t = rt->Actual_typespec();
      if (t->UhdmType() != uhdmlogic_typespec && t->UhdmType() != uhdmbit_typespec) continue;
      std::string tok = tokenAt(std::string(t->VpiFile()), t->VpiLineNo(), t->VpiColumnNo());
      if (tok == "logic" || tok == "reg" || tok == "bit" || tok == "wire" || tok == "?" || tok.empty()) continue;
      ++hits;
      std::cout << "HIT " << argv[i] << " " << av->VpiFullName() << " " << tok << " " << t->VpiLineNo() << "\n";
    }
    std::cout << "DB " << argv[i] << " hits " << hits << "\n";
  }
}
