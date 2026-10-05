// § cloneFormalTsParented253
package p;
  parameter W = 4;
  function string f(int s);
    return "";
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
