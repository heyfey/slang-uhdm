// § defFlipUnszBasedRaw459
package p; parameter bit [27:0] D = 'b0101; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
