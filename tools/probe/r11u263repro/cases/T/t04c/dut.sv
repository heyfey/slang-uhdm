// § dottedLhsElemSelShares263
module sock #(parameter int unsigned N = 4) (input logic a, input logic b, output logic y);
  struct packed { logic a_valid; logic [3:0] a_opcode; } tl_u_o [N+1];
  assign tl_u_o[N].a_valid = a & b;
  always_comb y = tl_u_o[N].a_valid;
endmodule
module top(input logic a, input logic b, output logic y);
  sock #(.N(2)) u_a (.a(a), .b(b), .y(y));
endmodule
