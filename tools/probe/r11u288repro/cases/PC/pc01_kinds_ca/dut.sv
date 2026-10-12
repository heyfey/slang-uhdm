// § parenCastReadsCastSyntax288 — every target kind in parentheses on a continuous-assignment right side
package pk;
  typedef logic [5:0] w6_t;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
endpackage
module m import pk::*; #(parameter int W = 8, parameter type T = logic [3:0])(input logic [7:0] x, output logic [63:0] o[16]);
  typedef logic [2:0] l3_t;
  assign o[0] = (int'(x)) + 1;
  assign o[1] = (byte'(x)) + 1;
  assign o[2] = (shortint'(x)) + 1;
  assign o[3] = (longint'(x)) + 1;
  assign o[4] = (integer'(x)) + 1;
  assign o[5] = (l3_t'(x)) + 1;
  assign o[6] = (pk::w6_t'(x)) + 1;
  assign o[7] = (e_t'(x[1:0])) == B;
  assign o[8] = (s_t'(x)) + 1;
  assign o[9] = (signed'(x)) + 1;
  assign o[10] = (unsigned'(x)) + 1;
  assign o[11] = (4'(x)) + 1;
  assign o[12] = (W'(x)) + 1;
  assign o[13] = (T'(x)) + 1;
  assign o[14] = ((int'(x))) + 1;
  assign o[15] = int'((byte'(x)));
endmodule
module top(input logic [7:0] x, output logic [63:0] o[16]);
  m #(.W(4)) u(.*);
endmodule
