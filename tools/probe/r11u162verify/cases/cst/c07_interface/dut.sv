// § elabCastSharesDeclRef154
interface tif #(parameter int unsigned N = 8) (input logic x);
  localparam int SEL_W = $clog2(N);
  logic [2:0] o;
  assign o = x ? SEL_W'(5) : SEL_W'(2);
endinterface
module top(input logic x, output logic [2:0] o); tif t(x); assign o = t.o; endmodule
