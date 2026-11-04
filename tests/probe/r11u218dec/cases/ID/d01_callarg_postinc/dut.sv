// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d01_callarg_postinc: a post-increment of a dotted class path as a call argument (BuildUVMPkg uvm_pkg.sv:54011)
package p;
  class s_t;
    int cnt;
  endclass
  class r_t;
    s_t sp;
    function void set(int a);
    endfunction
    function void g();
      set(sp.cnt++);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
