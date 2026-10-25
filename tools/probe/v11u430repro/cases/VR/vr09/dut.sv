// § defGenLpRangedTs430
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam signed [7:0] a = -1;
    assign o[k] = i[a + 2];
  end
endmodule
