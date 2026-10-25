// § defGenLpNoBlockListed430
module rr #(parameter N = 0) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    localparam a = 3;
    wire [3:0] w = i + a;
  end
  assign o = i;
endmodule
