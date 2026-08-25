// v92 adversarial arm 5 — HOMES and INSTANCE MULTIPLICITY.
// interface home, a bind instance, a 3-deep chain, three instantiations of one
// module from ONE span with different overrides, and a defparam'd condition.
interface v5_if #(parameter bit EN = 1) (input logic [7:0] k);
  logic [3:0] y;
  assign y = EN ? (k[5] ^ k[1]) : 4'h0;
endinterface

module v5_leaf #(parameter bit EN = 1) (input logic [7:0] k, output logic [3:0] y);
  assign y = EN ? (k[5] ^ k[2]) : 4'h0;
endmodule

module v5_mid #(parameter bit EN = 1) (input logic [7:0] k, output logic [3:0] y);
  v5_leaf #(.EN(EN)) u_leaf (.k(k), .y(y));
endmodule

module v5_top2 (input logic [7:0] k, output logic [3:0] y);
  assign y = 4'h0;
endmodule

module v5_bindee #(parameter bit EN = 1) (input logic [7:0] k);
  logic [3:0] yb;
  assign yb = EN ? (k[4] ^ k[1]) : 4'h0;
endmodule

module v5_home (input logic [7:0] k, output logic [3:0] o);
  logic [3:0] y0, y1, y2, ym, yi;
  // three instantiations from ONE span, different overrides
  v5_leaf #(.EN(1)) u0 (.k(k), .y(y0));
  v5_leaf #(.EN(0)) u1 (.k(k), .y(y1));
  v5_leaf #(.EN(1)) u2 (.k(k), .y(y2));
  // a 3-deep chain
  v5_mid  #(.EN(1)) u_mid (.k(k), .y(ym));
  // interface home
  v5_if   #(.EN(1)) u_if (.k(k));
  assign yi = u_if.y;
  // a bind target
  v5_top2 u_t2 (.k(k), .y());
  assign o = y0 ^ y1 ^ y2 ^ ym ^ yi;
endmodule

bind v5_top2 v5_bindee #(.EN(1)) u_bnd (.k(k));
