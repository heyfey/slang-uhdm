// § genLpFoldAddOperandKinds257v (the genvar itself as an add operand)
module common #(parameter int AW = 8)(output logic [31:0] o);
  for (genvar g = 1; g < 2; ++g) begin : g_decoder localparam bit [AW+g:0] S = '1; assign o = 32'(S); end
endmodule
module top; logic [31:0] o; common u(.o(o)); endmodule
