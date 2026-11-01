// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 'b0101; endpackage
module m (input logic clk); import p::*; endmodule
module top; logic c; m u(c); endmodule
