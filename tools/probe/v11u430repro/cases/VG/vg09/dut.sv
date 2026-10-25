// § defGenLpNoBlockListed430
module top #(parameter N = 2, M = 0) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    for (genvar j = 0; j < M; j++) begin : h
      localparam a = k + j;
    end
  end
  assign o = i;
endmodule
