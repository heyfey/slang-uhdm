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
  class S;
    int y;
  endclass
endpackage
interface ifc;
  import r::*;
  logic c;
endinterface
module top;
  ifc u();
endmodule
