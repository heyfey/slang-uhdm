// r10uvm63 arm b4 — THE OTHER PRODUCERS OF THE SAME INDEX RULE.
//
// The associative-INDEX rule has FIVE copies in this exporter (the campaign
// named them § assocIdxSiteFour43 and § assocIdxSiteFive44 when the typedef
// registry was threaded through each).  Arms b1/b2/b3 measure the two that
// `emitAssocDims` owns plus the module-instance one; this arm reaches the other
// two, because a law stamped in `assocIndexTs` fires at THREE call sites and a
// pass that measures only one of them is shipping two unmeasured changes:
//
//   PACKAGE scope        -> § assocIdxSiteFive44, `src/ParamEmit.cpp` (its own
//                           copy of the arms; it does NOT call assocIndexTs).
//   DYN-CONTAINER TYPEDEF-> `buildDynContainerTypedefTs`, the THIRD
//                           `assocIndexTs` call site: `typedef int T[integer];`
//                           has no declarator at all, so its index typespec
//                           rides the marker constant of a typespec-view
//                           array_typespec.
//   INTERFACE scope      -> the same instance-level writer as a module, kept
//                           here as the scope control the § 9 pass showed can
//                           flip a law (class right / module wrong).
package pk63;
  int p01_integer[integer];
  int p02_int[int];
  int p03_byte[byte];
  int p04_shortint[shortint];
  int p05_longint[longint];
  int p06_time[time];
  int p07_intu[int unsigned];
  int p08_bit[bit];
  int p09_string[string];
endpackage

typedef int t01_ai_t[integer];
typedef int t02_ab_t[byte];
typedef int t03_as_t[string];
typedef int t04_asi_t[string][integer];
typedef int t05_aiu_t[int unsigned];

interface b4if;
  int i01_integer[integer];
  int i02_byte[byte];
  int i03_intu[int unsigned];
  int i04_string[string];
endinterface

class b4c;
  t01_ai_t  q01_ai;
  t02_ab_t  q02_ab;
  t03_as_t  q03_as;
  t04_asi_t q04_asi;
  t05_aiu_t q05_aiu;
endclass

module b4_top;
  b4if u();
  t01_ai_t  n01_ai;
  t04_asi_t n04_asi;
  b4c h;
  initial h = new();
endmodule
