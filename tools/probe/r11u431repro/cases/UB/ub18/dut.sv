// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output y);
wire CF;
assign CF = c[0];
assign y = CF;
endmodule
