// § clsImpGroupHomeOrder472
`define MK(N) function void N(); endfunction
package p;
  function void zz(); endfunction
  `MK(bb)
  `MK(aa)
  function void mm(); endfunction
endpackage
package q;
  import p::*;
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule
