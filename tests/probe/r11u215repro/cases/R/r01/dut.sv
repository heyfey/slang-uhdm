// § opIdxRecvElemFollowsPath215 — a class method reading fields[i-1].get() and friends (BuildUVMPkg's uvm_reg_field::is_indv_accessible shape)
package p;
  class fld;
    function int get_lsb_pos(); return 0; endfunction
  endclass
  class reg_c;
    fld fields[$];
    function bit f(int fld_idx);
      int a, b, c, d;
      a = fields[fld_idx].get_lsb_pos();
      b = fields[fld_idx-1].get_lsb_pos();
      c = fields[fld_idx+1].get_lsb_pos();
      d = fields[2].get_lsb_pos();
      if (fields[fld_idx*2].get_lsb_pos() > 0) return 1;
      return fields[fld_idx-1].get_lsb_pos() + fields[fld_idx - 1].get_lsb_pos() > 0;
    endfunction
  endclass
endpackage
module m;
endmodule
