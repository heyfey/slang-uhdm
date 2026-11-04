// § modAliasTdAtBaseClone484 (module alias of a struct with a nested struct member and an enum member)
module top;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  typedef struct packed { in_t i; e_t e; logic [1:0] z; } op_t;
  typedef op_t op2_t;
  op2_t v;
  logic [9:0] o;
  assign v = 10'h15;
  assign o = v;
endmodule
