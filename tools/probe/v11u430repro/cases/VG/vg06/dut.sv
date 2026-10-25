// § defGenLpNoBlockListed430
module rr #(parameter N = 0) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    localparam a = 3, b = a + k;
  end
  assign o = i;
endmodule
module top (input [3:0] i, output [3:0] o); rr u(.i(i), .o(o)); endmodule
