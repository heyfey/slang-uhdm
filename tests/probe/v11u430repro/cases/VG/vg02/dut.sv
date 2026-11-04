// § defGenLpNoBlockListed430
module top (input [3:0] i, output [3:0] o);
  if (0) begin : g
    localparam a = 3;
  end
  assign o = i;
endmodule
