// r10v83 arm 5 — THE SPAN AND WHITESPACE MATRIX.  The folded constant must
// wear the span of the WHOLE cast text, byte for byte, including the
// based-literal space strip.  MEASUREMENT ONLY.
module snk5_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module v5_span83;
  localparam int W83 = 12;
  logic [63:0] s0,s1,s2,s3,s4,s5,s6,s7;

  // P01 spaces inside the parentheses
  snk5_83 p01 (.a(W83'( 0 )),            .y(s0));
  // P02 a space between the size and the base
  snk5_83 p02 (.a(24'(24 'h FFFFFF)),    .y(s1));
  // P03 a space between the base and the digits
  snk5_83 p03 (.a(24'(24'h FFFFFF)),     .y(s2));
  // P04 underscores in the literal
  snk5_83 p04 (.a(32'(32'h1234_5678)),   .y(s3));
  // P05 the cast written across TWO LINES
  snk5_83 p05 (.a(W83'(
                   5)),                  .y(s4));
  // P06 the cast wrapped in redundant parentheses
  snk5_83 p06 (.a(((W83'(6)))),          .y(s5));
  // P07 a space before the tick
  snk5_83 p07 (.a(W83 '(7)),             .y(s6));

  assign s7 = s0^s1^s2^s3^s4^s5^s6;
endmodule
