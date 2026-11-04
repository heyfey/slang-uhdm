// § defGenLpNoBlockListed430
module rr #(parameter blocks_p=0, width_p=4)
   (input [width_p-1:0] data_i, output [width_p-1:0] data_o);
  for (genvar j = 0; j < blocks_p; j++) begin: rof
     localparam e_lp = j + 1;
     assign data_o[j] = data_i[e_lp];
  end
endmodule
module top (input [3:0] i, output [3:0] o);
  rr #(.blocks_p(0)) u (.data_i(i), .data_o(o));
endmodule
