// § defGenLpRangedTs430
module top (input [3:0] i, output [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    localparam [7:0] a [2] = '{8'h1, 8'h2};
    assign o = a[1];
  end
endmodule
