// r10v68 arm v5 — ENUM and 4-state/unknown Lhs kinds, isolated so a tool
// rejection cannot mask the other arms.  MEASUREMENT ONLY.
typedef enum logic [2:0] { E0, E1, E2, E3, E4, E5, E6, E7 } v5_e68;
module v5_enum68 (input logic [7:0] din, output logic [7:0] dout);
  v5_e68      ev;
  logic [2:0] e3;
  for (genvar i = 4; i < 6; i++) begin : g_e
    if (i >= 4) begin : b1
      if (i == 4) begin : c0 assign ev = v5_e68'(i); end   // CAST Rhs
      if (i == 5) begin : c1 assign e3 = i; end            // 3-bit target
    end
  end
  assign dout = {5'b0, e3} ^ {5'b0, ev} ^ din;
endmodule
