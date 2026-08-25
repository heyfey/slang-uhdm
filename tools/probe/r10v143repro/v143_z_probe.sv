// r10v143 — WHICH SHAPE MAKES OUR EMITTER BIND?  one class, eight bodies.
package pkZ143v;
  class ElZ; int tally; int gauge; endclass
  class LedZ;
    ElZ rows[int];
    ElZ ridge[ElZ];
    int plain[int];
    function int z1_ret_fn(int k = 0);
      return rows[k].tally;                       // function + return
    endfunction
    function int z2_if_fn(int k = 0);
      if (rows[k].tally == 0) $display("z2");
      return 0;
    endfunction
    task z3_if_tk(int k = 0);
      if (rows[k].tally == 0) $display("z3");
    endtask
    task z4_asgn_tk(int k = 0);
      int t;
      t = rows[k].tally;                          // task + rvalue assign
    endtask
    function int z5_asgn_fn(int k = 0);
      int t;
      t = rows[k].tally;                          // function + rvalue assign
      return t;
    endfunction
    task z6_lhs_tk(int k = 0);
      rows[k].tally = 3;                          // lvalue
    endtask
    function int z7_disp_fn(int k = 0);
      $display("z7", rows[k].gauge);              // call argument
      return 0;
    endfunction
    task z8_hk_tk(ElZ h = null);
      if (ridge[h].tally == 0) $display("z8");    // handle key
    endtask
  endclass
endpackage
module topZ143v;
  pkZ143v::LedZ b;
  initial begin b = new(); b.z3_if_tk(); end
endmodule
