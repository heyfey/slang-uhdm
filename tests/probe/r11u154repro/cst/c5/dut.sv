// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [1:0] o);
  localparam int SEL_W = $clog2(N);
  logic [SEL_W-1:0] a;
  assign a = x ? SEL_W'(1) : SEL_W'(2);
  assign o = a;
endmodule
