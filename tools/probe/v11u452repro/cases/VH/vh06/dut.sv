// § hoistPoolTransitiveImports452
package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
endpackage
package s;
  import q::*;
endpackage
module top;
  import r::*;
  import s::*;
  wire w;
endmodule
