// v9: typedef-of-typedef with a FIXED range (no parameter) at the class OOB
// return site -- the second AWAY vector, isolated from the fold axis.
package vp9;
  typedef logic signed [7:0] base_t;
  typedef base_t             chain_t;      // typedef of typedef
  typedef chain_t            chain2_t;     // and again
  class C9;
    extern function chain_t  r1();
    extern function chain2_t r2();
    extern function base_t   r0();
  endclass
  function chain_t  C9::r1(); r1 = 'b0; endfunction
  function chain2_t C9::r2(); r2 = 'b0; endfunction
  function base_t   C9::r0(); r0 = 'b0; endfunction
  function chain_t free_c(); free_c = 'b0; endfunction
endpackage
module vt9;
  import vp9::*;
  vp9::chain_t w; vp9::C9 c;
  initial begin c = new(); w = c.r1(); end
endmodule
