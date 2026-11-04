// § cloneFormalTsParented253
package p;
  parameter W = 8;
  function string f(logic [W:0] s);
    return "";
  endfunction
endpackage
package q1;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
  import q1::*;
endmodule
