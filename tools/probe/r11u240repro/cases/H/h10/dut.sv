// § hoistPoolSourceOrder240: a reference written through a macro
`define RET(x) return x;
package hp;
  class zb;
    int m;
    extern function int get();
  endclass
  function int zb::get();
    `RET(m)
  endfunction
  class aa;
    int m;
    extern function int get();
  endclass
  function int aa::get();
    return m;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
