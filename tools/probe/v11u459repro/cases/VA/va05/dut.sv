// § defFlipUnszBasedRaw459
package p; parameter logic [7:0] D = 'b1x0; parameter logic [7:0] E = 'hz; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
