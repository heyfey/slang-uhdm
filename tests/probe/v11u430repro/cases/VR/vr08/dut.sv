// § defGenLpRangedTs430
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [7:0] a = 8'h1, b = 2;
    assign o[k] = i[a + b];
  end
endmodule
