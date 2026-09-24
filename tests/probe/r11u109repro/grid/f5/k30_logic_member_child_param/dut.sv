module ch #(parameter int N = 2) (input logic [2*N-1:0] i, output logic [2*N-1:0] o);
  struct packed { logic a; logic b; } [N-1:0] x;
  assign x = i;
  assign o = x;
endmodule
module dut(input logic [5:0] i, output logic [5:0] o);
  ch #(.N(3)) u(.i(i), .o(o));
endmodule
