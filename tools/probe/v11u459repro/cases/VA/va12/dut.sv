// § defFlipUnszBasedRaw459
package p; parameter logic [7:0] D = 'h3c; endpackage
module m #(A=8)(input logic clk, output logic [7:0] y); assign y = p::D; endmodule
module top; logic c; logic [7:0] y; m u(c, y); endmodule
