// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 'b0101; endpackage
interface ifc #(A=8)(input logic clk); import p::*; endinterface
module top; logic c; ifc #(.A(4)) u(c); endmodule
