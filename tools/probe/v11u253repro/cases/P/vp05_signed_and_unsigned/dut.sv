// § cloneFormalTsParented253 (signed vector, int unsigned, integer, byte)
package p;
  parameter W = 8;
  function automatic int f(input bit signed [W-1:0] a, int unsigned u, integer i, byte b, logic l);
    return a + u + i + b + l;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
