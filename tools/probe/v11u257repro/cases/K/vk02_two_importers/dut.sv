// § cloneTfIdOrder257v (two wildcard importers of one package, the subroutines sharing two typedefs)
package p;
  typedef bit [7:0] a_t; typedef logic [3:0] b_t;
  function automatic int f1(a_t x, b_t z); a_t y; y = x; return int'(y) + int'(z); endfunction
  function automatic int f2(b_t x); b_t y; a_t w; y = x; w = 8'(y); return int'(w); endfunction
  function automatic void t3(input a_t x, output b_t o); o = 4'(x); endfunction
endpackage
package q1; import p::*; function automatic int g(); b_t o; t3(8'h1, o); return f1(1, 2) + f2(3) + int'(o); endfunction endpackage
package q2; import p::*; function automatic int h(); return f2(4) + f1(5, 6); endfunction endpackage
module top; int r; initial r = q1::g() + q2::h(); endmodule
