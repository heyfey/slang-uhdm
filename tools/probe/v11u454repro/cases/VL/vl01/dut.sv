// § pkgLateTsBodyImportsOnly454v
package u;
  class C;
    extern function void f(ref int addr[]);
  endclass
  function void C::f(ref int addr[]);
    foreach (addr[i]) addr[i] = 0;
  endfunction
endpackage
package mid;
  function automatic int g();
    import u::*;
    return 1;
  endfunction
endpackage
interface bfm(output logic [7:0] addr);
  import mid::*;
endinterface
module top;
  logic [7:0] a;
  bfm b(.addr(a));
endmodule
