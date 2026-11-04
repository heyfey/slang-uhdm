// § paramFoldParenSpan131
// case q04: a parenthesized default of an interface parameter, instance with an override of the other one
interface ifc #(parameter int A = 2, parameter int P = (A * 2));
  logic [P-1:0] d;
endinterface
module top(output logic [5:0] o);
  ifc #(.A(3)) u();
  assign o = u.d;
endmodule
