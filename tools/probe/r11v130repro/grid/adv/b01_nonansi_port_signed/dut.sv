// § netSigningTsSpan130
module sub(p, q);
  input p;
  output q;
  wire signed [7:0] p;
  wire signed [7:0] q;
  assign q = p;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.p(i), .q(o));
endmodule
