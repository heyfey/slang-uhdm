// § errTypePortSyntaxRange440
module m #(parameter x = 4) (input wire [x-1:0][0:2] a, output var logic [x-1:0][0:2] q);
endmodule
module top; endmodule
