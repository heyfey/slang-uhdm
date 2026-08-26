// r10uvm154 arm C — the HOMES.  A `$unit` enum, a module enum, an interface
// enum and a class enum, all carrying the same written `-1` under a typedef
// base.  § unitArith's `$unit` fork (TypeEmit.cpp, the `unitEnum9` branch) sent
// the compilation-unit enum down a DIFFERENT road that folded the base-coerced
// digits into BOTH the value and the decompile; the law is placed AHEAD of that
// fork, so all four homes answer identically -- which is what golden does.
typedef bit [31:0] unit_mask_t;
typedef enum unit_mask_t { UNIT_ALL = -1, UNIT_TWO = 2 } unit_cov_e;

module mod_c154;
   typedef logic [31:0] mod_mask_t;
   typedef enum mod_mask_t { MOD_ALL = -1, MOD_THREE = 3 } mod_cov_e;
   mod_cov_e  mv;
   unit_cov_e uv;
   initial begin mv = MOD_ALL; uv = UNIT_ALL; end
endmodule

interface if_c154;
   typedef byte if_base_t;
   typedef enum if_base_t { IF_ALL = -2, IF_FOUR = 4 } if_cov_e;
   if_cov_e iv;
   initial iv = IF_ALL;
endinterface

package pk_c154;
   typedef bit [31:0] cls_mask_t;
   class Holder;
      typedef enum cls_mask_t { CLS_ALL = -1, CLS_FIVE = 5 } cls_cov_e;
      cls_cov_e cv;
      function void arm(); cv = CLS_ALL; endfunction
   endclass
endpackage

module top_c154;
   mod_c154 m();
   if_c154  i();
endmodule
