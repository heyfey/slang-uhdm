// § hoistPoolSourceOrder240: the module declares one of the names, the rest are minted; an interface imports too
package hp;
  class zb;
    int a, b, c;
    extern function int f();
  endclass
  class aa;
    int a, b, c;
    extern function int g();
  endclass
  function int zb::f();
    return c + a;
  endfunction
  function int aa::g();
    return b + c;
  endfunction
endpackage
interface ifc;
  import hp::*;
  logic b;
endinterface
module top;
  import hp::*;
  logic a;
  ifc u_if();
  initial $display("x");
endmodule
