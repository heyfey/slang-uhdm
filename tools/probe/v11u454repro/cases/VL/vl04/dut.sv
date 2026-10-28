// § pkgLateTsTransitiveImport454
package u;
  class C;
    extern function void f(ref int addr[]);
  endclass
  function void C::f(ref int addr[]);
    foreach (addr[i]) addr[i] = 0;
  endfunction
endpackage
package b2;
  import u::*;
  int y;
endpackage
package a2;
  import b2::*;
  int z;
endpackage
interface bfm(output logic [7:0] addr);
  import a2::*;
endinterface
module top;
  logic [7:0] a;
  bfm b(.addr(a));
endmodule
