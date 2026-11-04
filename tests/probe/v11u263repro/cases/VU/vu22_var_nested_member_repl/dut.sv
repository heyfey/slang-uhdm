// § dottedLhsVarOpRhsShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output logic y);
  typedef struct packed { tp::h2d_t h; logic q; } w_t;
  w_t s;
  assign s.h.d = c ^ {4{a}};
  always_comb y = s.h.d[0];
endmodule
module top(input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output logic y, output logic z);
  sock #(.N(2)) u_a (.a(a), .b(b), .c(c), .op(op), .y(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .c(c), .op(op), .y(z));
endmodule
