// § cloneForIncBindsHomeVar238
// a task with a for loop, a class method in a parameterized class, a $unit import of the home package
package p;
  task automatic t(output int o);
    o = 0;
    for (int k = 0; k < 3; ++k) o += k;
  endtask
  class pc #(int W = 4);
    extern function int m();
  endclass
  function int pc::m();
    int s = 0;
    for (int u = 0; u < W; u += 2) s += u;
    return s;
  endfunction
endpackage
import p::*;
package q;
  import p::*;
  task automatic qt(output int o);
    pc #(8) x = new;
    t(o);
    o += x.m();
  endtask
endpackage
module top;
  int r;
  initial q::qt(r);
endmodule
