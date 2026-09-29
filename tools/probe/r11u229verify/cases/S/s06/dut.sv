// § strLitPpEscIdShift224 (the literal as the first element of a localparam array pattern, the second after it)
module top(output string o, output string p);
  localparam string A [2] = '{"a\nb` c", "de"};
  assign o = A[0];
  assign p = A[1];
endmodule
