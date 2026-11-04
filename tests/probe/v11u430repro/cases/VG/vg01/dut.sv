// § defGenLpNoBlockListed430
module top #(parameter N = 0) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    localparam a = k + 1;
  end
  assign o = i;
endmodule
