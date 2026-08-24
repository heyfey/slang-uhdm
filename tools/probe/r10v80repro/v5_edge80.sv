// r10v80 v5_edge80.sv — ADVERSARIAL EDGE SHAPES for § ovHopOverriddenKeepsValue80.
// MEASUREMENT ONLY.
module v5_lf #(parameter int unsigned E = 4)();
  wire [31:0] w = E;
endmodule
module v5_h3 #(parameter int unsigned D = 3)();
  v5_lf #(.E(D)) u();
endmodule
module v5_h2 #(parameter int unsigned C = 2)();
  v5_h3 #(.D(C)) u();
endmodule
module v5_h1 #(parameter bit [3:0] B = 4'h1)();
  v5_h2 #(.C(B)) u();
endmodule
module v5_h1b #(parameter logic [7:0] B = 8'h1, parameter int unsigned K = 5)();
  v5_h2 #(.C(B)) u();
  v5_h3 #(.D(K)) v();
endmodule
module v5_dp #(parameter bit [3:0] B = 4'h1)();
  v5_h2 #(.C(B)) u();
endmodule
module topv5 #(parameter bit [3:0] TOPB = 4'h9,
               parameter int unsigned TOPI = 8'hab)();
  // 1. POSITIONAL (unnamed) override actuals
  v5_h1  #(4'h2) u_pos0();
  v5_h1b #(8'hff, 4'h3) u_pos1();
  // 2. the TOP module's own parameter (overridable with -G) passed down
  v5_h1 #(.B(TOPB)) u_top0();
  v5_h2 #(.C(TOPI)) u_top1();
  // 3. defparam on an instance
  v5_dp u_dp0();
  defparam u_dp0.B = 4'h5;
  // 4. a hierarchical reference as the actual
  v5_h1 #(.B(4'h6)) u_src();
  // (hierarchical actual removed: not a constant expression without --allow-hierarchical-const)
  // 5. an override actual that reads an OVERRIDDEN parameter of a SIBLING
  //    instance through a localparam
  localparam bit [3:0] LP = 4'h7;
  v5_h1 #(.B(LP)) u_lp0();
  // 6. an unbased-unsized fill and its '1 twin through the chain
  v5_h1 #(.B('0)) u_z0();
  v5_h1 #(.B('1)) u_o0();
  // 7. a WIDE literal narrowed by the formal
  v5_h1 #(.B(64'hFFFF)) u_w0();
  // 8. two DIFFERENT overrides of the same module, three instances
  v5_h1 #(.B(4'h1)) u_m0();
  v5_h1 #(.B(4'h2)) u_m1();
  v5_h1 #(.B(4'h1)) u_m2();
endmodule
