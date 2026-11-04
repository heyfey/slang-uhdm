// § cloneFormalTsParented253 (formal in a macro body)
`define FN(N) function string N(logic [W:0] s); return ""; endfunction
package p;
  parameter W = 8;
  `FN(f)
  `FN(g)
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
