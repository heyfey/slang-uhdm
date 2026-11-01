// § defFlipUnszBasedRaw459
package p; parameter logic [7:0] D = 'sh1f; parameter logic signed [7:0] E = 'sb101; endpackage
module m #(A=8)(input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
