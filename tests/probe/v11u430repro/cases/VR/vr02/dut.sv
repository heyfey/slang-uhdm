// § defGenLpRangedTs430
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [0:7] a = 5;
    assign o[k] = i[a - 3];
  end
endmodule
