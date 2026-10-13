// § castAliasSignCastRhsNoClone304v
module top (input logic [3:0] a, output logic signed [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = signed'(idx_t'(a) + 2'd1);
  end
endmodule
