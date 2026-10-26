// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input [x-1:0] a);
endmodule
module top; m #(.x(4)) u(.a(4'h0)); endmodule
