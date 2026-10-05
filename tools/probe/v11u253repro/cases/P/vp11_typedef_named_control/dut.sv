// § cloneFormalTsParented253 (control: a named typedef formal and a type-parameter class formal)
package p;
  parameter W = 8;
  typedef logic [W:0] w_t;
  function automatic int f(w_t s);
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
