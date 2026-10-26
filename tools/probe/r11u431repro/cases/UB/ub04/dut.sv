// § unitParamNameBindsDesign431
localparam CF = 0;
module top(input [3:0] c, output logic y, output z);
assign z = c[CF];
always_comb y = CF;
endmodule
