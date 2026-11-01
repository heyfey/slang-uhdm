// § defFlipUnszBasedRaw459
package p; typedef logic [15:0] ht; parameter ht H = 'hab; parameter ht O = 'o17; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
