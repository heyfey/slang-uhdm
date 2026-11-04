// § strLitPpEscIdShift224 (nonblocking assignments in an always_ff, another after the literal)
module top(input logic c, output string o, output int k);
  always_ff @(posedge c) begin o <= "a\nb` c"; k <= 1; end
endmodule
