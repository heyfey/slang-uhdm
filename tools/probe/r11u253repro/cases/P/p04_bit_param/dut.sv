// § cloneFormalTsParented253
package p;
  parameter W = 4;
  function string f(bit [W-1:0] s);
    return "";
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
