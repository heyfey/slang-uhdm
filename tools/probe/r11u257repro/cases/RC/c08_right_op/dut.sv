// § genLpFoldLeftOperandSpan257 (an operation on both bounds)
module common #(parameter int AW = 8, parameter int N = 2)(output logic [AW-1:0] o);
  for (genvar g = 0; g < 2; ++g) begin : g_decoder
    localparam bit [AW-1:AW-4] S = AW'(4 * g);
    assign o = AW'(S);
  end
endmodule
module top; logic [7:0] o; common u(.o(o)); endmodule
