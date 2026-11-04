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
module sub;
  import r::*;
endmodule
module top;
  import q::*;
  sub u();
endmodule
