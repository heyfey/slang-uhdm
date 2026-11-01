// § defFlipUnszBasedRaw459
package p; parameter byte D = 'o17; parameter shortint E = 'O7; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
