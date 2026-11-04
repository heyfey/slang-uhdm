// § hoistPoolSourceOrder240: one macro expansion defines two out-of-body bodies whose classes sort against source order
`define IMPL2 \
  function int zb::get(); return cnt; endfunction \
  function int aa::get(); return cnt + 1; endfunction
package hp;
  class zb;
    int cnt;
    extern function int get();
  endclass
  class aa;
    int cnt;
    extern function int get();
  endclass
  `IMPL2
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
