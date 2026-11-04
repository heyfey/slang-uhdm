// § defGenInitBitSelAtIndex202 § genVarInitOuterRefUnbound202 § defGenInitRhsKeepsParent200
module g04(input logic [7:0] q, output logic [7:0] o);
  logic [7:0] r;
  for (genvar i = 0; i < 3; i++) begin : gf
    logic [7:0] loc = q;
    if (i == 1) begin : gi
      logic [1:0] z = q[i+1:i];
      logic y = loc[i];
      logic x = z[0];
      logic [7:0] u = r;
    end
  end
  assign r = q;
  assign o = {6'b0, gf[1].gi.z} ^ {7'b0, gf[1].gi.y} ^ {7'b0, gf[1].gi.x} ^ gf[1].gi.u;
endmodule
