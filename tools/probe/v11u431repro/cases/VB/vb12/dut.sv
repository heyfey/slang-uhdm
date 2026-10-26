// § unitParamNameBindsDesign431 (a continuous-assignment left side net with the $unit name)
localparam CF = 2;
module top(input [3:0] c, output y);
wire CF;
assign CF = c[1];
assign y = CF;
endmodule
