// § cloneFormalTsParented253 (a ranged return beside a ranged formal)
package p;
  parameter W = 8;
  function automatic logic [W:0] f(logic [W:0] s);
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
