// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d04_callarg_preinc: a pre-increment as a call argument
package p;
  class s_t;
    int cnt;
  endclass
  class r_t;
    s_t sp;
    function void set(int a);
    endfunction
    function void g();
      set(++sp.cnt);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
