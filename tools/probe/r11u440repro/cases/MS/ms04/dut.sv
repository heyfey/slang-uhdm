// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input logic [x-1:0] a, output wire [x-1:0] b, input bit [1:0][x-1:0] c);
endmodule
module top; endmodule
