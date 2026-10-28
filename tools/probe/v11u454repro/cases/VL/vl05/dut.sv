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
module leaf;
  import mid::*;
  logic [3:0] addr;
  assign addr = 4'h3;
endmodule
module top;
  leaf l();
endmodule
