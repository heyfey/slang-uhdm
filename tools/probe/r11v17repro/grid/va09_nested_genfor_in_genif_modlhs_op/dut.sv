// NESTED: a for-generate inside a gen-if, module-level Lhs, operation Rhs.
module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gouter
    for (genvar i = 0; i < 1; i++) begin : ginner
      logic [31:0] src;
      assign src = a;
      assign mv = src ^ 32'd3;
    end
  end
  assign o = mv;
endmodule
