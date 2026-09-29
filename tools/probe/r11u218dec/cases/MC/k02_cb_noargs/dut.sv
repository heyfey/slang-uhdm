// r11u218 decode (no law written; the face named macroArgMethodCallSpan218 in the README) — k02_cb_noargs: the argument is a method name without arguments
`define DO_CB(OBJ,METHOD) \
   begin \
     OBJ.METHOD(); \
   end
package p;
  class cb_t;
    function void phase_state_change();
    endfunction
  endclass
  class d;
    cb_t cb;
    function void run();
      `DO_CB(cb, phase_state_change)
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
