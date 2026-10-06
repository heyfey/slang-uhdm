// § dottedLhsElemSelShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; } h2d_t;
  typedef struct packed { h2d_t inner; logic z; } w_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input tp::op_e op, output logic y);
  tp::h2d_t s;
  assign s.a_valid = (N > 2) ? a : b;
  assign s.a_opcode = op;
  always_comb y = s.a_valid;
endmodule
module top(input logic a, input logic b, input tp::op_e op, output logic y, output logic z);
  sock #(.N(2)) u_a (.a(a), .b(b), .op(op), .y(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .op(op), .y(z));
endmodule
