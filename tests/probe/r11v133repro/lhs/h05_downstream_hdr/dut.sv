// § impPaLhsDisjointClone133
package p; parameter int X = 4; parameter int Y = 3; endpackage
module m import p::*; #(parameter int Q = X) (input logic clk, input logic [Q-1:0] d, output logic [Q+Y-1:0] o);
  always_ff @(posedge clk) o <= {d, Y[Y-1:0]} + X;
endmodule
module dut(input logic clk, input logic [3:0] d, output logic [6:0] o); m u(.clk(clk), .d(d), .o(o)); endmodule
