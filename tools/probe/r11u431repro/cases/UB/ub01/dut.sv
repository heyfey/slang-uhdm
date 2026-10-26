// § unitParamNameBindsDesign431
localparam CF = 0, VF = 1;
module top(input [3:0] c, output logic y);
always_comb y = c[CF];
endmodule
