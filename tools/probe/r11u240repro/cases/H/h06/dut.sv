// § hoistPoolSourceOrder240: an include inside a class's file region (uvm_component includes uvm_root)
package hp;
  class zo;
    int r;
    extern function int get();
  endclass
`include "inner.svh"
  function int zo::get();
    return r;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
