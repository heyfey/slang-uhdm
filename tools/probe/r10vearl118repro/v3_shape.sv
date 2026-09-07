// r10earl118 VERIFIER arm v3_shape -- generate SHAPES and target KINDS the flag
// must leave exactly where pristine left them, plus the ones it must move.
// MEASUREMENT ONLY.  Legal SystemVerilog; scored against the GOLDEN database.
module v3_leaf (input logic [7:0] din, output logic [7:0] o);
  logic [7:0] leaf_tgt;                     // a MODULE-BODY target of a module
  assign leaf_tgt = $bits(leaf_tgt)'({din[3:0], 4'b0});   // INSTANTIATED in a gen scope
  assign o = leaf_tgt;
endmodule

module v3_shape (input logic [7:0] din, input logic [1:0] sel, output logic [7:0] dout);
  logic [7:0] tie;
  // g1 an UNNAMED if-generate block
  if (1) begin
    logic [7:0] u1;  assign u1 = $bits(u1)'({din[3:0], 4'b0});
    logic [7:0] u2;  assign u2 = din ^ 8'h0f;
  end
  // g2 a CASE-generate block
  case (2)
    2: begin : cg
      logic [7:0] k1;  assign k1 = $bits(k1)'({din[3:0], 4'b0});
      logic [7:0] k2;  assign k2 = din ^ 8'h0f;
    end
    default: begin : dg
      logic [7:0] k3;  assign k3 = 8'h00;
    end
  endcase
  // g3 a module INSTANTIATED inside a generate scope: its own body's target
  for (genvar k = 0; k < 2; k++) begin : mb
    v3_leaf u_leaf (.din(din), .o());
    // g4 an UNPACKED-ARRAY gen-local element target with a cast Rhs
    logic [7:0] arr [0:1];
    assign arr[k] = $bits(din)'({din[3:0], 4'b0});
    // g5 a gen-local target assigned with a cast, DEEP in three gen levels
    if (k == 0) begin : l2
      if (1) begin : l3
        logic [7:0] deep3;  assign deep3 = $bits(deep3)'({din[3:0], 4'b0});
      end
    end
    // g6 a gen-local target whose cast Rhs reads an ANCESTOR gen local
    logic [7:0] rd;  assign rd = $bits(rd)'({din[3:0], 4'b0});
  end
  assign tie = din;
  assign dout = tie ^ mb[0].arr[0] ^ mb[1].rd ^ mb[0].l2.l3.deep3 ^ cg.k1 ^ cg.k2;
endmodule
