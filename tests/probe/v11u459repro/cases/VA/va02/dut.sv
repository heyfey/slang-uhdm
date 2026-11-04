// § defFlipUnszBasedRaw459
package p; parameter int D = 'hFF; parameter int unsigned E = 'h7; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
