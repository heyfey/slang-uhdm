// § cloneFormalTsParented253
package p;
  
  function string f(logic [7:0] s);
    return "";
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
