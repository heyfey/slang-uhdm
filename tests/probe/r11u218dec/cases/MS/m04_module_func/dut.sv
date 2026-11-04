// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m04_module_func: a module function over a class-handle array
package p;
  class f_t;
    function int get_lsb_pos();
      return 1;
    endfunction
  endclass
endpackage
module top(output int o);
  p::f_t fields[4];
  function automatic int g(int k);
    return fields[k*2].get_lsb_pos();
  endfunction
  assign o = 1;
endmodule
