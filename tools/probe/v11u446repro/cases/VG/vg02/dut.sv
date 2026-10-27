// § importGroupKeepsHomeOrder446
`define MF(N) \
function automatic int N (int a); \
  return a + 1; \
endfunction
package p;
  function automatic int f0(int a); return a; endfunction
  `MF(f1)
  function automatic int f2(int a); return a * 2; endfunction
  `MF(f3)
endpackage
package q;
  import p::*;
  function automatic int g(int a); return f3(f1(a)); endfunction
endpackage
module top;
  import q::*;
  int o;
  initial o = g(1);
endmodule
