// § dottedLhsElemSelShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output tp::h2d_t so [2]);
  assign so[1].a_valid = ~a & b;
  assign so[0].d = c - N;
  assign so[0].a_valid = a;
endmodule
module top(input logic a, input logic b, input logic [3:0] c, input tp::op_e op, output tp::h2d_t y [2], output tp::h2d_t z [2]);
  sock #(.N(2)) u_a (.a(a), .b(b), .c(c), .op(op), .so(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .c(c), .op(op), .so(z));
endmodule
