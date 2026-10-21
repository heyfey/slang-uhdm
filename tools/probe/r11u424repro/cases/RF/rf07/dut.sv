// § defGenConnIpsExprBounds424
`define blk 8
`define clause(num) if ((width_p % `blk) == num) begin: z\
   m #(.w(num)) u (.d(di[width_p-1-:num])); end
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter width_p = 9) (input [width_p-1:0] di);
  genvar i;
  for (i = 0; i < (width_p/`blk); i = i + 1) begin : maxb
    m #(.w(`blk)) v (.d(di[i*`blk+:`blk]));
  end
  `clause(1)
endmodule
