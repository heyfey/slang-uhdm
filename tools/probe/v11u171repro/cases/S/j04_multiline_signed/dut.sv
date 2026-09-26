// § sysSignNameSpanSyntax172
module dut #(parameter P = 1) (input logic [7:0] a, b, output logic [8:0] y);
  if (P) begin : g
    assign y = $signed(
                 a
               ) * $signed(b);
  end
endmodule
