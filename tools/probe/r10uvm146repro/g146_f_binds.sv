// r10uvm146 arm F — the BINDING arm: the four reference shapes the law splits.
//   * a PACKAGE typedef's range        -> binds the design copy (chain
//                                         range > logic_typespec > package > design)
//   * a FUNCTION-LOCAL declaration's range -> does NOT (the chain runs through a
//                                         ref_typespec)
//   * a package FUNCTION BODY statement -> binds the design copy
//   * a CLASS METHOD inside the package -> binds the design copy
package bind_pk;
  parameter B_W = 12;
  parameter B_N = 4;
  parameter string B_S = "bee";
  typedef logic [B_W-1:0] bw_t;
  function automatic int f_body();
    logic [B_W-1:0] loc;
    int r;
    r = B_N + B_W;
    loc = '0;
    return r + $bits(loc);
  endfunction
  class bind_cls;
    function int m();
      return B_N * 2;
    endfunction
  endclass
endpackage

import bind_pk::*;

module f_binds(output int fo);
  bw_t bv;
  assign fo = f_body() + $bits(bv) + B_S.len();
endmodule
