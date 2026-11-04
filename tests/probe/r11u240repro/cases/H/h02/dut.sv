// § hoistPoolSourceOrder240: a constructor's reference yields to a later method's
package hp;
  class cc;
    int cnt;
    extern function new();
    extern function int get();
  endclass
  function cc::new();
    cnt = 0;
  endfunction
  function int cc::get();
    return cnt;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
