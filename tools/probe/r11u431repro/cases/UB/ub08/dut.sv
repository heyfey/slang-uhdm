// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output y);
localparam CF = 1;
assign y = c[CF];
endmodule
