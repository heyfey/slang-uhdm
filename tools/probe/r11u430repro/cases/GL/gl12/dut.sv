// § defGenLpNoBlockListed430
module rr #(parameter n_p=0) (input [3:0] i, output [3:0] o);
  for (genvar j = 0; j < n_p; j++) begin : rof
     localparam logic [3:0] c_lp = 4'd3;
     localparam signed [3:0] d_lp = -1;
     localparam e_lp [2] = '{1, 2};
     localparam f_lp = 5, g_lp = f_lp + j;
  end
  assign o = i;
endmodule
module top (input [3:0] i, output [3:0] o);
  rr #(.n_p(0)) u(.i(i), .o(o));
endmodule
