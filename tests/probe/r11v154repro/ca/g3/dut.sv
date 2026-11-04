// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o);
  localparam int SEL_W = $clog2(N);
  for (genvar i = 0; i < 1; i++) begin : g
    assign o = x ? SEL_W'(1) : SEL_W'(i);
  end
endmodule
