// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o, output logic [3:0] p);
  localparam int SEL_W = $clog2(N);
  assign o = x ? SEL_W'(1) : SEL_W'(2);
  assign p = SEL_W'(3);
endmodule
