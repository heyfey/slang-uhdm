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
  int z;
endpackage
import u::*;
interface bfm(output logic [7:0] addr);
  import mid::*;
endinterface
module top;
  logic [7:0] a;
  bfm b(.addr(a));
endmodule
