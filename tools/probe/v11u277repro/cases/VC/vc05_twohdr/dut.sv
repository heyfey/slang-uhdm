// § ctorRetVarSiblingSpan277
`define F2(t,n) input t n
package p1;
  `include "h.svh"
endpackage
package p2;
  class mc;
    function new(`F2(string, s));
    endfunction
  endclass
  class mc2;
    function new(input 
                 int a);
    endfunction
  endclass
endpackage
module top;
  p1::hc x;
  p2::mc y;
endmodule
