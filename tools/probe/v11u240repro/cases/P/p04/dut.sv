// § hoistPoolSourceOrder240: references in a fork, a nested begin, a local initializer and a loop bound
package hp;
  class zq;
    int n, lim, acc;
    extern task run();
    extern function int sum();
  endclass
  class aq;
    int n, lim;
    extern function int f();
  endclass
  function int aq::f();
    int t = lim;
    return t + n;
  endfunction
  task zq::run();
    fork
      begin
        acc = n;
      end
    join
  endtask
  function int zq::sum();
    int s = 0;
    for (int i = 0; i < lim; i++) begin
      s += acc;
    end
    return s;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
