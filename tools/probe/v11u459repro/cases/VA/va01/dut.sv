// § defFlipUnszBasedRaw459
package p; parameter int D = 'b1; parameter int E = 'b0; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
