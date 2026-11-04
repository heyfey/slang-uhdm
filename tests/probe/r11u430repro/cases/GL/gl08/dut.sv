// § defGenLpRangedTs430
module top #(parameter n_p=2) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < n_p; k++) begin : w
     localparam [7:0] a = k;
     localparam b = k + 1;
     assign o[k] = i[a];
  end
endmodule
