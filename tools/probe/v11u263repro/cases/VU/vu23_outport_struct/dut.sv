// § dottedLhsVarOpRhsShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output tp::h2d_t so);
  assign so.a_valid = ~a & b;
  assign so.d = c;
  assign so.a_opcode = op;
endmodule
module top(input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output tp::h2d_t y, output tp::h2d_t z);
  sock #(.N(2)) u_a (.a(a), .b(b), .c(c), .op(op), .so(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .c(c), .op(op), .so(z));
endmodule
