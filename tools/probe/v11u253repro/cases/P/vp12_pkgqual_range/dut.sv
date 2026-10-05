// § cloneFormalTsParented253 (a range written with another package's parameter)
package k;
  parameter KW = 6;
endpackage
package p;
  function automatic int f(logic [k::KW:0] s);
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
