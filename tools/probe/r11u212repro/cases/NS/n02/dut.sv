// § ndaSysCallNetTs212 — an unsigned net declared with an unsigned cast
module dut (input logic signed [9:0] i, output logic [6:0] o);
  wire [6:0] v = unsigned'(i[6:0]);
  assign o = v;
endmodule
