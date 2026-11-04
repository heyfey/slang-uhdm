// § genVarInitOuterRefUnbound202
module g01(input logic [7:0] m, output logic [7:0] o);
  logic [7:0] q;
  wire [7:0] w;
  if (1) begin : g1
    logic [7:0] x = 8'd5;
    logic [7:0] a = x;
    logic [7:0] b = q;
    logic [7:0] c = w;
    logic [7:0] d = m;
  end
  assign o = m;
endmodule
