// § elabCastSharesDeclRef154
module sub(input logic [1:0] i, output logic [1:0] o); assign o = i; endmodule
module dut #(parameter int unsigned N = 4) (input logic x, output logic [1:0] o);
  localparam int SEL_W = $clog2(N);
  logic [1:0] t;
  assign t = x ? SEL_W'(3) : SEL_W'(0);
  sub u(.i(t), .o(o));
endmodule
