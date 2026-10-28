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
module top;
  import mid::*;
  logic [7:0] addr;
  logic [3:0] i;
  assign addr = 0;
  assign i = 0;
endmodule
