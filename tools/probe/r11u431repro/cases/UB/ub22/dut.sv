// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input CF, output logic y, output z);
always_comb y = CF;
assign z = CF;
endmodule
