// § defPkgStructParamMemberNames154 § tpOvrTypedefStructSpan152
package p; typedef struct { int unsigned A; int unsigned B; } cfg_t; localparam cfg_t DEF = '{A: 1, B: 2}; endpackage
module sub #(parameter type T = logic, parameter p::cfg_t C = p::DEF) (input T i, output logic [7:0] o);
  assign o = C.A + i.x;
endmodule
module tb(input logic [3:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; } my_t;
  my_t w;
  assign w.x = a;
  sub #(.T(my_t)) d(.i(w), .o(o));
endmodule
