// § genVarInitOuterRefUnbound202
module g06(input logic [7:0] m, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] w = m ^ 8'h5a;
  if (1) begin : g1
    logic [7:0] a = w;
    logic [7:0] x = 8'd3;
    logic [7:0] b = x;
  end
  assign o = g1.a;
  assign o2 = g1.b;
endmodule
