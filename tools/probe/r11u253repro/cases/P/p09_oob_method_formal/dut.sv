// § cloneFormalTsParented253
package p;
  parameter W = 8;
  class c;
    extern function void f(logic [W:0] s);
  endclass
  function void c::f(logic [W:0] s);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
