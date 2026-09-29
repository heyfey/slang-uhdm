// § cloneHpIdxNamesByChain220 § hpVarSelRangeIdxNamesByPath220 § hpTrailIpsNamesByPath218 — an out-of-body method of a package class reading a path's var_select part select and an indexed part select, cloned by an importing package
package p1;
  typedef struct packed { logic [3:0][7:0] v; } w_t;
  class c;
    w_t arr [4];
    extern function logic [3:0] f(int i, int j, int k);
  endclass
  function logic [3:0] c::f(int i, int j, int k);
    return arr[i].v[j][3:0] ^ arr[i].v[j][k +: 4];
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
