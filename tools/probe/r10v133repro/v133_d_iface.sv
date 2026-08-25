// r10v133 arm D - interfaces, modports, virtual interfaces and THREE
// instances: the elaborated roads.  MEASUREMENT ONLY.
interface vif133 #(parameter int PW = 8) (input logic clk);
  logic [PW-1:0] dat;
  int            iq[$];
  function automatic int ifn133(); return PW; endfunction
  modport mp (input clk, output dat, import ifn133);
endinterface

package pv133d;
  function automatic int dfn133(); return 6; endfunction
endpackage

module vleaf133 #(parameter int PL = 3) (vif133 vi, output int ol);
  import pv133d::*;
  int lq[$];
  function automatic int lfn133(); return PL; endfunction
  always_comb begin
    ol = $bits(lfn133()) + $bits(lq.size()) + $bits(dfn133()) + $bits(vi.ifn133()) + $bits(vi.iq.size());
  end
endmodule

module vm133d (input logic clk, output int od);
  int o1, o2, o3;
  vif133 #(.PW(8))  if_a (.clk(clk));
  vif133 #(.PW(12)) if_b (.clk(clk));
  vleaf133 #(.PL(3)) ua (.vi(if_a), .ol(o1));
  vleaf133 #(.PL(4)) ub (.vi(if_b), .ol(o2));
  vleaf133 #(.PL(5)) uc (.vi(if_a), .ol(o3));
  assign od = o1 + o2 + o3;
endmodule
