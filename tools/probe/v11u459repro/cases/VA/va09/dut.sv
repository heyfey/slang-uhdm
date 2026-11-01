// § defFlipUnszBasedRaw459
package p; parameter logic [7:0] D = 'hc3; endpackage
module m #(parameter type T = int)(input logic clk); import p::*; T v; endmodule
module top; logic c; m #(byte) u(c); endmodule
