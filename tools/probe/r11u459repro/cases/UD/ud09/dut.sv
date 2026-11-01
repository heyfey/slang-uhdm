// § defFlipUnszBasedRaw459
package p; parameter int I = 'h9; parameter logic [7:0] S = 'sh1f; parameter byte Y = 'b101; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
