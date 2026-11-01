// § defFlipUnszBasedRaw459
package p; parameter logic [7:0] D = 'd200; parameter int E = 'd5; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
