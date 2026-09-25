// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [1:0] o);
  localparam int SEL_W = $clog2(N);
  wire [1:0] w = x ? SEL_W'(2) : SEL_W'(1);
  assign o = w;
endmodule
