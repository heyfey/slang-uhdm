// r11u218 decode (no law written; the face named macroArgMethodCallSpan218 in the README) — k01_cb_method: a method call whose name and arguments are one macro argument, `cb.METHOD` (uvm_callback_defines.svh:168)
`define DO_CB(OBJ,METHOD) \
   begin \
     OBJ.METHOD; \
   end
package p;
  class cb_t;
    function void phase_state_change(int a, int b);
    endfunction
  endclass
  class d;
    cb_t cb;
    function void run();
      `DO_CB(cb, phase_state_change(1, 2))
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
