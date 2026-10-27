// § importGroupKeepsHomeOrder446
`define M_SET(N) \
function void s_``N``(); \
endfunction
package p;
  function void f0(); endfunction
  `M_SET(one)
  function void f2(); endfunction
  `M_SET(two)
endpackage
package q;
  import p::*;
  function void own(); endfunction
endpackage
module top;
  import q::*;
endmodule
