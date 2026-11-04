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
package top2;
  import mid::*;
  int y;
endpackage
module sub(input logic [3:0] addr);
  import top2::*;
endmodule
module top;
  logic [3:0] a;
  sub s(.addr(a));
endmodule
