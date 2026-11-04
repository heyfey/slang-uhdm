// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d05_method_arg: a post-decrement as a method call argument, o.set(sp.cnt--)
package p;
  class s_t;
    int cnt;
    int arr[4];
  endclass
  class q_t;
    function void set(int a);
    endfunction
  endclass
  class r_t;
    s_t sp;
    q_t o;
    function void g();
      o.set(sp.cnt--);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
