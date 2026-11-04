// § strLitContLineSpan220
module top(input logic clk, output logic [63:0] o);
  always_ff @(posedge clk) o <= "nb\
x";
endmodule
