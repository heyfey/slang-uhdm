module sub #(parameter W = 1) (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) | 8'(e);
endmodule
module dut (input logic [9:0] i, output logic [7:0] o2);
  logic [9:0] r;
  assign r = i;
  sub u2 ({r[3:0], r[2:0]}, r[6:0], o2);
endmodule
