// r10earl118 VERIFIER arm v4_ancname -- A NAMESAKE IN AN ENCLOSING *GENERATE*
// SCOPE.  r10earl118's fence deliberately SKIPS generate scopes ("a namesake in
// an enclosing GENERATE block is NOT found and does not lift the suppress").
// These rows measure what GOLDEN does in exactly that shape.
// MEASUREMENT ONLY.  Legal SystemVerilog; scored against the GOLDEN database.
module v4_sib (input logic [7:0] din, output logic [7:0] o);
  assign o = din;
endmodule

module v4_ancname (input logic [7:0] din, input logic c, output logic [7:0] dout);
  logic [7:0] modonly;

  // A: ONE level of nesting, ancestor gen-local VARIABLE namesake
  for (genvar k = 0; k < 2; k++) begin : ab
    logic [7:0] a_var;                        // the ANCESTOR's variable
    assign a_var = din ^ 8'h11;
    if (1) begin : an
      logic [7:0] a_var;                      // shadows it, own-scope, CAST Rhs
      assign a_var = $bits(a_var)'({din[3:0], 4'b0});
      logic [7:0] a_free;                     // no namesake at all (control)
      assign a_free = $bits(a_free)'({din[3:0], 4'b0});
      logic [7:0] a_ctl;                      // namesake + NON-cast Rhs (control)
      assign a_ctl = din ^ 8'h22;
    end
  end

  // B: the ancestor namesake is a NET
  for (genvar k = 0; k < 2; k++) begin : bb
    wire [7:0] b_net;
    assign b_net = din ^ 8'h33;
    if (1) begin : bn
      logic [7:0] b_net;
      assign b_net = $bits(b_net)'({din[3:0], 4'b0});
    end
  end

  // C: the ancestor namesake is a PARAMETER (bindVariable cannot see one)
  for (genvar k = 0; k < 2; k++) begin : cb
    localparam int c_par = 8;
    if (1) begin : cn
      logic [7:0] c_par;
      assign c_par = $bits(c_par)'({din[3:0], 4'b0});
    end
  end

  // D: the namesake is in a SIBLING generate block, not an ancestor
  for (genvar k = 0; k < 2; k++) begin : db
    if (k == 0) begin : d1
      logic [7:0] d_sib;
      assign d_sib = din ^ 8'h44;
    end
    if (k == 1) begin : d2
      logic [7:0] d_sib;
      assign d_sib = $bits(d_sib)'({din[3:0], 4'b0});
    end
  end

  // E: the ancestor's declaration comes AFTER the inner block textually
  for (genvar k = 0; k < 2; k++) begin : eb
    if (1) begin : en
      logic [7:0] e_late;
      assign e_late = $bits(e_late)'({din[3:0], 4'b0});
    end
    logic [7:0] e_late;
    assign e_late = din ^ 8'h55;
  end

  // F: TWO ancestor levels above (the shape v2_fenceface found)
  for (genvar k = 0; k < 2; k++) begin : fb
    logic [7:0] f_deep;
    assign f_deep = din ^ 8'h66;
    for (genvar j = 0; j < 2; j++) begin : fn
      logic [7:0] f_deep;
      assign f_deep = $bits(f_deep)'({din[3:0], 4'b0});
    end
  end

  assign modonly = din | 8'h01;
  assign dout = modonly ^ ab[0].an.a_var ^ ab[1].an.a_free ^ ab[0].an.a_ctl ^
                bb[1].bn.b_net ^ cb[0].cn.c_par ^ db[1].d2.d_sib ^
                eb[0].en.e_late ^ fb[1].fn[0].f_deep;
endmodule
