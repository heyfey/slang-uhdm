// § defGenConnPsExprBounds424 (bsg_mem_1rw_sync_mask_write_var shape)
module m #(parameter w = 2) (input [w-1:0] data_i); endmodule
module top #(parameter mask_width_p = 4) (input [15:0] data_i);
  genvar i;
  for (i = 0; i < 2; i++) begin : mem
    m #(.w(mask_width_p)) u (.data_i(data_i[(i+1)*mask_width_p-1:i*mask_width_p]));
  end
endmodule
