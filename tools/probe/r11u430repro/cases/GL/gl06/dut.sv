// § defGenLpNoBlockListed430
module rr #(parameter n_p=0) (input [3:0] i, output [3:0] o);
  for (genvar j = 0; j < n_p; j++) begin : rof
     localparam a_lp = j;
  end
  assign o = i;
endmodule
