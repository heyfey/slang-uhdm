// § ctorRetVarSiblingSpan277
`define FORMAL input string nm
`define DIR input
package p;
  class c1;
    function new(`FORMAL);
    endfunction
  endclass
  class c2;
    function new(`DIR int a);
    endfunction
  endclass
  `include "inc.svh"
endpackage
package p2;
  `include "inc.svh"
endpackage
module top;
  p::c1 x;
endmodule
