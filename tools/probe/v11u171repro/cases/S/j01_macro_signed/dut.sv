// § sysSignNameSpanSyntax172
`define S(x) $signed(x)
module dut #(parameter P = 1) (input logic [7:0] a, b, output logic [8:0] y, z);
  if (P) begin : g
    assign y = `S(a) + $signed(b);
    assign z = $unsigned (a) - `S({1'b0, b});
  end
endmodule
