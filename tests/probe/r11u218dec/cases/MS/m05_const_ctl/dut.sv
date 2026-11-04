// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m05_const_ctl: control: a constant index
package p;
  class f_t;
    function int get_lsb_pos();
      return 1;
    endfunction
  endclass
  class r_t;
    f_t fields[$];
    function int g();
      return fields[2].get_lsb_pos();
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
