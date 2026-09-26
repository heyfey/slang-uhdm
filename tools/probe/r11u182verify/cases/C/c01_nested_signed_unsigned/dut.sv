// § sysSignNameSpanSyntax172
module dut #(parameter int N = 2) (input logic [7:0] a, input logic [2:0] s, output logic [7:0] o, p);
  if (N > 1) begin : g
    assign o = $signed($unsigned(a) >>> s);
    assign p = $unsigned($signed(a) + $signed({1'b0, s}));
  end
endmodule
