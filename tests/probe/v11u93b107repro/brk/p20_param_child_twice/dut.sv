module child #(parameter int N = 2) (input logic [2*N-1:0] i, output logic [2*N-1:0] o);
  struct packed { logic a; logic b; } [N-1:0] x;
  assign x = i;
  assign o = x;
endmodule
module dut(input logic [5:0] i, output logic [5:0] o);
  child #(.N(1)) u0(.i(i[1:0]), .o(o[1:0]));
  child #(.N(2)) u1(.i(i[5:2]), .o(o[5:2]));
endmodule
