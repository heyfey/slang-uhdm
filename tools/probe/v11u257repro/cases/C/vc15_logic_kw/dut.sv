// § genLpFoldLeftOperandSpan257 (a logic generate localparam inside a nested generate if, the bound over two lines)
module common #(parameter int AW = 8)(output logic [31:0] o);
  if (1) begin : g_if
    for (genvar g = 0; g < 2; ++g) begin : g_decoder
      localparam logic [AW
                        -1:0] S = AW'(g);
      if (g == 1) begin : g_last assign o = 32'(S); end
    end
  end
endmodule
module top; logic [31:0] o; common u(.o(o)); endmodule
