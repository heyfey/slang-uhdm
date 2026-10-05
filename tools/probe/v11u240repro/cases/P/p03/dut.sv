// § hoistPoolSourceOrder240: nested macros and a macro argument carrying the reference, constructor first in the text
`define RD(x) (x + 1)
`define RD2(x) `RD(x)
package hp;
  class zc;
    int k, m;
    extern function new();
    extern function int f();
    extern task g();
  endclass
  function zc::new();
    k = 0;
    m = 0;
  endfunction
  task zc::g();
    m = `RD2(k);
  endtask
  function int zc::f();
    return `RD(m) + k;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
