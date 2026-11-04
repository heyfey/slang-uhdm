// § genLpFoldLeftOperandSpan257 (a generate-block localparam with a parameter-minus-one range, two-line initializer)
module common #(parameter int AW = 8, parameter bit [AW-1:0] OFF = '0)(output logic [AW-1:0] o);
  for (genvar g = 0; g < 1; ++g) begin : g_decoder
    localparam bit [AW-1:0] S = OFF
                                + AW'(4 * g);
    assign o = S;
  end
endmodule
module top; logic [7:0] o; common u(.o(o)); endmodule
