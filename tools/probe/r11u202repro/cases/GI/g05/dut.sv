// § genVarInitOuterRefUnbound202
module g05 #(parameter int P = 3)(input logic [7:0] m, output logic [7:0] o);
  if (1) begin : g1
    localparam int L = 2;
    logic [7:0] y = 8'd1;
    logic [7:0] f = y + m;
    logic [7:0] h = L;
  end
  assign o = m;
endmodule
