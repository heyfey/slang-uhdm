// § sysSignNameSpanSyntax172
module dut #(parameter int N = 3) (input logic [7:0] a, output logic [7:0] y [3]);
  for (genvar i = 0; $signed(i) < $signed(N); i++) begin : g
    assign y[i] = $signed(a) >>> i;
  end
endmodule
