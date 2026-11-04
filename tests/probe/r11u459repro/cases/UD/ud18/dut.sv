// § defFlipUnszBasedRaw459
package p; typedef bit [27:0] ft; parameter ft D = 'b0101; localparam ft E = 'hf; endpackage
module m #(A=8)(input logic clk); import p::D; import p::E; endmodule
module top; logic c; m #(.A(4)) u(c); endmodule
