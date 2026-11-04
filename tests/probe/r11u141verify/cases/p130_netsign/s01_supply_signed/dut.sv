// § netSigningTsSpan130
// case s01: tri0/tri1/wor nets with a signing keyword
module top(output logic [11:0] o);
  tri0 signed [3:0] a;
  tri1 unsigned [3:0] b;
  wor signed [3:0] c;
  assign o = {a, b, c};
endmodule
