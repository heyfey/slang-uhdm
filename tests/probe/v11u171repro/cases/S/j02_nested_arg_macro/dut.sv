// § sysSignNameSpanSyntax172
`define ADD(x, y) ((x) + (y))
module dut #(parameter P = 1) (input logic [7:0] a, b, output logic [8:0] y);
  if (P) begin : g
    assign y = `ADD($signed(a), $signed($unsigned(b)));
  end
endmodule
