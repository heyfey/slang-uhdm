// § dottedLhsElemSelShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, output logic y);
  tp::h2d_t arr [N+1];
  tp::h2d_t s;
  assign arr[N].a_valid = a ^ b;
  assign s.a_valid = a | b;
  assign y = arr[N].a_valid & s.a_valid;
endmodule
module top(input logic a, input logic b, output logic y, output logic z);
  for (genvar k = 0; k < 2; k++) begin : gg
    sock #(.N(k+1)) u (.a(a), .b(b), .y());
  end
  sock #(.N(3)) u_b (.a(a), .b(b), .y(z));
  assign y = a;
endmodule
