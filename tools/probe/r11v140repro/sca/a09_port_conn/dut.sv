// § sysArgUnaryWholeSpan140
module sub(input logic [7:0] i, output logic [7:0] q);
  assign q = i;
endmodule
module top(input logic [7:0] a, output logic [7:0] o);
  sub u(.i($unsigned(~a)), .q(o));
endmodule
