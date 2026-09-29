// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m01_arr_minus: a method call on an element of a class-handle array indexed by an arithmetic expression (BuildUVMPkg uvm_pkg.sv:64845)
package p;
  class f_t;
    function int get_lsb_pos();
      return 1;
    endfunction
  endclass
  class r_t;
    f_t fields[$];
    function int g(int fld_idx);
      int prev;
      if (fld_idx > 0) begin
        prev = fields[fld_idx-1].get_lsb_pos();
      end
      return prev;
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
