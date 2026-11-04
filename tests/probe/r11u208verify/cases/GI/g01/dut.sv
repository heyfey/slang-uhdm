// § defGenInitBitSelAtIndex202 § defGenInitRhsKeepsParent200 § genVarInitOuterRefUnbound202
module g01(input logic [3:0][7:0] w, input logic [7:0] m [4], output logic [7:0] o);
  if (1) begin : g
    logic [7:0] a = w[1];
    logic b = w[2][3];
    logic [3:0] c = w[3][7:4];
    logic [7:0] d = m[2];
    logic e = m[1][0];
  end
  assign o = g.a ^ g.d ^ {6'b0, g.b, g.e} ^ {4'b0, g.c};
endmodule
