// VERIFIER arm: BODY SHAPES around the return — a nested NAMED block before
// the return, the return INSIDE a named block (fence), a NON-ANSI formal list,
// a declaration-only prologue, and a return whose expression is a
// CONCATENATION / INSIDE / cast wrapping the call.
package b22;
  import "DPI-C" context function int d22(input int a, input int b);
  function int g (int a, int b); return d22(a, b); endfunction
  // y1 declaration prologue, then the return  (still the window)
  function int y1 (int a, int b); int t; t = 1; return g(a, b); endfunction
  // y2 a nested NAMED block BEFORE the return  (still the window)
  function int y2 (int a, int b); begin : bl int t; t = 1; end return g(a, b); endfunction
  // y3 the return INSIDE a named block  (FENCE: paSeq_block hardcodes Reduce::No)
  function int y3 (int a, int b); begin : bl return g(a, b); end endfunction
  // y4 NON-ANSI formal list
  function int y4; input int a; input int b; return g(a, b); endfunction
  // y5 the call under a CAST in the returned expression
  function int y5 (int a, int b); return int'(g(a, b)); endfunction
  // y6 the call under a CONCATENATION
  function int y6 (int a, int b); return {g(a, b)}; endfunction
  // y7 two nested returns' worth: a ternary selecting between two calls
  function int y7 (int a, int b); return a ? g(a, b) : g(b, a); endfunction
endpackage
module m22;
  int r[7];
  initial begin
    r[0]=b22::y1(1,2); r[1]=b22::y2(1,2); r[2]=b22::y3(1,2); r[3]=b22::y4(1,2);
    r[4]=b22::y5(1,2); r[5]=b22::y6(1,2); r[6]=b22::y7(1,2);
  end
endmodule
