// § defFlipUnszBasedRaw459
package p; typedef logic [5:0] t6; parameter t6 D = 'b101; parameter t6 E = 'h2; endpackage
module m #(parameter p::t6 A = 0)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(1)) u(c); m #(.A(2)) v(c); endmodule
