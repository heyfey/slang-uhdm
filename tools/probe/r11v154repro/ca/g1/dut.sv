// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o);
  localparam int SEL_W = $clog2(N);
  assign o = x ? SEL_W'(1) : SEL_W'(2);
endmodule
module top(input logic x, output logic [3:0] o1, o2); dut #(4) a(x, o1); dut #(16) b(x, o2); endmodule
