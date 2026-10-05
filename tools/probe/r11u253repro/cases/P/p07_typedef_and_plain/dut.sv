// § cloneFormalTsParented253
package p;
  parameter W = 8;
  typedef logic [W:0] w_t;
  function string f(w_t s, logic [W:0] t);
    return "";
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
