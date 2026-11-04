// § hoistPoolSourceOrder240: this. paths, a hoisting interface body and an implicit net beside the hoist
package hp;
  class zb;
    int t;
    extern function int get();
  endclass
  function int zb::get();
    return this.t + t;
  endfunction
  class aa;
    int t;
    extern function int get();
  endclass
  function int aa::get();
    return t;
  endfunction
endpackage
interface ifc;
  import hp::*;
  logic sig;
endinterface
module top;
  import hp::*;
  ifc u_if();
  assign imp_w = 1'b1;
  initial $display("x");
endmodule
