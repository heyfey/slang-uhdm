// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic clk, input logic x, output logic [3:0] o);
  localparam int SEL_W = $clog2(N);
  always_ff @(posedge clk) o <= x ? SEL_W'(1) : SEL_W'(2);
endmodule
