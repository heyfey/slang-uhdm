// § cloneFormalTsParented253 (two formals sharing one declaration's type)
package p;
  parameter W = 8;
  function automatic logic f(input logic [W-1:0] a, b);
    return a == b;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
