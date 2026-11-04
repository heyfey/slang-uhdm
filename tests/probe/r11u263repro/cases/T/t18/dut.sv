// § dottedLhsElemSelShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; } h2d_t;
  typedef struct packed { h2d_t inner; logic z; } w_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input tp::op_e op, output logic y);
  struct packed { logic a_valid; logic [2:0] a_opcode; } tl_u_o [N+1];
  assign tl_u_o[N].a_opcode = 3'(N);
  assign tl_u_o[N].a_valid = a ^ b;
  always_comb y = tl_u_o[N].a_valid;
endmodule
module top(input logic a, input logic b, input tp::op_e op, output logic y, output logic z);
  sock #(.N(2)) u_a (.a(a), .b(b), .op(op), .y(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .op(op), .y(z));
endmodule
