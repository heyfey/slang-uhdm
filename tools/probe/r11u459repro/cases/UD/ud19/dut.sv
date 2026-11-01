// § defFlipUnszBasedRaw459
package p; parameter bit [27:0] D = 'b0101; endpackage
program pr #(A=8)(input logic clk); import p::*; endprogram
module top; logic c; pr #(.A(4)) u(c); endmodule
