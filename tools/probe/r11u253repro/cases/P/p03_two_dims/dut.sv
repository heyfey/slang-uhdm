// § cloneFormalTsParented253
package p;
  parameter W = 8;
  function string f(logic [W:0][3:0] s);
    return "";
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
