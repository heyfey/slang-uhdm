// § defGenLpRangedTs430
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      localparam [7:0] a = k + j;
      assign o[k] = i[a];
    end
  end
endmodule
