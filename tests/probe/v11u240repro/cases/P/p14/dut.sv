// § hoistPoolSourceOrder240: an include inside the package between the classes, the include holding a constructor and a task
package hp;
  class zb;
    int cnt, lvl;
    extern function new();
    extern task t();
  endclass
  `include "p14_inc.svh"
  class aa;
    int cnt, lvl;
    extern function int f();
  endclass
  function int aa::f();
    return lvl + cnt;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
