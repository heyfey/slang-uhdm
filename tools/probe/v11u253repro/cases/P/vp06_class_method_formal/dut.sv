// § cloneFormalTsParented253 (an in-class method and an out-of-block method)
package p;
  parameter W = 8;
  class c;
    function int f(logic [W:0] s); return s; endfunction
    extern function int g(logic [W:0] s);
  endclass
  function int c::g(logic [W:0] s); return s; endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
