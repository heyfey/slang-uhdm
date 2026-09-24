// r10uvm99 arm a8: class-scope methods, DEF vs ELAB copies, several instances.
package kappa99_pkg;
  class lam99;
    int fld99;
    function bit chk(int qv);
      if (qv inside {[1:3]}) return 1;
      return 0;
    endfunction
    extern function bit oob(int qv);
  endclass
  function bit lam99::oob(int qv);
    return qv inside {[4:6]};
  endfunction
endpackage
module mu99;
  import kappa99_pkg::*;
  lam99 i1, i2, i3;
  int outv99;
  initial begin
    i1 = new(); i2 = new(); i3 = new();
    if (i1.chk(2)) outv99 = 1;
  end
endmodule
