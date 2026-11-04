// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 16) (input logic x, output logic [7:0] o);
  localparam int SEL_W = $clog2(N);
  assign o = {SEL_W'(x), SEL_W'(3)};
endmodule
