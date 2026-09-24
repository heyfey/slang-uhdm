// § wildcardConnRefSpan130
package pkg; typedef struct packed { logic [3:0] a; } s_t; endpackage
module sub(input pkg::s_t s, output logic [3:0] y);
  assign y = s.a;
endmodule
module top(input pkg::s_t s, output logic [3:0] y);
  sub u(.*);
endmodule
