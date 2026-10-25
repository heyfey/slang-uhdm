// § defGenLpNoBlockListed430
module rr #(parameter N = 2) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    localparam a = k;
  end
  assign o = i;
endmodule
module top (input [3:0] i, output [3:0] o, output [3:0] o2);
  rr #(.N(0)) u0(.i(i), .o(o));
  rr #(.N(2)) u2(.i(i), .o(o2));
endmodule
