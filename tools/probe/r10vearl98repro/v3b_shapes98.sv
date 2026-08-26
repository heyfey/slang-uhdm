// v98 V3b -- GENERATE SHAPES, with the Rhs operands declared IN the gen scope
// (the only shape deep20 can bind) and every Lhs name shadowed at d1.
module v3bleaf98 (input logic clk, input logic [3:0] a, output logic [5:0] o);
  for (genvar i = 0; i < 1; i++) begin : gen_one
    logic [3:0] c1, c2;
    logic s_for;
    assign s_for = (c1 == c2);
    assign o[0] = s_for;
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; end
  end
  for (genvar j = 0; j < 3; j++) begin : gen_three
    logic [3:0] c1, c2;
    logic s_for3;
    assign s_for3 = (c1 != c2);
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; end
  end
  assign o[1] = gen_three[0].s_for3 ^ gen_three[1].s_for3 ^ gen_three[2].s_for3;
  if (1) begin : gen_outer
    logic [3:0] c1, c2;
    logic s_nest;
    assign s_nest = (c1 < c2);
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; end
    if (1) begin : gen_inner
      logic [3:0] d1, d2;
      logic s_deep;
      assign s_deep = (d1 > d2);
      always_ff @(posedge clk) begin d1 <= a; d2 <= d1; end
    end
    assign o[2] = s_nest ^ gen_inner.s_deep;
  end
  if (1) begin : gen_twinA
    logic [3:0] c1, c2;
    logic s_twin;                       // SAME name in two sibling gen scopes
    assign s_twin = (c1 & c2) != 0;
    assign o[3] = s_twin;
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; end
  end
  if (1) begin : gen_twinB
    logic [3:0] c1, c2;
    logic s_twin;
    assign s_twin = (c1 | c2) != 0;
    assign o[4] = s_twin;
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; end
  end
  if (1) begin : gen_use
    logic [3:0] c1, c2;
    logic s_both, s_seen;
    assign s_both = (c1 <= c2);         // continuous drive, procedural read
    always_ff @(posedge clk) begin c1 <= a; c2 <= c1; s_seen <= s_both; end
    assign o[5] = s_seen;
  end
endmodule
module v3b_shapes98 (input logic clk, input logic [3:0] a, output logic [5:0] o);
  logic s_for, s_for3, s_nest, s_deep, s_twin, s_both;   // ALL shadowed at d1
  assign s_for = 1'b0;
  v3bleaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
