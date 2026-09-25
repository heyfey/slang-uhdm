// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o);
  localparam int SEL_W = $clog2(N);
  localparam logic [3:0] C = SEL_W'(1);
  assign o = x ? C : SEL_W'(2);
endmodule
