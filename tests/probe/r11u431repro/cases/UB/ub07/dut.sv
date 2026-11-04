// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
always_comb y = c[CF];
endmodule
