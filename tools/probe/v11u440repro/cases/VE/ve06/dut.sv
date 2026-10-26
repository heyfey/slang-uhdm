// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input clk, input [x-1:0] d);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
