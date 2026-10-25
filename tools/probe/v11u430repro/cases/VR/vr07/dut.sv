// § defGenLpRangedTs430
module top #(parameter N = 4) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [N-1:0] a = 1;
    assign o[k] = i[a];
  end
endmodule
