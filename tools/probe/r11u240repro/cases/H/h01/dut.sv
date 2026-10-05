// § hoistPoolSourceOrder240: two classes, source order against name order
package hp;
  class zb;
    int cnt;
    extern function int get();
  endclass
  function int zb::get();
    return cnt;
  endfunction
  class aa;
    int cnt;
    extern function int get();
  endclass
  function int aa::get();
    return cnt + 1;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
