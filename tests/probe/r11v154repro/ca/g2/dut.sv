// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o);
  localparam int unsigned SEL_W = $clog2(N) + 1;
  localparam int unsigned K_W = SEL_W + 1;
  assign o = x ? SEL_W'(1) : K_W'(2);
endmodule
