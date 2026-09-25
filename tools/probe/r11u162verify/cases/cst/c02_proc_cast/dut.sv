// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic clk, input logic x, output logic [1:0] o);
  localparam int SW = $clog2(N);
  always_ff @(posedge clk) o <= x ? SW'(1) : SW'(3);
endmodule
