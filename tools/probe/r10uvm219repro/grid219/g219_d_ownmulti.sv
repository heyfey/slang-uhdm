// r10uvm219 grid arm D — MORE THAN ONE NAME THE MODULE'S *OWN* BODY CANNOT
// BIND.  Two `$dumpvars` scope arguments (the module itself and a child
// instance) plus a forwarded block: every module-own mint must stay AFTER the
// whole forwarded block, `this` included.
package pd0;
  class Cd0;
    int pd_a;
    extern function void f1();
  endclass
  function void Cd0::f1();
    int ld_a; pd_a = ld_a; $display("%p", this);
  endfunction
endpackage

module gd_child;
  logic gd_child_clk;
endmodule

module gd_ownmulti;
  import pd0::*;
  logic gd_clk;
  gd_child u_child();
  initial begin
    $dumpvars(0, gd_ownmulti);
    $dumpvars(1, u_child);
  end
endmodule
