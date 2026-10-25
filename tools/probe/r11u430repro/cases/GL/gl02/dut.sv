// § defGenLpNoBlockListed430
module rr #(parameter blocks_p=0, width_p=0, group_vec_p=0)
   (input [width_p-1:0] data_i, output [width_p-1:0] data_o);
   genvar j;
  for (j = 0; j < blocks_p;j=j+1)
     begin: rof
        localparam group_end_lp   = (group_vec_p >> ((j+1) << 3 )) & 8'hFF;
        localparam group_start_lp = (group_vec_p >> ((j  ) << 3 )) & 8'hFF;
        assign data_o[group_end_lp-1:group_start_lp] = data_i[group_end_lp-1:group_start_lp];
     end
endmodule
module top (input [15:0] i, output [15:0] o);
    rr #(.blocks_p(2), .width_p(16), .group_vec_p(24'h10_08_00)) u (.data_i(i), .data_o(o));
endmodule
