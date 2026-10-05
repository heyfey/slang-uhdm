// § hoistPoolSourceOrder240: a constructor of the alphabetically first class written first, the later class's method reads the same names
package hp;
  class ac;
    int k, m;
    extern function new();
  endclass
  function ac::new();
    k = 1;
    m = 2;
  endfunction
  class zc;
    int k, m;
    extern function int f();
    extern task t();
  endclass
  task zc::t();
    m = 0;
  endtask
  function int zc::f();
    return k;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
