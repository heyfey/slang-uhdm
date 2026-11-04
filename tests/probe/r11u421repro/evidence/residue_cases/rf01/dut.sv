// residue (no law landed): a parenthesized indexed-part-select base in a gen-block port connection (sister ground, async_fifo), see README
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter width_p = 8, parameter c = 2) (input [width_p-1:0] di);
  if (1) begin: ctrl
    m #(.w(c)) u (.d(di[(width_p-1)-:c]));
  end
endmodule
