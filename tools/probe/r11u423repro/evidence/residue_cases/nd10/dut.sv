// residue (no law landed): sister ground, see README
module top #(parameter W = 4) (input real r);
  if (W > 2) begin : g
    wire [63:0] n = $realtobits(r);
    wire [63:0] m;
    assign m = $realtobits(r);
  end
endmodule
