// § hoistPoolTransitiveImports452
package u;
  class E;
    int z;
    extern function void go();
  endclass
  function void E::go();
    z = 1;
  endfunction
endpackage
package q;
  import u::*;
endpackage
package r;
  import q::*;
endpackage
module top;
  import r::*;
  wire w;
endmodule
