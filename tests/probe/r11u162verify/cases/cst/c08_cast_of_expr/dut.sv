// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic [3:0] a, output logic [1:0] o);
  localparam int SEL_W = $clog2(N);
  assign o = SEL_W'(a + 1) ^ SEL_W'(a >> 2);
endmodule
