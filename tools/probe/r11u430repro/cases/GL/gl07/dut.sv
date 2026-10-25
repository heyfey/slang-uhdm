// § defGenLpRangedTs430
module rr #(parameter n_p=2) (input [3:0] i, output [3:0] o);
  genvar k;
  for (k = 0; k < n_p; k = k + 1) begin : w
     localparam [31:0] x7 = 3 + k - 1;
     localparam [31:0] x6 = 5;
     assign o[k] = i[x7];
  end
endmodule
module top (input [3:0] i, output [3:0] o);
  rr u(.i(i), .o(o));
endmodule
