// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d07_index_in_operand_ctl: control: the path is an index inside the operand, a[sp.cnt]++ as an argument
package p;
  class s_t;
    int cnt;
    int arr[4];
  endclass
  class r_t;
    s_t sp;
    int a[4];
    function void set(int v);
    endfunction
    function void g();
      set(a[sp.cnt]++);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
