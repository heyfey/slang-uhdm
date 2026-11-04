// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, input clk, output logic [3:0] y);
localparam CF = 1;
always_ff @(posedge clk) y[CF] <= c[CF];
endmodule
