// § genLpFoldAddOperandKinds257v (the add's operand is an earlier localparam of the same generate block)
module common #(parameter int AW = 8)(output logic [31:0] o);
  for (genvar g = 0; g < 1; ++g) begin : g_decoder localparam int L = 3; localparam bit [L+1:0] S = '1; assign o = 32'(S); end
endmodule
module top; logic [31:0] o; common u(.o(o)); endmodule
