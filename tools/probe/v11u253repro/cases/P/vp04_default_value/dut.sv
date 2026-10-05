// § cloneFormalTsParented253 (a formal with a default value)
package p;
  parameter W = 8;
  function automatic int f(input logic [W:0] s = '0, int k = W);
    return s + k;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
