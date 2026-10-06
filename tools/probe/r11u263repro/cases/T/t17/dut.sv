// § dottedLhsElemSelShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; } h2d_t;
  typedef struct packed { h2d_t inner; logic z; } w_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, input tp::op_e op, output logic y);
  wire tp::h2d_t wn [N+1];
  assign wn[N].a_valid = 1'b1;
  assign wn[N].a_opcode = tp::Get;
  assign y = wn[N].a_valid;
endmodule
module top(input logic a, input logic b, input tp::op_e op, output logic y, output logic z);
  sock #(.N(2)) u_a (.a(a), .b(b), .op(op), .y(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .op(op), .y(z));
endmodule
