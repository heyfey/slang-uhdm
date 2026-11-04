// § pkgLateTsTransitiveImport454
package u;
  class C;
    extern function void f(ref int addr[]);
  endclass
  function void C::f(ref int addr[]);
    foreach (addr[i]) addr[i] = 0;
  endfunction
endpackage
package mid;
  import u::*;
  int z;
endpackage
module other(output logic [5:0] addr);
  assign addr = 6'h1;
endmodule
module imp(output logic [2:0] addr);
  import mid::*;
  assign addr = 3'h1;
endmodule
module top;
  logic [5:0] x; logic [2:0] y;
  other o(.addr(x));
  imp i(.addr(y));
endmodule
