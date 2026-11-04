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
interface plain(output logic [7:0] addr);
endinterface
module sub(input logic [1:0] addr);
  import mid::*;
endmodule
module top;
  logic [7:0] a; logic [1:0] b;
  plain p(.addr(a));
  sub s(.addr(b));
endmodule
