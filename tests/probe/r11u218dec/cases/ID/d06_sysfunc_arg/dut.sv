// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d06_sysfunc_arg: a post-increment inside a system call argument
package p;
  class s_t;
    int cnt;
    int arr[4];
  endclass
  class r_t;
    s_t sp;
    function void g();
      $display("%0d", sp.cnt++);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
