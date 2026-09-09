// r10v224 adversarial arm — associative INDEX types the pass never measured:
// a CLASS handle, a PACKED-array index, and the narrower integer keywords.
// The predicate reprieves anything whose index is not a TypeAlias.
package p224v2;
   typedef logic [1:0] tv2_t;
   class Cv2_224; int x; endclass
endpackage

interface if224v2();
   import p224v2::*;
   tv2_t v2_clsidx224  [Cv2_224];
   tv2_t v2_pkidx224   [bit [7:0]];
   tv2_t v2_lgidx224   [logic [3:0]];
   tv2_t v2_byidx224   [byte];
   tv2_t v2_shidx224   [shortint];
   tv2_t v2_intgidx224 [integer];
   tv2_t v2_str224     [string];
   tv2_t v2_bare224    [tv2_t];
   tv2_t v2_plain224;
endinterface

module top224v2;
endmodule
