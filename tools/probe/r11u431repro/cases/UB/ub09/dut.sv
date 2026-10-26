// § unitParamNameBindsDesign431
localparam CF = 2;
module top #(parameter CF = 1) (input [3:0] c, output logic y);
always_comb y = c[CF];
endmodule
