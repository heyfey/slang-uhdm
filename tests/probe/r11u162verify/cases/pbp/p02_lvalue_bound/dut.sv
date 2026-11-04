// § psBoundPathFirstMember154
interface tif; localparam int W = 3; logic [7:0] d; endinterface
module m(tif sub, input logic clk, input logic [3:0] x, output logic [7:0] r);
  always_ff @(posedge clk) r[sub.W:0] <= x;
endmodule
module top(input logic clk, input logic [3:0] x, output logic [7:0] r); tif t(); m u(t, clk, x, r); endmodule
