// § castModTypeParamDefaultTs294
// an instance overriding with a struct type, both instances
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module sub #(parameter type T = logic [7:0]) (input logic [7:0] a, output logic [7:0] y);
  assign y = T'(a);
endmodule
module top(input logic [7:0] a, output logic [7:0] y1, y2);
  sub u1 (.a(a), .y(y1));
  sub #(.T(pk::in_t)) u2 (.a(a), .y(y2));
endmodule
