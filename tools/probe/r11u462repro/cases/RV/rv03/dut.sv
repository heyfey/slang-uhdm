// § cloneRetVarViaRefKeepsHome462
package p;
  typedef bit [7:0] a_t;
  function a_t g(int h);
    g = h;
  endfunction
endpackage
package q;
  import p::*;
  function int k(); return 1; endfunction
endpackage
module top;
  import q::*;
  int x;
endmodule
