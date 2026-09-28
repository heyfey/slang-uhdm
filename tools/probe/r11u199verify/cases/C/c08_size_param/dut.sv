// § castOperandLeafElab193 § connCastTsNamedByPort193
module sub #(parameter int N = 7) (input [N-1:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut #(parameter int W = 7) (input logic [9:0] i, output logic [7:0] o1, output logic [7:0] o2);
  logic [9:0] r;
  assign r = i;
  sub #(.N(W)) u1 (.d(W'(r)), .o(o1));
  sub #(.N(W+1)) u2 (.d((W+1)'(r)), .o(o2));
endmodule
