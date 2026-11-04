// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 'b0101; endpackage
module m #(A=8)(input logic clk); import p::*; class C; endclass endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
