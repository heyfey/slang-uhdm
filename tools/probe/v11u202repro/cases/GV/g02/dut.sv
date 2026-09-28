// § genVarInitOuterRefUnbound202
module g02 (input logic [7:0] x, output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [7:0] y = x;
    if (1) begin : gi
      logic [7:0] z = y;
      logic [7:0] w = x;
      logic [7:0] v = z;
    end
  end
  assign o = gf[0].gi.z ^ gf[1].gi.w ^ gf[0].gi.v;
endmodule
