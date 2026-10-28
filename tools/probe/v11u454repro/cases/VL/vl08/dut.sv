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
interface bfm;
  import mid::*;
  logic [7:0] addr;
endinterface
module top;
  bfm b();
endmodule
