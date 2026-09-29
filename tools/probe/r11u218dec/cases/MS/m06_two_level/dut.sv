// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m06_two_level: a two-level receiver r.fields[k-1]
package p;
  class f_t;
    function int get_lsb_pos();
      return 1;
    endfunction
  endclass
  class h_t;
    f_t fields[$];
  endclass
  class r_t;
    h_t h;
    function int g(int k);
      return h.fields[k-1].get_lsb_pos();
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
