// § strLitShiftNeedsBacktick220
module top(input logic clk, output logic [63:0] o);
  always_ff @(posedge clk) o <= "a\\b";
endmodule
