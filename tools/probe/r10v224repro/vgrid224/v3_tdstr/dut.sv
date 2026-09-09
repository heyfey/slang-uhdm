// r10v224 adversarial arm — an index written as a TYPEDEF OF a built-in.
// The predicate keys on the index SYMBOL KIND (TypeAlias => not a reprieve),
// so `[sv3_t]` where `typedef string sv3_t` must behave like `[tv3_t]`.
package p224v3;
   typedef logic [1:0] tv3_t;
   typedef string      sv3_t;
   typedef int         iv3_t;
endpackage

interface if224v3();
   import p224v3::*;
   typedef string locs3_t;
   tv3_t v3_tdstr224  [sv3_t];
   tv3_t v3_locstr224 [locs3_t];
   tv3_t v3_tdint224  [iv3_t];
   tv3_t v3_str224    [string];
   tv3_t v3_plain224;
endinterface

module top224v3;
endmodule
