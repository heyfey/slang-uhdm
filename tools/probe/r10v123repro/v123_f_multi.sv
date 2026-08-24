// r10v123 arm F — 1..3 INSTANCES of the same module casting the same package
// typedef, plus a generate loop, so a per-instance re-emission cannot mint a
// diverging clone.
package nutmeg123_pkg;
  parameter int NUT_W = 6;
  typedef bit   [NUT_W-1:0] nut_v_t;
  typedef logic [3:0]       nut_l_t;
  function automatic int nut_home(int qq);
    nut_v_t v; nut_l_t l;
    v = nut_v_t'(qq);
    l = nut_l_t'(qq);
    return int'(v) + int'(l);
  endfunction
endpackage

module nut_leaf #(parameter int ID = 0) (input logic clk, output int oo);
  import nutmeg123_pkg::*;
  nut_v_t vv;
  nut_l_t ll;
  assign vv = nut_v_t'(ID);
  assign ll = nut_l_t'(ID + 1);
  function automatic int leaf_sub(int qq);
    nut_v_t s1;
    s1 = nut_v_t'(qq);
    return int'(s1);
  endfunction
  assign oo = int'(vv) + int'(ll) + leaf_sub(ID);
endmodule

module nut_top(input logic clk);
  import nutmeg123_pkg::*;
  int o0, o1, o2;
  nut_leaf #(.ID(0)) i0 (.clk(clk), .oo(o0));
  nut_leaf #(.ID(1)) i1 (.clk(clk), .oo(o1));
  nut_leaf #(.ID(2)) i2 (.clk(clk), .oo(o2));
  genvar gi;
  generate
    for (gi = 0; gi < 3; gi++) begin : gband
      nut_v_t gv;
      assign gv = nut_v_t'(gi);
    end
  endgenerate
  initial begin
    int rr;
    rr = o0 + o1 + o2 + nut_home(4);
  end
endmodule
