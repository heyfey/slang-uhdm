// § dottedLhsVarOpRhsShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, output logic y);
  for (genvar i = 0; i < 2; i++) begin : g
    tp::h2d_t s;
    assign s.a_valid = a & b;
  end
  assign y = g[0].s.a_valid;
endmodule
module top(input logic a, input logic b, output logic y, output logic z);
  sock #(.N(2)) u_a (.a(a), .b(b), .y(y));
  sock #(.N(3)) u_b (.a(a), .b(b), .y(z));
endmodule
