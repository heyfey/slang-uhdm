// § genVarInitOuterRefUnbound202 § defGenInitRhsKeepsParent200 § defGenInitBitSelAtIndex202
package p;
  localparam logic [7:0] K = 8'h5a;
  localparam int W = 3;
endpackage
module g02(input logic [7:0] q, output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [7:0] a = p::K;
    logic [7:0] b = i;
    logic c = q[i];
    logic [7:0] d = p::K + i;
    logic e = q[p::W];
  end
  assign o = gf[0].a ^ gf[1].b ^ {7'b0, gf[1].c} ^ gf[0].d ^ {7'b0, gf[0].e};
endmodule
