// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m02_arr_plain: a plain index
package p;
  class f_t;
    function int get_lsb_pos();
      return 1;
    endfunction
  endclass
  class r_t;
    f_t fields[$];
    function int g(int fld_idx);
      return fields[fld_idx].get_lsb_pos();
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
