// § defGenLpNoBlockListed430
module rr #(parameter n_p=0) (input [3:0] i, output [3:0] o);
  genvar j;
  for (j = 0; j < n_p; j = j + 1) begin : rof
     localparam a_lp = (n_p >> j) & 8'hFF;
     localparam int t_lp = 3;
     localparam [3:0] s_lp = a_lp - 1, u_lp = 2;
  end
  assign o = i;
endmodule
module top (input [3:0] i, output [3:0] o);
  assign o = i;
endmodule
