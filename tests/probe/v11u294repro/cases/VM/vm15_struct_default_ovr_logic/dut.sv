// § castModTypeParamDefaultTs294
// a struct default overridden by a vector, and a string default
package pk; typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t; endpackage
module sub #(parameter type T = pk::s_t, parameter type S = string) (input logic [7:0] a, output logic [7:0] y, output string s);
  assign y = T'(a);
  initial s = S'("ab");
endmodule
module top(input logic [7:0] a, output logic [7:0] y1, y2, output string s1, s2);
  sub u1 (.a(a), .y(y1), .s(s1));
  sub #(.T(logic [7:0])) u2 (.a(a), .y(y2), .s(s2));
endmodule
