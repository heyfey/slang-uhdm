// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 8) (input logic x, output logic [2:0] o);
  localparam int W = $clog2(N);
  if (N > 2) begin : g
    assign o = x ? W'(2) : W'(5);
  end
endmodule
