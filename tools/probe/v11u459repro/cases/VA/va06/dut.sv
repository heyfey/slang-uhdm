// § defFlipUnszBasedRaw459
package p; parameter bit [3:0] D = 'b0; parameter logic [15:0] E = 'B1; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
