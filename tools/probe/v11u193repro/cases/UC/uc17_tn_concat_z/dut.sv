// § caUnsizedRhsClonePerInst193
module m #(parameter bit P = 1) (input logic [1:0] x, output logic a, output logic b);
  assign {a, b} = (P) ? x : 'z;
endmodule
module top (input logic [1:0] x, output logic a, output logic b);
  m #(.P(0)) u_a (.x(x), .a(a), .b(b));
endmodule
