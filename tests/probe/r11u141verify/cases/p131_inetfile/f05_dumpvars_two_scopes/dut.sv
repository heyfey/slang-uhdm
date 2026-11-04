// § implicitNetMintNoFile131
// case f05: $dumpvars with two instance scopes in one call
module sub(input logic a, output logic y);
  assign y = a;
endmodule
module top(input logic a, output logic y1, output logic y2);
  sub u1(.a(a), .y(y1));
  sub u2(.a(a), .y(y2));
  initial $dumpvars(0, u1, u2);
endmodule
