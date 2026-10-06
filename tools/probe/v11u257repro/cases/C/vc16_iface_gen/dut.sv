// § genLpFoldLeftOperandSpan257 (a generate localparam inside an interface)
interface ifc #(parameter int AW = 8); logic [31:0] o;
  for (genvar g = 0; g < 1; ++g) begin : g_decoder localparam bit [AW-1:0] S = '1; assign o = 32'(S); end
endinterface
module top; ifc i(); endmodule
