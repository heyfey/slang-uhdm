// § cloneFormalTsParented253 (formals declared in the body of a paren-less function)
package p;
  parameter W = 8;
  function automatic int f;
    input logic [W:0] s;
    input logic [3:0] t;
    return s + t;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
