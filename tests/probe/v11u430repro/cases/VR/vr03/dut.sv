// § defGenLpRangedTs430
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [1:0][3:0] a = 8'h12;
    assign o[k] = i[a[0]];
  end
endmodule
