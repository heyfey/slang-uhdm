// § classScopeTdPkgListingParent214 — a class-scope typedef of a parameterized class used through two specializations in the home package and read from two importing packages
package p;
  class reg_c #(int W = 8);
    typedef logic [W-1:0] data_t;
    data_t d;
  endclass
  typedef reg_c #(4)::data_t d4_t;
  typedef reg_c #(12)::data_t d12_t;
endpackage
package q;
  import p::*;
  function automatic int fq(d4_t x); return int'(x); endfunction
endpackage
package r;
  import p::*;
  function automatic int fr(d12_t x); return int'(x); endfunction
endpackage
module top(output int o);
  assign o = q::fq(4'd3) + r::fr(12'd5);
endmodule
