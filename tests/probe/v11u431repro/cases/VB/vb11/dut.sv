// § unitParamNameBindsDesign431 (an unpacked array variable with the $unit name)
localparam CF = 2;
module top(input [3:0] c, output logic y);
logic [3:0] CF [2];
assign CF[0] = c;
assign CF[1] = ~c;
always_comb y = CF[1][2];
endmodule
