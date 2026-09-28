// § genVarInitOuterRefUnbound202
module g03(input logic [7:0] m, output logic [7:0] o);
  logic [7:0] q;
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [7:0] y = q;
    if (1) begin : gi
      logic [7:0] z = y;
      logic [7:0] u = q;
    end
  end
  assign o = m;
endmodule
