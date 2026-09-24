// § contAssignLhsTsUnparented134
module top(input logic c, output logic [1:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef struct packed { e_t k; logic v; } s_t;
  s_t s;
  assign s.k = c ? B : C;
  assign s.v = c;
  assign o = s.k;
endmodule
