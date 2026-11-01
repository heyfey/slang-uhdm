// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 'b0101; endpackage
module m #(parameter int A=8, parameter p::ft L = p::D)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
