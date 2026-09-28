// § ndaSysCallNetTs212 — $signed written as the system call in a net initializer
module dut (input logic [9:0] i, output logic [6:0] o);
  wire signed [6:0] v = $signed(i[6:0]);
  assign o = v;
endmodule
