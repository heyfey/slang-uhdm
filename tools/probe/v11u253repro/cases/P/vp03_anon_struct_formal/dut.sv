// § cloneFormalTsParented253 (an anonymous packed struct formal and an anonymous enum formal)
package p;
  parameter W = 4;
  function automatic int f(input struct packed { logic [W-1:0] x; logic y; } s, input enum { A, B } e);
    return s.x + e;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
