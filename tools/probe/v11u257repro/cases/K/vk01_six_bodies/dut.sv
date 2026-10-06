// § cloneTfIdOrder257v (six package subroutines, each binding its own scalar typedef, cloned into a wildcard importer)
package p;
  typedef bit [7:0] a_t; typedef logic [3:0] b_t; typedef bit [15:0] c_t;
  typedef logic [5:0] d_t; typedef bit [2:0] e_t; typedef logic [9:0] f_t;
  function automatic int fa(a_t x); a_t y; y = x; return int'(y); endfunction
  function automatic int fb(b_t x); b_t y; y = x; return int'(y); endfunction
  function automatic int fc(c_t x); c_t y; y = x; return int'(y); endfunction
  function automatic int fd(d_t x); d_t y; y = x; return int'(y); endfunction
  function automatic int fe(e_t x); e_t y; y = x; return int'(y); endfunction
  function automatic int ff(f_t x); f_t y; y = x; return int'(y); endfunction
endpackage
package q;
  import p::*;
  function automatic int all(); return fa(1) + fb(2) + fc(3) + fd(4) + fe(5) + ff(6); endfunction
endpackage
module top; import q::*; int r; initial r = all(); endmodule
