// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 28'b0101; parameter ft E = 'd5; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
