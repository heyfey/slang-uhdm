// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d03_rhs_postinc: a post-increment on a right side
package p;
  class s_t;
    int cnt;
  endclass
  class r_t;
    s_t sp;
    function int g();
      int x;
      x = sp.cnt++;
      return x;
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
