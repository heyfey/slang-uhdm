// § emptyNamedConnLowConnAtDecl137
module sub(.p(q), .r(s));
  input q;
  output s;
  assign s = q;
endmodule
module top(input logic x, output logic y);
  sub u(.p(), .r(y));
endmodule
