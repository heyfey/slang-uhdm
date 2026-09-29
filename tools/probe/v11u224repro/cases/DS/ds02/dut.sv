// § strLitPpEscIdShift224
module top(input logic clk, input logic a, output logic y);
  always_ff @(posedge clk) begin if (a) $display("a\nb` c"); y <= a; end
endmodule
