// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] CF, output logic y);
always_comb y = CF[0];
endmodule
