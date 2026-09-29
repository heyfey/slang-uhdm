// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d02_stmt_postinc: a post-increment statement
package p;
  class s_t;
    int cnt;
  endclass
  class r_t;
    s_t sp;
    function void g();
      sp.cnt++;
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
