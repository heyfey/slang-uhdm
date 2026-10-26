// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
logic [1:0] CF;
always_comb y = c[CF];
endmodule
